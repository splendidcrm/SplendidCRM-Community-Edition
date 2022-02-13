if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spLEADS_Merge' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spLEADS_Merge;
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
-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
Create Procedure dbo.spLEADS_Merge
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @MERGE_ID         uniqueidentifier
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update PROSPECT_LISTS_PROSPECTS
		   set RELATED_ID       = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where RELATED_ID       = @MERGE_ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
	-- BEGIN Oracle Exception
		update CALLS_LEADS
		   set LEAD_ID          = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where LEAD_ID          = @MERGE_ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- 04/01/2012 Paul.  Add Meetings/Leads relationship. 
	-- BEGIN Oracle Exception
		update MEETINGS_LEADS
		   set LEAD_ID          = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where LEAD_ID          = @MERGE_ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- 04/01/2012 Paul.  Add Emails/Leads relationship. 
	-- BEGIN Oracle Exception
		update EMAILS_LEADS
		   set LEAD_ID          = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where LEAD_ID          = @MERGE_ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- 04/01/2012 Paul.  Add Users/Leads relationship. 
	-- BEGIN Oracle Exception
		update LEADS_USERS
		   set LEAD_ID          = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where LEAD_ID          = @MERGE_ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	exec dbo.spPARENT_Merge @ID, @MODIFIED_USER_ID, @MERGE_ID;
	
	exec dbo.spLEADS_Delete @MERGE_ID, @MODIFIED_USER_ID;
  end
GO

Grant Execute on dbo.spLEADS_Merge to public;
GO

