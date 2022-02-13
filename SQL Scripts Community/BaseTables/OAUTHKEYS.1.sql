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
-- 04/09/2012 Paul.  Twitter has a 40 character verifier. 
-- 04/13/2012 Paul.  Facebook has a 111 character access token. 
-- drop table dbo.OAUTHKEYS;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'OAUTHKEYS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.OAUTHKEYS';
	Create Table dbo.OAUTHKEYS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_OAUTHKEYS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier null
		, NAME                               nvarchar(25) null
		, TOKEN                              nvarchar(200) null
		, SECRET                             nvarchar(50) null
		, VERIFIER                           nvarchar(50) null
		)

	create index IDX_OAUTHKEYS on dbo.OAUTHKEYS (ASSIGNED_USER_ID, NAME, DELETED)
  end
GO


