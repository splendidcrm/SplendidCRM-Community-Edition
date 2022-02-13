
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
-- 09/05/2015 Paul.  Google now uses OAuth 2.0. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OAUTH_TOKENS' and COLUMN_NAME = 'TOKEN_EXPIRES_AT') begin -- then
	print 'alter table OAUTH_TOKENS add TOKEN_EXPIRES_AT datetime null';
	alter table OAUTH_TOKENS add TOKEN_EXPIRES_AT datetime null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OAUTH_TOKENS' and COLUMN_NAME = 'REFRESH_TOKEN') begin -- then
	print 'alter table OAUTH_TOKENS add REFRESH_TOKEN nvarchar(2000) null';
	alter table OAUTH_TOKENS add REFRESH_TOKEN nvarchar(2000) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OAUTH_TOKENS' and COLUMN_NAME = 'NAME' and CHARACTER_MAXIMUM_LENGTH < 50) begin -- then
	print 'alter table OAUTH_TOKENS alter column NAME nvarchar(50) null';
	alter table OAUTH_TOKENS alter column NAME nvarchar(50) null;
end -- if;
GO

-- 01/19/2017 Paul.  The Microsoft OAuth token can be large, but less than 2000 bytes. 
-- 12/02/2020 Paul.  The Microsoft OAuth token is now about 2400, so increase to 4000 characters.
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OAUTH_TOKENS' and COLUMN_NAME = 'TOKEN' and CHARACTER_MAXIMUM_LENGTH < 4000) begin -- then
	print 'alter table OAUTH_TOKENS alter column TOKEN nvarchar(4000) null';
	alter table OAUTH_TOKENS alter column TOKEN nvarchar(4000) null;
end -- if;
GO

-- 01/19/2017 Paul.  The Microsoft OAuth token can be large, but less than 2000 bytes. 
-- 12/02/2020 Paul.  The Microsoft OAuth token is now about 2400, so increase to 4000 characters.
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OAUTH_TOKENS' and COLUMN_NAME = 'REFRESH_TOKEN' and CHARACTER_MAXIMUM_LENGTH < 4000) begin -- then
	print 'alter table OAUTH_TOKENS alter column REFRESH_TOKEN nvarchar(4000) null';
	alter table OAUTH_TOKENS alter column REFRESH_TOKEN nvarchar(4000) null;
end -- if;
GO

