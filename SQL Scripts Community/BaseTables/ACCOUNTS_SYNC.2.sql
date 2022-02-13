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
-- drop table ACCOUNTS_SYNC;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ACCOUNTS_SYNC' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.ACCOUNTS_SYNC';
	Create Table dbo.ACCOUNTS_SYNC
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_ACCOUNTS_SYNC primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier not null
		, LOCAL_ID                           uniqueidentifier not null
		, REMOTE_KEY                         varchar(800) collate SQL_Latin1_General_CP1_CS_AS not null
		, LOCAL_DATE_MODIFIED                datetime null
		, REMOTE_DATE_MODIFIED               datetime null
		, LOCAL_DATE_MODIFIED_UTC            datetime null
		, REMOTE_DATE_MODIFIED_UTC           datetime null
		, SERVICE_NAME                       nvarchar(25) null
		, RAW_CONTENT                        nvarchar(max) null
		)

	create index IDX_ACCOUNTS_SYNC_REMOTE_KEY on dbo.ACCOUNTS_SYNC (ASSIGNED_USER_ID, DELETED, SERVICE_NAME, REMOTE_KEY, LOCAL_ID)
  end
GO

