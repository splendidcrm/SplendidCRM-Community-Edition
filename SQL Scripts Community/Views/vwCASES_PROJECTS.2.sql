if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCASES_PROJECTS')
	Drop View dbo.vwCASES_PROJECTS;
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
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwCASES_PROJECTS
as
select CASES.ID                    as CASE_ID
     , CASES.NAME                  as CASE_NAME
     , CASES.ASSIGNED_USER_ID      as CASE_ASSIGNED_USER_ID
     , CASES.ASSIGNED_SET_ID       as CASE_ASSIGNED_SET_ID
     , vwPROJECTS.ID               as PROJECT_ID
     , vwPROJECTS.NAME             as PROJECT_NAME
     , vwPROJECTS.*
  from           CASES
      inner join PROJECTS_CASES
              on PROJECTS_CASES.CASE_ID      = CASES.ID
             and PROJECTS_CASES.DELETED      = 0
      inner join vwPROJECTS
              on vwPROJECTS.ID               = PROJECTS_CASES.PROJECT_ID
 left outer join USERS
              on USERS.ID                    = vwPROJECTS.ASSIGNED_USER_ID
             and USERS.DELETED               = 0
 where CASES.DELETED = 0

GO

Grant Select on dbo.vwCASES_PROJECTS to public;
GO


