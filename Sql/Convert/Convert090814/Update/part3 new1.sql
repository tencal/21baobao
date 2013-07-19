/*------------------------------------------------------------------------------------------------------*/
--Change all "[UAT]." to "[TExpert db name]."
use [SIT-TEHR]  --Change "[UAT-TEHR]" to destination database name
/*------------------------------------------------------------------------------------------------------*/
SET XACT_ABORT ON 
begin transaction
begin
	--定义变量
	Begin
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
	
    --Gen_Continents --各大洲--South America,Asia,Africa,Oceania,North America,Europe,ANTARCTICA
    --begin 
		--if(select COUNT(1) from Gen_Continents c where c.ContinentName='South America')=0
		--	insert Gen_Continents ([ContinentName]) values ('South America')
		--if(select COUNT(1) from Gen_Continents c where c.ContinentName='Asia')=0
		--	insert Gen_Continents ([ContinentName]) values ('Asia')
		--if(select COUNT(1) from Gen_Continents c where c.ContinentName='Africa')=0
		--	insert Gen_Continents ([ContinentName]) values ('Africa')
		--if(select COUNT(1) from Gen_Continents c where c.ContinentName='Oceania')=0
		--	insert Gen_Continents ([ContinentName]) values ('Oceania')
		--if(select COUNT(1) from Gen_Continents c where c.ContinentName='North America')=0
		--	insert Gen_Continents ([ContinentName]) values ('North America')
		--if(select COUNT(1) from Gen_Continents c where c.ContinentName='Europe')=0
		--	insert Gen_Continents ([ContinentName]) values ('Europe')
		--if(select COUNT(1) from Gen_Continents c where c.ContinentName='ANTARCTICA')=0
		--	insert Gen_Continents ([ContinentName]) values ('ANTARCTICA')
		
		--select @SouthAmericaID=ContinentID from Gen_Continents where ContinentName='South America'
		--select @AsiaID=ContinentID from Gen_Continents where ContinentName='Asia'
		--select @AfricaID=ContinentID from Gen_Continents where ContinentName='Africa'
		--select @OceaniaID=ContinentID from Gen_Continents where ContinentName='Oceania'
		--select @NorthAmericaID=ContinentID from Gen_Continents where ContinentName='North America'
		--select @EuropeID=ContinentID from Gen_Continents where ContinentName='Europe'
		--select @ANTARCTICAID=ContinentID from Gen_Continents where ContinentName='ANTARCTICA'
    --end
    
	--Gen_Countries  --国家
	begin
		update  Gen_Countries set [CountryID]=uc.Code,[CountryName]=uc.EnglishName,
			[CountryCTName]=uc.ChineseName,[IddCode]=uc.IDDCode,
			CreateBy=uc.Creator,CreateDate=uc.CreateDate,ModifyBy=uc.ModifyBy,ModifyDate=uc.ModifyDate,OurURL=uc.OurURL
		from [UAT].dbo.gen_country uc
		where Gen_Countries.[CountryID]=uc.Code COLLATE SQL_Latin1_General_CP1_CI_AS
		
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
		from [UAT].dbo.gen_country uc
		where uc.Code COLLATE SQL_Latin1_General_CP1_CI_AS not in  (select [CountryID] from Gen_Countries) 
	end
	
	--Gen_Cities --城市
	begin
		update  [Gen_Cities] set [CityID]=a.ID,[CityName]=a.EnglishName,[CityCTName]=a.ChineseName,
			[IddCode]=a.IDDCode,[CityCode]=a.Code,[PreCode]=SUBSTRING(a.EnglishName,1,1),
			[CountryID]=b.Code,OurURL=c.OurURL
		from [UAT].dbo.relation a 
		inner join [UAT].dbo.relation b on a.fatherid=b.id and a.Class='1' 
		inner join [UAT].dbo.gen_city c on a.Code = c.Code
		where [Gen_Cities].[CityID] = convert(nvarchar(max),a.ID)
		
		INSERT INTO  [Gen_Cities]([CityID],[CityName],[CityCTName],[IddCode],[CityCode],[PreCode],[CountryID],OurURL)
		select a.ID,a.EnglishName,a.ChineseName,a.IDDCode,a.Code,SUBSTRING(a.EnglishName,1,1) as PreCode,b.Code,c.OurURL
		from [UAT].dbo.relation a 
		inner join [UAT].dbo.relation b on a.fatherid=b.id and a.Class='1' 
		inner join [UAT].dbo.gen_city c on a.Code = c.Code
		where convert(nvarchar(max),a.ID) not in (select [CityID] from [Gen_Cities])
		
		----数据对应的CityCode在Gen_Cities中无法找到
		--insert into Gen_Cities(CityID,CityName,CityCode,PreCode) values('039','039','039','0')
		--insert into Gen_Cities(CityID,CityName,CityCode,PreCode) values('FJI','FJI','FJI','F')
		--insert into Gen_Cities(CityID,CityName,CityCode,PreCode) values('JSP','JSP','JSP','J')
		--insert into Gen_Cities(CityID,CityName,CityCode,PreCode) values('KRA','KRA','KRA','K')
	end

	--Gen_Areas
	begin
		update  [Gen_Areas]set[AreaName]=a.EnglishName,[AreaCTName]=a.EnglishName,[CityID]=b.FatherID 
		from [UAT].dbo.relation a 
		inner join [UAT].dbo.relation b on a.fatherid=b.id and a.Class='4'
		where [Gen_Areas].[AreaID]=convert(nvarchar(max),a.ID)
	
		INSERT INTO  [Gen_Areas]([AreaID],[AreaName],[AreaCTName],[CityID])
		select a.ID,a.EnglishName,a.EnglishName,b.FatherID 
		from [UAT].dbo.relation a 
		inner join [UAT].dbo.relation b on a.fatherid=b.id and a.Class='4' 
		where convert(nvarchar(max),a.ID) not in (select [AreaID] from [Gen_Areas])
		
		--insert relation不存在的Area
		insert into Gen_Areas(AreaID,AreaName,AreaCSName,AreaCTName,CityID)
		select convert(nvarchar,max(Id))+'_hotel' as AreaID, District,District,District, c.CityID 
		from [UAT].dbo.gen_hotel h
		inner join Gen_Cities c on c.CityCode= h.CityCode collate database_default
		where ISNULL(District,'')<>'' 
			and not exists(select * from Gen_Areas a where a.AreaName=h.District collate database_default)
		group by h.District, c.CityID 
	end

	--Gen_Airports
	begin
		update [Gen_Airports]set[AirportCode]=a.Code,[CityID]=b.FatherID,[AirportName]=a.EnglishName,[AirportCTName]=a.ChineseName 
		from [UAT].dbo.relation a 
		inner join [UAT].dbo.relation b on a.fatherid=b.id and a.Class='3' 
		where [Gen_Airports].[AirportID]=a.Code collate database_default
	
		INSERT INTO  [Gen_Airports]([AirportID],[AirportCode],[CityID],[AirportName],[AirportCTName])
		select a.Code,a.Code,b.FatherID,a.EnglishName,a.ChineseName 
		from [UAT].dbo.relation a 
		inner join [UAT].dbo.relation b on a.fatherid=b.id and a.Class='3' 
		where a.Code collate database_default not in(select [AirportID] from [Gen_Airports])
	end
	
	--Gen_RoomType 07.20
	--begin
		--insert into Gen_RoomType(
		--	RoomTypeID,
		--	RmtName,
		--	RmtCTName,
		--	CreateBy,
		--	CreateDate,
		--	ModifyBy,
		--	ModifyDate,
		--	MaxPax
		--	)
		--	select 
		--	IdKey,
		--	EnglishName,
		--	ChineseName,
		--	Creator,
		--	CreateDate,
		--	ModifyBy,
		--	ModifyDate,
		--	Qty
		--	from [UAT].dbo.gen_roomtype 
			
		----插入空的RoomType ???
		--insert into Gen_RoomType(RoomTypeID,RmtName,RmtCTName,RmtCSName,MaxPax)
		--values('0','','','',1)
	--end
		
    --Gen_RoomCategory
    --begin
		--insert into Gen_RoomCategory(CategoryID,
		--	CategoryName,
		--	CategoryCTName,
		--	Sort,
		--	CreateBy,
		--	CreateDate,
		--	ModifyBy,
		--	ModifyDate
		--	)
		--	select ID,
		--	EnglishName,
		--	ChineseName,
		--	N_OrderBy,
		--	Creator,
		--	CreateDate,
		--	ModifyBy,
		--	ModifyDate
		--	from [UAT].dbo.Gen_HotelType 
		----插入空的Category ???
		--insert into Gen_RoomCategory(CategoryID,CategoryName,CategoryCTName,OwnerHotelID) values(0,'','',null)	
	--end
	
	--插入新类型Item ???
	--begin
		--if(select COUNT(1) from Gen_Items where ItemID='4')=0
		--	insert into Gen_Items(ItemID,ItemName,ItemCSName,ItemCTName,IsRoom) values('4','Breakfast',N'早餐',N'早餐',0)
	--end
	
	--Gen_Currency
	begin
		update Gen_Currency set CCYCode=C_Currency_Code,	
			CCYName=C_Description,
			[Status]=N_Status,
			CreateBy=C_Creator,
			CreateDate=D_CreateDate,
			ModifyBy=C_ModifyBy,
			ModifyDate=D_ModifyDate
		from [UAT].dbo.Gen_Account_Curr_Code
		where Gen_Currency.CCYCode=[UAT].dbo.Gen_Account_Curr_Code.C_Currency_Code collate database_default
	
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
		where [UAT].dbo.Gen_Account_Curr_Code.C_Currency_Code collate database_default not in( select CCYCode from Gen_Currency)
	
		--update Gen_Currency
		--update Gen_Currency set Symbol=(case when CCYCode='SGD' then N'SGD' else CCYCode end)	
		--update Gen_Currency set ccycsname=N'澳大利亚元',ccyctname=N'澳大利亞元'  where CCYCode='AUD'
		--update Gen_Currency set ccycsname=N'加拿大元',ccyctname=N'加拿大元'  where CCYCode='CAD'
		--update Gen_Currency set ccycsname=N'瑞士法郎',ccyctname=N'瑞士法郎'  where CCYCode='CHF'
		--update Gen_Currency set ccycsname=N'欧元',ccyctname=N'歐元'  where CCYCode='EUR'
		--update Gen_Currency set ccycsname=N'英镑',ccyctname=N'英鎊'  where CCYCode='GBP'
		--update Gen_Currency set ccycsname=N'港币',ccyctname=N'港幣'  where CCYCode='HKD'
		--update Gen_Currency set ccycsname=N'日元',ccyctname=N'日元'  where CCYCode='JPY'
		--update Gen_Currency set ccycsname=N'马来西亚币',ccyctname=N'馬來西亞幣'  where CCYCode='MYR'
		--update Gen_Currency set ccycsname=N'新台币',ccyctname=N'新臺幣'  where CCYCode='NTD'
		--update Gen_Currency set ccycsname=N'新西兰元',ccyctname=N'新西蘭元'  where CCYCode='NZD'
		--update Gen_Currency set ccycsname=N'菲律宾比索',ccyctname=N'菲律賓比索'  where CCYCode='PHP'
		--update Gen_Currency set ccycsname=N'人民币',ccyctname=N'人民幣'  where CCYCode='RMB'
		--update Gen_Currency set ccycsname=N'新加坡元',ccyctname=N'新加坡元'  where CCYCode='SGD'
		--update Gen_Currency set ccycsname=N'泰铢',ccyctname=N'泰銖'  where CCYCode='THB'
		--update Gen_Currency set ccycsname=N'新台币',ccyctname=N'新臺幣'  where CCYCode='TWD'
		--update Gen_Currency set ccycsname=N'美元',ccyctname=N'美元'  where CCYCode='USD'
		--update Gen_Currency set ccycsname=N'南非兰特',ccyctname=N'南非蘭特'  where CCYCode='ZAR'
	end
	
	--Gen_Rates 
	begin
		update Gen_Rates set CCYCodeA=c.Code,
			CCYCodeB=c.DEFCode,
			Rate=c.Rate,
			CreateDate=c.CreateDate,
			CreateBy=c.Creator,
			ModifyDate=c.ModifyDate,
			ModifyBy=c.ModifyBy
		from [UAT].dbo.gen_currency c
		where DEFCode is not null and Gen_Rates.CCYCodeA=c.Code collate database_default and Gen_Rates.CCYCodeB=c.DEFCode collate database_default
			  
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
		from [UAT].dbo.gen_currency c
		where DEFCode is not null and (select COUNT(0) from  Gen_Rates where Gen_Rates.CCYCodeA=c.Code collate database_default and Gen_Rates.CCYCodeB=c.DEFCode collate database_default)=0
	end
		
	--Gen_Styles
	begin
		update Gen_Styles set StyleCTName=s.ChineseName,
			CreateBy=s.Creator,CreateDate=s.CreateDate,
			ModifyBy=s.ModifyBy,ModifyDate=s.ModifyDate
		from [UAT].dbo.gen_style s
		where Gen_Styles.StyleName =s.EnglishName collate database_default
		
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
		from [UAT].dbo.gen_style s
		where not exists(select top 1 * from Gen_Styles where Gen_Styles.StyleName=s.EnglishName collate database_default)
	end
		
    --Gen_Hotels
    --Add by 2010-03-12 11:20 扩大字段存储容量
    alter table dbo.Gen_Hotels alter column CreateBy nvarchar(30)
    alter table dbo.Gen_Hotels alter column ModifyBy nvarchar(30)
    alter table dbo.Gen_Hotels alter column OldHotelInfo nvarchar(1500)
    alter table dbo.Gen_Hotels alter column Titlepic nvarchar(255)
    begin
		update Gen_Hotels set HotelID=b.Hot_Code,
			HotelName=b.EnglishName,
			HotelCTName=b.ChineseName,
			CityID=a.CityID,
			StyleID=c.StyleID, 
			Star=convert(int,substring((case b.Class when 'Motel' then '0' else b.Class end),1,1)),
			PhoneNo=b.Tel,
			FaxNo=b.Fax,
			OurURL=b.OurURL,
			HotelURL=b.URL,
			Email=b.Email,
			Address=b.Address,
			Transportation=b.Transporation,
			CreateBy=b.Creator,
			CreateDate=b.UpdateDate,
			ModifyBy=b.ModifyBy,
			ModifyDate=b.ModifyDate,
			CountryID=b.CountryCode,
			PromotionDescription=b.Pros,
			[ExpireDate]=b.D_ClosedDate,OldHotelInfo=b.C_RoomsRemark
		from (select CityID ,CityCode  from  Gen_Cities ) a,
			[UAT].dbo.gen_hotel b 
		left join Gen_Styles C on substring(b.Style ,1,charindex(' /',b.Style)) COLLATE SQL_Latin1_General_CP1_CI_AS=C.StyleName 
		where a.CityCode COLLATE SQL_Latin1_General_CP1_CI_AS=b.CityCode 
			and Gen_Hotels.HotelID=b.Hot_Code collate database_default
    
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
			CreateBy,
			CreateDate,
			ModifyBy,
			ModifyDate,
			CountryID,
			PromotionDescription,
			[ExpireDate],OldHotelInfo
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
			b.Creator,
			b.UpdateDate,
			b.ModifyBy,
			b.ModifyDate,
			b.CountryCode,
			b.Pros  ,
			b.D_ClosedDate,C_RoomsRemark
		from (select CityID ,CityCode  from  Gen_Cities ) a,[UAT].dbo.gen_hotel b 
		left join Gen_Styles C on substring(b.Style ,1,charindex(' /',b.Style)) COLLATE SQL_Latin1_General_CP1_CI_AS=C.StyleName 
		where a.CityCode COLLATE SQL_Latin1_General_CP1_CI_AS=b.CityCode 
			and (b.D_ClosedDate is null or b.D_ClosedDate>GETDATE())
			and b.Hot_Code collate database_default not in(select HotelID from Gen_Hotels)
		
		--更新 Gen_Hotels.AreaID
		update Gen_Hotels set AreaID = (
			select top 1 AreaID 
			from Gen_Areas a 
			inner join [UAT].dbo.gen_hotel h on h.District = a.AreaName collate database_default
			where h.Hot_Code = Gen_Hotels.HotelID collate database_default
		)
		
		--更新Gen_Hotels.CountryID
		update Gen_Hotels set CountryID =(select CountryID from Gen_Cities c where c.CityID = Gen_Hotels.CityID)
		where isnull(Gen_Hotels.CountryID,'')=''
		
		--更新Gen_Hotels.OldHotelInfo
		--update Gen_Hotels set OldHotelInfo=[UAT].[dbo].[gen_hot_room].RoomName
		--				 --,RefNo_ForRoom=[UAT].[dbo].[gen_hot_room].RefNo_ForRoom, --Edit by 2010-03-12 11:10 //字段已经移除
		--				 --BedSize=[UAT].[dbo].[gen_hot_room].BedSize 
		--from Gen_Rooms inner join [UAT].[dbo].[gen_hot_room] on RoomID COLLATE SQL_Latin1_General_CP1_CI_AS=convert(nvarchar(18) ,[UAT].[dbo].[gen_hot_room].Id ) 	
		
		--插入自己的Category从gen_hot_room
		--insert into Gen_RoomCategory(CategoryID,CategoryName,CategoryCTName,OwnerHotelID)
		--select convert(nvarchar,MAX(r.Id))+'_room' as CategoryID, r.[Type],r.[Type],r.hot_code
		--from [UAT].dbo.gen_hot_room r
		--where (select COUNT(1) from Gen_RoomCategory rc 
		--		where rc.CategoryName=isnull(r.[Type],'') COLLATE database_default
		--			and (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=r.hot_code COLLATE database_default)
		--	)=0
		--group by r.[Type],r.hot_code	
		
		
		--update Gen_RoomCategory set CategoryName=C.CategoryName,CategoryCTName=C.CategoryCTName--,OwnerHotelID=C.hot_code
		--from (	select convert(nvarchar,MAX(r.Id))+'_room' as CategoryID, r.[Type] as CategoryName,r.[Type] as CategoryCTName,r.hot_code
		--		from [UAT].dbo.gen_hot_room r
		--		where (select COUNT(0) from Gen_RoomCategory rc 
		--				where rc.CategoryName=isnull(r.[Type],'') COLLATE database_default
		--					and (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=r.hot_code COLLATE database_default)
		--			)=0 
		--			and isnull(r.[Type],'')<>'' and isnull(r.RoomCategory,'')<>''
		--			and exists(select top 1 * from Gen_Hotels where HotelID=r.hot_code COLLATE database_default)
		--		group by r.[Type],r.hot_code
		--		having 	exists(select top 1 * from Gen_RoomCategory where CategoryID=convert(nvarchar,MAX(r.Id))+'_room')
		--) C
		--where Gen_RoomCategory.CategoryID=C.CategoryID
		
		insert into Gen_RoomCategory(CategoryID,CategoryName,CategoryCTName,OwnerHotelID)
		select convert(nvarchar,MAX(r.Id))+'_room' as CategoryID, r.[Type] as CategoryName,r.[Type] as CategoryCTName,r.hot_code
		from [UAT].dbo.gen_hot_room r
		where (select COUNT(0) from Gen_RoomCategory rc 
				where rc.CategoryName=isnull(r.[Type],'') COLLATE database_default
					and (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=r.hot_code COLLATE database_default)
			)=0 
			and exists(select top 1 * from Gen_Hotels where HotelID=r.hot_code COLLATE database_default)
			and isnull(r.[Type],'')<>'' and isnull(r.RoomCategory,'')<>''
		group by r.[Type],r.hot_code
		having 	not exists(select * from Gen_RoomCategory where CategoryID=convert(nvarchar,MAX(r.Id))+'_room')
		
		--更新Gen_Hotels ConditionalDescription and ChildCondition
		update Gen_Hotels  set Gen_Hotels.ConditionalDescription=UH.Condition,
			Gen_Hotels.EffectiveDate=UH.EffectiveDate,
			Gen_Hotels.ChildCondition=UH.C_ChildRemark 
		from  Gen_Hotels 
		inner join [UAT].dbo.hotinfo UH on Gen_Hotels.HotelID COLLATE SQL_Latin1_General_CP1_CI_AS=UH.HotelRefNo 
	end	
		
