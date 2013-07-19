/*
exec sp_Gen_RoomItems '1','1','1,2,3','1'
*/
alter proc sp_Gen_RoomItems
@hotelID nvarchar(18),
@roomtypelist nvarchar(40),
@itemList nvarchar(20),
@marketID nvarchar(18)
as
/*Test*/
	--set @HotelID='1'
	--set @roomtypelist='1,2'
	--set @itemList='1,2,3'
	--set @marketID='1'

/*get all rooms with items */ 
	select rm.RoomID,
	rmc.CategoryID,rmc.CategoryName,rmc.CategoryCSName,rmc.CategoryCTName,
	--rmt.RoomTypeID,rmt.RmtName,rmt.RmtCSName,rmt.RmtCTName,
	i.ItemID,i.ItemName,i.ItemCSName,i.ItemCTName
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
	