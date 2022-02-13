if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildAllAuditTriggers' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildAllAuditTriggers;
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
-- 08/20/2008 Paul.  Build the triggers for the cached tables. 
Create Procedure dbo.spSqlBuildAllAuditTriggers
as
  begin
	set nocount on
	print N'spSqlBuildAllAuditTriggers';

	declare @TABLE_NAME varchar(80);
	declare TABLES_CURSOR cursor for
	select vwSqlTablesAudited.TABLE_NAME
	  from      vwSqlTablesAudited
	 inner join vwSqlTables
	         on vwSqlTables.TABLE_NAME = vwSqlTablesAudited.TABLE_NAME + '_AUDIT'
	order by vwSqlTablesAudited.TABLE_NAME;
	
	declare CACHE_CURSOR cursor for
	select TABLE_NAME
	  from vwSqlTablesCachedSystem
	union
	select TABLE_NAME
	  from vwSqlTablesCachedData
	 order by TABLE_NAME;
	
	open TABLES_CURSOR;
	fetch next from TABLES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		exec dbo.spSqlBuildAuditTrigger @TABLE_NAME;
		fetch next from TABLES_CURSOR into @TABLE_NAME;
	end -- while;
	close TABLES_CURSOR;
	deallocate TABLES_CURSOR;

	open CACHE_CURSOR;
	fetch next from CACHE_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		exec dbo.spSqlBuildSystemTrigger @TABLE_NAME;
		fetch next from CACHE_CURSOR into @TABLE_NAME;
	end -- while;
	close CACHE_CURSOR;
	deallocate CACHE_CURSOR;
  end
GO


Grant Execute on dbo.spSqlBuildAllAuditTriggers to public;
GO

-- exec dbo.spSqlBuildAllAuditTables;
-- exec dbo.spSqlBuildAllAuditTriggers;
-- exec dbo.spSqlDropAllAuditTriggers;
-- exec dbo.spSqlDropAllAuditTables;

