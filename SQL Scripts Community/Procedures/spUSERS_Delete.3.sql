if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_Delete;
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
-- 10/15/2006 Paul.  Delete team memberships. 
-- 11/18/2006 Paul.  Use a procedure to delete the user from the teams so that all implicit assignments can be recalculated. 
-- 09/12/2010 Paul.  We stopped using the table ROLES_USERS years ago. 
-- 09/12/2010 Paul.  VCALS was never used. 
-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
Create Procedure dbo.spUSERS_Delete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	-- 04/02/2006 Paul.  Catch the Oracle NO_DATA_FOUND exception. 
	-- BEGIN Oracle Exception
		-- 12/20/2005 Paul.  SugarCRM 4.0 relates Users to Prospect Lists.
		update PROSPECT_LISTS_PROSPECTS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where RELATED_ID       = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CALLS_USERS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CONTACTS_USERS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	/*
	-- BEGIN Oracle Exception
		-- 11/13/2005 Paul.  Not sure if it makes sense to delete email relationships as they amount to a log.
		update EMAILMAN
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILMAN_SENT
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILS_USERS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	*/
	-- BEGIN Oracle Exception
		update MEETINGS_USERS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update USERS_FEEDS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where USER_ID          = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		delete from TRACKER
		 where ITEM_ID          = @ID
		   and USER_ID          = @MODIFIED_USER_ID;
	-- END Oracle Exception
	
	exec dbo.spPARENT_Delete @ID, @MODIFIED_USER_ID;

	-- 11/18/2006 Paul.  Only use team procedures when team management has been enabled. 
	if dbo.fnCONFIG_Boolean(N'enable_team_management') = 1 begin -- then
		exec dbo.spTEAM_MEMBERSHIPS_DeleteUser @MODIFIED_USER_ID, @ID;
	end -- if;
	
	-- BEGIN Oracle Exception
		update USERS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 0;

		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update USERS_CSTM
		   set ID_C             = ID_C
		 where ID_C             = @ID;
	-- END Oracle Exception
  end
GO
 
Grant Execute on dbo.spUSERS_Delete to public;
GO
 
 
