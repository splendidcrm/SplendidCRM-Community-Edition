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
-- https://dev.twitter.com/docs/platform-objects/tweets
-- 05/24/2016 Paul.  Twitter is increasing the size of their tweets. They are going to 177, but we are going to 255. 
-- 02/11/2017 Paul.  New index based on missing indexes query. 
-- 10/21/2017 Paul.  Twitter increased sized to 280, but we are going to go to 420 so that we don't need to keep increasing. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/10/2017 Paul.  Twitter increased display name to 50. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- drop table TWITTER_MESSAGES;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TWITTER_MESSAGES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.TWITTER_MESSAGES';
	Create Table dbo.TWITTER_MESSAGES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_TWITTER_MESSAGES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier null
		, ASSIGNED_SET_ID                    uniqueidentifier null
		, TEAM_ID                            uniqueidentifier null
		, TEAM_SET_ID                        uniqueidentifier null
		, NAME                               nvarchar(420) null
		, DESCRIPTION                        nvarchar(max) null
		, DATE_START                         datetime null
		, TIME_START                         datetime null
		, PARENT_TYPE                        nvarchar(25) null
		, PARENT_ID                          uniqueidentifier null
		, TYPE                               nvarchar(25) null
		, STATUS                             nvarchar(25) null
		, TWITTER_ID                         bigint null
		, TWITTER_USER_ID                    bigint null
		, TWITTER_FULL_NAME                  nvarchar(50) null
		, TWITTER_SCREEN_NAME                nvarchar(50) null
		, ORIGINAL_ID                        bigint null
		, ORIGINAL_USER_ID                   bigint null
		, ORIGINAL_FULL_NAME                 nvarchar(50) null
		, ORIGINAL_SCREEN_NAME               nvarchar(50) null
		, IS_PRIVATE                         bit null
		)

	create index IDX_TWITTER_MSG_NAME            on dbo.TWITTER_MESSAGES (NAME, DELETED, ID)
	create index IDX_TWITTER_MSG_PARENT_ID       on dbo.TWITTER_MESSAGES (PARENT_ID, ID, DELETED)
	create index IDX_TWITTER_MSG_ASSIGNED_ID     on dbo.TWITTER_MESSAGES (ASSIGNED_USER_ID, ID, DELETED)
	create index IDX_TWITTER_MSG_TEAM_ID         on dbo.TWITTER_MESSAGES (TEAM_ID, ASSIGNED_USER_ID, ID, DELETED)
	create index IDX_TWITTER_MSG_TEAM_SET_ID     on dbo.TWITTER_MESSAGES (TEAM_SET_ID, ASSIGNED_USER_ID, ID, DELETED)
	-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	create index IDX_TWITTER_MSG_ASSIGNED_SET_ID on dbo.TWITTER_MESSAGES (ASSIGNED_SET_ID, ID, DELETED)
	-- 02/11/2017 Paul.  New index based on missing indexes query. 
	create index IDX_TWITTER_MESSAGES_TWITTER_ID on dbo.TWITTER_MESSAGES (DELETED, TWITTER_ID)
  end
GO

