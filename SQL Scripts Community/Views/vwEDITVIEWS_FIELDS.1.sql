if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEDITVIEWS_FIELDS')
	Drop View dbo.vwEDITVIEWS_FIELDS;
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
-- 01/08/2006 Paul.  LIST_NAME is used in Layout manager. 
-- 02/01/2006 Paul.  DB2 does not like comments in the middle of the Create View statement. 
-- 12/02/2007 Paul.  Add data columns. 
-- 12/08/2007 Paul.  Add the view name so that the SearchView can populate the Order By listbox. 
-- 04/02/2008 Paul.  Join to the field validators table. 
-- 05/17/2009 Paul.  Add support for a generic module popup. 
-- 05/22/2009 Paul.  Add MODULE_NAME to allow export. 
-- 06/12/2009 Paul.  Add TOOL_TIP for help hover.
-- 09/12/2009 Paul.  Add FIELD_VALIDATOR_ID it can be edited with the DynamicLayout editor. 
-- 01/19/2010 Paul.  We need to be able to format a Float field to prevent too many decimal places. 
-- 09/13/2010 Paul.  Add relationship fields. 
-- 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
Create View dbo.vwEDITVIEWS_FIELDS
as
select EDITVIEWS_FIELDS.ID
     , EDITVIEWS_FIELDS.DELETED
     , EDITVIEWS_FIELDS.EDIT_NAME
     , EDITVIEWS_FIELDS.FIELD_INDEX
     , EDITVIEWS_FIELDS.FIELD_TYPE
     , EDITVIEWS_FIELDS.DEFAULT_VIEW
     , EDITVIEWS_FIELDS.DATA_LABEL
     , EDITVIEWS_FIELDS.DATA_FIELD
     , EDITVIEWS_FIELDS.DATA_FORMAT
     , EDITVIEWS_FIELDS.DISPLAY_FIELD
     , EDITVIEWS_FIELDS.CACHE_NAME
     , EDITVIEWS_FIELDS.CACHE_NAME  as LIST_NAME
     , EDITVIEWS_FIELDS.DATA_REQUIRED
     , EDITVIEWS_FIELDS.UI_REQUIRED
     , EDITVIEWS_FIELDS.ONCLICK_SCRIPT
     , EDITVIEWS_FIELDS.FORMAT_SCRIPT
     , EDITVIEWS_FIELDS.FORMAT_TAB_INDEX
     , EDITVIEWS_FIELDS.FORMAT_MAX_LENGTH
     , EDITVIEWS_FIELDS.FORMAT_SIZE
     , EDITVIEWS_FIELDS.FORMAT_ROWS
     , EDITVIEWS_FIELDS.FORMAT_COLUMNS
     , EDITVIEWS_FIELDS.COLSPAN
     , EDITVIEWS_FIELDS.ROWSPAN
     , EDITVIEWS.LABEL_WIDTH
     , EDITVIEWS.FIELD_WIDTH
     , EDITVIEWS.DATA_COLUMNS
     , EDITVIEWS.VIEW_NAME
     , EDITVIEWS_FIELDS.FIELD_VALIDATOR_ID
     , EDITVIEWS_FIELDS.FIELD_VALIDATOR_MESSAGE
     , (case when FIELD_VALIDATORS.ID is not null then 1 else 0 end) as UI_VALIDATOR
     , FIELD_VALIDATORS.VALIDATION_TYPE
     , FIELD_VALIDATORS.REGULAR_EXPRESSION
     , FIELD_VALIDATORS.DATA_TYPE
     , FIELD_VALIDATORS.MININUM_VALUE
     , FIELD_VALIDATORS.MAXIMUM_VALUE
     , FIELD_VALIDATORS.COMPARE_OPERATOR
     , EDITVIEWS_FIELDS.MODULE_TYPE
     , EDITVIEWS.MODULE_NAME
     , FIELD_VALIDATORS.NAME                as FIELD_VALIDATOR_NAME
     , EDITVIEWS_FIELDS.TOOL_TIP
     , EDITVIEWS_FIELDS.RELATED_SOURCE_MODULE_NAME
     , EDITVIEWS_FIELDS.RELATED_SOURCE_VIEW_NAME
     , EDITVIEWS_FIELDS.RELATED_SOURCE_ID_FIELD
     , EDITVIEWS_FIELDS.RELATED_SOURCE_NAME_FIELD
     , EDITVIEWS_FIELDS.RELATED_VIEW_NAME
     , EDITVIEWS_FIELDS.RELATED_ID_FIELD
     , EDITVIEWS_FIELDS.RELATED_NAME_FIELD
     , EDITVIEWS_FIELDS.RELATED_JOIN_FIELD
     , EDITVIEWS_FIELDS.PARENT_FIELD
     , EDITVIEWS.SCRIPT
  from            EDITVIEWS_FIELDS
       inner join EDITVIEWS
               on EDITVIEWS.NAME           = EDITVIEWS_FIELDS.EDIT_NAME
              and EDITVIEWS.DELETED        = 0
  left outer join FIELD_VALIDATORS
               on FIELD_VALIDATORS.ID      = EDITVIEWS_FIELDS.FIELD_VALIDATOR_ID
              and FIELD_VALIDATORS.DELETED = 0
 where EDITVIEWS_FIELDS.DELETED = 0

GO

Grant Select on dbo.vwEDITVIEWS_FIELDS to public;
GO

