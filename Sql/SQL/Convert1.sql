use [TT]
SET XACT_ABORT ON 
begin transaction
	--清空数据
	Begin
	    --delete from Gen_Room_Facility
        --delete from Gen_RoomFacilities
		delete from Gen_RoomItem
		delete from Gen_Rooms
		delete from Gen_RoomCategory
		delete from Gen_Rates
        delete from Gen_Currency
        delete from Gen_RoomType
        delete from Gen_Hotel_Facility
        delete from Gen_Hotel_Services
        delete from Gen_Hotel_Restaurant
        delete from Gen_Hotels
        delete from Gen_Styles
       -- delete from Gen_HotelFacilities

		delete from Gen_Airports
		delete from Gen_Areas
		delete from Gen_Cities
		delete from Gen_MarketCountry
		delete from Gen_Countries
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
	
	--Gen_RoomType 07.20
	insert into Gen_RoomType(RoomTypeID,
		RmtName,
		RmtCTName,
		CreateBy,
		CreateDate,
		ModifyBy,
		ModifyDate
		)
		select IdKey,
		EnglishName,
		ChineseName,
		Creator,
		CreateDate,
		ModifyBy,
		ModifyDate
		from UAT.dbo.gen_roomtype 
		
    --Gen_RoomCategory
    insert into Gen_RoomCategory(CategoryID,
		CategoryName,
		CategoryCTName,
		CreateBy,
		CreateDate,
		ModifyBy,
		ModifyDate
		)
		select ID,
		EnglishName,
		ChineseName,
		Creator,
		CreateDate,
		ModifyBy,
		ModifyDate
		from UAT.dbo.Gen_HotelType 
	
	--Gen_Currency
	insert into Gen_Currency(CCYCode,	
		CCYName,
		Status,
		CreateBy,
		CreateDate,
		ModifyBy,
		ModifyDate
		)
		select C_Currency_Code,
		C_Description,
		N_Status,
		C_Creator,
		D_CreateDate,
		C_ModifyBy,
		D_ModifyDate
		from UAT.dbo.Gen_Account_Curr_Code
	
	--Gen_Rates
    insert into Gen_Rates(CCYCodeA,
		CCYCodeB,
		Rate,
		CreateDate,
		CreateBy,
		ModifyDate,
		ModifyBy
		)
		select Code,
		DEFCode,
		Rate,
		CreateDate,
		Creator,
		ModifyDate,
		ModifyBy
		from UAT.dbo.gen_currency 
		where DEFCode is not null 
		--旧DB有2笔数据对应在新DB中作为主键不能为空
		
    --Gen_Hotels 
    insert into Gen_Hotels(HotelID,
		HotelName,
		HotelCTName,
		CityID,
		StyleID, 
		Star,
		PhoneNo,
		FaxNo,
		OurURL,
		HotelURL,
		Email,
		Address,
		Transportation,
		--CreateBy,
		CreateDate,
		--ModifyBy,
		ModifyDate,
		CountryID,
		Photo,
		PromotionDescription
		)
        select  b.Hot_Code ,
		b.EnglishName,
		b.ChineseName,
		a.CityID ,
		c.StyleID  ,
		b.Class,
		b.Tel,
		b.Fax,
		b.OurURL,
		b.URL,
		b.Email,
		b.Address,
		b.Transporation,
		--b.Creator,
		b.UpdateDate,
		--b.ModifyBy,
		b.ModifyDate,
		b.CountryCode,
		b.FPhoto
		,b.Pros  
		from 
		(select CityID ,CityCode  from  Gen_Cities ) a,
		UAT.dbo.gen_hotel b 
		left join Gen_Styles C on substring(b.Style ,1,charindex(' /',b.Style)) COLLATE SQL_Latin1_General_CP1_CI_AS=C.StyleName 
		where a.CityCode COLLATE SQL_Latin1_General_CP1_CI_AS=b.CityCode

    --Gen_Styles
     insert into T.dbo.Gen_Styles(--StyleID, --StyleId为自增量
		StyleName,
		StyleCTName,
		Creator,	
		CreateDate,
		ModifyBy,
		ModifyDate
		)
		select --Idkey,
		EnglishName,
		ChineseName,	
		Creator,
		CreateDate,
		ModifyBy,
		ModifyDate
		from UAT.dbo.gen_style
		
	--Gen_Services
    insert into Gen_Services(--ServiceID,为自增量
		ServiceName,
		ServiceCTName,
		--Creator,
		CreateDate,
		ModifyBy,
		ModifyDate
		)
		select --IdKey,
		EnglishName,
		ChineseName,
		--Creator,
		CreateDate,
		ModifyBy,
		ModifyDate
		from UAT.dbo.gen_service
	
	--Gen_HotelFacilities
	--insert into Gen_HotelFacilities(--FacilityID,自增量
	--	FacilityName,
	--	FacilityCTName,
	--	Creator,
	--	CreateDate,
	--	ModifyBy,
	--	ModifyDate
	--	)
	--	select --IdKey,
	--	EnglishName,
	--	ChineseName,
	--	Creator,
	--	CreateDate,
	--	ModifyBy,
	--	ModifyDate
	--	from UAT.dbo.gen_facility
	
	--Gen_Restaurants
	insert into Gen_Restaurants(--RestaurantID,自增量
		RestaurantName,
		RestaurantCTName,
		--Creator,
		CreateDate,
		ModifyBy,
		ModifyDate
		)
		select --IdKey,
		EnglishName,
		ChineseName,
		--Creator,
		CreateDate,
		ModifyBy,
		ModifyDate
		from UAT.dbo.gen_restaurant

    --Gen_Rooms
    insert into Gen_Rooms(RoomID,
		HotelID,
		CategoryID,
		RoomTypeID,
		RoomSize
		)
		select a.Id,
		b.Hot_Code, 
		H.ID,
		c.IdKey ,
		a.RoomSize
		from UAT.dbo.gen_hot_room a,UAT.dbo.gen_hotel b,UAT.dbo.gen_roomtype c,UAT.dbo.Gen_HotelType H
		where  isnull(a.RoomCategory,'') <> ''
		and isnull(a.Type,'') <> ''
		and isnull(a.RoomCategory,'') <> ''
		and a.hot_code=b.Hot_Code 
		and a.RoomCategory=c.EnglishName 
		and a.Type =H.EnglishName
	
	--Gen_Hotel_Services
	insert into Gen_Hotel_Services(HotelID,
		ServiceID
		)
		select hot_code ,ServiceID  from 
		(select hot_code ,substring(ServiceName,1,charindex(' /',ServiceName)) as Name from UAT.dbo.gen_hot_service) a,
		 Gen_Services b
		 where a.Name COLLATE SQL_Latin1_General_CP1_CI_AS=b.ServiceName 
		
	--Gen_Hotel_Facility
	--insert into Gen_Hotel_Facility(HotelID,
	--	HotelFacilityID
	--	)
	--	select distinct a.Hot_Code , b.FacilityID from
	--	(select Hot_Code , substring(FacilityName,1, charindex(' /',FacilityName)) as FacilityName from UAT.dbo.gen_hot_facility) a,
	--	T.dbo.Gen_HotelFacilities b
	--	where a.FacilityName COLLATE SQL_Latin1_General_CP1_CI_AS=b.FacilityName 
	
	--Gen_Hotel_Restaurant
	insert into Gen_Hotel_Restaurant(HotelID,
		RestaurantID
		)
		select a.Hot_code,b.RestaurantID  from (
		select Hot_code , substring(name,1, charindex(' /',name))as name from UAT.dbo.gen_hot_restaurant) a,
		Gen_Restaurants b
		where a.name COLLATE SQL_Latin1_General_CP1_CI_AS=b.RestaurantName

commit transaction