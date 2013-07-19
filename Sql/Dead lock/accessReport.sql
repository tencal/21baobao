/* 
Author: Tencal Liao
Description: 
Test: select [dbo].[f_BO_GetFunctionRootName]('Hotel_Manage_UserAdd')
*/
Create function [dbo].[f_BO_GetFunctionRootName]
(
	@PageCode nvarchar(50)
)	returns nvarchar(100)
as 
begin
	declare @ret nvarchar(100);
	with tb as(
		select f.* from BO_Functions f where f.PageCode = @PageCode
		union all
		select ff.* from BO_Functions ff 
		inner join tb on ff.PageCode=tb.ParentID
	)
	select top 1 @ret=FunctionName from tb 
	where Status = 1 and ParentID='0';
	
	return @ret
end
/*******************************************************/

select fg.GroupID, fg.GroupName, isnull(dbo.f_BO_GetFunctionRootName(f.PageCode)+' - ','')+ f.FunctionName as FunctionName,
	g.GroupName as L_P_Name,g.L_P_Code,g.IsCatalog as IsLocation,
	(case when charindex('PageAccess,',ugfg.SubFunctions+',')>0 then 1 else 0 end) as 'PageAccess',
	(case when charindex('View,',ugfg.SubFunctions+',')>0 then 1 else 0 end) as 'View',
	(case when charindex('New,',ugfg.SubFunctions+',')>0 then 1 else 0 end) as 'New',
	(case when charindex('Edit,',ugfg.SubFunctions+',')>0 then 1 else 0 end) as 'Edit',
	(case when charindex('Delete,',ugfg.SubFunctions+',')>0 then 1 else 0 end) as 'Delete',
	(case when charindex('FrontLine,',ugfg.SubFunctions+',')>0 then 1 else 0 end) as 'FrontLine',
	(case when charindex('BackOffice,',ugfg.SubFunctions+',')>0 then 1 else 0 end) as 'BackOffice'
from BO_UserGroupHasFunGroups ugfg
inner join BO_FunctionGroups fg on fg.GroupID = ugfg.FunGroupID 
inner join BO_Groups g on g.GroupID = ugfg.UserGroupID
inner join BO_FunGroupHasFuns fghf on fghf.GroupID= ugfg.FunGroupID
inner join BO_Functions f on f.PageCode = fghf.PageCode