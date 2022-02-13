if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwTEAM_MEMBERSHIPS_List')
	Drop View dbo.vwTEAM_MEMBERSHIPS_List;
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
Create View dbo.vwTEAM_MEMBERSHIPS_List
as
select TEAMS.ID   as TEAM_ID
     , TEAMS.NAME as TEAM_NAME
     , USERS.ID   as USER_ID
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as FULL_NAME
     , USERS.USER_NAME
     , USERS.EMAIL1
     , USERS.PHONE_WORK
     , TEAM_MEMBERSHIPS.DATE_ENTERED
     , TEAM_MEMBERSHIPS.EXPLICIT_ASSIGN
     , TEAM_MEMBERSHIPS.IMPLICIT_ASSIGN
  from           TEAMS
      inner join TEAM_MEMBERSHIPS
              on TEAM_MEMBERSHIPS.TEAM_ID = TEAMS.ID
             and TEAM_MEMBERSHIPS.DELETED = 0
      inner join USERS
              on USERS.ID                 = TEAM_MEMBERSHIPS.USER_ID
             and USERS.DELETED            = 0
 where TEAMS.DELETED = 0

GO

Grant Select on dbo.vwTEAM_MEMBERSHIPS_List to public;
GO

