if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDYNAMIC_BUTTONS_ORDER_MoveUp' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDYNAMIC_BUTTONS_ORDER_MoveUp;
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
Create Procedure dbo.spDYNAMIC_BUTTONS_ORDER_MoveUp
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @SWAP_ID            uniqueidentifier;
	declare @VIEW_NAME          nvarchar(50);
	declare @CONTROL_INDEX      int;
	if exists(select * from DYNAMIC_BUTTONS where ID = @ID and DELETED = 0) begin -- then
		-- BEGIN Oracle Exception
			select @VIEW_NAME          = VIEW_NAME
			     , @CONTROL_INDEX      = CONTROL_INDEX
			  from DYNAMIC_BUTTONS
			 where ID                  = @ID
			   and DELETED             = 0;
		-- END Oracle Exception

		-- 12/13/2007 Paul.  CONTROL_INDEX 0 is reserved.  Don't allow decrease below 1. 
		if @CONTROL_INDEX is not null begin -- then
			-- BEGIN Oracle Exception
				select @SWAP_ID           = ID
				  from DYNAMIC_BUTTONS
				 where VIEW_NAME          = @VIEW_NAME
				   and CONTROL_INDEX      = @CONTROL_INDEX - 1
				   and DELETED            = 0;
			-- END Oracle Exception

			-- Moving up actually means decrementing the order value. 
			if dbo.fnIsEmptyGuid(@SWAP_ID) = 0 begin -- then
				-- BEGIN Oracle Exception
					update DYNAMIC_BUTTONS
					   set CONTROL_INDEX      = CONTROL_INDEX - 1
					     , DATE_MODIFIED      = getdate()
					     , DATE_MODIFIED_UTC= getutcdate()
					     , MODIFIED_USER_ID   = @MODIFIED_USER_ID
					 where ID                 = @ID;
				-- END Oracle Exception
				-- BEGIN Oracle Exception
					update DYNAMIC_BUTTONS
					   set CONTROL_INDEX      = CONTROL_INDEX + 1
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

Grant Execute on dbo.spDYNAMIC_BUTTONS_ORDER_MoveUp to public;
GO

