use [TE2010-HR_Empty]
	--update Gen_Currency
	begin 
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
	end
	
	--Update User info
	update BO_Users set BO_Users.OrgCode=e.OrgCode,BO_Users.PositionCode= e.User_PositionCode
	from [UAT].dbo.Employ_Position e
	where BO_Users.UserID =e.[User_id] collate database_default

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