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
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PHONE_NUMBERS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.PHONE_NUMBERS';
	Create Table dbo.PHONE_NUMBERS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_PHONE_NUMBERS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, PARENT_ID                          uniqueidentifier not null
		, PARENT_TYPE                        nvarchar(25) null
		, PHONE_TYPE                         nvarchar(25) null
		, NORMALIZED_NUMBER                  nvarchar(50) null
		)
	-- 07/05/2012 Paul.  PHONE_TYPE values include 'Work', 'Home', 'Mobile', 'Fax', 'Other', 'Assistant', 'Office', 'Alternate'

	-- 07/05/2012 Paul.  When searching by parent, it is because we are going to insert a phone by type. 
	create index IDX_PHONE_NUMBERS_PARENT_ID  on dbo.PHONE_NUMBERS (PARENT_ID        , PHONE_TYPE , DELETED, NORMALIZED_NUMBER)
	-- 07/05/2012 Paul.  When searching by normalized number, it is because we are searching by parent type. 
	create index IDX_PHONE_NUMBERS_NORMALIZED on dbo.PHONE_NUMBERS (NORMALIZED_NUMBER, PARENT_TYPE, DELETED, PARENT_ID)
  end
GO

