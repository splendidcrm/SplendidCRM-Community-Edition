
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
-- 06/12/2009 Paul.  Add TOOL_TIP for help hover.
-- 06/16/2010 Paul.  Increase the size of the URL_FIELD and URL_FORMAT so that we can create an IFrame to a Google map. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_FIELDS' and COLUMN_NAME = 'DEFAULT_VIEW') begin -- then
	print 'alter table DETAILVIEWS_FIELDS add DEFAULT_VIEW bit null default(0)';
	alter table DETAILVIEWS_FIELDS add DEFAULT_VIEW bit null default(0);
end -- if;
GO


if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_FIELDS' and COLUMN_NAME = 'DATA_LABEL' and CHARACTER_MAXIMUM_LENGTH < 150) begin -- then
	print 'alter table DETAILVIEWS_FIELDS alter column DATA_LABEL nvarchar(150) null';
	alter table DETAILVIEWS_FIELDS alter column DATA_LABEL nvarchar(150) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_FIELDS' and COLUMN_NAME = 'TOOL_TIP') begin -- then
	print 'alter table DETAILVIEWS_FIELDS add TOOL_TIP nvarchar(150) null';
	alter table DETAILVIEWS_FIELDS add TOOL_TIP nvarchar(150) null;
end -- if;
GO

-- 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_FIELDS' and COLUMN_NAME = 'MODULE_TYPE') begin -- then
	print 'alter table DETAILVIEWS_FIELDS add MODULE_TYPE nvarchar(25) null';
	alter table DETAILVIEWS_FIELDS add MODULE_TYPE nvarchar(25) null;
end -- if;
GO

-- 06/16/2010 Paul.  Increase the size of the URL_FIELD and URL_FORMAT so that we can create an IFrame to a Google map. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_FIELDS' and COLUMN_NAME = 'URL_FIELD' and CHARACTER_MAXIMUM_LENGTH <> -1) begin -- then
	print 'alter table DETAILVIEWS_FIELDS alter column URL_FIELD nvarchar(max) null';
	alter table DETAILVIEWS_FIELDS alter column URL_FIELD nvarchar(max) null;
end -- if;
GO

-- 08/02/2010 Paul.  Increase the size of the URL_FIELD and URL_FORMAT so that we can add a javascript info column. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_FIELDS' and COLUMN_NAME = 'URL_FORMAT' and CHARACTER_MAXIMUM_LENGTH <> -1) begin -- then
	print 'alter table DETAILVIEWS_FIELDS alter column URL_FORMAT nvarchar(max) null';
	alter table DETAILVIEWS_FIELDS alter column URL_FORMAT nvarchar(max) null;
end -- if;
GO

-- 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_FIELDS' and COLUMN_NAME = 'PARENT_FIELD') begin -- then
	print 'alter table DETAILVIEWS_FIELDS add PARENT_FIELD nvarchar(30) null';
	alter table DETAILVIEWS_FIELDS add PARENT_FIELD nvarchar(30) null
end -- if;
GO

-- 10/30/2013 Paul.  Increase size of URL_TARGET. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_FIELDS' and COLUMN_NAME = 'URL_TARGET' and CHARACTER_MAXIMUM_LENGTH < 60) begin -- then
	print 'alter table DETAILVIEWS_FIELDS alter column URL_TARGET nvarchar(60) null';
	alter table DETAILVIEWS_FIELDS alter column URL_TARGET nvarchar(60) null;
end -- if;
GO

-- 02/25/2015 Paul.  Increase size of DATA_FIELD and DATA_FORMAT for OfficeAddin. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_FIELDS' and COLUMN_NAME = 'DATA_FIELD' and CHARACTER_MAXIMUM_LENGTH < 1000) begin -- then
	print 'alter table DETAILVIEWS_FIELDS alter column DATA_FIELD nvarchar(1000) null';
	alter table DETAILVIEWS_FIELDS alter column DATA_FIELD nvarchar(1000) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_FIELDS' and COLUMN_NAME = 'DATA_FORMAT' and CHARACTER_MAXIMUM_LENGTH <> -1) begin -- then
	print 'alter table DETAILVIEWS_FIELDS alter column DATA_FORMAT nvarchar(max) null';
	alter table DETAILVIEWS_FIELDS alter column DATA_FORMAT nvarchar(max) null;
end -- if;
GO
