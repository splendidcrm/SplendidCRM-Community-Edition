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
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TASKS_CONTACTS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.TASKS_CONTACTS';
	Create Table dbo.TASKS_CONTACTS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_TASKS_CONTACTS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, TASK_ID                            uniqueidentifier not null
		, CONTACT_ID                         uniqueidentifier not null
		, REQUIRED                           bit null default(1)
		, ACCEPT_STATUS                      nvarchar(25) null default('none')
		, EMAIL_REMINDER_SENT                bit null default(0)
		, SMS_REMINDER_SENT                  bit null default(0)
		)

	-- 09/10/2009 Paul.  The indexes should be fully covered. 
	create index IDX_TASKS_CONTACTS_TASK_ID    on dbo.TASKS_CONTACTS (TASK_ID   , DELETED, CONTACT_ID, ACCEPT_STATUS, EMAIL_REMINDER_SENT, SMS_REMINDER_SENT)
	create index IDX_TASKS_CONTACTS_CONTACT_ID on dbo.TASKS_CONTACTS (CONTACT_ID, DELETED, TASK_ID   , ACCEPT_STATUS, EMAIL_REMINDER_SENT, SMS_REMINDER_SENT)

	alter table dbo.TASKS_CONTACTS add constraint FK_TASKS_CONTACTS_TASK_ID    foreign key ( TASK_ID    ) references dbo.TASKS    ( ID )
	alter table dbo.TASKS_CONTACTS add constraint FK_TASKS_CONTACTS_CONTACT_ID foreign key ( CONTACT_ID ) references dbo.CONTACTS ( ID )
  end
GO


