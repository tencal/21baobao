/*------------------------------------------------------------------------------------------------------*/
use [TEHR_Test] 
/*------------------------------------------------------------------------------------------------------*/
SET XACT_ABORT ON 
begin transaction
begin
	delete from dbo.Gen_PromotionPrice where RoomID in (select RoomID from Gen_Rooms where HotelID in (select HotelID from Gen_Hotels where ExpireDate<GETDATE()))
	delete from Gen_Rooms where HotelID in (select HotelID from Gen_Hotels where ExpireDate<GETDATE())
	delete from Gen_Rooms where CategoryID in (select CategoryID from dbo.Gen_RoomCategory  where OwnerHotelID in (select HotelID from Gen_Hotels where ExpireDate<GETDATE()))
	delete from dbo.Gen_RoomCategory  where OwnerHotelID in (select HotelID from Gen_Hotels where ExpireDate<GETDATE()) 
	delete from Gen_Hotels where ExpireDate<GETDATE()
end			
commit transaction