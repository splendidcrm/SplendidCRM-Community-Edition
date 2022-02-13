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
-- 07/16/2005 Paul.  Version 3.0.1 increased the size of the NEXT_STEP field. 
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 12/25/2007 Paul.  CAMPAIGN_ID was added in SugarCRM 4.5.1
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 10/05/2010 Paul.  Increase the size of the NAME field. 
-- 05/01/2013 Paul.  Add Contacts field to support B2C. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'OPPORTUNITIES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.OPPORTUNITIES';
	Create Table dbo.OPPORTUNITIES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_OPPORTUNITIES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier null
		, TEAM_ID                            uniqueidentifier null
		, OPPORTUNITY_NUMBER                 nvarchar(30) null
		, NAME                               nvarchar(150) null
		, OPPORTUNITY_TYPE                   nvarchar(255) null
		, LEAD_SOURCE                        nvarchar(50) null
		, AMOUNT                             money null
		, AMOUNT_BACKUP                      nvarchar(25) null
		, AMOUNT_USDOLLAR                    money null
		, CURRENCY_ID                        uniqueidentifier null
		, DATE_CLOSED                        datetime null
		, NEXT_STEP                          nvarchar(100) null
		, SALES_STAGE                        nvarchar(25) null
		, PROBABILITY                        float null
		, DESCRIPTION                        nvarchar(max) null
		, CAMPAIGN_ID                        uniqueidentifier null
		, TEAM_SET_ID                        uniqueidentifier null
		, ASSIGNED_SET_ID                    uniqueidentifier null
		, B2C_CONTACT_ID                     uniqueidentifier null
		)

	create index IDX_OPPORTUNITIES_NAME             on dbo.OPPORTUNITIES (NAME, DELETED, ID)
	create index IDX_OPPORTUNITIES_ASSIGNED_USER_ID on dbo.OPPORTUNITIES (ASSIGNED_USER_ID, DELETED, ID)
	create index IDX_OPPORTUNITIES_TEAM_ID          on dbo.OPPORTUNITIES (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_OPPORTUNITIES_TEAM_SET_ID      on dbo.OPPORTUNITIES (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
	-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	create index IDX_OPPORTUNITIES_ASSIGNED_SET_ID  on dbo.OPPORTUNITIES (ASSIGNED_SET_ID, DELETED, ID)
	create index IDX_OPPORTUNITIES_CAMPAIGN_ID      on dbo.OPPORTUNITIES (CAMPAIGN_ID, SALES_STAGE, DELETED, AMOUNT)
  end
GO


