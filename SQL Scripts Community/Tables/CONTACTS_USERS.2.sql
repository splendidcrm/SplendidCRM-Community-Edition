
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
-- 09/18/2015 Paul.  Add SERVICE_NAME to separate Exchange Folders from Contacts Sync. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS_USERS' and COLUMN_NAME = 'SERVICE_NAME') begin -- then
	print 'alter table CONTACTS_USERS alter column SERVICE_NAME nvarchar(25) null';

	if exists (select * from sys.indexes where name = 'IDX_CONTACTS_USERS_CONTACT_ID') begin -- then
		drop index IDX_CONTACTS_USERS_CONTACT_ID on CONTACTS_USERS;
	end -- if;
	if exists (select * from sys.indexes where name = 'IDX_CONTACTS_USERS_USER_ID') begin -- then
		drop index IDX_CONTACTS_USERS_USER_ID on CONTACTS_USERS;
	end -- if;

	alter table CONTACTS_USERS add SERVICE_NAME nvarchar(25) null;

	create index IDX_CONTACTS_USERS_CONTACT_ID on dbo.CONTACTS_USERS (CONTACT_ID, DELETED, USER_ID   , SERVICE_NAME);
	create index IDX_CONTACTS_USERS_USER_ID    on dbo.CONTACTS_USERS (USER_ID   , DELETED, CONTACT_ID, SERVICE_NAME);

	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'vwEXCHANGE_USERS') begin -- then
		exec('insert into CONTACTS_USERS(CONTACT_ID, USER_ID, SERVICE_NAME)
		select CONTACT_ID, USER_ID, N''Exchange''
		  from CONTACTS_USERS
		 where DELETED = 0
		   and USER_ID in (select ASSIGNED_USER_ID from vwEXCHANGE_USERS where vwEXCHANGE_USERS.ASSIGNED_USER_ID = CONTACTS_USERS.USER_ID)');
	end -- if;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CONTACTS_USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS_USERS_AUDIT' and COLUMN_NAME = 'SERVICE_NAME') begin -- then
		print 'alter table CONTACTS_USERS_AUDIT alter column SERVICE_NAME nvarchar(25) null';
		alter table CONTACTS_USERS_AUDIT add SERVICE_NAME nvarchar(25) null;
	end -- if;
end -- if;
GO

