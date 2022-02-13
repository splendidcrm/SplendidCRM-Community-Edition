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
-- 04/28/2006 Paul.  Added SHORTCUT_MODULE to help with ACL. 
-- 04/28/2006 Paul.  Added SHORTCUT_ACLTYPE to help with ACL. 
-- 07/24/2006 Paul.  Increase the DISPLAY_NAME to 150 to allow a fully-qualified (NAME+MODULE_NAME+LIST_NAME) TERMINOLOGY name. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'SHORTCUTS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.SHORTCUTS';
	Create Table dbo.SHORTCUTS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_SHORTCUTS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, MODULE_NAME                        nvarchar( 25) not null
		, DISPLAY_NAME                       nvarchar(150) not null
		, RELATIVE_PATH                      nvarchar(255) not null
		, IMAGE_NAME                         nvarchar( 50) null
		, SHORTCUT_ENABLED                   bit null default(1)
		, SHORTCUT_ORDER                     int null
		, SHORTCUT_MODULE                    nvarchar( 25) null
		, SHORTCUT_ACLTYPE                   nvarchar(100) null
		)
	-- 12/30/2010 Irantha.  Add index for caching. 
	create index IX_SHORTCUTS_SHORTCUT_ORDER on dbo.SHORTCUTS(DELETED, SHORTCUT_ORDER, SHORTCUT_MODULE)
  end
GO


