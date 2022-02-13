if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTERMINOLOGY_LIST_ReorderAll' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTERMINOLOGY_LIST_ReorderAll;
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
-- 08/24/2008 Paul.  The extension of this procedure is zero so that we do not have to rename any other procedures. 
-- The intent is to call this procedure any time the list order changes to ensure that there are not gaps or overlaps. 
Create Procedure dbo.spTERMINOLOGY_LIST_ReorderAll
	( @MODIFIED_USER_ID  uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ID             uniqueidentifier;
	declare @LANG           nvarchar(10);
	declare @LIST_NAME      nvarchar(50);

-- #if SQL_Server /*
	declare list_cursor cursor for
	select vwTERMINOLOGY.LANG
	     , vwTERMINOLOGY.LIST_NAME
	  from      vwTERMINOLOGY
	 inner join vwLANGUAGES
	         on vwLANGUAGES.NAME   = vwTERMINOLOGY.LANG
	        and vwLANGUAGES.ACTIVE = 1
	 where vwTERMINOLOGY.LIST_NAME is not null
	 group by vwTERMINOLOGY.LANG, vwTERMINOLOGY.LIST_NAME
	 order by vwTERMINOLOGY.LANG, vwTERMINOLOGY.LIST_NAME;
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

	open list_cursor;
	fetch next from list_cursor into @LANG, @LIST_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		--print @LANG + N'.' + @LIST_NAME;
		exec dbo.spTERMINOLOGY_LIST_Reorder @MODIFIED_USER_ID, @LANG, @LIST_NAME;
		fetch next from list_cursor into @LANG, @LIST_NAME;
/* -- #if Oracle
		IF list_cursor%NOTFOUND THEN
			StoO_sqlstatus := 2;
			StoO_fetchstatus := -1;
		ELSE
			StoO_sqlstatus := 0;
			StoO_fetchstatus := 0;
		END IF;
-- #endif Oracle */
	end -- while;
	close list_cursor;

	deallocate list_cursor;
  end
GO
 
-- exec dbo.spTERMINOLOGY_LIST_ReorderAll null;

Grant Execute on dbo.spTERMINOLOGY_LIST_ReorderAll to public;
GO
 
