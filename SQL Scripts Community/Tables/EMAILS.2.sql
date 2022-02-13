
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
-- 09/06/2005 Paul.  Version 3.5.0 added the DESCRIPTION_HTML field. 
-- 09/06/2005 Paul.  Allow nulls
-- 04/16/2006 Paul.  The NAME is not required.  An email can be sent without an email. 
-- 04/21/2006 Paul.  MESSAGE_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  REPLY_TO_NAME was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  REPLY_TO_ADDR was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  INTENT was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  MAILBOX_ID was added in SugarCRM 4.0.
-- 05/30/2006 Paul.  MESSAGE_ID is a nvarchar(100) in SugarCRM 4.2
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 01/13/2008 Paul.  Add RAW_SOURCE was added in SugarCRM 4.5.0.
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 09/15/2009 Paul.  Use new syntax to drop an index. 
-- 02/11/2017 Paul.  New index based on missing indexes query. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 07/09/2018 Paul.  New index for archival based on date. 

-- Deprecated feature 'DROP INDEX with two-part name' is not supported in this version of SQL Server.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'DESCRIPTION_HTML') begin -- then
	print 'alter table EMAILS add DESCRIPTION_HTML nvarchar(max) null';
	alter table EMAILS add DESCRIPTION_HTML nvarchar(max) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'DATE_START' and IS_NULLABLE = 'NO') begin -- then
	print 'alter table EMAILS alter column DATE_START datetime null';
	alter table EMAILS alter column DATE_START datetime null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'NAME' and IS_NULLABLE = 'NO') begin -- then
	print 'alter table EMAILS alter column NAME nvarchar(255) null';
	alter table EMAILS alter column NAME nvarchar(255) null;
end -- if;
GO

-- 11/01/2010 Paul.  Increase length of MESSAGE_ID to 851 to allow for IMAP value + login + server. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'MESSAGE_ID' and DATA_TYPE = 'uniqueidentifier') begin -- then
-- #if SQL_Server /*
	-- 06/28/2006 Paul.  We need to drop the index before we can drop the column. 
	if exists (select * from sys.indexes where name = 'IDX_EMAILS_MESSAGE_ID') begin -- then
		print 'drop index IDX_EMAILS_MESSAGE_ID';
		drop index IDX_EMAILS_MESSAGE_ID on EMAILS;
	end -- if;
-- #endif SQL_Server */
	print 'alter table EMAILS drop column MESSAGE_ID';
	alter table EMAILS drop column MESSAGE_ID;
end -- if;
GO

-- 11/01/2010 Paul.  Increase length of MESSAGE_ID to 851 to allow for IMAP value + login + server. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'MESSAGE_ID') begin -- then
	print 'alter table EMAILS add MESSAGE_ID varchar(851) null';
	alter table EMAILS add MESSAGE_ID varchar(851) null;

	create index IDX_EMAILS_MESSAGE_ID on dbo.EMAILS (MESSAGE_ID, DELETED, ID)
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'REPLY_TO_NAME') begin -- then
	print 'alter table EMAILS add REPLY_TO_NAME nvarchar(100) null';
	alter table EMAILS add REPLY_TO_NAME nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'REPLY_TO_ADDR') begin -- then
	print 'alter table EMAILS add REPLY_TO_ADDR nvarchar(100) null';
	alter table EMAILS add REPLY_TO_ADDR nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'INTENT') begin -- then
	print 'alter table EMAILS add INTENT nvarchar(25) null default(''pick'')';
	alter table EMAILS add INTENT nvarchar(25) null default('pick');
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'MAILBOX_ID') begin -- then
	print 'alter table EMAILS add MAILBOX_ID uniqueidentifier null';
	alter table EMAILS add MAILBOX_ID uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table EMAILS add TEAM_ID uniqueidentifier null';
	alter table EMAILS add TEAM_ID uniqueidentifier null;

	create index IDX_EMAILS_TEAM_ID on dbo.EMAILS (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'RAW_SOURCE') begin -- then
	print 'alter table EMAILS add RAW_SOURCE nvarchar(max) null';
	alter table EMAILS add RAW_SOURCE nvarchar(max) null;
end -- if;
GO

