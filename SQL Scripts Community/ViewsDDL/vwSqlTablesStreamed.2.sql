if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSqlTablesStreamed')
	Drop View dbo.vwSqlTablesStreamed;
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
-- 08/22/2017 Paul.  Manually specify default collation to ease migration to Azure
-- 06/25/2018 Paul.  Data Privacy is not streamed. 
-- 05/24/2020 Paul.  Exclude Azure tables. 
Create View dbo.vwSqlTablesStreamed
as
select TABLE_NAME
  from vwSqlTables
 where exists(select * from vwSqlTables AUDIT_TABLES where AUDIT_TABLES.TABLE_NAME = vwSqlTables.TABLE_NAME + N'_AUDIT')
   and exists(select * from vwSqlTables CSTM_TABLES  where CSTM_TABLES.TABLE_NAME  = vwSqlTables.TABLE_NAME + N'_CSTM')
   and exists(select * from INFORMATION_SCHEMA.COLUMNS vwSqlColumns  where vwSqlColumns.TABLE_NAME = vwSqlTables.TABLE_NAME collate database_default and vwSqlColumns.COLUMN_NAME = 'ASSIGNED_USER_ID')
   and TABLE_NAME not like 'AZURE[_]%'
   and TABLE_NAME not in
( N'CALLS'
, N'DATA_PRIVACY'
, N'MEETINGS'
, N'EMAILS'
, N'TASKS'
, N'NOTES'
, N'SMS_MESSAGES'
, N'TWITTER_MESSAGES'
, N'CALL_MARKETING'
, N'PROJECT'
, N'PROJECT_TASK'
, N'PRODUCT_TEMPLATES'
, N'INVOICES_LINE_ITEMS'
, N'ORDERS_LINE_ITEMS'
, N'QUOTES_LINE_ITEMS'
, N'REVENUE_LINE_ITEMS'
, N'PAYMENTS'
, N'CREDIT_CARDS'
, N'REGIONS'
, N'SURVEY_QUESTIONS'
, N'TEST_CASES'
, N'TEST_PLANS'
, N'THREADS'
, N'USERS'
)
GO


Grant Select on dbo.vwSqlTablesStreamed to public;
GO

-- select * from vwSqlTablesStreamed order by 1;

