use [UnitTest-TE2010HR] 
SET XACT_ABORT ON 
begin transaction

--insert Gen_Areas中不存在的areas
	insert into Gen_Areas(AreaID,AreaName,AreaCSName,AreaCTName,CityID)
	select convert(nvarchar,max(Id))+'_hotel' as AreaID, District,District,District, c.CityID 
	from [UAT-TExpert].dbo.gen_hotel h
	inner join Gen_Cities c on c.CityCode= h.CityCode collate database_default
	where ISNULL(District,'')<>'' 
		and not exists(select * from Gen_Areas a where a.AreaName=h.District collate database_default)
	group by h.District, c.CityID 
--update Gen_hotels
	update Gen_Hotels set AreaID = (
		select top 1 AreaID 
		from Gen_Areas a 
		inner join [UAT-TExpert].dbo.gen_hotel h on h.District = a.AreaName collate database_default
		where h.Hot_Code = Gen_Hotels.HotelID collate database_default
		)

commit transaction



alter table Gen_RoomItem add EffectivDate date
alter table Gen_RoomItemHistory add EffectivDate date
alter table Gen_RoomItem add ExpiryDate date
alter table Gen_RoomItemHistory add ExpiryDate date