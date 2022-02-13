if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropAllStreamProcedures' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlDropAllStreamProcedures;
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
Create Procedure dbo.spSqlDropAllStreamProcedures
as
  begin
	set nocount on

	declare @Command        varchar(max);
	declare @AUDIT_TABLE    varchar(90);
	declare @TABLE_NAME     varchar(80);
	declare @PROCEDURE_NAME varchar(90);

	declare PROCEDURES_CURSOR cursor for
	select ROUTINE_NAME
	  from INFORMATION_SCHEMA.ROUTINES
	 where ROUTINE_NAME like 'sp%[_]STREAM[_]InsertPost'
	   and ROUTINE_TYPE = 'PROCEDURE'
	 order by ROUTINE_NAME;
	open PROCEDURES_CURSOR;
	fetch next from PROCEDURES_CURSOR into @PROCEDURE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @Command = 'Drop Procedure dbo.' + @PROCEDURE_NAME;
		print @Command;
		exec(@Command);
		fetch next from PROCEDURES_CURSOR into @PROCEDURE_NAME;
	end -- while;
	close PROCEDURES_CURSOR;
	deallocate PROCEDURES_CURSOR;
  end
GO


Grant Execute on dbo.spSqlDropAllStreamProcedures to public;
GO

-- exec dbo.spSqlDropAllStreamProcedures;


