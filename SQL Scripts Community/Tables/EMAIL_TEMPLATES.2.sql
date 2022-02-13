
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
-- 09/06/2005 Paul.  Version 3.5.0 added the BODY_HTML field. 
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 12/19/2006 Paul.  Add READ_ONLY flag. 
-- 12/25/2007 Paul.  TEXT_ONLY was added in SugarCRM 4.5.1
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_TEMPLATES' and COLUMN_NAME = 'BODY_HTML') begin -- then
	print 'alter table EMAIL_TEMPLATES add BODY_HTML nvarchar(max) null';
	alter table EMAIL_TEMPLATES add BODY_HTML nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_TEMPLATES' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table EMAIL_TEMPLATES add TEAM_ID uniqueidentifier null';
	alter table EMAIL_TEMPLATES add TEAM_ID uniqueidentifier null;

	create index IDX_EMAIL_TEMPLATES_TEAM_ID on dbo.EMAIL_TEMPLATES (TEAM_ID, DELETED, ID)
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_TEMPLATES' and COLUMN_NAME = 'READ_ONLY') begin -- then
	print 'alter table EMAIL_TEMPLATES add READ_ONLY bit null default(0)';
	alter table EMAIL_TEMPLATES add READ_ONLY bit null default(0);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_TEMPLATES' and COLUMN_NAME = 'TEXT_ONLY') begin -- then
	print 'alter table EMAIL_TEMPLATES add TEXT_ONLY bit null default(0)';
	alter table EMAIL_TEMPLATES add TEXT_ONLY bit null default(0);
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_TEMPLATES' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table EMAIL_TEMPLATES add TEAM_SET_ID uniqueidentifier null';
	alter table EMAIL_TEMPLATES add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_EMAIL_TEMPLATES_TEAM_SET_ID on dbo.EMAIL_TEMPLATES (TEAM_SET_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_TEMPLATES' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table EMAIL_TEMPLATES add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table EMAIL_TEMPLATES add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_TEMPLATES' and COLUMN_NAME = 'ASSIGNED_USER_ID') begin -- then
	print 'alter table EMAIL_TEMPLATES add ASSIGNED_USER_ID uniqueidentifier null';
	alter table EMAIL_TEMPLATES add ASSIGNED_USER_ID uniqueidentifier null;

	create index IDX_EMAIL_TEMPLATES_ASSIGNED_USER_ID on dbo.EMAIL_TEMPLATES (ASSIGNED_USER_ID, DELETED, ID);
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	-- 09/11/2015 Paul.  Do not change the DATE_MODIFIED field as it will look like an end-user changed the value. 
	exec dbo.spSqlTableDisableTriggers 'EMAIL_TEMPLATES';
	exec('update EMAIL_TEMPLATES
	   set ASSIGNED_USER_ID  = MODIFIED_USER_ID
	     , DATE_MODIFIED_UTC = getutcdate()
	 where ASSIGNED_USER_ID is null
	   and DELETED = 0');
	exec dbo.spSqlTableEnableTriggers 'EMAIL_TEMPLATES';
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAIL_TEMPLATES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_TEMPLATES_AUDIT' and COLUMN_NAME = 'ASSIGNED_USER_ID') begin -- then
		print 'alter table EMAIL_TEMPLATES_AUDIT add ASSIGNED_USER_ID uniqueidentifier null';
		alter table EMAIL_TEMPLATES_AUDIT add ASSIGNED_USER_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_TEMPLATES' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table EMAIL_TEMPLATES add ASSIGNED_SET_ID uniqueidentifier null';
	alter table EMAIL_TEMPLATES add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_EMAIL_TEMPLATES_ASSIGNED_SET_ID on dbo.EMAIL_TEMPLATES (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAIL_TEMPLATES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_TEMPLATES_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table EMAIL_TEMPLATES_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table EMAIL_TEMPLATES_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

