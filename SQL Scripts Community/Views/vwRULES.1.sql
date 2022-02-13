if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwRULES')
	Drop View dbo.vwRULES;
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
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 02/23/2021 Paul.  DATE_MODIFIED_UTC for React client. 
-- 05/25/2021 Paul.  Add Tags module. 
Create View dbo.vwRULES
as
select RULES.ID
     , RULES.NAME
     , RULES.MODULE_NAME
     , RULES.RULE_TYPE
     , RULES.DESCRIPTION
     , RULES.ASSIGNED_USER_ID
     , RULES.DATE_ENTERED
     , RULES.DATE_MODIFIED
     , RULES.DATE_MODIFIED_UTC
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , cast(null as uniqueidentifier)      as ASSIGNED_SET_ID
     , cast(USERS_ASSIGNED.ID as char(36)) as ASSIGNED_SET_LIST
     , USERS_ASSIGNED.USER_NAME            as ASSIGNED_SET_NAME
     , TAG_SETS.TAG_SET_NAME
  from            RULES
  left outer join TEAMS
               on TEAMS.ID             = RULES.TEAM_ID
              and TEAMS.DELETED        = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID         = RULES.TEAM_SET_ID
              and TEAM_SETS.DELETED    = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID     = RULES.ID
              and TAG_SETS.DELETED     = 0
  left outer join USERS USERS_ASSIGNED
               on USERS_ASSIGNED.ID    = RULES.ASSIGNED_USER_ID
  left outer join USERS USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = RULES.CREATED_BY
  left outer join USERS USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = RULES.MODIFIED_USER_ID
 where RULES.DELETED = 0

GO

Grant Select on dbo.vwRULES to public;
GO


