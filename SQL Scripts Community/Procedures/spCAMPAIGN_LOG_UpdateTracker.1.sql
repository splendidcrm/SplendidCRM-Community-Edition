if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGN_LOG_UpdateTracker' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGN_LOG_UpdateTracker;
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
Create Procedure dbo.spCAMPAIGN_LOG_UpdateTracker
	( @MODIFIED_USER_ID    uniqueidentifier
	, @TARGET_TRACKER_KEY  uniqueidentifier
	, @ACTIVITY_TYPE       nvarchar(25)
	, @CAMPAIGN_TRKRS_ID   uniqueidentifier
	, @TARGET_ID           uniqueidentifier output
	, @TARGET_TYPE         nvarchar(25) output
	)
as
  begin
	set nocount on
	
	declare @ID               uniqueidentifier;
	declare @CAMPAIGN_ID      uniqueidentifier;
	declare @RELATED_ID       uniqueidentifier;
	declare @RELATED_TYPE     nvarchar(25);
	declare @LIST_ID          uniqueidentifier;
	declare @MARKETING_ID     uniqueidentifier;
	declare @MORE_INFORMATION nvarchar(100);
	-- BEGIN Oracle Exception
		select @ID                = ID
		     , @TARGET_ID         = TARGET_ID
		     , @TARGET_TYPE       = TARGET_TYPE
		  from CAMPAIGN_LOG
		 where TARGET_TRACKER_KEY = @TARGET_TRACKER_KEY
		   and ACTIVITY_TYPE      = @ACTIVITY_TYPE
		   and (@CAMPAIGN_TRKRS_ID is null or RELATED_ID = @CAMPAIGN_TRKRS_ID);
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @RELATED_ID   = null;
		set @RELATED_TYPE = null;
		-- BEGIN Oracle Exception
			select @ID                = ID
			     , @CAMPAIGN_ID       = CAMPAIGN_ID
			     , @TARGET_ID         = TARGET_ID
			     , @TARGET_TYPE       = TARGET_TYPE
			     , @RELATED_ID        = RELATED_ID
			     , @RELATED_TYPE      = RELATED_TYPE
			     , @LIST_ID           = LIST_ID
			     , @MARKETING_ID      = MARKETING_ID
			     , @MORE_INFORMATION  = MORE_INFORMATION
			  from CAMPAIGN_LOG
			 where TARGET_TRACKER_KEY = @TARGET_TRACKER_KEY
			   and ACTIVITY_TYPE      = N'targeted';
		-- END Oracle Exception
		
		-- 09/10/2007 Paul.  Users cannot remove themselves because the Users table does not have an opt out column. 
		if dbo.fnIsEmptyGuid(@ID) = 0 and (@TARGET_TYPE <> N'users' or @ACTIVITY_TYPE <> 'removed') begin -- then
			if @CAMPAIGN_TRKRS_ID is not null begin -- then
				set @RELATED_ID   = @CAMPAIGN_TRKRS_ID;
				set @RELATED_TYPE = N'CampaignTrackers';
			end -- if;
			set @ID = newid();
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
				, HITS               
				, LIST_ID            
				, MARKETING_ID       
				, MORE_INFORMATION   
				)
			values 	( @ID                 
				, @MODIFIED_USER_ID         
				,  getdate()          
				, @MODIFIED_USER_ID   
				,  getdate()          
				, @CAMPAIGN_ID        
				, @TARGET_TRACKER_KEY 
				, @TARGET_ID          
				, @TARGET_TYPE        
				, @ACTIVITY_TYPE      
				,  getdate()          
				, @RELATED_ID         
				, @RELATED_TYPE       
				, 1               
				, @LIST_ID            
				, @MARKETING_ID       
				, @MORE_INFORMATION   
				);
		end -- if;
		-- 01/21/2008 Paul.  If we get an email bounce, then go back and mark the email as an error. 
		if dbo.fnIsEmptyGuid(@RELATED_ID) = 0 and @RELATED_TYPE = N'Emails' and (@ACTIVITY_TYPE = N'invalid email' or @ACTIVITY_TYPE = N'send error') begin -- then
			-- 01/21/2008 Paul.  Lets not update MODIFIED_USER_ID as it will almost always be null. 
			update EMAILS
			   set STATUS           = @ACTIVITY_TYPE
			     , DATE_MODIFIED    = getdate()
			     , DATE_MODIFIED_UTC= getutcdate()
			 where ID               = @RELATED_ID
			   and STATUS           = N'sent'
			   and DELETED          = 0;
		end -- if;

		-- 06/12/2009 Paul.  We want to allow workflow emails to have an opt-out. 
		-- Workflow events will use the ID of the record. 
		if dbo.fnIsEmptyGuid(@TARGET_ID) = 1 begin -- then
			select @TARGET_ID         = PARENT_ID
			     , @TARGET_TYPE       = PARENT_TYPE
			  from vwPARENTS_EMAIL_ADDRESS
			 where PARENT_ID          = @TARGET_TRACKER_KEY;
		end -- if;
	end else begin
		update CAMPAIGN_LOG
		   set MODIFIED_USER_ID    = @MODIFIED_USER_ID 
		     , DATE_MODIFIED       =  getdate()        
		     , DATE_MODIFIED_UTC   =  getutcdate()     
		     , HITS                = HITS + 1          
		 where ID                  = @ID               ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spCAMPAIGN_LOG_UpdateTracker to public;
GO
 
