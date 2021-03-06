
/*
Description: 根据itemID获取Markup For Internet
Author: Tencal
Date: 2009-9-24
Test: SELECT [dbo].[f_Internet_GetMarkup]('1','9700503970054','977884','HKD')
*/
create FUNCTION [dbo].[f_Internet_GetMarkup]
(
	@itemID NVARCHAR(18),
	@roomID NVARCHAR(18),
	@marketID NVARCHAR(18),
	@ccyCode VARCHAR(3)
) RETURNS MONEY
AS
BEGIN
	DECLARE @markup MONEY
	DECLARE @countryID NVARCHAR(18)
	DECLARE @cityID NVARCHAR(18)
	DECLARE @hotelID NVARCHAR(18)
	DECLARE @roomTypeID NVARCHAR(18)
	DECLARE @categoryID NVARCHAR(18)
	DECLARE @markupCCYCode VARCHAR(3)
	SET @markup = NULL
	SET @countryID = NULL
	SET @cityID = NULL
	SET @hotelID = NULL
	SET @roomTypeID = NULL
	SET @categoryID = NULL
	
	
	--查询该项所有属性，如果未找，直接跳过返回0。
	IF (NOT EXISTS(SELECT ItemID FROM Gen_Items WHERE ItemID=@itemID))
		RETURN 0
	
	SELECT @categoryID = CategoryID, @roomTypeID = RoomTypeID, @hotelID = HotelID FROM Gen_Rooms WHERE RoomID = @roomID;
	SELECT @cityID = CityID, @countryID = CountryID FROM Gen_Hotels WHERE HotelID = @hotelID
	
	-- Hotel
	SELECT @markup = Value, @markupCCYCode = CCYCode FROM Gen_InternetMarkup WHERE (ItemID = @itemID OR ItemID = 'ALL') AND (HotelID = @hotelID OR HotelID = 'ALL') AND DATEDIFF(D,EffectiveDate,GETDATE()) >= 0 AND (MarketID = @marketID OR MarketID = 'ALL') ORDER BY MarkupID DESC
	IF (@markup IS NOT NULL)
		RETURN dbo.f_Gen_Exchange(@markup,@markupCCYCode,@ccyCode)
		
	SELECT @markup = Value, @markupCCYCode = CCYCode FROM Gen_InternetMarkup WHERE (CategoryID = @categoryID OR @categoryID = 'ALL') AND (HotelID = @hotelID OR HotelID = 'ALL') AND DATEDIFF(D,EffectiveDate,GETDATE()) >= 0 AND (MarketID = @marketID OR MarketID = 'ALL') ORDER BY MarkupID DESC
	IF (@markup IS NOT NULL)
		RETURN dbo.f_Gen_Exchange(@markup,@markupCCYCode,@ccyCode)
		
	SELECT @markup = Value, @markupCCYCode = CCYCode FROM Gen_InternetMarkup WHERE (RoomTypeID = @roomTypeID OR @roomTypeID = 'ALL') AND (HotelID = @hotelID OR HotelID = 'ALL') AND DATEDIFF(D,EffectiveDate,GETDATE()) >= 0 AND (MarketID = @marketID OR MarketID = 'ALL') ORDER BY MarkupID DESC
	IF (@markup IS NOT NULL)
		RETURN dbo.f_Gen_Exchange(@markup,@markupCCYCode,@ccyCode)
			
	-- City
	SELECT @markup = Value, @markupCCYCode = CCYCode FROM Gen_InternetMarkup WHERE (ItemID = @itemID OR ItemID = 'ALL') AND ((CityID = @cityID OR CityID = 'ALL') AND ISNULL(HotelID,'') = '') AND DATEDIFF(D,EffectiveDate,GETDATE()) >= 0 AND (MarketID = @marketID OR MarketID = 'ALL') ORDER BY MarkupID DESC
	IF (@markup IS NOT NULL)
		RETURN dbo.f_Gen_Exchange(@markup,@markupCCYCode,@ccyCode)
		
	SELECT @markup = Value, @markupCCYCode = CCYCode FROM Gen_InternetMarkup WHERE (CategoryID = @categoryID OR @categoryID = 'ALL') AND ((CityID = @cityID OR CityID = 'ALL') AND ISNULL(HotelID,'') = '') AND DATEDIFF(D,EffectiveDate,GETDATE()) >= 0 AND (MarketID = @marketID OR MarketID = 'ALL') ORDER BY MarkupID DESC
	IF (@markup IS NOT NULL)
		RETURN dbo.f_Gen_Exchange(@markup,@markupCCYCode,@ccyCode)
		
	SELECT @markup = Value, @markupCCYCode = CCYCode FROM Gen_InternetMarkup WHERE (RoomTypeID = @roomTypeID OR @roomTypeID = 'ALL') AND ((CityID = @cityID OR CityID = 'ALL') AND ISNULL(HotelID,'') = '') AND DATEDIFF(D,EffectiveDate,GETDATE()) >= 0 AND (MarketID = @marketID OR MarketID = 'ALL') ORDER BY MarkupID DESC
	IF (@markup IS NOT NULL)
		RETURN dbo.f_Gen_Exchange(@markup,@markupCCYCode,@ccyCode)
		
	-- Country
	SELECT @markup = Value, @markupCCYCode = CCYCode FROM Gen_InternetMarkup WHERE (ItemID = @itemID OR ItemID = 'ALL') AND ((CountryID = @countryID OR CountryID = 'ALL') AND ISNULL(CityID,'') = '' AND ISNULL(HotelID,'') = '') AND DATEDIFF(D,EffectiveDate,GETDATE()) >= 0 AND (MarketID = @marketID OR MarketID = 'ALL') ORDER BY MarkupID DESC
	IF (@markup IS NOT NULL)
		RETURN dbo.f_Gen_Exchange(@markup,@markupCCYCode,@ccyCode)
		
	SELECT @markup = Value, @markupCCYCode = CCYCode FROM Gen_InternetMarkup WHERE (CategoryID = @categoryID OR @categoryID = 'ALL') AND ((CountryID = @countryID OR CountryID = 'ALL') AND ISNULL(CityID,'') = '' AND ISNULL(HotelID,'') = '') AND DATEDIFF(D,EffectiveDate,GETDATE()) >= 0 AND (MarketID = @marketID OR MarketID = 'ALL') ORDER BY MarkupID DESC
	IF (@markup IS NOT NULL)
		RETURN dbo.f_Gen_Exchange(@markup,@markupCCYCode,@ccyCode)
		
	SELECT @markup = Value, @markupCCYCode = CCYCode FROM Gen_InternetMarkup WHERE (RoomTypeID = @roomTypeID OR @roomTypeID = 'ALL') AND ((CountryID = @countryID OR CountryID = 'ALL') AND ISNULL(CityID,'') = '' AND ISNULL(HotelID,'') = '') AND DATEDIFF(D,EffectiveDate,GETDATE()) >= 0 AND (MarketID = @marketID OR MarketID = 'ALL') ORDER BY MarkupID DESC
	IF (@markup IS NOT NULL)
		RETURN dbo.f_Gen_Exchange(@markup,@markupCCYCode,@ccyCode)
	
	-- No set, return default by setting
	SELECT @markup = Markup FROM Gen_Items WHERE ItemID=@itemID
	RETURN dbo.f_Gen_Exchange(@markup,'HKD',@ccyCode)
END