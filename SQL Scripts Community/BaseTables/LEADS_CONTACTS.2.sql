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
-- 08/07/2015 Paul.  Add Leads/Contacts relationship. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LEADS_CONTACTS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.LEADS_CONTACTS';
	Create Table dbo.LEADS_CONTACTS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_LEADS_CONTACTS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, CONTACT_ID                         uniqueidentifier not null
		, LEAD_ID                            uniqueidentifier not null
		)

	create index IDX_LEADS_CONTACTS_LEAD_ID    on dbo.LEADS_CONTACTS (LEAD_ID, DELETED, CONTACT_ID)
	create index IDX_LEADS_CONTACTS_CONTACT_ID on dbo.LEADS_CONTACTS (CONTACT_ID, DELETED, LEAD_ID)

	alter table dbo.LEADS_CONTACTS add constraint FK_LEADS_CONTACTS_LEAD_ID    foreign key ( LEAD_ID    ) references dbo.LEADS    ( ID )
	alter table dbo.LEADS_CONTACTS add constraint FK_LEADS_CONTACTS_CONTACT_ID foreign key ( CONTACT_ID ) references dbo.CONTACTS ( ID )
  end
GO


