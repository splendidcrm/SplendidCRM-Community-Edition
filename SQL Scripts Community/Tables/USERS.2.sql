
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
-- 04/21/2006 Paul.  IS_GROUP was added in SugarCRM 4.0.
-- 02/26/2008 Paul.  Increase USER_NAME so that an email can be used to login. 
-- 05/06/2009 Paul.  Add DEFAULT_TEAM to support SugarCRM migration. 
-- 09/15/2009 Paul.  Use new syntax to drop an index. 
-- Deprecated feature 'DROP INDEX with two-part name' is not supported in this version of SQL Server.
-- 11/21/2014 Paul.  Add User Picture. 
-- 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'IS_GROUP') begin -- then
	print 'alter table USERS add IS_GROUP bit null default(0)';
	alter table USERS add IS_GROUP bit null default(0);
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'USER_NAME' and CHARACTER_MAXIMUM_LENGTH < 60) begin -- then
	print 'alter table USERS alter column USER_NAME nvarchar(60) not null';
	if exists (select * from sys.indexes where name = 'IDX_USERS_USER_NAME') begin -- then
		drop index IDX_USERS_USER_NAME on USERS;
	end -- if;
	alter table USERS alter column USER_NAME nvarchar(60) null;
	create index IDX_USERS_USER_NAME  on dbo.USERS (USER_NAME, USER_HASH);
end -- if;
GO

-- 04/21/2008 Paul.  SugarCRM 5.0 has moved EMAIL1 and EMAIL2 to the EMAIL_ADDRESSES table.
-- We will eventually duplicate this behavior, but not now.  Add the fields if missing. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'EMAIL1') begin -- then
	print 'alter table USERS add EMAIL1 nvarchar(100) null';
	alter table USERS add EMAIL1 nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'EMAIL2') begin -- then
	print 'alter table USERS add EMAIL2 nvarchar(100) null';
	alter table USERS add EMAIL2 nvarchar(100) null;
end -- if;
GO

-- 04/21/2008 Paul.  SugarCRM 5.0 dropped USER_PASSWORD.  We will do so eventually. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'USER_PASSWORD') begin -- then
	print 'alter table USERS add USER_PASSWORD nvarchar(30) null';
	alter table USERS add USER_PASSWORD nvarchar(30) null;
end -- if;
GO

-- 07/16/2008 Paul.  Remove not null requirement on PORTAL_ONLY. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'PORTAL_ONLY' and IS_NULLABLE = 'NO') begin -- then
	print 'alter table USERS alter column PORTAL_ONLY bit null';
	alter table USERS alter column PORTAL_ONLY bit null;
end -- if;
GO

-- 08/08/2008 Paul.  Status should not be NULL. InsertNTLM was not setting the value. 
-- The problem with Status being null is that the user is not displayed in the Users list. 
if exists (select * from USERS where STATUS is null and DELETED = 0) begin -- then
	print 'Users STATUS should not be NULL. ';
	update USERS set STATUS = N'Active' where STATUS is null and DELETED = 0;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'DEFAULT_TEAM') begin -- then
	print 'alter table USERS add DEFAULT_TEAM uniqueidentifier null';
	alter table USERS add DEFAULT_TEAM uniqueidentifier null;
end -- if;
GO

-- 11/17/2009 Paul.  We have added DATE_MODIFIED_UTC to tables that are sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table USERS add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table USERS add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 03/16/2010 Paul.  Add IS_ADMIN_DELEGATE. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'IS_ADMIN_DELEGATE') begin -- then
	print 'alter table USERS add IS_ADMIN_DELEGATE bit null default(0)';
	alter table USERS add IS_ADMIN_DELEGATE bit null default(0);
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	exec dbo.spSqlTableDisableTriggers 'USERS';
	exec('update USERS set IS_ADMIN_DELEGATE = 0 where IS_ADMIN_DELEGATE is null and DELETED = 0');
	exec dbo.spSqlTableEnableTriggers 'USERS';
end -- if;
GO

-- 03/21/2010 Paul.  This code will also run on the Offline Client, so make sure that the USERS_AUDIT table exists. 
if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'IS_ADMIN_DELEGATE') begin -- then
		print 'alter table USERS_AUDIT add IS_ADMIN_DELEGATE bit null default(0)';
		alter table USERS_AUDIT add IS_ADMIN_DELEGATE bit null default(0);
	end -- if;
