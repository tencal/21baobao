/*------------------------------------------------------------------------------------------------------*/
use [TE2010-HR_Empty]
/*------------------------------------------------------------------------------------------------------*/
SET XACT_ABORT ON 
begin transaction
begin
	--清空数据
	Begin
	    delete from Gen_Room_Amenity
        delete from Gen_Amentities
		delete from Gen_RoomItem
		delete from Gen_Rooms
		delete from Gen_RoomItem
		delete from Gen_MarketCountry  --New Add
		delete from Gen_markets  --New Add
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
		delete from BO_UserHasFunctions
		delete from BO_UserInGroups
		delete from BO_Users
		
		delete from Gen_ReservePaxs
		delete from Gen_ReservePaxsHistory
		delete from Gen_ReserveDetails
		delete from Gen_ReserveDetailsHistory
		delete from Gen_Reserves
		delete from Gen_ReservesHistory
		delete from BO_AppLog
		delete from BO_OperationLog
		delete from Gen_Photo
		delete from Gen_UserCountry
		
		declare @SouthAmerica nvarchar(400) --
		declare @Asia nvarchar(400)
		declare @Africa nvarchar(400)
		declare @Oceania nvarchar(400)
		declare @NorthAmerica nvarchar(400)
		declare @Europe nvarchar(400)
		declare @ANTARCTICA nvarchar(400) 
		set @SouthAmerica='AR,BO,BR,CL,CO,EC,FK,GF,GY,PE,PY,SR,UY,'
		set @Asia='AE,AF,AL,AM,AZ,BD,BH,BN,BT,CN,CY,GE,HK,ID,IL,IN,IQ,IR,JO,JP,KG,KH,KP,KR,KW,KZ,LA,LB,LK,LU,MM,MN,MO,MV,MY,NP,OM,PH,PK,QA,SA,SG,SY,TH,TJ,TM,TP,TR,TW,UZ,VN,YE,'
		set @Africa ='AO,BF,BI,BJ,BW,CD,CF,CG,CI,CM,CV,DJ,DZ,EG,ER,ET,GA,GH,GM,GN,GQ,GW,KE,KM,KN,LR,LS,LY,MA,MG,ML,MR,MU,MW,MZ,NA,NE,NG,RE,RW,SC,SD,SH,SL,SN,SO,ST,SZ,TD,TG,TN,TZ,UG,YT,ZA,ZM,ZW,'
		set @Oceania='AS,AU,CK,CX,FJ,FM,GU,KI,MH,NC,NF,NR,NU,NZ,PF,PG,PW,SB,TK,TO,TV,VU,WF,WS,'
		set @NorthAmerica='AG,AI,AN,AW,BB,BM,BS,BZ,CA,CR,CU,DM,DO,GD,GL,GP,GT,HN,HT,JM,KY,LC,MP,MQ,MS,MX,NI,PA,PM,PR,SV,TC,TT,US,VC,VE,VG,'
		set @Europe='AD,AT,BA,BE,BG,BY,CH,CS,CZ,DE,DK,EE,ES,FI,FO,FR,GB,GI,GR,HR,HU,IE,IS,IT,LI,LT,LV,MC,MD,MK,MT,NL,NO,PL,PT,RO,RU,SE,SI,SK,SM,UA,UK,VA,YU,'
		set @ANTARCTICA = 'AQ,'
		
		declare @SouthAmericaID int 
		declare @AsiaID int
		declare @AfricaID int
		declare @OceaniaID int
		declare @NorthAmericaID int
		declare @EuropeID int
		declare @ANTARCTICAID int
	end

	--Gen_Organizations
	insert into Gen_Organizations(Id,
		UnitName,
		UnitCTName,
		Contact_No1,
		Contact_No2,
		Contact_No3,
		Contact_NoType1,
		Contact_NoType2,
		Contact_NoType3,
		Fax,
		CreateBy,
		CreateDate,
		ModifyBy,
		ModifyDate,
		AddressEn,
		AddressCT,
		Gateway,
		Type,
		Status,
		IsBranch,
		Email,
		HandlingEmail
		--,AddressCS,
		--UnitCSName
		)
		select L_Code,	
		L_English,	
		L_Chinese,	
		Contact_No1,
		Contact_No2,	
		Contact_No3,
		Contact_NoType1,	
		Contact_NoType2,
		Contact_NoType3,
		Fax,
		Creator,	
		CreateDate,	
		ModifyBy,	
		ModifyDate,	
		AddressEnglish,	
		AddressChinese,	
		Gateway,
		Type,	
		Status,	
		IsBranch,	
		Email,	
		HandlingEmail	
		from UAT.dbo.Gen_P_Location
		
    --Gen_Positions  
	insert into Gen_Positions(ID,
		PositionName,
		PositionCTName,
		CreateBy,
		CreateDate,
		ModifyBy,
		ModifyDate,
		Status,
		Remark
		)
		select P_Code,
		P_English,
		P_Chinese,
		Creator,
		CreateDate,
		Modify_By,
		ModifyDate,
		Status,
		Remark
		from UAT.dbo.Gen_Position
	
	--BO_Groups
	update [BO_GroupClasses] set ClassName='Position',ClassCSName=N'职位',ClassCTName=N'職位' where ClassID='1'
	insert into [BO_GroupClasses](ClassID,ClassName,ClassCSName,ClassCTName) values('0','Structure',N'机构',N'機構')
	insert into BO_Groups(GroupID,
		GroupName,
		GroupCSName,
		ClassID,
		ParentID,
		L_P_Code,
		SortList, --Not null
		GLevel,   --Not null
		IsCatalog,--Not null
		IsBranch  --Not null
		)
		select Id,
		EnglishName,
		ChineseName,
		(case c.division when 'Location' then  '0' else '1' end) as ClassID,
		FatherId,
		L_P_Code,
		'',
		[Class],
		(case c.division when 'Location' then  '1' else '0' end) as IsCatalog,
		'0'
		from UAT.dbo.CompanyStructure	c
		
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
           ,[OrgCode]
           ,[PositionCode]
           )
    select u.[User_id],u.EnglishName,u.ChineseName,
		u.[Password],u.Email,u.Gender, u.Birthday,u.[Status],u.Creator
		,u.CreateDate,u.ModifyBy,u.ModifyDate, ep.OrgCode,ep.User_PositionCode
    from [UAT].dbo.gen_user u
    left join [UAT].dbo.Employ_Position ep on u.[User_id]=ep.[User_id] 
    INSERT INTO [BO_Users]([UserID],[UserName],[Password]) values('f','Front Line','f')
    INSERT INTO [BO_Users]([UserID],[UserName],[Password]) values('b','Back Office','b')
    INSERT INTO [BO_Users]([UserID],[UserName],[Password]) values('n','Normal','n')
    insert into BO_UserInGroups(UserID,GroupID) values('f','200907081740436715')
    insert into BO_UserInGroups(UserID,GroupID) values('b','200907081741010019')
    
    --Gen_Continents ----South America,Asia,Africa,Oceania,North America,Europe,ANTARCTICA
    begin 
		if(select COUNT(1) from Gen_Continents c where c.ContinentName='South America')=0
			insert Gen_Continents ([ContinentName]) values ('South America')
		if(select COUNT(1) from Gen_Continents c where c.ContinentName='Asia')=0
			insert Gen_Continents ([ContinentName]) values ('Asia')
		if(select COUNT(1) from Gen_Continents c where c.ContinentName='Africa')=0
			insert Gen_Continents ([ContinentName]) values ('Africa')
		if(select COUNT(1) from Gen_Continents c where c.ContinentName='Oceania')=0
			insert Gen_Continents ([ContinentName]) values ('Oceania')
		if(select COUNT(1) from Gen_Continents c where c.ContinentName='North America')=0
			insert Gen_Continents ([ContinentName]) values ('North America')
		if(select COUNT(1) from Gen_Continents c where c.ContinentName='Europe')=0
			insert Gen_Continents ([ContinentName]) values ('Europe')
		if(select COUNT(1) from Gen_Continents c where c.ContinentName='ANTARCTICA')=0
			insert Gen_Continents ([ContinentName]) values ('ANTARCTICA')
		
		select @SouthAmericaID=ContinentID from Gen_Continents where ContinentName='South America'
		select @AsiaID=ContinentID from Gen_Continents where ContinentName='Asia'
		select @AfricaID=ContinentID from Gen_Continents where ContinentName='Africa'
		select @OceaniaID=ContinentID from Gen_Continents where ContinentName='Oceania'
		select @NorthAmericaID=ContinentID from Gen_Continents where ContinentName='North America'
		select @EuropeID=ContinentID from Gen_Continents where ContinentName='Europe'
		select @ANTARCTICAID=ContinentID from Gen_Continents where ContinentName='ANTARCTICA'
    end
    
	--Gen_Countries
	print 'Gen_Countries    Original date:243   Import:243'
	INSERT INTO  Gen_Countries([CountryID],[CountryName],[CountryCTName],[IddCode],ContinentID,CreateBy,CreateDate,ModifyBy,ModifyDate,OurURL)
	select Code,EnglishName,ChineseName,IDDCode,
		(case 
		   when (CHARINDEX(Code+',',@SouthAmerica))>0 THEN @SouthAmericaID
		   when (CHARINDEX(Code+',',@Asia))>0 THEN @AsiaID
		   when (CHARINDEX(Code+',',@Africa))>0 THEN @AfricaID
		   when (CHARINDEX(Code+',',@Oceania))>0 THEN @OceaniaID
		   when (CHARINDEX(Code+',',@NorthAmerica))>0 THEN @NorthAmericaID
		   when (CHARINDEX(Code+',',@Europe))>0 THEN @EuropeID
		   when (CHARINDEX(Code+',',@ANTARCTICA))>0 THEN @ANTARCTICAID
		END) as ContinentID,
		Creator,CreateDate,ModifyBy,ModifyDate ,uc.OurURL
	from [UAT]..gen_country uc
	
	--Gen_Cities
	print 'Gen_Cities  Original date:9572   Import:9572'
	INSERT INTO  [Gen_Cities]([CityID],[CityName],[CityCTName],[IddCode],[CityCode],[PreCode],[CountryID],OurURL)
	select a.ID,a.EnglishName,a.ChineseName,a.IDDCode,a.Code,SUBSTRING(a.EnglishName,1,1) as PreCode,b.Code,c.OurURL
	from [UAT]..relation a inner join [UAT]..relation b on a.fatherid=b.id and a.Class='1' 
	inner join [UAT].dbo.gen_city c on a.Code = c.Code
	order by b.ID
	
	--数据对应的CityCode在Gen_Cities中无法找到
	insert into Gen_Cities(CityID,CityName,CityCode,PreCode) values('039','039','039','0')
	insert into Gen_Cities(CityID,CityName,CityCode,PreCode) values('FJI','FJI','FJI','F')
	insert into Gen_Cities(CityID,CityName,CityCode,PreCode) values('JSP','JSP','JSP','J')
	insert into Gen_Cities(CityID,CityName,CityCode,PreCode) values('KRA','KRA','KRA','K')

	--Gen_Areas
	print 'Gen_Areas  Original date:277   Import:277'
	INSERT INTO  [Gen_Areas]([AreaID],[AreaName],[AreaCTName],[CityID])
	select a.ID,a.EnglishName,a.EnglishName,b.FatherID 
	from [uat]..relation a inner join [uat]..relation b on a.fatherid=b.id and a.Class='4' order by b.ID
	--insert relation不存在的Area
	insert into Gen_Areas(AreaID,AreaName,AreaCSName,AreaCTName,CityID)
	select convert(nvarchar,max(Id))+'_hotel' as AreaID, District,District,District, c.CityID 
	from [UAT].dbo.gen_hotel h
	inner join Gen_Cities c on c.CityCode= h.CityCode collate database_default
	where ISNULL(District,'')<>'' 
		and not exists(select * from Gen_Areas a where a.AreaName=h.District collate database_default)
	group by h.District, c.CityID 

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
		from [UAT].dbo.gen_roomtype 
	--插入空的RoomType
	insert into Gen_RoomType(RoomTypeID,RmtName,RmtCTName,RmtCSName,MaxPax)
	values('0','','','',1)
		
    --Gen_RoomCategory
    print 'Gen_RoomCategory  Original date:21  Import:21'
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
		from [UAT].dbo.Gen_HotelType 
	--插入空的Category
	insert into Gen_RoomCategory(CategoryID,CategoryName,CategoryCTName,OwnerHotelID) values(0,'','',null)	
	
	--插入新类型Item
	if(select COUNT(1) from Gen_Items where ItemID='4')=0
		insert into Gen_Items(ItemID,ItemName,ItemCSName,ItemCTName,IsRoom) values('4','Breakfast',N'早餐',N'早餐',0)
	
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
		from [UAT].dbo.Gen_Account_Curr_Code
	--update Gen_Currency
	update Gen_Currency set Symbol=(case when CCYCode='SGD' then N'SGD' else CCYCode end)	
	update Gen_Currency set ccycsname=N'澳大利亚元',ccyctname=N'澳大利亞元'  where CCYCode='AUD'
	update Gen_Currency set ccycsname=N'加拿大元',ccyctname=N'加拿大元'  where CCYCode='CAD'
	update Gen_Currency set ccycsname=N'瑞士法郎',ccyctname=N'瑞士法郎'  where CCYCode='CHF'
	update Gen_Currency set ccycsname=N'欧元',ccyctname=N'歐元'  where CCYCode='EUR'
	update Gen_Currency set ccycsname=N'英镑',ccyctname=N'英鎊'  where CCYCode='GBP'
	update Gen_Currency set ccycsname=N'港币',ccyctname=N'港幣'  where CCYCode='HKD'
	update Gen_Currency set ccycsname=N'日元',ccyctname=N'日元'  where CCYCode='JPY'
	update Gen_Currency set ccycsname=N'马来西亚币',ccyctname=N'馬來西亞幣'  where CCYCode='MYR'
	update Gen_Currency set ccycsname=N'新台币',ccyctname=N'新臺幣'  where CCYCode='NTD'
	update Gen_Currency set ccycsname=N'新西兰元',ccyctname=N'新西蘭元'  where CCYCode='NZD'
	update Gen_Currency set ccycsname=N'菲律宾比索',ccyctname=N'菲律賓比索'  where CCYCode='PHP'
	update Gen_Currency set ccycsname=N'人民币',ccyctname=N'人民幣'  where CCYCode='RMB'
	update Gen_Currency set ccycsname=N'新加坡元',ccyctname=N'新加坡元'  where CCYCode='SGD'
	update Gen_Currency set ccycsname=N'泰铢',ccyctname=N'泰銖'  where CCYCode='THB'
	update Gen_Currency set ccycsname=N'新台币',ccyctname=N'新臺幣'  where CCYCode='TWD'
	update Gen_Currency set ccycsname=N'美元',ccyctname=N'美元'  where CCYCode='USD'
	update Gen_Currency set ccycsname=N'南非兰特',ccyctname=N'南非蘭特'  where CCYCode='ZAR'
		
	--Gen_Rates 
	print 'Gen_Rates   Original date:14   Import:12   Reason:'--旧DB有2笔数据对应在新DB中作为主键不能为空
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
		from [UAT].dbo.gen_currency 
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
		from [UAT].dbo.gen_style
		
    --Gen_Hotels 
    print 'Gen_Hotels     Original date:8428   Import:8419' --数据对应的CityCode在Gen_Cities中无法找到 solution add city ('039','FJI','JSP','KRA')
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
		convert(int,substring((case b.Class when 'Motel' then '0' else b.Class end),1,1)) as Class,
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
		from (select CityID ,CityCode  from  Gen_Cities ) a,[UAT].dbo.gen_hotel b 
		left join Gen_Styles C on substring(b.Style ,1,charindex(' /',b.Style)) COLLATE SQL_Latin1_General_CP1_CI_AS=C.StyleName 
		where a.CityCode COLLATE SQL_Latin1_General_CP1_CI_AS=b.CityCode
	--update AreaID
	update Gen_Hotels set AreaID = (
		select top 1 AreaID 
		from Gen_Areas a 
		inner join [UAT-TExpert].dbo.gen_hotel h on h.District = a.AreaName collate database_default
		where h.Hot_Code = Gen_Hotels.HotelID collate database_default
		)	
	
	--插入自己的Category从gen_hot_room
	insert into Gen_RoomCategory(CategoryID,CategoryName,CategoryCTName,OwnerHotelID)
	select convert(nvarchar,MAX(r.Id))+'_room' as CategoryID, r.[Type],r.[Type],r.hot_code
	from [UAT].dbo.gen_hot_room r
	where (select COUNT(1) from Gen_RoomCategory rc 
			where rc.CategoryName=isnull(r.[Type],'') COLLATE database_default
				and (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=r.hot_code COLLATE database_default)
		)=0
	group by r.[Type],r.hot_code	
		
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
		from [UAT].dbo.gen_service
	
	--Gen_Services手动添加 FREE INTERNET   免費上網 记录 
	insert into Gen_Services(ServiceName ,ServiceCTName ) values('FREE INTERNET',N'免費上網')	
	
	--Gen_Hotel_Services
	print 'Gen_Hotel_Services   Original date:15449   Import:15449' --注:必须在Gen_Services手动添加 FREE INTERNET   免費上網 记录 
	insert into Gen_Hotel_Services(HotelID,ServiceID)
	select a.hot_code ,b.ServiceID from [UAT].dbo.gen_hot_service a
	left join Gen_Services b on a.ServiceName like b.ServiceName+'%' COLLATE SQL_Latin1_General_CP1_CI_AS	

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
		from [UAT].dbo.gen_facility

	--Gen_Hotel_Facility
	print 'Gen_Hotel_Facility    Original date:45739   Import:45736'--原数据有3笔重复的数据where a.Hot_Code  =200604196911 and b.facilityID in (592,611,614) solution: ignore
	--select * from [UAT].dbo.gen_hot_facility a  where a.Hot_Code  =200604196911-- and b.facilityID in (592,611,614)
	insert into Gen_Hotel_Facility(HotelID,HotelFacilityID)
	Select distinct a.Hot_Code , b.FacilityID  from (
	select substring(FacilityName, 1,charindex(' /',FacilityName+' /')-1) as ll,*  from [UAT].dbo.gen_hot_facility
	) as a left join Gen_Facilities b on a.ll COLLATE SQL_Latin1_General_CP1_CI_AS=  b.FacilityName 

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
		from [UAT].dbo.gen_restaurant
	
	--Gen_Hotel_Restaurant
	print 'Gen_Hotel_Restaurant    Original date:8614   Import:8614' 
	insert into Gen_Hotel_Restaurant(HotelID,     
		RestaurantID
		)
		select  a.Hot_code,b.RestaurantID
		from [UAT].dbo.gen_hot_restaurant a left join Gen_Restaurants b
		on a.Name COLLATE SQL_Latin1_General_CP1_CI_AS like b.RestaurantName +'%' 

    --Gen_Rooms
    print 'Gen_Rooms     Original date:34922   Import:1815'--原数据在RoomCategory,Type 2列可能存在空值,而对应的新DB中此2列均不能为空 solution: Ignore insert late
    --select * from [UAT].dbo.gen_hot_room a where  isnull(a.RoomCategory,'')= '' or isnull(a.Type,'') = ''
    insert into Gen_Rooms(RoomID,                          --且此2列的数据可能在[UAT].dbo.gen_roomtype,[UAT].dbo.Gen_HotelType中找不到
		HotelID,
		CategoryID,
		RoomTypeID,
		RoomSize,
		RoomCount,
		StatusID
		)
		select a.Id,
		a.Hot_Code, 
		H.CategoryID,
		isnull(c.RoomTypeID,'0') as  RoomTypeID,
		a.RoomSize,
		a.Qty,
		'0' as StatusID
		from [UAT].dbo.gen_hot_room a
		inner join Gen_RoomCategory H on ISNULL(a.[Type],'') =H.CategoryName collate database_default
					and (isnull(H.OwnerHotelID,'')='' or H.OwnerHotelID=a.hot_code collate database_default)
		left join gen_roomtype c on ISNULL(a.RoomCategory,'')=c.RmtName collate database_default

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
		from [UAT].dbo.gen_amenities
		
	/*gen_hot_amentities 设备与酒店的关系??? */
	--Gen_Room_Amenity
	--insert into Gen_Room_Amenity(RoomID,
	--	AmenityID
	--	)
	--	select distinct a.RoomID,b.AmenityID  from (
	--	select [Hot_code] as RoomID , substring([AmenityName],1, charindex(' /',[AmenityName]))as [AmenityName] from [UAT].dbo.gen_hot_amentities) a,
	--	Gen_Amentities b
	--	where a.[AmenityName] COLLATE SQL_Latin1_General_CP1_CI_AS=b.AmenityName	
	
	--更新Gen_Hotels ConditionalDescription and ChildCondition
	update Gen_Hotels  set Gen_Hotels.ConditionalDescription=[UAT].dbo.hotinfo.Condition,
		Gen_Hotels.EffectiveDate=convert(date,[UAT].dbo.hotinfo.EffectiveDate),
		Gen_Hotels.ChildCondition=[UAT].dbo.hotinfo.C_ChildRemark 
	from  Gen_Hotels join [UAT].dbo.hotinfo  on Gen_Hotels.HotelID COLLATE SQL_Latin1_General_CP1_CI_AS=[UAT].dbo.hotinfo.HotelRefNo 
	
	--插入单价
		--插入酒店自己的Category, select distinct categoryName from Gen_RoomCategory
		insert into Gen_RoomCategory(CategoryID,CategoryName,CategoryCTName,OwnerHotelID)
		select convert(nvarchar,MAX(h.Id))+'_fare' as CategoryID, h.[Type],h.[Type],i.HotelRefNo
		from [UAT].dbo.[hif_fare] h
		inner join [UAT].dbo.hotinfo i on h.RefNo= i.RefNo
		where (select COUNT(1) from Gen_RoomCategory rc 
				where rc.CategoryName=isnull(h.[Type],'') COLLATE database_default
					and (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=i.HotelRefNo COLLATE database_default)
			)=0
		group by h.Type,i.HotelRefNo

		--插入房间 select * from Gen_Rooms
		insert into Gen_Rooms(RoomID,HotelID,RoomTypeID,CategoryID,StatusID)
		select convert(nvarchar,max (h.id))+'_fare' as RoomID, i.HotelRefNo,t.RoomTypeID,rc.CategoryID,'0' as StatusID--,h.Roomtype, h.[type]
		from [UAT].dbo.[hif_fare] h 
		inner join [UAT].dbo.hotinfo i on h.RefNo= i.RefNo
		inner join Gen_RoomType t on h.Roomtype = t.RmtName COLLATE database_default
		inner join Gen_RoomCategory rc on (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=i.HotelRefNo COLLATE database_default) 
				and h.[Type]= rc.CategoryName COLLATE database_default
		where (select COUNT(1) from Gen_Rooms r 
				where r.HotelID=i.HotelRefNo COLLATE database_default 
					and r.RoomTypeID=t.RoomTypeID and r.CategoryID=rc.CategoryID
				)=0
		group by i.HotelRefNo,t.RoomTypeID,rc.CategoryID--,h.Roomtype, h.Type

		--插入Market select * from Gen_markets
		insert into Gen_Markets(MarketID,MarketName)
		select MAX(id) as id, remark1  from [UAT].dbo.hif_fare 
		where remark1 like '%MARKET%' and remark1 not like '%,%' and remark1 not like '%+%'
		group by remark1
		order by remark1
		
		--插入Price
		begin 
			delete from Gen_RoomItem
			delete from Gen_RoomItemHistory
			begin
				declare @HotelRefNo nvarchar(18)
				declare @RMID nvarchar(18)
				declare @ID nvarchar(18)
				declare @StartDate datetime
				declare @EndDate datetime
				declare @CastPrice money
				declare @Extra_bed money
				declare @Breakfast nvarchar(18)
				declare @BreakfastPri money
				declare @Sun nvarchar(18)
				declare @Mon nvarchar(18)
				declare @Tue nvarchar(18)
				declare @Wed nvarchar(18)
				declare @Thu nvarchar(18)
				declare @Fri nvarchar(18)
				declare @Sat nvarchar(18)
				declare @MarketID nvarchar(18)
				declare @Currency nvarchar(18)
				declare @MaxPax int
			end
			
			declare cursorPri cursor for 
				SELECT i.HotelRefNo,r.RoomId as RMID,h.id, h.StartDate,h.EndDate,h.CastPrice,h.Extra_bed,h.Breakfast,
					(case h.Breakfast WHEN ' Y' THEN 0 when 'Y' then 0 when 'N' then 0  when 'WBF' then 0 when '16..5' then 16.5  else convert(money, h.Breakfast) end) as BreakfastPri, 
					h.Sun,h.Mon,h.Tue,h.Wed,h.Thu,h.Fri,h.Sat,m.MarketID,
					(select top 1 s.Currency from [UAT].dbo.hif_supplier s where s.RefNo=h.RefNo) as Currency,
					t.MaxPax
				FROM [UAT].[dbo].[hif_fare] h
				inner join [UAT].dbo.hotinfo i on h.RefNo= i.RefNo
				inner join Gen_RoomType t on t.RmtName = h.Roomtype  collate database_default
				inner join Gen_RoomCategory rc on rc.CategoryName = h.[Type] collate database_default and (isnull(OwnerHotelID,'')='' or rc.OwnerHotelID=i.HotelRefNo collate database_default)
				inner join Gen_Rooms r on r.RoomTypeID=t.RoomTypeID collate database_default and r.CategoryID=rc.CategoryID collate database_default and r.HotelID=i.HotelRefNo collate database_default
				inner join Gen_Markets m on (case isnull(h.remark1,'') when '' then 'All Market' else h.remark1 End)=m.MarketName collate database_default
				where (remark1 like '%MARKET%' and remark1 not like '%,%' and remark1 not like '%+%') or isnull(remark1,'')=''
				--distinct 118838, not distinct 118838
			open cursorPri
			fetch next from cursorPri into @HotelRefNo,@RMID,@ID,@StartDate,@EndDate,@CastPrice,@Extra_bed,@Breakfast,@BreakfastPri,
			@Sun,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@MarketID,@Currency,@MaxPax
			while @@fetch_status=0  
				begin
					while(@StartDate<=@EndDate)
					begin
						if(DATEDIFF(d,@StartDate,getdate())>0)
							begin 
								if(@Breakfast='Y')
									if(select COUNT(1) from [Gen_RoomItemHistory] where [RoomID]=@RMID and [ItemID]='1' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
										INSERT INTO [Gen_RoomItemHistory]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold)
										values(@RMID,'1',@MarketID,@StartDate,@CastPrice,0,@Currency,@MaxPax,0,0,0,0,0)
								else
									if(select COUNT(1) from [Gen_RoomItemHistory] where [RoomID]=@RMID and [ItemID]='2' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
										INSERT INTO [Gen_RoomItemHistory]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold)
										values(@RMID,'2',@MarketID,@StartDate,@CastPrice,0,@Currency,@MaxPax,0,0,0,0,0)
								if(@BreakfastPri>0)
									if(select COUNT(1) from [Gen_RoomItemHistory] where [RoomID]=@RMID and [ItemID]='4' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
										INSERT INTO [Gen_RoomItemHistory]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold)
										values(@RMID,'4',@MarketID,@StartDate,@BreakfastPri,0,@Currency,0,0,0,0,0,0)
								if(@Extra_bed>0)
									if(select COUNT(1) from [Gen_RoomItemHistory] where [RoomID]=@RMID and [ItemID]='3' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
										INSERT INTO [Gen_RoomItemHistory]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold)
										values(@RMID,'3',@MarketID,@StartDate,@Extra_bed,0,@Currency,1,0,0,0,0,0)
							end
						else
							begin
								if(@Breakfast='Y')
									if(select COUNT(1) from [Gen_RoomItem] where [RoomID]=@RMID and [ItemID]='1' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
										INSERT INTO [Gen_RoomItem]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold)
										values(@RMID,'1',@MarketID,@StartDate,@CastPrice,0,@Currency,@MaxPax,0,0,0,0,0)
								else
									if(select COUNT(1) from [Gen_RoomItem] where [RoomID]=@RMID and [ItemID]='2' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
										INSERT INTO [Gen_RoomItem]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold)
										values(@RMID,'2',@MarketID,@StartDate,@CastPrice,0,@Currency,@MaxPax,0,0,0,0,0)
								if(@BreakfastPri>0)
									if(select COUNT(1) from [Gen_RoomItem] where [RoomID]=@RMID and [ItemID]='4' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
										INSERT INTO [Gen_RoomItem]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold)
										values(@RMID,'4',@MarketID,@StartDate,@BreakfastPri,0,@Currency,0,0,0,0,0,0)
								if(@Extra_bed>0)
									if(select COUNT(1) from [Gen_RoomItem] where [RoomID]=@RMID and [ItemID]='3' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
										INSERT INTO [Gen_RoomItem]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold)
										values(@RMID,'3',@MarketID,@StartDate,@Extra_bed,0,@Currency,1,0,0,0,0,0)
							end
							
						set @StartDate=dateadd(d,1,@StartDate)
					end
					fetch next from cursorPri into @HotelRefNo,@RMID,@ID,@StartDate,@EndDate,@CastPrice,@Extra_bed,@Breakfast,@BreakfastPri,
													@Sun,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@MarketID,@Currency,@MaxPax
				end

			close cursorPri
			deallocate cursorPri
		end
		
		--更新为空的Category
		update Gen_RoomCategory set CategoryName='(Blank)',CategoryCTName='(Blank)',CategoryCSName='(Blank)' where CategoryID='0'
		update Gen_RoomType set RmtName='(Blank)',RmtCSName='(Blank)',RmtCTName='(Blank)' where RoomTypeID='0'
End		
commit transaction
/*------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------*/
--SELECT COUNT(1) FROM [Gen_RoomItem]
--select count(1) FROM [Gen_RoomItemHistory]
--select MAX(PriceDate) from Gen_RoomItemHistory
--select Min(PriceDate) from Gen_RoomItem