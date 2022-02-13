
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
-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS' and COLUMN_NAME = 'DATA_COLUMNS') begin -- then
	print 'alter table DETAILVIEWS add DATA_COLUMNS int null';
	alter table DETAILVIEWS add DATA_COLUMNS int null;
end -- if;
GO

-- 10/30/2010 Paul.  Add support for Business Rules Framework. 
-- 11/11/2010 Paul.  Change to Pre Load and Post Load. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS' and COLUMN_NAME = 'LOAD_EVENT_ID') begin -- then
	print 'alter table DETAILVIEWS drop column LOAD_EVENT_ID';
	alter table DETAILVIEWS drop column LOAD_EVENT_ID;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS' and COLUMN_NAME = 'PRE_LOAD_EVENT_ID') begin -- then
	print 'alter table DETAILVIEWS add PRE_LOAD_EVENT_ID uniqueidentifier null';
	alter table DETAILVIEWS add PRE_LOAD_EVENT_ID uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS' and COLUMN_NAME = 'POST_LOAD_EVENT_ID') begin -- then
	print 'alter table DETAILVIEWS add POST_LOAD_EVENT_ID uniqueidentifier null';
	alter table DETAILVIEWS add POST_LOAD_EVENT_ID uniqueidentifier null;
end -- if;
GO

-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS' and COLUMN_NAME = 'SCRIPT') begin -- then
	print 'alter table DETAILVIEWS add SCRIPT nvarchar(max) null';
	alter table DETAILVIEWS add SCRIPT nvarchar(max) null;
end -- if;
GO

-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from sys.indexes where name = 'IDX_DETAILVIEWS_DELETED_VIEW') begin -- then
	print 'create index IDX_DETAILVIEWS_DELETED_VIEW';
	create index IDX_DETAILVIEWS_DELETED_VIEW on dbo.DETAILVIEWS (DELETED, VIEW_NAME)
end -- if;
GO