end -- if;
GO

-- 05/12/2010 Paul.  SYSTEM_GENERATED_PASSWORD and PWD_LAST_CHANGED are new to help manage forgotten passwrod. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'SYSTEM_GENERATED_PASSWORD') begin -- then
	print 'alter table USERS add SYSTEM_GENERATED_PASSWORD bit null';
	alter table USERS add SYSTEM_GENERATED_PASSWORD bit null;
end -- if;
GO

-- 07/09/2010 Paul.  This code will also run on the Offline Client, so make sure that the USERS_AUDIT table exists. 
if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'SYSTEM_GENERATED_PASSWORD') begin -- then
		print 'alter table USERS_AUDIT add SYSTEM_GENERATED_PASSWORD bit null';
		alter table USERS_AUDIT add SYSTEM_GENERATED_PASSWORD bit null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'PWD_LAST_CHANGED') begin -- then
	print 'alter table USERS add PWD_LAST_CHANGED datetime null';
	alter table USERS add PWD_LAST_CHANGED datetime null;
end -- if;
GO

-- 07/09/2010 Paul.  This code will also run on the Offline Client, so make sure that the USERS_AUDIT table exists. 
if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'PWD_LAST_CHANGED') begin -- then
		print 'alter table USERS_AUDIT add PWD_LAST_CHANGED datetime null';
		alter table USERS_AUDIT add PWD_LAST_CHANGED datetime null;
	end -- if;
end -- if;
GO

-- 07/09/2010 Paul.  Move the SMTP values from USER_PREFERENCES to the main table to make it easier to access. 
-- 07/09/2010 Paul.  SMTP values belong in the OUTBOUND_EMAILS table. 

-- 03/25/2011 Paul.  Add support for Google Apps. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'GOOGLEAPPS_SYNC_CONTACTS') begin -- then
	print 'alter table USERS add GOOGLEAPPS_SYNC_CONTACTS bit null';
	alter table USERS add GOOGLEAPPS_SYNC_CONTACTS bit null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'GOOGLEAPPS_SYNC_CONTACTS') begin -- then
		print 'alter table USERS_AUDIT add GOOGLEAPPS_SYNC_CONTACTS bit null';
		alter table USERS_AUDIT add GOOGLEAPPS_SYNC_CONTACTS bit null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'GOOGLEAPPS_SYNC_CALENDAR') begin -- then
	print 'alter table USERS add GOOGLEAPPS_SYNC_CALENDAR bit null';
	alter table USERS add GOOGLEAPPS_SYNC_CALENDAR bit null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'GOOGLEAPPS_SYNC_CALENDAR') begin -- then
		print 'alter table USERS_AUDIT add GOOGLEAPPS_SYNC_CALENDAR bit null';
		alter table USERS_AUDIT add GOOGLEAPPS_SYNC_CALENDAR bit null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'GOOGLEAPPS_USERNAME') begin -- then
	print 'alter table USERS add GOOGLEAPPS_USERNAME nvarchar(100) null';
	alter table USERS add GOOGLEAPPS_USERNAME nvarchar(100) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'GOOGLEAPPS_USERNAME') begin -- then
		print 'alter table USERS_AUDIT add GOOGLEAPPS_USERNAME nvarchar(100) null';
		alter table USERS_AUDIT add GOOGLEAPPS_USERNAME nvarchar(100) null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'GOOGLEAPPS_PASSWORD') begin -- then
	print 'alter table USERS add GOOGLEAPPS_PASSWORD nvarchar(100) null';
	alter table USERS add GOOGLEAPPS_PASSWORD nvarchar(100) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'GOOGLEAPPS_PASSWORD') begin -- then
		print 'alter table USERS_AUDIT add GOOGLEAPPS_PASSWORD nvarchar(100) null';
		alter table USERS_AUDIT add GOOGLEAPPS_PASSWORD nvarchar(100) null;
	end -- if;
end -- if;
GO

