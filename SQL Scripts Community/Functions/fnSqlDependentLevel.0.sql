if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnSqlDependentLevel' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnSqlDependentLevel;
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
-- 04/22/2010 Paul.  We need to ignore foreign keys that reference self. 
-- 10/13/2016 Paul.  Add view and procedure dependencies based on SQL 2008 sql_expression_dependencies table. 
Create Function dbo.fnSqlDependentLevel(@Object varchar(255), @Type varchar(25))
returns int
as
  begin
	declare @DepCount int;
	set @DepCount = 0;
	if @Object = 'fnSqlDependentLevel' begin -- then
		return 0;
	end else if @Type = 'U' or @Type = 'Table' begin -- then
		--select 'alter table '      + upper(TABLE_CONSTRAINTS.TABLE_NAME       ) + space(32-len(TABLE_CONSTRAINTS.TABLE_NAME     )) 
		--     + ' add constraint  ' + upper(TABLE_CONSTRAINTS.CONSTRAINT_NAME  ) + space(60-len(TABLE_CONSTRAINTS.CONSTRAINT_NAME)) 
		--     + ' foreign key ('    + upper(CONSTRAINT_COLUMN_USAGE.COLUMN_NAME) + ') '
		--     + ' references '      + PRIMARY_COLUMN_USAGE.TABLE_NAME + ' (' + upper(PRIMARY_COLUMN_USAGE.COLUMN_NAME) + ')' as ADD_CONSTRAINT
		select @DepCount = max(dbo.fnSqlDependentLevel(PRIMARY_KEYS.TABLE_NAME, @Type))
		  from      INFORMATION_SCHEMA.TABLE_CONSTRAINTS         TABLE_CONSTRAINTS
		 inner join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE   CONSTRAINT_COLUMN_USAGE
		         on CONSTRAINT_COLUMN_USAGE.CONSTRAINT_NAME    = TABLE_CONSTRAINTS.CONSTRAINT_NAME
		 inner join INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS   REFERENTIAL_CONSTRAINTS
		         on REFERENTIAL_CONSTRAINTS.CONSTRAINT_NAME    = TABLE_CONSTRAINTS.CONSTRAINT_NAME
		 inner join INFORMATION_SCHEMA.TABLE_CONSTRAINTS         PRIMARY_KEYS
		         on PRIMARY_KEYS.CONSTRAINT_NAME               = REFERENTIAL_CONSTRAINTS.UNIQUE_CONSTRAINT_NAME
		        and PRIMARY_KEYS.CONSTRAINT_TYPE               = 'PRIMARY KEY'
		-- inner join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE   PRIMARY_COLUMN_USAGE
		--         on PRIMARY_COLUMN_USAGE.CONSTRAINT_NAME       = PRIMARY_KEYS.CONSTRAINT_NAME
		 where TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'FOREIGN KEY'
		-- 04/22/2010 Paul.  We need to ignore foreign keys that reference self. 
		   and TABLE_CONSTRAINTS.TABLE_NAME = @Object
		   and TABLE_CONSTRAINTS.TABLE_NAME <> PRIMARY_KEYS.TABLE_NAME;
	end else if @Type = 'P' or @Type = 'Procedure' begin -- then
		-- 10/13/2016 Paul.  sql_expression_dependencies does not exist on SQL 2005. 
		-- 06/11/2019 Paul.  Exclude self. 
		select @DepCount = max(dbo.fnSqlDependentLevel(referenced_entity_name, @Type))
		  from      sys.sql_expression_dependencies
		 inner join sys.objects
		         on sys.sql_expression_dependencies.referencing_id = sys.objects.object_id
		 where referencing_id = object_id(@Object)
		--   and referenced_entity_name like 'sp%'
		   and referenced_entity_name <> @Object;
	end else if @Type = 'F' or @Type = 'Function' begin -- then
		-- 10/13/2016 Paul.  sql_expression_dependencies does not exist on SQL 2005. 
		-- 06/11/2019 Paul.  Exclude self. 
		select @DepCount = max(dbo.fnSqlDependentLevel(referenced_entity_name, @Type))
		  from      sys.sql_expression_dependencies
		 inner join sys.objects
		         on sys.sql_expression_dependencies.referencing_id = sys.objects.object_id
		 where referencing_id = object_id(@Object)
		--   and referenced_entity_name like 'sp%'
		   and referenced_entity_name <> @Object;
	end else if @Type = 'V' or @Type = 'View' begin -- then
		select @DepCount = max(dbo.fnSqlDependentLevel(referenced_entity_name, @Type))
		  from      sys.sql_expression_dependencies
		 inner join sys.objects
		         on sys.sql_expression_dependencies.referencing_id = sys.objects.object_id
		 where referencing_id = object_id(@Object)
		--   and referenced_entity_name like 'vw%';
	end -- if;
	if @DepCount is null begin -- then
		return 1;
	end -- if;
	return 1 + @DepCount;
  end
