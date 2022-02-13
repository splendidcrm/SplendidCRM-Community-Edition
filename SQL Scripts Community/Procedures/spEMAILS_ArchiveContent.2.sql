if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_ArchiveContent' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILS_ArchiveContent;
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
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spEMAILS_ArchiveContent
	( @ID                uniqueidentifier
	, @MODIFIED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(255)
	, @DESCRIPTION       nvarchar(max)
	, @DESCRIPTION_HTML  nvarchar(max)
	, @INCLUDE_CC        bit
	)
as
  begin
	set nocount on

	declare @ARCHIVE_ID  uniqueidentifier;
	declare @PARENT_ID   uniqueidentifier;
	declare @PARENT_TYPE nvarchar(25);
	declare @STATUS      nvarchar(25);
	declare @TYPE        nvarchar(25);
	declare @DATE_SENT   datetime;
	set @ARCHIVE_ID = newid();
	set @TYPE       = N'archived';
	set @STATUS     = N'sent';
	set @DATE_SENT  = getdate();

	-- BEGIN Oracle Exception
		select @PARENT_ID   = PARENT_ID
		     , @PARENT_TYPE = PARENT_TYPE
		  from EMAILS
		 where ID      = @ID
		   and DELETED = 0;
	-- END Oracle Exception

	insert into EMAILS
		( ID               
		, CREATED_BY       
		, DATE_ENTERED     
		, MODIFIED_USER_ID 
		, DATE_MODIFIED    
		, DATE_MODIFIED_UTC
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
		  @ARCHIVE_ID       
		,  CREATED_BY       
		, getdate()         
		,  MODIFIED_USER_ID 
		, getdate()         
		, getutcdate()      
		,  ASSIGNED_USER_ID 
		, @NAME             
		,  dbo.fnStoreDateOnly(@DATE_SENT)
		,  dbo.fnStoreTimeOnly(@DATE_SENT)
		,  PARENT_TYPE      
		,  PARENT_ID        
		, @DESCRIPTION      
		, @DESCRIPTION_HTML 
		,  FROM_ADDR        
		,  FROM_NAME        
		,  TO_ADDRS         
		, (case @INCLUDE_CC when 1 then CC_ADDRS         else null end)
		, (case @INCLUDE_CC when 1 then BCC_ADDRS        else null end)
		,  TO_ADDRS_IDS     
		,  TO_ADDRS_NAMES   
		,  TO_ADDRS_EMAILS  
		, (case @INCLUDE_CC when 1 then CC_ADDRS_IDS     else null end)
		, (case @INCLUDE_CC when 1 then CC_ADDRS_NAMES   else null end)
		, (case @INCLUDE_CC when 1 then CC_ADDRS_EMAILS  else null end)
		, (case @INCLUDE_CC when 1 then BCC_ADDRS_IDS    else null end)
		, (case @INCLUDE_CC when 1 then BCC_ADDRS_NAMES  else null end)
		, (case @INCLUDE_CC when 1 then BCC_ADDRS_EMAILS else null end)
		, @TYPE             
		, @STATUS           
		,  MESSAGE_ID       
		,  REPLY_TO_NAME    
		,  REPLY_TO_ADDR    
		,  INTENT           
		,  MAILBOX_ID       
		,  TEAM_ID          
		,  TEAM_SET_ID      
		,  ASSIGNED_SET_ID  
	  from EMAILS
	 where ID      = @ID
	   and DELETED = 0;
	
	-- 04/27/2011 Paul.  Only copy the relationship records for the first archived email. 
	if @INCLUDE_CC = 1 begin -- then
		if exists(select * from EMAILS_CONTACTS where EMAIL_ID = @ID and DELETED= 0) begin -- then
			insert into EMAILS_CONTACTS
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, EMAIL_ID         
				, CONTACT_ID       
				)
			select	  newid()          
				,  CREATED_BY      
				, getdate()        
				,  MODIFIED_USER_ID
				, getdate()        
				, @ARCHIVE_ID      
				,  CONTACT_ID      
			  from EMAILS_CONTACTS
			 where EMAIL_ID = @ID
			   and DELETED  = 0;
		end -- if;
		if exists(select * from EMAILS_LEADS where EMAIL_ID = @ID and DELETED= 0) begin -- then
			insert into EMAILS_LEADS
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, EMAIL_ID         
				, LEAD_ID          
				)
			select	  newid()          
				,  CREATED_BY      
				, getdate()        
				,  MODIFIED_USER_ID
				, getdate()        
				, @ARCHIVE_ID      
				,  LEAD_ID         
			  from EMAILS_LEADS
			 where EMAIL_ID = @ID
			   and DELETED  = 0;
		end -- if;
		if exists(select * from EMAILS_PROSPECTS where EMAIL_ID = @ID and DELETED= 0) begin -- then
			insert into EMAILS_PROSPECTS
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, EMAIL_ID         
				, PROSPECT_ID      
				)
			select	  newid()          
				,  CREATED_BY      
				, getdate()        
				,  MODIFIED_USER_ID
				, getdate()        
				, @ARCHIVE_ID      
				,  PROSPECT_ID     
			  from EMAILS_PROSPECTS
			 where EMAIL_ID = @ID
			   and DELETED  = 0;
		end -- if;
	end -- if;
	if @PARENT_ID is not null begin -- then
		if          @PARENT_TYPE = N'Accounts' begin -- then
			exec dbo.spEMAILS_ACCOUNTS_Update      @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Bugs' begin -- then
			exec dbo.spEMAILS_BUGS_Update          @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Cases' begin -- then
			exec dbo.spEMAILS_CASES_Update         @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Contacts' begin -- then
			exec dbo.spEMAILS_CONTACTS_Update      @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Leads' begin -- then
			exec dbo.spEMAILS_LEADS_Update         @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Opportunities' begin -- then
			exec dbo.spEMAILS_OPPORTUNITIES_Update @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Project' begin -- then
			exec dbo.spEMAILS_PROJECTS_Update      @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'ProjectTask' begin -- then
			exec dbo.spEMAILS_PROJECT_TASKS_Update @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Prospects' begin -- then
			exec dbo.spEMAILS_PROSPECTS_Update     @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Quotes' begin -- then
			exec dbo.spEMAILS_QUOTES_Update        @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Tasks' begin -- then
			exec dbo.spEMAILS_TASKS_Update         @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Users' begin -- then
			exec dbo.spEMAILS_USERS_Update         @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Contracts' begin -- then
			exec dbo.spEMAILS_CONTRACTS_Update     @MODIFIED_USER_ID, @ARCHIVE_ID, @PARENT_ID;
		end -- if;
	end -- if;
  end
GO
 
Grant Execute on dbo.spEMAILS_ArchiveContent to public;
GO
 
