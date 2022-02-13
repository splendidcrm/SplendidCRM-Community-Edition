if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAILS')
	Drop View dbo.vwEMAILS;
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
-- 04/21/2006 Paul.  MESSAGE_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  REPLY_TO_NAME was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  REPLY_TO_ADDR was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  INTENT was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  MAILBOX_ID was added in SugarCRM 4.0.
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 11/27/2006 Paul.  Return TEAM.ID so that a deleted team will return NULL even if a value remains in the related record. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 09/12/2011 Paul.  Add aliases DATE_TIME for the workflow engine. 
-- 06/05/2014 Paul.  Move _IDS and _EMAILS to base view so that they can be accessed via REST API. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 05/17/2017 Paul.  Add Tags module. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwEMAILS
as
select EMAILS.ID
     , EMAILS.NAME
     , EMAILS.DATE_START
     , EMAILS.TIME_START
     , dbo.fnViewDateTime(EMAILS.DATE_START, EMAILS.TIME_START) as DATE_TIME
     , EMAILS.PARENT_TYPE
     , EMAILS.PARENT_ID
     , EMAILS.FROM_ADDR
     , EMAILS.FROM_NAME
     , EMAILS.TYPE
     , EMAILS.STATUS
     , EMAILS.MESSAGE_ID
     , EMAILS.REPLY_TO_NAME
     , EMAILS.REPLY_TO_ADDR
     , EMAILS.INTENT
     , EMAILS.MAILBOX_ID
     , EMAILS.ASSIGNED_USER_ID
     , vwPARENTS.PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID
     , EMAILS.DATE_ENTERED
     , EMAILS.DATE_MODIFIED
     , EMAILS.DATE_MODIFIED_UTC
     , EMAILS.DESCRIPTION
     , EMAILS.DESCRIPTION_HTML
     , EMAILS.IS_PRIVATE
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , EMAILS.CREATED_BY           as CREATED_BY_ID
     , EMAILS.MODIFIED_USER_ID
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , EMAILS.TO_ADDRS_IDS
     , EMAILS.CC_ADDRS_IDS
     , EMAILS.BCC_ADDRS_IDS
     , EMAILS.TO_ADDRS_EMAILS
     , EMAILS.CC_ADDRS_EMAILS
     , EMAILS.BCC_ADDRS_EMAILS
     , TAG_SETS.TAG_SET_NAME
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , EMAILS_CSTM.*
  from            EMAILS
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID      = EMAILS.PARENT_ID
  left outer join TEAMS
               on TEAMS.ID                 = EMAILS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = EMAILS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = EMAILS.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = EMAILS.ASSIGNED_USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = EMAILS.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = EMAILS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = EMAILS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
  left outer join EMAILS_CSTM
               on EMAILS_CSTM.ID_C         = EMAILS.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = EMAILS.ID
 where EMAILS.DELETED = 0

GO

Grant Select on dbo.vwEMAILS to public;
GO

 
