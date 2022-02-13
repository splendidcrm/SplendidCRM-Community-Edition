if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwGRIDVIEWS_COLUMNS')
	Drop View dbo.vwGRIDVIEWS_COLUMNS;
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
-- 05/02/2006 Paul.  Add URL_ASSIGNED_FIELD to support ACL. 
-- 05/22/2009 Paul.  Add MODULE_NAME to allow export. 
-- 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
-- 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
Create View dbo.vwGRIDVIEWS_COLUMNS
as
select GRIDVIEWS_COLUMNS.ID
     , GRIDVIEWS_COLUMNS.DELETED
     , GRIDVIEWS_COLUMNS.GRID_NAME
     , GRIDVIEWS_COLUMNS.COLUMN_INDEX
     , GRIDVIEWS_COLUMNS.COLUMN_TYPE
     , GRIDVIEWS_COLUMNS.DEFAULT_VIEW
     , GRIDVIEWS_COLUMNS.HEADER_TEXT
     , GRIDVIEWS_COLUMNS.SORT_EXPRESSION
     , GRIDVIEWS_COLUMNS.ITEMSTYLE_WIDTH
     , GRIDVIEWS_COLUMNS.ITEMSTYLE_CSSCLASS
     , GRIDVIEWS_COLUMNS.ITEMSTYLE_HORIZONTAL_ALIGN
     , GRIDVIEWS_COLUMNS.ITEMSTYLE_VERTICAL_ALIGN
     , GRIDVIEWS_COLUMNS.ITEMSTYLE_WRAP
     , GRIDVIEWS_COLUMNS.DATA_FIELD
     , GRIDVIEWS_COLUMNS.DATA_FORMAT
     , GRIDVIEWS_COLUMNS.URL_FIELD
     , GRIDVIEWS_COLUMNS.URL_FORMAT
     , GRIDVIEWS_COLUMNS.URL_TARGET
     , GRIDVIEWS_COLUMNS.LIST_NAME
     , GRIDVIEWS_COLUMNS.URL_MODULE
     , GRIDVIEWS_COLUMNS.URL_ASSIGNED_FIELD
     , GRIDVIEWS.VIEW_NAME
     , GRIDVIEWS.MODULE_NAME
     , GRIDVIEWS_COLUMNS.MODULE_TYPE
     , GRIDVIEWS_COLUMNS.PARENT_FIELD
     , GRIDVIEWS.SCRIPT
  from      GRIDVIEWS_COLUMNS
 inner join GRIDVIEWS
         on GRIDVIEWS.NAME    = GRIDVIEWS_COLUMNS.GRID_NAME
        and GRIDVIEWS.DELETED = 0
 where GRIDVIEWS_COLUMNS.DELETED = 0

GO

Grant Select on dbo.vwGRIDVIEWS_COLUMNS to public;
GO

