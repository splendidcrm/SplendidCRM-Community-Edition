if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSqlColumns_Reporting')
	Drop View dbo.vwSqlColumns_Reporting;
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
-- 02/09/2007 Paul.  Use the EDITVIEWS_FIELDS to determine if a column is an enum. 
-- 01/16/2008 Paul.  Simplify conversion to Oracle. 
-- 05/20/2009 Paul.  We need to allow the multiple selection of users. 
-- 05/13/2021 Paul.  Include PARENT_ID. 
Create View dbo.vwSqlColumns_Reporting
as
select ObjectName
     , ColumnName
     , ColumnType
     , ColumnName as NAME
     , ColumnName as DISPLAY_NAME
     , SqlDbType
     , (case 
        when dbo.fnSqlColumns_IsEnum(ObjectName, ColumnName, CsType) = 1 then N'enum'
        else CsType
        end) as CsType
     , colid
  from vwSqlColumns
 where ColumnName not in (N'ID', N'ID_C')
   and (ColumnName not like N'%_ID' or ColumnName in ('PARENT_ID', 'CREATED_BY_ID', 'MODIFIED_USER_ID', 'ASSIGNED_USER_ID', 'TEAM_ID'))

GO

Grant Select on dbo.vwSqlColumns_Reporting to public;
GO


