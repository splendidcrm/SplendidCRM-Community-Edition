if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwNOTES')
	Drop View dbo.vwNOTES;
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
-- 04/25/2007 Paul.  We need to return a field for ASSIGNED_USER_ID in order for the team management code to work properly.
-- Since a note does not currently have an ASSIGNED_USER_ID field, we are going to return the parent value. 
-- 10/10/2008 Paul.  Add CREATED_BY_ID and MODIFIED_USER_ID so that the view is consistent with all others. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
-- 04/26/2012 Paul.  Add ASSIGNED_TO_NAME. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 05/12/2017 Paul.  Need to optimize for Azure. ATTACHMENT is null filter is not indexable, so index length field. 
-- 05/17/2017 Paul.  Add Tags module. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwNOTES
as
select NOTES.ID
     , NOTES.NAME
     , NOTES.PARENT_TYPE
     , NOTES.CONTACT_ID
     , NOTES.PORTAL_FLAG
     , NOTES.DATE_ENTERED
     , NOTES.DATE_MODIFIED
     , NOTES.DATE_MODIFIED_UTC
     , NOTES.PARENT_ID
     , NOTES.DESCRIPTION
     , NOTES.IS_PRIVATE
     , NOTES.NOTE_ATTACHMENT_ID
     , NOTE_ATTACHMENTS.FILENAME
     , NOTE_ATTACHMENTS.FILE_MIME_TYPE
     , (case when NOTE_ATTACHMENTS.ATTACHMENT_LENGTH > 0 then 1 else 0 end) as ATTACHMENT_READY
     , vwPARENTS.PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID
     , NOTES.ASSIGNED_USER_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
     , CONTACTS.PHONE_WORK         as CONTACT_PHONE
     , CONTACTS.EMAIL1             as CONTACT_EMAIL
     , CONTACTS.ASSIGNED_USER_ID   as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID    as CONTACT_ASSIGNED_SET_ID
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , NOTES.CREATED_BY            as CREATED_BY_ID
     , NOTES.MODIFIED_USER_ID
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , TAG_SETS.TAG_SET_NAME
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , NOTES_CSTM.*
  from            NOTES
  left outer join NOTE_ATTACHMENTS
               on NOTE_ATTACHMENTS.ID      = NOTES.NOTE_ATTACHMENT_ID
              and NOTE_ATTACHMENTS.DELETED = 0
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID      = NOTES.PARENT_ID
  left outer join CONTACTS
               on CONTACTS.ID              = NOTES.CONTACT_ID
              and CONTACTS.DELETED         = 0
  left outer join TEAMS
               on TEAMS.ID                 = NOTES.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = NOTES.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = NOTES.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = NOTES.ASSIGNED_USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = NOTES.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = NOTES.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = NOTES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
  left outer join NOTES_CSTM
               on NOTES_CSTM.ID_C          = NOTES.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = NOTES.ID
 where NOTES.DELETED = 0

GO

Grant Select on dbo.vwNOTES to public;
GO

 
