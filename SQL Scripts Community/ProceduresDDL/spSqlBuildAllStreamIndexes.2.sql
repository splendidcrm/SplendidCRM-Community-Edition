if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildAllStreamIndexes' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildAllStreamIndexes;
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
-- 07/31/2017 Paul.  Use unique name for cursor to help catch errors. 
Create Procedure dbo.spSqlBuildAllStreamIndexes
as
  begin
	set nocount on
	print N'spSqlBuildAllStreamIndexes';

	declare @TABLE_NAME varchar(80);
	declare STREAM_INDEX_TABLES_CURSOR cursor for
	select TABLE_NAME
	  from vwSqlTablesStreamed
	order by TABLE_NAME;
	
	open STREAM_INDEX_TABLES_CURSOR;
	fetch next from STREAM_INDEX_TABLES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		exec dbo.spSqlBuildStreamIndex @TABLE_NAME;
		fetch next from STREAM_INDEX_TABLES_CURSOR into @TABLE_NAME;
	end -- while;
	close STREAM_INDEX_TABLES_CURSOR;
	deallocate STREAM_INDEX_TABLES_CURSOR;
  end
GO


Grant Execute on dbo.spSqlBuildAllStreamIndexes to public;
GO

-- exec dbo.spSqlBuildAllStreamIndexes;




