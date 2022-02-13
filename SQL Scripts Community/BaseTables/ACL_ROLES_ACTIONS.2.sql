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
-- 04/21/2006 Paul.  Added in SugarCRM 4.0.
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ACL_ROLES_ACTIONS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.ACL_ROLES_ACTIONS';
	Create Table dbo.ACL_ROLES_ACTIONS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_ACL_ROLES_ACTIONS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ROLE_ID                            uniqueidentifier not null
		, ACTION_ID                          uniqueidentifier not null
		, ACCESS_OVERRIDE                    int null
		)

	create index IDX_ACL_ROLES_ACTIONS_ROLE_ID   on dbo.ACL_ROLES_ACTIONS (ROLE_ID  )
	create index IDX_ACL_ROLES_ACTIONS_ACTION_ID on dbo.ACL_ROLES_ACTIONS (ACTION_ID)

	alter table dbo.ACL_ROLES_ACTIONS add constraint FK_ACL_ROLES_ACTIONS_ROLE_ID   foreign key ( ROLE_ID   ) references dbo.ACL_ROLES   ( ID )
	alter table dbo.ACL_ROLES_ACTIONS add constraint FK_ACL_ROLES_ACTIONS_ACTION_ID foreign key ( ACTION_ID ) references dbo.ACL_ACTIONS ( ID )
  end
GO


