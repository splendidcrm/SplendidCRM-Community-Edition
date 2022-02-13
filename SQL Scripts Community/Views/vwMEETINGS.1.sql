if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMEETINGS')
	Drop View dbo.vwMEETINGS;
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
-- 10/23/2005 Paul.  Always return full date as it will need to be converted to the correct timezone.
-- 10/23/2005 Paul.  MySQL will require the combination of the date and time fields.
-- 02/01/2006 Paul.  DB2 does not like comments in the middle of the Create View statement. 
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 11/27/2006 Paul.  Return TEAM.ID so that a deleted team will return NULL even if a value remains in the related record. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 09/12/2011 Paul.  Add aliases DATE_TIME for the workflow engine. 
-- 12/25/2012 Paul.  Add support for email reminders. 
-- 03/07/2013 Paul.  Add ALL_DAY_EVENT. 
-- 03/20/2013 Paul.  Add REPEAT fields. 
-- 03/27/2013 Paul.  Use REPEAT_PARENT.ID as REPEAT_PARENT_ID might point to deleted parent. 
-- 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 05/17/2017 Paul.  Add Tags module. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwMEETINGS
as
select MEETINGS.ID
     , MEETINGS.NAME
     , MEETINGS.LOCATION
     , MEETINGS.DURATION_HOURS
     , MEETINGS.DURATION_MINUTES
     , MEETINGS.ALL_DAY_EVENT
     , dbo.fnViewDateTime(MEETINGS.DATE_START, MEETINGS.TIME_START) as DATE_START
     , dbo.fnViewDateTime(MEETINGS.DATE_START, MEETINGS.TIME_START) as DATE_TIME
     , MEETINGS.DATE_END
     , MEETINGS.PARENT_TYPE
     , MEETINGS.STATUS
     , MEETINGS.ASSIGNED_USER_ID
     , MEETINGS.REMINDER_TIME
     , MEETINGS.EMAIL_REMINDER_TIME
     , MEETINGS.SMS_REMINDER_TIME
     , MEETINGS.PARENT_ID
     , vwPARENTS.PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID
     , MEETINGS.DATE_ENTERED
     , MEETINGS.DATE_MODIFIED
     , MEETINGS.DATE_MODIFIED_UTC
     , MEETINGS.DESCRIPTION
     , MEETINGS.IS_PRIVATE
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , MEETINGS.CREATED_BY         as CREATED_BY_ID
     , MEETINGS.MODIFIED_USER_ID
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , MEETINGS.REPEAT_TYPE
     , MEETINGS.REPEAT_INTERVAL
     , MEETINGS.REPEAT_DOW
     , MEETINGS.REPEAT_UNTIL
     , MEETINGS.REPEAT_COUNT
     , MEETINGS.RECURRING_SOURCE
     , REPEAT_PARENT.ID            as REPEAT_PARENT_ID
     , REPEAT_PARENT.NAME          as REPEAT_PARENT_NAME
     , TAG_SETS.TAG_SET_NAME
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , MEETINGS_CSTM.*
  from            MEETINGS
  left outer join MEETINGS                       REPEAT_PARENT
               on REPEAT_PARENT.ID             = MEETINGS.REPEAT_PARENT_ID
              and REPEAT_PARENT.DELETED        = 0
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID          = MEETINGS.PARENT_ID
  left outer join TEAMS
               on TEAMS.ID                     = MEETINGS.TEAM_ID
              and TEAMS.DELETED                = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID                 = MEETINGS.TEAM_SET_ID
              and TEAM_SETS.DELETED            = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID             = MEETINGS.ID
              and TAG_SETS.DELETED             = 0
  left outer join USERS                          USERS_ASSIGNED
               on USERS_ASSIGNED.ID            = MEETINGS.ASSIGNED_USER_ID
  left outer join USERS                          USERS_CREATED_BY
               on USERS_CREATED_BY.ID          = MEETINGS.CREATED_BY
  left outer join USERS                          USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID         = MEETINGS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID             = MEETINGS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED        = 0
  left outer join MEETINGS_CSTM
               on MEETINGS_CSTM.ID_C           = MEETINGS.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = MEETINGS.ID
 where MEETINGS.DELETED = 0

GO

Grant Select on dbo.vwMEETINGS to public;
GO


