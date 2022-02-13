if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildStreamTable' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildStreamTable;
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
-- 10/31/2017 Paul.  TEAM_ID and TEAM_SET_ID are required, so make sure that they exist before creating the stream table. 
Create Procedure dbo.spSqlBuildStreamTable(@TABLE_NAME varchar(80))
as
  begin
	set nocount on

	declare @Command           varchar(max);
	declare @STREAM_TABLE      varchar(90);
	declare @AUDIT_TABLE       varchar(90);
	declare @STREAM_PK         varchar(90);
	declare @COLUMN_NAME       varchar(80);
	declare @COLUMN_TYPE       varchar(20);
	declare @COLUMN_MAX_LENGTH int;
	declare @TEST              bit;
	declare @CRLF              char(2);
	declare @SPLENDID_FIELDS   int;
	
	set @TEST            = 0;
	set @CRLF            = char(13) + char(10);
	set @SPLENDID_FIELDS = 0;
	set @STREAM_TABLE    = @TABLE_NAME + '_STREAM';
	set @AUDIT_TABLE     = @TABLE_NAME + '_AUDIT';
	set @STREAM_PK       = 'PKS_' + @TABLE_NAME;

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
	-- 10/31/2017 Paul.  TEAM_ID and TEAM_SET_ID are required, so make sure that they exist before creating the stream table. 
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'TEAM_ID') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;

	if @SPLENDID_FIELDS = 8 begin -- then
		if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = @STREAM_TABLE and TABLE_TYPE = 'BASE TABLE') begin -- then
			set @COLUMN_MAX_LENGTH = 30;

			set @Command = '';
			set @Command = @Command + 'Create Table dbo.' + @STREAM_TABLE + @CRLF;
			set @Command = @Command + '	( STREAM_ID'             + space(@COLUMN_MAX_LENGTH+1-len('STREAM_ID'            )) + 'uniqueidentifier   not null' + @CRLF;
			set @Command = @Command + '	, STREAM_DATE'           + space(@COLUMN_MAX_LENGTH+1-len('STREAM_DATE'          )) + 'datetime           not null' + @CRLF;
			set @Command = @Command + '	, STREAM_VERSION'        + space(@COLUMN_MAX_LENGTH+1-len('STREAM_VERSION'       )) + 'rowversion         not null' + @CRLF;
			set @Command = @Command + '	, STREAM_ACTION'         + space(@COLUMN_MAX_LENGTH+1-len('STREAM_ACTION'        )) + 'nvarchar(25)       null' + @CRLF;
			set @Command = @Command + '	, STREAM_COLUMNS'        + space(@COLUMN_MAX_LENGTH+1-len('STREAM_COLUMNS'       )) + 'varchar(max)       null' + @CRLF;
			set @Command = @Command + '	, STREAM_RELATED_ID'     + space(@COLUMN_MAX_LENGTH+1-len('STREAM_RELATED_ID'    )) + 'uniqueidentifier   null' + @CRLF;
			set @Command = @Command + '	, STREAM_RELATED_MODULE' + space(@COLUMN_MAX_LENGTH+1-len('STREAM_RELATED_MODULE')) + 'nvarchar(25)       null' + @CRLF;
			set @Command = @Command + '	, STREAM_RELATED_NAME'   + space(@COLUMN_MAX_LENGTH+1-len('STREAM_RELATED_NAME'  )) + 'nvarchar(255)      null' + @CRLF;
			set @Command = @Command + '	, AUDIT_ID'              + space(@COLUMN_MAX_LENGTH+1-len('AUDIT_ID'             )) + 'uniqueidentifier   null' + @CRLF;
			set @Command = @Command + '	, LINK_AUDIT_ID'         + space(@COLUMN_MAX_LENGTH+1-len('LINK_AUDIT_ID'        )) + 'uniqueidentifier   null' + @CRLF;
			set @Command = @Command + '	, ID'                    + space(@COLUMN_MAX_LENGTH+1-len('ID'                   )) + 'uniqueidentifier   null' + @CRLF;
			set @Command = @Command + '	, CREATED_BY'            + space(@COLUMN_MAX_LENGTH+1-len('CREATED_BY'           )) + 'uniqueidentifier   null' + @CRLF;
			--set @Command = @Command + '	, DATE_ENTERED'          + space(@COLUMN_MAX_LENGTH+1-len('DATE_ENTERED'         )) + 'datetime           null' + @CRLF;
			--set @Command = @Command + '	, MODIFIED_USER_ID'      + space(@COLUMN_MAX_LENGTH+1-len('MODIFIED_USER_ID'     )) + 'uniqueidentifier   null' + @CRLF;
			--set @Command = @Command + '	, DATE_MODIFIED'         + space(@COLUMN_MAX_LENGTH+1-len('DATE_MODIFIED'        )) + 'datetime           null' + @CRLF;
			--set @Command = @Command + '	, DATE_MODIFIED_UTC'     + space(@COLUMN_MAX_LENGTH+1-len('DATE_MODIFIED_UTC'    )) + 'datetime           null' + @CRLF;
			set @Command = @Command + '	, ASSIGNED_USER_ID'      + space(@COLUMN_MAX_LENGTH+1-len('ASSIGNED_USER_ID'     )) + 'uniqueidentifier   null' + @CRLF;
			set @Command = @Command + '	, TEAM_ID'               + space(@COLUMN_MAX_LENGTH+1-len('TEAM_ID'              )) + 'uniqueidentifier   null' + @CRLF;
			set @Command = @Command + '	, TEAM_SET_ID'           + space(@COLUMN_MAX_LENGTH+1-len('TEAM_SET_ID'          )) + 'uniqueidentifier   null' + @CRLF;
			set @Command = @Command + '	, NAME'                  + space(@COLUMN_MAX_LENGTH+1-len('NAME'                 )) + 'nvarchar(max)      null' + @CRLF;
			--set @Command = @Command + '	, DESCRIPTION'           + space(@COLUMN_MAX_LENGTH+1-len('DESCRIPTION'          )) + 'nvarchar(max)      null' + @CRLF;
			set @Command = @Command + '	)' + @CRLF;

			print 'Create Table dbo.' + @STREAM_TABLE + ';';
			if @TEST = 1 begin -- then
				print @Command;
			end else begin
				exec(@Command);
			end -- if;

			set @Command = 'create clustered index IDX_' + @STREAM_TABLE + '_ID on dbo.' + @STREAM_TABLE + '(ID, STREAM_DATE, STREAM_VERSION, STREAM_ACTION, AUDIT_ID)';
			if @TEST = 1 begin -- then
				print @Command;
			end else begin
				exec(@Command);
			end -- if;
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildStreamTable to public;
GO

