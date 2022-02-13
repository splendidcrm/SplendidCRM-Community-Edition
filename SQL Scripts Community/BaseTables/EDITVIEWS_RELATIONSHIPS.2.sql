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
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EDITVIEWS_RELATIONSHIPS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.EDITVIEWS_RELATIONSHIPS';
	Create Table dbo.EDITVIEWS_RELATIONSHIPS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_EDITVIEWS_RELATIONSHIPS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, EDIT_NAME                          nvarchar( 50) not null
		, MODULE_NAME                        nvarchar( 50) null
		, CONTROL_NAME                       nvarchar(100) null
		, RELATIONSHIP_ORDER                 int null
		, RELATIONSHIP_ENABLED               bit null default(1)
		, NEW_RECORD_ENABLED                 bit null
		, EXISTING_RECORD_ENABLED            bit null
		, TITLE                              nvarchar(100) null
		, ALTERNATE_VIEW                     nvarchar( 50) null
		)

	create index IDX_EDITVIEWS_RELATIONSHIPS_EDIT_NAME on dbo.EDITVIEWS_RELATIONSHIPS (EDIT_NAME, DELETED, RELATIONSHIP_ENABLED)
  end
GO

