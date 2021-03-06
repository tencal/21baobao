USE [TExpert]
GO
/****** Object:  UserDefinedFunction [dbo].[f_Gen_HotelCheapest]    Script Date: 07/29/2009 15:46:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
获得酒店最便宜的单价
Test: select dbo.[f_Gen_HotelCheapest]('200904159664','1','993903','HCK')
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
	declare @itemID nvarchar(18)
	declare @roomID nvarchar(18)
	
	select @retval=min(dbo.f_Gen_Exchange(ri.ItemPrice,ri.CCYCode,@ccy))
	from Gen_RoomItem ri
	inner join Gen_Items i on ri.ItemID =i.ItemID
	inner join Gen_Rooms rm on rm.RoomID=ri.RoomID
	where ri.MarketID=@marketID and i.IsRoom=1 and ri.PriceDate>GETDATE()
	and rm.HotelID=@hotelID and rm.RoomTypeID=@roomtype
	
	
	--select top 1 @itemID = ri.ItemID, @roomID = ri.RoomID
	--from Gen_RoomItem ri
	--inner join Gen_Items i on ri.ItemID =i.ItemID
	--inner join Gen_Rooms rm on rm.RoomID=ri.RoomID
	--where ri.MarketID=@marketID and i.IsRoom=1 and ri.PriceDate>GETDATE()
	--and rm.HotelID=@hotelID and rm.RoomTypeID=@roomtype 
	--ORDER BY ri.ItemPrice ASC
	
	return @retval
	--return dbo.f_Gen_GetMarkup(@itemID, @roomID, @marketID, @ccy) + @retval
end