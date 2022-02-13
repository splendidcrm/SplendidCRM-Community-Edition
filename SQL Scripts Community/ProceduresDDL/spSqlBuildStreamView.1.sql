if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildStreamView' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildStreamView;
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
Create Procedure dbo.spSqlBuildStreamView(@TABLE_NAME varchar(80))
as
  begin
	set nocount on
	
	declare @Command           varchar(max);
	declare @STREAM_TABLE      varchar(90);
	declare @AUDIT_VIEW        varchar(90);
	declare @VIEW_NAME         varchar(90);
	declare @COLUMN_NAME       varchar(80);
	declare @TEST              bit;
	declare @CRLF              char(2);
	declare @SPLENDID_FIELDS   int;
	declare @JOIN_TEAMS        bit;

	set @TEST            = 0;
	set @CRLF            = char(13) + char(10);
	set @SPLENDID_FIELDS = 0;
	set @STREAM_TABLE    = @TABLE_NAME + '_STREAM';
	set @AUDIT_VIEW      = 'vw' + @TABLE_NAME + '_AUDIT';

	-- 09/23/2015 Paul.  We need to prevent from adding streaming to non-SplendidCRM tables, so check for the base fields. 
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_VIEW and COLUMN_NAME = 'AUDIT_ID') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_VIEW and COLUMN_NAME = 'AUDIT_ACTION') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_VIEW and COLUMN_NAME = 'AUDIT_DATE') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_VIEW and COLUMN_NAME = 'AUDIT_VERSION') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_VIEW and COLUMN_NAME = 'AUDIT_TOKEN') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;

	if @SPLENDID_FIELDS = 5 begin -- then
		if exists (select * from vwSqlTables where TABLE_NAME = @STREAM_TABLE) begin -- then
			declare AUDIT_VIEW_COLUMNS_CURSOR cursor for
			select COLUMN_NAME
			  from INFORMATION_SCHEMA.COLUMNS
			 where TABLE_NAME = @AUDIT_VIEW
			   and COLUMN_NAME not in ('ID', 'AUDIT_ID', 'AUDIT_COLUMNS')
			 order by ORDINAL_POSITION;
			
			set @VIEW_NAME = 'vw' + @TABLE_NAME + '_STREAM';
			if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = @VIEW_NAME) begin -- then
				set @Command = 'Drop   View dbo.' + @VIEW_NAME;
				print @Command;
				exec(@Command);
			end -- if;
			
			set @JOIN_TEAMS    = 0;
			if not exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = @VIEW_NAME) begin -- then
				set @Command = '';
				set @Command = @Command + 'Create View dbo.' + @VIEW_NAME + @CRLF;
				set @Command = @Command + 'as' + @CRLF;
				set @Command = @Command + 'select ' + @STREAM_TABLE + '.STREAM_ID            ' + @CRLF;
				set @Command = @Command + '     , ' + @STREAM_TABLE + '.STREAM_DATE          ' + @CRLF;
				set @Command = @Command + '     , ' + @STREAM_TABLE + '.STREAM_VERSION       ' + @CRLF;
				set @Command = @Command + '     , ' + @STREAM_TABLE + '.STREAM_ACTION        ' + @CRLF;
				set @Command = @Command + '     , ' + @STREAM_TABLE + '.STREAM_COLUMNS       ' + @CRLF;
				set @Command = @Command + '     , ' + @STREAM_TABLE + '.STREAM_RELATED_ID    ' + @CRLF;
				set @Command = @Command + '     , ' + @STREAM_TABLE + '.STREAM_RELATED_MODULE' + @CRLF;
				set @Command = @Command + '     , ' + @STREAM_TABLE + '.STREAM_RELATED_NAME  ' + @CRLF;
				-- 09/24/2015 Paul.  It is important that we use the STREAM version of the ID as it will be indexed. 
				set @Command = @Command + '     , ' + @STREAM_TABLE + '.AUDIT_ID             ' + @CRLF;
				set @Command = @Command + '     , ' + @STREAM_TABLE + '.ID                   ' + @CRLF;
				-- 12/04/2017 Paul.  The Created By field needs to come from the stream table, not the original audit value. 
				set @Command = @Command + '     , USERS_CREATED_BY.ID               as CREATED_BY_ID'      + @CRLF;
				set @Command = @Command + '     , USERS_CREATED_BY.ID               as MODIFIED_USER_ID'   + @CRLF;
				set @Command = @Command + '     , USERS_CREATED_BY.USER_NAME        as CREATED_BY'         + @CRLF;
				set @Command = @Command + '     , USERS_CREATED_BY.USER_NAME        as MODIFIED_BY'        + @CRLF;
				set @Command = @Command + '     , USERS_CREATED_BY.PICTURE          as CREATED_BY_PICTURE' + @CRLF;

				open AUDIT_VIEW_COLUMNS_CURSOR;
				fetch next from AUDIT_VIEW_COLUMNS_CURSOR into @COLUMN_NAME;
				while @@FETCH_STATUS = 0 begin -- while
					if @COLUMN_NAME in ('CREATED_BY_ID', 'MODIFIED_USER_ID', 'CREATED_BY', 'MODIFIED_BY')  begin -- then
						-- 12/06/2017 Paul.  We can't use continue as it would skip the fetch next and create an endless loop. 
						set @Command = @Command;
					end else if @COLUMN_NAME = 'ASSIGNED_USER_ID' begin -- then
						set @Command = @Command + '     , isnull(' + @AUDIT_VIEW + '.ASSIGNED_USER_ID, ' + @STREAM_TABLE + '.ASSIGNED_USER_ID) as ASSIGNED_USER_ID' + @CRLF;
					end else if @COLUMN_NAME = 'TEAM_ID'          begin -- then
						set @Command = @Command + '     , isnull(' + @AUDIT_VIEW + '.TEAM_ID         , ' + @STREAM_TABLE + '.TEAM_ID         ) as TEAM_ID         ' + @CRLF;
					end else if @COLUMN_NAME = 'TEAM_SET_ID'      begin -- then
						set @Command = @Command + '     , isnull(' + @AUDIT_VIEW + '.TEAM_SET_ID     , ' + @STREAM_TABLE + '.TEAM_SET_ID     ) as TEAM_SET_ID     ' + @CRLF;
					end else if @COLUMN_NAME = 'DATE_ENTERED'     begin -- then
						set @Command = @Command + '     , isnull(' + @AUDIT_VIEW + '.DATE_ENTERED    , ' + @STREAM_TABLE + '.STREAM_DATE     ) as DATE_ENTERED    ' + @CRLF;
					end else if @COLUMN_NAME = 'DATE_MODIFIED'    begin -- then
						set @Command = @Command + '     , isnull(' + @AUDIT_VIEW + '.DATE_MODIFIED   , ' + @STREAM_TABLE + '.STREAM_DATE     ) as DATE_MODIFIED   ' + @CRLF;
					end else if @COLUMN_NAME = 'NAME'             begin -- then
						set @Command = @Command + '     , isnull(' + @AUDIT_VIEW + '.NAME            , ' + @STREAM_TABLE + '.NAME            ) as NAME            ' + @CRLF;
					--end else if @COLUMN_NAME = 'DESCRIPTION'      begin -- then
					--	set @Command = @Command + '     , isnull(' + @AUDIT_VIEW + '.DESCRIPTION     , ' + @STREAM_TABLE + '.DESCRIPTION     ) as DESCRIPTION     ' + @CRLF;
					end else if @COLUMN_NAME = 'ASSIGNED_TO'      begin -- then
						set @Command = @Command + '     , isnull(' + @AUDIT_VIEW + '.ASSIGNED_TO     , USERS_CREATED_BY.USER_NAME      ) as ASSIGNED_TO     ' + @CRLF;
					end else if @COLUMN_NAME = 'TEAM_NAME'        begin -- then
						set @Command = @Command + '     , isnull(' + @AUDIT_VIEW + '.TEAM_NAME       , TEAMS.NAME                      ) as TEAM_NAME       ' + @CRLF;
						set @JOIN_TEAMS = 1;
					--end else if @COLUMN_NAME = 'AUDIT_COLUMNS'             begin -- then
					--	set @Command = @Command + '     , dbo.fnSqlDecodeAuditColumns(''' + @TABLE_NAME + ''', ' + @AUDIT_VIEW + '.AUDIT_COLUMNS) as AUDIT_COLUMNS' + @CRLF;
					end else begin
						set @Command = @Command + '     , ' + @AUDIT_VIEW + '.' + @COLUMN_NAME + @CRLF;
					end -- if;
					fetch next from AUDIT_VIEW_COLUMNS_CURSOR into @COLUMN_NAME;
				end -- while;
				close AUDIT_VIEW_COLUMNS_CURSOR

				set @Command = @Command + '  from            ' + @STREAM_TABLE + @CRLF;
				set @Command = @Command + '  left outer join ' + @AUDIT_VIEW   + @CRLF;
				set @Command = @Command + '               on ' + @AUDIT_VIEW   + '.AUDIT_ID   = ' + @STREAM_TABLE + '.AUDIT_ID' + @CRLF;
				set @Command = @Command + '  left outer join USERS                         USERS_CREATED_BY' + @CRLF;
				set @Command = @Command + '               on USERS_CREATED_BY.ID         = ' + @STREAM_TABLE + '.CREATED_BY' + @CRLF;
				if @JOIN_TEAMS = 1 begin -- then
					set @Command = @Command + '  left outer join TEAMS' + @CRLF;
					set @Command = @Command + '               on TEAMS.ID                    = ' + @STREAM_TABLE + '.TEAM_ID' + @CRLF;
					set @Command = @Command + '              and TEAMS.DELETED               = 0' + @CRLF;
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
					--print @Command + @CRLF;
					exec(@Command);
				end -- if;
			end -- if;

			deallocate AUDIT_VIEW_COLUMNS_CURSOR;
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildStreamView to public;
GO

