if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAIL_TEMPLATES')
	Drop View dbo.vwEMAIL_TEMPLATES;
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
-- 12/19/2006 Paul.  Add READ_ONLY flag. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
-- 04/26/2012 Paul.  Add ASSIGNED_TO_NAME. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwEMAIL_TEMPLATES
as
select EMAIL_TEMPLATES.ID
     , EMAIL_TEMPLATES.NAME
     , EMAIL_TEMPLATES.DESCRIPTION
     , EMAIL_TEMPLATES.PUBLISHED
     , EMAIL_TEMPLATES.READ_ONLY
     , EMAIL_TEMPLATES.DATE_ENTERED
     , EMAIL_TEMPLATES.DATE_MODIFIED
     , EMAIL_TEMPLATES.DATE_MODIFIED_UTC
     , EMAIL_TEMPLATES.SUBJECT
     , EMAIL_TEMPLATES.BODY
     , EMAIL_TEMPLATES.BODY_HTML
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , EMAIL_TEMPLATES.ASSIGNED_USER_ID
     , USERS_ASSIGNED.USER_NAME         as ASSIGNED_TO
     , EMAIL_TEMPLATES_CSTM.*
  from            EMAIL_TEMPLATES
  left outer join TEAMS
               on TEAMS.ID                  = EMAIL_TEMPLATES.TEAM_ID
              and TEAMS.DELETED             = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID              = EMAIL_TEMPLATES.TEAM_SET_ID
              and TEAM_SETS.DELETED         = 0
  left outer join USERS                       USERS_ASSIGNED
               on USERS_ASSIGNED.ID         = EMAIL_TEMPLATES.ASSIGNED_USER_ID
  left outer join USERS                       USERS_CREATED_BY
               on USERS_CREATED_BY.ID       = EMAIL_TEMPLATES.CREATED_BY
  left outer join USERS                       USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID      = EMAIL_TEMPLATES.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID          = EMAIL_TEMPLATES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED     = 0
  left outer join EMAIL_TEMPLATES_CSTM
               on EMAIL_TEMPLATES_CSTM.ID_C = EMAIL_TEMPLATES.ID
 where EMAIL_TEMPLATES.DELETED = 0

GO

Grant Select on dbo.vwEMAIL_TEMPLATES to public;
GO

 
