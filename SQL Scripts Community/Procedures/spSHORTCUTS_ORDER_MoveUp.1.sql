if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSHORTCUTS_ORDER_MoveUp' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSHORTCUTS_ORDER_MoveUp;
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
Create Procedure dbo.spSHORTCUTS_ORDER_MoveUp
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @SWAP_ID            uniqueidentifier;
	declare @MODULE_NAME        nvarchar(50);
	declare @SHORTCUT_ORDER     int;
	if exists(select * from SHORTCUTS where ID = @ID and DELETED = 0) begin -- then
		-- BEGIN Oracle Exception
			select @MODULE_NAME        = MODULE_NAME
			     , @SHORTCUT_ORDER     = SHORTCUT_ORDER
			  from SHORTCUTS
			 where ID                  = @ID
			   and DELETED             = 0;
		-- END Oracle Exception

		-- 12/13/2007 Paul.  SHORTCUT_ORDER 0 is reserved.  Don't allow decrease below 1. 
		if @SHORTCUT_ORDER is not null begin -- then
			-- BEGIN Oracle Exception
				select @SWAP_ID           = ID
				  from SHORTCUTS
				 where MODULE_NAME        = @MODULE_NAME
				   and SHORTCUT_ORDER     = @SHORTCUT_ORDER - 1
				   and DELETED            = 0;
			-- END Oracle Exception

			-- Moving up actually means decrementing the order value. 
			if dbo.fnIsEmptyGuid(@SWAP_ID) = 0 begin -- then
				-- BEGIN Oracle Exception
					update SHORTCUTS
					   set SHORTCUT_ORDER     = SHORTCUT_ORDER - 1
					     , DATE_MODIFIED      = getdate()
					     , DATE_MODIFIED_UTC= getutcdate()
					     , MODIFIED_USER_ID   = @MODIFIED_USER_ID
					 where ID                 = @ID;
				-- END Oracle Exception
				-- BEGIN Oracle Exception
					update SHORTCUTS
					   set SHORTCUT_ORDER     = SHORTCUT_ORDER + 1
					     , DATE_MODIFIED      = getdate()
					     , DATE_MODIFIED_UTC= getutcdate()
					     , MODIFIED_USER_ID   = @MODIFIED_USER_ID
					 where ID                 = @SWAP_ID;
				-- END Oracle Exception
			end -- if;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spSHORTCUTS_ORDER_MoveUp to public;
GO

