if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMPLOYEES_Sync')
	Drop View dbo.vwEMPLOYEES_Sync;
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
-- 09/09/2019 Paul.  Employees access from the React Client. 
Create View dbo.vwEMPLOYEES_Sync
as
select ID
     , dbo.fnFullName(FIRST_NAME, LAST_NAME) as FULL_NAME
     , dbo.fnFullName(FIRST_NAME, LAST_NAME) as NAME
     , USER_NAME
     , FIRST_NAME
     , LAST_NAME
     , REPORTS_TO_ID
     , REPORTS_TO_NAME
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
     , EMPLOYEE_STATUS
     , ADDRESS_STREET
     , ADDRESS_CITY
     , ADDRESS_STATE
     , ADDRESS_COUNTRY
     , ADDRESS_POSTALCODE
     , DATE_ENTERED
     , DATE_MODIFIED
     , DATE_MODIFIED_UTC
     , DESCRIPTION
     , USER_PREFERENCES
     , CREATED_BY            as CREATED_BY_ID
     , MODIFIED_USER_ID
     , DEFAULT_TEAM
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
     , PRIMARY_ROLE_ID    as PRIMARY_ROLE_ID
  from vwEMPLOYEES

GO

Grant Select on dbo.vwEMPLOYEES_Sync to public;
GO


