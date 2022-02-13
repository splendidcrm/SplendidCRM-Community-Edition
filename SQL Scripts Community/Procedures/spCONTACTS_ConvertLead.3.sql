if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCONTACTS_ConvertLead' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCONTACTS_ConvertLead;
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
-- 08/23/2009 Paul.  Add support for dynamic teams. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 10/16/2011 Paul.  Increase size of SALUTATION, FIRST_NAME and LAST_NAME to match SugarCRM. 
-- 08/07/2015 Paul.  Migrate the new Leads/Contacts relationship. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 02/02/2019 Paul.  Ease conversion to Oracle. 
Create Procedure dbo.spCONTACTS_ConvertLead
	( @ID                          uniqueidentifier output
	, @MODIFIED_USER_ID            uniqueidentifier
	, @LEAD_ID                     uniqueidentifier
	, @ASSIGNED_USER_ID            uniqueidentifier
	, @SALUTATION                  nvarchar(25)
	, @FIRST_NAME                  nvarchar(100)
	, @LAST_NAME                   nvarchar(100)
	, @ACCOUNT_ID                  uniqueidentifier
	, @LEAD_SOURCE                 nvarchar(100)
	, @TITLE                       nvarchar(25)
	, @DEPARTMENT                  nvarchar(100)
	, @DO_NOT_CALL                 bit
	, @PHONE_HOME                  nvarchar(25)
	, @PHONE_MOBILE                nvarchar(25)
	, @PHONE_WORK                  nvarchar(25)
	, @PHONE_OTHER                 nvarchar(25)
	, @PHONE_FAX                   nvarchar(25)
	, @EMAIL1                      nvarchar(100)
	, @EMAIL2                      nvarchar(100)
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
	, @OPPORTUNITY_ID              uniqueidentifier
	, @OPPORTUNITY_NAME            nvarchar(255)
	, @OPPORTUNITY_AMOUNT          nvarchar(50)
	, @CAMPAIGN_ID                 uniqueidentifier
	, @TEAM_ID                     uniqueidentifier = null
	, @TEAM_SET_LIST               varchar(8000) = null
	, @ASSIGNED_SET_LIST           varchar(8000) = null
	)
as
  begin
	set nocount on

	declare @TARGET_TRACKER_KEY uniqueidentifier;
	declare @LEAD_CONTACT_ID    uniqueidentifier;
	-- 05/24/2015 Paul.  Add picture. 
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spCONTACTS_Update @ID out
		, @MODIFIED_USER_ID
		, @ASSIGNED_USER_ID
		, @SALUTATION
		, @FIRST_NAME
		, @LAST_NAME
		, @ACCOUNT_ID
		, @LEAD_SOURCE
		, @TITLE
		, @DEPARTMENT
		, null                    -- @REPORTS_TO_ID
		, null                    -- @BIRTHDATE
		, @DO_NOT_CALL
		, @PHONE_HOME
		, @PHONE_MOBILE
		, @PHONE_WORK
		, @PHONE_OTHER
		, @PHONE_FAX
		, @EMAIL1
		, @EMAIL2
		, null                    -- @ASSISTANT
		, null                    -- @ASSISTANT_PHONE
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
		, null                    -- @PARENT_TYPE
		, null                    -- @PARENT_ID
		, null                    -- @SYNC_CONTACT
		, @TEAM_ID
		, @TEAM_SET_LIST
		, null                    -- @SMS_OPT_IN
		, null                    -- @TWITTER_SCREEN_NAME
		, null                    -- @PICTURE
		, null                    -- @LEAD_ID
		, null                    -- @EXCHANGE_FOLDER
		, null                    -- @TAG_SET_NAME
		, null                    -- @CONTACT_NUMBER
		, @ASSIGNED_SET_LIST;

	-- 09/10/2007 Paul.  If the lead came from a campaign, then log the conversion. 
	if @CAMPAIGN_ID is not null begin -- then
		set @TARGET_TRACKER_KEY = newid();
		-- 12/28/2007 Paul.  Correct the parameters. 
		exec dbo.spCAMPAIGN_LOG_InsertOnly @MODIFIED_USER_ID, @CAMPAIGN_ID, @TARGET_TRACKER_KEY, @LEAD_ID, N'Leads', N'contact', @ID, N'Contacts', null, null, null;
	end -- if;

	-- 04/24/2006 Paul.  Update the CONTACT_ID with this new Contact. 	
	-- There will always be a lead to update. 
	-- 07/27/2006 Paul.  The status of the lead needs to change to Converted. 
	update LEADS
	   set MODIFIED_USER_ID   = @MODIFIED_USER_ID 
	     , DATE_MODIFIED      =  getdate()        
	     , DATE_MODIFIED_UTC  =  getutcdate()     
	     , CONTACT_ID         = @ID
	     , ACCOUNT_ID         = @ACCOUNT_ID
	     , OPPORTUNITY_ID     = @OPPORTUNITY_ID
	     , OPPORTUNITY_NAME   = @OPPORTUNITY_NAME
	     , OPPORTUNITY_AMOUNT = @OPPORTUNITY_AMOUNT
	     , STATUS             = N'Converted'
	     , CONVERTED          = 1
	 where ID                 = @LEAD_ID;
	-- 11/30/2017 Paul.  We should be creating the matching custom field audit record. 
	update LEADS_CSTM
	   set ID_C               = ID_C
	 where ID_C               = @LEAD_ID;

	-- 08/07/2015 Paul.  Migrate the new Leads/Contacts relationship. 
	if @ACCOUNT_ID is not null begin -- then
		insert into ACCOUNTS_CONTACTS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, CONTACT_ID       
			, ACCOUNT_ID       
			)
		select  newid()
		     , @MODIFIED_USER_ID 
		     ,  getdate()        
		     , @MODIFIED_USER_ID 
		     ,  getdate()        
		     ,  CONTACT_ID       
		     , @ACCOUNT_ID       
		  from LEADS_CONTACTS
		 where LEAD_ID = @LEAD_ID
		   and DELETED = 0;

		-- 08/08/2015 Paul.  When copying the relationships to the new account, make sure not to create a duplicate record.
		insert into ACCOUNTS_OPPORTUNITIES
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, OPPORTUNITY_ID       
			, ACCOUNT_ID       
			)
		select  newid()
		     , @MODIFIED_USER_ID 
		     ,  getdate()        
		     , @MODIFIED_USER_ID 
		     ,  getdate()        
		     ,  LEADS_OPPORTUNITIES.OPPORTUNITY_ID       
		     , @ACCOUNT_ID       
		  from            LEADS_OPPORTUNITIES
		  left outer join ACCOUNTS_OPPORTUNITIES
                               on ACCOUNTS_OPPORTUNITIES.OPPORTUNITY_ID = LEADS_OPPORTUNITIES.OPPORTUNITY_ID       
                              and ACCOUNTS_OPPORTUNITIES.ACCOUNT_ID     = @ACCOUNT_ID
		              and ACCOUNTS_OPPORTUNITIES.DELETED        = 0
		 where LEADS_OPPORTUNITIES.LEAD_ID = @LEAD_ID
		   and LEADS_OPPORTUNITIES.DELETED = 0
		   and LEADS_OPPORTUNITIES.ID is null;
	end -- if;
  end
GO

Grant Execute on dbo.spCONTACTS_ConvertLead to public;
GO

