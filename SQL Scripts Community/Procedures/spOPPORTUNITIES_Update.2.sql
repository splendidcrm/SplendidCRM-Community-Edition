if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spOPPORTUNITIES_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spOPPORTUNITIES_Update;
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
-- 02/19/2008 Paul.  Move relationship management to spACCOUNTS_OPPORTUNITIES_Update. 
-- 08/27/2008 Paul.  PostgreSQL does not allow modifying input parameters.  Use a local temp variable. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 08/23/2009 Paul.  Decrease set list so that index plus ID will be less than 900 bytes. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 12/16/2009 Paul.  CAMPAIGN_ID should have been added long ago. 
-- This will allow proper tracking when a lead is converted. 
-- 01/05/2009 Paul.  CAMPAIGN_ID should be optional. 
-- 04/07/2010 Paul.  Add EXCHANGE_FOLDER.
-- 10/05/2010 Paul.  Increase the size of the NAME field. 
-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
-- 05/01/2013 Paul.  Add Contacts field to support B2C. 
-- 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spOPPORTUNITIES_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @ACCOUNT_ID        uniqueidentifier
	, @NAME              nvarchar(150)
	, @OPPORTUNITY_TYPE  nvarchar(255)
	, @LEAD_SOURCE       nvarchar(50)
	, @AMOUNT            money
	, @CURRENCY_ID       uniqueidentifier
	, @DATE_CLOSED       datetime
	, @NEXT_STEP         nvarchar(100)
	, @SALES_STAGE       nvarchar(25)
	, @PROBABILITY       float
	, @DESCRIPTION       nvarchar(max)
	, @PARENT_TYPE       nvarchar(25)
	, @PARENT_ID         uniqueidentifier
	, @ACCOUNT_NAME      nvarchar(100)
	, @TEAM_ID           uniqueidentifier = null
	, @TEAM_SET_LIST     varchar(8000) = null
	, @CAMPAIGN_ID       uniqueidentifier = null
	, @EXCHANGE_FOLDER   bit = null
	, @B2C_CONTACT_ID    uniqueidentifier = null
	, @LEAD_ID           uniqueidentifier = null
	, @TAG_SET_NAME      nvarchar(4000) = null
	, @OPPORTUNITY_NUMBER nvarchar(30) = null
	, @ASSIGNED_SET_LIST  varchar(8000) = null
	)
