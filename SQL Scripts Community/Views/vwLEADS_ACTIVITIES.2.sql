if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwLEADS_ACTIVITIES')
	Drop View dbo.vwLEADS_ACTIVITIES;
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
-- 02/01/2006 Paul.  DB2 does not like to return NULL.  So cast NULL to the correct data type. 
-- 04/21/2006 Paul.  Email does have a status, make sure to return it.
-- 08/07/2006 Paul.  Notes has a direct relationship with Contacts.
-- 11/27/2006 Paul.  Add TEAM_ID. 
-- 11/27/2006 Paul.  Return TEAM.ID so that a deleted team will return NULL even if a value remains in the related record. 
-- 10/28/2007 Paul.  Include emails from the relationship table. 
-- 09/09/2008 Paul.  Always use a union all to prevent the implied distinct. 
-- 02/13/2009 Paul.  Notes should assume the ownership of the parent record. 
-- 08/30/2009 Paul.  All module views must have a TEAM_SET_ID. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
-- 09/05/2013 Paul.  Add ASSIGNED_TO. 
-- 09/26/2013 Paul.  Add SMS_MESSAGES to activity list. 
-- 10/22/2013 Paul.  Add TWITTER_MESSAGES to activity list. 
-- 11/29/2014 Paul.  Add CHAT_MESSAGES to activity list. 
-- 03/07/2016 Paul.  Add DESCRIPTION. 
-- 05/22/2016 Paul.  Use relationship views to include all related activities.  
-- 12/19/2016 Paul.  Remove EMAILS_LEADS as vwEMAILS_RELATED_LEADS already includes this join. 
-- 05/17/2017 Paul.  Add Tags module. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwLEADS_ACTIVITIES
as
select TASKS.ID
     , TASKS.ID                       as ACTIVITY_ID
     , N'Tasks'                       as ACTIVITY_TYPE
     , TASKS.NAME                     as ACTIVITY_NAME
     , TASKS.ASSIGNED_USER_ID         as ACTIVITY_ASSIGNED_USER_ID
     , TASKS.ASSIGNED_SET_ID          as ACTIVITY_ASSIGNED_SET_ID
     , TASKS.STATUS                   as STATUS
     , N'none'                        as DIRECTION
     , TASKS.DATE_DUE                 as DATE_DUE
     , TASKS.DATE_MODIFIED            as DATE_MODIFIED
     , TASKS.DATE_MODIFIED_UTC        as DATE_MODIFIED_UTC
     , LEADS.ID                       as LEAD_ID
     , LEADS.ASSIGNED_USER_ID         as LEAD_ASSIGNED_USER_ID
     , LEADS.ASSIGNED_SET_ID          as LEAD_ASSIGNED_SET_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as LEAD_NAME
     , CONTACTS.ID                    as CONTACT_ID
     , CONTACTS.ASSIGNED_USER_ID      as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID       as CONTACT_ASSIGNED_SET_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
     , (case TASKS.STATUS when N'Not Started'   then 1
                          when N'In Progress'   then 1
                          when N'Pending Input' then 1
        else 0
        end)                          as IS_OPEN
     , TEAMS.ID                       as TEAM_ID
     , TEAMS.NAME                     as TEAM_NAME
     , TEAM_SETS.ID                   as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME        as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST        as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME       as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , TASKS.DESCRIPTION
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
  from            LEADS
       inner join vwTASKS_RELATED_LEADS
               on vwTASKS_RELATED_LEADS.LEAD_ID = LEADS.ID
       inner join TASKS
               on TASKS.ID                 = vwTASKS_RELATED_LEADS.ID
  left outer join TEAMS
               on TEAMS.ID                 = TASKS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = TASKS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = TASKS.ID
              and TAG_SETS.DELETED         = 0
  left outer join CONTACTS
               on CONTACTS.ID              = TASKS.CONTACT_ID
              and CONTACTS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = TASKS.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = TASKS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where LEADS.DELETED = 0
