if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropAllAuditTables' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlDropAllAuditTables;
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
-- 11/17/2008 Paul.  Drop audit views. 
-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
-- This also fixes a problem for a customer with 100 custom fields. 
Create Procedure dbo.spSqlDropAllAuditTables
as
  begin
	set nocount on

	-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
	declare @Command           varchar(max);
	declare @TABLE_NAME   varchar(80);
	declare @TRIGGER_NAME varchar(90);
	declare AUDIT_TABLES_CURSOR cursor for
	select TABLE_NAME
	  from vwSqlTables
	 where TABLE_NAME like '%_AUDIT'
	order by TABLE_NAME;

	-- 09/14/2008 Paul.  A single space after the procedure simplifies the migration to DB2. 
	exec dbo.spSqlDropAllAuditTriggers ;
	exec dbo.spSqlDropAllAuditViews ;
	
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


Grant Execute on dbo.spSqlDropAllAuditTables to public;
GO

-- exec dbo.spSqlDropAllAuditTables;


