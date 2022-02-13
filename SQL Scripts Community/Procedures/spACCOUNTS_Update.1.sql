if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACCOUNTS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACCOUNTS_Update;
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
-- 07/26/2009 Paul.  Enough customers requested ACCOUNT_NUMBER that it makes sense to add it now. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 08/23/2009 Paul.  Decrease set list so that index plus ID will be less than 900 bytes. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 04/07/2010 Paul.  Add EXCHANGE_FOLDER. 
-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
-- 07/05/2012 Paul.  Create normalized and indexed phone fields for fast call center lookups. 
-- 05/24/2015 Paul.  Add picture. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 06/07/2017 Paul.  Add NAICSCodes module. 
-- 10/27/2017 Paul.  Add Accounts as email source. 
-- 11/24/2017 Paul.  Provide a way to format phone numbers.  
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spACCOUNTS_Update
	( @ID                           uniqueidentifier output
	, @MODIFIED_USER_ID             uniqueidentifier
	, @ASSIGNED_USER_ID             uniqueidentifier
	, @NAME                         nvarchar(150)
	, @ACCOUNT_TYPE                 nvarchar(25)
	, @PARENT_ID                    uniqueidentifier
	, @INDUSTRY                     nvarchar(25)
	, @ANNUAL_REVENUE               nvarchar(25)
	, @PHONE_FAX                    nvarchar(25)
	, @BILLING_ADDRESS_STREET       nvarchar(150)
	, @BILLING_ADDRESS_CITY         nvarchar(100)
	, @BILLING_ADDRESS_STATE        nvarchar(100)
	, @BILLING_ADDRESS_POSTALCODE   nvarchar(20)
	, @BILLING_ADDRESS_COUNTRY      nvarchar(100)
	, @DESCRIPTION                  nvarchar(max)
	, @RATING                       nvarchar(25)
	, @PHONE_OFFICE                 nvarchar(25)
	, @PHONE_ALTERNATE              nvarchar(25)
	, @EMAIL1                       nvarchar(100)
	, @EMAIL2                       nvarchar(100)
	, @WEBSITE                      nvarchar(255)
	, @OWNERSHIP                    nvarchar(100)
	, @EMPLOYEES                    nvarchar(10)
	, @SIC_CODE                     nvarchar(10)
	, @TICKER_SYMBOL                nvarchar(10)
	, @SHIPPING_ADDRESS_STREET      nvarchar(150)
	, @SHIPPING_ADDRESS_CITY        nvarchar(100)
	, @SHIPPING_ADDRESS_STATE       nvarchar(100)
	, @SHIPPING_ADDRESS_POSTALCODE  nvarchar(20)
	, @SHIPPING_ADDRESS_COUNTRY     nvarchar(100)
	, @ACCOUNT_NUMBER               nvarchar(30) = null
	, @TEAM_ID                      uniqueidentifier = null
	, @TEAM_SET_LIST                varchar(8000) = null
	, @EXCHANGE_FOLDER              bit = null
	, @PICTURE                      nvarchar(max) = null
	, @TAG_SET_NAME                 nvarchar(4000) = null
	, @NAICS_SET_NAME               nvarchar(4000) = null
	, @DO_NOT_CALL                  bit = null
	, @EMAIL_OPT_OUT                bit = null
	, @INVALID_EMAIL                bit = null
	, @ASSIGNED_SET_LIST            varchar(8000) = null
	)
