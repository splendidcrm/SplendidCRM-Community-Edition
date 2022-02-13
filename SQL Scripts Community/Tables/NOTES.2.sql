
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
-- 12/25/2007 Paul.  EMBED_FLAG was added in SugarCRM 4.5.1
-- 02/11/2017 Paul.  New index based on missing indexes query. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES' and COLUMN_NAME = 'NOTE_ATTACHMENT_ID') begin -- then
	print 'alter table NOTES add NOTE_ATTACHMENT_ID uniqueidentifier null';
	alter table NOTES add NOTE_ATTACHMENT_ID uniqueidentifier null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES' and COLUMN_NAME = 'ATTACHMENT') 
  begin
	print 'alter table NOTES drop column ATTACHMENT';
	alter table NOTES drop column ATTACHMENT;
  end
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table NOTES add TEAM_ID uniqueidentifier null';
	alter table NOTES add TEAM_ID uniqueidentifier null;

	create index IDX_NOTES_TEAM_ID on dbo.NOTES (TEAM_ID, DELETED, ID)
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES' and COLUMN_NAME = 'EMBED_FLAG') begin -- then
	print 'alter table NOTES add EMBED_FLAG bit null default(0)';
	alter table NOTES add EMBED_FLAG bit null default(0);
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table NOTES add TEAM_SET_ID uniqueidentifier null';
	alter table NOTES add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_NOTES_TEAM_SET_ID on dbo.NOTES (TEAM_SET_ID, DELETED, ID);
end -- if;
GO

-- 04/27/2014 Paul.  Also add TEAM_SET_ID to the audit table. 
if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'NOTES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES_AUDIT' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
		print 'alter table NOTES_AUDIT add TEAM_SET_ID uniqueidentifier null';
		alter table NOTES_AUDIT add TEAM_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table NOTES add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table NOTES add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 04/27/2014 Paul.  Also add DATE_MODIFIED_UTC to the audit table. 
if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'NOTES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES_AUDIT' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
		print 'alter table NOTES_AUDIT add DATE_MODIFIED_UTC datetime null';
		alter table NOTES_AUDIT add DATE_MODIFIED_UTC datetime null;
	end -- if;
end -- if;
GO

-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES' and COLUMN_NAME = 'ASSIGNED_USER_ID') begin -- then
	print 'alter table NOTES add ASSIGNED_USER_ID uniqueidentifier null';
	alter table NOTES add ASSIGNED_USER_ID uniqueidentifier null;

	create index IDX_NOTES_ASSIGNED_USER_ID on dbo.NOTES (ASSIGNED_USER_ID, DELETED, ID);

	-- 04/27/2014 Paul.  Move audit creation prior to update. 
	if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'NOTES_AUDIT') begin -- then
		if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES_AUDIT' and COLUMN_NAME = 'ASSIGNED_USER_ID') begin -- then
			print 'alter table NOTES_AUDIT add ASSIGNED_USER_ID uniqueidentifier null';
			alter table NOTES_AUDIT add ASSIGNED_USER_ID uniqueidentifier null;
		end -- if;
	end -- if;

	-- 04/02/2012 Paul.  The previous rule was that a note follows the assignment of the parent. 
	-- 01/09/2013 Paul.  Customers did not like that the modified date changed for a non-user event, so remove date update. 
	-- 01/09/2013 Paul.  Also make sure that the PARENT_ASSIGNED_USER_ID is not null. 
	if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwNOTES') begin -- then
		-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
		exec dbo.spSqlTableDisableTriggers 'NOTES';
		-- 04/27/2014 Paul.  Include date fields in update. 
		-- 09/11/2015 Paul.  Do not change the DATE_MODIFIED field as it will look like an end-user changed the value. 
		exec('update NOTES
		   set ASSIGNED_USER_ID  = vwNOTES.PARENT_ASSIGNED_USER_ID
		     , DATE_MODIFIED_UTC = getutcdate()
		  from      NOTES
		 inner join vwNOTES
		         on vwNOTES.ID = NOTES.ID
		        and vwNOTES.PARENT_ASSIGNED_USER_ID is not null
		 where NOTES.ASSIGNED_USER_ID is null
		   and NOTES.DELETED = 0');
		exec dbo.spSqlTableEnableTriggers 'NOTES';
	end -- if;
end -- if;
GO

-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from sys.indexes where name = 'IDX_NOTES_DELETED_PARENT') begin -- then
	print 'create index IDX_NOTES_DELETED_PARENT';
	create index IDX_NOTES_DELETED_PARENT on dbo.NOTES (DELETED, PARENT_TYPE, PARENT_ID, NOTE_ATTACHMENT_ID)
end -- if;
GO


-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES' and COLUMN_NAME = 'IS_PRIVATE') begin -- then
	print 'alter table NOTES add IS_PRIVATE bit null';
	alter table NOTES add IS_PRIVATE bit null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'NOTES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES_AUDIT' and COLUMN_NAME = 'IS_PRIVATE') begin -- then
		print 'alter table NOTES_AUDIT add IS_PRIVATE bit null';
		alter table NOTES_AUDIT add IS_PRIVATE bit null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table NOTES add ASSIGNED_SET_ID uniqueidentifier null';
	alter table NOTES add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_NOTES_ASSIGNED_SET_ID on dbo.NOTES (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'NOTES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTES_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table NOTES_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table NOTES_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

