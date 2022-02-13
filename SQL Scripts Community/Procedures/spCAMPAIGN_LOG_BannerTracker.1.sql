if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGN_LOG_BannerTracker' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGN_LOG_BannerTracker;
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
Create Procedure dbo.spCAMPAIGN_LOG_BannerTracker
	( @MODIFIED_USER_ID    uniqueidentifier
	, @ACTIVITY_TYPE       nvarchar(25)
	, @CAMPAIGN_TRKRS_ID   uniqueidentifier
	, @MORE_INFORMATION    nvarchar(100)
	)
as
  begin
	set nocount on
	
	declare @ID                 uniqueidentifier;
	declare @TARGET_TRACKER_KEY uniqueidentifier;
	declare @CAMPAIGN_ID        uniqueidentifier;
	declare @RELATED_ID         uniqueidentifier;
	declare @RELATED_TYPE       nvarchar(25);
	declare @TARGET_ID          uniqueidentifier;
	declare @TARGET_TYPE        nvarchar(25);
	declare @LIST_ID            uniqueidentifier;
	declare @MARKETING_ID       uniqueidentifier;

	-- 09/10/2007 Paul.  For banners, attempt to count hits by storing the REMOTE_ADDR. 
	-- BEGIN Oracle Exception
		select @ID              = ID
		  from CAMPAIGN_LOG
		 where RELATED_ID       = @CAMPAIGN_TRKRS_ID
		   and RELATED_TYPE     = N'CampaignTrackers'
		   and ACTIVITY_TYPE    = @ACTIVITY_TYPE
		   and MORE_INFORMATION = @MORE_INFORMATION;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		-- BEGIN Oracle Exception
			select @CAMPAIGN_ID = CAMPAIGN_ID
			  from CAMPAIGN_TRKRS
			 where ID = @CAMPAIGN_TRKRS_ID;
		-- END Oracle Exception
		
		if dbo.fnIsEmptyGuid(@CAMPAIGN_ID) = 0 begin -- then
			set @ID                 = newid();
			set @TARGET_TRACKER_KEY = newid();
			set @RELATED_ID         = @CAMPAIGN_TRKRS_ID;
			set @RELATED_TYPE       = N'CampaignTrackers';
			set @TARGET_ID          = newid();
			set @TARGET_TYPE        = N'Prospects';
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
				, @CAMPAIGN_TRKRS_ID  -- @RELATED_ID         
				, @RELATED_TYPE       
				, 1                   
				, @MORE_INFORMATION   
				);
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
 
Grant Execute on dbo.spCAMPAIGN_LOG_BannerTracker to public;
GO
 
