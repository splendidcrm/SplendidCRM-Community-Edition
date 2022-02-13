
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
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROJECT' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table PROJECT add TEAM_ID uniqueidentifier null';
	alter table PROJECT add TEAM_ID uniqueidentifier null;

	create index IDX_PROJECT_TEAM_ID on dbo.PROJECT (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROJECT' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table PROJECT add TEAM_SET_ID uniqueidentifier null';
	alter table PROJECT add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_PROJECT_TEAM_SET_ID on dbo.PROJECT (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROJECT' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table PROJECT add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table PROJECT add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 01/13/2010 Paul.  New Project fields in SugarCRM. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROJECT' and COLUMN_NAME = 'ESTIMATED_START_DATE') begin -- then
	print 'alter table PROJECT add ESTIMATED_START_DATE datetime null';
	alter table PROJECT add ESTIMATED_START_DATE datetime null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROJECT' and COLUMN_NAME = 'ESTIMATED_END_DATE') begin -- then
	print 'alter table PROJECT add ESTIMATED_END_DATE datetime null';
	alter table PROJECT add ESTIMATED_END_DATE datetime null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROJECT' and COLUMN_NAME = 'STATUS') begin -- then
	print 'alter table PROJECT add STATUS nvarchar(25) null';
	alter table PROJECT add STATUS nvarchar(25) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROJECT' and COLUMN_NAME = 'PRIORITY') begin -- then
	print 'alter table PROJECT add PRIORITY nvarchar(25) null';
	alter table PROJECT add PRIORITY nvarchar(25) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROJECT' and COLUMN_NAME = 'IS_TEMPLATE') begin -- then
	print 'alter table PROJECT add IS_TEMPLATE bit null';
	alter table PROJECT add IS_TEMPLATE bit null;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROJECT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table PROJECT add ASSIGNED_SET_ID uniqueidentifier null';
	alter table PROJECT add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_PROJECT_ASSIGNED_SET_ID on dbo.PROJECT (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROJECT_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROJECT_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table PROJECT_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table PROJECT_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

