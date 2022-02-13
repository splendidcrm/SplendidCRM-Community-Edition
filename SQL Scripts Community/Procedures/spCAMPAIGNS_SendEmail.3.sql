if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGNS_SendEmail' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGNS_SendEmail;
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
-- 08/27/2008 Paul.  PostgreSQL does not allow modifying input parameters.  Use a local temp variable. 
-- 09/13/2008 Paul.  Simplify migration to DB2. 
-- 09/15/2008 Paul.  MySQL does not support the return clause, so use the Leave clause instead. 
-- 12/05/2011 Paul.  We need to remove duplicates by email. 
-- 11/01/2015 Paul.  Include COMPUTED_EMAIL1 in table to increase performance of dup removal. 
Create Procedure dbo.spCAMPAIGNS_SendEmail
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @TEST             bit
	)
as
  begin
	set nocount on

	declare @CAMPAIGN_STATUS    nvarchar(25);
	declare @TEMP_TEST          bit;


	set @TEMP_TEST = @TEST;
	if @TEMP_TEST is null begin -- then
		set @TEMP_TEST = 0;
	end -- if;

	select @CAMPAIGN_STATUS = STATUS
	  from CAMPAIGNS
	 where ID = @ID;
	if @CAMPAIGN_STATUS = N'sending' begin -- then
		raiserror(N'ERR_SENDING_NOW', 16, 1);
		return;
	end -- if;

	-- 01/10/2010 Paul.  Update any dynamic lists before running the campaign. 
	exec dbo.spCAMPAIGNS_UpdateDynamic @ID, @MODIFIED_USER_ID;

/*
	delete EMAILMAN
	  from      EMAILMAN
	 inner join EMAIL_MARKETING
	         on EMAIL_MARKETING.CAMPAIGN_ID = EMAILMAN.CAMPAIGN_ID
	        and EMAIL_MARKETING.ID          = EMAILMAN.MARKETING_ID
	 inner join vwCAMPAIGNS_PROSPECT_LIST_Send
	         on vwCAMPAIGNS_PROSPECT_LIST_Send.PROSPECT_LIST_ID   = EMAILMAN.LIST_ID
	        and vwCAMPAIGNS_PROSPECT_LIST_Send.TEST               = @TEMP_TEST
	        and vwCAMPAIGNS_PROSPECT_LIST_Send.ALL_PROSPECT_LISTS = isnull(EMAIL_MARKETING.ALL_PROSPECT_LISTS, 0)
	        and (   vwCAMPAIGNS_PROSPECT_LIST_Send.CAMPAIGN_ID        = EMAILMAN.CAMPAIGN_ID
	             or vwCAMPAIGNS_PROSPECT_LIST_Send.EMAIL_MARKETING_ID = EMAILMAN.MARKETING_ID)
	 where EMAILMAN.CAMPAIGN_ID  = @ID;
*/
	-- 09/09/2007 Paul.  I'm not sure why SugarCRM only deletes emails that are in the list.  We should delete all of them. 
	-- 12/28/2007 Paul.  Oracle does not allow the join syntax in a delete statement. 
	-- 12/31/2007 Paul.  MySQL requires the from keyword when deleting a table. 
	delete from EMAILMAN
	 where ID in (select EMAILMAN.ID
	                from      EMAILMAN
	               inner join EMAIL_MARKETING
	                       on EMAIL_MARKETING.CAMPAIGN_ID = EMAILMAN.CAMPAIGN_ID
	                      and EMAIL_MARKETING.ID          = EMAILMAN.MARKETING_ID
	               where EMAILMAN.CAMPAIGN_ID  = @ID);

	-- 08/18/2007 Paul.  The complex select statement automatically includes all selected prospect lists
	-- and it automatically excludes all exempt lists. 
	-- 12/05/2011 Paul.  Sort the list by related type and email to establish a priority for Contacts, Leads and Prospects when removing duplicates. 
	-- 11/01/2015 Paul.  Include COMPUTED_EMAIL1 in table to increase performance of dup removal. 
	insert into EMAILMAN (USER_ID, CAMPAIGN_ID, MARKETING_ID, LIST_ID, RELATED_ID, RELATED_TYPE, SEND_DATE_TIME, COMPUTED_EMAIL1)
	select @MODIFIED_USER_ID
	     , CAMPAIGN_ID
	     , EMAIL_MARKETING_ID
	     , PROSPECT_LIST_ID
	     , RELATED_ID
	     , RELATED_TYPE
	     , SEND_DATE_TIME
	     , EMAIL1
	  from vwCAMPAIGNS_Send
	 where CAMPAIGN_ID = @ID
	   and TEST        = @TEMP_TEST
	 order by RELATED_TYPE, EMAIL1;

