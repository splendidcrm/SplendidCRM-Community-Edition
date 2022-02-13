if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlTableAddColumn' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlTableAddColumn;
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
-- 06/03/2008 Paul.  Add suport for bigint. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
Create Procedure dbo.spSqlTableAddColumn
	( @TABLE_NAME        varchar(255)
	, @COLUMN_NAME       varchar(255)
	, @DATA_TYPE         varchar(255)
	, @MAX_SIZE          int
	, @REQUIRED          bit
	, @DEFAULT_VALUE     varchar(255)
	)
as
  begin
	set nocount on
	
	declare @Command     varchar(2000);
	declare @NullStmt    varchar(  10);
	declare @DefaultStmt varchar( 300);
	-- 08/02/2008 Paul.  We can only enforce the not null attribute if a default value is specified. 
	-- This is because we create the custom field record before we assign the values.
	if @REQUIRED = 1 and @DefaultStmt is not null begin -- then
		set @NullStmt = ' not null';
	end else begin
		set @NullStmt = ' null';
	end -- if;
	-- 02/09/2007 Paul.  We should always create unicode fields.  Use nvarchar and not varchar. 
	if @DATA_TYPE = 'varchar' begin -- then
		set @Command = 'alter table ' + @TABLE_NAME + ' add ' + @COLUMN_NAME + ' nvarchar(' + cast(@MAX_SIZE as char(10)) + ')';
	end else if @DATA_TYPE = 'enum'    begin -- then
		set @Command = 'alter table ' + @TABLE_NAME + ' add ' + @COLUMN_NAME + ' nvarchar(' + cast(@MAX_SIZE as char(10)) + ')';
	end else if @DATA_TYPE = 'text'    begin -- then
		set @Command = 'alter table ' + @TABLE_NAME + ' add ' + @COLUMN_NAME + ' nvarchar(max)';
	end else if @DATA_TYPE = 'bool'    begin -- then
		set @Command = 'alter table ' + @TABLE_NAME + ' add ' + @COLUMN_NAME + ' bit';
	end else if @DATA_TYPE = 'int'     begin -- then
		set @Command = 'alter table ' + @TABLE_NAME + ' add ' + @COLUMN_NAME + ' int';
	end else if @DATA_TYPE = 'bigint'  begin -- then
		set @Command = 'alter table ' + @TABLE_NAME + ' add ' + @COLUMN_NAME + ' bigint';
	end else if @DATA_TYPE = 'float'   begin -- then
		set @Command = 'alter table ' + @TABLE_NAME + ' add ' + @COLUMN_NAME + ' float';
	end else if @DATA_TYPE = 'date'    begin -- then
		set @Command = 'alter table ' + @TABLE_NAME + ' add ' + @COLUMN_NAME + ' datetime';
	end else if @DATA_TYPE = 'guid'    begin -- then
		set @Command = 'alter table ' + @TABLE_NAME + ' add ' + @COLUMN_NAME + ' uniqueidentifier';
	-- 04/23/2007 Paul.  Add money type. This will allow default handling of currencies. 
	end else if @DATA_TYPE = 'money'    begin -- then
		set @Command = 'alter table ' + @TABLE_NAME + ' add ' + @COLUMN_NAME + ' money';
	end else begin
		raiserror(N'spSqlTableAddColumn: %s is not a supported DATA_TYPE. ', 16, 1, @DATA_TYPE);
	end -- if;

	if @DEFAULT_VALUE is not null begin -- then
		-- 01/06/2006 Paul.  For bool, int and float, cast to the type as a form of error checking.
		-- We want the cast to fail if it is not appropriate. 
		set @DefaultStmt = ' constraint DF_' + @TABLE_NAME + '_' + @COLUMN_NAME;
		if @DATA_TYPE = 'bool'    begin -- then
			set @DefaultStmt = @DefaultStmt + ' default(' + cast(cast(@DEFAULT_VALUE as int          ) as char(10)) + ')';
		end else if @DATA_TYPE = 'int' begin -- then
			set @DefaultStmt = @DefaultStmt + ' default(' + cast(cast(@DEFAULT_VALUE as int          ) as char(10)) + ')';
		end else if @DATA_TYPE = 'float' begin -- then
			set @DefaultStmt = @DefaultStmt + ' default(' + cast(cast(@DEFAULT_VALUE as decimal(19,4)) as char(20)) + ')';
		end else if @DATA_TYPE = 'guid' begin -- then
			if @DEFAULT_VALUE = 'newid()' begin -- then
				set @DefaultStmt = @DefaultStmt + ' default(newid())';
			end else begin
				set @DefaultStmt = @DefaultStmt + ' default(''' + replace(@DEFAULT_VALUE, '''', '''''') + ''')';
			end -- if;
		end else begin
			-- 01/06/2006 Paul.  Most default values need to be quoted. 
			set @DefaultStmt = @DefaultStmt + ' default(''' + replace(@DEFAULT_VALUE, '''', '''''') + ''')';
		end -- if;
	end -- if;
	if @Command is not null and @@ERROR = 0 begin -- then
		set @Command = @Command + @NullStmt;
		if @DefaultStmt is not null begin -- then
			set @Command = @Command + @DefaultStmt;
		end -- if;
		exec (@Command);
	end -- if;
  end
GO

Grant Execute on dbo.spSqlTableAddColumn to public;
GO