union all
select MEETINGS.ID
     , MEETINGS.ID                    as ACTIVITY_ID
     , N'Meetings'                    as ACTIVITY_TYPE
     , MEETINGS.NAME                  as ACTIVITY_NAME
     , MEETINGS.ASSIGNED_USER_ID      as ACTIVITY_ASSIGNED_USER_ID
     , MEETINGS.ASSIGNED_SET_ID       as ACTIVITY_ASSIGNED_SET_ID
     , MEETINGS.STATUS                as STATUS
     , N'none'                        as DIRECTION
     , MEETINGS.DATE_START            as DATE_DUE
     , MEETINGS.DATE_MODIFIED         as DATE_MODIFIED
     , MEETINGS.DATE_MODIFIED_UTC     as DATE_MODIFIED_UTC
     , LEADS.ID                       as LEAD_ID
     , LEADS.ASSIGNED_USER_ID         as LEAD_ASSIGNED_USER_ID
     , LEADS.ASSIGNED_SET_ID          as LEAD_ASSIGNED_SET_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as LEAD_NAME
     , CONTACTS.ID                    as CONTACT_ID
     , CONTACTS.ASSIGNED_USER_ID      as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID       as CONTACT_ASSIGNED_SET_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
     , (case MEETINGS.STATUS when N'Planned' then 1
        else 0
        end)                          as IS_OPEN
     , TEAMS.ID                       as TEAM_ID
     , TEAMS.NAME                     as TEAM_NAME
     , TEAM_SETS.ID                   as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME        as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST        as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME       as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , MEETINGS.DESCRIPTION
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
  from            LEADS
       inner join vwMEETINGS_RELATED_LEADS
               on vwMEETINGS_RELATED_LEADS.LEAD_ID = LEADS.ID
       inner join MEETINGS
               on MEETINGS.ID                  = vwMEETINGS_RELATED_LEADS.ID
  left outer join TEAMS
               on TEAMS.ID                     = MEETINGS.TEAM_ID
              and TEAMS.DELETED                = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID                 = MEETINGS.TEAM_SET_ID
              and TEAM_SETS.DELETED            = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID             = MEETINGS.ID
              and TAG_SETS.DELETED             = 0
  left outer join MEETINGS_CONTACTS
               on MEETINGS_CONTACTS.MEETING_ID = MEETINGS.ID
              and MEETINGS_CONTACTS.DELETED    = 0
  left outer join CONTACTS
               on CONTACTS.ID                  = MEETINGS_CONTACTS.CONTACT_ID
              and CONTACTS.DELETED             = 0
  left outer join USERS                          USERS_ASSIGNED
               on USERS_ASSIGNED.ID            = MEETINGS.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID             = MEETINGS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED        = 0
 where LEADS.DELETED = 0
union all
select CALLS.ID
     , CALLS.ID                       as ACTIVITY_ID
     , N'Calls'                       as ACTIVITY_TYPE
     , CALLS.NAME                     as ACTIVITY_NAME
     , CALLS.ASSIGNED_USER_ID         as ACTIVITY_ASSIGNED_USER_ID
     , CALLS.ASSIGNED_SET_ID          as ACTIVITY_ASSIGNED_SET_ID
     , CALLS.STATUS                   as STATUS
     , CALLS.DIRECTION                as DIRECTION
     , CALLS.DATE_START               as DATE_DUE
     , CALLS.DATE_MODIFIED            as DATE_MODIFIED
     , CALLS.DATE_MODIFIED_UTC        as DATE_MODIFIED_UTC
     , LEADS.ID                       as LEAD_ID
     , LEADS.ASSIGNED_USER_ID         as LEAD_ASSIGNED_USER_ID
     , LEADS.ASSIGNED_SET_ID          as LEAD_ASSIGNED_SET_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as LEAD_NAME
     , CONTACTS.ID                    as CONTACT_ID
     , CONTACTS.ASSIGNED_USER_ID      as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID       as CONTACT_ASSIGNED_SET_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
     , (case CALLS.STATUS when N'Planned' then 1
        else 0
        end)                          as IS_OPEN
     , TEAMS.ID                       as TEAM_ID
     , TEAMS.NAME                     as TEAM_NAME
     , TEAM_SETS.ID                   as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME        as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST        as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME       as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , CALLS.DESCRIPTION
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
  from            LEADS
       inner join vwCALLS_RELATED_LEADS
               on vwCALLS_RELATED_LEADS.LEAD_ID = LEADS.ID
       inner join CALLS
               on CALLS.ID               = vwCALLS_RELATED_LEADS.ID
  left outer join TEAMS
               on TEAMS.ID               = CALLS.TEAM_ID
              and TEAMS.DELETED          = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID           = CALLS.TEAM_SET_ID
              and TEAM_SETS.DELETED      = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID       = CALLS.ID
              and TAG_SETS.DELETED       = 0
  left outer join CALLS_CONTACTS
               on CALLS_CONTACTS.CALL_ID = CALLS.ID
              and CALLS_CONTACTS.DELETED = 0
  left outer join CONTACTS
               on CONTACTS.ID            = CALLS_CONTACTS.CONTACT_ID
              and CONTACTS.DELETED       = 0
  left outer join USERS                    USERS_ASSIGNED
               on USERS_ASSIGNED.ID      = CALLS.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID       = CALLS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED  = 0
 where LEADS.DELETED = 0
