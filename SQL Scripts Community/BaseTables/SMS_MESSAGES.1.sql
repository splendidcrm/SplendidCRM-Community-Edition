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
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- drop table SMS_MESSAGES;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'SMS_MESSAGES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.SMS_MESSAGES';
	Create Table dbo.SMS_MESSAGES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_SMS_MESSAGES primary key
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
		, MAILBOX_ID                         uniqueidentifier null
		, NAME                               nvarchar(1600) null
		, DATE_START                         datetime null
		, TIME_START                         datetime null
		, PARENT_TYPE                        nvarchar(25) null
		, PARENT_ID                          uniqueidentifier null
		, FROM_NUMBER                        nvarchar(20) null
		, TO_NUMBER                          nvarchar(20) null
		, TO_ID                              uniqueidentifier null
		, TYPE                               nvarchar(25) null
		, STATUS                             nvarchar(25) null
		, MESSAGE_SID                        nvarchar(100) null
		, FROM_LOCATION                      nvarchar(100) null
		, TO_LOCATION                        nvarchar(100) null
		, IS_PRIVATE                         bit null
		)

	-- 09/19/2013 Paul.  We are not going to index the NAME field as the index will exceed the maximum key length of 900 bytes. 
	create index IDX_SMS_MESSAGES_MESSAGE_SID          on dbo.SMS_MESSAGES (MESSAGE_SID, DELETED, ID)
	create index IDX_SMS_MESSAGES_PARENT_ID            on dbo.SMS_MESSAGES (PARENT_ID, ID, DELETED)
	create index IDX_SMS_MESSAGES_ASSIGNED_USER        on dbo.SMS_MESSAGES (ASSIGNED_USER_ID, ID, DELETED)
	create index IDX_SMS_MESSAGES_TEAM_ID              on dbo.SMS_MESSAGES (TEAM_ID, ASSIGNED_USER_ID, ID, DELETED)
	create index IDX_SMS_MESSAGES_TEAM_SET_ID          on dbo.SMS_MESSAGES (TEAM_SET_ID, ASSIGNED_USER_ID, ID, DELETED)
	-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	create index IDX_SMS_MESSAGES_ASSIGNED_SET_ID      on dbo.SMS_MESSAGES (ASSIGNED_SET_ID, ID, DELETED)
  end
GO

