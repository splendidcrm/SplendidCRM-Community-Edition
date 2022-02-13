if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACL_ACTIONS_Initialize' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACL_ACTIONS_Initialize;
GO
 
/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 *********************************************************************************************************************/
-- 05/02/2005 Paul.  DB2 requires that we use nvarchar to prevent any conversions.
-- 09/26/2017 Paul.  Add Archive access right. 
Create Procedure dbo.spACL_ACTIONS_Initialize
as
  begin
	set nocount on
	
	declare @MODULE_NAME nvarchar(100);

	declare module_cursor cursor for
	select distinct MODULE_NAME
	  from vwACL_ACCESS_ByModule
	  left outer join ACL_ACTIONS
	               on ACL_ACTIONS.CATEGORY = vwACL_ACCESS_ByModule.MODULE_NAME
	 where ACL_ACTIONS.ID is null
	 order by MODULE_NAME;

	declare archive_cursor cursor for
	select MODULE_NAME
	  from vwACL_ACCESS_ByModule
	  left outer join ACL_ACTIONS
	               on ACL_ACTIONS.CATEGORY = vwACL_ACCESS_ByModule.MODULE_NAME
	              and ACL_ACTIONS.NAME     = N'archive'
	 where ACL_ACTIONS.ID is null
	 order by MODULE_NAME;

/* -- #if IBM_DB2
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
-- #endif IBM_DB2 */
/* -- #if MySQL
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
	set in_FETCH_STATUS = 0;
-- #endif MySQL */

	open module_cursor;
	fetch next from module_cursor into @MODULE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		exec dbo.spACL_ACTIONS_InsertOnly N'admin' , @MODULE_NAME, N'module',  1;
		exec dbo.spACL_ACTIONS_InsertOnly N'access', @MODULE_NAME, N'module', 89;
		exec dbo.spACL_ACTIONS_InsertOnly N'view'  , @MODULE_NAME, N'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly N'list'  , @MODULE_NAME, N'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly N'edit'  , @MODULE_NAME, N'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly N'delete', @MODULE_NAME, N'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly N'import', @MODULE_NAME, N'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly N'export', @MODULE_NAME, N'module', 90;
		-- 09/26/2017 Paul.  Add Archive access right. 
		exec dbo.spACL_ACTIONS_InsertOnly N'archive', @MODULE_NAME, N'module', 90;
		fetch next from module_cursor into @MODULE_NAME;
	end -- while;
	close module_cursor;
	deallocate module_cursor;

	-- 09/26/2017 Paul.  Add Archive access right. 
	open archive_cursor;
	fetch next from archive_cursor into @MODULE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		exec dbo.spACL_ACTIONS_InsertOnly N'archive', @MODULE_NAME, N'module', 90;
		fetch next from archive_cursor into @MODULE_NAME;
	end -- while;
	close archive_cursor;
	deallocate archive_cursor;
  end
GO
 
Grant Execute on dbo.spACL_ACTIONS_Initialize to public;
GO
 
