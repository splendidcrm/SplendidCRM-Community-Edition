if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_Import' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_Import;
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
-- 09/04/2008 Paul.  PostgreSQL does not allow modifying input parameters.  Use a local temp variable. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 09/12/2010 Paul.  Add defaults for @DEFAULT_TEAM, @IS_ADMIN_DELEGATE, @MAIL_SMTPUSER, @MAIL_SMTPPASS to ease migration to EffiProz. 
-- 07/09/2011 Paul.  Add missing default fields. 
-- 09/27/2013 Paul.  SMS messages need to be opt-in. 
Create Procedure dbo.spUSERS_Import
	( @ID                     uniqueidentifier output
	, @MODIFIED_USER_ID       uniqueidentifier
	, @USER_NAME              nvarchar(60)
	, @FIRST_NAME             nvarchar(30)
	, @LAST_NAME              nvarchar(30)
	, @REPORTS_TO_ID          uniqueidentifier
	, @REPORTS_TO_NAME        nvarchar(60)
	, @TEAM_ID                uniqueidentifier
	, @TEAM_NAME              nvarchar(128)
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
	, @EMPLOYEE_STATUS        nvarchar(25)
	, @MESSENGER_ID           nvarchar(25)
	, @MESSENGER_TYPE         nvarchar(25)
	, @PARENT_TYPE            nvarchar(25)
	, @PARENT_ID              uniqueidentifier
	, @THEME                  nvarchar(25)
	, @LANGUAGE               nvarchar(5)
	, @DATE_FORMAT            nvarchar(50)
	, @TIME_FORMAT            nvarchar(50)
	, @TIMEZONE_ID            uniqueidentifier
	, @CURRENCY_ID            uniqueidentifier
	, @EXTENSION              nvarchar(25) = null
	, @SMS_OPT_IN             nvarchar(25) = null
	)
