if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGNS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGNS_Update;
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
-- 04/21/2006 Paul.  CURRENCY_ID was added in SugarCRM 4.2.
-- 12/25/2007 Paul.  IMPRESSIONS was added in SugarCRM 4.5.1
-- 12/25/2007 Paul.  FREQUENCY was added in SugarCRM 4.5.1
-- 12/25/2007 Paul.  Add USDOLLAR fields so that they can be automatically converted. 
-- 12/29/2007 Paul.  Add TEAM_ID so that it is not updated separately. 
-- 07/25/2009 Paul.  TRACKER_KEY is no longer an identity and must be formatted. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 08/23/2009 Paul.  Decrease set list so that index plus ID will be less than 900 bytes. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
-- 05/17/2017 Paul.  Add Tags module. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spCAMPAIGNS_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(50)
	, @REFER_URL         nvarchar(255)
	, @TRACKER_TEXT      nvarchar(255)
	, @START_DATE        datetime
	, @END_DATE          datetime
	, @STATUS            nvarchar(25)
	, @BUDGET            money
	, @EXPECTED_COST     money
	, @ACTUAL_COST       money
	, @EXPECTED_REVENUE  money
	, @CAMPAIGN_TYPE     nvarchar(25)
	, @OBJECTIVE         nvarchar(max)
	, @CONTENT           nvarchar(max)
	, @CURRENCY_ID       uniqueidentifier
	, @IMPRESSIONS       int = null
	, @FREQUENCY         nvarchar(25) = null
	, @TRACKER_KEY       nvarchar(30) = null
	, @TEAM_ID           uniqueidentifier = null
	, @TEAM_SET_LIST     varchar(8000) = null
	, @TAG_SET_NAME      nvarchar(4000) = null
	, @CAMPAIGN_NUMBER   nvarchar(30) = null
	, @ASSIGNED_SET_LIST varchar(8000) = null
	)
