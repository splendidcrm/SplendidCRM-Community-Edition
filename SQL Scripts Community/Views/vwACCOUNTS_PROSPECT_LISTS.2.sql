if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACCOUNTS_PROSPECT_LISTS')
	Drop View dbo.vwACCOUNTS_PROSPECT_LISTS;
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
Create View dbo.vwACCOUNTS_PROSPECT_LISTS
as
select ACCOUNTS.ID                  as ACCOUNT_ID
     , ACCOUNTS.NAME                as ACCOUNT_NAME
     , ACCOUNTS.ASSIGNED_USER_ID    as ACCOUNT_ASSIGNED_USER_ID
     , ACCOUNTS.ASSIGNED_SET_ID     as ACCOUNT_ASSIGNED_SET_ID
     , vwPROSPECT_LISTS.ID          as PROSPECT_LIST_ID
     , vwPROSPECT_LISTS.NAME        as PROSPECT_LIST_NAME
     , vwPROSPECT_LISTS.*
     , (select count(*)
          from PROSPECT_LISTS_PROSPECTS
         where PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID = vwPROSPECT_LISTS.ID
           and PROSPECT_LISTS_PROSPECTS.DELETED          = 0
       ) as ENTRIES
  from            ACCOUNTS
       inner join PROSPECT_LISTS_PROSPECTS
               on PROSPECT_LISTS_PROSPECTS.RELATED_ID   = ACCOUNTS.ID
              and PROSPECT_LISTS_PROSPECTS.RELATED_TYPE = N'Accounts'
              and PROSPECT_LISTS_PROSPECTS.DELETED      = 0
       inner join vwPROSPECT_LISTS
               on vwPROSPECT_LISTS.ID                   = PROSPECT_LISTS_PROSPECTS.PROSPECT_LIST_ID
 where ACCOUNTS.DELETED = 0

GO

Grant Select on dbo.vwACCOUNTS_PROSPECT_LISTS to public;
GO

