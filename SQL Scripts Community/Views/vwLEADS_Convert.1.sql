if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwLEADS_Convert')
	Drop View dbo.vwLEADS_Convert;
GO


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
-- 09/10/2007 Paul.  CAMPAIGN_ID was added in SugarCRM 4.0 for campaign tracking. 
-- 09/10/2007 Paul.  Add TEAM_ID for team management. 
-- 11/03/2008 Paul.  Include TEAM_NAME and ASSIGNED_TO for use on the convert page. 
-- 08/30/2009 Paul.  All module views must have a TEAM_SET_ID. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/12/2010 Paul.  When creating an Account during the conversion, we need define the Billing and Shipping fields. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 04/02/2012 Paul.  Add ASSISTANT, ASSISTANT_PHONE, BIRTHDATE, WEBSITE. 
-- 06/05/2015 Paul.  Add PICTURE. 
-- 09/28/2015 Paul.  Add LEAD_SOURCE_DESCRIPTION. 
-- 03/31/2016 Paul.  Add DATE_MODIFIED_UTC. 
-- 04/26/2016 Paul.  Add STATUS. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 02/04/2020 Paul.  Add Tags module. 
Create View dbo.vwLEADS_Convert
as
select LEADS.ID
     , LEADS.SALUTATION
     , LEADS.FIRST_NAME
     , LEADS.LAST_NAME
     , LEADS.TITLE
     , LEADS.LEAD_SOURCE
     , LEADS.LEAD_SOURCE_DESCRIPTION
     , LEADS.DEPARTMENT
     , LEADS.DO_NOT_CALL
     , LEADS.PHONE_HOME
     , LEADS.PHONE_MOBILE
     , LEADS.PHONE_WORK
     , LEADS.PHONE_OTHER
     , LEADS.PHONE_FAX
     , LEADS.EMAIL1
     , LEADS.EMAIL2
     , LEADS.ASSISTANT
     , LEADS.ASSISTANT_PHONE
     , LEADS.EMAIL_OPT_OUT
     , LEADS.INVALID_EMAIL
     , LEADS.PRIMARY_ADDRESS_STREET
     , LEADS.PRIMARY_ADDRESS_CITY
     , LEADS.PRIMARY_ADDRESS_STATE
     , LEADS.PRIMARY_ADDRESS_POSTALCODE
     , LEADS.PRIMARY_ADDRESS_COUNTRY
     , LEADS.PRIMARY_ADDRESS_STREET     as BILLING_ADDRESS_STREET
     , LEADS.PRIMARY_ADDRESS_CITY       as BILLING_ADDRESS_CITY
     , LEADS.PRIMARY_ADDRESS_STATE      as BILLING_ADDRESS_STATE
     , LEADS.PRIMARY_ADDRESS_POSTALCODE as BILLING_ADDRESS_POSTALCODE
     , LEADS.PRIMARY_ADDRESS_COUNTRY    as BILLING_ADDRESS_COUNTRY
     , LEADS.ALT_ADDRESS_STREET
     , LEADS.ALT_ADDRESS_CITY
     , LEADS.ALT_ADDRESS_STATE
     , LEADS.ALT_ADDRESS_POSTALCODE
     , LEADS.ALT_ADDRESS_COUNTRY
     , LEADS.ALT_ADDRESS_STREET         as SHIPPING_ADDRESS_STREET
     , LEADS.ALT_ADDRESS_CITY           as SHIPPING_ADDRESS_CITY
     , LEADS.ALT_ADDRESS_STATE          as SHIPPING_ADDRESS_STATE
     , LEADS.ALT_ADDRESS_POSTALCODE     as SHIPPING_ADDRESS_POSTALCODE
     , LEADS.ALT_ADDRESS_COUNTRY        as SHIPPING_ADDRESS_COUNTRY
     , LEADS.ACCOUNT_NAME
     , LEADS.ASSIGNED_USER_ID
     , LEADS.ASSIGNED_SET_ID
     , LEADS.DATE_ENTERED
     , LEADS.DATE_MODIFIED
     , LEADS.DATE_MODIFIED_UTC
     , LEADS.DESCRIPTION
     , LEADS.PICTURE
     , LEADS.CAMPAIGN_ID
     , TEAMS.ID                       as TEAM_ID
     , TEAMS.NAME                     as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME       as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME     as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME    as MODIFIED_BY
     , LEADS.CREATED_BY               as CREATED_BY_ID
     , LEADS.MODIFIED_USER_ID
     , TEAM_SETS.ID                   as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME        as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST        as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
     , LEADS.BIRTHDATE
     , LEADS.WEBSITE
     , LEADS.STATUS
     , TAG_SETS.TAG_SET_NAME
     , LEADS_CSTM.*
  from            LEADS
  left outer join TEAMS
               on TEAMS.ID                 = LEADS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = LEADS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = LEADS.ASSIGNED_USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = LEADS.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = LEADS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = LEADS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = LEADS.ID
              and TAG_SETS.DELETED         = 0
  left outer join LEADS_CSTM
               on LEADS_CSTM.ID_C          = LEADS.ID
 where LEADS.DELETED = 0

GO

Grant Select on dbo.vwLEADS_Convert to public;
GO


