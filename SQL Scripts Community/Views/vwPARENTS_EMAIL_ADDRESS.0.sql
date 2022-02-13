if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPARENTS_EMAIL_ADDRESS')
	Drop View dbo.vwPARENTS_EMAIL_ADDRESS;
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
-- 12/19/2006 Paul.  For performance, create a parent view with just Contacts, Leads and Prospects. 
-- 05/17/2008 Paul.  Include Accounts and Users so that this view can be used in spEMAILS_QueueEmailTemplate. 
-- 05/17/2008 Paul.  Also include EMAIL1. 
-- 10/15/2012 Paul.  Portal users need to be excluded as it is overlapping the Contacts record and causing a problem with Email Templates. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwPARENTS_EMAIL_ADDRESS
as
select ID               as PARENT_ID
     , NAME             as PARENT_NAME
     , N'Accounts'      as PARENT_TYPE
     , N'Accounts'      as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , EMAIL1           as EMAIL1
  from ACCOUNTS
 where DELETED = 0
union all
select ID               as PARENT_ID
     , dbo.fnFullName(FIRST_NAME, LAST_NAME) as PARENT_NAME
     , N'Contacts'      as PARENT_TYPE
     , N'Contacts'      as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , EMAIL1           as EMAIL1
  from CONTACTS
 where DELETED = 0
union all
select ID               as PARENT_ID
     , dbo.fnFullName(FIRST_NAME, LAST_NAME) as PARENT_NAME
     , N'Leads'         as PARENT_TYPE
     , N'Leads'         as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , EMAIL1           as EMAIL1
  from LEADS
 where DELETED = 0
union all
select ID               as PARENT_ID
     , dbo.fnFullName(FIRST_NAME, LAST_NAME) as PARENT_NAME
     , N'Prospects'     as PARENT_TYPE
     , N'Prospects'     as MODULE
     , ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , EMAIL1           as EMAIL1
  from PROSPECTS
union all
select ID               as PARENT_ID
     , dbo.fnFullName(FIRST_NAME, LAST_NAME) as PARENT_NAME
     , N'Users'         as PARENT_TYPE
     , N'Users'         as MODULE
     , cast(null as uniqueidentifier) as PARENT_ASSIGNED_USER_ID
     , cast(null as uniqueidentifier) as PARENT_ASSIGNED_SET_ID
     , EMAIL1           as EMAIL1
  from USERS
 where (PORTAL_ONLY is null or PORTAL_ONLY = 0)
   and DELETED = 0

GO

Grant Select on dbo.vwPARENTS_EMAIL_ADDRESS to public;
GO

