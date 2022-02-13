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
-- 01/04/2006 Paul.  Add CUSTOM_ENABLED if module has a _CSTM table and can be customized. 
-- 04/24/2006 Paul.  Add IS_ADMIN to simplify ACL management. 
-- 05/02/2006 Paul.  Add TABLE_NAME as direct table queries are required by SOAP and we need a mapping. 
-- 05/20/2006 Paul.  Add REPORT_ENABLED if the module can be the basis of a report. ACL rules will still apply. 
-- 10/06/2006 Paul.  Add IMPORT_ENABLED if the module can allow importing. 
-- 11/17/2007 Paul.  Add MOBILE_ENABLED flag to determine if module should be shown on mobile browser.
-- 07/20/2009 Paul.  Add SYNC_ENABLED flag to determine if module can be sync'd.
-- 09/08/2009 Paul.  Custom Paging can be enabled /disabled per module. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 12/02/2009 Paul.  Add the ability to disable Mass Updates. 
-- 01/13/2010 Paul.  Allow default search to be disabled. 
-- 04/01/2010 Paul.  Add Exchange Sync flag. 
-- 04/04/2010 Paul.  Add Exchange Folders flag. 
-- 04/05/2010 Paul.  Add Exchange Create Parent flag. Need to be able to disable Account creation. 
-- 06/18/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
-- 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
-- 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
-- 07/31/2019 Paul.  DEFAULT_SORT is a new field for the React Client. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'MODULES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.MODULES';
	Create Table dbo.MODULES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_MODULES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, MODULE_NAME                        nvarchar(25) not null
		, DISPLAY_NAME                       nvarchar(50) not null
		, RELATIVE_PATH                      nvarchar(50) not null
		, MODULE_ENABLED                     bit null default(1)
		, TAB_ENABLED                        bit null default(1)
		, MOBILE_ENABLED                     bit null default(0)
		, TAB_ORDER                          int null
		, PORTAL_ENABLED                     bit null default(0)
		, CUSTOM_ENABLED                     bit null default(0)
		, REPORT_ENABLED                     bit null default(0)
		, IMPORT_ENABLED                     bit null default(0)
		, SYNC_ENABLED                       bit null default(0)
		, REST_ENABLED                       bit null default(0)
		, IS_ADMIN                           bit null default(0)
		, CUSTOM_PAGING                      bit null default(0)
		, MASS_UPDATE_ENABLED                bit null default(0)
		, DEFAULT_SEARCH_ENABLED             bit null default(1)
		, TABLE_NAME                         nvarchar(30) null
		, EXCHANGE_SYNC                      bit null default(0)
		, EXCHANGE_FOLDERS                   bit null default(0)
		, EXCHANGE_CREATE_PARENT             bit null default(0)
		, DUPLICATE_CHECHING_ENABLED         bit null default(0)
		, RECORD_LEVEL_SECURITY_ENABLED      bit null default(0)
		, DEFAULT_SORT                       nvarchar(50) null
		)
	-- 12/30/2010 Irantha.  Add index for caching. 
	create index IX_MODULES_MODULE_NAME on dbo.MODULES(MODULE_NAME, DELETED, MODULE_ENABLED, IS_ADMIN, TAB_ORDER)
  end
GO


