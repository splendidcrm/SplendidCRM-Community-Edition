if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildArchiveTable' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildArchiveTable;
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
-- 02/08/2020 Paul.  Include Audit tables. 
Create Procedure dbo.spSqlBuildArchiveTable
	( @TABLE_NAME       nvarchar(80)
	, @ARCHIVE_DATABASE nvarchar(50)
	)
as
  begin
	set nocount on
	print 'spSqlBuildArchiveTable ' + @TABLE_NAME;

	declare @COMMAND              nvarchar(max);
	declare @CRLF                 nchar(2);
	declare @ARCHIVE_TABLE        nvarchar(90);
	declare @ARCHIVE_PK           nvarchar(90);
	declare @COLUMN_NAME          nvarchar(80);
	declare @COLUMN_TYPE          nvarchar(20);
	declare @COLUMN_MAX_LENGTH    int;
	declare @TEST                 bit;
	declare @SPLENDID_FIELDS      int;
	declare @EXISTS               bit;
	declare @ARCHIVE_DATABASE_DOT nvarchar(50);
	
	set @TEST = 0;
	set @SPLENDID_FIELDS = 0;
	set @CRLF = char(13) + char(10);
	set @ARCHIVE_TABLE = @TABLE_NAME + '_ARCHIVE';
	set @ARCHIVE_PK    = 'PKR_' + @TABLE_NAME;
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
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME and COLUMN_NAME = 'ID') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME and COLUMN_NAME = 'DELETED') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME and COLUMN_NAME = 'CREATED_BY') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME and COLUMN_NAME = 'DATE_ENTERED') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME and COLUMN_NAME = 'MODIFIED_USER_ID') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME and COLUMN_NAME = 'DATE_MODIFIED') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
	end -- if;

	if @SPLENDID_FIELDS = 6 begin -- then
		exec dbo.spSqlTableExists @EXISTS out, @ARCHIVE_TABLE, @ARCHIVE_DATABASE;
		if @EXISTS = 0 begin -- then
			declare TABLE_COLUMNS_CURSOR cursor for
			select ColumnName
			     , ColumnType
			  from vwSqlColumns
			 where ObjectName = @TABLE_NAME
			 order by colid;
		
			select @COLUMN_MAX_LENGTH = max(len(ColumnName)) + 1
			  from vwSqlColumns
			 where ObjectName = @TABLE_NAME;
			if @COLUMN_MAX_LENGTH < 20 begin -- then
				set @COLUMN_MAX_LENGTH = 20;
			end -- if;
		
			set @COMMAND = '';
			set @COMMAND = @COMMAND + 'Create Table ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + @CRLF;
			-- 02/08/2020 Paul.  Include Audit tables. 
			if right(@TABLE_NAME, 11) = '_CSTM_AUDIT' begin -- then
				set @COMMAND = @COMMAND + '	( AUDIT_ID'         + space(@COLUMN_MAX_LENGTH+1-len('AUDIT_ID'        )) + 'uniqueidentifier not null constraint ' + @ARCHIVE_PK + ' primary key' + @CRLF;
				set @COMMAND = @COMMAND + '	, ID_C'             + space(@COLUMN_MAX_LENGTH+1-len('ID_C'            )) + 'uniqueidentifier not null' + @CRLF;
			end else if right(@TABLE_NAME, 5) = '_CSTM' begin -- then
				set @COMMAND = @COMMAND + '	( ID_C'             + space(@COLUMN_MAX_LENGTH+1-len('ID_C'            )) + 'uniqueidentifier not null constraint ' + @ARCHIVE_PK + ' primary key' + @CRLF;
			end else if right(@TABLE_NAME, 6) = '_AUDIT' begin -- then
				set @COMMAND = @COMMAND + '	( ARCHIVE_DATE_UTC' + space(@COLUMN_MAX_LENGTH+1-len('ARCHIVE_DATE_UTC')) + 'datetime null' + @CRLF;
				set @COMMAND = @COMMAND + '	, ARCHIVE_USER_ID'  + space(@COLUMN_MAX_LENGTH+1-len('ARCHIVE_USER_ID' )) + 'uniqueidentifier null' + @CRLF;
				set @COMMAND = @COMMAND + '	, AUDIT_ID'         + space(@COLUMN_MAX_LENGTH+1-len('AUDIT_ID'        )) + 'uniqueidentifier not null constraint ' + @ARCHIVE_PK + ' primary key' + @CRLF;
				set @COMMAND = @COMMAND + '	, ID'               + space(@COLUMN_MAX_LENGTH+1-len('ID'              )) + 'uniqueidentifier not null' + @CRLF;
			end else begin
				set @COMMAND = @COMMAND + '	( ARCHIVE_DATE_UTC' + space(@COLUMN_MAX_LENGTH+1-len('ARCHIVE_DATE_UTC')) + 'datetime null' + @CRLF;
				set @COMMAND = @COMMAND + '	, ARCHIVE_USER_ID'  + space(@COLUMN_MAX_LENGTH+1-len('ARCHIVE_USER_ID' )) + 'uniqueidentifier null' + @CRLF;
				set @COMMAND = @COMMAND + '	, ID'               + space(@COLUMN_MAX_LENGTH+1-len('ID'              )) + 'uniqueidentifier not null constraint ' + @ARCHIVE_PK + ' primary key' + @CRLF;
			end -- if;
			open TABLE_COLUMNS_CURSOR;
			fetch next from TABLE_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
			while @@FETCH_STATUS = 0 begin -- while
				-- 02/08/2020 Paul.  Include Audit tables. 
				if @COLUMN_NAME not in ('ID', 'ID_C', 'AUDIT_ID') begin -- then
					set @COMMAND = @COMMAND + '	, ' + @COLUMN_NAME + space(@COLUMN_MAX_LENGTH+1-len(@COLUMN_NAME)) + @COLUMN_TYPE + space(18-len(@COLUMN_TYPE)) + ' null' + @CRLF;
				end -- if;
				fetch next from TABLE_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
			end -- while;
			close TABLE_COLUMNS_CURSOR;
			deallocate TABLE_COLUMNS_CURSOR;
			set @COMMAND = @COMMAND + '	)' + @CRLF;
			
			print 'Create Table ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + ';';
			if @TEST = 1 begin -- then
				print @COMMAND;
			end else begin
				exec(@COMMAND);
			end -- if;
		end else begin
			print 'Alter Table ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + ';';
			set @COMMAND = 'declare ARCHIVE_TABLE_COLUMNS_CURSOR cursor for
			select vwSqlColumns.ColumnName
			     , vwSqlColumns.ColumnType
			  from            vwSqlColumns
			  left outer join ' + @ARCHIVE_DATABASE_DOT + 'INFORMATION_SCHEMA.COLUMNS  vwSqlColumnsArchive
			               on vwSqlColumnsArchive.TABLE_NAME  = vwSqlColumns.ObjectName + ''_ARCHIVE''
			              and vwSqlColumnsArchive.COLUMN_NAME = vwSqlColumns.ColumnName
			 where vwSqlColumnsArchive.COLUMN_NAME is null
			   and vwSqlColumns.ObjectName = ''' + @TABLE_NAME + '''
			 order by vwSqlColumns.colid';
			exec sp_executesql @COMMAND;
	
			select @COLUMN_MAX_LENGTH = max(len(ColumnName)) + 1
			  from vwSqlColumns
			 where ObjectName = @TABLE_NAME;
			if @COLUMN_MAX_LENGTH < 20 begin -- then
				set @COLUMN_MAX_LENGTH = 20;
			end -- if;

			-- 02/08/2020 Paul.  Include Audit tables. 
			if right(@TABLE_NAME, 5) <> '_CSTM' or right(@TABLE_NAME, 11) = '_CSTM_AUDIT' begin -- then
				exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'ARCHIVE_DATE_UTC', @ARCHIVE_DATABASE;
				if @EXISTS = 0 begin -- then
					set @COMMAND = 'alter table ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + ' add ARCHIVE_DATE_UTC' + space(@COLUMN_MAX_LENGTH+1-len('ARCHIVE_DATE_UTC')) + ' datetime null' + @CRLF;
					print @COMMAND;
					if @TEST = 0 begin -- then
						exec(@COMMAND);
					end -- if;
				end -- if;
		
				exec dbo.spSqlTableColumnExists @EXISTS out, @ARCHIVE_TABLE, 'ARCHIVE_USER_ID', @ARCHIVE_DATABASE;
				if @EXISTS = 0 begin -- then
					set @COMMAND = 'alter table ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + ' add ARCHIVE_USER_ID' + space(@COLUMN_MAX_LENGTH+1-len('ARCHIVE_USER_ID')) + ' uniqueidentifier null' + @CRLF;
					print @COMMAND;
					if @TEST = 0 begin -- then
						exec(@COMMAND);
					end -- if;
				end -- if;
			end -- if;
	
			open ARCHIVE_TABLE_COLUMNS_CURSOR;
			fetch next from ARCHIVE_TABLE_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
			while @@FETCH_STATUS = 0 begin -- while
				set @COMMAND = 'alter table ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + ' add ' + @COLUMN_NAME + space(@COLUMN_MAX_LENGTH+1-len(@COLUMN_NAME)) + @COLUMN_TYPE + space(18-len(@COLUMN_TYPE)) + ' null' + @CRLF;
				print @COMMAND;
				if @TEST = 0 begin -- then
					exec(@COMMAND);
				end -- if;
				fetch next from ARCHIVE_TABLE_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
			end -- while;
			close ARCHIVE_TABLE_COLUMNS_CURSOR;
			deallocate ARCHIVE_TABLE_COLUMNS_CURSOR;
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildArchiveTable to public;
GO

/*
exec spSqlBuildArchiveTable 'ACCOUNTS', 'SplendidCRM_Archive';
exec spSqlBuildArchiveTable 'ACCOUNTS_CSTM', 'SplendidCRM_Archive';
exec spSqlBuildArchiveTable 'ACCOUNTS_AUDIT', 'SplendidCRM_Archive';
exec spSqlBuildArchiveTable 'ACCOUNTS_CSTM_AUDIT', 'SplendidCRM_Archive';
*/

