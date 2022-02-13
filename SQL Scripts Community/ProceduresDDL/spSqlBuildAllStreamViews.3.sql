if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildAllStreamViews' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildAllStreamViews;
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
-- 06/02/2016 Paul.  Create master activities view. 
Create Procedure dbo.spSqlBuildAllStreamViews
as
  begin
	set nocount on
	print N'spSqlBuildAllStreamViews';

	declare @Command           varchar(max);
	declare @STREAM_TABLE      varchar(90);
	declare @VIEW_NAME         varchar(90);
	declare @MODULE_NAME       varchar(50);
	declare @TEST              bit;
	declare @CRLF              char(2);
	declare @TABLE_NAME        varchar(80);
	declare TABLES_CURSOR cursor for
	select vwSqlTablesStreamed.TABLE_NAME
	  from      vwSqlTablesStreamed
	 inner join vwSqlTables
	         on vwSqlTables.TABLE_NAME = vwSqlTablesStreamed.TABLE_NAME + '_STREAM'
	order by vwSqlTablesStreamed.TABLE_NAME;
	
	set @TEST      = 0;
	set @CRLF      = char(13) + char(10);
	set @VIEW_NAME = 'vwACTIVITY_STREAMS';
	if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = @VIEW_NAME) begin -- then
		set @Command = 'Drop   View dbo.' + @VIEW_NAME;
		print @Command;
		exec(@Command);
	end -- if;

	set @Command = '';
	open TABLES_CURSOR;
	fetch next from TABLES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		exec dbo.spSqlBuildStreamView @TABLE_NAME;

		select @MODULE_NAME = MODULE_NAME
		  from MODULES
		 where TABLE_NAME = @TABLE_NAME
		   and DELETED    = 0;
		if @MODULE_NAME is null begin -- end
			set @MODULE_NAME = dbo.fnCamelCase(@TABLE_NAME);
		end -- if;
		set @STREAM_TABLE    = @TABLE_NAME + '_STREAM';
		if len(@Command) = 0 begin -- then
			set @Command = @Command + 'Create View dbo.' + @VIEW_NAME + @CRLF;
			set @Command = @Command + 'as' + @CRLF;
		end else begin
			set @Command = @Command + 'union all' + @CRLF;
		end -- if;
		set @Command = @Command + 'select STREAM_ID'                  + @CRLF;
		set @Command = @Command + '     , STREAM_DATE'                + @CRLF;
		set @Command = @Command + '     , STREAM_VERSION'             + @CRLF;
		set @Command = @Command + '     , STREAM_ACTION'              + @CRLF;
		set @Command = @Command + '     , STREAM_COLUMNS'             + @CRLF;
		set @Command = @Command + '     , STREAM_RELATED_ID'          + @CRLF;
		set @Command = @Command + '     , STREAM_RELATED_MODULE'      + @CRLF;
		set @Command = @Command + '     , STREAM_RELATED_NAME'        + @CRLF;
		set @Command = @Command + '     , AUDIT_ID'                   + @CRLF;
		set @Command = @Command + '     , ' + @STREAM_TABLE + '.ID   as ID'                  + @CRLF;
		set @Command = @Command + '     , ' + @STREAM_TABLE + '.NAME as NAME'                + @CRLF;
		set @Command = @Command + '     , ''' + @TABLE_NAME  + '''           as TABLE_NAME'  + @CRLF;
		set @Command = @Command + '     , ''' + @MODULE_NAME + '''           as MODULE_NAME' + @CRLF;
		set @Command = @Command + '     , ASSIGNED_USER_ID'           + @CRLF;
		set @Command = @Command + '     , TEAM_ID'                    + @CRLF;
		set @Command = @Command + '     , TEAM_SET_ID'                + @CRLF;
		set @Command = @Command + '     , STREAM_DATE                as DATE_ENTERED'        + @CRLF;
		set @Command = @Command + '     , STREAM_DATE                as DATE_MODIFIED'       + @CRLF;
		set @Command = @Command + '     , USERS_CREATED_BY.ID        as CREATED_BY_ID'       + @CRLF;
		set @Command = @Command + '     , USERS_CREATED_BY.ID        as MODIFIED_USER_ID'    + @CRLF;
		set @Command = @Command + '     , USERS_CREATED_BY.USER_NAME as CREATED_BY'          + @CRLF;
		set @Command = @Command + '     , USERS_CREATED_BY.USER_NAME as MODIFIED_BY'         + @CRLF;
		set @Command = @Command + '     , USERS_CREATED_BY.USER_NAME as ASSIGNED_TO'         + @CRLF;
		set @Command = @Command + '     , USERS_CREATED_BY.PICTURE   as CREATED_BY_PICTURE'  + @CRLF;
		set @Command = @Command + '     , TEAMS.NAME                 as TEAM_NAME'           + @CRLF;
		set @Command = @Command + '  from            ' + @STREAM_TABLE + @CRLF;
		set @Command = @Command + '  left outer join USERS                 USERS_CREATED_BY' + @CRLF;
		set @Command = @Command + '               on USERS_CREATED_BY.ID = ' + @STREAM_TABLE + '.CREATED_BY' + @CRLF;
		set @Command = @Command + '  left outer join TEAMS' + @CRLF;
		set @Command = @Command + '               on TEAMS.ID            = ' + @STREAM_TABLE + '.TEAM_ID' + @CRLF;
		set @Command = @Command + '              and TEAMS.DELETED       = 0' + @CRLF;
		fetch next from TABLES_CURSOR into @TABLE_NAME;
	end -- while;
	close TABLES_CURSOR;
	deallocate TABLES_CURSOR;

	if not exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = @VIEW_NAME) begin -- then
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
  end
GO


Grant Execute on dbo.spSqlBuildAllStreamViews to public;
GO

-- exec dbo.spSqlBuildAllStreamViews;

