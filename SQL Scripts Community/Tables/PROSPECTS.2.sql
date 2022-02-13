
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
-- 04/21/2006 Paul.  LEAD_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  ACCOUNT_NAME was added in SugarCRM 4.0.
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 12/25/2007 Paul.  CAMPAIGN_ID was added in SugarCRM 4.5.1
-- 09/15/2009 Paul.  Use new syntax to drop an index. 
-- 05/24/2015 Paul.  Add Picture. 
-- 02/11/2017 Paul.  New index based on missing indexes query. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 06/23/2018 Paul.  Add DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 

-- Deprecated feature 'DROP INDEX with two-part name' is not supported in this version of SQL Server.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'LEAD_ID') begin -- then
	print 'alter table PROSPECTS add LEAD_ID uniqueidentifier null';
	alter table PROSPECTS add LEAD_ID uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'ACCOUNT_NAME') begin -- then
	print 'alter table PROSPECTS add ACCOUNT_NAME nvarchar(150) null';
	alter table PROSPECTS add ACCOUNT_NAME nvarchar(150) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table PROSPECTS add TEAM_ID uniqueidentifier null';
	alter table PROSPECTS add TEAM_ID uniqueidentifier null;

	create index IDX_PROSPECTS_TEAM_ID on dbo.PROSPECTS (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'CAMPAIGN_ID') begin -- then
	print 'alter table PROSPECTS add CAMPAIGN_ID uniqueidentifier null';
	alter table PROSPECTS add CAMPAIGN_ID uniqueidentifier null;
end -- if;
GO

-- 04/21/2008 Paul.  SugarCRM 5.0 has moved EMAIL1 and EMAIL2 to the EMAIL_ADDRESSES table.
-- We will eventually duplicate this behavior, but not now.  Add the fields if missing. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'EMAIL1') begin -- then
	print 'alter table PROSPECTS add EMAIL1 nvarchar(100) null';
	alter table PROSPECTS add EMAIL1 nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'EMAIL2') begin -- then
	print 'alter table PROSPECTS add EMAIL2 nvarchar(100) null';
	alter table PROSPECTS add EMAIL2 nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'EMAIL_OPT_OUT') begin -- then
	print 'alter table PROSPECTS add EMAIL_OPT_OUT bit null default(0)';
	alter table PROSPECTS add EMAIL_OPT_OUT bit null default(0);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'INVALID_EMAIL') begin -- then
	print 'alter table PROSPECTS add INVALID_EMAIL bit null default(0)';
	alter table PROSPECTS add INVALID_EMAIL bit null default(0);
end -- if;
GO

-- 07/25/2009 Paul.  TRACKER_KEY is now a string. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'TRACKER_KEY' and DATA_TYPE <> 'nvarchar') begin -- then
	print 'Change PROSPECTS.TRACKER_KEY to nvarchar.';
	if exists (select * from sys.indexes where name = 'IDX_PROSPECTS_TRACKER_KEY') begin -- then
		drop index IDX_PROSPECTS_TRACKER_KEY on PROSPECTS;
	end -- if;

	declare @CURRENT_VALUE int;
	select @CURRENT_VALUE = max(TRACKER_KEY)
	  from PROSPECTS;
	-- 08/06/2009 Paul.  @CURRENT_VALUE cannot be null, so only insert if it has a value. 
	if @CURRENT_VALUE is not null begin -- then
		if exists (select * from NUMBER_SEQUENCES where NAME = 'PROSPECTS.TRACKER_KEY') begin -- then
			update NUMBER_SEQUENCES
			   set CURRENT_VALUE = @CURRENT_VALUE
			 where NAME = 'PROSPECTS.TRACKER_KEY';
		end else begin
			insert into NUMBER_SEQUENCES (ID, NAME, CURRENT_VALUE)
			values (newid(), 'PROSPECTS.TRACKER_KEY', @CURRENT_VALUE);
		end -- if;
	end -- if;

	exec sp_rename 'PROSPECTS.TRACKER_KEY', 'TRACKER_KEY_INT', 'COLUMN';
	exec ('alter table PROSPECTS add TRACKER_KEY nvarchar(30) null');
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	exec dbo.spSqlTableDisableTriggers 'PROSPECTS';
	exec ('update PROSPECTS set TRACKER_KEY = cast(TRACKER_KEY_INT as nvarchar(30))');
	exec dbo.spSqlTableEnableTriggers 'PROSPECTS';
	exec ('alter table PROSPECTS drop column TRACKER_KEY_INT');
	
	exec ('create index IDX_PROSPECTS_TRACKER_KEY          on dbo.PROSPECTS (TRACKER_KEY, DELETED, ID)');
