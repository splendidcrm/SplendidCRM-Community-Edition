if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCALL_MARKETING_PROSPECT_LST')
	Drop View dbo.vwCALL_MARKETING_PROSPECT_LST;
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
Create View dbo.vwCALL_MARKETING_PROSPECT_LST
as
select cast(null as uniqueidentifier)    as LIST_ID
     , CALL_MARKETING.ID                 as CALL_MARKETING_ID
     , CALL_MARKETING.NAME               as CALL_MARKETING_NAME
     , CAMPAIGNS.ID                      as CAMPAIGN_ID
     , CAMPAIGNS.ASSIGNED_USER_ID        as CAMPAIGN_ASSIGNED_USER_ID
     , CAMPAIGNS.ASSIGNED_SET_ID         as CAMPAIGN_ASSIGNED_SET_ID
     , vwPROSPECT_LISTS.ID               as PROSPECT_LIST_ID
     , vwPROSPECT_LISTS.NAME             as PROSPECT_LIST_NAME
     , vwPROSPECT_LISTS.*
     , (select count(*)
          from PROSPECT_LISTS_PROSPECTS
         where PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = vwPROSPECT_LISTS.ID
           and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       ) as ENTRIES
  from            CALL_MARKETING
  left outer join CAMPAIGNS
               on CAMPAIGNS.ID                        = CALL_MARKETING.CAMPAIGN_ID
              and CAMPAIGNS.DELETED                   = 0
  left outer join PROSPECT_LIST_CAMPAIGNS
               on PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID = CAMPAIGNS.ID
              and PROSPECT_LIST_CAMPAIGNS.DELETED     = 0
  left outer join vwPROSPECT_LISTS
               on vwPROSPECT_LISTS.ID                 = PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID
 where CALL_MARKETING.DELETED = 0
   and CALL_MARKETING.ALL_PROSPECT_LISTS = 1
union all
select CALL_MARKETING_PROSPECT_LISTS.ID  as LIST_ID
     , CALL_MARKETING.ID                 as CALL_MARKETING_ID
     , CALL_MARKETING.NAME               as CALL_MARKETING_NAME
     , CAMPAIGNS.ID                      as CAMPAIGN_ID
     , CAMPAIGNS.ASSIGNED_USER_ID        as CAMPAIGN_ASSIGNED_USER_ID
     , CAMPAIGNS.ASSIGNED_SET_ID         as CAMPAIGN_ASSIGNED_SET_ID
     , vwPROSPECT_LISTS.ID               as PROSPECT_LIST_ID
     , vwPROSPECT_LISTS.NAME             as PROSPECT_LIST_NAME
     , vwPROSPECT_LISTS.*
     , (select count(*)
          from PROSPECT_LISTS_PROSPECTS
         where PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = vwPROSPECT_LISTS.ID
           and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       ) as ENTRIES
  from            CALL_MARKETING
  left outer join CALL_MARKETING_PROSPECT_LISTS
               on CALL_MARKETING_PROSPECT_LISTS.CALL_MARKETING_ID = CALL_MARKETING.ID
              and CALL_MARKETING_PROSPECT_LISTS.DELETED            = 0
  left outer join CAMPAIGNS
               on CAMPAIGNS.ID                        = CALL_MARKETING.CAMPAIGN_ID
              and CAMPAIGNS.DELETED                   = 0
  left outer join vwPROSPECT_LISTS
               on vwPROSPECT_LISTS.ID                 = CALL_MARKETING_PROSPECT_LISTS.PROSPECT_LIST_ID
 where CALL_MARKETING.DELETED = 0
   and isnull(CALL_MARKETING.ALL_PROSPECT_LISTS, 0) = 0

GO

Grant Select on dbo.vwCALL_MARKETING_PROSPECT_LST to public;
GO

