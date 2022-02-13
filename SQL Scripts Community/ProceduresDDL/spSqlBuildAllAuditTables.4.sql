if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildAllAuditTables' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildAllAuditTables;
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
-- 11/17/2008 Paul.  Build audit views. 
Create Procedure dbo.spSqlBuildAllAuditTables
as
  begin
	set nocount on
	print N'spSqlBuildAllAuditTables';

	declare @TABLE_NAME varchar(80);
	declare TABLES_CURSOR cursor for
	select TABLE_NAME
	  from vwSqlTablesAudited
	order by TABLE_NAME;
	
	-- 07/25/2009 Paul.  We need to add a rowversion field to any sync'd table. 
	exec dbo.spSqlUpdateSyncdTables ;

	open TABLES_CURSOR;
	fetch next from TABLES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		exec dbo.spSqlBuildAuditTable @TABLE_NAME;
		fetch next from TABLES_CURSOR into @TABLE_NAME;
	end -- while;
	close TABLES_CURSOR;
	deallocate TABLES_CURSOR;

	-- 09/14/2008 Paul.  A single space after the procedure simplifies the migration to DB2. 
	exec dbo.spSqlBuildAllAuditTriggers ;
	exec dbo.spSqlBuildAllAuditViews ;
  end
GO


Grant Execute on dbo.spSqlBuildAllAuditTables to public;
GO

-- exec dbo.spSqlBuildAllAuditTables;
-- exec dbo.spSqlDropAllAuditTables;

-- exec dbo.spSqlBuildAllStreamTables;
-- exec dbo.spSqlDropAllStreamTables;


