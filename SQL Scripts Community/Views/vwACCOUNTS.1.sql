if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACCOUNTS')
	Drop View dbo.vwACCOUNTS;
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
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 11/27/2006 Paul.  Return TEAM.ID so that a deleted team will return NULL even if a value remains in the related record. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 07/26/2009 Paul.  Enough customers requested ACCOUNT_NUMBER that it makes sense to add it now. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 05/30/2012 Paul.  Add PARENT_ASSIGNED_USER_ID for use in vwACCOUNTS_QUOTES, vwACCOUNTS_ORDERS, vwACCOUNTS_INVOICES. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 11/22/2012 Paul.  Join to LAST_ACTIVITY table. 
-- 05/24/2015 Paul.  Add picture. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 06/07/2017 Paul.  Add NAICSCodes module. 
-- 10/27/2017 Paul.  Add Accounts as email source. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwACCOUNTS
as
select ACCOUNTS.ID
     , ACCOUNTS.ACCOUNT_NUMBER
     , ACCOUNTS.NAME
     , ACCOUNTS.PHONE_OFFICE
     , ACCOUNTS.PHONE_OFFICE as PHONE
     , ACCOUNTS.PHONE_FAX
     , ACCOUNTS.PHONE_ALTERNATE
     , ACCOUNTS.WEBSITE
     , ACCOUNTS.EMAIL1
     , ACCOUNTS.EMAIL2
     , ACCOUNTS.ANNUAL_REVENUE
     , ACCOUNTS.EMPLOYEES
     , ACCOUNTS.INDUSTRY
     , ACCOUNTS.OWNERSHIP
     , ACCOUNTS.ACCOUNT_TYPE
     , ACCOUNTS.TICKER_SYMBOL
     , ACCOUNTS.RATING
     , ACCOUNTS.SIC_CODE
     , ACCOUNTS.BILLING_ADDRESS_STREET
     , ACCOUNTS.BILLING_ADDRESS_CITY
     , ACCOUNTS.BILLING_ADDRESS_STATE
     , ACCOUNTS.BILLING_ADDRESS_POSTALCODE
     , ACCOUNTS.BILLING_ADDRESS_COUNTRY
     , dbo.fnLocation(ACCOUNTS.BILLING_ADDRESS_CITY, ACCOUNTS.BILLING_ADDRESS_STATE) as CITY
     , ACCOUNTS.SHIPPING_ADDRESS_STREET
     , ACCOUNTS.SHIPPING_ADDRESS_CITY
     , ACCOUNTS.SHIPPING_ADDRESS_STATE
     , ACCOUNTS.SHIPPING_ADDRESS_POSTALCODE
     , ACCOUNTS.SHIPPING_ADDRESS_COUNTRY
     , ACCOUNTS.ASSIGNED_USER_ID
     , ACCOUNTS.PARENT_ID
     , ACCOUNTS_PARENT.NAME             as PARENT_NAME
     , ACCOUNTS_PARENT.ASSIGNED_USER_ID as PARENT_ASSIGNED_USER_ID
     , ACCOUNTS_PARENT.ASSIGNED_SET_ID  as PARENT_ASSIGNED_SET_ID
     , ACCOUNTS.DATE_ENTERED
     , ACCOUNTS.DATE_MODIFIED
     , ACCOUNTS.DATE_MODIFIED_UTC
     , ACCOUNTS.DESCRIPTION
     , ACCOUNTS.PICTURE
     , ACCOUNTS.DO_NOT_CALL
     , ACCOUNTS.EMAIL_OPT_OUT
     , ACCOUNTS.INVALID_EMAIL
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , ACCOUNTS.CREATED_BY         as CREATED_BY_ID
     , ACCOUNTS.MODIFIED_USER_ID
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , LAST_ACTIVITY.LAST_ACTIVITY_DATE
     , TAG_SETS.TAG_SET_NAME
     , NAICS_CODE_SETS.NAICS_SET_NAME
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , ACCOUNTS_CSTM.*
  from            ACCOUNTS
  left outer join ACCOUNTS ACCOUNTS_PARENT
               on ACCOUNTS_PARENT.ID       = ACCOUNTS.PARENT_ID
              and ACCOUNTS_PARENT.DELETED  = 0
  left outer join TEAMS
               on TEAMS.ID                 = ACCOUNTS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = ACCOUNTS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join LAST_ACTIVITY
               on LAST_ACTIVITY.ACTIVITY_ID = ACCOUNTS.ID
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = ACCOUNTS.ID
              and TAG_SETS.DELETED         = 0
  left outer join NAICS_CODE_SETS
               on NAICS_CODE_SETS.PARENT_ID= ACCOUNTS.ID
              and NAICS_CODE_SETS.DELETED  = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = ACCOUNTS.ASSIGNED_USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = ACCOUNTS.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = ACCOUNTS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = ACCOUNTS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
  left outer join ACCOUNTS_CSTM
               on ACCOUNTS_CSTM.ID_C       = ACCOUNTS.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = ACCOUNTS.ID
 where ACCOUNTS.DELETED = 0

GO

Grant Select on dbo.vwACCOUNTS to public;
GO

