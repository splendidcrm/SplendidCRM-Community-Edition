if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwLEADS_ConvertAccount')
	Drop View dbo.vwLEADS_ConvertAccount;
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
Create View dbo.vwLEADS_ConvertAccount
as
select cast(null as nvarchar(30))     as ACCOUNT_NUMBER
     , ACCOUNT_NAME                   as NAME
     , PHONE_WORK                     as PHONE_OFFICE
     , PHONE_OTHER                    as PHONE_ALTERNATE
     , cast(null as nvarchar(25))     as ANNUAL_REVENUE
     , cast(null as nvarchar(10))     as EMPLOYEES
     , cast(null as nvarchar(25))     as INDUSTRY
     , cast(null as nvarchar(100))    as OWNERSHIP
     , cast(null as nvarchar(25))     as ACCOUNT_TYPE
     , cast(null as nvarchar(10))     as TICKER_SYMBOL
     , cast(null as nvarchar(25))     as RATING
     , cast(null as nvarchar(10))     as SIC_CODE
     , cast(null as uniqueidentifier) as PARENT_ID
     , cast(null as nvarchar(150))    as PARENT_NAME
     , cast(null as uniqueidentifier) as PARENT_ASSIGNED_USER_ID
     , cast(null as uniqueidentifier) as PARENT_ASSIGNED_SET_ID
     , vwLEADS_Convert.*
  from vwLEADS_Convert

GO

Grant Select on dbo.vwLEADS_ConvertAccount to public;
GO

