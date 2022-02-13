if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROSPECT_LISTS_InvalidEmails')
	Drop View dbo.vwPROSPECT_LISTS_InvalidEmails;
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
-- 12/27/2007 Paul.  Invalid emails should not include opt out. 
-- 09/13/2008 Paul.  DB2 requires that all column names in the union must match. 
-- 10/27/2017 Paul.  Add Accounts as email source. 
Create View dbo.vwPROSPECT_LISTS_InvalidEmails
as
select PROSPECT_LISTS.ID                                         as ID
     , PROSPECT_LISTS.NAME                                       as NAME
     , PROSPECT_LISTS.LIST_TYPE                                  as LIST_TYPE
     , PROSPECT_LISTS_PROSPECTS.RELATED_TYPE                     as RELATED_TYPE
     , CONTACTS.ID                                               as RELATED_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME)   as RELATED_NAME
     , CONTACTS.EMAIL1                                           as EMAIL1
  from            PROSPECT_LISTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = PROSPECT_LISTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE     = N'Contacts'
              and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       inner join CONTACTS
               on CONTACTS.ID                               = PROSPECT_LISTS_PROSPECTS.RELATED_ID
              and CONTACTS.DELETED                          = 0
 where PROSPECT_LISTS.DELETED = 0
   and (CONTACTS.EMAIL_OPT_OUT is null or CONTACTS.EMAIL_OPT_OUT = 0)
   and (CONTACTS.EMAIL1        is null or CONTACTS.INVALID_EMAIL = 1)
union all
select PROSPECT_LISTS.ID                                         as ID
     , PROSPECT_LISTS.NAME                                       as NAME
     , PROSPECT_LISTS.LIST_TYPE                                  as LIST_TYPE
     , PROSPECT_LISTS_PROSPECTS.RELATED_TYPE                     as RELATED_TYPE
     , PROSPECTS.ID                                              as RELATED_ID
     , dbo.fnFullName(PROSPECTS.FIRST_NAME, PROSPECTS.LAST_NAME) as RELATED_NAME
     , PROSPECTS.EMAIL1                                          as EMAIL1
  from            PROSPECT_LISTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = PROSPECT_LISTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE     = N'Prospects'
              and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       inner join PROSPECTS
               on PROSPECTS.ID                              = PROSPECT_LISTS_PROSPECTS.RELATED_ID
              and PROSPECTS.DELETED                         = 0
 where PROSPECT_LISTS.DELETED = 0
   and (PROSPECTS.EMAIL_OPT_OUT is null or PROSPECTS.EMAIL_OPT_OUT = 0)
   and (PROSPECTS.EMAIL1        is null or PROSPECTS.INVALID_EMAIL = 1)
union all
select PROSPECT_LISTS.ID                                         as ID
     , PROSPECT_LISTS.NAME                                       as NAME
     , PROSPECT_LISTS.LIST_TYPE                                  as LIST_TYPE
     , PROSPECT_LISTS_PROSPECTS.RELATED_TYPE                     as RELATED_TYPE
     , LEADS.ID                                                  as RELATED_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME)         as RELATED_NAME
     , LEADS.EMAIL1                                              as EMAIL1
  from            PROSPECT_LISTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = PROSPECT_LISTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE     = N'Leads'
              and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       inner join LEADS
               on LEADS.ID                                  = PROSPECT_LISTS_PROSPECTS.RELATED_ID
              and LEADS.DELETED                             = 0
 where PROSPECT_LISTS.DELETED = 0
   and (LEADS.EMAIL_OPT_OUT is null or LEADS.EMAIL_OPT_OUT = 0)
   and (LEADS.EMAIL1        is null or LEADS.INVALID_EMAIL = 1)
union all
select PROSPECT_LISTS.ID                                         as ID
     , PROSPECT_LISTS.NAME                                       as NAME
     , PROSPECT_LISTS.LIST_TYPE                                  as LIST_TYPE
     , PROSPECT_LISTS_PROSPECTS.RELATED_TYPE                     as RELATED_TYPE
     , USERS.ID                                                  as RELATED_ID
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME)         as RELATED_NAME
     , USERS.EMAIL1                                              as EMAIL1
  from            PROSPECT_LISTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = PROSPECT_LISTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE     = N'Users'
              and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       inner join USERS
               on USERS.ID                                  = PROSPECT_LISTS_PROSPECTS.RELATED_ID
              and USERS.DELETED                             = 0
 where PROSPECT_LISTS.DELETED = 0
   and USERS.EMAIL1 is null
union all
select PROSPECT_LISTS.ID                                         as ID
     , PROSPECT_LISTS.NAME                                       as NAME
     , PROSPECT_LISTS.LIST_TYPE                                  as LIST_TYPE
     , PROSPECT_LISTS_PROSPECTS.RELATED_TYPE                     as RELATED_TYPE
     , ACCOUNTS.ID                                               as RELATED_ID
     , ACCOUNTS.NAME                                             as RELATED_NAME
     , ACCOUNTS.EMAIL1                                           as EMAIL1
  from            PROSPECT_LISTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = PROSPECT_LISTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE     = N'Accounts'
              and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       inner join ACCOUNTS
               on ACCOUNTS.ID                               = PROSPECT_LISTS_PROSPECTS.RELATED_ID
              and ACCOUNTS.DELETED                          = 0
 where PROSPECT_LISTS.DELETED = 0
   and (ACCOUNTS.EMAIL_OPT_OUT is null or ACCOUNTS.EMAIL_OPT_OUT = 0)
   and (ACCOUNTS.EMAIL1        is null or ACCOUNTS.INVALID_EMAIL = 1)
GO

Grant Select on dbo.vwPROSPECT_LISTS_InvalidEmails to public;
GO


