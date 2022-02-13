
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
-- 04/21/2006 Paul.  CAMPAIGN_ID was added in SugarCRM 4.0.
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 05/24/2015 Paul.  Add Picture. 
-- 02/11/2017 Paul.  New index based on missing indexes query. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 06/23/2018 Paul.  Add DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'CAMPAIGN_ID') begin -- then
	print 'alter table LEADS add CAMPAIGN_ID uniqueidentifier null';
	alter table LEADS add CAMPAIGN_ID uniqueidentifier null;
end -- if;
GO


if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table LEADS add TEAM_ID uniqueidentifier null';
	alter table LEADS add TEAM_ID uniqueidentifier null;

	create index IDX_LEADS_TEAM_ID on dbo.LEADS (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 04/21/2008 Paul.  SugarCRM 5.0 has moved EMAIL1 and EMAIL2 to the EMAIL_ADDRESSES table.
-- We will eventually duplicate this behavior, but not now.  Add the fields if missing. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'EMAIL1') begin -- then
	print 'alter table LEADS add EMAIL1 nvarchar(100) null';
	alter table LEADS add EMAIL1 nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'EMAIL2') begin -- then
	print 'alter table LEADS add EMAIL2 nvarchar(100) null';
	alter table LEADS add EMAIL2 nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'EMAIL_OPT_OUT') begin -- then
	print 'alter table LEADS add EMAIL_OPT_OUT bit null default(0)';
	alter table LEADS add EMAIL_OPT_OUT bit null default(0);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'INVALID_EMAIL') begin -- then
	print 'alter table LEADS add INVALID_EMAIL bit null default(0)';
	alter table LEADS add INVALID_EMAIL bit null default(0);
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table LEADS add TEAM_SET_ID uniqueidentifier null';
	alter table LEADS add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_LEADS_TEAM_SET_ID on dbo.LEADS (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table LEADS add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table LEADS add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 10/24/2009 Paul.  Searching by first name is popular. 
if not exists (select * from sys.indexes where name = 'IDX_LEADS_FIRST_NAME_LAST_NAME') begin -- then
	print 'create index IDX_LEADS_FIRST_NAME_LAST_NAME';
	create index IDX_LEADS_FIRST_NAME_LAST_NAME        on dbo.LEADS (FIRST_NAME, LAST_NAME, DELETED, ID);
end -- if;
GO

-- 10/16/2011 Paul.  Increase size of SALUTATION, FIRST_NAME and LAST_NAME to match SugarCRM. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'SALUTATION' and CHARACTER_MAXIMUM_LENGTH < 25) begin -- then
	print 'alter table LEADS alter column SALUTATION nvarchar(25) null';
	alter table LEADS alter column SALUTATION nvarchar(25) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'SALUTATION' and CHARACTER_MAXIMUM_LENGTH < 25) begin -- then
		print 'alter table LEADS_AUDIT alter column SALUTATION nvarchar(25) null';
		alter table LEADS_AUDIT alter column SALUTATION nvarchar(25) null;
	end -- if;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'FIRST_NAME' and CHARACTER_MAXIMUM_LENGTH < 100) begin -- then
	print 'alter table LEADS alter column FIRST_NAME nvarchar(100) null';
	alter table LEADS alter column FIRST_NAME nvarchar(100) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'FIRST_NAME' and CHARACTER_MAXIMUM_LENGTH < 100) begin -- then
		print 'alter table LEADS_AUDIT alter column FIRST_NAME nvarchar(100) null';
		alter table LEADS_AUDIT alter column FIRST_NAME nvarchar(100) null;
	end -- if;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'LAST_NAME' and CHARACTER_MAXIMUM_LENGTH < 100) begin -- then
	print 'alter table LEADS alter column LAST_NAME nvarchar(100) null';
	alter table LEADS alter column LAST_NAME nvarchar(100) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'LAST_NAME' and CHARACTER_MAXIMUM_LENGTH < 100) begin -- then
		print 'alter table LEADS_AUDIT alter column LAST_NAME nvarchar(100) null';
		alter table LEADS_AUDIT alter column LAST_NAME nvarchar(100) null;
	end -- if;
end -- if;
GO

