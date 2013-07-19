use [TT]
SET XACT_ABORT ON 
begin transaction
	--清空数据
	if(1=1) begin 
	delete from Gen_RoomItem
	delete from Gen_Rooms
	delete from Gen_RoomCategory
	delete from Gen_Rates
    delete from Gen_Currency
    delete from Gen_RoomType
    delete from Gen_Hotel_Facility
    delete from Gen_Hotel_Restaurant
    delete from Gen_Hotel_Services
    delete from Gen_HotelEvents
    delete from Gen_Hotels

	delete from Gen_Airports
	delete from Gen_Areas
	delete from Gen_Cities
	delete from Gen_MarketCountry
	delete from Gen_Countries
	
	delete from BO_UserInGroups
	delete from BO_UserHasFunctions
	delete from BO_Users
	
	end
	
	--Gen_Countries
	INSERT INTO  Gen_Countries([CountryID],[CountryName],[CountryCTName],[IddCode],ContinentID,CreateBy,CreateDate,ModifyBy,ModifyDate)
	select Code,EnglishName,ChineseName,IDDCode,
		(select top 1 ContinentID from  Gen_Continents where ContinentName in
			(select tcon.ContinentName from [T]..Gen_Countries tc 
				inner join [T]..Gen_Continents tcon on tc.ContinentID=tcon.ContinentID 
				where tc.[CountryID]=uc.Code collate database_default)
		) as ContinentID,
		Creator,CreateDate,ModifyBy,ModifyDate 
	from [UAT]..gen_country uc
	
	--Gen_Cities
	INSERT INTO  [Gen_Cities]([CityID],[CityName],[CityCTName],[IddCode],[CityCode],[PreCode],[CountryID])
	select a.ID,a.EnglishName,a.ChineseName,a.IDDCode,a.Code,SUBSTRING(a.EnglishName,1,1) as PreCode,b.Code
	from [UAT]..relation a inner join [UAT]..relation b on a.fatherid=b.id and a.Class='1' order by b.ID

	--Gen_Areas
	INSERT INTO  [Gen_Areas]([AreaID],[AreaName],[AreaCTName],[CityID])
	select a.ID,a.EnglishName,a.EnglishName,b.FatherID 
	from [uat]..relation a inner join [uat]..relation b on a.fatherid=b.id and a.Class='4' order by b.ID

	--Gen_Airports
	INSERT INTO  [Gen_Airports]([AirportID],[AirportCode],[CityID],[AirportName],[AirportCTName])
	select a.ID,a.Code,b.FatherID,a.EnglishName,a.ChineseName 
	from [uat]..relation a inner join [uat]..relation b on a.fatherid=b.id and a.Class='3' order by b.ID
	
	--BO_Users
	INSERT INTO [BO_Users]
           ([UserID]
           ,[UserName]
           ,[ChineseUserName]
           ,[Password]
           ,[Email]
           ,[Gender]
           ,[Birthday]
           ,[Status]  --新数据库字段太短
           ,[CreateBy]
           ,[CreateDate]
           ,[ModifyBy]
           ,[ModifyDate]
           )
    select u.[User_id],u.EnglishName,u.ChineseName,
		u.[Password],u.Email,u.Gender, u.Birthday,u.[Status],u.Creator
		,u.CreateDate,u.ModifyBy,u.ModifyDate
    from UAT.dbo.gen_user u

commit transaction