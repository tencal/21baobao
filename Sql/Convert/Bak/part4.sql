use [UAT-TEHR] 
/*插入单价此段单独运行------------------------------------------------------------------------------------------------------*/
begin
	--插入酒店自己的Category, select distinct categoryName from Gen_RoomCategory
	insert into Gen_RoomCategory(CategoryID,CategoryName,CategoryCTName,OwnerHotelID)
	select convert(nvarchar,MAX(h.Id))+'_fare' as CategoryID, h.[Type],h.[Type],i.HotelRefNo
	from [UAT16].[UAT].dbo.[hif_fare] h
	inner join [UAT16].[UAT].dbo.hotinfo i on h.RefNo= i.RefNo
	where (select COUNT(1) from Gen_RoomCategory rc 
			where rc.CategoryName=isnull(h.[Type],'') COLLATE database_default
				and (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=i.HotelRefNo COLLATE database_default)
		)=0
	group by h.Type,i.HotelRefNo

	--插入房间 select * from Gen_Rooms
	insert into Gen_Rooms(RoomID,HotelID,RoomTypeID,CategoryID,StatusID)
	select convert(nvarchar,max (h.id))+'_fare' as RoomID, i.HotelRefNo,t.RoomTypeID,rc.CategoryID,'0' as StatusID--,h.Roomtype, h.[type]
	from [UAT16].[UAT].dbo.[hif_fare] h 
	inner join [UAT16].[UAT].dbo.hotinfo i on h.RefNo= i.RefNo
	inner join Gen_RoomType t on h.Roomtype = t.RmtName COLLATE database_default
	inner join Gen_RoomCategory rc on (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=i.HotelRefNo COLLATE database_default) 
			and h.[Type]= rc.CategoryName COLLATE database_default
	where (select COUNT(1) from Gen_Rooms r 
			where r.HotelID=i.HotelRefNo COLLATE database_default 
				and r.RoomTypeID=t.RoomTypeID and r.CategoryID=rc.CategoryID
			)=0
	group by i.HotelRefNo,t.RoomTypeID,rc.CategoryID--,h.Roomtype, h.Type

	--插入Market select * from Gen_markets
	insert into Gen_Markets(MarketID,MarketName,MarketCSName,MarketCTName)
	select MAX(id) as id, remark1,remark1,remark1  from [UAT16].[UAT].dbo.hif_fare 
	where remark1 like '%MARKET%' and remark1 not like '%,%' and remark1 not like '%+%'
	group by remark1
	--order by remark1
	
	--插入Price
	begin 
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
			declare @Sun bit
			declare @Mon bit
			declare @Tue bit
			declare @Wed bit
			declare @Thu bit
			declare @Fri bit
			declare @Sat bit
			declare @MarketID nvarchar(18)
			declare @Currency nvarchar(18)
			declare @MaxPax int
			declare @SupplierCode nvarchar(18)
		end
		
		declare cursorPri cursor for 
			SELECT i.HotelRefNo,r.RoomId as RMID,h.id, h.StartDate,h.EndDate,h.CastPrice,h.Extra_bed,h.Breakfast,
				(case h.Breakfast WHEN ' Y' THEN 0 when 'Y' then 0 when 'N' then 0  when 'WBF' then 0 when '16..5' then 16.5  else convert(money, h.Breakfast) end) as BreakfastPri, 
				h.Sun,h.Mon,h.Tue,h.Wed,h.Thu,h.Fri,h.Sat,m.MarketID,
				(select top 1 s.Currency from [UAT16].[UAT].dbo.hif_supplier s where s.RefNo=h.RefNo) as Currency,
				t.MaxPax,h.SupplierCode
			FROM [UAT16].[UAT].[dbo].[hif_fare] h
			inner join [UAT16].[UAT].dbo.hotinfo i on h.RefNo= i.RefNo
			inner join Gen_RoomType t on t.RmtName = h.Roomtype  collate database_default
			inner join Gen_RoomCategory rc on rc.CategoryName = h.[Type] collate database_default and (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=i.HotelRefNo collate database_default)
			inner join Gen_Rooms r on r.RoomTypeID=t.RoomTypeID collate database_default and r.CategoryID=rc.CategoryID collate database_default and r.HotelID=i.HotelRefNo collate database_default
			inner join Gen_Markets m on (case isnull(h.remark1,'') when '' then 'All Market' else h.remark1 End)=m.MarketName collate database_default
			where (remark1 like '%MARKET%' and remark1 not like '%,%' and remark1 not like '%+%') or isnull(remark1,'')=''
			--distinct 118838, not distinct 118838
		open cursorPri
		fetch next from cursorPri into @HotelRefNo,@RMID,@ID,@StartDate,@EndDate,@CastPrice,@Extra_bed,@Breakfast,@BreakfastPri,
		@Sun,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@MarketID,@Currency,@MaxPax,@SupplierCode
		while @@fetch_status=0  
			begin
				while(@StartDate<=@EndDate)
				begin
					if(DATEDIFF(d,@StartDate,getdate())>0)
					begin 
						if((@Sun=1 and DATEPART(dw,getdate())=1) or (@Mon=1 and DATEPART(dw,getdate())=2) or(@Tue=1 and DATEPART(dw,getdate())=3) 
						or (@Wed=1 and DATEPART(dw,getdate())=4) or (@Thu=1 and DATEPART(dw,getdate())=5) or (@Fri=1 and DATEPART(dw,getdate())=6) or (@Sat=1 and DATEPART(dw,getdate())=7))
						begin
							if(@Breakfast='Y')
								if(select COUNT(1) from [Gen_RoomItemHistory] where [RoomID]=@RMID and [ItemID]='1' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
									INSERT INTO [Gen_RoomItemHistory]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold,SupplierCode,EffectivDate,ExpiryDate)
									values(@RMID,'1',@MarketID,@StartDate,@CastPrice,0,@Currency,@MaxPax,0,0,0,0,0,@SupplierCode,'2009-01-01',@StartDate)
							else
								if(select COUNT(1) from [Gen_RoomItemHistory] where [RoomID]=@RMID and [ItemID]='2' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
									INSERT INTO [Gen_RoomItemHistory]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold,SupplierCode,EffectivDate,ExpiryDate)
									values(@RMID,'2',@MarketID,@StartDate,@CastPrice,0,@Currency,@MaxPax,0,0,0,0,0,@SupplierCode,'2009-01-01',@StartDate)
							if(@BreakfastPri>0)
								if(select COUNT(1) from [Gen_RoomItemHistory] where [RoomID]=@RMID and [ItemID]='4' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
									INSERT INTO [Gen_RoomItemHistory]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold,SupplierCode,EffectivDate,ExpiryDate)
									values(@RMID,'4',@MarketID,@StartDate,@BreakfastPri,0,@Currency,0,0,0,0,0,0,@SupplierCode,'2009-01-01',@StartDate)
							if(@Extra_bed>0)
								if(select COUNT(1) from [Gen_RoomItemHistory] where [RoomID]=@RMID and [ItemID]='3' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
									INSERT INTO [Gen_RoomItemHistory]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold,SupplierCode,EffectivDate,ExpiryDate)
									values(@RMID,'3',@MarketID,@StartDate,@Extra_bed,0,@Currency,1,0,0,0,0,0,@SupplierCode,'2009-01-01',@StartDate)
						end
					end
					else
					begin
						if((@Sun=1 and DATEPART(dw,getdate())=1) or (@Mon=1 and DATEPART(dw,getdate())=2) or(@Tue=1 and DATEPART(dw,getdate())=3) 
						or (@Wed=1 and DATEPART(dw,getdate())=4) or (@Thu=1 and DATEPART(dw,getdate())=5) or (@Fri=1 and DATEPART(dw,getdate())=6) or (@Sat=1 and DATEPART(dw,getdate())=7))
						begin
							if(@Breakfast='Y')
								if(select COUNT(1) from [Gen_RoomItem] where [RoomID]=@RMID and [ItemID]='1' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
									INSERT INTO [Gen_RoomItem]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold,SupplierCode,EffectivDate,ExpiryDate)
									values(@RMID,'1',@MarketID,@StartDate,@CastPrice,0,@Currency,@MaxPax,0,0,0,0,0,@SupplierCode,'2009-01-01',@StartDate)
							else
								if(select COUNT(1) from [Gen_RoomItem] where [RoomID]=@RMID and [ItemID]='2' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
									INSERT INTO [Gen_RoomItem]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold,SupplierCode,EffectivDate,ExpiryDate)
									values(@RMID,'2',@MarketID,@StartDate,@CastPrice,0,@Currency,@MaxPax,0,0,0,0,0,@SupplierCode,'2009-01-01',@StartDate)
							if(@BreakfastPri>0)
								if(select COUNT(1) from [Gen_RoomItem] where [RoomID]=@RMID and [ItemID]='4' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
									INSERT INTO [Gen_RoomItem]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold,SupplierCode,EffectivDate,ExpiryDate)
									values(@RMID,'4',@MarketID,@StartDate,@BreakfastPri,0,@Currency,0,0,0,0,0,0,@SupplierCode,'2009-01-01',@StartDate)
							if(@Extra_bed>0)
								if(select COUNT(1) from [Gen_RoomItem] where [RoomID]=@RMID and [ItemID]='3' and [MarketID]=@MarketID and [PriceDate]=@StartDate)=0
									INSERT INTO [Gen_RoomItem]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax],Allotment,Consignment,Hold,Reserved,Sold,SupplierCode,EffectivDate,ExpiryDate)
									values(@RMID,'3',@MarketID,@StartDate,@Extra_bed,0,@Currency,1,0,0,0,0,0,@SupplierCode,'2009-01-01',@StartDate)
						end
					end
						
					set @StartDate=dateadd(d,1,@StartDate)
				end
				fetch next from cursorPri into @HotelRefNo,@RMID,@ID,@StartDate,@EndDate,@CastPrice,@Extra_bed,@Breakfast,@BreakfastPri,
												@Sun,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@MarketID,@Currency,@MaxPax,@SupplierCode
			end

		close cursorPri
		deallocate cursorPri
	end
	
	--更新为空的Category
	update Gen_RoomCategory set CategoryName='(Blank)',CategoryCTName='(Blank)',CategoryCSName='(Blank)' where CategoryID='0'
	update Gen_RoomType set RmtName='(Blank)',RmtCSName='(Blank)',RmtCTName='(Blank)' where RoomTypeID='0'
end
/*------------------------------------------------------------------------------------------------------*/

select COUNT(0) from Gen_RoomItem
select COUNT(0) from Gen_RoomItemHistory
