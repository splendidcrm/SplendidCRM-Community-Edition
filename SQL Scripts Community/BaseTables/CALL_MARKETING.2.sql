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
-- drop table CALL_MARKETING_PROSPECT_LISTS;
-- drop table CALL_MARKETING;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CALL_MARKETING' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.CALL_MARKETING';
	Create Table dbo.CALL_MARKETING
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_CALL_MARKETING primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, CAMPAIGN_ID                        uniqueidentifier null
		, ASSIGNED_USER_ID                   uniqueidentifier null
		, ASSIGNED_SET_ID                    uniqueidentifier null
		, TEAM_ID                            uniqueidentifier null
		, TEAM_SET_ID                        uniqueidentifier null
		, NAME                               nvarchar(255) null
		, STATUS                             nvarchar(25) null
		, DISTRIBUTION                       nvarchar(25) null
		, ALL_PROSPECT_LISTS                 bit null default(0)

		, SUBJECT                            nvarchar(50) null
		, DURATION_HOURS                     int null
		, DURATION_MINUTES                   int null
		, DATE_START                         datetime null
		, TIME_START                         datetime null
		, DATE_END                           datetime null
		, TIME_END                           datetime null
		, REMINDER_TIME                      int null default(-1)
		, DESCRIPTION                        nvarchar(max) null
		)

	create index IDX_CALL_MARKETING_NAME             on dbo.CALL_MARKETING (NAME   )
	create index IDX_CALL_MARKETING                  on dbo.CALL_MARKETING (DELETED)
	create index IDX_CALL_MARKETING_TEAM_SET_ID      on dbo.CALL_MARKETING (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
	-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	create index IDX_CALL_MARKETING_ASSIGNED_SET_ID  on dbo.CALL_MARKETING (ASSIGNED_SET_ID, DELETED, ID)

	alter table dbo.CALL_MARKETING add constraint FK_CALL_MARKETING_CAMPAIGN_ID foreign key ( CAMPAIGN_ID ) references dbo.CAMPAIGNS       ( ID )
  end
GO

