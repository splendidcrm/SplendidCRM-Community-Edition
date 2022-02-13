if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCAMPAIGN_LOG_TrackClickThru')
	Drop View dbo.vwCAMPAIGN_LOG_TrackClickThru;
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
-- 03/18/2010 Paul.  The default behavior of vwCAMPAIGN_LOG_List is to join related to EMAILS. 
-- When we track a ClickThru, we want the related to be the tracker. 
Create View dbo.vwCAMPAIGN_LOG_TrackClickThru
as
select vwCAMPAIGN_LOG_List.RECIPIENT_NAME
     , vwCAMPAIGN_LOG_List.RECIPIENT_EMAIL
     , vwCAMPAIGN_LOG_List.ID
     , vwCAMPAIGN_LOG_List.TARGET_TRACKER_KEY
     , vwCAMPAIGN_LOG_List.TARGET_ID
     , vwCAMPAIGN_LOG_List.TARGET_TYPE
     , vwCAMPAIGN_LOG_List.ACTIVITY_TYPE
     , vwCAMPAIGN_LOG_List.ACTIVITY_DATE
     , vwCAMPAIGN_LOG_List.RELATED_ID
     , vwCAMPAIGN_LOG_List.RELATED_TYPE
     , vwCAMPAIGN_LOG_List.ARCHIVED
     , vwCAMPAIGN_LOG_List.HITS
     , vwCAMPAIGN_LOG_List.MORE_INFORMATION
     , vwCAMPAIGN_LOG_List.CAMPAIGN_ID
     , vwCAMPAIGN_LOG_List.CAMPAIGN_NAME
     , vwCAMPAIGN_LOG_List.EMAIL_MARKETING_ID
     , vwCAMPAIGN_LOG_List.EMAIL_MARKETING_NAME
     , vwCAMPAIGN_LOG_List.PROSPECT_LIST_ID
     , vwCAMPAIGN_LOG_List.PROSPECT_LIST_NAME
     , vwCAMPAIGN_LOG_List.RELATED_NAME
     , CAMPAIGN_TRKRS.ID            as TRACKER_ID
     , CAMPAIGN_TRKRS.TRACKER_NAME
     , CAMPAIGN_TRKRS.TRACKER_URL
     , CAMPAIGN_TRKRS.TRACKER_KEY
     , CAMPAIGN_TRKRS.IS_OPTOUT
     , CAMPAIGN_TRKRS_CSTM.*
  from            vwCAMPAIGN_LOG_List
  left outer join CAMPAIGN_TRKRS
               on CAMPAIGN_TRKRS.ID                = vwCAMPAIGN_LOG_List.RELATED_ID
              and CAMPAIGN_TRKRS.DELETED           = 0
              and vwCAMPAIGN_LOG_List.RELATED_TYPE = N'CampaignTrackers'
  left outer join CAMPAIGN_TRKRS_CSTM
               on CAMPAIGN_TRKRS_CSTM.ID_C         = CAMPAIGN_TRKRS.ID
 where vwCAMPAIGN_LOG_List.ACTIVITY_TYPE = N'link'

GO

Grant Select on dbo.vwCAMPAIGN_LOG_TrackClickThru to public;
GO

