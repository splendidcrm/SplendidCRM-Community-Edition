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
-- https://dev.twitter.com/docs/api/1.1/post/statuses/filter
-- 11/10/2017 Paul.  Twitter increased display name to 50. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- drop table TWITTER_TRACKS;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TWITTER_TRACKS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.TWITTER_TRACKS';
	Create Table dbo.TWITTER_TRACKS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_TWITTER_TRACKS primary key
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
		, NAME                               nvarchar(60) null
		, LOCATION                           nvarchar(60) null
		, TWITTER_USER_ID                    bigint null
		, TWITTER_SCREEN_NAME                nvarchar(50) null
		, STATUS                             nvarchar(25) null
		, TYPE                               nvarchar(25) null
		, DESCRIPTION                        nvarchar(max) null
		)

	create index IDX_TWITTER_TRACKS_NAME            on dbo.TWITTER_TRACKS (NAME, DELETED, ID)
	create index IDX_TWITTER_TRACKS_ASSIGNED_ID     on dbo.TWITTER_TRACKS (ASSIGNED_USER_ID, ID, DELETED)
	create index IDX_TWITTER_TRACKS_TEAM_ID         on dbo.TWITTER_TRACKS (TEAM_ID, ASSIGNED_USER_ID, ID, DELETED)
	create index IDX_TWITTER_TRACKS_TEAM_SET_ID     on dbo.TWITTER_TRACKS (TEAM_SET_ID, ASSIGNED_USER_ID, ID, DELETED)
	-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	create index IDX_TWITTER_TRACKS_ASSIGNED_SET_ID on dbo.TWITTER_TRACKS (ASSIGNED_SET_ID, ID, DELETED)
  end
GO

