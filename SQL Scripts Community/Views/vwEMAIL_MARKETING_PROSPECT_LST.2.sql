if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAIL_MARKETING_PROSPECT_LST')
	Drop View dbo.vwEMAIL_MARKETING_PROSPECT_LST;
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
-- 12/15/2007 Paul.  ALL_PROSPECT_LISTS is used to determine if we join to the EMAIL_MARKETING_PROSPECT_LISTS table. 
-- 09/01/2009 Paul.  Alow the display of email marketing even if campaign record has been deleted. 
-- 09/01/2009 Paul.  The join to EMAIL_MARKETING_PROSPECT_LISTS should not have included PROSPECT_LIST_CAMPAIGNS. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwEMAIL_MARKETING_PROSPECT_LST
as
select cast(null as uniqueidentifier)    as LIST_ID
     , EMAIL_MARKETING.ID                as EMAIL_MARKETING_ID
     , EMAIL_MARKETING.NAME              as EMAIL_MARKETING_NAME
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
  from            EMAIL_MARKETING
  left outer join CAMPAIGNS
               on CAMPAIGNS.ID                        = EMAIL_MARKETING.CAMPAIGN_ID
              and CAMPAIGNS.DELETED                   = 0
  left outer join PROSPECT_LIST_CAMPAIGNS
               on PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID = CAMPAIGNS.ID
              and PROSPECT_LIST_CAMPAIGNS.DELETED     = 0
  left outer join vwPROSPECT_LISTS
               on vwPROSPECT_LISTS.ID                 = PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID
 where EMAIL_MARKETING.DELETED = 0
   and EMAIL_MARKETING.ALL_PROSPECT_LISTS = 1
union all
select EMAIL_MARKETING_PROSPECT_LISTS.ID as LIST_ID
     , EMAIL_MARKETING.ID                as EMAIL_MARKETING_ID
     , EMAIL_MARKETING.NAME              as EMAIL_MARKETING_NAME
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
  from            EMAIL_MARKETING
  left outer join EMAIL_MARKETING_PROSPECT_LISTS
               on EMAIL_MARKETING_PROSPECT_LISTS.EMAIL_MARKETING_ID = EMAIL_MARKETING.ID
              and EMAIL_MARKETING_PROSPECT_LISTS.DELETED            = 0
  left outer join CAMPAIGNS
               on CAMPAIGNS.ID                        = EMAIL_MARKETING.CAMPAIGN_ID
              and CAMPAIGNS.DELETED                   = 0
  left outer join vwPROSPECT_LISTS
               on vwPROSPECT_LISTS.ID                 = EMAIL_MARKETING_PROSPECT_LISTS.PROSPECT_LIST_ID
 where EMAIL_MARKETING.DELETED = 0
   and isnull(EMAIL_MARKETING.ALL_PROSPECT_LISTS, 0) = 0

GO

Grant Select on dbo.vwEMAIL_MARKETING_PROSPECT_LST to public;
GO

