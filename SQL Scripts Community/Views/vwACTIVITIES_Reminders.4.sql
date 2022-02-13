if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACTIVITIES_Reminders')
	Drop View dbo.vwACTIVITIES_Reminders;
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
-- 12/24/2012 Paul.  Can't use vwACTIVITIES_List as the base because we need both USER_ID and ASSIGNED_USER_ID. 
-- 06/07/2017 Paul.  Add support for Task reminders. DATE_DUE is used and not DATE_START. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwACTIVITIES_Reminders
as
select N'Meetings'                as ACTIVITY_TYPE
     , MEETINGS_USERS.ACCEPT_STATUS
     , MEETINGS_USERS.USER_ID
     , MEETINGS.ID
     , MEETINGS.NAME
     , MEETINGS.LOCATION
     , MEETINGS.DURATION_HOURS
     , MEETINGS.DURATION_MINUTES
     , MEETINGS.DATE_START
     , MEETINGS.DATE_END
     , MEETINGS.REMINDER_TIME
     , MEETINGS.STATUS
     , cast(null as nvarchar(25)) as DIRECTION
     , MEETINGS.ASSIGNED_USER_ID
     , MEETINGS.ASSIGNED_SET_ID
     , MEETINGS.PARENT_TYPE
     , MEETINGS.PARENT_ID
     , MEETINGS.TEAM_ID
     , MEETINGS.TEAM_SET_ID
     , MEETINGS.DESCRIPTION
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
  from            MEETINGS
       inner join MEETINGS_USERS
               on MEETINGS_USERS.MEETING_ID         = MEETINGS.ID
              and MEETINGS_USERS.DELETED            = 0
              and MEETINGS_USERS.REMINDER_DISMISSED = 0
              and isnull(MEETINGS_USERS.ACCEPT_STATUS, N'none') <> N'decline'
       inner join USERS
               on USERS.ID                          =  MEETINGS_USERS.USER_ID
              and USERS.DELETED                     =  0
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID                   = MEETINGS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED              = 0
 where MEETINGS.DELETED       = 0
   and MEETINGS.REMINDER_TIME > 0
   and (MEETINGS.STATUS is null or MEETINGS.STATUS <> N'Held')
   and getdate() between dbo.fnDateAdd_Seconds(-dbo.fnCONFIG_Int('reminder_max_time'), MEETINGS.DATE_START) and dbo.fnDateAdd_Minutes(5, MEETINGS.DATE_START)
union all
select N'Calls'                   as ACTIVITY_TYPE
     , CALLS_USERS.ACCEPT_STATUS
     , CALLS_USERS.USER_ID
     , CALLS.ID
     , CALLS.NAME
     , cast(null as nvarchar(50)) as LOCATION
     , CALLS.DURATION_HOURS
     , CALLS.DURATION_MINUTES
     , CALLS.DATE_START
     , CALLS.DATE_END
     , CALLS.REMINDER_TIME
     , CALLS.STATUS
     , CALLS.DIRECTION
     , CALLS.ASSIGNED_USER_ID
     , CALLS.ASSIGNED_SET_ID
     , CALLS.PARENT_TYPE
     , CALLS.PARENT_ID
     , CALLS.TEAM_ID
     , CALLS.TEAM_SET_ID
     , CALLS.DESCRIPTION
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
  from            CALLS
       inner join CALLS_USERS
               on CALLS_USERS.CALL_ID            = CALLS.ID
              and CALLS_USERS.DELETED            = 0
              and CALLS_USERS.REMINDER_DISMISSED = 0
              and isnull(CALLS_USERS.ACCEPT_STATUS, N'none') <> N'decline'
       inner join USERS
               on USERS.ID                       = CALLS_USERS.USER_ID
              and USERS.DELETED                  = 0
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID               = CALLS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED          = 0
 where CALLS.DELETED       = 0
   and CALLS.REMINDER_TIME > 0
   and (CALLS.STATUS is null or CALLS.STATUS <> N'Held')
   and getdate() between dbo.fnDateAdd_Seconds(-dbo.fnCONFIG_Int('reminder_max_time'), CALLS.DATE_START) and dbo.fnDateAdd_Minutes(5, CALLS.DATE_START)
union all
select N'Tasks'                   as ACTIVITY_TYPE
     , TASKS_USERS.ACCEPT_STATUS
     , USERS_ASSIGNED.ID          as USER_ID
     , TASKS.ID
     , TASKS.NAME
     , cast(null as nvarchar(50)) as LOCATION
     , cast(null as int)                     as DURATION_HOURS
     , cast(null as int)                     as DURATION_MINUTES
     , TASKS.DATE_DUE                        as DATE_START
     , TASKS.DATE_DUE                        as DATE_END
     , TASKS.REMINDER_TIME
     , TASKS.STATUS
     , cast(null as nvarchar(25))            as DIRECTION
     , TASKS.ASSIGNED_USER_ID
     , TASKS.ASSIGNED_SET_ID
     , TASKS.PARENT_TYPE
     , TASKS.PARENT_ID
     , TASKS.TEAM_ID
     , TASKS.TEAM_SET_ID
     , TASKS.DESCRIPTION
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
  from            TASKS
       inner join USERS                             USERS_ASSIGNED
               on USERS_ASSIGNED.ID               = TASKS.ASSIGNED_USER_ID
              and USERS_ASSIGNED.DELETED          = 0
  left outer join TASKS_USERS
               on TASKS_USERS.TASK_ID             = TASKS.ID
              and TASKS_USERS.USER_ID             = TASKS.ASSIGNED_USER_ID
              and TASKS_USERS.DELETED             = 0
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID                = TASKS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED           = 0
 where TASKS.DELETED       = 0
   and TASKS.REMINDER_TIME > 0
   and (TASKS.STATUS is null or TASKS.STATUS in (N'Not started', N'In progress', N'Pending input'))
   and isnull(TASKS_USERS.REMINDER_DISMISSED, 0) = 0
   and isnull(TASKS_USERS.ACCEPT_STATUS, N'none') <> N'decline'
   and getdate() between dbo.fnDateAdd_Seconds(-dbo.fnCONFIG_Int('reminder_max_time'), TASKS.DATE_DUE) and dbo.fnDateAdd_Minutes(5, TASKS.DATE_DUE)

GO

Grant Select on dbo.vwACTIVITIES_Reminders to public;
GO

