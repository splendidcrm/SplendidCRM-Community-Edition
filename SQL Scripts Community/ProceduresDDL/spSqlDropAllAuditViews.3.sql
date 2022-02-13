if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropAllAuditViews' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlDropAllAuditViews;
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
-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
-- This also fixes a problem for a customer with 100 custom fields. 
Create Procedure dbo.spSqlDropAllAuditViews
as
  begin
	set nocount on

	-- 04/25/2011 Paul.  We've stopped supporting SQL 2000, so we can use varchar(max). 
	declare @Command           varchar(max);
	declare @TABLE_NAME   varchar(80);
	declare @VIEW_NAME    varchar(90);
	declare TABLES_CURSOR cursor for
	select vwSqlTablesAudited.TABLE_NAME
	  from      vwSqlTablesAudited
	 inner join vwSqlTables
	         on vwSqlTables.TABLE_NAME = vwSqlTablesAudited.TABLE_NAME + '_AUDIT'
	order by vwSqlTablesAudited.TABLE_NAME;

	open TABLES_CURSOR;
	fetch next from TABLES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @VIEW_NAME = 'vw' + @TABLE_NAME + '_AUDIT';
		if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = @VIEW_NAME) begin -- then
			set @Command = 'Drop View dbo.' + @VIEW_NAME;
			print @Command;
			exec(@Command);
		end -- if;

		fetch next from TABLES_CURSOR into @TABLE_NAME;
	end -- while;
	close TABLES_CURSOR;
	deallocate TABLES_CURSOR;
  end
GO


Grant Execute on dbo.spSqlDropAllAuditViews to public;
GO

-- exec dbo.spSqlDropAllAuditViews;


