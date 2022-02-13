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
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 01/02/2012 Paul.  Add iCal TZID. 
-- 03/26/2013 Paul.  iCloud uses linked_timezone values from http://tzinfo.rubyforge.org/doc/. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TIMEZONES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.TIMEZONES';
	Create Table dbo.TIMEZONES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_TIMEZONES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, NAME                               nvarchar(100) not null
		, STANDARD_NAME                      nvarchar(100) null
		, STANDARD_ABBREVIATION              nvarchar( 10) null
		, DAYLIGHT_NAME                      nvarchar(100) null
		, DAYLIGHT_ABBREVIATION              nvarchar( 10) null
		, BIAS                               int null
		, STANDARD_BIAS                      int null
		, DAYLIGHT_BIAS                      int null

		, STANDARD_YEAR                      int null
		, STANDARD_MONTH                     int null
		, STANDARD_WEEK                      int null
		, STANDARD_DAYOFWEEK                 int null
		, STANDARD_HOUR                      int null
		, STANDARD_MINUTE                    int null

		, DAYLIGHT_YEAR                      int null
		, DAYLIGHT_MONTH                     int null
		, DAYLIGHT_WEEK                      int null
		, DAYLIGHT_DAYOFWEEK                 int null
		, DAYLIGHT_HOUR                      int null
		, DAYLIGHT_MINUTE                    int null
		, TZID                               nvarchar(50) null
		, LINKED_TIMEZONE                    nvarchar(50) null
		)

	create index IX_TIMEZONES_NAME on dbo.TIMEZONES(NAME)
  end
GO


