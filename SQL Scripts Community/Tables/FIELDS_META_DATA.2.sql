
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
-- 04/21/2006 Paul.  MASS_UPDATE was added in SugarCRM 4.0.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'FIELDS_META_DATA' and COLUMN_NAME = 'AUDITED') begin -- then
	print 'alter table FIELDS_META_DATA add AUDITED bit null default(0)';
	alter table FIELDS_META_DATA add AUDITED bit null default(0);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'FIELDS_META_DATA' and COLUMN_NAME = 'MASS_UPDATE') begin -- then
	print 'alter table FIELDS_META_DATA add MASS_UPDATE bit null default(0)';
	alter table FIELDS_META_DATA add MASS_UPDATE bit null default(0);
end -- if;
GO

-- 04/21/2008 Paul.  We changed some of the original SugarCRM field names. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'FIELDS_META_DATA' and COLUMN_NAME = 'LABEL') begin -- then
	print 'alter table FIELDS_META_DATA add LABEL nvarchar(255) null';
	alter table FIELDS_META_DATA add LABEL nvarchar(255) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'FIELDS_META_DATA' and COLUMN_NAME = 'DATA_TYPE') begin -- then
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'FIELDS_META_DATA' and COLUMN_NAME = 'TYPE') begin -- then
		print 'alter table FIELDS_META_DATA rename TYPE to DATA_TYPE';
		exec sp_rename 'FIELDS_META_DATA.TYPE', 'DATA_TYPE', 'COLUMN';
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'FIELDS_META_DATA' and COLUMN_NAME = 'MAX_SIZE') begin -- then
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'FIELDS_META_DATA' and COLUMN_NAME = 'LEN') begin -- then
		print 'alter table FIELDS_META_DATA rename LEN to MAX_SIZE';
		exec sp_rename 'FIELDS_META_DATA.LEN', 'MAX_SIZE', 'COLUMN';
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'FIELDS_META_DATA' and COLUMN_NAME = 'REQUIRED_OPTION') begin -- then
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'FIELDS_META_DATA' and COLUMN_NAME = 'REQUIRED') begin -- then
		print 'alter table FIELDS_META_DATA rename REQUIRED to REQUIRED_OPTION';
		exec sp_rename 'FIELDS_META_DATA.REQUIRED', 'REQUIRED_OPTION', 'COLUMN';
	end -- if;
end -- if;
GO

-- 11/17/2009 Paul.  We have added DATE_MODIFIED_UTC to tables that are sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'FIELDS_META_DATA' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table FIELDS_META_DATA add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table FIELDS_META_DATA add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

