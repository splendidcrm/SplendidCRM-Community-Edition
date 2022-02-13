if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACCOUNTS_Undelete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACCOUNTS_Undelete;
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
Create Procedure dbo.spACCOUNTS_Undelete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @AUDIT_TOKEN      varchar(255)
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update ACCOUNTS_DOCUMENTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from ACCOUNTS_DOCUMENTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ACCOUNT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update ACCOUNTS_BUGS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from ACCOUNTS_BUGS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ACCOUNT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update ACCOUNTS_CASES
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from ACCOUNTS_CASES_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ACCOUNT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update ACCOUNTS_CONTACTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from ACCOUNTS_CONTACTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ACCOUNT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update ACCOUNTS_OPPORTUNITIES
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from ACCOUNTS_OPPORTUNITIES_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ACCOUNT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILS_ACCOUNTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAILS_ACCOUNTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ACCOUNT_ID = @ID);
	-- END Oracle Exception
	
	-- 08/07/2013 Paul.  Mapping the account back is a bit more difficult in that we need the previous case record. 
	-- First we use a group clause to get the previous record version number. 
	-- Then we get the previous record and make sure that the previous relationship ID matches. 
	-- We will not check the deleted flag in the main table because the record may have been deleted as part of the transaction 
	-- and it may be undeleted as part of the new transaction. 
	-- BEGIN Oracle Exception
		update CASES
		   set ACCOUNT_ID       = @ID
		     , ACCOUNT_NAME     = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       is null
		   and ID in (select CASES_AUDIT.ID
		                from      CASES_AUDIT
		               inner join (select CASES_AUDIT_PREVIOUS.ID, max(CASES_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      CASES_AUDIT                          CASES_AUDIT_CURRENT
		                            inner join CASES_AUDIT                          CASES_AUDIT_PREVIOUS
		                                    on CASES_AUDIT_PREVIOUS.ID            = CASES_AUDIT_CURRENT.ID
		                                   and CASES_AUDIT_PREVIOUS.AUDIT_VERSION < CASES_AUDIT_CURRENT.AUDIT_VERSION
		                                 where CASES_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by CASES_AUDIT_PREVIOUS.ID
		                          )                                        CASES_AUDIT_PREV_VERSION
		                       on CASES_AUDIT_PREV_VERSION.ID            = CASES_AUDIT.ID
		               inner join CASES_AUDIT                              CASES_AUDIT_PREV_ACCOUNT
		                       on CASES_AUDIT_PREV_ACCOUNT.ID            = CASES_AUDIT_PREV_VERSION.ID
		                      and CASES_AUDIT_PREV_ACCOUNT.AUDIT_VERSION = CASES_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and CASES_AUDIT_PREV_ACCOUNT.ACCOUNT_ID    = @ID
		                      and CASES_AUDIT_PREV_ACCOUNT.DELETED       = 0
		               where CASES_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update LEADS
		   set ACCOUNT_ID       = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       is null
		   and ID in (select LEADS_AUDIT.ID
		                from      LEADS_AUDIT
		               inner join (select LEADS_AUDIT_PREVIOUS.ID, max(LEADS_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      LEADS_AUDIT                          LEADS_AUDIT_CURRENT
		                            inner join LEADS_AUDIT                          LEADS_AUDIT_PREVIOUS
		                                    on LEADS_AUDIT_PREVIOUS.ID            = LEADS_AUDIT_CURRENT.ID
		                                   and LEADS_AUDIT_PREVIOUS.AUDIT_VERSION < LEADS_AUDIT_CURRENT.AUDIT_VERSION
		                                 where LEADS_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by LEADS_AUDIT_PREVIOUS.ID
		                          )                                        LEADS_AUDIT_PREV_VERSION
		                       on LEADS_AUDIT_PREV_VERSION.ID            = LEADS_AUDIT.ID
		               inner join LEADS_AUDIT                              LEADS_AUDIT_PREV_ACCOUNT
		                       on LEADS_AUDIT_PREV_ACCOUNT.ID            = LEADS_AUDIT_PREV_VERSION.ID
		                      and LEADS_AUDIT_PREV_ACCOUNT.AUDIT_VERSION = LEADS_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and LEADS_AUDIT_PREV_ACCOUNT.ACCOUNT_ID    = @ID
		                      and LEADS_AUDIT_PREV_ACCOUNT.DELETED       = 0
		               where LEADS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	exec dbo.spPARENT_Undelete @ID, @MODIFIED_USER_ID, @AUDIT_TOKEN, N'Accounts';
	
	-- BEGIN Oracle Exception
		update ACCOUNTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 1
		   and ID in (select ID from ACCOUNTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID);
	-- END Oracle Exception

  end
GO

Grant Execute on dbo.spACCOUNTS_Undelete to public;
GO

