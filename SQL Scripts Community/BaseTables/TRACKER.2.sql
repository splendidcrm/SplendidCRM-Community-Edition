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
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 03/08/2012 Paul.  Add ACTION to the tracker table so that we can create quick user activity reports. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TRACKER' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.TRACKER';
	Create Table dbo.TRACKER
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_TRACKER primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, USER_ID                            uniqueidentifier not null
		, ACTION                             nvarchar(25) null default('detailview')
		, MODULE_NAME                        nvarchar(25) null
		, ITEM_ID                            uniqueidentifier not null
		, ITEM_SUMMARY                       nvarchar(255) null
		)

	-- 03/08/2012 Paul.  Add ACTION to the tracker table so that we can create quick user activity reports. 
	create index IDX_TRACKER_USER_ID     on dbo.TRACKER (USER_ID, ACTION, DELETED)
	create index IDX_TRACKER_ITEM_ID     on dbo.TRACKER (ITEM_ID, ACTION, DELETED)
	-- 08/26/2010 Paul.  Add IDX_TRACKER_USER_MODULE to speed spTRACKER_Update. 
	create index IDX_TRACKER_USER_MODULE on dbo.TRACKER (USER_ID, ACTION, DELETED, MODULE_NAME, ID)

	-- 11/03/2009 Paul.  This foreign key will give us trouble on the offline client. 
	-- alter table dbo.TRACKER add constraint FK_TRACKER_USER_ID foreign key ( USER_ID ) references dbo.USERS ( ID )
  end
GO


