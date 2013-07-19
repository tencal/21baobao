/*
Description: 返回酒店列表。
Author: ruson
Date: 2009-09-24
Test: SELECT sp_Internet_GetHotels ...
*/
alter PROCEDURE sp_Internet_GetHotels
(
	@country NVARCHAR(18),		--国家ID
	@city NVARCHAR(18),			--城市ID
	@userCountryID NVARCHAR(18),--用户所在的国家ID,决定市场id
	@ccyCode VARCHAR(3),		--币种
	@checkIn Date,				--入住日期
	@nights INT,				--所住晚数
	@sort NVARCHAR(50),			--排序字段
	@isAsc BIT,					--是否为增序
	@pageIndex INT,				--页码
	@pageSize INT,				--每页大写
	@recordCount INT OUTPUT		--记录数 Out
)
AS
--SET NOCOUNT ON

--begin --测试数据
--	declare @country NVARCHAR(18) --国家ID
--	declare @city NVARCHAR(18)			--城市ID
--	declare @userCountryID NVARCHAR(18)--市场ID
--	declare @ccyCode VARCHAR(3)		--币种
--	declare @checkIn Date			--入住日期
--	declare @nights INT				--所住晚数
--	declare @sort NVARCHAR(50)		--排序字段
--	declare @isAsc BIT					--是否为增序
--	declare @pageIndex INT				--页码
--	declare @pageSize INT				--每页大写
--	declare @recordCount int

--	set @ccyCode='HKD' set @nights=2 set @checkIn='2009-10-01' set @pageIndex=2 set @pageSize=5
--	SET @city='426'
--end --测试数据 end

--数据初始化
	DECLARE @checkOut DATE --退房日期
	SET @checkOut = DATEADD(D, @nights, @checkIn)

	declare @market nvarchar(max)
	--set @market='992266'   --TODO:获取用户可以用的marketID列表

--得到满足基本条件酒店和房间
	--select h.*,r.RoomID
	--into #hotRm
	--from Gen_Hotels h
	--inner join Gen_Rooms r on h.HotelID=r.HotelID
	--where h.OpenType >= 2											--开放类型检查
	--	AND (ISNULL(@country,'') = '' OR h.CountryID =@country)		--国家检查
	--	AND (ISNULL(@city,'') = '' OR h.CityID =@city)				--城市检查)
	
--得到满足基本条件的单价列表
	select SumPrice,
		(case @nights when 0 then 0 else SumPrice/@nights end) as AvgPrice,
		(ROW_NUMBER() OVER(ORDER BY SumPrice)) AS RowNo, 
		h.*
	into #ret
	from( 
			--第三层获取每个酒店最低单价
			select HotelID,min(SumPrice) as SumPrice
			from (
				--第二层按RoomID,MarketID,SupplierCode,ItemID 取个房间最小价
				select priDay.RoomID,MarketID,SupplierCode,ItemID,r.HotelID,SUM(MinItemPrice) as SumPrice
				from(
						--第一层按RoomID,MarketID,SupplierCode,ItemID,PriceDate 取每天最小单价
						select RoomID,MarketID,SupplierCode,ItemID,PriceDate,
							MIN(dbo.f_Gen_Exchange(ItemPrice,CCYCode,@ccyCode)+dbo.f_Internet_GetMarkup(ItemID,RoomID,MarketID,@ccyCode)) as MinItemPrice
						from Gen_RoomItem ri
						where  (ri.MarketID = @market or ISNULL(@market,'')='')		--市场检查
						AND ri.EffectivDate <= @checkIn								--生效检查
						AND ri.ExpiryDate >= @checkIn								--过期检查
						AND ri.PriceDate >= @checkIn								--入住日期检查
						AND ri.PriceDate < @checkOut								--退房日期检查
						and ri.ItemTBA=0
						and ri.ItemID in (select ItemID from Gen_Items I where I.IsRoom=1)
						group by RoomID,MarketID,SupplierCode,ItemID,PriceDate
					) priDay
				inner join Gen_Rooms r on priDay.RoomID=r.RoomID
				group by priDay.RoomID,MarketID,SupplierCode,ItemID,r.HotelID
				having count(1)>=@nights
				) priHotel
			group by HotelID
		) priSum
	inner join Gen_Hotels h on priSum.HotelID = h.HotelID
	where h.OpenType >= 2											--开放类型检查
		AND (ISNULL(@country,'') = '' OR h.CountryID =@country)		--国家检查
		AND (ISNULL(@city,'') = '' OR h.CityID =@city)				--城市检查)

--返回数据			
	select #ret.*,1 as HasPromotion
	from #ret
	where #ret.RowNo between (@pageIndex-1)*@pageSize + 1 and @pageIndex * @pageSize
	
	select @recordCount=count(1) from #ret
	print @recordCount

--释放临时表
	drop table #ret
	--drop table #hotRm





/***************************************************************************************************/

----按RoomID,MarketID,SupplierCode分组,得到每天都有价的房间
--	if(@nights>1)
--		begin
--			select RoomID,MarketID,SupplierCode into #grp
--			from (select distinct RoomID,MarketID,SupplierCode,Pricedate from #priList) A
--			group by RoomID,MarketID,SupplierCode
--			having count(1)=@nights
			
--			delete from #priList 
--			where not exists(select 1 from #grp where #priList.RoomId=#grp.RoomID and #priList.MarketID=#grp.MarketID and #priList.SupplierCode=#grp.SupplierCode)
--		end

----返回结果
--	--select GrpPri.HotelID,min(case @nights when 0 then 0 else GrpPri.SumPrice/@nights end) as AvgPrice
--	select HotelID,min(GrpPri.SumPrice) as SumPrice
--	into #ret
--	from (select #priList.RoomID,#priList.MarketID,#priList.SupplierCode,#priList.HotelID,
--				SUM(dbo.f_Gen_Exchange(ItemPrice,CCYCode,@ccyCode)+dbo.f_Internet_GetMarkup(ItemID,RoomID,MarketID,@ccyCode)) as SumPrice
--			from #priList 
--			group by #priList.RoomID,#priList.MarketID,#priList.SupplierCode,#priList.HotelID
--		) GrpPri
--	group by HotelID

/******************************************************************************************************************/
