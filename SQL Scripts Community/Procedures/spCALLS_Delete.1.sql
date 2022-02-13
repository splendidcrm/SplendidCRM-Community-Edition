if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCALLS_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCALLS_Delete;
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
-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
-- 03/27/2013 Paul.  If this is a parent occurence, delete all future recurrences. 
-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
Create Procedure dbo.spCALLS_Delete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @REPEAT_TYPE nvarchar(25);
	-- BEGIN Oracle Exception
		select @REPEAT_TYPE = REPEAT_TYPE
		  from CALLS
		 where ID = @ID;
	-- END Oracle Exception

	-- 04/02/2006 Paul.  Catch the Oracle NO_DATA_FOUND exception. 
	-- BEGIN Oracle Exception
		update CALLS_CONTACTS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CALL_ID          = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CALLS_USERS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CALL_ID          = @ID
		   and DELETED          = 0;
	-- END Oracle Exception

	-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
	-- BEGIN Oracle Exception
		update CALLS_LEADS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CALL_ID          = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		delete from TRACKER
		 where ITEM_ID          = @ID
		   and USER_ID          = @MODIFIED_USER_ID;
	-- END Oracle Exception
	
	exec dbo.spPARENT_Delete @ID, @MODIFIED_USER_ID;
	
	-- BEGIN Oracle Exception
		update CALLS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 0;

		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update CALLS_CSTM
		   set ID_C             = ID_C
		 where ID_C             = @ID;
	-- END Oracle Exception
	
	-- 10/13/2015 Paul.  We need to delete all favorite records. 
	-- BEGIN Oracle Exception
		update SUGARFAVORITES
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
		 where RECORD_ID         = @ID
		   and DELETED           = 0;
	-- END Oracle Exception

	if @REPEAT_TYPE is not null begin -- then
		exec dbo.spCALLS_DeleteRecurrences @ID, @MODIFIED_USER_ID, 0;
	end -- if;
  end
GO

Grant Execute on dbo.spCALLS_Delete to public;
GO

