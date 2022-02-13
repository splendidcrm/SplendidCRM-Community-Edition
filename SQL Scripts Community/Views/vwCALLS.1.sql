if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCALLS')
	Drop View dbo.vwCALLS;
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
-- 08/28/2012 Paul.  Add PHONE_WORK so that it will be easy to display on the Calls detail view. 
-- 12/25/2012 Paul.  Add support for email reminders. 
-- 03/07/2013 Paul.  Add ALL_DAY_EVENT. 
-- 03/20/2013 Paul.  Add REPEAT fields. 
-- 03/27/2013 Paul.  Use REPEAT_PARENT.ID as REPEAT_PARENT_ID might point to deleted parent. 
-- 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 05/17/2017 Paul.  Add Tags module. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwCALLS
as
select CALLS.ID
     , CALLS.NAME
     , CALLS.DURATION_HOURS
     , CALLS.DURATION_MINUTES
     , CALLS.ALL_DAY_EVENT
     , dbo.fnViewDateTime(CALLS.DATE_START, CALLS.TIME_START) as DATE_START
     , dbo.fnViewDateTime(CALLS.DATE_START, CALLS.TIME_START) as DATE_TIME
     , CALLS.DATE_END
     , CALLS.PARENT_TYPE
     , CALLS.STATUS
     , CALLS.DIRECTION
     , CALLS.ASSIGNED_USER_ID
     , CALLS.REMINDER_TIME
     , CALLS.EMAIL_REMINDER_TIME
     , CALLS.SMS_REMINDER_TIME
     , CALLS.PARENT_ID
     , vwPARENTS.PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID
     , vwPARENTS.PHONE_WORK
     , CALLS.DATE_ENTERED
     , CALLS.DATE_MODIFIED
     , CALLS.DATE_MODIFIED_UTC
     , CALLS.DESCRIPTION
     , CALLS.IS_PRIVATE
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , CALLS.CREATED_BY            as CREATED_BY_ID
     , CALLS.MODIFIED_USER_ID
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , CALLS.REPEAT_TYPE
     , CALLS.REPEAT_INTERVAL
     , CALLS.REPEAT_DOW
     , CALLS.REPEAT_UNTIL
     , CALLS.REPEAT_COUNT
     , CALLS.RECURRING_SOURCE
     , REPEAT_PARENT.ID            as REPEAT_PARENT_ID
     , REPEAT_PARENT.NAME          as REPEAT_PARENT_NAME
     , TAG_SETS.TAG_SET_NAME
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , CALLS_CSTM.*
  from            CALLS
  left outer join CALLS                    REPEAT_PARENT
               on REPEAT_PARENT.ID       = CALLS.REPEAT_PARENT_ID
              and REPEAT_PARENT.DELETED  = 0
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID    = CALLS.PARENT_ID
  left outer join TEAMS
               on TEAMS.ID               = CALLS.TEAM_ID
              and TEAMS.DELETED          = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID           = CALLS.TEAM_SET_ID
              and TEAM_SETS.DELETED      = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID       = CALLS.ID
              and TAG_SETS.DELETED       = 0
  left outer join USERS                    USERS_ASSIGNED
               on USERS_ASSIGNED.ID      = CALLS.ASSIGNED_USER_ID
  left outer join USERS                    USERS_CREATED_BY
               on USERS_CREATED_BY.ID    = CALLS.CREATED_BY
  left outer join USERS                    USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID   = CALLS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID       = CALLS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED  = 0
  left outer join CALLS_CSTM
               on CALLS_CSTM.ID_C        = CALLS.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = CALLS.ID
 where CALLS.DELETED = 0

GO

Grant Select on dbo.vwCALLS to public;
GO

 
