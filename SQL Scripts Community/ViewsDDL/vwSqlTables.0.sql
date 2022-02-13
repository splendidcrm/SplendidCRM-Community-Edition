if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSqlTables')
	Drop View dbo.vwSqlTables;
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
-- 01/16/2008 Paul.  Simplify conversion to Oracle. 
-- 09/12/2008 Paul.  We need to exclude system tables, such as sysdiagrams. 
-- 09/22/2016 Paul.  Manually specify default collation to ease migration to Azure
Create View dbo.vwSqlTables
as
select TABLE_NAME  collate database_default  as TABLE_NAME
  from INFORMATION_SCHEMA.TABLES
 where TABLE_TYPE = N'BASE TABLE'
   and TABLE_NAME not in (N'dtproperties', N'sysdiagrams')
GO


Grant Select on dbo.vwSqlTables to public;
GO

