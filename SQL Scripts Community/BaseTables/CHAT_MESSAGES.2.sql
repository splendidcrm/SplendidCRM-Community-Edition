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
-- drop table CHAT_MESSAGES;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CHAT_MESSAGES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.CHAT_MESSAGES';
	Create Table dbo.CHAT_MESSAGES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_CHAT_MESSAGES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, CHAT_CHANNEL_ID                    uniqueidentifier not null
		, NAME                               nvarchar(400) null
		, PARENT_ID                          uniqueidentifier null
		, PARENT_TYPE                        nvarchar(25) null
		, NOTE_ATTACHMENT_ID                 uniqueidentifier null
		, DESCRIPTION                        nvarchar(max) null
		, IS_PRIVATE                         bit null
		)

	create index IDX_CHAT_MESSAGES_NAME      on dbo.CHAT_MESSAGES (CHAT_CHANNEL_ID, DELETED, NAME)
	create index IDX_CHAT_NOTE_ATTACHMENT_ID on dbo.CHAT_MESSAGES (NOTE_ATTACHMENT_ID, DELETED, ID)
	create index IDX_CHAT_MESSAGES_PARENT_ID on dbo.CHAT_MESSAGES (PARENT_ID, PARENT_TYPE, DELETED, ID)
  end
GO

