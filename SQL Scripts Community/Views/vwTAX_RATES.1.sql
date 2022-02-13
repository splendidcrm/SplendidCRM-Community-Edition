if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwTAX_RATES')
	Drop View dbo.vwTAX_RATES;
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
-- 05/13/2012 Paul.  DATE_MODIFIED is needed for sync with QuickBooks. 
-- 06/02/2012 Paul.  Tax Vendor is required to create a QuickBooks tax rate. 
-- 02/24/2015 Paul.  Add state for lookup. 
-- 04/07/2016 Paul.  Tax rates per team. 
Create View dbo.vwTAX_RATES
as
select TAX_RATES.ID
     , TAX_RATES.NAME
     , TAX_RATES.STATUS
     , TAX_RATES.VALUE
     , TAX_RATES.LIST_ORDER
     , TAX_RATES.DATE_MODIFIED
     , TAX_RATES.DATE_MODIFIED_UTC
     , TAX_RATES.QUICKBOOKS_TAX_VENDOR
     , TAX_RATES.DESCRIPTION
     , TAX_RATES.ADDRESS_STATE
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
  from            TAX_RATES
  left outer join TEAMS
               on TEAMS.ID                 = TAX_RATES.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = TAX_RATES.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
 where TAX_RATES.DELETED = 0

GO

Grant Select on dbo.vwTAX_RATES to public;
GO

 
