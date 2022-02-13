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
-- 03/23/2016 Paul.  Relationship used with OfficeAddin. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAILS_CONTRACTS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.EMAILS_CONTRACTS';
	Create Table dbo.EMAILS_CONTRACTS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_EMAILS_CONTRACTS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, EMAIL_ID                           uniqueidentifier not null
		, CONTRACT_ID                        uniqueidentifier not null
		, CAMPAIGN_DATA                      nvarchar(max) null
		)

	create index IDX_EMAILS_CONTRACTS_EMAIL_ID    on dbo.EMAILS_CONTRACTS (EMAIL_ID  , DELETED, CONTRACT_ID)
	create index IDX_EMAILS_CONTRACTS_CONTRACT_ID on dbo.EMAILS_CONTRACTS (CONTRACT_ID, DELETED, EMAIL_ID  )
  end
GO


