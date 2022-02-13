if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwOPPORTUNITIES_DOCUMENTS')
	Drop View dbo.vwOPPORTUNITIES_DOCUMENTS;
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
Create View dbo.vwOPPORTUNITIES_DOCUMENTS
as
select OPPORTUNITIES.ID               as OPPORTUNITY_ID
     , OPPORTUNITIES.NAME             as OPPORTUNITY_NAME
     , OPPORTUNITIES.ASSIGNED_USER_ID as OPPORTUNITY_ASSIGNED_USER_ID
     , OPPORTUNITIES.ASSIGNED_SET_ID  as OPPORTUNITY_ASSIGNED_SET_ID
     , DOCUMENT_REVISIONS.ID       as SELECTED_DOCUMENT_REVISION_ID
     , DOCUMENT_REVISIONS.REVISION    as SELECTED_REVISION
     , vwDOCUMENTS.ID                 as DOCUMENT_ID
     , vwDOCUMENTS.*
  from            OPPORTUNITIES
       inner join OPPORTUNITIES_DOCUMENTS
               on OPPORTUNITIES_DOCUMENTS.OPPORTUNITY_ID = OPPORTUNITIES.ID
              and OPPORTUNITIES_DOCUMENTS.DELETED        = 0
       inner join vwDOCUMENTS
               on vwDOCUMENTS.ID                         = OPPORTUNITIES_DOCUMENTS.DOCUMENT_ID
  left outer join DOCUMENT_REVISIONS
               on DOCUMENT_REVISIONS.ID                  = OPPORTUNITIES_DOCUMENTS.DOCUMENT_REVISION_ID
              and DOCUMENT_REVISIONS.DELETED             = 0
 where OPPORTUNITIES.DELETED = 0

GO

Grant Select on dbo.vwOPPORTUNITIES_DOCUMENTS to public;
GO

