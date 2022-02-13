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
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CHAT_CHANNELS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.CHAT_CHANNELS';
	Create Table dbo.CHAT_CHANNELS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_CHAT_CHANNELS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier null
		, NAME                               nvarchar(150) null
		, PARENT_ID                          uniqueidentifier null
		, PARENT_TYPE                        nvarchar(25) null
		, TEAM_ID                            uniqueidentifier null
		, TEAM_SET_ID                        uniqueidentifier null
		, ASSIGNED_SET_ID                    uniqueidentifier null
		)

	create index IDX_CHAT_CHANNELS_TEAM_ID         on dbo.CHAT_CHANNELS (TEAM_ID, DELETED, ID)
	create index IDX_CHAT_CHANNELS_TEAM_SET_ID     on dbo.CHAT_CHANNELS (TEAM_SET_ID, DELETED, ID)
	-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	create index IDX_CHAT_CHANNELS_ASSIGNED_SET_ID on dbo.CHAT_CHANNELS (ASSIGNED_SET_ID, DELETED, ID)
	create index IDX_CHAT_CHANNELS_PARENT_ID       on dbo.CHAT_CHANNELS (PARENT_ID, PARENT_TYPE, DELETED, ID)
  end
GO

-- alter table CHAT_CHANNELS add PARENT_ID uniqueidentifier null;
-- alter table CHAT_CHANNELS add PARENT_TYPE nvarchar(25) null;

