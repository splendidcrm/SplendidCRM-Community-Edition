
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
-- 07/16/2005 Paul.  Version 3.0.1 increased the size of the NEXT_STEP field. 
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 12/25/2007 Paul.  CAMPAIGN_ID was added in SugarCRM 4.5.1
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES' and COLUMN_NAME = 'NEXT_STEP' and CHARACTER_MAXIMUM_LENGTH <> 100) begin -- then
	print 'alter table OPPORTUNITIES alter column NEXT_STEP nvarchar(100) null';
	alter table OPPORTUNITIES alter column NEXT_STEP nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table OPPORTUNITIES add TEAM_ID uniqueidentifier null';
	alter table OPPORTUNITIES add TEAM_ID uniqueidentifier null;

	create index IDX_OPPORTUNITIES_TEAM_ID on dbo.OPPORTUNITIES (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES' and COLUMN_NAME = 'CAMPAIGN_ID') begin -- then
	print 'alter table OPPORTUNITIES add CAMPAIGN_ID uniqueidentifier null';
	alter table OPPORTUNITIES add CAMPAIGN_ID uniqueidentifier null;

	create index IDX_OPPORTUNITIES_CAMPAIGN_ID on dbo.OPPORTUNITIES (CAMPAIGN_ID, SALES_STAGE, DELETED, AMOUNT)
end -- if;
GO

-- 04/21/2008 Paul.  SugarCRM 5.0 dropped AMOUNT_BACKUP.  We will eventually do the same. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES' and COLUMN_NAME = 'AMOUNT_BACKUP') begin -- then
	print 'alter table OPPORTUNITIES add AMOUNT_BACKUP nvarchar(25) null';
	alter table OPPORTUNITIES add AMOUNT_BACKUP nvarchar(25) null;
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table OPPORTUNITIES add TEAM_SET_ID uniqueidentifier null';
	alter table OPPORTUNITIES add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_OPPORTUNITIES_TEAM_SET_ID on dbo.OPPORTUNITIES (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table OPPORTUNITIES add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table OPPORTUNITIES add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 10/05/2010 Paul.  Increase the size of the NAME field. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES' and COLUMN_NAME = 'NAME' and CHARACTER_MAXIMUM_LENGTH < 150) begin -- then
	print 'alter table OPPORTUNITIES alter column NAME nvarchar(150) null';
	alter table OPPORTUNITIES alter column NAME nvarchar(150) null;
end -- if;
GO

-- 10/20/2010 Paul.  Increase the size of the NAME field in the audit table. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES_AUDIT') begin -- then
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES_AUDIT' and COLUMN_NAME = 'NAME' and CHARACTER_MAXIMUM_LENGTH < 150) begin -- then
		print 'alter table OPPORTUNITIES_AUDIT alter column NAME nvarchar(150) null';
		alter table OPPORTUNITIES_AUDIT alter column NAME nvarchar(150) null;
	end -- if;
end -- if;
GO

-- 05/01/2013 Paul.  Add Contacts field to support B2C. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES' and COLUMN_NAME = 'B2C_CONTACT_ID') begin -- then
	print 'alter table OPPORTUNITIES add B2C_CONTACT_ID uniqueidentifier null';
	alter table OPPORTUNITIES add B2C_CONTACT_ID uniqueidentifier null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'OPPORTUNITIES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES_AUDIT' and COLUMN_NAME = 'B2C_CONTACT_ID') begin -- then
		print 'alter table OPPORTUNITIES_AUDIT add B2C_CONTACT_ID uniqueidentifier null';
		alter table OPPORTUNITIES_AUDIT add B2C_CONTACT_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES' and COLUMN_NAME = 'OPPORTUNITY_NUMBER') begin -- then
	print 'alter table OPPORTUNITIES add OPPORTUNITY_NUMBER nvarchar(30) null';
	alter table OPPORTUNITIES add OPPORTUNITY_NUMBER nvarchar(30) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'OPPORTUNITIES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES_AUDIT' and COLUMN_NAME = 'OPPORTUNITY_NUMBER') begin -- then
		print 'alter table OPPORTUNITIES_AUDIT add OPPORTUNITY_NUMBER nvarchar(30) null';
		alter table OPPORTUNITIES_AUDIT add OPPORTUNITY_NUMBER nvarchar(30) null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table OPPORTUNITIES add ASSIGNED_SET_ID uniqueidentifier null';
	alter table OPPORTUNITIES add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_OPPORTUNITIES_ASSIGNED_SET_ID on dbo.OPPORTUNITIES (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'OPPORTUNITIES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'OPPORTUNITIES_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table OPPORTUNITIES_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table OPPORTUNITIES_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

