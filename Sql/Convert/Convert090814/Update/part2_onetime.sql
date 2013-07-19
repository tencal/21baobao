/*------------------------------------------------------------------------------------------------------*/
use [TEHR_Test] 
/*------------------------------------------------------------------------------------------------------*/
SET XACT_ABORT ON 
begin transaction
begin
	--update Gen_RoomItem set EffectivDate='2009-01-01',ExpiryDate=PriceDate
	--update Gen_RoomItemHistory set EffectivDate='2009-01-01',ExpiryDate=PriceDate
	
	--alter table Gen_RoomItem alter column EffectivDate date not null
	--alter table Gen_RoomItemHistory alter column  EffectivDate date not null
	--alter table Gen_RoomItem alter column ExpiryDate date not null
	--alter table Gen_RoomItemHistory alter column ExpiryDate date not null

	--ALTER TABLE Gen_RoomItem DROP CONSTRAINT [PK_Gen_RoomItem]
	--ALTER TABLE Gen_RoomItem ADD CONSTRAINT [PK_Gen_RoomItem] PRIMARY KEY
	--	([RoomID],[ItemID],[MarketID],[PriceDate],[EffectivDate],[ExpiryDate],SupplierCode)
		
	--ALTER TABLE Gen_RoomItemHistory DROP CONSTRAINT [PK_Gen_RoomItemHistory]
	--ALTER TABLE Gen_RoomItemHistory ADD CONSTRAINT [PK_Gen_RoomItemHistory] PRIMARY KEY
	--	([RoomID],[ItemID],[MarketID],[PriceDate],[EffectivDate],[ExpiryDate],SupplierCode)
	
	CREATE TABLE [dbo].[Gen_City_Event](
		[Id] [int] IDENTITY(1,1) NOT NULL,
		[CityCode] [nvarchar](3) NOT NULL,
		[StartDate] [datetime] NULL,
		[EndDate] [datetime] NULL,
		[Event] [nvarchar](200) NULL,
		[EventCS] [nvarchar](200) NULL,
		[EventCT] [nvarchar](200) NULL,
		[Description] [nvarchar](200) NULL,
		[DescriptionCS] [nvarchar](200) NULL,
		[DescriptionCT] [nvarchar](200) NULL
	) ON [PRIMARY]
	
	CREATE TABLE [dbo].[Gen_City_Holiday](
		[Id] [int] IDENTITY(2991,1) NOT NULL,
		[CityCode] [nvarchar](3) NOT NULL,
		[StartDate] [datetime] NULL,
		[EndDate] [datetime] NULL,
		[Public_Holiday] [nvarchar](200) NULL,
		[Public_HolidayCS] [nvarchar](200) NULL,
		[Public_HolidayCT] [nvarchar](200) NULL,
		[Description] [nvarchar](200) NULL,
		[DescriptionCS] [nvarchar](200) NULL,
		[DescriptionCT] [nvarchar](200) NULL,
		[P_CountryHoliday_ID] [int] NULL
	) ON [PRIMARY]
	
	--CREATE TABLE [dbo].[Gen_Hotel_Amentities](
	--	[HotelID] [nvarchar](18) NOT NULL,
	--	[HotelAmentitiesID] [int] NOT NULL,
	-- CONSTRAINT [PK_Gen_Hotel_Amentities] PRIMARY KEY CLUSTERED 
	--(
	--	[HotelID] ASC,
	--	[HotelAmentitiesID] ASC
	--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	--) ON [PRIMARY]
	
	
	CREATE TABLE [dbo].[Gen_Hotel_Commments](
		[IdKey] [int] IDENTITY(1,1) NOT NULL,
		[Hot_Code] [varchar](12) NULL,
		[CreateDate] [datetime] NULL,
		[roomtypes] [nvarchar](50) NULL,
		[Detail] [nvarchar](4000) NULL,
		[Unit] [nvarchar](4) NULL,
		[UserName] [nvarchar](30) NULL
	) ON [PRIMARY]
	
	CREATE TABLE [dbo].[Gen_Country_Holiday](
		[Id] [int] IDENTITY(1,1) NOT NULL,
		[CountryCode] [nvarchar](10) NOT NULL,
		[StartDate] [datetime] NULL,
		[EndDate] [datetime] NULL,
		[Public_Holiday] [nvarchar](200) NULL,
		[Description] [nvarchar](200) NULL
	) ON [PRIMARY]

end			
commit transaction