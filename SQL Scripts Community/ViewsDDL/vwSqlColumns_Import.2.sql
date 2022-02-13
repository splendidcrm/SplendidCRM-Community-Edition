if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSqlColumns_Import')
	Drop View dbo.vwSqlColumns_Import;
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
Create View dbo.vwSqlColumns_Import
as
select ObjectName
     , ColumnName
     , ColumnType
     , replace(ColumnName, N'@', N'') as NAME
     , replace(ColumnName, N'@', N'') as DISPLAY_NAME
     , SqlDbType
     , CsType
     , length
     , colid
  from vwSqlColumns
 where ObjectType = N'P'

GO

Grant Select on dbo.vwSqlColumns_Import to public;
GO