end -- if;
GO

-- 08/08/2009 Paul.  We also need to change the field in the audit table. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS_AUDIT' and COLUMN_NAME = 'TRACKER_KEY' and DATA_TYPE <> 'nvarchar') begin -- then
	print 'Change PROSPECTS_AUDIT.TRACKER_KEY to nvarchar.';
	exec sp_rename 'PROSPECTS_AUDIT.TRACKER_KEY', 'TRACKER_KEY_INT', 'COLUMN';
	exec ('alter table PROSPECTS_AUDIT add TRACKER_KEY nvarchar(30) null');
	-- 04/27/2014 Paul.  Disable triggers as this is a system change that does not need to be tracked. 
	exec dbo.spSqlTableDisableTriggers 'PROSPECTS_AUDIT';
	exec ('update PROSPECTS_AUDIT set TRACKER_KEY = cast(TRACKER_KEY_INT as nvarchar(30))');
	exec dbo.spSqlTableEnableTriggers 'PROSPECTS_AUDIT';
	exec ('alter table PROSPECTS_AUDIT drop column TRACKER_KEY_INT');
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table PROSPECTS add TEAM_SET_ID uniqueidentifier null';
	alter table PROSPECTS add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_PROSPECTS_TEAM_SET_ID on dbo.PROSPECTS (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table PROSPECTS add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table PROSPECTS add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 10/24/2009 Paul.  Searching by first name is popular. 
if not exists (select * from sys.indexes where name = 'IDX_PROSPECTS_FIRST_NAME_LAST_NAME') begin -- then
	print 'create index IDX_PROSPECTS_FIRST_NAME_LAST_NAME';
	create index IDX_PROSPECTS_FIRST_NAME_LAST_NAME on dbo.PROSPECTS (FIRST_NAME, LAST_NAME, DELETED, ID);
end -- if;
GO

-- 10/16/2011 Paul.  Increase size of SALUTATION, FIRST_NAME and LAST_NAME to match SugarCRM. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'SALUTATION' and CHARACTER_MAXIMUM_LENGTH < 25) begin -- then
	print 'alter table PROSPECTS alter column SALUTATION nvarchar(25) null';
	alter table PROSPECTS alter column SALUTATION nvarchar(25) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS_AUDIT' and COLUMN_NAME = 'SALUTATION' and CHARACTER_MAXIMUM_LENGTH < 25) begin -- then
	print 'alter table PROSPECTS_AUDIT alter column SALUTATION nvarchar(25) null';
	alter table PROSPECTS_AUDIT alter column SALUTATION nvarchar(25) null;
end -- if;
GO

-- 09/27/2013 Paul.  SMS messages need to be opt-in. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'SMS_OPT_IN') begin -- then
	print 'alter table PROSPECTS add SMS_OPT_IN nvarchar(25) null';
	alter table PROSPECTS add SMS_OPT_IN nvarchar(25) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROSPECTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS_AUDIT' and COLUMN_NAME = 'SMS_OPT_IN') begin -- then
		print 'alter table PROSPECTS_AUDIT add SMS_OPT_IN nvarchar(25) null';
		alter table PROSPECTS_AUDIT add SMS_OPT_IN nvarchar(25) null;
	end -- if;
end -- if;
GO