--Part Two
	--Gen_Services
	begin
		update Gen_Services set ServiceCTName=s.ChineseName,
			CreateBy=s.Creator,CreateDate=s.CreateDate,
			ModifyBy=s.ModifyBy,ModifyDate=s.ModifyDate
		from [UAT].dbo.gen_service s
		where Gen_Services.ServiceName =s.EnglishName collate database_default
		
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
		where gen_service.EnglishName collate database_default not in (select ServiceName from Gen_Services)
		
		--Gen_Services手动添加 FREE INTERNET   免費上網 记录 
		--insert into Gen_Services(ServiceName ,ServiceCTName ) values('FREE INTERNET',N'免費上網')	
		
		----关系表中有,,资料表中没有的数据
		--insert into Gen_Services(ServiceName ,ServiceCTName )
		--select distinct dbo.f_Get_StrArrayStrOfIndex(ServiceName,' / ',1) ,N''+dbo.f_Get_StrArrayStrOfIndex(N''+ServiceName,' / ',2) 
		--from [UAT].dbo.gen_hot_service us 
		--where not exists(select * from Gen_Services b where us.ServiceName like b.ServiceName+'%' collate database_default)	
	end
	
	--Gen_Hotel_Services
	begin
		--删除关系表和没有用的资料表
		delete from Gen_Hotel_Services
		delete from Gen_Services where not exists(select top 1 * from [UAT].dbo.gen_service s where s.EnglishName=Gen_Services.ServiceName collate database_default)
		
		insert into Gen_Hotel_Services(HotelID,ServiceID)
		select a.hot_code ,b.ServiceID--,a.ServiceName,b.ServiceName
		from [UAT].dbo.gen_hot_service a
		inner join Gen_Services b on a.ServiceName like b.ServiceName+'%' COLLATE SQL_Latin1_General_CP1_CI_AS
		where (select COUNT(0) from Gen_Hotel_Services where HotelID=a.hot_code collate database_default and ServiceID=b.ServiceID)=0
			and exists(select top 1 * from Gen_Hotels h where h.HotelID=a.hot_code collate database_default and (ExpireDate>GETDATE() or ExpireDate is null))
	end

	--Gen_Facilities
	begin
		update Gen_Facilities set FacilityCTName=s.ChineseName,
			CreateBy=s.Creator,CreateDate=s.CreateDate,
			ModifyBy=s.ModifyBy,ModifyDate=s.ModifyDate
		from [UAT].dbo.gen_facility s
		where Gen_Facilities.FacilityName =s.EnglishName collate database_default
	
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
		from [UAT].dbo.gen_facility f
		where not exists(select * from Gen_Facilities b where b.FacilityName like f.EnglishName+'%' collate database_default)
		
		----资料表中没有,关系表中有的数据
		--insert into Gen_Facilities(FacilityName,FacilityCTName)
		--select distinct dbo.f_Get_StrArrayStrOfIndex(FacilityName,' / ',1) ,dbo.f_Get_StrArrayStrOfIndex(FacilityName,' / ',2) 
		--from [UAT].dbo.gen_hot_facility uf 
		--where not exists(select * from Gen_Facilities b where uf.FacilityName like b.FacilityName+'%' collate database_default)
	end
	
	--Gen_Hotel_Facility
	begin
		delete from Gen_Hotel_Facility
		delete from Gen_Facilities where not exists(select top 1 * from [UAT].dbo.gen_facility s where s.EnglishName=Gen_Facilities.FacilityName collate database_default)
		
		insert into Gen_Hotel_Facility(HotelID,HotelFacilityID)
		Select distinct a.Hot_Code , b.FacilityID  from (
			select substring(FacilityName, 1,charindex(' /',FacilityName+' /')-1) as ll,*  
			from [UAT].dbo.gen_hot_facility
		) as a 
		inner join Gen_Facilities b on a.ll COLLATE SQL_Latin1_General_CP1_CI_AS=  b.FacilityName 
		where (select COUNT(0) from Gen_Hotel_Facility where HotelID=a.Hot_Code collate database_default and HotelFacilityID=b.FacilityID)=0
			and exists(select top 1 * from Gen_Hotels h where h.HotelID=a.hot_code collate database_default  and (ExpireDate>GETDATE() or ExpireDate is null))
	end

	--Gen_Restaurants
	begin
		update Gen_Restaurants set RestaurantCTName=s.ChineseName,
			CreateBy=s.Creator,CreateDate=s.CreateDate,
			ModifyBy=s.ModifyBy,ModifyDate=s.ModifyDate
		from [UAT].dbo.gen_restaurant s
		where Gen_Restaurants.RestaurantName =s.EnglishName collate database_default
	
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
		from [UAT].dbo.gen_restaurant r
		where (select COUNT(0) from Gen_Restaurants where RestaurantName=r.EnglishName collate database_default )=0
	end
	
	--Gen_Hotel_Restaurant
	begin
		delete from Gen_Hotel_Restaurant
		delete from Gen_Restaurants 
		where not exists(select top 1 * from [UAT].dbo.gen_restaurant s where s.EnglishName=Gen_Restaurants.RestaurantName collate database_default)
		
		insert into Gen_Hotel_Restaurant(HotelID,RestaurantID)
		select  a.Hot_code,b.RestaurantID
		from [UAT].dbo.gen_hot_restaurant a 
		inner join Gen_Restaurants b on a.Name COLLATE SQL_Latin1_General_CP1_CI_AS like b.RestaurantName +'%' 
		where (select COUNT(0) from Gen_Hotel_Restaurant where HotelID=a.Hot_code collate database_default and  RestaurantID=b.RestaurantID)=0	
			and exists(select top 1 * from Gen_Hotels h where h.HotelID=a.hot_code collate database_default  and (ExpireDate>GETDATE() or ExpireDate is null))
	end
		
	--Gen_Activities
	begin
		update Gen_Activities set ActivityCTName=s.ChineseName,
			CreateBy=s.Creator,CreateDate=s.CreateDate,
			ModifyBy=s.ModifyBy,ModifyDate=s.ModifyDate
		from [UAT].dbo.gen_activity s
		where Gen_Activities.ActivityName =s.EnglishName collate database_default
	
		insert into Gen_Activities(ActivityName,ActivityCTName,CreateBy,CreateDate,ModifyBy,ModifyDate)
		select EnglishName,ChineseName,Creator,CreateDate,ModifyBy,ModifyDate 
		from [UAT].dbo.gen_activity a
		where not exists (select * from Gen_Activities where Gen_Activities.ActivityName=a.EnglishName collate database_default)
    end
    
    --插入Gen_Hotel_Activity表
    begin
		delete from Gen_Hotel_Activity
		delete from Gen_Activities where not exists(select top 1 * from [UAT].dbo.gen_activity s where s.EnglishName=Gen_Activities.ActivityName collate database_default)
		
		insert into Gen_Hotel_Activity(HotelID,ActivityID)
		select a.hot_code ,b.ActivityID 
		from [UAT].dbo.gen_hot_activity a
		inner join Gen_Activities b on a.ActivityName like b.ActivityName+'%' COLLATE SQL_Latin1_General_CP1_CI_AS	
		where not exists(select * from Gen_Hotel_Activity where HotelID=a.hot_code collate database_default and ActivityID=b.ActivityID)
			and exists(select top 1 * from Gen_Hotels h where h.HotelID=a.hot_code collate database_default  and (ExpireDate>GETDATE() or ExpireDate is null))
	end

	--Gen_Amentities
	begin
		update Gen_Amentities set AmenityCTName=s.ChineseName,
			CreateBy=s.Creator,CreateDate=s.CreateDate,
			ModifyBy=s.ModifyBy,ModifyDate=s.ModifyDate
		from [UAT].dbo.gen_amenities s
		where Gen_Amentities.AmenityName =s.EnglishName collate database_default
		
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
		from [UAT].dbo.gen_amenities am
		where not exists(select * from Gen_Amentities a where a.AmenityName=am.EnglishName collate database_default)
	end	
	
	--Gen_Room_Amenity /*gen_hot_amentities 设备与酒店的关系??? */
	--Edit by 2010-03-12 12:00 删除FK约束
	if  EXISTS (select * from sys.foreign_keys where object_id = OBJECT_ID(N'[dbo].[FK_Gen_Room_Facility_Gen_RoomFacilities]') AND parent_object_id = OBJECT_ID(N'[dbo].[Gen_Room_Amenity]'))
		alter table Gen_Room_Amenity drop CONSTRAINT FK_Gen_Room_Facility_Gen_RoomFacilities
	if  EXISTS (select * from sys.foreign_keys where object_id = OBJECT_ID(N'[dbo].[FK_Gen_Room_Facility_Gen_Rooms]') AND parent_object_id = OBJECT_ID(N'[dbo].[Gen_Room_Amenity]'))
		alter table Gen_Room_Amenity drop CONSTRAINT FK_Gen_Room_Facility_Gen_Rooms
	begin
		delete from Gen_Hotel_Amentities
		delete from Gen_Amentities where not exists(select top 1 * from [UAT].dbo.gen_amenities s where s.EnglishName=Gen_Amentities.AmenityName collate database_default)
		
		insert into Gen_Hotel_Amentities(HotelID,HotelAmentitiesID)
		select distinct a.HotelID,b.AmenityID  
		from (
			select [Hot_code] as HotelID , substring([AmenityName],1, charindex(' /',[AmenityName]))as [AmenityName] 
			from [UAT].dbo.gen_hot_amentities
			) a,
			Gen_Amentities b
		where a.[AmenityName] COLLATE SQL_Latin1_General_CP1_CI_AS=b.AmenityName	
			and not exists(select * from Gen_Hotel_Amentities where HotelID=a.HotelID collate database_default and HotelAmentitiesID=b.AmenityID)
			and exists(select top 1 * from Gen_Hotels h where h.HotelID=a.HotelID collate database_default  and (ExpireDate>GETDATE() or ExpireDate is null))
		
		/*房间的Amenity*/
		--insert into Gen_Room_Amenity(RoomID,AmenityID)
		--select distinct a.RoomID,b.AmenityID  
		--from (
		--	select [Hot_code] as RoomID , substring([AmenityName],1, charindex(' /',[AmenityName]))as [AmenityName] 
		--	from [UAT].dbo.gen_hot_amentities
		--	) a,
		--	Gen_Amentities b
		--where a.[AmenityName] COLLATE SQL_Latin1_General_CP1_CI_AS=b.AmenityName	
		--	and not exists(select * from Gen_Room_Amenity where RoomID=a.RoomID collate database_default and AmenityID=b.AmenityID)
	end
	
    --Gen_Rooms
    begin
		--print 'Gen_Rooms     Original date:34922   Import:1815'--原数据在RoomCategory,Type 2列可能存在空值,而对应的新DB中此2列均不能为空 solution: Ignore insert late
		----select * from [UAT].dbo.gen_hot_room a where  isnull(a.RoomCategory,'')= '' or isnull(a.Type,'') = ''
		update Gen_Rooms set                          --且此2列的数据可能在[UAT].dbo.gen_roomtype,[UAT].dbo.Gen_HotelType中找不到
			HotelID=a.Hot_Code,
			--CategoryID=H.CategoryID,
			--RoomTypeID=isnull(c.RoomTypeID,'0'),
			RoomSize=a.RoomSize,
			RoomCount=isnull(a.Qty,0),
			StatusID='0',
			BedSize=a.BedSize,
			RefNo_ForRoom =a.RefNo_ForRoom
		from [UAT].dbo.gen_hot_room a
		inner join Gen_RoomCategory H on ISNULL(a.[Type],'') =H.CategoryName collate database_default
					and (isnull(H.OwnerHotelID,'')='' or H.OwnerHotelID=a.hot_code collate database_default)
		inner join gen_roomtype c on ISNULL(a.RoomCategory,'')=c.RmtName collate database_default
		where Gen_Rooms.RoomID=convert(nvarchar(18),a.Id)
		
		insert into Gen_Rooms(RoomID,                          --且此2列的数据可能在[UAT].dbo.gen_roomtype,[UAT].dbo.Gen_HotelType中找不到
			HotelID,
			CategoryID,
			RoomTypeID,
			RoomSize,
			RoomCount,
			StatusID,
			BedSize,RefNo_ForRoom
			)
		select convert(nvarchar(max),a.Id),
			a.Hot_Code, 
			H.CategoryID,
			isnull(c.RoomTypeID,'0') as  RoomTypeID,
			a.RoomSize,
			isnull(a.Qty,0),
			'0' as StatusID,
			a.BedSize,a.RefNo_ForRoom
		from [UAT].dbo.gen_hot_room a
		inner join Gen_RoomCategory H on ISNULL(a.[Type],'') =H.CategoryName collate database_default
					and (isnull(H.OwnerHotelID,'')='' or H.OwnerHotelID=a.hot_code collate database_default)
		inner join gen_roomtype c on ISNULL(a.RoomCategory,'')=c.RmtName collate database_default
		where convert(nvarchar(max),a.Id) not in (select RoomID from Gen_Rooms)
			AND EXISTS(SELECT TOP 1 * FROM Gen_Hotels where HotelID=a.Hot_Code collate database_default)
	end
	
	--Gen_Suppliers
	begin
		--Update
		update s set 
			s.SupplierName=bc.EnglishName,s.SupplierCTName=bc.ChineseName,s.Abbreviate=bc.Abbreviate,s.BCType=bc.BCType,
			s.BusinessType=bc.BusinessType,s.OnetimeBC=bc.OnetimeBC,
			 s.IATAMember=bc.IATAMember,s.AbacusCode=bc.AbacusCode,s.Tel1=bc.Tel1,s.Fax=bc.Fax,s.Email=bc.Email,
			 s.Status=bc.Status,s.CreateBy=bc.Creator, s.CreateDate=bc.CreateDate, s.ModifyBy=bc.ModifyBy, s.ModifyDate=bc.ModifyDate, 
			 s.Tel2=bc.Tel2, s.Tel3=bc.Tel3, s.Tel_Type1=bc.Tel_Type1,
			 s.Tel_Type2=bc.Tel_Type2, s.CityCode=bc.CityCode, s.Tel_Type3=bc.Tel_Type3, s.Fax_Type=bc.Fax_Type, s.ContactPerson=bc.ContactPerson, 
			 s.CountryCode=bc.CountryCode, s.Tel1_CountryIDD=bc.Tel1_CountryIDD, s.Tel2_CountryIDD=bc.Tel2_CountryIDD, s.Tel3_CountryIDD=bc.Tel3_CountryIDD,
			 s.Fax_CountryIDD=bc.Fax_CountryIDD, s.Tel1_CityIDD=bc.Tel1_CityIDD, s.Tel2_CityIDD=bc.Tel2_CityIDD, s.Tel3_CityIDD=bc.Tel3_CityIDD, 
			 s.Fax_CityIDD=bc.Fax_CityIDD, s.UserName=bc.UserName, s.IATANum=bc.IATANum, s.DebtorStatus=bc.DebtorStatus,
			 s.Auto_HotelVoucher=bc.Auto_HotelVoucher, s.Auto_TransferVoucher=bc.Auto_TransferVoucher, s.Deposit=bc.Deposit, s.Reminder_Date=bc.Reminder_Date, 
			 s.Effective_Date=bc.Effective_Date, s.Expiry_Date=bc.Expiry_Date, s.N_Block=bc.N_Block,
			 s.B_Export=bc.B_Export, s.D_ExportDate=bc.D_ExportDate, s.CityName=bc.CityName, s.BC_EffectiveDate=bc.BC_EffectiveDate, 
			 s.BC_ExpiryDate=bc.BC_ExpiryDate, s.isBlockSeat=bc.isBlockSeat, s.IO_Option=bc.IO_Option, s.ReservationWebsite=bc.ReservationWebsite
		from Gen_Suppliers s
		inner join [UAT].dbo.BC_Info bc on bc.SupplierCode=S.SupplierCode collate database_default 
		
		--insert
		insert into Gen_Suppliers(SupplierCode,SupplierName,SupplierCTName,Abbreviate,BCType,BusinessType,OnetimeBC,
			 IATAMember,AbacusCode,Tel1,Fax,Email,Status,CreateBy, CreateDate, ModifyBy, ModifyDate, Tel2, Tel3, Tel_Type1,
			 Tel_Type2, CityCode, Tel_Type3, Fax_Type, ContactPerson, CountryCode, Tel1_CountryIDD, Tel2_CountryIDD, Tel3_CountryIDD,
			 Fax_CountryIDD, Tel1_CityIDD, Tel2_CityIDD, Tel3_CityIDD, Fax_CityIDD, UserName, IATANum, DebtorStatus,
			 Auto_HotelVoucher, Auto_TransferVoucher, Deposit, Reminder_Date, Effective_Date, Expiry_Date, N_Block,
			 B_Export, D_ExportDate, CityName, BC_EffectiveDate, BC_ExpiryDate, isBlockSeat, IO_Option, ReservationWebsite
		)
		select SupplierCode, EnglishName, ChineseName, Abbreviate, BCType, BusinessType, OnetimeBC, IATAMember, AbacusCode,
			 Tel1, Fax, Email, Status, Creator, CreateDate, ModifyBy, ModifyDate, Tel2, Tel3, Tel_Type1, Tel_Type2, CityCode,
			 Tel_Type3, Fax_Type, ContactPerson, CountryCode, Tel1_CountryIDD, Tel2_CountryIDD, Tel3_CountryIDD, Fax_CountryIDD,
			 Tel1_CityIDD, Tel2_CityIDD, Tel3_CityIDD, Fax_CityIDD,  UserName, IATANum, DebtorStatus, Auto_HotelVoucher,
			 Auto_TransferVoucher, Deposit, Reminder_Date, Effective_Date, Expiry_Date, N_Block, B_Export, D_ExportDate,
			 CityName, BC_EffectiveDate, BC_ExpiryDate, isBlockSeat, IO_Option, ReservationWebsite 
		FROM [UAT].dbo.BC_Info bc
		where bc.SupplierCode collate database_default not in(select SupplierCode from Gen_Suppliers )
	end
	
	--Gen_HotelsHistroy
	begin
		INSERT INTO [Gen_HotelsHistroy]([HotelID],[HotelName],[HotelCSName],[HotelCTName],[CreateBy],[CreateDate])
		select Hot_Code,EnglishName,null,null,null,ModifyDate 
		from [UAT].dbo.gen_hot_former h
		where not exists(select * from [Gen_HotelsHistroy] where [HotelID]=h.Hot_Code collate database_default)
	end
	
	--以下不可以运行多次
	--Gen_Hotel_Commments
	--Gen_Country_Holiday
	begin
		insert into Gen_Hotel_Commments (
			[Hot_Code],
			[CreateDate],
			[roomtypes],
			[Detail], 
			[Unit],
			[UserName])
		select [Hot_Code],
			[CreateDate],
			[roomtypes],
			[Detail], 
			[Unit],
			[UserName]
		from [UAT].dbo.gen_hot_comments 
           
		insert into Gen_Country_Holiday (
			[CountryCode],
			[StartDate],
			[EndDate],
			[Public_Holiday],
			[Description])
		select [CountryCode],
			[StartDate],
			[EndDate],
			[Public_Holiday],
			[Description]
		from [UAT].dbo.gen_Country_Holiday
	end
	
    --Edit by 2010-03-12 12:30 ID是自增列
	insert into Gen_City_Holiday(--Id,
		CityCode,
		StartDate,
		EndDate,
		Public_Holiday,
		Description,
		P_CountryHoliday_ID
		)
	select --Id,
		CityCode,
		StartDate,
		EndDate,
		Public_Holiday,
		Description,
		P_CountryHoliday_ID
	from [UAT].dbo.Gen_City_Holiday
	
    --Edit by 2010-03-12 12:30 ID是自增列
	insert into Gen_City_Event(--Id,
		CityCode,
		StartDate,
		EndDate,
		Event,
		Description
		)
	select --Id,
		CityCode,
		StartDate,
		EndDate,
		Event,
		Description
	from [UAT].dbo.Gen_City_Event
End		
commit transaction