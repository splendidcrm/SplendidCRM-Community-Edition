if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCALLS_DeleteRecurrences' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCALLS_DeleteRecurrences;
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
-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
Create Procedure dbo.spCALLS_DeleteRecurrences
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @DELETE_ALL       bit
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update CALLS_USERS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , DELETED           = 1                 
		 where CALL_ID in (select ID from CALLS where REPEAT_PARENT_ID = @ID and (@DELETE_ALL = 1 or DATE_START > getdate()) and DELETED = 0);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CALLS_CONTACTS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , DELETED           = 1                 
		 where CALL_ID in (select ID from CALLS where REPEAT_PARENT_ID = @ID and (@DELETE_ALL = 1 or DATE_START > getdate()) and DELETED = 0);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CALLS_LEADS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , DELETED           = 1                 
		 where CALL_ID in (select ID from CALLS where REPEAT_PARENT_ID = @ID and (@DELETE_ALL = 1 or DATE_START > getdate()) and DELETED = 0);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update NOTES_CSTM
		   set ID_C             = ID_C
		 where ID_C in
			(select ID
			   from NOTES
			 where PARENT_ID in (select ID from CALLS where REPEAT_PARENT_ID = @ID and (@DELETE_ALL = 1 or DATE_START > getdate()) and DELETED = 0)
			   and DELETED          = 0
			);

		update NOTES
		   set PARENT_ID        = null
		     , PARENT_TYPE      = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID in (select ID from CALLS where REPEAT_PARENT_ID = @ID and (@DELETE_ALL = 1 or DATE_START > getdate()) and DELETED = 0)
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update CALLS_CSTM
		   set ID_C             = ID_C
		 where ID_C in
			(select ID
			  from CALLS
			  where REPEAT_PARENT_ID  = @ID
			   and (@DELETE_ALL = 1 or DATE_START > getdate())
			   and DELETED           = 0
			);
		update CALLS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID   
		     , DATE_MODIFIED     =  getdate()          
		     , DATE_MODIFIED_UTC =  getutcdate()       
		     , DELETED           =  1                  
		 where REPEAT_PARENT_ID  = @ID
		   and (@DELETE_ALL = 1 or DATE_START > getdate())
		   and DELETED           = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		delete from TRACKER
		 where ITEM_ID in (select ID from CALLS where REPEAT_PARENT_ID = @ID and (@DELETE_ALL = 1 or DATE_START > getdate()) and DELETED = 0);
	-- END Oracle Exception
  end
GO

Grant Execute on dbo.spCALLS_DeleteRecurrences to public;
GO

