
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
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DASHLETS' and COLUMN_NAME = 'CATEGORY') begin -- then
	print 'alter table DASHLETS add CATEGORY nvarchar(25) null';
	alter table DASHLETS add CATEGORY nvarchar(25) null;
end -- if;
GO

-- 09/24/2009 Paul.  The DASHLETS table is a system table and should not be audited. 
if exists (select * from sys.objects where name = 'trDASHLETS_Ins_AUDIT' and type = 'TR') begin -- then
	print 'drop trigger dbo.trDASHLETS_Ins_AUDIT';
	drop trigger dbo.trDASHLETS_Ins_AUDIT;
end -- if;

if exists (select * from sys.objects where name = 'trDASHLETS_Upd_AUDIT' and type = 'TR') begin -- then
	print 'drop trigger dbo.trDASHLETS_Upd_AUDIT';
	drop trigger dbo.trDASHLETS_Upd_AUDIT;
end -- if;

if exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DASHLETS_AUDIT') begin -- then
	print 'drop table dbo.DASHLETS_AUDIT';
	drop table dbo.DASHLETS_AUDIT;
end -- if;

-- 09/24/2009 Paul.  The new Silverlight charts exceeded the control name length of 50. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DASHLETS' and COLUMN_NAME = 'CONTROL_NAME' and CHARACTER_MAXIMUM_LENGTH < 100) begin -- then
	print 'alter table DASHLETS alter column CONTROL_NAME nvarchar(100) not null';
	alter table DASHLETS alter column CONTROL_NAME nvarchar(100) not null;
end -- if;
GO

-- 01/24/2010 Paul.  Allow multiple. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DASHLETS' and COLUMN_NAME = 'ALLOW_MULTIPLE') begin -- then
	print 'alter table DASHLETS add ALLOW_MULTIPLE bit null default(0)';
	alter table DASHLETS add ALLOW_MULTIPLE bit null default(0);
	exec('update DASHLETS set ALLOW_MULTIPLE = 0');
end -- if;
GO

