if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROSPECTS_Convert')
	Drop View dbo.vwPROSPECTS_Convert;
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
-- 04/28/2006 Paul.  DB2 does not like to return just NULL, it must be cast to something. 
-- 06/16/2007 Paul.  Add TEAM_ID for team management. 
-- 08/30/2009 Paul.  All module views must have a TEAM_SET_ID. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 06/05/2015 Paul.  Add PICTURE. 
-- 03/31/2016 Paul.  Add DATE_MODIFIED_UTC. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 02/04/2020 Paul.  Add Tags module. 
Create View dbo.vwPROSPECTS_Convert
as
select PROSPECTS.ID
     , PROSPECTS.SALUTATION
     , PROSPECTS.FIRST_NAME
     , PROSPECTS.LAST_NAME
     , PROSPECTS.TITLE
     , cast(null as nvarchar(100))    as REFERED_BY
     , cast(null as nvarchar(100))    as LEAD_SOURCE
     , cast(null as nvarchar(100))    as STATUS
     , PROSPECTS.DEPARTMENT
     , PROSPECTS.DO_NOT_CALL
     , PROSPECTS.PHONE_HOME
     , PROSPECTS.PHONE_MOBILE
     , PROSPECTS.PHONE_WORK
     , PROSPECTS.PHONE_OTHER
     , PROSPECTS.PHONE_FAX
     , PROSPECTS.EMAIL1
     , PROSPECTS.EMAIL2
     , PROSPECTS.EMAIL_OPT_OUT
     , PROSPECTS.INVALID_EMAIL
     , PROSPECTS.PRIMARY_ADDRESS_STREET
     , PROSPECTS.PRIMARY_ADDRESS_CITY
     , PROSPECTS.PRIMARY_ADDRESS_STATE
     , PROSPECTS.PRIMARY_ADDRESS_POSTALCODE
     , PROSPECTS.PRIMARY_ADDRESS_COUNTRY
     , PROSPECTS.ALT_ADDRESS_STREET
     , PROSPECTS.ALT_ADDRESS_CITY
     , PROSPECTS.ALT_ADDRESS_STATE
     , PROSPECTS.ALT_ADDRESS_POSTALCODE
     , PROSPECTS.ALT_ADDRESS_COUNTRY
     , PROSPECTS.ACCOUNT_NAME
     , PROSPECTS.ASSIGNED_USER_ID
     , PROSPECTS.DATE_ENTERED
     , PROSPECTS.DATE_MODIFIED
     , PROSPECTS.DATE_MODIFIED_UTC
     , PROSPECTS.DESCRIPTION
     , PROSPECTS.PICTURE
     , cast(null as uniqueidentifier) as CAMPAIGN_ID
     , cast(null as nvarchar(100))    as CAMPAIGN_NAME
     , cast(null as nvarchar(100))    as LEAD_SOURCE_DESCRIPTION
     , cast(null as nvarchar(100))    as STATUS_DESCRIPTION
     , TEAMS.ID                       as TEAM_ID
     , TEAMS.NAME                     as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME       as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME     as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME    as MODIFIED_BY
     , PROSPECTS.CREATED_BY           as CREATED_BY_ID
     , PROSPECTS.MODIFIED_USER_ID
     , TEAM_SETS.ID                   as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME        as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST        as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , TAG_SETS.TAG_SET_NAME
     , PROSPECTS_CSTM.*
  from            PROSPECTS
  left outer join TEAMS
               on TEAMS.ID                 = PROSPECTS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = PROSPECTS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = PROSPECTS.ASSIGNED_USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = PROSPECTS.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = PROSPECTS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = PROSPECTS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = PROSPECTS.ID
              and TAG_SETS.DELETED         = 0
  left outer join PROSPECTS_CSTM
               on PROSPECTS_CSTM.ID_C      = PROSPECTS.ID
 where PROSPECTS.DELETED = 0

GO

Grant Select on dbo.vwPROSPECTS_Convert to public;
GO


