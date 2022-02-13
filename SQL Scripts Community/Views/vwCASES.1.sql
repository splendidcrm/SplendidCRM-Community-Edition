if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCASES')
	Drop View dbo.vwCASES;
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
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 04/02/2012 Paul.  Add TYPE and WORK_LOG. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 11/22/2012 Paul.  Join to LAST_ACTIVITY table. 
-- 05/01/2013 Paul.  Add Contacts field to support B2C. 
-- 03/19/2016 Paul.  Add EMAIL1 to make it easy for the Office Addin to search. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 01/09/2017 Paul.  Allow account to be determined from the contact. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwCASES
as
select CASES.ID
     , CASES.CASE_NUMBER
     , CASES.NAME
     , ACCOUNTS.NAME               as ACCOUNT_NAME
     , ACCOUNTS.ASSIGNED_USER_ID   as ACCOUNT_ASSIGNED_USER_ID
     , ACCOUNTS.ASSIGNED_SET_ID    as ACCOUNT_ASSIGNED_SET_ID
     , ACCOUNTS.EMAIL1             as ACCOUNT_EMAIL1
     , CASES.ACCOUNT_ID
     , CASES.STATUS
     , CASES.PRIORITY
     , CASES.TYPE
     , CASES.ASSIGNED_USER_ID
     , CASES.DATE_ENTERED
     , CASES.DATE_MODIFIED
     , CASES.DATE_MODIFIED_UTC
     , CASES.DESCRIPTION
     , CASES.RESOLUTION
     , CASES.WORK_LOG
     , CONTACTS.ID                 as B2C_CONTACT_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as B2C_CONTACT_NAME
     , CONTACTS.ASSIGNED_USER_ID   as B2C_CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID    as B2C_CONTACT_ASSIGNED_SET_ID
     , CONTACTS.EMAIL1             as B2C_CONTACT_EMAIL1
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , CASES.CREATED_BY            as CREATED_BY_ID
     , CASES.MODIFIED_USER_ID
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
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , CASES_CSTM.*
  from            CASES
  left outer join ACCOUNTS
               on (ACCOUNTS.ID = CASES.ACCOUNT_ID or ACCOUNTS.ID in (select top 1 ID from ACCOUNTS_CONTACTS where DELETED = 0 and CONTACT_ID = CASES.B2C_CONTACT_ID and CASES.ACCOUNT_ID is null))
              and ACCOUNTS.DELETED     = 0
  left outer join CONTACTS
               on CONTACTS.ID          = CASES.B2C_CONTACT_ID
              and CONTACTS.DELETED     = 0
  left outer join TEAMS
               on TEAMS.ID             = CASES.TEAM_ID
              and TEAMS.DELETED        = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID         = CASES.TEAM_SET_ID
              and TEAM_SETS.DELETED    = 0
  left outer join LAST_ACTIVITY
               on LAST_ACTIVITY.ACTIVITY_ID = CASES.ID
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID     = CASES.ID
              and TAG_SETS.DELETED     = 0
  left outer join USERS                  USERS_ASSIGNED
               on USERS_ASSIGNED.ID    = CASES.ASSIGNED_USER_ID
  left outer join USERS                  USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = CASES.CREATED_BY
  left outer join USERS                  USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = CASES.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID     = CASES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED= 0
  left outer join CASES_CSTM
               on CASES_CSTM.ID_C      = CASES.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = CASES.ID
 where CASES.DELETED = 0

GO

Grant Select on dbo.vwCASES to public;
GO

 
