use [TT]
SET XACT_ABORT ON 
begin transaction
	--清空数据
	Begin
	    delete from Gen_Room_Amenity
        delete from Gen_Amentities
		delete from Gen_RoomItem
		delete from Gen_Rooms
		delete from Gen_RoomCategory
		delete from Gen_Rates
        delete from Gen_Currency
        delete from Gen_RoomType
        delete from Gen_Hotel_Facility
        delete from Gen_Hotel_Services
        delete from Gen_Hotel_Restaurant
        delete from Gen_Restaurants       
        delete from Gen_Hotels
        delete from Gen_Services
        delete from Gen_Styles
        delete from Gen_Facilities

		delete from Gen_Airports
		delete from Gen_Areas
		delete from Gen_Cities
		delete from Gen_MarketCountry
		delete from Gen_Countries
		delete from BO_Users
	end

	--BO_Users
	print 'BO_Users  Original date:610   Import:610'
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
    
	--Gen_Countries
	print 'Gen_Countries    Original date:243   Import:243'
	INSERT INTO  Gen_Countries([CountryID],[CountryName],[CountryCTName],[IddCode],ContinentID,CreateBy,CreateDate,ModifyBy,ModifyDate)
	select Code,EnglishName,ChineseName,IDDCode,
		(select top 1 ContinentID from  Gen_Continents where ContinentName in
			(select tcon.ContinentName from [T]..Gen_Countries tc 
				inner join [T]..Gen_Continents tcon on tc.ContinentID=tcon.ContinentID 
				where tc.[CountryID]=uc.Code collate database_default)
		) as ContinentID, -- Copy from database T
		Creator,CreateDate,ModifyBy,ModifyDate 
	from [UAT]..gen_country uc
	
	--Gen_Cities
	print 'Gen_Cities  Original date:9527   Import:9527'
	INSERT INTO  [Gen_Cities]([CityID],[CityName],[CityCTName],[IddCode],[CityCode],[PreCode],[CountryID])
	select a.ID,a.EnglishName,a.ChineseName,a.IDDCode,a.Code,SUBSTRING(a.EnglishName,1,1) as PreCode,b.Code
	from [UAT]..relation a inner join [UAT]..relation b on a.fatherid=b.id and a.Class='1' order by b.ID

	--Gen_Areas
	print 'Gen_Areas  Original date:277   Import:277'
	INSERT INTO  [Gen_Areas]([AreaID],[AreaName],[AreaCTName],[CityID])
	select a.ID,a.EnglishName,a.EnglishName,b.FatherID 
	from [uat]..relation a inner join [uat]..relation b on a.fatherid=b.id and a.Class='4' order by b.ID

	--Gen_Airports
	print 'Gen_Airports   Original date:44   Import:44'
	INSERT INTO  [Gen_Airports]([AirportID],[AirportCode],[CityID],[AirportName],[AirportCTName])
	select a.Code,a.Code,b.FatherID,a.EnglishName,a.ChineseName 
	from [uat]..relation a inner join [uat]..relation b on a.fatherid=b.id and a.Class='3' order by b.ID
	
	--Gen_RoomType 07.20
	print 'Gen_RoomType   Original date:7   Import:7'
	insert into Gen_RoomType(
		RoomTypeID,
		RmtName,
		RmtCTName,
		CreateBy,
		CreateDate,
		ModifyBy,
		ModifyDate,
		MaxPax
		)
		select 
		IdKey,
		EnglishName,
		ChineseName,
		Creator,
		CreateDate,
		ModifyBy,
		ModifyDate,
		Qty
		from UAT.dbo.gen_roomtype 
		
    --Gen_RoomCategory
    print 'Gen_RoomCategory  Original date:21  Import:21 '
    insert into Gen_RoomCategory(CategoryID,
		CategoryName,
		CategoryCTName,
		Sort,
		CreateBy,
		CreateDate,
		ModifyBy,
		ModifyDate
		)
		select ID,
		EnglishName,
		ChineseName,
		N_OrderBy,
		Creator,
		CreateDate,
		ModifyBy,
		ModifyDate
		from UAT.dbo.Gen_HotelType 
	
	--Gen_Currency
	print 'Gen_Currency   Original date:17   Import:17'
	insert into Gen_Currency(CCYCode,	
		CCYName,
		[Status],
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
		
	--Gen_Rates 旧DB有2笔数据对应在新DB中作为主键不能为空
	print 'Gen_Rates   Original date:14   Import:12'
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
		
	--Gen_Styles
	print 'Gen_Styles    Original date:14   Import:14'
    insert into Gen_Styles(--StyleID, --StyleId为自增量
		StyleName,
		StyleCTName,
		CreateBy,
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
		
    --Gen_Hotels 
    print 'Gen_Hotels     Original date:8428   Import:8419'
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
		
	--Gen_Services
	print 'Gen_Services    Original date:17   Import:17'
    insert into Gen_Services(--ServiceID,为自增量
		ServiceName,
		ServiceCTName,
		CreateBy,
		CreateDate,
		ModifyBy,
		ModifyDate
		)
		select --IdKey,
		EnglishName,
		ChineseName,
		Creator,
		CreateDate,
		ModifyBy,
		ModifyDate
		from UAT.dbo.gen_service
	
	--Gen_Hotel_Services
	print 'Gen_Hotel_Services   Original date:15449   Import:15433'
	insert into Gen_Hotel_Services(HotelID,
		ServiceID
		)
		select hot_code ,ServiceID  from 
		(select hot_code ,substring(ServiceName,1,charindex(' /',ServiceName)) as Name from UAT.dbo.gen_hot_service) a,
		 Gen_Services b
		 where a.Name COLLATE SQL_Latin1_General_CP1_CI_AS=b.ServiceName 	

	--Gen_Facilities
	print 'Gen_Facilities      Original date:41   Import:41'
	insert into Gen_Facilities(--FacilityID,自增量
		FacilityName,
		FacilityCTName,
		CreateBy,
		CreateDate,
		ModifyBy,
		ModifyDate
		)
		select --IdKey,
		EnglishName,
		ChineseName,
		Creator,
		CreateDate,
		ModifyBy,
		ModifyDate
		from UAT.dbo.gen_facility
	
	--Gen_Hotel_Facility
	print 'Gen_Hotel_Facility    Original date:45739   Import:45713'
	insert into Gen_Hotel_Facility(HotelID,
		HotelFacilityID
		)
		select distinct a.Hot_Code , b.FacilityID from
		(select Hot_Code , substring(FacilityName,1, charindex(' /',FacilityName)) as FacilityName from UAT.dbo.gen_hot_facility) a,
		dbo.Gen_Facilities b
		where a.FacilityName COLLATE SQL_Latin1_General_CP1_CI_AS=b.FacilityName 	
	
	--Gen_Restaurants
	print 'Gen_Restaurants    Original date:14   Import:14'
	insert into Gen_Restaurants(--RestaurantID,自增量
		RestaurantName,
		RestaurantCTName,
		CreateBy,
		CreateDate,
		ModifyBy,
		ModifyDate
		)
		select --IdKey,
		EnglishName,
		ChineseName,
		Creator,
		CreateDate,
		ModifyBy,
		ModifyDate
		from UAT.dbo.gen_restaurant
	
	--Gen_Hotel_Restaurant
	print 'Gen_Hotel_Restaurant    Original date:8614   Import:8608'
	insert into Gen_Hotel_Restaurant(HotelID,
		RestaurantID
		)
		select a.Hot_code,b.RestaurantID  from (
		select Hot_code , substring(name,1, charindex(' /',name))as name from UAT.dbo.gen_hot_restaurant) a,
		Gen_Restaurants b
		where a.name COLLATE SQL_Latin1_General_CP1_CI_AS=b.RestaurantName	

    --Gen_Rooms
    print 'Gen_Rooms     Original date:34922   Import:1815'
    insert into Gen_Rooms(RoomID,
		HotelID,
		CategoryID,
		RoomTypeID,
		RoomSize,
		RoomCount
		)
		select a.Id,
		b.Hot_Code, 
		H.ID,
		c.IdKey ,
		a.RoomSize,
		a.Qty
		from UAT.dbo.gen_hot_room a,UAT.dbo.gen_hotel b,UAT.dbo.gen_roomtype c,UAT.dbo.Gen_HotelType H
		where  isnull(a.RoomCategory,'') <> ''
		and isnull(a.Type,'') <> ''
		and isnull(a.RoomCategory,'') <> ''
		and a.hot_code=b.Hot_Code 
		and a.RoomCategory=c.EnglishName 
		and a.Type =H.EnglishName
	
	--Gen_Amentities
	print 'Gen_Amentities    Original date:24   Import:24'
	insert into Gen_Amentities(--RestaurantID,自增量
		AmenityName,
		AmenityCTName,
		CreateBy,
		CreateDate,
		ModifyBy,
		ModifyDate
		)
		select --IdKey,
		EnglishName,
		ChineseName,
		Creator,
		CreateDate,
		ModifyBy,
		ModifyDate
		from UAT.dbo.gen_amenities
		
	/*gen_hot_amentities 设备与酒店的关系??? */
	--Gen_Room_Amenity
	--insert into Gen_Room_Amenity(RoomID,
	--	AmenityID
	--	)
	--	select distinct a.RoomID,b.AmenityID  from (
	--	select [Hot_code] as RoomID , substring([AmenityName],1, charindex(' /',[AmenityName]))as [AmenityName] from UAT.dbo.gen_hot_amentities) a,
	--	Gen_Amentities b
	--	where a.[AmenityName] COLLATE SQL_Latin1_General_CP1_CI_AS=b.AmenityName	
		
commit transaction

--use UAT
--select * from UAT.dbo.gen_hotel h where h.Hot_Code in( 
--select Hot_Code from UAT.dbo.gen_hot_amentities)

--select * from gen_hot_room h where h.Hot_Code in( 
--select Hot_Code from UAT.dbo.gen_hot_amentities)