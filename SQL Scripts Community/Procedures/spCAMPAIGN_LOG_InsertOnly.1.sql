if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGN_LOG_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGN_LOG_InsertOnly;
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
-- 12/20/2007 Paul.  We need to set the activity date. 
Create Procedure dbo.spCAMPAIGN_LOG_InsertOnly
	( @MODIFIED_USER_ID    uniqueidentifier
	, @CAMPAIGN_ID         uniqueidentifier
	, @TARGET_TRACKER_KEY  uniqueidentifier
	, @TARGET_ID           uniqueidentifier
	, @TARGET_TYPE         nvarchar(25)
	, @ACTIVITY_TYPE       nvarchar(25)
	, @RELATED_ID          uniqueidentifier
	, @RELATED_TYPE        nvarchar(25)
	, @MARKETING_ID        uniqueidentifier
	, @LIST_ID             uniqueidentifier
	, @MORE_INFORMATION    nvarchar(100)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
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
		, MARKETING_ID       
		, LIST_ID            
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
		, @MARKETING_ID       
		, @LIST_ID            
		, @MORE_INFORMATION   
		);
  end
GO
 
Grant Execute on dbo.spCAMPAIGN_LOG_InsertOnly to public;
GO
 
