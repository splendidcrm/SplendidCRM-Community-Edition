if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildAllStreamData' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildAllStreamData;
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
-- 04/23/2017 Paul. Don't populate stream tables if streaming has been disabled. 
-- 09/25/2017 Paul.  Archive tables are not audited. 
Create Procedure dbo.spSqlBuildAllStreamData
as
  begin
	set nocount on
	print N'spSqlBuildAllStreamData';

	declare @ENABLE_ACTIVITY_STREAMS bit;
	declare @TABLE_NAME varchar(80);
	declare TABLES_CURSOR cursor for
	select vwSqlTablesStreamed.TABLE_NAME
	  from      vwSqlTablesStreamed
	 inner join vwSqlTables
	         on vwSqlTables.TABLE_NAME = vwSqlTablesStreamed.TABLE_NAME + '_STREAM'
	order by vwSqlTablesStreamed.TABLE_NAME;
	
	-- 10/30/2015 Paul.  Exclude EMAILS table because there are separate relationship tables where the parent info is also stored. 
	-- If we include EMAILS Parent events then we would get 2 activity records for each email. 
	-- 01/15/2018 Paul.  Exclude NAICS and PROCESSES. 
	declare PARENT_TABLES_CURSOR cursor for
	select TABLE_NAME
	  from INFORMATION_SCHEMA.COLUMNS
	 where COLUMN_NAME = 'PARENT_ID'
	   and TABLE_NAME not like 'vw%'
	   and TABLE_NAME not like '%[_]AUDIT'
	   and TABLE_NAME not like '%[_]ARCHIVE'
	   and TABLE_NAME not like '%[_]SYNC'
	   and TABLE_NAME not like 'WORKFLOW[_]%'
	   and TABLE_NAME not in ('EMAILS', 'EMAIL_IMAGES', 'IMAGES', 'PHONE_NUMBERS', 'PROJECT_TASK', 'SUBSCRIPTIONS', 'CHAT_MESSAGES')
	   and TABLE_NAME not in ('EXCHANGE_FOLDERS', 'PRODUCT_PRODUCT', 'PRODUCT_CATEGORIES', 'LINKED_DOCUMENTS', 'SURVEY_RESULTS', 'TIME_PERIODS', 'WORKFLOW')
	   and TABLE_NAME not in ('NAICS_CODE_SETS', 'NAICS_CODES_RELATED', 'PROCESSES', 'PROCESSES_OPTOUT')
	 order by TABLE_NAME;

	-- 04/23/2017 Paul. Don't populate stream tables if streaming has been disabled. 
	select top 1 @ENABLE_ACTIVITY_STREAMS = (case lower(convert(nvarchar(20), VALUE)) when '1' then 1 when 'true' then 1 else 0 end)
	  from CONFIG
	 where NAME = 'enable_activity_streams'
	   and DELETED = 0;

	if @ENABLE_ACTIVITY_STREAMS = 1 begin -- then
		open TABLES_CURSOR;
		fetch next from TABLES_CURSOR into @TABLE_NAME;
		while @@FETCH_STATUS = 0 begin -- do
			exec dbo.spSqlBuildStreamData           @TABLE_NAME;
			exec dbo.spSqlBuildStreamLinkDataTables @TABLE_NAME;
			fetch next from TABLES_CURSOR into @TABLE_NAME;
		end -- while;
		close TABLES_CURSOR;
	
		open PARENT_TABLES_CURSOR;
		fetch next from PARENT_TABLES_CURSOR into @TABLE_NAME;
		while @@FETCH_STATUS = 0 begin -- do
			exec dbo.spSqlBuildStreamParentData @TABLE_NAME;
			fetch next from PARENT_TABLES_CURSOR into @TABLE_NAME;
		end -- while;
		close PARENT_TABLES_CURSOR;
	end -- if;
	-- 06/23/2017 Paul.  Deallocate must be outside the if clause. 
	deallocate TABLES_CURSOR;
	deallocate PARENT_TABLES_CURSOR;
  end
GO


Grant Execute on dbo.spSqlBuildAllStreamData to public;
GO

-- exec dbo.spSqlBuildAllStreamData ;

