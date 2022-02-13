if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCHAT_MESSAGES_RELATED_ACCOUNTS')
	Drop View dbo.vwCHAT_MESSAGES_RELATED_ACCOUNTS;
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
Create View dbo.vwCHAT_MESSAGES_RELATED_ACCOUNTS
as
select ID
     , PARENT_ID as ACCOUNT_ID
  from CHAT_MESSAGES
 where PARENT_ID   is not null
   and PARENT_TYPE = N'Accounts'
   and DELETED     = 0
union
select CHAT_MESSAGES.ID
     , CHAT_CHANNELS.PARENT_ID as ACCOUNT_ID
  from      CHAT_CHANNELS
 inner join CHAT_MESSAGES
         on CHAT_MESSAGES.CHAT_CHANNEL_ID = CHAT_CHANNELS.ID
        and CHAT_MESSAGES.DELETED         = 0
 where CHAT_CHANNELS.PARENT_ID   is not null
   and CHAT_CHANNELS.PARENT_TYPE = N'Accounts'
   and CHAT_CHANNELS.DELETED     = 0
union
select CHAT_MESSAGES.ID
     , ACCOUNTS_CONTACTS.ACCOUNT_ID
  from      ACCOUNTS_CONTACTS
 inner join CHAT_MESSAGES
         on CHAT_MESSAGES.PARENT_ID   = ACCOUNTS_CONTACTS.CONTACT_ID
        and CHAT_MESSAGES.PARENT_TYPE = N'Contacts'
        and CHAT_MESSAGES.DELETED     = 0
 where ACCOUNTS_CONTACTS.DELETED = 0
union
select CHAT_MESSAGES.ID
     , ACCOUNTS_OPPORTUNITIES.ACCOUNT_ID
  from      ACCOUNTS_OPPORTUNITIES
 inner join CHAT_MESSAGES
         on CHAT_MESSAGES.PARENT_ID   = ACCOUNTS_OPPORTUNITIES.OPPORTUNITY_ID
        and CHAT_MESSAGES.PARENT_TYPE = N'Opportunities'
        and CHAT_MESSAGES.DELETED     = 0
 where ACCOUNTS_OPPORTUNITIES.DELETED = 0
union
select CHAT_MESSAGES.ID
     , ACCOUNTS_CONTACTS.ACCOUNT_ID
  from      ACCOUNTS_CONTACTS
 inner join CHAT_CHANNELS
         on CHAT_CHANNELS.PARENT_ID       = ACCOUNTS_CONTACTS.CONTACT_ID
        and CHAT_CHANNELS.PARENT_TYPE     = N'Contacts'
        and CHAT_CHANNELS.DELETED         = 0
 inner join CHAT_MESSAGES
         on CHAT_MESSAGES.CHAT_CHANNEL_ID = CHAT_CHANNELS.ID
        and CHAT_MESSAGES.DELETED         = 0
 where ACCOUNTS_CONTACTS.DELETED = 0
union
select CHAT_MESSAGES.ID
     , LEADS.ACCOUNT_ID
  from      LEADS
 inner join CHAT_MESSAGES
         on CHAT_MESSAGES.PARENT_ID   = LEADS.ID
        and CHAT_MESSAGES.PARENT_TYPE = N'Leads'
        and CHAT_MESSAGES.DELETED     = 0
 where LEADS.DELETED = 0
union
select CHAT_MESSAGES.ID
     , LEADS.ACCOUNT_ID
  from      LEADS
 inner join CHAT_CHANNELS
         on CHAT_CHANNELS.PARENT_ID       = LEADS.ID
        and CHAT_CHANNELS.PARENT_TYPE     = N'Leads'
        and CHAT_CHANNELS.DELETED         = 0
 inner join CHAT_MESSAGES
         on CHAT_MESSAGES.CHAT_CHANNEL_ID = CHAT_CHANNELS.ID
        and CHAT_MESSAGES.DELETED         = 0
 where LEADS.DELETED = 0

GO

Grant Select on dbo.vwCHAT_MESSAGES_RELATED_ACCOUNTS to public;
GO

