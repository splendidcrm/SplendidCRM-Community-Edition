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
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'DOCUMENTS_BUGS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.DOCUMENTS_BUGS';
	Create Table dbo.DOCUMENTS_BUGS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_DOCUMENTS_BUGS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, BUG_ID                             uniqueidentifier not null
		, DOCUMENT_ID                        uniqueidentifier not null
		, DOCUMENT_REVISION_ID               uniqueidentifier not null
		)

	create index IDX_DOCUMENTS_BUGS_BUG_ID      on dbo.DOCUMENTS_BUGS (BUG_ID     , DELETED, DOCUMENT_ID, DOCUMENT_REVISION_ID)
	create index IDX_DOCUMENTS_BUGS_DOCUMENT_ID on dbo.DOCUMENTS_BUGS (DOCUMENT_ID, DELETED, BUG_ID)

	alter table dbo.DOCUMENTS_BUGS add constraint FK_DOCUMENTS_BUGS_BUG_ID               foreign key ( BUG_ID               ) references dbo.BUGS               ( ID )
	alter table dbo.DOCUMENTS_BUGS add constraint FK_DOCUMENTS_BUGS_DOCUMENT_ID          foreign key ( DOCUMENT_ID          ) references dbo.DOCUMENTS          ( ID )
	alter table dbo.DOCUMENTS_BUGS add constraint FK_DOCUMENTS_BUGS_DOCUMENT_REVISION_ID foreign key ( DOCUMENT_REVISION_ID ) references dbo.DOCUMENT_REVISIONS ( ID )
  end
GO

