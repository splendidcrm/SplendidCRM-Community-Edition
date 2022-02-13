if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILMAN_SendSuccessful' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILMAN_SendSuccessful;
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
-- 01/13/2008 Paul.  The email manager is also being used for AutoReplies, so the campaign might not exist. 
Create Procedure dbo.spEMAILMAN_SendSuccessful
	( @ID                  uniqueidentifier
	, @MODIFIED_USER_ID    uniqueidentifier
	, @TARGET_TRACKER_KEY  uniqueidentifier
	, @EMAIL_ID            uniqueidentifier
	)
as
  begin
	set nocount on
	
	if exists(select * from vwEMAILMAN_List where ID = @ID) begin -- then
		insert into CAMPAIGN_LOG
			( ID                 
			, CREATED_BY         
			, DATE_ENTERED       
			, MODIFIED_USER_ID   
			, DATE_MODIFIED      
			, CAMPAIGN_ID        
			, TARGET_TRACKER_KEY 
			, TARGET_ID          
			, TARGET_TYPE        
			, ACTIVITY_TYPE      
			, ACTIVITY_DATE      
			, RELATED_ID         
			, RELATED_TYPE       
			, MARKETING_ID       
			, LIST_ID            
			, MORE_INFORMATION   
			)
		select	   newid()            
			, @MODIFIED_USER_ID   
			,  getdate()          
			, @MODIFIED_USER_ID   
			,  getdate()          
			,  CAMPAIGN_ID        
			, @TARGET_TRACKER_KEY 
			,  RELATED_ID         
			,  RELATED_TYPE       
			,  N'targeted'        
			,  getdate()          
			, @EMAIL_ID           
			,  N'Emails'          
			,  MARKETING_ID       
			,  LIST_ID            
			,  RECIPIENT_EMAIL    
		  from vwEMAILMAN_List
		 where ID = @ID
		   and CAMPAIGN_ID is not null;
		
		exec dbo.spEMAILMAN_Delete @ID, @MODIFIED_USER_ID;
	end -- if;
  end
GO

Grant Execute on dbo.spEMAILMAN_SendSuccessful to public;
GO

