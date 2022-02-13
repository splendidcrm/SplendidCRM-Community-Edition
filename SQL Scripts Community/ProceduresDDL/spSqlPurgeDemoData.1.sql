if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlPurgeDemoData' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlPurgeDemoData;
GO


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
-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
-- This also fixes a problem for a customer with 100 custom fields. 
-- 12/21/2011 Paul.  Clean Contracts table. 
Create Procedure dbo.spSqlPurgeDemoData
as
  begin
	set nocount on

	-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
	declare @Command           varchar(max);
	declare @TABLE_NAME varchar(80);
	declare DEPENDS2_CURSOR cursor for
	select TABLE_NAME
	  from INFORMATION_SCHEMA.TABLES
	 where TABLE_NAME in
		( ''
		, 'CONTRACTS_OPPORTUNITIES_AUDIT'
		, 'CONTRACTS_OPPORTUNITIES'
		, 'CONTRACTS_DOCUMENTS_AUDIT'
		, 'CONTRACTS_DOCUMENTS'
		, 'CONTRACTS_CONTACTS_AUDIT'
		, 'CONTRACTS_CONTACTS'
		, 'CONTRACTS_PRODUCTS_AUDIT'
		, 'CONTRACTS_PRODUCTS'
		, 'CONTRACTS_QUOTES_AUDIT'
		, 'CONTRACTS_QUOTES'
		, 'EMAILS_CONTRACTS_AUDIT'
		, 'EMAILS_CONTRACTS'
		, 'OPPORTUNITIES_CONTACTS_AUDIT'
		, 'OPPORTUNITIES_CONTACTS'
		, 'MEETINGS_USERS_AUDIT'
		, 'MEETINGS_USERS'
		, 'MEETINGS_CONTACTS_AUDIT'
		, 'MEETINGS_CONTACTS'
		, 'EMAILS_USERS_AUDIT'
		, 'EMAILS_USERS'
		, 'EMAILS_CONTACTS_AUDIT'
		, 'EMAILS_CONTACTS'
		, 'EMAILS_ACCOUNTS_AUDIT'
		, 'EMAILS_ACCOUNTS'
		, 'CALLS_USERS_AUDIT'
		, 'CALLS_USERS'
		, 'ACCOUNTS_OPPORTUNITIES_AUDIT'
		, 'ACCOUNTS_OPPORTUNITIES'
		, 'ACCOUNTS_CONTACTS_AUDIT'
		, 'ACCOUNTS_CONTACTS'
		)
	 order by TABLE_NAME desc;
	declare DEPENDS1_CURSOR cursor for
	select TABLE_NAME
	  from INFORMATION_SCHEMA.TABLES
	 where TABLE_NAME in
		( 'TRACKER'
		, 'CONTRACTS_CSTM_AUDIT'
		, 'CONTRACTS_AUDIT'
		, 'CONTRACTS_CSTM'
		, 'CONTRACTS'
		, 'TASKS_CSTM_AUDIT'
		, 'TASKS_CSTM'
		, 'TASKS_AUDIT'
		, 'TASKS'
		, 'PROJECT_TASK_CSTM_AUDIT'
		, 'PROJECT_TASK_CSTM'
		, 'PROJECT_TASK_AUDIT'
		, 'PROJECT_TASK'
		, 'PROJECT_CSTM_AUDIT'
		, 'PROJECT_CSTM'
		, 'PROJECT_AUDIT'
		, 'PROJECT'
		, 'OPPORTUNITIES_CSTM_AUDIT'
		, 'OPPORTUNITIES_CSTM'
		, 'OPPORTUNITIES_AUDIT'
		, 'OPPORTUNITIES'
		, 'NOTES_CSTM_AUDIT'
		, 'NOTES_CSTM'
		, 'NOTES_AUDIT'
		, 'NOTES'
		, 'MEETINGS_CSTM_AUDIT'
		, 'MEETINGS_CSTM'
		, 'MEETINGS_AUDIT'
		, 'MEETINGS'
		, 'LEADS_CSTM_AUDIT'
		, 'LEADS_CSTM'
		, 'LEADS_AUDIT'
		, 'LEADS'
		, 'EMAILS_CSTM_AUDIT'
		, 'EMAILS_CSTM'
		, 'EMAILS_AUDIT'
		, 'EMAILS'
		, 'EMAIL_TEMPLATES_CSTM_AUDIT'
		, 'EMAIL_TEMPLATES_CSTM'
		, 'EMAIL_TEMPLATES_AUDIT'
		, 'EMAIL_TEMPLATES'
		, 'CONTACTS_CSTM_AUDIT'
		, 'CONTACTS_CSTM'
		, 'CONTACTS_AUDIT'
		, 'CONTACTS'
		, 'CASES_CSTM_AUDIT'
		, 'CASES_CSTM'
		, 'CASES_AUDIT'
		, 'CASES'
		, 'CALLS_CSTM_AUDIT'
		, 'CALLS_CSTM'
		, 'CALLS_AUDIT'
		, 'CALLS'
		, 'BUGS_CSTM_AUDIT'
		, 'BUGS_CSTM'
		, 'BUGS_AUDIT'
		, 'BUGS'
		, 'ACCOUNTS_CSTM_AUDIT'
		, 'ACCOUNTS_CSTM'
		, 'ACCOUNTS_AUDIT'
		, 'ACCOUNTS'
		)
	 order by TABLE_NAME desc;
	declare DEPENDS0_CURSOR cursor for
	select TABLE_NAME
	  from INFORMATION_SCHEMA.TABLES
	 where TABLE_NAME in
		( 'USERS_LOGINS'
		, 'USERS_CSTM_AUDIT'
		, 'USERS_CSTM'
		, 'USERS_AUDIT'
		, 'USERS'
		)
	 order by TABLE_NAME desc;
	
	open DEPENDS2_CURSOR;
	fetch next from DEPENDS2_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		if right(@TABLE_NAME, 5) = '_CSTM' begin -- then
			set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where ID_C in (select ID from ' + substring(@TABLE_NAME, 1, len(@TABLE_NAME) - 5) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'');';
		end else if right(@TABLE_NAME, 11) = '_CSTM_AUDIT' begin -- then
			set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where ID_C in (select ID from ' + substring(@TABLE_NAME, 1, len(@TABLE_NAME) - 11) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'');';
		end else begin
			set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'';';
		end -- if;
		print @Command
		exec(@Command);
		fetch next from DEPENDS2_CURSOR into @TABLE_NAME;
	end -- while;
	close DEPENDS2_CURSOR;
	deallocate DEPENDS2_CURSOR;

	open DEPENDS1_CURSOR;
	fetch next from DEPENDS1_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		-- 12/21/2011 Paul.  Make sure to delete records dependent on an account or a contact. 
		if exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME and COLUMN_NAME = 'ACCOUNT_ID') begin -- then
			if right(@TABLE_NAME, 5) = '_CSTM' begin -- then
				set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where ID_C in (select ID from ' + substring(@TABLE_NAME, 1, len(@TABLE_NAME) - 5) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'' or ACCOUNT_ID in (select ID from ACCOUNTS where CREATED_BY = ''00000000-0000-0000-0000-000000000003''));';
			end else if right(@TABLE_NAME, 11) = '_CSTM_AUDIT' begin -- then
				set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where ID_C in (select ID from ' + substring(@TABLE_NAME, 1, len(@TABLE_NAME) - 11) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'' or ACCOUNT_ID in (select ID from ACCOUNTS where CREATED_BY = ''00000000-0000-0000-0000-000000000003''));';
			end else begin
				set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'' or ACCOUNT_ID in (select ID from ACCOUNTS where CREATED_BY = ''00000000-0000-0000-0000-000000000003'');';
			end -- if;
		end else if exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME and COLUMN_NAME = 'CONTACT_ID') begin -- then
			if right(@TABLE_NAME, 5) = '_CSTM' begin -- then
				set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where ID_C in (select ID from ' + substring(@TABLE_NAME, 1, len(@TABLE_NAME) - 5) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'' or CONTACT_ID in (select ID from CONTACTS where CREATED_BY = ''00000000-0000-0000-0000-000000000003''));';
			end else if right(@TABLE_NAME, 11) = '_CSTM_AUDIT' begin -- then
				set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where ID_C in (select ID from ' + substring(@TABLE_NAME, 1, len(@TABLE_NAME) - 11) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'' or CONTACT_ID in (select ID from CONTACTS where CREATED_BY = ''00000000-0000-0000-0000-000000000003''));';
			end else begin
				set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'' or CONTACT_ID in (select ID from CONTACTS where CREATED_BY = ''00000000-0000-0000-0000-000000000003'');';
			end -- if;
		end else if right(@TABLE_NAME, 5) = '_CSTM' begin -- then
			set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where ID_C in (select ID from ' + substring(@TABLE_NAME, 1, len(@TABLE_NAME) - 5) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'');';
		end else if right(@TABLE_NAME, 11) = '_CSTM_AUDIT' begin -- then
			set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where ID_C in (select ID from ' + substring(@TABLE_NAME, 1, len(@TABLE_NAME) - 11) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'');';
		end else begin
			set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'';';
		end -- if;
		print @Command
		exec(@Command);
		fetch next from DEPENDS1_CURSOR into @TABLE_NAME;
	end -- while;
	close DEPENDS1_CURSOR;
	deallocate DEPENDS1_CURSOR;

	-- 12/21/2011 Paul.  Team Memberships might be depended on users that will be deleted. 
	if exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TEAM_MEMBERSHIPS') begin -- then
		set @Command = 'delete from TEAM_MEMBERSHIPS where CREATED_BY = ''00000000-0000-0000-0000-000000000003'' or USER_ID in (select ID from USERS where CREATED_BY = ''00000000-0000-0000-0000-000000000003'')';
		print @Command;
		exec(@Command);
	end -- if;
	
	-- 06/07/2017 Paul.  Delete demo teams. 
	-- 09/13/2019 Paul.  Make sure that TEAM_SETS_TEAMS exists. 
	if exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TEAM_SETS_TEAMS') begin -- then
		set @Command = 'delete from TEAM_SETS_TEAMS where TEAM_ID in (select ID from TEAMS where CREATED_BY = ''00000000-0000-0000-0000-000000000003'' or PARENT_ID = ''00000000-0000-0000-0003-000000000003'')';
		print @Command;
		exec(@Command);
	end -- if;
	if exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TEAMS') begin -- then
		set @Command = 'delete from TEAMS where CREATED_BY = ''00000000-0000-0000-0000-000000000003'' or PARENT_ID = ''00000000-0000-0000-0003-000000000003''';
		print @Command;
		exec(@Command);
	end -- if;
	
	open DEPENDS0_CURSOR;
	fetch next from DEPENDS0_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		if right(@TABLE_NAME, 5) = '_CSTM' begin -- then
			set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where ID_C in (select ID from ' + substring(@TABLE_NAME, 1, len(@TABLE_NAME) - 5) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'');';
		end else begin
			set @Command = 'delete from ' + @TABLE_NAME + space(35 - len(@TABLE_NAME)) + ' where CREATED_BY = ''00000000-0000-0000-0000-000000000003'';';
		end -- if;
		print @Command
		exec(@Command);
		fetch next from DEPENDS0_CURSOR into @TABLE_NAME;
	end -- while;
	close DEPENDS0_CURSOR;
	deallocate DEPENDS0_CURSOR;

  end
GO

-- exec dbo.spSqlPurgeDemoData;

Grant Execute on dbo.spSqlPurgeDemoData to public;
GO