/*
	select distinct
	       @MODIFIED_USER_ID
	     ,  PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID
	     , EMAIL_MARKETING.ID
	     ,  vwPROSPECT_LISTS_Emails.ID
	     ,  vwPROSPECT_LISTS_Emails.RELATED_ID
	     ,  vwPROSPECT_LISTS_Emails.RELATED_TYPE
	     , (case @TEMP_TEST when 1 then getdate() else EMAIL_MARKETING.DATE_START end)
	  from            EMAIL_MARKETING
	       inner join PROSPECT_LIST_CAMPAIGNS
	               on PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID               = EMAIL_MARKETING.CAMPAIGN_ID
	              and PROSPECT_LIST_CAMPAIGNS.DELETED                   = 0
	       inner join vwPROSPECT_LISTS_Emails
	               on vwPROSPECT_LISTS_Emails.ID                        = PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID
	       inner join vwCAMPAIGNS_PROSPECT_LIST_Send
	               on vwCAMPAIGNS_PROSPECT_LIST_Send.PROSPECT_LIST_ID   = vwPROSPECT_LISTS_Emails.ID
	              and vwCAMPAIGNS_PROSPECT_LIST_Send.TEST               = @TEMP_TEST
	              and vwCAMPAIGNS_PROSPECT_LIST_Send.ALL_PROSPECT_LISTS = isnull(EMAIL_MARKETING.ALL_PROSPECT_LISTS, 0)
	              and (   vwCAMPAIGNS_PROSPECT_LIST_Send.CAMPAIGN_ID        = PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID
	                   or vwCAMPAIGNS_PROSPECT_LIST_Send.EMAIL_MARKETING_ID = EMAIL_MARKETING.ID)
	  left outer join vwPROSPECT_LISTS_ExemptEmails
	               on vwPROSPECT_LISTS_ExemptEmails.RELATED_ID          = vwPROSPECT_LISTS_Emails.RELATED_ID
	              and vwPROSPECT_LISTS_ExemptEmails.CAMPAIGN_ID         = PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID
	 where EMAIL_MARKETING.CAMPAIGN_ID       = @ID
	   and EMAIL_MARKETING.DELETED           = 0
	   and vwPROSPECT_LISTS_ExemptEmails.RELATED_ID is null
*/
	if @TEMP_TEST = 0 begin -- then
		-- 12/05/2011 Paul.  We need to remove duplicates by email. 
		exec dbo.spEMAILMAN_RemoveDuplicates @ID, @MODIFIED_USER_ID;

		insert into CAMPAIGN_LOG
			( ID                 
			, CREATED_BY         
			, DATE_ENTERED       
			, MODIFIED_USER_ID   
			, DATE_MODIFIED      
			, CAMPAIGN_ID        
--			, TARGET_TRACKER_KEY 
			, TARGET_ID          
			, TARGET_TYPE        
			, ACTIVITY_TYPE      
			, ACTIVITY_DATE      
--			, RELATED_ID         
--			, RELATED_TYPE       
			, MARKETING_ID       
			, LIST_ID            
			, MORE_INFORMATION   
			)
		select	  newid()             
			, @MODIFIED_USER_ID   
			,  getdate()          
			, @MODIFIED_USER_ID   
			,  getdate()          
			,  CAMPAIGN_ID        
--			,  null               
			,  RELATED_ID         
			,  RELATED_TYPE       
			, N'invalid email'    
			,  getdate()          
--			,  null               
--			,  null               
			,  EMAIL_MARKETING_ID 
			,  PROSPECT_LIST_ID   
			,  EMAIL1             
		  from vwCAMPAIGNS_InvalidEmails
		 where CAMPAIGN_ID = @ID;
		
		insert into CAMPAIGN_LOG
			( ID                 
			, CREATED_BY         
			, DATE_ENTERED       
			, MODIFIED_USER_ID   
			, DATE_MODIFIED      
			, CAMPAIGN_ID        
--			, TARGET_TRACKER_KEY 
			, TARGET_ID          
			, TARGET_TYPE        
			, ACTIVITY_TYPE      
			, ACTIVITY_DATE      
--			, RELATED_ID         
--			, RELATED_TYPE       
			, MARKETING_ID       
			, LIST_ID            
			, MORE_INFORMATION   
			)
		select	  newid()             
			, @MODIFIED_USER_ID   
			,  getdate()          
			, @MODIFIED_USER_ID   
			,  getdate()          
			,  CAMPAIGN_ID        
--			,  null               
			,  RELATED_ID         
			,  RELATED_TYPE       
			, N'removed'          
			,  getdate()          
--			,  null               
--			,  null               
			,  EMAIL_MARKETING_ID 
			,  PROSPECT_LIST_ID   
			,  EMAIL1             
		  from vwCAMPAIGNS_OptOutEmails
		 where CAMPAIGN_ID = @ID;
		
		insert into CAMPAIGN_LOG
			( ID                 
			, CREATED_BY         
			, DATE_ENTERED       
			, MODIFIED_USER_ID   
			, DATE_MODIFIED      
			, CAMPAIGN_ID        
--			, TARGET_TRACKER_KEY 
			, TARGET_ID          
			, TARGET_TYPE        
			, ACTIVITY_TYPE      
			, ACTIVITY_DATE      
--			, RELATED_ID         
--			, RELATED_TYPE       
			, MARKETING_ID       
			, LIST_ID            
			, MORE_INFORMATION   
			)
		select	  newid()             
			, @MODIFIED_USER_ID   
			,  getdate()          
			, @MODIFIED_USER_ID   
			,  getdate()          
			,  CAMPAIGN_ID        
--			,  null               
			,  RELATED_ID         
			,  RELATED_TYPE       
			, N'blocked'          
			,  getdate()          
--			,  null               
--			,  null               
			,  EMAIL_MARKETING_ID 
			,  PROSPECT_LIST_ID   
			,  EMAIL1             
		  from vwCAMPAIGNS_ExemptEmails
		 where CAMPAIGN_ID = @ID;
	end -- if;
/* -- #if MySQL
  end;  #MainProcedureBlock
-- #endif MySQL */
  end
GO

Grant Execute on dbo.spCAMPAIGNS_SendEmail to public;
GO

