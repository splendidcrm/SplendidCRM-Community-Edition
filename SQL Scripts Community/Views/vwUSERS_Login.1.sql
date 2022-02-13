if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS_Login')
	Drop View dbo.vwUSERS_Login;
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
-- 07/14/2006 Paul.  Inactive users should not be able to login. 
-- 07/14/2006 Paul.  New users created via NTLM will have a status of NULL. 
-- 11/25/2006 Paul.  We need to keep TEAM_ID in the session for quick access. 
-- 08/23/2008 Paul.  The Community Edition does not support Teams. 
-- 10/14/2009 Paul.  Exclude Employees and Inbound emails. 
-- 04/08/2010 Paul.  Add IS_ADMIN_DELEGATE, EXCHANGE_ALIAS, EXCHANGE_EMAIL. 
-- 07/09/2010 Paul.  Move the SMTP values from USER_PREFERENCES to the main table to make it easier to access. 
-- 07/09/2010 Paul.  SMTP values belong in the OUTBOUND_EMAILS table. 
-- 11/05/2010 Paul.  Each user can have their own email account, so we need to store EMAIL1 in the session. 
-- 03/19/2011 Paul.  Facebook login uses the MESSENGER_ID field. 
-- 03/25/2011 Paul.  Create a separate field for the Facebook ID. 
-- 09/17/2011 Paul.  Add PWD_LAST_CHANGED and SYSTEM_GENERATED_PASSWORD for password management. 
-- 08/28/2012 Paul.  PRIVATE_TEAM_ID is used in the Campaign GenerateCalls. 
-- 12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
-- 09/20/2013 Paul.  Move EXTENSION to the main table. 
-- 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
-- 05/05/2016 Paul.  Remove the space characters and quotes to make SQL parsing easier. 
-- 08/21/2017 Paul.  Add support for Office 365 OAuth credentials. 
Create View dbo.vwUSERS_Login
as
select USERS.ID
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as FULL_NAME
     , USERS.USER_NAME
     , USERS.USER_PASSWORD
     , USERS.USER_HASH
     , USERS.FIRST_NAME
     , USERS.LAST_NAME
     , USERS.IS_ADMIN
     , USERS.IS_ADMIN_DELEGATE
     , USERS.PORTAL_ONLY
     , USERS.STATUS
     , cast(null as uniqueidentifier) as TEAM_ID
     , cast(null as nvarchar(128))    as TEAM_NAME
     , cast(null as nvarchar(60))     as EXCHANGE_ALIAS
     , cast(null as nvarchar(100))    as EXCHANGE_EMAIL
     , OUTBOUND_EMAILS.MAIL_SMTPUSER
     , OUTBOUND_EMAILS.MAIL_SMTPPASS
     , USERS.EMAIL1
     , USERS.PWD_LAST_CHANGED
     , USERS.SYSTEM_GENERATED_PASSWORD
     , USERS.FACEBOOK_ID
     , cast(null as uniqueidentifier) as PRIVATE_TEAM_ID
     , USERS.THEME
     , USERS.DATE_FORMAT
     , USERS.TIME_FORMAT
     , USERS.LANG
     , USERS.CURRENCY_ID
     , USERS.TIMEZONE_ID
     , USERS.SAVE_QUERY
     , USERS.GROUP_TABS
     , USERS.SUBPANEL_TABS
     , USERS.EXTENSION
     , USERS.PRIMARY_ROLE_ID    as PRIMARY_ROLE_ID
     , replace(replace(ACL_ROLES.NAME, ' ', ''), '''', '') as PRIMARY_ROLE_NAME
     , (select count(*) from OAUTH_TOKENS where OAUTH_TOKENS.ASSIGNED_USER_ID = USERS.ID and OAUTH_TOKENS.NAME = N'Office365'  and OAUTH_TOKENS.DELETED = 0) as OFFICE365_OAUTH_ENABLED
     , (select count(*) from OAUTH_TOKENS where OAUTH_TOKENS.ASSIGNED_USER_ID = USERS.ID and OAUTH_TOKENS.NAME = N'GoogleApps' and OAUTH_TOKENS.DELETED = 0) as GOOGLEAPPS_OAUTH_ENABLED
from            USERS
  left outer join OUTBOUND_EMAILS
               on OUTBOUND_EMAILS.USER_ID         = USERS.ID
              and OUTBOUND_EMAILS.TYPE            = N'system-override'
              and OUTBOUND_EMAILS.DELETED         = 0
   left outer join ACL_ROLES_USERS
               on ACL_ROLES_USERS.USER_ID   = USERS.ID
              and ACL_ROLES_USERS.ROLE_ID   = USERS.PRIMARY_ROLE_ID
              and ACL_ROLES_USERS.DELETED   = 0
  left outer join ACL_ROLES
               on ACL_ROLES.ID              = ACL_ROLES_USERS.ROLE_ID
              and ACL_ROLES.DELETED         = 0
where USERS.DELETED = 0
   and USERS.USER_NAME is not null
  and (USERS.STATUS is null or USERS.STATUS = N'Active')

GO

Grant Select on dbo.vwUSERS_Login to public;
GO


