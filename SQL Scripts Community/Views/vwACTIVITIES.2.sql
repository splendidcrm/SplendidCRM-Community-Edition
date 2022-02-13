if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACTIVITIES')
	Drop View dbo.vwACTIVITIES;
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
-- 08/30/2009 Paul.  All module views must have a TEAM_SET_ID. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 09/05/2013 Paul.  Add ASSIGNED_TO. 
-- 02/07/2014 Paul.  Add SMS_MESSAGES to activity list. 
-- 02/07/2014 Paul.  Add TWITTER_MESSAGES to activity list. 
-- 11/29/2014 Paul.  Add CHAT_MESSAGES to activity list. 
-- 03/07/2016 Paul.  Add same fields used for most activities to be used in deep search. 
-- 05/17/2017 Paul.  Add Tags module. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 02/03/2018 Paul.  The parent should be the parent of the base object, not the base object itself. 
Create View dbo.vwACTIVITIES
as
select TASKS.ID
     , TASKS.NAME
     , TASKS.ASSIGNED_USER_ID             as ASSIGNED_USER_ID
     , TASKS.ID                           as ACTIVITY_ID
     , N'Tasks'                           as ACTIVITY_TYPE
     , TASKS.NAME                         as ACTIVITY_NAME
     , TASKS.ASSIGNED_USER_ID             as ACTIVITY_ASSIGNED_USER_ID
     , TASKS.ASSIGNED_SET_ID              as ACTIVITY_ASSIGNED_SET_ID
     , TASKS.PARENT_ID                    as PARENT_ID
     , TASKS.PARENT_TYPE                  as PARENT_TYPE
     , vwPARENTS.PARENT_NAME              as PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID   as PARENT_ASSIGNED_SET_ID
     , TASKS.STATUS                       as STATUS
     , N'none'                            as DIRECTION
     , TASKS.DATE_START                   as DATE_START
     , TASKS.DATE_DUE                     as DATE_DUE
     , TASKS.DATE_MODIFIED                as DATE_MODIFIED
     , TASKS.DATE_MODIFIED_UTC            as DATE_MODIFIED_UTC
     , (case TASKS.STATUS when N'Not Started'   then 1
                          when N'In Progress'   then 1
                          when N'Pending Input' then 1
        else 0
        end)                              as IS_OPEN
     , TEAMS.ID                           as TEAM_ID
     , TEAMS.NAME                         as TEAM_NAME
     , TEAM_SETS.ID                       as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME
     , TASKS.DESCRIPTION
     , TASKS.IS_PRIVATE
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                   as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
  from            TASKS
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID      = TASKS.PARENT_ID
  left outer join TEAMS
               on TEAMS.ID                 = TASKS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = TASKS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = TASKS.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = TASKS.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = TASKS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where TASKS.DELETED = 0
union all
select MEETINGS.ID
     , MEETINGS.NAME
     , MEETINGS.ASSIGNED_USER_ID          as ASSIGNED_USER_ID
     , MEETINGS.ID                        as ACTIVITY_ID
     , N'Meetings'                        as ACTIVITY_TYPE
     , MEETINGS.NAME                      as ACTIVITY_NAME
     , MEETINGS.ASSIGNED_USER_ID          as ACTIVITY_ASSIGNED_USER_ID
     , MEETINGS.ASSIGNED_SET_ID           as ACTIVITY_ASSIGNED_SET_ID
     , MEETINGS.PARENT_ID                 as PARENT_ID
     , MEETINGS.PARENT_TYPE               as PARENT_TYPE
     , vwPARENTS.PARENT_NAME              as PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID   as PARENT_ASSIGNED_SET_ID
     , MEETINGS.STATUS                    as STATUS
     , N'none'                            as DIRECTION
     , MEETINGS.DATE_START                as DATE_START
     , MEETINGS.DATE_START                as DATE_DUE
     , MEETINGS.DATE_MODIFIED             as DATE_MODIFIED
     , MEETINGS.DATE_MODIFIED_UTC         as DATE_MODIFIED_UTC
     , (case MEETINGS.STATUS when N'Planned' then 1
        else 0
        end)                              as IS_OPEN
     , TEAMS.ID                           as TEAM_ID
     , TEAMS.NAME                         as TEAM_NAME
     , TEAM_SETS.ID                       as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME
     , MEETINGS.DESCRIPTION
     , MEETINGS.IS_PRIVATE
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                   as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
  from            MEETINGS
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID      = MEETINGS.PARENT_ID
  left outer join TEAMS
               on TEAMS.ID                 = MEETINGS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = MEETINGS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = MEETINGS.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = MEETINGS.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = MEETINGS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where MEETINGS.DELETED = 0
