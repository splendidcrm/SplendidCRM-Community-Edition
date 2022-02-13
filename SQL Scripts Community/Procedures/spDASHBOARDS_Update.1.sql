if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDASHBOARDS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDASHBOARDS_Update;
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
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 06/14/2017 Paul.  Add CATEGORY for separate home/dashboard pages. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spDASHBOARDS_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @TEAM_ID           uniqueidentifier
	, @TEAM_SET_LIST     varchar(8000)
	, @NAME              nvarchar(100)
	, @CATEGORY          nvarchar( 50)
	, @DESCRIPTION       nvarchar(max)
	, @CONTENT           nvarchar(max)
	, @ASSIGNED_SET_LIST varchar(8000) = null
	)
as
  begin
	set nocount on
	
	declare @TEAM_SET_ID         uniqueidentifier;
	declare @ASSIGNED_SET_ID     uniqueidentifier;
	
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;
	
	if not exists(select * from DASHBOARDS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into DASHBOARDS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, ASSIGNED_USER_ID 
			, TEAM_ID          
			, TEAM_SET_ID      
			, NAME             
			, CATEGORY         
			, DESCRIPTION      
			, CONTENT          
			, ASSIGNED_SET_ID  
			)
		values 	( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @ASSIGNED_USER_ID 
			, @TEAM_ID          
			, @TEAM_SET_ID      
			, @NAME             
			, @CATEGORY         
			, @DESCRIPTION      
			, @CONTENT          
			, @ASSIGNED_SET_ID  
			);
	end else begin
		update DASHBOARDS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , ASSIGNED_USER_ID  = @ASSIGNED_USER_ID 
		     , TEAM_ID           = @TEAM_ID          
		     , TEAM_SET_ID       = @TEAM_SET_ID      
		     , NAME              = @NAME             
		     , CATEGORY          = @CATEGORY         
		     , DESCRIPTION       = @DESCRIPTION      
		     , CONTENT           = @CONTENT          
		     , ASSIGNED_SET_ID   = @ASSIGNED_SET_ID  
		 where ID                = @ID               ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spDASHBOARDS_Update to public;
GO
 
