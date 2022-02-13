if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS_LOGINS')
	Drop View dbo.vwUSERS_LOGINS;
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
-- 07/08/2018 Paul.  The ID is needed for export. 
-- 03/27/2019 Paul.  Every searchable view should have a NAME field. 
-- 10/30/2020 Paul.  DATE_ENTERED for the React Client. 
Create View dbo.vwUSERS_LOGINS
as
select USERS_LOGINS.ID
     , USERS_LOGINS.USER_ID
     , USERS_LOGINS.USER_NAME
     , USERS_LOGINS.LOGIN_TYPE
     , USERS_LOGINS.LOGIN_DATE
     , USERS_LOGINS.LOGOUT_DATE
     , USERS_LOGINS.LOGIN_STATUS
     , USERS_LOGINS.ASPNET_SESSIONID
     , USERS_LOGINS.REMOTE_HOST
     , USERS_LOGINS.TARGET
     , USERS_LOGINS.USER_AGENT
     , USERS_LOGINS.DATE_MODIFIED
     , USERS_LOGINS.DATE_ENTERED
     , vwUSERS.FULL_NAME
     , vwUSERS.IS_ADMIN
     , vwUSERS.STATUS
     , USERS_LOGINS.USER_NAME        as NAME
  from            USERS_LOGINS
  left outer join vwUSERS
               on vwUSERS.ID = USERS_LOGINS.USER_ID

GO

Grant Select on dbo.vwUSERS_LOGINS to public;
GO

