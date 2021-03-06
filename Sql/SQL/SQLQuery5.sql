USE [TExpert]
GO
/****** Object:  StoredProcedure [dbo].[sp_Internet_RoomPrices]    Script Date: 10/06/2009 10:14:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Author: Tencal Liao
Description: get price for internet
Test: exec [sp_Internet_RoomPrices] '200406170081','2009-08-20',3,'','1','TH','HKD'
*/
--ALTER proc [dbo].[sp_Internet_RoomPrices]
--@hotelID nvarchar(18),
--@checkin date,
--@nights int,
--@roomtypelist nvarchar(40) = '',
--@itemList nvarchar(20) = '',
--@userCountryID nvarchar(18) = '',
--@ccyCode varchar(3)
--as 

/*Test*/
	declare @hotelID nvarchar(18)
	declare @checkin date
	declare @nights int
	declare @roomtypelist nvarchar(40)
	declare @itemList nvarchar(20)
	declare @userCountryID nvarchar(18)
	declare @ccyCode varchar(3)
	
	set @HotelID='200406170081'
	set @checkin='2009-08-20'
	set @nights=3
	set @roomtypelist=''
	set @itemList='1,3,'
	set @userCountryID='TH'
	set @ccyCode='HKD'

/*初始化数据*/
	declare @checkout date
	declare @market nvarchar(max)
	declare @itemCount int

	set @checkout=DATEADD(D, @nights, @checkIn)
	
	select @itemCount = COUNT(0) from Gen_Items i where (isnull(@itemList,'')='' or CHARINDEX(','+CONVERT(nvarchar, i.ItemID)+',',','+@itemList+',')>0)
	
	select @market=@market+mc.MarketID+',' from Gen_MarketCountry mc 
	where isnull(@userCountryID,'')!='' and mc.CountryID = @userCountryID
	
	/* create dates between checkin and checkou*/
	create table #Tdates
	(
		PriceDate date null
	)

	declare @check date
	set @check =@checkin
	
	while(@check<@checkout)
	begin
		insert into #Tdates values(@check)
		set @check = DATEADD("day", 1, @check)
	end
	
	/*create temp table #DateItem*/
	select #Tdates.*,
		i.ItemName,i.ItemCSName,i.ItemCTName,i.IsRoom
	into #DateItem 
	from #Tdates,Gen_Items i
	where (isnull(@itemList,'')='' or CHARINDEX(','+CONVERT(nvarchar, i.ItemID)+',',','+@itemList+',')>0)

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
	select ri.RoomID, ri.ItemID, ri.MarketID,ri.PriceDate,max(ri.ItemTBA) as ItemTBA,
		(min(ri.Consignment)-min(ri.Sold)-min(ri.Reserved)-min(ri.Hold)) as Available,
		MIN(dbo.f_Gen_Exchange(ri.ItemPrice,ri.CCYCode,@ccyCode)+dbo.f_Internet_GetMarkup(ri.ItemID,ri.RoomID,ri.MarketID,@ccyCode)) as ItemPrice,
		max(i.ItemName) as ItemName,max(i.ItemCSName) as ItemCSName,max(i.ItemCTName)as ItemCTName,i.IsRoom,
		ri.SupplierCode,null as PromotionID
	into #priAll
	from Gen_RoomItem ri
	inner join Gen_Items i on ri.ItemID=i.ItemID
	where (@market like '%'+ri.MarketID+',%' or ISNULL(@market,'')='')
	and (ri.RoomID in (select distinct RoomID from #rms))
	and (ri.PriceDate>=@checkin and ri.PriceDate<@checkout)
	and ri.ItemTBA=0
	group by ri.RoomID, ri.ItemID, ri.MarketID,ri.PriceDate,ri.SupplierCode,i.IsRoom
	union
	SELECT pr.RoomID,pr.ItemID,pc.MarketID,#Tdates.PriceDate,pr.ItemTBA,
		999 as Available, pr.ItemPrice, i.ItemName,i.ItemCSName,i.ItemCTName,i.IsRoom,
		p.SupplierCode,p.PromotionID
	FROM Gen_Promotion p
		INNER JOIN Gen_PromotionPrice pr ON pr.PromotionID = p.PromotionID
		Left JOIN Gen_PromotionCondition pc ON pc.PromotionID = p.PromotionID
		inner join #Tdates on #Tdates.PriceDate>= p.PriceStartDate and #Tdates.PriceDate<=p.PriceEndDate
		inner join Gen_Items i on pr.ItemID=i.ItemID
	WHERE (@market like '%'+pc.MarketID+',%' or ISNULL(@market,'')='')
		AND(ISNULL(@itemList,'')='' or CHARINDEX(',' + pr.ItemID + ',',',' + @itemList + ',')>0) 
		AND DATEDIFF(D,pc.PromotionStartDate,GETDATE()) >= 0 AND DATEDIFF(D,pc.PromotionEndDate,GETDATE()) <= 0 
		AND( 
			(pc.[Type]=0 AND DATEDIFF(D, p.PriceStartDate, @checkIn) >= 0 AND DATEDIFF(D, p.PriceEndDate, @checkIn) <= 0) 
			OR
			(pc.[Type]=0 AND DATEDIFF(D, @checkIn,p.PriceStartDate) >= 0 AND DATEDIFF(D, @checkOut,p.PriceStartDate) <= 0) 
			OR
			(pc.[Type]=1 AND DATEDIFF(D, p.PriceStartDate, @checkIn) >= 0 AND DATEDIFF(D, p.PriceEndDate, @checkOut) <= 0)
			OR
			(pc.[Type]=1 AND DATEDIFF(D, @checkIn,p.PriceStartDate) >= 0 AND DATEDIFF(D, @checkOut,p.PriceEndDate) <= 0)
		)
		and ISNULL(pc.MinNight,0)<=@nights
		and ISNULL(pc.Night,0)<=@nights
		and (pc.MaxNight is null or pc.MaxNight>=@nights)
		and pr.ItemTBA =0
		
	select * from #priAll

	--第三层房间时间段内所有项单价和
	select priDaySum.RoomID,MarketID,SupplierCode,SUM(SumPrice) as SumPrice
	from(
		--第二层按RoomID,MarketID,SupplierCode,ItemID 房间时间段内每项单价和
		select priDay.RoomID,MarketID,SupplierCode,ItemID,
			SUM(MinItemPrice) as SumPrice
		from(
			--第一层按RoomID,MarketID,SupplierCode,ItemID,PriceDate 取每天最小单价
			select RoomID, ItemID, MarketID,PriceDate,
				MIN(case when ISNULL()='' then 
					dbo.f_Gen_Exchange(ItemPrice,CCYCode,@ccyCode)+dbo.f_Internet_GetMarkup(ItemID,RoomID,MarketID,@ccyCode)
					else end)
					) as ItemPrice,
				ri.SupplierCode
			from #priAll ri
			group by ri.RoomID, ri.ItemID, ri.MarketID,ri.PriceDate,ri.SupplierCode,i.IsRoom

		)priDay
		group by RoomID,MarketID,SupplierCode,ItemID
		having count(0)>=@nights
	)priDaySum
	group by RoomID,MarketID,SupplierCode
	having COUNT(0)>=@itemCount
		
	select a.SumPrice,a.RoomID,
	from #RMarkSup a,(select b.RoomID,MIN(b.SumPrice) as MinSumPrice from #RMarkSup b group by b.RoomID) c
	where a.SumPrice=c.MinSumPrice and a.RoomID= c.RoomID
	group by a.SumPrice,a.RoomID
	
	select ri.RoomID,ri.ItemID,ri.MarketID,ri.PriceDate,
		max(ri.ItemTBA) as ItemTBA,
		(min(ri.Consignment)-min(ri.Sold)-min(ri.Reserved)-min(ri.Hold)) as Available,
		dbo.f_Gen_GetItemPrice(ri.RoomID, ri.ItemID, ri.MarketID,ri.PriceDate,@ccyCode, ri.SupplierCode) + 
		dbo.f_Gen_GetMarkup(ri.ItemID, ri.RoomID, ri.MarketID, max(ri.CCYCode)) as ItemPrice,
		max(i.ItemName) as ItemName,max(i.ItemCSName) as ItemCSName,max(i.ItemCTName) as ItemCTName,
		i.IsRoom,ri.SupplierCode,null as PromotionID
	into #pris
	from Gen_RoomItem ri
	inner join Gen_Items i on ri.ItemID=i.ItemID
	where (@market like '%'+ri.MarketID+',%' or ISNULL(@market,'')='')
	and (ri.RoomID in (select distinct RoomID from #rms))
	and (isnull(@itemList,'')='' or CHARINDEX(','+CONVERT(nvarchar, i.ItemID)+',',','+@itemList+',')>0)
	and (ri.PriceDate>=@checkin and ri.PriceDate<@checkout)
	group by ri.RoomID, ri.ItemID, ri.MarketID,ri.PriceDate,i.IsRoom,ri.SupplierCode
	
	--select * 
	--from #DateItem 
	--left join #pris on #DateItem.PriceDate=#pris.PriceDate and #DateItem.ItemID=#pris.ItemID
	--group by ri.RoomID, ri.MarketID,i.IsRoom,ri.SupplierCodeææ
	
/* For promotion insert TBA for days has promotion*/
	insert into #pris(RoomID,ItemID,MarketID,PriceDate,ItemTBA,Available,IsRoom,SupplierCode,PromotionID)
	select #rms.RoomID,i.ItemID,'',@checkin,1,999,i.IsRoom,'',''
	from #rms
	inner join Gen_Items i on (isnull(@itemList,'')='' or CHARINDEX(','+CONVERT(nvarchar, i.ItemID)+',',','+@itemList+',')>0)
	where (#rms.RoomID not in(select #pris.RoomID from #pris))
		--and dbo.f_Gen_CheckHasPromotion(@checkin ,@checkout,#rms.RoomID,@itemList,'', '')=1
		and dbo.f_Gen_CheckHotelHasPromotion(@checkIn ,@nights,'',#rms.RoomID,'','','')=1




	
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
		#rms.Notice,#rms.NoticeCS,#rms.NoticeCT,'993903' as MarketID,'200506210114' as SupplierCode
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
	drop table #RMarkSup
	drop table #priAll
	
/*--------------------*/
