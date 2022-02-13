if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spLEADS_InsRelated' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spLEADS_InsRelated;
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
-- 05/11/2010 Paul.  The Opportunity is a member of the LEADS table. 
-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
Create Procedure dbo.spLEADS_InsRelated
	( @MODIFIED_USER_ID  uniqueidentifier
	, @LEAD_ID           uniqueidentifier
	, @PARENT_TYPE       nvarchar(25)
	, @PARENT_ID         uniqueidentifier
	)
as
  begin
	set nocount on
	
	if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
		if @PARENT_TYPE = N'Emails' begin -- then
			exec dbo.spEMAILS_LEADS_Update         @MODIFIED_USER_ID, @PARENT_ID, @LEAD_ID;
		end else if @PARENT_TYPE = N'ProspectLists' begin -- then
			exec dbo.spPROSPECT_LISTS_LEADS_Update @MODIFIED_USER_ID, @PARENT_ID, @LEAD_ID;
		end else if @PARENT_TYPE = N'Opportunities' begin -- then
			-- 05/11/2010 Paul.  The Opportunity is a member of the LEADS table. 
			update LEADS
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID
			     , DATE_MODIFIED     =  getdate()       
			     , DATE_MODIFIED_UTC =  getutcdate()    
			     , OPPORTUNITY_ID    = @PARENT_ID       
			 where ID                = @LEAD_ID         ;
		-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
		end else if @PARENT_TYPE = N'Calls' begin -- then
			exec dbo.spCALLS_LEADS_Update          @MODIFIED_USER_ID, @PARENT_ID , @LEAD_ID, null, null;
		-- 04/01/2012 Paul.  Add Meetings/Leads relationship. 
		end else if @PARENT_TYPE = N'Meetings' begin -- then
			exec dbo.spMEETINGS_LEADS_Update       @MODIFIED_USER_ID, @PARENT_ID , @LEAD_ID, null, null;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spLEADS_InsRelated to public;
GO

