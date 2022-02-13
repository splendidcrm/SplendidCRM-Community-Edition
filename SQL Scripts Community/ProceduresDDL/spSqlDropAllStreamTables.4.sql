if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropAllStreamTables' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlDropAllStreamTables;
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
Create Procedure dbo.spSqlDropAllStreamTables
as
  begin
	set nocount on

	declare @Command      varchar(max);
	declare @TABLE_NAME   varchar(80);
	declare @TRIGGER_NAME varchar(90);
	declare AUDIT_TABLES_CURSOR cursor for
	select TABLE_NAME
	  from vwSqlTables
	 where TABLE_NAME like '%_STREAM'
	order by TABLE_NAME;

	exec dbo.spSqlDropAllStreamProcedures ;
	exec dbo.spSqlDropAllStreamTriggers ;
	exec dbo.spSqlDropAllStreamFunctions ;
	exec dbo.spSqlDropAllStreamViews ;
	
	open AUDIT_TABLES_CURSOR;
	fetch next from AUDIT_TABLES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = @TABLE_NAME and TABLE_TYPE = 'BASE TABLE') begin -- then
			set @Command = 'Drop Table dbo.' + @TABLE_NAME;
			print @Command;
			exec(@Command);
		end -- if;
		fetch next from AUDIT_TABLES_CURSOR into @TABLE_NAME;
	end -- while;
	close AUDIT_TABLES_CURSOR;
	deallocate AUDIT_TABLES_CURSOR;
  end
GO


Grant Execute on dbo.spSqlDropAllStreamTables to public;
GO

-- exec dbo.spSqlBuildAllStreamTables;
-- exec dbo.spSqlDropAllStreamTables;