-- 04/21/2008 Paul.  SugarCRM 5.0 has dropped TIME_START and combined it with DATE_START. 
-- We did this long ago, but we kept the use of TIME_START for compatibility with MySQL. 
-- We will eventually duplicate this behavior, but not now.  Add the fields if missing. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'TIME_START') begin -- then
	print 'alter table EMAILS add TIME_START datetime null';
	alter table EMAILS add TIME_START datetime null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'DATE_START') begin -- then
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'DATE_SENT') begin -- then
		print 'alter table EMAILS rename DATE_SENT to DATE_START';
		exec sp_rename 'EMAILS.DATE_SENT', 'DATE_START', 'COLUMN';
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'DESCRIPTION') begin -- then
	print 'alter table EMAILS add DESCRIPTION nvarchar(max) null';
	alter table EMAILS add DESCRIPTION nvarchar(max) null;
end -- if;
GO

-- 04/21/2008 Paul.  SugarCRM 5.0 has moved the email fields to a separate table. 
-- We will eventually duplicate this behavior, but not now.  Add the fields if missing. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'FROM_ADDR') begin -- then
	print 'alter table EMAILS add FROM_ADDR                          nvarchar(100) null';
	alter table EMAILS add FROM_ADDR                          nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'FROM_NAME') begin -- then
	print 'alter table EMAILS add FROM_NAME                          nvarchar(100) null';
	alter table EMAILS add FROM_NAME                          nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'TO_ADDRS') begin -- then
	print 'alter table EMAILS add TO_ADDRS                           nvarchar(max) null';
	alter table EMAILS add TO_ADDRS                           nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'CC_ADDRS') begin -- then
	print 'alter table EMAILS add CC_ADDRS                           nvarchar(max) null';
	alter table EMAILS add CC_ADDRS                           nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'BCC_ADDRS') begin -- then
	print 'alter table EMAILS add BCC_ADDRS                          nvarchar(max) null';
	alter table EMAILS add BCC_ADDRS                          nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'TO_ADDRS_IDS') begin -- then
	print 'alter table EMAILS add TO_ADDRS_IDS                       nvarchar(max) null';
	alter table EMAILS add TO_ADDRS_IDS                       nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'TO_ADDRS_NAMES') begin -- then
	print 'alter table EMAILS add TO_ADDRS_NAMES                     nvarchar(max) null';
	alter table EMAILS add TO_ADDRS_NAMES                     nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'TO_ADDRS_EMAILS') begin -- then
	print 'alter table EMAILS add TO_ADDRS_EMAILS                    nvarchar(max) null';
	alter table EMAILS add TO_ADDRS_EMAILS                    nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'CC_ADDRS_IDS') begin -- then
	print 'alter table EMAILS add CC_ADDRS_IDS                       nvarchar(max) null';
	alter table EMAILS add CC_ADDRS_IDS                       nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'CC_ADDRS_NAMES') begin -- then
	print 'alter table EMAILS add CC_ADDRS_NAMES                     nvarchar(max) null';
	alter table EMAILS add CC_ADDRS_NAMES                     nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'CC_ADDRS_EMAILS') begin -- then
	print 'alter table EMAILS add CC_ADDRS_EMAILS                    nvarchar(max) null';
	alter table EMAILS add CC_ADDRS_EMAILS                    nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'BCC_ADDRS_IDS') begin -- then
	print 'alter table EMAILS add BCC_ADDRS_IDS                      nvarchar(max) null';
	alter table EMAILS add BCC_ADDRS_IDS                      nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'BCC_ADDRS_NAMES') begin -- then
	print 'alter table EMAILS add BCC_ADDRS_NAMES                    nvarchar(max) null';
	alter table EMAILS add BCC_ADDRS_NAMES                    nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'BCC_ADDRS_EMAILS') begin -- then
	print 'alter table EMAILS add BCC_ADDRS_EMAILS                   nvarchar(max) null';
	alter table EMAILS add BCC_ADDRS_EMAILS                   nvarchar(max) null;
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table EMAILS add TEAM_SET_ID uniqueidentifier null';
	alter table EMAILS add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_EMAILS_TEAM_SET_ID on dbo.EMAILS (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID);
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table EMAILS add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table EMAILS add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 11/01/2010 Paul.  Increase length of MESSAGE_ID to varchar(851) to allow for IMAP value + login + server. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'MESSAGE_ID' and CHARACTER_OCTET_LENGTH < 851) begin -- then
-- #if SQL_Server /*
	if exists (select * from sys.indexes where name = 'IDX_EMAILS_MESSAGE_ID') begin -- then
		print 'drop index IDX_EMAILS_MESSAGE_ID';
		drop index IDX_EMAILS_MESSAGE_ID on EMAILS;
	end -- if;
