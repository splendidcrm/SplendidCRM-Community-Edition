if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPARENTS')
	Drop View dbo.vwPARENTS;
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
-- 12/19/2006 Paul.  Include Prospects.  This is so that we can determine if an email is sent to a Contact, Lead or Prospect. 
-- 06/12/2007 Paul.  Include Contracts as contracts can contain notes. 
-- 06/12/2007 Paul.  Include Calls as calls can contain notes. 
-- 06/21/2007 Paul.  Include Products, Quotes, Orders and Invoices so that they can contain notes. 
-- 12/25/2007 Paul.  Include Users so that we can link from Campaign Status/Logs.
-- 08/23/2008 Paul.  Contracts, Products, Quotes, Orders, Invoices are not supported in the Community Edition. 
-- 08/28/2012 Paul.  Add PHONE_WORK so that it will be easy to display on the Calls detail view. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwPARENTS
as
select ID               as PARENT_ID
     , NAME             as PARENT_NAME
     , N'Accounts'      as PARENT_TYPE
     , N'Accounts'      as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , PHONE_OFFICE     as PHONE_WORK
  from ACCOUNTS
 where DELETED = 0
union all
select ID               as PARENT_ID
     , NAME             as PARENT_NAME
     , N'Bugs'          as PARENT_TYPE
     , N'Bugs'          as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , cast(null as nvarchar(25)) as PHONE_WORK
  from BUGS
 where DELETED = 0
union all
select ID               as PARENT_ID
     , NAME             as PARENT_NAME
     , N'Cases'         as PARENT_TYPE
     , N'Cases'         as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , cast(null as nvarchar(25)) as PHONE_WORK
  from CASES
 where DELETED = 0
union all
select ID               as PARENT_ID
     , rtrim(isnull(FIRST_NAME, N'') + N' ' + isnull(LAST_NAME, N'')) as PARENT_NAME
     , N'Contacts'      as PARENT_TYPE
     , N'Contacts'      as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , PHONE_WORK
  from CONTACTS
 where DELETED = 0
union all
select ID               as PARENT_ID
     , NAME             as PARENT_NAME
     , N'Emails'        as PARENT_TYPE
     , N'Emails'        as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , cast(null as nvarchar(25)) as PHONE_WORK
  from EMAILS
 where DELETED = 0
union all
select ID               as PARENT_ID
     , rtrim(isnull(FIRST_NAME, N'') + N' ' + isnull(LAST_NAME, N'')) as PARENT_NAME
     , N'Leads'         as PARENT_TYPE
     , N'Leads'         as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , PHONE_WORK
  from LEADS
 where DELETED = 0
union all
select ID               as PARENT_ID
     , NAME             as PARENT_NAME
     , N'Opportunities' as PARENT_TYPE
     , N'Opportunities' as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , cast(null as nvarchar(25)) as PHONE_WORK
  from OPPORTUNITIES
 where DELETED = 0
union all
select ID               as PARENT_ID
     , NAME             as PARENT_NAME
     , N'Project'       as PARENT_TYPE
     , N'Projects'      as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , cast(null as nvarchar(25)) as PHONE_WORK
  from PROJECT
 where DELETED = 0
union all
select ID               as PARENT_ID
     , NAME             as PARENT_NAME
     , N'ProjectTask'   as PARENT_TYPE
     , N'ProjectTasks'  as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , cast(null as nvarchar(25)) as PHONE_WORK
  from PROJECT_TASK
 where DELETED = 0
union all
select ID               as PARENT_ID
     , NAME             as PARENT_NAME
     , N'Campaigns'     as PARENT_TYPE
     , N'Campaigns'     as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , cast(null as nvarchar(25)) as PHONE_WORK
  from CAMPAIGNS
 where DELETED = 0
union all
select ID               as PARENT_ID
     , rtrim(isnull(FIRST_NAME, N'') + N' ' + isnull(LAST_NAME, N'')) as PARENT_NAME
     , N'Prospects'     as PARENT_TYPE
     , N'Prospects'     as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , PHONE_WORK
  from PROSPECTS
 where DELETED = 0
union all
select ID               as PARENT_ID
     , NAME             as PARENT_NAME
     , N'Calls'         as PARENT_TYPE
     , N'Calls'         as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , cast(null as nvarchar(25)) as PHONE_WORK
  from CALLS
 where DELETED = 0
union all
select ID               as PARENT_ID
     , USER_NAME        as PARENT_NAME
     , N'Users'         as PARENT_TYPE
     , N'Users'         as MODULE
     , cast(null as uniqueidentifier) as PARENT_ASSIGNED_USER_ID
     , cast(null as uniqueidentifier) as PARENT_ASSIGNED_SET_ID
     , PHONE_WORK
  from USERS
 where DELETED = 0

GO

Grant Select on dbo.vwPARENTS to public;
GO

