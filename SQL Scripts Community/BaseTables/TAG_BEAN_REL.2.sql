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
-- drop table TAG_BEAN_REL;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TAG_BEAN_REL' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.TAG_BEAN_REL';
	Create Table dbo.TAG_BEAN_REL
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_TAG_BEAN_REL primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, TAG_ID                             uniqueidentifier not null
		, BEAN_ID                            uniqueidentifier not null
		, BEAN_MODULE                        nvarchar(100) null
		)

	create index IDX_TAG_BEAN_REL on dbo.TAG_BEAN_REL (TAG_ID, BEAN_ID, DELETED)
  end
GO

