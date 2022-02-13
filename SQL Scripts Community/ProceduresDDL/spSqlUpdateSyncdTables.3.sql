if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlUpdateSyncdTables' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlUpdateSyncdTables;
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
-- 06/13/2010 Paul.  Remove the spacers and increase the size of the table and column name. 
-- This should allow the procedure to run even with unspecified tables. 
-- 04/27/2014 Paul.  Simplified approach to enable/disable triggers. 
Create Procedure dbo.spSqlUpdateSyncdTables
as
  begin
	set nocount on
	print N'spSqlUpdateSyncdTables';

	declare @Command           nvarchar(4000);  -- varchar(max) on SQL 2005
	declare @TABLE_NAME        varchar(100);
	declare @COLUMN_NAME       varchar(100);
	declare @TEST              bit;
	declare @TIMEZONE_OFFSET   int;
	declare @ParmDefinition    nvarchar(100);
	declare @EmptyRows         int;
	set @TEST = 0;
	set @TIMEZONE_OFFSET = datediff(minute, getdate(), getutcdate());
	set @ParmDefinition = '@EmptyRowsOUT int output';
	
	-- 10/28/2009 Paul.  For all tables that have DATE_MODIFIED but don't have DATE_MODIFIED_UTC. 
	declare DATE_MODIFIED_UTC_CURSOR cursor for
	select TABLES.TABLE_NAME
	  from            INFORMATION_SCHEMA.TABLES   TABLES
	  left outer join INFORMATION_SCHEMA.COLUMNS  COLUMNS
	               on COLUMNS.TABLE_NAME        = TABLES.TABLE_NAME
	              and COLUMNS.COLUMN_NAME       = 'DATE_MODIFIED_UTC'
	 where TABLES.TABLE_TYPE = 'BASE TABLE'
	   and COLUMNS.TABLE_NAME is null
	--   and TABLES.TABLE_NAME not like '%_AUDIT'
	   and TABLES.TABLE_NAME not like '%_SYNC'
	   and TABLES.TABLE_NAME in (select TABLE_NAME
	                               from INFORMATION_SCHEMA.COLUMNS
	                              where COLUMN_NAME = 'DATE_MODIFIED'
	                            )
	 order by TABLES.TABLE_NAME;

	--declare TRIGGER_CURSOR cursor for
	--select TABLES.name
	--     , TRIGGERS.name
	--  from      sys.objects        TRIGGERS
	-- inner join sys.objects        TABLES
	--         on TABLES.object_id = TRIGGERS.parent_object_id
	-- where TRIGGERS.type = 'TR';

	declare UTC_UPDATE_CURSOR cursor for
	select TABLES.TABLE_NAME
	  from      INFORMATION_SCHEMA.TABLES   TABLES
	 inner join INFORMATION_SCHEMA.COLUMNS  COLUMNS
	         on COLUMNS.TABLE_NAME        = TABLES.TABLE_NAME
	        and COLUMNS.COLUMN_NAME       = 'DATE_MODIFIED_UTC'
	 where TABLES.TABLE_TYPE = 'BASE TABLE'
	 order by TABLES.TABLE_NAME;
	
	declare ROW_VERSION_CURSOR cursor for
	select TABLES.TABLE_NAME
	  from      INFORMATION_SCHEMA.TABLES   TABLES
	 inner join INFORMATION_SCHEMA.COLUMNS  COLUMNS
	         on COLUMNS.TABLE_NAME        = TABLES.TABLE_NAME
	        and COLUMNS.COLUMN_NAME       = 'ROW_VERSION'
	        and COLUMNS.DATA_TYPE         = 'timestamp'
	 where TABLES.TABLE_TYPE = 'BASE TABLE'
	 order by TABLES.TABLE_NAME;

	-- 11/02/2009 Paul.  Drop ROW_VERSION. Using UTC date is a cross-platform approach. 
	open ROW_VERSION_CURSOR;
	fetch next from ROW_VERSION_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @Command = 'alter table ' + upper(@TABLE_NAME) + ' drop column ROW_VERSION;';
		if @TEST = 0 begin -- then
			exec(@Command);
		end -- if;
		fetch next from ROW_VERSION_CURSOR into @TABLE_NAME;
	end -- while;
	close ROW_VERSION_CURSOR;
	deallocate ROW_VERSION_CURSOR;

	-- Disable all triggers.
	--open TRIGGER_CURSOR;
	--fetch next from TRIGGER_CURSOR into @TABLE_NAME, @COLUMN_NAME;
	--while @@FETCH_STATUS = 0 begin -- do
	--	set @Command = 'alter table ' + upper(@TABLE_NAME) + ' disable trigger ' +  @COLUMN_NAME + ';';
	--	if @TEST = 0 begin -- then
	--		exec(@Command);
	--	end -- if;
	--	fetch next from TRIGGER_CURSOR into @TABLE_NAME, @COLUMN_NAME;
	--end -- while;
	--close TRIGGER_CURSOR;
	
	-- 04/27/2014 Paul.  Simplified approach to enable/disable triggers. 
	disable trigger all on database;
	
	open DATE_MODIFIED_UTC_CURSOR;
	fetch next from DATE_MODIFIED_UTC_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- while
		set @Command = 'alter table ' + @TABLE_NAME + ' add DATE_MODIFIED_UTC datetime null default(getutcdate())';
		print @Command;
		if @TEST = 0 begin -- then
			exec(@Command);
		end -- if;
		set @Command = 'update ' + @TABLE_NAME 
		             + '   set DATE_MODIFIED_UTC = dateadd(minute, ' + cast(@TIMEZONE_OFFSET as varchar(10)) + ', DATE_MODIFIED)'
		             + ' where DATE_MODIFIED_UTC is null';
		print @Command;
		if @TEST = 0 begin -- then
			exec(@Command);
		end -- if;
		fetch next from DATE_MODIFIED_UTC_CURSOR into @TABLE_NAME;
	end -- while;
	close DATE_MODIFIED_UTC_CURSOR;
	deallocate DATE_MODIFIED_UTC_CURSOR;

	-- 11/02/2009 Paul.  DATE_MODIFIED_UTC cannot be NULL, so update any tables were it is NULL. 
	open UTC_UPDATE_CURSOR;
	fetch next from UTC_UPDATE_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- while
		set @Command = 'select @EmptyRowsOUT = count(*) from ' + @TABLE_NAME + ' where DATE_MODIFIED_UTC is null';
		exec sp_executesql @Command, @ParmDefinition, @EmptyRowsOUT = @EmptyRows output;
		if @EmptyRows > 0 begin -- then
			set @Command = 'update ' + @TABLE_NAME 
			             + '   set DATE_MODIFIED_UTC = dateadd(minute, ' + cast(@TIMEZONE_OFFSET as varchar(10)) + ', DATE_MODIFIED)'
			             + ' where DATE_MODIFIED_UTC is null';
			print @Command;
			if @TEST = 0 begin -- then
				exec(@Command);
			end -- if;
		end -- if;
		fetch next from UTC_UPDATE_CURSOR into @TABLE_NAME;
	end -- while;
	close UTC_UPDATE_CURSOR;
	deallocate UTC_UPDATE_CURSOR;

	-- Restore all triggers.
	--open TRIGGER_CURSOR;
	--fetch next from TRIGGER_CURSOR into @TABLE_NAME, @COLUMN_NAME;
	--while @@FETCH_STATUS = 0 begin -- do
	--	set @Command = 'alter table ' + upper(@TABLE_NAME) + ' enable trigger ' +  @COLUMN_NAME + ';';
	--	if @TEST = 0 begin -- then
	--		exec(@Command);
	--	end -- if;
	--	fetch next from TRIGGER_CURSOR into @TABLE_NAME, @COLUMN_NAME;
	--end -- while;
	--close TRIGGER_CURSOR;
	--deallocate TRIGGER_CURSOR;
	
	-- 04/27/2014 Paul.  Simplified approach to enable/disable triggers. 
	enable trigger all on database;

  end
GO


Grant Execute on dbo.spSqlUpdateSyncdTables to public;
GO

-- exec dbo.spSqlUpdateSyncdTables;
/*
select getdate()
     , getutcdate()
     , dateadd(minute, datediff(minute, getdate(), getutcdate()), getdate())
     , datediff(minute, getdate(), getutcdate())
*/


