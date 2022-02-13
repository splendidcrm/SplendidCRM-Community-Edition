if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_Update;
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
-- 04/21/2006 Paul.  IS_GROUP was added in SugarCRM 4.0.
-- 08/08/2006 Paul.  Set default role if defined. 
-- 11/18/2006 Paul.  If team management is enabled, create a private team for this user. 
-- 11/18/2006 Paul.  Also watch for changes to REPORTS_TO_ID so that teams can be refreshed. 
-- 02/26/2008 Paul.  Increase USER_NAME so that an email can be used to login. 
-- 08/27/2008 Paul.  PostgreSQL does not allow modifying input parameters.  Use a local temp variable. 
-- 09/28/2008 Paul.  Block insert or update if number of users exceeds the max. 
-- 05/06/2009 Paul.  Add DEFAULT_TEAM to support SugarCRM migration. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 11/26/2009 Paul.  We need to make sure that the default team is added to the membership table. 
-- 03/16/2010 Paul.  Add IS_ADMIN_DELEGATE. 
-- 07/09/2010 Paul.  Move the SMTP values from USER_PREFERENCES to the main table to make it easier to access. 
-- 07/09/2010 Paul.  SMTP values belong in the OUTBOUND_EMAILS table. 
-- 10/19/2010 Paul.  Set global default team if defined. 
-- 03/04/2011 Paul.  We need to allow the admin to set the flag to force a password change. 
-- 03/25/2011 Paul.  Add support for Google Apps. 
-- 03/25/2011 Paul.  Create a separate field for the Facebook ID. 
-- 12/13/2011 Paul.  Add support for Apple iCloud. 
-- 12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
-- 09/20/2013 Paul.  Move EXTENSION to the main table. 
-- 09/27/2013 Paul.  SMS messages need to be opt-in. 
-- 11/21/2014 Paul.  Add User Picture. 
-- 04/20/2016 Paul.  Provide a way to allow each user to have their own SMTP server. 
-- 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
-- 11/24/2017 Paul.  Provide a way to format phone numbers.  
-- 03/09/2020 Paul.  Increase @MAIL_SMTPPASS to 100. 
Create Procedure dbo.spUSERS_Update
	( @ID                     uniqueidentifier output
	, @MODIFIED_USER_ID       uniqueidentifier
	, @USER_NAME              nvarchar(60)
	, @FIRST_NAME             nvarchar(30)
	, @LAST_NAME              nvarchar(30)
	, @REPORTS_TO_ID          uniqueidentifier
	, @IS_ADMIN               bit
	, @RECEIVE_NOTIFICATIONS  bit
	, @DESCRIPTION            nvarchar(max)
	, @TITLE                  nvarchar(50)
	, @DEPARTMENT             nvarchar(50)
	, @PHONE_HOME             nvarchar(50)
	, @PHONE_MOBILE           nvarchar(50)
	, @PHONE_WORK             nvarchar(50)
	, @PHONE_OTHER            nvarchar(50)
	, @PHONE_FAX              nvarchar(50)
	, @EMAIL1                 nvarchar(100)
	, @EMAIL2                 nvarchar(100)
	, @STATUS                 nvarchar(25)
	, @ADDRESS_STREET         nvarchar(150)
	, @ADDRESS_CITY           nvarchar(100)
	, @ADDRESS_STATE          nvarchar(100)
	, @ADDRESS_POSTALCODE     nvarchar(9)
	, @ADDRESS_COUNTRY        nvarchar(25)
	, @USER_PREFERENCES       nvarchar(max)
	, @PORTAL_ONLY            bit
	, @EMPLOYEE_STATUS        nvarchar(25)
	, @MESSENGER_ID           nvarchar(25)
	, @MESSENGER_TYPE         nvarchar(25)
	, @PARENT_TYPE            nvarchar(25)
	, @PARENT_ID              uniqueidentifier
	, @IS_GROUP               bit
	, @DEFAULT_TEAM           uniqueidentifier = null
	, @IS_ADMIN_DELEGATE      bit = null
	, @MAIL_SMTPUSER          nvarchar(60) = null
	, @MAIL_SMTPPASS          nvarchar(100) = null
	, @SYSTEM_GENERATED_PASSWORD bit = null
	, @GOOGLEAPPS_SYNC_CONTACTS  bit = null
	, @GOOGLEAPPS_SYNC_CALENDAR  bit = null
	, @GOOGLEAPPS_USERNAME       nvarchar(100) = null
	, @GOOGLEAPPS_PASSWORD       nvarchar(100) = null
	, @FACEBOOK_ID               nvarchar(25) = null
	, @ICLOUD_SYNC_CONTACTS      bit = null
	, @ICLOUD_SYNC_CALENDAR      bit = null
	, @ICLOUD_USERNAME           nvarchar(100) = null
	, @ICLOUD_PASSWORD           nvarchar(100) = null
	, @THEME                     nvarchar(25) = null
	, @DATE_FORMAT               nvarchar(25) = null
	, @TIME_FORMAT               nvarchar(25) = null
	, @LANG                      nvarchar(10) = null
	, @CURRENCY_ID               uniqueidentifier = null
	, @TIMEZONE_ID               uniqueidentifier = null
	, @SAVE_QUERY                bit = null
	, @GROUP_TABS                bit = null
	, @SUBPANEL_TABS             bit = null
	, @EXTENSION                 nvarchar(25) = null
	, @SMS_OPT_IN                nvarchar(25) = null
	, @PICTURE                   nvarchar(max) = null
	, @MAIL_SMTPSERVER           nvarchar(100) = null
	, @MAIL_SMTPPORT             int = null
	, @MAIL_SMTPAUTH_REQ         bit = null
	, @MAIL_SMTPSSL              int = null
	, @MAIL_SENDTYPE             nvarchar(25) = null
	)
