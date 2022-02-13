if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_TAB_ORDER_MoveDown' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_TAB_ORDER_MoveDown;
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
-- 04/21/2009 Paul.  Correct any ordering problems before moving. 
Create Procedure dbo.spMODULES_TAB_ORDER_MoveDown
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @SWAP_ID    uniqueidentifier;
	declare @TAB_ORDER  int;
	if exists(select * from MODULES where ID = @ID and DELETED = 0) begin -- then
		-- 04/21/2009 Paul.  Correct any ordering problems before moving. 
		exec dbo.spMODULES_TAB_ORDER_Reorder @MODIFIED_USER_ID;

		-- BEGIN Oracle Exception
			select @TAB_ORDER = TAB_ORDER
			  from MODULES
			 where ID          = @ID
			   and DELETED     = 0;
		-- END Oracle Exception
		
		-- Moving down actually means incrementing the order value. 
		-- BEGIN Oracle Exception
			select @SWAP_ID   = ID
			  from MODULES
			 where TAB_ORDER = @TAB_ORDER + 1
			   and DELETED    = 0;
		-- END Oracle Exception
		if dbo.fnIsEmptyGuid(@SWAP_ID) = 0 begin -- then
			-- BEGIN Oracle Exception
				update MODULES
				   set TAB_ORDER       = TAB_ORDER + 1
				     , DATE_MODIFIED    = getdate()
				     , DATE_MODIFIED_UTC= getutcdate()
				     , MODIFIED_USER_ID = @MODIFIED_USER_ID
				 where ID               = @ID;
			-- END Oracle Exception
			-- BEGIN Oracle Exception
				update MODULES
				   set TAB_ORDER       = TAB_ORDER - 1
				     , DATE_MODIFIED    = getdate()
				     , DATE_MODIFIED_UTC= getutcdate()
				     , MODIFIED_USER_ID = @MODIFIED_USER_ID
				 where ID               = @SWAP_ID;
			-- END Oracle Exception
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spMODULES_TAB_ORDER_MoveDown to public;
GO

