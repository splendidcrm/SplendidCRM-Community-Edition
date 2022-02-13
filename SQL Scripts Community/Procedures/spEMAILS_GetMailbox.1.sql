if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_GetMailbox' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILS_GetMailbox;
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
-- 01/31/2019 Paul.  Ease conversion to Oracle. 
-- 01/24/2021 Paul.  Correct to return OAUTH_USER_ID not OAUTH_TOKEN_ID. 
Create Procedure dbo.spEMAILS_GetMailbox
	( @ID                uniqueidentifier
	, @MAIL_SENDTYPE     nvarchar(25) output
	, @MAIL_SMTPSERVER   nvarchar(100) output
	, @MAIL_SMTPPORT     int output
	, @MAIL_SMTPUSER     nvarchar(100) output
	, @MAIL_SMTPPASS     nvarchar(100) output
	, @MAIL_SMTPAUTH_REQ bit output
	, @MAIL_SMTPSSL      bit output
	, @OAUTH_USER_ID     uniqueidentifier output
	)
as
  begin
	set nocount on

	declare @MODIFIED_USER_ID  uniqueidentifier;
	declare @MAILBOX_ID        uniqueidentifier;
	select @MODIFIED_USER_ID = MODIFIED_USER_ID
	     , @MAILBOX_ID       = MAILBOX_ID
	  from EMAILS
	 where ID                = @ID;

	if @MAILBOX_ID is not null begin -- then
		-- 01/19/2017 Paul.  When a mailbox is specified, it is easy as there is only one possible choice. 
		-- 02/04/2017 Paul.  The OAUTH_TOKENS reference will either be the USER_ID or the ID of the OUTBOUND_EMAIL record. 
		-- 02/04/2017 Paul.  Use case instead of case as it is Oracle friendly. 
		-- 02/04/2017 Paul.  OUTBOUND_EMAILS.USER_ID is either null for global outbound records or not null for the primary user email. 
		select @MAIL_SENDTYPE     = isnull(OUTBOUND_EMAILS.MAIL_SENDTYPE, N'smtp')
		     , @MAIL_SMTPUSER     = OUTBOUND_EMAILS.MAIL_SMTPUSER
		     , @MAIL_SMTPPASS     = OUTBOUND_EMAILS.MAIL_SMTPPASS
		     , @MAIL_SMTPSERVER   = OUTBOUND_EMAILS.MAIL_SMTPSERVER
		     , @MAIL_SMTPPORT     = OUTBOUND_EMAILS.MAIL_SMTPPORT
		     , @MAIL_SMTPAUTH_REQ = OUTBOUND_EMAILS.MAIL_SMTPAUTH_REQ
		     , @MAIL_SMTPSSL      = (case OUTBOUND_EMAILS.MAIL_SMTPSSL when 1 then 1 when 0 then 0 end)
		     , @OAUTH_USER_ID     = OAUTH_TOKENS.ASSIGNED_USER_ID
		  from            OUTBOUND_EMAILS
		  left outer join OAUTH_TOKENS
		               on (OAUTH_TOKENS.ASSIGNED_USER_ID = OUTBOUND_EMAILS.USER_ID or OAUTH_TOKENS.ASSIGNED_USER_ID = OUTBOUND_EMAILS.ID)
		              and OAUTH_TOKENS.NAME             = OUTBOUND_EMAILS.MAIL_SENDTYPE
		              and OAUTH_TOKENS.DELETED          = 0
		 where OUTBOUND_EMAILS.ID      = @MAILBOX_ID
		   and OUTBOUND_EMAILS.DELETED = 0;
	end else begin
		-- 01/19/2017 Paul.  If a mailbox is not specified, then we need to select from 3 possible User configurations (SMTP, Office365 and GoogleApps). 
		-- We are looking for the primary send type, so NAME is always 'system' and TYPE is always 'system-override'. 
		-- First is SMTP or Exchange. 
		select @MAIL_SENDTYPE     = isnull(OUTBOUND_EMAILS.MAIL_SENDTYPE, N'smtp')
		     , @MAIL_SMTPUSER     = MAIL_SMTPUSER
		     , @MAIL_SMTPPASS     = MAIL_SMTPPASS
		  from OUTBOUND_EMAILS
		 where OUTBOUND_EMAILS.USER_ID    = @MODIFIED_USER_ID
		   and OUTBOUND_EMAILS.NAME       = N'system'
		   and OUTBOUND_EMAILS.TYPE       = N'system-override'
		   and (OUTBOUND_EMAILS.MAIL_SENDTYPE is null or OUTBOUND_EMAILS.MAIL_SENDTYPE in (N'smtp', N'Exchange-Password'))
		   and OUTBOUND_EMAILS.DELETED    = 0;
		if @MAIL_SMTPUSER is null begin -- then
			-- Second is Office365. 
			-- 01/24/2021 Paul.  Correct to return OAUTH_USER_ID not OAUTH_TOKEN_ID. 
			select @MAIL_SENDTYPE  = OAUTH_TOKENS.NAME
			     , @OAUTH_USER_ID  = OAUTH_TOKENS.ASSIGNED_USER_ID -- OAUTH_TOKENS.ID
			  from            OUTBOUND_EMAILS
			  left outer join OAUTH_TOKENS
			               on OAUTH_TOKENS.ASSIGNED_USER_ID = OUTBOUND_EMAILS.USER_ID
			              and OAUTH_TOKENS.NAME             = OUTBOUND_EMAILS.MAIL_SENDTYPE
			              and OAUTH_TOKENS.DELETED          = 0
			 where OUTBOUND_EMAILS.USER_ID       = @MODIFIED_USER_ID
			   and OUTBOUND_EMAILS.NAME          = N'system'
			   and OUTBOUND_EMAILS.TYPE          = N'system-override'
			   and OUTBOUND_EMAILS.MAIL_SENDTYPE = N'Office365'
			   and OUTBOUND_EMAILS.DELETED       = 0;
			if @OAUTH_USER_ID  is null begin -- then
				-- Third is GoogleApps/Gmail. 
				-- 01/24/2021 Paul.  Correct to return OAUTH_USER_ID not OAUTH_TOKEN_ID. 
				select @MAIL_SENDTYPE  = OAUTH_TOKENS.NAME
				     , @OAUTH_USER_ID  = OAUTH_TOKENS.ASSIGNED_USER_ID -- OAUTH_TOKENS.ID
				  from            OUTBOUND_EMAILS
				  left outer join OAUTH_TOKENS
				               on OAUTH_TOKENS.ASSIGNED_USER_ID = OUTBOUND_EMAILS.USER_ID
				              and OAUTH_TOKENS.NAME             = OUTBOUND_EMAILS.MAIL_SENDTYPE
				              and OAUTH_TOKENS.DELETED          = 0
				 where OUTBOUND_EMAILS.USER_ID       = @MODIFIED_USER_ID
				   and OUTBOUND_EMAILS.NAME          = N'system'
				   and OUTBOUND_EMAILS.TYPE          = N'system-override'
				   and OUTBOUND_EMAILS.MAIL_SENDTYPE = N'GoogleApps'
				   and OUTBOUND_EMAILS.DELETED       = 0;
			end -- if;
		end -- if;
	end -- if;
  end
GO
 
Grant Execute on dbo.spEMAILS_GetMailbox to public;
GO
 
