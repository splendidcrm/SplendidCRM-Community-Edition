if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSHORTCUTS_ORDER_MoveItem' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSHORTCUTS_ORDER_MoveItem;
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
Create Procedure dbo.spSHORTCUTS_ORDER_MoveItem
	( @MODIFIED_USER_ID uniqueidentifier
	, @MODULE_NAME      nvarchar(50)
	, @OLD_INDEX        int
	, @NEW_INDEX        int
	)
as
  begin
	set nocount on
	
	declare @SWAP_ID    uniqueidentifier;
	-- BEGIN Oracle Exception
		select @SWAP_ID   = ID
		  from SHORTCUTS
		 where MODULE_NAME    = @MODULE_NAME
		   and SHORTCUT_ORDER = @OLD_INDEX
		   and DELETED        = 0;
	-- END Oracle Exception

	if dbo.fnIsEmptyGuid(@SWAP_ID) = 0 and (@OLD_INDEX > @NEW_INDEX or @OLD_INDEX < @NEW_INDEX) begin -- then
		if @OLD_INDEX < @NEW_INDEX begin -- then
			update SHORTCUTS
			   set SHORTCUT_ORDER    = SHORTCUT_ORDER - 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
			 where MODULE_NAME       = @MODULE_NAME
			   and SHORTCUT_ORDER   >= @OLD_INDEX
			   and SHORTCUT_ORDER   <= @NEW_INDEX
			   and DELETED           = 0;
		end else if @OLD_INDEX > @NEW_INDEX begin -- then
			update SHORTCUTS
			   set SHORTCUT_ORDER    = SHORTCUT_ORDER + 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
			 where MODULE_NAME       = @MODULE_NAME
			   and SHORTCUT_ORDER   >= @NEW_INDEX
			   and SHORTCUT_ORDER   <= @OLD_INDEX
			   and DELETED           = 0;
		end -- if;
		update SHORTCUTS
		   set SHORTCUT_ORDER    = @NEW_INDEX
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
		 where ID                = @SWAP_ID
		   and DELETED           = 0;
	end -- if;
  end
GO

Grant Execute on dbo.spSHORTCUTS_ORDER_MoveItem to public;
GO

