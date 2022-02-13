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
-- 04/21/2006 Paul.  TITLE was increased to nvarchar(50) in SugarCRM 4.0.
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 12/25/2007 Paul.  CAMPAIGN_ID was added in SugarCRM 4.5.1
-- 03/05/2009 Paul.  Add PORTAL_PASSWORD for Splendid Portal.  Sugar added it in 4.5.0. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 10/16/2011 Paul.  Increase size of SALUTATION, FIRST_NAME and LAST_NAME to match SugarCRM. 
-- 09/27/2013 Paul.  SMS messages need to be opt-in. 
-- 10/22/2013 Paul.  Provide a way to map Tweets to a parent. 
-- 05/24/2015 Paul.  Add Picture. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 06/23/2018 Paul.  Add DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CONTACTS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.CONTACTS';
	Create Table dbo.CONTACTS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_CONTACTS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier null
		, TEAM_ID                            uniqueidentifier null
		, CONTACT_NUMBER                     nvarchar(30) null
		, SALUTATION                         nvarchar(25) null
		, FIRST_NAME                         nvarchar(100) null
		, LAST_NAME                          nvarchar(100) null
		, LEAD_SOURCE                        nvarchar(100) null
		, TITLE                              nvarchar(50) null
		, DEPARTMENT                         nvarchar(100) null
		, REPORTS_TO_ID                      uniqueidentifier null
		, BIRTHDATE                          datetime null
		, DO_NOT_CALL                        bit null default(0)
		, PHONE_HOME                         nvarchar(25) null
		, PHONE_MOBILE                       nvarchar(25) null
		, PHONE_WORK                         nvarchar(25) null
		, PHONE_OTHER                        nvarchar(25) null
		, PHONE_FAX                          nvarchar(25) null
		, EMAIL1                             nvarchar(100) null
		, EMAIL2                             nvarchar(100) null
		, ASSISTANT                          nvarchar(75) null
		, ASSISTANT_PHONE                    nvarchar(25) null
		, EMAIL_OPT_OUT                      bit null default(0)
		, INVALID_EMAIL                      bit null default(0)
		, SMS_OPT_IN                         nvarchar(25) null
		, TWITTER_SCREEN_NAME                nvarchar(20) null
		, PRIMARY_ADDRESS_STREET             nvarchar(150) null
		, PRIMARY_ADDRESS_CITY               nvarchar(100) null
		, PRIMARY_ADDRESS_STATE              nvarchar(100) null
		, PRIMARY_ADDRESS_POSTALCODE         nvarchar(20) null
		, PRIMARY_ADDRESS_COUNTRY            nvarchar(100) null
		, ALT_ADDRESS_STREET                 nvarchar(150) null
		, ALT_ADDRESS_CITY                   nvarchar(100) null
		, ALT_ADDRESS_STATE                  nvarchar(100) null
		, ALT_ADDRESS_POSTALCODE             nvarchar(20) null
		, ALT_ADDRESS_COUNTRY                nvarchar(100) null
		, DESCRIPTION                        nvarchar(max) null
		, PORTAL_NAME                        nvarchar(255) null
		, PORTAL_PASSWORD                    nvarchar(32) null
		, PORTAL_ACTIVE                      bit not null default(0)
		, PORTAL_APP                         nvarchar(255) null
		, CAMPAIGN_ID                        uniqueidentifier null
		, TEAM_SET_ID                        uniqueidentifier null
		, ASSIGNED_SET_ID                    uniqueidentifier null
		, PICTURE                            nvarchar(max) null
		, DP_BUSINESS_PURPOSE                nvarchar(max) null
		, DP_CONSENT_LAST_UPDATED            datetime null
		)

	-- 03/10/2016 Paul.  Re-order list of indexes as only 7 will be created on in-memory database. 
	-- 09/07/2009 Paul.  The vwACCOUNTS_List view joins to contacts and returns the full contact name. 
	create index IDX_CONTACTS_LAST_NAME_FIRST_NAME    on dbo.CONTACTS (LAST_NAME, FIRST_NAME, DELETED, ID)
	-- 10/24/2009 Paul.  Searching by first name is popular. 
	create index IDX_CONTACTS_FIRST_NAME_LAST_NAME    on dbo.CONTACTS (FIRST_NAME, LAST_NAME, DELETED, ID)
	create index IDX_CONTACTS_ASSIGNED_USER_ID        on dbo.CONTACTS (ASSIGNED_USER_ID, DELETED, ID)
	create index IDX_CONTACTS_TEAM_ID                 on dbo.CONTACTS (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_CONTACTS_TEAM_SET_ID             on dbo.CONTACTS (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
	-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	create index IDX_CONTACTS_ASSIGNED_SET_ID         on dbo.CONTACTS (ASSIGNED_SET_ID, DELETED, ID)
	create index IDX_CONTACTS_EMAIL1                  on dbo.CONTACTS (EMAIL1, DELETED, ID)
	create index IDX_CONTACTS_PORTAL                  on dbo.CONTACTS (DELETED, PORTAL_ACTIVE, PORTAL_NAME, PORTAL_PASSWORD)
	create index IDX_CONTACTS_EMAIL2                  on dbo.CONTACTS (EMAIL2, DELETED, ID)
	-- 10/22/2013 Paul.  An index is necessary for quick mapping to tweets. 
	create index IDX_CONTACTS_TWITTER_SCREEN          on dbo.CONTACTS (TWITTER_SCREEN_NAME, DELETED, ID)
	create index IDX_CONTACTS_ID_LAST_FIRST           on dbo.CONTACTS (ID, DELETED, LAST_NAME, FIRST_NAME)
	create index IDX_CONTACTS_LAST_NAME               on dbo.CONTACTS (LAST_NAME, DELETED, ID)
	create index IDX_CONTACTS_REPORTS_TO_ID_LAST_NAME on dbo.CONTACTS (REPORTS_TO_ID, LAST_NAME, DELETED, ID)
  end
GO


