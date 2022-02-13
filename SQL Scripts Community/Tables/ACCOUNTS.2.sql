
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
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 12/25/2007 Paul.  CAMPAIGN_ID was added in SugarCRM 4.5.1
-- 05/24/2015 Paul.  Add Picture. 
-- 10/27/2017 Paul.  Add Accounts as email source. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table ACCOUNTS add TEAM_ID uniqueidentifier null';
	alter table ACCOUNTS add TEAM_ID uniqueidentifier null;

	create index IDX_ACCOUNTS_TEAM_ID on dbo.ACCOUNTS (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS' and COLUMN_NAME = 'CAMPAIGN_ID') begin -- then
	print 'alter table ACCOUNTS add CAMPAIGN_ID uniqueidentifier null';
	alter table ACCOUNTS add CAMPAIGN_ID uniqueidentifier null;
end -- if;
GO

-- 04/21/2008 Paul.  SugarCRM 5.0 has moved EMAIL1 and EMAIL2 to the EMAIL_ADDRESSES table.
-- We will eventually duplicate this behavior, but not now.  Add the fields if missing. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS' and COLUMN_NAME = 'EMAIL1') begin -- then
	print 'alter table ACCOUNTS add EMAIL1 nvarchar(100) null';
	alter table ACCOUNTS add EMAIL1 nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS' and COLUMN_NAME = 'EMAIL2') begin -- then
	print 'alter table ACCOUNTS add EMAIL2 nvarchar(100) null';
	alter table ACCOUNTS add EMAIL2 nvarchar(100) null;
end -- if;
GO

-- 07/26/2009 Paul.  Enough customers requested ACCOUNT_NUMBER that it makes sense to add it now. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS' and COLUMN_NAME = 'ACCOUNT_NUMBER') begin -- then
	print 'alter table ACCOUNTS add ACCOUNT_NUMBER nvarchar(30) null';
	alter table ACCOUNTS add ACCOUNT_NUMBER nvarchar(30) null;
	exec ('create index IDX_ACCOUNTS_NUMBER           on dbo.ACCOUNTS (ACCOUNT_NUMBER, ID, DELETED)');
end -- if;
GO

-- 07/26/2009 Paul.  We did not have an index on the account name. This is a popular search, so it should be added. 
if not exists (select * from sys.indexes where name = 'IDX_ACCOUNTS_NAME') begin -- then
	print 'create index IDX_ACCOUNTS_NAME';
	create index IDX_ACCOUNTS_NAME             on dbo.ACCOUNTS (NAME, ID, DELETED);
end -- if;
GO

-- 08/08/2009 Paul.  We also need to change the field in the audit table. 
-- 09/14/2009 Paul.  Only alter if the audit table exists. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS_AUDIT' and COLUMN_NAME = 'ACCOUNT_NUMBER') begin -- then
		print 'alter table ACCOUNTS_AUDIT add ACCOUNT_NUMBER nvarchar(30) null';
		alter table ACCOUNTS_AUDIT add ACCOUNT_NUMBER nvarchar(30) null;
	end -- if;
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table ACCOUNTS add TEAM_SET_ID uniqueidentifier null';
	alter table ACCOUNTS add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_ACCOUNTS_TEAM_SET_ID on dbo.ACCOUNTS (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table ACCOUNTS add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table ACCOUNTS add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 05/24/2015 Paul.  Add Picture. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS' and COLUMN_NAME = 'PICTURE') begin -- then
	print 'alter table ACCOUNTS add PICTURE nvarchar(max) null';
	alter table ACCOUNTS add PICTURE nvarchar(max) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ACCOUNTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS_AUDIT' and COLUMN_NAME = 'PICTURE') begin -- then
		print 'alter table ACCOUNTS_AUDIT add PICTURE nvarchar(max) null';
		alter table ACCOUNTS_AUDIT add PICTURE nvarchar(max) null;
	end -- if;
end -- if;
GO

-- 10/27/2017 Paul.  Add Accounts as email source. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS' and COLUMN_NAME = 'DO_NOT_CALL') begin -- then
	print 'alter table ACCOUNTS add DO_NOT_CALL bit null';
	alter table ACCOUNTS add DO_NOT_CALL bit null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ACCOUNTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS_AUDIT' and COLUMN_NAME = 'DO_NOT_CALL') begin -- then
		print 'alter table ACCOUNTS_AUDIT add DO_NOT_CALL bit null';
		alter table ACCOUNTS_AUDIT add DO_NOT_CALL bit null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS' and COLUMN_NAME = 'EMAIL_OPT_OUT') begin -- then
	print 'alter table ACCOUNTS add EMAIL_OPT_OUT bit null';
	alter table ACCOUNTS add EMAIL_OPT_OUT bit null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ACCOUNTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS_AUDIT' and COLUMN_NAME = 'EMAIL_OPT_OUT') begin -- then
		print 'alter table ACCOUNTS_AUDIT add EMAIL_OPT_OUT bit null';
		alter table ACCOUNTS_AUDIT add EMAIL_OPT_OUT bit null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS' and COLUMN_NAME = 'INVALID_EMAIL') begin -- then
	print 'alter table ACCOUNTS add INVALID_EMAIL bit null';
	alter table ACCOUNTS add INVALID_EMAIL bit null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ACCOUNTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS_AUDIT' and COLUMN_NAME = 'INVALID_EMAIL') begin -- then
		print 'alter table ACCOUNTS_AUDIT add INVALID_EMAIL bit null';
		alter table ACCOUNTS_AUDIT add INVALID_EMAIL bit null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table ACCOUNTS add ASSIGNED_SET_ID uniqueidentifier null';
	alter table ACCOUNTS add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_ACCOUNTS_ASSIGNED_SET_ID on dbo.ACCOUNTS (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ACCOUNTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ACCOUNTS_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table ACCOUNTS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table ACCOUNTS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

