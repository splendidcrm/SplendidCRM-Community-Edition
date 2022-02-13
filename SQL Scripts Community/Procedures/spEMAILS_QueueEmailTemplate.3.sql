if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_QueueEmailTemplate' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILS_QueueEmailTemplate;
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
-- 06/09/2008 Paul.  Replace vwPARENTS_EMAIL_ADDRESS with vwQUEUE_EMAIL_ADDRESS when validating. 
-- 06/09/2008 Paul.  Email Templates do not use the BODY field, so we need to copy the BODY_HTML to the EMAILS Description field. 
-- 09/07/2008 Paul.  Reorder variables to simplify migration to Oracle. 
-- 09/15/2008 Paul.  MySQL does not support the return clause, so use the Leave clause instead. 
-- 11/01/2010 Paul.  Increase length of MESSAGE_ID to varchar(851) to allow for IMAP value + login + server. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spEMAILS_QueueEmailTemplate
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @FROM_ADDR         nvarchar(100)
	, @FROM_NAME         nvarchar(100)
	, @PARENT_TYPE       nvarchar( 25)
	, @PARENT_ID         uniqueidentifier
	, @EMAIL_TEMPLATE_ID uniqueidentifier
	)
as
  begin
	set nocount on

	declare @ASSIGNED_USER_ID    uniqueidentifier;
	declare @DATE_TIME           datetime;
	declare @TO_ADDRS_IDS        varchar(8000);
	declare @TO_ADDRS_NAMES      nvarchar(4000);
	declare @TO_ADDRS_EMAILS     nvarchar(4000);
	declare @CC_ADDRS_IDS        varchar(8000);
	declare @CC_ADDRS_NAMES      nvarchar(4000);
	declare @CC_ADDRS_EMAILS     nvarchar(4000);
	declare @BCC_ADDRS_IDS       varchar(8000);
	declare @BCC_ADDRS_NAMES     nvarchar(4000);
	declare @BCC_ADDRS_EMAILS    nvarchar(4000);
	declare @TO_ADDRS            nvarchar(4000);
	declare @CC_ADDRS            nvarchar(4000);
	declare @BCC_ADDRS           nvarchar(4000);
	declare @TYPE                nvarchar( 25);
	declare @MESSAGE_ID          varchar(851);
	declare @REPLY_TO_NAME       nvarchar(100);
	declare @REPLY_TO_ADDR       nvarchar(100);
	declare @INTENT              nvarchar( 25);
	declare @MAILBOX_ID          uniqueidentifier;
	declare @STATUS              nvarchar(25);
	declare @DATE_START          datetime;
	declare @TIME_START          datetime;
	declare @ERROR_TEXT          nvarchar(150);


	-- 09/07/2008 Paul.  Simplify for migration to Oracle.
	if not exists(select * from EMAIL_TEMPLATES where ID = @EMAIL_TEMPLATE_ID and DELETED = 0) begin -- then
		set @ERROR_TEXT = N'spEMAILS_QueueEmailTemplate: Could not find Email Template ' + cast(@EMAIL_TEMPLATE_ID as char(36)) + '.';
		-- 06/24/2008 Paul.  Don't raise an error as it will abort the entire transaction.  Just log the error and continue. 
		--raiserror(@ERROR_TEXT, 16, 1);
		exec dbo.spSYSTEM_LOG_InsertOnly null, null, null, null, null, null, null, null, null, null, N'Error', null, N'spEMAILS_QueueEmailTemplate', null, @ERROR_TEXT;
		return;
	end -- if;

	if not exists(select * from vwQUEUE_EMAIL_ADDRESS where PARENT_ID = @PARENT_ID and PARENT_TYPE = @PARENT_TYPE) begin -- then
		set @ERROR_TEXT = N'spEMAILS_QueueEmailTemplate: Could not find ' + @PARENT_TYPE + ' ID ' + cast(@PARENT_ID as char(36)) + '.';
		-- 06/24/2008 Paul.  Don't raise an error as it will abort the entire transaction.  Just log the error and continue. 
		--raiserror(@ERROR_TEXT, 16, 1);
		exec dbo.spSYSTEM_LOG_InsertOnly null, null, null, null, null, null, null, null, null, null, N'Error', null, N'spEMAILS_QueueEmailTemplate', null, @ERROR_TEXT;
		return;
	end -- if;

	if @FROM_ADDR is null begin -- then
		-- 06/24/2008 Paul.  Don't raise an error as it will abort the entire transaction.  Just log the error and continue. 
		--raiserror(N'spEMAILS_QueueEmailTemplate: Sender address was not provided.', 16, 1);
		exec dbo.spSYSTEM_LOG_InsertOnly null, null, null, null, null, null, null, null, null, null, N'Error', null, N'spEMAILS_QueueEmailTemplate', null, N'spEMAILS_QueueEmailTemplate: Sender address was not provided.';
		return;
	end else begin
		set @ID         = newid();
		set @TYPE       = N'out';
		set @STATUS     = N'draft';
		set @DATE_TIME  = getdate();
		set @DATE_START = dbo.fnStoreDateOnly(@DATE_TIME);
		set @TIME_START = dbo.fnStoreTimeOnly(@DATE_TIME);

		-- 06/03/2008 Paul.  Use vwQUEUE_EMAIL_ADDRESS to bring in emails from Invoices, Orders and Quotes. 
		select top 1
		       @PARENT_TYPE     = PARENT_TYPE
		     , @TO_ADDRS        = ltrim(rtrim(PARENT_NAME + N' <' + EMAIL1 + N'>'))
		     , @TO_ADDRS_IDS    = cast(PARENT_ID as char(36))
		     , @TO_ADDRS_NAMES  = PARENT_NAME
		     , @TO_ADDRS_EMAILS = EMAIL1
		  from vwQUEUE_EMAIL_ADDRESS
		 where PARENT_ID        = @PARENT_ID
		   and PARENT_TYPE      = @PARENT_TYPE;

		-- exec dbo.spEMAILS_Update @ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @NAME, @DATE_TIME, @PARENT_TYPE, @PARENT_ID, @DESCRIPTION, @DESCRIPTION_HTML, @FROM_ADDR, @FROM_NAME, @TO_ADDRS, @CC_ADDRS, @BCC_ADDRS, @TO_ADDRS_IDS, @TO_ADDRS_NAMES, @TO_ADDRS_EMAILS, @CC_ADDRS_IDS, @CC_ADDRS_NAMES, @CC_ADDRS_EMAILS, @BCC_ADDRS_IDS, @BCC_ADDRS_NAMES, @BCC_ADDRS_EMAILS, @TYPE, @MESSAGE_ID, @REPLY_TO_NAME, @REPLY_TO_ADDR, @INTENT, @MAILBOX_ID, @TEAM_ID;
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
			, TO_ADDRS_IDS     
			, TO_ADDRS_NAMES   
			, TO_ADDRS_EMAILS  
			, CC_ADDRS_IDS     
			, CC_ADDRS_NAMES   
			, CC_ADDRS_EMAILS  
			, BCC_ADDRS_IDS    
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
			, ASSIGNED_SET_ID  
			)
		select
			  @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @ASSIGNED_USER_ID 
			,  SUBJECT
			, @DATE_START       
			, @TIME_START       
			, @PARENT_TYPE      
			, @PARENT_ID        
			, (case when BODY is null then BODY_HTML else BODY end)
			,  BODY_HTML
			, @FROM_ADDR        
			, @FROM_NAME        
			, @TO_ADDRS         
			, @CC_ADDRS         
			, @BCC_ADDRS        
			, @TO_ADDRS_IDS     
			, @TO_ADDRS_NAMES   
			, @TO_ADDRS_EMAILS  
			, @CC_ADDRS_IDS     
			, @CC_ADDRS_NAMES   
			, @CC_ADDRS_EMAILS  
			, @BCC_ADDRS_IDS    
			, @BCC_ADDRS_NAMES  
			, @BCC_ADDRS_EMAILS 
			, @TYPE             
			, @STATUS           
			, @MESSAGE_ID       
			, @REPLY_TO_NAME    
			, @REPLY_TO_ADDR    
			, @INTENT           
			, @MAILBOX_ID       
			,  TEAM_ID          
			,  TEAM_SET_ID      
			,  ASSIGNED_SET_ID  
		  from EMAIL_TEMPLATES
		 where ID      = @EMAIL_TEMPLATE_ID
		   and DELETED = 0;

		insert into EMAILS_CSTM ( ID_C ) values ( @ID );
	
		if          @PARENT_TYPE = N'Accounts' begin -- then
			exec dbo.spEMAILS_ACCOUNTS_Update      @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Contacts' begin -- then
			exec dbo.spEMAILS_CONTACTS_Update      @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Leads' begin -- then
			exec dbo.spEMAILS_LEADS_Update         @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Prospects' begin -- then
			exec dbo.spEMAILS_PROSPECTS_Update     @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Users' begin -- then
			exec dbo.spEMAILS_USERS_Update         @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end -- if;
		
		if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
			-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
			exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @PARENT_ID, @PARENT_TYPE;
		end -- if;
	end -- if;
/* -- #if MySQL
  end;  #MainProcedureBlock
-- #endif MySQL */
  end
GO

Grant Execute on dbo.spEMAILS_QueueEmailTemplate to public;
GO

