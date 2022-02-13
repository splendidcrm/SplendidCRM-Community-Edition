if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spOUTBOUND_EMAILS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spOUTBOUND_EMAILS_Update;
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
-- 07/16/2013 Paul.  spOUTBOUND_EMAILS_Update now returns the ID. 
-- 04/20/2016 Paul.  Add team management to Outbound Emails. 
-- 01/17/2017 Paul.  @MAIL_SMTPUSER will be null for Office 365 and other OAuth accounts. 
-- 01/17/2017 Paul.  Increase size of @MAIL_SENDTYPE to fit office365. 
-- 05/05/2021 Paul.  Must prevent multiple system-override records as there can be only, otherwise vwUSERS_Edit will return multiple records. 
Create Procedure dbo.spOUTBOUND_EMAILS_Update
	( @ID                 uniqueidentifier output
	, @MODIFIED_USER_ID   uniqueidentifier
	, @NAME               nvarchar(50)
	, @TYPE               nvarchar(15)
	, @USER_ID            uniqueidentifier
	, @MAIL_SENDTYPE      nvarchar(25)
	, @MAIL_SMTPTYPE      nvarchar(20)
	, @MAIL_SMTPSERVER    nvarchar(100)
	, @MAIL_SMTPPORT      int
	, @MAIL_SMTPUSER      nvarchar(100)
	, @MAIL_SMTPPASS      nvarchar(100)
	, @MAIL_SMTPAUTH_REQ  bit
	, @MAIL_SMTPSSL       int
	, @FROM_NAME          nvarchar(100) = null
	, @FROM_ADDR          nvarchar(100) = null
	, @TEAM_ID            uniqueidentifier = null
	, @TEAM_SET_LIST      varchar(8000) = null
	)
as
  begin
	set nocount on
	
	-- 04/20/2016 Paul.  Add team management to Outbound Emails. 
	declare @TEAM_SET_ID         uniqueidentifier;
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;

	-- 05/05/2021 Paul.  Must prevent multiple system-override records as there can be only, otherwise vwUSERS_Edit will return multiple records. 
	-- The problem is likely that this procedure is called instead of spOUTBOUND_EMAILS_UpdateUser. 
	if @ID is null and @TYPE = N'system-override' begin -- then
		select @ID = ID
		  from OUTBOUND_EMAILS
		 where USER_ID = @USER_ID 
		   and TYPE    = N'system-override'
		   and DELETED = 0;
	end -- if;

	if not exists(select * from OUTBOUND_EMAILS where ID = @ID) begin -- then
		-- 07/09/2010 Paul.  Don't create the OUTBOUND_EMAILS record unless the SMTP User is specified. 
		-- 01/17/2017 Paul.  @MAIL_SMTPUSER will be null for Office 365 and other OAuth accounts. 
		-- 02/06/2017 Paul.  ASSIGNED_USER_ID could be the USER_ID or the OUTBOUND_EMAILS.ID. 
		if @MAIL_SMTPUSER is not null or exists(select * from OAUTH_TOKENS where (ASSIGNED_USER_ID = @USER_ID or ASSIGNED_USER_ID = @ID) and DELETED = 0) begin -- then
			-- 07/05/2018 Paul.  We need to prevent duplicate records when dealing with Office365. 
			if not exists(select * from OUTBOUND_EMAILS where USER_ID = @USER_ID and TYPE = N'system-override' and MAIL_SENDTYPE = @MAIL_SENDTYPE and DELETED = 0) begin -- then
				if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
					set @ID = newid();
				end -- if;
				insert into OUTBOUND_EMAILS
					( ID                
					, CREATED_BY        
					, DATE_ENTERED      
					, MODIFIED_USER_ID  
					, DATE_MODIFIED     
					, DATE_MODIFIED_UTC 
					, NAME              
					, TYPE              
					, USER_ID           
					, MAIL_SENDTYPE     
					, MAIL_SMTPTYPE     
					, MAIL_SMTPSERVER   
					, MAIL_SMTPPORT     
					, MAIL_SMTPUSER     
					, MAIL_SMTPPASS     
					, MAIL_SMTPAUTH_REQ 
					, MAIL_SMTPSSL      
					, FROM_NAME         
					, FROM_ADDR         
					, TEAM_ID           
					, TEAM_SET_ID       
					)
				values 	( @ID                
					, @MODIFIED_USER_ID  
					,  getdate()         
					, @MODIFIED_USER_ID  
					,  getdate()         
					,  getutcdate()      
					, @NAME              
					, @TYPE              
					, @USER_ID           
					, @MAIL_SENDTYPE     
					, @MAIL_SMTPTYPE     
					, @MAIL_SMTPSERVER   
					, @MAIL_SMTPPORT     
					, @MAIL_SMTPUSER     
					, @MAIL_SMTPPASS     
					, @MAIL_SMTPAUTH_REQ 
					, @MAIL_SMTPSSL      
					, @FROM_NAME         
					, @FROM_ADDR         
					, @TEAM_ID           
					, @TEAM_SET_ID       
					);
			end -- if;
		end -- if;
	end else begin
		update OUTBOUND_EMAILS
		   set MODIFIED_USER_ID   = @MODIFIED_USER_ID  
		     , DATE_MODIFIED      =  getdate()         
		     , DATE_MODIFIED_UTC  =  getutcdate()      
		     , NAME               = @NAME              
		     , TYPE               = @TYPE              
		     , USER_ID            = @USER_ID           
		     , MAIL_SENDTYPE      = @MAIL_SENDTYPE     
		     , MAIL_SMTPTYPE      = @MAIL_SMTPTYPE     
		     , MAIL_SMTPSERVER    = @MAIL_SMTPSERVER   
		     , MAIL_SMTPPORT      = @MAIL_SMTPPORT     
		     , MAIL_SMTPUSER      = @MAIL_SMTPUSER     
		     , MAIL_SMTPPASS      = @MAIL_SMTPPASS     
		     , MAIL_SMTPAUTH_REQ  = @MAIL_SMTPAUTH_REQ 
		     , MAIL_SMTPSSL       = @MAIL_SMTPSSL      
		     , FROM_NAME          = @FROM_NAME         
		     , FROM_ADDR          = @FROM_ADDR         
		     , TEAM_ID            = @TEAM_ID           
		     , TEAM_SET_ID        = @TEAM_SET_ID       
		 where ID                 = @ID                ;
	end -- if;
  end
GO

Grant Execute on dbo.spOUTBOUND_EMAILS_Update to public;
GO

