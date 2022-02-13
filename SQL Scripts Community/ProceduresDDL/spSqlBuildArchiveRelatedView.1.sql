if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildArchiveRelatedView' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildArchiveRelatedView;
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
Create Procedure dbo.spSqlBuildArchiveRelatedView
	( @MODULE_NAME      nvarchar(25)
	, @ARCHIVE_DATABASE nvarchar(50)
	)
as
  begin
	set nocount on
	print 'spSqlBuildArchiveRelatedView ' + @MODULE_NAME;
	
	declare @COMMAND              nvarchar(max);
	declare @CRLF                 nchar(2);
	declare @TABLE_NAME           nvarchar(80);
	declare @ARCHIVE_TABLE        nvarchar(90);
	declare @RELATED_TABLE        nvarchar(90);
	declare @LEFT_TABLE           nvarchar(90);
	declare @RIGHT_TABLE          nvarchar(90);
	declare @VIEW_NAME            nvarchar(90);
	declare @RELATED_VIEW         nvarchar(90);
	declare @SINGULAR_LEFT        nvarchar(80);
	declare @SINGULAR_RIGHT       nvarchar(80);
	declare @ARCHIVE_COLUMN       nvarchar(80);
	declare @TEST                 bit;
	declare @SPLENDID_FIELDS      int;
	declare @EXISTS               bit;
	declare @ARCHIVE_DATABASE_DOT nvarchar(50);

	set @TEST            = 0;
	set @SPLENDID_FIELDS = 0;
	select @TABLE_NAME = TABLE_NAME
	  from MODULES
	 where MODULE_NAME = @MODULE_NAME
	   and DELETED     = 0;
	set @CRLF            = char(13) + char(10);
	set @ARCHIVE_TABLE   = @TABLE_NAME + '_ARCHIVE';
	if len(@ARCHIVE_DATABASE) > 0 begin -- then
		set @ARCHIVE_DATABASE_DOT = '[' + @ARCHIVE_DATABASE + '].';
	end else begin
		set @ARCHIVE_DATABASE_DOT = '';
	end -- if;

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

	if @SPLENDID_FIELDS = 6 begin -- then
		exec dbo.spSqlTableExists @EXISTS out, @ARCHIVE_TABLE, @ARCHIVE_DATABASE;
		if @EXISTS = 1 begin -- then
			-- 12/08/2017 Paul.  Module TABLE_NAME may be invalid, so just to vwSqlTables to validate. 
			declare ARCHIVE_RELATED_CURSOR cursor for
			select vwSqlTables.TABLE_NAME                  as RELATED_TABLE
			     , vwMODULES_ARCHIVE_RELATED.TABLE_NAME    as LEFT_TABLE
			     , vwMODULES_ARCHIVE_RELATED.RELATED_TABLE as RIGHT_TABLE
			  from            vwMODULES_ARCHIVE_RELATED
			  left outer join vwSqlTables
			               on vwSqlTables.TABLE_NAME = vwMODULES_ARCHIVE_RELATED.TABLE_NAME    + '_' + vwMODULES_ARCHIVE_RELATED.RELATED_TABLE
			               or vwSqlTables.TABLE_NAME = vwMODULES_ARCHIVE_RELATED.RELATED_TABLE + '_' + vwMODULES_ARCHIVE_RELATED.TABLE_NAME
			               or vwSqlTables.TABLE_NAME = vwMODULES_ARCHIVE_RELATED.RELATED_TABLE + 'S_' + vwMODULES_ARCHIVE_RELATED.TABLE_NAME
			 where vwMODULES_ARCHIVE_RELATED.TABLE_NAME    = @TABLE_NAME
			   and vwMODULES_ARCHIVE_RELATED.RELATED_TABLE is not null
			 union all
			select 'PROSPECT_LISTS_PROSPECTS'
			     , 'PROSPECT_LISTS'                        as LEFT_TABLE
			     , vwSqlTables.TABLE_NAME                  as RIGHT_TABLE
			  from vwSqlTables
			 where vwSqlTables.TABLE_NAME = @TABLE_NAME
			   and vwSqlTables.TABLE_NAME in ('CONTACTS', 'LEADS', 'PROSPECTS')
			 order by 3;

			open ARCHIVE_RELATED_CURSOR;
			fetch next from ARCHIVE_RELATED_CURSOR into @RELATED_TABLE, @LEFT_TABLE, @RIGHT_TABLE;
			while @@FETCH_STATUS = 0 begin -- do
				--print @RELATED_TABLE + ' ' + @LEFT_TABLE + ' ' + @RIGHT_TABLE;
				if @RIGHT_TABLE = @TABLE_NAME or @RELATED_TABLE = 'PROSPECT_LISTS_PROSPECTS' begin -- then
					set @RIGHT_TABLE = @LEFT_TABLE;
					set @LEFT_TABLE  = @TABLE_NAME;
				end -- if;
				set @SINGULAR_LEFT  = dbo.fnSqlSingularName(@LEFT_TABLE );
				set @SINGULAR_RIGHT = dbo.fnSqlSingularName(@RIGHT_TABLE);
				if @RELATED_TABLE is null begin -- then
					set @RELATED_TABLE = @RIGHT_TABLE;
				end -- if;

				set @VIEW_NAME    = 'vw' + @LEFT_TABLE  + '_' + @RIGHT_TABLE + '_ARCHIVE';
				if exists (select * from vwSqlViews where VIEW_NAME = @VIEW_NAME) begin -- then
					set @COMMAND = 'Drop   View dbo.' + @VIEW_NAME;
					print @COMMAND;
					exec(@COMMAND);
				end -- if;
		
				declare ARCHIVE_RELATED_COLUMN_CURSOR cursor for
				select vwSqlColumns.ColumnName
				  from      vwSqlColumns
				 inner join vwSqlColumns                   vwSqlColumnsArchive
				         on vwSqlColumnsArchive.ObjectName = vwSqlColumns.ObjectName + '_ARCHIVE'
				        and vwSqlColumnsArchive.ColumnName = vwSqlColumns.ColumnName
				 where vwSqlColumns.ObjectName = 'vw' + @RIGHT_TABLE
				 order by vwSqlColumns.colid;
	
				set @COMMAND = '';
				set @RELATED_VIEW = 'vw' + @RIGHT_TABLE;
				set @COMMAND = @COMMAND + 'Create View dbo.' + @VIEW_NAME + @CRLF;
				set @COMMAND = @COMMAND + 'as' + @CRLF;
				set @COMMAND = @COMMAND + 'select 0                              as ARCHIVE_VIEW'     + @CRLF;
				set @COMMAND = @COMMAND + '     , cast(null as datetime        ) as ARCHIVE_DATE_UTC' + @CRLF;
				set @COMMAND = @COMMAND + '     , cast(null as uniqueidentifier) as ARCHIVE_USER_ID'  + @CRLF;
				set @COMMAND = @COMMAND + '     , cast(null as nvarchar(60)    ) as ARCHIVE_BY'       + @CRLF;
				set @COMMAND = @COMMAND + '     , cast(null as nvarchar(200)   ) as ARCHIVE_BY_NAME'  + @CRLF;
				if exists (select * from vwSqlViews where VIEW_NAME = 'vw' + @RIGHT_TABLE + '_ARCHIVE') begin -- then
					open ARCHIVE_RELATED_COLUMN_CURSOR;
					fetch next from ARCHIVE_RELATED_COLUMN_CURSOR into @ARCHIVE_COLUMN;
					while @@FETCH_STATUS = 0 begin -- do
						set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.' + @ARCHIVE_COLUMN + @CRLF;
						fetch next from ARCHIVE_RELATED_COLUMN_CURSOR into @ARCHIVE_COLUMN;
					end -- while;
					close ARCHIVE_RELATED_COLUMN_CURSOR;
				end else begin
					set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.*' + @CRLF;
				end -- if;

				if exists (select * from vwSqlViews where VIEW_NAME = 'vw' + @RIGHT_TABLE + '_ARCHIVE') begin -- then
					if not exists(select * from vwSqlColumns inner join vwSqlColumns vwSqlColumnsArchive on vwSqlColumnsArchive.ObjectName = vwSqlColumns.ObjectName + '_ARCHIVE' and vwSqlColumnsArchive.ColumnName = vwSqlColumns.ColumnName where vwSqlColumns.ObjectName = 'vw' + @RIGHT_TABLE and vwSqlColumns.ColumnName = @SINGULAR_LEFT + '_ID') begin -- then
						set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE + '.ID               as ' + @SINGULAR_LEFT + '_ID' + @CRLF;
					end -- if;
					if not exists(select * from vwSqlColumns inner join vwSqlColumns vwSqlColumnsArchive on vwSqlColumnsArchive.ObjectName = vwSqlColumns.ObjectName + '_ARCHIVE' and vwSqlColumnsArchive.ColumnName = vwSqlColumns.ColumnName where vwSqlColumns.ObjectName = 'vw' + @RIGHT_TABLE and vwSqlColumns.ColumnName = @SINGULAR_LEFT + '_NAME') begin -- then
						if @LEFT_TABLE = 'CONTACTS' or @LEFT_TABLE = 'LEADS' or @LEFT_TABLE = 'PROSPECTS' begin -- then
							set @COMMAND = @COMMAND + '     , dbo.fnFullName(' + @ARCHIVE_TABLE + '.FIRST_NAME, ' + @ARCHIVE_TABLE + '.LAST_NAME) as ' + @SINGULAR_LEFT + '_NAME' + @CRLF;
						end else if @LEFT_TABLE = 'PAYMENTS' begin -- then
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.PAYMENT_NUM      as ' + @SINGULAR_LEFT + '_NAME' + @CRLF;
						end else if @LEFT_TABLE = 'DOCUMENTS' begin -- then
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.DOCUMENT_NAME    as ' + @SINGULAR_LEFT + '_NAME' + @CRLF;
						end else begin
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.NAME             as ' + @SINGULAR_LEFT + '_NAME' + @CRLF;
						end -- if;
					end -- if;
					if not exists(select * from vwSqlColumns inner join vwSqlColumns vwSqlColumnsArchive on vwSqlColumnsArchive.ObjectName = vwSqlColumns.ObjectName + '_ARCHIVE' and vwSqlColumnsArchive.ColumnName = vwSqlColumns.ColumnName where vwSqlColumns.ObjectName = 'vw' + @RIGHT_TABLE and vwSqlColumns.ColumnName = @SINGULAR_LEFT + '_ASSIGNED_USER_ID') begin -- then
						exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'ASSIGNED_USER_ID', @ARCHIVE_DATABASE;
						if @EXISTS = 1 begin -- then
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.ASSIGNED_USER_ID as ' + @SINGULAR_LEFT + '_ASSIGNED_USER_ID' + @CRLF;
						end -- if;
					end -- if;
					if not exists(select * from vwSqlColumns inner join vwSqlColumns vwSqlColumnsArchive on vwSqlColumnsArchive.ObjectName = vwSqlColumns.ObjectName + '_ARCHIVE' and vwSqlColumnsArchive.ColumnName = vwSqlColumns.ColumnName where vwSqlColumns.ObjectName = 'vw' + @RIGHT_TABLE and vwSqlColumns.ColumnName = @SINGULAR_LEFT + '_ASSIGNED_SET_ID') begin -- then
						exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'ASSIGNED_SET_ID', @ARCHIVE_DATABASE;
						if @EXISTS = 1 begin -- then
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.ASSIGNED_SET_ID as ' + @SINGULAR_LEFT + '_ASSIGNED_SET_ID' + @CRLF;
						end -- if;
					end -- if;
				end else begin
					if not exists(select * from vwSqlColumns where ObjectName = @RELATED_VIEW and ColumnName = @SINGULAR_LEFT + '_ID') begin -- then
						set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE + '.ID               as ' + @SINGULAR_LEFT + '_ID' + @CRLF;
					end -- if;
					if not exists(select * from vwSqlColumns where ObjectName = @RELATED_VIEW and ColumnName = @SINGULAR_LEFT + '_NAME') begin -- then
						if @LEFT_TABLE = 'CONTACTS' or @LEFT_TABLE = 'LEADS' or @LEFT_TABLE = 'PROSPECTS' begin -- then
							set @COMMAND = @COMMAND + '     , dbo.fnFullName(' + @ARCHIVE_TABLE + '.FIRST_NAME, ' + @ARCHIVE_TABLE + '.LAST_NAME) as ' + @SINGULAR_LEFT + '_NAME' + @CRLF;
						end else if @LEFT_TABLE = 'PAYMENTS' begin -- then
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.PAYMENT_NUM      as ' + @SINGULAR_LEFT + '_NAME' + @CRLF;
						end else if @LEFT_TABLE = 'DOCUMENTS' begin -- then
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.DOCUMENT_NAME    as ' + @SINGULAR_LEFT + '_NAME' + @CRLF;
						end else begin
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.NAME             as ' + @SINGULAR_LEFT + '_NAME' + @CRLF;
						end -- if;
					end -- if;
					if not exists(select * from vwSqlColumns where ObjectName = @RELATED_VIEW and ColumnName = @SINGULAR_LEFT + '_ASSIGNED_USER_ID') begin -- then
						exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'ASSIGNED_USER_ID', @ARCHIVE_DATABASE;
						if @EXISTS = 1 begin -- then
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.ASSIGNED_USER_ID as ' + @SINGULAR_LEFT + '_ASSIGNED_USER_ID' + @CRLF;
						end -- if;
					end -- if;
					if not exists(select * from vwSqlColumns where ObjectName = @RELATED_VIEW and ColumnName = @SINGULAR_LEFT + '_ASSIGNED_SET_ID') begin -- then
						exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'ASSIGNED_SET_ID', @ARCHIVE_DATABASE;
						if @EXISTS = 1 begin -- then
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.ASSIGNED_SET_ID as ' + @SINGULAR_LEFT + '_ASSIGNED_SET_ID' + @CRLF;
						end -- if;
					end -- if;
				end -- if;
				if not exists(select * from vwSqlColumns where ObjectName = @RELATED_VIEW and ColumnName = @SINGULAR_RIGHT + '_ID') begin -- then
					set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.ID               as ' + @SINGULAR_RIGHT + '_ID' + @CRLF;
				end -- if;
				if @RIGHT_TABLE = 'THREADS' begin -- then
					set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.TITLE          as ' + @SINGULAR_RIGHT + '_TITLE' + @CRLF;
				end else if @RIGHT_TABLE = 'PAYMENTS' begin -- then
					set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.PAYMENT_NUM    as ' + @SINGULAR_RIGHT + '_NAME' + @CRLF;
				end else if @RIGHT_TABLE = 'DOCUMENTS' begin -- then
					set @COMMAND = @COMMAND + '     , DOCUMENT_REVISIONS.ID                as SELECTED_DOCUMENT_REVISION_ID' + @CRLF;
					set @COMMAND = @COMMAND + '     , DOCUMENT_REVISIONS.REVISION          as SELECTED_REVISION' + @CRLF;
				end else if not exists(select * from vwSqlColumns where ObjectName = @RELATED_VIEW and ColumnName = @SINGULAR_RIGHT + '_NAME') begin -- then
					set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.NAME             as ' + @SINGULAR_RIGHT + '_NAME' + @CRLF;
				end -- if;
				set @COMMAND = @COMMAND + '  from            ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + ' ' + @ARCHIVE_TABLE + @CRLF;
				if @RELATED_TABLE = @RIGHT_TABLE begin -- then
					set @COMMAND = @COMMAND + '       inner join ' + @RELATED_VIEW + '' + @CRLF;
					set @COMMAND = @COMMAND + '               on ' + @RELATED_VIEW + '.' + @SINGULAR_LEFT + '_ID = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
				end else begin
					set @COMMAND = @COMMAND + '       inner join ' + @RELATED_TABLE + @CRLF;
					if @RELATED_TABLE = 'PROSPECT_LISTS_PROSPECTS' begin -- then
						set @COMMAND = @COMMAND + '               on ' + @RELATED_TABLE + '.RELATED_ID = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '               on ' + @RELATED_TABLE + '.' + @SINGULAR_LEFT + '_ID = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '              and ' + @RELATED_TABLE + '.DELETED    = 0' + @CRLF;
					set @COMMAND = @COMMAND + '       inner join ' + @RELATED_VIEW + '' + @CRLF;
					set @COMMAND = @COMMAND + '               on ' + @RELATED_VIEW + '.ID          = ' + @RELATED_TABLE + '.' + @SINGULAR_RIGHT + '_ID' + @CRLF;
					if @RIGHT_TABLE = 'DOCUMENTS' begin -- then
						set @COMMAND = @COMMAND + '  left outer join DOCUMENT_REVISIONS' + @CRLF;
						set @COMMAND = @COMMAND + '               on DOCUMENT_REVISIONS.ID           = ' + @RELATED_TABLE + '.DOCUMENT_REVISION_ID' + @CRLF;
						set @COMMAND = @COMMAND + '              and DOCUMENT_REVISIONS.DELETED      = 0' + @CRLF;
					end -- if;
				end -- if;
				set @COMMAND = @COMMAND + ' where ' + @ARCHIVE_TABLE + '.DELETED = 0' + @CRLF;
				if exists (select * from vwSqlViews where VIEW_NAME = 'vw' + @RIGHT_TABLE + '_ARCHIVE') begin -- then
					set @LEFT_TABLE   = @TABLE_NAME;
					set @RELATED_VIEW = 'vw' + @RIGHT_TABLE + '_ARCHIVE';
					set @COMMAND = @COMMAND + 'union all' + @CRLF;
					set @COMMAND = @COMMAND + 'select 1    as ARCHIVE_VIEW' + @CRLF;
					set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.ARCHIVE_DATE_UTC' + @CRLF;
					set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.ARCHIVE_USER_ID'  + @CRLF;
					set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.ARCHIVE_BY'       + @CRLF;
					set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.ARCHIVE_BY_NAME'  + @CRLF;
					open ARCHIVE_RELATED_COLUMN_CURSOR;
					fetch next from ARCHIVE_RELATED_COLUMN_CURSOR into @ARCHIVE_COLUMN;
					while @@FETCH_STATUS = 0 begin -- do
						-- 12/19/2017 Paul.  We need to make sure to use the relationship table and not the view value as the view value may make a failed join to the base table. 
						if @ARCHIVE_COLUMN = @SINGULAR_LEFT + '_ID' and @RELATED_TABLE <> @RIGHT_TABLE begin -- then
							set @COMMAND = @COMMAND + '     , ' + @RELATED_TABLE + '.' + @ARCHIVE_COLUMN + @CRLF;
						end else begin
							set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.' + @ARCHIVE_COLUMN + @CRLF;
						end -- if;
						fetch next from ARCHIVE_RELATED_COLUMN_CURSOR into @ARCHIVE_COLUMN;
					end -- while;
					close ARCHIVE_RELATED_COLUMN_CURSOR;
					if not exists(select * from vwSqlColumns inner join vwSqlColumns vwSqlColumnsArchive on vwSqlColumnsArchive.ObjectName = vwSqlColumns.ObjectName + '_ARCHIVE' and vwSqlColumnsArchive.ColumnName = vwSqlColumns.ColumnName where vwSqlColumns.ObjectName = 'vw' + @RIGHT_TABLE and vwSqlColumns.ColumnName = @SINGULAR_LEFT + '_ID') begin -- then
						set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE + '.ID               as ' + @SINGULAR_LEFT + '_ID' + @CRLF;
					end -- if;
					if not exists(select * from vwSqlColumns inner join vwSqlColumns vwSqlColumnsArchive on vwSqlColumnsArchive.ObjectName = vwSqlColumns.ObjectName + '_ARCHIVE' and vwSqlColumnsArchive.ColumnName = vwSqlColumns.ColumnName where vwSqlColumns.ObjectName = 'vw' + @RIGHT_TABLE and vwSqlColumns.ColumnName = @SINGULAR_LEFT + '_NAME') begin -- then
						if @LEFT_TABLE = 'CONTACTS' or @LEFT_TABLE = 'LEADS' or @LEFT_TABLE = 'PROSPECTS' begin -- then
							set @COMMAND = @COMMAND + '     , dbo.fnFullName(' + @ARCHIVE_TABLE + '.FIRST_NAME, ' + @ARCHIVE_TABLE + '.LAST_NAME) as ' + @SINGULAR_LEFT + '_NAME' + @CRLF;
						end else if @LEFT_TABLE = 'PAYMENTS' begin -- then
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.PAYMENT_NUM      as ' + @SINGULAR_LEFT + '_NAME' + @CRLF;
						end else if @LEFT_TABLE = 'DOCUMENTS' begin -- then
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.DOCUMENT_NAME    as ' + @SINGULAR_LEFT + '_NAME' + @CRLF;
						end else begin
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.NAME             as ' + @SINGULAR_LEFT + '_NAME' + @CRLF;
						end -- if;
					end -- if;
					if not exists(select * from vwSqlColumns inner join vwSqlColumns vwSqlColumnsArchive on vwSqlColumnsArchive.ObjectName = vwSqlColumns.ObjectName + '_ARCHIVE' and vwSqlColumnsArchive.ColumnName = vwSqlColumns.ColumnName where vwSqlColumns.ObjectName = 'vw' + @RIGHT_TABLE and vwSqlColumns.ColumnName = @SINGULAR_LEFT + '_ASSIGNED_USER_ID') begin -- then
						exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'ASSIGNED_USER_ID', @ARCHIVE_DATABASE;
						if @EXISTS = 1 begin -- then
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.ASSIGNED_USER_ID as ' + @SINGULAR_LEFT + '_ASSIGNED_USER_ID' + @CRLF;
						end -- if;
					end -- if;
					if not exists(select * from vwSqlColumns inner join vwSqlColumns vwSqlColumnsArchive on vwSqlColumnsArchive.ObjectName = vwSqlColumns.ObjectName + '_ARCHIVE' and vwSqlColumnsArchive.ColumnName = vwSqlColumns.ColumnName where vwSqlColumns.ObjectName = 'vw' + @RIGHT_TABLE and vwSqlColumns.ColumnName = @SINGULAR_LEFT + '_ASSIGNED_SET_ID') begin -- then
						exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'ASSIGNED_SET_ID', @ARCHIVE_DATABASE;
						if @EXISTS = 1 begin -- then
							set @COMMAND = @COMMAND + '     , ' + @ARCHIVE_TABLE   + '.ASSIGNED_SET_ID as ' + @SINGULAR_LEFT + '_ASSIGNED_SET_ID' + @CRLF;
						end -- if;
					end -- if;
					if not exists(select * from vwSqlColumns where ObjectName = @RELATED_VIEW and ColumnName = @SINGULAR_RIGHT + '_ID') begin -- then
						set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.ID               as ' + @SINGULAR_RIGHT + '_ID' + @CRLF;
					end -- if;
					if @RIGHT_TABLE = 'THREADS' begin -- then
						set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.TITLE          as ' + @SINGULAR_RIGHT + '_TITLE' + @CRLF;
					end else if @RIGHT_TABLE = 'PAYMENTS' begin -- then
						set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.PAYMENT_NUM    as ' + @SINGULAR_RIGHT + '_NAME' + @CRLF;
					end else if @RIGHT_TABLE = 'DOCUMENTS' begin -- then
						set @COMMAND = @COMMAND + '     , DOCUMENT_REVISIONS.ID                as SELECTED_DOCUMENT_REVISION_ID' + @CRLF;
						set @COMMAND = @COMMAND + '     , DOCUMENT_REVISIONS.REVISION          as SELECTED_REVISION' + @CRLF;
					end else if not exists(select * from vwSqlColumns where ObjectName = @RELATED_VIEW and ColumnName = @SINGULAR_RIGHT + '_NAME') begin -- then
						set @COMMAND = @COMMAND + '     , ' + @RELATED_VIEW + '.NAME             as ' + @SINGULAR_RIGHT + '_NAME' + @CRLF;
					end -- if;
					set @COMMAND = @COMMAND + '  from            ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + ' ' + @ARCHIVE_TABLE + @CRLF;
					if @RELATED_TABLE = @RIGHT_TABLE begin -- then
						set @COMMAND = @COMMAND + '       inner join ' + @RELATED_VIEW + '' + @CRLF;
						set @COMMAND = @COMMAND + '               on ' + @RELATED_VIEW + '.' + @SINGULAR_LEFT + '_ID = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
					end else begin
						set @COMMAND = @COMMAND + '       inner join ' + @RELATED_TABLE + @CRLF;
						if @RELATED_TABLE = 'PROSPECT_LISTS_PROSPECTS' begin -- then
							set @COMMAND = @COMMAND + '               on ' + @RELATED_TABLE + '.RELATED_ID = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
						end else begin
							set @COMMAND = @COMMAND + '               on ' + @RELATED_TABLE + '.' + @SINGULAR_LEFT + '_ID = ' + @ARCHIVE_TABLE + '.ID' + @CRLF;
						end -- if;
						set @COMMAND = @COMMAND + '              and ' + @RELATED_TABLE + '.DELETED    = 0' + @CRLF;
						set @COMMAND = @COMMAND + '       inner join ' + @RELATED_VIEW + '' + @CRLF;
						set @COMMAND = @COMMAND + '               on ' + @RELATED_VIEW + '.ID          = ' + @RELATED_TABLE + '.' + @SINGULAR_RIGHT + '_ID' + @CRLF;
						if @RIGHT_TABLE = 'DOCUMENTS' begin -- then
							set @COMMAND = @COMMAND + '  left outer join DOCUMENT_REVISIONS' + @CRLF;
							set @COMMAND = @COMMAND + '               on DOCUMENT_REVISIONS.ID           = ' + @RELATED_TABLE + '.DOCUMENT_REVISION_ID' + @CRLF;
							set @COMMAND = @COMMAND + '              and DOCUMENT_REVISIONS.DELETED      = 0' + @CRLF;
						end -- if;
					end -- if;
					set @COMMAND = @COMMAND + ' where ' + @ARCHIVE_TABLE + '.DELETED = 0' + @CRLF;
				end -- if;
				deallocate ARCHIVE_RELATED_COLUMN_CURSOR;

				if @TEST = 1 begin -- then
					print @COMMAND + @CRLF;
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
				fetch next from ARCHIVE_RELATED_CURSOR into @RELATED_TABLE, @LEFT_TABLE, @RIGHT_TABLE;
			end -- while;
			close ARCHIVE_RELATED_CURSOR;
			deallocate ARCHIVE_RELATED_CURSOR;
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildArchiveRelatedView to public;
GO

-- exec dbo.spSqlBuildArchiveRelatedView 'Accounts', null;

