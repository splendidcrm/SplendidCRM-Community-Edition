
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
-- 07/24/2006 Paul.  Increase the DATA_LABEL to 150 to allow a fully-qualified (NAME+MODULE_NAME+LIST_NAME) TERMINOLOGY name. 
-- 04/02/2008 Paul.  Add Validation fields. 
-- 05/17/2009 Paul.  Add support for a generic module popup. 
-- 06/12/2009 Paul.  Add TOOL_TIP for help hover.
-- 09/16/2012 Paul.  Increase ONCLICK_SCRIPT to nvarchar(max). 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'DEFAULT_VIEW') begin -- then
	print 'alter table EDITVIEWS_FIELDS add DEFAULT_VIEW bit null default(0)';
	alter table EDITVIEWS_FIELDS add DEFAULT_VIEW bit null default(0);
end -- if;
GO


if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'DATA_LABEL' and CHARACTER_MAXIMUM_LENGTH < 150) begin -- then
	print 'alter table EDITVIEWS_FIELDS alter column DATA_LABEL nvarchar(150) null';
	alter table EDITVIEWS_FIELDS alter column DATA_LABEL nvarchar(150) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'FIELD_VALIDATOR_ID') begin -- then
	print 'alter table EDITVIEWS_FIELDS add FIELD_VALIDATOR_ID uniqueidentifier null';
	alter table EDITVIEWS_FIELDS add FIELD_VALIDATOR_ID uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'FIELD_VALIDATOR_MESSAGE') begin -- then
	print 'alter table EDITVIEWS_FIELDS add FIELD_VALIDATOR_MESSAGE nvarchar(150) null';
	alter table EDITVIEWS_FIELDS add FIELD_VALIDATOR_MESSAGE nvarchar(150) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'MODULE_TYPE') begin -- then
	print 'alter table EDITVIEWS_FIELDS add MODULE_TYPE nvarchar(25) null';
	alter table EDITVIEWS_FIELDS add MODULE_TYPE nvarchar(25) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'TOOL_TIP') begin -- then
	print 'alter table EDITVIEWS_FIELDS add TOOL_TIP nvarchar(150) null';
	alter table EDITVIEWS_FIELDS add TOOL_TIP nvarchar(150) null;
end -- if;
GO

-- 01/19/2010 Paul.  We need to be able to format a Float field to prevent too many decimal places. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'DATA_FORMAT') begin -- then
	print 'alter table EDITVIEWS_FIELDS add DATA_FORMAT nvarchar(100) null';
	alter table EDITVIEWS_FIELDS add DATA_FORMAT nvarchar(100) null;
end -- if;
GO


-- 09/13/2010 Paul.  Add relationship fields. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'RELATED_SOURCE_MODULE_NAME') begin -- then
	print 'alter table EDITVIEWS_FIELDS add RELATED_SOURCE_MODULE_NAME nvarchar(50) null';
	alter table EDITVIEWS_FIELDS add RELATED_SOURCE_MODULE_NAME nvarchar(50) null
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'RELATED_SOURCE_VIEW_NAME') begin -- then
	print 'alter table EDITVIEWS_FIELDS add RELATED_SOURCE_VIEW_NAME nvarchar(50) null';
	alter table EDITVIEWS_FIELDS add RELATED_SOURCE_VIEW_NAME nvarchar(50) null
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'RELATED_SOURCE_ID_FIELD') begin -- then
	print 'alter table EDITVIEWS_FIELDS add RELATED_SOURCE_ID_FIELD nvarchar(30) null';
	alter table EDITVIEWS_FIELDS add RELATED_SOURCE_ID_FIELD nvarchar(30) null
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'RELATED_SOURCE_DISPLAY_FIELD') begin -- then
	print 'rename EDITVIEWS_FIELDS.RELATED_SOURCE_DISPLAY_FIELD to EDITVIEWS_FIELDS.RELATED_SOURCE_NAME_FIELD';
	exec sp_rename 'EDITVIEWS_FIELDS.RELATED_SOURCE_DISPLAY_FIELD', 'RELATED_SOURCE_NAME_FIELD', 'COLUMN';
end -- if;
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'RELATED_SOURCE_NAME_FIELD') begin -- then
	print 'alter table EDITVIEWS_FIELDS add RELATED_SOURCE_NAME_FIELD nvarchar(100) null';
	alter table EDITVIEWS_FIELDS add RELATED_SOURCE_NAME_FIELD nvarchar(100) null
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'RELATED_VIEW_NAME') begin -- then
	print 'alter table EDITVIEWS_FIELDS add RELATED_VIEW_NAME nvarchar(50) null';
	alter table EDITVIEWS_FIELDS add RELATED_VIEW_NAME nvarchar(50) null
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'RELATED_ID_FIELD') begin -- then
	print 'alter table EDITVIEWS_FIELDS add RELATED_ID_FIELD nvarchar(30) null';
	alter table EDITVIEWS_FIELDS add RELATED_ID_FIELD nvarchar(30) null
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'RELATED_DISPLAY_FIELD') begin -- then
	print 'rename EDITVIEWS_FIELDS.RELATED_DISPLAY_FIELD to EDITVIEWS_FIELDS.RELATED_NAME_FIELD';
	exec sp_rename 'EDITVIEWS_FIELDS.RELATED_DISPLAY_FIELD', 'RELATED_NAME_FIELD', 'COLUMN';
end -- if;
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'RELATED_NAME_FIELD') begin -- then
	print 'alter table EDITVIEWS_FIELDS add RELATED_NAME_FIELD nvarchar(100) null';
	alter table EDITVIEWS_FIELDS add RELATED_NAME_FIELD nvarchar(100) null
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'RELATED_JOIN_FIELD') begin -- then
	print 'alter table EDITVIEWS_FIELDS add RELATED_JOIN_FIELD nvarchar(30) null';
	alter table EDITVIEWS_FIELDS add RELATED_JOIN_FIELD nvarchar(30) null
end -- if;
GO

-- 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'PARENT_FIELD') begin -- then
	print 'alter table EDITVIEWS_FIELDS add PARENT_FIELD nvarchar(30) null';
	alter table EDITVIEWS_FIELDS add PARENT_FIELD nvarchar(30) null
end -- if;
GO

-- 09/16/2012 Paul.  Increase ONCLICK_SCRIPT to nvarchar(max). 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EDITVIEWS_FIELDS' and COLUMN_NAME = 'ONCLICK_SCRIPT' and CHARACTER_MAXIMUM_LENGTH <> -1) begin -- then
	print 'alter table EDITVIEWS_FIELDS alter column ONCLICK_SCRIPT nvarchar(max) null';
	alter table EDITVIEWS_FIELDS alter column ONCLICK_SCRIPT nvarchar(max) null;
end -- if;
GO

