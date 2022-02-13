if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCALLS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCALLS_Update;
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
-- 12/29/2007 Paul.  Add TEAM_ID so that it is not updated separately. 
-- 01/26/2009 Paul.  The current user is accepted by default. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 08/23/2009 Paul.  Decrease set list so that index plus ID will be less than 900 bytes. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
-- 07/15/2012 Paul.  If the invitee list is null, then don't change the relationships. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 12/26/2012 Paul.  Add EMAIL_REMINDER_TIME. 
-- 03/07/2013 Paul.  Add ALL_DAY_EVENT. 
-- 03/20/2013 Paul.  Add REPEAT fields. 
-- 09/06/2013 Paul.  Increase NAME size to 150 to support Asterisk. 
-- 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
-- 01/20/2015 Paul.  Prevent a repeated record from generating other repeats. 
-- 05/17/2017 Paul.  Add Tags module. 
-- 06/07/2017 Paul.  We need to make sure not to save reminder of 0 or -1 as values not in dropdown. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spCALLS_Update
	( @ID                  uniqueidentifier output
	, @MODIFIED_USER_ID    uniqueidentifier
	, @ASSIGNED_USER_ID    uniqueidentifier
	, @NAME                nvarchar(150)
	, @DURATION_HOURS      int
	, @DURATION_MINUTES    int
	, @DATE_TIME           datetime
	, @PARENT_TYPE         nvarchar(25)
	, @PARENT_ID           uniqueidentifier
	, @STATUS              nvarchar(25)
	, @DIRECTION           nvarchar(25)
	, @REMINDER_TIME       int
	, @DESCRIPTION         nvarchar(max)
	, @INVITEE_LIST        varchar(8000)
	, @TEAM_ID             uniqueidentifier = null
	, @TEAM_SET_LIST       varchar(8000) = null
	, @EMAIL_REMINDER_TIME int = null
	, @ALL_DAY_EVENT       bit = null
	, @REPEAT_TYPE         nvarchar(25) = null
	, @REPEAT_INTERVAL     int = null
	, @REPEAT_DOW          nvarchar(7) = null
	, @REPEAT_UNTIL        datetime = null
	, @REPEAT_COUNT        int = null
	, @SMS_REMINDER_TIME   int = null
	, @TAG_SET_NAME        nvarchar(4000) = null
	, @IS_PRIVATE          bit = null
	, @ASSIGNED_SET_LIST   varchar(8000) = null
	)
