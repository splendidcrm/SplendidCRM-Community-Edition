if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILS_Update;
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
-- 04/21/2006 Paul.  MESSAGE_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  REPLY_TO_NAME was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  REPLY_TO_ADDR was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  INTENT was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  MAILBOX_ID was added in SugarCRM 4.0.
-- 05/30/2006 Paul.  MESSAGE_ID is a nvarchar(100) in SugarCRM 4.2
-- 08/17/2006 Matt Holden.  Changed Delimiter for Contact Lists to ';' from ','
-- 12/19/2006 Paul.  Create relationships if email sent to Contacts, Leads or Prospects. 
-- 09/29/2007 Paul.  In SugarCRM 4.5.1, the parent relationship is also stored in the separate relationship table.  
-- 09/29/2007 Paul.  Use Table Variables to efficient add new recipients or remove deleted recipients. 
-- 12/29/2007 Paul.  Add TEAM_ID so that it is not updated separately. 
-- 09/15/2008 Paul.  MySQL needs a begin-end block when using a cursor for a temporary table. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 08/23/2009 Paul.  Decrease set list so that index plus ID will be less than 900 bytes. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 11/01/2010 Paul.  Increase length of MESSAGE_ID to varchar(851) to allow for IMAP value + login + server. 
-- 11/17/2010 Paul.  Not sure why we were not deallocating this cursor until now. 
-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 03/24/2016 Paul.  Add Invoices relationship for the OfficeAddin. 
-- 05/17/2017 Paul.  Add Tags module. 
-- 10/27/2017 Paul.  Add Accounts as email source. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spEMAILS_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(255)
	, @DATE_TIME         datetime
	, @PARENT_TYPE       nvarchar(25)
	, @PARENT_ID         uniqueidentifier
	, @DESCRIPTION       nvarchar(max)
	, @DESCRIPTION_HTML  nvarchar(max)
	, @FROM_ADDR         nvarchar(100)
	, @FROM_NAME         nvarchar(100)
	, @TO_ADDRS          nvarchar(max)
	, @CC_ADDRS          nvarchar(max)
	, @BCC_ADDRS         nvarchar(max)
	, @TO_ADDRS_IDS      varchar(8000)
	, @TO_ADDRS_NAMES    nvarchar(max)
	, @TO_ADDRS_EMAILS   nvarchar(max)
	, @CC_ADDRS_IDS      varchar(8000)
	, @CC_ADDRS_NAMES    nvarchar(max)
	, @CC_ADDRS_EMAILS   nvarchar(max)
	, @BCC_ADDRS_IDS     varchar(8000)
	, @BCC_ADDRS_NAMES   nvarchar(max)
	, @BCC_ADDRS_EMAILS  nvarchar(max)
	, @TYPE              nvarchar(25)
	, @MESSAGE_ID        varchar(851)
	, @REPLY_TO_NAME     nvarchar(100)
	, @REPLY_TO_ADDR     nvarchar(100)
	, @INTENT            nvarchar(25)
	, @MAILBOX_ID        uniqueidentifier
	, @TEAM_ID           uniqueidentifier = null
	, @TEAM_SET_LIST     varchar(8000) = null
	, @TAG_SET_NAME      nvarchar(4000) = null
	, @IS_PRIVATE        bit = null
	, @ASSIGNED_SET_LIST varchar(8000) = null
	)
as
  begin
	set nocount on

	declare @STATUS              nvarchar(25);
	declare @ID_LIST             varchar(8000);
	declare @CONTACT_ID          uniqueidentifier;
	declare @CurrentPosR         int;
	declare @NextPosR            int;
	declare @DATE_START          datetime;
	declare @TIME_START          datetime;
	declare @CONTACT_TYPE        nvarchar(25);
	declare @LAST_TO_ADDRS_IDS   varchar(8000);
	declare @LAST_CC_ADDRS_IDS   varchar(8000);
	declare @LAST_BCC_ADDRS_IDS  varchar(8000);
	declare @TEAM_SET_ID         uniqueidentifier;
	declare @ASSIGNED_SET_ID     uniqueidentifier;
