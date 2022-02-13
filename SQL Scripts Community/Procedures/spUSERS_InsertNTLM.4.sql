if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_InsertNTLM' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_InsertNTLM;
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
-- 08/08/2006 Paul.  Set default role if defined. 
-- 11/18/2006 Paul.  If team management is enabled, create a private team for this user. 
-- 02/26/2008 Paul.  Increase USER_NAME so that an email can be used to login. 
-- 08/08/2008 Paul.  Status should not be NULL. InsertNTLM was not setting the value. 
-- The problem with Status being null is that the user is not displayed in the Users list. 
-- 08/27/2008 Paul.  PostgreSQL does not allow modifying input parameters.  Use a local temp variable. 
-- 10/19/2010 Paul.  Set global default team if defined. 
-- 08/18/2016 Paul.  Provide a way to disable NTLM new user creation. 
Create Procedure dbo.spUSERS_InsertNTLM
	( @ID                     uniqueidentifier output
	, @USER_DOMAIN            nvarchar(20)
	, @USER_NAME              nvarchar(60)
	, @IS_ADMIN               bit
	)
as
  begin
	set nocount on
	
	-- 08/08/2006 Paul.  Set default role if defined. 
	declare @DEFAULT_ROLE_ID  uniqueidentifier;
	declare @TEMP_USER_DOMAIN nvarchar(20);
	declare @TEMP_USER_NAME   nvarchar(60);
	-- 10/19/2010 Paul.  Set global default team if defined. 
	declare @GLOBAL_DEFAULT_TEAM_ID    uniqueidentifier;
	declare @DISABLE_NTLM     bit;

	set @DISABLE_NTLM = dbo.fnCONFIG_Boolean('Users.DisableNTLM');
	if @DISABLE_NTLM = 1 begin -- then
		raiserror(N'spUSERS_InsertNTLM: %s has attempted to access the system, but new user creation has been disabled.', 16, 1, @USER_NAME);
		return;
	end -- if;

	-- BEGIN Oracle Exception
		select @DEFAULT_ROLE_ID = ACL_ROLES.ID
		  from      ACL_ROLES
		 inner join CONFIG
		         on cast(CONFIG.VALUE as varchar(36)) = cast(ACL_ROLES.ID as varchar(36))
		        and lower(CONFIG.NAME)                = N'default_role'
		        and CONFIG.DELETED                    = 0
		 where ACL_ROLES.DELETED = 0
		   and datalength(CONFIG.VALUE) > 0;
	-- END Oracle Exception
	
	if dbo.fnCONFIG_Boolean(N'enable_team_management') = 1 begin -- then
		-- BEGIN Oracle Exception
			select @GLOBAL_DEFAULT_TEAM_ID = TEAMS.ID
			  from      TEAMS
			 inner join CONFIG
			         on cast(CONFIG.VALUE as varchar(36)) = cast(TEAMS.ID as varchar(36))
			        and lower(CONFIG.NAME)                = N'default_team'
			        and CONFIG.DELETED                    = 0
			 where TEAMS.DELETED = 0
			   and datalength(CONFIG.VALUE) > 0;
		-- END Oracle Exception
	end -- if;
	
	-- 11/18/2005 Paul.  User Domain is not used, but we are planning ahead. 
	set @TEMP_USER_DOMAIN = lower(@USER_DOMAIN);
	set @TEMP_USER_NAME   = lower(@USER_NAME);
	-- 12/18/2005 Paul.  Make sure not to find deleted users. 
	if not exists(select * from USERS where USER_NAME = @TEMP_USER_NAME and DELETED = 0) begin -- then
		set @ID = newid();
		-- 05/02/2016 Paul.  Default SAVE_QUERY to 1. 
		-- 05/20/2106 Paul.  Value should be 1, not 10. 
		insert into USERS
			( ID                    
			, USER_NAME             
			, LAST_NAME             
			, IS_ADMIN              
			, CREATED_BY            
			, DATE_ENTERED          
			, MODIFIED_USER_ID      
			, DATE_MODIFIED         
			, STATUS                
			, SAVE_QUERY            
			)
		values
			( @ID                    
			, @TEMP_USER_NAME        
			, @TEMP_USER_NAME        
			, @IS_ADMIN              
			, @ID                    
			,  getdate()             
			, @ID                    
			,  getdate()             
			, N'Active'              
			, 1                      
			);

		-- 04/21/2006 Paul.  Always create a custom record. 
		insert into USERS_CSTM ( ID_C ) values ( @ID );

		-- 08/12/2006 Paul.  Set default role if defined. 
		if dbo.fnIsEmptyGuid(@DEFAULT_ROLE_ID) = 0 begin -- then
			exec dbo.spACL_ROLES_USERS_Update @ID, @DEFAULT_ROLE_ID, @ID;
		end -- if;
		-- 11/18/2006 Paul.  Only use team procedures when team management has been enabled. 
		if dbo.fnCONFIG_Boolean(N'enable_team_management') = 1 begin -- then
			exec dbo.spTEAMS_InsertPrivate @ID, @ID, @TEMP_USER_NAME, @TEMP_USER_NAME;
			-- 10/19/2010 Paul.  Set global default team if defined. 
			if dbo.fnIsEmptyGuid(@GLOBAL_DEFAULT_TEAM_ID) = 0 begin -- then
				exec dbo.spTEAM_MEMBERSHIPS_Update null, @GLOBAL_DEFAULT_TEAM_ID, @ID, 1;
			end -- if;
		end -- if;
	end -- if;
  end
GO
 
Grant Execute on dbo.spUSERS_InsertNTLM to public;
GO
 
