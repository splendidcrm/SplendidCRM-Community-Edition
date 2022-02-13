if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildStreamLinkData' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildStreamLinkData;
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
Create Procedure dbo.spSqlBuildStreamLinkData(@TABLE_NAME varchar(80), @LEFT_TABLE_NAME varchar(80), @RIGHT_TABLE_NAME varchar(80))
as
  begin
	set nocount on
--	print N'	spSqlBuildStreamLinkData  ' + @TABLE_NAME + ' ' + space(30 - len(@TABLE_NAME)) + @LEFT_TABLE_NAME + '  ' + @RIGHT_TABLE_NAME;
	
	declare @Command           varchar(max);
	declare @AUDIT_TABLE       varchar(90);
	declare @LEFT_PRIMARY_KEY  varchar(30);
	declare @RIGHT_PRIMARY_KEY varchar(30);
	declare @LEFT_MODULE_NAME  varchar(30);
	declare @RIGHT_MODULE_NAME varchar(30);
	declare @TEST                bit;
	declare @CRLF                char(2);
	declare @AUDIT_FIELDS        int;
	declare @LEFT_STREAM_FIELDS  int;
	declare @RIGHT_STREAM_FIELDS int;

	set @TEST                = 0;
	set @CRLF                = char(13) + char(10);
	set @AUDIT_FIELDS        = 0;
	set @LEFT_STREAM_FIELDS  = 0;
	set @RIGHT_STREAM_FIELDS = 0;
	set @AUDIT_TABLE     = @TABLE_NAME + '_AUDIT';
	-- 10/16/2017 Paul.  New function to get singular name. 
	set @LEFT_PRIMARY_KEY  = dbo.fnSqlSingularName(@LEFT_TABLE_NAME ) + '_ID';
	set @RIGHT_PRIMARY_KEY = dbo.fnSqlSingularName(@RIGHT_TABLE_NAME) + '_ID';
	set @LEFT_MODULE_NAME  = substring(@LEFT_TABLE_NAME , 1, 1) + replace(lower(substring(@LEFT_TABLE_NAME , 2, len(@LEFT_TABLE_NAME ))), '_', '');
	set @RIGHT_MODULE_NAME = substring(@RIGHT_TABLE_NAME, 1, 1) + replace(lower(substring(@RIGHT_TABLE_NAME, 2, len(@RIGHT_TABLE_NAME))), '_', '');
	-- 09/29/2015 Paul.  Correction for non-standard naming. 
	if @RIGHT_TABLE_NAME = 'PROSPECT_LIST' begin -- then
		set @RIGHT_TABLE_NAME  = 'PROSPECT_LISTS';
		set @RIGHT_PRIMARY_KEY = 'PROSPECT_LIST_ID';
		set @RIGHT_MODULE_NAME = 'ProspectLists';
	end -- if;
	if @RIGHT_TABLE_NAME = 'CALL_MARKETING' begin -- then
		set @RIGHT_PRIMARY_KEY = @RIGHT_TABLE_NAME + '_ID';
		set @RIGHT_MODULE_NAME = 'CallMarketing';
	end -- if;
	if @RIGHT_TABLE_NAME = 'PROSPECT_LISTS' begin -- then
		set @RIGHT_MODULE_NAME = 'ProspectLists';
	end -- if;
	if @RIGHT_TABLE_NAME = 'KBDOCUMENTS' begin -- then
		set @RIGHT_MODULE_NAME = 'KBDocuments';
	end -- if;
	if @RIGHT_TABLE_NAME = 'PROJECTS' begin -- then
		set @RIGHT_TABLE_NAME  = 'PROJECT';
		set @RIGHT_MODULE_NAME = 'Project';
	end -- if;
	if @LEFT_TABLE_NAME = 'PROJECTS' begin -- then
		set @LEFT_TABLE_NAME  = 'PROJECT';
		set @LEFT_MODULE_NAME = 'Project';
	end -- if;
	if @LEFT_TABLE_NAME = 'PROSPECT_LISTS' begin -- then
		set @LEFT_MODULE_NAME = 'ProspectLists';
	end -- if;
	if @TABLE_NAME = 'PROSPECT_LISTS_PROSPECTS' begin -- then
		if @RIGHT_TABLE_NAME = 'PROSPECTS' begin -- then
			set @RIGHT_PRIMARY_KEY = 'RELATED_ID';
		end else if @LEFT_TABLE_NAME = 'PROSPECTS' begin -- then
			set @LEFT_PRIMARY_KEY = 'RELATED_ID';
		end -- if;
	end -- if;

	-- 09/23/2015 Paul.  We need to prevent from adding streaming to non-SplendidCRM tables, so check for the base fields. 
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_ID') begin -- then
		set @AUDIT_FIELDS = @AUDIT_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_ACTION') begin -- then
		set @AUDIT_FIELDS = @AUDIT_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_DATE') begin -- then
		set @AUDIT_FIELDS = @AUDIT_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_VERSION') begin -- then
		set @AUDIT_FIELDS = @AUDIT_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_COLUMNS') begin -- then
		set @AUDIT_FIELDS = @AUDIT_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_TOKEN') begin -- then
		set @AUDIT_FIELDS = @AUDIT_FIELDS + 1;
	end -- if;

	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @LEFT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'STREAM_ID') begin -- then
		set @LEFT_STREAM_FIELDS = @LEFT_STREAM_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @LEFT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'STREAM_DATE') begin -- then
		set @LEFT_STREAM_FIELDS = @LEFT_STREAM_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @LEFT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'STREAM_VERSION') begin -- then
		set @LEFT_STREAM_FIELDS = @LEFT_STREAM_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @LEFT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'STREAM_ACTION') begin -- then
		set @LEFT_STREAM_FIELDS = @LEFT_STREAM_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @LEFT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'STREAM_COLUMNS') begin -- then
		set @LEFT_STREAM_FIELDS = @LEFT_STREAM_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @LEFT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'AUDIT_ID') begin -- then
		set @LEFT_STREAM_FIELDS = @LEFT_STREAM_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @LEFT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'ID') begin -- then
		set @LEFT_STREAM_FIELDS = @LEFT_STREAM_FIELDS + 1;
	end -- if;

	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @RIGHT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'STREAM_ID') begin -- then
		set @RIGHT_STREAM_FIELDS = @RIGHT_STREAM_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @RIGHT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'STREAM_DATE') begin -- then
		set @RIGHT_STREAM_FIELDS = @RIGHT_STREAM_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @RIGHT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'STREAM_VERSION') begin -- then
		set @RIGHT_STREAM_FIELDS = @RIGHT_STREAM_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @RIGHT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'STREAM_ACTION') begin -- then
		set @RIGHT_STREAM_FIELDS = @RIGHT_STREAM_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @RIGHT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'STREAM_COLUMNS') begin -- then
		set @RIGHT_STREAM_FIELDS = @RIGHT_STREAM_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @RIGHT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'AUDIT_ID') begin -- then
		set @RIGHT_STREAM_FIELDS = @RIGHT_STREAM_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @RIGHT_TABLE_NAME + '_STREAM' and COLUMN_NAME = 'ID') begin -- then
		set @RIGHT_STREAM_FIELDS = @RIGHT_STREAM_FIELDS + 1;
	end -- if;

	if @AUDIT_FIELDS = 6 and (@LEFT_STREAM_FIELDS = 7 or @RIGHT_STREAM_FIELDS = 7) begin -- then
		-- 10/08/2015 Paul.  Left and Right tables must both exist. 
		if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = @LEFT_TABLE_NAME) and exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = @RIGHT_TABLE_NAME) begin -- then
			set @Command = '';
			-- 09/29/2015 Paul.  Exclude PROSPECT_LISTS_PROSPECTS as there would be too much information that is not very useful. 
			if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = @LEFT_TABLE_NAME) and @LEFT_STREAM_FIELDS = 7 and not (@LEFT_TABLE_NAME = 'PROSPECT_LISTS' and @RIGHT_PRIMARY_KEY = 'RELATED_ID') begin -- then
				set @Command = @Command + 'insert into dbo.' + @LEFT_TABLE_NAME + '_STREAM' + @CRLF;
				set @Command = @Command + '     ( STREAM_ID'             + @CRLF;
				set @Command = @Command + '     , STREAM_DATE'           + @CRLF;
				set @Command = @Command + '     , LINK_AUDIT_ID'         + @CRLF;
				set @Command = @Command + '     , STREAM_ACTION'         + @CRLF;
				set @Command = @Command + '     , STREAM_RELATED_ID'     + @CRLF;
				set @Command = @Command + '     , STREAM_RELATED_MODULE' + @CRLF;
				set @Command = @Command + '     , STREAM_RELATED_NAME'   + @CRLF;
				set @Command = @Command + '     , ID'                    + @CRLF;
				set @Command = @Command + '     , CREATED_BY'            + @CRLF;
				set @Command = @Command + '     , ASSIGNED_USER_ID'      + @CRLF;
				set @Command = @Command + '     , TEAM_ID'               + @CRLF;
				set @Command = @Command + '     , TEAM_SET_ID'           + @CRLF;
				set @Command = @Command + '     , NAME'                  + @CRLF;
				set @Command = @Command + '     )' + @CRLF;
				set @Command = @Command + 'select newid()'                                    + @CRLF;
				set @Command = @Command + '     , ' + @AUDIT_TABLE + '.AUDIT_DATE'            + @CRLF;
				set @Command = @Command + '     , ' + @AUDIT_TABLE + '.AUDIT_ID'              + @CRLF;
				set @Command = @Command + '     , (case ' + @AUDIT_TABLE + '.DELETED when 0 then ''Linked'' when 1 then ''Unlinked'' end)' + @CRLF;
				set @Command = @Command + '     , ' + @AUDIT_TABLE + '.' + @RIGHT_PRIMARY_KEY + @CRLF;
				if @TABLE_NAME = 'PROSPECT_LISTS_PROSPECTS' and @RIGHT_PRIMARY_KEY = 'RELATED_ID' begin -- then
					set @Command = @Command + '     , ' + @AUDIT_TABLE + '.RELATED_TYPE'  + @CRLF;
				end else begin
					set @Command = @Command + '     , ''' + @RIGHT_MODULE_NAME + ''''     + @CRLF;
				end -- if;
				if @RIGHT_TABLE_NAME = 'CONTACTS' or @RIGHT_TABLE_NAME = 'LEADS' or @RIGHT_TABLE_NAME = 'PROSPECTS' or @RIGHT_TABLE_NAME = 'USERS' begin -- then
					set @Command = @Command + '     , dbo.fnFullName(' + @RIGHT_TABLE_NAME + '.FIRST_NAME, ' + @RIGHT_TABLE_NAME + '.LAST_NAME)' + @CRLF;
				end else if @RIGHT_TABLE_NAME = 'DOCUMENTS' begin -- then
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.DOCUMENT_NAME' + @CRLF;
				end else if @RIGHT_TABLE_NAME = 'PAYMENTS' begin -- then
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.PAYMENT_NUM'   + @CRLF;
				end else begin
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.NAME'          + @CRLF;
				end -- if;
				set @Command = @Command + '     , ' + @LEFT_TABLE_NAME + '.ID'                + @CRLF;
				-- 06/03/2016 Paul.  We should be using the MODIFIED_USER_ID as the person who made the change. 
				set @Command = @Command + '     , ' + @LEFT_TABLE_NAME + '.MODIFIED_USER_ID'  + @CRLF;
				set @Command = @Command + '     , ' + @LEFT_TABLE_NAME + '.ASSIGNED_USER_ID'  + @CRLF;
				set @Command = @Command + '     , ' + @LEFT_TABLE_NAME + '.TEAM_ID'           + @CRLF;
				set @Command = @Command + '     , ' + @LEFT_TABLE_NAME + '.TEAM_SET_ID'       + @CRLF;
				if @LEFT_TABLE_NAME = 'CONTACTS' or @LEFT_TABLE_NAME = 'LEADS' or @LEFT_TABLE_NAME = 'PROSPECTS' or @LEFT_TABLE_NAME = 'USERS' begin -- then
					set @Command = @Command + '     , dbo.fnFullName(' + @LEFT_TABLE_NAME + '.FIRST_NAME, ' + @LEFT_TABLE_NAME + '.LAST_NAME) as NAME' + @CRLF;
				end else if @LEFT_TABLE_NAME = 'DOCUMENTS' begin -- then
					set @Command = @Command + '     , ' + @LEFT_TABLE_NAME + '.DOCUMENT_NAME' + @CRLF;
				end else if @LEFT_TABLE_NAME = 'PAYMENTS' begin -- then
					set @Command = @Command + '     , ' + @LEFT_TABLE_NAME + '.PAYMENT_NUM'   + @CRLF;
				end else begin
					set @Command = @Command + '     , ' + @LEFT_TABLE_NAME + '.NAME'          + @CRLF;
				end -- if;
				set @Command = @Command + '  from       ' + @AUDIT_TABLE      + @CRLF;
				set @Command = @Command + '  inner join ' + @LEFT_TABLE_NAME  + @CRLF;
				set @Command = @Command + '          on ' + @LEFT_TABLE_NAME  + '.ID = ' + @AUDIT_TABLE + '.' + @LEFT_PRIMARY_KEY  + @CRLF;
				set @Command = @Command + '  inner join ' + @RIGHT_TABLE_NAME + @CRLF;
				set @Command = @Command + '          on ' + @RIGHT_TABLE_NAME + '.ID = ' + @AUDIT_TABLE + '.' + @RIGHT_PRIMARY_KEY + '' + @CRLF;
				set @Command = @Command + ' where ' + @AUDIT_TABLE + '.AUDIT_ID not in (select LINK_AUDIT_ID from dbo.' + @LEFT_TABLE_NAME + '_STREAM where LINK_AUDIT_ID is not null)' + @CRLF;
				set @Command = @Command + ' order by AUDIT_VERSION;'  + @CRLF;
				if @TEST = 1 begin -- then
					print @Command + @CRLF;
				end else begin
					print substring(@Command, 1, charindex(@CRLF, @Command) - 1) + ' -- ' + @RIGHT_MODULE_NAME;
					exec(@Command);
				end -- if;
			end -- if;
			if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = @RIGHT_TABLE_NAME) and @RIGHT_STREAM_FIELDS = 7 begin -- then
				set @Command = '';
				set @Command = @Command + 'insert into dbo.' + @RIGHT_TABLE_NAME + '_STREAM' + @CRLF;
				set @Command = @Command + '     ( STREAM_ID'             + @CRLF;
				set @Command = @Command + '     , STREAM_DATE'           + @CRLF;
				set @Command = @Command + '     , LINK_AUDIT_ID'         + @CRLF;
				set @Command = @Command + '     , STREAM_ACTION'         + @CRLF;
				set @Command = @Command + '     , STREAM_RELATED_ID'     + @CRLF;
				set @Command = @Command + '     , STREAM_RELATED_MODULE' + @CRLF;
				set @Command = @Command + '     , STREAM_RELATED_NAME'   + @CRLF;
				set @Command = @Command + '     , ID'                    + @CRLF;
				set @Command = @Command + '     , CREATED_BY'            + @CRLF;
				set @Command = @Command + '     , ASSIGNED_USER_ID'      + @CRLF;
				set @Command = @Command + '     , TEAM_ID'               + @CRLF;
				set @Command = @Command + '     , TEAM_SET_ID'           + @CRLF;
				set @Command = @Command + '     , NAME'                  + @CRLF;
				set @Command = @Command + '     )' + @CRLF;
				set @Command = @Command + 'select newid()'                                    + @CRLF;
				set @Command = @Command + '     , ' + @AUDIT_TABLE + '.AUDIT_DATE'            + @CRLF;
				set @Command = @Command + '     , ' + @AUDIT_TABLE + '.AUDIT_ID'              + @CRLF;
				set @Command = @Command + '     , (case ' + @AUDIT_TABLE + '.DELETED when 0 then ''Linked'' when 1 then ''Unlinked'' end)' + @CRLF;
				set @Command = @Command + '     , ' + @AUDIT_TABLE + '.' + @LEFT_PRIMARY_KEY  + @CRLF;
				set @Command = @Command + '     , ''' + @LEFT_MODULE_NAME + ''''              + @CRLF;
				if @LEFT_TABLE_NAME = 'CONTACTS' or @LEFT_TABLE_NAME = 'LEADS' or @LEFT_TABLE_NAME = 'PROSPECTS' or @LEFT_TABLE_NAME = 'USERS' begin -- then
					set @Command = @Command + '     , dbo.fnFullName(' + @LEFT_TABLE_NAME + '.FIRST_NAME, ' + @LEFT_TABLE_NAME + '.LAST_NAME)' + @CRLF;
				end else if @LEFT_TABLE_NAME = 'DOCUMENTS' begin -- then
					set @Command = @Command + '     , ' + @LEFT_TABLE_NAME + '.DOCUMENT_NAME'    + @CRLF;
				end else if @LEFT_TABLE_NAME = 'PAYMENTS' begin -- then
					set @Command = @Command + '     , ' + @LEFT_TABLE_NAME + '.PAYMENT_NUM'      + @CRLF;
				end else begin
					set @Command = @Command + '     , ' + @LEFT_TABLE_NAME + '.NAME'             + @CRLF;
				end -- if;
				set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.ID'               + @CRLF;
				-- 06/03/2016 Paul.  We should be using the MODIFIED_USER_ID as the person who made the change. 
				set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.MODIFIED_USER_ID' + @CRLF;
				set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.ASSIGNED_USER_ID' + @CRLF;
				set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.TEAM_ID'          + @CRLF;
				set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.TEAM_SET_ID'      + @CRLF;
				if @RIGHT_TABLE_NAME = 'CONTACTS' or @RIGHT_TABLE_NAME = 'LEADS' or @RIGHT_TABLE_NAME = 'PROSPECTS' or @RIGHT_TABLE_NAME = 'USERS' begin -- then
					set @Command = @Command + '     , dbo.fnFullName(' + @RIGHT_TABLE_NAME + '.FIRST_NAME, ' + @RIGHT_TABLE_NAME + '.LAST_NAME)' + @CRLF;
				end else if @RIGHT_TABLE_NAME = 'DOCUMENTS' begin -- then
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.DOCUMENT_NAME' + @CRLF;
				end else if @RIGHT_TABLE_NAME = 'PAYMENTS' begin -- then
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.PAYMENT_NUM'   + @CRLF;
				end else begin
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.NAME'          + @CRLF;
				end -- if;
				set @Command = @Command + '  from       ' + @AUDIT_TABLE      + @CRLF;
				set @Command = @Command + '  inner join ' + @RIGHT_TABLE_NAME + @CRLF;
				set @Command = @Command + '          on ' + @RIGHT_TABLE_NAME + '.ID = ' + @AUDIT_TABLE + '.' + @RIGHT_PRIMARY_KEY;
				set @Command = @Command + '  inner join ' + @LEFT_TABLE_NAME  + @CRLF;
				set @Command = @Command + '          on ' + @LEFT_TABLE_NAME  + '.ID = ' + @AUDIT_TABLE + '.' + @LEFT_PRIMARY_KEY;
				set @Command = @Command + ' where ' + @AUDIT_TABLE + '.AUDIT_ID not in (select LINK_AUDIT_ID from dbo.' + @RIGHT_TABLE_NAME + '_STREAM where LINK_AUDIT_ID is not null)' + @CRLF;
				if @AUDIT_TABLE = 'PROSPECT_LISTS_PROSPECTS_AUDIT' and @RIGHT_PRIMARY_KEY = 'RELATED_ID' begin -- then
					set @Command = @Command + @CRLF;
					set @Command = @Command + '   and ' + @AUDIT_TABLE + '.RELATED_TYPE = ''Prospects'''
				end -- if;
				set @Command = @Command + ' order by AUDIT_VERSION;'  + @CRLF;
				if @TEST = 1 begin -- then
					print @Command + @CRLF;
				end else begin
					print substring(@Command, 1, charindex(@CRLF, @Command) - 1) + ' -- ' + @LEFT_MODULE_NAME;
					exec(@Command);
				end -- if;

				if @AUDIT_TABLE = 'PROSPECT_LISTS_PROSPECTS_AUDIT' and @RIGHT_PRIMARY_KEY = 'RELATED_ID' begin -- then
					set @RIGHT_TABLE_NAME = 'CONTACTS';
					set @Command = '';
					set @Command = @Command + 'insert into dbo.' + @RIGHT_TABLE_NAME + '_STREAM' + @CRLF;
					set @Command = @Command + '     ( STREAM_ID'             + @CRLF;
					set @Command = @Command + '     , STREAM_DATE'           + @CRLF;
					set @Command = @Command + '     , LINK_AUDIT_ID'         + @CRLF;
					set @Command = @Command + '     , STREAM_ACTION'         + @CRLF;
					set @Command = @Command + '     , STREAM_RELATED_ID'     + @CRLF;
					set @Command = @Command + '     , STREAM_RELATED_MODULE' + @CRLF;
					set @Command = @Command + '     , STREAM_RELATED_NAME'   + @CRLF;
					set @Command = @Command + '     , ID'                    + @CRLF;
					set @Command = @Command + '     , CREATED_BY'            + @CRLF;
					set @Command = @Command + '     , ASSIGNED_USER_ID'      + @CRLF;
					set @Command = @Command + '     , TEAM_ID'               + @CRLF;
					set @Command = @Command + '     , TEAM_SET_ID'           + @CRLF;
					set @Command = @Command + '     , NAME'                  + @CRLF;
					set @Command = @Command + '     )' + @CRLF;
					set @Command = @Command + 'select newid()'                                    + @CRLF;
					set @Command = @Command + '     , ' + @AUDIT_TABLE + '.AUDIT_DATE'            + @CRLF;
					set @Command = @Command + '     , ' + @AUDIT_TABLE + '.AUDIT_ID'              + @CRLF;
					set @Command = @Command + '     , (case ' + @AUDIT_TABLE + '.DELETED when 0 then ''Linked'' when 1 then ''Unlinked'' end)' + @CRLF;
					set @Command = @Command + '     , ' + @AUDIT_TABLE + '.' + @LEFT_PRIMARY_KEY  + @CRLF;
					set @Command = @Command + '     , ''' + @LEFT_MODULE_NAME + ''''              + @CRLF;
					set @Command = @Command + '     , ' + @LEFT_TABLE_NAME  + '.NAME'             + @CRLF;
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.ID'               + @CRLF;
					-- 06/03/2016 Paul.  We should be using the MODIFIED_USER_ID as the person who made the change. 
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.MODIFIED_USER_ID' + @CRLF;
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.ASSIGNED_USER_ID' + @CRLF;
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.TEAM_ID'          + @CRLF;
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.TEAM_SET_ID'      + @CRLF;
					set @Command = @Command + '     , dbo.fnFullName(' + @RIGHT_TABLE_NAME + '.FIRST_NAME, ' + @RIGHT_TABLE_NAME + '.LAST_NAME) as NAME' + @CRLF;
					set @Command = @Command + '  from       ' + @AUDIT_TABLE      + @CRLF;
					set @Command = @Command + '  inner join ' + @RIGHT_TABLE_NAME + @CRLF;
					set @Command = @Command + '          on ' + @RIGHT_TABLE_NAME + '.ID = ' + @AUDIT_TABLE + '.' + @RIGHT_PRIMARY_KEY + @CRLF;
					set @Command = @Command + '  inner join ' + @LEFT_TABLE_NAME  + @CRLF;
					set @Command = @Command + '          on ' + @LEFT_TABLE_NAME  + '.ID = ' + @AUDIT_TABLE + '.' + @LEFT_PRIMARY_KEY  + @CRLF;
					set @Command = @Command + ' where ' + @AUDIT_TABLE + '.AUDIT_ID not in (select LINK_AUDIT_ID from dbo.' + @RIGHT_TABLE_NAME + '_STREAM where LINK_AUDIT_ID is not null)' + @CRLF;
					set @Command = @Command + '   and ' + @AUDIT_TABLE + '.RELATED_TYPE = ''Contacts''' + @CRLF;
					set @Command = @Command + ' order by AUDIT_VERSION;'  + @CRLF;
					if @TEST = 1 begin -- then
						print @Command + @CRLF;
					end else begin
						print substring(@Command, 1, charindex(@CRLF, @Command) - 1) + ' -- ' + @LEFT_MODULE_NAME;
						exec(@Command);
					end -- if;

					set @RIGHT_TABLE_NAME = 'LEADS';
					set @Command = '';
					set @Command = @Command + 'insert into dbo.' + @RIGHT_TABLE_NAME + '_STREAM' + @CRLF;
					set @Command = @Command + '     ( STREAM_ID'             + @CRLF;
					set @Command = @Command + '     , STREAM_DATE'           + @CRLF;
					set @Command = @Command + '     , LINK_AUDIT_ID'         + @CRLF;
					set @Command = @Command + '     , STREAM_ACTION'         + @CRLF;
					set @Command = @Command + '     , STREAM_RELATED_ID'     + @CRLF;
					set @Command = @Command + '     , STREAM_RELATED_MODULE' + @CRLF;
					set @Command = @Command + '     , STREAM_RELATED_NAME'   + @CRLF;
					set @Command = @Command + '     , ID'                    + @CRLF;
					set @Command = @Command + '     , CREATED_BY'            + @CRLF;
					set @Command = @Command + '     , ASSIGNED_USER_ID'      + @CRLF;
					set @Command = @Command + '     , TEAM_ID'               + @CRLF;
					set @Command = @Command + '     , TEAM_SET_ID'           + @CRLF;
					set @Command = @Command + '     , NAME'                  + @CRLF;
					set @Command = @Command + '     )' + @CRLF;
					set @Command = @Command + 'select newid()'                                    + @CRLF;
					set @Command = @Command + '     , ' + @AUDIT_TABLE + '.AUDIT_DATE'            + @CRLF;
					set @Command = @Command + '     , ' + @AUDIT_TABLE + '.AUDIT_ID'              + @CRLF;
					set @Command = @Command + '     , (case ' + @AUDIT_TABLE + '.DELETED when 0 then ''Linked'' when 1 then ''Unlinked'' end)' + @CRLF;
					set @Command = @Command + '     , ' + @AUDIT_TABLE + '.' + @LEFT_PRIMARY_KEY  + @CRLF;
					set @Command = @Command + '     , ''' + @LEFT_MODULE_NAME + ''''              + @CRLF;
					set @Command = @Command + '     , ' + @LEFT_TABLE_NAME  + '.NAME'             + @CRLF;
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.ID'               + @CRLF;
					-- 06/03/2016 Paul.  We should be using the MODIFIED_USER_ID as the person who made the change. 
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.MODIFIED_USER_ID' + @CRLF;
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.ASSIGNED_USER_ID' + @CRLF;
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.TEAM_ID'          + @CRLF;
					set @Command = @Command + '     , ' + @RIGHT_TABLE_NAME + '.TEAM_SET_ID'      + @CRLF;
					set @Command = @Command + '     , dbo.fnFullName(' + @RIGHT_TABLE_NAME + '.FIRST_NAME, ' + @RIGHT_TABLE_NAME + '.LAST_NAME) as NAME' + @CRLF;
					set @Command = @Command + '  from       ' + @AUDIT_TABLE      + @CRLF;
					set @Command = @Command + '  inner join ' + @RIGHT_TABLE_NAME + @CRLF;
					set @Command = @Command + '          on ' + @RIGHT_TABLE_NAME + '.ID = ' + @AUDIT_TABLE + '.' + @RIGHT_PRIMARY_KEY + @CRLF;
					set @Command = @Command + '  inner join ' + @LEFT_TABLE_NAME  + @CRLF;
					set @Command = @Command + '          on ' + @LEFT_TABLE_NAME  + '.ID = ' + @AUDIT_TABLE + '.' + @LEFT_PRIMARY_KEY  + @CRLF;
					set @Command = @Command + ' where ' + @AUDIT_TABLE + '.AUDIT_ID not in (select LINK_AUDIT_ID from dbo.' + @RIGHT_TABLE_NAME + '_STREAM where LINK_AUDIT_ID is not null)' + @CRLF;
					set @Command = @Command + '   and ' + @AUDIT_TABLE + '.RELATED_TYPE = ''Leads''' + @CRLF;
					set @Command = @Command + ' order by AUDIT_VERSION;'  + @CRLF;
					if @TEST = 1 begin -- then
						print @Command + @CRLF;
					end else begin
						print substring(@Command, 1, charindex(@CRLF, @Command) - 1) + ' -- ' + @LEFT_MODULE_NAME;
						exec(@Command);
					end -- if;
				end -- if;
			end -- if;
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildStreamLinkData to public;
GO

