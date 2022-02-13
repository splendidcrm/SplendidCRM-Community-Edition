if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildAuditTable' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildAuditTable;
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
-- 01/07/2008 Paul.  Create an index in the ID field as this will be the primary lookup field when viewing the history. 
-- 09/20/2009 Paul.  Use a unique name for the cursor to prevent a collision with another procedure. 
-- 06/13/2010 Paul.  We need to prevent from adding auditing to non-SplendidCRM tables, so check for the base fields. 
-- 07/21/2010 Paul.  Custom tables were being excluded from the audit. 
-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
-- This also fixes a problem for a customer with 100 custom fields. 
Create Procedure dbo.spSqlBuildAuditTable(@TABLE_NAME varchar(80))
as
  begin
	set nocount on

	-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
	declare @Command           varchar(max);
	declare @AUDIT_TABLE       varchar(90);
	declare @AUDIT_PK          varchar(90);
	declare @COLUMN_NAME       varchar(80);
	declare @COLUMN_TYPE       varchar(20);
	declare @CRLF              char(2);
	declare @COLUMN_MAX_LENGTH int;
	declare @TEST              bit;
	declare @SPLENDID_FIELDS   int;
	
	set @TEST = 0;
	set @SPLENDID_FIELDS = 0;
	set @CRLF = char(13) + char(10);
	set @AUDIT_TABLE = @TABLE_NAME + '_AUDIT';
	set @AUDIT_PK    = 'PKA_' + @TABLE_NAME;

	-- 07/21/2010 Paul.  Custom tables were being excluded from the audit. 
	if right(@TABLE_NAME, 5) = '_CSTM' begin -- then
		-- 07/21/2010 Paul.  A custom table will only have an ID_C field, so if found then allow to continue. 
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME and COLUMN_NAME = 'ID_C') begin -- then
			set @SPLENDID_FIELDS = 6;
		end -- if;
	end else begin
		-- 06/13/2010 Paul.  We need to prevent from adding auditing to non-SplendidCRM tables, so check for the base fields. 
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
		-- 12/29/2007 Paul.  On Oracle, we will likely need to avoid auditing tables with length > 30. 
		-- The only two tables are DETAILVIEWS_RELATIONSHIPS and EMAIL_MARKETING_PROSPECT_LISTS. 
		if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = @AUDIT_TABLE and TABLE_TYPE = 'BASE TABLE') begin -- then
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
		
			set @Command = '';
			set @Command = @Command + 'Create Table dbo.' + @AUDIT_TABLE + @CRLF;
			-- 12/29/2007 Paul.  We need a transaction ID to be able to join operations into a single workflow operation. 
			-- sp_getbindtoken - Returns a unique identifier for the transaction. This unique identifier is referred to as a bind token. 
			set @Command = @Command + '	( AUDIT_ID'      + space(@COLUMN_MAX_LENGTH+1-len('AUDIT_ID'       )) + 'uniqueidentifier   not null constraint ' + @AUDIT_PK + ' primary key' + @CRLF;
			set @Command = @Command + '	, AUDIT_ACTION'  + space(@COLUMN_MAX_LENGTH+1-len('AUDIT_ACTION'   )) + 'int                not null' + @CRLF;
			set @Command = @Command + '	, AUDIT_DATE'    + space(@COLUMN_MAX_LENGTH+1-len('AUDIT_DATE'     )) + 'datetime           not null' + @CRLF;
			set @Command = @Command + '	, AUDIT_VERSION' + space(@COLUMN_MAX_LENGTH+1-len('AUDIT_VERSION'  )) + 'rowversion         not null' + @CRLF;
			set @Command = @Command + '	, AUDIT_COLUMNS' + space(@COLUMN_MAX_LENGTH+1-len('AUDIT_COLUMNS'  )) + 'varbinary(128)     null' + @CRLF;
			set @Command = @Command + '	, AUDIT_TOKEN'   + space(@COLUMN_MAX_LENGTH+1-len('AUDIT_TOKEN'    )) + 'varchar(255)       null' + @CRLF;
			open TABLE_COLUMNS_CURSOR;
			fetch next from TABLE_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
			while @@FETCH_STATUS = 0 begin -- while
				set @Command = @Command + '	, ' + @COLUMN_NAME + space(@COLUMN_MAX_LENGTH+1-len(@COLUMN_NAME)) + @COLUMN_TYPE + space(18-len(@COLUMN_TYPE)) + ' null' + @CRLF;
				fetch next from TABLE_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
			end -- while;
			close TABLE_COLUMNS_CURSOR;
			deallocate TABLE_COLUMNS_CURSOR;
			set @Command = @Command + '	)' + @CRLF;
			
			print 'Create Table dbo.' + @AUDIT_TABLE + ';';
			if @TEST = 1 begin -- then
				print @Command;
			end else begin
				exec(@Command);
			end -- if;
	
			-- 01/07/2008 Paul.  Create an index in the ID field as this will be the primary lookup field when viewing the history. 
			-- 11/17/2008 Paul.  Add audit token to main audit index as it is used in the workflow engine to get the old audit record. 
			-- 11/18/2008 Paul.  Include the audit action in the CSTM table as the workflow engine needs to get just the update action and not the insert. 
			-- We may want to remove the insert trigger on the CSTM table. 
			if right(@TABLE_NAME, 5) = '_CSTM' begin -- then
				set @Command = 'create index IDX_' + @AUDIT_TABLE + ' on dbo.' + @AUDIT_TABLE + '(ID_C, AUDIT_TOKEN, AUDIT_ACTION)';
			end else begin
				set @Command = 'create index IDX_' + @AUDIT_TABLE + ' on dbo.' + @AUDIT_TABLE + '(ID, AUDIT_VERSION, AUDIT_TOKEN)';
			end -- if;
			if @TEST = 1 begin -- then
				print @Command;
			end else begin
				exec(@Command);
			end -- if;
		end else begin
			print 'Alter Table dbo.' + @AUDIT_TABLE + ';';
			declare AUDIT_TABLE_COLUMNS_CURSOR cursor for
			select vwSqlColumns.ColumnName
			     , vwSqlColumns.ColumnType
			  from            vwSqlColumns
			  left outer join vwSqlColumns                   vwSqlColumnsAudit
			               on vwSqlColumnsAudit.ObjectName = vwSqlColumns.ObjectName + '_AUDIT'
			              and vwSqlColumnsAudit.ColumnName = vwSqlColumns.ColumnName
			 where vwSqlColumnsAudit.ObjectName is null
			   and vwSqlColumns.ObjectName = @TABLE_NAME
			 order by vwSqlColumns.colid;
	
			select @COLUMN_MAX_LENGTH = max(len(ColumnName)) + 1
			  from vwSqlColumns
			 where ObjectName = @TABLE_NAME;
			if @COLUMN_MAX_LENGTH < 20 begin -- then
				set @COLUMN_MAX_LENGTH = 20;
			end -- if;
	
			open AUDIT_TABLE_COLUMNS_CURSOR;
			fetch next from AUDIT_TABLE_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
			while @@FETCH_STATUS = 0 begin -- while
				set @Command = 'alter table ' + @AUDIT_TABLE + ' add ' + @COLUMN_NAME + space(@COLUMN_MAX_LENGTH+1-len(@COLUMN_NAME)) + @COLUMN_TYPE + space(18-len(@COLUMN_TYPE)) + ' null' + @CRLF;
				print @Command;
				if @TEST = 0 begin -- then
					exec(@Command);
				end -- if;
				fetch next from AUDIT_TABLE_COLUMNS_CURSOR into @COLUMN_NAME, @COLUMN_TYPE;
			end -- while;
			close AUDIT_TABLE_COLUMNS_CURSOR;
			deallocate AUDIT_TABLE_COLUMNS_CURSOR;
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildAuditTable to public;
GO

-- exec dbo.spSqlBuildAuditTable 'CONTACTS';

