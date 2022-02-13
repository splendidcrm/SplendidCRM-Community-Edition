if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAILS_RELATED_LEADS')
	Drop View dbo.vwEMAILS_RELATED_LEADS;
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
Create View dbo.vwEMAILS_RELATED_LEADS
as
select ID
     , PARENT_ID as LEAD_ID
  from EMAILS
 where PARENT_ID   is not null
   and PARENT_TYPE = N'Leads'
   and DELETED     = 0
union
select EMAILS.ID
     , PROSPECTS.LEAD_ID
  from      PROSPECTS
 inner join EMAILS
         on EMAILS.PARENT_ID   = PROSPECTS.ID
        and EMAILS.PARENT_TYPE = N'Prospects'
        and EMAILS.DELETED     = 0
 where PROSPECTS.DELETED = 0
   and PROSPECTS.LEAD_ID is not null
union
select EMAIL_ID
     , LEAD_ID
  from EMAILS_LEADS
 where DELETED    = 0
union
select EMAIL_ID
     , PROSPECTS.LEAD_ID
  from      PROSPECTS
 inner join EMAILS_PROSPECTS
         on EMAILS_PROSPECTS.PROSPECT_ID = PROSPECTS.ID
        and EMAILS_PROSPECTS.DELETED = 0
 where PROSPECTS.DELETED     = 0

GO

Grant Select on dbo.vwEMAILS_RELATED_LEADS to public;
GO