as
  begin
	set nocount on
	
	-- 12/25/2007 Paul.  Convert currency to USD. 
	declare @BUDGET_USDOLLAR           money;
	declare @EXPECTED_COST_USDOLLAR    money;
	declare @ACTUAL_COST_USDOLLAR      money;
	declare @EXPECTED_REVENUE_USDOLLAR money;
	declare @TEMP_TRACKER_KEY          nvarchar(30);
	declare @TEMP_CAMPAIGN_NUMBER      nvarchar(30);
	declare @TEAM_SET_ID               uniqueidentifier;
	declare @ASSIGNED_SET_ID           uniqueidentifier;
	-- BEGIN Oracle Exception
		-- 06/08/2006 Paul.  We could convert all the values in a single statement, 
		-- but then it becomes a pain to convert the code to the other database platforms. 
		-- It is a minor performance issue, so lets ignore it. 
		select @BUDGET_USDOLLAR           = @BUDGET           / CONVERSION_RATE
		  from CURRENCIES
		 where ID = @CURRENCY_ID;
		select @EXPECTED_COST_USDOLLAR    = @EXPECTED_COST    / CONVERSION_RATE
		  from CURRENCIES
		 where ID = @CURRENCY_ID;
		select @ACTUAL_COST_USDOLLAR      = @ACTUAL_COST      / CONVERSION_RATE
		  from CURRENCIES
		 where ID = @CURRENCY_ID;
		select @EXPECTED_REVENUE_USDOLLAR = @EXPECTED_REVENUE / CONVERSION_RATE
		  from CURRENCIES
		 where ID = @CURRENCY_ID;
	-- END Oracle Exception

	set @TEMP_TRACKER_KEY = @TRACKER_KEY;
	set @TEMP_CAMPAIGN_NUMBER = @CAMPAIGN_NUMBER;

	-- 08/22/2009 Paul.  Normalize the team set by placing the primary ID first, then order list by ID and the name by team names. 
	-- 08/23/2009 Paul.  Use a team set so that team name changes can propagate. 
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;

	if not exists(select * from CAMPAIGNS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		-- 07/25/2009 Paul.  Allow the TRACKER_KEY to be imported. 
		if @TEMP_TRACKER_KEY is null begin -- then
			exec dbo.spNUMBER_SEQUENCES_Formatted 'CAMPAIGNS.TRACKER_KEY', 1, @TEMP_TRACKER_KEY out;
		end -- if;
		-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
		if @TEMP_CAMPAIGN_NUMBER is null begin -- then
			exec dbo.spNUMBER_SEQUENCES_Formatted 'CAMPAIGNS.CAMPAIGN_NUMBER', 1, @TEMP_CAMPAIGN_NUMBER out;
		end -- if;
		insert into CAMPAIGNS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, DATE_MODIFIED_UTC
			, ASSIGNED_USER_ID 
			, TRACKER_KEY      
			, CAMPAIGN_NUMBER  
			, NAME             
			, REFER_URL        
			, TRACKER_TEXT     
			, START_DATE       
			, END_DATE         
			, STATUS           
			, BUDGET           
			, BUDGET_USDOLLAR  
			, EXPECTED_COST    
			, EXPECTED_COST_USDOLLAR
			, ACTUAL_COST      
			, ACTUAL_COST_USDOLLAR
			, EXPECTED_REVENUE 
			, EXPECTED_REVENUE_USDOLLAR
			, CAMPAIGN_TYPE    
			, OBJECTIVE        
			, CONTENT          
			, CURRENCY_ID      
			, IMPRESSIONS      
			, FREQUENCY        
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
			, @TEMP_TRACKER_KEY         
			, @TEMP_CAMPAIGN_NUMBER     
			, @NAME                     
			, @REFER_URL                
			, @TRACKER_TEXT             
			, @START_DATE               
			, @END_DATE                 
			, @STATUS                   
			, @BUDGET                   
			, @BUDGET_USDOLLAR          
			, @EXPECTED_COST            
			, @EXPECTED_COST_USDOLLAR   
			, @ACTUAL_COST              
			, @ACTUAL_COST_USDOLLAR     
			, @EXPECTED_REVENUE         
			, @EXPECTED_REVENUE_USDOLLAR
			, @CAMPAIGN_TYPE            
			, @OBJECTIVE                
			, @CONTENT                  
			, @CURRENCY_ID              
			, @IMPRESSIONS              
			, @FREQUENCY                
			, @TEAM_ID                  
			, @TEAM_SET_ID              
			, @ASSIGNED_SET_ID          
			);
	end else begin
		update CAMPAIGNS
		   set MODIFIED_USER_ID           = @MODIFIED_USER_ID         
		     , DATE_MODIFIED              =  getdate()                
		     , DATE_MODIFIED_UTC          =  getutcdate()             
		     , ASSIGNED_USER_ID           = @ASSIGNED_USER_ID         
		     , TRACKER_KEY                = isnull(@TEMP_TRACKER_KEY, TRACKER_KEY)
		     , CAMPAIGN_NUMBER            = isnull(@TEMP_CAMPAIGN_NUMBER, CAMPAIGN_NUMBER)
		     , NAME                       = @NAME                     
		     , REFER_URL                  = @REFER_URL                
		     , TRACKER_TEXT               = @TRACKER_TEXT             
		     , START_DATE                 = @START_DATE               
		     , END_DATE                   = @END_DATE                 
		     , STATUS                     = @STATUS                   
		     , BUDGET                     = @BUDGET                   
		     , BUDGET_USDOLLAR            = @BUDGET_USDOLLAR          
		     , EXPECTED_COST              = @EXPECTED_COST            
		     , EXPECTED_COST_USDOLLAR     = @EXPECTED_COST_USDOLLAR   
		     , ACTUAL_COST                = @ACTUAL_COST              
		     , ACTUAL_COST_USDOLLAR       = @ACTUAL_COST_USDOLLAR     
		     , EXPECTED_REVENUE           = @EXPECTED_REVENUE         
		     , EXPECTED_REVENUE_USDOLLAR  = @EXPECTED_REVENUE_USDOLLAR
		     , CAMPAIGN_TYPE              = @CAMPAIGN_TYPE            
		     , OBJECTIVE                  = @OBJECTIVE                
		     , CONTENT                    = @CONTENT                  
		     , CURRENCY_ID                = @CURRENCY_ID              
		     , IMPRESSIONS                = @IMPRESSIONS              
		     , FREQUENCY                  = @FREQUENCY                
		     , TEAM_ID                    = @TEAM_ID                  
		     , TEAM_SET_ID                = @TEAM_SET_ID              
		     , ASSIGNED_SET_ID            = @ASSIGNED_SET_ID          
		 where ID                         = @ID                       ;
		
		-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
		exec dbo.spSUGARFAVORITES_UpdateName @MODIFIED_USER_ID, @ID, @NAME;
	end -- if;

	-- 08/22/2009 Paul.  If insert fails, then the rest will as well. Just display the one error. 
	if @@ERROR = 0 begin -- then
		if not exists(select * from CAMPAIGNS_CSTM where ID_C = @ID) begin -- then
			insert into CAMPAIGNS_CSTM ( ID_C ) values ( @ID );
		end -- if;

		-- 08/21/2009 Paul.  Add or remove the team relationship records. 
		-- 08/30/2009 Paul.  Instead of using @TEAM_SET_LIST, use the @TEAM_SET_ID to build the module-specific team relationships. 
		-- 08/31/2009 Paul.  Instead of managing a separate teams relationship, we will leverage TEAM_SETS_TEAMS. 
		-- exec dbo.spCAMPAIGNS_TEAMS_Update @ID, @MODIFIED_USER_ID, @TEAM_SET_ID;
	end -- if;
	-- 05/17/2017 Paul.  Add Tags module. Must add after @ID is set. 
	if @@ERROR = 0 begin -- then
		exec dbo.spTAG_SETS_NormalizeSet @MODIFIED_USER_ID, @ID, N'Campaigns', @TAG_SET_NAME;
	end -- if;
  end
GO

Grant Execute on dbo.spCAMPAIGNS_Update to public;
GO

