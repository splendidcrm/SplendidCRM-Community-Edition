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
-- 07/24/2006 Paul.  Increase the MODULE_NAME to 25 to match the size in the MODULES table.
-- 02/11/2017 Paul.  New index based on missing indexes query. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TERMINOLOGY' and COLUMN_NAME = 'MODULE_NAME' and CHARACTER_MAXIMUM_LENGTH < 25) begin -- then
	print 'alter table TERMINOLOGY alter column MODULE_NAME nvarchar(25) null';
	alter table TERMINOLOGY alter column MODULE_NAME nvarchar(25) null;
end -- if;
GO

-- 03/06/2012 Paul.  Increase size of the NAME field so that it can include a date formula. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TERMINOLOGY' and COLUMN_NAME = 'NAME' and CHARACTER_MAXIMUM_LENGTH < 150) begin -- then
	print 'alter table TERMINOLOGY alter column NAME nvarchar(150) null';
	alter table TERMINOLOGY alter column NAME nvarchar(150) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TERMINOLOGY' and COLUMN_NAME = 'DISPLAY_NAME' and CHARACTER_MAXIMUM_LENGTH <> -1) begin -- then
	print 'alter table TERMINOLOGY alter column DISPLAY_NAME nvarchar(max) null';
	alter table TERMINOLOGY alter column DISPLAY_NAME nvarchar(max) null;
end -- if;
GO

-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from sys.indexes where name = 'IX_TERMINOLOGY_LIST_NAME') begin -- then
	print 'create index IX_TERMINOLOGY_LIST_NAME';
	create index IX_TERMINOLOGY_LIST_NAME on dbo.TERMINOLOGY(DELETED, LANG, LIST_NAME)
end -- if;
GO

-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from sys.indexes where name = 'IDX_TERMINOLOGY_DELETED_LIST') begin -- then
	print 'create index IDX_TERMINOLOGY_DELETED_LIST';
	create index IDX_TERMINOLOGY_DELETED_LIST on dbo.TERMINOLOGY (DELETED, LIST_NAME)
end -- if;
GO

