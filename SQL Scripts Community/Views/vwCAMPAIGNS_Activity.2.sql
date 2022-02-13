if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCAMPAIGNS_Activity')
	Drop View dbo.vwCAMPAIGNS_Activity;
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
-- 12/25/2007 Paul.  We need a union to capture all activities that are not defined in the list. 
-- 08/30/2009 Paul.  Dynamic teams required an ID and TEAM_SET_ID. 
Create View dbo.vwCAMPAIGNS_Activity
as
select CAMPAIGNS.ID
     , CAMPAIGNS.ASSIGNED_USER_ID
     , CAMPAIGNS.TEAM_ID
     , CAMPAIGNS.TEAM_SET_ID
     , CAMPAIGN_LOG.ID               as CAMPAIGN_LOG_ID
     , CAMPAIGN_LOG.ACTIVITY_TYPE
     , CAMPAIGN_LOG.TARGET_TYPE
     , TERMINOLOGY.LIST_ORDER
  from            CAMPAIGNS
       inner join CAMPAIGN_LOG
               on CAMPAIGN_LOG.CAMPAIGN_ID = CAMPAIGNS.ID
              and CAMPAIGN_LOG.ARCHIVED    = 0
              and CAMPAIGN_LOG.DELETED     = 0
       inner join TERMINOLOGY
               on TERMINOLOGY.NAME         = CAMPAIGN_LOG.ACTIVITY_TYPE
              and TERMINOLOGY.LIST_NAME    = N'campainglog_activity_type_dom'
              and TERMINOLOGY.LANG         = N'en-US'
              and TERMINOLOGY.DELETED      = 0
union all
select CAMPAIGNS.ID
     , CAMPAIGNS.ASSIGNED_USER_ID
     , CAMPAIGNS.TEAM_ID
     , CAMPAIGNS.TEAM_SET_ID
     , CAMPAIGN_LOG.ID               as CAMPAIGN_LOG_ID
     , CAMPAIGN_LOG.ACTIVITY_TYPE
     , CAMPAIGN_LOG.TARGET_TYPE
     , cast(0 as int)                as LIST_ORDER
  from            CAMPAIGNS
       inner join CAMPAIGN_LOG
               on CAMPAIGN_LOG.CAMPAIGN_ID = CAMPAIGNS.ID
              and CAMPAIGN_LOG.ARCHIVED    = 0
              and CAMPAIGN_LOG.DELETED     = 0
  left outer join TERMINOLOGY
               on TERMINOLOGY.NAME         = CAMPAIGN_LOG.ACTIVITY_TYPE
              and TERMINOLOGY.LIST_NAME    = N'campainglog_activity_type_dom'
              and TERMINOLOGY.LANG         = N'en-US'
              and TERMINOLOGY.DELETED      = 0
 where TERMINOLOGY.ID is null


GO

Grant Select on dbo.vwCAMPAIGNS_Activity to public;
GO


