/*
exec sp_Gen_getPriceList '1','2009-06-10','2009-06-12','1,2','1',0,0
*/
--alter proc sp_Gen_getPriceList
declare @HotelID nvarchar(18)
declare @checkin date
declare @checkout date
declare @roomtypelist nvarchar(40)
declare @marketID nvarchar(18)
declare @confirmType int --还没用
declare @noRm int        --还没用

/*Test*/
set @HotelID='1'
set @checkin='2009-06-10'
set @checkout='2009-06-12'
set @roomtypelist='1,2'
set @marketID='1'

/*get all rooms by Hotel ID */ 
	select rm.RoomID,
	rmc.CategoryID,rmc.CategoryName,rmc.CategoryCSName,rmc.CategoryCTName,
	rmt.RoomTypeID,rmt.RmtName,rmt.RmtCSName,rmt.RmtCTName
	into #rms
	from Gen_Rooms rm
	inner join Gen_RoomCategory rmc on rm.CategoryID=rmc.CategoryID
	inner join Gen_RoomType rmt on rm.RoomTypeID =rmt.RoomTypeID
	where (HotelID=@HotelID) and
	(isnull(@roomtypelist,'')='' or CHARINDEX(','+rmt.RoomTypeID+',',','+@roomtypelist+',')>0)

/* get all quotations */
	select q.QutationID,q.RoomID as RID,q.StartDate,q.EndDate,q.MarketID,q.CCYCode,
	qi.Price,
	ei.ItemID,ei.ItemlName
	into #qall
	from Gen_Quotations q
	inner join Gen_QuotationItem qi on q.QutationID=qi.QuotationID
	inner join Gen_ExtraItems ei on qi.ItemID=ei.ItemID
	where not(q.StartDate> @checkout or q.EndDate<@checkin) and q.MarketID=@marketID



create table #Tdates
(
	DateT date null
)

declare @check date
declare @sql nvarchar(400)
set @check =@checkin
while(@check<@checkout)
	begin
		insert into #Tdates values(@check)
		set @check = DATEADD("day", 1, @check)
	end

/*Result */
select * 
from 
(
	select * from #rms,#Tdates
) rmDates
left join
(
	select qtall.*,dates.DateT as DateT2
	from #qall qtall,#Tdates dates
	where qtall.StartDate<= dates.DateT and dates.DateT<=qtall.EndDate
) qdate
on rmDates.RoomID = qdate.RID and rmDates.DateT=qdate.DateT2

/**/
select qtall.*,dates.DateT as DateT2 into #plist
from #qall qtall,#Tdates dates
where qtall.StartDate<= dates.DateT and dates.DateT<=qtall.EndDate

select * from #plist

select QutationID,RID,MarketID,CCYCode,ItemID ,
	[2009-06-10] as "2009-06-10", 
	[2009-06-11] as "2009-06-11"
from #plist
pivot 
( 
	max(Price) 
	for DateT2 in 
	([2009-06-10],[2009-06-11]) 
) 
as pvt 

/* clare all temp table*/

select * from #qall
select * from #rms
select * from #Tdates

drop table #qall
drop table #rms
drop table #Tdates
drop table #plist

----------------------
/*
declare @check date
declare @sql nvarchar(400)
set @check ='2009-06-10'
while(@check<='2009-06-11')
	begin
		set @sql='alter table Table_1 add ['+CONVERT(nvarchar,@check)+'] date null'
		EXECUTE  sp_executesql @sql
		set @sql ='update Table_1 set ['+CONVERT(nvarchar,@check)+']='''+CONVERT(nvarchar,@check)+''''
		EXECUTE  sp_executesql @sql
		set @check = DATEADD("day", 1, @check)
	end

select qtall.*,
(
select max(Price) 
from #qall qtall2, Table_1 tt
where qtall.StartDate<= tt.[2009-06-10] and tt.[2009-06-10]<=qtall.EndDate
and qtall2.RID=qtall.RID and qtall2.QutationID=qtall.QutationID and qtall2.ItemID=qtall.ItemID
)  as [2009-06-10] 
from #qall qtall


select * from #qall qtall
where qtall.StartDate<= tt.[2009-06-10] and tt.[2009-06-10]<=qtall.EndDate

select * from #qall
select * from #rms
select * from #Tdates

drop table #qall
drop table #rms
drop table #Tdates
*/