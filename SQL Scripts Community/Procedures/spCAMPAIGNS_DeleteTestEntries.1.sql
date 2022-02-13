if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGNS_DeleteTestEntries' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGNS_DeleteTestEntries;
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
Create Procedure dbo.spCAMPAIGNS_DeleteTestEntries
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	-- 01/26/2008 Paul.  Oracle does not allow the join syntax in a delete statement. 
	update EMAILS
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = @MODIFIED_USER_ID
	 where DELETED          = 0
	   and ID in (select CAMPAIGN_LOG.RELATED_ID
	                from      CAMPAIGN_LOG
	               inner join PROSPECT_LIST_CAMPAIGNS
	                       on PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID      = CAMPAIGN_LOG.CAMPAIGN_ID
	                      and PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID = CAMPAIGN_LOG.LIST_ID
	                      and PROSPECT_LIST_CAMPAIGNS.DELETED          = 0
	               inner join PROSPECT_LISTS
	                       on PROSPECT_LISTS.ID                        = PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID
	                      and PROSPECT_LISTS.LIST_TYPE                 = N'test'
	                      and PROSPECT_LISTS.DELETED                   = 0
	               where CAMPAIGN_LOG.CAMPAIGN_ID  = @ID
	                 and CAMPAIGN_LOG.DELETED      = 0
	                 and CAMPAIGN_LOG.RELATED_TYPE = N'Emails');
	
	delete from EMAILMAN
	 where ID in (select EMAILMAN.ID
	                from      EMAILMAN
	               inner join PROSPECT_LIST_CAMPAIGNS
	                       on PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID      = EMAILMAN.CAMPAIGN_ID
	                      and PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID = EMAILMAN.LIST_ID
	                      and PROSPECT_LIST_CAMPAIGNS.DELETED          = 0
	               inner join PROSPECT_LISTS
	                       on PROSPECT_LISTS.ID                        = PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID
	                      and PROSPECT_LISTS.LIST_TYPE                 = N'test'
	                      and PROSPECT_LISTS.DELETED                   = 0
	               where EMAILMAN.CAMPAIGN_ID  = @ID);

	update CAMPAIGN_LOG
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = @MODIFIED_USER_ID
	 where DELETED          = 0
	   and ID in (select CAMPAIGN_LOG.ID
	                from      CAMPAIGN_LOG
	               inner join PROSPECT_LIST_CAMPAIGNS
	                       on PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID      = CAMPAIGN_LOG.CAMPAIGN_ID
	                      and PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID = CAMPAIGN_LOG.LIST_ID
	                      and PROSPECT_LIST_CAMPAIGNS.DELETED          = 0
	               inner join PROSPECT_LISTS
	                       on PROSPECT_LISTS.ID                        = PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID
	                      and PROSPECT_LISTS.LIST_TYPE                 = N'test'
	                      and PROSPECT_LISTS.DELETED                   = 0
	               where CAMPAIGN_LOG.CAMPAIGN_ID  = @ID
	                 and CAMPAIGN_LOG.DELETED      = 0);
  end
GO

Grant Execute on dbo.spCAMPAIGNS_DeleteTestEntries to public;
GO

