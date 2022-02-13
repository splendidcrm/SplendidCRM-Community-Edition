if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCALL_MARKETING_Duplicate' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCALL_MARKETING_Duplicate;
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
-- 11/30/2017 Paul.  Add TEAM_SET_ID. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spCALL_MARKETING_Duplicate
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @DUPLICATE_ID      uniqueidentifier
	, @CAMPAIGN_ID       uniqueidentifier
	)
as
  begin
	set nocount on
	
	set @ID = null;
	if not exists(select * from vwCALL_MARKETING where ID = @DUPLICATE_ID) begin -- then
		raiserror(N'Cannot duplicate non-existent call marketing.', 16, 1);
		return;
	end -- if;

	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
	end -- if;
	insert into CALL_MARKETING
		( ID                 
		, CREATED_BY         
		, DATE_ENTERED       
		, MODIFIED_USER_ID   
		, DATE_MODIFIED      
		, CAMPAIGN_ID        
		, ASSIGNED_USER_ID   
		, TEAM_ID            
		, NAME               
		, STATUS             
		, DISTRIBUTION       
		, ALL_PROSPECT_LISTS 
		, SUBJECT            
		, DURATION_HOURS     
		, DURATION_MINUTES   
		, DATE_START         
		, TIME_START         
		, DATE_END           
		, TIME_END           
		, REMINDER_TIME      
		, DESCRIPTION        
		, TEAM_SET_ID        
		, ASSIGNED_SET_ID    
		)
	select @ID                 
		, @MODIFIED_USER_ID   
		,  getdate()          
		, @MODIFIED_USER_ID   
		,  getdate()          
		, @CAMPAIGN_ID        
		,  ASSIGNED_USER_ID   
		,  TEAM_ID            
		,  NAME               
		,  STATUS             
		,  DISTRIBUTION       
		,  ALL_PROSPECT_LISTS 
		,  SUBJECT            
		,  DURATION_HOURS     
		,  DURATION_MINUTES   
		,  DATE_START         
		,  TIME_START         
		,  DATE_END           
		,  TIME_END           
		,  REMINDER_TIME      
		,  DESCRIPTION        
		,  TEAM_SET_ID        
		,  ASSIGNED_SET_ID    
	  from CALL_MARKETING
	 where ID = @DUPLICATE_ID;

	insert into CALL_MARKETING_CSTM ( ID_C ) values ( @ID );
  end
GO
 
Grant Execute on dbo.spCALL_MARKETING_Duplicate to public;
GO

