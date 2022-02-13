if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROJECT_TASKS')
	Drop View dbo.vwPROJECT_TASKS;
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
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 09/12/2011 Paul.  Add aliases DATE_TIME_DUE and DATE_TIME_START for the workflow engine. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwPROJECT_TASKS
as
select PROJECT_TASK.ID
     , PROJECT_TASK.NAME
     , PROJECT_TASK.STATUS
     , PROJECT_TASK.DATE_DUE
     , PROJECT_TASK.TIME_DUE
     , PROJECT_TASK.DATE_START
     , PROJECT_TASK.TIME_START
     , dbo.fnViewDateTime(PROJECT_TASK.DATE_DUE  , PROJECT_TASK.TIME_DUE  ) as DATE_TIME_DUE
     , dbo.fnViewDateTime(PROJECT_TASK.DATE_START, PROJECT_TASK.TIME_START) as DATE_TIME_START
     , PROJECT_TASK.PRIORITY
     , PROJECT_TASK.ORDER_NUMBER
     , PROJECT_TASK.TASK_NUMBER
     , PROJECT_TASK.MILESTONE_FLAG
     , PROJECT_TASK.ESTIMATED_EFFORT
     , PROJECT_TASK.ACTUAL_EFFORT
     , PROJECT_TASK.UTILIZATION
     , PROJECT_TASK.PERCENT_COMPLETE
     , PROJECT_TASK.ASSIGNED_USER_ID
     , PROJECT_TASK.DATE_ENTERED
     , PROJECT_TASK.DATE_MODIFIED
     , PROJECT_TASK.DATE_MODIFIED_UTC
     , PROJECT_TASK.DESCRIPTION
     , PROJECT.ID                  as PROJECT_ID
     , PROJECT.NAME                as PROJECT_NAME
     , PROJECT.ASSIGNED_USER_ID    as PROJECT_ASSIGNED_USER_ID
     , PROJECT.ASSIGNED_SET_ID     as PROJECT_ASSIGNED_SET_ID
     , DEPENDS_PROJECT_TASK.ID     as DEPENDS_ON_ID
     , DEPENDS_PROJECT_TASK.NAME   as DEPENDS_ON_NAME
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , PROJECT_TASK.CREATED_BY     as CREATED_BY_ID
     , PROJECT_TASK.MODIFIED_USER_ID
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , PROJECT_TASK_CSTM.*
  from            PROJECT_TASK
  left outer join PROJECT
               on PROJECT.ID               = PROJECT_TASK.PARENT_ID
  left outer join PROJECT_TASK               DEPENDS_PROJECT_TASK
               on DEPENDS_PROJECT_TASK.ID  = PROJECT_TASK.DEPENDS_ON_ID
  left outer join TEAMS
               on TEAMS.ID                 = PROJECT_TASK.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = PROJECT_TASK.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = PROJECT_TASK.ASSIGNED_USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = PROJECT_TASK.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = PROJECT_TASK.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = PROJECT_TASK.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
  left outer join PROJECT_TASK_CSTM
               on PROJECT_TASK_CSTM.ID_C   = PROJECT_TASK.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = PROJECT_TASK.ID
 where PROJECT_TASK.DELETED = 0

GO

Grant Select on dbo.vwPROJECT_TASKS to public;
GO


