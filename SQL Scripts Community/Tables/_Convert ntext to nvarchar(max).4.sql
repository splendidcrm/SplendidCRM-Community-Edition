
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
declare @Command           varchar(8000);  -- varchar(max) on SQL 2005
declare @TABLE_NAME        varchar(80);
declare @COLUMN_NAME       varchar(80);
declare @DATA_TYPE         varchar(20);
declare @TEST              bit;

set @TEST = 0;

-- 09/19/2009 Paul.  Azure does not support ntext and image data types, 
-- so we have converted all tables and procedures to use nvarchar(max) and varbinary(max). 
declare NVARCHAR_COLUMNS_CURSOR cursor for
select COLUMNS.TABLE_NAME
     , COLUMNS.COLUMN_NAME
     , (case COLUMNS.DATA_TYPE when 'ntext' then 'nvarchar(max)' when 'image' then 'varbinary(max)' end) as DATA_TYPE
  from      INFORMATION_SCHEMA.TABLES   TABLES
 inner join INFORMATION_SCHEMA.COLUMNS  COLUMNS
         on COLUMNS.TABLE_NAME        = TABLES.TABLE_NAME
 where TABLES.TABLE_TYPE = 'BASE TABLE'
   and COLUMNS.DATA_TYPE in ('ntext', 'image')
   and TABLES.TABLE_NAME not in ('dtproperties', 'sysdiagrams')
 order by COLUMNS.DATA_TYPE, COLUMNS.TABLE_NAME, COLUMNS.COLUMN_NAME;

if exists (select COLUMNS.*
             from      INFORMATION_SCHEMA.TABLES   TABLES
            inner join INFORMATION_SCHEMA.COLUMNS  COLUMNS
                    on COLUMNS.TABLE_NAME        = TABLES.TABLE_NAME
            where TABLES.TABLE_TYPE = 'BASE TABLE'
              and COLUMNS.DATA_TYPE in ('ntext', 'image')
              and TABLES.TABLE_NAME not in ('dtproperties', 'sysdiagrams')
          ) begin -- then
	print 'Converting fields from image to varbinary(max) and ntext to nvarchar(max)';	

	open NVARCHAR_COLUMNS_CURSOR;
	fetch next from NVARCHAR_COLUMNS_CURSOR into @TABLE_NAME, @COLUMN_NAME, @DATA_TYPE;
	while @@FETCH_STATUS = 0 begin -- while
		-- 12/04/2009 Paul.  Columns with default constraints cannot be altered, so just dump an warning message. 
		if exists (select *
		             from      sys.default_constraints  default_constraints
		            inner join sys.objects              objects
		                    on objects.object_id      = default_constraints.parent_object_id
		            inner join sys.columns              columns
		                    on columns.object_id      = objects.object_id
		                   and columns.column_id      = default_constraints.parent_column_id
		            where objects.type = 'U'
		              and default_constraints.type = 'D'
		              and objects.name = @TABLE_NAME
		              and columns.name = @COLUMN_NAME) begin -- then
			print 'Warning: ' + @TABLE_NAME + '.' + @COLUMN_NAME + ' has a default constraint, so it will not be converted.'
		end else begin
			-- 12/04/2009 Paul.  Full-Text fields cannot be converted. 
			if columnproperty(object_id(@TABLE_NAME), @COLUMN_NAME, 'IsFullTextIndexed') = 1 begin -- then
				print 'Warning: ' + @TABLE_NAME + '.' + @COLUMN_NAME + ' is a Full-Text Search field, so it will not be converted.'
			end else begin
				set @Command = 'alter table ' + @TABLE_NAME + space(35-len(@TABLE_NAME)) + ' alter column ' + @COLUMN_NAME + space(35-len(@COLUMN_NAME)) + ' ' + @DATA_TYPE + ' null';
				print @Command;
				if @TEST = 0 begin -- then
					exec(@Command);
				end -- if;
			end -- if;
		end -- if;
		fetch next from NVARCHAR_COLUMNS_CURSOR into @TABLE_NAME, @COLUMN_NAME, @DATA_TYPE;
	end -- while;
	close NVARCHAR_COLUMNS_CURSOR;
end -- if;
-- 10/13/2009 Paul.  We should always deallocate the cursor. 
deallocate NVARCHAR_COLUMNS_CURSOR;
GO


