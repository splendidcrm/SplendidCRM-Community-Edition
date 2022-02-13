if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwLEADS_ConvertOpportunity')
	Drop View dbo.vwLEADS_ConvertOpportunity;
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
Create View dbo.vwLEADS_ConvertOpportunity
as
select cast(null as nvarchar(150))    as NAME
     , cast(null as nvarchar(255))    as OPPORTUNITY_TYPE
     , cast(null as money)            as AMOUNT
     , cast(null as nvarchar(25))     as AMOUNT_BACKUP
     , cast(null as money)            as AMOUNT_USDOLLAR
     , cast(null as uniqueidentifier) as CURRENCY_ID
     , cast(null as datetime)         as DATE_CLOSED
     , cast(null as nvarchar(100))    as NEXT_STEP
     , cast(null as nvarchar(25))     as SALES_STAGE
     , cast(null as float)            as PROBABILITY
     , cast(null as nvarchar(150))    as CAMPAIGN_NAME
     , cast(null as uniqueidentifier) as CAMPAIGN_ASSIGNED_USER_ID
     , cast(null as uniqueidentifier) as CAMPAIGN_ASSIGNED_SET_ID
     , cast(null as uniqueidentifier) as ACCOUNT_ID
     , cast(null as uniqueidentifier) as ACCOUNT_ASSIGNED_USER_ID
     , cast(null as uniqueidentifier) as ACCOUNT_ASSIGNED_SET_ID
     , cast(null as uniqueidentifier) as B2C_CONTACT_ID
     , cast(null as nvarchar(150))    as B2C_CONTACT_NAME
     , cast(null as uniqueidentifier) as B2C_CONTACT_ASSIGNED_USER_ID
     , cast(null as uniqueidentifier) as B2C_CONTACT_ASSIGNED_SET_ID
     , vwLEADS_Convert.*
  from vwLEADS_Convert

GO

Grant Select on dbo.vwLEADS_ConvertOpportunity to public;
GO