as
  begin
	set nocount on
	
	declare @DATE_START             datetime;
	declare @TIME_START             datetime;
	declare @DATE_END               datetime;
	declare @TEAM_SET_ID            uniqueidentifier;
	declare @ASSIGNED_SET_ID        uniqueidentifier;
	declare @TEMP_DATE_TIME         datetime;
	declare @TEMP_DURATION_HOURS    int;
	declare @TEMP_DURATION_MINUTES  int;
	-- 03/22/2013 Paul.  Add REPEAT fields. 
	declare @MAX_REPEAT_COUNT       int;
	declare @REPEAT_INDEX           int;
	-- 08/08/2013 Paul.  Move @WEEKDAY_CHAR before @@WEEKDAY to ease migration to Oracle. 
	declare @WEEKDAY_CHAR           char(1);
	declare @WEEKDAY                int;
	declare @WEEK_START             datetime;
	declare @REPEAT_ID              uniqueidentifier;
	declare @REPEAT_UTC             datetime;
	declare @TEMP_REPEAT_INTERVAL   int;
	declare @TEMP_REPEAT_DOW        nvarchar(7);
	declare @TEMP_REPEAT_UNTIL      datetime;
	declare @TEMP_REPEAT_COUNT      int;
	-- 06/07/2017 Paul.  We need to make sure not to save reminder of 0 or -1 as values not in dropdown. 
	declare @TEMP_REMINDER_TIME       int;
	declare @TEMP_EMAIL_REMINDER_TIME int;
	declare @TEMP_SMS_REMINDER_TIME   int;
	set @TEMP_REMINDER_TIME       = @REMINDER_TIME      ;
	set @TEMP_EMAIL_REMINDER_TIME = @EMAIL_REMINDER_TIME;
	set @TEMP_SMS_REMINDER_TIME   = @SMS_REMINDER_TIME  ;
	if @TEMP_REMINDER_TIME <= 0 begin -- then
		set @TEMP_REMINDER_TIME = null;
	end -- if;
	if @TEMP_EMAIL_REMINDER_TIME <= 0 begin -- then
		set @TEMP_EMAIL_REMINDER_TIME = null;
	end -- if;
	if @TEMP_SMS_REMINDER_TIME <= 0 begin -- then
		set @TEMP_SMS_REMINDER_TIME = null;
	end -- if;

	-- 03/07/2013 Paul.  Add ALL_DAY_EVENT. 
	set @TEMP_DATE_TIME        = @DATE_TIME       ;
	set @TEMP_DURATION_HOURS   = @DURATION_HOURS  ;
	set @TEMP_DURATION_MINUTES = @DURATION_MINUTES;
	if @ALL_DAY_EVENT = 1 begin -- then
		set @TEMP_DURATION_HOURS   = 24;
		set @TEMP_DURATION_MINUTES =  0;
		-- 03/07/2013 Paul.  The time will be truncated in the code-behind. 
		--set @TEMP_DATE_TIME        = dbo.fnDateOnly(@TEMP_DATE_TIME);
	end -- if;
	-- 03/22/2013 Paul.  Add recurring records. 
	if @REPEAT_TYPE = N'Daily' or @REPEAT_TYPE = N'Weekly' or @REPEAT_TYPE = N'Monthly' or @REPEAT_TYPE = N'Yearly' begin -- then
		set @TEMP_REPEAT_INTERVAL = @REPEAT_INTERVAL;
		set @TEMP_REPEAT_UNTIL    = @REPEAT_UNTIL   ;
		set @TEMP_REPEAT_COUNT    = @REPEAT_COUNT   ;
		if @TEMP_REPEAT_INTERVAL is null or @TEMP_REPEAT_INTERVAL < 1 begin -- then
			set @TEMP_REPEAT_INTERVAL = 1;
		end -- if;
		if @TEMP_REPEAT_COUNT is null begin -- then
			set @TEMP_REPEAT_COUNT = 0;
		end else if @TEMP_REPEAT_COUNT < 0 begin -- then
			set @TEMP_REPEAT_COUNT = 1;
		end -- if;
		if @REPEAT_TYPE = N'Weekly' begin -- then
			set @TEMP_REPEAT_DOW = @REPEAT_DOW;
			-- @TEMP_REPEAT_DOW pattern uses 0-6 to mean Sunday-Saturday. 
			set @WEEKDAY      = dbo.fnDatePart(N'weekday', @DATE_TIME) - 1;
			set @WEEK_START   = dbo.fnDateAdd(N'day', -@WEEKDAY, @DATE_TIME);
			set @WEEKDAY_CHAR = cast(@WEEKDAY as char(1));
			-- 03/26/2013 Paul.  If the first day is not included in the DOW list, then use our next procedure to get the first day. 
			if charindex(@WEEKDAY_CHAR, @REPEAT_DOW, 1) = 0 begin -- then
				set @REPEAT_INDEX = 1;
				exec dbo.spCALENDAR_Next @DATE_TIME, @REPEAT_TYPE, @TEMP_REPEAT_INTERVAL, @TEMP_REPEAT_DOW, @REPEAT_INDEX, @TEMP_DATE_TIME output, @WEEK_START output, @WEEKDAY output;
			end -- if;
		end -- if;
	end -- if;

	-- 12/15/2005 Paul.  Oracle uses fractions to add hours and minutes to date.  24 hours, 1440 minutes, 86400 seconds in a day. 
	-- 04/02/2006 Paul.  Use date functions so that the conversions will be simplified. 
	set @DATE_END   = dbo.fnDateAdd_Minutes(@DURATION_MINUTES, dbo.fnDateAdd_Hours(@DURATION_HOURS, @TEMP_DATE_TIME));
	set @DATE_START = dbo.fnStoreDateOnly(@TEMP_DATE_TIME);
	set @TIME_START = dbo.fnStoreTimeOnly(@TEMP_DATE_TIME);

	-- 08/22/2009 Paul.  Normalize the team set by placing the primary ID first, then order list by ID and the name by team names. 
	-- 08/23/2009 Paul.  Use a team set so that team name changes can propagate. 
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;

	if not exists(select * from CALLS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into CALLS
			( ID                 
			, CREATED_BY         
			, DATE_ENTERED       
			, MODIFIED_USER_ID   
			, DATE_MODIFIED      
			, DATE_MODIFIED_UTC  
			, ASSIGNED_USER_ID   
			, NAME               
			, DURATION_HOURS     
			, DURATION_MINUTES   
			, DATE_START         
			, TIME_START         
			, DATE_END           
			, PARENT_TYPE        
			, PARENT_ID          
			, STATUS             
			, DIRECTION          
			, REMINDER_TIME      
			, DESCRIPTION        
			, TEAM_ID            
			, TEAM_SET_ID        
			, EMAIL_REMINDER_TIME
			, SMS_REMINDER_TIME  
			, ALL_DAY_EVENT      
			, REPEAT_TYPE        
			, REPEAT_INTERVAL    
			, REPEAT_DOW         
			, REPEAT_UNTIL       
			, REPEAT_COUNT       
			, IS_PRIVATE         
			, ASSIGNED_SET_ID    
			)
		values
			( @ID                 
			, @MODIFIED_USER_ID   
			,  getdate()          
			, @MODIFIED_USER_ID   
			,  getdate()          
			,  getutcdate()       
			, @ASSIGNED_USER_ID   
			, @NAME               
			, @TEMP_DURATION_HOURS  
			, @TEMP_DURATION_MINUTES
			, @DATE_START         
			, @TIME_START         
			, @DATE_END           
			, @PARENT_TYPE        
			, @PARENT_ID          
			, @STATUS             
			, @DIRECTION          
			, @TEMP_REMINDER_TIME      
			, @DESCRIPTION        
			, @TEAM_ID            
			, @TEAM_SET_ID        
			, @TEMP_EMAIL_REMINDER_TIME
			, @TEMP_SMS_REMINDER_TIME  
			, @ALL_DAY_EVENT      
			, @REPEAT_TYPE        
			, @TEMP_REPEAT_INTERVAL    
			, @TEMP_REPEAT_DOW         
			, @TEMP_REPEAT_UNTIL       
			, @TEMP_REPEAT_COUNT       
			, @IS_PRIVATE         
			, @ASSIGNED_SET_ID    
			);
	end else begin
		update CALLS
		   set MODIFIED_USER_ID    = @MODIFIED_USER_ID   
		     , DATE_MODIFIED       =  getdate()          
		     , DATE_MODIFIED_UTC   =  getutcdate()       
		     , ASSIGNED_USER_ID    = @ASSIGNED_USER_ID   
		     , NAME                = @NAME               
		     , DURATION_HOURS      = @TEMP_DURATION_HOURS  
		     , DURATION_MINUTES    = @TEMP_DURATION_MINUTES
		     , DATE_START          = @DATE_START         
		     , TIME_START          = @TIME_START         
		     , DATE_END            = @DATE_END           
		     , PARENT_TYPE         = @PARENT_TYPE        
		     , PARENT_ID           = @PARENT_ID          
		     , STATUS              = @STATUS             
		     , DIRECTION           = @DIRECTION          
		     , REMINDER_TIME       = @TEMP_REMINDER_TIME      
		     , DESCRIPTION         = @DESCRIPTION        
		     , TEAM_ID             = @TEAM_ID            
		     , TEAM_SET_ID         = @TEAM_SET_ID        
		     , EMAIL_REMINDER_TIME = @TEMP_EMAIL_REMINDER_TIME
		     , SMS_REMINDER_TIME   = @TEMP_SMS_REMINDER_TIME  
		     , ALL_DAY_EVENT       = @ALL_DAY_EVENT      
		     , REPEAT_TYPE         = @REPEAT_TYPE        
		     , REPEAT_INTERVAL     = @TEMP_REPEAT_INTERVAL    
		     , REPEAT_DOW          = @TEMP_REPEAT_DOW         
		     , REPEAT_UNTIL        = @TEMP_REPEAT_UNTIL       
		     , REPEAT_COUNT        = @TEMP_REPEAT_COUNT       
		     , IS_PRIVATE          = @IS_PRIVATE         
		     , ASSIGNED_SET_ID     = @ASSIGNED_SET_ID    
		 where ID                  = @ID                 ;
		
		-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
		exec dbo.spSUGARFAVORITES_UpdateName @MODIFIED_USER_ID, @ID, @NAME;
	end -- if;

	-- 03/06/2006 Paul.  If insert fails, then the rest will as well. Just display the one error. 
	if @@ERROR = 0 begin -- then
		if not exists(select * from CALLS_CSTM where ID_C = @ID) begin -- then
			insert into CALLS_CSTM ( ID_C ) values ( @ID );
		end -- if;
		
		-- 08/21/2009 Paul.  Add or remove the team relationship records. 
		-- 08/30/2009 Paul.  Instead of using @TEAM_SET_LIST, use the @TEAM_SET_ID to build the module-specific team relationships. 
		-- 08/31/2009 Paul.  Instead of managing a separate teams relationship, we will leverage TEAM_SETS_TEAMS. 
		-- exec dbo.spCALLS_TEAMS_Update @ID, @MODIFIED_USER_ID, @TEAM_SET_ID;
		
		-- 07/15/2012 Paul.  If the invitee list is null, then don't change the relationships. 
		-- This should prevent the Outlook Plug-in from resetting the relationships. 
		if @INVITEE_LIST is not null begin -- then
			-- BEGIN Oracle Exception
				update CALLS_USERS
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     =  getdate()        
				     , DATE_MODIFIED_UTC =  getutcdate()     
				     , DELETED           = 1                 
				 where CALL_ID           = @ID               ;
			-- END Oracle Exception
			
			-- BEGIN Oracle Exception
				update CALLS_CONTACTS
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     =  getdate()        
				     , DATE_MODIFIED_UTC =  getutcdate()     
				     , DELETED           = 1                 
				 where CALL_ID           = @ID               ;
			-- END Oracle Exception
			
			-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
			-- BEGIN Oracle Exception
				update CALLS_LEADS
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     =  getdate()        
				     , DATE_MODIFIED_UTC =  getutcdate()     
				     , DELETED           = 1                 
				 where CALL_ID           = @ID               ;
			-- END Oracle Exception
			
			exec dbo.spCALLS_InviteeMassUpdate @MODIFIED_USER_ID, @ID, @INVITEE_LIST, 1;
		end -- if;
		-- 03/06/2006 Paul.  Assigned user is optional, so only try to assign if provided. 
		if dbo.fnIsEmptyGuid(@ASSIGNED_USER_ID) = 0 begin -- then
			-- 01/26/2009 Paul.  The current user is accepted by default. 
			if @MODIFIED_USER_ID = @ASSIGNED_USER_ID begin -- then
				-- 01/26/2009 Paul.  Avoid updating the record if it is already correct. 
				if not exists(select * from CALLS_USERS where CALL_ID = @ID and USER_ID = @MODIFIED_USER_ID and ACCEPT_STATUS = N'accept' and DELETED = 0) begin -- then
					exec dbo.spCALLS_USERS_Update @MODIFIED_USER_ID, @ID, @ASSIGNED_USER_ID, 1, N'accept';
				end -- if;
			end else begin
				exec dbo.spCALLS_USERS_Update @MODIFIED_USER_ID, @ID, @ASSIGNED_USER_ID, 1, null;
			end -- if;
		end -- if;
		
		if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
			-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
			exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @PARENT_ID, @PARENT_TYPE;
		end -- if;
	end -- if;

	-- 03/22/2013 Paul.  Add recurring records. 
	if @REPEAT_TYPE = N'Daily' or (@REPEAT_TYPE = N'Weekly' and (@TEMP_REPEAT_DOW is not null and len(@TEMP_REPEAT_DOW) > 0)) or @REPEAT_TYPE = N'Monthly'  or @REPEAT_TYPE = N'Yearly' begin -- then
		set @MAX_REPEAT_COUNT = dbo.fnCONFIG_Int(N'calendar.max_repeat_count');
		-- SQL Server weekday uses Sunday = 1, Saturday = 7
		-- @TEMP_REPEAT_DOW pattern uses 0-6 to mean Sunday-Saturday. 
		set @WEEKDAY      = dbo.fnDatePart(N'weekday', @DATE_START) - 1;
		set @WEEK_START   = dbo.fnDateAdd(N'day', -@WEEKDAY, @DATE_START);
		set @REPEAT_INDEX = 1;
		set @REPEAT_ID    = null;
		-- 03/22/2013 Paul.  Any records not updated after @REPEAT_UTC should be deleted. 
		set @REPEAT_UTC   = getutcdate();

		-- 01/20/2015 Paul.  Prevent a repeated record from generating other repeats. 
		if exists(select * from CALLS where ID = @ID and REPEAT_PARENT_ID is null and DELETED = 0) begin -- then
			exec dbo.spCALENDAR_Next @DATE_TIME, @REPEAT_TYPE, @TEMP_REPEAT_INTERVAL, @TEMP_REPEAT_DOW, @REPEAT_INDEX, @TEMP_DATE_TIME output, @WEEK_START output, @WEEKDAY output;
			-- 03/22/2013 Paul.  @WEEKDAY = -1 is an error condition. 
			-- 03/24/2013 Paul.  Multiply COUNT by DOW so that COUNT is the number of weeks, not the number of occurrences. 
			-- 03/25/2013 Paul.  Google Calendar uses the COUNT as an absolute value, not the number of weeks. 
			-- 03/25/2013 Paul.  Less than @TEMP_REPEAT_COUNT so that a count of 1 means no repeat. 
			-- 03/25/2013 Paul.  Google Calendar uses UNTIL as less than or equal to. 
			while @WEEKDAY >= 0 and (@TEMP_REPEAT_COUNT = 0 or ((@REPEAT_TYPE = 'Weekly' and @REPEAT_INDEX < @TEMP_REPEAT_COUNT) or (@REPEAT_TYPE <> 'Weekly' and @REPEAT_INDEX < @TEMP_REPEAT_COUNT))) and @REPEAT_INDEX < @MAX_REPEAT_COUNT and (@TEMP_REPEAT_UNTIL is null or @TEMP_DATE_TIME <= @TEMP_REPEAT_UNTIL) begin -- do
				--print cast(@REPEAT_INDEX as char(3)) + '.  ' + convert(varchar(10), @TEMP_DATE_TIME, 101) + '  ' + datename(weekday, @TEMP_DATE_TIME);
				set @DATE_END   = dbo.fnDateAdd_Minutes(@DURATION_MINUTES, dbo.fnDateAdd_Hours(@DURATION_HOURS, @TEMP_DATE_TIME));
				set @DATE_START = dbo.fnStoreDateOnly(@TEMP_DATE_TIME);
				set @TIME_START = dbo.fnStoreTimeOnly(@TEMP_DATE_TIME);
				
				set @REPEAT_ID = null;
				-- 03/22/2013 Paul.  First try and find an existing record to see if we can update it. 
				select @REPEAT_ID = ID
				  from CALLS
				 where DELETED          = 0
				   and REPEAT_PARENT_ID = @ID
				   and DATE_START       = @DATE_START;
				if @REPEAT_ID is null begin -- then
					set @REPEAT_ID = newid();
					-- 03/22/2013 Paul.  Make sure to set the REPEAT_PARENT_ID field. 
					insert into CALLS
						( ID                 
						, CREATED_BY         
						, DATE_ENTERED       
						, MODIFIED_USER_ID   
						, DATE_MODIFIED      
						, DATE_MODIFIED_UTC  
						, ASSIGNED_USER_ID   
						, NAME               
						, DURATION_HOURS     
						, DURATION_MINUTES   
						, DATE_START         
						, TIME_START         
						, DATE_END           
						, PARENT_TYPE        
						, PARENT_ID          
						, STATUS             
						, DIRECTION          
						, REMINDER_TIME      
						, DESCRIPTION        
						, TEAM_ID            
						, TEAM_SET_ID        
						, EMAIL_REMINDER_TIME
						, SMS_REMINDER_TIME  
						, ALL_DAY_EVENT      
						, REPEAT_TYPE        
						, REPEAT_INTERVAL    
						, REPEAT_DOW         
						, REPEAT_UNTIL       
						, REPEAT_COUNT       
						, REPEAT_PARENT_ID   
						, RECURRING_SOURCE   
						, IS_PRIVATE         
						, ASSIGNED_SET_ID    
						)
					values
						( @REPEAT_ID          
						, @MODIFIED_USER_ID   
						,  getdate()          
						, @MODIFIED_USER_ID   
						,  getdate()          
						,  getutcdate()       
						, @ASSIGNED_USER_ID   
						, @NAME               
						, @TEMP_DURATION_HOURS  
						, @TEMP_DURATION_MINUTES
						, @DATE_START         
						, @TIME_START         
						, @DATE_END           
						, @PARENT_TYPE        
						, @PARENT_ID          
						, @STATUS             
						, @DIRECTION          
						, @TEMP_REMINDER_TIME      
						, @DESCRIPTION        
						, @TEAM_ID            
						, @TEAM_SET_ID        
						, @TEMP_EMAIL_REMINDER_TIME
						, @TEMP_SMS_REMINDER_TIME  
						, @ALL_DAY_EVENT      
						, @REPEAT_TYPE        
						, @TEMP_REPEAT_INTERVAL    
						, @TEMP_REPEAT_DOW         
						, @TEMP_REPEAT_UNTIL       
						, @TEMP_REPEAT_COUNT       
						, @ID                 
						, N'Sugar'            
						, @IS_PRIVATE         
						, @ASSIGNED_SET_ID    
						);
					insert into CALLS_CSTM ( ID_C ) values ( @REPEAT_ID );
				end else begin
					update CALLS
					   set MODIFIED_USER_ID    = @MODIFIED_USER_ID   
					     , DATE_MODIFIED       =  getdate()          
					     , DATE_MODIFIED_UTC   =  getutcdate()       
					     , ASSIGNED_USER_ID    = @ASSIGNED_USER_ID   
					     , NAME                = @NAME               
					     , DURATION_HOURS      = @TEMP_DURATION_HOURS  
					     , DURATION_MINUTES    = @TEMP_DURATION_MINUTES
					     , DATE_START          = @DATE_START         
					     , TIME_START          = @TIME_START         
					     , DATE_END            = @DATE_END           
					     , PARENT_TYPE         = @PARENT_TYPE        
					     , PARENT_ID           = @PARENT_ID          
					     , STATUS              = @STATUS             
					     , DIRECTION           = @DIRECTION          
					     , REMINDER_TIME       = @TEMP_REMINDER_TIME      
					     , DESCRIPTION         = @DESCRIPTION        
					     , TEAM_ID             = @TEAM_ID            
					     , TEAM_SET_ID         = @TEAM_SET_ID        
					     , EMAIL_REMINDER_TIME = @TEMP_EMAIL_REMINDER_TIME
					     , SMS_REMINDER_TIME   = @TEMP_SMS_REMINDER_TIME  
					     , ALL_DAY_EVENT       = @ALL_DAY_EVENT      
					     , REPEAT_TYPE         = @REPEAT_TYPE        
					     , REPEAT_INTERVAL     = @TEMP_REPEAT_INTERVAL    
					     , REPEAT_DOW          = @TEMP_REPEAT_DOW         
					     , REPEAT_UNTIL        = @TEMP_REPEAT_UNTIL       
					     , REPEAT_COUNT        = @TEMP_REPEAT_COUNT       
					     , IS_PRIVATE          = @IS_PRIVATE         
					     , ASSIGNED_SET_ID     = @ASSIGNED_SET_ID    
					 where ID                  = @REPEAT_ID;
					if @INVITEE_LIST is not null begin -- then
						-- BEGIN Oracle Exception
							update CALLS_USERS
							   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
							     , DATE_MODIFIED     =  getdate()        
							     , DATE_MODIFIED_UTC =  getutcdate()     
							     , DELETED           = 1                 
							 where CALL_ID           = @REPEAT_ID;
						-- END Oracle Exception
						
						-- BEGIN Oracle Exception
							update CALLS_CONTACTS
							   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
							     , DATE_MODIFIED     =  getdate()        
							     , DATE_MODIFIED_UTC =  getutcdate()     
							     , DELETED           = 1                 
							 where CALL_ID           = @REPEAT_ID;
						-- END Oracle Exception
						
						-- BEGIN Oracle Exception
							update CALLS_LEADS
							   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
							     , DATE_MODIFIED     =  getdate()        
							     , DATE_MODIFIED_UTC =  getutcdate()     
							     , DELETED           = 1                 
							 where CALL_ID           = @REPEAT_ID;
						-- END Oracle Exception
					end -- if;
				end -- if;
				if @INVITEE_LIST is not null begin -- then
					exec dbo.spCALLS_InviteeMassUpdate @MODIFIED_USER_ID, @REPEAT_ID, @INVITEE_LIST, 1;
				end -- if;
				if dbo.fnIsEmptyGuid(@ASSIGNED_USER_ID) = 0 begin -- then
					if @MODIFIED_USER_ID = @ASSIGNED_USER_ID begin -- then
						if not exists(select * from CALLS_USERS where CALL_ID = @REPEAT_ID and USER_ID = @MODIFIED_USER_ID and ACCEPT_STATUS = N'accept' and DELETED = 0) begin -- then
							exec dbo.spCALLS_USERS_Update @MODIFIED_USER_ID, @REPEAT_ID, @ASSIGNED_USER_ID, 1, N'accept';
						end -- if;
					end else begin
						exec dbo.spCALLS_USERS_Update @MODIFIED_USER_ID, @REPEAT_ID, @ASSIGNED_USER_ID, 1, null;
					end -- if;
				end -- if;
	
				-- 03/22/2013 Paul.  Any records that were not updated should be deleted as they would be on a different repeat pattern. 
				-- Don't delete any old meetings as the old meetings may have important information. 
				-- BEGIN Oracle Exception
					update CALLS_USERS
					   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
					     , DATE_MODIFIED     =  getdate()        
					     , DATE_MODIFIED_UTC =  getutcdate()     
					     , DELETED           = 1                 
					 where CALL_ID in (select ID from CALLS where REPEAT_PARENT_ID = @ID and DATE_MODIFIED_UTC < @REPEAT_UTC and DATE_START > getdate() and DELETED = 0);
				-- END Oracle Exception
				
				-- BEGIN Oracle Exception
					update CALLS_CONTACTS
					   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
					     , DATE_MODIFIED     =  getdate()        
					     , DATE_MODIFIED_UTC =  getutcdate()     
					     , DELETED           = 1                 
					 where CALL_ID in (select ID from CALLS where REPEAT_PARENT_ID = @ID and DATE_MODIFIED_UTC < @REPEAT_UTC and DATE_START > getdate() and DELETED = 0);
				-- END Oracle Exception
				
				-- BEGIN Oracle Exception
					update CALLS_LEADS
					   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
					     , DATE_MODIFIED     =  getdate()        
					     , DATE_MODIFIED_UTC =  getutcdate()     
					     , DELETED           = 1                 
					 where CALL_ID in (select ID from CALLS where REPEAT_PARENT_ID = @ID and DATE_MODIFIED_UTC < @REPEAT_UTC and DATE_START > getdate() and DELETED = 0);
				-- END Oracle Exception
				-- BEGIN Oracle Exception
					update CALLS
					   set MODIFIED_USER_ID    = @MODIFIED_USER_ID   
					     , DATE_MODIFIED       =  getdate()          
					     , DATE_MODIFIED_UTC   =  getutcdate()       
					     , DELETED             =  1                  
					 where REPEAT_PARENT_ID    = @ID
					   and DATE_MODIFIED_UTC   < @REPEAT_UTC
					   and DATE_START          > getdate()
					   and DELETED             = 0;
				-- END Oracle Exception
	
				set @REPEAT_INDEX = @REPEAT_INDEX + 1;
				exec dbo.spCALENDAR_Next @DATE_TIME, @REPEAT_TYPE, @TEMP_REPEAT_INTERVAL, @TEMP_REPEAT_DOW, @REPEAT_INDEX, @TEMP_DATE_TIME output, @WEEK_START output, @WEEKDAY output;
			end -- while;
		end -- if;
	end else begin
		exec dbo.spCALLS_DeleteRecurrences @ID, @MODIFIED_USER_ID, 0;
	end -- if;
	-- 05/17/2017 Paul.  Add Tags module. Must add after @ID is set. 
	if @@ERROR = 0 begin -- then
		exec dbo.spTAG_SETS_NormalizeSet @MODIFIED_USER_ID, @ID, N'Calls', @TAG_SET_NAME;
	end -- if;
  end
GO

Grant Execute on dbo.spCALLS_Update to public;
GO

