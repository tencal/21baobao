-- =============================================
-- Author:		<Tencal Liao>
-- Create date: <2009-08-19>
-- Description:	<Group Price by RoomID, ItemID, MarketID, CCYCode, ItemPrice, EffectivDate, ExpiryDate, SupplierCode>
-- =============================================
ALTER VIEW [dbo].[v_Gen_GetRoomPriceListGroupBY]
AS
SELECT  
	B.StartDate, B.EndDate, B.ItemPrice, B.EffectivDate, B.ExpiryDate, B.SupplierCode,B.MarkUp,B.IsHistory,
	M.MarketName, M.MarketCSName, M.MarketCTName, M.MarketID, 
	I.ItemName, I.ItemCSName, I.ItemID,I.ItemCTName, 
	C.CCYName, C.CCYCSName, C.CCYCTName,C.CCYCode, 
	R.RoomID, R.HotelID, 
	T.RmtName, T.RmtCSName, T.RmtCTName, T.RoomTypeID,
	RC.CategoryName, RC.CategoryCSName, RC.CategoryCTName, RC.CategoryID, 
	H.CityID, H.CountryID,H.HotelName, H.HotelCSName, H.HotelCTName, 
	Co.CountryName, Co.CountryCSName, Co.CountryCTName,
	Ci.CityName,Ci.CityCSName, Ci.CityCTName    
FROM	
	(SELECT	RoomID, ItemID, MarketID, CCYCode, MIN(PriceDate) AS StartDate, MAX(PriceDate) AS EndDate, ItemPrice, dbo.f_Gen_GetMarkup(ItemID, 
            RoomID, MarketID, CCYCode) AS MarkUp, EffectivDate, ExpiryDate, COUNT(*) AS Expr1, SupplierCode,0 as IsHistory
    FROM    dbo.Gen_RoomItem
    GROUP BY RoomID, ItemID, MarketID, CCYCode, ItemPrice, EffectivDate, ExpiryDate,SupplierCode
    UNION ALL
	SELECT	RoomID, ItemID, MarketID, CCYCode, MIN(PriceDate) AS StartDate, MAX(PriceDate) AS EndDate, ItemPrice, dbo.f_Gen_GetMarkup(ItemID, 
            RoomID, MarketID, CCYCode) AS MarkUp, EffectivDate, ExpiryDate, COUNT(*) AS Expr1,SupplierCode,1 as IsHistory
	FROM         dbo.Gen_RoomItemHistory
    GROUP BY RoomID, ItemID, MarketID, CCYCode, ItemPrice, EffectivDate, ExpiryDate, SupplierCode
	) AS B 
INNER JOIN dbo.Gen_Markets M ON B.MarketID = M.MarketID 
INNER JOIN dbo.Gen_Items I ON B.ItemID = I.ItemID 
INNER JOIN dbo.Gen_Currency C ON B.CCYCode = C.CCYCode 
INNER JOIN dbo.Gen_Rooms R ON B.RoomID = R.RoomID 
INNER JOIN dbo.Gen_RoomType T ON R.RoomTypeID = T.RoomTypeID 
INNER JOIN dbo.Gen_RoomCategory RC ON R.CategoryID = RC.CategoryID 
INNER JOIN dbo.Gen_Hotels H ON R.HotelID = H.HotelID 
INNER JOIN dbo.Gen_Countries Co ON H.CountryID = Co.CountryID 
INNER JOIN dbo.Gen_Cities Ci ON H.CityID = Ci.CityID AND Co.CountryID = Ci.CountryID
GO


