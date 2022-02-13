if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildArchiveIndexes' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildArchiveIndexes;
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
-- 01/04/2020 Paul.  Watch for unsupported indexes. 
Create Procedure dbo.spSqlBuildArchiveIndexes
	( @TABLE_NAME       nvarchar(80)
	, @ARCHIVE_DATABASE nvarchar(50)
	)
as
  begin
	set nocount on
	print 'spSqlBuildArchiveIndexes ' + @TABLE_NAME;

	declare @COMMAND              nvarchar(max);
	declare @CRLF                 char(2);
	declare @ARCHIVE_TABLE        nvarchar(90);
	declare @OBJECT_ID            int;
	declare @INDEX_NAME           nvarchar(100);
	declare @ARCHIVE_INDEX_NAME   nvarchar(100);
	declare @COLUMN_NAME          nvarchar(90);
	declare @IS_DESCENDING_KEY    bit;
	declare @IS_INCLUDED_COLUMN   bit;
	declare @INDEX_COLUMNS        nvarchar(max);
	declare @INCLUDE_COLUMNS      nvarchar(max);
	declare @INDEX_MAX_LENGTH     int;
	declare @TEST                 bit;
	declare @EXISTS               bit;
	declare @ARCHIVE_DATABASE_DOT nvarchar(50);
	
	set @TEST = 0;
	set @CRLF = char(13) + char(10);
	set @ARCHIVE_TABLE = @TABLE_NAME + '_ARCHIVE';
	if len(@ARCHIVE_DATABASE) > 0 begin -- then
		set @ARCHIVE_DATABASE_DOT = '[' + @ARCHIVE_DATABASE + '].';
	end else begin
		set @ARCHIVE_DATABASE_DOT = '';
	end -- if;

	exec dbo.spSqlTableExists @EXISTS out, @ARCHIVE_TABLE, @ARCHIVE_DATABASE;
	if @EXISTS = 1 begin -- then
		-- https://www.mssqltips.com/sqlservertip/3441/script-out-all-sql-server-indexes-in-a-database-using-tsql/
		declare ARCHIVE_INDEXES_CURSOR cursor for
		select object_id
		     , name
		  from sys.indexes
		 where object_id            = object_id(@TABLE_NAME)
		   and type                 > 0
		   and is_primary_key       = 0
		   and is_unique_constraint = 0
		 order by name;

		select @INDEX_MAX_LENGTH = max(len(name)) + 1
		  from sys.indexes
		 where object_id            = object_id(@TABLE_NAME)
		   and type                 > 0
		   and is_primary_key       = 0
		   and is_unique_constraint = 0;
		
		open ARCHIVE_INDEXES_CURSOR;
		fetch next from ARCHIVE_INDEXES_CURSOR into @OBJECT_ID, @INDEX_NAME;
		while @@FETCH_STATUS = 0 begin -- do
			-- 02/08/2020 Paul.  The AUDIT_VERSION field (timestamp) is not archived, so exclude from index. timestamp cannot be inserted. 
			set @COMMAND = 'declare ARCHIVE_INDEX_COLUMNS_CURSOR cursor for 
			select col.name
			     , ixc.is_descending_key
			     , ixc.is_included_column
			  from      sys.indexes         ix
			 inner join sys.index_columns   ixc
			         on ixc.object_id     = ix.object_id
			        and ixc.index_id      = ix.index_id
			 inner join sys.columns         col
			         on col.object_id     = ixc.object_id
			        and col.column_id     = ixc.column_id
			 where ix.type                 > 0
			   and ix.is_primary_key       = 0
			   and ix.is_unique_constraint = 0
			   and ix.object_id            = ' + cast(@OBJECT_ID as varchar(10)) + '
			   and ix.name                 = ''' + @INDEX_NAME + '''
			   and ix.name                 like ''IDX_%''
			   and col.name                <> ''AUDIT_VERSION''
			 order by ixc.index_column_id';
			exec sp_executesql @COMMAND;
 
			set @INDEX_COLUMNS   = '';
			set @INCLUDE_COLUMNS = '';
			open ARCHIVE_INDEX_COLUMNS_CURSOR 
			fetch next from ARCHIVE_INDEX_COLUMNS_CURSOR into @COLUMN_NAME, @IS_DESCENDING_KEY, @IS_INCLUDED_COLUMN;
 			while @@FETCH_STATUS = 0 begin -- do
				if @IS_INCLUDED_COLUMN = 0 begin -- then
					if len(@INDEX_COLUMNS) > 0 begin -- then
						set @INDEX_COLUMNS = @INDEX_COLUMNS + ', ';
					end -- if;
					set @INDEX_COLUMNS = @INDEX_COLUMNS + @COLUMN_NAME;
					if @IS_DESCENDING_KEY = 1 begin -- then
						set @INDEX_COLUMNS = @INDEX_COLUMNS + ' desc';
					end -- if;
				end else begin
					if len(@INCLUDE_COLUMNS) > 0 begin -- then
						set @INCLUDE_COLUMNS = @INCLUDE_COLUMNS + ', ';
					end -- if;
					set @INCLUDE_COLUMNS = @INCLUDE_COLUMNS + @COLUMN_NAME;
				end -- if;
				fetch next from ARCHIVE_INDEX_COLUMNS_CURSOR into @COLUMN_NAME, @IS_DESCENDING_KEY, @IS_INCLUDED_COLUMN;
			end -- while;
			close ARCHIVE_INDEX_COLUMNS_CURSOR
			deallocate ARCHIVE_INDEX_COLUMNS_CURSOR

			-- 01/04/2020 Paul.  Watch for unsupported indexes. 
			if len(@INDEX_COLUMNS) > 0 begin -- then
				set @ARCHIVE_INDEX_NAME = 'IDXR_' + substring(@INDEX_NAME, 5, len(@INDEX_NAME) - 4);
				exec dbo.spSqlTableIndexExists @EXISTS out, @ARCHIVE_TABLE, @ARCHIVE_INDEX_NAME, @ARCHIVE_DATABASE;
				if @EXISTS = 0 begin -- then
					set @COMMAND = 'Create Index ' + @ARCHIVE_INDEX_NAME + space(@INDEX_MAX_LENGTH - len(@INDEX_NAME)) + ' on ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @ARCHIVE_TABLE + ' (' + @INDEX_COLUMNS + ')';
					if len(@INCLUDE_COLUMNS) > 0 begin -- then
						set @COMMAND = @COMMAND + ' include (' + @INCLUDE_COLUMNS + ')';
					end -- if;
					if @TEST = 1 begin -- then
						print @COMMAND;
					end else begin
						print @COMMAND;
						exec(@COMMAND);
					end -- if;
				end else begin
					print '    ' + @ARCHIVE_INDEX_NAME + ' already exists';
				end -- if;
			end -- if;
			fetch next from ARCHIVE_INDEXES_CURSOR into @OBJECT_ID, @INDEX_NAME;
		end -- while;
		close ARCHIVE_INDEXES_CURSOR;
		deallocate ARCHIVE_INDEXES_CURSOR;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildArchiveIndexes to public;
GO

-- exec dbo.spSqlBuildArchiveIndexes 'OPPORTUNITIES', 'SplendidCRM_Archive';

