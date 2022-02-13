
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
-- 04/21/2006 Paul.  TITLE was increased to nvarchar(50) in SugarCRM 4.0.
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 12/25/2007 Paul.  CAMPAIGN_ID was added in SugarCRM 4.5.1
-- 03/05/2009 Paul.  Add PORTAL_PASSWORD for Splendid Portal.  Sugar added it in 4.5.0. 
-- 05/24/2015 Paul.  Add Picture. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 06/23/2018 Paul.  Add DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'TITLE' and CHARACTER_MAXIMUM_LENGTH < 50) begin -- then
	print 'alter table CONTACTS alter column TITLE nvarchar(50) null';
	alter table CONTACTS alter column TITLE nvarchar(50) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table CONTACTS add TEAM_ID uniqueidentifier null';
	alter table CONTACTS add TEAM_ID uniqueidentifier null;

	create index IDX_CONTACTS_TEAM_ID on dbo.CONTACTS (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'CAMPAIGN_ID') begin -- then
	print 'alter table CONTACTS add CAMPAIGN_ID uniqueidentifier null';
	alter table CONTACTS add CAMPAIGN_ID uniqueidentifier null;
end -- if;
GO

-- 04/21/2008 Paul.  SugarCRM 5.0 has moved EMAIL1 and EMAIL2 to the EMAIL_ADDRESSES table.
-- We will eventually duplicate this behavior, but not now.  Add the fields if missing. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'EMAIL1') begin -- then
	print 'alter table CONTACTS add EMAIL1 nvarchar(100) null';
	alter table CONTACTS add EMAIL1 nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'EMAIL2') begin -- then
	print 'alter table CONTACTS add EMAIL2 nvarchar(100) null';
	alter table CONTACTS add EMAIL2 nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'EMAIL_OPT_OUT') begin -- then
	print 'alter table CONTACTS add EMAIL_OPT_OUT bit null default(0)';
	alter table CONTACTS add EMAIL_OPT_OUT bit null default(0);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'INVALID_EMAIL') begin -- then
	print 'alter table CONTACTS add INVALID_EMAIL bit null default(0)';
	alter table CONTACTS add INVALID_EMAIL bit null default(0);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'PORTAL_PASSWORD') begin -- then
	print 'alter table CONTACTS add PORTAL_PASSWORD nvarchar(32) null';
	alter table CONTACTS add PORTAL_PASSWORD nvarchar(32) null;

	create index IDX_CONTACTS_PORTAL on dbo.CONTACTS (DELETED, PORTAL_ACTIVE, PORTAL_NAME, PORTAL_PASSWORD, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add support for dynamic teams. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table CONTACTS add TEAM_SET_ID uniqueidentifier null';
	alter table CONTACTS add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_CONTACTS_TEAM_SET_ID on dbo.CONTACTS (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

-- 08/21/2009 Paul.  Add UTC date so that this module can be sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table CONTACTS add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table CONTACTS add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 09/07/2009 Paul.  The vwACCOUNTS_List view joins to contacts and returns the full contact name. 
if not exists (select * from sys.indexes where name = 'IDX_CONTACTS_ID_LAST_FIRST') begin -- then
	print 'create index IDX_CONTACTS_ID_LAST_FIRST';
	create index IDX_CONTACTS_ID_LAST_FIRST           on dbo.CONTACTS (ID, DELETED, LAST_NAME, FIRST_NAME);
end -- if;
GO

-- 10/24/2009 Paul.  Searching by first name is popular. 
if not exists (select * from sys.indexes where name = 'IDX_CONTACTS_FIRST_NAME_LAST_NAME') begin -- then
	print 'create index IDX_CONTACTS_FIRST_NAME_LAST_NAME';
	create index IDX_CONTACTS_FIRST_NAME_LAST_NAME    on dbo.CONTACTS (FIRST_NAME, LAST_NAME, DELETED, ID);
end -- if;
GO

-- 10/16/2011 Paul.  Increase size of SALUTATION, FIRST_NAME and LAST_NAME to match SugarCRM. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'SALUTATION' and CHARACTER_MAXIMUM_LENGTH < 25) begin -- then
	print 'alter table CONTACTS alter column SALUTATION nvarchar(25) null';
	alter table CONTACTS alter column SALUTATION nvarchar(25) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS_AUDIT' and COLUMN_NAME = 'SALUTATION' and CHARACTER_MAXIMUM_LENGTH < 25) begin -- then
	print 'alter table CONTACTS_AUDIT alter column SALUTATION nvarchar(25) null';
	alter table CONTACTS_AUDIT alter column SALUTATION nvarchar(25) null;
end -- if;
GO

-- 09/27/2013 Paul.  SMS messages need to be opt-in. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'SMS_OPT_IN') begin -- then
	print 'alter table CONTACTS add SMS_OPT_IN nvarchar(25) null';
	alter table CONTACTS add SMS_OPT_IN nvarchar(25) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CONTACTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS_AUDIT' and COLUMN_NAME = 'SMS_OPT_IN') begin -- then
		print 'alter table CONTACTS_AUDIT add SMS_OPT_IN nvarchar(25) null';
		alter table CONTACTS_AUDIT add SMS_OPT_IN nvarchar(25) null;
	end -- if;
