
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
-- 12/24/2012 Paul.  Add REMINDER_DISMISSED flag. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MEETINGS_USERS' and COLUMN_NAME = 'REMINDER_DISMISSED') begin -- then
	print 'alter table MEETINGS_USERS add REMINDER_DISMISSED bit null default(0)';
	alter table MEETINGS_USERS add REMINDER_DISMISSED bit null default(0);
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	exec dbo.spSqlTableDisableTriggers 'MEETINGS_USERS';
	exec('update MEETINGS_USERS set REMINDER_DISMISSED = 0');
	exec dbo.spSqlTableEnableTriggers 'MEETINGS_USERS';
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'MEETINGS_USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MEETINGS_USERS_AUDIT' and COLUMN_NAME = 'REMINDER_DISMISSED') begin -- then
		print 'alter table MEETINGS_USERS_AUDIT add REMINDER_DISMISSED bit null';
		alter table MEETINGS_USERS_AUDIT add REMINDER_DISMISSED bit null;
	end -- if;
end -- if;
GO

-- 12/25/2012 Paul.  EMAIL_REMINDER_SENT was moved to relationship table so that it can be applied per recipient. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MEETINGS_USERS' and COLUMN_NAME = 'EMAIL_REMINDER_SENT') begin -- then
	print 'alter table MEETINGS_USERS add EMAIL_REMINDER_SENT bit null default(0)';
	alter table MEETINGS_USERS add EMAIL_REMINDER_SENT bit null default(0);
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	exec dbo.spSqlTableDisableTriggers 'MEETINGS_USERS';
	exec('update MEETINGS_USERS set EMAIL_REMINDER_SENT = 0');
	exec dbo.spSqlTableEnableTriggers 'MEETINGS_USERS';

	if exists (select * from sys.indexes where name = 'IDX_MEETINGS_USERS_MEETING_ID') begin -- then
		drop index IDX_MEETINGS_USERS_MEETING_ID on MEETINGS_USERS;
	end -- if;
	if exists (select * from sys.indexes where name = 'IDX_MEETINGS_USERS_USER_ID') begin -- then
		drop index IDX_MEETINGS_USERS_USER_ID    on MEETINGS_USERS;
	end -- if;

	create index IDX_MEETINGS_USERS_MEETING_ID on dbo.MEETINGS_USERS (MEETING_ID, DELETED, USER_ID   , ACCEPT_STATUS, REMINDER_DISMISSED, EMAIL_REMINDER_SENT)
	create index IDX_MEETINGS_USERS_USER_ID    on dbo.MEETINGS_USERS (USER_ID   , DELETED, MEETING_ID, ACCEPT_STATUS, REMINDER_DISMISSED, EMAIL_REMINDER_SENT)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'MEETINGS_USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MEETINGS_USERS_AUDIT' and COLUMN_NAME = 'EMAIL_REMINDER_SENT') begin -- then
		print 'alter table MEETINGS_USERS_AUDIT add EMAIL_REMINDER_SENT bit null';
		alter table MEETINGS_USERS_AUDIT add EMAIL_REMINDER_SENT bit null;
	end -- if;
end -- if;
GO

-- 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MEETINGS_USERS' and COLUMN_NAME = 'SMS_REMINDER_SENT') begin -- then
	print 'alter table MEETINGS_USERS add SMS_REMINDER_SENT bit null default(0)';
	alter table MEETINGS_USERS add SMS_REMINDER_SENT bit null default(0);
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	exec dbo.spSqlTableDisableTriggers 'MEETINGS_USERS';
	exec('update MEETINGS_USERS set SMS_REMINDER_SENT = 0');
	exec dbo.spSqlTableEnableTriggers 'MEETINGS_USERS';

	if exists (select * from sys.indexes where name = 'IDX_MEETINGS_USERS_MEETING_ID') begin -- then
		drop index IDX_MEETINGS_USERS_MEETING_ID on MEETINGS_USERS;
	end -- if;
	if exists (select * from sys.indexes where name = 'IDX_MEETINGS_USERS_USER_ID') begin -- then
		drop index IDX_MEETINGS_USERS_USER_ID    on MEETINGS_USERS;
	end -- if;

	create index IDX_MEETINGS_USERS_MEETING_ID on dbo.MEETINGS_USERS (MEETING_ID, DELETED, USER_ID   , ACCEPT_STATUS, REMINDER_DISMISSED, EMAIL_REMINDER_SENT, SMS_REMINDER_SENT)
	create index IDX_MEETINGS_USERS_USER_ID    on dbo.MEETINGS_USERS (USER_ID   , DELETED, MEETING_ID, ACCEPT_STATUS, REMINDER_DISMISSED, EMAIL_REMINDER_SENT, SMS_REMINDER_SENT)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'MEETINGS_USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MEETINGS_USERS_AUDIT' and COLUMN_NAME = 'SMS_REMINDER_SENT') begin -- then
		print 'alter table MEETINGS_USERS_AUDIT add SMS_REMINDER_SENT bit null';
		alter table MEETINGS_USERS_AUDIT add SMS_REMINDER_SENT bit null;
	end -- if;
end -- if;
GO

