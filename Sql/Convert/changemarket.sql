  --修改Market数据
 --Add by Cheng Zhen 2009-12-18 14:30
 --Modify by Tencal Liao
begin transaction
begin
    --Delete Gen_MarketCountry Data
    delete from Gen_MarketCountry
	--A
	--Edit RoomItem
	update Gen_RoomItem set MarketID=(select MarketID from Gen_Markets where MarketName='All Market Except P.R.C')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='All Market (Except P.R.C.)' or MarketName='All Market excpet P.R.C' or MarketName='EXCEPT P.R.C ( All Market)'))
	--Edit Promotion
	update Gen_PromotionCondition set MarketID=(select MarketID from Gen_Markets where MarketName='All Market Except P.R.C')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='All Market (Except P.R.C.)' or MarketName='All Market excpet P.R.C' or MarketName='EXCEPT P.R.C ( All Market)'))
	--Delete Market
	delete Gen_Markets where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='All Market (Except P.R.C.)' or MarketName='All Market excpet P.R.C' or MarketName='EXCEPT P.R.C ( All Market)'))

	--B
	update Gen_RoomItem set MarketID=(select MarketID from Gen_Markets where MarketName='All Market Except HK Market')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='All Market Except HK' or MarketName='All Market Excpet HK Market'))
	--Edit Promotion
	update Gen_PromotionCondition set MarketID=(select MarketID from Gen_Markets where MarketName='All Market Except HK Market')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='All Market Except HK' or MarketName='All Market Excpet HK Market'))
	--Delete Market
	delete Gen_Markets where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='All Market Except HK' or MarketName='All Market Excpet HK Market'))

	--C
	update Gen_RoomItem set MarketID=(select MarketID from Gen_Markets where MarketName='Asia Market Except Japanese')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='Asian Market Except Japan' or MarketName='China Market'))
	--Edit Promotion
	update Gen_PromotionCondition set MarketID=(select MarketID from Gen_Markets where MarketName='Asia Market Except Japanese')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='Asian Market Except Japan' or MarketName='China Market'))
	--Delete Market
	delete Gen_Markets where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='Asian Market Except Japan' or MarketName='China Market'))

	--D
	update Gen_RoomItem set MarketID=(select MarketID from Gen_Markets where MarketName='China & Hong Kong Market')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='China & HK Market' or MarketName='HK & CHINA MARKET' or MarketName='HK & Chinese Market'))
	--Edit Promotion
	update Gen_PromotionCondition set MarketID=(select MarketID from Gen_Markets where MarketName='China & Hong Kong Market')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='China & HK Market' or MarketName='HK & CHINA MARKET' or MarketName='HK & Chinese Market'))
	--Delete Market
	delete Gen_Markets where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='China & HK Market' or MarketName='HK & CHINA MARKET' or MarketName='HK & Chinese Market'))

	--E
	update Gen_RoomItem set MarketID=(select MarketID from Gen_Markets where MarketName='Chinese Market')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='P.R.C MARKET' or MarketName='P.R.C MARKET ONLY'))
	--Edit Promotion
	update Gen_PromotionCondition set MarketID=(select MarketID from Gen_Markets where MarketName='Chinese Market')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='P.R.C MARKET' or MarketName='P.R.C MARKET ONLY'))
	--Delete Market
	delete Gen_Markets where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='P.R.C MARKET' or MarketName='P.R.C MARKET ONLY'))

	--F
	update Gen_RoomItem set MarketID=(select MarketID from Gen_Markets where MarketName='HK & Taiwan Market')
	where MarketID in (select MarketID from Gen_Markets where MarketName='HK & TW Market')
	--Edit Promotion
	update Gen_PromotionCondition set MarketID=(select MarketID from Gen_Markets where MarketName='HK & Taiwan Market')
	where MarketID in (select MarketID from Gen_Markets where MarketName='HK & TW Market')
	--Delete Market
	delete Gen_Markets where MarketID in (select MarketID from Gen_Markets where MarketName='HK & TW Market')

	--G
	update Gen_RoomItem set MarketID=(select MarketID from Gen_Markets where MarketName='HK & Macau Market')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='HKG & MFM MARKET' or MarketName='Hong Kong & Macau Market '))
	--Edit Promotion
	declare @count int
	set @count=(select  COUNT(1) from Gen_Markets where MarketName='HK & Macau Market')
	if(@count=1)
	begin
		update Gen_PromotionCondition set MarketID=(select isnull(MarketID,'') from Gen_Markets where MarketName='HK & Macau Market')
		where MarketID in (select MarketID from Gen_Markets where 
		(MarketName='HKG & MFM MARKET' or MarketName='Hong Kong & Macau Market '))
			--Delete Market
		delete Gen_Markets where MarketID in (select MarketID from Gen_Markets where 
	    (MarketName='HKG & MFM MARKET' or MarketName='Hong Kong & Macau Market '))
	end
		
	--H
	update Gen_RoomItem set MarketID=(select MarketID from Gen_Markets where MarketName='Indian Market')
	where MarketID in (select MarketID from Gen_Markets where MarketName='HKG & MFM MARKET')
	--Edit Promotion
	update Gen_PromotionCondition set MarketID=(select MarketID from Gen_Markets where MarketName='Indian Market')
	where MarketID in (select MarketID from Gen_Markets where MarketName='India Market')
	--Delete Market
	delete Gen_Markets where MarketID in (select MarketID from Gen_Markets where MarketName='India Market')

	--I
	update Gen_RoomItem set MarketID=(select MarketID from Gen_Markets where MarketName='Japanese Market')
	where MarketID in (select MarketID from Gen_Markets where MarketName='Japaness Market')
	--Edit Promotion
	update Gen_PromotionCondition set MarketID=(select MarketID from Gen_Markets where MarketName='Japanese Market')
	where MarketID in (select MarketID from Gen_Markets where MarketName='Japaness Market')
	--Delete Market
	delete Gen_Markets where MarketID in (select MarketID from Gen_Markets where MarketName='Japaness Market')

	--M
	update Gen_RoomItem set MarketID=(select MarketID from Gen_Markets where MarketName='All Market')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='Worldwide Market' or MarketName='Worldwide Market.'))
	--Edit Promotion
	update Gen_PromotionCondition set MarketID=(select MarketID from Gen_Markets where MarketName='All Market')
	where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='Worldwide Market' or MarketName='Worldwide Market.'))
	--Delete Market
	delete Gen_Markets where MarketID in (select MarketID from Gen_Markets where 
	(MarketName='Worldwide Market' or MarketName='Worldwide Market.'))

	--N
	update Gen_RoomItem set MarketID=(select MarketID from Gen_Markets where MarketName='All Market Except Japanese')
	where MarketID in (select MarketID from Gen_Markets where MarketName='Worldwide Market except Japane')
	--Edit Promotion
	--Delete Market
	delete Gen_Markets where MarketID in (select MarketID from Gen_Markets where MarketName='Worldwide Market except Japane')

	--Update Market Name
	--O
	update Gen_Markets set MarketName='All Market Except Japanese',MarketCSName='All Market Except Japanese',MarketCTName='All Market Except Japanese'
	where MarketID = (select MarketID from Gen_Markets where MarketName='Worldwide Market except Thai')

	--Select Price List
	--J
	select 'MIN 2 N For Worldwide Market'
	select h.HotelName from Gen_RoomItem ri
	inner join Gen_Hotels h on ri.HotelID=h.HotelID
	where MarketID=(
	select MarketID from Gen_Markets where MarketName='MIN 2 N For Worldwide Market')
	--K
	select 'PROMOTION RATE/HK Market'
	select h.HotelName from Gen_RoomItem ri
	inner join Gen_Hotels h on ri.HotelID=h.HotelID
	where MarketID=(
	select MarketID from Gen_Markets where MarketName='PROMOTION RATE/HK Market')
	--L
	select 'SUMMER PROMOTION/HK MARKET'
	select h.HotelName from Gen_RoomItem ri
	inner join Gen_Hotels h on ri.HotelID=h.HotelID
	where MarketID=(
	select MarketID from Gen_Markets where MarketName='SUMMER PROMOTION/HK MARKET')
end			
commit transaction

