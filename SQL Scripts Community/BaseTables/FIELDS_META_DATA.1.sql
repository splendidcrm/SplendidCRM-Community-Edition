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
-- 04/21/2006 Paul.  MASS_UPDATE was added in SugarCRM 4.0.1.
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'FIELDS_META_DATA' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.FIELDS_META_DATA';
	Create Table dbo.FIELDS_META_DATA
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_FIELDS_META_DATA primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, NAME                               nvarchar(255) not null
		, LABEL                              nvarchar(255) not null
		, CUSTOM_MODULE                      nvarchar(255) null
		, DATA_TYPE                          nvarchar(255) not null
		, MAX_SIZE                           int null default(0)
		, REQUIRED_OPTION                    nvarchar(255) null
		, DEFAULT_VALUE                      nvarchar(255) null
		, EXT1                               nvarchar(255) null
		, EXT2                               nvarchar(255) null
		, EXT3                               nvarchar(255) null
		, AUDITED                            bit null default(0)
		, MASS_UPDATE                        bit null default(0)
		)
  end
GO


