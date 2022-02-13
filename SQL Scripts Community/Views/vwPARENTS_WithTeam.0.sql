if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPARENTS_WithTeam')
	Drop View dbo.vwPARENTS_WithTeam;
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
Create View dbo.vwPARENTS_WithTeam
as
select ACCOUNTS.ID                    as PARENT_ID
     , ACCOUNTS.NAME                  as PARENT_NAME
     , N'Accounts'                    as PARENT_TYPE
     , N'Accounts'                    as MODULE
     , ASSIGNED_USER_ID               as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as PARENT_ASSIGNED_SET_ID
     , USERS.USER_NAME                as PARENT_ASSIGNED_TO
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from            ACCOUNTS
  left outer join USERS
               on USERS.ID      = ASSIGNED_USER_ID
 where ACCOUNTS.DELETED = 0
union all
select BUGS.ID                        as PARENT_ID
     , BUGS.NAME                      as PARENT_NAME
     , N'Bugs'                        as PARENT_TYPE
     , N'Bugs'                        as MODULE
     , ASSIGNED_USER_ID               as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as PARENT_ASSIGNED_SET_ID
     , USERS.USER_NAME                as PARENT_ASSIGNED_TO
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from            BUGS
  left outer join USERS
               on USERS.ID      = ASSIGNED_USER_ID
 where BUGS.DELETED = 0
union all
select CASES.ID                       as PARENT_ID
     , CASES.NAME                     as PARENT_NAME
     , N'Cases'                       as PARENT_TYPE
     , N'Cases'                       as MODULE
     , ASSIGNED_USER_ID               as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as PARENT_ASSIGNED_SET_ID
     , USERS.USER_NAME                as PARENT_ASSIGNED_TO
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from            CASES
  left outer join USERS
               on USERS.ID      = ASSIGNED_USER_ID
 where CASES.DELETED = 0
union all
select CONTACTS.ID                    as PARENT_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as PARENT_NAME
     , N'Contacts'                    as PARENT_TYPE
     , N'Contacts'                    as MODULE
     , ASSIGNED_USER_ID               as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as PARENT_ASSIGNED_SET_ID
     , USERS.USER_NAME                as PARENT_ASSIGNED_TO
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from            CONTACTS
  left outer join USERS
               on USERS.ID      = ASSIGNED_USER_ID
 where CONTACTS.DELETED = 0
union all
select EMAILS.ID                      as PARENT_ID
     , EMAILS.NAME                    as PARENT_NAME
     , N'Emails'                      as PARENT_TYPE
     , N'Emails'                      as MODULE
     , ASSIGNED_USER_ID               as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as PARENT_ASSIGNED_SET_ID
     , USERS.USER_NAME                as PARENT_ASSIGNED_TO
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from            EMAILS
  left outer join USERS
               on USERS.ID      = ASSIGNED_USER_ID
 where EMAILS.DELETED = 0
union all
select LEADS.ID                       as PARENT_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as PARENT_NAME
     , N'Leads'                       as PARENT_TYPE
     , N'Leads'                       as MODULE
     , ASSIGNED_USER_ID               as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as PARENT_ASSIGNED_SET_ID
     , USERS.USER_NAME                as PARENT_ASSIGNED_TO
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from            LEADS
  left outer join USERS
               on USERS.ID      = ASSIGNED_USER_ID
 where LEADS.DELETED = 0
union all
select OPPORTUNITIES.ID               as PARENT_ID
     , OPPORTUNITIES.NAME             as PARENT_NAME
     , N'Opportunities'               as PARENT_TYPE
     , N'Opportunities'               as MODULE
     , ASSIGNED_USER_ID               as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as PARENT_ASSIGNED_SET_ID
     , USERS.USER_NAME                as PARENT_ASSIGNED_TO
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from            OPPORTUNITIES
  left outer join USERS
               on USERS.ID      = ASSIGNED_USER_ID
 where OPPORTUNITIES.DELETED = 0
union all
select PROJECT.ID                     as PARENT_ID
     , PROJECT.NAME                   as PARENT_NAME
     , N'Project'                     as PARENT_TYPE
     , N'Projects'                    as MODULE
     , ASSIGNED_USER_ID               as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as PARENT_ASSIGNED_SET_ID
     , USERS.USER_NAME                as PARENT_ASSIGNED_TO
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from            PROJECT
  left outer join USERS
               on USERS.ID      = ASSIGNED_USER_ID
 where PROJECT.DELETED = 0
union all
select PROJECT_TASK.ID                as PARENT_ID
     , PROJECT_TASK.NAME              as PARENT_NAME
     , N'ProjectTask'                 as PARENT_TYPE
     , N'ProjectTasks'                as MODULE
     , ASSIGNED_USER_ID               as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as PARENT_ASSIGNED_SET_ID
     , USERS.USER_NAME                as PARENT_ASSIGNED_TO
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from            PROJECT_TASK
  left outer join USERS
               on USERS.ID      = ASSIGNED_USER_ID
 where PROJECT_TASK.DELETED = 0
union all
select CAMPAIGNS.ID                   as PARENT_ID
     , CAMPAIGNS.NAME                 as PARENT_NAME
     , N'Campaigns'                   as PARENT_TYPE
     , N'Campaigns'                   as MODULE
     , ASSIGNED_USER_ID               as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as PARENT_ASSIGNED_SET_ID
     , USERS.USER_NAME                as PARENT_ASSIGNED_TO
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from            CAMPAIGNS
  left outer join USERS
               on USERS.ID      = ASSIGNED_USER_ID
 where CAMPAIGNS.DELETED = 0
union all
select PROSPECTS.ID                   as PARENT_ID
     , dbo.fnFullName(PROSPECTS.FIRST_NAME, PROSPECTS.LAST_NAME) as PARENT_NAME
     , N'Prospects'                   as PARENT_TYPE
     , N'Prospects'                   as MODULE
     , ASSIGNED_USER_ID               as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as PARENT_ASSIGNED_SET_ID
     , USERS.USER_NAME                as PARENT_ASSIGNED_TO
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from            PROSPECTS
  left outer join USERS
               on USERS.ID      = ASSIGNED_USER_ID
 where PROSPECTS.DELETED = 0
union all
select CALLS.ID                       as PARENT_ID
     , CALLS.NAME                     as PARENT_NAME
     , N'Calls'                       as PARENT_TYPE
     , N'Calls'                       as MODULE
     , ASSIGNED_USER_ID               as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as PARENT_ASSIGNED_SET_ID
     , USERS.USER_NAME                as PARENT_ASSIGNED_TO
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from            CALLS
  left outer join USERS
               on USERS.ID      = ASSIGNED_USER_ID
 where CALLS.DELETED = 0
union all
select USERS.ID                       as PARENT_ID
     , USERS.USER_NAME                as PARENT_NAME
     , N'Users'                       as PARENT_TYPE
     , N'Users'                       as MODULE
     , cast(null as uniqueidentifier) as PARENT_ASSIGNED_USER_ID
     , cast(null as uniqueidentifier) as PARENT_ASSIGNED_SET_ID
     , cast(null as nvarchar(60))     as PARENT_ASSIGNED_TO
     , cast(null as nvarchar(100))    as PARENT_ASSIGNED_TO_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_ID
     , cast(null as nvarchar(128))    as PARENT_TEAM_NAME
     , cast(null as uniqueidentifier) as PARENT_TEAM_SET_ID
  from USERS
 where DELETED = 0

GO

Grant Select on dbo.vwPARENTS_WithTeam to public;
GO

