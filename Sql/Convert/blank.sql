select RoomTypeID from Gen_RoomType t where t.RmtName='(Blank)' 
select CategoryID from Gen_RoomCategory c where c.CategoryName='(Blank)' 

delete from Gen_Rooms --20425 records
where  RoomTypeID=(select RoomTypeID from Gen_RoomType t where t.RmtName='(Blank)' ) 
	and CategoryID=(select CategoryID from Gen_RoomCategory c where c.CategoryName='(Blank)')

delete from Gen_RoomItem   --78 records
where RoomID in 
(select r.RoomID from Gen_Rooms r 
	where  r.RoomTypeID=(select RoomTypeID from Gen_RoomType t where t.RmtName='(Blank)' ) 
		and r.CategoryID=(select CategoryID from Gen_RoomCategory c where c.CategoryName='(Blank)'))
		

select distinct h.HotelName from Gen_RoomItem ri 
inner join Gen_Hotels h on ri.HotelID = h.HotelID
where ri.RoomID in 
(select r.RoomID from Gen_Rooms r 
	where  r.RoomTypeID=(select RoomTypeID from Gen_RoomType t where t.RmtName='(Blank)' ) 
		and r.CategoryID=(select CategoryID from Gen_RoomCategory c where c.CategoryName='(Blank)'))