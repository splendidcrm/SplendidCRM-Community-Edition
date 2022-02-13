
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
-- 01/04/2006 Paul.  Add CUSTOM_ENABLED if module has a _CSTM table and can be customized. 
-- 04/24/2006 Paul.  Add IS_ADMIN to simplify ACL management. 
-- 05/02/2006 Paul.  Add TABLE_NAME as direct table queries are required by SOAP and we need a mapping. 
-- 05/02/2006 Paul.  Make sure to use unicode strings.  Oracle reported a conversion issue. 
-- 05/20/2006 Paul.  Add REPORT_ENABLED if the module can be the basis of a report. ACL rules will still apply. 
-- 10/07/2006 Paul.  Add IMPORT_ENABLED is needed to apply ACL rules. 
-- 11/17/2007 Paul.  Add MOBILE_ENABLED flag to determine if module should be shown on mobile browser.
-- 04/21/2008 Paul.  Move MODULE maintenance from Tables area to Data area. 
-- 07/20/2009 Paul.  Add SYNC_ENABLED flag to determine if module can be sync'd.
-- 09/08/2009 Paul.  Custom Paging can be enabled /disabled per module. 
-- 12/02/2009 Paul.  Add the ability to disable Mass Updates. 
-- 01/13/2010 Paul.  Allow default search to be disabled. 
-- 04/01/2010 Paul.  Add Exchange Sync flag. 
-- 04/04/2010 Paul.  Add Exchange Folders flag. 
-- 04/05/2010 Paul.  Add Exchange Create Parent flag. 
-- 06/18/2011 Paul.  SYSTEM_REST_TABLES are nearly identical to SYSTEM_SYNC_TABLES,
-- but the Module tables typically refer to the base view instead of the raw table. 
-- 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
-- 07/31/2019 Paul.  DEFAULT_SORT is a new field for the React Client. 
set nocount on;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'CUSTOM_ENABLED') begin -- then
	print 'alter table MODULES add CUSTOM_ENABLED bit null default(0)';
	alter table MODULES add CUSTOM_ENABLED bit null default(0);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'CUSTOM_PAGING') begin -- then
	print 'alter table MODULES add CUSTOM_PAGING bit null default(0)';
	alter table MODULES add CUSTOM_PAGING bit null default(0);
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'IS_ADMIN') begin -- then
	print 'alter table MODULES add IS_ADMIN bit null default(0)';
	alter table MODULES add IS_ADMIN bit null default(0);
	
	exec ('update MODULES set IS_ADMIN = 0');
	exec ('update MODULES set IS_ADMIN = 1 where MODULE_NAME = N''ACLRoles''');
	exec ('update MODULES set IS_ADMIN = 1 where MODULE_NAME = N''Administration''');
	exec ('update MODULES set IS_ADMIN = 1 where MODULE_NAME = N''Dropdown''');
	exec ('update MODULES set IS_ADMIN = 1 where MODULE_NAME = N''DynamicLayout''');
	exec ('update MODULES set IS_ADMIN = 1 where MODULE_NAME = N''EditCustomFields''');
	exec ('update MODULES set IS_ADMIN = 1 where MODULE_NAME = N''Import''');
	exec ('update MODULES set IS_ADMIN = 1 where MODULE_NAME = N''Roles''');
	exec ('update MODULES set IS_ADMIN = 1 where MODULE_NAME = N''Terminology''');
	exec ('update MODULES set IS_ADMIN = 1 where MODULE_NAME = N''Users''');
	exec ('update MODULES set IS_ADMIN = 1 where MODULE_NAME = N''Releases''');
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'TABLE_NAME') begin -- then
	print 'alter table MODULES add TABLE_NAME nvarchar(30) null';
	alter table MODULES add TABLE_NAME nvarchar(30) null;

	exec (	'update MODULES
		   set TABLE_NAME = (case when MODULE_NAME = N''EmailMarketing'' then N''EMAIL_MARKETING''
		                          when MODULE_NAME = N''EmailTemplates'' then N''EMAIL_TEMPLATES''
		                          when MODULE_NAME = N''ProjectTask''    then N''PROJECT_TASK''
		                          when MODULE_NAME = N''ProspectLists''  then N''PROSPECT_LISTS''
		                          when MODULE_NAME = N''TestCases''      then N''TEST_CASES''
		                          when MODULE_NAME = N''TestPlans''      then N''TEST_PLANS''
		                          when MODULE_NAME = N''TestRuns''       then N''TEST_RUNS''
		                     else upper(MODULE_NAME)
		                     end)
		 where TABLE_NAME is null');
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'REPORT_ENABLED') begin -- then
	print 'alter table MODULES add REPORT_ENABLED bit null default(0)';
	alter table MODULES add REPORT_ENABLED bit null default(0);

	exec ( 'update MODULES
		   set REPORT_ENABLED = 1
		 where MODULE_NAME in (
			  N''Accounts''
			, N''Bugs''
			, N''Calls''
			, N''Campaigns''
			, N''Cases''
			, N''Contacts''
			, N''Documents''
			, N''Emails''
			, N''Leads''
			, N''Meetings''
			, N''Opportunities''
			, N''Project''
			, N''ProjectTask''
			, N''ProspectLists''
			, N''Prospects''
			, N''Releases''
			, N''Tasks''
			, N''Users'') ');
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'IMPORT_ENABLED') begin -- then
	print 'alter table MODULES add IMPORT_ENABLED bit null default(0)';
	alter table MODULES add IMPORT_ENABLED bit null default(0);

	exec ( 'update MODULES
		   set IMPORT_ENABLED = 1
		 where MODULE_NAME in (
			  N''Accounts''
			, N''Contacts''
			, N''Notes''
			, N''Opportunities''
			, N''Leads''
			, N''Prospects'') ');
end -- if;
GO

-- 11/17/2007 Paul.  Add MOBILE_ENABLED flag.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'MOBILE_ENABLED') begin -- then
	print 'alter table MODULES add MOBILE_ENABLED bit null default(0)';
	alter table MODULES add MOBILE_ENABLED bit null default(0);

	exec ( 'update MODULES
		   set MOBILE_ENABLED = 1
		 where MODULE_NAME in (
			  N''Accounts''
			, N''Calls''
			, N''Cases''
			, N''Contacts''
			, N''Leads''
			, N''Meetings''
			, N''Opportunities''
			, N''Tasks'') ');
end -- if;
GO

-- 07/20/2009 Paul.  Add SYNC_ENABLED flag to determine if module can be sync'd.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'SYNC_ENABLED') begin -- then
	print 'alter table MODULES add SYNC_ENABLED bit null default(0)';
	alter table MODULES add SYNC_ENABLED bit null default(0);

	exec ( 'update MODULES
		   set SYNC_ENABLED = 1
		 where MODULE_NAME in 
			( N''Accounts''
			, N''Bugs''
			, N''Calls''
			, N''Cases''
			, N''Contacts''
			, N''Documents''
			, N''Emails''
			, N''Leads''
			, N''Meetings''
			, N''Notes''
			, N''Opportunities''
			, N''Project''
			, N''ProjectTask''
			, N''Prospects''
			, N''Releases''
			, N''Tasks''
			, N''Users''
			)');
end -- if;
GO

-- 06/18/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'REST_ENABLED') begin -- then
	print 'alter table MODULES add REST_ENABLED bit null default(0)';
	alter table MODULES add REST_ENABLED bit null default(0);

	exec ( 'update MODULES
		   set REST_ENABLED = 1
		 where MODULE_NAME in 
			( N''Accounts''
			, N''Bugs''
			, N''Calls''
			, N''Cases''
			, N''Contacts''
			, N''Documents''
			, N''Emails''
			, N''Leads''
			, N''Meetings''
			, N''Notes''
			, N''Opportunities''
			, N''Project''
			, N''ProjectTask''
			, N''Prospects''
			, N''Releases''
			, N''Tasks''
			, N''Users''
			)');
end -- if;
GO

-- 11/17/2009 Paul.  We have added DATE_MODIFIED_UTC to tables that are sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table MODULES add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table MODULES add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

-- 07/20/2009 Paul.  Add SYNC_ENABLED flag to determine if module can be sync'd.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'MASS_UPDATE_ENABLED') begin -- then
	print 'alter table MODULES add MASS_UPDATE_ENABLED bit null default(0)';
	alter table MODULES add MASS_UPDATE_ENABLED bit null default(0);

	-- 01/13/2010 Paul.  Project and ProjectTask should be singular. 
	exec ( 'update MODULES
		   set MASS_UPDATE_ENABLED = 1
		 where MODULE_NAME in 
			( N''Accounts''
			, N''Bugs''
			, N''Calls''
			, N''Campaigns''
			, N''Cases''
			, N''Contacts''
			, N''Contracts''
			, N''Documents''
			, N''Emails''
			, N''EmailTemplates''
			, N''iFrames''
			, N''Invoices''
			, N''KBDocuments''
			, N''Leads''
			, N''Meetings''
			, N''Notes''
			, N''Opportunities''
			, N''Orders''
			, N''Payments''
			, N''Products''
			, N''Project''
			, N''ProjectTask''
			, N''ProspectLists''
			, N''Prospects''
			, N''Quotes''
			, N''Tasks''
			)');
end -- if;
GO

-- 01/13/2010 Paul.  Allow default search to be disabled. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'DEFAULT_SEARCH_ENABLED') begin -- then
	print 'alter table MODULES add DEFAULT_SEARCH_ENABLED bit null default(1)';
	alter table MODULES add DEFAULT_SEARCH_ENABLED bit null default(1);

	exec ( 'update MODULES
		   set DEFAULT_SEARCH_ENABLED = 1');
end -- if;
GO

-- 04/01/2010 Paul.  Add Exchange Sync flag. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'EXCHANGE_SYNC') begin -- then
	print 'alter table MODULES add EXCHANGE_SYNC bit null default(0)';
	alter table MODULES add EXCHANGE_SYNC bit null default(0);
	
	exec ( 'update MODULES
		   set EXCHANGE_SYNC = 0');
	exec ( 'update MODULES
		   set EXCHANGE_SYNC = 1
		 where MODULE_NAME in 
			( N''Accounts''
			, N''Bugs''
			, N''Cases''
			, N''Contacts''
			, N''Leads''
			, N''Opportunities''
			, N''Project''
			)');
end -- if;
GO

-- 04/04/2010 Paul.  Add Exchange Folders flag. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'EXCHANGE_FOLDERS') begin -- then
	print 'alter table MODULES add EXCHANGE_FOLDERS bit null default(0)';
	alter table MODULES add EXCHANGE_FOLDERS bit null default(0);
	
	exec ( 'update MODULES
		   set EXCHANGE_FOLDERS = 0');
	exec ( 'update MODULES
		   set EXCHANGE_FOLDERS = 1
		 where MODULE_NAME in 
			( N''Accounts''
			, N''Bugs''
			, N''Cases''
			, N''Contacts''
			, N''Leads''
			, N''Opportunities''
			, N''Project''
			)');
end -- if;
GO

-- 04/05/2010 Paul.  Add Exchange Create Parent flag. Need to be able to disable Account creation. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'EXCHANGE_CREATE_PARENT') begin -- then
	print 'alter table MODULES add EXCHANGE_CREATE_PARENT bit null default(0)';
	alter table MODULES add EXCHANGE_CREATE_PARENT bit null default(0);
	
	exec ( 'update MODULES
		   set EXCHANGE_CREATE_PARENT = 0');
	exec ( 'update MODULES
		   set EXCHANGE_CREATE_PARENT = 1
		 where MODULE_NAME in 
			( N''Accounts''
			, N''Bugs''
			, N''Cases''
			, N''Contacts''
			, N''Leads''
			, N''Opportunities''
			, N''Project''
			)');
end -- if;
GO

-- 03/14/2014 Paul.  DUP_CHECH_ENABLED enables duplicate checking. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'DUPLICATE_CHECHING_ENABLED') begin -- then
	print 'alter table MODULES add DUPLICATE_CHECHING_ENABLED bit null default(0)';
	alter table MODULES add DUPLICATE_CHECHING_ENABLED bit null default(0);
end -- if;
GO

-- 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'RECORD_LEVEL_SECURITY_ENABLED') begin -- then
	print 'alter table MODULES add RECORD_LEVEL_SECURITY_ENABLED bit null default(0)';
	alter table MODULES add RECORD_LEVEL_SECURITY_ENABLED bit null default(0);
end -- if;
GO

-- 07/31/2019 Paul.  DEFAULT_SORT is a new field for the React Client. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'MODULES' and COLUMN_NAME = 'DEFAULT_SORT') begin -- then
	print 'alter table MODULES add DEFAULT_SORT nvarchar(50) null';
	alter table MODULES add DEFAULT_SORT nvarchar(50) null;
end -- if;
GO

set nocount off;
GO

