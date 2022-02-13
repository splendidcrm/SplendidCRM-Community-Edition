if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCAMPAIGNS_PROSPECT_LIST_Call')
	Drop View dbo.vwCAMPAIGNS_PROSPECT_LIST_Call;
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
Create View dbo.vwCAMPAIGNS_PROSPECT_LIST_Call
as
select PROSPECT_LISTS.ID                                 as PROSPECT_LIST_ID
     , PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID               as CAMPAIGN_ID
     , cast(null as uniqueidentifier)                    as CALL_MARKETING_ID
     , cast(1 as bit)                                    as ALL_PROSPECT_LISTS
  from      PROSPECT_LIST_CAMPAIGNS
 inner join PROSPECT_LISTS
         on PROSPECT_LISTS.ID         = PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID
        and PROSPECT_LISTS.DELETED    = 0
        and PROSPECT_LISTS.LIST_TYPE in (N'default', N'seed')
 where PROSPECT_LIST_CAMPAIGNS.DELETED = 0
union all
select PROSPECT_LISTS.ID                                 as PROSPECT_LIST_ID
     , cast(null as uniqueidentifier)                    as CAMPAIGN_ID
     , CALL_MARKETING_PROSPECT_LISTS.CALL_MARKETING_ID   as CALL_MARKETING_ID
     , cast(0 as bit)                                    as ALL_PROSPECT_LISTS
  from      CALL_MARKETING_PROSPECT_LISTS
 inner join PROSPECT_LISTS
         on PROSPECT_LISTS.ID         = CALL_MARKETING_PROSPECT_LISTS.PROSPECT_LIST_ID
        and PROSPECT_LISTS.DELETED    = 0
        and PROSPECT_LISTS.LIST_TYPE in (N'default', N'seed')
 where CALL_MARKETING_PROSPECT_LISTS.DELETED = 0
GO

Grant Select on dbo.vwCAMPAIGNS_PROSPECT_LIST_Call to public;
GO


