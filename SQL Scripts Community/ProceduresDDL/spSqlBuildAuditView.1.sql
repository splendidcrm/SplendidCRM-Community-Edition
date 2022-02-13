if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildAuditView' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildAuditView;
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
-- 11/17/2008 Paul.  Audit views are used to simplify support of custom fields in workflow engine. 
-- 11/19/2008 Paul.  Join to the USERS table and the TEAMS table to match the base view. 
-- 09/20/2009 Paul.  Use a unique name for the cursor to prevent a collision with another procedure. 
-- 06/13/2010 Paul.  We need to prevent from adding auditing to non-SplendidCRM tables, so check for the base fields. 
-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
-- This also fixes a problem for a customer with 100 custom fields. 
-- 09/25/2017 Paul.  Join to team sets and tag sets. 
-- 09/25/2017 Paul.  Simplify code by only having one section adding joins. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spSqlBuildAuditView(@TABLE_NAME varchar(80))
as
  begin
	set nocount on
	
	-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
	declare @Command           varchar(max);
	declare @CRLF              char(2);
	declare @AUDIT_TABLE       varchar(90);
	declare @CSTM_AUDIT_TABLE  varchar(90);
	declare @VIEW_NAME         varchar(90);
	declare @COLUMN_NAME       varchar(80);
	declare @TEST              bit;
	declare @JOIN_ASSIGNED     bit;
	declare @JOIN_ASSIGNED_SET bit;
	declare @JOIN_TEAMS        bit;
	-- 09/25/2017 Paul.  Join to team sets. 
	declare @JOIN_TEAM_SETS    bit;
	declare @JOIN_TAG_SETS     bit;
	declare @SPLENDID_FIELDS   int;

	set @TEST = 0;
	set @SPLENDID_FIELDS = 0;
	set @AUDIT_TABLE      = @TABLE_NAME + '_AUDIT';
	set @CSTM_AUDIT_TABLE = @TABLE_NAME + '_CSTM_AUDIT';

	-- 06/30/2011 Paul.  Custom tables were being excluded from the audit. 
	if right(@TABLE_NAME, 5) = '_CSTM' begin -- then
		-- 06/30/2011 Paul.  A custom table will only have an ID_C field, so if found then allow to continue. 
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME and COLUMN_NAME = 'ID_C') begin -- then
			set @SPLENDID_FIELDS = 6;
		end -- if;
	end else begin
		-- 06/13/2010 Paul.  We need to prevent from adding auditing to non-SplendidCRM tables, so check for the base fields. 
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'ID') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'DELETED') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'CREATED_BY') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'DATE_ENTERED') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'MODIFIED_USER_ID') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'DATE_MODIFIED') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
	end -- if;

	if @SPLENDID_FIELDS = 6 begin -- then
		if exists (select * from vwSqlTables where TABLE_NAME = @AUDIT_TABLE) begin -- then
			set @CRLF = char(13) + char(10);
			declare VIEW_COLUMNS_CURSOR cursor for
			select vwSqlColumns.ColumnName
			  from       vwSqlColumns
			  inner join vwSqlColumns                   vwSqlColumnsAudit
			          on vwSqlColumnsAudit.ObjectName = vwSqlColumns.ObjectName + '_AUDIT'
			         and vwSqlColumnsAudit.ColumnName = vwSqlColumns.ColumnName
			 where vwSqlColumns.ObjectName = @TABLE_NAME
			 order by vwSqlColumns.colid;
	
			declare VIEW_CSTM_COLUMNS_CURSOR cursor for
			select vwSqlColumns.ColumnName
			  from       vwSqlColumns
			  inner join vwSqlColumns                   vwSqlColumnsAudit
			          on vwSqlColumnsAudit.ObjectName = vwSqlColumns.ObjectName + '_AUDIT'
			         and vwSqlColumnsAudit.ColumnName = vwSqlColumns.ColumnName
			 where vwSqlColumns.ObjectName = @TABLE_NAME + '_CSTM'
			   and vwSqlColumns.ColumnName not in ('AUDIT_ID', 'AUDIT_ACTION', 'AUDIT_DATE', 'AUDIT_COLUMNS', 'AUDIT_TOKEN')
			 order by vwSqlColumns.colid;
	
			set @VIEW_NAME = 'vw' + @TABLE_NAME + '_AUDIT';
			if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = @VIEW_NAME) begin -- then
				set @Command = 'Drop   View dbo.' + @VIEW_NAME;
				print @Command;
				exec(@Command);
			end -- if;
	
			set @JOIN_ASSIGNED     = 0;
			set @JOIN_ASSIGNED_SET = 0;
			set @JOIN_TEAMS        = 0;
			set @JOIN_TEAM_SETS    = 0;
			set @JOIN_TAG_SETS     = 0;
			if not exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = @VIEW_NAME) begin -- then
				set @Command = '';
				set @Command = @Command + 'Create View dbo.' + @VIEW_NAME + @CRLF;
				set @Command = @Command + 'as' + @CRLF;
				set @Command = @Command + 'select ' + @AUDIT_TABLE + '.AUDIT_ID     ' + @CRLF;
				set @Command = @Command + '     , ' + @AUDIT_TABLE + '.AUDIT_ACTION ' + @CRLF;
				set @Command = @Command + '     , ' + @AUDIT_TABLE + '.AUDIT_DATE   ' + @CRLF;
				set @Command = @Command + '     , ' + @AUDIT_TABLE + '.AUDIT_VERSION' + @CRLF;
				set @Command = @Command + '     , ' + @AUDIT_TABLE + '.AUDIT_TOKEN  ' + @CRLF;
				-- 08/07/2013 Paul.  The audit table needs a NAME field in order to allow searching in the Undelete area. 
				-- 09/29/2015 Paul.  Table names will be in upper case.  Not important on SQL Server, but important for Oracle. 
				if @TABLE_NAME = 'CONTACTS' or @TABLE_NAME = 'LEADS' or @TABLE_NAME = 'PROSPECTS' or @TABLE_NAME = 'USERS' begin -- then
					set @Command = @Command + '     , dbo.fnFullName(' + @AUDIT_TABLE + '.FIRST_NAME, ' + @AUDIT_TABLE + '.LAST_NAME) as NAME' + @CRLF;
				end else if @TABLE_NAME = 'DOCUMENTS' begin -- then
					set @Command = @Command + '     , ' + @AUDIT_TABLE + '.DOCUMENT_NAME as NAME  ' + @CRLF;
				end -- if;
				
				open VIEW_COLUMNS_CURSOR;
				fetch next from VIEW_COLUMNS_CURSOR into @COLUMN_NAME;
				while @@FETCH_STATUS = 0 begin -- while
					if @COLUMN_NAME = 'CREATED_BY' begin -- then
						set @Command = @Command + '     , ' + @AUDIT_TABLE + '.CREATED_BY       as CREATED_BY_ID' + @CRLF;
						set @Command = @Command + '     , USERS_CREATED_BY.USER_NAME      as CREATED_BY' + @CRLF;
					end else begin
						set @Command = @Command + '     , ' + @AUDIT_TABLE + '.' + @COLUMN_NAME + @CRLF;
						if @COLUMN_NAME = 'MODIFIED_USER_ID' begin -- then
							set @Command = @Command + '     , USERS_MODIFIED_BY.USER_NAME     as MODIFIED_BY' + @CRLF;
						end else if @COLUMN_NAME = 'ASSIGNED_USER_ID' begin -- then
							set @Command = @Command + '     , USERS_ASSIGNED.USER_NAME        as ASSIGNED_TO' + @CRLF;
							set @JOIN_ASSIGNED = 1;
						end else if @COLUMN_NAME = 'TEAM_ID' begin -- then
							set @Command = @Command + '     , TEAMS.NAME                      as TEAM_NAME' + @CRLF;
							set @JOIN_TEAMS = 1;
						-- 09/25/2017 Paul.  Join to team sets. 
						end else if @COLUMN_NAME = 'TEAM_SET_ID' begin -- then
							set @Command = @Command + '     , TEAM_SETS.TEAM_SET_NAME         as TEAM_SET_NAME' + @CRLF;
							set @Command = @Command + '     , TEAM_SETS.TEAM_SET_LIST         as TEAM_SET_LIST' + @CRLF;
							set @JOIN_TEAM_SETS = 1;
						-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
						end else if @COLUMN_NAME = 'ASSIGNED_SET_ID' begin -- then
							set @Command = @Command + '     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME' + @CRLF;
							set @Command = @Command + '     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST' + @CRLF;
							set @JOIN_ASSIGNED_SET = 1;
						end else if @COLUMN_NAME = 'TAG_ID' begin -- then
							set @Command = @Command + '     , TAG_SETS.TAG_SET_NAME' + @CRLF;
							set @JOIN_TAG_SETS  = 1;
						end -- if;
					end -- if;
					fetch next from VIEW_COLUMNS_CURSOR into @COLUMN_NAME;
				end -- while;
				close VIEW_COLUMNS_CURSOR
				if exists(select * from vwSqlColumns where ObjectName = @CSTM_AUDIT_TABLE) begin -- then
					open VIEW_CSTM_COLUMNS_CURSOR;
					fetch next from VIEW_CSTM_COLUMNS_CURSOR into @COLUMN_NAME;
					while @@FETCH_STATUS = 0 begin -- while
						set @Command = @Command + '     , ' + @CSTM_AUDIT_TABLE + '.' + @COLUMN_NAME + @CRLF;
						fetch next from VIEW_CSTM_COLUMNS_CURSOR into @COLUMN_NAME;
					end -- while;
					close VIEW_CSTM_COLUMNS_CURSOR
				end -- if;
				-- 09/25/2017 Paul.  Simplify code by only having one section adding joins. 
				set @Command = @Command + '  from            ' + @AUDIT_TABLE + @CRLF;
				if @JOIN_TEAMS = 1 begin -- then
					set @Command = @Command + '  left outer join TEAMS' + @CRLF;
					set @Command = @Command + '               on TEAMS.ID                 = ' + @AUDIT_TABLE + '.TEAM_ID' + @CRLF;
					set @Command = @Command + '              and TEAMS.DELETED            = 0' + @CRLF;
				end -- if;
				-- 09/25/2017 Paul.  Join to team sets. 
				if @JOIN_TEAM_SETS = 1 begin -- then
					set @Command = @Command + '  left outer join TEAM_SETS' + @CRLF;
					set @Command = @Command + '               on TEAM_SETS.ID             = ' + @AUDIT_TABLE + '.TEAM_SET_ID' + @CRLF;
					set @Command = @Command + '              and TEAM_SETS.DELETED        = 0' + @CRLF;
				end -- if;
				-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				if @JOIN_ASSIGNED_SET = 1 begin -- then
					set @Command = @Command + '  left outer join ASSIGNED_SETS' + @CRLF;
					set @Command = @Command + '               on ASSIGNED_SETS.ID         = ' + @AUDIT_TABLE + '.ASSIGNED_SET_ID' + @CRLF;
					set @Command = @Command + '              and ASSIGNED_SETS.DELETED    = 0' + @CRLF;
				end -- if;
				if @JOIN_TAG_SETS = 1 begin -- then
					set @Command = @Command + '  left outer join TAG_SETS' + @CRLF;
					set @Command = @Command + '               on TAG_SETS.BEAN_ID         = ' + @AUDIT_TABLE + '.ID' + @CRLF;
					set @Command = @Command + '              and TAG_SETS.DELETED         = 0' + @CRLF;
				end -- if;
				if @JOIN_ASSIGNED = 1 begin -- then
					set @Command = @Command + '  left outer join USERS                      USERS_ASSIGNED' + @CRLF;
					set @Command = @Command + '               on USERS_ASSIGNED.ID        = ' + @AUDIT_TABLE + '.ASSIGNED_USER_ID' + @CRLF;
				end -- if;
				set @Command = @Command + '  left outer join USERS                      USERS_CREATED_BY' + @CRLF;
				set @Command = @Command + '               on USERS_CREATED_BY.ID      = ' + @AUDIT_TABLE + '.CREATED_BY' + @CRLF;
				set @Command = @Command + '  left outer join USERS                      USERS_MODIFIED_BY' + @CRLF;
				set @Command = @Command + '               on USERS_MODIFIED_BY.ID     = ' + @AUDIT_TABLE + '.MODIFIED_USER_ID' + @CRLF;
				-- 09/25/2017 Paul.  Simplify code by only having one section adding joins. 
				if exists(select * from vwSqlColumns where ObjectName = @CSTM_AUDIT_TABLE) begin -- then
					set @Command = @Command + '  left outer join ' + @CSTM_AUDIT_TABLE + @CRLF;
					set @Command = @Command + '               on ' + @CSTM_AUDIT_TABLE + '.ID_C         = ' + @AUDIT_TABLE + '.ID         ' + @CRLF;
					set @Command = @Command + '              and ' + @CSTM_AUDIT_TABLE + '.AUDIT_TOKEN  = ' + @AUDIT_TABLE + '.AUDIT_TOKEN' + @CRLF;
					-- 11/18/2008 Paul.  Only use the update action as the insert action in the custom table is almost always just the ID_C.
					set @Command = @Command + '              and ' + @CSTM_AUDIT_TABLE + '.AUDIT_ACTION = 1' + @CRLF;
				end -- if;
				if @TEST = 1 begin -- then
					print @Command + @CRLF;
				end else begin
					print substring(@Command, 1, charindex(@CRLF, @Command));
					exec(@Command);
				end -- if;
	
				set @Command = 'Grant Select on dbo.' + @VIEW_NAME + ' to public' + @CRLF;
				if @TEST = 1 begin -- then
					print @Command + @CRLF;
				end else begin
					print @Command + @CRLF;
					exec(@Command);
				end -- if;
			end -- if;
	
			deallocate VIEW_COLUMNS_CURSOR;
			deallocate VIEW_CSTM_COLUMNS_CURSOR;
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildAuditView to public;
GO

-- exec dbo.spSqlBuildAuditView 'ACCOUNTS';
-- sp_helptext vwACCOUNTS_AUDIT

