if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACL_ROLES_USERS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACL_ROLES_USERS_Update;
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
-- 11/13/2009 Paul.  Remove the unnecessary update as it will reduce offline client conflicts. 
-- 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
-- 03/22/2017 Paul.  Update the custom field table so that the audit view will have matching custom field values. 
Create Procedure dbo.spACL_ROLES_USERS_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @ROLE_ID           uniqueidentifier
	, @USER_ID           uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- 04/26/2006 Paul.  @ACCESS_OVERRIDE is not used yet. 
	-- BEGIN Oracle Exception
		select @ID = ID
		  from ACL_ROLES_USERS
		 where ROLE_ID           = @ROLE_ID
		   and USER_ID           = @USER_ID
		   and DELETED           = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into ACL_ROLES_USERS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, ROLE_ID          
			, USER_ID          
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @ROLE_ID          
			, @USER_ID          
			);

		-- 05/05/2016 Paul.  Add the primary role if unassigned. 
		if exists(select * from USERS where ID = @USER_ID and PRIMARY_ROLE_ID is null and DELETED = 0) begin -- then
			-- BEGIN Oracle Exception
				update USERS
				   set PRIMARY_ROLE_ID   = @ROLE_ID
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
				 where ID                = @USER_ID
				   and DELETED           = 0;
			-- END Oracle Exception
			-- 03/22/2017 Paul.  Update the custom field table so that the audit view will have matching custom field values. 
			-- BEGIN Oracle Exception
				update USERS_CSTM
				   set ID_C              = ID_C
				 where ID_C              = @USER_ID;
			-- END Oracle Exception
		end -- if;
	end -- if;
  end
GO
 
Grant Execute on dbo.spACL_ROLES_USERS_Update to public;
GO
 
