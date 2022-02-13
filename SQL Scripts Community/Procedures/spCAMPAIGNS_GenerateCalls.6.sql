if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGNS_GenerateCalls' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGNS_GenerateCalls;
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
Create Procedure dbo.spCAMPAIGNS_GenerateCalls
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on

	declare @TEMP_TEST          bit;
	declare @CALL_MARKETING_ID  uniqueidentifier;


-- #if SQL_Server /*
	declare CAMPAIGN_CALL_MKTG_CURSOR cursor for
	select ID
	  from vwCAMPAIGNS_CALL_MARKETING
	 where CAMPAIGN_ID = @ID
	   and STATUS  = N'active'
	 order by DATE_START, NAME;
-- #endif SQL_Server */

/* -- #if IBM_DB2
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
-- #endif IBM_DB2 */
/* -- #if MySQL
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
	set in_FETCH_STATUS = 0;
-- #endif MySQL */

	set @TEMP_TEST = 0;
	exec dbo.spCAMPAIGNS_UpdateDynamic @ID, @MODIFIED_USER_ID;

	open CAMPAIGN_CALL_MKTG_CURSOR;
	fetch next from CAMPAIGN_CALL_MKTG_CURSOR into @CALL_MARKETING_ID;
	while @@FETCH_STATUS = 0 and @@ERROR = 0 begin -- do
		exec dbo.spCALL_MARKETING_GenerateCalls @CALL_MARKETING_ID, @MODIFIED_USER_ID;
		fetch next from CAMPAIGN_CALL_MKTG_CURSOR into @CALL_MARKETING_ID;
/* -- #if Oracle
		IF CAMPAIGN_CALL_MKTG_CURSOR%NOTFOUND THEN
			StoO_sqlstatus := 2;
			StoO_fetchstatus := -1;
		ELSE
			StoO_sqlstatus := 0;
			StoO_fetchstatus := 0;
		END IF;
-- #endif Oracle */
	end -- while;
	close CAMPAIGN_CALL_MKTG_CURSOR;
	deallocate CAMPAIGN_CALL_MKTG_CURSOR;

	if @TEMP_TEST = 0 begin -- then
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
			,  CALL_MARKETING_ID  
			,  PROSPECT_LIST_ID   
			,  PHONE_WORK         
		  from vwCAMPAIGNS_InvalidPhones
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
			,  CALL_MARKETING_ID  
			,  PROSPECT_LIST_ID   
			,  PHONE_WORK         
		  from vwCAMPAIGNS_DoNotCall
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
			,  CALL_MARKETING_ID  
			,  PROSPECT_LIST_ID   
			,  PHONE_WORK         
		  from vwCAMPAIGNS_ExemptPhones
		 where CAMPAIGN_ID = @ID;
	end -- if;
  end
GO

Grant Execute on dbo.spCAMPAIGNS_GenerateCalls to public;
GO

