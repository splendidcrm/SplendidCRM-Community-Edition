if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildStreamFunction' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildStreamFunction;
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
Create Procedure dbo.spSqlBuildStreamFunction(@TABLE_NAME varchar(80))
as
  begin
	set nocount on
	
	declare @Command           varchar(max);
	declare @AUDIT_TABLE       varchar(90);
	declare @AUDIT_VIEW        varchar(90);
	declare @FUNCTION_NAME     varchar(90);
	declare @COLUMN_NAME       varchar(80);
	declare @STREAM_COLUMNS    varchar(max);
	declare @COLUMN_MAX_LENGTH int;
	declare @TEST              bit;
	declare @CRLF              char(2);
	declare @SPLENDID_FIELDS   int;

	set @TEST            = 0;
	set @CRLF            = char(13) + char(10);
	set @SPLENDID_FIELDS = 0;
	set @AUDIT_TABLE     = @TABLE_NAME + '_AUDIT';
	set @AUDIT_VIEW      = 'vw' + @AUDIT_TABLE;

	-- 09/23/2015 Paul.  We need to prevent from adding streaming to non-SplendidCRM tables, so check for the base fields. 
	-- 10/11/2015 Paul.  We need to check the view, not the base table, as we use the view in the function to include custom fields. 
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_VIEW and COLUMN_NAME = 'AUDIT_ID') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_VIEW and COLUMN_NAME = 'AUDIT_ACTION') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_VIEW and COLUMN_NAME = 'AUDIT_DATE') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_VIEW and COLUMN_NAME = 'AUDIT_VERSION') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_VIEW and COLUMN_NAME = 'AUDIT_TOKEN') begin -- then
		set @SPLENDID_FIELDS = @SPLENDID_FIELDS + 1;
	end -- if;

	if @SPLENDID_FIELDS = 5 begin -- then
		set @FUNCTION_NAME = 'fn' + @AUDIT_TABLE + '_COLUMNS';
		if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = @FUNCTION_NAME and ROUTINE_TYPE = 'FUNCTION') begin -- then
			set @Command = 'Drop Function dbo.' + @FUNCTION_NAME;
			if @TEST = 0 begin -- then
				print @Command;
				exec(@Command);
			end -- if;
		end -- if;

		if not exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = @FUNCTION_NAME and ROUTINE_TYPE = 'FUNCTION') begin -- then
			declare FUNCTION_COLUMNS_CURSOR cursor for
			select COLUMN_NAME
		          from INFORMATION_SCHEMA.COLUMNS
		         where TABLE_NAME = 'vw' + @AUDIT_TABLE
		           and COLUMN_NAME not in ('AUDIT_ID', 'AUDIT_ACTION', 'AUDIT_DATE', 'AUDIT_VERSION', 'AUDIT_COLUMNS', 'AUDIT_TOKEN', 'ID', 'ID_C', 'DELETED', 'CREATED_BY_ID', 'CREATED_BY', 'DATE_ENTERED', 'MODIFIED_USER_ID', 'MODIFIED_BY', 'DATE_MODIFIED', 'DATE_MODIFIED_UTC', 'ASSIGNED_TO', 'TEAM_NAME')
			order by ORDINAL_POSITION;

			select @COLUMN_MAX_LENGTH = max(len(COLUMN_NAME)) + 1
		          from INFORMATION_SCHEMA.COLUMNS
		         where TABLE_NAME = 'vw' + @AUDIT_TABLE
		           and COLUMN_NAME not in ('AUDIT_ID', 'AUDIT_ACTION', 'AUDIT_DATE', 'AUDIT_VERSION', 'AUDIT_COLUMNS', 'AUDIT_TOKEN', 'ID', 'ID_C', 'DELETED', 'CREATED_BY_ID', 'CREATED_BY', 'DATE_ENTERED', 'MODIFIED_USER_ID', 'MODIFIED_BY', 'DATE_MODIFIED', 'DATE_MODIFIED_UTC', 'ASSIGNED_TO', 'TEAM_NAME')
			if @COLUMN_MAX_LENGTH < 20 begin -- then
				set @COLUMN_MAX_LENGTH = 20;
			end -- if;
		
			set @Command = '';
			set @Command = @Command + 'Create Function dbo.' + @FUNCTION_NAME + @CRLF;
			set @Command = @Command + '	( @AUDIT_ID uniqueidentifier ' + @CRLF;
			set @Command = @Command + '	, @ID uniqueidentifier       ' + @CRLF;
			set @Command = @Command + '	, @AUDIT_VERSION varbinary(8)' + @CRLF;
			set @Command = @Command + '	, @AUDIT_ACTION int          ' + @CRLF;
			set @Command = @Command + '	)' + @CRLF;
			set @Command = @Command + 'returns varchar(max)' + @CRLF;
			set @Command = @Command + 'as' + @CRLF;
			set @Command = @Command + '  begin' + @CRLF;
			set @Command = @Command + '	declare @STREAM_COLUMNS    varchar(max);' + @CRLF;
			set @Command = @Command + '	declare @PREVIOUS_AUDIT_ID uniqueidentifier;' + @CRLF;
			set @Command = @Command + '	' + @CRLF;
			set @Command = @Command + '	if @AUDIT_ACTION = 1 begin -- then' + @CRLF;
			set @Command = @Command + '		select top 1 @PREVIOUS_AUDIT_ID = AUDIT_ID' + @CRLF;
			set @Command = @Command + '		  from ' + @AUDIT_TABLE + '' + @CRLF;
			set @Command = @Command + '		 where ID            = @ID' + @CRLF;
			set @Command = @Command + '		   and AUDIT_VERSION < @AUDIT_VERSION' + @CRLF;
			set @Command = @Command + '		 order by AUDIT_VERSION desc;' + @CRLF;
			set @Command = @Command + '		' + @CRLF;
			set @Command = @Command + '		if @PREVIOUS_AUDIT_ID is not null begin -- then' + @CRLF;
			set @STREAM_COLUMNS = '';
			open FUNCTION_COLUMNS_CURSOR;
			fetch next from FUNCTION_COLUMNS_CURSOR into @COLUMN_NAME;
			while @@FETCH_STATUS = 0 begin -- while
				if len(@STREAM_COLUMNS) = 0 begin -- then
					set @STREAM_COLUMNS = @STREAM_COLUMNS + '			select @STREAM_COLUMNS = ';
				end else begin
					set @STREAM_COLUMNS = @STREAM_COLUMNS + '			                       + ';
				end -- if;
				set @STREAM_COLUMNS = @STREAM_COLUMNS + '(case when (CURRENT_AUDIT.' + @COLUMN_NAME + space(@COLUMN_MAX_LENGTH-len(@COLUMN_NAME)) + ' is null and PREVIOUS_AUDIT.' + @COLUMN_NAME + space(@COLUMN_MAX_LENGTH-len(@COLUMN_NAME)) + ' is null) or (CURRENT_AUDIT.' + @COLUMN_NAME + space(@COLUMN_MAX_LENGTH-len(@COLUMN_NAME)) + ' = PREVIOUS_AUDIT.' + @COLUMN_NAME + space(@COLUMN_MAX_LENGTH-len(@COLUMN_NAME)) + ') then '''' else ''' + @COLUMN_NAME + ' ''' + space(@COLUMN_MAX_LENGTH-len(@COLUMN_NAME)) + ' end)' + @CRLF;
				fetch next from FUNCTION_COLUMNS_CURSOR into @COLUMN_NAME;
			end -- while;
			close FUNCTION_COLUMNS_CURSOR;
			deallocate FUNCTION_COLUMNS_CURSOR;
			set @Command = @Command + @STREAM_COLUMNS;
			set @Command = @Command + '			  from      vw' + @AUDIT_TABLE + ' CURRENT_AUDIT          ' + @CRLF;
			set @Command = @Command + '			 inner join vw' + @AUDIT_TABLE + ' PREVIOUS_AUDIT         ' + @CRLF;
			set @Command = @Command + '			         on PREVIOUS_AUDIT.ID       = CURRENT_AUDIT.ID  ' + @CRLF;
			set @Command = @Command + '			        and PREVIOUS_AUDIT.AUDIT_ID = @PREVIOUS_AUDIT_ID' + @CRLF;
			set @Command = @Command + '			 where CURRENT_AUDIT.AUDIT_ID = @AUDIT_ID;              ' + @CRLF;
			set @Command = @Command + '			' + @CRLF;
			set @Command = @Command + '			set @STREAM_COLUMNS = rtrim(@STREAM_COLUMNS);' + @CRLF;
			set @Command = @Command + '		end -- if;' + @CRLF;
			set @Command = @Command + '	end -- if;' + @CRLF;
			set @Command = @Command + '	return @STREAM_COLUMNS;' + @CRLF;
			set @Command = @Command + '  end' + @CRLF;

			if @TEST = 1 begin -- then
				print @Command + @CRLF;
			end else begin
				print substring(@Command, 1, charindex(@CRLF, @Command));
				exec(@Command);
			end -- if;
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildStreamFunction to public;
GO

