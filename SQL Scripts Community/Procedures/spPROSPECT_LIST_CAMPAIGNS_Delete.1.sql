if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPROSPECT_LIST_CAMPAIGNS_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPROSPECT_LIST_CAMPAIGNS_Delete;
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
-- 12/15/2007 Paul.  When a prospect list is removed, also removed it from the email marketing lists. 
Create Procedure dbo.spPROSPECT_LIST_CAMPAIGNS_Delete
	( @MODIFIED_USER_ID uniqueidentifier
	, @PROSPECT_LIST_ID uniqueidentifier
	, @CAMPAIGN_ID      uniqueidentifier
	)
as
  begin
	set nocount on
	
	update PROSPECT_LIST_CAMPAIGNS
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = @MODIFIED_USER_ID
	 where PROSPECT_LIST_ID = @PROSPECT_LIST_ID
	   and CAMPAIGN_ID      = @CAMPAIGN_ID
	   and DELETED          = 0;

	-- 12/15/2007 Paul.  Although SQL Server supports the join syntax in an update statement, MySQL and Oracle do not. 
	-- 05/22/2008 Paul.  We need to use the in clause when using a sub query as more than one value may be returned. 
	update EMAIL_MARKETING_PROSPECT_LISTS
	   set DELETED            = 1
	     , DATE_MODIFIED      = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID   = @MODIFIED_USER_ID
	 where EMAIL_MARKETING_ID in (select ID from EMAIL_MARKETING where CAMPAIGN_ID = @CAMPAIGN_ID and DELETED = 0)
	   and PROSPECT_LIST_ID   = @PROSPECT_LIST_ID
	   and DELETED            = 0;
  end
GO

Grant Execute on dbo.spPROSPECT_LIST_CAMPAIGNS_Delete to public;
GO


