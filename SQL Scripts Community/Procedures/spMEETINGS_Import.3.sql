if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMEETINGS_Import' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMEETINGS_Import;
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
-- 12/29/2007 Paul.  Add TEAM_ID so that it is not updated separately. 
-- 01/26/2009 Paul.  The current user is accepted by default. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 08/23/2009 Paul.  Decrease set list so that index plus ID will be less than 900 bytes. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 02/04/2010 Paul.  Special import procedure to allow date from ACT! import. 
-- 04/01/2012 Paul.  Add Meetings/Leads relationship. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 12/07/2018 Paul.  Allow Team Name to be specified during import. 
Create Procedure dbo.spMEETINGS_Import
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @DATE_MODIFIED     datetime
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(50)
	, @LOCATION          nvarchar(50)
	, @DURATION_HOURS    int
	, @DURATION_MINUTES  int
	, @DATE_TIME         datetime
	, @STATUS            nvarchar(25)
	, @PARENT_TYPE       nvarchar(25)
	, @PARENT_ID         uniqueidentifier
	, @REMINDER_TIME     int
	, @DESCRIPTION       nvarchar(max)
	, @INVITEE_LIST      varchar(8000)
	, @TEAM_ID           uniqueidentifier = null
	, @TEAM_SET_LIST     varchar(8000) = null
	, @ASSIGNED_SET_LIST varchar(8000) = null
	, @TEAM_NAME         nvarchar(128) = null
	)