-- 10/22/2013 Paul.  Provide a way to map Tweets to a parent. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'TWITTER_SCREEN_NAME') begin -- then
	print 'alter table PROSPECTS add TWITTER_SCREEN_NAME nvarchar(20) null';
	alter table PROSPECTS add TWITTER_SCREEN_NAME nvarchar(20) null;

	exec ('create index IDX_PROSPECTS_TWITTER_SCREEN on dbo.PROSPECTS (TWITTER_SCREEN_NAME, DELETED, ID)');
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROSPECTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS_AUDIT' and COLUMN_NAME = 'TWITTER_SCREEN_NAME') begin -- then
		print 'alter table PROSPECTS_AUDIT add TWITTER_SCREEN_NAME nvarchar(20) null';
		alter table PROSPECTS_AUDIT add TWITTER_SCREEN_NAME nvarchar(20) null;
	end -- if;
end -- if;
GO

-- 05/24/2015 Paul.  Add Picture. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'PICTURE') begin -- then
	print 'alter table PROSPECTS add PICTURE nvarchar(max) null';
	alter table PROSPECTS add PICTURE nvarchar(max) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROSPECTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS_AUDIT' and COLUMN_NAME = 'PICTURE') begin -- then
		print 'alter table PROSPECTS_AUDIT add PICTURE nvarchar(max) null';
		alter table PROSPECTS_AUDIT add PICTURE nvarchar(max) null;
	end -- if;
end -- if;
GO

-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from sys.indexes where name = 'IDX_PROSPECTS_EMAIL1') begin -- then
	print 'create index IDX_PROSPECTS_EMAIL1';
	create index IDX_PROSPECTS_EMAIL1 on dbo.PROSPECTS (EMAIL1, DELETED, ID)
end -- if;
GO

-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'PROSPECT_NUMBER') begin -- then
	print 'alter table PROSPECTS add PROSPECT_NUMBER nvarchar(30) null';
	alter table PROSPECTS add PROSPECT_NUMBER nvarchar(30) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROSPECTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS_AUDIT' and COLUMN_NAME = 'PROSPECT_NUMBER') begin -- then
		print 'alter table PROSPECTS_AUDIT add PROSPECT_NUMBER nvarchar(30) null';
		alter table PROSPECTS_AUDIT add PROSPECT_NUMBER nvarchar(30) null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table PROSPECTS add ASSIGNED_SET_ID uniqueidentifier null';
	alter table PROSPECTS add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_PROSPECTS_ASSIGNED_SET_ID on dbo.PROSPECTS (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROSPECTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table PROSPECTS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table PROSPECTS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

-- 06/23/2018 Paul.  Add LEAD_SOURCE, DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'LEAD_SOURCE') begin -- then
	print 'alter table PROSPECTS add LEAD_SOURCE nvarchar(100) null';
	alter table PROSPECTS add LEAD_SOURCE nvarchar(100) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROSPECTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS_AUDIT' and COLUMN_NAME = 'LEAD_SOURCE') begin -- then
		print 'alter table PROSPECTS_AUDIT add LEAD_SOURCE nvarchar(100) null';
		alter table PROSPECTS_AUDIT add LEAD_SOURCE nvarchar(100) null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'DP_BUSINESS_PURPOSE') begin -- then
	print 'alter table PROSPECTS add DP_BUSINESS_PURPOSE nvarchar(max) null';
	alter table PROSPECTS add DP_BUSINESS_PURPOSE nvarchar(max) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROSPECTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS_AUDIT' and COLUMN_NAME = 'DP_BUSINESS_PURPOSE') begin -- then
		print 'alter table PROSPECTS_AUDIT add DP_BUSINESS_PURPOSE nvarchar(max) null';
		alter table PROSPECTS_AUDIT add DP_BUSINESS_PURPOSE nvarchar(max) null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS' and COLUMN_NAME = 'DP_CONSENT_LAST_UPDATED') begin -- then
	print 'alter table PROSPECTS add DP_CONSENT_LAST_UPDATED datetime null';
	alter table PROSPECTS add DP_CONSENT_LAST_UPDATED datetime null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROSPECTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECTS_AUDIT' and COLUMN_NAME = 'DP_CONSENT_LAST_UPDATED') begin -- then
		print 'alter table PROSPECTS_AUDIT add DP_CONSENT_LAST_UPDATED datetime null';
		alter table PROSPECTS_AUDIT add DP_CONSENT_LAST_UPDATED datetime null;
	end -- if;
end -- if;
GO

