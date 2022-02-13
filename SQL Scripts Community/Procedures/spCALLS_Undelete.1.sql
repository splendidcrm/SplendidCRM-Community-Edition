if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCALLS_Undelete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCALLS_Undelete;
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
Create Procedure dbo.spCALLS_Undelete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @AUDIT_TOKEN      varchar(255)
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update CALLS_CONTACTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CALL_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from CALLS_CONTACTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CALL_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CALLS_USERS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CALL_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from CALLS_USERS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CALL_ID = @ID);
	-- END Oracle Exception

	-- BEGIN Oracle Exception
		update CALLS_LEADS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CALL_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from CALLS_LEADS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CALL_ID = @ID);
	-- END Oracle Exception
	
	exec dbo.spPARENT_Undelete @ID, @MODIFIED_USER_ID, @AUDIT_TOKEN, N'Calls';
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update CALLS_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from CALLS
			  where ID               = @ID
			    and DELETED          = 1
			    and ID in (select ID from CALLS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID)
			);
		update CALLS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 1
		   and ID in (select ID from CALLS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID);
	-- END Oracle Exception
	
  end
GO

Grant Execute on dbo.spCALLS_Undelete to public;
GO

