if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACTIVITIES_UpdateStatus' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACTIVITIES_UpdateStatus;
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
-- 06/09/2017 Paul.  Add support for Tasks reminders. 
-- 09/03/2017 Paul.  Need to create a new ID for TASKS_USERS. 
Create Procedure dbo.spACTIVITIES_UpdateStatus
	( @ID                uniqueidentifier
	, @MODIFIED_USER_ID  uniqueidentifier
	, @USER_ID           uniqueidentifier
	, @STATUS            nvarchar(25)
	)
as
  begin
	set nocount on
	
	declare @ACTIVITY_TYPE nvarchar(25);
	-- BEGIN Oracle Exception
		select @ACTIVITY_TYPE = min(ACTIVITY_TYPE)
		  from vwACTIVITIES_MyList
		 where ID               = @ID
		   and ASSIGNED_USER_ID = @USER_ID
		 group by ACTIVITY_TYPE;
	-- END Oracle Exception

	if @ACTIVITY_TYPE = N'Meetings' begin -- then
		update MEETINGS_USERS
		   set ACCEPT_STATUS    = @STATUS
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		 where MEETING_ID       = @ID
		   and USER_ID          = @USER_ID;
	end else if @ACTIVITY_TYPE = N'Calls' begin -- then
		update CALLS_USERS
		   set ACCEPT_STATUS    = @STATUS
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		 where CALL_ID          = @ID
		   and USER_ID          = @USER_ID;
	-- 06/09/2017 Paul.  Add support for Tasks reminders. 
	end else if @ACTIVITY_TYPE = N'Tasks' begin -- then
		if exists(select * from TASKS_USERS where TASK_ID = @ID and USER_ID = @USER_ID) begin -- then
			update TASKS_USERS
			   set ACCEPT_STATUS    = @STATUS
			     , MODIFIED_USER_ID = @MODIFIED_USER_ID
			     , DATE_MODIFIED    = getdate()
			     , DATE_MODIFIED_UTC= getutcdate()
			 where TASK_ID          = @ID
			   and USER_ID          = @USER_ID;
		end else begin
			-- 09/03/2017 Paul.  Need to create a new ID for TASKS_USERS. 
			insert into TASKS_USERS
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, DATE_MODIFIED_UTC
				, TASK_ID          
				, USER_ID          
				, ACCEPT_STATUS    
				)
			values
				( newid()           
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @MODIFIED_USER_ID 
				,  getdate()        
				,  getutcdate()     
				, @ID               
				, @USER_ID          
				, @STATUS           
				);
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spACTIVITIES_UpdateStatus to public;
GO

