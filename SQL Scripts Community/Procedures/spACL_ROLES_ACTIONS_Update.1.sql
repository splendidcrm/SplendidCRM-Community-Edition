if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACL_ROLES_ACTIONS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACL_ROLES_ACTIONS_Update;
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
-- 12/17/2017 Paul.  Add helpful message. 
Create Procedure dbo.spACL_ROLES_ACTIONS_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ROLE_ID           uniqueidentifier
	, @ACTION_NAME       nvarchar(25)
	, @MODULE_NAME       nvarchar(25)
	, @ACCESS_OVERRIDE   int
	)
as
  begin
	set nocount on

	declare @ACTION_ID uniqueidentifier;

	-- BEGIN Oracle Exception
		select @ACTION_ID = ID
		  from ACL_ACTIONS
		 where NAME     = @ACTION_NAME
		   and CATEGORY = @MODULE_NAME
		   and DELETED  = 0           ;
	-- END Oracle Exception
	-- 12/17/2017 Paul.  Add helpful message. 
	if @ACTION_ID is null begin -- then
		raiserror(N'spACL_ROLES_ACTIONS_Update: Could not find action "%s" for module "%s".', 16, 1, @ACTION_NAME, @MODULE_NAME);
		return;
	end -- if;
	
	-- BEGIN Oracle Exception
		select @ID = ID
		  from ACL_ROLES_ACTIONS
		 where ROLE_ID   = @ROLE_ID  
		   and ACTION_ID = @ACTION_ID
		   and DELETED   = 0         ;
	-- END Oracle Exception
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into ACL_ROLES_ACTIONS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, ROLE_ID          
			, ACTION_ID        
			, ACCESS_OVERRIDE  
			)
		values 	( @ID               
			, @MODIFIED_USER_ID       
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @ROLE_ID          
			, @ACTION_ID        
			, @ACCESS_OVERRIDE  
			);
	end else begin
		update ACL_ROLES_ACTIONS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , ACCESS_OVERRIDE   = @ACCESS_OVERRIDE  
		 where ID                = @ID               ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spACL_ROLES_ACTIONS_Update to public;
GO

