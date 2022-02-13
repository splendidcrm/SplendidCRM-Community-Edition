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
-- 04/04/2010 Paul.  EXCHANGE_WATERMARK for push and pull subscriptions. 
-- 04/04/2010 Paul.  The Watermark seems to be 40 characters. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EXCHANGE_USERS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.EXCHANGE_USERS';
	Create Table dbo.EXCHANGE_USERS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_EXCHANGE_USERS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier not null
		, EXCHANGE_ALIAS                     nvarchar( 60) null
		, EXCHANGE_EMAIL                     nvarchar(100) null
		, EXCHANGE_WATERMARK                 varchar(100) null
		)

	create index IDX_EXCHANGE_USERS_ASSIGNED_USER_ID on dbo.EXCHANGE_USERS (ASSIGNED_USER_ID, DELETED, EXCHANGE_ALIAS, EXCHANGE_EMAIL)
  end
GO

