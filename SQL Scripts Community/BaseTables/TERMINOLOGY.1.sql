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
-- 07/24/2006 Paul.  Increase the MODULE_NAME to 25 to match the size in the MODULES table.
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 03/06/2012 Paul.  Increase size of the NAME field so that it can include a date formula. 
-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TERMINOLOGY' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.TERMINOLOGY';
	Create Table dbo.TERMINOLOGY
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_TERMINOLOGY primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, NAME                               nvarchar(150) null
		, LANG                               nvarchar(10) null
		, MODULE_NAME                        nvarchar(25) null
		, LIST_NAME                          nvarchar(50) null
		, LIST_ORDER                         int null
		, DISPLAY_NAME                       nvarchar(max) null
		)

	create index IX_TERMINOLOGY_DISPLAY_NAME on dbo.TERMINOLOGY(LANG, MODULE_NAME, NAME, LIST_NAME)
	-- 12/30/2010 Irantha.  Add index for list caching. 
	create index IX_TERMINOLOGY_LIST_NAME on dbo.TERMINOLOGY(DELETED, LANG, LIST_NAME)
	-- 02/11/2017 Paul.  New index based on missing indexes query. 
	create index IDX_TERMINOLOGY_DELETED_LIST on dbo.TERMINOLOGY (DELETED, LIST_NAME)
  end
GO


