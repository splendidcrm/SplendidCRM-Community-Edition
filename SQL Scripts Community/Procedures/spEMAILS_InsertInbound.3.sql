if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_InsertInbound' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILS_InsertInbound;
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
-- 01/13/2008 Paul.  Process the email based on the MAILBOX_TYPE/INTENT. 
-- 01/13/2008 Paul.  Generate AutoReplies by adding a record to the EMAILMAN table. 
-- 04/18/2008 Paul.  Create Bugs, Contacts, Leads, and Tasks. 
-- 06/03/2008 Paul.  When creating the new case, make sure to use the @CASE_MACRO. 
-- 08/27/2008 Paul.  PostgreSQL does not allow modifying input parameters.  Use a local temp variable. 
-- 04/21/2009 Paul.  The routing was not working.  The IsEmptyGuid test for Create Lead was not correct. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 02/14/2010 Paul.  spLEADS_Update has changed to allow links to Account and Contact. 
-- 09/12/2010 Paul.  Add default parameter EXCHANGE_FOLDER to ease migration to EffiProz. 
-- 11/01/2010 Paul.  Increase length of MESSAGE_ID to varchar(851) to allow for IMAP value + login + server. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 02/06/2013 Paul.  If the intent is empty, then set the @TEAM_ID to the @ASSIGNED_USER_ID. We need to specify @TEAM_SET_ID in EMAILS creation. 
-- 01/19/2017 Paul.  If not found as a campaign tracker, then try as an email. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 12/29/2019 Paul.  Incorrect assignment of @TEMP_TEAM_ID to the following fields. 
Create Procedure dbo.spEMAILS_InsertInbound
	( @ID                 uniqueidentifier output
	, @MODIFIED_USER_ID   uniqueidentifier
	, @ASSIGNED_USER_ID   uniqueidentifier
	, @NAME               nvarchar(255)
	, @DATE_TIME          datetime
	, @DESCRIPTION        nvarchar(max)
	, @DESCRIPTION_HTML   nvarchar(max)
	, @FROM_ADDR          nvarchar(100)
	, @FROM_NAME          nvarchar(100)
	, @TO_ADDRS           nvarchar(max)
	, @CC_ADDRS           nvarchar(max)
	, @BCC_ADDRS          nvarchar(max)
	, @TO_ADDRS_NAMES     nvarchar(max)
	, @TO_ADDRS_EMAILS    varchar(8000)
	, @CC_ADDRS_NAMES     nvarchar(max)
	, @CC_ADDRS_EMAILS    varchar(8000)
	, @BCC_ADDRS_NAMES    nvarchar(max)
	, @BCC_ADDRS_EMAILS   varchar(8000)
	, @TYPE               nvarchar(25)
	, @STATUS             nvarchar(25)
	, @MESSAGE_ID         varchar(851)
	, @REPLY_TO_NAME      nvarchar(100)
	, @REPLY_TO_ADDR      nvarchar(100)
	, @INTENT             nvarchar(25)
	, @MAILBOX_ID         uniqueidentifier
	, @TARGET_TRACKER_KEY uniqueidentifier
	, @RAW_SOURCE         nvarchar(max)
	, @TEAM_ID            uniqueidentifier = null
	)
as
  begin
	set nocount on

	declare @EMAIL_LIST      varchar(8000);
	declare @EMAIL           varchar(8000);
	declare @CASE_MACRO      nvarchar(255);
	declare @CurrentPosR     int;
	declare @NextPosR        int;
	declare @DATE_START      datetime;
	declare @TIME_START      datetime;
	-- 02/06/2013 Paul.  The correct field name is @TEAM_SET_LIST. 
	declare @TEMP_TEAM_ID    uniqueidentifier;
	declare @TEAM_SET_LIST   varchar(8000);
	declare @TEAM_SET_ID     uniqueidentifier;
	declare @PARENT_ID       uniqueidentifier;
	declare @PARENT_TYPE     nvarchar(25);
	declare @ACTIVITY_TYPE   nvarchar(25);
	declare @TARGET_ID       uniqueidentifier;
	declare @TARGET_TYPE     nvarchar(25);
	declare @AUTOREPLY_COUNT int;
	declare @AUTOREPLY_MAX   int;
	declare @FILTER_DOMAIN   nvarchar(100);
	declare @TEMPLATE_ID     uniqueidentifier;
	declare @AUTOREPLY_ID    uniqueidentifier;
	declare @AUTOREPLY_FROM_NAME nvarchar(100);
	declare @AUTOREPLY_FROM_ADDR nvarchar(100);

	declare @TEMP_NAME             nvarchar(255);
	declare @TEMP_REPLY_TO_NAME    nvarchar(100);
	declare @TEMP_REPLY_TO_ADDR    nvarchar(100);
	declare @TEMP_FROM_ADDR        nvarchar(100);
	declare @TEMP_ASSIGNED_USER_ID uniqueidentifier;

	-- 01/09/2017 Paul.  Lookup accounts and contacts for new case. 
	declare @ACCOUNT_ID            uniqueidentifier;
	declare @CONTACT_ID            uniqueidentifier;
	declare @RECIPIENT_ID          uniqueidentifier;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	declare @ASSIGNED_SET_LIST     varchar(8000);
	declare @ASSIGNED_SET_ID       uniqueidentifier;
-- #if SQL_Server /*
	declare @RECIPIENTS      table ( ID uniqueidentifier primary key );
-- #endif SQL_Server */


	declare added_contacts_cursor cursor for
	select ID
	  from @RECIPIENTS;

