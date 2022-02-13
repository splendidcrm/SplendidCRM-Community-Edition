
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
-- 09/06/2005 Paul.  Version 3.5.0 renamed the NUMBER column to BUG_NUMBER (likely to support Oracle)
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 09/15/2009 Paul.  Use new syntax to drop an index. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 

-- Deprecated feature 'DROP INDEX with two-part name' is not supported in this version of SQL Server.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'BUGS' and COLUMN_NAME = 'BUG_NUMBER') begin -- then
	print 'rename BUGS.NUMBER to BUGS.BUG_NUMBER';
	exec sp_rename 'BUGS.NUMBER', 'BUG_NUMBER', 'COLUMN';
	
	if exists (select * from sys.indexes where name = 'IDX_BUGS_NUMBER') begin -- then
		drop index IDX_BUGS_NUMBER on BUGS;
	end -- if;
	create index IDX_BUGS_NUMBER on dbo.BUGS (BUG_NUMBER);
end -- if;
GO

-- 12/20/2005 Paul.  Version 4.0 renamed the RELEASE column to FOUND_IN_RELEASE. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'BUGS' and COLUMN_NAME = 'FOUND_IN_RELEASE') begin -- then
	print 'rename BUGS.RELEASE to BUGS.FOUND_IN_RELEASE';
	exec sp_rename 'BUGS.RELEASE', 'FOUND_IN_RELEASE', 'COLUMN';
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'BUGS' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table BUGS add TEAM_ID uniqueidentifier null';
	alter table BUGS add TEAM_ID uniqueidentifier null;

	create index IDX_BUGS_TEAM_ID on dbo.BUGS (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 07/25/2009 Paul.  BUG_NUMBER is now a string. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'BUGS' and COLUMN_NAME = 'BUG_NUMBER' and DATA_TYPE <> 'nvarchar') begin -- then
	print 'Change BUGS.BUG_NUMBER to nvarchar.';
	if exists (select * from sys.indexes where name = 'IDX_BUGS_NUMBER') begin -- then
		drop index IDX_BUGS_NUMBER on BUGS;
	end -- if;

	declare @CURRENT_VALUE int;
	select @CURRENT_VALUE = max(BUG_NUMBER)
	  from BUGS;
	-- 08/06/2009 Paul.  @CURRENT_VALUE cannot be null, so only insert if it has a value. 
	if @CURRENT_VALUE is not null begin -- then
		if exists (select * from NUMBER_SEQUENCES where NAME = 'BUGS.BUG_NUMBER') begin -- then
			update NUMBER_SEQUENCES
			   set CURRENT_VALUE = @CURRENT_VALUE
			 where NAME = 'BUGS.BUG_NUMBER';
		end else begin
			insert into NUMBER_SEQUENCES (ID, NAME, CURRENT_VALUE)
			values (newid(), 'BUGS.BUG_NUMBER', @CURRENT_VALUE);
		end -- if;
	end -- if;

	-- 02/18/2010 Paul.  Disable triggers before converting.
	exec dbo.spSqlTableDisableTriggers 'BUGS';
	
	exec sp_rename 'BUGS.BUG_NUMBER', 'BUG_NUMBER_INT', 'COLUMN';
	exec ('alter table BUGS add BUG_NUMBER nvarchar(30) null');
	exec ('update BUGS set BUG_NUMBER = cast(BUG_NUMBER_INT as nvarchar(30))');
	exec ('alter table BUGS drop column BUG_NUMBER_INT');
	
	-- 02/18/2010 Paul.  Enable triggers after converting.
	exec dbo.spSqlTableEnableTriggers 'BUGS';
	
	exec ('create index IDX_BUGS_NUMBER           on dbo.BUGS (BUG_NUMBER, ID, DELETED)');
end -- if;
GO

-- 08/08/2009 Paul.  We also need to change the field in the audit table. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'BUGS_AUDIT' and COLUMN_NAME = 'BUG_NUMBER' and DATA_TYPE <> 'nvarchar') begin -- then
	print 'Change BUGS_AUDIT.BUG_NUMBER to nvarchar.';
	exec sp_rename 'BUGS_AUDIT.BUG_NUMBER', 'BUG_NUMBER_INT', 'COLUMN';
	exec ('alter table BUGS_AUDIT add BUG_NUMBER nvarchar(30) null');
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	exec dbo.spSqlTableDisableTriggers 'BUGS_AUDIT';
	exec ('update BUGS_AUDIT set BUG_NUMBER = cast(BUG_NUMBER_INT as nvarchar(30))');
	exec dbo.spSqlTableEnableTriggers 'BUGS_AUDIT';
	exec ('alter table BUGS_AUDIT drop column BUG_NUMBER_INT');
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'BUGS' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table BUGS add TEAM_SET_ID uniqueidentifier null';
	alter table BUGS add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_BUGS_TEAM_SET_ID on dbo.BUGS (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'BUGS' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table BUGS add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table BUGS add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'BUGS' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table BUGS add ASSIGNED_SET_ID uniqueidentifier null';
	alter table BUGS add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_BUGS_ASSIGNED_SET_ID on dbo.BUGS (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'BUGS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'BUGS_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table BUGS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table BUGS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

