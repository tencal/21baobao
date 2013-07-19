drop table #prID

--HotelID
select HotelID 
into #hotelID
from Gen_Hotels 
where CityID in 
(
	select CityID from Gen_Cities 
	where CountryID = 'TH' 
		and CityName in('Chiang Mai','Chiang Rai','Krabi','Phi Phi Island','Koh Samed','Rayong')
)

--删除
delete from  Gen_RoomItem   --420722
where HotelID in(select HotelID from  #hotelID)

--删除CityID 和 HotelID外的所有单价
select count(0) from  Gen_RoomItemHistory  --66449
where HotelID in(select HotelID from  #hotelID)

--
select pr.PromotionID 
into #prID
from Gen_PromotionPrice pr 
inner join Gen_Rooms r on pr.RoomID = r.RoomID
where r.HotelID in(select HotelID from  #hotelID)

--删除
delete from Gen_PromotionPrice --96
where PromotionID in (select PromotionID from #prID)

--删除
delete from Gen_PromotionCondition --66
where PromotionID  in (select PromotionID from #prID)

--删除
delete from Gen_Promotion --92
where PromotionID  in (select PromotionID from #prID)