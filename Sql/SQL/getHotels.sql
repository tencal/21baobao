/*
for Hotellist.aspx?city=1&area=1&in=30/06/2009&out=03/07/2009&ctyp=0&rms=1&tylst=1,
Test: exec sp_Gen_HotelList '1','1','1','1','RMB'
*/
alter procedure sp_Gen_HotelList
@cityID nvarchar(18),
@areaID nvarchar(18),
@roomtype nvarchar(18),
@marketID nvarchar(18),
@ccy varchar(10)
as
begin
/*Test*/
	--declare @cityID nvarchar(18)
	--declare @areaID nvarchar(18)
	--declare @roomtype nvarchar(18)
	--declare @marketID nvarchar(18)
	--declare @ccy varchar(10)
	
	--set @cityID='1'
	--set @areaID='0'
	--set @roomtype='1'
	--set @marketID='1'
	--set @ccy='HKD'
	
	select h.HotelName,h.HotelCSName,h.HotelCTName,
	c.CityName+'-'+ISNULL(a.AreaName,'') as Location,
	c.CityCSName+'-'+ISNULL(a.AreaCSName,'') as LocationCS,
	c.CityCTName+'-'+ISNULL(a.AreaCTName,'') as LocationCT,
	dbo.[f_Gen_HotelCheapest](h.HotelID,@roomtype,@marketID,@ccy) as Cheapest
	from Gen_Hotels h
	inner join Gen_Cities c on h.CityID=c.CityID
	left join Gen_Areas a on h.AreaID=a.AreaID
	where h.CityID=@cityID 
	and (h.AreaID=@areaID or ISNULL(@areaID,'0')='0')
end