
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
-- 07/16/2013 Paul.  USER_ID should be nullable so that table can contain system email accounts. 
-- 04/20/2016 Paul.  Add team management to Outbound Emails. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OUTBOUND_EMAILS' and COLUMN_NAME = 'USER_ID' and IS_NULLABLE = 'NO') begin -- then
	print 'alter table OUTBOUND_EMAILS alter column USER_ID uniqueidentifier null';
	alter table OUTBOUND_EMAILS alter column USER_ID uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OUTBOUND_EMAILS' and COLUMN_NAME = 'FROM_NAME') begin -- then
	print 'alter table OUTBOUND_EMAILS add FROM_NAME nvarchar(100) null';
	alter table OUTBOUND_EMAILS add FROM_NAME nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OUTBOUND_EMAILS' and COLUMN_NAME = 'FROM_ADDR') begin -- then
	print 'alter table OUTBOUND_EMAILS add FROM_ADDR nvarchar(100) null';
	alter table OUTBOUND_EMAILS add FROM_ADDR nvarchar(100) null;
end -- if;
GO

-- 04/20/2016 Paul.  Add team management to Outbound Emails. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OUTBOUND_EMAILS' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table OUTBOUND_EMAILS add TEAM_ID uniqueidentifier null';
	alter table OUTBOUND_EMAILS add TEAM_ID uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OUTBOUND_EMAILS' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table OUTBOUND_EMAILS add TEAM_SET_ID uniqueidentifier null';
	alter table OUTBOUND_EMAILS add TEAM_SET_ID uniqueidentifier null;
end -- if;
GO

-- 01/17/2017 Paul.  Increase size of @MAIL_SENDTYPE to fit office365. 
-- 11/07/2017 Paul.  Correct max test. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OUTBOUND_EMAILS' and COLUMN_NAME = 'MAIL_SENDTYPE' and CHARACTER_MAXIMUM_LENGTH < 25) begin -- then
	print 'alter table OUTBOUND_EMAILS alter column MAIL_SENDTYPE nvarchar(25) null';
	alter table OUTBOUND_EMAILS alter column MAIL_SENDTYPE nvarchar(25) null;
end -- if;
GO

