if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCHAT_MESSAGES_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCHAT_MESSAGES_Update;
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
Create Procedure dbo.spCHAT_MESSAGES_Update
	( @ID                 uniqueidentifier output
	, @MODIFIED_USER_ID   uniqueidentifier
	, @CHAT_CHANNEL_ID    uniqueidentifier
	, @NAME               nvarchar(400)
	, @PARENT_ID          uniqueidentifier
	, @PARENT_TYPE        nvarchar(25)
	, @NOTE_ATTACHMENT_ID uniqueidentifier
	, @DESCRIPTION        nvarchar(max)
	, @TAG_SET_NAME       nvarchar(4000) = null
	, @IS_PRIVATE         bit = null
	)
as
  begin
	set nocount on
	
	declare @TEMP_NAME nvarchar(400);
	set @TEMP_NAME = @NAME;
	if @TEMP_NAME is null begin -- then
		set @TEMP_NAME = substring(@DESCRIPTION, 1, 400);
	end -- if;
	if not exists(select * from CHAT_MESSAGES where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into CHAT_MESSAGES
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, DATE_MODIFIED_UTC 
			, CHAT_CHANNEL_ID   
			, NAME              
			, PARENT_ID         
			, PARENT_TYPE       
			, NOTE_ATTACHMENT_ID
			, DESCRIPTION       
			, IS_PRIVATE         
			)
		values 	( @ID                
			, @MODIFIED_USER_ID  
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			,  getutcdate()      
			, @CHAT_CHANNEL_ID   
			, @TEMP_NAME         
			, @PARENT_ID         
			, @PARENT_TYPE       
			, @NOTE_ATTACHMENT_ID
			, @DESCRIPTION       
			, @IS_PRIVATE         
			);
	end else begin
		update CHAT_MESSAGES
		   set MODIFIED_USER_ID   = @MODIFIED_USER_ID  
		     , DATE_MODIFIED      =  getdate()         
		     , DATE_MODIFIED_UTC  =  getutcdate()      
		     , NAME               = @TEMP_NAME         
		     , PARENT_ID          = @PARENT_ID         
		     , PARENT_TYPE        = @PARENT_TYPE       
		     , NOTE_ATTACHMENT_ID = isnull(@NOTE_ATTACHMENT_ID, NOTE_ATTACHMENT_ID)
		     , DESCRIPTION        = @DESCRIPTION       
		     , IS_PRIVATE         = @IS_PRIVATE        
		 where ID                 = @ID                ;
		
		exec dbo.spSUGARFAVORITES_UpdateName @MODIFIED_USER_ID, @ID, @NAME;
	end -- if;
	-- 05/17/2017 Paul.  Add Tags module. Must add after @ID is set. 
	if @@ERROR = 0 begin -- then
		exec dbo.spTAG_SETS_NormalizeSet @MODIFIED_USER_ID, @ID, N'ChatMessages', @TAG_SET_NAME;
	end -- if;
  end
GO

Grant Execute on dbo.spCHAT_MESSAGES_Update to public;
GO

