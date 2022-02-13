if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_ARCHIVE_RULES_RunAll' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_ARCHIVE_RULES_RunAll;
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
Create Procedure dbo.spMODULES_ARCHIVE_RULES_RunAll
as
  begin
	set nocount on

	declare @ID uniqueidentifier;

-- #if SQL_Server /*
	declare ARCHIVE_RULES_CURSOR cursor for
	select ID
	  from MODULES_ARCHIVE_RULES
	 where DELETED = 0
	   and STATUS  = 1
	 order by LIST_ORDER_Y, MODULE_NAME, NAME;
-- #endif SQL_Server */

/* -- #if IBM_DB2
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
-- #endif IBM_DB2 */
/* -- #if MySQL
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
	set in_FETCH_STATUS = 0;
-- #endif MySQL */

	open ARCHIVE_RULES_CURSOR;
	fetch next from ARCHIVE_RULES_CURSOR into @ID;
	while @@FETCH_STATUS = 0 begin -- do
		exec dbo.spMODULES_ARCHIVE_RULES_Run @ID, null;
		fetch next from ARCHIVE_RULES_CURSOR into @ID;
	end -- while;
	close ARCHIVE_RULES_CURSOR;
	deallocate ARCHIVE_RULES_CURSOR;
  end
GO

Grant Execute on dbo.spMODULES_ARCHIVE_RULES_RunAll to public;
GO

