select *from BO_UserHasFunctions
select *from BO_UserHasFunGroups
	
select *from BO_UserGroupHasFunGroups
select *from BO_GroupHasFunctions

select * from BO_UserInGroups where UserID='60TT040E'

insert into BO_UserHasFunctions(UserID,PageCode,SubFunctions)
select UserID,PageCode,SubFunctions
from TEUser_bak20091202.dbo.BO_UserHasFunctions

insert into BO_UserHasFunGroups(UserID,FunGroupID,SubFunctions)
select UserID,FunGroupID,SubFunctions
from TEUser_bak20091202.dbo.BO_UserHasFunGroups

insert into BO_UserGroupHasFunGroups(UserGroupID,FunGroupID,SubFunctions)
select UserGroupID,FunGroupID,SubFunctions
from TEUser_bak20091202.dbo.BO_UserGroupHasFunGroups

insert into BO_GroupHasFunctions(GroupID,PageCode,SubFunctions)
select GroupID,PageCode,SubFunctions
from TEUser_bak20091202.dbo.BO_GroupHasFunctions

--for lala data
select * from BO_Users where UserID='60TT040E'
select * from BO_UserInGroups where UserID='60TT040E'

insert into BO_Users
select * from TEUser_bak20091202.dbo.BO_Users where UserID='60TT040E'

insert into BO_UserInGroups(UserID,GroupID)
select UserID,GroupID from TEUser_bak20091202.dbo.BO_UserInGroups where UserID='60TT040E'
