if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildAllAuditViews' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildAllAuditViews;
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
-- 11/17/2008 Paul.  Audit views are used to simplify support of custom fields in workflow engine. 
-- 06/02/2009 Paul.  This procedure must be run after the data for the MODULES table has been loaded. 
-- 10/11/2015 Paul.  Don't use vwMODULES as disabled tables can cause errors with the stream generation. 
Create Procedure dbo.spSqlBuildAllAuditViews
as
  begin
	set nocount on
	print N'spSqlBuildAllAuditViews';

	declare @TABLE_NAME varchar(80);
	-- 11/17/2008 Paul.  Only use module-based tables and exclude the custom fields tables. 
	declare TABLES_CURSOR cursor for
	select vwSqlTablesAudited.TABLE_NAME
	  from      vwSqlTablesAudited
	 inner join vwSqlTables
	         on vwSqlTables.TABLE_NAME = vwSqlTablesAudited.TABLE_NAME + '_AUDIT'
	 inner join MODULES
	         on MODULES.TABLE_NAME   = vwSqlTablesAudited.TABLE_NAME
	        and MODULES.DELETED      = 0
	 where vwSqlTablesAudited.TABLE_NAME not like '%[_]CSTM'
	order by vwSqlTablesAudited.TABLE_NAME;
	
	open TABLES_CURSOR;
	fetch next from TABLES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		exec dbo.spSqlBuildAuditView @TABLE_NAME;
		fetch next from TABLES_CURSOR into @TABLE_NAME;
	end -- while;
	close TABLES_CURSOR;
	deallocate TABLES_CURSOR;
  end
GO


Grant Execute on dbo.spSqlBuildAllAuditViews to public;
GO

-- exec dbo.spSqlBuildAllAuditTables;
-- exec dbo.spSqlBuildAllAuditViews;
-- exec dbo.spSqlDropAllAuditTriggers;
-- exec dbo.spSqlDropAllAuditTables;

