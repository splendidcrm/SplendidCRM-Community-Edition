if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROSPECT_LISTS_USERS')
	Drop View dbo.vwPROSPECT_LISTS_USERS;
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
-- 04/22/2006 Paul.  SugarCRM 4.0 uses plural RELATED_TYPES, like Contacts, Leads, Prospects and Users. 
-- 12/05/2006 Paul.  Literals should be in unicode to reduce conversions at runtime. 
-- 05/09/2008 Paul.  USER_NAME comes from the USERS table. 
-- 01/09/2010 Paul.  A Dynamic List is one that uses SQL to build the prospect list. 
-- 10/11/2015 Paul.  The primary ID is needed to enable Preview in the Seven theme. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwPROSPECT_LISTS_USERS
as
select PROSPECT_LISTS.ID               as PROSPECT_LIST_ID
     , PROSPECT_LISTS.NAME             as PROSPECT_LIST_NAME
     , PROSPECT_LISTS.ASSIGNED_USER_ID as PROSPECT_ASSIGNED_USER_ID
     , PROSPECT_LISTS.ASSIGNED_SET_ID  as PROSPECT_ASSIGNED_SET_ID
     , PROSPECT_LISTS.DYNAMIC_LIST     as PROSPECT_DYNAMIC_LIST
     , USERS.ID                        as ID
     , USERS.ID                        as USER_ID
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as FULL_NAME
     , USERS.USER_NAME
     , USERS.TITLE
     , USERS.EMAIL1
     , USERS.PHONE_WORK
     , PROSPECT_LISTS_PROSPECTS.DATE_ENTERED
  from            PROSPECT_LISTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = PROSPECT_LISTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE     = N'Users'
              and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       inner join USERS
               on USERS.ID                                  = PROSPECT_LISTS_PROSPECTS.RELATED_ID
              and USERS.DELETED                             = 0
 where PROSPECT_LISTS.DELETED = 0

GO

Grant Select on dbo.vwPROSPECT_LISTS_USERS to public;
GO

