if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDASHLETS_USERS_MoveDown' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDASHLETS_USERS_MoveDown;
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
-- 01/28/2010 Paul.  The ASSIGNED_USER_ID must be used when managing dashlets. 
Create Procedure dbo.spDASHLETS_USERS_MoveDown
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ASSIGNED_USER_ID uniqueidentifier;
	declare @SWAP_ID       uniqueidentifier;
	declare @DETAIL_NAME   nvarchar(50);
	declare @DASHLET_ORDER int;

	set @ASSIGNED_USER_ID = @MODIFIED_USER_ID;
	if exists(select * from DASHLETS_USERS where ID = @ID and DELETED = 0) begin -- then
		-- BEGIN Oracle Exception
			select @DETAIL_NAME   = DETAIL_NAME
			     , @DASHLET_ORDER = DASHLET_ORDER
			  from DASHLETS_USERS
			 where ID             = @ID
			   and DELETED        = 0;
		-- END Oracle Exception
		
		-- Moving down actually means incrementing the order value. 
		-- 01/28/2010 Paul.  The ASSIGNED_USER_ID must be used when managing dashlets. 
		-- BEGIN Oracle Exception
			select @SWAP_ID = ID
			  from DASHLETS_USERS
			 where ASSIGNED_USER_ID = @ASSIGNED_USER_ID 
			   and DETAIL_NAME      = @DETAIL_NAME
			   and DASHLET_ORDER    = @DASHLET_ORDER + 1
			   and DELETED          = 0;
		-- END Oracle Exception
		if dbo.fnIsEmptyGuid(@SWAP_ID) = 0 begin -- then
			-- BEGIN Oracle Exception
				update DASHLETS_USERS
				   set DASHLET_ORDER    = DASHLET_ORDER + 1
				     , DATE_MODIFIED    = getdate()
				     , DATE_MODIFIED_UTC= getutcdate()
				     , MODIFIED_USER_ID = @MODIFIED_USER_ID
				 where ID               = @ID;
			-- END Oracle Exception
			-- BEGIN Oracle Exception
				update DASHLETS_USERS
				   set DASHLET_ORDER    = DASHLET_ORDER - 1
				     , DATE_MODIFIED    = getdate()
				     , DATE_MODIFIED_UTC= getutcdate()
				     , MODIFIED_USER_ID = @MODIFIED_USER_ID
				 where ID               = @SWAP_ID;
			-- END Oracle Exception
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spDASHLETS_USERS_MoveDown to public;
GO

