if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_Undelete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_Undelete;
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
Create Procedure dbo.spUSERS_Undelete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @AUDIT_TOKEN      varchar(255)
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update PROSPECT_LISTS_PROSPECTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where RELATED_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from PROSPECT_LISTS_PROSPECTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and RELATED_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CALLS_USERS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from CALLS_USERS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and USER_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CONTACTS_USERS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from CONTACTS_USERS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and USER_ID = @ID);
	-- END Oracle Exception
	
	/*
	-- BEGIN Oracle Exception
		-- 11/13/2005 Paul.  Not sure if it makes sense to delete email relationships as they amount to a log.
		update EMAILMAN
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAILMAN_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and USER_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILMAN_SENT
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAILMAN_SENT_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and USER_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILS_USERS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAILS_USERS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and USER_ID = @ID);
	-- END Oracle Exception
	*/
	-- BEGIN Oracle Exception
		update MEETINGS_USERS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from MEETINGS_USERS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and USER_ID = @ID);
	-- END Oracle Exception
	
	-- 08/08/2013 Paul.  USERS_FEEDS is not audited. 
	/*
	-- BEGIN Oracle Exception
		update USERS_FEEDS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from USERS_FEEDS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and USER_ID = @ID);
	-- END Oracle Exception
	*/
	
	exec dbo.spPARENT_Undelete @ID, @MODIFIED_USER_ID, @AUDIT_TOKEN, N'Users';

	-- 08/07/2013 Paul.  Team Memberships are not audited, so we cannot undelete them. 
	-- This should not be an issue as we do not allow users to be deleted from the Admin panel 
	-- so there will be little need to undelete a user. 
	/*
	if dbo.fnCONFIG_Boolean(N'enable_team_management') = 1 begin -- then
		-- BEGIN Oracle Exception
			update TEAM_MEMBERSHIPS
			   set DELETED          = 0
			     , DATE_MODIFIED    = getdate()
			     , DATE_MODIFIED_UTC= getutcdate()
			     , MODIFIED_USER_ID = @MODIFIED_USER_ID
			 where USER_ID          = @ID
			   and DELETED          = 1
			   and ID in (select ID from TEAM_MEMBERSHIPS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and USER_ID = @ID);
		-- END Oracle Exception
	end -- if;
	*/
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update USERS_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from USERS
			 where ID               = @ID
			   and DELETED          = 1
			   and ID in (select ID from USERS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID)
			);
		update USERS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 1
		   and ID in (select ID from USERS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID);
	-- END Oracle Exception
  end
GO
 
Grant Execute on dbo.spUSERS_Undelete to public;
GO
 
 
