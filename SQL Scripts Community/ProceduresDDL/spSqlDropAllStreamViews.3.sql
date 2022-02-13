if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropAllStreamViews' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlDropAllStreamViews;
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
-- 06/02/2016 Paul.  Create master activities view. 
Create Procedure dbo.spSqlDropAllStreamViews
as
  begin
	set nocount on

	declare @Command      varchar(max);
	declare @TABLE_NAME   varchar(80);
	declare @VIEW_NAME    varchar(90);
	declare TABLES_CURSOR cursor for
	select vwSqlTablesStreamed.TABLE_NAME
	  from      vwSqlTablesStreamed
	 inner join vwSqlTables
	         on vwSqlTables.TABLE_NAME = vwSqlTablesStreamed.TABLE_NAME + '_STREAM'
	order by vwSqlTablesStreamed.TABLE_NAME;

	open TABLES_CURSOR;
	fetch next from TABLES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @VIEW_NAME = 'vw' + @TABLE_NAME + '_STREAM';
		if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = @VIEW_NAME) begin -- then
			set @Command = 'Drop View dbo.' + @VIEW_NAME;
			print @Command;
			exec(@Command);
		end -- if;

		fetch next from TABLES_CURSOR into @TABLE_NAME;
	end -- while;
	close TABLES_CURSOR;
	deallocate TABLES_CURSOR;

	set @VIEW_NAME = 'vwACTIVITY_STREAMS';
	if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = @VIEW_NAME) begin -- then
		set @Command = 'Drop View dbo.' + @VIEW_NAME;
		print @Command;
		exec(@Command);
	end -- if;
  end
GO


Grant Execute on dbo.spSqlDropAllStreamViews to public;
GO

-- exec dbo.spSqlDropAllStreamViews;