union all
select EMAILS.ID
     , EMAILS.ID                      as ACTIVITY_ID
     , N'Emails'                      as ACTIVITY_TYPE
     , EMAILS.NAME                    as ACTIVITY_NAME
     , EMAILS.ASSIGNED_USER_ID        as ACTIVITY_ASSIGNED_USER_ID
     , EMAILS.ASSIGNED_SET_ID         as ACTIVITY_ASSIGNED_SET_ID
     , EMAILS.STATUS                  as STATUS
     , N'none'                        as DIRECTION
     , EMAILS.DATE_START              as DATE_DUE
     , EMAILS.DATE_START              as DATE_MODIFIED
     , EMAILS.DATE_MODIFIED_UTC       as DATE_MODIFIED_UTC
     , LEADS.ID                       as LEAD_ID
     , LEADS.ASSIGNED_USER_ID         as LEAD_ASSIGNED_USER_ID
     , LEADS.ASSIGNED_SET_ID          as LEAD_ASSIGNED_SET_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as LEAD_NAME
     , CONTACTS.ID                    as CONTACT_ID
     , CONTACTS.ASSIGNED_USER_ID      as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID       as CONTACT_ASSIGNED_SET_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
     , 0                              as IS_OPEN
     , TEAMS.ID                       as TEAM_ID
     , TEAMS.NAME                     as TEAM_NAME
     , TEAM_SETS.ID                   as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME        as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST        as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME       as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , EMAILS.DESCRIPTION
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
  from            LEADS
       inner join vwEMAILS_RELATED_LEADS
               on vwEMAILS_RELATED_LEADS.LEAD_ID = LEADS.ID
       inner join EMAILS
               on EMAILS.ID                = vwEMAILS_RELATED_LEADS.ID
  left outer join TEAMS
               on TEAMS.ID                 = EMAILS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = EMAILS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = EMAILS.ID
              and TAG_SETS.DELETED         = 0
  left outer join EMAILS_CONTACTS
               on EMAILS_CONTACTS.EMAIL_ID = EMAILS.ID
              and EMAILS_CONTACTS.DELETED  = 0
  left outer join CONTACTS
               on CONTACTS.ID              = EMAILS_CONTACTS.CONTACT_ID
              and CONTACTS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = EMAILS.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = EMAILS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where LEADS.DELETED = 0
union all
select NOTES.ID
     , NOTES.ID                       as ACTIVITY_ID
     , N'Notes'                       as ACTIVITY_TYPE
     , NOTES.NAME                     as ACTIVITY_NAME
     , NOTES.ASSIGNED_USER_ID         as ACTIVITY_ASSIGNED_USER_ID
     , NOTES.ASSIGNED_SET_ID          as ACTIVITY_ASSIGNED_SET_ID
     , N'Note'                        as STATUS
     , N'none'                        as DIRECTION
     , cast(null as datetime)         as DATE_DUE
     , NOTES.DATE_MODIFIED            as DATE_MODIFIED
     , NOTES.DATE_MODIFIED_UTC        as DATE_MODIFIED_UTC
     , LEADS.ID                       as LEAD_ID
     , LEADS.ASSIGNED_USER_ID         as LEAD_ASSIGNED_USER_ID
     , LEADS.ASSIGNED_SET_ID          as LEAD_ASSIGNED_SET_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as LEAD_NAME
     , CONTACTS.ID                    as CONTACT_ID
     , CONTACTS.ASSIGNED_USER_ID      as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID       as CONTACT_ASSIGNED_SET_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
     , 0                              as IS_OPEN
     , TEAMS.ID                       as TEAM_ID
     , TEAMS.NAME                     as TEAM_NAME
     , TEAM_SETS.ID                   as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME        as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST        as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME       as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , NOTES.DESCRIPTION
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
  from            LEADS
       inner join vwNOTES_RELATED_LEADS
               on vwNOTES_RELATED_LEADS.LEAD_ID = LEADS.ID
       inner join NOTES
               on NOTES.ID                 = vwNOTES_RELATED_LEADS.ID
  left outer join TEAMS
               on TEAMS.ID                 = NOTES.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = NOTES.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = NOTES.ID
              and TAG_SETS.DELETED         = 0
  left outer join CONTACTS
               on CONTACTS.ID              = NOTES.CONTACT_ID
              and CONTACTS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = NOTES.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = NOTES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where LEADS.DELETED = 0
