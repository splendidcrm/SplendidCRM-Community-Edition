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
-- REMOTE_HOST   = Request.UserHostName
-- SERVER_HOST   = Request.Url.Host
-- TARGET        = Request.Path
-- RELATIVE_PATH = Request.AppRelativeCurrentExecutionFilePath
-- PARAMETERS    = Request.QueryString.ToString()
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- drop table SYSTEM_LOG;
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'SYSTEM_LOG' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.SYSTEM_LOG';
	Create Table dbo.SYSTEM_LOG
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_SYSTEM_LOG primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, USER_ID                            uniqueidentifier null
		, USER_NAME                          nvarchar(255) null
		, MACHINE                            nvarchar(60) null
		, ASPNET_SESSIONID                   nvarchar(50) null
		, REMOTE_HOST                        nvarchar(100) null
		, SERVER_HOST                        nvarchar(100) null
		, TARGET                             nvarchar(255) null
		, RELATIVE_PATH                      nvarchar(255) null
		, PARAMETERS                         nvarchar(2000) null

		, ERROR_TYPE                         nvarchar(25) null
		, FILE_NAME                          nvarchar(255) null
		, METHOD                             nvarchar(450) null
		, LINE_NUMBER                        int null
		, MESSAGE                            nvarchar(max) null
		)

	create index IDX_SYSTEM_LOG        on dbo.SYSTEM_LOG (DATE_ENTERED, ID)
	create index IDX_SYSTEM_LOG_METHOD on dbo.SYSTEM_LOG (METHOD)
  end
GO

