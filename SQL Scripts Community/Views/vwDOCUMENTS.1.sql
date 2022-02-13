if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDOCUMENTS')
	Drop View dbo.vwDOCUMENTS;
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
-- 04/21/2006 Paul.  MAIL_MERGE_DOCUMENT was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  RELATED_DOC_ID was added in SugarCRM 4.2.
-- 04/21/2006 Paul.  RELATED_DOC_REV_ID was added in SugarCRM 4.2.
-- 04/21/2006 Paul.  IS_TEMPLATE was added in SugarCRM 4.2.
-- 04/21/2006 Paul.  TEMPLATE_TYPE was added in SugarCRM 4.2.
-- 07/04/2006 Paul.  Fixed name REVISION_MODIFIED_BY. 
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 11/27/2006 Paul.  Return TEAM.ID so that a deleted team will return NULL even if a value remains in the related record. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/12/2010 Paul.  All modules should have a NAME field. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 05/15/2011 Paul.  We need to include the Master and Secondary so that the user selects the correct template. 
-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
-- 04/26/2012 Paul.  Add ASSIGNED_TO_NAME. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 08/03/2016 Paul.  DESCRIPTION is a core field that needs to be in the main view. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwDOCUMENTS
as
select DOCUMENTS.ID
     , DOCUMENTS.DOCUMENT_NAME as NAME
     , DOCUMENTS.DOCUMENT_NAME
     , DOCUMENTS.ACTIVE_DATE
     , DOCUMENTS.EXP_DATE
     , DOCUMENTS.CATEGORY_ID
     , DOCUMENTS.SUBCATEGORY_ID
     , DOCUMENTS.STATUS_ID
     , DOCUMENTS.MAIL_MERGE_DOCUMENT
     , DOCUMENTS.RELATED_DOC_ID
     , DOCUMENTS.RELATED_DOC_REV_ID
     , DOCUMENTS.IS_TEMPLATE
     , DOCUMENTS.TEMPLATE_TYPE
     , DOCUMENTS.PRIMARY_MODULE       
     , DOCUMENTS.SECONDARY_MODULE     
     , DOCUMENTS.DATE_ENTERED
     , DOCUMENTS.DATE_MODIFIED
     , DOCUMENTS.DATE_MODIFIED_UTC
     , DOCUMENTS.DOCUMENT_REVISION_ID
     , DOCUMENTS.DESCRIPTION
     , DOCUMENT_REVISIONS.FILENAME
     , DOCUMENT_REVISIONS.FILE_MIME_TYPE
     , DOCUMENT_REVISIONS.REVISION
     , DOCUMENT_REVISIONS.DATE_ENTERED  as REVISION_DATE_ENTERED
     , DOCUMENT_REVISIONS.DATE_MODIFIED as REVISION_DATE_MODIFIED
     , REVISION_CREATED_BY.USER_NAME    as REVISION_CREATED_BY
     , REVISION_MODIFIED_BY.USER_NAME   as REVISION_MODIFIED_BY
     , TEAMS.ID                         as TEAM_ID
     , TEAMS.NAME                       as TEAM_NAME
     , USERS_CREATED_BY.USER_NAME       as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME      as MODIFIED_BY
     , DOCUMENTS.ASSIGNED_USER_ID
     , DOCUMENTS.CREATED_BY             as CREATED_BY_ID
     , DOCUMENTS.MODIFIED_USER_ID
     , USERS_ASSIGNED.USER_NAME         as ASSIGNED_TO
     , TEAM_SETS.ID                     as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME          as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST          as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME      , USERS_ASSIGNED.LAST_NAME      ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME    , USERS_CREATED_BY.LAST_NAME    ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME   , USERS_MODIFIED_BY.LAST_NAME   ) as MODIFIED_BY_NAME
     , dbo.fnFullName(REVISION_CREATED_BY.FIRST_NAME , REVISION_CREATED_BY.LAST_NAME ) as REVISION_CREATED_BY_NAME
     , dbo.fnFullName(REVISION_MODIFIED_BY.FIRST_NAME, REVISION_MODIFIED_BY.LAST_NAME) as REVISION_MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , TAG_SETS.TAG_SET_NAME
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , DOCUMENTS_CSTM.*
  from            DOCUMENTS
  left outer join DOCUMENT_REVISIONS
               on DOCUMENT_REVISIONS.ID      = DOCUMENTS.DOCUMENT_REVISION_ID
              and DOCUMENT_REVISIONS.DELETED = 0
  left outer join TEAMS
               on TEAMS.ID                   = DOCUMENTS.TEAM_ID
              and TEAMS.DELETED              = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID               = DOCUMENTS.TEAM_SET_ID
              and TEAM_SETS.DELETED          = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID           = DOCUMENTS.ID
              and TAG_SETS.DELETED           = 0
  left outer join USERS                        REVISION_CREATED_BY
               on REVISION_CREATED_BY.ID     = DOCUMENT_REVISIONS.CREATED_BY
  left outer join USERS                        REVISION_MODIFIED_BY
               on REVISION_MODIFIED_BY.ID    = DOCUMENT_REVISIONS.MODIFIED_USER_ID
  left outer join USERS                        USERS_ASSIGNED
               on USERS_ASSIGNED.ID          = DOCUMENTS.ASSIGNED_USER_ID
  left outer join USERS                        USERS_CREATED_BY
               on USERS_CREATED_BY.ID        = DOCUMENTS.CREATED_BY
  left outer join USERS                        USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID       = DOCUMENTS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID           = DOCUMENTS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED      = 0
  left outer join DOCUMENTS_CSTM
               on DOCUMENTS_CSTM.ID_C        = DOCUMENTS.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = DOCUMENTS.ID
 where DOCUMENTS.DELETED = 0

GO

Grant Select on dbo.vwDOCUMENTS to public;
GO

 
