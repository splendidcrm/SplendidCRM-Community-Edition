if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildAllStreamParentTriggers' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildAllStreamParentTriggers;
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
-- 07/31/2017 Paul.  Exclude NAICS_CODE_SETS. 
-- 09/25/2017 Paul.  Archive tables are not audited. 
Create Procedure dbo.spSqlBuildAllStreamParentTriggers
as
  begin
	set nocount on
	print N'spSqlBuildAllStreamParentTriggers';

	-- 10/30/2015 Paul.  Exclude EMAILS table because there are separate relationship tables where the parent info is also stored. 
	-- If we include EMAILS Parent events then we would get 2 activity records for each email. 
	-- 01/15/2018 Paul.  Exclude NAICS and PROCESSES. 
	declare @TABLE_NAME varchar(80);
	declare TABLES_CURSOR cursor for
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
	
	open TABLES_CURSOR;
	fetch next from TABLES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		exec dbo.spSqlBuildStreamParentTrigger @TABLE_NAME;
		fetch next from TABLES_CURSOR into @TABLE_NAME;
	end -- while;
	close TABLES_CURSOR;
	deallocate TABLES_CURSOR;
  end
GO


Grant Execute on dbo.spSqlBuildAllStreamParentTriggers to public;
GO

-- exec dbo.spSqlBuildAllStreamParentTriggers ;