as
  begin
	set nocount on
	
	-- 09/19/2005 Paul.  Convert currency to USD. 
	declare @AMOUNT_USDOLLAR     money;
	declare @TEMP_ACCOUNT_ID     uniqueidentifier;
	declare @TEAM_SET_ID         uniqueidentifier;
	declare @ASSIGNED_SET_ID     uniqueidentifier;
	declare @TEMP_OPPORTUNITY_NUMBER nvarchar(30);

	set @TEMP_ACCOUNT_ID = @ACCOUNT_ID;
	set @TEMP_OPPORTUNITY_NUMBER = @OPPORTUNITY_NUMBER;
	set @AMOUNT_USDOLLAR = @AMOUNT;
	-- 04/02/2006 Paul.  Catch the Oracle NO_DATA_FOUND exception. 
	-- BEGIN Oracle Exception
		select @AMOUNT_USDOLLAR = @AMOUNT / CONVERSION_RATE
		  from CURRENCIES
		 where ID = @CURRENCY_ID;
	-- END Oracle Exception

	-- 08/22/2009 Paul.  Normalize the team set by placing the primary ID first, then order list by ID and the name by team names. 
	-- 08/23/2009 Paul.  Use a team set so that team name changes can propagate. 
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;

	-- 11/02/2006 Paul.  If the ACCOUNT_ID is null, then look it up using @ACCOUNT_NAME. 
	-- Converting an account name to an account ID is important to allow importing. 
	-- 02/20/2008 Paul.  Only lookup if @ACCOUNT_NAME is provided. 
	if dbo.fnIsEmptyGuid(@TEMP_ACCOUNT_ID) = 1 and @ACCOUNT_NAME is not null begin -- then
		-- BEGIN Oracle Exception
			select @TEMP_ACCOUNT_ID = ID
			  from ACCOUNTS
			 where NAME        = @ACCOUNT_NAME
			   and DELETED     = 0;
		-- END Oracle Exception
		-- 02/20/2008 Paul.  If account does not exist, then it will be created. 
		-- This is primarily for importing. 
		if dbo.fnIsEmptyGuid(@TEMP_ACCOUNT_ID) = 1 begin -- then
			-- 08/21/2009 Paul.  The layout of spACCOUNTS_Update changed to put the two team fields together and at the end. 
			-- 05/24/2015 Paul.  Add picture. 
			-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			exec dbo.spACCOUNTS_Update
				  @TEMP_ACCOUNT_ID out
				, @MODIFIED_USER_ID
				, @ASSIGNED_USER_ID
				, @ACCOUNT_NAME
				, null                          -- @ACCOUNT_TYPE                 
				, null                          -- @PARENT_ID                    
				, null                          -- @INDUSTRY                     
				, null                          -- @ANNUAL_REVENUE               
				, null                          -- @PHONE_FAX                    
				, null                          -- @BILLING_ADDRESS_STREET       
				, null                          -- @BILLING_ADDRESS_CITY         
				, null                          -- @BILLING_ADDRESS_STATE        
				, null                          -- @BILLING_ADDRESS_POSTALCODE   
				, null                          -- @BILLING_ADDRESS_COUNTRY      
				, null                          -- @DESCRIPTION                  
				, null                          -- @RATING                       
				, null                          -- @PHONE_OFFICE                 
				, null                          -- @PHONE_ALTERNATE              
				, null                          -- @EMAIL1                       
				, null                          -- @EMAIL2                       
				, null                          -- @WEBSITE                      
				, null                          -- @OWNERSHIP                    
				, null                          -- @EMPLOYEES                    
				, null                          -- @SIC_CODE                     
				, null                          -- @TICKER_SYMBOL                
				, null                          -- @SHIPPING_ADDRESS_STREET      
				, null                          -- @SHIPPING_ADDRESS_CITY        
				, null                          -- @SHIPPING_ADDRESS_STATE       
				, null                          -- @SHIPPING_ADDRESS_POSTALCODE  
				, null                          -- @SHIPPING_ADDRESS_COUNTRY     
				, null                          -- @ACCOUNT_NUMBER
				, @TEAM_ID
				, @TEAM_SET_LIST
				, null                          -- @EXCHANGE_FOLDER
				, null                          -- @PICTURE
				, @ASSIGNED_SET_LIST
				;
		end -- if;
	end -- if;

	if not exists(select * from OPPORTUNITIES where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
		if @TEMP_OPPORTUNITY_NUMBER is null begin -- then
			exec dbo.spNUMBER_SEQUENCES_Formatted 'OPPORTUNITIES.OPPORTUNITY_NUMBER', 1, @TEMP_OPPORTUNITY_NUMBER out;
		end -- if;
		insert into OPPORTUNITIES
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, DATE_MODIFIED_UTC
			, ASSIGNED_USER_ID 
			, OPPORTUNITY_NUMBER
			, NAME             
			, OPPORTUNITY_TYPE 
			, LEAD_SOURCE      
			, AMOUNT           
			, AMOUNT_USDOLLAR  
			, CURRENCY_ID      
			, DATE_CLOSED      
			, NEXT_STEP        
			, SALES_STAGE      
			, PROBABILITY      
			, DESCRIPTION      
			, TEAM_ID          
			, TEAM_SET_ID      
			, CAMPAIGN_ID      
			, B2C_CONTACT_ID   
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
			, @TEMP_OPPORTUNITY_NUMBER
			, @NAME              
			, @OPPORTUNITY_TYPE  
			, @LEAD_SOURCE       
			, @AMOUNT            
			, @AMOUNT_USDOLLAR   
			, @CURRENCY_ID       
			, @DATE_CLOSED       
			, @NEXT_STEP         
			, @SALES_STAGE       
			, @PROBABILITY       
			, @DESCRIPTION       
			, @TEAM_ID           
			, @TEAM_SET_ID       
			, @CAMPAIGN_ID       
			, @B2C_CONTACT_ID    
			, @ASSIGNED_SET_ID   
			);
	end else begin
		update OPPORTUNITIES
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID  
		     , DATE_MODIFIED     =  getdate()         
		     , DATE_MODIFIED_UTC =  getutcdate()      
		     , ASSIGNED_USER_ID  = @ASSIGNED_USER_ID  
		     , OPPORTUNITY_NUMBER= isnull(@TEMP_OPPORTUNITY_NUMBER, OPPORTUNITY_NUMBER)
		     , NAME              = @NAME              
		     , OPPORTUNITY_TYPE  = @OPPORTUNITY_TYPE  
		     , LEAD_SOURCE       = @LEAD_SOURCE       
		     , AMOUNT            = @AMOUNT            
		     , AMOUNT_USDOLLAR   = @AMOUNT_USDOLLAR   
		     , CURRENCY_ID       = @CURRENCY_ID       
		     , DATE_CLOSED       = @DATE_CLOSED       
		     , NEXT_STEP         = @NEXT_STEP         
		     , SALES_STAGE       = @SALES_STAGE       
		     , PROBABILITY       = @PROBABILITY       
		     , DESCRIPTION       = @DESCRIPTION       
		     , TEAM_ID           = @TEAM_ID           
		     , TEAM_SET_ID       = @TEAM_SET_ID       
		     , CAMPAIGN_ID       = @CAMPAIGN_ID       
		     , B2C_CONTACT_ID    = @B2C_CONTACT_ID    
		     , ASSIGNED_SET_ID   = @ASSIGNED_SET_ID   
		 where ID                = @ID                ;
		-- Delete any existing account/opportunity relationships for this opportunity. 
		-- 02/19/2008 Paul.  Move relationship management to spACCOUNTS_OPPORTUNITIES_Update. 
		/*
		-- 04/02/2006 Paul.  Catch the Oracle NO_DATA_FOUND exception. 
		-- BEGIN Oracle Exception
			update ACCOUNTS_OPPORTUNITIES
			   set DELETED          = 1                
			     , MODIFIED_USER_ID = @MODIFIED_USER_ID
			     , DATE_MODIFIED    =  getdate()        
			     , DATE_MODIFIED_UTC=  getutcdate()     
			 where OPPORTUNITY_ID   = @ID              ;
		-- END Oracle Exception
		*/
		
		-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
		exec dbo.spSUGARFAVORITES_UpdateName @MODIFIED_USER_ID, @ID, @NAME;
	end -- if;

	-- 03/06/2006 Paul.  If insert fails, then the rest will as well. Just display the one error. 
	if @@ERROR = 0 begin -- then
		if not exists(select * from OPPORTUNITIES_CSTM where ID_C = @ID) begin -- then
			insert into OPPORTUNITIES_CSTM ( ID_C ) values ( @ID );
		end -- if;
		
		-- 08/21/2009 Paul.  Add or remove the team relationship records. 
		-- 08/30/2009 Paul.  Instead of using @TEAM_SET_LIST, use the @TEAM_SET_ID to build the module-specific team relationships. 
		-- 08/31/2009 Paul.  Instead of managing a separate teams relationship, we will leverage TEAM_SETS_TEAMS. 
		-- exec dbo.spOPPORTUNITIES_TEAMS_Update @ID, @MODIFIED_USER_ID, @TEAM_SET_ID;
		
		-- 03/06/2006 Paul.  First remove any account relationships before assigning again. 
		-- This will prevent an opportunity from being assigned to multiple accounts. 
		-- 02/19/2008 Paul.  Move relationship management to spACCOUNTS_OPPORTUNITIES_Update. 
		/*
		-- 04/02/2006 Paul.  Catch the Oracle NO_DATA_FOUND exception. 
		-- BEGIN Oracle Exception
			update ACCOUNTS_OPPORTUNITIES
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , DELETED           = 1                 
			 where OPPORTUNITY_ID    = @ID               ;
		-- END Oracle Exception
		*/
		-- Assign any new account. 
		if dbo.fnIsEmptyGuid(@TEMP_ACCOUNT_ID) = 0 begin -- then
			exec dbo.spACCOUNTS_OPPORTUNITIES_Update @MODIFIED_USER_ID, @TEMP_ACCOUNT_ID, @ID;
		end -- if;
		-- 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
		if dbo.fnIsEmptyGuid(@LEAD_ID) = 0 begin -- then
			exec dbo.spLEADS_OPPORTUNITIES_Update @MODIFIED_USER_ID, @LEAD_ID, @ID;
		end -- if;
		
		if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
			if @PARENT_TYPE = N'Accounts' begin -- then
				exec dbo.spACCOUNTS_OPPORTUNITIES_Update @MODIFIED_USER_ID, @PARENT_ID, @ID;
			end else if @PARENT_TYPE = N'Emails' begin -- then
				exec dbo.spEMAILS_OPPORTUNITIES_Update   @MODIFIED_USER_ID, @PARENT_ID, @ID;
			end else if @PARENT_TYPE = N'Contacts' begin -- then
				exec dbo.spOPPORTUNITIES_CONTACTS_Update @MODIFIED_USER_ID, @ID, @PARENT_ID, null;
			end -- if;
		end -- if;

		-- 04/07/2010 Paul.  If the Exchange Folder value is NULL, then don't do anything. This is to prevent the Exchange from unsyncing after update. 
		if @EXCHANGE_FOLDER = 0 begin -- then
			exec dbo.spOPPORTUNITIES_USERS_Delete @MODIFIED_USER_ID, @ID, @MODIFIED_USER_ID;
		end else if @EXCHANGE_FOLDER = 1 begin -- then
			exec dbo.spOPPORTUNITIES_USERS_Update @MODIFIED_USER_ID, @ID, @MODIFIED_USER_ID;
		end -- if;
	end -- if;
	-- 05/12/2016 Paul.  Add Tags module. Must add after @ID is set. 
	if @@ERROR = 0 begin -- then
		exec dbo.spTAG_SETS_NormalizeSet @MODIFIED_USER_ID, @ID, N'Opportunities', @TAG_SET_NAME;
	end -- if;
  end
GO

Grant Execute on dbo.spOPPORTUNITIES_Update to public;
GO

