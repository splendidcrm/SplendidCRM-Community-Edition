if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spLEADS_Undelete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spLEADS_Undelete;
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
Create Procedure dbo.spLEADS_Undelete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @AUDIT_TOKEN      varchar(255)
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update LEADS_DOCUMENTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where LEAD_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from LEADS_DOCUMENTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and LEAD_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update PROSPECT_LISTS_PROSPECTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where RELATED_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from PROSPECT_LISTS_PROSPECTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and RELATED_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CALLS_LEADS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where LEAD_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from CALLS_LEADS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and LEAD_ID = @ID);
	-- END Oracle Exception

	-- BEGIN Oracle Exception
		update MEETINGS_LEADS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where LEAD_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from MEETINGS_LEADS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and LEAD_ID = @ID);
	-- END Oracle Exception

	-- BEGIN Oracle Exception
		update LEADS_USERS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where LEAD_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from LEADS_USERS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and LEAD_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILS_LEADS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where LEAD_ID          = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAILS_LEADS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and LEAD_ID = @ID);
	-- END Oracle Exception
	
	exec dbo.spPARENT_Undelete @ID, @MODIFIED_USER_ID, @AUDIT_TOKEN, N'Leads';
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update LEADS_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from LEADS
			  where ID               = @ID
			    and DELETED          = 1
			    and ID in (select ID from LEADS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID)
			);
		update LEADS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 1
		   and ID in (select ID from LEADS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID);
	-- END Oracle Exception
	
  end
GO

Grant Execute on dbo.spLEADS_Undelete to public;
GO

