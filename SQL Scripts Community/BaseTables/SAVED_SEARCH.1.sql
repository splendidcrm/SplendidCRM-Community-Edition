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
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 09/01/2010 Paul.  Store a copy of the DEFAULT_SEARCH_ID in the table so that we don't need to read the XML in order to get the value. 
-- 09/01/2010 Paul.  We also need a separate module-only field so that the query will get all records for the module. 
-- 09/02/1010 Paul.  Adding the default search caused lots of problems, so we are going to ignore the fields for now. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'SAVED_SEARCH' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.SAVED_SEARCH';
	Create Table dbo.SAVED_SEARCH
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_SAVED_SEARCH primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier null
		, DEFAULT_SEARCH_ID                  uniqueidentifier null
		, NAME                               nvarchar(150) null
		, SEARCH_MODULE                      nvarchar(150) null
		, CONTENTS                           nvarchar(max) null
		, DESCRIPTION                        nvarchar(max) null
		)

	create index IDX_SAVED_SEARCH on dbo.SAVED_SEARCH (ASSIGNED_USER_ID, SEARCH_MODULE, NAME, DELETED, ID)
  end
GO


