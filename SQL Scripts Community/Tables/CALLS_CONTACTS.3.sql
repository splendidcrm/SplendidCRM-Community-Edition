
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
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CALLS_CONTACTS' and COLUMN_NAME = 'EMAIL_REMINDER_SENT') begin -- then
	print 'alter table CALLS_CONTACTS add EMAIL_REMINDER_SENT bit null default(0)';
	alter table CALLS_CONTACTS add EMAIL_REMINDER_SENT bit null default(0);
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	exec dbo.spSqlTableDisableTriggers 'CALLS_CONTACTS';
	exec('update CALLS_CONTACTS set EMAIL_REMINDER_SENT = 0');
	exec dbo.spSqlTableEnableTriggers 'CALLS_CONTACTS';

	if exists (select * from sys.indexes where name = 'IDX_CALLS_CONTACTS_CALL_ID') begin -- then
		drop index IDX_CALLS_CONTACTS_CALL_ID    on CALLS_CONTACTS;
	end -- if;
	if exists (select * from sys.indexes where name = 'IDX_CALLS_CONTACTS_CONTACT_ID') begin -- then
		drop index IDX_CALLS_CONTACTS_CONTACT_ID on CALLS_CONTACTS;
	end -- if;

	create index IDX_CALLS_CONTACTS_CALL_ID    on dbo.CALLS_CONTACTS (CALL_ID   , DELETED, CONTACT_ID, ACCEPT_STATUS, EMAIL_REMINDER_SENT)
	create index IDX_CALLS_CONTACTS_CONTACT_ID on dbo.CALLS_CONTACTS (CONTACT_ID, DELETED, CALL_ID   , ACCEPT_STATUS, EMAIL_REMINDER_SENT)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CALLS_CONTACTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CALLS_CONTACTS_AUDIT' and COLUMN_NAME = 'EMAIL_REMINDER_SENT') begin -- then
		print 'alter table CALLS_CONTACTS_AUDIT add EMAIL_REMINDER_SENT bit null';
		alter table CALLS_CONTACTS_AUDIT add EMAIL_REMINDER_SENT bit null;
	end -- if;
end -- if;
GO

-- 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CALLS_CONTACTS' and COLUMN_NAME = 'SMS_REMINDER_SENT') begin -- then
	print 'alter table CALLS_CONTACTS add SMS_REMINDER_SENT bit null default(0)';
	alter table CALLS_CONTACTS add SMS_REMINDER_SENT bit null default(0);
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	exec dbo.spSqlTableDisableTriggers 'CALLS_CONTACTS';
	exec('update CALLS_CONTACTS set SMS_REMINDER_SENT = 0');
	exec dbo.spSqlTableEnableTriggers 'CALLS_CONTACTS';

	if exists (select * from sys.indexes where name = 'IDX_CALLS_CONTACTS_CALL_ID') begin -- then
		drop index IDX_CALLS_CONTACTS_CALL_ID    on CALLS_CONTACTS;
	end -- if;
	if exists (select * from sys.indexes where name = 'IDX_CALLS_CONTACTS_CONTACT_ID') begin -- then
		drop index IDX_CALLS_CONTACTS_CONTACT_ID on CALLS_CONTACTS;
	end -- if;

	create index IDX_CALLS_CONTACTS_CALL_ID    on dbo.CALLS_CONTACTS (CALL_ID   , DELETED, CONTACT_ID, ACCEPT_STATUS, EMAIL_REMINDER_SENT, SMS_REMINDER_SENT)
	create index IDX_CALLS_CONTACTS_CONTACT_ID on dbo.CALLS_CONTACTS (CONTACT_ID, DELETED, CALL_ID   , ACCEPT_STATUS, EMAIL_REMINDER_SENT, SMS_REMINDER_SENT)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CALLS_CONTACTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CALLS_CONTACTS_AUDIT' and COLUMN_NAME = 'SMS_REMINDER_SENT') begin -- then
		print 'alter table CALLS_CONTACTS_AUDIT add SMS_REMINDER_SENT bit null';
		alter table CALLS_CONTACTS_AUDIT add SMS_REMINDER_SENT bit null;
	end -- if;
end -- if;
GO

-- 04/30/2017 Paul.  Azure recommended index. 
if not exists (select * from sys.indexes where name = 'IDX_CALLS_CONTACTS_EMAIL_SENT') begin -- then
	create nonclustered index IDX_CALLS_CONTACTS_EMAIL_SENT on dbo.CALLS_CONTACTS (DELETED, EMAIL_REMINDER_SENT, CALL_ID) include (ACCEPT_STATUS, CONTACT_ID);
end -- if;
GO

