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
-- drop table NAICS_CODE_SETS;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'NAICS_CODE_SETS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.NAICS_CODE_SETS';
	Create Table dbo.NAICS_CODE_SETS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_NAICS_CODE_SETS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, PARENT_ID                          uniqueidentifier not null
		, PARENT_MODULE                      nvarchar(50) not null
		, NAICS_SET_LIST                     varchar(851) null
		, NAICS_SET_NAME                     varchar(851) null
		)

	create index IDX_NAICS_CODE_SETS_ID              on dbo.NAICS_CODE_SETS (ID, DELETED)
	create index IDX_NAICS_CODE_SETS_NAICS_SET_NAME  on dbo.NAICS_CODE_SETS (PARENT_ID, NAICS_SET_NAME, DELETED, ID)
  end
GO

