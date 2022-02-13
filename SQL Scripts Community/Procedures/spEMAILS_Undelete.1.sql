if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_Undelete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILS_Undelete;
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
Create Procedure dbo.spEMAILS_Undelete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @AUDIT_TOKEN      varchar(255)
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update EMAILS_ACCOUNTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where EMAIL_ID         = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAILS_ACCOUNTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and EMAIL_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILS_CASES
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where EMAIL_ID         = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAILS_CASES_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and EMAIL_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILS_CONTACTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where EMAIL_ID         = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAILS_CONTACTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and EMAIL_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILS_OPPORTUNITIES
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where EMAIL_ID         = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAILS_OPPORTUNITIES_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and EMAIL_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILS_USERS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where EMAIL_ID         = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAILS_USERS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and EMAIL_ID = @ID);
	-- END Oracle Exception
	
	-- 09/25/2013 Paul.  Email Images also need to be deleted as they are tied directly to the email. 
	-- BEGIN Oracle Exception
		update EMAIL_IMAGES
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAIL_IMAGES_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and PARENT_ID = @ID);
	-- END Oracle Exception
	
	exec dbo.spPARENT_Undelete @ID, @MODIFIED_USER_ID, @AUDIT_TOKEN, N'Emails';
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update EMAILS_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from EMAILS
			  where ID               = @ID
			    and DELETED          = 1
			    and ID in (select ID from EMAILS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID)
			);
		update EMAILS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAILS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID);
	-- END Oracle Exception
	
  end
GO

Grant Execute on dbo.spEMAILS_Undelete to public;
GO

