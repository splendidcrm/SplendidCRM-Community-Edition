if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPROJECTS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPROJECTS_Update;
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
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 08/23/2009 Paul.  Decrease set list so that index plus ID will be less than 900 bytes. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 01/13/2010 Paul.  New Project fields in SugarCRM. 
-- 04/07/2010 Paul.  Add EXCHANGE_FOLDER. 
-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spPROJECTS_Update
	( @ID                   uniqueidentifier output
	, @MODIFIED_USER_ID     uniqueidentifier
	, @ASSIGNED_USER_ID     uniqueidentifier
	, @NAME                 nvarchar(50)
	, @DESCRIPTION          nvarchar(max)
	, @PARENT_TYPE          nvarchar(25)
	, @PARENT_ID            uniqueidentifier
	, @TEAM_ID              uniqueidentifier = null
	, @TEAM_SET_LIST        varchar(8000) = null
	, @ESTIMATED_START_DATE datetime = null
	, @ESTIMATED_END_DATE   datetime = null
	, @STATUS               nvarchar(25) = null
	, @PRIORITY             nvarchar(25) = null
	, @IS_TEMPLATE          bit = null
	, @EXCHANGE_FOLDER      bit = null
	, @TAG_SET_NAME         nvarchar(4000) = null
	, @ASSIGNED_SET_LIST    varchar(8000) = null
	)
as
  begin
	set nocount on
	
	declare @TEAM_SET_ID         uniqueidentifier;
	declare @ASSIGNED_SET_ID     uniqueidentifier;

	-- 08/22/2009 Paul.  Normalize the team set by placing the primary ID first, then order list by ID and the name by team names. 
	-- 08/23/2009 Paul.  Use a team set so that team name changes can propagate. 
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;

	if not exists(select * from PROJECT where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into PROJECT
			( ID                  
			, CREATED_BY          
			, DATE_ENTERED        
			, MODIFIED_USER_ID    
			, DATE_MODIFIED       
			, DATE_MODIFIED_UTC   
			, ASSIGNED_USER_ID    
			, NAME                
			, ESTIMATED_START_DATE
			, ESTIMATED_END_DATE  
			, STATUS              
			, PRIORITY            
			, IS_TEMPLATE         
			, DESCRIPTION         
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
			, @ESTIMATED_START_DATE
			, @ESTIMATED_END_DATE  
			, @STATUS              
			, @PRIORITY            
			, @IS_TEMPLATE         
			, @DESCRIPTION         
			, @TEAM_ID             
			, @TEAM_SET_ID         
			, @ASSIGNED_SET_ID     
			);
	end else begin
		update PROJECT
		   set MODIFIED_USER_ID     = @MODIFIED_USER_ID    
		     , DATE_MODIFIED        =  getdate()           
		     , DATE_MODIFIED_UTC    =  getutcdate()        
		     , ASSIGNED_USER_ID     = @ASSIGNED_USER_ID    
		     , NAME                 = @NAME                
		     , ESTIMATED_START_DATE = @ESTIMATED_START_DATE
		     , ESTIMATED_END_DATE   = @ESTIMATED_END_DATE  
		     , STATUS               = @STATUS              
		     , PRIORITY             = @PRIORITY            
		     , IS_TEMPLATE          = @IS_TEMPLATE         
		     , DESCRIPTION          = @DESCRIPTION         
		     , TEAM_ID              = @TEAM_ID             
		     , TEAM_SET_ID          = @TEAM_SET_ID         
		     , ASSIGNED_SET_ID      = @ASSIGNED_SET_ID     
		 where ID                   = @ID                  ;
		
		-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
		exec dbo.spSUGARFAVORITES_UpdateName @MODIFIED_USER_ID, @ID, @NAME;
	end -- if;

	-- 08/22/2009 Paul.  If insert fails, then the rest will as well. Just display the one error. 
	if @@ERROR = 0 begin -- then
		-- 05/10/2007 Paul.  Always check to ensure that the matching custom record exists. 
		if not exists(select * from PROJECT_CSTM where ID_C = @ID) begin -- then
			insert into PROJECT_CSTM ( ID_C ) values ( @ID );
		end -- if;
		
		-- 08/21/2009 Paul.  Add or remove the team relationship records. 
		-- 08/30/2009 Paul.  Instead of using @TEAM_SET_LIST, use the @TEAM_SET_ID to build the module-specific team relationships. 
		-- 08/31/2009 Paul.  Instead of managing a separate teams relationship, we will leverage TEAM_SETS_TEAMS. 
		-- exec dbo.spPROJECT_TEAMS_Update @ID, @MODIFIED_USER_ID, @TEAM_SET_ID;
		
		if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
			exec dbo.spPROJECT_RELATION_Update @MODIFIED_USER_ID, @ID, @PARENT_TYPE, @PARENT_ID;
		end -- if;

		-- 04/07/2010 Paul.  If the Exchange Folder value is NULL, then don't do anything. This is to prevent the Exchange from unsyncing after update. 
		if @EXCHANGE_FOLDER = 0 begin -- then
			exec dbo.spPROJECT_USERS_Delete @MODIFIED_USER_ID, @ID, @MODIFIED_USER_ID;
		end else if @EXCHANGE_FOLDER = 1 begin -- then
			exec dbo.spPROJECT_USERS_Update @MODIFIED_USER_ID, @ID, @MODIFIED_USER_ID;
		end -- if;
	end -- if;
	-- 05/12/2016 Paul.  Add Tags module. Must add after @ID is set. 
	if @@ERROR = 0 begin -- then
		exec dbo.spTAG_SETS_NormalizeSet @MODIFIED_USER_ID, @ID, N'Project', @TAG_SET_NAME;
	end -- if;
  end
GO

Grant Execute on dbo.spPROJECTS_Update to public;
GO

