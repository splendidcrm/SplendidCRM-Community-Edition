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
-- 03/28/2010 Paul.  Exchange Web Services returns dates in local time, so lets store both local time and UTC time. 
-- 03/28/2010 Paul.  REMOTE_KEY does not need to be an nvarchar.  
-- 04/01/2010 Paul.  Add the MODULE_NAME so that the LastModifiedTime can be filtered by module. 
-- 04/04/2010 Paul.  Add PARENT_ID so that the LastModifiedTime can be filtered by record. 
-- 07/24/2010 Paul.  Instead of managing collation in code, it is better to change the collation on the field in the database. 
-- 08/31/2010 Paul.  The EMAILS_SYNC table was renamed to EMAIL_CLIENT_SYNC to prevent conflict with Offline Client sync tables. 
-- drop table EMAIL_CLIENT_SYNC;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAIL_CLIENT_SYNC' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.EMAIL_CLIENT_SYNC';
	Create Table dbo.EMAIL_CLIENT_SYNC
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_EMAIL_CLIENT_SYNC primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier not null
		, LOCAL_ID                           uniqueidentifier not null
		, REMOTE_KEY                         varchar(800) collate SQL_Latin1_General_CP1_CS_AS not null
		, MODULE_NAME                        nvarchar(25) null
		, PARENT_ID                          uniqueidentifier null
		, LOCAL_DATE_MODIFIED                datetime null
		, REMOTE_DATE_MODIFIED               datetime null
		, LOCAL_DATE_MODIFIED_UTC            datetime null
		, REMOTE_DATE_MODIFIED_UTC           datetime null
		)

	-- drop index IDX_EMAIL_CLIENT_SYNC_REMOTE_KEY on dbo.EMAIL_CLIENT_SYNC
	create index IDX_EMAIL_CLIENT_SYNC_DATE_MODIFIED on dbo.EMAIL_CLIENT_SYNC (ASSIGNED_USER_ID, DELETED, MODULE_NAME, PARENT_ID, REMOTE_DATE_MODIFIED_UTC)
	create index IDX_EMAIL_CLIENT_SYNC_REMOTE_KEY    on dbo.EMAIL_CLIENT_SYNC (ASSIGNED_USER_ID, DELETED, REMOTE_KEY, LOCAL_ID)
  end
GO