union all
select SMS_MESSAGES.ID
     , SMS_MESSAGES.ID                as ACTIVITY_ID
     , N'SmsMessages'                 as ACTIVITY_TYPE
     , SMS_MESSAGES.NAME              as ACTIVITY_NAME
     , SMS_MESSAGES.ASSIGNED_USER_ID  as ACTIVITY_ASSIGNED_USER_ID
     , SMS_MESSAGES.ASSIGNED_SET_ID   as ACTIVITY_ASSIGNED_SET_ID
     , SMS_MESSAGES.STATUS            as STATUS
     , (case SMS_MESSAGES.TYPE when N'inbound' then N'Inbound' else N'Outbound' end) as DIRECTION
     , SMS_MESSAGES.DATE_START        as DATE_DUE
     , SMS_MESSAGES.DATE_START        as DATE_MODIFIED
     , SMS_MESSAGES.DATE_MODIFIED_UTC as DATE_MODIFIED_UTC
     , LEADS.ID                       as LEAD_ID
     , LEADS.ASSIGNED_USER_ID         as LEAD_ASSIGNED_USER_ID
     , LEADS.ASSIGNED_SET_ID          as LEAD_ASSIGNED_SET_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as LEAD_NAME
     , CONTACTS.ID                    as CONTACT_ID
     , CONTACTS.ASSIGNED_USER_ID      as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID       as CONTACT_ASSIGNED_SET_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
     , 0                              as IS_OPEN
     , TEAMS.ID                       as TEAM_ID
     , TEAMS.NAME                     as TEAM_NAME
     , TEAM_SETS.ID                   as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME        as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST        as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME       as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , SMS_MESSAGES.NAME              as DESCRIPTION
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
  from            LEADS
       inner join vwSMS_MESSAGES_RELATED_LEADS
               on vwSMS_MESSAGES_RELATED_LEADS.LEAD_ID = LEADS.ID
       inner join SMS_MESSAGES
               on SMS_MESSAGES.ID          = vwSMS_MESSAGES_RELATED_LEADS.ID
  left outer join TEAMS
               on TEAMS.ID                 = SMS_MESSAGES.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = SMS_MESSAGES.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = SMS_MESSAGES.ID
              and TAG_SETS.DELETED         = 0
  left outer join CONTACTS
               on CONTACTS.ID              = SMS_MESSAGES.TO_ID
              and CONTACTS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = SMS_MESSAGES.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = SMS_MESSAGES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where LEADS.DELETED = 0
union all
select TWITTER_MESSAGES.ID
     , TWITTER_MESSAGES.ID                as ACTIVITY_ID
     , N'TwitterMessages'                 as ACTIVITY_TYPE
     , TWITTER_MESSAGES.NAME              as ACTIVITY_NAME
     , TWITTER_MESSAGES.ASSIGNED_USER_ID  as ACTIVITY_ASSIGNED_USER_ID
     , TWITTER_MESSAGES.ASSIGNED_SET_ID   as ACTIVITY_ASSIGNED_SET_ID
     , TWITTER_MESSAGES.STATUS            as STATUS
     , (case TWITTER_MESSAGES.TYPE when N'inbound' then N'Inbound' else N'Outbound' end) as DIRECTION
     , TWITTER_MESSAGES.DATE_START        as DATE_DUE
     , TWITTER_MESSAGES.DATE_START        as DATE_MODIFIED
     , TWITTER_MESSAGES.DATE_MODIFIED_UTC as DATE_MODIFIED_UTC
     , LEADS.ID                           as LEAD_ID
     , LEADS.ASSIGNED_USER_ID             as LEAD_ASSIGNED_USER_ID
     , LEADS.ASSIGNED_SET_ID              as LEAD_ASSIGNED_SET_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as LEAD_NAME
     , cast(null as uniqueidentifier)     as CONTACT_ID
     , cast(null as uniqueidentifier)     as CONTACT_ASSIGNED_USER_ID
     , cast(null as uniqueidentifier)     as CONTACT_ASSIGNED_SET_ID
     , cast(null as nvarchar(200))        as CONTACT_NAME
     , 0                                  as IS_OPEN
     , TEAMS.ID                           as TEAM_ID
     , TEAMS.NAME                         as TEAM_NAME
     , TEAM_SETS.ID                       as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , TWITTER_MESSAGES.DESCRIPTION
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
  from            LEADS
       inner join vwTWITTER_MESSAGES_RELATED_LEADS
               on vwTWITTER_MESSAGES_RELATED_LEADS.LEAD_ID = LEADS.ID
       inner join TWITTER_MESSAGES
               on TWITTER_MESSAGES.ID          = vwTWITTER_MESSAGES_RELATED_LEADS.ID
  left outer join TEAMS
               on TEAMS.ID                     = TWITTER_MESSAGES.TEAM_ID
              and TEAMS.DELETED                = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID                 = TWITTER_MESSAGES.TEAM_SET_ID
              and TEAM_SETS.DELETED            = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID             = TWITTER_MESSAGES.ID
              and TAG_SETS.DELETED             = 0
  left outer join USERS                          USERS_ASSIGNED
               on USERS_ASSIGNED.ID            = TWITTER_MESSAGES.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID             = TWITTER_MESSAGES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED        = 0
 where LEADS.DELETED = 0
