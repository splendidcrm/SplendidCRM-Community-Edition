if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropAllAuditTriggers' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlDropAllAuditTriggers;
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
-- 08/20/2008 Paul.  Drop triggers for the cached tables. 
-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
-- This also fixes a problem for a customer with 100 custom fields. 
-- 07/25/2015 Paul.  Starting on 05/11/2014, we started dropping triggers in ~\Tables\_Update Sync Fields.5.sql
-- The problem is that vwSqlTablesCachedSystem may not exist on an old database and thereby will generate an error. 
Create Procedure dbo.spSqlDropAllAuditTriggers
as
  begin
	set nocount on

	-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
	declare @Command           varchar(max);
	declare @AUDIT_TABLE  varchar(90);
	declare @TABLE_NAME   varchar(80);
	declare @TRIGGER_NAME varchar(90);

	-- 07/25/2015 Paul.  Remove references to vwSql views as they may not have been created. 
	-- SplendidCRM has a unique signature of these triggers, so it should be safe. 
	declare TRIGGERS_CURSOR cursor for
	select name
	  from sys.triggers
	 where name like 'tr%_System'
	    or name like 'tr%_Ins_AUDIT'
	    or name like 'tr%_Upd_AUDIT'
	    or name like 'tr%_Del_AUDIT'
	    or name like 'tr%_Ins_WORK'
	 order by name;
	open TRIGGERS_CURSOR;
	fetch next from TRIGGERS_CURSOR into @TRIGGER_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @Command = 'Drop Trigger dbo.' + @TRIGGER_NAME;
		print @Command;
		exec(@Command);
		fetch next from TRIGGERS_CURSOR into @TRIGGER_NAME;
	end -- while;
	close TRIGGERS_CURSOR;
	deallocate TRIGGERS_CURSOR;

	/*
	declare TABLES_CURSOR cursor for
	select vwSqlTablesAudited.TABLE_NAME
	  from      vwSqlTablesAudited
	 inner join vwSqlTables
	         on vwSqlTables.TABLE_NAME = vwSqlTablesAudited.TABLE_NAME + '_AUDIT'
	order by vwSqlTablesAudited.TABLE_NAME;

	declare CACHE_CURSOR cursor for
	select TABLE_NAME
	  from vwSqlTablesCachedSystem
	union
	select TABLE_NAME
	  from vwSqlTablesCachedData
	 order by TABLE_NAME;
	
	open TABLES_CURSOR;
	fetch next from TABLES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @TRIGGER_NAME = 'tr' + @TABLE_NAME + '_Ins_AUDIT';
		if exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
			set @Command = 'Drop Trigger dbo.' + @TRIGGER_NAME;
			print @Command;
			exec(@Command);
		end -- if;

		set @TRIGGER_NAME = 'tr' + @TABLE_NAME + '_Upd_AUDIT';
		if exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
			set @Command = 'Drop Trigger dbo.' + @TRIGGER_NAME;
			print @Command;
			exec(@Command);
		end -- if;

		set @TRIGGER_NAME = 'tr' + @TABLE_NAME + '_Del_AUDIT';
		if exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
			set @Command = 'Drop Trigger dbo.' + @TRIGGER_NAME;
			print @Command;
			exec(@Command);
		end -- if;

		set @AUDIT_TABLE = @TABLE_NAME + '_AUDIT';
		set @TRIGGER_NAME = 'tr' + @AUDIT_TABLE + '_Ins_WORK';
		if exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
			set @Command = 'Drop Trigger dbo.' + @TRIGGER_NAME;
			print @Command;
			exec(@Command);
		end -- if;
		fetch next from TABLES_CURSOR into @TABLE_NAME;
	end -- while;
	close TABLES_CURSOR;
	deallocate TABLES_CURSOR;

	open CACHE_CURSOR;
	fetch next from CACHE_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @TRIGGER_NAME = 'tr' + @TABLE_NAME + '_System';
		if exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
			set @Command = 'Drop Trigger dbo.' + @TRIGGER_NAME;
			print @Command;
			exec(@Command);
		end -- if;
		fetch next from CACHE_CURSOR into @TABLE_NAME;
	end -- while;
	close CACHE_CURSOR;
	deallocate CACHE_CURSOR;
	*/
  end
GO


Grant Execute on dbo.spSqlDropAllAuditTriggers to public;
GO

-- exec dbo.spSqlDropAllAuditTriggers;


