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
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ASSIGNED_SETS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.ASSIGNED_SETS';
	Create Table dbo.ASSIGNED_SETS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_ASSIGNED_SETS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_SET_LIST                  varchar(851) not null
		, ASSIGNED_SET_NAME                  nvarchar(200) not null
		)

	create index IDX_ASSIGNED_SETS_ID       on dbo.ASSIGNED_SETS (ID, DELETED, ASSIGNED_SET_NAME)
	create index IDX_ASSIGNED_SETS_SET_LIST on dbo.ASSIGNED_SETS (ASSIGNED_SET_LIST, DELETED, ID)
  end
GO

