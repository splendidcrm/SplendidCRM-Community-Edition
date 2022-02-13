if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwBUGS')
	Drop View dbo.vwBUGS;
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
-- 07/04/2007 Paul.  The Releases list references the fields as IDs, but we need to use them as text values in the detail and grid views. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 08/01/2009 Paul.  The Release list returns GUIDs as the value, but the vwBUGS view returned FOUND_IN_RELEASE as the text value. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 11/22/2012 Paul.  Join to LAST_ACTIVITY table. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwBUGS
as
select BUGS.ID
     , BUGS.BUG_NUMBER
     , BUGS.NAME
     , BUGS.STATUS
     , BUGS.PRIORITY
     , BUGS.RESOLUTION
     , FOUND_RELEASES.NAME         as FOUND_IN_RELEASE
     , BUGS.TYPE
     , FIXED_RELEASES.NAME         as FIXED_IN_RELEASE
     , BUGS.SOURCE
     , BUGS.PRODUCT_CATEGORY
     , BUGS.ASSIGNED_USER_ID
     , BUGS.DATE_ENTERED
     , BUGS.DATE_MODIFIED
     , BUGS.DATE_MODIFIED_UTC
     , BUGS.DESCRIPTION
     , BUGS.WORK_LOG
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , BUGS.CREATED_BY             as CREATED_BY_ID
     , BUGS.MODIFIED_USER_ID
     , FOUND_RELEASES.ID           as FOUND_IN_RELEASE_ID
     , FIXED_RELEASES.ID           as FIXED_IN_RELEASE_ID
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
     , BUGS_CSTM.*
  from            BUGS
  left outer join TEAMS
               on TEAMS.ID             = BUGS.TEAM_ID
              and TEAMS.DELETED        = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID         = BUGS.TEAM_SET_ID
              and TEAM_SETS.DELETED    = 0
  left outer join LAST_ACTIVITY
               on LAST_ACTIVITY.ACTIVITY_ID = BUGS.ID
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID     = BUGS.ID
              and TAG_SETS.DELETED     = 0
  left outer join USERS                  USERS_ASSIGNED
               on USERS_ASSIGNED.ID    = BUGS.ASSIGNED_USER_ID
  left outer join USERS                  USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = BUGS.CREATED_BY
  left outer join USERS                  USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = BUGS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID     = BUGS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED= 0
  left outer join RELEASES               FOUND_RELEASES
               on cast(FOUND_RELEASES.ID as char(36))  = BUGS.FOUND_IN_RELEASE
  left outer join RELEASES               FIXED_RELEASES
               on cast(FIXED_RELEASES.ID as char(36))  = BUGS.FIXED_IN_RELEASE
  left outer join BUGS_CSTM
               on BUGS_CSTM.ID_C       = BUGS.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = BUGS.ID
 where BUGS.DELETED = 0

GO

Grant Select on dbo.vwBUGS to public;
GO

 