union all
select CALLS.ID
     , CALLS.NAME
     , CALLS.ASSIGNED_USER_ID             as ASSIGNED_USER_ID
     , CALLS.ID                           as ACTIVITY_ID
     , N'Calls'                           as ACTIVITY_TYPE
     , CALLS.NAME                         as ACTIVITY_NAME
     , CALLS.ASSIGNED_USER_ID             as ACTIVITY_ASSIGNED_USER_ID
     , CALLS.ASSIGNED_SET_ID              as ACTIVITY_ASSIGNED_SET_ID
     , CALLS.PARENT_ID                    as PARENT_ID
     , CALLS.PARENT_TYPE                  as PARENT_TYPE
     , vwPARENTS.PARENT_NAME              as PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID   as PARENT_ASSIGNED_SET_ID
     , CALLS.STATUS                       as STATUS
     , CALLS.DIRECTION                    as DIRECTION
     , CALLS.DATE_START                   as DATE_START
     , CALLS.DATE_START                   as DATE_DUE
     , CALLS.DATE_MODIFIED                as DATE_MODIFIED
     , CALLS.DATE_MODIFIED_UTC            as DATE_MODIFIED_UTC
     , (case CALLS.STATUS when N'Planned' then 1
        else 0
        end)                              as IS_OPEN
     , TEAMS.ID                           as TEAM_ID
     , TEAMS.NAME                         as TEAM_NAME
     , TEAM_SETS.ID                       as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME
     , CALLS.DESCRIPTION
     , CALLS.IS_PRIVATE
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                   as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
  from            CALLS
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID      = CALLS.PARENT_ID
  left outer join TEAMS
               on TEAMS.ID                 = CALLS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = CALLS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = CALLS.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = CALLS.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = CALLS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where CALLS.DELETED = 0
union all
select EMAILS.ID
     , EMAILS.NAME
     , EMAILS.ASSIGNED_USER_ID            as ASSIGNED_USER_ID
     , EMAILS.ID                          as ACTIVITY_ID
     , N'Emails'                          as ACTIVITY_TYPE
     , EMAILS.NAME                        as ACTIVITY_NAME
     , EMAILS.ASSIGNED_USER_ID            as ACTIVITY_ASSIGNED_USER_ID
     , EMAILS.ASSIGNED_SET_ID             as ACTIVITY_ASSIGNED_SET_ID
     , EMAILS.PARENT_ID                   as PARENT_ID
     , EMAILS.PARENT_TYPE                 as PARENT_TYPE
     , vwPARENTS.PARENT_NAME              as PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID   as PARENT_ASSIGNED_SET_ID
     , EMAILS.STATUS                      as STATUS
     , N'none'                            as DIRECTION
     , EMAILS.DATE_START                  as DATE_START
     , EMAILS.DATE_START                  as DATE_DUE
     , EMAILS.DATE_START                  as DATE_MODIFIED
     , EMAILS.DATE_MODIFIED_UTC           as DATE_MODIFIED_UTC
     , 0                                  as IS_OPEN
     , TEAMS.ID                           as TEAM_ID
     , TEAMS.NAME                         as TEAM_NAME
     , TEAM_SETS.ID                       as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME
     , EMAILS.DESCRIPTION
     , EMAILS.IS_PRIVATE
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                   as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
  from            EMAILS
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID      = EMAILS.PARENT_ID
  left outer join TEAMS
               on TEAMS.ID                 = EMAILS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = EMAILS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = EMAILS.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = EMAILS.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = EMAILS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where EMAILS.DELETED = 0
