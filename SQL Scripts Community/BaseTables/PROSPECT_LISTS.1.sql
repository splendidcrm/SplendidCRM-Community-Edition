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
-- 04/21/2006 Paul.  LIST_TYPE was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  DOMAIN_NAME was added in SugarCRM 4.0.1.
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 01/09/2010 Paul.  A Dynamic List is one that uses SQL to build the prospect list. 
-- 01/14/2010 Paul.  Move DYNAMIC_SQL to a separate table so that it cannot be imported or exported. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROSPECT_LISTS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.PROSPECT_LISTS';
	Create Table dbo.PROSPECT_LISTS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_PROSPECT_LISTS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier null
		, TEAM_ID                            uniqueidentifier null
		, NAME                               nvarchar(50) null
		, DESCRIPTION                        nvarchar(max) null
		, LIST_TYPE                          nvarchar(25) null
		, DOMAIN_NAME                        nvarchar(255) null
		, DYNAMIC_LIST                       bit null default(0)
		, TEAM_SET_ID                        uniqueidentifier null
		, ASSIGNED_SET_ID                    uniqueidentifier null
		)

	create index IDX_PROSPECT_LISTS_NAME             on dbo.PROSPECT_LISTS (NAME, DELETED, ID)
	create index IDX_PROSPECT_LISTS_ASSIGNED_USER_ID on dbo.PROSPECT_LISTS (ASSIGNED_USER_ID, DELETED, ID)
	create index IDX_PROSPECT_LISTS_TEAM_ID          on dbo.PROSPECT_LISTS (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_PROSPECT_LISTS_TEAM_SET_ID      on dbo.PROSPECT_LISTS (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
	-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	create index IDX_PROSPECT_LISTS_ASSIGNED_SET_ID  on dbo.PROSPECT_LISTS (ASSIGNED_SET_ID, DELETED, ID)
  end
GO


