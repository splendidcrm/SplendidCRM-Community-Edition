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
-- drop table DYNAMIC_BUTTONS;
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 07/28/2010 Paul.  We need a flag to exclude a button from a mobile device. 
-- 03/14/2014 Paul.  Allow hidden buttons to be created. 
-- 08/16/2017 Paul.  Increase the size of the ONCLICK_SCRIPT so that we can add a javascript info column. 
-- 08/16/2017 Paul.  Add ability to apply a business rule to a button. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'DYNAMIC_BUTTONS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.DYNAMIC_BUTTONS';
	Create Table dbo.DYNAMIC_BUTTONS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_DYNAMIC_BUTTONS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, VIEW_NAME                          nvarchar( 50) not null
		, CONTROL_INDEX                      int not null
		, CONTROL_TYPE                       nvarchar( 25) not null
		, DEFAULT_VIEW                       bit null default(0)

		, MODULE_NAME                        nvarchar( 25) null
		, MODULE_ACCESS_TYPE                 nvarchar(100) null
		, TARGET_NAME                        nvarchar( 25) null
		, TARGET_ACCESS_TYPE                 nvarchar(100) null
		, MOBILE_ONLY                        bit null default(0)
		, ADMIN_ONLY                         bit null default(0)
		, EXCLUDE_MOBILE                     bit null default(0)
		, HIDDEN                             bit null default(0)

		, CONTROL_TEXT                       nvarchar(150) null
		, CONTROL_TOOLTIP                    nvarchar(150) null
		, CONTROL_ACCESSKEY                  nvarchar(150) null
		, CONTROL_CSSCLASS                   nvarchar( 50) null

		, TEXT_FIELD                         nvarchar(200) null
		, ARGUMENT_FIELD                     nvarchar(200) null

		, COMMAND_NAME                       nvarchar( 50) null
		, URL_FORMAT                         nvarchar(255) null
		, URL_TARGET                         nvarchar( 20) null
		, ONCLICK_SCRIPT                     nvarchar(max) null

		, BUSINESS_RULE                      nvarchar(max) null
		, BUSINESS_SCRIPT                    nvarchar(max) null
		)

	create index IDX_DYNAMIC_BUTTONS_DETAIL_NAME on dbo.DYNAMIC_BUTTONS (VIEW_NAME, DELETED)
  end
GO