union all
select NOTES.ID
     , NOTES.NAME
     , NOTES.ASSIGNED_USER_ID             as ASSIGNED_USER_ID
     , NOTES.ID                           as ACTIVITY_ID
     , N'Notes'                           as ACTIVITY_TYPE
     , NOTES.NAME                         as ACTIVITY_NAME
     , cast(null as uniqueidentifier)     as ACTIVITY_ASSIGNED_USER_ID
     , cast(null as uniqueidentifier)     as ACTIVITY_ASSIGNED_SET_ID
     , NOTES.PARENT_ID                    as PARENT_ID
     , NOTES.PARENT_TYPE                  as PARENT_TYPE
     , vwPARENTS.PARENT_NAME              as PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID   as PARENT_ASSIGNED_SET_ID
     , N'Note'                            as STATUS
     , N'none'                            as DIRECTION
     , cast(null as datetime)             as DATE_START
     , cast(null as datetime)             as DATE_DUE
     , NOTES.DATE_MODIFIED                as DATE_MODIFIED
     , NOTES.DATE_MODIFIED_UTC            as DATE_MODIFIED_UTC
     , 0                                  as IS_OPEN
     , TEAMS.ID                           as TEAM_ID
     , TEAMS.NAME                         as TEAM_NAME
     , TEAM_SETS.ID                       as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME
     , NOTES.DESCRIPTION
     , NOTES.IS_PRIVATE
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                   as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
  from            NOTES
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID      = NOTES.PARENT_ID
  left outer join TEAMS
               on TEAMS.ID                 = NOTES.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = NOTES.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = NOTES.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = NOTES.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = NOTES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where NOTES.DELETED = 0
union all
select SMS_MESSAGES.ID
     , SMS_MESSAGES.NAME
     , SMS_MESSAGES.ASSIGNED_USER_ID      as ASSIGNED_USER_ID
     , SMS_MESSAGES.ID                    as ACTIVITY_ID
     , N'SmsMessages'                     as ACTIVITY_TYPE
     , SMS_MESSAGES.NAME                  as ACTIVITY_NAME
     , SMS_MESSAGES.ASSIGNED_USER_ID      as ACTIVITY_ASSIGNED_USER_ID
     , SMS_MESSAGES.ASSIGNED_SET_ID       as ACTIVITY_ASSIGNED_SET_ID
     , SMS_MESSAGES.PARENT_ID             as PARENT_ID
     , SMS_MESSAGES.PARENT_TYPE           as PARENT_TYPE
     , vwPARENTS.PARENT_NAME              as PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID   as PARENT_ASSIGNED_SET_ID
     , SMS_MESSAGES.STATUS                as STATUS
     , (case SMS_MESSAGES.TYPE when N'inbound' then N'Inbound' else N'Outbound' end) as DIRECTION
     , SMS_MESSAGES.DATE_START            as DATE_START
     , SMS_MESSAGES.DATE_START            as DATE_DUE
     , SMS_MESSAGES.DATE_START            as DATE_MODIFIED
     , SMS_MESSAGES.DATE_MODIFIED_UTC     as DATE_MODIFIED_UTC
     , 0                                  as IS_OPEN
     , TEAMS.ID                           as TEAM_ID
     , TEAMS.NAME                         as TEAM_NAME
     , TEAM_SETS.ID                       as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME
     , SMS_MESSAGES.NAME                  as DESCRIPTION
     , SMS_MESSAGES.IS_PRIVATE
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                   as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
  from            SMS_MESSAGES
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID      = SMS_MESSAGES.PARENT_ID
  left outer join TEAMS
               on TEAMS.ID                 = SMS_MESSAGES.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = SMS_MESSAGES.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = SMS_MESSAGES.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = SMS_MESSAGES.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = SMS_MESSAGES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where SMS_MESSAGES.DELETED = 0
