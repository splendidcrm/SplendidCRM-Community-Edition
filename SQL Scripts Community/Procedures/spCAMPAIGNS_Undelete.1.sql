if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGNS_Undelete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGNS_Undelete;
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
Create Procedure dbo.spCAMPAIGNS_Undelete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @AUDIT_TOKEN      varchar(255)
	)
as
  begin
	set nocount on
	
	/*
	-- BEGIN Oracle Exception
		-- 09/19/2005 Paul.  SugarCRM does not modify these. 
		update EMAIL_MARKETING
		   set CAMPAIGN_ID      = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CAMPAIGN_ID       is null
		   and ID in (select EMAIL_MARKETING_AUDIT.ID
		                from      EMAIL_MARKETING_AUDIT
		               inner join (select EMAIL_MARKETING_AUDIT_PREVIOUS.ID, max(EMAIL_MARKETING_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      EMAIL_MARKETING_AUDIT                          EMAIL_MARKETING_AUDIT_CURRENT
		                            inner join EMAIL_MARKETING_AUDIT                          EMAIL_MARKETING_AUDIT_PREVIOUS
		                                    on EMAIL_MARKETING_AUDIT_PREVIOUS.ID            = EMAIL_MARKETING_AUDIT_CURRENT.ID
		                                   and EMAIL_MARKETING_AUDIT_PREVIOUS.AUDIT_VERSION < EMAIL_MARKETING_AUDIT_CURRENT.AUDIT_VERSION
		                                 where EMAIL_MARKETING_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by EMAIL_MARKETING_AUDIT_PREVIOUS.ID
		                          )                                        EMAIL_MARKETING_AUDIT_PREV_VERSION
		                       on EMAIL_MARKETING_AUDIT_PREV_VERSION.ID            = EMAIL_MARKETING_AUDIT.ID
		               inner join EMAIL_MARKETING_AUDIT                              EMAIL_MARKETING_AUDIT_PREV_ACCOUNT
		                       on EMAIL_MARKETING_AUDIT_PREV_ACCOUNT.ID            = EMAIL_MARKETING_AUDIT_PREV_VERSION.ID
		                      and EMAIL_MARKETING_AUDIT_PREV_ACCOUNT.AUDIT_VERSION = EMAIL_MARKETING_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and EMAIL_MARKETING_AUDIT_PREV_ACCOUNT.CAMPAIGN_ID    = @ID
		                      and EMAIL_MARKETING_AUDIT_PREV_ACCOUNT.DELETED       = 0
		               where EMAIL_MARKETING_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILMAN
		   set CAMPAIGN_ID      = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CAMPAIGN_ID       is null
		   and ID in (select EMAILMAN_AUDIT.ID
		                from      EMAILMAN_AUDIT
		               inner join (select EMAILMAN_AUDIT_PREVIOUS.ID, max(EMAILMAN_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      EMAILMAN_AUDIT                          EMAILMAN_AUDIT_CURRENT
		                            inner join EMAILMAN_AUDIT                          EMAILMAN_AUDIT_PREVIOUS
		                                    on EMAILMAN_AUDIT_PREVIOUS.ID            = EMAILMAN_AUDIT_CURRENT.ID
		                                   and EMAILMAN_AUDIT_PREVIOUS.AUDIT_VERSION < EMAILMAN_AUDIT_CURRENT.AUDIT_VERSION
		                                 where EMAILMAN_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by EMAILMAN_AUDIT_PREVIOUS.ID
		                          )                                        EMAILMAN_AUDIT_PREV_VERSION
		                       on EMAILMAN_AUDIT_PREV_VERSION.ID            = EMAILMAN_AUDIT.ID
		               inner join EMAILMAN_AUDIT                              EMAILMAN_AUDIT_PREV_ACCOUNT
		                       on EMAILMAN_AUDIT_PREV_ACCOUNT.ID            = EMAILMAN_AUDIT_PREV_VERSION.ID
		                      and EMAILMAN_AUDIT_PREV_ACCOUNT.AUDIT_VERSION = EMAILMAN_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and EMAILMAN_AUDIT_PREV_ACCOUNT.CAMPAIGN_ID    = @ID
		                      and EMAILMAN_AUDIT_PREV_ACCOUNT.DELETED       = 0
		               where EMAILMAN_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		update EMAILMAN_SENT
		   set CAMPAIGN_ID      = @ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CAMPAIGN_ID       is null
		   and ID in (select EMAILMAN_SENT_AUDIT.ID
		                from      EMAILMAN_SENT_AUDIT
		               inner join (select EMAILMAN_SENT_AUDIT_PREVIOUS.ID, max(EMAILMAN_SENT_AUDIT_PREVIOUS.AUDIT_VERSION) as AUDIT_VERSION
		                             from      EMAILMAN_SENT_AUDIT                          EMAILMAN_SENT_AUDIT_CURRENT
		                            inner join EMAILMAN_SENT_AUDIT                          EMAILMAN_SENT_AUDIT_PREVIOUS
		                                    on EMAILMAN_SENT_AUDIT_PREVIOUS.ID            = EMAILMAN_SENT_AUDIT_CURRENT.ID
		                                   and EMAILMAN_SENT_AUDIT_PREVIOUS.AUDIT_VERSION < EMAILMAN_SENT_AUDIT_CURRENT.AUDIT_VERSION
		                                 where EMAILMAN_SENT_AUDIT_CURRENT.AUDIT_TOKEN = @AUDIT_TOKEN
		                                 group by EMAILMAN_SENT_AUDIT_PREVIOUS.ID
		                          )                                        EMAILMAN_SENT_AUDIT_PREV_VERSION
		                       on EMAILMAN_SENT_AUDIT_PREV_VERSION.ID            = EMAILMAN_SENT_AUDIT.ID
		               inner join EMAILMAN_SENT_AUDIT                              EMAILMAN_SENT_AUDIT_PREV_ACCOUNT
		                       on EMAILMAN_SENT_AUDIT_PREV_ACCOUNT.ID            = EMAILMAN_SENT_AUDIT_PREV_VERSION.ID
		                      and EMAILMAN_SENT_AUDIT_PREV_ACCOUNT.AUDIT_VERSION = EMAILMAN_SENT_AUDIT_PREV_VERSION.AUDIT_VERSION
		                      and EMAILMAN_SENT_AUDIT_PREV_ACCOUNT.CAMPAIGN_ID    = @ID
		                      and EMAILMAN_SENT_AUDIT_PREV_ACCOUNT.DELETED       = 0
		               where EMAILMAN_SENT_AUDIT.AUDIT_TOKEN = @AUDIT_TOKEN
		             )
		;
	-- END Oracle Exception
	*/
	-- BEGIN Oracle Exception
		update PROSPECT_LIST_CAMPAIGNS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where CAMPAIGN_ID      = @ID
		   and DELETED          = 1
		   and ID in (select ID from PROSPECT_LIST_CAMPAIGNS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and CAMPAIGN_ID = @ID);
	-- END Oracle Exception
	
	-- BEGIN Oracle Exception
		-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
		update CAMPAIGNS_CSTM
		   set ID_C             = ID_C
		 where ID_C in 
			(select ID
			   from CAMPAIGNS
			  where ID               = @ID
			    and DELETED          = 1
			    and ID in (select ID from CAMPAIGNS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID)
			);
		update CAMPAIGNS
		   set DELETED          = 0
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 1
		   and ID in (select ID from CAMPAIGNS_AUDIT where AUDIT_TOKEN = @AUDIT_TOKEN and ID = @ID);
	-- END Oracle Exception
	
  end
GO

Grant Execute on dbo.spCAMPAIGNS_Undelete to public;
GO

