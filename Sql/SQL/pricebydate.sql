
/*
exec [sp_Gen_RoomPriceByDate] '1','2009-06-10','1','1,2,3','1','RMB',1
*/
alter proc sp_Gen_RoomPriceByDate
@hotelID nvarchar(18),
@priceDate date,
@roomtypelist nvarchar(40),
@itemList nvarchar(20),
@marketID nvarchar(18),
@ccyCode varchar(3),
@needHeadName bit
as
/*Test*/
	--set @HotelID='1'
	--set @priceDate='2009-06-10'
	--set @roomtypelist='1'
	--set @itemList='1,2,3'
	--set @marketID='1'
	--set @ccyCode='HKD'

/*get all rooms by Hotel ID */ 
	select rm.RoomID,
	rmc.CategoryID,rmc.CategoryName,rmc.CategoryCSName,rmc.CategoryCTName,
	--rmt.RoomTypeID,rmt.RmtName,rmt.RmtCSName,rmt.RmtCTName,
	i.ItemID,i.ItemName,i.ItemCSName,i.ItemCTName
	into #rmItems
	from Gen_Rooms rm
	inner join Gen_RoomCategory rmc on rm.CategoryID=rmc.CategoryID
	--inner join Gen_RoomType rmt on rm.RoomTypeID =rmt.RoomTypeID
	inner join dbo.Gen_RoomItem ri on rm.RoomID = ri.RoomID
	inner join dbo.Gen_Items i on ri.ItemID = i.ItemID
	where (HotelID=@HotelID) and
	(isnull(@roomtypelist,'')='' or CHARINDEX(','+rm.RoomTypeID+',',','+@roomtypelist+',')>0)
	and (rm.StatusID='0')
	and ri.MarketID = @marketID
	and (isnull(@itemList,'')='' or CHARINDEX(','+CONVERT(nvarchar, i.ItemID)+',',','+@itemList+',')>0)
	
	

/* get all price */
	select ri.RoomID,ri.ItemID,ri.MarketID,ri.PriceDate,ri.ItemTBA,ri.Available,
	dbo.f_Gen_Exchange(ri.ItemPrice,ri.CCYCode,@ccyCode) as ItemPrice,
	i.ItemName,i.ItemCSName,i.ItemCTName
	into #pris
	from Gen_RoomItem ri
	inner join Gen_Items i on ri.ItemID=i.ItemID
	where ri.MarketID=@marketID and ri.PriceDate = @priceDate
	and (ri.RoomID in (select distinct RoomID from #rms))
	and (isnull(@itemList,'')='' or CHARINDEX(','+CONVERT(nvarchar, i.ItemID)+',',','+@itemList+',')>0)
	
/*Result */
	if(ISNULL(@needHeadName,1)=1)
		select * from #rmItems 
		left join #pris on #rmItems.RoomID=#pris.RoomID
		and #rmItems.ItemID=#pris.ItemID
	else
		select ItemPrice from #rmItems 
		left join #pris on #rmItems.RoomID=#pris.RoomID
		and #rmItems.ItemID=#pris.ItemID

/* drop all temp table*/
	--select * from #rms
	--select * from #pris

	drop table #rmItems
	drop table #pris
	
/*--------------------*/