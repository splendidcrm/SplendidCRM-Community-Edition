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
-- 04/21/2006 Paul.  Added in SugarCRM 4.0.1.
-- 12/25/2007 Paul.  CAMPAIGN_DATA was added in SugarCRM 4.5.1
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAILS_LEADS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.EMAILS_LEADS';
	Create Table dbo.EMAILS_LEADS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_EMAILS_LEADS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, EMAIL_ID                           uniqueidentifier not null
		, LEAD_ID                            uniqueidentifier not null
		, CAMPAIGN_DATA                      nvarchar(max) null
		)

	-- 09/10/2009 Paul.  The indexes should be fully covered. 
	create index IDX_EMAILS_LEADS_EMAIL_ID on dbo.EMAILS_LEADS (EMAIL_ID, DELETED, LEAD_ID )
	create index IDX_EMAILS_LEADS_LEAD_ID  on dbo.EMAILS_LEADS (LEAD_ID , DELETED, EMAIL_ID)

	alter table dbo.EMAILS_LEADS add constraint FK_EMAILS_LEADS_EMAIL_ID foreign key ( EMAIL_ID ) references dbo.EMAILS ( ID )
	alter table dbo.EMAILS_LEADS add constraint FK_EMAILS_LEADS_LEAD_ID  foreign key ( LEAD_ID  ) references dbo.LEADS  ( ID )
  end
GO


