if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spLEADS_ConvertProspect' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spLEADS_ConvertProspect;
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
-- 02/14/2010 Paul.  Allow links to Account and Contact. 
-- 09/12/2010 Paul.  Add default parameter EXCHANGE_FOLDER to ease migration to EffiProz. 
-- 10/16/2011 Paul.  Increase size of SALUTATION, FIRST_NAME and LAST_NAME to match SugarCRM. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spLEADS_ConvertProspect
	( @ID                          uniqueidentifier output
	, @MODIFIED_USER_ID            uniqueidentifier
	, @PROSPECT_ID                 uniqueidentifier
	, @ASSIGNED_USER_ID            uniqueidentifier
	, @SALUTATION                  nvarchar(25)
	, @FIRST_NAME                  nvarchar(100)
	, @LAST_NAME                   nvarchar(100)
	, @TITLE                       nvarchar(100)
	, @REFERED_BY                  nvarchar(100)
	, @LEAD_SOURCE                 nvarchar(100)
	, @LEAD_SOURCE_DESCRIPTION     nvarchar(max)
	, @STATUS                      nvarchar(100)
	, @STATUS_DESCRIPTION          nvarchar(max)
	, @DEPARTMENT                  nvarchar(100)
	, @REPORTS_TO_ID               uniqueidentifier
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
	, @ACCOUNT_NAME                nvarchar(150)
	, @CAMPAIGN_ID                 uniqueidentifier
	, @TEAM_ID                     uniqueidentifier = null
	, @TEAM_SET_LIST               varchar(8000) = null
	, @CONTACT_ID                  uniqueidentifier = null
	, @ACCOUNT_ID                  uniqueidentifier = null
	, @EXCHANGE_FOLDER             bit = null
	, @TAG_SET_NAME                nvarchar(4000) = null
	, @ASSIGNED_SET_LIST           varchar(8000) = null
	)
as
  begin
	set nocount on
	
	-- 05/24/2015 Paul.  Add picture. 
	-- 05/12/2016 Paul.  Add Tags module. 
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spLEADS_Update @ID out
		, @MODIFIED_USER_ID
		, @ASSIGNED_USER_ID
		, @SALUTATION
		, @FIRST_NAME
		, @LAST_NAME
		, @TITLE
		, @REFERED_BY
		, @LEAD_SOURCE
		, @LEAD_SOURCE_DESCRIPTION
		, @STATUS
		, @STATUS_DESCRIPTION
		, @DEPARTMENT
		, @REPORTS_TO_ID
		, @DO_NOT_CALL
		, @PHONE_HOME
		, @PHONE_MOBILE
		, @PHONE_WORK
		, @PHONE_OTHER
		, @PHONE_FAX
		, @EMAIL1
		, @EMAIL2
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
		, @ACCOUNT_NAME
		, @CAMPAIGN_ID
		, @TEAM_ID
		, @TEAM_SET_LIST
		, @CONTACT_ID
		, @ACCOUNT_ID
		, @EXCHANGE_FOLDER
		, null                    -- @BIRTHDATE
		, null                    -- @ASSISTANT
		, null                    -- @ASSISTANT_PHONE
		, null                    -- @WEBSITE
		, null                    -- @SMS_OPT_IN
		, null                    -- @TWITTER_SCREEN_NAME
		, null                    -- @PICTURE
		, @TAG_SET_NAME
		, null                    -- @LEAD_NUMBER
		, @ASSIGNED_SET_LIST;

	-- 04/24/2006 Paul.  Update the LEAD_ID with this new Lead. 	
	update PROSPECTS
	   set MODIFIED_USER_ID = @MODIFIED_USER_ID 
	     , DATE_MODIFIED    =  getdate()        
	     , DATE_MODIFIED_UTC=  getutcdate()     
	     , LEAD_ID          = @ID
	 where ID               = @PROSPECT_ID;

	-- 12/29/2019 Paul.  We should be creating the matching custom field audit record. 
	update PROSPECTS_CSTM
	   set ID_C               = ID_C
	 where ID_C               = @PROSPECT_ID;
  end
GO

Grant Execute on dbo.spLEADS_ConvertProspect to public;
GO

