if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS')
	Drop View dbo.vwUSERS;
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
-- 05/23/2006 Paul.  Remove USER_PASSWORD and USER_HASH so that this view can be used in reports. 
-- 09/21/2007 Paul.  Email Templates need the full name to be returned in the NAME field. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 05/06/2009 Paul.  Add DEFAULT_TEAM to support SugarCRM migration. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 03/16/2010 Paul.  Add IS_ADMIN_DELEGATE. 
-- 07/09/2010 Paul.  Move the SMTP values from USER_PREFERENCES to the main table to make it easier to access. 
-- 07/09/2010 Paul.  SMTP values belong in the OUTBOUND_EMAILS table. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 03/04/2011 Paul.  We need to allow the admin to set the flag to force a password change. 
-- 03/25/2011 Paul.  Add support for Google Apps. 
-- 03/25/2011 Paul.  Create a separate field for the Facebook ID. 
-- 12/13/2011 Paul.  Add support for Apple iCloud. 
-- 12/23/2011 Paul.  We need separate CTAGs for Contacts and Calendar. 
-- 12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
-- 09/20/2013 Paul.  Move EXTENSION to the main table. 
-- 09/27/2013 Paul.  SMS messages need to be opt-in. 
-- 11/21/2014 Paul.  Add User Picture. 
-- 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
-- 05/05/2016 Paul.  Remove the space characters and quotes to make SQL parsing easier. 
Create View dbo.vwUSERS
as
select USERS.ID
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as FULL_NAME
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as NAME
     , USERS.USER_NAME
     , USERS.FIRST_NAME
     , USERS.LAST_NAME
     , USERS.REPORTS_TO_ID
     , dbo.fnFullName(REPORTS_TO_USERS.FIRST_NAME, REPORTS_TO_USERS.LAST_NAME) as REPORTS_TO_NAME
     , USERS.IS_ADMIN
     , USERS.PORTAL_ONLY
     , USERS.RECEIVE_NOTIFICATIONS
     , USERS.TITLE
     , USERS.DEPARTMENT
     , USERS.PHONE_HOME
     , USERS.PHONE_MOBILE
     , USERS.PHONE_WORK
     , USERS.PHONE_OTHER
     , USERS.PHONE_FAX
     , USERS.EMAIL1
     , USERS.EMAIL2
     , USERS.STATUS
     , USERS.EMPLOYEE_STATUS
     , USERS.MESSENGER_ID
     , USERS.MESSENGER_TYPE
     , USERS.ADDRESS_STREET
     , USERS.ADDRESS_CITY
     , USERS.ADDRESS_STATE
     , USERS.ADDRESS_COUNTRY
     , USERS.ADDRESS_POSTALCODE
     , USERS.IS_GROUP
     , USERS.DATE_ENTERED
     , USERS.DATE_MODIFIED
     , USERS.DATE_MODIFIED_UTC
     , USERS.DESCRIPTION
     , USERS.USER_PREFERENCES
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , USERS.CREATED_BY            as CREATED_BY_ID
     , USERS.MODIFIED_USER_ID
     , USERS.DEFAULT_TEAM
     , TEAMS.NAME                  as DEFAULT_TEAM_NAME
     , USERS.IS_ADMIN_DELEGATE
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , USERS.SYSTEM_GENERATED_PASSWORD
     , USERS.GOOGLEAPPS_SYNC_CONTACTS
     , USERS.GOOGLEAPPS_SYNC_CALENDAR
     , USERS.GOOGLEAPPS_USERNAME
     , USERS.GOOGLEAPPS_PASSWORD
     , USERS.FACEBOOK_ID
     , USERS.ICLOUD_SYNC_CONTACTS
     , USERS.ICLOUD_SYNC_CALENDAR
     , USERS.ICLOUD_USERNAME
     , USERS.ICLOUD_PASSWORD
     , USERS.ICLOUD_CTAG_CONTACTS
     , USERS.ICLOUD_CTAG_CALENDAR
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
     , USERS.SMS_OPT_IN
     , USERS.PICTURE
     , USERS.PRIMARY_ROLE_ID    as PRIMARY_ROLE_ID
     , replace(replace(ACL_ROLES.NAME, ' ', ''), '''', '') as PRIMARY_ROLE_NAME
     , USERS_CSTM.*
  from            USERS
  left outer join USERS REPORTS_TO_USERS
               on REPORTS_TO_USERS.ID       = USERS.REPORTS_TO_ID
              and REPORTS_TO_USERS.DELETED  = 0
  left outer join USERS USERS_CREATED_BY
               on USERS_CREATED_BY.ID       = USERS.CREATED_BY
  left outer join USERS USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID      = USERS.MODIFIED_USER_ID
  left outer join USERS_CSTM
               on USERS_CSTM.ID_C           = USERS.ID
  left outer join TEAMS
               on TEAMS.ID                  = USERS.DEFAULT_TEAM
  left outer join ACL_ROLES_USERS
               on ACL_ROLES_USERS.USER_ID   = USERS.ID
              and ACL_ROLES_USERS.ROLE_ID   = USERS.PRIMARY_ROLE_ID
              and ACL_ROLES_USERS.DELETED   = 0
  left outer join ACL_ROLES
               on ACL_ROLES.ID              = ACL_ROLES_USERS.ROLE_ID
              and ACL_ROLES.DELETED         = 0
 where USERS.DELETED = 0

GO

Grant Select on dbo.vwUSERS to public;
GO


