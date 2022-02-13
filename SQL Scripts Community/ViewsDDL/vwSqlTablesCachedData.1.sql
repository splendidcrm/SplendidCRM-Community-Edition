if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSqlTablesCachedData')
	Drop View dbo.vwSqlTablesCachedData;
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
-- 03/09/2016 Paul.  Change from terminology payment_types_dom to PaymentTypes list for QuickBooks Online. 
Create View dbo.vwSqlTablesCachedData
as
select TABLE_NAME
  from vwSqlTables
 where TABLE_NAME in
( N'CONTRACT_TYPES'
, N'CURRENCIES'
, N'FORUM_TOPICS'
, N'FORUMS'
, N'INBOUND_EMAILS'
, N'MANUFACTURERS'
, N'PRODUCT_CATEGORIES'
, N'PRODUCT_TYPES'
, N'RELEASES'
, N'SHIPPERS'
, N'TAX_RATES'
, N'TEAMS'
, N'USERS'
, N'PAYMENT_TYPES'
, N'PAYMENT_TERMS'
)
GO


Grant Select on dbo.vwSqlTablesCachedData to public;
GO

