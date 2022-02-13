if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildArchiveActivityView' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildArchiveActivityView;
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
-- 04/27/2020 Paul.  Some views may not have the field, but we need to prevent invalid unions. 
Create Procedure dbo.spSqlBuildArchiveActivityView
	( @ARCHIVE_DATABASE nvarchar(50)
	)
as
  begin
	set nocount on
	print 'spSqlBuildArchiveActivityView';
	
	declare @COMMAND              nvarchar(max);
	declare @CRLF                 nchar(2);
	declare @TABLE_NAME           nvarchar(80);
	declare @ARCHIVE_TABLE        nvarchar(90);
	declare @VIEW_NAME            nvarchar(90);
	declare @RELATED_TABLE        nvarchar(80);
	declare @TEST                 bit;
	declare @SPLENDID_FIELDS      int;
	declare @EXISTS               bit;
	declare @ARCHIVE_DATABASE_DOT nvarchar(50);
	declare @RELATED_DATABASE_DOT nvarchar(50);

	set @TEST      = 0;
	set @CRLF      = char(13) + char(10);
	if len(@ARCHIVE_DATABASE) > 0 begin -- then
		set @ARCHIVE_DATABASE_DOT = '[' + @ARCHIVE_DATABASE + '].';
	end else begin
		set @ARCHIVE_DATABASE_DOT = '';
	end -- if;

	set @VIEW_NAME = 'vwACTIVITIES_ARCHIVE';
	if exists (select * from vwSqlViews where VIEW_NAME = @VIEW_NAME) begin -- then
		set @COMMAND = 'Drop   View dbo.' + @VIEW_NAME;
		print @COMMAND;
		exec(@COMMAND);
	end -- if;

	set @COMMAND = '';
	set @COMMAND = @COMMAND + 'Create View dbo.' + @VIEW_NAME + @CRLF;
	set @COMMAND = @COMMAND + 'as' + @CRLF;

	set @RELATED_TABLE = 'TASKS_ARCHIVE';
	set @RELATED_DATABASE_DOT = @ARCHIVE_DATABASE_DOT;
	exec dbo.spSqlTableExists @EXISTS out, @RELATED_TABLE, @ARCHIVE_DATABASE;
	if @EXISTS = 0 begin -- then
		set @RELATED_DATABASE_DOT = '';
		set @RELATED_TABLE = 'TASKS';
	end -- if;
	set @COMMAND = @COMMAND + 'select ' + @RELATED_TABLE + '.ID' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '     , 1                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , ARCHIVE_MODIFIED_BY.USER_NAME                                                 as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , dbo.fnFullName(ARCHIVE_MODIFIED_BY.FIRST_NAME, ARCHIVE_MODIFIED_BY.LAST_NAME) as ARCHIVE_BY_NAME' + @CRLF;
	end else begin
		set @COMMAND = @COMMAND + '     , 0                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as datetime        ) as ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as uniqueidentifier) as ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(60)    ) as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(200)   ) as ARCHIVE_BY_NAME' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.CREATED_BY       as CREATED_BY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_CREATED_BY.USER_NAME                                                as CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_MODIFIED_BY.USER_NAME                                               as MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID             as ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ID                           as ACTIVITY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''Tasks''                           as ACTIVITY_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME                         as ACTIVITY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID             as ACTIVITY_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_ID                    as PARENT_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_TYPE                  as PARENT_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_NAME              as PARENT_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.STATUS                       as STATUS' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''none''                            as DIRECTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START                   as DATE_START' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_DUE                     as DATE_DUE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_MODIFIED                as DATE_MODIFIED' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_MODIFIED_UTC            as DATE_MODIFIED_UTC' + @CRLF;
	set @COMMAND = @COMMAND + '     , (case ' + @RELATED_TABLE + '.STATUS when N''Not Started''   then 1' + @CRLF;
	set @COMMAND = @COMMAND + '                          when N''In Progress''   then 1' + @CRLF;
	set @COMMAND = @COMMAND + '                          when N''Pending Input'' then 1' + @CRLF;
	set @COMMAND = @COMMAND + '        else 0' + @CRLF;
	set @COMMAND = @COMMAND + '        end)                              as IS_OPEN' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.ID                           as TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.NAME                         as TEAM_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.ID                       as TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DESCRIPTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , TAG_SETS.TAG_SET_NAME' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST' + @CRLF;
	end else begin
		-- 04/27/2020 Paul.  Some views may not have the field, but we need to prevent invalid unions. 
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_LIST' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  from            ' + @RELATED_DATABASE_DOT + 'dbo.' + @RELATED_TABLE + ' ' + @RELATED_TABLE + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
	set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID      = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAMS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAMS.ID                 = ' + @RELATED_TABLE + '.TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAMS.DELETED            = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAM_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAM_SETS.ID             = ' + @RELATED_TABLE + '.TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAM_SETS.DELETED        = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TAG_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TAG_SETS.BEAN_ID         = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TAG_SETS.DELETED         = 0' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '  left outer join USERS                           ARCHIVE_MODIFIED_BY' + @CRLF;
		set @COMMAND = @COMMAND + '               on ARCHIVE_MODIFIED_BY.ID       = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_CREATED_BY.ID          = ' + @RELATED_TABLE + '.CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_MODIFIED_BY.ID         = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_ASSIGNED' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_ASSIGNED.ID            = ' + @RELATED_TABLE + '.ASSIGNED_USER_ID' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '  left outer join ASSIGNED_SETS' + @CRLF;
		set @COMMAND = @COMMAND + '               on ASSIGNED_SETS.ID             = ' + @RELATED_TABLE + '.ASSIGNED_SET_ID' + @CRLF;
		set @COMMAND = @COMMAND + '              and ASSIGNED_SETS.DELETED        = 0' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + ' where ' + @RELATED_TABLE + '.DELETED = 0' + @CRLF;

	set @RELATED_TABLE = 'MEETINGS_ARCHIVE';
	set @RELATED_DATABASE_DOT = @ARCHIVE_DATABASE_DOT;
	exec dbo.spSqlTableExists @EXISTS out, @RELATED_TABLE, @ARCHIVE_DATABASE;
	if @EXISTS = 0 begin -- then
		set @RELATED_DATABASE_DOT = '';
		set @RELATED_TABLE = 'MEETINGS';
	end -- if;
	set @COMMAND = @COMMAND + 'union all' + @CRLF;
	set @COMMAND = @COMMAND + 'select ' + @RELATED_TABLE + '.ID' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '     , 1                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , ARCHIVE_MODIFIED_BY.USER_NAME                                                 as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , dbo.fnFullName(ARCHIVE_MODIFIED_BY.FIRST_NAME, ARCHIVE_MODIFIED_BY.LAST_NAME) as ARCHIVE_BY_NAME' + @CRLF;
	end else begin
		set @COMMAND = @COMMAND + '     , 0                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as datetime        ) as ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as uniqueidentifier) as ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(60)    ) as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(200)   ) as ARCHIVE_BY_NAME' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.CREATED_BY       as CREATED_BY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_CREATED_BY.USER_NAME                                                as CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_MODIFIED_BY.USER_NAME                                               as MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID          as ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ID                        as ACTIVITY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''Meetings''                        as ACTIVITY_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME                      as ACTIVITY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID          as ACTIVITY_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_ID                 as PARENT_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_TYPE               as PARENT_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_NAME              as PARENT_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.STATUS                    as STATUS' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''none''                            as DIRECTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START                as DATE_START' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START                as DATE_DUE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_MODIFIED             as DATE_MODIFIED' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_MODIFIED_UTC         as DATE_MODIFIED_UTC' + @CRLF;
	set @COMMAND = @COMMAND + '     , (case ' + @RELATED_TABLE + '.STATUS when N''Planned'' then 1' + @CRLF;
	set @COMMAND = @COMMAND + '        else 0' + @CRLF;
	set @COMMAND = @COMMAND + '        end)                              as IS_OPEN' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.ID                           as TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.NAME                         as TEAM_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.ID                       as TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DESCRIPTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , TAG_SETS.TAG_SET_NAME' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST' + @CRLF;
	end else begin
		-- 04/27/2020 Paul.  Some views may not have the field, but we need to prevent invalid unions. 
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_LIST' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  from            ' + @RELATED_DATABASE_DOT + 'dbo.' + @RELATED_TABLE + ' ' + @RELATED_TABLE + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
	set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID      = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAMS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAMS.ID                 = ' + @RELATED_TABLE + '.TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAMS.DELETED            = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAM_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAM_SETS.ID             = ' + @RELATED_TABLE + '.TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAM_SETS.DELETED        = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TAG_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TAG_SETS.BEAN_ID         = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TAG_SETS.DELETED         = 0' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '  left outer join USERS                           ARCHIVE_MODIFIED_BY' + @CRLF;
		set @COMMAND = @COMMAND + '               on ARCHIVE_MODIFIED_BY.ID       = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_CREATED_BY.ID          = ' + @RELATED_TABLE + '.CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_MODIFIED_BY.ID         = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_ASSIGNED' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_ASSIGNED.ID            = ' + @RELATED_TABLE + '.ASSIGNED_USER_ID' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '  left outer join ASSIGNED_SETS' + @CRLF;
		set @COMMAND = @COMMAND + '               on ASSIGNED_SETS.ID             = ' + @RELATED_TABLE + '.ASSIGNED_SET_ID' + @CRLF;
		set @COMMAND = @COMMAND + '              and ASSIGNED_SETS.DELETED        = 0' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + ' where ' + @RELATED_TABLE + '.DELETED = 0' + @CRLF;

	set @RELATED_TABLE = 'CALLS_ARCHIVE';
	set @RELATED_DATABASE_DOT = @ARCHIVE_DATABASE_DOT;
	exec dbo.spSqlTableExists @EXISTS out, @RELATED_TABLE, @ARCHIVE_DATABASE;
	if @EXISTS = 0 begin -- then
		set @RELATED_DATABASE_DOT = '';
		set @RELATED_TABLE = 'CALLS';
	end -- if;
	set @COMMAND = @COMMAND + 'union all' + @CRLF;
	set @COMMAND = @COMMAND + 'select ' + @RELATED_TABLE + '.ID' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '     , 1                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , ARCHIVE_MODIFIED_BY.USER_NAME                                                 as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , dbo.fnFullName(ARCHIVE_MODIFIED_BY.FIRST_NAME, ARCHIVE_MODIFIED_BY.LAST_NAME) as ARCHIVE_BY_NAME' + @CRLF;
	end else begin
		set @COMMAND = @COMMAND + '     , 0                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as datetime        ) as ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as uniqueidentifier) as ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(60)    ) as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(200)   ) as ARCHIVE_BY_NAME' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.CREATED_BY       as CREATED_BY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_CREATED_BY.USER_NAME                                                as CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_MODIFIED_BY.USER_NAME                                               as MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID             as ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ID                           as ACTIVITY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''Calls''                           as ACTIVITY_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME                         as ACTIVITY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID             as ACTIVITY_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_ID                    as PARENT_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_TYPE                  as PARENT_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_NAME              as PARENT_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.STATUS                       as STATUS' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DIRECTION                    as DIRECTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START                   as DATE_START' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START                   as DATE_DUE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_MODIFIED                as DATE_MODIFIED' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_MODIFIED_UTC            as DATE_MODIFIED_UTC' + @CRLF;
	set @COMMAND = @COMMAND + '     , (case ' + @RELATED_TABLE + '.STATUS when N''Planned'' then 1' + @CRLF;
	set @COMMAND = @COMMAND + '        else 0' + @CRLF;
	set @COMMAND = @COMMAND + '        end)                              as IS_OPEN' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.ID                           as TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.NAME                         as TEAM_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.ID                       as TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DESCRIPTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , TAG_SETS.TAG_SET_NAME' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST' + @CRLF;
	end else begin
		-- 04/27/2020 Paul.  Some views may not have the field, but we need to prevent invalid unions. 
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_LIST' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  from            ' + @RELATED_DATABASE_DOT + 'dbo.' + @RELATED_TABLE + ' ' + @RELATED_TABLE + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
	set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID      = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAMS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAMS.ID                 = ' + @RELATED_TABLE + '.TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAMS.DELETED            = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAM_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAM_SETS.ID             = ' + @RELATED_TABLE + '.TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAM_SETS.DELETED        = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TAG_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TAG_SETS.BEAN_ID         = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TAG_SETS.DELETED         = 0' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '  left outer join USERS                           ARCHIVE_MODIFIED_BY' + @CRLF;
		set @COMMAND = @COMMAND + '               on ARCHIVE_MODIFIED_BY.ID       = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_CREATED_BY.ID          = ' + @RELATED_TABLE + '.CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_MODIFIED_BY.ID         = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_ASSIGNED' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_ASSIGNED.ID            = ' + @RELATED_TABLE + '.ASSIGNED_USER_ID' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '  left outer join ASSIGNED_SETS' + @CRLF;
		set @COMMAND = @COMMAND + '               on ASSIGNED_SETS.ID             = ' + @RELATED_TABLE + '.ASSIGNED_SET_ID' + @CRLF;
		set @COMMAND = @COMMAND + '              and ASSIGNED_SETS.DELETED        = 0' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + ' where ' + @RELATED_TABLE + '.DELETED = 0' + @CRLF;

	set @RELATED_TABLE = 'EMAILS_ARCHIVE';
	set @RELATED_DATABASE_DOT = @ARCHIVE_DATABASE_DOT;
	exec dbo.spSqlTableExists @EXISTS out, @RELATED_TABLE, @ARCHIVE_DATABASE;
	if @EXISTS = 0 begin -- then
		set @RELATED_DATABASE_DOT = '';
		set @RELATED_TABLE = 'EMAILS';
	end -- if;
	set @COMMAND = @COMMAND + 'union all' + @CRLF;
	set @COMMAND = @COMMAND + 'select ' + @RELATED_TABLE + '.ID' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '     , 1                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , ARCHIVE_MODIFIED_BY.USER_NAME                                                 as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , dbo.fnFullName(ARCHIVE_MODIFIED_BY.FIRST_NAME, ARCHIVE_MODIFIED_BY.LAST_NAME) as ARCHIVE_BY_NAME' + @CRLF;
	end else begin
		set @COMMAND = @COMMAND + '     , 0                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as datetime        ) as ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as uniqueidentifier) as ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(60)    ) as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(200)   ) as ARCHIVE_BY_NAME' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.CREATED_BY       as CREATED_BY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_CREATED_BY.USER_NAME                                                as CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_MODIFIED_BY.USER_NAME                                               as MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID            as ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ID                          as ACTIVITY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''Emails''                          as ACTIVITY_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME                        as ACTIVITY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID            as ACTIVITY_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_ID                   as PARENT_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_TYPE                 as PARENT_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_NAME              as PARENT_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.STATUS                      as STATUS' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''none''                            as DIRECTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START                  as DATE_START' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START                  as DATE_DUE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START                  as DATE_MODIFIED' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_MODIFIED_UTC           as DATE_MODIFIED_UTC' + @CRLF;
	set @COMMAND = @COMMAND + '     , 0                                  as IS_OPEN' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.ID                           as TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.NAME                         as TEAM_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.ID                       as TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DESCRIPTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , TAG_SETS.TAG_SET_NAME' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST' + @CRLF;
	end else begin
		-- 04/27/2020 Paul.  Some views may not have the field, but we need to prevent invalid unions. 
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_LIST' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  from            ' + @RELATED_DATABASE_DOT + 'dbo.' + @RELATED_TABLE + ' ' + @RELATED_TABLE + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
	set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID      = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAMS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAMS.ID                 = ' + @RELATED_TABLE + '.TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAMS.DELETED            = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAM_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAM_SETS.ID             = ' + @RELATED_TABLE + '.TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAM_SETS.DELETED        = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TAG_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TAG_SETS.BEAN_ID         = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TAG_SETS.DELETED         = 0' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '  left outer join USERS                           ARCHIVE_MODIFIED_BY' + @CRLF;
		set @COMMAND = @COMMAND + '               on ARCHIVE_MODIFIED_BY.ID       = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_CREATED_BY.ID          = ' + @RELATED_TABLE + '.CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_MODIFIED_BY.ID         = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_ASSIGNED' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_ASSIGNED.ID            = ' + @RELATED_TABLE + '.ASSIGNED_USER_ID' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '  left outer join ASSIGNED_SETS' + @CRLF;
		set @COMMAND = @COMMAND + '               on ASSIGNED_SETS.ID             = ' + @RELATED_TABLE + '.ASSIGNED_SET_ID' + @CRLF;
		set @COMMAND = @COMMAND + '              and ASSIGNED_SETS.DELETED        = 0' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + ' where ' + @RELATED_TABLE + '.DELETED = 0' + @CRLF;

	set @RELATED_TABLE = 'NOTES_ARCHIVE';
	set @RELATED_DATABASE_DOT = @ARCHIVE_DATABASE_DOT;
	exec dbo.spSqlTableExists @EXISTS out, @RELATED_TABLE, @ARCHIVE_DATABASE;
	if @EXISTS = 0 begin -- then
		set @RELATED_DATABASE_DOT = '';
		set @RELATED_TABLE = 'NOTES';
	end -- if;
	set @COMMAND = @COMMAND + 'union all' + @CRLF;
	set @COMMAND = @COMMAND + 'select ' + @RELATED_TABLE + '.ID' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '     , 1                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , ARCHIVE_MODIFIED_BY.USER_NAME                                                 as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , dbo.fnFullName(ARCHIVE_MODIFIED_BY.FIRST_NAME, ARCHIVE_MODIFIED_BY.LAST_NAME) as ARCHIVE_BY_NAME' + @CRLF;
	end else begin
		set @COMMAND = @COMMAND + '     , 0                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as datetime        ) as ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as uniqueidentifier) as ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(60)    ) as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(200)   ) as ARCHIVE_BY_NAME' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.CREATED_BY       as CREATED_BY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_CREATED_BY.USER_NAME                                                as CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_MODIFIED_BY.USER_NAME                                               as MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID             as ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ID                           as ACTIVITY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''Notes''                           as ACTIVITY_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME                         as ACTIVITY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , cast(null as uniqueidentifier)     as ACTIVITY_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_ID                    as PARENT_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_TYPE                  as PARENT_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_NAME              as PARENT_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''Note''                            as STATUS' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''none''                            as DIRECTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , cast(null as datetime)             as DATE_START' + @CRLF;
	set @COMMAND = @COMMAND + '     , cast(null as datetime)             as DATE_DUE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_MODIFIED                as DATE_MODIFIED' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_MODIFIED_UTC            as DATE_MODIFIED_UTC' + @CRLF;
	set @COMMAND = @COMMAND + '     , 0                                  as IS_OPEN' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.ID                           as TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.NAME                         as TEAM_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.ID                       as TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DESCRIPTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , TAG_SETS.TAG_SET_NAME' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST' + @CRLF;
	end else begin
		-- 04/27/2020 Paul.  Some views may not have the field, but we need to prevent invalid unions. 
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_LIST' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  from            ' + @RELATED_DATABASE_DOT + 'dbo.' + @RELATED_TABLE + ' ' + @RELATED_TABLE + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
	set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID      = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAMS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAMS.ID                 = ' + @RELATED_TABLE + '.TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAMS.DELETED            = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAM_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAM_SETS.ID             = ' + @RELATED_TABLE + '.TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAM_SETS.DELETED        = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TAG_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TAG_SETS.BEAN_ID         = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TAG_SETS.DELETED         = 0' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '  left outer join USERS                           ARCHIVE_MODIFIED_BY' + @CRLF;
		set @COMMAND = @COMMAND + '               on ARCHIVE_MODIFIED_BY.ID       = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_CREATED_BY.ID          = ' + @RELATED_TABLE + '.CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_MODIFIED_BY.ID         = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_ASSIGNED' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_ASSIGNED.ID            = ' + @RELATED_TABLE + '.ASSIGNED_USER_ID' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '  left outer join ASSIGNED_SETS' + @CRLF;
		set @COMMAND = @COMMAND + '               on ASSIGNED_SETS.ID             = ' + @RELATED_TABLE + '.ASSIGNED_SET_ID' + @CRLF;
		set @COMMAND = @COMMAND + '              and ASSIGNED_SETS.DELETED        = 0' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + ' where ' + @RELATED_TABLE + '.DELETED = 0' + @CRLF;

	set @RELATED_TABLE = 'SMS_MESSAGES_ARCHIVE';
	set @RELATED_DATABASE_DOT = @ARCHIVE_DATABASE_DOT;
	exec dbo.spSqlTableExists @EXISTS out, @RELATED_TABLE, @ARCHIVE_DATABASE;
	if @EXISTS = 0 begin -- then
		set @RELATED_DATABASE_DOT = '';
		set @RELATED_TABLE = 'SMS_MESSAGES';
	end -- if;
	set @COMMAND = @COMMAND + 'union all' + @CRLF;
	set @COMMAND = @COMMAND + 'select ' + @RELATED_TABLE + '.ID' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '     , 1                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , ARCHIVE_MODIFIED_BY.USER_NAME                                                 as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , dbo.fnFullName(ARCHIVE_MODIFIED_BY.FIRST_NAME, ARCHIVE_MODIFIED_BY.LAST_NAME) as ARCHIVE_BY_NAME' + @CRLF;
	end else begin
		set @COMMAND = @COMMAND + '     , 0                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as datetime        ) as ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as uniqueidentifier) as ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(60)    ) as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(200)   ) as ARCHIVE_BY_NAME' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.CREATED_BY       as CREATED_BY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_CREATED_BY.USER_NAME                                                as CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_MODIFIED_BY.USER_NAME                                               as MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID      as ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ID                    as ACTIVITY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''SmsMessages''                     as ACTIVITY_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME                  as ACTIVITY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID      as ACTIVITY_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_ID             as PARENT_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_TYPE           as PARENT_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_NAME              as PARENT_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.STATUS                as STATUS' + @CRLF;
	set @COMMAND = @COMMAND + '     , (case ' + @RELATED_TABLE + '.TYPE when N''inbound'' then N''Inbound'' else N''Outbound'' end) as DIRECTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START            as DATE_START' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START            as DATE_DUE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START            as DATE_MODIFIED' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_MODIFIED_UTC     as DATE_MODIFIED_UTC' + @CRLF;
	set @COMMAND = @COMMAND + '     , 0                                  as IS_OPEN' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.ID                           as TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.NAME                         as TEAM_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.ID                       as TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME                  as DESCRIPTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , TAG_SETS.TAG_SET_NAME' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST' + @CRLF;
	end else begin
		-- 04/27/2020 Paul.  Some views may not have the field, but we need to prevent invalid unions. 
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_LIST' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  from            ' + @RELATED_DATABASE_DOT + 'dbo.' + @RELATED_TABLE + ' ' + @RELATED_TABLE + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
	set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID      = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAMS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAMS.ID                 = ' + @RELATED_TABLE + '.TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAMS.DELETED            = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAM_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAM_SETS.ID             = ' + @RELATED_TABLE + '.TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAM_SETS.DELETED        = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TAG_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TAG_SETS.BEAN_ID         = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TAG_SETS.DELETED         = 0' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '  left outer join USERS                           ARCHIVE_MODIFIED_BY' + @CRLF;
		set @COMMAND = @COMMAND + '               on ARCHIVE_MODIFIED_BY.ID       = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_CREATED_BY.ID          = ' + @RELATED_TABLE + '.CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_MODIFIED_BY.ID         = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_ASSIGNED' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_ASSIGNED.ID            = ' + @RELATED_TABLE + '.ASSIGNED_USER_ID' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '  left outer join ASSIGNED_SETS' + @CRLF;
		set @COMMAND = @COMMAND + '               on ASSIGNED_SETS.ID             = ' + @RELATED_TABLE + '.ASSIGNED_SET_ID' + @CRLF;
		set @COMMAND = @COMMAND + '              and ASSIGNED_SETS.DELETED        = 0' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + ' where ' + @RELATED_TABLE + '.DELETED = 0' + @CRLF;

	set @RELATED_TABLE = 'TWITTER_MESSAGES_ARCHIVE';
	set @RELATED_DATABASE_DOT = @ARCHIVE_DATABASE_DOT;
	exec dbo.spSqlTableExists @EXISTS out, @RELATED_TABLE, @ARCHIVE_DATABASE;
	if @EXISTS = 0 begin -- then
		set @RELATED_DATABASE_DOT = '';
		set @RELATED_TABLE = 'TWITTER_MESSAGES';
	end -- if;
	set @COMMAND = @COMMAND + 'union all' + @CRLF;
	set @COMMAND = @COMMAND + 'select ' + @RELATED_TABLE + '.ID' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '     , 1                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , ARCHIVE_MODIFIED_BY.USER_NAME                                                 as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , dbo.fnFullName(ARCHIVE_MODIFIED_BY.FIRST_NAME, ARCHIVE_MODIFIED_BY.LAST_NAME) as ARCHIVE_BY_NAME' + @CRLF;
	end else begin
		set @COMMAND = @COMMAND + '     , 0                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as datetime        ) as ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as uniqueidentifier) as ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(60)    ) as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(200)   ) as ARCHIVE_BY_NAME' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.CREATED_BY       as CREATED_BY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_CREATED_BY.USER_NAME                                                as CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_MODIFIED_BY.USER_NAME                                               as MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID  as ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ID                as ACTIVITY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''TwitterMessages''                 as ACTIVITY_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME              as ACTIVITY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ASSIGNED_USER_ID  as ACTIVITY_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_ID         as PARENT_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_TYPE       as PARENT_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_NAME              as PARENT_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.STATUS            as STATUS' + @CRLF;
	set @COMMAND = @COMMAND + '     , (case ' + @RELATED_TABLE + '.TYPE when N''inbound'' then N''Inbound'' else N''Outbound'' end) as DIRECTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START        as DATE_START' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START        as DATE_DUE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_START        as DATE_MODIFIED' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_MODIFIED_UTC as DATE_MODIFIED_UTC' + @CRLF;
	set @COMMAND = @COMMAND + '     , 0                                  as IS_OPEN' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.ID                           as TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.NAME                         as TEAM_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.ID                       as TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DESCRIPTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , TAG_SETS.TAG_SET_NAME' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST' + @CRLF;
	end else begin
		-- 04/27/2020 Paul.  Some views may not have the field, but we need to prevent invalid unions. 
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_LIST' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  from            ' + @RELATED_DATABASE_DOT + 'dbo.' + @RELATED_TABLE + ' ' + @RELATED_TABLE + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
	set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID      = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAMS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAMS.ID                 = ' + @RELATED_TABLE + '.TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAMS.DELETED            = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAM_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAM_SETS.ID             = ' + @RELATED_TABLE + '.TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAM_SETS.DELETED        = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TAG_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TAG_SETS.BEAN_ID         = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TAG_SETS.DELETED         = 0' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '  left outer join USERS                           ARCHIVE_MODIFIED_BY' + @CRLF;
		set @COMMAND = @COMMAND + '               on ARCHIVE_MODIFIED_BY.ID       = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_CREATED_BY.ID          = ' + @RELATED_TABLE + '.CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_MODIFIED_BY.ID         = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_ASSIGNED' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_ASSIGNED.ID            = ' + @RELATED_TABLE + '.ASSIGNED_USER_ID' + @CRLF;
	exec dbo.spSqlTableColumnExists @EXISTS out, @RELATED_TABLE, 'ASSIGNED_SET_ID', @RELATED_DATABASE_DOT;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '  left outer join ASSIGNED_SETS' + @CRLF;
		set @COMMAND = @COMMAND + '               on ASSIGNED_SETS.ID             = ' + @RELATED_TABLE + '.ASSIGNED_SET_ID' + @CRLF;
		set @COMMAND = @COMMAND + '              and ASSIGNED_SETS.DELETED        = 0' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + ' where ' + @RELATED_TABLE + '.DELETED = 0' + @CRLF;

	set @RELATED_TABLE = 'CHAT_MESSAGES_ARCHIVE';
	set @RELATED_DATABASE_DOT = @ARCHIVE_DATABASE_DOT;
	exec dbo.spSqlTableExists @EXISTS out, @RELATED_TABLE, @ARCHIVE_DATABASE;
	if @EXISTS = 0 begin -- then
		set @RELATED_DATABASE_DOT = '';
		set @RELATED_TABLE = 'CHAT_MESSAGES';
	end -- if;
	set @COMMAND = @COMMAND + 'union all' + @CRLF;
	set @COMMAND = @COMMAND + 'select ' + @RELATED_TABLE + '.ID' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '     , 1                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , ARCHIVE_MODIFIED_BY.USER_NAME                                                 as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , dbo.fnFullName(ARCHIVE_MODIFIED_BY.FIRST_NAME, ARCHIVE_MODIFIED_BY.LAST_NAME) as ARCHIVE_BY_NAME' + @CRLF;
	end else begin
		set @COMMAND = @COMMAND + '     , 0                              as ARCHIVE_VIEW' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as datetime        ) as ARCHIVE_DATE_UTC' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as uniqueidentifier) as ARCHIVE_USER_ID' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(60)    ) as ARCHIVE_BY' + @CRLF;
		set @COMMAND = @COMMAND + '     , cast(null as nvarchar(200)   ) as ARCHIVE_BY_NAME' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.CREATED_BY       as CREATED_BY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_CREATED_BY.USER_NAME                                                as CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_MODIFIED_BY.USER_NAME                                               as MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , CHAT_CHANNELS.ASSIGNED_USER_ID     as ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.ID                   as ACTIVITY_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''ChatMessages''                    as ACTIVITY_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.NAME                 as ACTIVITY_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , CHAT_CHANNELS.ASSIGNED_USER_ID     as ACTIVITY_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_ID            as PARENT_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.PARENT_TYPE          as PARENT_TYPE' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_NAME              as PARENT_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , vwPARENTS.PARENT_ASSIGNED_USER_ID  as PARENT_ASSIGNED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , cast(null as nvarchar(25))         as STATUS' + @CRLF;
	set @COMMAND = @COMMAND + '     , N''none''                            as DIRECTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , cast(null as datetime)             as DATE_DUE' + @CRLF;
	set @COMMAND = @COMMAND + '     , cast(null as datetime)             as DATE_START' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_ENTERED         as DATE_MODIFIED' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DATE_MODIFIED_UTC    as DATE_MODIFIED_UTC' + @CRLF;
	set @COMMAND = @COMMAND + '     , 0                                  as IS_OPEN' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.ID                           as TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAMS.NAME                         as TEAM_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.ID                       as TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_NAME            as TEAM_SET_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , TEAM_SETS.TEAM_SET_LIST            as TEAM_SET_LIST' + @CRLF;
	set @COMMAND = @COMMAND + '     , USERS_ASSIGNED.USER_NAME           as ASSIGNED_TO' + @CRLF;
	set @COMMAND = @COMMAND + '     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) as ASSIGNED_TO_NAME' + @CRLF;
	set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.DESCRIPTION' + @CRLF;
	set @COMMAND = @COMMAND + '     , TAG_SETS.TAG_SET_NAME' + @CRLF;
	-- 12/19/2017 Paul.  CHAT_CHANNELS is not archived, so always check against current database. 
	exec dbo.spSqlTableColumnExists @EXISTS out, 'CHAT_CHANNELS', 'ASSIGNED_SET_ID', null;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST' + @CRLF;
	end else begin
		-- 04/27/2020 Paul.  Some views may not have the field, but we need to prevent invalid unions. 
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_ID'   + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_NAME' + @CRLF;
		set @COMMAND = @COMMAND + '     , null                            as ASSIGNED_SET_LIST' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  from            ' + @RELATED_DATABASE_DOT + 'dbo.' + @RELATED_TABLE + ' ' + @RELATED_TABLE + @CRLF;
	set @COMMAND = @COMMAND + '       inner join CHAT_CHANNELS' + @CRLF;
	set @COMMAND = @COMMAND + '               on CHAT_CHANNELS.ID         = ' + @RELATED_TABLE + '.CHAT_CHANNEL_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and CHAT_CHANNELS.DELETED    = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join vwPARENTS' + @CRLF;
	set @COMMAND = @COMMAND + '               on vwPARENTS.PARENT_ID      = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAMS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAMS.ID                 = CHAT_CHANNELS.TEAM_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAMS.DELETED            = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TEAM_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TEAM_SETS.ID             = CHAT_CHANNELS.TEAM_SET_ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TEAM_SETS.DELETED        = 0' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join TAG_SETS' + @CRLF;
	set @COMMAND = @COMMAND + '               on TAG_SETS.BEAN_ID         = ' + @RELATED_TABLE + '.ID' + @CRLF;
	set @COMMAND = @COMMAND + '              and TAG_SETS.DELETED         = 0' + @CRLF;
	if right(@RELATED_TABLE, 8) = '_ARCHIVE' begin -- then
		set @COMMAND = @COMMAND + '  left outer join USERS                           ARCHIVE_MODIFIED_BY' + @CRLF;
		set @COMMAND = @COMMAND + '               on ARCHIVE_MODIFIED_BY.ID       = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_CREATED_BY.ID          = ' + @RELATED_TABLE + '.CREATED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_MODIFIED_BY' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_MODIFIED_BY.ID         = ' + @RELATED_TABLE + '.MODIFIED_USER_ID' + @CRLF;
	set @COMMAND = @COMMAND + '  left outer join USERS                          USERS_ASSIGNED' + @CRLF;
	set @COMMAND = @COMMAND + '               on USERS_ASSIGNED.ID            = CHAT_CHANNELS.ASSIGNED_USER_ID' + @CRLF;
	-- 12/19/2017 Paul.  CHAT_CHANNELS is not archived, so always check against current database. 
	exec dbo.spSqlTableColumnExists @EXISTS out, 'CHAT_CHANNELS', 'ASSIGNED_SET_ID', null;
	if @EXISTS = 1 begin -- then
		set @COMMAND = @COMMAND + '  left outer join ASSIGNED_SETS' + @CRLF;
		set @COMMAND = @COMMAND + '               on ASSIGNED_SETS.ID             = CHAT_CHANNELS.ASSIGNED_SET_ID' + @CRLF;
		set @COMMAND = @COMMAND + '              and ASSIGNED_SETS.DELETED        = 0' + @CRLF;
	end -- if;
	set @COMMAND = @COMMAND + ' where ' + @RELATED_TABLE + '.DELETED = 0' + @CRLF;

	if len(@COMMAND) > 100 begin -- then
		if @TEST = 1 begin -- then
			set @COMMAND = @COMMAND + @CRLF;
			exec dbo.spSqlPrintByLine @COMMAND;
			--print @COMMAND;
		end else begin
			print substring(@COMMAND, 1, charindex(@CRLF, @COMMAND));
			--print @COMMAND + @CRLF;
			exec(@COMMAND);
		end -- if;

		set @COMMAND = 'Grant Select on dbo.' + @VIEW_NAME + ' to public' + @CRLF;
		if @TEST = 1 begin -- then
			set @COMMAND = @COMMAND + @CRLF;
			exec dbo.spSqlPrintByLine @COMMAND;
			--print @COMMAND;
		end else begin
			print @COMMAND + @CRLF;
			exec(@COMMAND);
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildArchiveActivityView to public;
GO

-- exec dbo.spSqlBuildArchiveActivityView null;
-- exec dbo.spSqlBuildArchiveActivityView 'SplendidCRM_Archive';

