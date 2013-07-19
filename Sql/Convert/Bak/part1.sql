/*------------------------------------------------------------------------------------------------------*/
use [TEHR_Test]  
/*------------------------------------------------------------------------------------------------------*/
SET XACT_ABORT ON 
begin transaction
begin
    truncate table Gen_Room_Amenity
    delete from Gen_Amentities
    
	truncate table Gen_RoomItem /*需要从新拿回来数据的*/
	truncate table Gen_PromotionPrice /*需要从新拿回来数据的*/
	
	delete from Gen_Rooms
	
	truncate table Gen_promotionCondition /*需要从新拿回来数据的*/
	delete from Gen_Promotion /*需要从新拿回来数据的*/
	
	truncate table Gen_RoomItem
	truncate table Gen_MarketCountry 
	
	truncate table Gen_FreeEnquires
	
	delete from Gen_markets
	delete from Gen_RoomCategory
	truncate table Gen_Rates
    delete from Gen_Currency
	delete from Gen_RoomType
    truncate table Gen_Hotel_Facility
    truncate table Gen_Hotel_Services
	truncate table Gen_Hotel_Restaurant
	truncate table Gen_Hotel_Activity
    delete from Gen_Restaurants       
    delete from Gen_Hotels
    truncate table Gen_HotelsHistroy
    delete from Gen_Services
    delete from Gen_Styles
    delete from Gen_Facilities

	truncate table Gen_Airports
	delete from Gen_Areas
	delete from Gen_Cities
	truncate table Gen_MarketCountry
	delete from Gen_Countries
	
	
	truncate table Gen_ReservePaxs  /*需要从新拿回来数据的*/
	truncate table Gen_ReservePaxsHistory /*需要从新拿回来数据的*/
	delete from Gen_ReserveDetails/*需要从新拿回来数据的*/
	delete from Gen_ReserveDetailsHistory/*需要从新拿回来数据的*/
	truncate table Gen_Order/*需要从新拿回来数据的*/
	delete from Gen_Reserves/*需要从新拿回来数据的*/
	delete from Gen_ReservesHistory/*需要从新拿回来数据的*/
	
	truncate table Gen_Photo
	truncate table Gen_UserCountry
	
	truncate table Gen_Rooms
	truncate table Gen_Suppliers
	
	truncate table Gen_RoomItem /*需要从新拿回来数据的*/
	truncate table Gen_RoomItemHistory/*需要从新拿回来数据的*/
	
	
	delete from Gen_Activities
	truncate table Gen_Suppliers
end			
commit transaction