/*------------------------------------------------------------------------------------------------------*/
use [TEUser_Test] 
/*------------------------------------------------------------------------------------------------------*/
SET XACT_ABORT ON 
begin transaction
begin
	--Gen_Organizations
	begin 
		update BO_Organizations set UnitName=p.L_English,
			UnitCTName=p.L_Chinese,
			Contact_No1=p.Contact_No1,
			Contact_No2=p.Contact_No2,
			Contact_No3=p.Contact_No3,
			Contact_NoType1=p.Contact_NoType1,
			Contact_NoType2=p.Contact_NoType2,
			Contact_NoType3=p.Contact_NoType3,
			Fax=p.Fax,
			CreateBy=p.Creator,
			CreateDate=p.CreateDate,
			ModifyBy=p.ModifyBy,
			ModifyDate=p.ModifyDate,
			AddressEn=p.AddressEnglish,
			AddressCT=p.AddressChinese,
			Gateway=p.Gateway,
			Type=p.Type,
			Status=p.Status,
			IsBranch=p.IsBranch,
			Email=p.Email,
			HandlingEmail=p.HandlingEmail
		from [UAT].dbo.Gen_P_Location p
		where BO_Organizations.ID=p.L_Code collate database_default 
		
		insert into BO_Organizations(Id,
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
		from [UAT].dbo.Gen_P_Location p
		where not exists(select * from BO_Organizations b where b.Id=p.L_Code collate database_default )
	end
	
    --Gen_Positions  
    begin
		update BO_Positions set
			PositionName=p.P_English,
			PositionCTName=p.P_Chinese,
			CreateBy=p.Creator,
			CreateDate=p.CreateDate,
			ModifyBy=p.Modify_By,
			ModifyDate=p.ModifyDate,
			Status=p.Status,
			Remark=p.Remark
		from [UAT].dbo.Gen_Position p
		where BO_Positions.ID=p.P_Code collate database_default 
		
		insert into BO_Positions(ID,
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
		from [UAT].dbo.Gen_Position p
		where not exists(select * from BO_Positions b where b.ID=p.P_Code collate database_default )
	end
	
	--BO_GroupClasses
	--update [BO_GroupClasses] set ClassName='Position',ClassCSName=N'职位',ClassCTName=N'職位' where ClassID='1'
	--if(not exists(select 1 from BO_GroupClasses gc where gc.ClassID='0'))
	--	insert into [BO_GroupClasses](ClassID,ClassName,ClassCSName,ClassCTName) values('0','Structure',N'机构',N'機構')
	
	--BO_Groups
	begin
		update BO_Groups set 
			GroupName=EnglishName,
			GroupCSName=ChineseName,
			ClassID=(case c.division when 'Location' then  '0' else '1' end),
			ParentID=FatherId,
			L_P_Code=c.L_P_Code,
			SortList='', --Not null
			GLevel=[Class],   --Not null
			IsCatalog=(case c.division when 'Location' then  '1' else '0' end),--Not null
			IsBranch ='0' --Not null
		from [UAT].dbo.CompanyStructure	c
		where BO_Groups.GroupID=convert(nvarchar(max),c.Id)
		
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
		from [UAT].dbo.CompanyStructure	c
		where not exists(select * from BO_Groups where BO_Groups.GroupID=convert(nvarchar(max),c.Id))
	end
		
	--BO_Users
	begin
		update [BO_Users] set [UserName]=u.EnglishName
			   ,[ChineseUserName]=u.ChineseName
			   ,[Password]=u.[Password]
			   ,[Email]=u.Email
			   ,[Gender]=u.Gender
			   ,[Birthday]=u.Birthday
			   ,[Status]=u.[Status]  --新数据库字段太短
			   ,[CreateBy]=u.Creator
			   ,[CreateDate]=u.CreateDate
			   ,[ModifyBy]=u.ModifyBy
			   ,[ModifyDate]=u.ModifyDate
			   ,[OrgCode]=ep.OrgCode
			   ,[PositionCode]=ep.User_PositionCode
			   ,InsurLicense=u.C_InsureAgencyNo,D_InsureAgency_ExpriyDate=u.D_InsureAgency_ExpriyDate
		from [UAT].dbo.gen_user u
		left join [UAT].dbo.Employ_Position ep on u.[User_id]=ep.[User_id] 
		where [BO_Users].[UserID]=u.[User_id] collate database_default 
	    
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
			   ,[PositionCode],
			   InsurLicense,D_InsureAgency_ExpriyDate
			   )
		select u.[User_id],u.EnglishName,u.ChineseName,
			u.[Password],u.Email,u.Gender, u.Birthday,u.[Status],u.Creator
			,u.CreateDate,u.ModifyBy,u.ModifyDate, ep.OrgCode,ep.User_PositionCode,u.C_InsureAgencyNo,u.D_InsureAgency_ExpriyDate
		from [UAT].dbo.gen_user u
		left join [UAT].dbo.Employ_Position ep on u.[User_id]=ep.[User_id] 
		where not exists(select * from [BO_Users] where [BO_Users].[UserID]=u.[User_id] collate database_default )
    end

	--BO_UserInGroups
	begin 
		declare @userID nvarchar(18)=''
		declare @orgCode nvarchar(18)=''
		declare @positionCode nvarchar(18)=''
		declare @groupID nvarchar(18)=''
		
		declare cursorUser cursor for 
			select u.UserID,u.OrgCode,u.PositionCode from [BO_Users] u 
			--where u.UserID in (select UserID from dbo.BO_Users where OrgCode='OLY' and Status='Active')
		
		open cursorUser
		fetch next from cursorUser into @userID,@orgCode,@positionCode
		while @@fetch_status=0  
		begin
			WITH tb(GroupID,L_P_Code,ParentID,IsCatalog)
			AS
			(
				select GroupID,L_P_Code,ParentID,IsCatalog from BO_Groups where L_P_Code=@orgCode
				union all
				SELECT A.GroupID,A.L_P_Code,A.ParentID,A.IsCatalog
				FROM BO_Groups A
				INNER JOIN tb ON A.ParentID = tb.GroupID
			) 

			select @groupID=GroupID from tb where L_P_Code=@positionCode and IsCatalog=0
			
			if(ISNULL(@groupID,'')<>'' and (select COUNT(0) from BO_UserInGroups where UserID=@userID and GroupID=@groupID)=0)
			begin
				print @userID
				print @groupID
				insert into BO_UserInGroups(UserID,GroupID) values(@userID,@groupID)
				set @groupID=''
			end
			
			fetch next from cursorUser into @userID,@orgCode,@positionCode
		end
		
		close cursorUser
		deallocate cursorUser
	end
End		
commit transaction