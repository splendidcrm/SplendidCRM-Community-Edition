if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGNS_Duplicate' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGNS_Duplicate;
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
-- 06/23/2013 Paul.  Add copy-of. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spCAMPAIGNS_Duplicate
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @DUPLICATE_ID      uniqueidentifier
	, @COPY_OF           nvarchar(50)
	)
as
  begin
	set nocount on

	declare @TEMP_NAME              nvarchar(50);
	declare @PROSPECT_LIST_ID       uniqueidentifier;
	declare @CAMPAIGN_TRKRS_ID      uniqueidentifier;
	declare @NEW_CAMPAIGN_TRKRS_ID  uniqueidentifier;
	declare @EMAIL_MARKETING_ID     uniqueidentifier;
	declare @NEW_EMAIL_MARKETING_ID uniqueidentifier;
	declare @TEMP_TRACKER_KEY       nvarchar(30);

	
-- #if SQL_Server /*
	declare prospect_list_cursor cursor for
	select PROSPECT_LIST_ID
	  from vwCAMPAIGNS_PROSPECT_LISTS
	 where CAMPAIGN_ID = @DUPLICATE_ID
	 order by NAME;

	declare campaign_trkrs_cursor cursor for
	select ID
	  from vwCAMPAIGNS_CAMPAIGN_TRKRS
	 where CAMPAIGN_ID = @DUPLICATE_ID
	 order by TRACKER_KEY;

	declare email_marketing_cursor cursor for
	select ID
	  from vwCAMPAIGNS_EMAIL_MARKETING
	 where CAMPAIGN_ID = @DUPLICATE_ID
	 order by NAME;
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

	if not exists(select * from CAMPAIGNS where ID = @DUPLICATE_ID and DELETED = 0) begin -- then
		raiserror(N'Cannot duplicate non-existent campaign.  ', 16, 1);
		return;
	end -- if;

	select @TEMP_NAME = replace(isnull(@COPY_OF, N'{0}'), N'{0}', NAME)
	  from CAMPAIGNS
	 where ID      = @DUPLICATE_ID
	   and DELETED = 0;

	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
	end -- if;
	exec dbo.spNUMBER_SEQUENCES_Formatted 'CAMPAIGNS.TRACKER_KEY', 1, @TEMP_TRACKER_KEY out;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	insert into CAMPAIGNS
		( ID                       
		, CREATED_BY               
		, DATE_ENTERED             
		, MODIFIED_USER_ID         
		, DATE_MODIFIED            
		, DATE_MODIFIED_UTC        
		, ASSIGNED_USER_ID         
		, TRACKER_KEY              
		, NAME                     
		, REFER_URL                
		, TRACKER_TEXT             
		, START_DATE               
		, END_DATE                 
		, STATUS                   
		, BUDGET                   
		, BUDGET_USDOLLAR          
		, EXPECTED_COST            
		, EXPECTED_COST_USDOLLAR   
		, ACTUAL_COST              
		, ACTUAL_COST_USDOLLAR     
		, EXPECTED_REVENUE         
		, EXPECTED_REVENUE_USDOLLAR
		, CAMPAIGN_TYPE            
		, OBJECTIVE                
		, CONTENT                  
		, CURRENCY_ID              
		, IMPRESSIONS              
		, FREQUENCY                
		, TEAM_ID                  
		, TEAM_SET_ID              
		, ASSIGNED_SET_ID          
		)
	select @ID                      
		, @MODIFIED_USER_ID        
		,  getdate()               
		, @MODIFIED_USER_ID        
		,  getdate()               
		,  getutcdate()            
		, ASSIGNED_USER_ID         
		, @TEMP_TRACKER_KEY        
		, @TEMP_NAME               
		, REFER_URL                
		, TRACKER_TEXT             
		, START_DATE               
		, END_DATE                 
		, STATUS                   
		, BUDGET                   
		, BUDGET_USDOLLAR          
		, EXPECTED_COST            
		, EXPECTED_COST_USDOLLAR   
		, ACTUAL_COST              
		, ACTUAL_COST_USDOLLAR     
		, EXPECTED_REVENUE         
		, EXPECTED_REVENUE_USDOLLAR
		, CAMPAIGN_TYPE            
		, OBJECTIVE                
		, CONTENT                  
		, CURRENCY_ID              
		, IMPRESSIONS              
		, FREQUENCY                
		, TEAM_ID                  
		, TEAM_SET_ID              
		, ASSIGNED_SET_ID          
	  from CAMPAIGNS
	 where ID = @DUPLICATE_ID;

	insert into CAMPAIGNS_CSTM ( ID_C ) values ( @ID );

	open prospect_list_cursor;
	fetch next from prospect_list_cursor into @PROSPECT_LIST_ID;
	while @@FETCH_STATUS = 0 begin -- do
		exec dbo.spPROSPECT_LIST_CAMPAIGNS_Update @MODIFIED_USER_ID, @PROSPECT_LIST_ID, @ID;
		fetch next from prospect_list_cursor into @PROSPECT_LIST_ID;
