if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACCOUNTS_Merge' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACCOUNTS_Merge;
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
-- 09/11/2010 Paul.  Update UTC date. 
Create Procedure dbo.spACCOUNTS_Merge
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @MERGE_ID         uniqueidentifier
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update ACCOUNTS_BUGS
		   set ACCOUNT_ID       = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @MERGE_ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update ACCOUNTS_CASES
		   set ACCOUNT_ID       = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @MERGE_ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update ACCOUNTS_CONTACTS
		   set ACCOUNT_ID       = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @MERGE_ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update ACCOUNTS_OPPORTUNITIES
		   set ACCOUNT_ID       = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @MERGE_ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILS_ACCOUNTS
		   set ACCOUNT_ID       = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @MERGE_ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CASES
		   set ACCOUNT_ID       = @ID
		     , ACCOUNT_NAME     = (select NAME from ACCOUNTS where ID = @ID)
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @MERGE_ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update LEADS
		   set ACCOUNT_ID       = @ID
		     , ACCOUNT_NAME     = (select NAME from ACCOUNTS where ID = @ID)
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @MERGE_ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	exec dbo.spPARENT_Merge @ID, @MODIFIED_USER_ID, @MERGE_ID;
	
	exec dbo.spACCOUNTS_Delete @MERGE_ID, @MODIFIED_USER_ID;
  end
GO

Grant Execute on dbo.spACCOUNTS_Merge to public;
GO

