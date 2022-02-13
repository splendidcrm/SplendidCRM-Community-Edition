if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPROSPECTS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPROSPECTS_Update;
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
-- 04/21/2006 Paul.  LEAD_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  ACCOUNT_NAME was added in SugarCRM 4.0.
-- 06/18/2007 Paul.  The LEAD_ID should not be changed here. It is typically only used when converting to a Lead. 
-- Updating here will break that connection. 
-- 12/29/2007 Paul.  Add TEAM_ID so that it is not updated separately. 
-- 07/25/2009 Paul.  TRACKER_KEY is no longer an identity and must be formatted. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 08/23/2009 Paul.  Decrease set list so that index plus ID will be less than 900 bytes. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 10/16/2011 Paul.  Increase size of SALUTATION, FIRST_NAME and LAST_NAME to match SugarCRM. 
-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
-- 07/05/2012 Paul.  Create normalized and indexed phone fields for fast call center lookups. 
-- 09/27/2013 Paul.  SMS messages need to be opt-in. 
-- 10/22/2013 Paul.  Provide a way to map Tweets to a parent. 
-- 05/24/2015 Paul.  Add picture. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/24/2017 Paul.  Provide a way to format phone numbers.  
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 06/23/2018 Paul.  Add LEAD_SOURCE, DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 
Create Procedure dbo.spPROSPECTS_Update
	( @ID                          uniqueidentifier output
	, @MODIFIED_USER_ID            uniqueidentifier
	, @ASSIGNED_USER_ID            uniqueidentifier
	, @SALUTATION                  nvarchar(25)
	, @FIRST_NAME                  nvarchar(100)
	, @LAST_NAME                   nvarchar(100)
	, @TITLE                       nvarchar(25)
	, @DEPARTMENT                  nvarchar(255)
	, @BIRTHDATE                   datetime
	, @DO_NOT_CALL                 bit
	, @PHONE_HOME                  nvarchar(25)
	, @PHONE_MOBILE                nvarchar(25)
	, @PHONE_WORK                  nvarchar(25)
	, @PHONE_OTHER                 nvarchar(25)
	, @PHONE_FAX                   nvarchar(25)
	, @EMAIL1                      nvarchar(100)
	, @EMAIL2                      nvarchar(100)
	, @ASSISTANT                   nvarchar(75)
	, @ASSISTANT_PHONE             nvarchar(25)
	, @EMAIL_OPT_OUT               bit
	, @INVALID_EMAIL               bit
	, @PRIMARY_ADDRESS_STREET      nvarchar(150)
	, @PRIMARY_ADDRESS_CITY        nvarchar(100)
	, @PRIMARY_ADDRESS_STATE       nvarchar(100)
	, @PRIMARY_ADDRESS_POSTALCODE  nvarchar(20)
	, @PRIMARY_ADDRESS_COUNTRY     nvarchar(100)
	, @ALT_ADDRESS_STREET          nvarchar(150)
	, @ALT_ADDRESS_CITY            nvarchar(100)
	, @ALT_ADDRESS_STATE           nvarchar(100)
	, @ALT_ADDRESS_POSTALCODE      nvarchar(20)
	, @ALT_ADDRESS_COUNTRY         nvarchar(100)
	, @DESCRIPTION                 nvarchar(max)
	, @PARENT_TYPE                 nvarchar(25)
	, @PARENT_ID                   uniqueidentifier
	, @LEAD_ID                     uniqueidentifier
	, @ACCOUNT_NAME                nvarchar(150)
	, @TRACKER_KEY                 nvarchar(30) = null
	, @TEAM_ID                     uniqueidentifier = null
	, @TEAM_SET_LIST               varchar(8000) = null
	, @SMS_OPT_IN                  nvarchar(25) = null
	, @TWITTER_SCREEN_NAME         nvarchar(20) = null
	, @PICTURE                     nvarchar(max) = null
	, @TAG_SET_NAME                nvarchar(4000) = null
	, @PROSPECT_NUMBER             nvarchar(30) = null
	, @ASSIGNED_SET_LIST           varchar(8000) = null
	, @LEAD_SOURCE                 nvarchar(100) = null
	, @DP_BUSINESS_PURPOSE         nvarchar(max) = null
	, @DP_CONSENT_LAST_UPDATED     datetime = null
	)
