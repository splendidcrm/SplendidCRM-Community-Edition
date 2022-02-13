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
-- http://www.sql-server-helper.com/sql-server-2008/convert-latitude-longitude-to-geography-point.aspx
-- drop table ZIPCODES;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ZIPCODES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.ZIPCODES';
	Create Table dbo.ZIPCODES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_ZIPCODES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, NAME                               nvarchar(20) null
		, CITY                               nvarchar(100) null
		, STATE                              nvarchar(100) null
		, COUNTRY                            nvarchar(100) null
		, LONGITUDE                          decimal(10, 6) null
		, LATITUDE                           decimal(10, 6) null
		, TIMEZONE_ID                        uniqueidentifier null
		)

	create index IDX_ZIPCODES_NAME on dbo.ZIPCODES (NAME, ID, DELETED)
  end
GO