union all
select CHAT_MESSAGES.ID
     , CHAT_MESSAGES.ID                   as ACTIVITY_ID
     , N'ChatMessages'                    as ACTIVITY_TYPE
     , CHAT_MESSAGES.NAME                 as ACTIVITY_NAME
     , CHAT_CHANNELS.ASSIGNED_USER_ID     as ACTIVITY_ASSIGNED_USER_ID
     , CHAT_CHANNELS.ASSIGNED_SET_ID      as ACTIVITY_ASSIGNED_SET_ID
     , cast(null as nvarchar(25))         as STATUS
     , N'none'                            as DIRECTION
     , cast(null as datetime)             as DATE_DUE
     , CHAT_MESSAGES.DATE_ENTERED         as DATE_MODIFIED
     , CHAT_MESSAGES.DATE_MODIFIED_UTC    as DATE_MODIFIED_UTC
     , LEADS.ID                           as LEAD_ID
     , LEADS.ASSIGNED_USER_ID             as LEAD_ASSIGNED_USER_ID
     , LEADS.ASSIGNED_SET_ID              as LEAD_ASSIGNED_SET_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as LEAD_NAME
     , cast(null as uniqueidentifier)     as CONTACT_ID
     , cast(null as uniqueidentifier)     as CONTACT_ASSIGNED_USER_ID
     , cast(null as uniqueidentifier)     as CONTACT_ASSIGNED_SET_ID
     , cast(null as nvarchar(200))        as CONTACT_NAME
     , 0                                  as IS_OPEN
     , TEAMS.ID                           as TEAM_ID
     , TEAMS.NAME                         as TEAM_NAME
     , TEAM_SETS.ID                       as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST
     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , CHAT_MESSAGES.DESCRIPTION
     , TAG_SETS.TAG_SET_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
  from            LEADS
       inner join vwCHAT_MESSAGES_RELATED_LEADS
               on vwCHAT_MESSAGES_RELATED_LEADS.LEAD_ID = LEADS.ID
       inner join CHAT_MESSAGES
               on CHAT_MESSAGES.ID             = vwCHAT_MESSAGES_RELATED_LEADS.ID
       inner join CHAT_CHANNELS
               on CHAT_CHANNELS.ID             = CHAT_MESSAGES.CHAT_CHANNEL_ID
              and CHAT_CHANNELS.DELETED        = 0
  left outer join TEAMS
               on TEAMS.ID                     = CHAT_CHANNELS.TEAM_ID
              and TEAMS.DELETED                = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID                 = CHAT_CHANNELS.TEAM_SET_ID
              and TEAM_SETS.DELETED            = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID             = CHAT_CHANNELS.ID
              and TAG_SETS.DELETED             = 0
  left outer join USERS                          USERS_ASSIGNED
               on USERS_ASSIGNED.ID            = CHAT_CHANNELS.ASSIGNED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID             = CHAT_CHANNELS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED        = 0
 where LEADS.DELETED = 0

GO

Grant Select on dbo.vwLEADS_ACTIVITIES to public;
GO

