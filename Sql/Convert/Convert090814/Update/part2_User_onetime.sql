/*------------------------------------------------------------------------------------------------------*/
use [TEUser_Test] 
/*------------------------------------------------------------------------------------------------------*/
SET XACT_ABORT ON 
begin transaction
begin
	alter table [BO_Users] add D_InsureAgency_ExpriyDate datetime
end			
commit transaction