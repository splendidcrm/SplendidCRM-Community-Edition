
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
-- 01/06/2006 Paul.  Administration shortcuts are large.
-- 04/28/2006 Paul.  Added SHORTCUT_MODULE to help with ACL. 
-- 04/28/2006 Paul.  Added SHORTCUT_ACLTYPE to help with ACL. 
-- 07/24/2006 Paul.  Increase the DISPLAY_NAME to 150 to allow a fully-qualified (NAME+MODULE_NAME+LIST_NAME) TERMINOLOGY name. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SHORTCUTS' and COLUMN_NAME = 'RELATIVE_PATH' and CHARACTER_MAXIMUM_LENGTH < 255) begin -- then
	print 'alter table SHORTCUTS alter column RELATIVE_PATH nvarchar(255) not null';
	alter table SHORTCUTS alter column RELATIVE_PATH nvarchar(255) not null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SHORTCUTS' and COLUMN_NAME = 'SHORTCUT_MODULE') begin -- then
	print 'alter table SHORTCUTS add SHORTCUT_MODULE nvarchar(25) null';
	alter table SHORTCUTS add SHORTCUT_MODULE nvarchar(25) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SHORTCUTS' and COLUMN_NAME = 'SHORTCUT_ACLTYPE') begin -- then
	print 'alter table SHORTCUTS add SHORTCUT_ACLTYPE nvarchar(100) null';
	alter table SHORTCUTS add SHORTCUT_ACLTYPE nvarchar(100) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SHORTCUTS' and COLUMN_NAME = 'DISPLAY_NAME' and CHARACTER_MAXIMUM_LENGTH < 150) begin -- then
	print 'alter table SHORTCUTS alter column DISPLAY_NAME nvarchar(150) not null';
	alter table SHORTCUTS alter column DISPLAY_NAME nvarchar(150) not null;
end -- if;
GO