as
  begin
	set nocount on

	declare @IS_ADMIN_DELEGATE      bit;
	declare @RECEIVE_NOTIFICATIONS  bit;
	declare @IS_ADMIN               bit;
	declare @PORTAL_ONLY            bit;
	declare @IS_GROUP               bit;
	declare @USER_PREFERENCES       nvarchar(4000);
	declare @TEMP_REPORTS_TO_ID     uniqueidentifier;
	declare @TEMP_TEAM_ID           uniqueidentifier;
	declare @DEFAULT_TEAM              uniqueidentifier;
	declare @MAIL_SMTPUSER             nvarchar(60);
	declare @MAIL_SMTPPASS             nvarchar(30);
	declare @SYSTEM_GENERATED_PASSWORD bit;
	declare @GOOGLEAPPS_SYNC_CONTACTS  bit;
	declare @GOOGLEAPPS_SYNC_CALENDAR  bit;
	declare @GOOGLEAPPS_USERNAME       nvarchar(100);
	declare @GOOGLEAPPS_PASSWORD       nvarchar(100);
	declare @FACEBOOK_ID               nvarchar(25);
	declare @ICLOUD_SYNC_CONTACTS      bit;
	declare @ICLOUD_SYNC_CALENDAR      bit;
	declare @ICLOUD_USERNAME           nvarchar(100);
	declare @ICLOUD_PASSWORD           nvarchar(100);
	declare @SAVE_QUERY                bit;
	declare @GROUP_TABS                bit;
	declare @SUBPANEL_TABS             bit;

	set @TEMP_REPORTS_TO_ID = @REPORTS_TO_ID;
	set @TEMP_TEAM_ID       = @TEAM_ID;
	set @USER_PREFERENCES = N'<?xml version="1.0" encoding="UTF-8"?>';
	set @USER_PREFERENCES = @USER_PREFERENCES + N'<USER_PREFERENCE>';
	if @LANGUAGE is not null begin -- then
		set @USER_PREFERENCES = @USER_PREFERENCES + N'<culture>';
		set @USER_PREFERENCES = @USER_PREFERENCES + @LANGUAGE;
		set @USER_PREFERENCES = @USER_PREFERENCES + N'</culture>';
	end -- if;
	if @THEME is not null begin -- then
		set @USER_PREFERENCES = @USER_PREFERENCES + N'<theme>';
		set @USER_PREFERENCES = @USER_PREFERENCES + @THEME;
		set @USER_PREFERENCES = @USER_PREFERENCES + N'</theme>';
	end -- if;
	if @DATE_FORMAT is not null begin -- then
		set @USER_PREFERENCES = @USER_PREFERENCES + N'<dateformat>';
		set @USER_PREFERENCES = @USER_PREFERENCES + @DATE_FORMAT;
		set @USER_PREFERENCES = @USER_PREFERENCES + N'</dateformat>';
	end -- if;
	if @TIME_FORMAT is not null begin -- then
		set @USER_PREFERENCES = @USER_PREFERENCES + N'<timeformat>';
		set @USER_PREFERENCES = @USER_PREFERENCES + @TIME_FORMAT;
		set @USER_PREFERENCES = @USER_PREFERENCES + N'</timeformat>';
	end -- if;
	if @TIMEZONE_ID is not null begin -- then
		set @USER_PREFERENCES = @USER_PREFERENCES + N'<timezone>';
		set @USER_PREFERENCES = @USER_PREFERENCES + cast(@TIMEZONE_ID as char(36));
		set @USER_PREFERENCES = @USER_PREFERENCES + N'</timezone>';
	end -- if;
	if @CURRENCY_ID is not null begin -- then
		set @USER_PREFERENCES = @USER_PREFERENCES + N'<currency_id>';
		set @USER_PREFERENCES = @USER_PREFERENCES + cast(@CURRENCY_ID as char(36));
		set @USER_PREFERENCES = @USER_PREFERENCES + N'</currency_id>';
	end -- if;
	set @USER_PREFERENCES = @USER_PREFERENCES + N'</USER_PREFERENCE>';

	if @TEMP_REPORTS_TO_ID is null and @REPORTS_TO_NAME is not null begin -- then
		select @TEMP_REPORTS_TO_ID = ID
		  from USERS
		 where USER_NAME      = @REPORTS_TO_NAME
		   and DELETED        = 0;
	end -- if;

	if @ID is null begin -- then
		-- 06/25/2010 Paul.  Import should lookup the user name and update if it already exists. 
		-- BEGIN Oracle Exception
			select @ID = ID
			  from USERS
			 where USER_NAME = @USER_NAME
			   and DELETED   = 0;
		-- END Oracle Exception
	end -- if;
	

	-- 09/12/2010 Paul.  Add defaults for @DEFAULT_TEAM, @IS_ADMIN_DELEGATE, @MAIL_SMTPUSER, @MAIL_SMTPPASS. 
	-- 07/09/2011 Paul.  Add more defaults. 
	-- 09/27/2013 Paul.  Add defaults for @ICLOUD_SYNC_CONTACTS, @ICLOUD_SYNC_CALENDAR, @ICLOUD_USERNAME, @ICLOUD_PASSWORD, @THEME, @DATE_FORMAT, @TIME_FORMAT, @LANG, @CURRENCY_ID, @TIMEZONE_ID, @SAVE_QUERY, @GROUP_TABS, @SUBPANEL_TABS, @EXTENSION, @SMS_OPT_IN. 
	exec dbo.spUSERS_Update @ID out, @MODIFIED_USER_ID, @USER_NAME, @FIRST_NAME, @LAST_NAME, @TEMP_REPORTS_TO_ID, @IS_ADMIN, @RECEIVE_NOTIFICATIONS, @DESCRIPTION, @TITLE, @DEPARTMENT, @PHONE_HOME, @PHONE_MOBILE, @PHONE_WORK, @PHONE_OTHER, @PHONE_FAX, @EMAIL1, @EMAIL2, @STATUS, @ADDRESS_STREET, @ADDRESS_CITY, @ADDRESS_STATE, @ADDRESS_POSTALCODE, @ADDRESS_COUNTRY, @USER_PREFERENCES, @PORTAL_ONLY, @EMPLOYEE_STATUS, @MESSENGER_ID, @MESSENGER_TYPE, @PARENT_TYPE, @PARENT_ID, @IS_GROUP, @DEFAULT_TEAM, @IS_ADMIN_DELEGATE, @MAIL_SMTPUSER, @MAIL_SMTPPASS, @SYSTEM_GENERATED_PASSWORD, @GOOGLEAPPS_SYNC_CONTACTS, @GOOGLEAPPS_SYNC_CALENDAR, @GOOGLEAPPS_USERNAME, @GOOGLEAPPS_PASSWORD, @FACEBOOK_ID, @ICLOUD_SYNC_CONTACTS, @ICLOUD_SYNC_CALENDAR, @ICLOUD_USERNAME, @ICLOUD_PASSWORD, @THEME, @DATE_FORMAT, @TIME_FORMAT, @LANGUAGE, @CURRENCY_ID, @TIMEZONE_ID, @SAVE_QUERY, @GROUP_TABS, @SUBPANEL_TABS, @EXTENSION, @SMS_OPT_IN;


	if dbo.fnCONFIG_Boolean(N'enable_team_management') = 1 begin -- then
		if @TEMP_TEAM_ID is null and @TEAM_NAME is not null begin -- then
			select @TEMP_TEAM_ID = ID
			  from TEAMS
			 where NAME     = @TEAM_NAME
			   and DELETED  = 0;
		end -- if;

		if @TEMP_TEAM_ID is not null begin -- then
			exec dbo.spTEAM_MEMBERSHIPS_Update @MODIFIED_USER_ID, @TEMP_TEAM_ID, @ID, 1;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spUSERS_Import to public;
GO

