if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwNOTES_RELATED_ACCOUNTS')
	Drop View dbo.vwNOTES_RELATED_ACCOUNTS;
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
-- 12/05/2017 Paul.  Include Opportunities activities under account. 
Create View dbo.vwNOTES_RELATED_ACCOUNTS
as
select ID
     , PARENT_ID as ACCOUNT_ID
  from NOTES
 where PARENT_ID   is not null
   and PARENT_TYPE = N'Accounts'
   and DELETED     = 0
union
select NOTES.ID
     , ACCOUNTS_CONTACTS.ACCOUNT_ID
  from      ACCOUNTS_CONTACTS
 inner join NOTES
         on NOTES.PARENT_ID   = ACCOUNTS_CONTACTS.CONTACT_ID
        and NOTES.PARENT_TYPE = N'Contacts'
        and NOTES.DELETED     = 0
 where ACCOUNTS_CONTACTS.DELETED = 0
union
select NOTES.ID
     , ACCOUNTS_OPPORTUNITIES.ACCOUNT_ID
  from      ACCOUNTS_OPPORTUNITIES
 inner join NOTES
         on NOTES.PARENT_ID   = ACCOUNTS_OPPORTUNITIES.OPPORTUNITY_ID
        and NOTES.PARENT_TYPE = N'Opportunities'
        and NOTES.DELETED     = 0
 where ACCOUNTS_OPPORTUNITIES.DELETED = 0
union
select NOTES.ID
     , LEADS.ACCOUNT_ID
  from      LEADS
 inner join NOTES
         on NOTES.PARENT_ID   = LEADS.ID
        and NOTES.PARENT_TYPE = N'Leads'
        and NOTES.DELETED     = 0
 where LEADS.DELETED = 0
union
select NOTES.ID
     , ACCOUNTS_CONTACTS.ACCOUNT_ID
  from      ACCOUNTS_CONTACTS
 inner join LEADS_CONTACTS
         on LEADS_CONTACTS.CONTACT_ID = ACCOUNTS_CONTACTS.CONTACT_ID
        and LEADS_CONTACTS.DELETED    = 0
 inner join NOTES
         on NOTES.PARENT_ID   = LEADS_CONTACTS.LEAD_ID
        and NOTES.PARENT_TYPE = N'Leads'
        and NOTES.DELETED     = 0
 where ACCOUNTS_CONTACTS.DELETED = 0

GO

Grant Select on dbo.vwNOTES_RELATED_ACCOUNTS to public;
GO

