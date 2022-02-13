if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCONTACTS_Undelete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCONTACTS_Undelete;
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
Create Procedure dbo.spCONTACTS_Undelete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @AUDIT_TOKEN      varchar(255)
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update CONTACTS_DOCUMENTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CONTACT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from CONTACTS_DOCUMENTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CONTACT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update ACCOUNTS_CONTACTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CONTACT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from ACCOUNTS_CONTACTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CONTACT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CALLS_CONTACTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CONTACT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from CALLS_CONTACTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CONTACT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CONTACTS_BUGS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CONTACT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from CONTACTS_BUGS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CONTACT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CONTACTS_CASES
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CONTACT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from CONTACTS_CASES_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CONTACT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update CONTACTS_USERS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CONTACT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from CONTACTS_USERS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CONTACT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILS_CONTACTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CONTACT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from EMAILS_CONTACTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CONTACT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update MEETINGS_CONTACTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CONTACT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from MEETINGS_CONTACTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CONTACT_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update OPPORTUNITIES_CONTACTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CONTACT_ID       = @ID
		   and DELETED          = 1
		   and ID in (select ID from OPPORTUNITIES_CONTACTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CONTACT_ID = @ID);
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
		update LEADS
		   set CONTACT_ID       = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CONTACT_ID       is null
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
		                      and LEADS_AUDIT_PREV_ACCOUNT.CONTACT_ID    = @ID 
		                      and LEADS_AUDIT_PREV_ACCOUNT.DELETED       = 0
		               where LEADS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update NOTES
		   set CONTACT_ID       = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CONTACT_ID       is null
		   and ID in (select NOTES_AUDIT.ID
		                from      NOTES_AUDIT
		               inner join (select NOTES_AUDIT_PREVIOUS.ID, max(NOTES_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      NOTES_AUDIT                          NOTES_AUDIT_CURRENT
		                            inner join NOTES_AUDIT                          NOTES_AUDIT_PREVIOUS
		                                    on NOTES_AUDIT_PREVIOUS.ID            = NOTES_AUDIT_CURRENT.ID
		                                   and NOTES_AUDIT_PREVIOUS.AUDIT_VERSION < NOTES_AUDIT_CURRENT.AUDIT_VERSION
		                                 where NOTES_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by NOTES_AUDIT_PREVIOUS.ID
		                          )                                        NOTES_AUDIT_PREV_VERSION
		                       on NOTES_AUDIT_PREV_VERSION.ID            = NOTES_AUDIT.ID
		               inner join NOTES_AUDIT                              NOTES_AUDIT_PREV_ACCOUNT
		                       on NOTES_AUDIT_PREV_ACCOUNT.ID            = NOTES_AUDIT_PREV_VERSION.ID
		                      and NOTES_AUDIT_PREV_ACCOUNT.AUDIT_VERSION = NOTES_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and NOTES_AUDIT_PREV_ACCOUNT.CONTACT_ID    = @ID 
		                      and NOTES_AUDIT_PREV_ACCOUNT.DELETED       = 0
		               where NOTES_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update TASKS
		   set CONTACT_ID       = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CONTACT_ID       is null
		   and ID in (select TASKS_AUDIT.ID
		                from      TASKS_AUDIT
		               inner join (select TASKS_AUDIT_PREVIOUS.ID, max(TASKS_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      TASKS_AUDIT                          TASKS_AUDIT_CURRENT
		                            inner join TASKS_AUDIT                          TASKS_AUDIT_PREVIOUS
		                                    on TASKS_AUDIT_PREVIOUS.ID            = TASKS_AUDIT_CURRENT.ID
		                                   and TASKS_AUDIT_PREVIOUS.AUDIT_VERSION < TASKS_AUDIT_CURRENT.AUDIT_VERSION
		                                 where TASKS_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by TASKS_AUDIT_PREVIOUS.ID
		                          )                                        TASKS_AUDIT_PREV_VERSION
		                       on TASKS_AUDIT_PREV_VERSION.ID            = TASKS_AUDIT.ID
		               inner join TASKS_AUDIT                              TASKS_AUDIT_PREV_ACCOUNT
		                       on TASKS_AUDIT_PREV_ACCOUNT.ID            = TASKS_AUDIT_PREV_VERSION.ID
		                      and TASKS_AUDIT_PREV_ACCOUNT.AUDIT_VERSION = TASKS_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and TASKS_AUDIT_PREV_ACCOUNT.CONTACT_ID    = @ID 
		                      and TASKS_AUDIT_PREV_ACCOUNT.DELETED       = 0
		               where TASKS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	exec dbo.spPARENT_Undelete @ID, @MODIFIED_USER_ID, @AUDIT_TOKEN, N'Contacts';
	
	-- BEGIN Oracle Exception
		update CONTACTS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 1
		   and ID in (select ID from CONTACTS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID);
	-- END Oracle Exception
	
  end
GO

Grant Execute on dbo.spCONTACTS_Undelete to public;
GO

