/*
Description: ���ؾƵ��б�
Author: ruson
Date: 2009-09-24
Test: SELECT sp_Internet_GetHotels ...
*/
alter PROCEDURE sp_Internet_GetHotels
(
	@country NVARCHAR(18),		--����ID
	@city NVARCHAR(18),			--����ID
	@userCountryID NVARCHAR(18),--�û����ڵĹ���ID,�����г�id
	@ccyCode VARCHAR(3),		--����
	@checkIn Date,				--��ס����
	@nights INT,				--��ס����
	@sort NVARCHAR(50),			--�����ֶ�
	@isAsc BIT,					--�Ƿ�Ϊ����
	@pageIndex INT,				--ҳ��
	@pageSize INT,				--ÿҳ��д
	@recordCount INT OUTPUT		--��¼�� Out
)
AS
--SET NOCOUNT ON

--begin --��������
--	declare @country NVARCHAR(18) --����ID
--	declare @city NVARCHAR(18)			--����ID
--	declare @userCountryID NVARCHAR(18)--�г�ID
--	declare @ccyCode VARCHAR(3)		--����
--	declare @checkIn Date			--��ס����
--	declare @nights INT				--��ס����
--	declare @sort NVARCHAR(50)		--�����ֶ�
--	declare @isAsc BIT					--�Ƿ�Ϊ����
--	declare @pageIndex INT				--ҳ��
--	declare @pageSize INT				--ÿҳ��д
--	declare @recordCount int

--	set @ccyCode='HKD' set @nights=2 set @checkIn='2009-10-01' set @pageIndex=2 set @pageSize=5
--	SET @city='426'
--end --�������� end

--���ݳ�ʼ��
	DECLARE @checkOut DATE --�˷�����
	SET @checkOut = DATEADD(D, @nights, @checkIn)

	declare @market nvarchar(max)
	--set @market='992266'   --TODO:��ȡ�û������õ�marketID�б�

--�õ�������������Ƶ�ͷ���
	--select h.*,r.RoomID
	--into #hotRm
	--from Gen_Hotels h
	--inner join Gen_Rooms r on h.HotelID=r.HotelID
	--where h.OpenType >= 2											--�������ͼ��
	--	AND (ISNULL(@country,'') = '' OR h.CountryID =@country)		--���Ҽ��
	--	AND (ISNULL(@city,'') = '' OR h.CityID =@city)				--���м��)
	
--�õ�������������ĵ����б�
	select SumPrice,
		(case @nights when 0 then 0 else SumPrice/@nights end) as AvgPrice,
		(ROW_NUMBER() OVER(ORDER BY SumPrice)) AS RowNo, 
		h.*
	into #ret
	from( 
			--�������ȡÿ���Ƶ���͵���
			select HotelID,min(SumPrice) as SumPrice
			from (
				--�ڶ��㰴RoomID,MarketID,SupplierCode,ItemID ȡ��������С��
				select priDay.RoomID,MarketID,SupplierCode,ItemID,r.HotelID,SUM(MinItemPrice) as SumPrice
				from(
						--��һ�㰴RoomID,MarketID,SupplierCode,ItemID,PriceDate ȡÿ����С����
						select RoomID,MarketID,SupplierCode,ItemID,PriceDate,
							MIN(dbo.f_Gen_Exchange(ItemPrice,CCYCode,@ccyCode)+dbo.f_Internet_GetMarkup(ItemID,RoomID,MarketID,@ccyCode)) as MinItemPrice
						from Gen_RoomItem ri
						where  (ri.MarketID = @market or ISNULL(@market,'')='')		--�г����
						AND ri.EffectivDate <= @checkIn								--��Ч���
						AND ri.ExpiryDate >= @checkIn								--���ڼ��
						AND ri.PriceDate >= @checkIn								--��ס���ڼ��
						AND ri.PriceDate < @checkOut								--�˷����ڼ��
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
	where h.OpenType >= 2											--�������ͼ��
		AND (ISNULL(@country,'') = '' OR h.CountryID =@country)		--���Ҽ��
		AND (ISNULL(@city,'') = '' OR h.CityID =@city)				--���м��)

--��������			
	select #ret.*,1 as HasPromotion
	from #ret
	where #ret.RowNo between (@pageIndex-1)*@pageSize + 1 and @pageIndex * @pageSize
	
	select @recordCount=count(1) from #ret
	print @recordCount

--�ͷ���ʱ��
	drop table #ret
	--drop table #hotRm





/***************************************************************************************************/

----��RoomID,MarketID,SupplierCode����,�õ�ÿ�춼�м۵ķ���
--	if(@nights>1)
--		begin
--			select RoomID,MarketID,SupplierCode into #grp
--			from (select distinct RoomID,MarketID,SupplierCode,Pricedate from #priList) A
--			group by RoomID,MarketID,SupplierCode
--			having count(1)=@nights
			
--			delete from #priList 
--			where not exists(select 1 from #grp where #priList.RoomId=#grp.RoomID and #priList.MarketID=#grp.MarketID and #priList.SupplierCode=#grp.SupplierCode)
--		end

----���ؽ��
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