as
  begin
	set nocount on
	
	declare @TEMP_ACCOUNT_NUMBER nvarchar(30);
	declare @TEAM_SET_ID         uniqueidentifier;
	declare @ASSIGNED_SET_ID     uniqueidentifier;
	-- 11/24/2017 Paul.  Provide a way to format phone numbers.  
	declare @TEMP_PHONE_OFFICE    nvarchar(25);
	declare @TEMP_PHONE_ALTERNATE nvarchar(25);
	declare @TEMP_PHONE_FAX       nvarchar(25);
	set @TEMP_PHONE_OFFICE    = dbo.fnFormatPhone(@PHONE_OFFICE   );
	set @TEMP_PHONE_ALTERNATE = dbo.fnFormatPhone(@PHONE_ALTERNATE);
	set @TEMP_PHONE_FAX       = dbo.fnFormatPhone(@PHONE_FAX      );
	set @TEMP_ACCOUNT_NUMBER  = @ACCOUNT_NUMBER ;

	-- 08/22/2009 Paul.  Normalize the team set by placing the primary ID first, then order list by ID and the name by team names. 
	-- 08/23/2009 Paul.  Use a team set so that team name changes can propagate. 
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;

	if not exists(select * from ACCOUNTS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		-- 07/25/2009 Paul.  Allow the ACCOUNT_NUMBER to be imported. 
		if @TEMP_ACCOUNT_NUMBER is null begin -- then
			exec dbo.spNUMBER_SEQUENCES_Formatted 'ACCOUNTS.ACCOUNT_NUMBER', 1, @TEMP_ACCOUNT_NUMBER out;
		end -- if;
		insert into ACCOUNTS
			( ID                          
			, CREATED_BY                  
			, DATE_ENTERED                
			, MODIFIED_USER_ID            
			, DATE_MODIFIED               
			, DATE_MODIFIED_UTC           
			, ASSIGNED_USER_ID            
			, ACCOUNT_NUMBER              
			, NAME                        
			, ACCOUNT_TYPE                
			, PARENT_ID                   
			, INDUSTRY                    
			, ANNUAL_REVENUE              
			, PHONE_FAX                   
			, BILLING_ADDRESS_STREET      
			, BILLING_ADDRESS_CITY        
			, BILLING_ADDRESS_STATE       
			, BILLING_ADDRESS_POSTALCODE  
			, BILLING_ADDRESS_COUNTRY     
			, DESCRIPTION                 
			, RATING                      
			, PHONE_OFFICE                
			, PHONE_ALTERNATE             
			, EMAIL1                      
			, EMAIL2                      
			, WEBSITE                     
			, OWNERSHIP                   
			, EMPLOYEES                   
			, SIC_CODE                    
			, TICKER_SYMBOL               
			, SHIPPING_ADDRESS_STREET     
			, SHIPPING_ADDRESS_CITY       
			, SHIPPING_ADDRESS_STATE      
			, SHIPPING_ADDRESS_POSTALCODE 
			, SHIPPING_ADDRESS_COUNTRY    
			, TEAM_ID                     
			, TEAM_SET_ID                 
			, PICTURE                     
			, DO_NOT_CALL                 
			, EMAIL_OPT_OUT               
			, INVALID_EMAIL               
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
			, @TEMP_ACCOUNT_NUMBER         
			, @NAME                        
			, @ACCOUNT_TYPE                
			, @PARENT_ID                   
			, @INDUSTRY                    
			, @ANNUAL_REVENUE              
			, @TEMP_PHONE_FAX              
			, @BILLING_ADDRESS_STREET      
			, @BILLING_ADDRESS_CITY        
			, @BILLING_ADDRESS_STATE       
			, @BILLING_ADDRESS_POSTALCODE  
			, @BILLING_ADDRESS_COUNTRY     
			, @DESCRIPTION                 
			, @RATING                      
			, @TEMP_PHONE_OFFICE           
			, @TEMP_PHONE_ALTERNATE        
			, @EMAIL1                      
			, @EMAIL2                      
			, @WEBSITE                     
			, @OWNERSHIP                   
			, @EMPLOYEES                   
			, @SIC_CODE                    
			, @TICKER_SYMBOL               
			, @SHIPPING_ADDRESS_STREET     
			, @SHIPPING_ADDRESS_CITY       
			, @SHIPPING_ADDRESS_STATE      
			, @SHIPPING_ADDRESS_POSTALCODE 
			, @SHIPPING_ADDRESS_COUNTRY    
			, @TEAM_ID                     
			, @TEAM_SET_ID                 
			, @PICTURE                     
			, @DO_NOT_CALL                 
			, @EMAIL_OPT_OUT               
			, @INVALID_EMAIL               
			, @ASSIGNED_SET_ID             
			);
	end else begin
		update ACCOUNTS
		   set MODIFIED_USER_ID             = @MODIFIED_USER_ID            
		     , DATE_MODIFIED                =  getdate()                   
		     , DATE_MODIFIED_UTC            =  getutcdate()                
		     , ASSIGNED_USER_ID             = @ASSIGNED_USER_ID            
		     , ACCOUNT_NUMBER               = isnull(@TEMP_ACCOUNT_NUMBER, ACCOUNT_NUMBER)
		     , NAME                         = @NAME                        
		     , ACCOUNT_TYPE                 = @ACCOUNT_TYPE                
		     , PARENT_ID                    = @PARENT_ID                   
		     , INDUSTRY                     = @INDUSTRY                    
		     , ANNUAL_REVENUE               = @ANNUAL_REVENUE              
		     , PHONE_FAX                    = @TEMP_PHONE_FAX              
		     , BILLING_ADDRESS_STREET       = @BILLING_ADDRESS_STREET      
		     , BILLING_ADDRESS_CITY         = @BILLING_ADDRESS_CITY        
		     , BILLING_ADDRESS_STATE        = @BILLING_ADDRESS_STATE       
		     , BILLING_ADDRESS_POSTALCODE   = @BILLING_ADDRESS_POSTALCODE  
		     , BILLING_ADDRESS_COUNTRY      = @BILLING_ADDRESS_COUNTRY     
		     , DESCRIPTION                  = @DESCRIPTION                 
		     , RATING                       = @RATING                      
		     , PHONE_OFFICE                 = @TEMP_PHONE_OFFICE           
		     , PHONE_ALTERNATE              = @TEMP_PHONE_ALTERNATE        
		     , EMAIL1                       = @EMAIL1                      
		     , EMAIL2                       = @EMAIL2                      
		     , WEBSITE                      = @WEBSITE                     
		     , OWNERSHIP                    = @OWNERSHIP                   
		     , EMPLOYEES                    = @EMPLOYEES                   
		     , SIC_CODE                     = @SIC_CODE                    
		     , TICKER_SYMBOL                = @TICKER_SYMBOL               
		     , SHIPPING_ADDRESS_STREET      = @SHIPPING_ADDRESS_STREET     
		     , SHIPPING_ADDRESS_CITY        = @SHIPPING_ADDRESS_CITY       
		     , SHIPPING_ADDRESS_STATE       = @SHIPPING_ADDRESS_STATE      
		     , SHIPPING_ADDRESS_POSTALCODE  = @SHIPPING_ADDRESS_POSTALCODE 
		     , SHIPPING_ADDRESS_COUNTRY     = @SHIPPING_ADDRESS_COUNTRY    
		     , TEAM_ID                      = @TEAM_ID                     
		     , TEAM_SET_ID                  = @TEAM_SET_ID                 
		     , PICTURE                      = @PICTURE                     
		     , DO_NOT_CALL                  = @DO_NOT_CALL                 
		     , EMAIL_OPT_OUT                = @EMAIL_OPT_OUT               
		     , INVALID_EMAIL                = @INVALID_EMAIL               
		     , ASSIGNED_SET_ID              = @ASSIGNED_SET_ID             
		 where ID                           = @ID                          ;
		
		-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
		exec dbo.spSUGARFAVORITES_UpdateName @MODIFIED_USER_ID, @ID, @NAME;
	end -- if;

	-- 08/22/2009 Paul.  If insert fails, then the rest will as well. Just display the one error. 
	if @@ERROR = 0 begin -- then
		if not exists(select * from ACCOUNTS_CSTM where ID_C = @ID) begin -- then
			insert into ACCOUNTS_CSTM ( ID_C ) values ( @ID );
		end -- if;

		-- 08/21/2009 Paul.  Add or remove the team relationship records. 
		-- 08/30/2009 Paul.  Instead of using @TEAM_SET_LIST, use the @TEAM_SET_ID to build the module-specific team relationships. 
		-- 08/31/2009 Paul.  Instead of managing a separate teams relationship, we will leverage TEAM_SETS_TEAMS. 
		-- exec dbo.spACCOUNTS_TEAMS_Update @ID, @MODIFIED_USER_ID, @TEAM_SET_ID;

		-- 04/07/2010 Paul.  If the Exchange Folder value is NULL, then don't do anything. This is to prevent the Exchange from unsyncing after update. 
		if @EXCHANGE_FOLDER = 0 begin -- then
			exec dbo.spACCOUNTS_USERS_Delete @MODIFIED_USER_ID, @ID, @MODIFIED_USER_ID;
		end else if @EXCHANGE_FOLDER = 1 begin -- then
			exec dbo.spACCOUNTS_USERS_Update @MODIFIED_USER_ID, @ID, @MODIFIED_USER_ID;
		end -- if;
	end -- if;

	-- 07/05/2012 Paul.  Create normalized and indexed phone fields for fast call center lookups. 
	if @@ERROR = 0 begin -- then
		exec dbo.spPHONE_NUMBERS_Update @MODIFIED_USER_ID, @ID, N'Accounts', N'Office'   , @PHONE_OFFICE;
		exec dbo.spPHONE_NUMBERS_Update @MODIFIED_USER_ID, @ID, N'Accounts', N'Fax'      , @PHONE_FAX;
		exec dbo.spPHONE_NUMBERS_Update @MODIFIED_USER_ID, @ID, N'Accounts', N'Alternate', @PHONE_ALTERNATE;
	end -- if;
	-- 05/12/2016 Paul.  Add Tags module. Must add after @ID is set. 
	if @@ERROR = 0 begin -- then
		exec dbo.spTAG_SETS_NormalizeSet @MODIFIED_USER_ID, @ID, N'Accounts', @TAG_SET_NAME;
	end -- if;
	-- 06/07/2017 Paul.  Add NAICSCodes module. Must add after @ID is set. 
	if @@ERROR = 0 begin -- then
		exec dbo.spNAICS_CODE_SETS_NormalizeSet @MODIFIED_USER_ID, @ID, N'Accounts', @NAICS_SET_NAME;
	end -- if;
  end
GO

Grant Execute on dbo.spACCOUNTS_Update to public;
GO

