if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACL_ROLES_USERS_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACL_ROLES_USERS_Delete;
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
-- 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
Create Procedure dbo.spACL_ROLES_USERS_Delete
	( @MODIFIED_USER_ID uniqueidentifier
	, @ROLE_ID          uniqueidentifier
	, @USER_ID          uniqueidentifier
	)
as
  begin
	set nocount on
	
	update ACL_ROLES_USERS
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = @MODIFIED_USER_ID
	 where ROLE_ID = @ROLE_ID
	   and USER_ID = @USER_ID
	   and DELETED = 0;

	-- 05/05/2016 Paul.  Remove the primary role when unassigned. 
	if exists(select * from USERS where ID = @USER_ID and PRIMARY_ROLE_ID = @ROLE_ID and DELETED = 0) begin -- then
		update USERS
		   set PRIMARY_ROLE_ID   = null
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
		 where ID                = @USER_ID
		   and DELETED           = 0;
	end -- if;
  end
GO
 
Grant Execute on dbo.spACL_ROLES_USERS_Delete to public;
GO
 
