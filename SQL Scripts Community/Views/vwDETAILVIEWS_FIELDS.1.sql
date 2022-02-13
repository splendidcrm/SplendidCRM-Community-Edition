if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDETAILVIEWS_FIELDS')
	Drop View dbo.vwDETAILVIEWS_FIELDS;
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
-- 12/02/2007 Paul.  Add data columns. 
-- 05/22/2009 Paul.  Add MODULE_NAME to allow export. 
-- 06/12/2009 Paul.  Add TOOL_TIP for help hover.
-- 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
-- 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
Create View dbo.vwDETAILVIEWS_FIELDS
as
select DETAILVIEWS_FIELDS.ID
     , DETAILVIEWS_FIELDS.DELETED
     , DETAILVIEWS_FIELDS.DETAIL_NAME
     , DETAILVIEWS_FIELDS.FIELD_INDEX
     , DETAILVIEWS_FIELDS.FIELD_TYPE
     , DETAILVIEWS_FIELDS.DEFAULT_VIEW
     , DETAILVIEWS_FIELDS.DATA_LABEL
     , DETAILVIEWS_FIELDS.DATA_FIELD
     , DETAILVIEWS_FIELDS.DATA_FORMAT
     , DETAILVIEWS_FIELDS.URL_FIELD
     , DETAILVIEWS_FIELDS.URL_FORMAT
     , DETAILVIEWS_FIELDS.URL_TARGET
     , DETAILVIEWS_FIELDS.LIST_NAME
     , DETAILVIEWS_FIELDS.COLSPAN
     , DETAILVIEWS.LABEL_WIDTH
     , DETAILVIEWS.FIELD_WIDTH
     , DETAILVIEWS.DATA_COLUMNS
     , DETAILVIEWS.VIEW_NAME
     , DETAILVIEWS.MODULE_NAME
     , DETAILVIEWS_FIELDS.TOOL_TIP
     , DETAILVIEWS_FIELDS.MODULE_TYPE
     , DETAILVIEWS_FIELDS.PARENT_FIELD
     , DETAILVIEWS.SCRIPT
  from      DETAILVIEWS_FIELDS
 inner join DETAILVIEWS
         on DETAILVIEWS.NAME    = DETAILVIEWS_FIELDS.DETAIL_NAME
        and DETAILVIEWS.DELETED = 0
 where DETAILVIEWS_FIELDS.DELETED = 0

GO

Grant Select on dbo.vwDETAILVIEWS_FIELDS to public;
GO

