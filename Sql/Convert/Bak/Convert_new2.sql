use [TE2010-HR_Empty]
	--update Gen_Currency
	begin 
		update Gen_Currency set ccycsname=N'�Ĵ�����Ԫ',ccyctname=N'�Ĵ�����Ԫ'  where CCYCode='AUD'
		update Gen_Currency set ccycsname=N'���ô�Ԫ',ccyctname=N'���ô�Ԫ'  where CCYCode='CAD'
		update Gen_Currency set ccycsname=N'��ʿ����',ccyctname=N'��ʿ����'  where CCYCode='CHF'
		update Gen_Currency set ccycsname=N'ŷԪ',ccyctname=N'�WԪ'  where CCYCode='EUR'
		update Gen_Currency set ccycsname=N'Ӣ��',ccyctname=N'Ӣ�^'  where CCYCode='GBP'
		update Gen_Currency set ccycsname=N'�۱�',ccyctname=N'�ێ�'  where CCYCode='HKD'
		update Gen_Currency set ccycsname=N'��Ԫ',ccyctname=N'��Ԫ'  where CCYCode='JPY'
		update Gen_Currency set ccycsname=N'�������Ǳ�',ccyctname=N'�R��������'  where CCYCode='MYR'
		update Gen_Currency set ccycsname=N'��̨��',ccyctname=N'���_��'  where CCYCode='NTD'
		update Gen_Currency set ccycsname=N'������Ԫ',ccyctname=N'�����mԪ'  where CCYCode='NZD'
		update Gen_Currency set ccycsname=N'���ɱ�����',ccyctname=N'�����e����'  where CCYCode='PHP'
		update Gen_Currency set ccycsname=N'�����',ccyctname=N'�����'  where CCYCode='RMB'
		update Gen_Currency set ccycsname=N'�¼���Ԫ',ccyctname=N'�¼���Ԫ'  where CCYCode='SGD'
		update Gen_Currency set ccycsname=N'̩��',ccyctname=N'̩�'  where CCYCode='THB'
		update Gen_Currency set ccycsname=N'��̨��',ccyctname=N'���_��'  where CCYCode='TWD'
		update Gen_Currency set ccycsname=N'��Ԫ',ccyctname=N'��Ԫ'  where CCYCode='USD'
		update Gen_Currency set ccycsname=N'�Ϸ�����',ccyctname=N'�Ϸ��m��'  where CCYCode='ZAR'
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
	update [BO_GroupClasses] set ClassName='Position',ClassCSName=N'ְλ',ClassCTName=N'λ' where ClassID='1'
	insert into [BO_GroupClasses](ClassID,ClassName,ClassCSName,ClassCTName) values('0','Structure',N'����',N'�C��')
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