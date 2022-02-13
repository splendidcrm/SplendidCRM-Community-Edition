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
-- 04/13/2012 Paul.  Facebook has a 111 character access token. 
-- 09/05/2015 Paul.  Google now uses OAuth 2.0. 
-- 01/19/2017 Paul.  The Microsoft OAuth token can be large, but less than 2000 bytes. 
-- 12/02/2020 Paul.  The Microsoft OAuth token is now about 2400, so increase to 4000 characters.
-- drop table dbo.OAUTH_TOKENS;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'OAUTH_TOKENS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.OAUTH_TOKENS';
	Create Table dbo.OAUTH_TOKENS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_OAUTH_TOKENS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier null
		, NAME                               nvarchar(50) null
		, TOKEN                              nvarchar(4000) null
		, SECRET                             nvarchar(50) null
		, TOKEN_EXPIRES_AT                   datetime null
		, REFRESH_TOKEN                      nvarchar(4000) null
		)

	create index IDX_OAUTH_TOKENS on dbo.OAUTH_TOKENS (ASSIGNED_USER_ID, NAME, DELETED)
  end
GO


