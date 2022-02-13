if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlRecoverArchiveData' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlRecoverArchiveData;
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
-- 02/17/2018 Paul.  This is an internal procedure so we do not need to limit to 8000 chars. 
-- 02/08/2020 Paul.  Include Audit tables. 
Create Procedure dbo.spSqlRecoverArchiveData
	( @MODIFIED_USER_ID  uniqueidentifier
	, @TABLE_NAME        nvarchar(80)
	, @ID_LIST           nvarchar(max)
	, @PARENT_TABLE      nvarchar(80)
	, @PARENT_KEY        nvarchar(30)
	, @RIGHT_TABLE       nvarchar(80)
	, @ARCHIVE_DATABASE  nvarchar(50)
	)
as
  begin
	set nocount on

	declare @Command              nvarchar(max);
	declare @ID                   uniqueidentifier;
	declare @ID_VALUES            nvarchar(max);
	declare @CRLF                 nchar(2);
	declare @ARCHIVE_TABLE        nvarchar(90);
	declare @TRIGGER_NAME         nvarchar(90);
	declare @COLUMN_NAME          nvarchar(80);
	declare @COLUMN_TYPE          nvarchar(20);
	declare @PRIMARY_KEY          nvarchar(10);
	declare @LEFT_TABLE           nvarchar(90);
	declare @RELATED_TABLE        nvarchar(90);
	declare @SINGULAR_LEFT_KEY    nvarchar(80);
	declare @SINGULAR_RIGHT_KEY   nvarchar(80);
	declare @CurrentPosR          int;
	declare @NextPosR             int;
	declare @TEST                 bit;
	declare @SPLENDID_FIELDS      int;
	declare @EXISTS               bit;
	declare @ARCHIVE_DATABASE_DOT nvarchar(50);

	set @TEST            = 0;
	set @SPLENDID_FIELDS = 0;
	set @PRIMARY_KEY     = 'ID';
	-- 02/08/2020 Paul.  Include Audit tables. 
	if right(@TABLE_NAME, 5) = '_CSTM' or right(@TABLE_NAME, 11) = '_CSTM_AUDIT' begin -- then
		set @PRIMARY_KEY = 'ID_C';
	end -- if;
	set @ARCHIVE_TABLE = @TABLE_NAME + '_ARCHIVE';
	set @LEFT_TABLE    = @TABLE_NAME;
	if @RIGHT_TABLE is not null and @LEFT_TABLE in ('CALLS', 'MEETINGS', 'EMAILS') begin -- then
		set @RELATED_TABLE      = @LEFT_TABLE + '_' + @RIGHT_TABLE;
		set @SINGULAR_LEFT_KEY  = dbo.fnSqlSingularName(@LEFT_TABLE ) + '_ID';
		set @SINGULAR_RIGHT_KEY = dbo.fnSqlSingularName(@RIGHT_TABLE) + '_ID';
	end -- if;
	if len(@ARCHIVE_DATABASE) > 0 begin -- then
		set @ARCHIVE_DATABASE_DOT = '[' + @ARCHIVE_DATABASE + '].';
	end else begin
		set @ARCHIVE_DATABASE_DOT = '';
	end -- if;

	-- 02/08/2020 Paul.  Include Audit tables. 
	if right(@TABLE_NAME, 5) = '_CSTM' or right(@TABLE_NAME, 11) = '_CSTM_AUDIT' begin -- then
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME and COLUMN_NAME = 'ID_C') begin -- then
			set @SPLENDID_FIELDS = 6;
		end -- if;
	end else begin
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

	set @ID_VALUES = '';
	set @CurrentPosR = 1;
	while @CurrentPosR <= len(@ID_LIST) begin -- do
		set @NextPosR = charindex(',', @ID_LIST,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@ID_LIST) + 1;
		end -- if;
		set @ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
		if len(@ID_VALUES) > 0 begin -- then
			set @ID_VALUES = @ID_VALUES + ', ';
		end -- if;
		set @ID_VALUES = @ID_VALUES + '''' + cast(@ID as char(36)) + '''';
		set @CurrentPosR = @NextPosR+1;
	end -- while;
	if len(@ID_VALUES) = 0 begin -- then
		raiserror(N'List of IDs is empty.', 16, 1);
	end else if @SPLENDID_FIELDS = 6 begin -- then
		exec dbo.spSqlTableExists @EXISTS out, @ARCHIVE_TABLE, @ARCHIVE_DATABASE;
		if @EXISTS = 1 begin -- then
			set @CRLF = char(13) + char(10);
			-- 06/26/2018 Paul.  We need to use a command so that we can compare to the table in an archive database. 
			set @Command = 'declare ARCHIVE_COLUMNS_CURSOR cursor for
			select vwSqlColumns.ColumnName
			     , vwSqlColumns.ColumnType
			  from            vwSqlColumns
			  left outer join ' + @ARCHIVE_DATABASE_DOT + 'INFORMATION_SCHEMA.COLUMNS  vwSqlColumnsArchive
			               on vwSqlColumnsArchive.TABLE_NAME  = vwSqlColumns.ObjectName + ''_ARCHIVE''
			              and vwSqlColumnsArchive.COLUMN_NAME = vwSqlColumns.ColumnName
			 where vwSqlColumns.ObjectName = ''' + @TABLE_NAME + '''
			 order by vwSqlColumns.colid';
			-- 08/08/2018 Paul.  Add missing execute. 
			exec sp_executesql @Command;
	
			set @Command = '';
			-- 11/17/2017 Paul.  When recovering data, use the DATE_MODIFIED_UTC field to mark the restore. 
			-- We will not change the modified user at this time. 
			set @Command = @Command + 'insert into dbo.' + @TABLE_NAME + @CRLF;
			set @Command = @Command + '	( ' + @PRIMARY_KEY + @CRLF;
			if @PRIMARY_KEY <> 'ID_C' begin -- then
				set @Command = @Command + '	, DATE_MODIFIED_UTC' + @CRLF;
			end -- if;
			--set @Command = @Command + '	, MODIFIED_USER_ID' + @CRLF;
			open ARCHIVE_COLUMNS_CURSOR;
			fetch next from ARCHIVE_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
			while @@FETCH_STATUS = 0 begin -- while
				if @COLUMN_NAME <> @PRIMARY_KEY and @COLUMN_NAME <> 'DATE_MODIFIED_UTC' begin -- then
					set @Command = @Command + '	, ' + @COLUMN_NAME + @CRLF;
				end -- if;
				fetch next from ARCHIVE_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
			end -- while;
			close ARCHIVE_COLUMNS_CURSOR;
			set @Command = @Command + '	)' + @CRLF;
			set @Command = @Command + 'select ' + @PRIMARY_KEY + @CRLF;
			if @PRIMARY_KEY <> 'ID_C' begin -- then
				set @Command = @Command + '	, getutcdate()' + @CRLF;
			end -- if;
			--if @MODIFIED_USER_ID is not null begin -- then
			--	set @Command = @Command + '	, ''' + cast(@MODIFIED_USER_ID as char(36)) + '''' + @CRLF;
			--end else begin
			--	set @Command = @Command + '	, null' + @CRLF;
			--end -- if;

			open ARCHIVE_COLUMNS_CURSOR;
			fetch next from ARCHIVE_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
			while @@FETCH_STATUS = 0 begin -- while
				if @COLUMN_NAME <> @PRIMARY_KEY and @COLUMN_NAME <> 'DATE_MODIFIED_UTC' begin -- then
					set @Command = @Command + '	, ' + @COLUMN_NAME + @CRLF;
				end -- if;
				fetch next from ARCHIVE_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
			end -- while;
			close ARCHIVE_COLUMNS_CURSOR;
			deallocate ARCHIVE_COLUMNS_CURSOR;

			set @Command = @Command + '  from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + ' ' + @ARCHIVE_TABLE + @CRLF;
			if @PARENT_KEY is null begin -- then
				set @Command = @Command + ' where ' + @PRIMARY_KEY + ' in (' + @ID_VALUES  + ')' + @CRLF;
			end else begin
				if @PARENT_TABLE is null or @PARENT_TABLE = @TABLE_NAME begin -- then
					set @Command = @Command + ' where ' + @PARENT_KEY + ' in (' + @ID_VALUES  + ')' + @CRLF;
				end else begin
					set @Command = @Command + ' where ' + @PRIMARY_KEY + ' in (select ID from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @PARENT_TABLE + '_ARCHIVE' + ' where ' + @PARENT_KEY + ' in (' + @ID_VALUES  + '))' + @CRLF;
				end -- if;
				if exists(select * from vwSqlTables where TABLE_NAME = @RELATED_TABLE) begin -- then
					set @Command = @Command + '    or ' + @PRIMARY_KEY + ' in (select ' + @SINGULAR_LEFT_KEY + ' from ' + @RELATED_TABLE + ' where DELETED = 0 and ' + @SINGULAR_RIGHT_KEY + ' in (' + @ID_VALUES  + '))' + @CRLF;
				end -- if;
			end -- if;
			if @TEST = 1 begin -- then
				print @Command + @CRLF;
			end else begin
				--print substring(@Command, 1, charindex(@CRLF, @Command));
				--exec dbo.spSqlPrintByLine @Command;
				--print(@Command + ';');
				exec(@Command);
			end -- if;
			set @Command = '';
			set @Command = @Command + 'delete from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + @CRLF;
			if @PARENT_KEY is null begin -- then
				set @Command = @Command + ' where ' + @PRIMARY_KEY + ' in (' + @ID_VALUES  + ')' + @CRLF;
			end else begin
				if @PARENT_TABLE is null or @PARENT_TABLE = @TABLE_NAME begin -- then
					set @Command = @Command + ' where ' + @PARENT_KEY + ' in (' + @ID_VALUES  + ')' + @CRLF;
				end else begin
					set @Command = @Command + ' where ' + @PRIMARY_KEY + ' in (select ID from ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @PARENT_TABLE + '_ARCHIVE' + ' where ' + @PARENT_KEY + ' in (' + @ID_VALUES  + '))' + @CRLF;
				end -- if;
				if exists(select * from vwSqlTables where TABLE_NAME = @RELATED_TABLE) begin -- then
					set @Command = @Command + '    or ' + @PRIMARY_KEY + ' in (select ' + @SINGULAR_LEFT_KEY + ' from ' + @RELATED_TABLE + ' where DELETED = 0 and ' + @SINGULAR_RIGHT_KEY + ' in (' + @ID_VALUES  + '))' + @CRLF;
				end -- if;
			end -- if;
			if @TEST = 1 begin -- then
				print @Command + @CRLF;
			end else begin
				--print substring(@Command, 1, charindex(@CRLF, @Command));
				--exec dbo.spSqlPrintByLine @Command;
				--print(@Command + ';');
				exec(@Command);
			end -- if;
		end else begin
			set @Command = @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + N' does not exist.';
			raiserror(@Command, 16, 1);
		end -- if;
	end else begin
		set @Command = @TABLE_NAME + N' is not a table valid for archive.';
		raiserror(@Command, 16, 1);
	end -- if;
  end
GO


Grant Execute on dbo.spSqlRecoverArchiveData to public;
GO

/*
declare @ID_LIST varchar(8000);
set @ID_LIST = '27667C9D-5B60-403C-B95E-42DF8758E38F, 27667C9D-5B60-403C-B95E-42DF8758E38E';
exec dbo.spSqlRecoverArchiveData 'CONTACTS', @ID_LIST;
exec dbo.spSqlRecoverArchiveData 'CONTACTS_CSTM', @ID_LIST;
*/

