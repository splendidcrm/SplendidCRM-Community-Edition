if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropAllArchiveTables' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlDropAllArchiveTables;
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
Create Procedure dbo.spSqlDropAllArchiveTables
	( @ARCHIVE_DATABASE nvarchar(50) = null
	)
as
  begin
	set nocount on
	print 'spSqlDropAllArchiveTables';

	declare @COMMAND      nvarchar(max);
	declare @TABLE_NAME   nvarchar(80);
	declare @ARCHIVE_DATABASE_DOT nvarchar(50);
	if len(@ARCHIVE_DATABASE) > 0 begin -- then
		set @ARCHIVE_DATABASE_DOT = '[' + @ARCHIVE_DATABASE + '].';
	end else begin
		set @ARCHIVE_DATABASE_DOT = '';
	end -- if;

	set @COMMAND = 'declare ARCHIVE_TABLES_CURSOR cursor for
	select TABLE_NAME
	  from ' + @ARCHIVE_DATABASE_DOT + 'INFORMATION_SCHEMA.TABLES
	 where TABLE_NAME like ''%_ARCHIVE''
	   and TABLE_TYPE = ''BASE TABLE''
	order by TABLE_NAME';
print @COMMAND;
	exec sp_executesql @COMMAND;

	if exists(select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropAllArchiveViews' and ROUTINE_TYPE = 'PROCEDURE') begin -- then
		exec('dbo.spSqlDropAllArchiveViews');
	end -- if;
	if exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'MODULES_ARCHIVE_LOG') begin -- then
		exec('delete from MODULES_ARCHIVE_LOG');
	end -- if;
	
	open ARCHIVE_TABLES_CURSOR;
	fetch next from ARCHIVE_TABLES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @COMMAND = 'Drop Table ' + @ARCHIVE_DATABASE_DOT + 'dbo.' + @TABLE_NAME;
		print @COMMAND;
		exec(@COMMAND);
		fetch next from ARCHIVE_TABLES_CURSOR into @TABLE_NAME;
	end -- while;
	close ARCHIVE_TABLES_CURSOR;
	deallocate ARCHIVE_TABLES_CURSOR;
  end
GO


Grant Execute on dbo.spSqlDropAllArchiveTables to public;
GO

-- exec dbo.spSqlDropAllArchiveTables ;


