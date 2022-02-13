
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
-- 09/01/2010 Paul.  Store a copy of the DEFAULT_SEARCH_ID in the table so that we don't need to read the XML in order to get the value. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SAVED_SEARCH' and COLUMN_NAME = 'DEFAULT_SEARCH_ID') begin -- then
	print 'alter table SAVED_SEARCH add DEFAULT_SEARCH_ID uniqueidentifier null';
	alter table SAVED_SEARCH add DEFAULT_SEARCH_ID uniqueidentifier null;
end -- if;
GO

-- 09/01/2010 Paul.  We also need a separate module-only field so that the query will get all records for the module. 
/*
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SAVED_SEARCH' and COLUMN_NAME = 'MODULE') begin -- then
	print 'alter table SAVED_SEARCH add MODULE nvarchar(50) null';
	alter table SAVED_SEARCH add MODULE nvarchar(50) null;
	exec('update SAVED_SEARCH set MODULE = SEARCH_MODULE where MODULE is null and SEARCH_MODULE not like ''%.%''');
	exec('update SAVED_SEARCH set MODULE = substring(SEARCH_MODULE, 1, charindex(''.'', SEARCH_MODULE, 1) - 1) where MODULE is null and SEARCH_MODULE like ''%.%''');
	
	-- 09/01/2010 Paul.  The index has changed from including SEARCH_MODULE to including MODULE. 
	-- exec dbo.spSqlUpdateIndex 'IDX_SAVED_SEARCH', 'SAVED_SEARCH', 'ASSIGNED_USER_ID', 'MODULE', 'DELETED', 'ID';
end -- if;
*/

-- 09/02/1010 Paul.  Adding the default search caused lots of problems, so we are going to ignore the fields for now. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SAVED_SEARCH' and COLUMN_NAME = 'MODULE') begin -- then
	print 'alter table SAVED_SEARCH drop column MODULE';
	exec dbo.spSqlUpdateIndex 'IDX_SAVED_SEARCH', 'SAVED_SEARCH', 'ASSIGNED_USER_ID', 'SEARCH_MODULE', 'NAME', 'DELETED', 'ID';

	alter table SAVED_SEARCH drop column MODULE;
end -- if;
GO