GO

Grant Execute on dbo.fnSqlDependentLevel to public
GO


/*
select 'ren dbo.' + TABLE_NAME + '.Table.sql ' + TABLE_NAME + '.' + cast(dbo.fnSqlDependentLevel(TABLE_NAME, 'U') as varchar(1)) + '.sql'
  from INFORMATION_SCHEMA.TABLES
 where TABLE_TYPE = 'BASE TABLE'
--   and dbo.fnSqlDependentLevel(TABLE_NAME, 'U') > 1
 order by TABLE_NAME;

select 'ren dbo.' + TABLE_NAME + '.View.sql ' + TABLE_NAME + '.' + cast(dbo.fnSqlDependentLevel(TABLE_NAME, 'V')-1 as varchar(1)) + '.sql'
  from INFORMATION_SCHEMA.TABLES
 where TABLE_TYPE = 'VIEW'
--   and dbo.fnSqlDependentLevel(TABLE_NAME, 'V') > 1
 order by dbo.fnSqlDependentLevel(TABLE_NAME, 'V');

select 'ren dbo.' + ROUTINE_NAME + '.StoredProcedure.sql ' + ROUTINE_NAME + '.' + cast(dbo.fnSqlDependentLevel(ROUTINE_NAME, 'P') as varchar(1)) + '.sql'
  from INFORMATION_SCHEMA.ROUTINES
 where ROUTINE_TYPE = 'PROCEDURE'
--   and dbo.fnSqlDependentLevel(ROUTINE_NAME, 'P') > 1
 order by ROUTINE_NAME;

select 'ren dbo.' + ROUTINE_NAME + '.UserDefinedFunction.sql ' + ROUTINE_NAME + '.' + cast(dbo.fnSqlDependentLevel(ROUTINE_NAME, 'F') as varchar(1)) + '.sql'
  from INFORMATION_SCHEMA.ROUTINES
 where ROUTINE_TYPE = 'FUNCTION'
   and ROUTINE_NAME <> 'fnSqlDependentLevel'
 order by ROUTINE_NAME;

select 'ren dbo.' + name + '.UserDefinedTableType.sql ' + name + '.1.sql'
  from sys.types
 where is_user_defined = 1
 order by name;


declare @DEP_COUNT int;
declare @ROUTINE_NAME varchar(100);
declare ROUTINE_CURSOR cursor for
select  ROUTINE_NAME
  from INFORMATION_SCHEMA.ROUTINES
 where ROUTINE_TYPE = 'FUNCTION'
 order by ROUTINE_NAME;
open ROUTINE_CURSOR;
fetch next from ROUTINE_CURSOR into @ROUTINE_NAME;
while @@FETCH_STATUS = 0 begin -- do
	begin try
		set @DEP_COUNT = dbo.fnSqlDependentLevel(@ROUTINE_NAME, 'F');
		print 'ren dbo.' + @ROUTINE_NAME + '.UserDefinedFunction.sql ' + @ROUTINE_NAME + '.' + cast(@DEP_COUNT as varchar(1)) + '.sql';
	end try
	begin catch
		print '   ****  ' + @ROUTINE_NAME + ': ' + error_message();
	end catch
	fetch next from ROUTINE_CURSOR into @ROUTINE_NAME;
end -- while;
close ROUTINE_CURSOR;
deallocate ROUTINE_CURSOR;
*/