-- 04/02/2012 Paul.  Add ASSISTANT, ASSISTANT_PHONE, BIRTHDATE, WEBSITE. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'BIRTHDATE') begin -- then
	print 'alter table LEADS add BIRTHDATE datetime null';
	alter table LEADS add BIRTHDATE datetime null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'BIRTHDATE') begin -- then
		print 'alter table LEADS_AUDIT add BIRTHDATE datetime null';
		alter table LEADS_AUDIT add BIRTHDATE datetime null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'ASSISTANT') begin -- then
	print 'alter table LEADS add ASSISTANT nvarchar(75) null';
	alter table LEADS add ASSISTANT nvarchar(75) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'ASSISTANT') begin -- then
		print 'alter table LEADS_AUDIT add ASSISTANT nvarchar(75) null';
		alter table LEADS_AUDIT add ASSISTANT nvarchar(75) null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'ASSISTANT_PHONE') begin -- then
	print 'alter table LEADS add ASSISTANT_PHONE nvarchar(25) null';
	alter table LEADS add ASSISTANT_PHONE nvarchar(25) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'ASSISTANT_PHONE') begin -- then
		print 'alter table LEADS_AUDIT add ASSISTANT_PHONE nvarchar(25) null';
		alter table LEADS_AUDIT add ASSISTANT_PHONE nvarchar(25) null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'WEBSITE') begin -- then
	print 'alter table LEADS add WEBSITE nvarchar(255) null';
	alter table LEADS add WEBSITE nvarchar(255) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'WEBSITE') begin -- then
		print 'alter table LEADS_AUDIT add WEBSITE nvarchar(255) null';
		alter table LEADS_AUDIT add WEBSITE nvarchar(255) null;
	end -- if;
end -- if;
GO

-- 09/27/2013 Paul.  SMS messages need to be opt-in. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'SMS_OPT_IN') begin -- then
	print 'alter table LEADS add SMS_OPT_IN nvarchar(25) null';
	alter table LEADS add SMS_OPT_IN nvarchar(25) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'SMS_OPT_IN') begin -- then
		print 'alter table LEADS_AUDIT add SMS_OPT_IN nvarchar(25) null';
		alter table LEADS_AUDIT add SMS_OPT_IN nvarchar(25) null;
	end -- if;
end -- if;
GO

-- 10/22/2013 Paul.  Provide a way to map Tweets to a parent. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'TWITTER_SCREEN_NAME') begin -- then
	print 'alter table LEADS add TWITTER_SCREEN_NAME nvarchar(20) null';
	alter table LEADS add TWITTER_SCREEN_NAME nvarchar(20) null;

	exec ('create index IDX_LEADS_TWITTER_SCREEN_NAME on dbo.LEADS (TWITTER_SCREEN_NAME, DELETED, ID)');
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'TWITTER_SCREEN_NAME') begin -- then
		print 'alter table LEADS_AUDIT add TWITTER_SCREEN_NAME nvarchar(20) null';
		alter table LEADS_AUDIT add TWITTER_SCREEN_NAME nvarchar(20) null;
	end -- if;
end -- if;
GO

-- 05/24/2015 Paul.  Add Picture. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'PICTURE') begin -- then
	print 'alter table LEADS add PICTURE nvarchar(max) null';
	alter table LEADS add PICTURE nvarchar(max) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'PICTURE') begin -- then
		print 'alter table LEADS_AUDIT add PICTURE nvarchar(max) null';
		alter table LEADS_AUDIT add PICTURE nvarchar(max) null;
	end -- if;
end -- if;
GO

-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from sys.indexes where name = 'IDX_LEADS_DELETED_EMAIL1') begin -- then
	print 'create index IDX_LEADS_DELETED_EMAIL1';
	create index IDX_LEADS_DELETED_EMAIL1 on dbo.LEADS (DELETED, EMAIL1)
end -- if;
GO


-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'LEAD_NUMBER') begin -- then
	print 'alter table LEADS add LEAD_NUMBER nvarchar(30) null';
	alter table LEADS add LEAD_NUMBER nvarchar(30) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'LEAD_NUMBER') begin -- then
		print 'alter table LEADS_AUDIT add LEAD_NUMBER nvarchar(30) null';
		alter table LEADS_AUDIT add LEAD_NUMBER nvarchar(30) null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table LEADS add ASSIGNED_SET_ID uniqueidentifier null';
	alter table LEADS add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_LEADS_ASSIGNED_SET_ID on dbo.LEADS (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table LEADS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table LEADS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

-- 06/23/2018 Paul.  Add DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'DP_BUSINESS_PURPOSE') begin -- then
	print 'alter table LEADS add DP_BUSINESS_PURPOSE nvarchar(max) null';
	alter table LEADS add DP_BUSINESS_PURPOSE nvarchar(max) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'DP_BUSINESS_PURPOSE') begin -- then
		print 'alter table LEADS_AUDIT add DP_BUSINESS_PURPOSE nvarchar(max) null';
		alter table LEADS_AUDIT add DP_BUSINESS_PURPOSE nvarchar(max) null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS' and COLUMN_NAME = 'DP_CONSENT_LAST_UPDATED') begin -- then
	print 'alter table LEADS add DP_CONSENT_LAST_UPDATED datetime null';
	alter table LEADS add DP_CONSENT_LAST_UPDATED datetime null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LEADS_AUDIT' and COLUMN_NAME = 'DP_CONSENT_LAST_UPDATED') begin -- then
		print 'alter table LEADS_AUDIT add DP_CONSENT_LAST_UPDATED datetime null';
		alter table LEADS_AUDIT add DP_CONSENT_LAST_UPDATED datetime null;
	end -- if;
end -- if;
GO

