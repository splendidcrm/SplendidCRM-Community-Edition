if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROJECTS')
	Drop View dbo.vwPROJECTS;
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
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 11/27/2006 Paul.  Return TEAM.ID so that a deleted team will return NULL even if a value remains in the related record. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 08/30/2009 Paul.  All module views must have a TEAM_SET_ID. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 01/07/2010 Paul.  The effort should not include deleted records. 
-- 01/13/2010 Paul.  New Project fields in SugarCRM. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwPROJECTS
as
select PROJECT.ID
     , PROJECT.NAME
     , (select sum(ESTIMATED_EFFORT) from PROJECT_TASK where PROJECT_TASK.DELETED = 0 and PROJECT_TASK.PARENT_ID = PROJECT.ID) as TOTAL_ESTIMATED_EFFORT
     , (select sum(ACTUAL_EFFORT   ) from PROJECT_TASK where PROJECT_TASK.DELETED = 0 and PROJECT_TASK.PARENT_ID = PROJECT.ID) as TOTAL_ACTUAL_EFFORT
     , PROJECT.ASSIGNED_USER_ID
     , PROJECT.ESTIMATED_START_DATE
     , PROJECT.ESTIMATED_END_DATE
     , PROJECT.STATUS
     , PROJECT.PRIORITY
     , PROJECT.IS_TEMPLATE
     , PROJECT.DATE_ENTERED
     , PROJECT.DATE_MODIFIED
     , PROJECT.DATE_MODIFIED_UTC
     , PROJECT.DESCRIPTION
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , PROJECT.CREATED_BY          as CREATED_BY_ID
     , PROJECT.MODIFIED_USER_ID
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , LAST_ACTIVITY.LAST_ACTIVITY_DATE
     , TAG_SETS.TAG_SET_NAME
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , PROJECT_CSTM.*
  from            PROJECT
  left outer join TEAMS
               on TEAMS.ID                 = PROJECT.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = PROJECT.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join LAST_ACTIVITY
               on LAST_ACTIVITY.ACTIVITY_ID= PROJECT.ID
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = PROJECT.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = PROJECT.ASSIGNED_USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = PROJECT.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = PROJECT.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = PROJECT.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
  left outer join PROJECT_CSTM
               on PROJECT_CSTM.ID_C        = PROJECT.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = PROJECT.ID
 where PROJECT.DELETED = 0

GO

Grant Select on dbo.vwPROJECTS to public;
GO

 
