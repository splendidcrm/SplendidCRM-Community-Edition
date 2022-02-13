if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACCOUNTS_PROJECTS')
	Drop View dbo.vwACCOUNTS_PROJECTS;
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
-- 10/27/2012 Paul.  Project Relations data for Accounts moved to PROJECTS_ACCOUNTS. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwACCOUNTS_PROJECTS
as
select ACCOUNTS.ID                 as ACCOUNT_ID
     , ACCOUNTS.NAME               as ACCOUNT_NAME
     , ACCOUNTS.ASSIGNED_USER_ID   as ACCOUNT_ASSIGNED_USER_ID
     , ACCOUNTS.ASSIGNED_SET_ID    as ACCOUNT_ASSIGNED_SET_ID
     , vwPROJECTS.ID               as PROJECT_ID
     , vwPROJECTS.NAME             as PROJECT_NAME
     , vwPROJECTS.*
  from           ACCOUNTS
      inner join PROJECTS_ACCOUNTS
              on PROJECTS_ACCOUNTS.ACCOUNT_ID   = ACCOUNTS.ID
             and PROJECTS_ACCOUNTS.DELETED      = 0
      inner join vwPROJECTS
              on vwPROJECTS.ID                  = PROJECTS_ACCOUNTS.PROJECT_ID
 left outer join USERS
              on USERS.ID                       = vwPROJECTS.ASSIGNED_USER_ID
             and USERS.DELETED                  = 0
 where ACCOUNTS.DELETED = 0

GO

Grant Select on dbo.vwACCOUNTS_PROJECTS to public;
GO


