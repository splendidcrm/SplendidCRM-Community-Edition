
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
-- 03/06/2008 Paul.  The USERS_LOGINS fields should match SYSTEM_LOG fields to simplify joins. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_LOGINS' and COLUMN_NAME = 'SERVER_HOST') begin -- then
	print 'alter table USERS_LOGINS add SERVER_HOST nvarchar(100) null';
	alter table USERS_LOGINS add SERVER_HOST nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_LOGINS' and COLUMN_NAME = 'RELATIVE_PATH') begin -- then
	print 'alter table USERS_LOGINS add RELATIVE_PATH nvarchar(255) null';
	alter table USERS_LOGINS add RELATIVE_PATH nvarchar(255) null;
end -- if;
GO

-- 08/07/2010 Paul.  Create an index to speed the cleanup of the logins table. 
if not exists (select * from sys.indexes where name = 'IDX_USERS_LOGINS_LOGIN_DATE') begin -- then
	print 'create index IDX_USERS_LOGINS_LOGIN_DATE';
	create index IDX_USERS_LOGINS_LOGIN_DATE on dbo.USERS_LOGINS (LOGIN_DATE)
end -- if;
GO

