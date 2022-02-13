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
-- 11/18/2006 Paul.  Create a covered index that will be heavily used when updating implicit team memberships. 
-- 11/18/2006 Paul.  Create a covered index that will be heavily used when modifying the organizational tree. 
-- 11/18/2006 Paul.  Add private flag.  We need to be able to isolate the user that started the private team. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TEAM_MEMBERSHIPS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.TEAM_MEMBERSHIPS';
	Create Table dbo.TEAM_MEMBERSHIPS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_TEAM_MEMBERSHIPS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, TEAM_ID                            uniqueidentifier not null
		, USER_ID                            uniqueidentifier not null
		, EXPLICIT_ASSIGN                    bit null
		, IMPLICIT_ASSIGN                    bit null
		, PRIVATE                            bit null default(0)
		)

	alter table dbo.TEAM_MEMBERSHIPS add constraint FK_TEAM_MEMBERSHIPS_TEAM_ID foreign key ( TEAM_ID ) references dbo.TEAMS ( ID )
	alter table dbo.TEAM_MEMBERSHIPS add constraint FK_TEAM_MEMBERSHIPS_USER_ID foreign key ( USER_ID ) references dbo.USERS ( ID )

	create index IDX_TEAM_MEMBERSHIPS_EXPLICIT on dbo.TEAM_MEMBERSHIPS (TEAM_ID, EXPLICIT_ASSIGN, DELETED, USER_ID)
	-- 09/10/2009 Paul.  The indexes should be fully covered. 
	create index IDX_TEAM_MEMBERSHIPS_TEAM_ID  on dbo.TEAM_MEMBERSHIPS (TEAM_ID, DELETED, USER_ID, ID)
	-- 09/10/2009 Paul.  Include the PRIVATE field as it is used during login. 
	create index IDX_TEAM_MEMBERSHIPS_USER_ID  on dbo.TEAM_MEMBERSHIPS (USER_ID, DELETED, TEAM_ID, ID, PRIVATE)
  end
GO

