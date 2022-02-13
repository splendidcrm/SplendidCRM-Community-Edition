if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDOCUMENTS_CONTACTS')
	Drop View dbo.vwDOCUMENTS_CONTACTS;
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
-- 01/16/2013 Paul.  Fix SELECTED_DOCUMENT_REVISION_ID. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwDOCUMENTS_CONTACTS
as
select DOCUMENTS.ID                   as DOCUMENT_ID
     , DOCUMENTS.DOCUMENT_NAME        as DOCUMENT_NAME
     , DOCUMENTS.ASSIGNED_USER_ID     as DOCUMENT_ASSIGNED_USER_ID
     , DOCUMENTS.ASSIGNED_SET_ID      as DOCUMENT_ASSIGNED_SET_ID
     , DOCUMENT_REVISIONS.REVISION    as REVISION
     , DOCUMENT_REVISIONS.ID          as SELECTED_DOCUMENT_REVISION_ID
     , DOCUMENT_REVISIONS.REVISION    as SELECTED_REVISION
     , vwCONTACTS.ID                  as CONTACT_ID
     , vwCONTACTS.NAME                as CONTACT_NAME
     , vwCONTACTS.*
  from            DOCUMENTS
       inner join CONTACTS_DOCUMENTS
               on CONTACTS_DOCUMENTS.DOCUMENT_ID = DOCUMENTS.ID
              and CONTACTS_DOCUMENTS.DELETED     = 0
       inner join vwCONTACTS
               on vwCONTACTS.ID                  = CONTACTS_DOCUMENTS.CONTACT_ID
  left outer join DOCUMENT_REVISIONS
               on DOCUMENT_REVISIONS.ID          = CONTACTS_DOCUMENTS.DOCUMENT_REVISION_ID
              and DOCUMENT_REVISIONS.DELETED     = 0
 where DOCUMENTS.DELETED = 0
GO

Grant Select on dbo.vwDOCUMENTS_CONTACTS to public;
GO

