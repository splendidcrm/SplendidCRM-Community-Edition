if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROSPECT_LISTS_Phones')
	Drop View dbo.vwPROSPECT_LISTS_Phones;
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
-- 01/17/2013 Paul.  Allow either work phone or mobile phone. 
-- 10/27/2017 Paul.  Add Accounts as email source. 
Create View dbo.vwPROSPECT_LISTS_Phones
as
select PROSPECT_LISTS.ID                                         as ID
     , PROSPECT_LISTS.NAME                                       as NAME
     , PROSPECT_LISTS.LIST_TYPE                                  as LIST_TYPE
     , PROSPECT_LISTS_PROSPECTS.RELATED_TYPE                     as RELATED_TYPE
     , CONTACTS.ID                                               as RELATED_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME)   as RELATED_NAME
     , isnull(CONTACTS.PHONE_WORK, CONTACTS.PHONE_MOBILE)        as PHONE_WORK
  from            PROSPECT_LISTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = PROSPECT_LISTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE     = N'Contacts'
              and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       inner join CONTACTS
               on CONTACTS.ID                               = PROSPECT_LISTS_PROSPECTS.RELATED_ID
              and CONTACTS.DELETED                          = 0
 where PROSPECT_LISTS.DELETED = 0
   and (CONTACTS.PHONE_WORK is not null or CONTACTS.PHONE_MOBILE is not null)
   and (CONTACTS.DO_NOT_CALL is null or CONTACTS.DO_NOT_CALL = 0)
union all
select PROSPECT_LISTS.ID                                         as ID
     , PROSPECT_LISTS.NAME                                       as NAME
     , PROSPECT_LISTS.LIST_TYPE                                  as LIST_TYPE
     , PROSPECT_LISTS_PROSPECTS.RELATED_TYPE                     as RELATED_TYPE
     , PROSPECTS.ID                                              as RELATED_ID
     , dbo.fnFullName(PROSPECTS.FIRST_NAME, PROSPECTS.LAST_NAME) as RELATED_NAME
     , isnull(PROSPECTS.PHONE_WORK, PROSPECTS.PHONE_MOBILE)      as PHONE_WORK
  from            PROSPECT_LISTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = PROSPECT_LISTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE     = N'Prospects'
              and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       inner join PROSPECTS
               on PROSPECTS.ID                              = PROSPECT_LISTS_PROSPECTS.RELATED_ID
              and PROSPECTS.DELETED                         = 0
 where PROSPECT_LISTS.DELETED = 0
   and (PROSPECTS.PHONE_WORK is not null or PROSPECTS.PHONE_MOBILE is not null)
   and (PROSPECTS.DO_NOT_CALL is null or PROSPECTS.DO_NOT_CALL = 0)
union all
select PROSPECT_LISTS.ID                                         as ID
     , PROSPECT_LISTS.NAME                                       as NAME
     , PROSPECT_LISTS.LIST_TYPE                                  as LIST_TYPE
     , PROSPECT_LISTS_PROSPECTS.RELATED_TYPE                     as RELATED_TYPE
     , LEADS.ID                                                  as RELATED_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME)         as RELATED_NAME
     , isnull(LEADS.PHONE_WORK, LEADS.PHONE_MOBILE)              as PHONE_WORK
  from            PROSPECT_LISTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = PROSPECT_LISTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE     = N'Leads'
              and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       inner join LEADS
               on LEADS.ID                                  = PROSPECT_LISTS_PROSPECTS.RELATED_ID
              and LEADS.DELETED                             = 0
 where PROSPECT_LISTS.DELETED = 0
   and (LEADS.PHONE_WORK is not null or LEADS.PHONE_MOBILE is not null)
   and (LEADS.DO_NOT_CALL is null or LEADS.DO_NOT_CALL = 0)
union all
select PROSPECT_LISTS.ID                                         as ID
     , PROSPECT_LISTS.NAME                                       as NAME
     , PROSPECT_LISTS.LIST_TYPE                                  as LIST_TYPE
     , PROSPECT_LISTS_PROSPECTS.RELATED_TYPE                     as RELATED_TYPE
     , USERS.ID                                                  as RELATED_ID
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME)         as RELATED_NAME
     , isnull(USERS.PHONE_WORK, USERS.PHONE_MOBILE)              as PHONE_WORK
  from            PROSPECT_LISTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = PROSPECT_LISTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE     = N'Users'
              and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       inner join USERS
               on USERS.ID                                  = PROSPECT_LISTS_PROSPECTS.RELATED_ID
              and USERS.DELETED                             = 0
 where PROSPECT_LISTS.DELETED = 0
   and (USERS.PHONE_WORK is not null or USERS.PHONE_MOBILE is not null)
union all
select PROSPECT_LISTS.ID                                         as ID
     , PROSPECT_LISTS.NAME                                       as NAME
     , PROSPECT_LISTS.LIST_TYPE                                  as LIST_TYPE
     , PROSPECT_LISTS_PROSPECTS.RELATED_TYPE                     as RELATED_TYPE
     , ACCOUNTS.ID                                               as RELATED_ID
     , ACCOUNTS.NAME                                             as RELATED_NAME
     , isnull(ACCOUNTS.PHONE_OFFICE, ACCOUNTS.PHONE_ALTERNATE)   as PHONE_WORK
  from            PROSPECT_LISTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = PROSPECT_LISTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE     = N'Accounts'
              and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       inner join ACCOUNTS
               on ACCOUNTS.ID                               = PROSPECT_LISTS_PROSPECTS.RELATED_ID
              and ACCOUNTS.DELETED                          = 0
 where PROSPECT_LISTS.DELETED = 0
   and (ACCOUNTS.PHONE_OFFICE is not null or ACCOUNTS.PHONE_ALTERNATE is not null)
   and (ACCOUNTS.DO_NOT_CALL is null or ACCOUNTS.DO_NOT_CALL = 0)
GO

Grant Select on dbo.vwPROSPECT_LISTS_Phones to public;
GO


