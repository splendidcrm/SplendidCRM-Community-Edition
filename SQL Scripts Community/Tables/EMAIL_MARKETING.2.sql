
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
-- 04/21/2006 Paul.  INBOUND_EMAIL_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  STATUS was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  ALL_PROSPECT_LISTS was added in SugarCRM 4.0.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_MARKETING' and COLUMN_NAME = 'INBOUND_EMAIL_ID') begin -- then
	print 'alter table EMAIL_MARKETING add INBOUND_EMAIL_ID uniqueidentifier null';
	alter table EMAIL_MARKETING add INBOUND_EMAIL_ID uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_MARKETING' and COLUMN_NAME = 'STATUS') begin -- then
	print 'alter table EMAIL_MARKETING add STATUS nvarchar(25) null';
	alter table EMAIL_MARKETING add STATUS nvarchar(25) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_MARKETING' and COLUMN_NAME = 'ALL_PROSPECT_LISTS') begin -- then
	print 'alter table EMAIL_MARKETING add ALL_PROSPECT_LISTS bit null default(0)';
	alter table EMAIL_MARKETING add ALL_PROSPECT_LISTS bit null default(0);
end -- if;
GO

-- 04/21/2008 Paul.  SugarCRM 5.0 has dropped TIME_START and combined it with DATE_START. 
-- We did this long ago, but we kept the use of TIME_START for compatibility with MySQL. 
-- We will eventually duplicate this behavior, but not now.  Add the fields if missing. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_MARKETING' and COLUMN_NAME = 'TIME_START') begin -- then
	print 'alter table EMAIL_MARKETING add TIME_START datetime null';
	alter table EMAIL_MARKETING add TIME_START datetime null;
end -- if;
GO

-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_MARKETING' and COLUMN_NAME = 'REPLY_TO_NAME') begin -- then
	print 'alter table EMAIL_MARKETING add REPLY_TO_NAME nvarchar(100) null';
	alter table EMAIL_MARKETING add REPLY_TO_NAME nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_MARKETING' and COLUMN_NAME = 'REPLY_TO_ADDR') begin -- then
	print 'alter table EMAIL_MARKETING add REPLY_TO_ADDR nvarchar(100) null';
	alter table EMAIL_MARKETING add REPLY_TO_ADDR nvarchar(100) null;
end -- if;
GO

