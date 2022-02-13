if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropForeignKeys' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlDropForeignKeys;
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
Create Procedure dbo.spSqlDropForeignKeys(@TABLE_NAME varchar(80))
as
  begin
	set nocount on

	declare @Command           varchar(max);
	declare @AddConstraint     varchar(1000);
	declare @FOREIGN_TABLE     varchar(90);
	declare @CONSTRAINT_NAME   varchar(90);
	declare @TEST              bit;
	set @TEST = 0;

	declare FOREIGN_KEYS_CURSOR cursor for
	select TABLE_CONSTRAINTS.TABLE_NAME
	     , TABLE_CONSTRAINTS.CONSTRAINT_NAME
	--     , N'alter table '      + TABLE_CONSTRAINTS.TABLE_SCHEMA + '.' + TABLE_CONSTRAINTS.TABLE_NAME + space(30-len(TABLE_CONSTRAINTS.TABLE_NAME       )) 
	--     + N' add  constraint ' + TABLE_CONSTRAINTS.CONSTRAINT_NAME                                   + space(60-len(TABLE_CONSTRAINTS.CONSTRAINT_NAME  )) 
	--     + N' foreign key ( '   + CONSTRAINT_COLUMN_USAGE.COLUMN_NAME                                 + space(30-len(CONSTRAINT_COLUMN_USAGE.COLUMN_NAME)) + N')'
	--     + N' references '      + PRIMARY_KEYS.TABLE_SCHEMA + '.' + PRIMARY_KEYS.TABLE_NAME           + space(30-len(PRIMARY_KEYS.TABLE_NAME            )) 
	--     + N' ('                + PRIMARY_COLUMN_USAGE.COLUMN_NAME                                    + space(30-len(PRIMARY_COLUMN_USAGE.COLUMN_NAME   )) + N');'
	  from      INFORMATION_SCHEMA.TABLE_CONSTRAINTS         TABLE_CONSTRAINTS
	 inner join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE   CONSTRAINT_COLUMN_USAGE
	         on CONSTRAINT_COLUMN_USAGE.CONSTRAINT_NAME    = TABLE_CONSTRAINTS.CONSTRAINT_NAME
	 inner join INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS   REFERENTIAL_CONSTRAINTS
	         on REFERENTIAL_CONSTRAINTS.CONSTRAINT_NAME    = TABLE_CONSTRAINTS.CONSTRAINT_NAME
	 inner join INFORMATION_SCHEMA.TABLE_CONSTRAINTS         PRIMARY_KEYS
	         on PRIMARY_KEYS.CONSTRAINT_NAME               = REFERENTIAL_CONSTRAINTS.UNIQUE_CONSTRAINT_NAME
	        and PRIMARY_KEYS.CONSTRAINT_TYPE               = 'PRIMARY KEY'
	 inner join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE   PRIMARY_COLUMN_USAGE
	         on PRIMARY_COLUMN_USAGE.CONSTRAINT_NAME       = PRIMARY_KEYS.CONSTRAINT_NAME
	 where TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'FOREIGN KEY'
	   and PRIMARY_KEYS.TABLE_NAME           = @TABLE_NAME
	 order by 1;

	open FOREIGN_KEYS_CURSOR;
	fetch next from FOREIGN_KEYS_CURSOR into @FOREIGN_TABLE, @CONSTRAINT_NAME;  --, @AddConstraint;
	while @@FETCH_STATUS = 0 begin -- while
		--print @AddConstraint;
		set @Command = 'alter table dbo.' + @FOREIGN_TABLE + space(30-len(@FOREIGN_TABLE)) + ' drop constraint ' + @CONSTRAINT_NAME;
		if @TEST = 1 begin -- then
			print @Command;
		end else begin
			exec(@Command);
		end -- if;
		fetch next from FOREIGN_KEYS_CURSOR into @FOREIGN_TABLE, @CONSTRAINT_NAME;  --, @AddConstraint;
	end -- while;
	close FOREIGN_KEYS_CURSOR;
	deallocate FOREIGN_KEYS_CURSOR;
  end
GO


Grant Execute on dbo.spSqlDropForeignKeys to public;
GO

-- exec dbo.spSqlDropForeignKeys 'LEADS';

