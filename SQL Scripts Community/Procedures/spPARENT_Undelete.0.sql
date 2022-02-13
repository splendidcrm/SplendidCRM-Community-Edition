if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPARENT_Undelete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPARENT_Undelete;
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
-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
Create Procedure dbo.spPARENT_Undelete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @AUDIT_TOKEN      varchar(255)
	, @PARENT_TYPE      nvarchar(25)
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update ACCOUNTS_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from ACCOUNTS
			 where PARENT_ID        is null
			   and ID in (select ACCOUNTS_AUDIT.ID
			                from      ACCOUNTS_AUDIT
			               inner join (select ACCOUNTS_AUDIT_PREVIOUS.ID, max(ACCOUNTS_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
			                             from      ACCOUNTS_AUDIT                          ACCOUNTS_AUDIT_CURRENT
			                            inner join ACCOUNTS_AUDIT                          ACCOUNTS_AUDIT_PREVIOUS
			                                    on ACCOUNTS_AUDIT_PREVIOUS.ID            = ACCOUNTS_AUDIT_CURRENT.ID
			                                   and ACCOUNTS_AUDIT_PREVIOUS.AUDIT_VERSION < ACCOUNTS_AUDIT_CURRENT.AUDIT_VERSION
			                                 where ACCOUNTS_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
			                                 group by ACCOUNTS_AUDIT_PREVIOUS.ID
			                          )                                       ACCOUNTS_AUDIT_PREV_VERSION
			                       on ACCOUNTS_AUDIT_PREV_VERSION.ID           = ACCOUNTS_AUDIT.ID
			               inner join ACCOUNTS_AUDIT                             ACCOUNTS_AUDIT_PREV_PARENT
			                       on ACCOUNTS_AUDIT_PREV_PARENT.ID            = ACCOUNTS_AUDIT_PREV_VERSION.ID
			                      and ACCOUNTS_AUDIT_PREV_PARENT.AUDIT_VERSION = ACCOUNTS_AUDIT_PREV_VERSION.AUDIT_VERSION
			                      and ACCOUNTS_AUDIT_PREV_PARENT.PARENT_ID    = @ID 
			                      and ACCOUNTS_AUDIT_PREV_PARENT.DELETED      = 0
			               where ACCOUNTS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
			             )
			);

		update ACCOUNTS
		   set PARENT_ID        = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        is null
		   and ID in (select ACCOUNTS_AUDIT.ID
		                from      ACCOUNTS_AUDIT
		               inner join (select ACCOUNTS_AUDIT_PREVIOUS.ID, max(ACCOUNTS_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      ACCOUNTS_AUDIT                          ACCOUNTS_AUDIT_CURRENT
		                            inner join ACCOUNTS_AUDIT                          ACCOUNTS_AUDIT_PREVIOUS
		                                    on ACCOUNTS_AUDIT_PREVIOUS.ID            = ACCOUNTS_AUDIT_CURRENT.ID
		                                   and ACCOUNTS_AUDIT_PREVIOUS.AUDIT_VERSION < ACCOUNTS_AUDIT_CURRENT.AUDIT_VERSION
		                                 where ACCOUNTS_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by ACCOUNTS_AUDIT_PREVIOUS.ID
		                          )                                       ACCOUNTS_AUDIT_PREV_VERSION
		                       on ACCOUNTS_AUDIT_PREV_VERSION.ID           = ACCOUNTS_AUDIT.ID
		               inner join ACCOUNTS_AUDIT                             ACCOUNTS_AUDIT_PREV_PARENT
		                       on ACCOUNTS_AUDIT_PREV_PARENT.ID            = ACCOUNTS_AUDIT_PREV_VERSION.ID
		                      and ACCOUNTS_AUDIT_PREV_PARENT.AUDIT_VERSION = ACCOUNTS_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and ACCOUNTS_AUDIT_PREV_PARENT.PARENT_ID    = @ID 
		                      and ACCOUNTS_AUDIT_PREV_PARENT.DELETED      = 0
		               where ACCOUNTS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update CALLS_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from CALLS
			 where PARENT_ID        is null
			   and ID in (select CALLS_AUDIT.ID
			                from      CALLS_AUDIT
			               inner join (select CALLS_AUDIT_PREVIOUS.ID, max(CALLS_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
			                             from      CALLS_AUDIT                          CALLS_AUDIT_CURRENT
			                            inner join CALLS_AUDIT                          CALLS_AUDIT_PREVIOUS
			                                    on CALLS_AUDIT_PREVIOUS.ID            = CALLS_AUDIT_CURRENT.ID
			                                   and CALLS_AUDIT_PREVIOUS.AUDIT_VERSION < CALLS_AUDIT_CURRENT.AUDIT_VERSION
			                                 where CALLS_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
			                                 group by CALLS_AUDIT_PREVIOUS.ID
			                          )                                       CALLS_AUDIT_PREV_VERSION
			                       on CALLS_AUDIT_PREV_VERSION.ID           = CALLS_AUDIT.ID
			               inner join CALLS_AUDIT                             CALLS_AUDIT_PREV_PARENT
			                       on CALLS_AUDIT_PREV_PARENT.ID            = CALLS_AUDIT_PREV_VERSION.ID
			                      and CALLS_AUDIT_PREV_PARENT.AUDIT_VERSION = CALLS_AUDIT_PREV_VERSION.AUDIT_VERSION
			                      and CALLS_AUDIT_PREV_PARENT.PARENT_ID    = @ID
			                      and CALLS_AUDIT_PREV_PARENT.DELETED      = 0
			               where CALLS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
			             )
			);
		update CALLS
		   set PARENT_ID        = @ID
		     , PARENT_TYPE      = @PARENT_TYPE
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        is null
		   and ID in (select CALLS_AUDIT.ID
		                from      CALLS_AUDIT
		               inner join (select CALLS_AUDIT_PREVIOUS.ID, max(CALLS_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      CALLS_AUDIT                          CALLS_AUDIT_CURRENT
		                            inner join CALLS_AUDIT                          CALLS_AUDIT_PREVIOUS
		                                    on CALLS_AUDIT_PREVIOUS.ID            = CALLS_AUDIT_CURRENT.ID
		                                   and CALLS_AUDIT_PREVIOUS.AUDIT_VERSION < CALLS_AUDIT_CURRENT.AUDIT_VERSION
		                                 where CALLS_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by CALLS_AUDIT_PREVIOUS.ID
		                          )                                       CALLS_AUDIT_PREV_VERSION
		                       on CALLS_AUDIT_PREV_VERSION.ID           = CALLS_AUDIT.ID
		               inner join CALLS_AUDIT                             CALLS_AUDIT_PREV_PARENT
		                       on CALLS_AUDIT_PREV_PARENT.ID            = CALLS_AUDIT_PREV_VERSION.ID
		                      and CALLS_AUDIT_PREV_PARENT.AUDIT_VERSION = CALLS_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and CALLS_AUDIT_PREV_PARENT.PARENT_ID    = @ID
		                      and CALLS_AUDIT_PREV_PARENT.DELETED      = 0
		               where CALLS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update EMAILS_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from EMAILS
			 where PARENT_ID        is null
			   and ID in (select EMAILS_AUDIT.ID
			                from      EMAILS_AUDIT
			               inner join (select EMAILS_AUDIT_PREVIOUS.ID, max(EMAILS_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
			                             from      EMAILS_AUDIT                          EMAILS_AUDIT_CURRENT
			                            inner join EMAILS_AUDIT                          EMAILS_AUDIT_PREVIOUS
			                                    on EMAILS_AUDIT_PREVIOUS.ID            = EMAILS_AUDIT_CURRENT.ID
			                                   and EMAILS_AUDIT_PREVIOUS.AUDIT_VERSION < EMAILS_AUDIT_CURRENT.AUDIT_VERSION
			                                 where EMAILS_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
			                                 group by EMAILS_AUDIT_PREVIOUS.ID
			                          )                                       EMAILS_AUDIT_PREV_VERSION
			                       on EMAILS_AUDIT_PREV_VERSION.ID           = EMAILS_AUDIT.ID
			               inner join EMAILS_AUDIT                             EMAILS_AUDIT_PREV_PARENT
			                       on EMAILS_AUDIT_PREV_PARENT.ID            = EMAILS_AUDIT_PREV_VERSION.ID
			                      and EMAILS_AUDIT_PREV_PARENT.AUDIT_VERSION = EMAILS_AUDIT_PREV_VERSION.AUDIT_VERSION
			                      and EMAILS_AUDIT_PREV_PARENT.PARENT_ID    = @ID
			                      and EMAILS_AUDIT_PREV_PARENT.DELETED      = 0
			               where EMAILS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
			             )
			);
		update EMAILS
		   set PARENT_ID        = @ID
		     , PARENT_TYPE      = @PARENT_TYPE
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        is null
		   and ID in (select EMAILS_AUDIT.ID
		                from      EMAILS_AUDIT
		               inner join (select EMAILS_AUDIT_PREVIOUS.ID, max(EMAILS_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      EMAILS_AUDIT                          EMAILS_AUDIT_CURRENT
		                            inner join EMAILS_AUDIT                          EMAILS_AUDIT_PREVIOUS
		                                    on EMAILS_AUDIT_PREVIOUS.ID            = EMAILS_AUDIT_CURRENT.ID
		                                   and EMAILS_AUDIT_PREVIOUS.AUDIT_VERSION < EMAILS_AUDIT_CURRENT.AUDIT_VERSION
		                                 where EMAILS_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by EMAILS_AUDIT_PREVIOUS.ID
		                          )                                       EMAILS_AUDIT_PREV_VERSION
		                       on EMAILS_AUDIT_PREV_VERSION.ID           = EMAILS_AUDIT.ID
		               inner join EMAILS_AUDIT                             EMAILS_AUDIT_PREV_PARENT
		                       on EMAILS_AUDIT_PREV_PARENT.ID            = EMAILS_AUDIT_PREV_VERSION.ID
		                      and EMAILS_AUDIT_PREV_PARENT.AUDIT_VERSION = EMAILS_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and EMAILS_AUDIT_PREV_PARENT.PARENT_ID    = @ID
		                      and EMAILS_AUDIT_PREV_PARENT.DELETED      = 0
		               where EMAILS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- 09/25/2013 Paul.  SMS messages act like emails. 
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update SMS_MESSAGES_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from SMS_MESSAGES
			 where PARENT_ID        is null
			   and ID in (select SMS_MESSAGES_AUDIT.ID
			                from      SMS_MESSAGES_AUDIT
			               inner join (select SMS_MESSAGES_AUDIT_PREVIOUS.ID, max(SMS_MESSAGES_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
			                             from      SMS_MESSAGES_AUDIT                          SMS_MESSAGES_AUDIT_CURRENT
			                            inner join SMS_MESSAGES_AUDIT                          SMS_MESSAGES_AUDIT_PREVIOUS
			                                    on SMS_MESSAGES_AUDIT_PREVIOUS.ID            = SMS_MESSAGES_AUDIT_CURRENT.ID
			                                   and SMS_MESSAGES_AUDIT_PREVIOUS.AUDIT_VERSION < SMS_MESSAGES_AUDIT_CURRENT.AUDIT_VERSION
			                                 where SMS_MESSAGES_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
			                                 group by SMS_MESSAGES_AUDIT_PREVIOUS.ID
			                          )                                       SMS_MESSAGES_AUDIT_PREV_VERSION
			                       on SMS_MESSAGES_AUDIT_PREV_VERSION.ID           = SMS_MESSAGES_AUDIT.ID
			               inner join SMS_MESSAGES_AUDIT                             SMS_MESSAGES_AUDIT_PREV_PARENT
			                       on SMS_MESSAGES_AUDIT_PREV_PARENT.ID            = SMS_MESSAGES_AUDIT_PREV_VERSION.ID
			                      and SMS_MESSAGES_AUDIT_PREV_PARENT.AUDIT_VERSION = SMS_MESSAGES_AUDIT_PREV_VERSION.AUDIT_VERSION
			                      and SMS_MESSAGES_AUDIT_PREV_PARENT.PARENT_ID     = @ID
			                      and SMS_MESSAGES_AUDIT_PREV_PARENT.DELETED       = 0
			               where SMS_MESSAGES_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
			             )
			);
		update SMS_MESSAGES
		   set PARENT_ID        = @ID
		     , PARENT_TYPE      = @PARENT_TYPE
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        is null
		   and ID in (select SMS_MESSAGES_AUDIT.ID
		                from      SMS_MESSAGES_AUDIT
		               inner join (select SMS_MESSAGES_AUDIT_PREVIOUS.ID, max(SMS_MESSAGES_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      SMS_MESSAGES_AUDIT                          SMS_MESSAGES_AUDIT_CURRENT
		                            inner join SMS_MESSAGES_AUDIT                          SMS_MESSAGES_AUDIT_PREVIOUS
		                                    on SMS_MESSAGES_AUDIT_PREVIOUS.ID            = SMS_MESSAGES_AUDIT_CURRENT.ID
		                                   and SMS_MESSAGES_AUDIT_PREVIOUS.AUDIT_VERSION < SMS_MESSAGES_AUDIT_CURRENT.AUDIT_VERSION
		                                 where SMS_MESSAGES_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by SMS_MESSAGES_AUDIT_PREVIOUS.ID
		                          )                                       SMS_MESSAGES_AUDIT_PREV_VERSION
		                       on SMS_MESSAGES_AUDIT_PREV_VERSION.ID           = SMS_MESSAGES_AUDIT.ID
		               inner join SMS_MESSAGES_AUDIT                             SMS_MESSAGES_AUDIT_PREV_PARENT
		                       on SMS_MESSAGES_AUDIT_PREV_PARENT.ID            = SMS_MESSAGES_AUDIT_PREV_VERSION.ID
		                      and SMS_MESSAGES_AUDIT_PREV_PARENT.AUDIT_VERSION = SMS_MESSAGES_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and SMS_MESSAGES_AUDIT_PREV_PARENT.PARENT_ID     = @ID
		                      and SMS_MESSAGES_AUDIT_PREV_PARENT.DELETED       = 0
		               where SMS_MESSAGES_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- 10/30/2013 Paul.  TWITTER messages act like emails. 
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update TWITTER_MESSAGES_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from TWITTER_MESSAGES
			 where PARENT_ID        is null
			   and ID in (select TWITTER_MESSAGES_AUDIT.ID
			                from      TWITTER_MESSAGES_AUDIT
			               inner join (select TWITTER_MESSAGES_AUDIT_PREVIOUS.ID, max(TWITTER_MESSAGES_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
			                             from      TWITTER_MESSAGES_AUDIT                          TWITTER_MESSAGES_AUDIT_CURRENT
			                            inner join TWITTER_MESSAGES_AUDIT                          TWITTER_MESSAGES_AUDIT_PREVIOUS
			                                    on TWITTER_MESSAGES_AUDIT_PREVIOUS.ID            = TWITTER_MESSAGES_AUDIT_CURRENT.ID
			                                   and TWITTER_MESSAGES_AUDIT_PREVIOUS.AUDIT_VERSION < TWITTER_MESSAGES_AUDIT_CURRENT.AUDIT_VERSION
			                                 where TWITTER_MESSAGES_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
			                                 group by TWITTER_MESSAGES_AUDIT_PREVIOUS.ID
			                          )                                       TWITTER_MESSAGES_AUDIT_PREV_VERSION
			                       on TWITTER_MESSAGES_AUDIT_PREV_VERSION.ID                = TWITTER_MESSAGES_AUDIT.ID
			               inner join TWITTER_MESSAGES_AUDIT                             TWITTER_MESSAGES_AUDIT_PREV_PARENT
			                       on TWITTER_MESSAGES_AUDIT_PREV_PARENT.ID            = TWITTER_MESSAGES_AUDIT_PREV_VERSION.ID
			                      and TWITTER_MESSAGES_AUDIT_PREV_PARENT.AUDIT_VERSION = TWITTER_MESSAGES_AUDIT_PREV_VERSION.AUDIT_VERSION
			                      and TWITTER_MESSAGES_AUDIT_PREV_PARENT.PARENT_ID     = @ID
			                      and TWITTER_MESSAGES_AUDIT_PREV_PARENT.DELETED       = 0
			               where TWITTER_MESSAGES_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
			             )
			);
		update TWITTER_MESSAGES
		   set PARENT_ID        = @ID
		     , PARENT_TYPE      = @PARENT_TYPE
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        is null
		   and ID in (select TWITTER_MESSAGES_AUDIT.ID
		                from      TWITTER_MESSAGES_AUDIT
		               inner join (select TWITTER_MESSAGES_AUDIT_PREVIOUS.ID, max(TWITTER_MESSAGES_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      TWITTER_MESSAGES_AUDIT                          TWITTER_MESSAGES_AUDIT_CURRENT
		                            inner join TWITTER_MESSAGES_AUDIT                          TWITTER_MESSAGES_AUDIT_PREVIOUS
		                                    on TWITTER_MESSAGES_AUDIT_PREVIOUS.ID            = TWITTER_MESSAGES_AUDIT_CURRENT.ID
		                                   and TWITTER_MESSAGES_AUDIT_PREVIOUS.AUDIT_VERSION < TWITTER_MESSAGES_AUDIT_CURRENT.AUDIT_VERSION
		                                 where TWITTER_MESSAGES_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by TWITTER_MESSAGES_AUDIT_PREVIOUS.ID
		                          )                                       TWITTER_MESSAGES_AUDIT_PREV_VERSION
		                       on TWITTER_MESSAGES_AUDIT_PREV_VERSION.ID                = TWITTER_MESSAGES_AUDIT.ID
		               inner join TWITTER_MESSAGES_AUDIT                             TWITTER_MESSAGES_AUDIT_PREV_PARENT
		                       on TWITTER_MESSAGES_AUDIT_PREV_PARENT.ID            = TWITTER_MESSAGES_AUDIT_PREV_VERSION.ID
		                      and TWITTER_MESSAGES_AUDIT_PREV_PARENT.AUDIT_VERSION = TWITTER_MESSAGES_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and TWITTER_MESSAGES_AUDIT_PREV_PARENT.PARENT_ID     = @ID
		                      and TWITTER_MESSAGES_AUDIT_PREV_PARENT.DELETED       = 0
		               where TWITTER_MESSAGES_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update MEETINGS_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from MEETINGS
			 where PARENT_ID        is null
			   and ID in (select MEETINGS_AUDIT.ID
			                from      MEETINGS_AUDIT
			               inner join (select MEETINGS_AUDIT_PREVIOUS.ID, max(MEETINGS_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
			                             from      MEETINGS_AUDIT                          MEETINGS_AUDIT_CURRENT
			                            inner join MEETINGS_AUDIT                          MEETINGS_AUDIT_PREVIOUS
			                                    on MEETINGS_AUDIT_PREVIOUS.ID            = MEETINGS_AUDIT_CURRENT.ID
			                                   and MEETINGS_AUDIT_PREVIOUS.AUDIT_VERSION < MEETINGS_AUDIT_CURRENT.AUDIT_VERSION
			                                 where MEETINGS_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
			                                 group by MEETINGS_AUDIT_PREVIOUS.ID
			                          )                                       MEETINGS_AUDIT_PREV_VERSION
			                       on MEETINGS_AUDIT_PREV_VERSION.ID           = MEETINGS_AUDIT.ID
			               inner join MEETINGS_AUDIT                             MEETINGS_AUDIT_PREV_PARENT
			                       on MEETINGS_AUDIT_PREV_PARENT.ID            = MEETINGS_AUDIT_PREV_VERSION.ID
			                      and MEETINGS_AUDIT_PREV_PARENT.AUDIT_VERSION = MEETINGS_AUDIT_PREV_VERSION.AUDIT_VERSION
			                      and MEETINGS_AUDIT_PREV_PARENT.PARENT_ID    = @ID
			                      and MEETINGS_AUDIT_PREV_PARENT.DELETED      = 0
			               where MEETINGS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
			             )
			);
		update MEETINGS
		   set PARENT_ID        = @ID
		     , PARENT_TYPE      = @PARENT_TYPE
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        is null
		   and ID in (select MEETINGS_AUDIT.ID
		                from      MEETINGS_AUDIT
		               inner join (select MEETINGS_AUDIT_PREVIOUS.ID, max(MEETINGS_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      MEETINGS_AUDIT                          MEETINGS_AUDIT_CURRENT
		                            inner join MEETINGS_AUDIT                          MEETINGS_AUDIT_PREVIOUS
		                                    on MEETINGS_AUDIT_PREVIOUS.ID            = MEETINGS_AUDIT_CURRENT.ID
		                                   and MEETINGS_AUDIT_PREVIOUS.AUDIT_VERSION < MEETINGS_AUDIT_CURRENT.AUDIT_VERSION
		                                 where MEETINGS_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by MEETINGS_AUDIT_PREVIOUS.ID
		                          )                                       MEETINGS_AUDIT_PREV_VERSION
		                       on MEETINGS_AUDIT_PREV_VERSION.ID           = MEETINGS_AUDIT.ID
		               inner join MEETINGS_AUDIT                             MEETINGS_AUDIT_PREV_PARENT
		                       on MEETINGS_AUDIT_PREV_PARENT.ID            = MEETINGS_AUDIT_PREV_VERSION.ID
		                      and MEETINGS_AUDIT_PREV_PARENT.AUDIT_VERSION = MEETINGS_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and MEETINGS_AUDIT_PREV_PARENT.PARENT_ID    = @ID
		                      and MEETINGS_AUDIT_PREV_PARENT.DELETED      = 0
		               where MEETINGS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update NOTES_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from NOTES
			 where PARENT_ID        is null
			   and ID in (select NOTES_AUDIT.ID
			                from      NOTES_AUDIT
			               inner join (select NOTES_AUDIT_PREVIOUS.ID, max(NOTES_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
			                             from      NOTES_AUDIT                          NOTES_AUDIT_CURRENT
			                            inner join NOTES_AUDIT                          NOTES_AUDIT_PREVIOUS
			                                    on NOTES_AUDIT_PREVIOUS.ID            = NOTES_AUDIT_CURRENT.ID
			                                   and NOTES_AUDIT_PREVIOUS.AUDIT_VERSION < NOTES_AUDIT_CURRENT.AUDIT_VERSION
			                                 where NOTES_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
			                                 group by NOTES_AUDIT_PREVIOUS.ID
			                          )                                       NOTES_AUDIT_PREV_VERSION
			                       on NOTES_AUDIT_PREV_VERSION.ID           = NOTES_AUDIT.ID
			               inner join NOTES_AUDIT                             NOTES_AUDIT_PREV_PARENT
			                       on NOTES_AUDIT_PREV_PARENT.ID            = NOTES_AUDIT_PREV_VERSION.ID
			                      and NOTES_AUDIT_PREV_PARENT.AUDIT_VERSION = NOTES_AUDIT_PREV_VERSION.AUDIT_VERSION
			                      and NOTES_AUDIT_PREV_PARENT.PARENT_ID    = @ID
			                      and NOTES_AUDIT_PREV_PARENT.DELETED      = 0
			               where NOTES_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
			             )
			);
		update NOTES
		   set PARENT_ID        = @ID
		     , PARENT_TYPE      = @PARENT_TYPE
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        is null
		   and ID in (select NOTES_AUDIT.ID
		                from      NOTES_AUDIT
		               inner join (select NOTES_AUDIT_PREVIOUS.ID, max(NOTES_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      NOTES_AUDIT                          NOTES_AUDIT_CURRENT
		                            inner join NOTES_AUDIT                          NOTES_AUDIT_PREVIOUS
		                                    on NOTES_AUDIT_PREVIOUS.ID            = NOTES_AUDIT_CURRENT.ID
		                                   and NOTES_AUDIT_PREVIOUS.AUDIT_VERSION < NOTES_AUDIT_CURRENT.AUDIT_VERSION
		                                 where NOTES_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by NOTES_AUDIT_PREVIOUS.ID
		                          )                                       NOTES_AUDIT_PREV_VERSION
		                       on NOTES_AUDIT_PREV_VERSION.ID           = NOTES_AUDIT.ID
		               inner join NOTES_AUDIT                             NOTES_AUDIT_PREV_PARENT
		                       on NOTES_AUDIT_PREV_PARENT.ID            = NOTES_AUDIT_PREV_VERSION.ID
		                      and NOTES_AUDIT_PREV_PARENT.AUDIT_VERSION = NOTES_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and NOTES_AUDIT_PREV_PARENT.PARENT_ID    = @ID
		                      and NOTES_AUDIT_PREV_PARENT.DELETED      = 0
		               where NOTES_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update PROJECT_TASK_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from PROJECT_TASK
			 where PARENT_ID        is null
			   and ID in (select PROJECT_TASK_AUDIT.ID
			                from      PROJECT_TASK_AUDIT
			               inner join (select PROJECT_TASK_AUDIT_PREVIOUS.ID, max(PROJECT_TASK_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
			                             from      PROJECT_TASK_AUDIT                          PROJECT_TASK_AUDIT_CURRENT
			                            inner join PROJECT_TASK_AUDIT                          PROJECT_TASK_AUDIT_PREVIOUS
			                                    on PROJECT_TASK_AUDIT_PREVIOUS.ID            = PROJECT_TASK_AUDIT_CURRENT.ID
			                                   and PROJECT_TASK_AUDIT_PREVIOUS.AUDIT_VERSION < PROJECT_TASK_AUDIT_CURRENT.AUDIT_VERSION
			                                 where PROJECT_TASK_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
			                                 group by PROJECT_TASK_AUDIT_PREVIOUS.ID
			                          )                                       PROJECT_TASK_AUDIT_PREV_VERSION
			                       on PROJECT_TASK_AUDIT_PREV_VERSION.ID           = PROJECT_TASK_AUDIT.ID
			               inner join PROJECT_TASK_AUDIT                             PROJECT_TASK_AUDIT_PREV_PARENT
			                       on PROJECT_TASK_AUDIT_PREV_PARENT.ID            = PROJECT_TASK_AUDIT_PREV_VERSION.ID
			                      and PROJECT_TASK_AUDIT_PREV_PARENT.AUDIT_VERSION = PROJECT_TASK_AUDIT_PREV_VERSION.AUDIT_VERSION
			                      and PROJECT_TASK_AUDIT_PREV_PARENT.PARENT_ID    = @ID
			                      and PROJECT_TASK_AUDIT_PREV_PARENT.DELETED      = 0
			               where PROJECT_TASK_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
			             )
			);
		update PROJECT_TASK
		   set PARENT_ID        = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        is null
		   and ID in (select PROJECT_TASK_AUDIT.ID
		                from      PROJECT_TASK_AUDIT
		               inner join (select PROJECT_TASK_AUDIT_PREVIOUS.ID, max(PROJECT_TASK_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      PROJECT_TASK_AUDIT                          PROJECT_TASK_AUDIT_CURRENT
		                            inner join PROJECT_TASK_AUDIT                          PROJECT_TASK_AUDIT_PREVIOUS
		                                    on PROJECT_TASK_AUDIT_PREVIOUS.ID            = PROJECT_TASK_AUDIT_CURRENT.ID
		                                   and PROJECT_TASK_AUDIT_PREVIOUS.AUDIT_VERSION < PROJECT_TASK_AUDIT_CURRENT.AUDIT_VERSION
		                                 where PROJECT_TASK_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by PROJECT_TASK_AUDIT_PREVIOUS.ID
		                          )                                       PROJECT_TASK_AUDIT_PREV_VERSION
		                       on PROJECT_TASK_AUDIT_PREV_VERSION.ID           = PROJECT_TASK_AUDIT.ID
		               inner join PROJECT_TASK_AUDIT                             PROJECT_TASK_AUDIT_PREV_PARENT
		                       on PROJECT_TASK_AUDIT_PREV_PARENT.ID            = PROJECT_TASK_AUDIT_PREV_VERSION.ID
		                      and PROJECT_TASK_AUDIT_PREV_PARENT.AUDIT_VERSION = PROJECT_TASK_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and PROJECT_TASK_AUDIT_PREV_PARENT.PARENT_ID    = @ID
		                      and PROJECT_TASK_AUDIT_PREV_PARENT.DELETED      = 0
		               where PROJECT_TASK_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update PROJECT_RELATION
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where RELATION_ID      = @ID
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update TASKS_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from TASKS
			 where PARENT_ID        is null
			   and ID in (select TASKS_AUDIT.ID
			                from      TASKS_AUDIT
			               inner join (select TASKS_AUDIT_PREVIOUS.ID, max(TASKS_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
			                             from      TASKS_AUDIT                          TASKS_AUDIT_CURRENT
			                            inner join TASKS_AUDIT                          TASKS_AUDIT_PREVIOUS
			                                    on TASKS_AUDIT_PREVIOUS.ID            = TASKS_AUDIT_CURRENT.ID
			                                   and TASKS_AUDIT_PREVIOUS.AUDIT_VERSION < TASKS_AUDIT_CURRENT.AUDIT_VERSION
			                                 where TASKS_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
			                                 group by TASKS_AUDIT_PREVIOUS.ID
			                          )                                       TASKS_AUDIT_PREV_VERSION
			                       on TASKS_AUDIT_PREV_VERSION.ID           = TASKS_AUDIT.ID
			               inner join TASKS_AUDIT                             TASKS_AUDIT_PREV_PARENT
			                       on TASKS_AUDIT_PREV_PARENT.ID            = TASKS_AUDIT_PREV_VERSION.ID
			                      and TASKS_AUDIT_PREV_PARENT.AUDIT_VERSION = TASKS_AUDIT_PREV_VERSION.AUDIT_VERSION
			                      and TASKS_AUDIT_PREV_PARENT.PARENT_ID    = @ID
			                      and TASKS_AUDIT_PREV_PARENT.DELETED      = 0
			               where TASKS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
			             )
			);
		update TASKS
		   set PARENT_ID        = @ID
		     , PARENT_TYPE      = @PARENT_TYPE
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        is null
		   and ID in (select TASKS_AUDIT.ID
		                from      TASKS_AUDIT
		               inner join (select TASKS_AUDIT_PREVIOUS.ID, max(TASKS_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      TASKS_AUDIT                          TASKS_AUDIT_CURRENT
		                            inner join TASKS_AUDIT                          TASKS_AUDIT_PREVIOUS
		                                    on TASKS_AUDIT_PREVIOUS.ID            = TASKS_AUDIT_CURRENT.ID
		                                   and TASKS_AUDIT_PREVIOUS.AUDIT_VERSION < TASKS_AUDIT_CURRENT.AUDIT_VERSION
		                                 where TASKS_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by TASKS_AUDIT_PREVIOUS.ID
		                          )                                       TASKS_AUDIT_PREV_VERSION
		                       on TASKS_AUDIT_PREV_VERSION.ID           = TASKS_AUDIT.ID
		               inner join TASKS_AUDIT                             TASKS_AUDIT_PREV_PARENT
		                       on TASKS_AUDIT_PREV_PARENT.ID            = TASKS_AUDIT_PREV_VERSION.ID
		                      and TASKS_AUDIT_PREV_PARENT.AUDIT_VERSION = TASKS_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and TASKS_AUDIT_PREV_PARENT.PARENT_ID    = @ID
		                      and TASKS_AUDIT_PREV_PARENT.DELETED      = 0
		               where TASKS_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
  end
GO

Grant Execute on dbo.spPARENT_Undelete to public;
GO

