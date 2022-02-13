if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROSPECT_LISTS_ExemptPhones')
	Drop View dbo.vwPROSPECT_LISTS_ExemptPhones;
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
Create View dbo.vwPROSPECT_LISTS_ExemptPhones
as
select PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID
     , vwPROSPECT_LISTS_Phones.ID
     , vwPROSPECT_LISTS_Phones.NAME
     , vwPROSPECT_LISTS_Phones.RELATED_TYPE
     , vwPROSPECT_LISTS_Phones.RELATED_ID
     , vwPROSPECT_LISTS_Phones.RELATED_NAME
     , vwPROSPECT_LISTS_Phones.PHONE_WORK
  from      PROSPECT_LIST_CAMPAIGNS
 inner join vwPROSPECT_LISTS_Phones
         on vwPROSPECT_LISTS_Phones.ID             = PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID
        and vwPROSPECT_LISTS_Phones.LIST_TYPE      = N'exempt'
 where PROSPECT_LIST_CAMPAIGNS.DELETED = 0
union
select PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID
     , vwPROSPECT_LISTS_Phones.ID
     , vwPROSPECT_LISTS_Phones.NAME
     , PROSPECT_LISTS_Default.RELATED_TYPE
     , PROSPECT_LISTS_Default.RELATED_ID
     , PROSPECT_LISTS_Default.RELATED_NAME
     , PROSPECT_LISTS_Default.PHONE_WORK
  from      PROSPECT_LIST_CAMPAIGNS
 inner join vwPROSPECT_LISTS_Phones
         on vwPROSPECT_LISTS_Phones.ID             = PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID
        and vwPROSPECT_LISTS_Phones.LIST_TYPE      = N'exempt_address'
 inner join vwPROSPECT_LISTS_Phones                  PROSPECT_LISTS_Default
         on lower(PROSPECT_LISTS_Default.PHONE_WORK) = lower(vwPROSPECT_LISTS_Phones.PHONE_WORK)
        and PROSPECT_LISTS_Default.LIST_TYPE    in (N'default', N'seed')
 where PROSPECT_LIST_CAMPAIGNS.DELETED = 0
union
select PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID
     , vwPROSPECT_LISTS.ID
     , vwPROSPECT_LISTS.NAME
     , PROSPECT_LISTS_Default.RELATED_TYPE
     , PROSPECT_LISTS_Default.RELATED_ID
     , PROSPECT_LISTS_Default.RELATED_NAME
     , PROSPECT_LISTS_Default.PHONE_WORK
  from      PROSPECT_LIST_CAMPAIGNS
 inner join vwPROSPECT_LISTS
         on vwPROSPECT_LISTS.ID                    = PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID
        and vwPROSPECT_LISTS.LIST_TYPE             = N'exempt_domain'
        and vwPROSPECT_LISTS.DOMAIN_NAME is not null
 inner join vwPROSPECT_LISTS_Phones                  PROSPECT_LISTS_Default
         on lower(PROSPECT_LISTS_Default.PHONE_WORK) like lower(vwPROSPECT_LISTS.DOMAIN_NAME) + '%'
        and PROSPECT_LISTS_Default.LIST_TYPE    in (N'default', N'seed')
 where PROSPECT_LIST_CAMPAIGNS.DELETED = 0
GO

Grant Select on dbo.vwPROSPECT_LISTS_ExemptPhones to public;
GO


