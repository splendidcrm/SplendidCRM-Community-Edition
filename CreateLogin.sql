/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved.
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

declare @dbName sysname;
declare @dbUser sysname;
declare @dbPwd  nvarchar(100);
declare @cmd    nvarchar(1000);

set @dbName = 'PlaceholderForDbName';
set @dbUser = 'PlaceholderForDbUsername';
set @dbPwd  = 'PlaceholderForDbUserPassword';

-- Create login
if SUSER_SID(@dbUser) is null begin -- then
	print '-- Creating login ';
	set @cmd = N'create login ' + quotename(@dbUser) + N' with password = '''+ @dbPwd + N'''';
	exec (@cmd);
end -- if;

-- Create database user and map to login
-- and add user to the datareader, datawriter, ddladmin and securityadmin roles
set @cmd = N'use ' + quotename(@DBName) + N'; 
if not exists (select * from sys.database_principals where name = ''' + replace(@dbUser, '''', '''''') + N''') begin -- then
    print ''-- Creating user'';
    create user ' + quotename(@dbUser) + N' for login ' + quotename(@dbUser) + N';
    print ''-- Adding user'';
    exec sp_addrolemember ''db_owner'', ''' + replace(@dbUser, '''', '''''') + N''';
end -- if;'

exec (@cmd);
GO

