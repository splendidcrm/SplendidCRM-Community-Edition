
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
-- 04/21/2008 Paul.  SugarCRM 5.0 does not have some of the core auditing fields. 
-- 05/01/2009 Paul.  SugarCRM 4.5.1 migration requires addition of auditing fields.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_FEEDS' and COLUMN_NAME = 'ID') begin -- then
	print 'alter table USERS_FEEDS add ID uniqueidentifier not null default(newid())';
	alter table USERS_FEEDS add ID uniqueidentifier not null default(newid());
	alter table USERS_FEEDS add constraint PK_USERS_FEEDS primary key (ID);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_FEEDS' and COLUMN_NAME = 'CREATED_BY') begin -- then
	print 'alter table USERS_FEEDS alter column CREATED_BY uniqueidentifier null';
	alter table USERS_FEEDS add CREATED_BY uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_FEEDS' and COLUMN_NAME = 'MODIFIED_USER_ID') begin -- then
	print 'alter table USERS_FEEDS alter column MODIFIED_USER_ID uniqueidentifier null';
	alter table USERS_FEEDS add MODIFIED_USER_ID uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_FEEDS' and COLUMN_NAME = 'DATE_ENTERED') begin -- then
	print 'alter table USERS_FEEDS alter column DATE_ENTERED datetime not null default(getdate())';
	alter table USERS_FEEDS add DATE_ENTERED datetime not null default(getdate());
end -- if;
GO


if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_FEEDS' and COLUMN_NAME = 'DATE_MODIFIED') begin -- then
	print 'alter table USERS_FEEDS alter column DATE_MODIFIED datetime not null default(getdate())';
	alter table USERS_FEEDS add DATE_MODIFIED datetime not null default(getdate());
end -- if;
GO


