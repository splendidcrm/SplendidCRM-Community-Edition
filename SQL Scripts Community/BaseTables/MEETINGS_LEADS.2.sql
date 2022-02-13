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
-- 12/25/2012 Paul.  EMAIL_REMINDER_SENT was moved to relationship table so that it can be applied per recipient. 
-- 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'MEETINGS_LEADS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.MEETINGS_LEADS';
	Create Table dbo.MEETINGS_LEADS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_MEETINGS_LEADS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, MEETING_ID                         uniqueidentifier not null
		, LEAD_ID                            uniqueidentifier not null
		, REQUIRED                           bit null default(1)
		, ACCEPT_STATUS                      nvarchar(25) null default('none')
		, EMAIL_REMINDER_SENT                bit null default(0)
		, SMS_REMINDER_SENT                  bit null default(0)
		)

	create index IDX_MEETINGS_LEADS_MEETING_ID on dbo.MEETINGS_LEADS (MEETING_ID, DELETED, LEAD_ID, ACCEPT_STATUS, EMAIL_REMINDER_SENT, SMS_REMINDER_SENT)
	create index IDX_MEETINGS_LEADS_LEAD_ID    on dbo.MEETINGS_LEADS (LEAD_ID, DELETED, MEETING_ID, ACCEPT_STATUS, EMAIL_REMINDER_SENT, SMS_REMINDER_SENT)

	alter table dbo.MEETINGS_LEADS add constraint FK_MEETINGS_LEADS_MEETING_ID foreign key ( MEETING_ID ) references dbo.MEETINGS ( ID )
	alter table dbo.MEETINGS_LEADS add constraint FK_MEETINGS_LEADS_LEAD_ID    foreign key ( LEAD_ID    ) references dbo.LEADS    ( ID )
  end
GO