-- 03/25/2011 Paul.  Create a separate field for the Facebook ID. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'FACEBOOK_ID') begin -- then
	print 'alter table USERS add FACEBOOK_ID nvarchar(25) null';
	alter table USERS add FACEBOOK_ID nvarchar(25) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'FACEBOOK_ID') begin -- then
		print 'alter table USERS_AUDIT add FACEBOOK_ID nvarchar(25) null';
		alter table USERS_AUDIT add FACEBOOK_ID nvarchar(25) null;
	end -- if;
end -- if;
GO

-- 12/13/2011 Paul.  Add support for Apple iCloud. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'ICLOUD_SYNC_CONTACTS') begin -- then
	print 'alter table USERS add ICLOUD_SYNC_CONTACTS bit null';
	alter table USERS add ICLOUD_SYNC_CONTACTS bit null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'ICLOUD_SYNC_CONTACTS') begin -- then
		print 'alter table USERS_AUDIT add ICLOUD_SYNC_CONTACTS bit null';
		alter table USERS_AUDIT add ICLOUD_SYNC_CONTACTS bit null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'ICLOUD_SYNC_CALENDAR') begin -- then
	print 'alter table USERS add ICLOUD_SYNC_CALENDAR bit null';
	alter table USERS add ICLOUD_SYNC_CALENDAR bit null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'ICLOUD_SYNC_CALENDAR') begin -- then
		print 'alter table USERS_AUDIT add ICLOUD_SYNC_CALENDAR bit null';
		alter table USERS_AUDIT add ICLOUD_SYNC_CALENDAR bit null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'ICLOUD_USERNAME') begin -- then
	print 'alter table USERS add ICLOUD_USERNAME nvarchar(100) null';
	alter table USERS add ICLOUD_USERNAME nvarchar(100) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'ICLOUD_USERNAME') begin -- then
		print 'alter table USERS_AUDIT add ICLOUD_USERNAME nvarchar(100) null';
		alter table USERS_AUDIT add ICLOUD_USERNAME nvarchar(100) null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'ICLOUD_PASSWORD') begin -- then
	print 'alter table USERS add ICLOUD_PASSWORD nvarchar(100) null';
	alter table USERS add ICLOUD_PASSWORD nvarchar(100) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'ICLOUD_PASSWORD') begin -- then
		print 'alter table USERS_AUDIT add ICLOUD_PASSWORD nvarchar(100) null';
		alter table USERS_AUDIT add ICLOUD_PASSWORD nvarchar(100) null;
	end -- if;
end -- if;
GO

-- 12/23/2011 Paul.  We need separate CTAGs for Contacts and Calendar. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'ICLOUD_CTAG_CONTACTS') begin -- then
	print 'alter table USERS add ICLOUD_CTAG_CONTACTS varchar(100) null';
	alter table USERS add ICLOUD_CTAG_CONTACTS varchar(100) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'ICLOUD_CTAG_CONTACTS') begin -- then
		print 'alter table USERS_AUDIT add ICLOUD_CTAG_CONTACTS varchar(100) null';
		alter table USERS_AUDIT add ICLOUD_CTAG_CONTACTS varchar(100) null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'ICLOUD_CTAG_CALENDAR') begin -- then
	print 'alter table USERS add ICLOUD_CTAG_CALENDAR varchar(100) null';
	alter table USERS add ICLOUD_CTAG_CALENDAR varchar(100) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'ICLOUD_CTAG_CALENDAR') begin -- then
		print 'alter table USERS_AUDIT add ICLOUD_CTAG_CALENDAR varchar(100) null';
		alter table USERS_AUDIT add ICLOUD_CTAG_CALENDAR varchar(100) null;
	end -- if;
end -- if;
GO

