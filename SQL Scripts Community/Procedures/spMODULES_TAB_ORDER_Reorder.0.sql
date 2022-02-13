if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_TAB_ORDER_Reorder' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_TAB_ORDER_Reorder;
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
-- 04/21/2009 Paul.  The extension of this procedure is zero so that we do not have to rename any other procedures. 
-- The intent is to call this procedure any time the list order changes to ensure that there are not gaps or overlaps. 
Create Procedure dbo.spMODULES_TAB_ORDER_Reorder
	( @MODIFIED_USER_ID  uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ID            uniqueidentifier;
	declare @NAME          nvarchar(25);
	declare @TAB_ORDER_OLD int;
	declare @TAB_ORDER_NEW int;

	declare module_cursor cursor for
	select ID
	     , MODULE_NAME
	     , TAB_ORDER
	  from MODULES
	 where (MODULE_ENABLED = 1 and (TAB_ENABLED = 1 or MOBILE_ENABLED = 1))
	   and DELETED = 0
	 order by TAB_ENABLED desc, TAB_ORDER, MOBILE_ENABLED desc, MODULE_NAME;

/* -- #if IBM_DB2
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
-- #endif IBM_DB2 */
/* -- #if MySQL
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
	set in_FETCH_STATUS = 0;
-- #endif MySQL */

	-- 04/21/2009 Paul.  First make sure to clear the tab order for disabled or hidden tabs. 
	update MODULES
	   set TAB_ORDER = 0
	 where (MODULE_ENABLED = 0 or (TAB_ENABLED = 0 and MOBILE_ENABLED = 0))
	   and DELETED = 0;

	set @TAB_ORDER_NEW = 1;
	open module_cursor;
	fetch next from module_cursor into @ID, @NAME, @TAB_ORDER_OLD;
	while @@FETCH_STATUS = 0 begin -- do
		if @TAB_ORDER_OLD != @TAB_ORDER_NEW begin -- then
			print N'Correcting list order of ' + @NAME + N' (' + cast(@TAB_ORDER_NEW as varchar(10)) + N')';
			update MODULES
			   set TAB_ORDER        = @TAB_ORDER_NEW
			     , MODIFIED_USER_ID = null
			     , DATE_MODIFIED    = getdate()
			     , DATE_MODIFIED_UTC= getutcdate()
			 where ID               = @ID;
		end -- if;
		set @TAB_ORDER_NEW = @TAB_ORDER_NEW + 1;
		fetch next from module_cursor into @ID, @NAME, @TAB_ORDER_OLD;
	end -- while;
	close module_cursor;

	deallocate module_cursor;
  end
GO
 
--exec dbo.spMODULES_TAB_ORDER_Reorder null;

Grant Execute on dbo.spMODULES_TAB_ORDER_Reorder to public;
GO
 