as
  begin
	set nocount on
	
	declare @TEMP_DATE_MODIFIED  datetime;
	declare @DATE_START          datetime;
	declare @TIME_START          datetime;
	declare @DATE_END            datetime;
	declare @TEAM_SET_ID         uniqueidentifier;
	declare @ASSIGNED_SET_ID     uniqueidentifier;

	-- 12/15/2005 Paul.  Oracle uses fractions to add hours and minutes to date.  24 hours, 1440 minutes, 86400 seconds in a day. 
	-- 04/02/2006 Paul.  Use date functions so that the conversions will be simplified. 
	set @DATE_END   = dbo.fnDateAdd_Minutes(@DURATION_MINUTES, dbo.fnDateAdd_Hours(@DURATION_HOURS, @DATE_TIME));
	set @DATE_START = dbo.fnStoreDateOnly(@DATE_TIME);
	set @TIME_START = dbo.fnStoreTimeOnly(@DATE_TIME);
	-- 02/04/2010 Paul.  DATE_ENTERED cannot be NULL. 
	set @TEMP_DATE_MODIFIED = @DATE_MODIFIED;
	if @TEMP_DATE_MODIFIED is null begin -- then
		set @TEMP_DATE_MODIFIED = getdate();
	end -- if;

	-- 12/07/2018 Paul.  Allow Team Name to be specified during import. 
	if @TEAM_ID is null and @TEAM_NAME is not null begin -- then
		select @TEAM_ID = ID
		  from TEAMS
		 where NAME     = @TEAM_NAME
		   and DELETED  = 0;
	end -- if;

	-- 08/22/2009 Paul.  Normalize the team set by placing the primary ID first, then order list by ID and the name by team names. 
	-- 08/23/2009 Paul.  Use a team set so that team name changes can propagate. 
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;

	if not exists(select * from MEETINGS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into MEETINGS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, DATE_MODIFIED_UTC
			, ASSIGNED_USER_ID 
			, NAME             
			, LOCATION         
			, DURATION_HOURS   
			, DURATION_MINUTES 
			, DATE_START       
			, TIME_START       
			, DATE_END         
			, STATUS           
			, PARENT_TYPE      
			, PARENT_ID        
			, REMINDER_TIME    
			, DESCRIPTION      
			, TEAM_ID          
			, TEAM_SET_ID      
			, ASSIGNED_SET_ID  
			)
		values
			( @ID                
			, @MODIFIED_USER_ID  
			, @TEMP_DATE_MODIFIED
			, @MODIFIED_USER_ID  
			, @TEMP_DATE_MODIFIED
			,  getutcdate()      
			, @ASSIGNED_USER_ID  
			, @NAME              
			, @LOCATION          
			, @DURATION_HOURS    
			, @DURATION_MINUTES  
			, @DATE_START        
			, @TIME_START        
			, @DATE_END          
			, @STATUS            
			, @PARENT_TYPE       
			, @PARENT_ID         
			, @REMINDER_TIME     
			, @DESCRIPTION       
			, @TEAM_ID           
			, @TEAM_SET_ID       
			, @ASSIGNED_SET_ID   
			);
	end else begin
		-- 07/24/2012 Paul.  Import is used by Outlook Plug-in soap call, so we need to allow update. 
		update MEETINGS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID  
		     , DATE_MODIFIED     =  getdate()         
		     , DATE_MODIFIED_UTC =  getutcdate()      
		     , ASSIGNED_USER_ID  = @ASSIGNED_USER_ID  
		     , NAME              = @NAME              
		     , LOCATION          = @LOCATION          
		     , DURATION_HOURS    = @DURATION_HOURS    
		     , DURATION_MINUTES  = @DURATION_MINUTES  
		     , DATE_START        = @DATE_START        
		     , TIME_START        = @TIME_START        
		     , DATE_END          = @DATE_END          
		     , STATUS            = @STATUS            
		     , PARENT_TYPE       = @PARENT_TYPE       
		     , PARENT_ID         = @PARENT_ID         
		     , REMINDER_TIME     = @REMINDER_TIME     
		     , DESCRIPTION       = @DESCRIPTION       
		     , TEAM_ID           = @TEAM_ID           
		     , TEAM_SET_ID       = @TEAM_SET_ID       
		     , ASSIGNED_SET_ID   = @ASSIGNED_SET_ID   
		 where ID                = @ID                ;
		
		-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
		exec dbo.spSUGARFAVORITES_UpdateName @MODIFIED_USER_ID, @ID, @NAME;
	end -- if;

	-- 03/06/2006 Paul.  If insert fails, then the rest will as well. Just display the one error. 
	if @@ERROR = 0 begin -- then
		if not exists(select * from MEETINGS_CSTM where ID_C = @ID) begin -- then
			insert into MEETINGS_CSTM ( ID_C ) values ( @ID );
		end -- if;
		
		-- 08/21/2009 Paul.  Add or remove the team relationship records. 
		-- 08/30/2009 Paul.  Instead of using @TEAM_SET_LIST, use the @TEAM_SET_ID to build the module-specific team relationships. 
		-- 08/31/2009 Paul.  Instead of managing a separate teams relationship, we will leverage TEAM_SETS_TEAMS. 
		-- exec dbo.spMEETINGS_TEAMS_Update @ID, @MODIFIED_USER_ID, @TEAM_SET_ID;
		
		-- 07/15/2012 Paul.  If the invitee list is null, then don't change the relationships. 
		-- This should prevent the Outlook Plug-in from resetting the relationships. 
		if @INVITEE_LIST is not null begin -- then
			-- 04/02/2006 Paul.  Catch the Oracle NO_DATA_FOUND exception. 
			-- BEGIN Oracle Exception
				update MEETINGS_USERS
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     =  getdate()        
				     , DATE_MODIFIED_UTC =  getutcdate()     
				     , DELETED           = 1                 
				 where MEETING_ID        = @ID               ;
			-- END Oracle Exception
			
			-- BEGIN Oracle Exception
				update MEETINGS_CONTACTS
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     =  getdate()        
				     , DATE_MODIFIED_UTC =  getutcdate()     
				     , DELETED           = 1                 
				 where MEETING_ID        = @ID               ;
			-- END Oracle Exception
			
			-- 04/01/2012 Paul.  Add Meetings/Leads relationship. 
			-- BEGIN Oracle Exception
				update MEETINGS_LEADS
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     =  getdate()        
				     , DATE_MODIFIED_UTC =  getutcdate()     
				     , DELETED           = 1                 
				 where MEETING_ID        = @ID               ;
			-- END Oracle Exception
			
			exec dbo.spMEETINGS_InviteeMassUpdate @MODIFIED_USER_ID, @ID, @INVITEE_LIST, 1;
		end -- if;
		-- 03/06/2006 Paul.  Assigned user is optional, so only try to assign if provided. 
		if dbo.fnIsEmptyGuid(@ASSIGNED_USER_ID) = 0 begin -- then
			-- 01/26/2009 Paul.  The current user is accepted by default. 
			if @MODIFIED_USER_ID = @ASSIGNED_USER_ID begin -- then
				-- 01/26/2009 Paul.  Avoid updating the record if it is already correct. 
				if not exists(select * from MEETINGS_USERS where MEETING_ID = @ID and USER_ID = @MODIFIED_USER_ID and ACCEPT_STATUS = N'accept' and DELETED = 0) begin -- then
					exec dbo.spMEETINGS_USERS_Update @MODIFIED_USER_ID, @ID, @ASSIGNED_USER_ID, 1, N'accept';
				end -- if;
			end else begin
				exec dbo.spMEETINGS_USERS_Update @MODIFIED_USER_ID, @ID, @ASSIGNED_USER_ID, 1, null;
			end -- if;
		end -- if;
		
		if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
			-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
			exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @PARENT_ID, @PARENT_TYPE;
		end -- if;
	end -- if;

  end
GO

Grant Execute on dbo.spMEETINGS_Import to public;
GO

