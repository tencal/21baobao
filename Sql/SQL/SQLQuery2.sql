USE [TExpert]
GO
/****** Object:  StoredProcedure [dbo].[sp_Gen_GetPromotion]    Script Date: 08/06/2009 14:50:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Description:获取符合条件的促销
Author:ruson
Date:2009-8-4
Test: EXEC sp_Gen_GetPromotion '2009-10-6','2009-10-11','99194917','','993903','HKD'
Date:2009-8-5,Tencal, add Week condition, and Promotion Price grouped, and selected promotion, and promotion date
*/
ALTER PROCEDURE [dbo].[sp_Gen_GetPromotion]
(
	@checkIn DATE,
	@checkOut DATE,
	@roomID NVARCHAR(60),
	@items NVARCHAR(500),
	@marketID NVARCHAR(18),
	@ccyCode VARCHAR(3)
)
AS
BEGIN
	declare @nights int
	set @nights=DATEDIFF(D,@checkIn,@checkOut)
	
	--Get all available promotion
	SELECT p.PromotionID,p.PromotionName,p.PromotionCSName,p.PromotionCTName,pr.RoomID,pr.ItemID,
		dbo.f_Gen_Exchange(pr.ItemPrice, pr.CCYCode, @ccyCode) AS ItemPrice,
		pc.[Week],pc.MinNight,pc.MaxNight,pc.PromotionShare,pc.Night, pc.FreeNight, pc.[Type],
		p.PriceStartDate,p.PriceEndDate,
		0 as Selected,0 as Qty
	into #plist
	FROM Gen_Promotion p
		INNER JOIN Gen_PromotionPrice pr ON pr.PromotionID = p.PromotionID
		Left JOIN Gen_PromotionCondition pc ON pc.PromotionID = p.PromotionID
	WHERE pr.RoomID = @roomID AND pc.MarketID = @marketID 
		AND(ISNULL(@items,'')='' or CHARINDEX(',' + pr.ItemID + ',',',' + @items + ',')>0) 
		AND DATEDIFF(D,pc.PromotionStartDate,GETDATE()) >= 0 AND DATEDIFF(D,pc.PromotionEndDate,GETDATE()) <= 0 
		AND( 
			(pc.[Type]=0 AND DATEDIFF(D, p.PriceStartDate, @checkIn) >= 0 AND DATEDIFF(D, p.PriceEndDate, @checkIn) <= 0) 
			OR
			(pc.[Type]=0 AND DATEDIFF(D, @checkIn,p.PriceStartDate) >= 0 AND DATEDIFF(D, @checkOut,p.PriceStartDate) <= 0) 
			OR
			(pc.[Type]=1 AND DATEDIFF(D, p.PriceStartDate, @checkIn) >= 0 AND DATEDIFF(D, p.PriceEndDate, @checkOut) <= 0)
		)
		and(
			isnull(pc.[Week],'')='' or(
				(pc.[Type]=0 and CHARINDEX(convert(nvarchar,datepart(dw,@checkIn))+',',pc.[Week]+',')>0)
				or
				(pc.[Type]=0 and CHARINDEX(convert(nvarchar,datepart(dw,@checkIn))+',',pc.[Week]+',')>0 and CHARINDEX(convert(nvarchar,datepart(dw,@checkOut))+',',pc.[Week]+',')>0 
					and ((len(pc.[Week])+1)/2>=@nights)
				)
			)
		)
		and ISNULL(pc.MinNight,0)<=@nights
		and ISNULL(pc.Night,0)<=@nights
		and (pc.MaxNight is null or pc.MaxNight>=@nights)
	
	--result all available promotion
	select * from #plist
		
	--promotion grouped
	select #plist.PromotionID,
		Sum(#plist.ItemPrice)*MAX(isnull(#plist.Night,1))/(MAX(isnull(#plist.Night,1))+MIN(isnull(FreeNight,0))) as PricePerNight,
		Sum(#plist.ItemPrice)*
		(case MIN(isnull(FreeNight,0))
			when 0 then Max(isnull(#plist.MinNight,1))
			else MAX(isnull(#plist.Night,1))
		end) as PackagePrice,
		MAX(#plist.[Week]) as [Week],
		(case MIN(isnull(FreeNight,0))
			when 0 then Max(isnull(#plist.MinNight,1))
			else MAX(isnull(#plist.Night,1))
		end) as MinNight,
		MIN(#plist.MaxNight) as MaxNight, #plist.PromotionShare,
		MAX(isnull(#plist.Night,1)) as MNight, MIN(isnull(FreeNight,0)) as MFreeNight,
		MAX(#plist.PriceStartDate) as PriceStartDate,Min(#plist.PriceEndDate) as PriceEndDate,
		MAX(#plist.Selected) as Selected, 0 as Qty, 1 as MaxQty,[Type],
		'' as NightIndex 
	into #proGroup
	from #plist
	group by #plist.PromotionID,PromotionShare,[Type]
	order by PricePerNight,PriceStartDate
	
	---更新#proGroup
	alter table #proGroup alter column NightIndex nvarchar(30)
	update #proGroup set MaxQty=datediff(D,
											(case when PriceStartDate<@checkIn then @checkIn else PriceStartDate end),
											(case when PriceEndDate<dateadd(D,-1,@checkOut) then PriceEndDate else dateadd(D,-1,@checkOut) end)
										)+1
	where PromotionShare=1
	update #proGroup set MaxQty=MaxNight where PromotionShare=1 and MaxNight<MaxQty
	update #proGroup set MaxQty=MaxQty/MinNight where PromotionShare=1
	
	update #proGroup set MaxQty=1 where PromotionShare=0
	
	--局部变量
	declare @ProId int
	declare @Weeks nvarchar(15)
	declare @MinNight int
	declare @FreeNight int
	declare @IsShare bit
	declare @selectedDay int
	declare @idx int
	declare @indexDays nvarchar(30)
	declare @indexDaysPro nvarchar(30)
	set @idx=0
	set @selectedDay=0
	set @indexDays=''
	set @indexDaysPro=''
	
	---get first promotion
	print 'First Promotion'
	select top 1 @ProId=PromotionID,@Weeks=isnull([Week],''),@MinNight=MinNight,@FreeNight=MFreeNight,@IsShare=PromotionShare
	from #proGroup
	
	if(ISNULL(@ProId,'')<>'')
	begin
		update #proGroup set Qty=Qty+1 where PromotionID=@ProId
		print @selectedDay print @MinNight
		set @selectedDay=@selectedDay+@MinNight+@FreeNight
		print 'First promotion selected day:'+convert(nvarchar,@selectedDay)
		if(@Weeks<>'')
		begin
			set @idx=0
			set @indexDaysPro=''
			while(@idx<@nights and @MinNight>0)
				begin
					if(CHARINDEX(convert(nvarchar,@idx)+',',@indexDays)<=0)--这天还没安排
						begin
							if(CHARINDEX(convert(nvarchar,datepart(dw,dateadd(D,@idx,@checkIn)))+',' ,@Weeks+',')>0)
								begin
									set @MinNight=@MinNight-1
									set  @indexDays=@indexDays+convert(nvarchar,@idx)+',' 
									set @indexDaysPro=@indexDaysPro+convert(nvarchar,@idx)+',' 
								end
						end
					set @idx=@idx+1
				end
			update #proGroup set NightIndex=NightIndex+@indexDaysPro where PromotionID=@ProId
		end
	end
	
	
	--Find next Promotion
	print 'Find next Promotion'
	print @IsShare print @selectedDay print @nights
	while(@IsShare =1 and @selectedDay<@nights)
	begin 
		if(select COUNT(0) from #proGroup where PromotionShare=1 and MinNight<=@nights-@selectedDay and Qty<MaxQty)>0
			begin 
				select top 1 @ProId=PromotionID,@Weeks=isnull([Week],''),@MinNight=MinNight,@FreeNight=MFreeNight
				from #proGroup 
				where PromotionShare=1 and MinNight<=@nights-@selectedDay and Qty<MaxQty
				
				print @ProId print @MinNight print @selectedDay
				if(ISNULL(@ProId,'')<>'')
				begin
					update #proGroup set Qty=Qty+1 where PromotionID=@ProId
					set @selectedDay=@selectedDay+@MinNight+@FreeNight
					
					if(@Weeks<>'')
					begin
						set @idx=0
						set @indexDaysPro=''
						while(@idx<@nights and @MinNight>0)
							begin
								if(CHARINDEX(convert(nvarchar,@idx)+',',@indexDays)<=0)--这天还没安排
									begin
										if(CHARINDEX(convert(nvarchar,datepart(dw,dateadd(D,@idx,@checkIn)))+',' ,@Weeks+',')>0)
											begin
												set @MinNight=@MinNight-1
												set  @indexDays=@indexDays+convert(nvarchar,@idx)+',' 
												set @indexDaysPro=@indexDaysPro+convert(nvarchar,@idx)+',' 
											end
									end
								set @idx=@idx+1
							end
						update #proGroup set NightIndex=NightIndex+@indexDaysPro where PromotionID=@ProId
					end
				end 
			end 
		else
			break
	end
	
	--Return 
	print @indexDays
	update #proGroup set Selected=1 where Qty>0
	select * from #proGroup
END