-- 12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'DATE_FORMAT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'THEME') begin -- then
		print 'alter table USERS add THEME nvarchar(25) null';
		alter table USERS add THEME nvarchar(25) null;
	end -- if;
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'DATE_FORMAT') begin -- then
		print 'alter table USERS add DATE_FORMAT nvarchar(25) null';
		alter table USERS add DATE_FORMAT nvarchar(25) null;
	end -- if;
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'TIME_FORMAT') begin -- then
		print 'alter table USERS add TIME_FORMAT nvarchar(25) null';
		alter table USERS add TIME_FORMAT nvarchar(25) null;
	end -- if;
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'LANG') begin -- then
		print 'alter table USERS add LANG nvarchar(10) null';
		alter table USERS add LANG nvarchar(10) null;
	end -- if;
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'CURRENCY_ID') begin -- then
		print 'alter table USERS add CURRENCY_ID uniqueidentifier null';
		alter table USERS add CURRENCY_ID uniqueidentifier null;
	end -- if;
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'TIMEZONE_ID') begin -- then
		print 'alter table USERS add TIMEZONE_ID uniqueidentifier null';
		alter table USERS add TIMEZONE_ID uniqueidentifier null;
	end -- if;
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'SAVE_QUERY') begin -- then
		print 'alter table USERS add SAVE_QUERY bit null';
		alter table USERS add SAVE_QUERY bit null;
	end -- if;
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'GROUP_TABS') begin -- then
		print 'alter table USERS add GROUP_TABS bit null';
		alter table USERS add GROUP_TABS bit null;
	end -- if;
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'SUBPANEL_TABS') begin -- then
		print 'alter table USERS add SUBPANEL_TABS bit null';
		alter table USERS add SUBPANEL_TABS bit null;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
		if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'THEME') begin -- then
			print 'alter table USERS_AUDIT add THEME nvarchar(25) null';
			alter table USERS_AUDIT add THEME nvarchar(25) null;
		end -- if;
		if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'DATE_FORMAT') begin -- then
			print 'alter table USERS_AUDIT add DATE_FORMAT nvarchar(25) null';
			alter table USERS_AUDIT add DATE_FORMAT nvarchar(25) null;
		end -- if;
		if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'TIME_FORMAT') begin -- then
			print 'alter table USERS_AUDIT add TIME_FORMAT nvarchar(25) null';
			alter table USERS_AUDIT add TIME_FORMAT nvarchar(25) null;
		end -- if;
		if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'LANG') begin -- then
			print 'alter table USERS_AUDIT add LANG nvarchar(10) null';
			alter table USERS_AUDIT add LANG nvarchar(10) null;
		end -- if;
		if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'CURRENCY_ID') begin -- then
			print 'alter table USERS_AUDIT add CURRENCY_ID uniqueidentifier null';
			alter table USERS_AUDIT add CURRENCY_ID uniqueidentifier null;
		end -- if;
		if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'TIMEZONE_ID') begin -- then
			print 'alter table USERS_AUDIT add TIMEZONE_ID uniqueidentifier null';
			alter table USERS_AUDIT add TIMEZONE_ID uniqueidentifier null;
		end -- if;
		if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'SAVE_QUERY') begin -- then
			print 'alter table USERS_AUDIT add SAVE_QUERY bit null';
			alter table USERS_AUDIT add SAVE_QUERY bit null;
		end -- if;
		if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'GROUP_TABS') begin -- then
			print 'alter table USERS_AUDIT add GROUP_TABS bit null';
			alter table USERS_AUDIT add GROUP_TABS bit null;
		end -- if;
		if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'SUBPANEL_TABS') begin -- then
			print 'alter table USERS_AUDIT add SUBPANEL_TABS bit null';
			alter table USERS_AUDIT add SUBPANEL_TABS bit null;
		end -- if;
	end -- if;
	-- 02/09/2013 Paul.  SAVE_QUERY should default to 1 when upgrading from version 2.x.
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	exec dbo.spSqlTableDisableTriggers 'USERS';
	exec('update USERS
	   set THEME             =         isnull(nullif(dbo.fnXmlValue(USER_PREFERENCES, ''theme''        ), ''''), dbo.fnCONFIG_String(''default_theme''        ))
	     , DATE_FORMAT       =         isnull(nullif(dbo.fnXmlValue(USER_PREFERENCES, ''dateformat''   ), ''''), dbo.fnCONFIG_String(''default_date_format''  ))
	     , TIME_FORMAT       =         isnull(nullif(dbo.fnXmlValue(USER_PREFERENCES, ''timeformat''   ), ''''), dbo.fnCONFIG_String(''default_time_format''  ))
	     , LANG              = replace(isnull(nullif(dbo.fnXmlValue(USER_PREFERENCES, ''culture''      ), ''''), dbo.fnCONFIG_String(''default_language''     )), ''_'', ''-'')
	     , CURRENCY_ID       = cast(   isnull(nullif(dbo.fnXmlValue(USER_PREFERENCES, ''currency_id''  ), ''''), dbo.fnCONFIG_String(''default_currency''     )) as uniqueidentifier)
	     , TIMEZONE_ID       = cast(   isnull(nullif(dbo.fnXmlValue(USER_PREFERENCES, ''timezone''     ), ''''), dbo.fnCONFIG_String(''default_timezone''     )) as uniqueidentifier)
	     , SAVE_QUERY        = (case   isnull(nullif(dbo.fnXmlValue(USER_PREFERENCES, ''save_query''   ), ''''), dbo.fnCONFIG_String(''save_query''           )) when ''true'' then 1 when ''1'' then 1 else 1 end)
	     , GROUP_TABS        = (case   isnull(nullif(dbo.fnXmlValue(USER_PREFERENCES, ''group_tabs''   ), ''''), dbo.fnCONFIG_String(''default_group_tabs''   )) when ''true'' then 1 when ''1'' then 1 else 0 end)
	     , SUBPANEL_TABS     = (case   isnull(nullif(dbo.fnXmlValue(USER_PREFERENCES, ''subpanel_tabs''), ''''), dbo.fnCONFIG_String(''default_subpanel_tabs'')) when ''true'' then 1 when ''1'' then 1 else 0 end)
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	');
	-- 07/25/2015 Paul.  SugarClassic and Sugar2006 were moved long ago.  We need to change the default to prevent app crash. 
	exec('update USERS
	   set THEME             = ''Seven''
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where THEME in (''SugarClassic'', ''Sugar2006'')
	');
	exec dbo.spSqlTableEnableTriggers 'USERS';
end -- if;
GO


-- 08/24/2013 Paul.  Add EXTENSION_C in preparation for Asterisk click-to-call. 
-- 09/20/2013 Paul.  Move EXTENSION to the main table. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'EXTENSION') begin -- then
	print 'alter table USERS add EXTENSION nvarchar(25) null';
	alter table USERS add EXTENSION nvarchar(25) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'EXTENSION') begin -- then
		print 'alter table USERS_AUDIT add EXTENSION nvarchar(25) null';
		alter table USERS_AUDIT add EXTENSION nvarchar(25) null;
	end -- if;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'EXTENSION' and DATA_TYPE = 'varchar') begin -- then
	print 'alter table USERS alter column EXTENSION nvarchar(25) null';
	alter table USERS alter column EXTENSION nvarchar(25) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'EXTENSION' and DATA_TYPE = 'varchar') begin -- then
		print 'alter table USERS_AUDIT alter column EXTENSION nvarchar(25) null';
		alter table USERS_AUDIT alter column EXTENSION nvarchar(25) null;
	end -- if;
end -- if;
GO

-- 09/27/2013 Paul.  SMS messages need to be opt-in. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'SMS_OPT_IN') begin -- then
	print 'alter table USERS add SMS_OPT_IN nvarchar(25) null';
	alter table USERS add SMS_OPT_IN nvarchar(25) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'SMS_OPT_IN') begin -- then
		print 'alter table USERS_AUDIT add SMS_OPT_IN nvarchar(25) null';
		alter table USERS_AUDIT add SMS_OPT_IN nvarchar(25) null;
	end -- if;
end -- if;
GO

-- 11/21/2014 Paul.  Add User Picture. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'PICTURE') begin -- then
	print 'alter table USERS add PICTURE nvarchar(max) null';
	alter table USERS add PICTURE nvarchar(max) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'PICTURE') begin -- then
		print 'alter table USERS_AUDIT add PICTURE nvarchar(max) null';
		alter table USERS_AUDIT add PICTURE nvarchar(max) null;
	end -- if;
end -- if;
GO

-- 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS' and COLUMN_NAME = 'PRIMARY_ROLE_ID') begin -- then
	print 'alter table USERS add PRIMARY_ROLE_ID uniqueidentifier null';
	alter table USERS add PRIMARY_ROLE_ID uniqueidentifier null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_AUDIT' and COLUMN_NAME = 'PRIMARY_ROLE_ID') begin -- then
		print 'alter table USERS_AUDIT add PRIMARY_ROLE_ID uniqueidentifier null';
		alter table USERS_AUDIT add PRIMARY_ROLE_ID uniqueidentifier null;
	end -- if;
end -- if;
GO
