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
-- 04/21/2006 Paul.  RELATIONSHIP_ROLE_COLUMN_VALUE was increased to nvarchar(50) in SugarCRM 4.0.
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'RELATIONSHIPS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.RELATIONSHIPS';
	Create Table dbo.RELATIONSHIPS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_RELATIONSHIPS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, RELATIONSHIP_NAME                  nvarchar(150) null
		, LHS_MODULE                         nvarchar(100) null
		, LHS_TABLE                          nvarchar( 64) null
		, LHS_KEY                            nvarchar( 64) null
		, RHS_MODULE                         nvarchar(100) null
		, RHS_TABLE                          nvarchar( 64) null
		, RHS_KEY                            nvarchar( 64) null
		, JOIN_TABLE                         nvarchar( 64) null
		, JOIN_KEY_LHS                       nvarchar( 64) null
		, JOIN_KEY_RHS                       nvarchar( 64) null
		, RELATIONSHIP_TYPE                  nvarchar( 64) null
		, RELATIONSHIP_ROLE_COLUMN           nvarchar( 64) null
		, RELATIONSHIP_ROLE_COLUMN_VALUE     nvarchar( 50) null
		, REVERSE                            bit null default(0)
		)

	create index IDX_RELATIONSHIPS_NAME on dbo.RELATIONSHIPS (RELATIONSHIP_NAME)
  end
GO


