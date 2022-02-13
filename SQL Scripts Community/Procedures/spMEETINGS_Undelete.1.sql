if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMEETINGS_Undelete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMEETINGS_Undelete;
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
Create Procedure dbo.spMEETINGS_Undelete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @AUDIT_TOKEN      varchar(255)
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update MEETINGS_CONTACTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where MEETING_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from MEETINGS_CONTACTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and MEETING_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update MEETINGS_USERS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where MEETING_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from MEETINGS_USERS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and MEETING_ID = @ID);
	-- END Oracle Exception
	
	-- 04/01/2012 Paul.  Add Meetings/Leads relationship. 
	-- BEGIN Oracle Exception
		update MEETINGS_LEADS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where MEETING_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from MEETINGS_LEADS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and MEETING_ID = @ID);
	-- END Oracle Exception

	exec dbo.spPARENT_Undelete @ID, @MODIFIED_USER_ID, @AUDIT_TOKEN, N'Meetings';
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update MEETINGS_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from MEETINGS
			  where ID               = @ID
			    and DELETED          = 1
			    and ID in (select ID from MEETINGS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID)
			);
		update MEETINGS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 1
		   and ID in (select ID from MEETINGS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID);
	-- END Oracle Exception
	
  end
GO

Grant Execute on dbo.spMEETINGS_Undelete to public;
GO

