if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildArchiveView' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildArchiveView;
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
-- 10/16/2018 Paul.  Join to both main and archive table. 
-- 02/08/2020 Paul.  Include Audit tables. 
-- 02/26/2021 Paul.  Correct CSTM AUDIT table name.  Audit archive was not including custom fields. 
-- 05/04/2021 Paul.  Must include the AUDIT_TOKEN in join for audit tables. 
Create Procedure dbo.spSqlBuildArchiveView
	( @TABLE_NAME       nvarchar(80)
	, @ARCHIVE_DATABASE nvarchar(50)
	)
as
  begin
	set nocount on
	print 'spSqlBuildArchiveView ' + @TABLE_NAME;
	
	declare @COMMAND              nvarchar(max);
	declare @CRLF                 nchar(2);
	declare @ARCHIVE_TABLE        nvarchar(90);
	declare @CSTM_ARCHIVE_TABLE   nvarchar(90);
	declare @VIEW_NAME            nvarchar(90);
	declare @COLUMN_NAME          nvarchar(80);
	declare @TEST                 bit;
	declare @JOIN_ASSIGNED        bit;
	declare @JOIN_TEAMS           bit;
	declare @JOIN_TEAM_SETS       bit;
	declare @JOIN_TAG_SETS        bit;
	declare @JOIN_LAST_ACTIVITY   bit;
	declare @JOIN_ASSIGNED_SETS   bit;
	declare @SPLENDID_FIELDS      int;
	declare @EXISTS               bit;
	declare @ARCHIVE_DATABASE_DOT nvarchar(50);
	--declare @ACCOUNTS_TABLE       nvarchar(50);
	--declare @CONTACTS_ARCHIVE     nvarchar(50);
	--declare @QUOTES_ARCHIVE       nvarchar(50);
	--declare @ORDERS_ARCHIVE       nvarchar(50);
	-- 10/16/2018 Paul.  Join to both main and archive table. 
	declare @ACCOUNTS_ARCHIVE_EXISTS      bit;
	declare @CONTACTS_ARCHIVE_EXISTS      bit;
	declare @QUOTES_ARCHIVE_EXISTS        bit;
	declare @ORDERS_ARCHIVE_EXISTS        bit;
	declare @LEADS_ARCHIVE_EXISTS         bit;
	declare @OPPORTUNITIES_ARCHIVE_EXISTS bit;

	set @TEST = 0;
	set @SPLENDID_FIELDS    = 0;
	set @ARCHIVE_TABLE      = @TABLE_NAME + '_ARCHIVE';
	set @CSTM_ARCHIVE_TABLE = @TABLE_NAME + '_CSTM_ARCHIVE';
	-- 02/26/2021 Paul.  Correct CSTM AUDIT table name. 
	set @CSTM_ARCHIVE_TABLE = replace(@CSTM_ARCHIVE_TABLE, '_AUDIT_CSTM', '_CSTM_AUDIT');

	if len(@ARCHIVE_DATABASE) > 0 begin -- then
		set @ARCHIVE_DATABASE_DOT = '[' + @ARCHIVE_DATABASE + '].';
	end else begin
		set @ARCHIVE_DATABASE_DOT = '';
	end -- if;

	-- 06/30/2011 Paul.  Custom tables were being excluded from the audit. 
	-- 02/08/2020 Paul.  Include Audit tables. 
	if right(@TABLE_NAME, 5) = '_CSTM' or right(@TABLE_NAME, 11) = '_CSTM_AUDIT' begin -- then
		return;
	end else begin
		-- 06/13/2010 Paul.  We need to prevent from adding auditing to non-SplendidCRM tables, so check for the base fields. 
		exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'ID', @ARCHIVE_DATABASE;
		if @EXISTS = 1 begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'DELETED', @ARCHIVE_DATABASE;
		if @EXISTS = 1 begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'CREATED_BY', @ARCHIVE_DATABASE;
		if @EXISTS = 1 begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'DATE_ENTERED', @ARCHIVE_DATABASE;
		if @EXISTS = 1 begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'MODIFIED_USER_ID', @ARCHIVE_DATABASE;
		if @EXISTS = 1 begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'DATE_MODIFIED', @ARCHIVE_DATABASE;
		if @EXISTS = 1 begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
	end -- if;

	if @SPLENDID_FIELDS = 6 begin -- then
		exec dbo.spSqlTableExists @EXISTS out, @ARCHIVE_TABLE, @ARCHIVE_DATABASE;
		if @EXISTS = 1 begin -- then
			set @CRLF = char(13) + char(10);
			set @COMMAND = 'declare VIEW_COLUMNS_CURSOR cursor for
			select vwSqlColumns.ColumnName
			  from       vwSqlColumns
			  inner join ' + @ARCHIVE_DATABASE_DOT + 'INFORMATION_SCHEMA.COLUMNS   vwSqlColumnsArchive
			          on vwSqlColumnsArchive.TABLE_NAME  = vwSqlColumns.ObjectName + ''_ARCHIVE''
			         and vwSqlColumnsArchive.COLUMN_NAME = vwSqlColumns.ColumnName
			 where vwSqlColumns.ObjectName = ''' + @TABLE_NAME + '''
			 order by vwSqlColumns.colid';
			exec sp_executesql @COMMAND;
	
			-- 02/26/2021 Paul.  Correct CSTM AUDIT table name. 
			set @COMMAND = 'declare VIEW_CSTM_COLUMNS_CURSOR cursor for
			select vwSqlColumns.ColumnName
			  from       vwSqlColumns
			  inner join ' + @ARCHIVE_DATABASE_DOT + 'INFORMATION_SCHEMA.COLUMNS   vwSqlColumnsArchive
			          on vwSqlColumnsArchive.TABLE_NAME  = vwSqlColumns.ObjectName + ''_ARCHIVE''
			         and vwSqlColumnsArchive.COLUMN_NAME = vwSqlColumns.ColumnName
			 where vwSqlColumns.ObjectName = replace(''' + @TABLE_NAME + ''' + ''_CSTM'', ''_AUDIT_CSTM'', ''_CSTM_AUDIT'')
			   and vwSqlColumns.ColumnName not in (''AUDIT_ID'', ''AUDIT_ACTION'', ''AUDIT_DATE'', ''AUDIT_COLUMNS'', ''AUDIT_TOKEN'')
			 order by vwSqlColumns.colid';
			exec sp_executesql @COMMAND;
	
			set @VIEW_NAME = 'vw' + @TABLE_NAME + '_ARCHIVE';
			if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = @VIEW_NAME) begin -- then
				set @COMMAND = 'Drop   View dbo.' + @VIEW_NAME;
				print @COMMAND;
				exec(@COMMAND);
			end -- if;
	
			set @JOIN_ASSIGNED      = 0;
			set @JOIN_TEAMS         = 0;
			set @JOIN_TEAM_SETS     = 0;
			set @JOIN_TAG_SETS      = 0;
			set @JOIN_LAST_ACTIVITY = 0;
			set @JOIN_ASSIGNED_SETS = 0;
			if not exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = @VIEW_NAME) begin -- then
				-- 10/16/2018 Paul.  Join to both main and archive table. 
				set @ACCOUNTS_ARCHIVE_EXISTS      = 0;
				--set @ACCOUNTS_TABLE   = @ARCHIVE_DATABASE_DOT + 'dbo.ACCOUNTS_ARCHIVE';
				exec dbo.spSqlTableExists @ACCOUNTS_ARCHIVE_EXISTS out, 'ACCOUNTS_ARCHIVE', @ARCHIVE_DATABASE;
				--if @ACCOUNTS_ARCHIVE_EXISTS = 0 begin -- then
				--	set @ACCOUNTS_TABLE   = 'ACCOUNTS';
				--end -- if;
				
				set @CONTACTS_ARCHIVE_EXISTS      = 0;
				--set @CONTACTS_ARCHIVE = @ARCHIVE_DATABASE_DOT + 'dbo.CONTACTS_ARCHIVE';
				exec dbo.spSqlTableExists @CONTACTS_ARCHIVE_EXISTS out, 'CONTACTS_ARCHIVE', @ARCHIVE_DATABASE;
				--if @CONTACTS_ARCHIVE_EXISTS = 0 begin -- then
				--	set @CONTACTS_ARCHIVE   = 'CONTACTS';
				--end -- if;
				
				set @QUOTES_ARCHIVE_EXISTS        = 0;
				--set @QUOTES_ARCHIVE   = @ARCHIVE_DATABASE_DOT + 'dbo.QUOTES_ARCHIVE';
				exec dbo.spSqlTableExists @QUOTES_ARCHIVE_EXISTS out, 'QUOTES_ARCHIVE', @ARCHIVE_DATABASE;
				--if @QUOTES_ARCHIVE_EXISTS = 0 begin -- then
				--	set @QUOTES_ARCHIVE   = 'QUOTES';
				--end -- if;
				
				set @ORDERS_ARCHIVE_EXISTS        = 0;
				--set @ORDERS_ARCHIVE   = @ARCHIVE_DATABASE_DOT + 'dbo.ORDERS_ARCHIVE';
				exec dbo.spSqlTableExists @ORDERS_ARCHIVE_EXISTS out, 'ORDERS_ARCHIVE', @ARCHIVE_DATABASE;
				--if @ORDERS_ARCHIVE_EXISTS = 0 begin -- then
				--	set @ORDERS_ARCHIVE   = 'ORDERS';
				--end -- if;

				-- 10/16/2018 Paul.  Join to both main and archive table. 
				set @LEADS_ARCHIVE_EXISTS = 0;
				exec dbo.spSqlTableExists @LEADS_ARCHIVE_EXISTS out, 'LEADS_ARCHIVE', @ARCHIVE_DATABASE;
				set @OPPORTUNITIES_ARCHIVE_EXISTS = 0;
				exec dbo.spSqlTableExists @OPPORTUNITIES_ARCHIVE_EXISTS out, 'OPPORTUNITIES_ARCHIVE', @ARCHIVE_DATABASE;

				set @COMMAND = '';
				set @COMMAND = @COMMAND + 'Create View dbo.' + @VIEW_NAME + @CRLF;
				set @COMMAND = @COMMAND + 'as' + @CRLF;
				set @COMMAND = @COMMAND + 'select ' + @ARCHIVE_TABLE + '.ARCHIVE_DATE_UTC' + @CRLF;
				set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE + '.ARCHIVE_USER_ID' + @CRLF;
				set @COMMAND = @COMMAND + '     , ARCHIVE_MODIFIED_BY.USER_NAME                                                 as ARCHIVE_BY' + @CRLF;
				set @COMMAND = @COMMAND + '     , dbo.fnFullName(ARCHIVE_MODIFIED_BY.FIRST_NAME, ARCHIVE_MODIFIED_BY.LAST_NAME) as ARCHIVE_BY_NAME' + @CRLF;
				set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
				if @TABLE_NAME = 'CONTACTS' or @TABLE_NAME = 'LEADS' or @TABLE_NAME = 'PROSPECTS' or @TABLE_NAME = 'USERS' begin -- then
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(' + @ARCHIVE_TABLE + '.FIRST_NAME, ' + @ARCHIVE_TABLE + '.LAST_NAME) as NAME' + @CRLF;
				end else if @TABLE_NAME = 'DOCUMENTS' begin -- then
					set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE + '.DOCUMENT_NAME as NAME  ' + @CRLF;
				end else if @TABLE_NAME = 'PAYMENTS' begin -- then
					set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE + '.PAYMENT_NUM   as NAME  ' + @CRLF;
				end -- if;
				
				open VIEW_COLUMNS_CURSOR;
				fetch next from VIEW_COLUMNS_CURSOR into @COLUMN_NAME;
				while @@FETCH_STATUS = 0 begin -- while
					if @COLUMN_NAME = 'CREATED_BY' begin -- then
						set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE + '.CREATED_BY       as CREATED_BY_ID' + @CRLF;
						set @COMMAND = @COMMAND + '     , USERS_CREATED_BY.USER_NAME                                                as CREATED_BY' + @CRLF;
						set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME' + @CRLF;
					end else if @TABLE_NAME = 'BUGS' and @COLUMN_NAME = 'FOUND_IN_RELEASE' begin -- then
						set @COMMAND = @COMMAND + '     , FOUND_RELEASES.NAME         as FOUND_IN_RELEASE' + @CRLF;
						set @COMMAND = @COMMAND + '     , FOUND_RELEASES.ID           as FOUND_IN_RELEASE_ID' + @CRLF;
					end else if @TABLE_NAME = 'BUGS' and @COLUMN_NAME = 'FIXED_IN_RELEASE' begin -- then
						set @COMMAND = @COMMAND + '     , FIXED_RELEASES.NAME         as FIXED_IN_RELEASE' + @CRLF;
						set @COMMAND = @COMMAND + '     , FIXED_RELEASES.ID           as FIXED_IN_RELEASE_ID' + @CRLF;
					end else if @TABLE_NAME = 'CASES' and @COLUMN_NAME = 'ACCOUNT_NAME' begin -- then
						set @COMMAND = @COMMAND + '     , isnull(ACCOUNTS.NAME, ACCOUNT_NAME)     as ACCOUNT_NAME' + @CRLF;
					end else if (@TABLE_NAME = 'CALLS' or @TABLE_NAME = 'MEETINGS' ) and @COLUMN_NAME = 'DATE_START' begin -- then
						set @COMMAND = @COMMAND + '     , dbo.fnViewDateTime(' + @ARCHIVE_TABLE + '.DATE_START, ' + @ARCHIVE_TABLE + '.TIME_START) as DATE_START' + @CRLF;
						set @COMMAND = @COMMAND + '     , dbo.fnViewDateTime(' + @ARCHIVE_TABLE + '.DATE_START, ' + @ARCHIVE_TABLE + '.TIME_START) as DATE_TIME' + @CRLF;
					end else if @TABLE_NAME = 'NOTES' and @COLUMN_NAME = 'FILENAME' begin -- then
						set @COMMAND = @COMMAND + '     , isnull(NOTE_ATTACHMENTS.FILENAME      , ' + @ARCHIVE_TABLE + '.FILENAME         ) as FILENAME' + @CRLF;
					end else if @TABLE_NAME = 'NOTES' and @COLUMN_NAME = 'FILE_MIME_TYPE' begin -- then
						set @COMMAND = @COMMAND + '     , isnull(NOTE_ATTACHMENTS.FILE_MIME_TYPE, ' + @ARCHIVE_TABLE + '.FILE_MIME_TYPE   ) as FILE_MIME_TYPE' + @CRLF;
					end else if @COLUMN_NAME <> 'ID' begin -- then
						set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE + '.' + @COLUMN_NAME + @CRLF;
						if @COLUMN_NAME = 'MODIFIED_USER_ID' begin -- then
							set @COMMAND = @COMMAND + '     , USERS_MODIFIED_BY.USER_NAME                                               as MODIFIED_BY' + @CRLF;
							set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME' + @CRLF;
						end else if @COLUMN_NAME = 'ASSIGNED_USER_ID' begin -- then
							set @COMMAND = @COMMAND + '     , USERS_ASSIGNED.USER_NAME                                                  as ASSIGNED_TO' + @CRLF;
							set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME' + @CRLF;
							set @JOIN_ASSIGNED = 1;
						end else if @COLUMN_NAME = 'TEAM_ID' begin -- then
							set @COMMAND = @COMMAND + '     , TEAMS.NAME                      as TEAM_NAME' + @CRLF;
							set @JOIN_TEAMS = 1;
						end else if @COLUMN_NAME = 'TEAM_SET_ID' begin -- then
							set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_NAME' + @CRLF;
							set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_LIST' + @CRLF;
							set @JOIN_TEAM_SETS = 1;
						end -- if;
					end -- if;
					fetch next from VIEW_COLUMNS_CURSOR into @COLUMN_NAME;
				end -- while;
				close VIEW_COLUMNS_CURSOR
				if @TABLE_NAME = 'ACCOUNTS' begin -- then
					set @COMMAND = @COMMAND + '     , dbo.fnLocation(' + @ARCHIVE_TABLE + '.BILLING_ADDRESS_CITY, ' + @ARCHIVE_TABLE + '.BILLING_ADDRESS_STATE) as CITY' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_PARENT.NAME             as PARENT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_PARENT.ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , NAICS_CODE_SETS.NAICS_SET_NAME' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'CONTACTS' begin -- then
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(REPORTS_TO_CONTACTS.FIRST_NAME, REPORTS_TO_CONTACTS.LAST_NAME) as REPORTS_TO_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS.ID                                       as ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS.NAME                                     as ACCOUNT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS.ASSIGNED_USER_ID                         as ACCOUNT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , LEADS.ID                                          as LEAD_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as LEAD_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , LEADS.ASSIGNED_USER_ID                            as LEAD_ASSIGNED_USER_ID' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'LEADS' begin -- then
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONVERTED_CONTACT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS.ASSIGNED_USER_ID      as CONTACT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS.NAME                  as CONVERTED_ACCOUNT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS.ASSIGNED_USER_ID      as ACCOUNT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , OPPORTUNITY_ID                 as CONVERTED_OPPORTUNITY_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , OPPORTUNITY_NAME               as CONVERTED_OPPORTUNITY_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , OPPORTUNITY_AMOUNT             as CONVERTED_OPPORTUNITY_AMOUNT' + @CRLF;
					set @COMMAND = @COMMAND + '     , OPPORTUNITIES.ASSIGNED_USER_ID as CONVERTED_OPPORTUNITY_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , CAMPAIGNS.NAME                 as CAMPAIGN_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CAMPAIGNS.ASSIGNED_USER_ID     as CAMPAIGN_ASSIGNED_USER_ID' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'PROSPECTS' begin -- then
					set @COMMAND = @COMMAND + '     , LEADS.ASSIGNED_USER_ID  as LEAD_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as CONVERTED_LEAD_NAME' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'OPPORTUNITIES' begin -- then
					set @COMMAND = @COMMAND + '     , CAMPAIGNS.NAME              as CAMPAIGN_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CAMPAIGNS.ASSIGNED_USER_ID  as CAMPAIGN_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS.ID                 as ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS.NAME               as ACCOUNT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS.ASSIGNED_USER_ID   as ACCOUNT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS.EMAIL1             as ACCOUNT_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , LEADS.ID                    as LEAD_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as LEAD_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , LEADS.ASSIGNED_USER_ID      as LEAD_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , LEADS.EMAIL1                as LEAD_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as B2C_CONTACT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS.ASSIGNED_USER_ID   as B2C_CONTACT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS.EMAIL1             as B2C_CONTACT_EMAIL1' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'CASES' begin -- then
					set @COMMAND = @COMMAND + '     , ACCOUNTS.ASSIGNED_USER_ID   as ACCOUNT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as B2C_CONTACT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS.ASSIGNED_USER_ID   as B2C_CONTACT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS.EMAIL1             as B2C_CONTACT_EMAIL1' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'DOCUMENTS' begin -- then
					set @COMMAND = @COMMAND + '     , DOCUMENT_REVISIONS.FILENAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , DOCUMENT_REVISIONS.FILE_MIME_TYPE' + @CRLF;
					set @COMMAND = @COMMAND + '     , DOCUMENT_REVISIONS.REVISION' + @CRLF;
					set @COMMAND = @COMMAND + '     , DOCUMENT_REVISIONS.DATE_ENTERED  as REVISION_DATE_ENTERED' + @CRLF;
					set @COMMAND = @COMMAND + '     , DOCUMENT_REVISIONS.DATE_MODIFIED as REVISION_DATE_MODIFIED' + @CRLF;
					set @COMMAND = @COMMAND + '     , REVISION_CREATED_BY.USER_NAME    as REVISION_CREATED_BY' + @CRLF;
					set @COMMAND = @COMMAND + '     , REVISION_MODIFIED_BY.USER_NAME   as REVISION_MODIFIED_BY' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(REVISION_CREATED_BY.FIRST_NAME , REVISION_CREATED_BY.LAST_NAME ) as REVISION_CREATED_BY_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(REVISION_MODIFIED_BY.FIRST_NAME, REVISION_MODIFIED_BY.LAST_NAME) as REVISION_MODIFIED_BY_NAME' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'EMAILS' begin -- then
					set @COMMAND = @COMMAND + '     , dbo.fnViewDateTime(' + @ARCHIVE_TABLE + '.DATE_START, ' + @ARCHIVE_TABLE + '.TIME_START) as DATE_TIME' + @CRLF;
					set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_ASSIGNED_USER_ID' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'CALLS' or @TABLE_NAME = 'MEETINGS' begin -- then
					set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , vwPARENTS.PHONE_WORK' + @CRLF;
					set @COMMAND = @COMMAND + '     , REPEAT_PARENT.NAME          as REPEAT_PARENT_NAME' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'TASKS' begin -- then
					set @COMMAND = @COMMAND + '     , dbo.fnViewDateTime(' + @ARCHIVE_TABLE + '.DATE_DUE  , ' + @ARCHIVE_TABLE + '.TIME_DUE  ) as DATE_TIME_DUE' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnViewDateTime(' + @ARCHIVE_TABLE + '.DATE_START, ' + @ARCHIVE_TABLE + '.TIME_START) as DATE_TIME_START' + @CRLF;
					set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS.ASSIGNED_USER_ID   as CONTACT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS.PHONE_WORK         as CONTACT_PHONE' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS.EMAIL1             as CONTACT_EMAIL' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'NOTES' begin -- then
					set @COMMAND = @COMMAND + '     , (case when NOTE_ATTACHMENTS.ATTACHMENT_LENGTH > 0 then 1 else 0 end) as ATTACHMENT_READY' + @CRLF;
					set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS.PHONE_WORK         as CONTACT_PHONE' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS.EMAIL1             as CONTACT_EMAIL' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS.ASSIGNED_USER_ID   as CONTACT_ASSIGNED_USER_ID' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'QUOTES' begin -- then
					set @COMMAND = @COMMAND + '     , QUOTES_ACCOUNTS_BILLING.ACCOUNT_ID  as BILLING_ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_BILLING.NAME               as BILLING_ACCOUNT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_BILLING.ASSIGNED_USER_ID   as BILLING_ACCOUNT_ASSIGNED_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_BILLING.EMAIL1             as BILLING_ACCOUNT_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , QUOTES_ACCOUNTS_SHIPPING.ACCOUNT_ID as SHIPPING_ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_SHIPPING.NAME              as SHIPPING_ACCOUNT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_SHIPPING.ASSIGNED_USER_ID  as SHIPPING_ACCOUNT_ASSIGNED_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_SHIPPING.EMAIL1            as SHIPPING_ACCOUNT_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , QUOTES_CONTACTS_BILLING.CONTACT_ID  as BILLING_CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(CONTACTS_BILLING.FIRST_NAME, CONTACTS_BILLING.LAST_NAME) as BILLING_CONTACT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS_BILLING.ASSIGNED_USER_ID   as BILLING_CONTACT_ASSIGNED_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS_BILLING.EMAIL1             as BILLING_CONTACT_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , QUOTES_CONTACTS_SHIPPING.CONTACT_ID as SHIPPING_CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(CONTACTS_SHIPPING.FIRST_NAME, CONTACTS_SHIPPING.LAST_NAME) as SHIPPING_CONTACT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS_SHIPPING.ASSIGNED_USER_ID  as SHIPPING_CONTACT_ASSIGNED_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS_SHIPPING.EMAIL1            as SHIPPING_CONTACT_EMAIL1' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'ORDERS' begin -- then
					set @COMMAND = @COMMAND + '     , ORDERS_ACCOUNTS_BILLING.ACCOUNT_ID  as BILLING_ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_BILLING.NAME               as BILLING_ACCOUNT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_BILLING.ASSIGNED_USER_ID   as BILLING_ACCOUNT_ASSIGNED_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_BILLING.EMAIL1             as BILLING_ACCOUNT_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , ORDERS_ACCOUNTS_SHIPPING.ACCOUNT_ID as SHIPPING_ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_SHIPPING.NAME              as SHIPPING_ACCOUNT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_SHIPPING.ASSIGNED_USER_ID  as SHIPPING_ACCOUNT_ASSIGNED_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_SHIPPING.EMAIL1            as SHIPPING_ACCOUNT_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , ORDERS_CONTACTS_BILLING.CONTACT_ID  as BILLING_CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(CONTACTS_BILLING.FIRST_NAME, CONTACTS_BILLING.LAST_NAME) as BILLING_CONTACT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS_BILLING.ASSIGNED_USER_ID   as BILLING_CONTACT_ASSIGNED_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS_BILLING.EMAIL1             as BILLING_CONTACT_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , ORDERS_CONTACTS_SHIPPING.CONTACT_ID as SHIPPING_CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(CONTACTS_SHIPPING.FIRST_NAME, CONTACTS_SHIPPING.LAST_NAME) as SHIPPING_CONTACT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS_SHIPPING.ASSIGNED_USER_ID  as SHIPPING_CONTACT_ASSIGNED_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS_SHIPPING.EMAIL1            as SHIPPING_CONTACT_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , QUOTES.NAME                         as QUOTE_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , QUOTES.QUOTE_NUM                    as QUOTE_NUM' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'INVOICES' begin -- then
					set @COMMAND = @COMMAND + '     , INVOICES_ACCOUNTS_BILLING.ACCOUNT_ID  as BILLING_ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_BILLING.NAME                 as BILLING_ACCOUNT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_BILLING.ASSIGNED_USER_ID     as BILLING_ACCOUNT_ASSIGNED_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_BILLING.EMAIL1               as BILLING_ACCOUNT_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , INVOICES_ACCOUNTS_SHIPPING.ACCOUNT_ID as SHIPPING_ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_SHIPPING.NAME                as SHIPPING_ACCOUNT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_SHIPPING.ASSIGNED_USER_ID    as SHIPPING_ACCOUNT_ASSIGNED_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS_SHIPPING.EMAIL1              as SHIPPING_ACCOUNT_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , INVOICES_CONTACTS_BILLING.CONTACT_ID  as BILLING_CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(CONTACTS_BILLING.FIRST_NAME, CONTACTS_BILLING.LAST_NAME) as BILLING_CONTACT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS_BILLING.ASSIGNED_USER_ID     as BILLING_CONTACT_ASSIGNED_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS_BILLING.EMAIL1               as BILLING_CONTACT_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , INVOICES_CONTACTS_SHIPPING.CONTACT_ID as SHIPPING_CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(CONTACTS_SHIPPING.FIRST_NAME, CONTACTS_SHIPPING.LAST_NAME) as SHIPPING_CONTACT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS_SHIPPING.ASSIGNED_USER_ID    as SHIPPING_CONTACT_ASSIGNED_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS_SHIPPING.EMAIL1              as SHIPPING_CONTACT_EMAIL1' + @CRLF;
					set @COMMAND = @COMMAND + '     , QUOTES.NAME                           as QUOTE_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , QUOTES.QUOTE_NUM                      as QUOTE_NUM' + @CRLF;
					set @COMMAND = @COMMAND + '     , ORDERS.NAME                           as ORDER_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ORDERS.ORDER_NUM                      as ORDER_NUM' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'CONTRACTS' begin -- then
					set @COMMAND = @COMMAND + '     , ACCOUNTS.NAME                  as ACCOUNT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ACCOUNTS.ASSIGNED_USER_ID      as ACCOUNT_ASSIGNED_USER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as B2C_CONTACT_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , CONTACTS.ASSIGNED_USER_ID      as B2C_CONTACT_ASSIGNED_USER_ID' + @CRLF;
				end -- if;
				if exists(select * from vwSqlColumns where ObjectName = @TABLE_NAME and ColumnName = 'ASSIGNED_SET_ID') begin -- then
					set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME' + @CRLF;
					set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST' + @CRLF;
					set @JOIN_ASSIGNED_SETS = 1;
				end -- if;
				-- 09/26/2017 Paul.  All views can have a tag set. 
				set @COMMAND = @COMMAND + '     , TAG_SETS.TAG_SET_NAME' + @CRLF;
				set @JOIN_TAG_SETS  = 1;
				if exists(select * from vwSqlColumns where ObjectName = 'vw' + @TABLE_NAME and ColumnName = 'LAST_ACTIVITY_DATE') begin -- then
					set @COMMAND = @COMMAND + '     , LAST_ACTIVITY.LAST_ACTIVITY_DATE' + @CRLF;
					set @JOIN_LAST_ACTIVITY = 1;
				end -- if;
				if exists(select * from vwSqlColumns where ObjectName = 'vw' + @TABLE_NAME and ColumnName = 'PENDING_PROCESS_ID') begin -- then
					set @COMMAND = @COMMAND + '     , cast(null as uniqueidentifier) as PENDING_PROCESS_ID' + @CRLF;
				end -- if;

				exec dbo.spSqlTableExists @EXISTS out, @CSTM_ARCHIVE_TABLE, @ARCHIVE_DATABASE;
				if @EXISTS = 1 begin -- then
					open VIEW_CSTM_COLUMNS_CURSOR;
					fetch next from VIEW_CSTM_COLUMNS_CURSOR into @COLUMN_NAME;
					while @@FETCH_STATUS = 0 begin -- while
						set @COMMAND = @COMMAND + '     , ' + @CSTM_ARCHIVE_TABLE + '.' + @COLUMN_NAME + @CRLF;
						fetch next from VIEW_CSTM_COLUMNS_CURSOR into @COLUMN_NAME;
					end -- while;
					close VIEW_CSTM_COLUMNS_CURSOR
				end -- if;
				set @COMMAND = @COMMAND + '  from            ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + ' ' + @ARCHIVE_TABLE + @CRLF;
				if @TABLE_NAME = 'ACCOUNTS' begin -- then
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ACCOUNTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ACCOUNTS union all select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ACCOUNTS_ARCHIVE)  ACCOUNTS_PARENT' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ACCOUNTS                       ACCOUNTS_PARENT' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on ACCOUNTS_PARENT.ID           = ' + @ARCHIVE_TABLE + '.PARENT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS_PARENT.DELETED      = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join NAICS_CODE_SETS' + @CRLF;
					set @COMMAND = @COMMAND + '               on NAICS_CODE_SETS.PARENT_ID    = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and NAICS_CODE_SETS.DELETED      = 0' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'CONTACTS' begin -- then
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  REPORTS_TO_CONTACTS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS                       REPORTS_TO_CONTACTS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on REPORTS_TO_CONTACTS.ID       = ' + @ARCHIVE_TABLE + '.REPORTS_TO_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and REPORTS_TO_CONTACTS.DELETED  = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join ACCOUNTS_CONTACTS' + @CRLF;
					set @COMMAND = @COMMAND + '               on ACCOUNTS_CONTACTS.CONTACT_ID = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS_CONTACTS.DELETED    = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ACCOUNTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ACCOUNTS union all select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ACCOUNTS_ARCHIVE)  ACCOUNTS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ACCOUNTS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on ACCOUNTS.ID                  = ACCOUNTS_CONTACTS.ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join LEADS_CONTACTS' + @CRLF;
					set @COMMAND = @COMMAND + '               on LEADS_CONTACTS.CONTACT_ID    = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and LEADS_CONTACTS.DELETED       = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @LEADS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1 from LEADS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'LEADS_ARCHIVE)  LEADS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join LEADS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on LEADS.ID                     = LEADS_CONTACTS.LEAD_ID' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'LEADS' begin -- then
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  CONTACTS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on CONTACTS.ID                  = ' + @ARCHIVE_TABLE + '.CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CONTACTS.DELETED             = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ACCOUNTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ACCOUNTS union all select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ACCOUNTS_ARCHIVE)  ACCOUNTS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ACCOUNTS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on ACCOUNTS.ID                  = ' + @ARCHIVE_TABLE + '.ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS.DELETED             = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join CAMPAIGNS' + @CRLF;
					set @COMMAND = @COMMAND + '               on CAMPAIGNS.ID                 = ' + @ARCHIVE_TABLE + '.CAMPAIGN_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CAMPAIGNS.DELETED            = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @OPPORTUNITIES_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID from OPPORTUNITIES union all select ID, DELETED, NAME, ASSIGNED_USER_ID from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'OPPORTUNITIES_ARCHIVE)  OPPORTUNITIES' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join OPPORTUNITIES' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on OPPORTUNITIES.ID             = ' + @ARCHIVE_TABLE + '.OPPORTUNITY_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and OPPORTUNITIES.DELETED        = 0' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'PROSPECTS' begin -- then
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @LEADS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1 from LEADS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'LEADS_ARCHIVE)  LEADS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join LEADS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on LEADS.ID                     = ' + @ARCHIVE_TABLE + '.LEAD_ID' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'OPPORTUNITIES' begin -- then
					set @COMMAND = @COMMAND + '  left outer join ACCOUNTS_OPPORTUNITIES' + @CRLF;
					set @COMMAND = @COMMAND + '               on ACCOUNTS_OPPORTUNITIES.OPPORTUNITY_ID = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS_OPPORTUNITIES.DELETED        = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ACCOUNTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ACCOUNTS union all select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ACCOUNTS_ARCHIVE)  ACCOUNTS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ACCOUNTS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on ACCOUNTS.ID                           = ACCOUNTS_OPPORTUNITIES.ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS.DELETED                      = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join LEADS_OPPORTUNITIES' + @CRLF;
					set @COMMAND = @COMMAND + '               on LEADS_OPPORTUNITIES.OPPORTUNITY_ID    = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and LEADS_OPPORTUNITIES.DELETED           = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @LEADS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1 from LEADS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'LEADS_ARCHIVE)  LEADS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join LEADS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on LEADS.ID                              = LEADS_OPPORTUNITIES.LEAD_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and LEADS.DELETED                         = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  CONTACTS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on CONTACTS.ID                           = ' + @ARCHIVE_TABLE + '.B2C_CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CONTACTS.DELETED                      = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join CAMPAIGNS' + @CRLF;
					set @COMMAND = @COMMAND + '               on CAMPAIGNS.ID                          = ' + @ARCHIVE_TABLE + '.CAMPAIGN_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CAMPAIGNS.DELETED                     = 0' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'BUGS' begin -- then
					set @COMMAND = @COMMAND + '  left outer join RELEASES               FOUND_RELEASES' + @CRLF;
					set @COMMAND = @COMMAND + '               on cast(FOUND_RELEASES.ID as char(36))  = ' + @ARCHIVE_TABLE + '.FOUND_IN_RELEASE' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join RELEASES               FIXED_RELEASES' + @CRLF;
					set @COMMAND = @COMMAND + '               on cast(FIXED_RELEASES.ID as char(36))  = ' + @ARCHIVE_TABLE + '.FIXED_IN_RELEASE' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'CASES' begin -- then
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ACCOUNTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ACCOUNTS union all select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ACCOUNTS_ARCHIVE)  ACCOUNTS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ACCOUNTS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on (ACCOUNTS.ID = ' + @ARCHIVE_TABLE + '.ACCOUNT_ID or ACCOUNTS.ID in (select top 1 ID from ACCOUNTS_CONTACTS where DELETED = 0 and CONTACT_ID = ' + @ARCHIVE_TABLE + '.B2C_CONTACT_ID and ' + @ARCHIVE_TABLE + '.ACCOUNT_ID is null))' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS.DELETED             = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  CONTACTS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on CONTACTS.ID                  = ' + @ARCHIVE_TABLE + '.B2C_CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CONTACTS.DELETED             = 0' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'DOCUMENTS' begin -- then
					set @COMMAND = @COMMAND + '  left outer join DOCUMENT_REVISIONS' + @CRLF;
					set @COMMAND = @COMMAND + '               on DOCUMENT_REVISIONS.ID      = ' + @ARCHIVE_TABLE + '.DOCUMENT_REVISION_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and DOCUMENT_REVISIONS.DELETED = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join USERS                        REVISION_CREATED_BY' + @CRLF;
					set @COMMAND = @COMMAND + '               on REVISION_CREATED_BY.ID     = DOCUMENT_REVISIONS.CREATED_BY' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join USERS                        REVISION_MODIFIED_BY' + @CRLF;
					set @COMMAND = @COMMAND + '               on REVISION_MODIFIED_BY.ID    = DOCUMENT_REVISIONS.MODIFIED_USER_ID' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'EMAILS' begin -- then
					set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
					set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID          = ' + @ARCHIVE_TABLE + '.PARENT_ID' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'CALLS' begin -- then
					set @COMMAND = @COMMAND + '  left outer join CALLS                          REPEAT_PARENT' + @CRLF;
					set @COMMAND = @COMMAND + '               on REPEAT_PARENT.ID             = ' + @ARCHIVE_TABLE + '.REPEAT_PARENT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and REPEAT_PARENT.DELETED        = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
					set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID          = ' + @ARCHIVE_TABLE + '.PARENT_ID' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'MEETINGS' begin -- then
					set @COMMAND = @COMMAND + '  left outer join MEETINGS                       REPEAT_PARENT' + @CRLF;
					set @COMMAND = @COMMAND + '               on REPEAT_PARENT.ID             = ' + @ARCHIVE_TABLE + '.REPEAT_PARENT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and REPEAT_PARENT.DELETED        = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
					set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID          = ' + @ARCHIVE_TABLE + '.PARENT_ID' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'TASKS' begin -- then
					set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
					set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID          = ' + @ARCHIVE_TABLE + '.PARENT_ID' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  CONTACTS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on CONTACTS.ID                  = ' + @ARCHIVE_TABLE + '.CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CONTACTS.DELETED             = 0' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'NOTES' begin -- then
					set @COMMAND = @COMMAND + '  left outer join NOTE_ATTACHMENTS' + @CRLF;
					set @COMMAND = @COMMAND + '               on NOTE_ATTACHMENTS.ID          = ' + @ARCHIVE_TABLE + '.NOTE_ATTACHMENT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and NOTE_ATTACHMENTS.DELETED     = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
					set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID          = ' + @ARCHIVE_TABLE + '.PARENT_ID' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  CONTACTS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on CONTACTS.ID                  = ' + @ARCHIVE_TABLE + '.CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CONTACTS.DELETED             = 0' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'QUOTES' begin -- then
					set @COMMAND = @COMMAND + '  left outer join QUOTES_ACCOUNTS                         QUOTES_ACCOUNTS_BILLING' + @CRLF;
					set @COMMAND = @COMMAND + '               on QUOTES_ACCOUNTS_BILLING.QUOTE_ID      = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and QUOTES_ACCOUNTS_BILLING.ACCOUNT_ROLE  = N''Bill To''' + @CRLF;
					set @COMMAND = @COMMAND + '              and QUOTES_ACCOUNTS_BILLING.DELETED       = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ACCOUNTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ACCOUNTS union all select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ACCOUNTS_ARCHIVE)  ACCOUNTS_BILLING' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ACCOUNTS                                ACCOUNTS_BILLING' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on ACCOUNTS_BILLING.ID                   = QUOTES_ACCOUNTS_BILLING.ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS_BILLING.DELETED              = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join QUOTES_ACCOUNTS                         QUOTES_ACCOUNTS_SHIPPING' + @CRLF;
					set @COMMAND = @COMMAND + '               on QUOTES_ACCOUNTS_SHIPPING.QUOTE_ID     = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and QUOTES_ACCOUNTS_SHIPPING.ACCOUNT_ROLE = N''Ship To''' + @CRLF;
					set @COMMAND = @COMMAND + '              and QUOTES_ACCOUNTS_SHIPPING.DELETED      = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ACCOUNTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ACCOUNTS union all select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ACCOUNTS_ARCHIVE)  ACCOUNTS_SHIPPING' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ACCOUNTS                                ACCOUNTS_SHIPPING' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on ACCOUNTS_SHIPPING.ID                  = QUOTES_ACCOUNTS_SHIPPING.ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS_SHIPPING.DELETED             = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join QUOTES_CONTACTS                         QUOTES_CONTACTS_BILLING' + @CRLF;
					set @COMMAND = @COMMAND + '               on QUOTES_CONTACTS_BILLING.QUOTE_ID      = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and QUOTES_CONTACTS_BILLING.CONTACT_ROLE  = N''Bill To''' + @CRLF;
					set @COMMAND = @COMMAND + '              and QUOTES_CONTACTS_BILLING.DELETED       = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  CONTACTS_BILLING' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS                                CONTACTS_BILLING' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on CONTACTS_BILLING.ID                   = QUOTES_CONTACTS_BILLING.CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CONTACTS_BILLING.DELETED              = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join QUOTES_CONTACTS                         QUOTES_CONTACTS_SHIPPING' + @CRLF;
					set @COMMAND = @COMMAND + '               on QUOTES_CONTACTS_SHIPPING.QUOTE_ID     = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and QUOTES_CONTACTS_SHIPPING.CONTACT_ROLE = N''Ship To''' + @CRLF;
					set @COMMAND = @COMMAND + '              and QUOTES_CONTACTS_SHIPPING.DELETED      = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  CONTACTS_SHIPPING' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS                                CONTACTS_SHIPPING' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on CONTACTS_SHIPPING.ID                  = QUOTES_CONTACTS_SHIPPING.CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CONTACTS_SHIPPING.DELETED             = 0' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'ORDERS' begin -- then
					set @COMMAND = @COMMAND + '  left outer join ORDERS_ACCOUNTS                         ORDERS_ACCOUNTS_BILLING' + @CRLF;
					set @COMMAND = @COMMAND + '               on ORDERS_ACCOUNTS_BILLING.ORDER_ID      = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ORDERS_ACCOUNTS_BILLING.ACCOUNT_ROLE  = N''Bill To''' + @CRLF;
					set @COMMAND = @COMMAND + '              and ORDERS_ACCOUNTS_BILLING.DELETED       = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ACCOUNTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ACCOUNTS union all select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ACCOUNTS_ARCHIVE)  ACCOUNTS_BILLING' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ACCOUNTS                                ACCOUNTS_BILLING' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on ACCOUNTS_BILLING.ID                   = ORDERS_ACCOUNTS_BILLING.ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS_BILLING.DELETED              = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join ORDERS_ACCOUNTS                         ORDERS_ACCOUNTS_SHIPPING' + @CRLF;
					set @COMMAND = @COMMAND + '               on ORDERS_ACCOUNTS_SHIPPING.ORDER_ID     = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ORDERS_ACCOUNTS_SHIPPING.ACCOUNT_ROLE = N''Ship To''' + @CRLF;
					set @COMMAND = @COMMAND + '              and ORDERS_ACCOUNTS_SHIPPING.DELETED      = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ACCOUNTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ACCOUNTS union all select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ACCOUNTS_ARCHIVE)  ACCOUNTS_SHIPPING' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ACCOUNTS                                ACCOUNTS_SHIPPING' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on ACCOUNTS_SHIPPING.ID                  = ORDERS_ACCOUNTS_SHIPPING.ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS_SHIPPING.DELETED             = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join ORDERS_CONTACTS                         ORDERS_CONTACTS_BILLING' + @CRLF;
					set @COMMAND = @COMMAND + '               on ORDERS_CONTACTS_BILLING.ORDER_ID      = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ORDERS_CONTACTS_BILLING.CONTACT_ROLE  = N''Bill To''' + @CRLF;
					set @COMMAND = @COMMAND + '              and ORDERS_CONTACTS_BILLING.DELETED       = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  CONTACTS_BILLING' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS                                CONTACTS_BILLING' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on CONTACTS_BILLING.ID                   = ORDERS_CONTACTS_BILLING.CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CONTACTS_BILLING.DELETED              = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join ORDERS_CONTACTS                         ORDERS_CONTACTS_SHIPPING' + @CRLF;
					set @COMMAND = @COMMAND + '               on ORDERS_CONTACTS_SHIPPING.ORDER_ID     = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ORDERS_CONTACTS_SHIPPING.CONTACT_ROLE = N''Ship To''' + @CRLF;
					set @COMMAND = @COMMAND + '              and ORDERS_CONTACTS_SHIPPING.DELETED      = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  CONTACTS_SHIPPING' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS                                CONTACTS_SHIPPING' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on CONTACTS_SHIPPING.ID                  = ORDERS_CONTACTS_SHIPPING.CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CONTACTS_SHIPPING.DELETED             = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @QUOTES_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, QUOTE_NUM from QUOTES union all select ID, DELETED, NAME, QUOTE_NUM from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'QUOTES_ARCHIVE)  QUOTES' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join QUOTES' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on QUOTES.ID                             = ' + @ARCHIVE_TABLE + '.QUOTE_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and QUOTES.DELETED                        = 0' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'INVOICES' begin -- then
					set @COMMAND = @COMMAND + '  left outer join INVOICES_ACCOUNTS                         INVOICES_ACCOUNTS_BILLING' + @CRLF;
					set @COMMAND = @COMMAND + '               on INVOICES_ACCOUNTS_BILLING.INVOICE_ID    = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and INVOICES_ACCOUNTS_BILLING.ACCOUNT_ROLE  = N''Bill To''' + @CRLF;
					set @COMMAND = @COMMAND + '              and INVOICES_ACCOUNTS_BILLING.DELETED       = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ACCOUNTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ACCOUNTS union all select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ACCOUNTS_ARCHIVE)  ACCOUNTS_BILLING' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ACCOUNTS                                ACCOUNTS_BILLING' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on ACCOUNTS_BILLING.ID                     = INVOICES_ACCOUNTS_BILLING.ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS_BILLING.DELETED                = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join INVOICES_ACCOUNTS                         INVOICES_ACCOUNTS_SHIPPING' + @CRLF;
					set @COMMAND = @COMMAND + '               on INVOICES_ACCOUNTS_SHIPPING.INVOICE_ID   = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and INVOICES_ACCOUNTS_SHIPPING.ACCOUNT_ROLE = N''Ship To''' + @CRLF;
					set @COMMAND = @COMMAND + '              and INVOICES_ACCOUNTS_SHIPPING.DELETED      = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ACCOUNTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ACCOUNTS union all select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ACCOUNTS_ARCHIVE)  ACCOUNTS_SHIPPING' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ACCOUNTS                                ACCOUNTS_SHIPPING' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on ACCOUNTS_SHIPPING.ID                    = INVOICES_ACCOUNTS_SHIPPING.ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS_SHIPPING.DELETED               = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join INVOICES_CONTACTS                         INVOICES_CONTACTS_BILLING' + @CRLF;
					set @COMMAND = @COMMAND + '               on INVOICES_CONTACTS_BILLING.INVOICE_ID    = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and INVOICES_CONTACTS_BILLING.CONTACT_ROLE  = N''Bill To''' + @CRLF;
					set @COMMAND = @COMMAND + '              and INVOICES_CONTACTS_BILLING.DELETED       = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  CONTACTS_BILLING' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS                                CONTACTS_BILLING' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on CONTACTS_BILLING.ID                     = INVOICES_CONTACTS_BILLING.CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CONTACTS_BILLING.DELETED                = 0' + @CRLF;
					set @COMMAND = @COMMAND + '  left outer join INVOICES_CONTACTS                         INVOICES_CONTACTS_SHIPPING' + @CRLF;
					set @COMMAND = @COMMAND + '               on INVOICES_CONTACTS_SHIPPING.INVOICE_ID   = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and INVOICES_CONTACTS_SHIPPING.CONTACT_ROLE = N''Ship To''' + @CRLF;
					set @COMMAND = @COMMAND + '              and INVOICES_CONTACTS_SHIPPING.DELETED      = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  CONTACTS_SHIPPING' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS                                CONTACTS_SHIPPING' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on CONTACTS_SHIPPING.ID                    = INVOICES_CONTACTS_SHIPPING.CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CONTACTS_SHIPPING.DELETED               = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @QUOTES_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, QUOTE_NUM from QUOTES union all select ID, DELETED, NAME, QUOTE_NUM from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'QUOTES_ARCHIVE)  QUOTES' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join QUOTES' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on QUOTES.ID                               = ' + @ARCHIVE_TABLE + '.QUOTE_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and QUOTES.DELETED                          = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ORDERS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ORDER_NUM from ORDERS union all select ID, DELETED, NAME, ORDER_NUM from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ORDERS_ARCHIVE)  ORDERS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ORDERS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on ORDERS.ID                               = ' + @ARCHIVE_TABLE + '.ORDER_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ORDERS.DELETED                          = 0' + @CRLF;
				end -- if;
				if @TABLE_NAME = 'CONTRACTS' begin -- then
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @ACCOUNTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ACCOUNTS union all select ID, DELETED, NAME, ASSIGNED_USER_ID, EMAIL1 from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'ACCOUNTS_ARCHIVE)  ACCOUNTS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join ACCOUNTS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on ACCOUNTS.ID                         = ' + @ARCHIVE_TABLE + '.ACCOUNT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ACCOUNTS.DELETED                    = 0' + @CRLF;
					-- 10/16/2018 Paul.  Join to both main and archive table. 
					if @CONTACTS_ARCHIVE_EXISTS = 1 begin -- then
						set @COMMAND = @COMMAND + '  left outer join (select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from CONTACTS union all select ID, DELETED, FIRST_NAME, LAST_NAME, ASSIGNED_USER_ID, EMAIL1, PHONE_WORK from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + 'CONTACTS_ARCHIVE)  CONTACTS' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '  left outer join CONTACTS' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '               on CONTACTS.ID                         = ' + @ARCHIVE_TABLE + '.B2C_CONTACT_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and CONTACTS.DELETED                    = 0' + @CRLF;
				end -- if;
				if @JOIN_TEAMS = 1 begin -- then
					set @COMMAND = @COMMAND + '  left outer join TEAMS' + @CRLF;
					set @COMMAND = @COMMAND + '               on TEAMS.ID                     = ' + @ARCHIVE_TABLE + '.TEAM_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and TEAMS.DELETED                = 0' + @CRLF;
				end -- if;
				if @JOIN_TEAM_SETS = 1 begin -- then
					set @COMMAND = @COMMAND + '  left outer join TEAM_SETS' + @CRLF;
					set @COMMAND = @COMMAND + '               on TEAM_SETS.ID                 = ' + @ARCHIVE_TABLE + '.TEAM_SET_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and TEAM_SETS.DELETED            = 0' + @CRLF;
				end -- if;
				if @JOIN_LAST_ACTIVITY = 1  begin -- then
					set @COMMAND = @COMMAND + '  left outer join LAST_ACTIVITY' + @CRLF;
					set @COMMAND = @COMMAND + '               on LAST_ACTIVITY.ACTIVITY_ID    = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
				end -- if;
				if @JOIN_TAG_SETS = 1 begin -- then
					set @COMMAND = @COMMAND + '  left outer join TAG_SETS' + @CRLF;
					set @COMMAND = @COMMAND + '               on TAG_SETS.BEAN_ID             = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and TAG_SETS.DELETED             = 0' + @CRLF;
				end -- if;
				if @JOIN_ASSIGNED = 1 begin -- then
					set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_ASSIGNED' + @CRLF;
					set @COMMAND = @COMMAND + '               on USERS_ASSIGNED.ID            = ' + @ARCHIVE_TABLE + '.ASSIGNED_USER_ID' + @CRLF;
				end -- if;
				set @COMMAND = @COMMAND + '  left outer join USERS                          ARCHIVE_MODIFIED_BY' + @CRLF;
				set @COMMAND = @COMMAND + '               on ARCHIVE_MODIFIED_BY.ID       = ' + @ARCHIVE_TABLE + '.MODIFIED_USER_ID' + @CRLF;
				set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_CREATED_BY' + @CRLF;
				set @COMMAND = @COMMAND + '               on USERS_CREATED_BY.ID          = ' + @ARCHIVE_TABLE + '.CREATED_BY' + @CRLF;
				set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_MODIFIED_BY' + @CRLF;
				set @COMMAND = @COMMAND + '               on USERS_MODIFIED_BY.ID         = ' + @ARCHIVE_TABLE + '.MODIFIED_USER_ID' + @CRLF;
				if @JOIN_ASSIGNED_SETS = 1 begin -- then
					set @COMMAND = @COMMAND + '  left outer join ASSIGNED_SETS' + @CRLF;
					set @COMMAND = @COMMAND + '               on ASSIGNED_SETS.ID         = ' + @ARCHIVE_TABLE + '.ASSIGNED_SET_ID' + @CRLF;
					set @COMMAND = @COMMAND + '              and ASSIGNED_SETS.DELETED    = 0' + @CRLF;
				end -- if;
				exec dbo.spSqlTableExists @EXISTS out, @CSTM_ARCHIVE_TABLE, @ARCHIVE_DATABASE;
				if @EXISTS = 1 begin -- then
					set @COMMAND = @COMMAND + '  left outer join ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @CSTM_ARCHIVE_TABLE + ' ' + @CSTM_ARCHIVE_TABLE + @CRLF;
					set @COMMAND = @COMMAND + '               on ' + @CSTM_ARCHIVE_TABLE + '.ID_C        = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					-- 05/04/2021 Paul.  Must include the AUDIT_TOKEN in join for audit tables. 
					if charindex('_AUDIT', @TABLE_NAME) > 0 begin -- then
						set @COMMAND = @COMMAND + '              and ' + @CSTM_ARCHIVE_TABLE + '.AUDIT_TOKEN = ' + @ARCHIVE_TABLE + '.AUDIT_TOKEN' + @CRLF;
					end -- if;
				end -- if;
				if @TEST = 1 begin -- then
					exec dbo.spSqlPrintByLine @COMMAND;
				end else begin
					print substring(@COMMAND, 1, charindex(@CRLF, @COMMAND));
					--print @COMMAND + @CRLF;
					exec(@COMMAND);
				end -- if;
	
				set @COMMAND = 'Grant Select on dbo.' + @VIEW_NAME + ' to public' + @CRLF;
				if @TEST = 1 begin -- then
					print @COMMAND + @CRLF;
				end else begin
					print @COMMAND + @CRLF;
					exec(@COMMAND);
				end -- if;
			end -- if;
	
			deallocate VIEW_COLUMNS_CURSOR;
			deallocate VIEW_CSTM_COLUMNS_CURSOR;
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildArchiveView to public;
GO

-- exec dbo.spSqlBuildArchiveView 'ACCOUNTS', 'SplendidCRM_Archive';
-- exec dbo.spSqlBuildArchiveView 'ACCOUNTS_AUDIT', 'SplendidCRM_Archive';

