if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spBUGS_Undelete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spBUGS_Undelete;
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
-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
Create Procedure dbo.spBUGS_Undelete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @AUDIT_TOKEN      varchar(255)
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update DOCUMENTS_BUGS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where BUG_ID           = @ID
		   and DELETED          = 1
		   and ID in (select ID from DOCUMENTS_BUGS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and BUG_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update ACCOUNTS_BUGS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where BUG_ID           = @ID
		   and DELETED          = 1
		   and ID in (select ID from ACCOUNTS_BUGS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and BUG_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CASES_BUGS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where BUG_ID           = @ID
		   and DELETED          = 1
		   and ID in (select ID from CASES_BUGS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and BUG_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CONTACTS_BUGS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where BUG_ID           = @ID
		   and DELETED          = 1
		   and ID in (select ID from CONTACTS_BUGS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and BUG_ID = @ID);
	-- END Oracle Exception
	
	exec dbo.spPARENT_Undelete @ID, @MODIFIED_USER_ID, @AUDIT_TOKEN, N'Bugs';
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update BUGS_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from BUGS
			  where ID               = @ID
			    and DELETED          = 1
			    and ID in (select ID from BUGS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID)
			);
		update BUGS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 1
		   and ID in (select ID from BUGS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID);
	-- END Oracle Exception

  end
GO

Grant Execute on dbo.spBUGS_Undelete to public;
GO

