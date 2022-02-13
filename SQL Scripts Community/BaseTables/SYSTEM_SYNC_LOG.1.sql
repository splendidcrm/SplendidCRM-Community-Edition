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
-- drop table SYSTEM_SYNC_LOG;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'SYSTEM_SYNC_LOG' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.SYSTEM_SYNC_LOG';
	Create Table dbo.SYSTEM_SYNC_LOG
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_SYSTEM_SYNC_LOG primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, USER_ID                            uniqueidentifier null
		, MACHINE                            nvarchar(60) null
		, REMOTE_URL                         nvarchar(255) null

		, ERROR_TYPE                         nvarchar(25) null
		, FILE_NAME                          nvarchar(255) null
		, METHOD                             nvarchar(450) null
		, LINE_NUMBER                        int null
		, MESSAGE                            nvarchar(max) null
		)

	create index IDX_SYSTEM_SYNC_LOG        on dbo.SYSTEM_SYNC_LOG (DATE_ENTERED, ID)
  end
GO

