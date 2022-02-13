if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDASHLETS_USERS_Reorder' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDASHLETS_USERS_Reorder;
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
Create Procedure dbo.spDASHLETS_USERS_Reorder
	( @MODIFIED_USER_ID uniqueidentifier
	, @ASSIGNED_USER_ID uniqueidentifier
	, @DETAIL_NAME      nvarchar(50)
	)
as
  begin
	set nocount on
	
	declare @ID                 uniqueidentifier;
	declare @DASHLET_ENABLED    bit;
	declare @DASHLET_ORDER_OLD  int;
	declare @DASHLET_ORDER_NEW  int;

	declare module_cursor cursor for
	select ID
	     , DASHLET_ENABLED
	     , DASHLET_ORDER
	  from vwDASHLETS_USERS
	 where ASSIGNED_USER_ID = @ASSIGNED_USER_ID
	   and DETAIL_NAME      = @DETAIL_NAME
	 order by DASHLET_ORDER;

/* -- #if IBM_DB2
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
-- #endif IBM_DB2 */
/* -- #if MySQL
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
	set in_FETCH_STATUS = 0;
-- #endif MySQL */

	set @DASHLET_ORDER_NEW = 0;
	open module_cursor;
	fetch next from module_cursor into @ID, @DASHLET_ENABLED, @DASHLET_ORDER_OLD;
	while @@FETCH_STATUS = 0 begin -- do
		if @DASHLET_ENABLED = 1 begin -- then
			if @DASHLET_ORDER_OLD != @DASHLET_ORDER_NEW begin -- then
				update DASHLETS_USERS
				   set DASHLET_ORDER    = @DASHLET_ORDER_NEW
				     , MODIFIED_USER_ID = null
				     , DATE_MODIFIED    = getdate()
				     , DATE_MODIFIED_UTC= getutcdate()
				 where ID               = @ID;
			end -- if;
			set @DASHLET_ORDER_NEW = @DASHLET_ORDER_NEW + 1;
		end else begin
			if @DASHLET_ORDER_OLD != 0 begin -- then
				update DASHLETS_USERS
				   set DASHLET_ORDER    = 0
				     , MODIFIED_USER_ID = null
				     , DATE_MODIFIED    = getdate()
				     , DATE_MODIFIED_UTC= getutcdate()
				 where ID               = @ID;
			end -- if;
		end -- if;
		fetch next from module_cursor into @ID, @DASHLET_ENABLED, @DASHLET_ORDER_OLD;
	end -- while;
	close module_cursor;

	deallocate module_cursor;
  end
GO

Grant Execute on dbo.spDASHLETS_USERS_Reorder to public;
GO

