
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
-- 02/18/2010 Paul.  The MODULES_GROUPS table is a system table and should not be audited. 
if exists (select * from sys.objects where name = 'trMODULES_GROUPS_Ins_AUDIT' and type = 'TR') begin -- then
	print 'drop trigger dbo.trMODULES_GROUPS_Ins_AUDIT';
	drop trigger dbo.trMODULES_GROUPS_Ins_AUDIT;
end -- if;

if exists (select * from sys.objects where name = 'trMODULES_GROUPS_Upd_AUDIT' and type = 'TR') begin -- then
	print 'drop trigger dbo.trMODULES_GROUPS_Upd_AUDIT';
	drop trigger dbo.trMODULES_GROUPS_Upd_AUDIT;
end -- if;

if exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES_GROUPS_AUDIT') begin -- then
	print 'drop table dbo.MODULES_GROUPS_AUDIT';
	drop table dbo.MODULES_GROUPS_AUDIT;
end -- if;

-- 09/24/2009 Paul.  The new Silverlight charts exceeded the control name length of 50. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES_GROUPS' and COLUMN_NAME = 'CONTROL_NAME' and CHARACTER_MAXIMUM_LENGTH < 100) begin -- then
	print 'alter table MODULES_GROUPS alter column CONTROL_NAME nvarchar(100) not null';
	alter table MODULES_GROUPS alter column CONTROL_NAME nvarchar(100) not null;
end -- if;
GO

-- 02/24/2010 Paul.  We need to specify an order to the modules for the tab menu. 
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES_GROUPS' and COLUMN_NAME = 'MODULE_ORDER') begin -- then
	print 'alter table MODULES_GROUPS add MODULE_ORDER int null';
	alter table MODULES_GROUPS add MODULE_ORDER int null;
end -- if;
GO

-- 02/24/2010 Paul.  We need to specify an order to the modules for the tab menu. 
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES_GROUPS' and COLUMN_NAME = 'MODULE_MENU') begin -- then
	print 'alter table MODULES_GROUPS add MODULE_MENU bit null';
	alter table MODULES_GROUPS add MODULE_MENU bit null;
end -- if;
GO

