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
-- 04/21/2006 Paul.  Added in SugarCRM 4.2.
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 09/10/2012 Paul.  Add PRIMARY_SIGNATURE. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'USERS_SIGNATURES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.USERS_SIGNATURES';
	Create Table dbo.USERS_SIGNATURES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_USERS_SIGNATURES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, USER_ID                            uniqueidentifier null
		, NAME                               nvarchar(255) null
		, SIGNATURE                          nvarchar(max) null
		, SIGNATURE_HTML                     nvarchar(max) null
		, PRIMARY_SIGNATURE                  bit null
		)

	create index IDX_USERS_SIGNATURES_USER_ID on dbo.USERS_SIGNATURES (USER_ID)

	alter table dbo.USERS_SIGNATURES add constraint FK_USERS_SIGNATURES_USER_ID foreign key ( USER_ID ) references dbo.USERS ( ID )
  end
GO


