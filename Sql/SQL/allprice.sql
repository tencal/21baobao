/*
exec [sp_Gen_RoomPrices] '1','2009-06-10','2009-06-12','1,2','1','HKD',0,0
*/
alter proc [dbo].[sp_Gen_RoomPrices]
@HotelID nvarchar(18),
@checkin date,
@checkout date,
@roomtypelist nvarchar(40),
@marketID nvarchar(18),
@ccyCode varchar(3),
@confirmType int, --还没用
@noRm int        --还没用

as 
	/*Test*/
	set @HotelID='1'
	set @checkin='2009-06-10'
	set @checkout='2009-06-12'
	set @roomtypelist='1,2'
	set @marketID='1'
	set @ccyCode='HKD'

	/*get all rooms by Hotel ID */ 
	select rm.RoomID,
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
	select ri.RoomID,ri.ItemID,ri.MarketID,ri.PriceDate,ri.ItemTBA,ri.Available,
	dbo.f_Gen_Exchange(ri.ItemPrice,ri.CCYCode,@ccyCode) as ItemPrice,
	i.ItemlName,i.ItemCSName,i.ItemCTName
	into #pris
	from Gen_RoomItem ri
	inner join Gen_Items i on ri.ItemID=i.ItemID
	where ri.MarketID=@marketID
	and (ri.RoomID in (select distinct RoomID from #rms))

	/* create dates*/
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
	select *  into #DateItem from #Tdates,
	(select distinct RoomID,ItemID from #pris) items
	
	/*Result */
	select distinct CategoryID,CategoryName,CategoryCSName,CategoryName from #rms

	select #DateItem.PriceDate,#DateItem.ItemID,
		#pris.ItemPrice,#pris.ItemCSName,#pris.ItemCTName,isnull(#pris.ItemTBA,1) as ItemTBA,#pris.Available,
		#rms.*
	from #DateItem
	left join #pris on #DateItem.PriceDate =#pris.PriceDate 
	and #DateItem.RoomID=#pris.RoomID and #DateItem.ItemID=#pris.ItemID
	inner join #rms on #DateItem.RoomID=#rms.RoomID
	order by PriceDate,ItemID

	/* drop all temp table*/
	--select * from #rms
	--select * from #pris
	--select * from #Tdates
	--select * from #DateItem

	drop table #rms
	drop table #pris
	drop table #Tdates
	drop table #DateItem
	
/*--------------------*/
