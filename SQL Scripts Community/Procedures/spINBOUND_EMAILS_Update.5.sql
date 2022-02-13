if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spINBOUND_EMAILS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spINBOUND_EMAILS_Update;
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
-- 01/08/2008 Paul.  Separate out MAILBOX_SSL for ease of coding. Sugar combines it an TLS into the SERVICE field. 
-- 01/13/2008 Paul.  ONLY_SINCE will not be stored in STORED_OPTIONS because we need high-performance access. 
-- 01/13/2008 Paul.  Correct spelling of DELETE_SEEN, which is the reverse of MARK_READ. 
-- 08/27/2008 Paul.  PostgreSQL does not allow modifying input parameters.  Use a local temp variable. 
-- 04/19/2011 Paul.  Add IS_PERSONAL to exclude EmailClient inbound from being included in monitored list. 
-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
-- 01/28/2017 Paul.  TEAM_ID for inbound emails. 
-- 03/22/2017 Paul.  Rename file to spINBOUND_EMAILS_Update.3.sql. 
-- 07/26/2017 Paul.  Rename file to spINBOUND_EMAILS_Update.5.sql due to dependency with spTEAMS_InsertPrivate.4.sql. 
Create Procedure dbo.spINBOUND_EMAILS_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(255)
	, @STATUS            nvarchar(25)
	, @SERVER_URL        nvarchar(100)
	, @EMAIL_USER        nvarchar(100)
	, @EMAIL_PASSWORD    nvarchar(100)
	, @PORT              int
	, @MAILBOX_SSL       bit
	, @SERVICE           nvarchar(50)
	, @MAILBOX           nvarchar(50)
	, @MARK_READ         bit
	, @ONLY_SINCE        bit
	, @MAILBOX_TYPE      nvarchar(10)
	, @TEMPLATE_ID       uniqueidentifier
	, @GROUP_ID          uniqueidentifier
	, @FROM_NAME         nvarchar(100)
	, @FROM_ADDR         nvarchar(100)
	, @FILTER_DOMAIN     nvarchar(100)
	, @IS_PERSONAL       bit = null
	, @REPLY_TO_NAME     nvarchar(100) = null
	, @REPLY_TO_ADDR     nvarchar(100) = null
	, @GROUP_TEAM_ID     uniqueidentifier = null
	)
as
  begin
	set nocount on

	declare @DELETE_SEEN   bit;
	-- 01/28/2017 Paul.  TEAM_ID for inbound emails. 
	declare @TEMP_GROUP_ID   uniqueidentifier;
	declare @TEMP_TEAM_ID    uniqueidentifier;
	set @TEMP_GROUP_ID = @GROUP_ID;
	set @TEMP_TEAM_ID  = @GROUP_TEAM_ID ;
	if @MARK_READ = 1 begin -- then
		set @DELETE_SEEN = 0;
	end else begin
		set @DELETE_SEEN = 1;
	end -- if;

	-- 12/22/2007 Paul.  Create a new group if one is not provided. 
	-- 04/19/2011 Paul.  Don't create a new group if this is a personal email. 
	if dbo.fnIsEmptyGuid(@TEMP_GROUP_ID) = 1 and isnull(@IS_PERSONAL, 0) = 0 begin -- then
		set @TEMP_GROUP_ID = newid();
		insert into USERS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, LAST_NAME        
			, IS_ADMIN         
			, RECEIVE_NOTIFICATIONS
			, STATUS           
			, IS_GROUP         
			)
		values	( @TEMP_GROUP_ID    
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @NAME             
			, 0                 
			, 1                 
			, N'Active'         
			, 1                 
			);
		if dbo.fnCONFIG_Boolean(N'enable_team_management') = 1 and @TEMP_TEAM_ID is null begin -- then
			exec dbo.spTEAMS_InsertPrivate @MODIFIED_USER_ID, @TEMP_GROUP_ID, @NAME, @NAME;
			select @TEMP_TEAM_ID = TEAM_ID
			  from TEAM_MEMBERSHIPS
			 where USER_ID = @TEMP_GROUP_ID;
		end -- if;	
	end -- if;	
	if not exists(select * from INBOUND_EMAILS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into INBOUND_EMAILS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, NAME             
			, STATUS           
			, SERVER_URL       
			, EMAIL_USER       
			, EMAIL_PASSWORD   
			, PORT             
			, SERVICE          
			, MAILBOX          
			, DELETE_SEEN      
			, ONLY_SINCE       
			, MAILBOX_TYPE     
			, TEMPLATE_ID      
			, GROUP_ID         
			, GROUP_TEAM_ID    
			, FROM_NAME        
			, FROM_ADDR        
			, FILTER_DOMAIN    
			, MAILBOX_SSL      
			, IS_PERSONAL      
			, REPLY_TO_NAME    
			, REPLY_TO_ADDR    
			)
		values 	( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @NAME             
			, @STATUS           
			, @SERVER_URL       
			, @EMAIL_USER       
			, @EMAIL_PASSWORD   
			, @PORT             
			, @SERVICE          
			, @MAILBOX          
			, @DELETE_SEEN      
			, @ONLY_SINCE       
			, @MAILBOX_TYPE     
			, @TEMPLATE_ID      
			, @TEMP_GROUP_ID    
			, @TEMP_TEAM_ID     
			, @FROM_NAME        
			, @FROM_ADDR        
			, @FILTER_DOMAIN    
			, @MAILBOX_SSL      
			, @IS_PERSONAL      
			, @REPLY_TO_NAME    
			, @REPLY_TO_ADDR    
			);
	end else begin
		update INBOUND_EMAILS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , NAME              = @NAME             
		     , STATUS            = @STATUS           
		     , SERVER_URL        = @SERVER_URL       
		     , EMAIL_USER        = @EMAIL_USER       
		     , EMAIL_PASSWORD    = @EMAIL_PASSWORD   
		     , PORT              = @PORT             
		     , SERVICE           = @SERVICE          
		     , MAILBOX           = @MAILBOX          
		     , DELETE_SEEN       = @DELETE_SEEN      
		     , ONLY_SINCE        = @ONLY_SINCE       
		     , MAILBOX_TYPE      = @MAILBOX_TYPE     
		     , TEMPLATE_ID       = @TEMPLATE_ID      
		     , GROUP_ID          = @TEMP_GROUP_ID    
		     , GROUP_TEAM_ID     = @TEMP_TEAM_ID     
		     , FROM_NAME         = @FROM_NAME        
		     , FROM_ADDR         = @FROM_ADDR        
		     , FILTER_DOMAIN     = @FILTER_DOMAIN    
		     , MAILBOX_SSL       = @MAILBOX_SSL      
		     , IS_PERSONAL       = @IS_PERSONAL      
		     , REPLY_TO_ADDR     = @REPLY_TO_ADDR    
		     , REPLY_TO_NAME     = @REPLY_TO_NAME    
		 where ID                = @ID               ;
	end -- if;

	if not exists(select * from INBOUND_EMAILS_CSTM where ID_C = @ID) begin -- then
		insert into INBOUND_EMAILS_CSTM ( ID_C ) values ( @ID );
	end -- if;

  end
GO
 
Grant Execute on dbo.spINBOUND_EMAILS_Update to public;
GO

