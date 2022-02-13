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
-- 04/30/2016 Paul.  Add reference to log entry that modified the record. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CURRENCIES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.CURRENCIES';
	Create Table dbo.CURRENCIES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_CURRENCIES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, NAME                               nvarchar(36) not null
		, SYMBOL                             nvarchar(36) not null
		, ISO4217                            nvarchar(3) not null
		, CONVERSION_RATE                    float not null default(0.0)
		, STATUS                             nvarchar(25) null
		, SYSTEM_CURRENCY_LOG_ID             uniqueidentifier null
		)

	create index IDX_CURRENCIES_NAME on dbo.CURRENCIES (NAME, DELETED)
  end
GO


