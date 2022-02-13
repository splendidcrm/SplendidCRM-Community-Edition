if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCAMPAIGNS_PROSPECT_LISTS')
	Drop View dbo.vwCAMPAIGNS_PROSPECT_LISTS;
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
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwCAMPAIGNS_PROSPECT_LISTS
as
select CAMPAIGNS.ID               as CAMPAIGN_ID
     , CAMPAIGNS.NAME             as CAMPAIGN_NAME
     , CAMPAIGNS.ASSIGNED_USER_ID as CAMPAIGN_ASSIGNED_USER_ID
     , CAMPAIGNS.ASSIGNED_SET_ID  as CAMPAIGN_ASSIGNED_SET_ID
     , vwPROSPECT_LISTS.ID        as PROSPECT_LIST_ID
     , vwPROSPECT_LISTS.NAME      as PROSPECT_LIST_NAME
     , vwPROSPECT_LISTS.*
     , (select count(*)
          from PROSPECT_LISTS_PROSPECTS
         where PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = vwPROSPECT_LISTS.ID
           and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       ) as ENTRIES
  from            CAMPAIGNS
       inner join PROSPECT_LIST_CAMPAIGNS
               on PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID = CAMPAIGNS.ID
              and PROSPECT_LIST_CAMPAIGNS.DELETED     = 0
       inner join vwPROSPECT_LISTS
               on vwPROSPECT_LISTS.ID                 = PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID
 where CAMPAIGNS.DELETED = 0

GO

Grant Select on dbo.vwCAMPAIGNS_PROSPECT_LISTS to public;
GO

