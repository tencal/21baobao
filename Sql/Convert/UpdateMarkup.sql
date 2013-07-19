/********************************************************/
use [UAT-TEHR] 
/**********************************************************/
--markup 只是房间? ,,markup null?
truncate table Gen_Markup
insert into dbo.Gen_Markup(HotelID,RoomTypeID,ItemID,Value,CCYCode,MarketID,EffectiveDate,CreateDate,CreateBy)
select AA.[RefNo],'ALL' as RoomTypeID,i.ItemID,Max(AA.MarkUp) as Value,'HKD' as CCYCode,'ALL' as MarketID,
		'2009-01-01' as EffectiveDate,GETDATE() as CreateDate,'Admin' as CreateBy 
from (
	select H.[RefNo],H.MarkUp
	from [UAT16].[UAT].[dbo].[hif_fare] H
	where not H.MarkUp is null
	group by H.RefNo,H.MarkUp
) AA,Gen_Items i
where i.IsRoom=1
group by AA.RefNo,i.ItemID having COUNT(1)=1

------------------  
--select AA.[RefNo]from 
--(
--	select H.[RefNo],H.MarkUp
--	from [UAT16].[UAT].[dbo].[hif_fare] H
--	where not H.MarkUp is null
--	group by h.RefNo,H.MarkUp
--) AA
--group by AA.RefNo having COUNT(1)>1

--最大的
insert into dbo.Gen_Markup(HotelID,RoomTypeID,CategoryID,ItemID,Value,CCYCode,MarketID,EffectiveDate,CreateDate,CreateBy)
select H.[RefNo],'ALL' as RoomTypeID,rc.CategoryID,i.ItemID,max(H.MarkUp) as Value,'HKD' as CCYCode,'ALL' as MarketID,
	'2009-01-01' as EffectiveDate,GETDATE() as CreateDate,'Admin' as CreateBy 
from [UAT16].[UAT].[dbo].[hif_fare] H
inner join dbo.Gen_RoomCategory rc on (case rc.CategoryName when '(Blank)' then '' else rc.CategoryName end)= isnull(H.Type ,'') COLLATE database_default
			and (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=H.RefNo COLLATE database_default)
inner join Gen_Items i on i.IsRoom=1
where (not H.MarkUp is null) AND H.RefNo IN (select AA.[RefNo]from 
												(
													select H.[RefNo],H.MarkUp
													from [UAT16].[UAT].[dbo].[hif_fare] H
													where not H.MarkUp is null
													group by h.RefNo,H.MarkUp
												) AA
												group by AA.RefNo having COUNT(1)>1)
group by H.RefNo,rc.CategoryID,i.ItemID

---最新startdate的markup
--insert into dbo.Gen_Markup(HotelID,RoomTypeID,CategoryID,ItemID,Value,CCYCode,MarketID,EffectiveDate,CreateDate,CreateBy)
--select BB.[RefNo],'ALL' as RoomTypeID,BB.CategoryID,i.ItemID,max(H.MarkUp) as Value,'HKD' as CCYCode,'ALL' as MarketID,
--	'2009-01-01' as EffectiveDate,GETDATE() as CreateDate,'Admin' as CreateBy 
--from [UAT16].[UAT].[dbo].[hif_fare] H 
--inner join(	
--			select H.RefNo,rc.CategoryID,MAX(H.StartDate) as StartDate
--			from [UAT16].[UAT].[dbo].[hif_fare] H
--			inner join dbo.Gen_RoomCategory rc on (case rc.CategoryName when '(Blank)' then '' else rc.CategoryName end)= isnull(H.Type ,'') COLLATE database_default
--						and (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=H.RefNo COLLATE database_default)
--			where (not H.MarkUp is null) AND H.RefNo IN (select AA.[RefNo]from 
--															(
--																select H.[RefNo],H.MarkUp
--																from [UAT16].[UAT].[dbo].[hif_fare] H
--																where not H.MarkUp is null
--																group by h.RefNo,H.MarkUp
--															) AA
--															group by AA.RefNo having COUNT(1)>1)
--			group by H.RefNo,rc.CategoryID
--	) BB on H.RefNo=BB.RefNo and H.StartDate=BB.StartDate
--inner join Gen_Items i on i.IsRoom=1
--group by BB.RefNo,BB.CategoryID,i.ItemID



/*-----------Result Check--------------------------*/
select distinct H.RefNo,rc.CategoryID,H.MarkUp
from [UAT16].[UAT].[dbo].[hif_fare] H
inner join dbo.Gen_RoomCategory rc on (case rc.CategoryName when '(Blank)' then '' else rc.CategoryName end)= isnull(H.Type ,'') COLLATE database_default
			and (isnull(rc.OwnerHotelID,'')='' or rc.OwnerHotelID=H.RefNo COLLATE database_default)
where not exists(select* from Gen_Markup m where m.HotelID=H.RefNo collate database_default and m.CategoryID=rc.CategoryID)
and H.RefNo in(select AA.[RefNo]from 
												(
													select H.[RefNo],H.MarkUp
													from [UAT16].[UAT].[dbo].[hif_fare] H
													where not H.MarkUp is null
													group by h.RefNo,H.MarkUp
												) AA
												group by AA.RefNo having COUNT(1)>1)
/*check end*/