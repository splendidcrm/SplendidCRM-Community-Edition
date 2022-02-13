if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILMAN_RemoveDuplicates' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILMAN_RemoveDuplicates;
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
-- 11/01/2015 Paul.  Include COMPUTED_EMAIL1 in table to increase performance of dup removal. 
Create Procedure dbo.spEMAILMAN_RemoveDuplicates
	( @CAMPAIGN_ID      uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on

	declare @ID              uniqueidentifier;
	declare @MERGE_ID        uniqueidentifier;
	declare @RECIPIENT_EMAIL nvarchar(100);
	declare @STATUS          nvarchar(1000);

-- #if SQL_Server /*
	-- 11/01/2015 Paul.  Include COMPUTED_EMAIL1 in table to increase performance of dup removal. 
	declare duplicate_cursor cursor static for
	select ID
	     , COMPUTED_EMAIL1
	  from vwEMAILMAN
	 where CAMPAIGN_ID = @CAMPAIGN_ID
	   and ID in (select ID 
	                from      vwEMAILMAN PROSPECTS
	               inner join (select COMPUTED_EMAIL1
	                             from vwEMAILMAN
	                            where CAMPAIGN_ID = @CAMPAIGN_ID
	                            group by COMPUTED_EMAIL1
	                            having count(*) >= 2
	                          ) DUPS
	                        on DUPS.COMPUTED_EMAIL1 = PROSPECTS.COMPUTED_EMAIL1
	               where CAMPAIGN_ID = @CAMPAIGN_ID
	             ) 
	 order by RELATED_TYPE, COMPUTED_EMAIL1;
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

	open duplicate_cursor;
	fetch next from duplicate_cursor into @ID, @RECIPIENT_EMAIL;
	while @@FETCH_STATUS = 0 begin -- do
		if exists(select * from EMAILMAN where ID = @ID and DELETED = 0) begin -- then
			set @STATUS = cast(@ID as char(36)) + ' ' + @RECIPIENT_EMAIL;
			print @STATUS;
-- #if SQL_Server /*
			declare merge_cursor cursor for
			select ID
			  from vwEMAILMAN
			 where COMPUTED_EMAIL1 = @RECIPIENT_EMAIL
			   and ID     <> @ID;
-- #endif SQL_Server */
			
			open merge_cursor;
			fetch next from merge_cursor into @MERGE_ID;
/* -- #if Oracle
			IF merge_cursor%NOTFOUND THEN
				StoO_sqlstatus := 2;
				StoO_fetchstatus := -1;
			ELSE
				StoO_sqlstatus := 0;
				StoO_fetchstatus := 0;
			END IF;
-- #endif Oracle */
			while @@FETCH_STATUS = 0 begin -- do
				set @STATUS = '    ' + cast(@MERGE_ID as char(36));
				print @STATUS;

				insert into CAMPAIGN_LOG
					( ID                 
					, CREATED_BY         
					, DATE_ENTERED       
					, MODIFIED_USER_ID   
					, DATE_MODIFIED      
					, CAMPAIGN_ID        
--					, TARGET_TRACKER_KEY 
					, TARGET_ID          
					, TARGET_TYPE        
					, ACTIVITY_TYPE      
					, ACTIVITY_DATE      
--					, RELATED_ID         
--					, RELATED_TYPE       
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
--					,  null               
					,  RELATED_ID         
					,  RELATED_TYPE       
					, N'duplicate email'  
					,  getdate()          
--					,  null               
--					,  null               
					,  MARKETING_ID       
					,  LIST_ID            
					,  RECIPIENT_EMAIL    
				  from vwEMAILMAN_List
				 where ID = @MERGE_ID;

				update EMAILMAN
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , DELETED           = 1
				 where ID = @MERGE_ID;
				fetch next from merge_cursor into @MERGE_ID;
/* -- #if Oracle
				IF merge_cursor%NOTFOUND THEN
					StoO_sqlstatus := 2;
					StoO_fetchstatus := -1;
				ELSE
					StoO_sqlstatus := 0;
					StoO_fetchstatus := 0;
				END IF;
-- #endif Oracle */
			end -- while;
			close merge_cursor;
			deallocate merge_cursor;
		end -- if;

		fetch next from duplicate_cursor into @ID, @RECIPIENT_EMAIL;
/* -- #if Oracle
		IF duplicate_cursor%NOTFOUND THEN
			StoO_sqlstatus := 2;
			StoO_fetchstatus := -1;
		ELSE
			StoO_sqlstatus := 0;
			StoO_fetchstatus := 0;
		END IF;
-- #endif Oracle */
	end -- while;
	close duplicate_cursor;

	deallocate duplicate_cursor;
  end
GO

Grant Execute on dbo.spEMAILMAN_RemoveDuplicates to public;
GO