end -- if;
GO

-- 10/22/2013 Paul.  Provide a way to map Tweets to a parent. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'TWITTER_SCREEN_NAME') begin -- then
	print 'alter table CONTACTS add TWITTER_SCREEN_NAME nvarchar(20) null';
	alter table CONTACTS add TWITTER_SCREEN_NAME nvarchar(20) null;

	exec ('create index IDX_CONTACTS_TWITTER_SCREEN on dbo.CONTACTS (TWITTER_SCREEN_NAME, DELETED, ID)');
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CONTACTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS_AUDIT' and COLUMN_NAME = 'TWITTER_SCREEN_NAME') begin -- then
		print 'alter table CONTACTS_AUDIT add TWITTER_SCREEN_NAME nvarchar(20) null';
		alter table CONTACTS_AUDIT add TWITTER_SCREEN_NAME nvarchar(20) null;
	end -- if;
end -- if;
GO

-- 05/24/2015 Paul.  Add Picture. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'PICTURE') begin -- then
	print 'alter table CONTACTS add PICTURE nvarchar(max) null';
	alter table CONTACTS add PICTURE nvarchar(max) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CONTACTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS_AUDIT' and COLUMN_NAME = 'PICTURE') begin -- then
		print 'alter table CONTACTS_AUDIT add PICTURE nvarchar(max) null';
		alter table CONTACTS_AUDIT add PICTURE nvarchar(max) null;
	end -- if;
end -- if;
GO

-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'CONTACT_NUMBER') begin -- then
	print 'alter table CONTACTS add CONTACT_NUMBER nvarchar(30) null';
	alter table CONTACTS add CONTACT_NUMBER nvarchar(30) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CONTACTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS_AUDIT' and COLUMN_NAME = 'CONTACT_NUMBER') begin -- then
		print 'alter table CONTACTS_AUDIT add CONTACT_NUMBER nvarchar(30) null';
		alter table CONTACTS_AUDIT add CONTACT_NUMBER nvarchar(30) null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table CONTACTS add ASSIGNED_SET_ID uniqueidentifier null';
	alter table CONTACTS add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_CONTACTS_ASSIGNED_SET_ID on dbo.CONTACTS (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CONTACTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table CONTACTS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table CONTACTS_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

-- 06/23/2018 Paul.  Add DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'DP_BUSINESS_PURPOSE') begin -- then
	print 'alter table CONTACTS add DP_BUSINESS_PURPOSE nvarchar(max) null';
	alter table CONTACTS add DP_BUSINESS_PURPOSE nvarchar(max) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CONTACTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS_AUDIT' and COLUMN_NAME = 'DP_BUSINESS_PURPOSE') begin -- then
		print 'alter table CONTACTS_AUDIT add DP_BUSINESS_PURPOSE nvarchar(max) null';
		alter table CONTACTS_AUDIT add DP_BUSINESS_PURPOSE nvarchar(max) null;
	end -- if;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS' and COLUMN_NAME = 'DP_CONSENT_LAST_UPDATED') begin -- then
	print 'alter table CONTACTS add DP_CONSENT_LAST_UPDATED datetime null';
	alter table CONTACTS add DP_CONSENT_LAST_UPDATED datetime null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CONTACTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CONTACTS_AUDIT' and COLUMN_NAME = 'DP_CONSENT_LAST_UPDATED') begin -- then
		print 'alter table CONTACTS_AUDIT add DP_CONSENT_LAST_UPDATED datetime null';
		alter table CONTACTS_AUDIT add DP_CONSENT_LAST_UPDATED datetime null;
	end -- if;
end -- if;
GO

