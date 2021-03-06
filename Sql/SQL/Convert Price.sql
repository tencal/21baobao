		--插入酒店自己的Category select distinct categoryName from Gen_RoomCategory
		--select count(1) from Gen_RoomCategory rc where isnull(rc.OwnerHotelID,'')!=''
		--delete from Gen_RoomCategory  where isnull(OwnerHotelID,'')!=''
		--delete from Gen_Rooms
		--delete from Gen_RoomItem
		insert into Gen_RoomCategory(CategoryID,CategoryName,CategoryCTName,OwnerHotelID)
		select MAX(h.id), h.Type,h.Type,i.HotelRefNo
		from UAT.dbo.[hif_fare] h
		inner join UAT.dbo.hotinfo i on h.RefNo= i.RefNo
		where (select COUNT(1) from Gen_RoomCategory rc 
				where rc.CategoryName=h.[Type] COLLATE database_default
					and (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=i.HotelRefNo COLLATE database_default)
			)=0
		group by h.Type,i.HotelRefNo


		--插入房间 select * from Gen_Rooms
		insert into Gen_Rooms(RoomID,HotelID,RoomTypeID,CategoryID)
		select convert(nvarchar(18),max (h.id))+t.RoomTypeID+rc.CategoryID as RoomID, i.HotelRefNo,t.RoomTypeID,rc.CategoryID--,h.Roomtype, h.[type]
		from uat.dbo.[hif_fare] h 
		inner join UAT.dbo.hotinfo i on h.RefNo= i.RefNo
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
		select MAX(id) as id, remark1  from uat.dbo.hif_fare 
		where remark1 like '%MARKET%' and remark1 not like '%,%' and remark1 not like '%+%'
		group by remark1
		order by remark1

		delete from Gen_RoomItem
		--插入Price
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
				(select top 1 s.Currency from uat.dbo.hif_supplier s where s.RefNo=h.RefNo) as Currency,
				t.MaxPax
			FROM [UAT].[dbo].[hif_fare] h
			inner join UAT.dbo.hotinfo i on h.RefNo= i.RefNo
			inner join Gen_RoomType t on t.RmtName = h.Roomtype  collate database_default
			inner join Gen_RoomCategory rc on rc.CategoryName = h.[Type] collate database_default and (isnull(OwnerHotelID,'')='' or rc.OwnerHotelID=i.HotelRefNo collate database_default)
			inner join Gen_Rooms r on r.RoomTypeID=t.RoomTypeID collate database_default and r.CategoryID=rc.CategoryID collate database_default and r.HotelID=i.HotelRefNo collate database_default
			inner join Gen_Markets m on (case isnull(h.remark1,'') when '' then 'All Market' else h.remark1 End)=m.MarketName collate database_default
			where (remark1 like '%MARKET%' and remark1 not like '%,%' and remark1 not like '%+%') or isnull(remark1,'')=''
			--distinct 119021, not distinct 119021
		open cursorPri
		fetch next from cursorPri into @HotelRefNo,@RMID,@ID,@StartDate,@EndDate,@CastPrice,@Extra_bed,@Breakfast,@BreakfastPri,
		@Sun,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@MarketID,@Currency,@MaxPax
		while @@fetch_status=0  
			begin
				while(@StartDate<=@EndDate)
				begin
					if(@Breakfast='Y')
						INSERT INTO [Gen_RoomItem]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax])
						values(@RMID,'1',@MarketID,@StartDate,@CastPrice,0,@Currency,@MaxPax)
					else
						INSERT INTO [Gen_RoomItem]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax])
						values(@RMID,'2',@MarketID,@StartDate,@CastPrice,0,@Currency,@MaxPax)
					if(@BreakfastPri>0)
						INSERT INTO [Gen_RoomItem]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax])
						values(@RMID,'4',@MarketID,@StartDate,@BreakfastPri,0,@Currency,0)
					if(@Extra_bed>0)
						INSERT INTO [Gen_RoomItem]([RoomID],[ItemID],[MarketID],[PriceDate],[ItemPrice],[ItemTBA],[CCYCode],[MaxPax])
						values(@RMID,'3',@MarketID,@StartDate,@Extra_bed,0,@Currency,1)
						
					set @StartDate=@StartDate+1
				end
				fetch next from cursorPri into @HotelRefNo,@RMID,@ID,@StartDate,@EndDate,@CastPrice,@Extra_bed,@Breakfast,@BreakfastPri,
												@Sun,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@MarketID,@Currency,@MaxPax
			end

		close cursorPri
		deallocate cursorPri

--select COUNT(1) from UAT.dbo.hif_fare h 164975