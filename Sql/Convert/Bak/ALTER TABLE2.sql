alter table BO_Users add [OrgCode] nvarchar(18)
alter table BO_Users add [PositionCode] nvarchar(18)

CREATE TABLE [dbo].[Gen_Organizations](
	[Id] [nvarchar](4) NOT NULL,
	[UnitName] [nvarchar](40) NULL,
	[UnitCTName] [nvarchar](50) NULL,
	[UnitCSName] [nvarchar](50) NULL,
	[Contact_No1] [nvarchar](30) NULL,
	[Contact_No2] [nvarchar](30) NULL,
	[Contact_No3] [nvarchar](30) NULL,
	[Contact_NoType1] [nvarchar](10) NULL,
	[Contact_NoType2] [nvarchar](10) NULL,
	[Contact_NoType3] [nvarchar](10) NULL,
	[Fax] [nvarchar](30) NULL,
	[CreateBy] [nvarchar](30) NULL,
	[CreateDate] [datetime] NULL,
	[ModifyBy] [nvarchar](30) NULL,
	[ModifyDate] [datetime] NULL,
	[AddressEn] [nvarchar](255) NULL,
	[AddressCT] [nvarchar](255) NULL,
	[AddressCS] [nvarchar](255) NULL,
	[Gateway] [varchar](40) NULL,
	[Type] [nvarchar](30) NULL,
	[Status] [bit] NULL,
	[IsBranch] [bit] NULL,
	[Email] [nvarchar](40) NULL,
	[HandlingEmail] [nvarchar](40) NULL,
 CONSTRAINT [PK_Gen_Organizations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 99) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Gen_Positions](
	[ID] [nvarchar](4) NOT NULL,
	[PositionName] [nvarchar](40) NOT NULL,
	[PositionCTName] [nvarchar](50) NULL,
	[PositionCSName] [nvarchar](50) NULL,
	[CreateBy] [nvarchar](30) NULL,
	[CreateDate] [datetime] NULL,
	[ModifyBy] [nvarchar](30) NULL,
	[ModifyDate] [datetime] NULL,
	[Status] [nvarchar](15) NULL,
	[Remark] [nvarchar](80) NULL,
 CONSTRAINT [PK_Gen_Positions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 99) ON [PRIMARY]
) ON [PRIMARY]

GO


alter table BO_Groups add L_P_Code nvarchar(4)

ALTER TABLE Gen_Photo ALTER COLUMN PhotoName NVARCHAR(255)