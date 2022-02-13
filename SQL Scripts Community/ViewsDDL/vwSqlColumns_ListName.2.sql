if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSqlColumns_ListName')
	Drop View dbo.vwSqlColumns_ListName;
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
Create View dbo.vwSqlColumns_ListName
as
select ObjectName
     , ColumnName                  as DATA_FIELD
     , EDITVIEWS_FIELDS.CACHE_NAME as LIST_NAME
  from      vwSqlColumns
 inner join EDITVIEWS_FIELDS
         on EDITVIEWS_FIELDS.DATA_FIELD   = vwSqlColumns.ColumnName
        and EDITVIEWS_FIELDS.DELETED      = 0
        and EDITVIEWS_FIELDS.FIELD_TYPE   = N'ListBox'
        and EDITVIEWS_FIELDS.DEFAULT_VIEW = 0
        and EDITVIEWS_FIELDS.CACHE_NAME is not null
 inner join EDITVIEWS
         on EDITVIEWS.NAME                = EDITVIEWS_FIELDS.EDIT_NAME
        and EDITVIEWS.VIEW_NAME           = vwSqlColumns.ObjectName + N'_Edit'
        and EDITVIEWS.DELETED             = 0
 where CsType in(N'string', N'ansistring')

GO

Grant Select on dbo.vwSqlColumns_ListName to public;
GO


