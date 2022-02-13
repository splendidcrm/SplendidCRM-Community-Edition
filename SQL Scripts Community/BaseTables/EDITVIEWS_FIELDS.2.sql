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
-- 07/24/2006 Paul.  Increase the DATA_LABEL to 150 to allow a fully-qualified (NAME+MODULE_NAME+LIST_NAME) TERMINOLOGY name. 
-- 04/02/2008 Paul.  Add Validation fields. 
-- 05/17/2009 Paul.  Add support for a generic module popup. 
-- 06/12/2009 Paul.  Add TOOL_TIP for help hover.
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 01/19/2010 Paul.  We need to be able to format a Float field to prevent too many decimal places. 
-- 09/13/2010 Paul.  Add relationship fields. 
-- 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
-- 09/16/2012 Paul.  Increase ONCLICK_SCRIPT to nvarchar(max). 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EDITVIEWS_FIELDS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.EDITVIEWS_FIELDS';
	Create Table dbo.EDITVIEWS_FIELDS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_EDITVIEWS_FIELDS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, EDIT_NAME                          nvarchar( 50) not null
		, FIELD_INDEX                        int not null
		, FIELD_TYPE                         nvarchar( 25) not null
		, DEFAULT_VIEW                       bit null default(0)

		, DATA_LABEL                         nvarchar(150) null
		, DATA_FIELD                         nvarchar(100) null
		, DATA_FORMAT                        nvarchar(100) null
		, DISPLAY_FIELD                      nvarchar(100) null
		, CACHE_NAME                         nvarchar( 50) null
		, DATA_REQUIRED                      bit null
		, UI_REQUIRED                        bit null
		, ONCLICK_SCRIPT                     nvarchar(max) null
		, FORMAT_SCRIPT                      nvarchar(255) null
		, FORMAT_TAB_INDEX                   int null
		, FORMAT_MAX_LENGTH                  int null
		, FORMAT_SIZE                        int null
		, FORMAT_ROWS                        int null
		, FORMAT_COLUMNS                     int null
		, COLSPAN                            int null
		, ROWSPAN                            int null
		, FIELD_VALIDATOR_ID                 uniqueidentifier null
		, FIELD_VALIDATOR_MESSAGE            nvarchar(150) null
		, MODULE_TYPE                        nvarchar(25) null
		, TOOL_TIP                           nvarchar(150) null

		, RELATED_SOURCE_MODULE_NAME         nvarchar(50) null
		, RELATED_SOURCE_VIEW_NAME           nvarchar(50) null
		, RELATED_SOURCE_ID_FIELD            nvarchar(30) null
		, RELATED_SOURCE_NAME_FIELD          nvarchar(100) null
		, RELATED_VIEW_NAME                  nvarchar(50) null
		, RELATED_ID_FIELD                   nvarchar(30) null
		, RELATED_NAME_FIELD                 nvarchar(100) null
		, RELATED_JOIN_FIELD                 nvarchar(30) null
		, PARENT_FIELD                       nvarchar(30) null
		)

	create index IDX_EDITVIEWS_FIELDS_EDIT_NAME on dbo.EDITVIEWS_FIELDS (EDIT_NAME, DELETED)
	-- 12/31/2010 Irantha.  Add index to improve caching. 
	create index IDX_EDITVIEWS_FIELDS_CACHE_NAME on dbo.EDITVIEWS_FIELDS (DATA_FIELD, DELETED, FIELD_TYPE, DEFAULT_VIEW, CACHE_NAME)
  end
GO

