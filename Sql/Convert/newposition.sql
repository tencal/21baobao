--select * from BO_Groups
--select top 1 GroupID from BO_Groups where GroupName like 'Data Information Section'
--select * from BO_Positions where ID like '1061%'
--select * from BO_GroupClasses 0 org,,1 position

INSERT INTO [BO_Groups]
			([GroupID],[GroupName],[GroupCSName],[GroupCTName],[ClassID],[ParentID],
			[SortList],[GLevel],[IsCatalog],[IsBranch],[BranchCode],[L_P_Code])
select '1000' as GroupID, PositionName,PositionCSName,PositionCTName,'1',(select top 1 GroupID from BO_Groups where GroupName like 'Data Information Section'),
			'',(select top 1 GLevel+1 from BO_Groups where GroupName like 'Data Information Section'),0,0,null,ID
from BO_Positions
where ID='1061'

