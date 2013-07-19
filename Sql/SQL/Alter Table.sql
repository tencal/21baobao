go
ALTER TABLE Gen_ReservesHistory ADD [IsRead] BIT DEFAULT(0)
go

go
ALTER VIEW [dbo].[V_Gen_GetHotelWithCC]
AS
SELECT     dbo.Gen_Cities.CityName, dbo.Gen_Cities.CityCode,dbo.Gen_Cities.CityCSName, dbo.Gen_Cities.CityCTName, dbo.Gen_Countries.CountryName, 
                      dbo.Gen_Countries.CountryCSName, dbo.Gen_Hotels.HotelID, dbo.Gen_Hotels.HotelName, dbo.Gen_Hotels.HotelCSName, 
                      dbo.Gen_Hotels.HotelCTName, dbo.Gen_Hotels.Address, dbo.Gen_Hotels.AddressCS, dbo.Gen_Hotels.AddressCT, dbo.Gen_Hotels.PhoneNo, 
                      dbo.Gen_Hotels.FaxNo, dbo.Gen_Hotels.Email, dbo.Gen_Hotels.HotelURL, dbo.Gen_Hotels.StyleID, dbo.Gen_Hotels.Transportation, 
                      dbo.Gen_Hotels.TransportationCS, dbo.Gen_Hotels.TransportationCT, dbo.Gen_Hotels.CountryID, dbo.Gen_Hotels.AreaID, dbo.Gen_Hotels.CityID, 
                      dbo.Gen_Hotels.Star, dbo.Gen_Hotels.TitlePic, dbo.Gen_Hotels.Status, dbo.Gen_Hotels.Hot, dbo.Gen_Hotels.CreateBy, dbo.Gen_Hotels.CreateDate, 
                      dbo.Gen_Hotels.ModifyBy, dbo.Gen_Hotels.ModifyDate, dbo.Gen_Hotels.IsPromotion, dbo.Gen_Hotels.PromotionDescription, 
                      dbo.Gen_Hotels.PromotionCSDescription, dbo.Gen_Hotels.PromotionCTDescription, dbo.Gen_Hotels.PromotionEnd, dbo.Gen_Hotels.PromotionSort, 
                      dbo.Gen_Hotels.OverView, dbo.Gen_Hotels.OverViewCS, dbo.Gen_Hotels.OverViewCT, dbo.Gen_Hotels.LoactionDescription, 
                      dbo.Gen_Hotels.LoactionCSDescription, dbo.Gen_Hotels.LoacationCTDescription, dbo.Gen_Hotels.ConditionalDescription, 
                      dbo.Gen_Hotels.ConditionalCSDescription, dbo.Gen_Hotels.ConditionalCTDescription, dbo.Gen_Hotels.Photo, dbo.Gen_Hotels.OurURL, 
                      dbo.Gen_Hotels.OpenDate, dbo.Gen_Countries.CountryCTName
FROM         dbo.Gen_Hotels INNER JOIN
                      dbo.Gen_Countries ON dbo.Gen_Hotels.CountryID = dbo.Gen_Countries.CountryID INNER JOIN
                      dbo.Gen_Cities ON dbo.Gen_Hotels.CityID = dbo.Gen_Cities.CityID AND dbo.Gen_Countries.CountryID = dbo.Gen_Cities.CountryID

GO


