if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTAG_SETS_UpdateAllNames' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTAG_SETS_UpdateAllNames;
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
Create Procedure dbo.spTAG_SETS_UpdateAllNames
	( @MODIFIED_USER_ID     uniqueidentifier
	)
as
  begin
	set nocount on

	declare @TAG_ID uniqueidentifier;

	declare TAG_cursor cursor for
	select ID
	  from TAGS
	 where DELETED = 0;

/* -- #if IBM_DB2
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
-- #endif IBM_DB2 */
/* -- #if MySQL
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
	set in_FETCH_STATUS = 0;
-- #endif MySQL */

	open TAG_cursor;
	fetch next from TAG_cursor into @TAG_ID;
	while @@FETCH_STATUS = 0 and @@ERROR = 0 begin -- do
		exec dbo.spTAG_SETS_UpdateNames @MODIFIED_USER_ID, @TAG_ID;
		fetch next from TAG_cursor into @TAG_ID;
	end -- while;
	close TAG_cursor;

	deallocate TAG_cursor;
  end
GO

Grant Execute on dbo.spTAG_SETS_UpdateAllNames to public;
GO