union all
select TWITTER_MESSAGES.ID
     , TWITTER_MESSAGES.NAME
     , TWITTER_MESSAGES.ASSIGNED_USER_ID  as ASSIGNED_USER_ID
     , TWITTER_MESSAGES.ID                as ACTIVITY_ID
     , N'TwitterMessages'                 as ACTIVITY_TYPE
     , TWITTER_MESSAGES.NAME              as ACTIVITY_NAME
     , TWITTER_MESSAGES.ASSIGNED_USER_ID  as ACTIVITY_ASSIGNED_USER_ID
     , TWITTER_MESSAGES.ASSIGNED_SET_ID   as ACTIVITY_ASSIGNED_SET_ID
     , TWITTER_MESSAGES.PARENT_ID         as PARENT_ID
     , TWITTER_MESSAGES.PARENT_TYPE       as PARENT_TYPE
     , vwPARENTS.PARENT_NAME              as PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID   as PARENT_ASSIGNED_SET_ID
     , TWITTER_MESSAGES.STATUS            as STATUS
     , (case TWITTER_MESSAGES.TYPE when N'inbound' then N'Inbound' else N'Outbound' end) as DIRECTION
     , TWITTER_MESSAGES.DATE_START        as DATE_START
     , TWITTER_MESSAGES.DATE_START        as DATE_DUE
     , TWITTER_MESSAGES.DATE_START        as DATE_MODIFIED
     , TWITTER_MESSAGES.DATE_MODIFIED_UTC as DATE_MODIFIED_UTC
     , 0                                  as IS_OPEN
     , TEAMS.ID                           as TEAM_ID
     , TEAMS.NAME                         as TEAM_NAME
     , TEAM_SETS.ID                       as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME
     , TWITTER_MESSAGES.DESCRIPTION
     , TWITTER_MESSAGES.IS_PRIVATE
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                   as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
  from            TWITTER_MESSAGES
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID      = TWITTER_MESSAGES.PARENT_ID
  left outer join TEAMS
               on TEAMS.ID                 = TWITTER_MESSAGES.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = TWITTER_MESSAGES.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = TWITTER_MESSAGES.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = TWITTER_MESSAGES.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = TWITTER_MESSAGES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where TWITTER_MESSAGES.DELETED = 0
union all
select CHAT_MESSAGES.ID
     , CHAT_MESSAGES.NAME
     , CHAT_CHANNELS.ASSIGNED_USER_ID     as ASSIGNED_USER_ID
     , CHAT_MESSAGES.ID                   as ACTIVITY_ID
     , N'ChatMessages'                    as ACTIVITY_TYPE
     , CHAT_MESSAGES.NAME                 as ACTIVITY_NAME
     , CHAT_CHANNELS.ASSIGNED_USER_ID     as ACTIVITY_ASSIGNED_USER_ID
     , CHAT_CHANNELS.ASSIGNED_SET_ID      as ACTIVITY_ASSIGNED_SET_ID
     , CHAT_MESSAGES.PARENT_ID            as PARENT_ID
     , CHAT_MESSAGES.PARENT_TYPE          as PARENT_TYPE
     , vwPARENTS.PARENT_NAME              as PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID   as PARENT_ASSIGNED_SET_ID
     , cast(null as nvarchar(25))         as STATUS
     , N'none'                            as DIRECTION
     , cast(null as datetime)             as DATE_DUE
     , cast(null as datetime)             as DATE_START
     , CHAT_MESSAGES.DATE_ENTERED         as DATE_MODIFIED
     , CHAT_MESSAGES.DATE_MODIFIED_UTC    as DATE_MODIFIED_UTC
     , 0                                  as IS_OPEN
     , TEAMS.ID                           as TEAM_ID
     , TEAMS.NAME                         as TEAM_NAME
     , TEAM_SETS.ID                       as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME
     , CHAT_MESSAGES.DESCRIPTION
     , CHAT_MESSAGES.IS_PRIVATE
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                   as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
  from            CHAT_MESSAGES
       inner join CHAT_CHANNELS
               on CHAT_CHANNELS.ID         = CHAT_MESSAGES.CHAT_CHANNEL_ID
              and CHAT_CHANNELS.DELETED    = 0
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID      = CHAT_MESSAGES.PARENT_ID
  left outer join TEAMS
               on TEAMS.ID                 = CHAT_CHANNELS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = CHAT_CHANNELS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = CHAT_MESSAGES.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = CHAT_CHANNELS.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = CHAT_CHANNELS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where CHAT_MESSAGES.DELETED = 0

GO

Grant Select on dbo.vwACTIVITIES to public;
GO

