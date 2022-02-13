
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
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DYNAMIC_BUTTONS' and COLUMN_NAME = 'EXCLUDE_MOBILE') begin -- then
	print 'alter table DYNAMIC_BUTTONS add EXCLUDE_MOBILE bit null default(0)';
	alter table DYNAMIC_BUTTONS add EXCLUDE_MOBILE bit null default(0);
end -- if;
GO

-- 03/14/2014 Paul.  Allow hidden buttons to be created. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DYNAMIC_BUTTONS' and COLUMN_NAME = 'HIDDEN') begin -- then
	print 'alter table DYNAMIC_BUTTONS add HIDDEN bit null default(0)';
	alter table DYNAMIC_BUTTONS add HIDDEN bit null default(0);
end -- if;
GO

-- 08/16/2017 Paul.  Increase the size of the ONCLICK_SCRIPT so that we can add a javascript info column. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DYNAMIC_BUTTONS' and COLUMN_NAME = 'ONCLICK_SCRIPT' and CHARACTER_MAXIMUM_LENGTH <> -1) begin -- then
	print 'alter table DYNAMIC_BUTTONS alter column ONCLICK_SCRIPT nvarchar(max) null';
	alter table DYNAMIC_BUTTONS alter column ONCLICK_SCRIPT nvarchar(max) null;
end -- if;
GO

-- 08/16/2017 Paul.  Add ability to apply a business rule to a button. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DYNAMIC_BUTTONS' and COLUMN_NAME = 'BUSINESS_RULE') begin -- then
	print 'alter table DYNAMIC_BUTTONS add BUSINESS_RULE nvarchar(max) null';
	alter table DYNAMIC_BUTTONS add BUSINESS_RULE nvarchar(max) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DYNAMIC_BUTTONS' and COLUMN_NAME = 'BUSINESS_SCRIPT') begin -- then
	print 'alter table DYNAMIC_BUTTONS add BUSINESS_SCRIPT nvarchar(max) null';
	alter table DYNAMIC_BUTTONS add BUSINESS_SCRIPT nvarchar(max) null;
end -- if;
GO

