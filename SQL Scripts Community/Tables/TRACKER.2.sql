
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
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TRACKER' and COLUMN_NAME = 'NUMBER') begin -- then
	print 'alter table TRACKER drop column NUMBER';
	alter table TRACKER drop column NUMBER;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TRACKER' and COLUMN_NAME = 'DELETED') begin -- then
	print 'alter table TRACKER add DELETED bit not null default(0)';
	alter table TRACKER add DELETED bit not null default(0);
end -- if;
GO

-- 11/03/2009 Paul.  This foreign key will give us trouble on the offline client. 
if exists(select * from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = 'FK_TRACKER_USER_ID') begin -- then
	print 'alter table TRACKER drop constraint FK_TRACKER_USER_ID;';

	alter table TRACKER drop constraint FK_TRACKER_USER_ID;
end -- if;
GO

-- 08/26/2010 Paul.  Add IDX_TRACKER_USER_MODULE to speed spTRACKER_Update. 
if not exists (select * from sys.indexes where name = 'IDX_TRACKER_USER_MODULE') begin -- then
	print 'create index IDX_TRACKER_USER_MODULE';
	create index IDX_TRACKER_USER_MODULE on dbo.TRACKER (USER_ID, MODULE_NAME, ID)
end -- if;
GO

-- 03/08/2012 Paul.  Add ACTION to the tracker table so that we can create quick user activity reports. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TRACKER' and COLUMN_NAME = 'ACTION') begin -- then
	print 'alter table TRACKER add ACTION nvarchar(25) null default(''detailview'')';
	alter table TRACKER add ACTION nvarchar(25) null default('detailview');
	exec('update TRACKER
	   set ACTION = ''detailview''
	 where ACTION is null');

	if exists (select * from sys.indexes where name = 'IDX_TRACKER_USER_ID') begin -- then
		drop index IDX_TRACKER_USER_ID on TRACKER;
	end -- if;
	if exists (select * from sys.indexes where name = 'IDX_TRACKER_ITEM_ID') begin -- then
		drop index IDX_TRACKER_ITEM_ID on TRACKER;
	end -- if;
	if exists (select * from sys.indexes where name = 'IDX_TRACKER_USER_MODULE') begin -- then
		drop index IDX_TRACKER_USER_MODULE on TRACKER;
	end -- if;

	create index IDX_TRACKER_USER_ID     on dbo.TRACKER (USER_ID, ACTION, DELETED);
	create index IDX_TRACKER_ITEM_ID     on dbo.TRACKER (ITEM_ID, ACTION, DELETED);
	create index IDX_TRACKER_USER_MODULE on dbo.TRACKER (USER_ID, ACTION, DELETED, MODULE_NAME, ID);
end -- if;
GO

