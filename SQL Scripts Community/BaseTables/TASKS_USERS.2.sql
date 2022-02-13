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
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TASKS_USERS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.TASKS_USERS';
	Create Table dbo.TASKS_USERS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_TASKS_USERS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, TASK_ID                            uniqueidentifier not null
		, USER_ID                            uniqueidentifier not null
		, REQUIRED                           bit null default(1)
		, ACCEPT_STATUS                      nvarchar(25) null default('none')
		, REMINDER_DISMISSED                 bit null default(0)
		, EMAIL_REMINDER_SENT                bit null default(0)
		, SMS_REMINDER_SENT                  bit null default(0)
		)

	-- 09/10/2009 Paul.  The indexes should be fully covered. 
	create index IDX_TASKS_USERS_TASK_ID on dbo.TASKS_USERS (TASK_ID, DELETED, USER_ID, ACCEPT_STATUS, REMINDER_DISMISSED, EMAIL_REMINDER_SENT, SMS_REMINDER_SENT)
	create index IDX_TASKS_USERS_USER_ID on dbo.TASKS_USERS (USER_ID, DELETED, TASK_ID, ACCEPT_STATUS, REMINDER_DISMISSED, EMAIL_REMINDER_SENT, SMS_REMINDER_SENT)
	-- 09/18/2016 Paul.  Azure recommended index for vwACTIVITIES_EmailReminders. 
	create index IDX_TASKS_USERS_REMINDER on dbo.TASKS_USERS (DELETED, EMAIL_REMINDER_SENT, TASK_ID)

	alter table dbo.TASKS_USERS add constraint FK_TASKS_USERS_TASK_ID  foreign key ( TASK_ID ) references dbo.TASKS ( ID )
	alter table dbo.TASKS_USERS add constraint FK_TASKS_USERS_USER_ID  foreign key ( USER_ID ) references dbo.USERS ( ID )
  end
GO


