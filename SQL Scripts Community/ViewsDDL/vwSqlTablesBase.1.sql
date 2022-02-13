if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSqlTablesBase')
	Drop View dbo.vwSqlTablesBase;
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
-- 05/01/2009 Paul.  We need to isolate tables that are non CRM tables. 
-- 09/08/2009 Paul.  Azura requires the use of aliases when dealing with INFORMATION_SCHEMA. 
-- 09/22/2016 Paul.  Manually specify default collation to ease migration to Azure
Create View dbo.vwSqlTablesBase
as
select TABLES.TABLE_NAME  collate database_default  as TABLE_NAME
  from      INFORMATION_SCHEMA.TABLES   TABLES
 inner join INFORMATION_SCHEMA.COLUMNS  COLUMNS
         on COLUMNS.TABLE_NAME        = TABLES.TABLE_NAME
 where TABLES.TABLE_TYPE = N'BASE TABLE'
   and TABLES.TABLE_NAME   not in (N'dtproperties', N'sysdiagrams')
   and COLUMNS.COLUMN_NAME in (N'ID', N'ID_C')
   and COLUMNS.DATA_TYPE   = N'uniqueidentifier'
GO


Grant Select on dbo.vwSqlTablesBase to public;
GO

