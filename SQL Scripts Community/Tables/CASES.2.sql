
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
-- 09/06/2005 Paul.  Version 3.5.0 renamed the NUMBER column to CASE_NUMBER (likely to support Oracle)
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 09/15/2009 Paul.  Use new syntax to drop an index. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 

-- Deprecated feature 'DROP INDEX with two-part name' is not supported in this version of SQL Server.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES' and COLUMN_NAME = 'CASE_NUMBER') begin -- then
	print 'rename CASES.NUMBER to CASES.CASE_NUMBER';
	exec sp_rename 'CASES.NUMBER', 'CASE_NUMBER', 'COLUMN';
	
	if exists (select * from sys.indexes where name = 'IDX_CASES_NUMBER') begin -- then
		drop index IDX_CASES_NUMBER on CASES;
	end -- if;
	create index IDX_CASES_NUMBER on dbo.CASES (CASE_NUMBER);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table CASES add TEAM_ID uniqueidentifier null';
	alter table CASES add TEAM_ID uniqueidentifier null;

	create index IDX_CASES_TEAM_ID on dbo.CASES (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 04/21/2008 Paul.  SugarCRM 5.0 dropped ACCOUNT_NAME.  We will eventually do so. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES' and COLUMN_NAME = 'ACCOUNT_NAME') begin -- then
	print 'alter table CASES add ACCOUNT_NAME nvarchar(100) null';
	alter table CASES add ACCOUNT_NAME nvarchar(100) null;
end -- if;
GO

-- 07/25/2009 Paul.  CASE_NUMBER is now a string. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES' and COLUMN_NAME = 'CASE_NUMBER' and DATA_TYPE <> 'nvarchar') begin -- then
	print 'Change CASES.CASE_NUMBER to nvarchar.';
	if exists (select * from sys.indexes where name = 'IDX_CASES_NUMBER') begin -- then
		drop index IDX_CASES_NUMBER on CASES;
	end -- if;

	declare @CURRENT_VALUE int;
	select @CURRENT_VALUE = max(CASE_NUMBER)
	  from CASES;
	-- 08/06/2009 Paul.  @CURRENT_VALUE cannot be null, so only insert if it has a value. 
	if @CURRENT_VALUE is not null begin -- then
		if exists (select * from NUMBER_SEQUENCES where NAME = 'CASES.CASE_NUMBER') begin -- then
			update NUMBER_SEQUENCES
			   set CURRENT_VALUE = @CURRENT_VALUE
			 where NAME = 'CASES.CASE_NUMBER';
		end else begin
			insert into NUMBER_SEQUENCES (ID, NAME, CURRENT_VALUE)
			values (newid(), 'CASES.CASE_NUMBER', @CURRENT_VALUE);
		end -- if;
	end -- if;

	-- 02/18/2010 Paul.  Disable triggers before converting.
	exec dbo.spSqlTableDisableTriggers 'CASES';
	
	exec sp_rename 'CASES.CASE_NUMBER', 'CASE_NUMBER_INT', 'COLUMN';
	exec ('alter table CASES add CASE_NUMBER nvarchar(30) null');
	exec ('update CASES set CASE_NUMBER = cast(CASE_NUMBER_INT as nvarchar(30))');
	exec ('alter table CASES drop column CASE_NUMBER_INT');
	
	-- 02/18/2010 Paul.  Enable triggers after converting.
	exec dbo.spSqlTableEnableTriggers 'CASES';
	
	exec ('create index IDX_CASES_NUMBER           on dbo.CASES (CASE_NUMBER, ID, DELETED)');
end -- if;
GO

-- 08/08/2009 Paul.  We also need to change the field in the audit table. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES_AUDIT' and COLUMN_NAME = 'CASE_NUMBER' and DATA_TYPE <> 'nvarchar') begin -- then
	print 'Change CASES_AUDIT.CASE_NUMBER to nvarchar.';
	exec sp_rename 'CASES_AUDIT.CASE_NUMBER', 'CASE_NUMBER_INT', 'COLUMN';
	exec ('alter table CASES_AUDIT add CASE_NUMBER nvarchar(30) null');
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	exec dbo.spSqlTableDisableTriggers 'CASES_AUDIT';
	exec ('update CASES_AUDIT set CASE_NUMBER = cast(CASE_NUMBER_INT as nvarchar(30))');
	exec dbo.spSqlTableEnableTriggers 'CASES_AUDIT';
	exec ('alter table CASES_AUDIT drop column CASE_NUMBER_INT');
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table CASES add TEAM_SET_ID uniqueidentifier null';
	alter table CASES add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_CASES_TEAM_SET_ID on dbo.CASES (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table CASES add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table CASES add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 04/02/2012 Paul.  Add TYPE and WORK_LOG. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES' and COLUMN_NAME = 'TYPE') begin -- then
	print 'alter table CASES add TYPE nvarchar(25) null';
	alter table CASES add TYPE nvarchar(25) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CASES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES_AUDIT' and COLUMN_NAME = 'TYPE') begin -- then
		print 'alter table CASES_AUDIT add TYPE nvarchar(25) null';
		alter table CASES_AUDIT add TYPE nvarchar(25) null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES' and COLUMN_NAME = 'WORK_LOG') begin -- then
	print 'alter table CASES add WORK_LOG nvarchar(max) null';
	alter table CASES add WORK_LOG nvarchar(max) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CASES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES_AUDIT' and COLUMN_NAME = 'WORK_LOG') begin -- then
		print 'alter table CASES_AUDIT add WORK_LOG nvarchar(max) null';
		alter table CASES_AUDIT add WORK_LOG nvarchar(max) null;
	end -- if;
end -- if;
GO


-- 05/01/2013 Paul.  Add Contacts field to support B2C. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES' and COLUMN_NAME = 'B2C_CONTACT_ID') begin -- then
	print 'alter table CASES add B2C_CONTACT_ID uniqueidentifier null';
	alter table CASES add B2C_CONTACT_ID uniqueidentifier null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CASES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES_AUDIT' and COLUMN_NAME = 'B2C_CONTACT_ID') begin -- then
		print 'alter table CASES_AUDIT add B2C_CONTACT_ID uniqueidentifier null';
		alter table CASES_AUDIT add B2C_CONTACT_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table CASES add ASSIGNED_SET_ID uniqueidentifier null';
	alter table CASES add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_CASES_ASSIGNED_SET_ID on dbo.CASES (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CASES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CASES_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table CASES_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table CASES_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

