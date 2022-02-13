
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
-- 04/21/2006 Paul.  MAIL_MERGE_DOCUMENT was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  RELATED_DOC_ID was added in SugarCRM 4.2.
-- 04/21/2006 Paul.  RELATED_DOC_REV_ID was added in SugarCRM 4.2.
-- 04/21/2006 Paul.  IS_TEMPLATE was added in SugarCRM 4.2.
-- 04/21/2006 Paul.  TEMPLATE_TYPE was added in SugarCRM 4.2.
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS' and COLUMN_NAME = 'MAIL_MERGE_DOCUMENT') begin -- then
	print 'alter table DOCUMENTS add MAIL_MERGE_DOCUMENT bit null default(0)';
	alter table DOCUMENTS add MAIL_MERGE_DOCUMENT bit null default(0);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS' and COLUMN_NAME = 'RELATED_DOC_ID') begin -- then
	print 'alter table DOCUMENTS add RELATED_DOC_ID uniqueidentifier null';
	alter table DOCUMENTS add RELATED_DOC_ID uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS' and COLUMN_NAME = 'RELATED_DOC_REV_ID') begin -- then
	print 'alter table DOCUMENTS add RELATED_DOC_REV_ID uniqueidentifier null';
	alter table DOCUMENTS add RELATED_DOC_REV_ID uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS' and COLUMN_NAME = 'IS_TEMPLATE') begin -- then
	print 'alter table DOCUMENTS add IS_TEMPLATE bit null default(0)';
	alter table DOCUMENTS add IS_TEMPLATE bit null default(0);
	print 'alter table DOCUMENTS add TEMPLATE_TYPE nvarchar(25) null';
	alter table DOCUMENTS add TEMPLATE_TYPE nvarchar(25) null;

	execute ('update DOCUMENTS set IS_TEMPLATE = 1, TEMPLATE_TYPE = ''mailmerge'' where MAIL_MERGE_DOCUMENT = 1');
end -- if;
GO


if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table DOCUMENTS add TEAM_ID uniqueidentifier null';
	alter table DOCUMENTS add TEAM_ID uniqueidentifier null;

	create index IDX_DOCUMENTS_TEAM_ID on dbo.DOCUMENTS (TEAM_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table DOCUMENTS add TEAM_SET_ID uniqueidentifier null';
	alter table DOCUMENTS add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_DOCUMENTS_TEAM_SET_ID on dbo.DOCUMENTS (TEAM_SET_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table DOCUMENTS add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table DOCUMENTS add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 05/15/2011 Paul.  We need to include the Master and Secondary so that the user selects the correct template. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS' and COLUMN_NAME = 'PRIMARY_MODULE') begin -- then
	print 'alter table DOCUMENTS add PRIMARY_MODULE nvarchar(25) null';
	alter table DOCUMENTS add PRIMARY_MODULE nvarchar(25) null;

end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS_AUDIT' and COLUMN_NAME = 'PRIMARY_MODULE') begin -- then
		print 'alter table DOCUMENTS_AUDIT add PRIMARY_MODULE nvarchar(25) null';
		alter table DOCUMENTS_AUDIT add PRIMARY_MODULE nvarchar(25) null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS' and COLUMN_NAME = 'SECONDARY_MODULE') begin -- then
	print 'alter table DOCUMENTS add SECONDARY_MODULE nvarchar(25) null';
	alter table DOCUMENTS add SECONDARY_MODULE nvarchar(25) null;

end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS_AUDIT' and COLUMN_NAME = 'SECONDARY_MODULE') begin -- then
		print 'alter table DOCUMENTS_AUDIT add SECONDARY_MODULE nvarchar(25) null';
		alter table DOCUMENTS_AUDIT add SECONDARY_MODULE nvarchar(25) null;
	end -- if;
end -- if;
GO

-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS' and COLUMN_NAME = 'ASSIGNED_USER_ID') begin -- then
	print 'alter table DOCUMENTS add ASSIGNED_USER_ID uniqueidentifier null';
	alter table DOCUMENTS add ASSIGNED_USER_ID uniqueidentifier null;

	create index IDX_DOCUMENTS_ASSIGNED_USER_ID on dbo.DOCUMENTS (ASSIGNED_USER_ID, DELETED, ID);
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	-- 09/11/2015 Paul.  Do not change the DATE_MODIFIED field as it will look like an end-user changed the value. 
	exec dbo.spSqlTableDisableTriggers 'DOCUMENTS';
	exec('update DOCUMENTS
	   set ASSIGNED_USER_ID  = MODIFIED_USER_ID
	     , DATE_MODIFIED_UTC = getutcdate()
	 where ASSIGNED_USER_ID is null
	   and DELETED = 0');
	exec dbo.spSqlTableEnableTriggers 'DOCUMENTS';
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'DOCUMENTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS_AUDIT' and COLUMN_NAME = 'ASSIGNED_USER_ID') begin -- then
		print 'alter table DOCUMENTS_AUDIT add ASSIGNED_USER_ID uniqueidentifier null';
		alter table DOCUMENTS_AUDIT add ASSIGNED_USER_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table DOCUMENTS add ASSIGNED_SET_ID uniqueidentifier null';
	alter table DOCUMENTS add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_DOCUMENTS_ASSIGNED_SET_ID on dbo.DOCUMENTS (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'DOCUMENTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DOCUMENTS_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table DOCUMENTS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table DOCUMENTS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

