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
-- 06/16/2017 Paul.  Add DEFAULT_SETTINGS. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'DASHBOARD_APPS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.DASHBOARD_APPS';
	Create Table dbo.DASHBOARD_APPS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_DASHBOARD_APPS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, NAME                               nvarchar(150) null
		, CATEGORY                           nvarchar( 25) null
		, MODULE_NAME                        nvarchar( 50) null
		, TITLE                              nvarchar(100) null
		, SETTINGS_EDITVIEW                  nvarchar( 50) null
		, IS_ADMIN                           bit null default(0)
		, APP_ENABLED                        bit null default(1)
		, SCRIPT_URL                         nvarchar(2083) null
		, DEFAULT_SETTINGS                   nvarchar(max) null
		)

	create index IDX_DASHBOARD_APPS_MODULE on dbo.DASHBOARD_APPS (MODULE_NAME, DELETED, ID)
  end
GO

