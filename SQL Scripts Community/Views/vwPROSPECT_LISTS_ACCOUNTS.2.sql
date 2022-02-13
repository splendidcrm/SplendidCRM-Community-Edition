if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROSPECT_LISTS_ACCOUNTS')
	Drop View dbo.vwPROSPECT_LISTS_ACCOUNTS;
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
Create View dbo.vwPROSPECT_LISTS_ACCOUNTS
as
select PROSPECT_LISTS.ID               as PROSPECT_LIST_ID
     , PROSPECT_LISTS.NAME             as PROSPECT_LIST_NAME
     , PROSPECT_LISTS.ASSIGNED_USER_ID as PROSPECT_ASSIGNED_USER_ID
     , PROSPECT_LISTS.ASSIGNED_SET_ID  as PROSPECT_ASSIGNED_SET_ID
     , PROSPECT_LISTS.DYNAMIC_LIST     as PROSPECT_DYNAMIC_LIST
     , vwACCOUNTS.ID                   as ACCOUNT_ID
     , vwACCOUNTS.NAME                 as ACCOUNT_NAME
     , vwACCOUNTS.*
  from            PROSPECT_LISTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = PROSPECT_LISTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE     = N'Accounts'
              and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       inner join vwACCOUNTS
               on vwACCOUNTS.ID                             = PROSPECT_LISTS_PROSPECTS.RELATED_ID
 where PROSPECT_LISTS.DELETED = 0

GO

Grant Select on dbo.vwPROSPECT_LISTS_ACCOUNTS to public;
GO

