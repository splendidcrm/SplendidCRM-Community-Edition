if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSMS_MESSAGES_RELATED_CONTACTS')
	Drop View dbo.vwSMS_MESSAGES_RELATED_CONTACTS;
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
Create View dbo.vwSMS_MESSAGES_RELATED_CONTACTS
as
select ID
     , TO_ID      as CONTACT_ID
  from SMS_MESSAGES
 where TO_ID      is not null
   and DELETED    = 0
union
select ID
     , PARENT_ID as CONTACT_ID
  from SMS_MESSAGES
 where PARENT_ID   is not null
   and PARENT_TYPE = N'Contacts'
   and DELETED     = 0
union
select SMS_MESSAGES.ID
     , LEADS.CONTACT_ID
  from      LEADS
 inner join SMS_MESSAGES
         on SMS_MESSAGES.PARENT_ID   = LEADS.ID
        and SMS_MESSAGES.PARENT_TYPE = N'Leads'
        and SMS_MESSAGES.DELETED     = 0
 where LEADS.DELETED = 0
   and LEADS.CONTACT_ID is not null
union
select SMS_MESSAGES.ID
     , LEADS_CONTACTS.CONTACT_ID
  from      LEADS_CONTACTS
 inner join SMS_MESSAGES
         on SMS_MESSAGES.PARENT_ID   = LEADS_CONTACTS.LEAD_ID
        and SMS_MESSAGES.PARENT_TYPE = N'Leads'
        and SMS_MESSAGES.DELETED     = 0
 where LEADS_CONTACTS.DELETED = 0
union
select SMS_MESSAGES.ID
     , LEADS.CONTACT_ID
  from      LEADS
 inner join PROSPECTS
         on PROSPECTS.LEAD_ID = LEADS.ID
        and PROSPECTS.DELETED = 0
 inner join SMS_MESSAGES
         on SMS_MESSAGES.PARENT_ID   = PROSPECTS.ID
        and SMS_MESSAGES.PARENT_TYPE = N'Prospects'
        and SMS_MESSAGES.DELETED     = 0
 where LEADS.DELETED = 0
   and LEADS.CONTACT_ID is not null
union
select SMS_MESSAGES.ID
     , LEADS_CONTACTS.CONTACT_ID
  from      LEADS_CONTACTS
 inner join PROSPECTS
         on PROSPECTS.LEAD_ID = LEADS_CONTACTS.LEAD_ID
        and PROSPECTS.DELETED = 0
 inner join SMS_MESSAGES
         on SMS_MESSAGES.PARENT_ID   = PROSPECTS.ID
        and SMS_MESSAGES.PARENT_TYPE = N'Prospects'
        and SMS_MESSAGES.DELETED     = 0
 where LEADS_CONTACTS.DELETED = 0

GO

Grant Select on dbo.vwSMS_MESSAGES_RELATED_CONTACTS to public;
GO

