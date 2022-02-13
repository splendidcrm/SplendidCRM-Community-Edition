if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSMS_MESSAGES_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSMS_MESSAGES_Update;
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
-- 05/17/2017 Paul.  Add Tags module. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spSMS_MESSAGES_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @TEAM_ID           uniqueidentifier
	, @TEAM_SET_LIST     varchar(8000)
	, @MAILBOX_ID        uniqueidentifier
	, @NAME              nvarchar(1600)
	, @DATE_TIME         datetime
	, @PARENT_TYPE       nvarchar(25)
	, @PARENT_ID         uniqueidentifier
	, @FROM_NUMBER       nvarchar(20)
	, @TO_NUMBER         nvarchar(20)
	, @TO_ID             uniqueidentifier
	, @TYPE              nvarchar(25)
	, @MESSAGE_SID       nvarchar(100)
	, @FROM_LOCATION     nvarchar(100)
	, @TO_LOCATION       nvarchar(100)
	, @TAG_SET_NAME      nvarchar(4000) = null
	, @IS_PRIVATE        bit = null
	, @ASSIGNED_SET_LIST varchar(8000) = null
	)
as
  begin
	set nocount on
	
	declare @TEAM_SET_ID uniqueidentifier;
	declare @ASSIGNED_SET_ID     uniqueidentifier;
	declare @STATUS      nvarchar(25);
	declare @DATE_START  datetime;
	declare @TIME_START  datetime;
	set @DATE_START = dbo.fnStoreDateOnly(@DATE_TIME);
	set @TIME_START = dbo.fnStoreTimeOnly(@DATE_TIME);

	-- 09/26/2013 Paul.  Just in case the TwiML event is fired more than once for the same message, do a lookup. 
	if @ID is null and @MESSAGE_SID is not null begin -- then
	-- BEGIN Oracle Exception
		select @ID = ID
		  from SMS_MESSAGES
		 where MESSAGE_SID = @MESSAGE_SID 
		   and DELETED = 0;
	-- END Oracle Exception
	end -- if;
	
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;
	
	if not exists(select * from SMS_MESSAGES where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		if @TYPE is null or @TYPE = N'' begin -- then
			set @TYPE = N'draft';
		end -- if;
		if @TYPE = N'archived' begin -- then
			set @STATUS = N'sent';
		end else if @TYPE = N'inbound' begin -- then
			set @STATUS = N'received';
		end else begin
			set @STATUS = N'draft';
		end -- if;
		insert into SMS_MESSAGES
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, DATE_MODIFIED_UTC 
			, ASSIGNED_USER_ID  
			, TEAM_ID           
			, TEAM_SET_ID       
			, MAILBOX_ID        
			, NAME              
			, DATE_START        
			, TIME_START        
			, PARENT_TYPE       
			, PARENT_ID         
			, FROM_NUMBER       
			, TO_NUMBER         
			, TO_ID             
			, TYPE              
			, STATUS            
			, MESSAGE_SID       
			, FROM_LOCATION     
			, TO_LOCATION       
			, IS_PRIVATE        
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
			, @TEAM_ID           
			, @TEAM_SET_ID       
			, @MAILBOX_ID        
			, @NAME              
			, @DATE_START        
			, @TIME_START        
			, @PARENT_TYPE       
			, @PARENT_ID         
			, @FROM_NUMBER       
			, @TO_NUMBER         
			, @TO_ID             
			, @TYPE              
			, @STATUS            
			, @MESSAGE_SID       
			, @FROM_LOCATION     
			, @TO_LOCATION       
			, @IS_PRIVATE        
			, @ASSIGNED_SET_ID   
			);
	end else begin
		update SMS_MESSAGES
		   set MODIFIED_USER_ID   = @MODIFIED_USER_ID  
		     , DATE_MODIFIED      =  getdate()         
		     , DATE_MODIFIED_UTC  =  getutcdate()      
		     , ASSIGNED_USER_ID   = @ASSIGNED_USER_ID  
		     , TEAM_ID            = @TEAM_ID           
		     , TEAM_SET_ID        = @TEAM_SET_ID       
		     , MAILBOX_ID         = @MAILBOX_ID        
		     , NAME               = @NAME              
		     , DATE_START         = @DATE_START        
		     , TIME_START         = @TIME_START        
		     , PARENT_TYPE        = @PARENT_TYPE       
		     , PARENT_ID          = @PARENT_ID         
		     , FROM_NUMBER        = @FROM_NUMBER       
		     , TO_NUMBER          = @TO_NUMBER         
		     , TO_ID              = @TO_ID             
		     , TYPE               = @TYPE              -- 09/21/2013 Paul.  Update type, but not status. 
		     , MESSAGE_SID        = @MESSAGE_SID       
		     , FROM_LOCATION      = @FROM_LOCATION     
		     , TO_LOCATION        = @TO_LOCATION       
		     , IS_PRIVATE         = @IS_PRIVATE        
		     , ASSIGNED_SET_ID    = @ASSIGNED_SET_ID   
		 where ID                 = @ID                ;
		
		exec dbo.spSUGARFAVORITES_UpdateName @MODIFIED_USER_ID, @ID, @NAME;
	end -- if;

	if @@ERROR = 0 begin -- then
		if not exists(select * from SMS_MESSAGES_CSTM where ID_C = @ID) begin -- then
			insert into SMS_MESSAGES_CSTM ( ID_C ) values ( @ID );
		end -- if;
	end -- if;

	if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
		exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @PARENT_ID, @PARENT_TYPE;
	end -- if;
	-- 05/17/2017 Paul.  Add Tags module. Must add after @ID is set. 
	if @@ERROR = 0 begin -- then
		exec dbo.spTAG_SETS_NormalizeSet @MODIFIED_USER_ID, @ID, N'SmsMessages', @TAG_SET_NAME;
	end -- if;
  end
GO

Grant Execute on dbo.spSMS_MESSAGES_Update to public;
GO

