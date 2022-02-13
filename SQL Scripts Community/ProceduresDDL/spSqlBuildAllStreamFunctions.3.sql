if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildAllStreamFunctions' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildAllStreamFunctions;
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
Create Procedure dbo.spSqlBuildAllStreamFunctions
as
  begin
	set nocount on
	print N'spSqlBuildAllStreamFunctions';

	declare @TABLE_NAME varchar(80);
	declare TABLES_CURSOR cursor for
	select vwSqlTablesStreamed.TABLE_NAME
	  from      vwSqlTablesStreamed
	 inner join vwSqlTables
	         on vwSqlTables.TABLE_NAME = vwSqlTablesStreamed.TABLE_NAME + '_STREAM'
	order by vwSqlTablesStreamed.TABLE_NAME;
	
	open TABLES_CURSOR;
	fetch next from TABLES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		exec dbo.spSqlBuildStreamFunction @TABLE_NAME;
		fetch next from TABLES_CURSOR into @TABLE_NAME;
	end -- while;
	close TABLES_CURSOR;
	deallocate TABLES_CURSOR;
  end
GO


Grant Execute on dbo.spSqlBuildAllStreamFunctions to public;
GO

