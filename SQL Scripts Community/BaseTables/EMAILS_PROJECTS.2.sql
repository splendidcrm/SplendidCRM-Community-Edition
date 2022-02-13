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
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAILS_PROJECTS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.EMAILS_PROJECTS';
	Create Table dbo.EMAILS_PROJECTS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_EMAILS_PROJECTS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, EMAIL_ID                           uniqueidentifier not null
		, PROJECT_ID                         uniqueidentifier not null
		)

	-- 09/10/2009 Paul.  The indexes should be fully covered. 
	create index IDX_EMAILS_PROJECTS_EMAIL_ID   on dbo.EMAILS_PROJECTS (EMAIL_ID  , DELETED, PROJECT_ID)
	create index IDX_EMAILS_PROJECTS_PROJECT_ID on dbo.EMAILS_PROJECTS (PROJECT_ID, DELETED, EMAIL_ID  )

	alter table dbo.EMAILS_PROJECTS add constraint FK_EMAILS_PROJECTS_EMAIL_ID   foreign key ( EMAIL_ID   ) references dbo.EMAILS  ( ID )
	alter table dbo.EMAILS_PROJECTS add constraint FK_EMAILS_PROJECTS_PROJECT_ID foreign key ( PROJECT_ID ) references dbo.PROJECT ( ID )
  end
GO