/* -- #if Oracle
		IF prospect_list_cursor%NOTFOUND THEN
			StoO_sqlstatus := 2;
			StoO_fetchstatus := -1;
		ELSE
			StoO_sqlstatus := 0;
			StoO_fetchstatus := 0;
		END IF;
-- #endif Oracle */
	end -- while;
	close prospect_list_cursor;
	deallocate prospect_list_cursor;

	open campaign_trkrs_cursor;
	fetch next from campaign_trkrs_cursor into @CAMPAIGN_TRKRS_ID;
/* -- #if Oracle
	IF campaign_trkrs_cursor%NOTFOUND THEN
		StoO_sqlstatus := 2;
		StoO_fetchstatus := -1;
	ELSE
		StoO_sqlstatus := 0;
		StoO_fetchstatus := 0;
	END IF;
-- #endif Oracle */
	while @@FETCH_STATUS = 0 begin -- do
		set @NEW_CAMPAIGN_TRKRS_ID = null;
		exec dbo.spCAMPAIGN_TRKRS_Duplicate @NEW_CAMPAIGN_TRKRS_ID out, @MODIFIED_USER_ID, @CAMPAIGN_TRKRS_ID, @ID;
		fetch next from campaign_trkrs_cursor into @CAMPAIGN_TRKRS_ID;
/* -- #if Oracle
		IF campaign_trkrs_cursor%NOTFOUND THEN
			StoO_sqlstatus := 2;
			StoO_fetchstatus := -1;
		ELSE
			StoO_sqlstatus := 0;
			StoO_fetchstatus := 0;
		END IF;
-- #endif Oracle */
	end -- while;
	close campaign_trkrs_cursor;
	deallocate campaign_trkrs_cursor;

	open email_marketing_cursor;
	fetch next from email_marketing_cursor into @EMAIL_MARKETING_ID;
/* -- #if Oracle
	IF email_marketing_cursor%NOTFOUND THEN
		StoO_sqlstatus := 2;
		StoO_fetchstatus := -1;
	ELSE
		StoO_sqlstatus := 0;
		StoO_fetchstatus := 0;
	END IF;
-- #endif Oracle */
	while @@FETCH_STATUS = 0 begin -- do
		set @NEW_EMAIL_MARKETING_ID = null;
		exec dbo.spEMAIL_MARKETING_Duplicate @NEW_EMAIL_MARKETING_ID out, @MODIFIED_USER_ID, @EMAIL_MARKETING_ID, @ID;
		fetch next from email_marketing_cursor into @EMAIL_MARKETING_ID;
/* -- #if Oracle
		IF email_marketing_cursor%NOTFOUND THEN
			StoO_sqlstatus := 2;
			StoO_fetchstatus := -1;
		ELSE
			StoO_sqlstatus := 0;
			StoO_fetchstatus := 0;
		END IF;
-- #endif Oracle */
	end -- while;
	close email_marketing_cursor;
	deallocate email_marketing_cursor;
  end
GO

Grant Execute on dbo.spCAMPAIGNS_Duplicate to public;
GO

