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
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CONTACTS_DOCUMENTS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.CONTACTS_DOCUMENTS';
	Create Table dbo.CONTACTS_DOCUMENTS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_CONTACTS_DOCUMENTS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, CONTACT_ID                        uniqueidentifier not null
		, DOCUMENT_ID                        uniqueidentifier not null
		, DOCUMENT_REVISION_ID               uniqueidentifier not null
		)

	-- 09/10/2009 Paul.  The indexes should be fully covered. 
	create index IDX_CONTACTS_DOCUMENTS_CONTACT_ID on dbo.CONTACTS_DOCUMENTS (CONTACT_ID, DELETED, DOCUMENT_ID, DOCUMENT_REVISION_ID)
	create index IDX_CONTACTS_DOCUMENTS_DOCUMENT_ID on dbo.CONTACTS_DOCUMENTS (DOCUMENT_ID, DELETED, CONTACT_ID)

	alter table dbo.CONTACTS_DOCUMENTS add constraint FK_CONTACTS_DOCUMENTS_CONTACT_ID          foreign key ( CONTACT_ID          ) references dbo.CONTACTS          ( ID )
	alter table dbo.CONTACTS_DOCUMENTS add constraint FK_CONTACTS_DOCUMENTS_DOCUMENT_ID          foreign key ( DOCUMENT_ID          ) references dbo.DOCUMENTS          ( ID )
	alter table dbo.CONTACTS_DOCUMENTS add constraint FK_CONTACTS_DOCUMENTS_DOCUMENT_REVISION_ID foreign key ( DOCUMENT_REVISION_ID ) references dbo.DOCUMENT_REVISIONS ( ID )
  end
GO

