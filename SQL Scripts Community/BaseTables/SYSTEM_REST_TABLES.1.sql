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
-- 06/18/2011 Paul.  SYSTEM_REST_TABLES are nearly identical to SYSTEM_SYNC_TABLES,
-- but the Module tables typically refer to the base view instead of the raw table. 
-- 08/02/2019 Paul.  The React Client will need access to views that require a filter, like CAMPAIGN_ID. 
-- drop table SYSTEM_REST_TABLES;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'SYSTEM_REST_TABLES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.SYSTEM_REST_TABLES';
	Create Table dbo.SYSTEM_REST_TABLES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_SYSTEM_REST_TABLES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, TABLE_NAME                         nvarchar(50) not null
		, VIEW_NAME                          nvarchar(60) not null
		, MODULE_NAME                        nvarchar(25) null
		, MODULE_NAME_RELATED                nvarchar(25) null
		, MODULE_SPECIFIC                    int null default(0)
		, MODULE_FIELD_NAME                  nvarchar(50) null
		, IS_SYSTEM                          bit null default(0)
		, IS_ASSIGNED                        bit null default(0)
		, ASSIGNED_FIELD_NAME                nvarchar(50) null
		, IS_RELATIONSHIP                    bit null default(0)
		, HAS_CUSTOM                         bit null default(0)
		, DEPENDENT_LEVEL                    int null default(0) -- fnSqlDependentLevel()
		, REQUIRED_FIELDS                    nvarchar(150) null
		)
	
  end
GO