-- #endif SQL_Server */
	print 'alter table EMAILS alter column MESSAGE_ID varchar(851) collate SQL_Latin1_General_CP1_CS_AS null';
	alter table EMAILS alter column MESSAGE_ID varchar(851) collate SQL_Latin1_General_CP1_CS_AS null;

	create index IDX_EMAILS_MESSAGE_ID on dbo.EMAILS (MESSAGE_ID, DELETED, ID);
end -- if;
GO

-- 11/04/2010 Paul.  We must also increase the size in the audit table. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS_AUDIT' and COLUMN_NAME = 'MESSAGE_ID' and CHARACTER_OCTET_LENGTH < 851) begin -- then
	print 'alter table EMAILS_AUDIT alter column MESSAGE_ID varchar(851) null';
	alter table EMAILS_AUDIT alter column MESSAGE_ID varchar(851) null;
end -- if;
GO

-- 11/04/2010 Paul.  It looks like the MESSAGE_ID could be case-significant.  Lets set the collation just to be safe. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'MESSAGE_ID' and COLLATION_NAME = 'SQL_Latin1_General_CP1_CI_AS') begin -- then
-- #if SQL_Server /*
	if exists (select * from sys.indexes where name = 'IDX_EMAILS_MESSAGE_ID') begin -- then
		print 'drop index IDX_EMAILS_MESSAGE_ID';
		drop index IDX_EMAILS_MESSAGE_ID on EMAILS;
	end -- if;
-- #endif SQL_Server */
	print 'alter table EMAILS alter column MESSAGE_ID varchar(851) collate SQL_Latin1_General_CP1_CS_AS not null';
	alter table EMAILS alter column MESSAGE_ID varchar(851) collate SQL_Latin1_General_CP1_CS_AS null;

	create index IDX_EMAILS_MESSAGE_ID on dbo.EMAILS (MESSAGE_ID, DELETED, ID);
end -- if;
GO

-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from sys.indexes where name = 'IDX_EMAILS_DELETED_PARENT') begin -- then
	print 'create index IDX_EMAILS_DELETED_PARENT';
	create index IDX_EMAILS_DELETED_PARENT on dbo.EMAILS (DELETED, PARENT_TYPE, PARENT_ID)
end -- if;
GO

-- 04/30/2017 Paul.  Azure recommended index. 
if not exists (select * from sys.indexes where name = 'IDX_EMAILS_TYPE_STATUS') begin -- then
	create nonclustered index IDX_EMAILS_TYPE_STATUS on dbo.EMAILS (DELETED, TYPE, STATUS) include (DATE_MODIFIED, MODIFIED_USER_ID);
end -- if;
GO

-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'IS_PRIVATE') begin -- then
	print 'alter table EMAILS add IS_PRIVATE bit null';
	alter table EMAILS add IS_PRIVATE bit null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAILS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS_AUDIT' and COLUMN_NAME = 'IS_PRIVATE') begin -- then
		print 'alter table EMAILS_AUDIT add IS_PRIVATE bit null';
		alter table EMAILS_AUDIT add IS_PRIVATE bit null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table EMAILS add ASSIGNED_SET_ID uniqueidentifier null';
	alter table EMAILS add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_EMAILS_ASSIGNED_SET_ID on dbo.EMAILS (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAILS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table EMAILS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table EMAILS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

-- 07/09/2018 Paul.  New index for archival based on date. 
if not exists (select * from sys.indexes where name = 'IDX_EMAILS_DATE_START') begin -- then
	create index IDX_EMAILS_DATE_START           on dbo.EMAILS (DELETED, DATE_START, TIME_START, PARENT_ID, ID);
end -- if;
GO

