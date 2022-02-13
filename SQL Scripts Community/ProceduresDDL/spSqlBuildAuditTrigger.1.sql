if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildAuditTrigger' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildAuditTrigger;
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
-- 04/10/2008 Paul.  sp_getbindtoken may not be accessible in a hosted environment. 
-- Wrap sp_getbindtoken in a procedure that can be bypassed.
-- The EXECUTE permission was denied on the object 'sp_getbindtoken', database 'mssqlsystemresource', 
-- 07/26/2008 Paul.  Add AUDIT_ACTION to speed workflow processing. 
-- 12/03/2008 Paul.  AUDIT_PARENT_ID is needed to roll-up events within a transaction. 
-- 12/04/2008 Paul.  We don't need the insert trigger on the CSTM tables. 
-- 01/09/2009 Paul.  spSqlGetTransactionToken should be used instead of sp_getbindtoken. 
-- 09/20/2009 Paul.  Use a unique name for the cursor to prevent a collision with another procedure. 
-- 01/20/2010 Paul.  Insert CREATED_BY and MODIFIED_USER_ID to simplify tracking of who performed the action. 
-- 06/13/2010 Paul.  We need to prevent from adding auditing to non-SplendidCRM tables, so check for the base fields. 
-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
-- This also fixes a problem for a customer with 100 custom fields. 
Create Procedure dbo.spSqlBuildAuditTrigger(@TABLE_NAME varchar(80))
as
  begin
	set nocount on
	
	-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
	declare @Command           varchar(max);
	declare @CRLF         char(2);
	declare @AUDIT_TABLE  varchar(90);
	declare @TRIGGER_NAME varchar(90);
	declare @COLUMN_NAME  varchar(80);
	declare @COLUMN_TYPE  varchar(20);
	declare @PRIMARY_KEY  varchar(10);
	declare @TEST         bit;
	declare @SPLENDID_FIELDS   int;

	set @TEST = 0;
	set @SPLENDID_FIELDS = 0;
	set @PRIMARY_KEY = 'ID';
	if right(@TABLE_NAME, 5) = '_CSTM' begin -- then
		set @PRIMARY_KEY = 'ID_C';
	end -- if;
	set @AUDIT_TABLE = @TABLE_NAME + '_AUDIT';

	-- 06/30/2011 Paul.  Custom tables were being excluded from the audit. 
	if right(@TABLE_NAME, 5) = '_CSTM' begin -- then
		-- 06/30/2011 Paul.  A custom table will only have an ID_C field, so if found then allow to continue. 
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME and COLUMN_NAME = 'ID_C') begin -- then
			set @SPLENDID_FIELDS = 6;
		end -- if;
	end else begin
		-- 06/13/2010 Paul.  We need to prevent from adding auditing to non-SplendidCRM tables, so check for the base fields. 
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'ID') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'DELETED') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'CREATED_BY') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'DATE_ENTERED') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'MODIFIED_USER_ID') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'DATE_MODIFIED') begin -- then
			set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
		end -- if;
	end -- if;

	if @SPLENDID_FIELDS = 6 begin -- then
		if exists (select * from vwSqlTables where TABLE_NAME = @AUDIT_TABLE) begin -- then
			set @CRLF = char(13) + char(10);
			declare TRIGGER_COLUMNS_CURSOR cursor for
			select vwSqlColumns.ColumnName
			     , vwSqlColumns.ColumnType
			  from       vwSqlColumns
			  inner join vwSqlColumns                   vwSqlColumnsAudit
			          on vwSqlColumnsAudit.ObjectName = vwSqlColumns.ObjectName + '_AUDIT'
			         and vwSqlColumnsAudit.ColumnName = vwSqlColumns.ColumnName
			 where vwSqlColumns.ObjectName = @TABLE_NAME
			 order by vwSqlColumns.colid;
	
			-- 12/29/2007 Paul.  Creating the audit record on insert will duplicate the data, with little benefit. 
			-- By skipping this trigger, data imports will be significantly faster. 
			-- 12/29/2007 Paul.  Actually, we will need the insert record for workflow tracking. 
			set @TRIGGER_NAME = 'tr' + @TABLE_NAME + '_Ins_AUDIT';
			if exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
				set @Command = 'Drop   Trigger dbo.' + @TRIGGER_NAME;
				if @TEST = 0 begin -- then
					print @Command;
					exec(@Command);
				end -- if;
			end -- if;
	
			-- 12/04/2008 Paul.  We don't need the insert trigger on the CSTM tables. 
			-- We already handle the issue in the workflow code, but lets reduce our events. 
			if right(@TABLE_NAME, 5) <> '_CSTM' begin -- then
				if not exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
					set @Command = '';
					set @Command = @Command + 'Create Trigger dbo.' + @TRIGGER_NAME + ' on dbo.' + @TABLE_NAME + @CRLF;
					set @Command = @Command + 'for insert' + @CRLF;
					set @Command = @Command + 'as' + @CRLF;
					set @Command = @Command + '  begin' + @CRLF;
					set @Command = @Command + '	declare @BIND_TOKEN varchar(255);' + @CRLF;
					set @Command = @Command + '	exec spSqlGetTransactionToken @BIND_TOKEN out;' + @CRLF;
					set @Command = @Command + '	insert into dbo.' + @AUDIT_TABLE + @CRLF;
					set @Command = @Command + '	     ( AUDIT_ID'      + @CRLF;
					set @Command = @Command + '	     , AUDIT_ACTION'  + @CRLF;
					set @Command = @Command + '	     , AUDIT_DATE'    + @CRLF;
					set @Command = @Command + '	     , AUDIT_COLUMNS' + @CRLF;
					set @Command = @Command + '	     , AUDIT_TOKEN'   + @CRLF;
					open TRIGGER_COLUMNS_CURSOR;
					fetch next from TRIGGER_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
					while @@FETCH_STATUS = 0 begin -- while
						--Cannot use text, ntext, or image columns in the 'inserted' and 'deleted' tables.
						--if @COLUMN_TYPE <> 'text' and @COLUMN_TYPE <> 'ntext' and @COLUMN_TYPE <> 'image' begin -- then
							set @Command = @Command + '	     , ' + @COLUMN_NAME + @CRLF;
						--end -- if;
						fetch next from TRIGGER_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
					end -- while;
					close TRIGGER_COLUMNS_CURSOR
					set @Command = @Command + '	     )' + @CRLF;
					set @Command = @Command + '	select newid()'           + @CRLF;
					set @Command = @Command + '	     , 0  -- insert'      + @CRLF;
					set @Command = @Command + '	     , getdate()'         + @CRLF;
					set @Command = @Command + '	     , columns_updated()' + @CRLF;
					set @Command = @Command + '	     , @BIND_TOKEN'       + @CRLF;
					
					open TRIGGER_COLUMNS_CURSOR;
					fetch next from TRIGGER_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
					while @@FETCH_STATUS = 0 begin -- while
						--Cannot use text, ntext, or image columns in the 'inserted' and 'deleted' tables.
						--if @COLUMN_TYPE <> 'text' and @COLUMN_TYPE <> 'ntext' and @COLUMN_TYPE <> 'image' begin -- then
							set @Command = @Command + '	     , ' + @TABLE_NAME + '.' + @COLUMN_NAME + @CRLF;
						--end -- if;
						fetch next from TRIGGER_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
					end -- while;
					close TRIGGER_COLUMNS_CURSOR;
					set @Command = @Command + '	  from       inserted' + @CRLF;
					set @Command = @Command + '	  inner join ' + @TABLE_NAME + @CRLF;
					set @Command = @Command + '	          on ' + @TABLE_NAME + '.' + @PRIMARY_KEY + ' = inserted.' + @PRIMARY_KEY + ';' + @CRLF;
					set @Command = @Command + '  end' + @CRLF;
					if @TEST = 1 begin -- then
						print @Command + @CRLF;
					end else begin
						print substring(@Command, 1, charindex(@CRLF, @Command));
						exec(@Command);
					end -- if;
				end -- if;
			end -- if;
	
			set @TRIGGER_NAME = 'tr' + @TABLE_NAME + '_Upd_AUDIT';
			if exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
				set @Command = 'Drop   Trigger dbo.' + @TRIGGER_NAME;
				if @TEST = 0 begin -- then
					print @Command;
					exec(@Command);
				end -- if;
			end -- if;
	
			if not exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
				set @Command = '';
				set @Command = @Command + 'Create Trigger dbo.' + @TRIGGER_NAME + ' on dbo.' + @TABLE_NAME + @CRLF;
				set @Command = @Command + 'for update' + @CRLF;
				set @Command = @Command + 'as' + @CRLF;
				set @Command = @Command + '  begin' + @CRLF;
				set @Command = @Command + '	declare @BIND_TOKEN varchar(255);' + @CRLF;
				-- 01/09/2009 Paul.  spSqlGetTransactionToken should be used instead of sp_getbindtoken. 
				set @Command = @Command + '	exec spSqlGetTransactionToken @BIND_TOKEN out;' + @CRLF;
				set @Command = @Command + '	insert into dbo.' + @AUDIT_TABLE + @CRLF;
				set @Command = @Command + '	     ( AUDIT_ID'      + @CRLF;
				set @Command = @Command + '	     , AUDIT_ACTION'  + @CRLF;
				set @Command = @Command + '	     , AUDIT_DATE'    + @CRLF;
				set @Command = @Command + '	     , AUDIT_COLUMNS' + @CRLF;
				set @Command = @Command + '	     , AUDIT_TOKEN'   + @CRLF;
				open TRIGGER_COLUMNS_CURSOR;
				fetch next from TRIGGER_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
				while @@FETCH_STATUS = 0 begin -- while
					--Cannot use text, ntext, or image columns in the 'inserted' and 'deleted' tables.
					--if @COLUMN_TYPE <> 'text' and @COLUMN_TYPE <> 'ntext' and @COLUMN_TYPE <> 'image' begin -- then
						set @Command = @Command + '	     , ' + @COLUMN_NAME + @CRLF;
					--end -- if;
					fetch next from TRIGGER_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
				end -- while;
				close TRIGGER_COLUMNS_CURSOR;
				set @Command = @Command + '	     )' + @CRLF;
				set @Command = @Command + '	select newid()'           + @CRLF;
				-- 12/03/2008 Paul.  We need to make sure that we treat the delete flag as a delete event. 
				if right(@TABLE_NAME, 5) <> '_CSTM' begin -- then
					set @Command = @Command + '	     , (case inserted.DELETED when 1 then -1 else 1 end) -- updated'      + @CRLF;
				end else begin
					set @Command = @Command + '	     , 1 -- updated'      + @CRLF;
				end -- if;
				set @Command = @Command + '	     , getdate()'         + @CRLF;
				set @Command = @Command + '	     , columns_updated()' + @CRLF;
				set @Command = @Command + '	     , @BIND_TOKEN'       + @CRLF;
				
				open TRIGGER_COLUMNS_CURSOR;
				fetch next from TRIGGER_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
				while @@FETCH_STATUS = 0 begin -- while
					--Cannot use text, ntext, or image columns in the 'inserted' and 'deleted' tables.
					--if @COLUMN_TYPE <> 'text' and @COLUMN_TYPE <> 'ntext' and @COLUMN_TYPE <> 'image' begin -- then
						set @Command = @Command + '	     , ' + @TABLE_NAME + '.' + @COLUMN_NAME + @CRLF;
					--end -- if;
					fetch next from TRIGGER_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
				end -- while;
				close TRIGGER_COLUMNS_CURSOR;
				set @Command = @Command + '	  from       inserted' + @CRLF;
				set @Command = @Command + '	  inner join ' + @TABLE_NAME + @CRLF;
				set @Command = @Command + '	          on ' + @TABLE_NAME + '.' + @PRIMARY_KEY + ' = inserted.' + @PRIMARY_KEY + ';' + @CRLF;
				set @Command = @Command + '  end' + @CRLF;
				if @TEST = 1 begin -- then
					print @Command + @CRLF;
				end else begin
					print substring(@Command, 1, charindex(@CRLF, @Command));
					exec(@Command);
				end -- if;
			end -- if;
	
			-- 12/29/2007 Paul.  Records are not deleted, they are marked as deleted, so the delete trigger will rarely fire. 
			-- We may want to enable it some day. 
			/*
			set @TRIGGER_NAME = 'tr' + @TABLE_NAME + '_Del_AUDIT';
			if exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
				set @Command = 'Drop   Trigger dbo.' + @TRIGGER_NAME;
				if @TEST = 0 begin -- then
					print @Command;
					exec(@Command);
				end -- if;
			end -- if;
	
			if not exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
				set @Command = ''
				set @Command = @Command + 'Create Trigger dbo.' + @TRIGGER_NAME + ' on dbo.' + @TABLE_NAME + @CRLF;
				set @Command = @Command + 'for delete' + @CRLF;
				set @Command = @Command + 'as' + @CRLF;
				set @Command = @Command + '  begin' + @CRLF;
				-- 01/09/2009 Paul.  spSqlGetTransactionToken should be used instead of sp_getbindtoken. 
				set @Command = @Command + '	declare @BIND_TOKEN varchar(255);' + @CRLF;
				set @Command = @Command + '	exec spSqlGetTransactionToken @BIND_TOKEN out;' + @CRLF;
				set @Command = @Command + '	insert into dbo.' + @AUDIT_TABLE + @CRLF;
				set @Command = @Command + '	     ( AUDIT_ID'     + @CRLF;
				set @Command = @Command + '	     , AUDIT_ACTION' + @CRLF;
				set @Command = @Command + '	     , AUDIT_DATE'   + @CRLF;
				set @Command = @Command + '	     , AUDIT_TOKEN'  + @CRLF;
				open TRIGGER_COLUMNS_CURSOR;
				fetch next from TRIGGER_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
				while @@FETCH_STATUS = 0 begin -- while
					--Cannot use text, ntext, or image columns in the 'inserted' and 'deleted' tables.
					if @COLUMN_TYPE <> 'text' and @COLUMN_TYPE <> 'ntext' and @COLUMN_TYPE <> 'image' begin -- then
						set @Command = @Command + '	     , ' + @COLUMN_NAME + @CRLF;
					end -- if;
					fetch next from TRIGGER_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
				end -- while;
				close TRIGGER_COLUMNS_CURSOR;
				set @Command = @Command + '	     )' + @CRLF;
				set @Command = @Command + '	select newid()'       + @CRLF;
				set @Command = @Command + '	     , -1  -- delete' + @CRLF;
				set @Command = @Command + '	     , getdate()'     + @CRLF;
				set @Command = @Command + '	     , @BIND_TOKEN'   + @CRLF;
				
				open TRIGGER_COLUMNS_CURSOR;
				fetch next from TRIGGER_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
				while @@FETCH_STATUS = 0 begin -- while
					--Cannot use text, ntext, or image columns in the 'inserted' and 'deleted' tables.
					if @COLUMN_TYPE <> 'text' and @COLUMN_TYPE <> 'ntext' and @COLUMN_TYPE <> 'image' begin -- then
						set @Command = @Command + '	     , ' + @COLUMN_NAME + @CRLF;
					end -- if;
					fetch next from TRIGGER_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
				end -- while;
				close TRIGGER_COLUMNS_CURSOR;
				set @Command = @Command + '	  from deleted;' + @CRLF;
				set @Command = @Command + '  end' + @CRLF;
				if @TEST = 1 begin -- then
					print @Command + @CRLF;
				end else begin
					print substring(@Command, 1, charindex(@CRLF, @Command));
					exec(@Command);
				end -- if;
			end -- if;
			*/
			deallocate TRIGGER_COLUMNS_CURSOR;
	
			if right(@TABLE_NAME, 5) <> '_CSTM' begin -- then
				set @TRIGGER_NAME = 'tr' + @AUDIT_TABLE + '_Ins_WORK';
				if exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
					set @Command = 'Drop   Trigger dbo.' + @TRIGGER_NAME;
					if @TEST = 0 begin -- then
						print @Command;
						exec(@Command);
					end -- if;
				end -- if;
		
				if not exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
					-- 07/26/2008 Paul.  Add AUDIT_ACTION to speed workflow processing. 
					-- 12/03/2008 Paul.  AUDIT_PARENT_ID is needed to roll-up events within a transaction. 
					-- 01/20/2010 Paul.  Insert CREATED_BY and MODIFIED_USER_ID to simplify tracking of who performed the action. 
					-- This primarily to allow AUDIT_EVENTS entries to contain the who information. 
					set @Command = '';
					set @Command = @Command + 'Create Trigger dbo.' + @TRIGGER_NAME + ' on dbo.' + @AUDIT_TABLE + @CRLF;
					set @Command = @Command + 'for insert' + @CRLF;
					set @Command = @Command + 'as' + @CRLF;
					set @Command = @Command + '  begin' + @CRLF;
					set @Command = @Command + '	insert into dbo.WORKFLOW_EVENTS' + @CRLF;
					set @Command = @Command + '	     ( ID'              + @CRLF;
					set @Command = @Command + '	     , DATE_ENTERED'    + @CRLF;
					set @Command = @Command + '	     , CREATED_BY'      + @CRLF;
					set @Command = @Command + '	     , MODIFIED_USER_ID'+ @CRLF;
					set @Command = @Command + '	     , AUDIT_ID'        + @CRLF;
					set @Command = @Command + '	     , AUDIT_TABLE'     + @CRLF;
					set @Command = @Command + '	     , AUDIT_TOKEN'     + @CRLF;
					set @Command = @Command + '	     , AUDIT_ACTION'    + @CRLF;
					set @Command = @Command + '	     , AUDIT_PARENT_ID' + @CRLF;
					set @Command = @Command + '	     )' + @CRLF;
					set @Command = @Command + '	select newid()'         + @CRLF;
					set @Command = @Command + '	     , getdate()'       + @CRLF;
					set @Command = @Command + '	     , CREATED_BY'      + @CRLF;
					set @Command = @Command + '	     , MODIFIED_USER_ID'+ @CRLF;
					set @Command = @Command + '	     , AUDIT_ID'        + @CRLF;
					set @Command = @Command + '	     , ''' + @AUDIT_TABLE  + '''' + @CRLF;
					set @Command = @Command + '	     , AUDIT_TOKEN'     + @CRLF;
					set @Command = @Command + '	     , AUDIT_ACTION'    + @CRLF;
					set @Command = @Command + '	     , ID'              + @CRLF;
					set @Command = @Command + '	  from inserted;'       + @CRLF;
					set @Command = @Command + '  end' + @CRLF;
					if @TEST = 1 begin -- then
						print @Command + @CRLF;
					end else begin
						print substring(@Command, 1, charindex(@CRLF, @Command));
						exec(@Command);
					end -- if;
				end -- if;
			end -- if;
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildAuditTrigger to public;
GO

-- exec dbo.spSqlBuildAllAuditTriggers;
-- exec spSqlBuildAuditTrigger 'LEADS';
-- exec spSqlBuildAuditTrigger 'LEADS_CSTM';