as
  begin
	set nocount on
	
	declare @TEMP_TRACKER_KEY     nvarchar(30);
	declare @TEAM_SET_ID          uniqueidentifier;
	declare @ASSIGNED_SET_ID     uniqueidentifier;
	declare @NAME                 nvarchar(255);
	declare @TEMP_PROSPECT_NUMBER nvarchar(30);
	-- 11/24/2017 Paul.  Provide a way to format phone numbers.  
	declare @TEMP_PHONE_HOME      nvarchar(25);
	declare @TEMP_PHONE_MOBILE    nvarchar(25);
	declare @TEMP_PHONE_WORK      nvarchar(25);
	declare @TEMP_PHONE_OTHER     nvarchar(25);
	declare @TEMP_PHONE_FAX       nvarchar(25);
	declare @TEMP_ASSISTANT_PHONE nvarchar(25);
	set @TEMP_PHONE_HOME      = dbo.fnFormatPhone(@PHONE_HOME     );
	set @TEMP_PHONE_MOBILE    = dbo.fnFormatPhone(@PHONE_MOBILE   );
	set @TEMP_PHONE_WORK      = dbo.fnFormatPhone(@PHONE_WORK     );
	set @TEMP_PHONE_OTHER     = dbo.fnFormatPhone(@PHONE_OTHER    );
	set @TEMP_PHONE_FAX       = dbo.fnFormatPhone(@PHONE_FAX      );
	set @TEMP_ASSISTANT_PHONE = dbo.fnFormatPhone(@ASSISTANT_PHONE);
	set @TEMP_TRACKER_KEY     = @TRACKER_KEY    ;
	set @TEMP_PROSPECT_NUMBER = @PROSPECT_NUMBER;

	-- 08/22/2009 Paul.  Normalize the team set by placing the primary ID first, then order list by ID and the name by team names. 
	-- 08/23/2009 Paul.  Use a team set so that team name changes can propagate. 
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;

	if not exists(select * from PROSPECTS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		-- 07/25/2009 Paul.  Allow the TRACKER_KEY to be imported. 
		if @TEMP_TRACKER_KEY is null begin -- then
			exec dbo.spNUMBER_SEQUENCES_Formatted 'PROSPECTS.TRACKER_KEY', 1, @TEMP_TRACKER_KEY out;
		end -- if;
		-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
		if @TEMP_PROSPECT_NUMBER is null begin -- then
			exec dbo.spNUMBER_SEQUENCES_Formatted 'PROSPECTS.PROSPECT_NUMBER', 1, @TEMP_PROSPECT_NUMBER out;
		end -- if;
		insert into PROSPECTS
			( ID                         
			, CREATED_BY                 
			, DATE_ENTERED               
			, MODIFIED_USER_ID           
			, DATE_MODIFIED              
			, DATE_MODIFIED_UTC          
			, ASSIGNED_USER_ID           
			, TRACKER_KEY                
			, PROSPECT_NUMBER            
			, SALUTATION                 
			, FIRST_NAME                 
			, LAST_NAME                  
			, TITLE                      
			, DEPARTMENT                 
			, BIRTHDATE                  
			, DO_NOT_CALL                
			, PHONE_HOME                 
			, PHONE_MOBILE               
			, PHONE_WORK                 
			, PHONE_OTHER                
			, PHONE_FAX                  
			, EMAIL1                     
			, EMAIL2                     
			, ASSISTANT                  
			, ASSISTANT_PHONE            
			, EMAIL_OPT_OUT              
			, INVALID_EMAIL              
			, PRIMARY_ADDRESS_STREET     
			, PRIMARY_ADDRESS_CITY       
			, PRIMARY_ADDRESS_STATE      
			, PRIMARY_ADDRESS_POSTALCODE 
			, PRIMARY_ADDRESS_COUNTRY    
			, ALT_ADDRESS_STREET         
			, ALT_ADDRESS_CITY           
			, ALT_ADDRESS_STATE          
			, ALT_ADDRESS_POSTALCODE     
			, ALT_ADDRESS_COUNTRY        
			, DESCRIPTION                
			, LEAD_ID                    
			, ACCOUNT_NAME               
			, TEAM_ID                    
			, TEAM_SET_ID                
			, SMS_OPT_IN                 
			, TWITTER_SCREEN_NAME        
			, PICTURE                    
			, ASSIGNED_SET_ID            
			, LEAD_SOURCE                
			, DP_BUSINESS_PURPOSE        
			, DP_CONSENT_LAST_UPDATED    
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
			, @TEMP_PROSPECT_NUMBER       
			, @SALUTATION                 
			, @FIRST_NAME                 
			, @LAST_NAME                  
			, @TITLE                      
			, @DEPARTMENT                 
			, @BIRTHDATE                  
			, @DO_NOT_CALL                
			, @TEMP_PHONE_HOME            
			, @TEMP_PHONE_MOBILE          
			, @TEMP_PHONE_WORK            
			, @TEMP_PHONE_OTHER           
			, @TEMP_PHONE_FAX             
			, @EMAIL1                     
			, @EMAIL2                     
			, @ASSISTANT                  
			, @TEMP_ASSISTANT_PHONE       
			, @EMAIL_OPT_OUT              
			, @INVALID_EMAIL              
			, @PRIMARY_ADDRESS_STREET     
			, @PRIMARY_ADDRESS_CITY       
			, @PRIMARY_ADDRESS_STATE      
			, @PRIMARY_ADDRESS_POSTALCODE 
			, @PRIMARY_ADDRESS_COUNTRY    
			, @ALT_ADDRESS_STREET         
			, @ALT_ADDRESS_CITY           
			, @ALT_ADDRESS_STATE          
			, @ALT_ADDRESS_POSTALCODE     
			, @ALT_ADDRESS_COUNTRY        
			, @DESCRIPTION                
			, @LEAD_ID                    
			, @ACCOUNT_NAME               
			, @TEAM_ID                    
			, @TEAM_SET_ID                
			, @SMS_OPT_IN                 
			, @TWITTER_SCREEN_NAME        
			, @PICTURE                    
			, @ASSIGNED_SET_ID            
			, @LEAD_SOURCE                
			, @DP_BUSINESS_PURPOSE        
			, @DP_CONSENT_LAST_UPDATED    
			);
	end else begin
		update PROSPECTS
		   set MODIFIED_USER_ID            = @MODIFIED_USER_ID           
		     , DATE_MODIFIED               =  getdate()                  
		     , DATE_MODIFIED_UTC           =  getutcdate()               
		     , ASSIGNED_USER_ID            = @ASSIGNED_USER_ID           
		     , TRACKER_KEY                 = isnull(@TEMP_TRACKER_KEY, TRACKER_KEY)
		     , PROSPECT_NUMBER             = isnull(@TEMP_PROSPECT_NUMBER, PROSPECT_NUMBER)
		     , SALUTATION                  = @SALUTATION                 
		     , FIRST_NAME                  = @FIRST_NAME                 
		     , LAST_NAME                   = @LAST_NAME                  
		     , TITLE                       = @TITLE                      
		     , DEPARTMENT                  = @DEPARTMENT                 
		     , BIRTHDATE                   = @BIRTHDATE                  
		     , DO_NOT_CALL                 = @DO_NOT_CALL                
		     , PHONE_HOME                  = @TEMP_PHONE_HOME            
		     , PHONE_MOBILE                = @TEMP_PHONE_MOBILE          
		     , PHONE_WORK                  = @TEMP_PHONE_WORK            
		     , PHONE_OTHER                 = @TEMP_PHONE_OTHER           
		     , PHONE_FAX                   = @TEMP_PHONE_FAX             
		     , EMAIL1                      = @EMAIL1                     
		     , EMAIL2                      = @EMAIL2                     
		     , ASSISTANT                   = @ASSISTANT                  
		     , ASSISTANT_PHONE             = @TEMP_ASSISTANT_PHONE       
		     , EMAIL_OPT_OUT               = @EMAIL_OPT_OUT              
		     , INVALID_EMAIL               = @INVALID_EMAIL              
		     , PRIMARY_ADDRESS_STREET      = @PRIMARY_ADDRESS_STREET     
		     , PRIMARY_ADDRESS_CITY        = @PRIMARY_ADDRESS_CITY       
		     , PRIMARY_ADDRESS_STATE       = @PRIMARY_ADDRESS_STATE      
		     , PRIMARY_ADDRESS_POSTALCODE  = @PRIMARY_ADDRESS_POSTALCODE 
		     , PRIMARY_ADDRESS_COUNTRY     = @PRIMARY_ADDRESS_COUNTRY    
		     , ALT_ADDRESS_STREET          = @ALT_ADDRESS_STREET         
		     , ALT_ADDRESS_CITY            = @ALT_ADDRESS_CITY           
		     , ALT_ADDRESS_STATE           = @ALT_ADDRESS_STATE          
		     , ALT_ADDRESS_POSTALCODE      = @ALT_ADDRESS_POSTALCODE     
		     , ALT_ADDRESS_COUNTRY         = @ALT_ADDRESS_COUNTRY        
		     , DESCRIPTION                 = @DESCRIPTION                
-- 06/18/2007 Paul.  The LEAD_ID should not be changed here. 
--		     , LEAD_ID                     = @LEAD_ID                    
		     , ACCOUNT_NAME                = @ACCOUNT_NAME               
		     , TEAM_ID                     = @TEAM_ID                    
		     , TEAM_SET_ID                 = @TEAM_SET_ID                
		     , SMS_OPT_IN                  = @SMS_OPT_IN                 
		     , TWITTER_SCREEN_NAME         = @TWITTER_SCREEN_NAME        
		     , PICTURE                     = @PICTURE                    
		     , ASSIGNED_SET_ID             = @ASSIGNED_SET_ID            
		     , LEAD_SOURCE                 = @LEAD_SOURCE                
		     , DP_BUSINESS_PURPOSE         = @DP_BUSINESS_PURPOSE        
		     , DP_CONSENT_LAST_UPDATED     = @DP_CONSENT_LAST_UPDATED    
		 where ID                          = @ID                         ;
		
		-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
		select @NAME = NAME
		  from vwPROSPECTS
		 where ID = @ID;
		exec dbo.spSUGARFAVORITES_UpdateName @MODIFIED_USER_ID, @ID, @NAME;
	end -- if;

	-- 08/22/2009 Paul.  If insert fails, then the rest will as well. Just display the one error. 
	if @@ERROR = 0 begin -- then
		if not exists(select * from PROSPECTS_CSTM where ID_C = @ID) begin -- then
			insert into PROSPECTS_CSTM ( ID_C ) values ( @ID );
		end -- if;
		
		-- 08/21/2009 Paul.  Add or remove the team relationship records. 
		-- 08/30/2009 Paul.  Instead of using @TEAM_SET_LIST, use the @TEAM_SET_ID to build the module-specific team relationships. 
		-- 08/31/2009 Paul.  Instead of managing a separate teams relationship, we will leverage TEAM_SETS_TEAMS. 
		-- exec dbo.spPROSPECTS_TEAMS_Update @ID, @MODIFIED_USER_ID, @TEAM_SET_ID;
		
		if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
			if @PARENT_TYPE = N'ProspectLists' begin -- then
				exec dbo.spPROSPECT_LISTS_PROSPECTS_Update @MODIFIED_USER_ID, @PARENT_ID, @ID;
			end -- if;
		end -- if;
	end -- if;

	-- 07/05/2012 Paul.  Create normalized and indexed phone fields for fast call center lookups. 
	if @@ERROR = 0 begin -- then
		exec dbo.spPHONE_NUMBERS_Update @MODIFIED_USER_ID, @ID, N'Prospects', N'Home'     , @PHONE_HOME;
		exec dbo.spPHONE_NUMBERS_Update @MODIFIED_USER_ID, @ID, N'Prospects', N'Mobile'   , @PHONE_MOBILE;
		exec dbo.spPHONE_NUMBERS_Update @MODIFIED_USER_ID, @ID, N'Prospects', N'Work'     , @PHONE_WORK;
		exec dbo.spPHONE_NUMBERS_Update @MODIFIED_USER_ID, @ID, N'Prospects', N'Other'    , @PHONE_OTHER;
		exec dbo.spPHONE_NUMBERS_Update @MODIFIED_USER_ID, @ID, N'Prospects', N'Fax'      , @PHONE_FAX;
		exec dbo.spPHONE_NUMBERS_Update @MODIFIED_USER_ID, @ID, N'Prospects', N'Assistant', @ASSISTANT_PHONE;
	end -- if;
	-- 05/12/2016 Paul.  Add Tags module. Must add after @ID is set. 
	if @@ERROR = 0 begin -- then
		exec dbo.spTAG_SETS_NormalizeSet @MODIFIED_USER_ID, @ID, N'Prospects', @TAG_SET_NAME;
	end -- if;
  end
GO

Grant Execute on dbo.spPROSPECTS_Update to public;
GO