as
  begin
	set nocount on

	declare @FULL_NAME          nvarchar(128);
	declare @LAST_REPORTS_TO_ID uniqueidentifier;
	declare @TEMP_USER_NAME     nvarchar(60);
	declare @TEMP_REPORTS_TO_ID uniqueidentifier;
	-- 08/08/2006 Paul.  Set default role if defined. 
	declare @DEFAULT_ROLE_ID    uniqueidentifier;
	declare @MaxUsers           int;
	declare @ActiveUsers        int;
	-- 10/19/2010 Paul.  Set global default team if defined. 
	declare @GLOBAL_DEFAULT_TEAM_ID    uniqueidentifier;
	-- 11/24/2017 Paul.  Provide a way to format phone numbers.  
	declare @TEMP_PHONE_HOME    nvarchar(50);
	declare @TEMP_PHONE_MOBILE  nvarchar(50);
	declare @TEMP_PHONE_WORK    nvarchar(50);
	declare @TEMP_PHONE_OTHER   nvarchar(50);
	declare @TEMP_PHONE_FAX     nvarchar(50);
	declare @OLD_USER_NAME      nvarchar(60);
	set @TEMP_PHONE_HOME   = dbo.fnFormatPhone(@PHONE_HOME  );
	set @TEMP_PHONE_MOBILE = dbo.fnFormatPhone(@PHONE_MOBILE);
	set @TEMP_PHONE_WORK   = dbo.fnFormatPhone(@PHONE_WORK  );
	set @TEMP_PHONE_OTHER  = dbo.fnFormatPhone(@PHONE_OTHER );
	set @TEMP_PHONE_FAX    = dbo.fnFormatPhone(@PHONE_FAX   );

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
	
	-- 12/06/2005 Paul. Normalize the name.  A null USER_NAME means that the user is just an Employee. 
	set @TEMP_USER_NAME = rtrim(ltrim(@USER_NAME));
	if len(@TEMP_USER_NAME) = 0 begin -- then
		set @TEMP_USER_NAME = null;
	end -- if;
	-- 11/19/2006 Paul.  Prevent a user from reporting to himself. 
	set @TEMP_REPORTS_TO_ID = @REPORTS_TO_ID;
	if @TEMP_REPORTS_TO_ID = @ID begin -- then
		set @TEMP_REPORTS_TO_ID = null;
	end -- if;
	
	if dbo.fnUSERS_IsValidName(@ID, @TEMP_USER_NAME) = 0 begin -- then
		raiserror(N'spUSERS_Update: The user name %s already exists.  Duplicate user names are not allowed. ', 16, 1, @TEMP_USER_NAME);
	end else begin
		
		if not exists(select * from USERS where ID = @ID) begin -- then
			if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
				set @ID = newid();
			end -- if;
			insert into USERS
				( ID                    
				, CREATED_BY            
				, DATE_ENTERED          
				, MODIFIED_USER_ID      
				, DATE_MODIFIED         
				, DATE_MODIFIED_UTC     
				, USER_NAME             
				, FIRST_NAME            
				, LAST_NAME             
				, REPORTS_TO_ID         
				, IS_ADMIN              
				, RECEIVE_NOTIFICATIONS 
				, DESCRIPTION           
				, TITLE                 
				, DEPARTMENT            
				, PHONE_HOME            
				, PHONE_MOBILE          
				, PHONE_WORK            
				, PHONE_OTHER           
				, PHONE_FAX             
				, EMAIL1                
				, EMAIL2                
				, STATUS                
				, ADDRESS_STREET        
				, ADDRESS_CITY          
				, ADDRESS_STATE         
				, ADDRESS_COUNTRY       
				, ADDRESS_POSTALCODE    
				, USER_PREFERENCES      
				, PORTAL_ONLY           
				, EMPLOYEE_STATUS       
				, MESSENGER_ID          
				, MESSENGER_TYPE        
				, IS_GROUP              
				, DEFAULT_TEAM          
				, IS_ADMIN_DELEGATE     
				, SYSTEM_GENERATED_PASSWORD
				, GOOGLEAPPS_SYNC_CONTACTS 
				, GOOGLEAPPS_SYNC_CALENDAR 
				, GOOGLEAPPS_USERNAME      
				, GOOGLEAPPS_PASSWORD      
				, FACEBOOK_ID              
				, ICLOUD_SYNC_CONTACTS     
				, ICLOUD_SYNC_CALENDAR     
				, ICLOUD_USERNAME          
				, ICLOUD_PASSWORD          
				, THEME                    
				, DATE_FORMAT              
				, TIME_FORMAT              
				, LANG                     
				, CURRENCY_ID              
				, TIMEZONE_ID              
				, SAVE_QUERY               
				, GROUP_TABS               
				, SUBPANEL_TABS            
				, EXTENSION                
				, SMS_OPT_IN               
				, PICTURE                  
				)
			values
				( @ID                    
				, @MODIFIED_USER_ID      
				,  getdate()             
				, @MODIFIED_USER_ID      
				,  getdate()             
				,  getutcdate()          
				, @TEMP_USER_NAME        
				, @FIRST_NAME            
				, @LAST_NAME             
				, @TEMP_REPORTS_TO_ID    
				, @IS_ADMIN              
				, @RECEIVE_NOTIFICATIONS 
				, @DESCRIPTION           
				, @TITLE                 
				, @DEPARTMENT            
				, @TEMP_PHONE_HOME       
				, @TEMP_PHONE_MOBILE     
				, @TEMP_PHONE_WORK       
				, @TEMP_PHONE_OTHER      
				, @TEMP_PHONE_FAX        
				, @EMAIL1                
				, @EMAIL2                
				, @STATUS                
				, @ADDRESS_STREET        
				, @ADDRESS_CITY          
				, @ADDRESS_STATE         
				, @ADDRESS_COUNTRY       
				, @ADDRESS_POSTALCODE    
				, @USER_PREFERENCES      
				, @PORTAL_ONLY           
				, @EMPLOYEE_STATUS       
				, @MESSENGER_ID          
				, @MESSENGER_TYPE        
				, @IS_GROUP              
				, @DEFAULT_TEAM          
				, @IS_ADMIN_DELEGATE     
				, @SYSTEM_GENERATED_PASSWORD
				, @GOOGLEAPPS_SYNC_CONTACTS 
				, @GOOGLEAPPS_SYNC_CALENDAR 
				, @GOOGLEAPPS_USERNAME      
				, @GOOGLEAPPS_PASSWORD      
				, @FACEBOOK_ID              
				, @ICLOUD_SYNC_CONTACTS     
				, @ICLOUD_SYNC_CALENDAR     
				, @ICLOUD_USERNAME          
				, @ICLOUD_PASSWORD          
				, @THEME                    
				, @DATE_FORMAT              
				, @TIME_FORMAT              
				, @LANG                     
				, @CURRENCY_ID              
				, @TIMEZONE_ID              
				, @SAVE_QUERY               
				, @GROUP_TABS               
				, @SUBPANEL_TABS            
				, @EXTENSION                
				, @SMS_OPT_IN               
				, @PICTURE                  
				);
			-- 08/12/2006 Paul.  Set default role if defined. 
			if dbo.fnIsEmptyGuid(@DEFAULT_ROLE_ID) = 0 begin -- then
				exec dbo.spACL_ROLES_USERS_Update @MODIFIED_USER_ID, @DEFAULT_ROLE_ID, @ID;
			end -- if;
			-- 11/18/2006 Paul.  Only use team procedures when team management has been enabled. 
			if dbo.fnCONFIG_Boolean(N'enable_team_management') = 1 begin -- then
				set @FULL_NAME = dbo.fnFullName(@FIRST_NAME, @LAST_NAME);
				exec dbo.spTEAMS_InsertPrivate @ID, @ID, @TEMP_USER_NAME, @FULL_NAME;
				-- 11/26/2009 Paul.  We need to make sure that the default team is added to the membership table. 
				if dbo.fnIsEmptyGuid(@DEFAULT_TEAM) = 0 begin -- then
					exec dbo.spTEAM_MEMBERSHIPS_Update @MODIFIED_USER_ID, @DEFAULT_TEAM, @ID, 1;
				end -- if;
				-- 10/19/2010 Paul.  Set global default team if defined. 
				if dbo.fnIsEmptyGuid(@GLOBAL_DEFAULT_TEAM_ID) = 0 begin -- then
					exec dbo.spTEAM_MEMBERSHIPS_Update @MODIFIED_USER_ID, @GLOBAL_DEFAULT_TEAM_ID, @ID, 1;
				end -- if;
			end -- if;
		end else begin
			-- 11/18/2006 Paul.  We need to capture the last REPORTS_TO_ID to watch for changes. 
			-- 11/30/2017 Paul.  If the user name changes, we need to update assigned set names. 
			select @LAST_REPORTS_TO_ID = REPORTS_TO_ID
			     , @OLD_USER_NAME      = USER_NAME
			  from USERS
			 where ID = @ID;

			-- 04/15/2011 Paul.  We need to allow the Goole and Facebook properties to be cleared, so don't check if null. 
			update USERS
			   set MODIFIED_USER_ID       = @MODIFIED_USER_ID      
			     , DATE_MODIFIED          =  getdate()             
			     , DATE_MODIFIED_UTC      =  getutcdate()          
			     , USER_NAME              = @TEMP_USER_NAME        
			     , FIRST_NAME             = @FIRST_NAME            
			     , LAST_NAME              = @LAST_NAME             
			     , REPORTS_TO_ID          = @TEMP_REPORTS_TO_ID    
			     , IS_ADMIN               = @IS_ADMIN              
			     , RECEIVE_NOTIFICATIONS  = @RECEIVE_NOTIFICATIONS 
			     , DESCRIPTION            = @DESCRIPTION           
			     , TITLE                  = @TITLE                 
			     , DEPARTMENT             = @DEPARTMENT            
			     , PHONE_HOME             = @TEMP_PHONE_HOME       
			     , PHONE_MOBILE           = @TEMP_PHONE_MOBILE     
			     , PHONE_WORK             = @TEMP_PHONE_WORK       
			     , PHONE_OTHER            = @TEMP_PHONE_OTHER      
			     , PHONE_FAX              = @TEMP_PHONE_FAX        
			     , EMAIL1                 = @EMAIL1                
			     , EMAIL2                 = @EMAIL2                
			     , STATUS                 = @STATUS                
			     , ADDRESS_STREET         = @ADDRESS_STREET        
			     , ADDRESS_CITY           = @ADDRESS_CITY          
			     , ADDRESS_STATE          = @ADDRESS_STATE         
			     , ADDRESS_COUNTRY        = @ADDRESS_COUNTRY       
			     , ADDRESS_POSTALCODE     = @ADDRESS_POSTALCODE    
			     , USER_PREFERENCES       = @USER_PREFERENCES      
			     , PORTAL_ONLY            = @PORTAL_ONLY           
			     , EMPLOYEE_STATUS        = @EMPLOYEE_STATUS       
			     , MESSENGER_ID           = @MESSENGER_ID          
			     , MESSENGER_TYPE         = @MESSENGER_TYPE        
			     , IS_GROUP               = @IS_GROUP              
			     , DEFAULT_TEAM           = @DEFAULT_TEAM          
			     , IS_ADMIN_DELEGATE      = @IS_ADMIN_DELEGATE     
			     , SYSTEM_GENERATED_PASSWORD = @SYSTEM_GENERATED_PASSWORD
			     , GOOGLEAPPS_SYNC_CONTACTS  = @GOOGLEAPPS_SYNC_CONTACTS 
			     , GOOGLEAPPS_SYNC_CALENDAR  = @GOOGLEAPPS_SYNC_CALENDAR 
			     , GOOGLEAPPS_USERNAME       = @GOOGLEAPPS_USERNAME      
			     , GOOGLEAPPS_PASSWORD       = @GOOGLEAPPS_PASSWORD      
			     , FACEBOOK_ID               = @FACEBOOK_ID              
			     , ICLOUD_SYNC_CONTACTS      = @ICLOUD_SYNC_CONTACTS     
			     , ICLOUD_SYNC_CALENDAR      = @ICLOUD_SYNC_CALENDAR     
			     , ICLOUD_USERNAME           = @ICLOUD_USERNAME          
			     , ICLOUD_PASSWORD           = @ICLOUD_PASSWORD          
			     , THEME                     = @THEME                    
			     , DATE_FORMAT               = @DATE_FORMAT              
			     , TIME_FORMAT               = @TIME_FORMAT              
			     , LANG                      = @LANG                     
			     , CURRENCY_ID               = @CURRENCY_ID              
			     , TIMEZONE_ID               = @TIMEZONE_ID              
			     , SAVE_QUERY                = @SAVE_QUERY               
			     , GROUP_TABS                = @GROUP_TABS               
			     , SUBPANEL_TABS             = @SUBPANEL_TABS            
			     , EXTENSION                 = @EXTENSION                
			     , SMS_OPT_IN                = @SMS_OPT_IN               
			     , PICTURE                   = @PICTURE                  
			 where ID                     = @ID                    ;

			if dbo.fnCONFIG_Boolean(N'enable_team_management') = 1 begin -- then
				-- 11/18/2006 Paul.  If reports to has changed, then update all related teams. 
				-- Make sure that nulls don't cause a problem. 
				if @LAST_REPORTS_TO_ID is null begin -- then
					set @LAST_REPORTS_TO_ID = '00000000-0000-0000-0000-000000000000';
				end -- if;
				if @TEMP_REPORTS_TO_ID is null begin -- then
					set @TEMP_REPORTS_TO_ID = '00000000-0000-0000-0000-000000000000';
				end -- if;
				if @LAST_REPORTS_TO_ID <> @TEMP_REPORTS_TO_ID begin -- then
					exec dbo.spTEAM_MEMBERSHIPS_RefreshUser @MODIFIED_USER_ID, @ID;
				end -- if;
				-- 11/26/2009 Paul.  We need to make sure that the default team is added to the membership table. 
				if dbo.fnIsEmptyGuid(@DEFAULT_TEAM) = 0 begin -- then
					exec dbo.spTEAM_MEMBERSHIPS_Update @MODIFIED_USER_ID, @DEFAULT_TEAM, @ID, 1;
				end -- if;
			end -- if;
			-- 11/30/2017 Paul.  If the team name changes, we need to update team set names. 
			if @OLD_USER_NAME <> @USER_NAME begin -- then
				exec dbo.spASSIGNED_SETS_UpdateNames @MODIFIED_USER_ID, @ID;
			end -- if;
		end -- if;

		if not exists(select * from USERS_CSTM where ID_C = @ID) begin -- then
			insert into USERS_CSTM ( ID_C ) values ( @ID );
		end -- if;

		-- 07/09/2010 Paul.  SMTP values belong in the OUTBOUND_EMAILS table. 
		-- 04/20/2016 Paul.  Provide a way to allow each user to have their own SMTP server. 
		-- 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
		exec dbo.spOUTBOUND_EMAILS_UpdateUser @MODIFIED_USER_ID, @ID, @MAIL_SMTPUSER, @MAIL_SMTPPASS, @MAIL_SMTPSERVER, @MAIL_SMTPPORT, @MAIL_SMTPAUTH_REQ, @MAIL_SMTPSSL, @MAIL_SENDTYPE;

		-- 09/015/2016 Paul.  This is 10-year old code that makes no sense.  The parent of a user can only be another user, not an Email, Call or Meeting. 
		--if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
		--	if @PARENT_TYPE = N'Emails' begin -- then
		--		exec dbo.spEMAILS_USERS_Update        @MODIFIED_USER_ID, @PARENT_ID, @ID;
		--	end else if @PARENT_TYPE = N'Calls' begin -- then
		--		exec dbo.spCALLS_USERS_Update         @MODIFIED_USER_ID, @PARENT_ID, @ID, 1, null;
		--	end else if @PARENT_TYPE = N'Meetings' begin -- then
		--		exec dbo.spMEETINGS_USERS_Update      @MODIFIED_USER_ID, @PARENT_ID, @ID, 1, null;
		--	end -- if;
		--end -- if;

		-- 09/28/2008 Paul.  Validate after inserting or updating so that activating an existing user will be validated. 
		set @MaxUsers = dbo.fnCONFIG_Int(N'max_users');
		if @MaxUsers is not null and @MaxUsers > 0 begin -- then
			-- 08/29/2012 Paul.  Exclude the Admin and QuickBooks users from the count. 
			-- 01/09/2014 Paul.  Make room for SalesFusion and other special users. 
			-- 06/26/2015 Paul.  Make room for Marketo. 
			select @ActiveUsers = count(*)
			  from vwUSERS_Login
			 where ID > '00000000-0000-0000-0000-00000000000F';
			if @ActiveUsers > @MaxUsers begin -- then
				raiserror(N'This service has been limited to %d active users.', 16, 1, @MaxUsers);
			end -- if;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spUSERS_Update to public;
GO

