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
-- 10/02/2006 Paul.  Fix name of foreign key from FK_ACCOUNTS_CASES_BUG_ID to FK_ACCOUNTS_CASES_CASE_ID. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ACCOUNTS_OPPORTUNITIES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.ACCOUNTS_OPPORTUNITIES';
	Create Table dbo.ACCOUNTS_OPPORTUNITIES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_ACCOUNTS_OPPORTUNITIES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, OPPORTUNITY_ID                     uniqueidentifier not null
		, ACCOUNT_ID                         uniqueidentifier not null
		)

	-- 09/10/2009 Paul.  The indexes should be fully covered. 
	create index IDX_ACCOUNTS_OPPORTUNITIES_ACCOUNT_ID                on dbo.ACCOUNTS_OPPORTUNITIES (ACCOUNT_ID    , DELETED, OPPORTUNITY_ID)
	create index IDX_ACCOUNTS_OPPORTUNITIES_OPPORTUNITY_ID            on dbo.ACCOUNTS_OPPORTUNITIES (OPPORTUNITY_ID, DELETED, ACCOUNT_ID    )
	-- create index IDX_ACCOUNTS_OPPORTUNITIES_OPPORTUNITY_ID_ACCOUNT_ID on dbo.ACCOUNTS_OPPORTUNITIES (OPPORTUNITY_ID, ACCOUNT_ID, DELETED)

	alter table dbo.ACCOUNTS_OPPORTUNITIES add constraint FK_ACCOUNTS_OPPORTUNITIES_ACCOUNT_ID     foreign key ( ACCOUNT_ID     ) references dbo.ACCOUNTS      ( ID )
	alter table dbo.ACCOUNTS_OPPORTUNITIES add constraint FK_ACCOUNTS_OPPORTUNITIES_OPPORTUNITY_ID foreign key ( OPPORTUNITY_ID ) references dbo.OPPORTUNITIES ( ID )
  end
GO


