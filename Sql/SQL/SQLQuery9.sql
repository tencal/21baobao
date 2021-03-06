/*
Author: Tencal Liao
Description: get price for TC
Test: exec [sp_Gen_RoomPrices] '200406170081','2009-08-20','2009-08-25','','1','993903','HKD',0,0,'HHHH'
Date: 2009/08/13 Tencal add promotion date that has no reguar price 
Modify: 2009-8-18 by ruson: add supplierCode param
*/
Create proc [dbo].[sp_Internet_RoomPrices]
@hotelID nvarchar(18),
@checkin date,
@nights int,
@roomtypelist nvarchar(40),
@itemList nvarchar(20),
@userCountryID nvarchar(18),
@marketID nvarchar(18),
@ccyCode varchar(3)
as 

/*Test*/
	--declare @hotelID nvarchar(18)
	--declare @checkin date
	--declare @checkout date
	--declare @roomtypelist nvarchar(40)
	--declare @itemList nvarchar(20)
	--declare @marketID nvarchar(18)
	--declare @ccyCode varchar(3)
	
	--set @HotelID='1'
	--set @checkin='2009-06-10'
	--set @checkout='2009-06-12'
	--set @roomtypelist='1,2'
	--set @marketID='1'
	--set @ccyCode='HKD'

/*初始化数据*/
declare @checkout date

set @checkout=DATEADD(D, @nights, @checkIn)

/*get all rooms by Hotel ID */ 
	select rm.RoomID,rm.Notice,rm.NoticeCS,rm.NoticeCT,
	rmc.CategoryID,rmc.CategoryName,rmc.CategoryCSName,rmc.CategoryCTName,
	rmt.RoomTypeID,rmt.RmtName,rmt.RmtCSName,rmt.RmtCTName
	into #rms
	from Gen_Rooms rm
	inner join Gen_RoomCategory rmc on rm.CategoryID=rmc.CategoryID
	inner join Gen_RoomType rmt on rm.RoomTypeID =rmt.RoomTypeID
	where (HotelID=@HotelID) and
	(isnull(@roomtypelist,'')='' or CHARINDEX(','+rmt.RoomTypeID+',',','+@roomtypelist+',')>0)
	and (rm.StatusID='0')

