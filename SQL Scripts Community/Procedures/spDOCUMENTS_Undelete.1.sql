if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDOCUMENTS_Undelete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDOCUMENTS_Undelete;
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
Create Procedure dbo.spDOCUMENTS_Undelete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @AUDIT_TOKEN      varchar(255)
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update ACCOUNTS_DOCUMENTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where DOCUMENT_ID      = @ID
		   and DELETED          = 1
		   and ID in (select ID from ACCOUNTS_DOCUMENTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and DOCUMENT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CONTACTS_DOCUMENTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where DOCUMENT_ID      = @ID
		   and DELETED          = 1
		   and ID in (select ID from CONTACTS_DOCUMENTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and DOCUMENT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update DOCUMENTS_BUGS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where DOCUMENT_ID      = @ID
		   and DELETED          = 1
		   and ID in (select ID from DOCUMENTS_BUGS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and DOCUMENT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update DOCUMENTS_CASES
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where DOCUMENT_ID      = @ID
		   and DELETED          = 1
		   and ID in (select ID from DOCUMENTS_CASES_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and DOCUMENT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update LEADS_DOCUMENTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where DOCUMENT_ID      = @ID
		   and DELETED          = 1
		   and ID in (select ID from LEADS_DOCUMENTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and DOCUMENT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update OPPORTUNITIES_DOCUMENTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where DOCUMENT_ID      = @ID
		   and DELETED          = 1
		   and ID in (select ID from OPPORTUNITIES_DOCUMENTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and DOCUMENT_ID = @ID);
	-- END Oracle Exception
	
	-- 08/07/2013 Paul.  Document Revisions are not tracked, so we cannot rely upon the audit token. 
	-- Just undelete all revisions as it is unlikely to have very many incorrect undeleted revisions. 
	-- BEGIN Oracle Exception
		update DOCUMENT_REVISIONS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where DOCUMENT_ID      = @ID
		   and DELETED          = 1;
	-- END Oracle Exception

	-- BEGIN Oracle Exception
		update DOCUMENTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 1
		   and ID in (select ID from CONTACTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID);
	-- END Oracle Exception
  end
GO

Grant Execute on dbo.spDOCUMENTS_Undelete to public;
GO

