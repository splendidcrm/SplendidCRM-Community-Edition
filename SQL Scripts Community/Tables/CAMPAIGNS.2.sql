
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
-- 04/21/2006 Paul.  CURRENCY_ID was added in SugarCRM 4.2.
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 12/25/2007 Paul.  IMPRESSIONS was added in SugarCRM 4.5.1
-- 12/25/2007 Paul.  FREQUENCY was added in SugarCRM 4.5.1
-- 12/25/2007 Paul.  Add USDOLLAR fields so that they can be automatically converted. 
-- 09/15/2009 Paul.  Use new syntax to drop an index. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 

-- Deprecated feature 'DROP INDEX with two-part name' is not supported in this version of SQL Server.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'CURRENCY_ID') begin -- then
	print 'alter table CAMPAIGNS add CURRENCY_ID uniqueidentifier null';
	alter table CAMPAIGNS add CURRENCY_ID uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table CAMPAIGNS add TEAM_ID uniqueidentifier null';
	alter table CAMPAIGNS add TEAM_ID uniqueidentifier null;

	create index IDX_CAMPAIGNS_TEAM_ID on dbo.CAMPAIGNS (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'IMPRESSIONS') begin -- then
	print 'alter table CAMPAIGNS add IMPRESSIONS int null default(0)';
	alter table CAMPAIGNS add IMPRESSIONS int null default(0);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'FREQUENCY') begin -- then
	print 'alter table CAMPAIGNS add FREQUENCY nvarchar(25) null';
	alter table CAMPAIGNS add FREQUENCY nvarchar(25) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'BUDGET_USDOLLAR') begin -- then
	print 'alter table CAMPAIGNS add BUDGET_USDOLLAR money null';
	alter table CAMPAIGNS add BUDGET_USDOLLAR money null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'EXPECTED_COST_USDOLLAR') begin -- then
	print 'alter table CAMPAIGNS add EXPECTED_COST_USDOLLAR money null';
	alter table CAMPAIGNS add EXPECTED_COST_USDOLLAR money null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'ACTUAL_COST_USDOLLAR') begin -- then
	print 'alter table CAMPAIGNS add ACTUAL_COST_USDOLLAR money null';
	alter table CAMPAIGNS add ACTUAL_COST_USDOLLAR money null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'EXPECTED_REVENUE_USDOLLAR') begin -- then
	print 'alter table CAMPAIGNS add EXPECTED_REVENUE_USDOLLAR money null';
	alter table CAMPAIGNS add EXPECTED_REVENUE_USDOLLAR money null;
end -- if;
GO

-- 07/25/2009 Paul.  TRACKER_KEY is now a string. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'TRACKER_KEY' and DATA_TYPE <> 'nvarchar') begin -- then
	print 'Change CAMPAIGNS.TRACKER_KEY to nvarchar.';
	if exists (select * from sys.indexes where name = 'IDX_CAMPAIGNS_TRACKER_KEY') begin -- then
		drop index IDX_CAMPAIGNS_TRACKER_KEY on CAMPAIGNS;
	end -- if;

	declare @CURRENT_VALUE int;
	select @CURRENT_VALUE = max(TRACKER_KEY)
	  from CAMPAIGNS;
	-- 08/06/2009 Paul.  @CURRENT_VALUE cannot be null, so only insert if it has a value. 
	if @CURRENT_VALUE is not null begin -- then
		if exists (select * from NUMBER_SEQUENCES where NAME = 'CAMPAIGNS.TRACKER_KEY') begin -- then
			update NUMBER_SEQUENCES
			   set CURRENT_VALUE = @CURRENT_VALUE
			 where NAME = 'CAMPAIGNS.TRACKER_KEY';
		end else begin
			insert into NUMBER_SEQUENCES (ID, NAME, CURRENT_VALUE)
			values (newid(), 'CAMPAIGNS.TRACKER_KEY', @CURRENT_VALUE);
		end -- if;
	end -- if;

	-- 02/18/2010 Paul.  Disable triggers before converting.
	exec dbo.spSqlTableDisableTriggers 'CAMPAIGNS';
	
	exec sp_rename 'CAMPAIGNS.TRACKER_KEY', 'TRACKER_KEY_INT', 'COLUMN';
	exec ('alter table CAMPAIGNS add TRACKER_KEY nvarchar(30) null');
	exec ('update CAMPAIGNS set TRACKER_KEY = cast(TRACKER_KEY_INT as nvarchar(30))');
	exec ('alter table CAMPAIGNS drop column TRACKER_KEY_INT');
	
	-- 02/18/2010 Paul.  Enable triggers after converting.
	exec dbo.spSqlTableEnableTriggers 'CAMPAIGNS';
	
	exec ('create index IDX_CAMPAIGNS_TRACKER_KEY      on dbo.CAMPAIGNS (TRACKER_KEY, ID, DELETED)');
end -- if;
GO

-- 08/08/2009 Paul.  We also need to change the field in the audit table. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS_AUDIT' and COLUMN_NAME = 'TRACKER_KEY' and DATA_TYPE <> 'nvarchar') begin -- then
	print 'Change CAMPAIGNS_AUDIT_AUDIT.TRACKER_KEY to nvarchar.';
	exec sp_rename 'CAMPAIGNS_AUDIT.TRACKER_KEY', 'TRACKER_KEY_INT', 'COLUMN';
	exec ('alter table CAMPAIGNS_AUDIT add TRACKER_KEY nvarchar(30) null');
	exec ('update CAMPAIGNS_AUDIT set TRACKER_KEY = cast(TRACKER_KEY_INT as nvarchar(30))');
	exec ('alter table CAMPAIGNS_AUDIT drop column TRACKER_KEY_INT');
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table CAMPAIGNS add TEAM_SET_ID uniqueidentifier null';
	alter table CAMPAIGNS add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_CAMPAIGNS_TEAM_SET_ID on dbo.CAMPAIGNS (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID);
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table CAMPAIGNS add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table CAMPAIGNS add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'CAMPAIGN_NUMBER') begin -- then
	print 'alter table CAMPAIGNS add CAMPAIGN_NUMBER nvarchar(30) null';
	alter table CAMPAIGNS add CAMPAIGN_NUMBER nvarchar(30) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CAMPAIGNS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS_AUDIT' and COLUMN_NAME = 'CAMPAIGN_NUMBER') begin -- then
		print 'alter table CAMPAIGNS_AUDIT add CAMPAIGN_NUMBER nvarchar(30) null';
		alter table CAMPAIGNS_AUDIT add CAMPAIGN_NUMBER nvarchar(30) null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table CAMPAIGNS add ASSIGNED_SET_ID uniqueidentifier null';
	alter table CAMPAIGNS add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_CAMPAIGNS_ASSIGNED_SET_ID on dbo.CAMPAIGNS (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CAMPAIGNS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGNS_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table CAMPAIGNS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table CAMPAIGNS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

