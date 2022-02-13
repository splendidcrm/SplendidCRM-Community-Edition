if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildStreamLinkDataTables' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildStreamLinkDataTables;
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
-- 05/24/2020 Paul.  Exclude AZURE_APP_UPDATES_ORDERS_AUDIT. 
Create Procedure dbo.spSqlBuildStreamLinkDataTables(@TABLE_NAME varchar(80))
as
  begin
	set nocount on
	print N'spSqlBuildStreamLinkDataTables ' + @TABLE_NAME;

	declare @LINK_TABLE_NAME    varchar(80);
	declare @RELATED_TABLE_NAME varchar(80);
	declare LEFT_TABLES_CURSOR cursor for
	select TABLE_NAME
	  from vwSqlTables
	 where TABLE_NAME     like @TABLE_NAME + '[_]%[_]AUDIT'
	   and TABLE_NAME not like @TABLE_NAME + '[_]CSTM[_]AUDIT'
	   and TABLE_NAME not like '%[_]RELATED[_]AUDIT'
	   and TABLE_NAME not like '%[_]USERS[_]AUDIT'
	   and TABLE_NAME not like '%[_]TEAMS[_]AUDIT'
	   and TABLE_NAME not like '%[_]SQL[_]AUDIT'
	   and TABLE_NAME not like '%[_]KBTAGS[_]AUDIT'
	   and TABLE_NAME not like '%[_]THREADS[_]AUDIT'
	   and TABLE_NAME not like '%[_]LINE[_]ITEMS[_]AUDIT'
	   and TABLE_NAME not like '%[_]LINE[_]ITEMS[_]CSTM[_]AUDIT'
	order by TABLE_NAME;

	open LEFT_TABLES_CURSOR;
	fetch next from LEFT_TABLES_CURSOR into @LINK_TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @LINK_TABLE_NAME = substring(@LINK_TABLE_NAME, 1, len(@LINK_TABLE_NAME) - 6);
		set @RELATED_TABLE_NAME = substring(@LINK_TABLE_NAME, len(@TABLE_NAME) + 2, len(@LINK_TABLE_NAME));
		-- print '	' + @LINK_TABLE_NAME + ', ' + @TABLE_NAME + ', ' + @RELATED_TABLE_NAME;
		exec dbo.spSqlBuildStreamLinkData @LINK_TABLE_NAME, @TABLE_NAME, @RELATED_TABLE_NAME
		fetch next from LEFT_TABLES_CURSOR into @LINK_TABLE_NAME;
	end -- while;
	close LEFT_TABLES_CURSOR;
	deallocate LEFT_TABLES_CURSOR;

	-- 09/29/2015 Paul.  Exclude CONTRACT_TYPES_DOCUMENTS as the information is not useful. 
	-- 10/26/2015 Paul.  Exclude AZURE_ORDERS as there is no AZURE table. 
	-- 05/24/2020 Paul.  Exclude AZURE_APP_UPDATES_ORDERS_AUDIT. 
	declare RIGHT_TABLES_CURSOR cursor for
	select TABLE_NAME
	  from vwSqlTables
	 where TABLE_NAME     like '%[_]' + @TABLE_NAME + '[_]AUDIT'
	   and TABLE_NAME not like '%[_]USERS[_]AUDIT'
	   and TABLE_NAME not like '%[_]TEAMS[_]AUDIT'
	   and TABLE_NAME not like '%[_]SQL[_]AUDIT'
	   and TABLE_NAME not like '%[_]KBTAGS[_]AUDIT'
	   and TABLE_NAME not like '%[_]THREADS[_]AUDIT'
	   and TABLE_NAME not like '%[_]LINE[_]ITEMS[_]AUDIT'
	   and TABLE_NAME not like '%[_]LINE[_]ITEMS[_]CSTM[_]AUDIT'
	   and TABLE_NAME not in ('CONTRACT_TYPES_DOCUMENTS_AUDIT', 'AZURE_ORDERS_AUDIT', 'AZURE_APP_UPDATES_ORDERS_AUDIT')
	order by TABLE_NAME;

	open RIGHT_TABLES_CURSOR;
	fetch next from RIGHT_TABLES_CURSOR into @LINK_TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @LINK_TABLE_NAME = substring(@LINK_TABLE_NAME, 1, len(@LINK_TABLE_NAME) - 6);
		set @RELATED_TABLE_NAME = substring(@LINK_TABLE_NAME, 1, len(@LINK_TABLE_NAME) - len(@TABLE_NAME) - 1);
		-- print '	' + @LINK_TABLE_NAME + ', ' + @RELATED_TABLE_NAME + ', ' + @TABLE_NAME;
		exec dbo.spSqlBuildStreamLinkData @LINK_TABLE_NAME, @TABLE_NAME, @RELATED_TABLE_NAME
		fetch next from RIGHT_TABLES_CURSOR into @LINK_TABLE_NAME;
	end -- while;
	close RIGHT_TABLES_CURSOR;
	deallocate RIGHT_TABLES_CURSOR;
  end
GO


Grant Execute on dbo.spSqlBuildStreamLinkDataTables to public;
GO

