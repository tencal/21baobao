use TExpert
alter table BO_Users alter column Status nvarchar(30)
alter table Gen_RoomCategory add Sort int
alter table Gen_Hotels alter column HotelName nvarchar(70)
alter table Gen_Services add CreateBy nvarchar(18)
--alter table Gen_Services drop COLUMN Creator
alter table Gen_Restaurants add CreateBy nvarchar(18)
--alter table Gen_Restaurants drop COLUMN Creator
alter table Gen_Styles add CreateBy nvarchar(18)
--alter table Gen_Styles drop COLUMN Creator

alter table Gen_Hotels add EffectiveDate date
alter table Gen_Hotels add ChildCondition nvarchar(max)
alter table Gen_Hotels alter column PhoneNo nvarchar(30)
alter table Gen_Hotels alter column FaxNo nvarchar(30)
alter table Gen_Hotels alter column Email nvarchar(100)
alter table Gen_Hotels alter column Address nvarchar(200)  

alter table gen_countries add OurURL nvarchar(200)
alter table gen_cities add OurURL nvarchar(200)