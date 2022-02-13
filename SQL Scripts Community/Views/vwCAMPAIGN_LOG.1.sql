if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCAMPAIGN_LOG')
	Drop View dbo.vwCAMPAIGN_LOG;
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
Create View dbo.vwCAMPAIGN_LOG
as
select CAMPAIGN_LOG.ID
     , CAMPAIGN_LOG.TARGET_TRACKER_KEY
     , CAMPAIGN_LOG.TARGET_ID
     , CAMPAIGN_LOG.TARGET_TYPE             -- Contacts, Leads, Prospects, Users. 
     , CAMPAIGN_LOG.ACTIVITY_TYPE
     , CAMPAIGN_LOG.ACTIVITY_DATE
     , CAMPAIGN_LOG.RELATED_ID
     , CAMPAIGN_LOG.RELATED_TYPE            -- Emails. 
     , CAMPAIGN_LOG.ARCHIVED
     , CAMPAIGN_LOG.HITS
     , CAMPAIGN_LOG.MORE_INFORMATION
     , CAMPAIGNS.ID                as CAMPAIGN_ID
     , CAMPAIGNS.NAME              as CAMPAIGN_NAME
     , EMAIL_MARKETING.ID          as EMAIL_MARKETING_ID
     , EMAIL_MARKETING.NAME        as EMAIL_MARKETING_NAME
     , PROSPECT_LISTS.ID           as PROSPECT_LIST_ID
     , PROSPECT_LISTS.NAME         as PROSPECT_LIST_NAME
     , EMAILS.NAME                 as RELATED_NAME
  from            CAMPAIGN_LOG
  left outer join CAMPAIGNS
               on CAMPAIGNS.ID            = CAMPAIGN_LOG.CAMPAIGN_ID
              and CAMPAIGNS.DELETED       = 0
  left outer join EMAIL_MARKETING
               on EMAIL_MARKETING.ID      = CAMPAIGN_LOG.MARKETING_ID
              and EMAIL_MARKETING.DELETED = 0
  left outer join PROSPECT_LISTS
               on PROSPECT_LISTS.ID       = CAMPAIGN_LOG.LIST_ID
              and PROSPECT_LISTS.DELETED  = 0
  left outer join EMAILS
               on EMAILS.ID               = CAMPAIGN_LOG.RELATED_ID
              and EMAILS.DELETED          = 0
 where CAMPAIGN_LOG.DELETED = 0

GO

Grant Select on dbo.vwCAMPAIGN_LOG to public;
GO

