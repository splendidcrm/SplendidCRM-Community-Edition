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
-- 04/21/2006 Paul.  Added in SugarCRM 4.0.
-- 01/13/2008 Paul.  Change index to include the date so that it will be a covered index. 
-- 01/13/2008 Paul.  Add the reply name so that this lis can be used by the email manager. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'INBOUND_EMAIL_AUTOREPLY' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.INBOUND_EMAIL_AUTOREPLY';
	Create Table dbo.INBOUND_EMAIL_AUTOREPLY
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_INBOUND_EMAIL_AUTOREPLY primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, AUTOREPLIED_TO                     nvarchar(100) null
		, AUTOREPLIED_NAME                   nvarchar(100) null
		)

	create index IDX_INBOUND_EMAIL on dbo.INBOUND_EMAIL_AUTOREPLY (AUTOREPLIED_TO, DATE_ENTERED, DELETED, AUTOREPLIED_NAME)
  end
GO

