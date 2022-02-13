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
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 12/25/2007 Paul.  EMBED_FLAG was added in SugarCRM 4.5.1
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
-- 02/11/2017 Paul.  New index based on missing indexes query. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'NOTES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.NOTES';
	Create Table dbo.NOTES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_NOTES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier null
		, TEAM_ID                            uniqueidentifier null
		, NAME                               nvarchar(255) null
		, FILENAME                           nvarchar(255) null
		, FILE_MIME_TYPE                     nvarchar(100) null
		, PARENT_TYPE                        nvarchar(25) null
		, PARENT_ID                          uniqueidentifier null
		, CONTACT_ID                         uniqueidentifier null
		, PORTAL_FLAG                        bit not null default(0)
		, EMBED_FLAG                         bit null default(0)
		, DESCRIPTION                        nvarchar(max) null
		, NOTE_ATTACHMENT_ID                 uniqueidentifier null
		, TEAM_SET_ID                        uniqueidentifier null
		, ASSIGNED_SET_ID                    uniqueidentifier null
		, IS_PRIVATE                         bit null
		)

	create index IDX_NOTES_NAME               on dbo.NOTES (NAME, DELETED, ID)
	create index IDX_NOTES_NAME_PARENT        on dbo.NOTES (PARENT_ID, PARENT_TYPE, DELETED, ID)
	create index IDX_NOTES_CONTACT_ID         on dbo.NOTES (CONTACT_ID, DELETED, ID)
	create index IDX_NOTES_NOTE_ATTACHMENT_ID on dbo.NOTES (NOTE_ATTACHMENT_ID, DELETED, ID)
	create index IDX_NOTES_TEAM_ID            on dbo.NOTES (TEAM_ID, DELETED, ID)
	create index IDX_NOTES_ASSIGNED_USER_ID   on dbo.NOTES (ASSIGNED_USER_ID, DELETED, ID)
	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_NOTES_TEAM_SET_ID        on dbo.NOTES (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
	-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	create index IDX_NOTES_ASSIGNED_SET_ID    on dbo.NOTES (ASSIGNED_SET_ID, DELETED, ID)
	-- 02/11/2017 Paul.  New index based on missing indexes query. 
	create index IDX_NOTES_DELETED_PARENT     on dbo.NOTES (DELETED, PARENT_TYPE, PARENT_ID, NOTE_ATTACHMENT_ID)
  end
GO


