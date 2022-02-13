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
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CALL_MARKETING_PROSPECT_LISTS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.CALL_MARKETING_PROSPECT_LISTS';
	Create Table dbo.CALL_MARKETING_PROSPECT_LISTS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_CALL_MARKETING_PROSPECT_LISTS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, PROSPECT_LIST_ID                   uniqueidentifier null
		, CALL_MARKETING_ID                  uniqueidentifier null
		)

	create index IDX_CALL_MARKETING_PROSPECT_LISTS_CALL_MARKETING_ID on dbo.CALL_MARKETING_PROSPECT_LISTS (CALL_MARKETING_ID, DELETED, PROSPECT_LIST_ID )
	create index IDX_CALL_MARKETING_PROSPECT_LISTS_PROSPECT_LIST_ID  on dbo.CALL_MARKETING_PROSPECT_LISTS (PROSPECT_LIST_ID , DELETED, CALL_MARKETING_ID)

	alter table dbo.CALL_MARKETING_PROSPECT_LISTS add constraint FK_CALL_MARKETING_PROSPECT_LISTS_PROSPECT_LIST_ID  foreign key ( PROSPECT_LIST_ID  ) references dbo.PROSPECT_LISTS ( ID )
	alter table dbo.CALL_MARKETING_PROSPECT_LISTS add constraint FK_CALL_MARKETING_PROSPECT_LISTS_CALL_MARKETING_ID foreign key ( CALL_MARKETING_ID ) references dbo.CALL_MARKETING ( ID )
  end
GO

