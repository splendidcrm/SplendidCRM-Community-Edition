if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPARENT_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPARENT_Delete;
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
Create Procedure dbo.spPARENT_Delete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	-- 04/02/2006 Paul.  Catch the Oracle NO_DATA_FOUND exception. 
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update ACCOUNTS_CSTM
		   set ID_C             = ID_C
		 where ID_C in
			(select ID
			   from ACCOUNTS
			  where PARENT_ID        = @ID
			    and DELETED          = 0
			);
		update ACCOUNTS
		   set PARENT_ID        = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update CALLS_CSTM
		   set ID_C             = ID_C
		 where ID_C in
			(select ID
			   from CALLS
			  where PARENT_ID        = @ID
			    and DELETED          = 0
			);
		update CALLS
		   set PARENT_ID        = null
		     , PARENT_TYPE      = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update EMAILS_CSTM
		   set ID_C             = ID_C
		 where ID_C in
			(select ID
			   from EMAILS
			  where PARENT_ID        = @ID
			    and DELETED          = 0
			);
		update EMAILS
		   set PARENT_ID        = null
		     , PARENT_TYPE      = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- 09/25/2013 Paul.  SMS messages act like emails. 
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update SMS_MESSAGES_CSTM
		   set ID_C             = ID_C
		 where ID_C in
			(select ID
			   from SMS_MESSAGES
			  where PARENT_ID        = @ID
			    and DELETED          = 0
			);
		update SMS_MESSAGES
		   set PARENT_ID        = null
		     , PARENT_TYPE      = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- 10/30/2013 Paul.  Twitter messages act like emails. 
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update TWITTER_MESSAGES_CSTM
		   set ID_C             = ID_C
		 where ID_C in
			(select ID
			   from TWITTER_MESSAGES
			  where PARENT_ID        = @ID
			    and DELETED          = 0
			);
		update TWITTER_MESSAGES
		   set PARENT_ID        = null
		     , PARENT_TYPE      = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update MEETINGS_CSTM
		   set ID_C             = ID_C
		 where ID_C in
			(select ID
			   from MEETINGS
			  where PARENT_ID        = @ID
			    and DELETED          = 0
			);
		update MEETINGS
		   set PARENT_ID        = null
		     , PARENT_TYPE      = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update NOTES_CSTM
		   set ID_C             = ID_C
		 where ID_C in
			(select ID
			   from NOTES
			  where PARENT_ID        = @ID
			    and DELETED          = 0
			);
		update NOTES
		   set PARENT_ID        = null
		     , PARENT_TYPE      = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 10/18/2005 Paul.  Fixed PROJECT_TASKS table name. 
		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update PROJECT_TASK_CSTM
		   set ID_C             = ID_C
		 where ID_C in
			(select ID
			   from PROJECT_TASK
			  where PARENT_ID        = @ID
			    and DELETED          = 0
			);
		update PROJECT_TASK
		   set PARENT_ID        = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 11/13/2005 Paul.  Delete from project relationship. 
		update PROJECT_RELATION
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where RELATION_ID      = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 10/18/2005 Paul.  Fixed PROJECT_TASKS table name. 
		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update TASKS_CSTM
		   set ID_C             = ID_C
		 where ID_C in
			(select ID
			   from TASKS
			  where PARENT_ID        = @ID
			    and DELETED          = 0
			);
		update TASKS
		   set PARENT_ID        = null
		     , PARENT_TYPE      = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
  end
GO

Grant Execute on dbo.spPARENT_Delete to public;
GO