/* -- #if IBM_DB2
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
	set l_error ='00000';
-- #endif IBM_DB2 */
/* -- #if MySQL
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
	set in_FETCH_STATUS = 0;

	drop temporary table if exists in_RECIPIENTS;

	create temporary table in_RECIPIENTS      ( ID char(36) primary key );
-- #endif MySQL */

	set @DATE_START    = dbo.fnStoreDateOnly(@DATE_TIME);
	set @TIME_START    = dbo.fnStoreTimeOnly(@DATE_TIME);
	set @CASE_MACRO    = dbo.fnCONFIG_String(N'inbound_email_case_subject_macro');
	-- 01/13/2008 Paul.  Convert to lower case for Oracle. No significant penalty for SQL Server. 
	set @TEMP_REPLY_TO_NAME = @REPLY_TO_NAME;
	set @TEMP_REPLY_TO_ADDR = rtrim(lower(@REPLY_TO_ADDR));
	set @TEMP_FROM_ADDR     = rtrim(lower(@FROM_ADDR    ));
	-- 01/23/2008 Paul.  Nullify as extra protection against accidental match with empty fields. 
	-- 04/18/2008 Paul.  Previous code was improperly clearing address fields. 
	if len(@TEMP_REPLY_TO_ADDR) = 0 begin -- then
		set @TEMP_REPLY_TO_ADDR = null;
	end -- if;
	if len(@TEMP_FROM_ADDR) = 0 begin -- then
		set @TEMP_FROM_ADDR = null;
	end -- if;
	set @TEMP_NAME = @NAME;
	if @TEMP_NAME is null or len(@TEMP_NAME) = 0 begin -- then
		set @TEMP_NAME = N'Inbound email';
	end -- if;
	set @TEMP_ASSIGNED_USER_ID = @ASSIGNED_USER_ID;
	-- 03/11/2012 Paul.  Set the default for the team to be the Global team. 
	set @TEMP_TEAM_ID = @TEAM_ID;
	if @TEMP_TEAM_ID is null begin -- then
		-- 12/29/2019 Paul.  Use default team config. 
		set @TEMP_TEAM_ID = dbo.fnCONFIG_Guid('global_team_id');
		if @TEMP_TEAM_ID is null begin -- then
			set @TEMP_TEAM_ID = '17BB7135-2B95-42DC-85DE-842CAFF927A0';
		end -- if;
	end -- if;
	-- 02/06/2013 Paul.  We need to specify @TEAM_SET_ID in EMAILS creation. 
	set @TEAM_SET_LIST = cast(@TEMP_TEAM_ID as char(36));
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEMP_TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	set @ASSIGNED_SET_LIST = cast(@TEMP_ASSIGNED_USER_ID as char(36));
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;

	-- 01/13/2008 Paul.  SugarCRM does not do anything with 'bug', 'info',  'task'.
	--bounce   -- Bounce Handling
	--pick     -- Create [Any]
	--support  -- Create Case
	--bug      -- Create Bug
	--contact  -- Create Contact
	--sales    -- Create Lead
	--task     -- Create Task
	if @INTENT = N'support' or @INTENT = N'pick' begin -- then
		-- 09/02/2012 Paul.  We should always create a contact for support and pick. 
		-- 01/09/2017 Paul.  Move up so that contact is created before case. 
		select top 1
		       @CONTACT_ID = ID
		  from CONTACTS
		 where DELETED = 0
		   and (EMAIL1 = @TEMP_REPLY_TO_ADDR or EMAIL2 = @TEMP_REPLY_TO_ADDR or EMAIL1 = @TEMP_FROM_ADDR or EMAIL2 = @TEMP_FROM_ADDR);
		if dbo.fnIsEmptyGuid(@TARGET_ID) = 1 begin -- then
			set @TARGET_ID   = @CONTACT_ID
			set @TARGET_TYPE = N'Contacts';
			-- 05/24/2015 Paul.  Add picture. 
			-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			exec dbo.spCONTACTS_Update @TARGET_ID out
				, @MODIFIED_USER_ID
				, @TEMP_ASSIGNED_USER_ID
				, null                  -- @SALUTATION
				, null                  -- @FIRST_NAME
				, @FROM_NAME            -- @LAST_NAME
				, null                  -- @ACCOUNT_ID
				, N'Email'              -- @LEAD_SOURCE
				, null                  -- @TITLE
				, null                  -- @DEPARTMENT
				, null                  -- @REPORTS_TO_ID
				, null                  -- @BIRTHDATE
				, null                  -- @DO_NOT_CALL
				, null                  -- @PHONE_HOME
				, null                  -- @PHONE_MOBILE
				, null                  -- @PHONE_WORK
				, null                  -- @PHONE_OTHER
				, null                  -- @PHONE_FAX
				, @TEMP_FROM_ADDR       -- @EMAIL1
				, null                  -- @EMAIL2
				, null                  -- @ASSISTANT
				, null                  -- @ASSISTANT_PHONE
				, null                  -- @EMAIL_OPT_OUT
				, null                  -- @INVALID_EMAIL
				, null                  -- @PRIMARY_ADDRESS_STREET
				, null                  -- @PRIMARY_ADDRESS_CITY
				, null                  -- @PRIMARY_ADDRESS_STATE
				, null                  -- @PRIMARY_ADDRESS_POSTALCODE
				, null                  -- @PRIMARY_ADDRESS_COUNTRY
				, null                  -- @ALT_ADDRESS_STREET
				, null                  -- @ALT_ADDRESS_CITY
				, null                  -- @ALT_ADDRESS_STATE
				, null                  -- @ALT_ADDRESS_POSTALCODE
				, null                  -- @ALT_ADDRESS_COUNTRY
				, @DESCRIPTION
				, null                  -- @PARENT_TYPE
				, null                  -- @PARENT_ID
				, 0                     -- @SYNC_CONTACT
				, @TEMP_TEAM_ID         -- @TEAM_ID
				, @TEAM_SET_LIST
				, null                  -- @SMS_OPT_IN
				, null                  -- @TWITTER_SCREEN_NAME
				, null                  -- @PICTURE
				, null                  -- @LEAD_ID
				, null                  -- @EXCHANGE_FOLDER
				, null                  -- @TAG_SET_NAME
				, null                  -- @CONTACT_NUMBER
				, @ASSIGNED_SET_LIST
				;
		end else begin
			set @TARGET_ID = null;
		end -- if;
		-- 09/07/2008 Paul.  Oracle does not allow optional parameters to charindex. 
		select top 1
		       @PARENT_ID = ID
		  from vwCASES
		 where charindex(replace(@CASE_MACRO, N'%1', cast(ID as char(36))), @TEMP_NAME, 1) > 0;
		if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
			set @PARENT_TYPE = N'Cases';
			-- 01/13/2008 Paul.  The inbound email is assigned to the owner of the case. 
			-- We are not going to combine the lookup so that @ASSIGNED_USER_ID does not 
			-- get overwritten if the case is not found. 
			select @TEMP_ASSIGNED_USER_ID = ASSIGNED_USER_ID
			     , @TEMP_TEAM_ID = isnull(@TEMP_TEAM_ID, TEAM_ID)
			  from CASES
			 where ID = @PARENT_ID;
			set @TEAM_SET_LIST = cast(@TEMP_TEAM_ID as char(36));
			-- 01/09/2017 Paul.  Change status to Pending Input when new email arrives. 
			update CASES
			   set STATUS            = N'Pending Input'
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = @ASSIGNED_USER_ID
			 where ID                = @PARENT_ID
			   and isnull(STATUS, N'') <> N'Pending Input';
		end else if @INTENT = N'support' begin -- then
			-- 04/18/2008 Paul.  Create Case.
			set @PARENT_TYPE = N'Cases';
			-- 06/03/2008 Paul.  When creating the new case, make sure to use the @CASE_MACRO. 
			set @PARENT_ID = newid();
			set @CASE_MACRO = replace(@CASE_MACRO, N'%1', cast(@PARENT_ID as char(36)));
			if len(@TEMP_NAME) + len(@CASE_MACRO) + 1 > 200 begin -- then
				-- 06/03/2008 Paul.  Truncate the name if greater than 200 so that there is enough space for RE:
				set @TEMP_NAME = substring(@TEMP_NAME, 1, 200 - len(@CASE_MACRO));
			end -- if;
			set @TEMP_NAME = @TEMP_NAME + N' ' + @CASE_MACRO;
			-- 01/09/2017 Paul.  Lookup accounts and contacts for new case. 
			if dbo.fnIsEmptyGuid(@CONTACT_ID) = 0 begin -- then
				select top 1
				       @ACCOUNT_ID = ID
				  from ACCOUNTS_CONTACTS
				 where DELETED     = 0
				   and CONTACT_ID  = @CONTACT_ID;
			end -- if;
			if dbo.fnIsEmptyGuid(@ACCOUNT_ID) = 1 begin -- then
				select top 1
				       @ACCOUNT_ID = ID
				  from ACCOUNTS
				 where DELETED = 0
				   and (EMAIL1 = @TEMP_REPLY_TO_ADDR or EMAIL2 = @TEMP_REPLY_TO_ADDR or EMAIL1 = @TEMP_FROM_ADDR or EMAIL2 = @TEMP_FROM_ADDR);
			end -- if;
			-- 08/23/2009 Paul.  Add field for CASE_NUMBER and TEAM_SET_NAME. 
			-- 09/12/2010 Paul.  Add default parameter EXCHANGE_FOLDER to ease migration to EffiProz. 
			-- 01/09/2017 Paul.  Added fields TYPE, WORK_LOG, B2C_CONTACT_IC and TAG_SET_NAME. 
			-- 01/09/2017 Paul.  Change Case status to Pending Input when created by an email event. 
			-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			exec dbo.spCASES_Update @PARENT_ID out
				, @MODIFIED_USER_ID
				, @TEMP_ASSIGNED_USER_ID
				, @TEMP_NAME
				, null                  -- @ACCOUNT_NAME
				, @ACCOUNT_ID
				, N'Pending Input'      -- @STATUS
				, null                  -- @PRIORITY
				, @DESCRIPTION
				, null                  -- @RESOLUTION
				, null                  -- @PARENT_TYPE
				, null                  -- @PARENT_ID
				, null                  -- @CASE_NUMBER
				, @TEMP_TEAM_ID         -- @TEAM_ID
				, @TEAM_SET_LIST
				, null                  -- @EXCHANGE_FOLDER
				, null                  -- @TYPE
				, null                  -- @WORK_LOG
				, @CONTACT_ID           -- @B2C_CONTACT_ID
				, null                  -- @TAG_SET_NAME
				, @ASSIGNED_SET_LIST
				;
		end -- if;
	end else if @INTENT = N'bounce' begin -- then
		-- 01/13/2008 Paul.  Gmail and MS Exchange Server both return the following subject upon failure. 
		-- 07/20/2011 Paul.  There are a number of other possible failure messages. 
		-- 01/26/2013 Paul.  Oracle queries are case-significant. 
		if    substring(@FROM_ADDR, 1, 14) = N'mailer-daemon@'
		   or substring(@FROM_ADDR, 1, 14) = N'MAILER-DAEMON@'
		   or substring(@FROM_ADDR, 1, 11) = N'postmaster@'
		   or @TEMP_NAME = N'Delivery Status Notification (Failure)' 
		   or @TEMP_NAME = N'Undeliverable Mail Returned to Sender' 
		   or @TEMP_NAME = N'Mail System Error - Returned Mail' 
		   or @TEMP_NAME = N'Mail delivery failed' 
		   or @TEMP_NAME = N'failure notice' 
		   or substring(@TEMP_NAME, 1, 14) = N'Undeliverable:' 
		   or substring(@TEMP_NAME, 1, 19) = N'Undeliverable mail:' 
		   or substring(@TEMP_NAME, 1, 17) = N'DELIVERY FAILURE:'
		begin -- then
			set @ACTIVITY_TYPE = N'invalid email';
		end else begin
			set @ACTIVITY_TYPE = N'send error';
		end -- if;
		-- 01/19/2017 Paul.  Make sure the tracker key exists before trying to lookup. 
		if dbo.fnIsEmptyGuid(@TARGET_TRACKER_KEY) = 0 begin -- then
			exec dbo.spCAMPAIGN_LOG_UpdateTracker @MODIFIED_USER_ID, @TARGET_TRACKER_KEY, @ACTIVITY_TYPE, null, @TARGET_ID out, @TARGET_TYPE out;
			if @ACTIVITY_TYPE = N'invalid email' begin -- then
				-- 01/19/2017 Paul.  Make sure the target was found before trying to mark as invalid. 
				if dbo.fnIsEmptyGuid(@TARGET_ID) = 0 begin -- then
					-- 01/21/2008 Paul.  If we get an invalid email event, then mark as invalid. 
					exec dbo.spCAMPAIGNS_InvalidEmail @MODIFIED_USER_ID, @TARGET_ID, @TARGET_TYPE;
				end else begin
					-- 01/19/2017 Paul.  If not found as a campaign tracker, then try as an email. 
					select @TARGET_ID   = PARENT_ID
					     , @TARGET_TYPE = PARENT_TYPE
					  from EMAILS
					 where ID = @TARGET_TRACKER_KEY;
					if dbo.fnIsEmptyGuid(@TARGET_ID) = 0 begin -- then
						exec dbo.spCAMPAIGNS_InvalidEmail @MODIFIED_USER_ID, @TARGET_ID, @TARGET_TYPE;
					end -- if;
				end -- if;
			end -- if;
		end -- if;
	end else if @INTENT = N'bug' begin -- then
		-- 04/18/2008 Paul.  Create Bug.
		set @PARENT_TYPE = N'Bugs';
		-- 08/23/2009 Paul.  Add field for BUG_NUMBER and TEAM_SET_NAME. 
		-- 09/12/2010 Paul.  Add default parameter EXCHANGE_FOLDER to ease migration to EffiProz. 
		-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		exec dbo.spBUGS_Update @PARENT_ID out
			, @MODIFIED_USER_ID
			, @TEMP_ASSIGNED_USER_ID
			, @TEMP_NAME
			, N'New'                 -- @STATUS
			, null                   -- @PRIORITY
			, @DESCRIPTION
			, null                   -- @RESOLUTION
			, null                   -- @FOUND_IN_RELEASE
			, null                   -- @TYPE
			, null                   -- @FIXED_IN_RELEASE
			, null                   -- @WORK_LOG
			, null                   -- @SOURCE
			, null                   -- @PRODUCT_CATEGORY
			, null                   -- @PARENT_TYPE
			, null                   -- @PARENT_ID
			, null                   -- @BUG_NUMBER
			, @TEMP_TEAM_ID          -- @TEAM_ID
			, @TEAM_SET_LIST
			, null                   -- @EXCHANGE_FOLDER
			, null                   -- @TAG_SET_NAME
			, @ASSIGNED_SET_LIST
			;
	end else if @INTENT = N'contact' begin -- then
		set @PARENT_TYPE = N'Contacts';
		-- 06/02/2008 Paul.  Lookup the contact before creating. 
		select top 1
		       @PARENT_ID = ID
		  from CONTACTS
		 where DELETED = 0
		   and (EMAIL1 = @TEMP_REPLY_TO_ADDR or EMAIL2 = @TEMP_REPLY_TO_ADDR or EMAIL1 = @TEMP_FROM_ADDR or EMAIL2 = @TEMP_FROM_ADDR);
		-- 04/21/2009 Paul.  The IsEmptyGuid test was not correct.  If the parent is not found, we want to create a lead. 
		-- If the parent is found, then we want to link the parent to this lead. 
		if dbo.fnIsEmptyGuid(@PARENT_ID) = 1 begin -- then
			-- 04/18/2008 Paul.  Create Contact.
			-- 08/23/2009 Paul.  Add TEAM_SET_NAME. 
			-- 05/24/2015 Paul.  Add picture. 
			-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			exec dbo.spCONTACTS_Update @PARENT_ID out
				, @MODIFIED_USER_ID
				, @TEMP_ASSIGNED_USER_ID
				, null                   -- @SALUTATION
				, null                   -- @FIRST_NAME
				, @FROM_NAME             -- @LAST_NAME
				, null                   -- @ACCOUNT_ID
				, N'Email'               -- @LEAD_SOURCE
				, null                   -- @TITLE
				, null                   -- @DEPARTMENT
				, null                   -- @REPORTS_TO_ID
				, null                   -- @BIRTHDATE
				, null                   -- @DO_NOT_CALL
				, null                   -- @PHONE_HOME
				, null                   -- @PHONE_MOBILE
				, null                   -- @PHONE_WORK
				, null                   -- @PHONE_OTHER
				, null                   -- @PHONE_FAX
				, @TEMP_FROM_ADDR        -- @EMAIL1
				, null                   -- @EMAIL2
				, null                   -- @ASSISTANT
				, null                   -- @ASSISTANT_PHONE
				, null                   -- @EMAIL_OPT_OUT
				, null                   -- @INVALID_EMAIL
				, null                   -- @PRIMARY_ADDRESS_STREET
				, null                   -- @PRIMARY_ADDRESS_CITY
				, null                   -- @PRIMARY_ADDRESS_STATE
				, null                   -- @PRIMARY_ADDRESS_POSTALCODE
				, null                   -- @PRIMARY_ADDRESS_COUNTRY
				, null                   -- @ALT_ADDRESS_STREET
				, null                   -- @ALT_ADDRESS_CITY
				, null                   -- @ALT_ADDRESS_STATE
				, null                   -- @ALT_ADDRESS_POSTALCODE
				, null                   -- @ALT_ADDRESS_COUNTRY
				, @DESCRIPTION
				, null                   -- @PARENT_TYPE
				, null                   -- @PARENT_ID
				, 0                      -- @SYNC_CONTACT
				, @TEMP_TEAM_ID          -- @TEAM_ID
				, @TEAM_SET_LIST
				, null                   -- @SMS_OPT_IN
				, null                   -- @TWITTER_SCREEN_NAME
				, null                   -- @PICTURE
				, null                   -- @LEAD_ID
				, null                   -- @EXCHANGE_FOLDER
				, null                   -- @TAG_SET_NAME
				, null                   -- @CONTACT_NUMBER
				, @ASSIGNED_SET_LIST
				;
		end -- if;
	end else if @INTENT = N'sales' begin -- then
		set @PARENT_TYPE = N'Leads';
		-- 06/02/2008 Paul.  Lookup the lead before creating. 
		select top 1
		       @PARENT_ID = ID
		  from LEADS
		 where DELETED = 0
		   and (EMAIL1 = @TEMP_REPLY_TO_ADDR or EMAIL2 = @TEMP_REPLY_TO_ADDR or EMAIL1 = @TEMP_FROM_ADDR or EMAIL2 = @TEMP_FROM_ADDR);
		-- 04/21/2009 Paul.  The IsEmptyGuid test was not correct.  If the parent is not found, we want to create a lead. 
		-- If the parent is found, then we want to link the parent to this lead. 
		if dbo.fnIsEmptyGuid(@PARENT_ID) = 1 begin -- then
			-- 04/18/2008 Paul.  Create Lead.
			-- 08/23/2009 Paul.  Add TEAM_SET_NAME. 
			-- 09/12/2010 Paul.  Add default parameter EXCHANGE_FOLDER to ease migration to EffiProz. 
			-- 05/24/2015 Paul.  Add picture. 
			-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			exec dbo.spLEADS_Update @PARENT_ID out
				, @MODIFIED_USER_ID
				, @TEMP_ASSIGNED_USER_ID
				, null                   -- @SALUTATION
				, null                   -- @FIRST_NAME
				, @FROM_NAME             -- @LAST_NAME
				, null                   -- @TITLE
				, null                   -- @REFERED_BY
				, N'Email'               -- @LEAD_SOURCE
				, null                   -- @LEAD_SOURCE_DESCRIPTION
				, N'New'                 -- @STATUS
				, null                   -- @STATUS_DESCRIPTION
				, null                   -- @DEPARTMENT
				, null                   -- @REPORTS_TO_ID
				, null                   -- @DO_NOT_CALL
				, null                   -- @PHONE_HOME
				, null                   -- @PHONE_MOBILE
				, null                   -- @PHONE_WORK
				, null                   -- @PHONE_OTHER
				, null                   -- @PHONE_FAX
				, @TEMP_FROM_ADDR        -- @EMAIL1
				, null                   -- @EMAIL2
				, null                   -- @EMAIL_OPT_OUT
				, null                   -- @INVALID_EMAIL
				, null                   -- @PRIMARY_ADDRESS_STREET
				, null                   -- @PRIMARY_ADDRESS_CITY
				, null                   -- @PRIMARY_ADDRESS_STATE
				, null                   -- @PRIMARY_ADDRESS_POSTALCODE
				, null                   -- @PRIMARY_ADDRESS_COUNTRY
				, null                   -- @ALT_ADDRESS_STREET
				, null                   -- @ALT_ADDRESS_CITY
				, null                   -- @ALT_ADDRESS_STATE
				, null                   -- @ALT_ADDRESS_POSTALCODE
				, null                   -- @ALT_ADDRESS_COUNTRY
				, @DESCRIPTION
				, null                   -- @ACCOUNT_NAME
				, null                   -- @CAMPAIGN_ID
				, @TEMP_TEAM_ID          -- @TEAM_ID
				, @TEAM_SET_LIST
				-- 12/29/2019 Paul.  Incorrect assignment of @TEMP_TEAM_ID to the following fields. 
				, null                   -- @CONTACT_ID
				, null                   -- @ACCOUNT_ID
				, null                   -- @EXCHANGE_FOLDER
				, null                   -- @BIRTHDATE
				, null                   -- @ASSISTANT
				, null                   -- @ASSISTANT_PHONE
				, null                   -- @WEBSITE
				, null                   -- @SMS_OPT_IN
				, null                   -- @TWITTER_SCREEN_NAME
				, null                   -- @PICTURE
				, null                   -- @TAG_SET_NAME
				, null                   -- @LEAD_NUMBER
				, @ASSIGNED_SET_LIST
				;
		end -- if;
	end else if @INTENT = N'task' begin -- then
		-- 04/18/2008 Paul.  Create Task.
		set @PARENT_TYPE = N'Tasks';
		-- 08/23/2009 Paul.  Add TEAM_SET_NAME. 
		-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		exec dbo.spTASKS_Update @PARENT_ID out
			, @MODIFIED_USER_ID
			, @TEMP_ASSIGNED_USER_ID
			, @TEMP_NAME
			, N'Not Started'         -- @STATUS
			, null                   -- @DATE_TIME_DUE
			, null                   -- @DATE_TIME_START
			, null                   -- @PARENT_TYPE
			, null                   -- @PARENT_ID
			, null                   -- @CONTACT_ID
			, null                   -- @PRIORITY
			, @DESCRIPTION
			, @TEMP_TEAM_ID          -- @TEAM_ID
			, @TEAM_SET_LIST
			, null                   -- @TAG_SET_NAME
			, null                   -- @REMINDER_TIME
			, null                   -- @EMAIL_REMINDER_TIME
			, null                   -- @SMS_REMINDER_TIME
			, null                   -- @IS_PRIVATE
			, @ASSIGNED_SET_LIST
			;
	end else begin
		-- 02/06/2013 Paul.  If the intent is empty, then set the @TEMP_TEAM_ID from the @ASSIGNED_USER_ID. 
		select @TEMP_TEAM_ID = isnull(@TEMP_TEAM_ID, TEAM_ID)
		  from vwUSERS_Login
		 where ID = @ASSIGNED_USER_ID;
		-- 02/06/2013 Paul.  We need to specify @TEAM_SET_ID in EMAILS creation. 
		set @TEAM_SET_LIST = cast(@TEMP_TEAM_ID as char(36));
		exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEMP_TEAM_ID, @TEAM_SET_LIST;
	end -- if;

	-- 02/06/2013 Paul.  We need to specify @TEAM_SET_ID in EMAILS creation. 
	set @ID = newid();
	insert into EMAILS
		( ID               
		, CREATED_BY       
		, DATE_ENTERED     
		, MODIFIED_USER_ID 
		, DATE_MODIFIED    
		, ASSIGNED_USER_ID 
		, NAME             
		, DATE_START       
		, TIME_START       
		, PARENT_TYPE      
		, PARENT_ID        
		, DESCRIPTION      
		, DESCRIPTION_HTML 
		, FROM_ADDR        
		, FROM_NAME        
		, TO_ADDRS         
		, CC_ADDRS         
		, BCC_ADDRS        
		, TO_ADDRS_NAMES   
		, TO_ADDRS_EMAILS  
		, CC_ADDRS_NAMES   
		, CC_ADDRS_EMAILS  
		, BCC_ADDRS_NAMES  
		, BCC_ADDRS_EMAILS 
		, TYPE             
		, STATUS           
		, MESSAGE_ID       
		, REPLY_TO_NAME    
		, REPLY_TO_ADDR    
		, INTENT           
		, MAILBOX_ID       
		, TEAM_ID          
		, TEAM_SET_ID      
		, RAW_SOURCE       
		, ASSIGNED_SET_ID  
		)
	values
		( @ID               
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @TEMP_ASSIGNED_USER_ID 
		, @TEMP_NAME             
		, @DATE_START       
		, @TIME_START       
		, @PARENT_TYPE      
		, @PARENT_ID        
		, @DESCRIPTION      
		, @DESCRIPTION_HTML 
		, @TEMP_FROM_ADDR   
		, @FROM_NAME        
		, @TO_ADDRS         
		, @CC_ADDRS         
		, @BCC_ADDRS        
		, @TO_ADDRS_NAMES   
		, @TO_ADDRS_EMAILS  
		, @CC_ADDRS_NAMES   
		, @CC_ADDRS_EMAILS  
		, @BCC_ADDRS_NAMES  
		, @BCC_ADDRS_EMAILS 
		, @TYPE             
		, @STATUS           
		, @MESSAGE_ID       
		, @TEMP_REPLY_TO_NAME    
		, @TEMP_REPLY_TO_ADDR    
		, @INTENT           
		, @MAILBOX_ID       
		, @TEMP_TEAM_ID     
		, @TEAM_SET_ID      
		, @RAW_SOURCE       
		, @ASSIGNED_SET_ID  
		);

	if @@ERROR = 0 begin -- then
		if not exists(select * from EMAILS_CSTM where ID_C = @ID) begin -- then
			insert into EMAILS_CSTM ( ID_C ) values ( @ID );
		end -- if;
	end -- if;

	-- 01/26/2013 Paul.  We have a new procedure that will pull the tracker key out of the email body. 
	if @ACTIVITY_TYPE = N'invalid email' and @TARGET_ID is null and @TARGET_TYPE is null begin -- then
		exec dbo.spEMAILS_UndeliverableEmail @ID, @MODIFIED_USER_ID, @TARGET_ID out, @TARGET_TYPE out;
	end -- if;
	
	-- 01/23/2008 Paul.  There are multiple ways that the email can be assigned to a lead, contact or prospect. 
	-- Make sure to only assign once. However, it is possible for a TARGET_ID match and an EMAIL1 match, to two different records. 
	-- Allow this double match to occur as it clearly implies some sort of relationship. 
	if @TARGET_ID is not null or len(@TEMP_REPLY_TO_ADDR) > 0 or len(@TEMP_FROM_ADDR) > 0 begin -- then
		delete from @RECIPIENTS;
		insert into @RECIPIENTS
			( ID               
			)
		select ID
		  from LEADS
		 where DELETED = 0
		   and (   (ID = @TARGET_ID    and @TARGET_TYPE = N'Leads')
		        or (EMAIL1 = @TEMP_REPLY_TO_ADDR or EMAIL2 = @TEMP_REPLY_TO_ADDR or EMAIL1 = @TEMP_FROM_ADDR or EMAIL2 = @TEMP_FROM_ADDR)
		       );
		-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
		open added_contacts_cursor;
		fetch next from added_contacts_cursor into @RECIPIENT_ID;
		while @@FETCH_STATUS = 0 and @@ERROR = 0 begin -- do
			exec dbo.spEMAILS_LEADS_Update @MODIFIED_USER_ID, @ID, @RECIPIENT_ID;
			-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
			exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @RECIPIENT_ID, N'Leads';
			fetch next from added_contacts_cursor into @RECIPIENT_ID;
		end -- while;
		close added_contacts_cursor;
		--deallocate added_contacts_cursor;

		delete from @RECIPIENTS;
		insert into @RECIPIENTS
			( ID               
			)
		select ID
		  from CONTACTS
		 where DELETED = 0
		   and (   (ID = @TARGET_ID    and @TARGET_TYPE = N'Contacts')
		        or (EMAIL1 = @TEMP_REPLY_TO_ADDR or EMAIL2 = @TEMP_REPLY_TO_ADDR or EMAIL1 = @TEMP_FROM_ADDR or EMAIL2 = @TEMP_FROM_ADDR)
		       );
		-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
		open added_contacts_cursor;
		fetch next from added_contacts_cursor into @RECIPIENT_ID;
		while @@FETCH_STATUS = 0 and @@ERROR = 0 begin -- do
			exec dbo.spEMAILS_CONTACTS_Update @MODIFIED_USER_ID, @ID, @RECIPIENT_ID;
			-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
			exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @RECIPIENT_ID, N'Contacts';
			fetch next from added_contacts_cursor into @RECIPIENT_ID;
		end -- while;
		close added_contacts_cursor;
		--deallocate added_contacts_cursor;

		delete from @RECIPIENTS;
		insert into @RECIPIENTS
			( ID               
			)
		select ID
		  from PROSPECTS
		 where DELETED = 0
		   and (   (ID = @TARGET_ID    and @TARGET_TYPE = N'Prospects')
		        or (EMAIL1 = @TEMP_REPLY_TO_ADDR or EMAIL2 = @TEMP_REPLY_TO_ADDR or EMAIL1 = @TEMP_FROM_ADDR or EMAIL2 = @TEMP_FROM_ADDR)
		       );
		-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
		open added_contacts_cursor;
		fetch next from added_contacts_cursor into @RECIPIENT_ID;
		while @@FETCH_STATUS = 0 and @@ERROR = 0 begin -- do
			exec dbo.spEMAILS_PROSPECTS_Update @MODIFIED_USER_ID, @ID, @RECIPIENT_ID;
			-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
			exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @RECIPIENT_ID, N'Prospects';
			fetch next from added_contacts_cursor into @RECIPIENT_ID;
		end -- while;
		close added_contacts_cursor;
		--deallocate added_contacts_cursor;

		if @TARGET_TYPE = N'Cases' begin -- then
			-- 04/18/2008 Paul.  Create Case.
			exec dbo.spEMAILS_CASES_Update @MODIFIED_USER_ID, @ID, @TARGET_ID;
		end else if @TARGET_TYPE = N'Bugs' begin -- then
			-- 04/18/2008 Paul.  Create Bug.
			exec dbo.spEMAILS_BUGS_Update @MODIFIED_USER_ID, @ID, @TARGET_ID;
		end else if @TARGET_TYPE = N'Contacts' begin -- then
			-- 04/18/2008 Paul.  Create Contact.
			exec dbo.spEMAILS_CONTACTS_Update @MODIFIED_USER_ID, @ID, @TARGET_ID;
		end else if @TARGET_TYPE = N'Leads' begin -- then
			-- 04/18/2008 Paul.  Create Lead.
			exec dbo.spEMAILS_LEADS_Update @MODIFIED_USER_ID, @ID, @TARGET_ID;
		end else if @TARGET_TYPE = N'Tasks' begin -- then
			-- 04/18/2008 Paul.  Create Task.
			exec dbo.spEMAILS_TASKS_Update @MODIFIED_USER_ID, @ID, @TARGET_ID;
		end -- if;
		
		if dbo.fnIsEmptyGuid(@TARGET_ID) = 0 begin -- then
			-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
			exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @TARGET_ID, @TARGET_TYPE;
		end -- if;
	end -- if;

	-- 05/21/2009 Paul.  Attempt to add the parent after Reply To and From Address inserts to prevent duplicates. 
	-- We are not checking for duplicates in the above code, but we do in the relationship procedures used below. 
	if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
		-- 04/18/2008  Paul.  Emails/Cases relationship only applies to support and pick. 
		if @PARENT_TYPE = N'Cases' begin -- then
			-- 04/18/2008 Paul.  Create Case.
			exec dbo.spEMAILS_CASES_Update @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Bugs' begin -- then
			-- 04/18/2008 Paul.  Create Bug.
			exec dbo.spEMAILS_BUGS_Update @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Contacts' begin -- then
			-- 04/18/2008 Paul.  Create Contact.
			exec dbo.spEMAILS_CONTACTS_Update @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Leads' begin -- then
			-- 04/18/2008 Paul.  Create Lead.
			exec dbo.spEMAILS_LEADS_Update @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Tasks' begin -- then
			-- 04/18/2008 Paul.  Create Task.
			exec dbo.spEMAILS_TASKS_Update @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end -- if;
		
		-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
		exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @PARENT_ID, @PARENT_TYPE;
	end -- if;

	-- 01/13/2008 Paul.  If the reply-to and the from address are both empty, then this is likely spam. 
	-- 01/23/2008 Paul.  The @ACTIVITY_TYPE is null requirement is so that this code will not execute if processing a bounce. 
	if @ACTIVITY_TYPE is null and (len(@TEMP_REPLY_TO_ADDR) > 0 or len(@TEMP_FROM_ADDR) > 0) begin -- then
		-- 01/13/2008 Paul.  Link the sender email to accounts, contacts, leads and prospects. 
		delete from @RECIPIENTS;
		insert into @RECIPIENTS
			( ID               
			)
		select ID
		  from ACCOUNTS
		 where DELETED = 0
		   and (EMAIL1 = @TEMP_REPLY_TO_ADDR or EMAIL2 = @TEMP_REPLY_TO_ADDR or EMAIL1 = @TEMP_FROM_ADDR or EMAIL2 = @TEMP_FROM_ADDR);
		-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
		open added_contacts_cursor;
		fetch next from added_contacts_cursor into @RECIPIENT_ID;
		while @@FETCH_STATUS = 0 and @@ERROR = 0 begin -- do
			exec dbo.spEMAILS_ACCOUNTS_Update @MODIFIED_USER_ID, @ID, @RECIPIENT_ID;
			-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
			exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @RECIPIENT_ID, N'Accounts';
			fetch next from added_contacts_cursor into @RECIPIENT_ID;
		end -- while;
		close added_contacts_cursor;
		--deallocate added_contacts_cursor;

		-- 01/13/2008 Paul.  Link the recipient to a user. 
		set @EMAIL_LIST = lower(@TO_ADDRS_EMAILS);
		set @CurrentPosR = 1;
		while @CurrentPosR <= len(@EMAIL_LIST) begin -- do
			-- 09/07/2008 Paul.  charindex should not use unicode parameters as it will limit all inputs to 4000 characters. 
			set @NextPosR = charindex(';', @EMAIL_LIST,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@EMAIL_LIST) + 1;
			end -- if;
			set @EMAIL = rtrim(ltrim(substring(@EMAIL_LIST, @CurrentPosR, @NextPosR - @CurrentPosR)));
			if len(@EMAIL) > 0 begin -- then
				insert into EMAILS_USERS
					( ID               
					, CREATED_BY       
					, DATE_ENTERED     
					, MODIFIED_USER_ID 
					, DATE_MODIFIED    
					, EMAIL_ID         
					, USER_ID          
					)
				select	  newid()
					, @MODIFIED_USER_ID 
					,  getdate()        
					, @MODIFIED_USER_ID 
					,  getdate()        
					, @ID         
					, ID
				  from USERS
				 where DELETED = 0
				   and (EMAIL1 = @EMAIL or EMAIL2 = @EMAIL);
			end -- if;
			set @CurrentPosR = @NextPosR + 1;
		end -- while;
	end -- if;

	if @@ERROR = 0 begin -- then
		if dbo.fnIsEmptyGuid(@TEMP_ASSIGNED_USER_ID) = 0 begin -- then
			exec dbo.spEMAILS_USERS_Update @MODIFIED_USER_ID, @ID, @TEMP_ASSIGNED_USER_ID;
		end -- if;
	end -- if;

	-- 01/13/2008 Paul.  Only send out Auto-Replies if the mailbox has a template. 
	if exists(select * from vwINBOUND_EMAILS where ID = @MAILBOX_ID and STATUS = N'Active' and TEMPLATE_ID is not null) begin -- then
		select @FILTER_DOMAIN       = FILTER_DOMAIN
		     , @TEMPLATE_ID         = TEMPLATE_ID
		     , @AUTOREPLY_FROM_NAME = isnull(FROM_NAME, dbo.fnCONFIG_String(N'fromname'))
		     , @AUTOREPLY_FROM_ADDR = isnull(FROM_ADDR, dbo.fnCONFIG_String(N'fromaddress'))
		  from INBOUND_EMAILS
		 where ID = @MAILBOX_ID;
		-- 01/13/2008 Paul.  Add the @ symbol makes it easy to find the domain. 
		if @FILTER_DOMAIN is not null and substring(@FILTER_DOMAIN, 1, 1) <> N'@' begin -- then
			set @FILTER_DOMAIN = N'@' + @FILTER_DOMAIN;
		end -- if;
		set @FILTER_DOMAIN = lower(@FILTER_DOMAIN);
		-- 01/23/2008 Paul.  The @ACTIVITY_TYPE is null requirement is so that this code will not execute if processing a bounce. 
		-- 09/07/2008 Paul.  Oracle does not allow optional parameters to charindex. 
		-- 02/12/2012 Paul.  @FILTER_DOMAIN can't be null and be found inside the REPLY_TO.  There must be an OR condition. 
		if @ACTIVITY_TYPE is null and (@FILTER_DOMAIN is null or (charindex(@FILTER_DOMAIN, @TEMP_REPLY_TO_ADDR, 1) = 0 and charindex(@FILTER_DOMAIN, @TEMP_FROM_ADDR, 1) = 0)) begin -- then
			-- 01/13/2008 Paul.  We need a localizable list of Out-of-Office terms to filter Auto-Replies
			-- Use a terminology list to lookup any out of office message in any language. 
			if not exists(select * from TERMINOLOGY where DELETED = 0 and LIST_NAME = N'out_of_office' and DISPLAY_NAME = @TEMP_NAME) begin -- then
				set @AUTOREPLY_MAX = dbo.fnCONFIG_Int(N'email_num_autoreplies_24_hours');
				if @AUTOREPLY_MAX is null begin -- then
					set @AUTOREPLY_MAX = 10;
				end -- if;
				-- 08/30/2008 Paul.  Use fnDateAdd_Hours() instead of dateadd() to simplify port to PostgreSQL. 
				select @AUTOREPLY_COUNT = count(*)
				  from INBOUND_EMAIL_AUTOREPLY
				 where (AUTOREPLIED_TO = @TEMP_REPLY_TO_ADDR or AUTOREPLIED_TO = @TEMP_FROM_ADDR)
				   and DATE_ENTERED > dbo.fnDateAdd_Hours(-24, getdate());
				if @AUTOREPLY_COUNT < @AUTOREPLY_MAX begin -- then
					if @TEMP_REPLY_TO_ADDR is null begin -- then
						set @TEMP_REPLY_TO_ADDR = @TEMP_FROM_ADDR;
					end -- if;
					if @TEMP_REPLY_TO_NAME is null begin -- then
						set @TEMP_REPLY_TO_NAME = @FROM_NAME;
					end -- if;
					set @AUTOREPLY_ID = newid();
					insert into INBOUND_EMAIL_AUTOREPLY
						( ID               
						, CREATED_BY       
						, DATE_ENTERED     
						, MODIFIED_USER_ID 
						, DATE_MODIFIED    
						, AUTOREPLIED_TO   
						, AUTOREPLIED_NAME 
						)
					values
						( @AUTOREPLY_ID     
						, @MODIFIED_USER_ID 
						,  getdate()        
						, @MODIFIED_USER_ID 
						,  getdate()        
						, @TEMP_REPLY_TO_ADDR    
						, @TEMP_REPLY_TO_NAME    
						);

					-- 01/13/2008 Paul.  To have an auto-reply generated we just need to insert
					-- the inbound record and the auto-reply record. The rest is automatic. 
					insert into EMAILMAN
						( USER_ID
						, INBOUND_EMAIL_ID
						, RELATED_ID
						, RELATED_TYPE
						, SEND_DATE_TIME
						)
					values
						( @MODIFIED_USER_ID
						, @MAILBOX_ID
						, @AUTOREPLY_ID
						, N'AutoReply'
						, getdate()
						);

				end -- if;
			end -- if;
		end -- if;
	end -- if;
	
	deallocate added_contacts_cursor;
  end
GO

Grant Execute on dbo.spEMAILS_InsertInbound to public;
GO


