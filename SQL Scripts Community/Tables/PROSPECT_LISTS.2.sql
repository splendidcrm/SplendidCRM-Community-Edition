
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
-- 04/21/2006 Paul.  LIST_TYPE was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  DOMAIN_NAME was added in SugarCRM 4.0.1.
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS' and COLUMN_NAME = 'LIST_TYPE') begin -- then
	print 'alter table PROSPECT_LISTS add LIST_TYPE nvarchar(255) null';
	alter table PROSPECT_LISTS add LIST_TYPE nvarchar(255) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS' and COLUMN_NAME = 'DOMAIN_NAME') begin -- then
	print 'alter table PROSPECT_LISTS add DOMAIN_NAME nvarchar(255) null';
	alter table PROSPECT_LISTS add DOMAIN_NAME nvarchar(255) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table PROSPECT_LISTS add TEAM_ID uniqueidentifier null';
	alter table PROSPECT_LISTS add TEAM_ID uniqueidentifier null;

	create index IDX_PROSPECT_LISTS_TEAM_ID on dbo.PROSPECT_LISTS (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table PROSPECT_LISTS add TEAM_SET_ID uniqueidentifier null';
	alter table PROSPECT_LISTS add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_PROSPECT_LISTS_TEAM_SET_ID on dbo.PROSPECT_LISTS (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table PROSPECT_LISTS add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table PROSPECT_LISTS add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 01/09/2010 Paul.  A Dynamic List is one that uses SQL to build the prospect list. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS' and COLUMN_NAME = 'DYNAMIC_LIST') begin -- then
	print 'alter table PROSPECT_LISTS add DYNAMIC_LIST bit null default(0)';
	alter table PROSPECT_LISTS add DYNAMIC_LIST bit null default(0);
	exec ('update PROSPECT_LISTS set DYNAMIC_LIST = 0 where DYNAMIC_LIST is null');
end -- if;
GO

-- 01/14/2010 Paul.  Move DYNAMIC_SQL to a separate table so that it cannot be imported or exported. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS' and COLUMN_NAME = 'DYNAMIC_SQL') begin -- then
	print 'alter table PROSPECT_LISTS drop column DYNAMIC_SQL';
	alter table PROSPECT_LISTS drop column DYNAMIC_SQL;
end -- if;
GO

-- 01/14/2010 Paul.  Move DYNAMIC_RDL to a separate table so that it cannot be imported or exported. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS' and COLUMN_NAME = 'DYNAMIC_RDL') begin -- then
	print 'alter table PROSPECT_LISTS drop column DYNAMIC_RDL';
	alter table PROSPECT_LISTS drop column DYNAMIC_RDL;
end -- if;
GO

-- 01/14/2010 Paul.  Move DYNAMIC_SQL to a separate table so that it cannot be imported or exported. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS_AUDIT' and COLUMN_NAME = 'DYNAMIC_SQL') begin -- then
	print 'alter table PROSPECT_LISTS_AUDIT drop column DYNAMIC_SQL';
	alter table PROSPECT_LISTS_AUDIT drop column DYNAMIC_SQL;
end -- if;
GO

-- 01/14/2010 Paul.  Move DYNAMIC_RDL to a separate table so that it cannot be imported or exported. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS_AUDIT' and COLUMN_NAME = 'DYNAMIC_RDL') begin -- then
	print 'alter table PROSPECT_LISTS_AUDIT drop column DYNAMIC_RDL';
	alter table PROSPECT_LISTS_AUDIT drop column DYNAMIC_RDL;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table PROSPECT_LISTS add ASSIGNED_SET_ID uniqueidentifier null';
	alter table PROSPECT_LISTS add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_PROSPECT_LISTS_ASSIGNED_SET_ID on dbo.PROSPECT_LISTS (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROSPECT_LISTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table PROSPECT_LISTS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table PROSPECT_LISTS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

