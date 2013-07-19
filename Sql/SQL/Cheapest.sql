/*
获得酒店最便宜的单价
Test: select dbo.[f_Gen_HotelCheapest]('1','1','1','RMB')
*/
ALTER function [dbo].[f_Gen_HotelCheapest]
(
	@hotelID nvarchar(18),
	@roomtype nvarchar(18),
	@marketID nvarchar(18),
	@ccy varchar(10)
) returns money
as 
begin
/*Test*/
	--declare @hotelID nvarchar(18)
	--declare @roomtype nvarchar(18)
	--declare @marketID nvarchar(18)
	--declare @ccy varchar(10)
	--set @HotelID='1'
	--set @roomtype='1'
	--set @marketID='1'
	--set @ccy='HKD'
	
	declare @retval money
	
	select @retval=min(dbo.f_Gen_Exchange(ri.ItemPrice,ri.CCYCode,@ccy))
	from Gen_RoomItem ri
	inner join Gen_Items i on ri.ItemID =i.ItemID
	where ri.MarketID=1 and i.IsRoom=1 and ri.PriceDate>GETDATE()
	and RoomID in(
		select rm.RoomID
		from Gen_Rooms rm
		where rm.HotelID=@hotelID and rm.RoomTypeID=@roomtype
	)
	
	return @retval
end