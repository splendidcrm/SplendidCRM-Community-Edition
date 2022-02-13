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
-- 12/02/2007 Paul.  Add field for data columns. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 10/30/2010 Paul.  Add support for Business Rules Framework. 
-- 11/11/2010 Paul.  Change to Pre Load and Post Load. 
-- 02/12/2011 Paul.  POST_VALIDATION_EVENT_ID was not used.  Instead, we use VALIDATION_EVENT_ID. 
-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EDITVIEWS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.EDITVIEWS';
	Create Table dbo.EDITVIEWS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_EDITVIEWS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, NAME                               nvarchar( 50) not null
		, MODULE_NAME                        nvarchar( 25) not null
		, VIEW_NAME                          nvarchar( 50) not null
		, LABEL_WIDTH                        nvarchar( 10) null default('15%')
		, FIELD_WIDTH                        nvarchar( 10) null default('35%')
		, DATA_COLUMNS                       int null

		, NEW_EVENT_ID                       uniqueidentifier null
		, PRE_LOAD_EVENT_ID                  uniqueidentifier null
		, POST_LOAD_EVENT_ID                 uniqueidentifier null
		, VALIDATION_EVENT_ID                uniqueidentifier null
		, PRE_SAVE_EVENT_ID                  uniqueidentifier null
		, POST_SAVE_EVENT_ID                 uniqueidentifier null
		, SCRIPT                             nvarchar(max) null
		)

	create index IDX_EDITVIEWS_NAME on dbo.EDITVIEWS (NAME, DELETED)
	-- 02/11/2017 Paul.  New index based on missing indexes query. 
	create index IDX_EDITVIEWS_DELETED_VIEW on dbo.EDITVIEWS (DELETED, VIEW_NAME)
  end
GO


