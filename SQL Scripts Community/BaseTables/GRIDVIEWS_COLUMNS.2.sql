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
-- 04/27/2006 Paul.  Add URL_MODULE to support ACL.
-- 05/02/2006 Paul.  Add URL_ASSIGNED_FIELD to support ACL. 
-- 07/24/2006 Paul.  Increase the HEADER_TEXT to 150 to allow a fully-qualified (NAME+MODULE_NAME+LIST_NAME) TERMINOLOGY name. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
-- 08/02/2010 Paul.  Increase the size of the URL_FIELD and URL_FORMAT so that we can add a javascript info column. 
-- 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
-- 10/30/2013 Paul.  Increase size of URL_TARGET. 
-- 03/01/2014 Paul.  Increase size of DATA_FORMAT. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'GRIDVIEWS_COLUMNS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.GRIDVIEWS_COLUMNS';
	Create Table dbo.GRIDVIEWS_COLUMNS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_GRIDVIEWS_COLUMNS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, GRID_NAME                          nvarchar( 50) not null
		, COLUMN_INDEX                       int not null
		, COLUMN_TYPE                        nvarchar( 25) not null
		, DEFAULT_VIEW                       bit null default(0)

		, HEADER_TEXT                        nvarchar(150) null
		, SORT_EXPRESSION                    nvarchar( 50) null
		, ITEMSTYLE_WIDTH                    nvarchar( 10) null
		, ITEMSTYLE_CSSCLASS                 nvarchar( 50) null
		, ITEMSTYLE_HORIZONTAL_ALIGN         nvarchar( 10) null
		, ITEMSTYLE_VERTICAL_ALIGN           nvarchar( 10) null
		, ITEMSTYLE_WRAP                     bit null

		, DATA_FIELD                         nvarchar( 50) null
		, DATA_FORMAT                        nvarchar( 25) null
		, URL_FIELD                          nvarchar(max) null
		, URL_FORMAT                         nvarchar(max) null
		, URL_TARGET                         nvarchar( 60) null
		, LIST_NAME                          nvarchar( 50) null
		, URL_MODULE                         nvarchar( 25) null
		, URL_ASSIGNED_FIELD                 nvarchar( 30) null
		, MODULE_TYPE                        nvarchar( 25) null
		, PARENT_FIELD                       nvarchar( 30) null
		)

	create index IDX_GRIDVIEWS_COLUMNS_GRID_NAME on dbo.GRIDVIEWS_COLUMNS (GRID_NAME, DELETED)
  end
GO


