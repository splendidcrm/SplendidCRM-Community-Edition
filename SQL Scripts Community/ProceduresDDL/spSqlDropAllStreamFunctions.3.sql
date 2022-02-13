if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropAllStreamFunctions' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlDropAllStreamFunctions;
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
Create Procedure dbo.spSqlDropAllStreamFunctions
as
  begin
	set nocount on

	declare @Command      varchar(max);
	declare @AUDIT_TABLE  varchar(90);
	declare @TABLE_NAME   varchar(80);
	declare @FUNCTION_NAME varchar(90);

	declare FUNCTIONS_CURSOR cursor for
	select ROUTINE_NAME
	  from INFORMATION_SCHEMA.ROUTINES
	 where ROUTINE_NAME like 'fn%[_]AUDIT[_]COLUMNS'
	   and ROUTINE_TYPE = 'FUNCTION'
	 order by ROUTINE_NAME;
	open FUNCTIONS_CURSOR;
	fetch next from FUNCTIONS_CURSOR into @FUNCTION_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @Command = 'Drop Function dbo.' + @FUNCTION_NAME;
		print @Command;
		exec(@Command);
		fetch next from FUNCTIONS_CURSOR into @FUNCTION_NAME;
	end -- while;
	close FUNCTIONS_CURSOR;
	deallocate FUNCTIONS_CURSOR;
  end
GO


Grant Execute on dbo.spSqlDropAllStreamFunctions to public;
GO

-- exec dbo.spSqlDropAllStreamFunctions;


