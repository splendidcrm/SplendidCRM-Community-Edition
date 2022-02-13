if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildStreamData' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildStreamData;
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
Create Procedure dbo.spSqlBuildStreamData(@TABLE_NAME varchar(80))
as
  begin
	set nocount on
	
	declare @Command           varchar(max);
	declare @STREAM_TABLE      varchar(90);
	declare @AUDIT_TABLE       varchar(90);
	declare @TRIGGER_NAME      varchar(90);
	declare @COLUMN_NAME       varchar(80);
	declare @COLUMN_TYPE       varchar(20);
	declare @TEST              bit;
	declare @CRLF              char(2);
	declare @SPLENDID_FIELDS   int;

	set @TEST            = 0;
	set @CRLF            = char(13) + char(10);
	set @SPLENDID_FIELDS = 0;
	set @STREAM_TABLE    = @TABLE_NAME + '_STREAM';
	set @AUDIT_TABLE     = @TABLE_NAME + '_AUDIT';

	-- 09/23/2015 Paul.  We need to prevent from adding streaming to non-SplendidCRM tables, so check for the base fields. 
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_ID') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_ACTION') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_DATE') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_VERSION') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_COLUMNS') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_TOKEN') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;

	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'STREAM_ID') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'STREAM_DATE') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'STREAM_VERSION') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'STREAM_ACTION') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'STREAM_COLUMNS') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'AUDIT_ID') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'ID') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;

	if @SPLENDID_FIELDS = 13 begin -- then
		if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = @AUDIT_TABLE) begin -- then
			set @Command = '';
			set @Command = @Command + 'insert into dbo.' + @STREAM_TABLE + @CRLF;
			set @Command = @Command + '     ( STREAM_ID'         + @CRLF;
			set @Command = @Command + '     , STREAM_DATE'       + @CRLF;
			set @Command = @Command + '     , STREAM_ACTION'     + @CRLF;
			set @Command = @Command + '     , STREAM_COLUMNS'    + @CRLF;
			set @Command = @Command + '     , AUDIT_ID'          + @CRLF;
			set @Command = @Command + '     , ID'                + @CRLF;
			set @Command = @Command + '     , CREATED_BY'        + @CRLF;
			set @Command = @Command + '     , TEAM_ID'           + @CRLF;
			set @Command = @Command + '     , ASSIGNED_USER_ID'  + @CRLF;
			set @Command = @Command + '     , NAME'              + @CRLF;
			set @Command = @Command + '     )' + @CRLF;
			set @Command = @Command + 'select newid()'           + @CRLF;
			set @Command = @Command + '     , AUDIT_DATE'        + @CRLF;
			set @Command = @Command + '     , (case AUDIT_ACTION when 0 then ''Created'' when 1 then ''Updated'' when -1 then ''Deleted'' end)' + @CRLF;
			set @Command = @Command + '     , dbo.fn' + @AUDIT_TABLE + '_COLUMNS(AUDIT_ID, ID, AUDIT_VERSION, AUDIT_ACTION)' + @CRLF;
			set @Command = @Command + '     , AUDIT_ID'          + @CRLF;
			set @Command = @Command + '     , ID'                + @CRLF;
			-- 06/03/2016 Paul.  We should be using the MODIFIED_USER_ID as the person who made the change. 
			set @Command = @Command + '     , MODIFIED_USER_ID'  + @CRLF;
			set @Command = @Command + '     , ASSIGNED_USER_ID'  + @CRLF;
			set @Command = @Command + '     , TEAM_ID'           + @CRLF;
			if @TABLE_NAME = 'CONTACTS' or @TABLE_NAME = 'LEADS' or @TABLE_NAME = 'PROSPECTS' or @TABLE_NAME = 'USERS' begin -- then
				set @Command = @Command + '     , dbo.fnFullName(' + @AUDIT_TABLE + '.FIRST_NAME, ' + @AUDIT_TABLE + '.LAST_NAME) as NAME' + @CRLF;
			end else if @TABLE_NAME = 'DOCUMENTS' begin -- then
				set @Command = @Command + '     , ' + @AUDIT_TABLE + '.DOCUMENT_NAME as NAME  ' + @CRLF;
			end else begin
				set @Command = @Command + '     , ' + @AUDIT_TABLE + '.NAME'             + @CRLF;
			end -- if;
			set @Command = @Command + '  from ' + @AUDIT_TABLE   + @CRLF;
			set @Command = @Command + ' where AUDIT_ID not in (select AUDIT_ID from dbo.' + @STREAM_TABLE + ' where AUDIT_ID is not null)' + @CRLF;
			set @Command = @Command + ' order by AUDIT_VERSION'  + @CRLF;
			if @TEST = 1 begin -- then
				print @Command + @CRLF;
			end else begin
				print substring(@Command, 1, charindex(@CRLF, @Command));
				exec(@Command);
			end -- if;
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildStreamData to public;
GO