-- #if SQL_Server /*
	declare @RECIPIENTS      table ( ID uniqueidentifier primary key );
	declare @LAST_RECIPIENTS table ( ID uniqueidentifier primary key );
-- #endif SQL_Server */


	declare added_contacts_cursor cursor for
	select RECIPIENTS.ID
	  from            @RECIPIENTS          RECIPIENTS
	  left outer join @LAST_RECIPIENTS     LAST_RECIPIENTS
	               on LAST_RECIPIENTS.ID = RECIPIENTS.ID
	where LAST_RECIPIENTS.ID is null;

	declare removed_contacts_cursor cursor for
	select LAST_RECIPIENTS.ID
	  from            @LAST_RECIPIENTS  LAST_RECIPIENTS
	  left outer join @RECIPIENTS       RECIPIENTS
	               on RECIPIENTS.ID   = LAST_RECIPIENTS.ID
	where RECIPIENTS.ID is null;

/* -- #if IBM_DB2
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
	set l_error ='00000';
-- #endif IBM_DB2 */
/* -- #if MySQL
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
	set in_FETCH_STATUS = 0;

	drop temporary table if exists in_RECIPIENTS;
	drop temporary table if exists in_LAST_RECIPIENTS;

	create temporary table in_RECIPIENTS      ( ID char(36) primary key );
	create temporary table in_LAST_RECIPIENTS ( ID char(36) primary key );
-- #endif MySQL */

	set @DATE_START = dbo.fnStoreDateOnly(@DATE_TIME);
	set @TIME_START = dbo.fnStoreTimeOnly(@DATE_TIME);

	-- 08/22/2009 Paul.  Normalize the team set by placing the primary ID first, then order list by ID and the name by team names. 
	-- 08/23/2009 Paul.  Use a team set so that team name changes can propagate. 
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;

	if not exists(select * from EMAILS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		if @TYPE is null or @TYPE = N'' begin -- then
			set @TYPE = N'draft';
		end -- if;
		if @TYPE = N'archived' begin -- then
			set @STATUS = N'sent';
		end else begin
			set @STATUS = N'draft';
		end -- if;
		insert into EMAILS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, DATE_MODIFIED_UTC
			, ASSIGNED_USER_ID 
			, NAME             
			, DATE_START       
			, TIME_START       
			, PARENT_TYPE      
			, PARENT_ID        
			, DESCRIPTION      
			, DESCRIPTION_HTML 
			, FROM_ADDR        
			, FROM_NAME        
			, TO_ADDRS         
			, CC_ADDRS         
			, BCC_ADDRS        
			, TO_ADDRS_IDS     
			, TO_ADDRS_NAMES   
			, TO_ADDRS_EMAILS  
			, CC_ADDRS_IDS     
			, CC_ADDRS_NAMES   
			, CC_ADDRS_EMAILS  
			, BCC_ADDRS_IDS    
			, BCC_ADDRS_NAMES  
			, BCC_ADDRS_EMAILS 
			, TYPE             
			, STATUS           
			, MESSAGE_ID       
			, REPLY_TO_NAME    
			, REPLY_TO_ADDR    
			, INTENT           
			, MAILBOX_ID       
			, TEAM_ID          
			, TEAM_SET_ID      
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
			, @DATE_START        
			, @TIME_START        
			, @PARENT_TYPE       
			, @PARENT_ID         
			, @DESCRIPTION       
			, @DESCRIPTION_HTML  
			, @FROM_ADDR         
			, @FROM_NAME         
			, @TO_ADDRS          
			, @CC_ADDRS          
			, @BCC_ADDRS         
			, @TO_ADDRS_IDS      
			, @TO_ADDRS_NAMES    
			, @TO_ADDRS_EMAILS   
			, @CC_ADDRS_IDS      
			, @CC_ADDRS_NAMES    
			, @CC_ADDRS_EMAILS   
			, @BCC_ADDRS_IDS     
			, @BCC_ADDRS_NAMES   
			, @BCC_ADDRS_EMAILS  
			, @TYPE              
			, @STATUS            
			, @MESSAGE_ID        
			, @REPLY_TO_NAME     
			, @REPLY_TO_ADDR     
			, @INTENT            
			, @MAILBOX_ID        
			, @TEAM_ID           
			, @TEAM_SET_ID       
			, @IS_PRIVATE        
			, @ASSIGNED_SET_ID   
			);
	end else begin
		select @LAST_TO_ADDRS_IDS  = cast(TO_ADDRS_IDS  as varchar(8000))
		     , @LAST_CC_ADDRS_IDS  = cast(CC_ADDRS_IDS  as varchar(8000))
		     , @LAST_BCC_ADDRS_IDS = cast(BCC_ADDRS_IDS as varchar(8000))
		  from EMAILS
		 where ID                  = @ID               ;

		update EMAILS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID  
		     , DATE_MODIFIED     =  getdate()         
		     , DATE_MODIFIED_UTC =  getutcdate()      
		     , ASSIGNED_USER_ID  = @ASSIGNED_USER_ID  
		     , NAME              = @NAME              
		     , DATE_START        = @DATE_START        
		     , TIME_START        = @TIME_START        
		     , PARENT_TYPE       = @PARENT_TYPE       
		     , PARENT_ID         = @PARENT_ID         
		     , DESCRIPTION       = @DESCRIPTION       
		     , DESCRIPTION_HTML  = @DESCRIPTION_HTML  
		     , FROM_ADDR         = @FROM_ADDR         
		     , FROM_NAME         = @FROM_NAME         
		     , TO_ADDRS          = @TO_ADDRS          
		     , CC_ADDRS          = @CC_ADDRS          
		     , BCC_ADDRS         = @BCC_ADDRS         
		     , TO_ADDRS_IDS      = @TO_ADDRS_IDS      
		     , TO_ADDRS_NAMES    = @TO_ADDRS_NAMES    
		     , TO_ADDRS_EMAILS   = @TO_ADDRS_EMAILS   
		     , CC_ADDRS_IDS      = @CC_ADDRS_IDS      
		     , CC_ADDRS_NAMES    = @CC_ADDRS_NAMES    
		     , CC_ADDRS_EMAILS   = @CC_ADDRS_EMAILS   
		     , BCC_ADDRS_IDS     = @BCC_ADDRS_IDS     
		     , BCC_ADDRS_NAMES   = @BCC_ADDRS_NAMES   
		     , BCC_ADDRS_EMAILS  = @BCC_ADDRS_EMAILS  
		     , TYPE              = @TYPE             -- 01/21/2006 Paul.  Update type, but not status. 
		     , MESSAGE_ID        = @MESSAGE_ID        
		     , REPLY_TO_NAME     = @REPLY_TO_NAME     
		     , REPLY_TO_ADDR     = @REPLY_TO_ADDR     
		     , INTENT            = @INTENT            
		     , MAILBOX_ID        = @MAILBOX_ID        
		     , TEAM_ID           = @TEAM_ID           
		     , TEAM_SET_ID       = @TEAM_SET_ID       
		     , IS_PRIVATE        = @IS_PRIVATE         
		     , ASSIGNED_SET_ID   = @ASSIGNED_SET_ID   
		 where ID                = @ID                ;
		
		-- 04/03/2012 Paul.  When the name changes, update the favorites table. 
		exec dbo.spSUGARFAVORITES_UpdateName @MODIFIED_USER_ID, @ID, @NAME;

		set @ID_LIST = @LAST_TO_ADDRS_IDS;
		set @CurrentPosR = 1;
		while @CurrentPosR <= len(@ID_LIST) begin -- do
			-- 09/07/2008 Paul.  charindex should not use unicode parameters as it will limit all inputs to 4000 characters. 
			set @NextPosR = charindex(';', @ID_LIST,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@ID_LIST) + 1;
			end -- if;
			set @CONTACT_ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
			if not exists(select * from @LAST_RECIPIENTS where ID = @CONTACT_ID) begin -- then
				insert into @LAST_RECIPIENTS
				     values(@CONTACT_ID);
			end -- if;

			set @CurrentPosR = @NextPosR+1;
		end -- while;

		set @ID_LIST = @LAST_CC_ADDRS_IDS;
		set @CurrentPosR = 1;
		while @CurrentPosR <= len(@ID_LIST) begin -- do
			-- 09/07/2008 Paul.  charindex should not use unicode parameters as it will limit all inputs to 4000 characters. 
			set @NextPosR = charindex(';', @ID_LIST,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@ID_LIST) + 1;
			end -- if;
			set @CONTACT_ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
			if not exists(select * from @LAST_RECIPIENTS where ID = @CONTACT_ID) begin -- then
				insert into @LAST_RECIPIENTS
				     values(@CONTACT_ID);
			end -- if;

			set @CurrentPosR = @NextPosR+1;
		end -- while;

		set @ID_LIST = @LAST_BCC_ADDRS_IDS;
		set @CurrentPosR = 1;
		while @CurrentPosR <= len(@ID_LIST) begin -- do
			-- 09/07/2008 Paul.  charindex should not use unicode parameters as it will limit all inputs to 4000 characters. 
			set @NextPosR = charindex(';', @ID_LIST,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@ID_LIST) + 1;
			end -- if;
			set @CONTACT_ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
			if not exists(select * from @LAST_RECIPIENTS where ID = @CONTACT_ID) begin -- then
				insert into @LAST_RECIPIENTS
				     values(@CONTACT_ID);
			end -- if;

			set @CurrentPosR = @NextPosR+1;
		end -- while;
	end -- if;

	-- 01/21/2006 Paul.  If insert fails, then the rest will as well. Just display the one error. 
	if @@ERROR = 0 begin -- then
		if not exists(select * from EMAILS_CSTM where ID_C = @ID) begin -- then
			insert into EMAILS_CSTM ( ID_C ) values ( @ID );
		end -- if;

		-- 08/21/2009 Paul.  Add or remove the team relationship records. 
		-- 08/30/2009 Paul.  Instead of using @TEAM_SET_LIST, use the @TEAM_SET_ID to build the module-specific team relationships. 
		-- 08/31/2009 Paul.  Instead of managing a separate teams relationship, we will leverage TEAM_SETS_TEAMS. 
		-- exec dbo.spEMAILS_TEAMS_Update @ID, @MODIFIED_USER_ID, @TEAM_SET_ID;

		if dbo.fnIsEmptyGuid(@ASSIGNED_USER_ID) = 0 begin -- then
			exec dbo.spEMAILS_USERS_Update @MODIFIED_USER_ID, @ID, @ASSIGNED_USER_ID;
		end -- if;
	end -- if;

	if @@ERROR = 0 begin -- then
		set @ID_LIST = @TO_ADDRS_IDS;
		set @CurrentPosR = 1;
		while @CurrentPosR <= len(@ID_LIST) begin -- do
			-- 09/07/2008 Paul.  charindex should not use unicode parameters as it will limit all inputs to 4000 characters. 
			set @NextPosR = charindex(';', @ID_LIST,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@ID_LIST) + 1;
			end -- if;
			set @CONTACT_ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
			if not exists(select * from @RECIPIENTS where ID = @CONTACT_ID) begin -- then
				insert into @RECIPIENTS
				     values(@CONTACT_ID);
			end -- if;

			set @CurrentPosR = @NextPosR+1;
		end -- while;

		set @ID_LIST = @CC_ADDRS_IDS;
		set @CurrentPosR = 1;
		while @CurrentPosR <= len(@ID_LIST) begin -- do
			-- 09/07/2008 Paul.  charindex should not use unicode parameters as it will limit all inputs to 4000 characters. 
			set @NextPosR = charindex(';', @ID_LIST,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@ID_LIST) + 1;
			end -- if;
			set @CONTACT_ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
			if not exists(select * from @RECIPIENTS where ID = @CONTACT_ID) begin -- then
				insert into @RECIPIENTS
				     values(@CONTACT_ID);
			end -- if;

			set @CurrentPosR = @NextPosR+1;
		end -- while;

		set @ID_LIST = @BCC_ADDRS_IDS;
		set @CurrentPosR = 1;
		while @CurrentPosR <= len(@ID_LIST) begin -- do
			-- 09/07/2008 Paul.  charindex should not use unicode parameters as it will limit all inputs to 4000 characters. 
			set @NextPosR = charindex(';', @ID_LIST,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@ID_LIST) + 1;
			end -- if;
			set @CONTACT_ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
			if not exists(select * from @RECIPIENTS where ID = @CONTACT_ID) begin -- then
				insert into @RECIPIENTS
				     values(@CONTACT_ID);
			end -- if;

			set @CurrentPosR = @NextPosR+1;
		end -- while;

	end -- if;

	if @@ERROR = 0 begin -- then
		open added_contacts_cursor;
		fetch next from added_contacts_cursor into @CONTACT_ID;
		while @@FETCH_STATUS = 0 and @@ERROR = 0 begin -- do
			-- 12/19/2006 Paul.  Find the table of origin for the address, and assign accordingly. 
			-- BEGIN Oracle Exception
				set @CONTACT_TYPE = null;
				select @CONTACT_TYPE = PARENT_TYPE
				  from vwPARENTS_EMAIL_ADDRESS
				 where PARENT_ID = @CONTACT_ID;
			-- END Oracle Exception
			if @CONTACT_TYPE = N'Contacts' begin -- then
				exec dbo.spEMAILS_CONTACTS_Update @MODIFIED_USER_ID, @ID, @CONTACT_ID;
			end else if @CONTACT_TYPE = N'Leads' begin -- then
				exec dbo.spEMAILS_LEADS_Update @MODIFIED_USER_ID, @ID, @CONTACT_ID;
			end else if @CONTACT_TYPE = N'Prospects' begin -- then
				exec dbo.spEMAILS_PROSPECTS_Update @MODIFIED_USER_ID, @ID, @CONTACT_ID;
			-- 10/27/2017 Paul.  Add Accounts as email source. 
			end else if @CONTACT_TYPE = N'Accounts' begin -- then
				exec dbo.spEMAILS_ACCOUNTS_Update @MODIFIED_USER_ID, @ID, @CONTACT_ID;
			end -- if;
			
			-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
			exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @CONTACT_ID, @CONTACT_TYPE;
			fetch next from added_contacts_cursor into @CONTACT_ID;
		end -- while;
		close added_contacts_cursor;
		-- 11/17/2010 Paul.  Not sure why we were not deallocating this cursor until now. 
		deallocate added_contacts_cursor;

		open removed_contacts_cursor;
		fetch next from removed_contacts_cursor into @CONTACT_ID;
		while @@FETCH_STATUS = 0 and @@ERROR = 0 begin -- do
			-- 12/19/2006 Paul.  Find the table of origin for the address, and delete accordingly. 
			-- BEGIN Oracle Exception
				set @CONTACT_TYPE = null;
				select @CONTACT_TYPE = PARENT_TYPE
				  from vwPARENTS_EMAIL_ADDRESS
				 where PARENT_ID = @CONTACT_ID;
			-- END Oracle Exception
			if @CONTACT_TYPE = N'Contacts' begin -- then
				exec dbo.spEMAILS_CONTACTS_Delete @MODIFIED_USER_ID, @ID, @CONTACT_ID;
			end else if @CONTACT_TYPE = N'Leads' begin -- then
				exec dbo.spEMAILS_LEADS_Delete @MODIFIED_USER_ID, @ID, @CONTACT_ID;
			end else if @CONTACT_TYPE = N'Prospects' begin -- then
				exec dbo.spEMAILS_PROSPECTS_Delete @MODIFIED_USER_ID, @ID, @CONTACT_ID;
			-- 10/27/2017 Paul.  Add Accounts as email source. 
			end else if @CONTACT_TYPE = N'Accounts' begin -- then
				exec dbo.spEMAILS_ACCOUNTS_Update @MODIFIED_USER_ID, @ID, @CONTACT_ID;
			end -- if;
			fetch next from removed_contacts_cursor into @CONTACT_ID;
		end -- while;
		close removed_contacts_cursor;
		-- 11/17/2010 Paul.  Not sure why we were not deallocating this cursor until now. 
		deallocate removed_contacts_cursor;

	end -- if;

	-- 09/28/2007 Paul.  In SugarCRM 4.5.1, the parent relationship is also stored in the separate relationship table.  
	-- However, when the parent is removed, the relationship table record is not. 
	if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
		if          @PARENT_TYPE = N'Accounts' begin -- then
			exec dbo.spEMAILS_ACCOUNTS_Update      @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Bugs' begin -- then
			exec dbo.spEMAILS_BUGS_Update          @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Cases' begin -- then
			exec dbo.spEMAILS_CASES_Update         @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Contacts' begin -- then
			exec dbo.spEMAILS_CONTACTS_Update      @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Leads' begin -- then
			exec dbo.spEMAILS_LEADS_Update         @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Opportunities' begin -- then
			exec dbo.spEMAILS_OPPORTUNITIES_Update @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Project' begin -- then
			exec dbo.spEMAILS_PROJECTS_Update      @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'ProjectTask' begin -- then
			exec dbo.spEMAILS_PROJECT_TASKS_Update @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Prospects' begin -- then
			exec dbo.spEMAILS_PROSPECTS_Update     @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Quotes' begin -- then
			exec dbo.spEMAILS_QUOTES_Update        @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Tasks' begin -- then
			exec dbo.spEMAILS_TASKS_Update         @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Users' begin -- then
			exec dbo.spEMAILS_USERS_Update         @MODIFIED_USER_ID, @ID, @PARENT_ID;
		-- 02/13/2009 Paul.  Add relationship to Contracts. 
		end else if @PARENT_TYPE = N'Contracts' begin -- then
			exec dbo.spEMAILS_CONTRACTS_Update     @MODIFIED_USER_ID, @ID, @PARENT_ID;
		-- 05/18/2014 Paul.  Customer wants to be able to archive to an order. 
		end else if @PARENT_TYPE = N'Orders' begin -- then
			exec dbo.spEMAILS_ORDERS_Update        @MODIFIED_USER_ID, @ID, @PARENT_ID;
		-- 03/23/2016 Paul.  Relationship used with OfficeAddin. 
		end else if @PARENT_TYPE = N'Invoices' begin -- then
			exec dbo.spEMAILS_INVOICES_Update      @MODIFIED_USER_ID, @ID, @PARENT_ID;
		end -- if;
		
		-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
		exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @PARENT_ID, @PARENT_TYPE;
	end -- if;
	-- 05/17/2017 Paul.  Add Tags module. Must add after @ID is set. 
	if @@ERROR = 0 begin -- then
		exec dbo.spTAG_SETS_NormalizeSet @MODIFIED_USER_ID, @ID, N'Emails', @TAG_SET_NAME;
	end -- if;
  end
GO

Grant Execute on dbo.spEMAILS_Update to public;
GO

