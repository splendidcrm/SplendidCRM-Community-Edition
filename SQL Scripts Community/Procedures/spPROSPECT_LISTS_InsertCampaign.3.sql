if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPROSPECT_LISTS_InsertCampaign' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPROSPECT_LISTS_InsertCampaign;
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
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spPROSPECT_LISTS_InsertCampaign
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @CAMPAIGN_ID       uniqueidentifier
	, @NAME              nvarchar(50)
	, @DYNAMIC_SQL       nvarchar(max)
	)
as
  begin
	set nocount on
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
	end -- if;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	insert into PROSPECT_LISTS
		( ID               
		, CREATED_BY       
		, DATE_ENTERED     
		, MODIFIED_USER_ID 
		, DATE_MODIFIED    
		, DATE_MODIFIED_UTC
		, ASSIGNED_USER_ID 
		, NAME             
		, DESCRIPTION      
		, LIST_TYPE        
		, DOMAIN_NAME      
		, DYNAMIC_LIST     
		, TEAM_ID          
		, TEAM_SET_ID      
		, ASSIGNED_SET_ID  
		)
	select
		  @ID                
		, @MODIFIED_USER_ID  
		,  getdate()         
		, @MODIFIED_USER_ID  
		,  getdate()         
		,  getutcdate()      
		, ASSIGNED_USER_ID   
		, @NAME              
		, null               
		, N'default'         
		, null               
		, 1                  
		, TEAM_ID            
		, TEAM_SET_ID        
		, ASSIGNED_SET_ID    
	  from vwCAMPAIGNS
	 where ID = @CAMPAIGN_ID;

	if @@ERROR = 0 begin -- then
		if not exists(select * from PROSPECT_LISTS_CSTM where ID_C = @ID) begin -- then
			insert into PROSPECT_LISTS_CSTM ( ID_C ) values ( @ID );
		end -- if;
		
		exec dbo.spPROSPECT_LISTS_SQL_Update @ID, @MODIFIED_USER_ID, @DYNAMIC_SQL, null;
		exec dbo.spPROSPECT_LISTS_UpdateDynamic @ID, @MODIFIED_USER_ID;
	end -- if;
  end
GO

Grant Execute on dbo.spPROSPECT_LISTS_InsertCampaign to public;
GO

