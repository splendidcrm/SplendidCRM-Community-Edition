if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDOCUMENT_REVISIONS')
	Drop View dbo.vwDOCUMENT_REVISIONS;
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
-- 04/26/2012 Paul.  Add NAME, ASSIGNED_USER_ID and ASSIGNED_TO_NAME. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwDOCUMENT_REVISIONS
as
select DOCUMENT_REVISIONS.ID
     , DOCUMENT_REVISIONS.CHANGE_LOG
     , DOCUMENT_REVISIONS.DOCUMENT_ID
     , DOCUMENT_REVISIONS.FILENAME
     , DOCUMENT_REVISIONS.FILE_MIME_TYPE
     , DOCUMENT_REVISIONS.REVISION
     , DOCUMENT_REVISIONS.DATE_ENTERED 
     , DOCUMENTS.DOCUMENT_NAME          as NAME
     , DOCUMENTS.ASSIGNED_USER_ID
     , USERS_ASSIGNED.USER_NAME         as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME       as CREATED_BY
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , ASSIGNED_SETS.ID                   as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
  from            DOCUMENT_REVISIONS
  left outer join DOCUMENTS
               on DOCUMENTS.ID               = DOCUMENT_REVISIONS.DOCUMENT_ID
  left outer join USERS                        USERS_ASSIGNED
               on USERS_ASSIGNED.ID          = DOCUMENTS.ASSIGNED_USER_ID
  left outer join USERS                        USERS_CREATED_BY
               on USERS_CREATED_BY.ID        = DOCUMENT_REVISIONS.CREATED_BY
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID           = DOCUMENTS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED      = 0
 where DOCUMENT_REVISIONS.DELETED = 0

GO

Grant Select on dbo.vwDOCUMENT_REVISIONS to public;
GO