/* get all price */
	select ri.RoomID,ri.ItemID,ri.MarketID,ri.PriceDate,
		max(ri.ItemTBA) as ItemTBA,
		(max(ri.Consignment)-max(ri.Sold)-max(ri.Reserved)-max(ri.Hold)) as Available,
		dbo.f_Gen_GetItemPrice(ri.RoomID, ri.ItemID, ri.MarketID,ri.PriceDate,@ccyCode, @supplierCode) + dbo.f_Gen_GetMarkup(ri.ItemID, ri.RoomID, ri.MarketID, max(ri.CCYCode)) as ItemPrice,
		max(i.ItemName) as ItemName,max(i.ItemCSName) as ItemCSName,max(i.ItemCTName) as ItemCTName,i.IsRoom
	into #pris
	from Gen_RoomItem ri
	inner join Gen_Items i on ri.ItemID=i.ItemID
	where ri.MarketID=@marketID
	and ri.SupplierCode = @supplierCode
	and (ri.RoomID in (select distinct RoomID from #rms))
	and (isnull(@itemList,'')='' or CHARINDEX(','+CONVERT(nvarchar, i.ItemID)+',',','+@itemList+',')>0)
	and (ri.PriceDate>=@checkin and ri.PriceDate<@checkout)
	group by ri.RoomID, ri.ItemID, ri.MarketID,ri.PriceDate,i.IsRoom
	
/* For promotion insert TBA for days has promotion*/
	insert into #pris(RoomID,ItemID,MarketID,PriceDate,ItemTBA,Available,IsRoom)
	select #rms.RoomID,i.ItemID,@marketID,@checkin,1,0,i.IsRoom
	from #rms
	inner join Gen_Items i on (isnull(@itemList,'')='' or CHARINDEX(','+CONVERT(nvarchar, i.ItemID)+',',','+@itemList+',')>0)
	where (#rms.RoomID not in(select #pris.RoomID from #pris))
		and dbo.f_Gen_CheckHasPromotion(@checkin ,@checkout,#rms.RoomID,@itemList,@marketID, @supplierCode)=1

/* create dates between checkin and checkou*/
	create table #Tdates
	(
		PriceDate date null
	)

	declare @check date
	declare @sql nvarchar(400)
	set @check =@checkin
	
	while(@check<@checkout)
	begin
		insert into #Tdates values(@check)
		set @check = DATEADD("day", 1, @check)
	end

/*create temp table #DateItem*/
	select #Tdates.*,rmi.*,
		i.ItemName,i.ItemCSName,i.ItemCTName,i.IsRoom
	into #DateItem 
	from #Tdates,(select distinct RoomID,ItemID from #pris) rmi
	inner join Gen_Items i on rmi.ItemID=i.ItemID
	
/*Result */
	--Result of room types
	select distinct #rms.RoomTypeID,#rms.RmtName,#rms.RmtCSName,#rms.RmtCTName
	from #rms
	where #rms.RoomID in (select RoomID from #DateItem where IsRoom=1)
	
	--result of room Category
	select distinct #rms.RoomID,#rms.CategoryID,#rms.RoomTypeID,CategoryName,CategoryCSName,CategoryCTName
	from #rms
	where #rms.RoomID in (select RoomID from #DateItem where IsRoom=1)
	order by #rms.RoomTypeID
	
	--result of prices 价格明细表
	select #DateItem.PriceDate,#DateItem.ItemID,#DateItem.ItemName,#DateItem.ItemCSName,#DateItem.ItemCTName,#DateItem.IsRoom,
		#pris.ItemPrice,isnull(#pris.ItemTBA,1) as ItemTBA,#pris.Available,
		#rms.RoomID,#rms.CategoryID,#rms.RoomTypeID,#rms.RmtName,#rms.RmtCSName,#rms.RmtCTName
	into #picelist
	from #DateItem
	left join #pris on #DateItem.PriceDate =#pris.PriceDate 
	and #DateItem.RoomID=#pris.RoomID and #DateItem.ItemID=#pris.ItemID
	inner join #rms on #DateItem.RoomID=#rms.RoomID
	order by PriceDate,ItemID

	select * from #picelist ------返回价格明细表
	
	--创建价格汇总表
	select RoomID,CategoryID,RoomTypeID,sum(isnull(ItemPrice,null))as PriceSum,SUM(ItemTBA) TBASum ,
		SUM(convert(int,IsRoom)) as IsRoom , dbo.sp_Gen_getstr(RoomID,CategoryID,RoomTypeID) as ItemIDList
	into #priceTotal
	from #picelist
	group by RoomID,CategoryID,RoomTypeID
	
	select #priceTotal.* ,
		rmt.RmtName,rmt.RmtCSName,rmt.RmtCTName,
		ct.CategoryName,ct.CategoryCSName,ct.CategoryCTName ,
		#rms.Notice,#rms.NoticeCS,#rms.NoticeCT
	from #priceTotal
	inner join Gen_RoomType rmt on #priceTotal.RoomTypeID =rmt.RoomTypeID
	inner join Gen_RoomCategory ct on #priceTotal.CategoryID =ct.CategoryID
	inner join #rms on #priceTotal.RoomID=#rms.RoomID
	where IsRoom>0

/* drop all temp table*/
	--select * from #rms
	--select * from #pris
	--select * from #Tdates
	--select * from #DateItem
	--select * from #picelist
	--select * from #priceTotal

	drop table #rms
	drop table #pris
	drop table #Tdates
	drop table #DateItem
	drop table #picelist
	drop table #priceTotal
	
/*--------------------*/
