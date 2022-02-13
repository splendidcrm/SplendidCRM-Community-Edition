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
-- drop table NAICS_CODES_RELATED;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'NAICS_CODES_RELATED' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.NAICS_CODES_RELATED';
	Create Table dbo.NAICS_CODES_RELATED
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_NAICS_CODES_RELATED primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, NAICS_CODE_ID                      uniqueidentifier not null
		, PARENT_ID                          uniqueidentifier not null
		, PARENT_MODULE                      nvarchar(50) null
		)

	create index IDX_NAICS_CODES_RELATED on dbo.NAICS_CODES_RELATED (NAICS_CODE_ID, PARENT_ID, DELETED)
  end
GO

