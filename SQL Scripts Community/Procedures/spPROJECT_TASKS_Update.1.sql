if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPROJECT_TASKS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPROJECT_TASKS_Update;
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
-- 02/19/2009 Paul.  We must create a matching custom field record.
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 08/23/2009 Paul.  Decrease set list so that index plus ID will be less than 900 bytes. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 01/19/2010 Paul.  Some customers have requested that we allow for fractional efforts. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spPROJECT_TASKS_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(50)
	, @STATUS            nvarchar(25)
	, @DATE_TIME_DUE     datetime
	, @DATE_TIME_START   datetime
	, @PARENT_ID         uniqueidentifier
	, @PRIORITY          nvarchar(25)
	, @DESCRIPTION       nvarchar(max)
	, @ORDER_NUMBER      int
	, @TASK_NUMBER       int
	, @DEPENDS_ON_ID     uniqueidentifier
	, @MILESTONE_FLAG    bit
	, @ESTIMATED_EFFORT  float
	, @ACTUAL_EFFORT     float
	, @UTILIZATION       int
	, @PERCENT_COMPLETE  int
	, @TEAM_ID           uniqueidentifier = null
	, @TEAM_SET_LIST     varchar(8000) = null
	, @ASSIGNED_SET_LIST varchar(8000) = null
	)
as
  begin
	set nocount on
	
	declare @DATE_START          datetime;
	declare @TIME_START          datetime;
	declare @DATE_DUE            datetime;
	declare @TIME_DUE            datetime;
	declare @TEAM_SET_ID         uniqueidentifier;
	declare @ASSIGNED_SET_ID     uniqueidentifier;
	set @DATE_START = dbo.fnStoreDateOnly(@DATE_TIME_START);
	set @TIME_START = dbo.fnStoreTimeOnly(@DATE_TIME_START);
	set @DATE_DUE   = dbo.fnStoreDateOnly(@DATE_TIME_DUE  );
	set @TIME_DUE   = dbo.fnStoreTimeOnly(@DATE_TIME_DUE  );


	-- 08/22/2009 Paul.  Normalize the team set by placing the primary ID first, then order list by ID and the name by team names. 
	-- 08/23/2009 Paul.  Use a team set so that team name changes can propagate. 
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;

	if not exists(select * from PROJECT_TASK where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into PROJECT_TASK
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, DATE_MODIFIED_UTC
			, ASSIGNED_USER_ID 
			, NAME             
			, STATUS           
			, DATE_DUE         
			, TIME_DUE         
			, DATE_START       
			, TIME_START       
			, PARENT_ID        
			, PRIORITY         
			, DESCRIPTION      
			, ORDER_NUMBER     
			, TASK_NUMBER      
			, DEPENDS_ON_ID    
			, MILESTONE_FLAG   
			, ESTIMATED_EFFORT 
			, ACTUAL_EFFORT    
			, UTILIZATION      
			, PERCENT_COMPLETE 
			, TEAM_ID          
			, TEAM_SET_ID      
			, ASSIGNED_SET_ID  
			)
		values
			( @ID                
			, @MODIFIED_USER_ID  
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			,  getutcdate()      
			, @ASSIGNED_USER_ID  
			, @NAME              
			, @STATUS            
			, @DATE_DUE          
			, @TIME_DUE          
			, @DATE_START        
			, @TIME_START        
			, @PARENT_ID         
			, @PRIORITY          
			, @DESCRIPTION       
			, @ORDER_NUMBER      
			, @TASK_NUMBER       
			, @DEPENDS_ON_ID     
			, @MILESTONE_FLAG    
			, @ESTIMATED_EFFORT  
			, @ACTUAL_EFFORT     
			, @UTILIZATION       
			, @PERCENT_COMPLETE  
			, @TEAM_ID           
			, @TEAM_SET_ID       
			, @ASSIGNED_SET_ID   
			);
	end else begin
		update PROJECT_TASK
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID  
		     , DATE_MODIFIED     =  getdate()         
		     , DATE_MODIFIED_UTC =  getutcdate()      
		     , ASSIGNED_USER_ID  = @ASSIGNED_USER_ID  
		     , NAME              = @NAME              
		     , STATUS            = @STATUS            
		     , DATE_DUE          = @DATE_DUE          
		     , TIME_DUE          = @TIME_DUE          
		     , DATE_START        = @DATE_START        
		     , TIME_START        = @TIME_START        
		     , PARENT_ID         = @PARENT_ID         
		     , PRIORITY          = @PRIORITY          
		     , DESCRIPTION       = @DESCRIPTION       
		     , ORDER_NUMBER      = @ORDER_NUMBER      
		     , TASK_NUMBER       = @TASK_NUMBER       
		     , DEPENDS_ON_ID     = @DEPENDS_ON_ID     
		     , MILESTONE_FLAG    = @MILESTONE_FLAG    
		     , ESTIMATED_EFFORT  = @ESTIMATED_EFFORT  
		     , ACTUAL_EFFORT     = @ACTUAL_EFFORT     
		     , UTILIZATION       = @UTILIZATION       
		     , PERCENT_COMPLETE  = @PERCENT_COMPLETE  
		     , TEAM_ID           = @TEAM_ID           
		     , TEAM_SET_ID       = @TEAM_SET_ID       
		     , ASSIGNED_SET_ID   = @ASSIGNED_SET_ID   
		 where ID                = @ID                ;
	end -- if;

	-- 08/22/2009 Paul.  If insert fails, then the rest will as well. Just display the one error. 
	if @@ERROR = 0 begin -- then
		-- 02/19/2009 Paul.  We must create a matching custom field record.
		if not exists(select * from PROJECT_TASK_CSTM where ID_C = @ID) begin -- then
			insert into PROJECT_TASK_CSTM ( ID_C ) values ( @ID );
		end -- if;
		
		-- 08/21/2009 Paul.  Add or remove the team relationship records. 
		-- 08/30/2009 Paul.  Instead of using @TEAM_SET_LIST, use the @TEAM_SET_ID to build the module-specific team relationships. 
		-- 08/31/2009 Paul.  Instead of managing a separate teams relationship, we will leverage TEAM_SETS_TEAMS. 
		-- exec dbo.spPROJECT_TASK_TEAMS_Update @ID, @MODIFIED_USER_ID, @TEAM_SET_ID;
	end -- if;

  end
GO

Grant Execute on dbo.spPROJECT_TASKS_Update to public;
GO

