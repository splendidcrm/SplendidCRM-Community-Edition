if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_UndeliverableEmail' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILS_UndeliverableEmail;
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
-- 10/27/2017 Paul.  Add Accounts as email source. 
Create Procedure dbo.spEMAILS_UndeliverableEmail
	( @ID                 uniqueidentifier
	, @MODIFIED_USER_ID   uniqueidentifier
	, @TARGET_ID          uniqueidentifier output
	, @TARGET_TYPE        nvarchar(25) output
	)
as
  begin
	set nocount on
	
	declare @FROM_ADDR          nvarchar(100);
	declare @NAME               nvarchar(255);
	declare @DESCRIPTION        nvarchar(max);
	declare @SEARCH_TEXT        nvarchar(255);
	declare @RECIPIENT_ADDR     nvarchar(100);
	declare @TARGET_TRACKER_KEY uniqueidentifier;
	declare @StartPos           int;
	declare @EndPos             int;

	-- BEGIN Oracle Exception
		select @FROM_ADDR   = FROM_ADDR
		     , @NAME        = NAME
		     , @DESCRIPTION = DESCRIPTION
		  from EMAILS
		 where ID           = @ID
		   and DELETED      = 0;
	-- END Oracle Exception

	if    substring(@FROM_ADDR, 1, 14) = N'mailer-daemon@'
	   or substring(@FROM_ADDR, 1, 14) = N'MAILER-DAEMON@'
	   or substring(@FROM_ADDR, 1, 11) = N'postmaster@'
	   or @NAME = N'Delivery Status Notification (Failure)' 
	   or @NAME = N'Undeliverable Mail Returned to Sender' 
	   or @NAME = N'Mail System Error - Returned Mail' 
	   or @NAME = N'Mail delivery failed' 
	   or @NAME = N'failure notice' 
	   or substring(@NAME, 1, 14) = N'Undeliverable:' 
	   or substring(@NAME, 1, 19) = N'Undeliverable mail:' 
	   or substring(@NAME, 1, 17) = N'DELIVERY FAILURE:'
	begin -- then
		if @RECIPIENT_ADDR is null and @TARGET_TRACKER_KEY is null begin -- then
			set @SEARCH_TEXT = N'X-SplendidCRM-ID: ';
			set @StartPos = charindex(@SEARCH_TEXT, @DESCRIPTION, 1);
			if @StartPos > 0 begin -- then
				set @StartPos = @StartPos + len(@SEARCH_TEXT) + 1;
				set @EndPos   = @StartPos + 36;
				set @TARGET_TRACKER_KEY = cast(substring(@DESCRIPTION, @StartPos, @EndPos - @StartPos) as uniqueidentifier);
			end -- if;
		end -- if;
		if @RECIPIENT_ADDR is null and @TARGET_TRACKER_KEY is null begin -- then
			set @SEARCH_TEXT = N'/RemoveMe.aspx?identifier=';
			set @StartPos = charindex(@SEARCH_TEXT, @DESCRIPTION, 1);
			if @StartPos > 0 begin -- then
				set @StartPos = @StartPos + len(@SEARCH_TEXT);
				set @EndPos   = @StartPos + 36;
				set @TARGET_TRACKER_KEY = cast(substring(@DESCRIPTION, @StartPos, @EndPos - @StartPos) as uniqueidentifier);
			end -- if;
		end -- if;
		if @RECIPIENT_ADDR is null and @TARGET_TRACKER_KEY is null begin -- then
			set @SEARCH_TEXT = N'/campaign_trackerv2.aspx?identifier=';
			set @StartPos = charindex(@SEARCH_TEXT, @DESCRIPTION, 1);
			if @StartPos > 0 begin -- then
				set @StartPos = @StartPos + len(@SEARCH_TEXT);
				set @EndPos   = @StartPos + 36;
				set @TARGET_TRACKER_KEY = cast(substring(@DESCRIPTION, @StartPos, @EndPos - @StartPos) as uniqueidentifier);
			end -- if;
		end -- if;
		if @RECIPIENT_ADDR is null and @TARGET_TRACKER_KEY is null begin -- then
			set @SEARCH_TEXT = N'/image.aspx?identifier=';
			set @StartPos = charindex(@SEARCH_TEXT, @DESCRIPTION, 1);
			if @StartPos > 0 begin -- then
				set @StartPos = @StartPos + len(@SEARCH_TEXT);
				set @EndPos   = @StartPos + 36;
				set @TARGET_TRACKER_KEY = cast(substring(@DESCRIPTION, @StartPos, @EndPos - @StartPos) as uniqueidentifier);
			end -- if;
		end -- if;
		if @RECIPIENT_ADDR is null and @TARGET_TRACKER_KEY is null begin -- then
			set @SEARCH_TEXT = N'Delivery has failed to these recipients or distribution lists:';
			set @StartPos = charindex(@SEARCH_TEXT, @DESCRIPTION, 1);
			if @StartPos > 0 begin -- then
				set @StartPos = @StartPos + len(@SEARCH_TEXT) + 1;
				set @SEARCH_TEXT = N'<mailto:';
				set @StartPos = charindex(@SEARCH_TEXT, @DESCRIPTION, @StartPos);
				if @StartPos > 0 begin -- then
					set @StartPos = @StartPos + len(@SEARCH_TEXT);
					set @EndPos   = charindex('>', @DESCRIPTION, @StartPos);
					set @RECIPIENT_ADDR = substring(@DESCRIPTION, @StartPos, @EndPos - @StartPos);
					set @RECIPIENT_ADDR = replace(@RECIPIENT_ADDR, nchar(10), '');
					set @RECIPIENT_ADDR = replace(@RECIPIENT_ADDR, nchar(13), '');
					set @RECIPIENT_ADDR = rtrim(ltrim(@RECIPIENT_ADDR));
				end -- if;
			end -- if;
		end -- if;
		if @RECIPIENT_ADDR is null and @TARGET_TRACKER_KEY is null begin -- then
			set @SEARCH_TEXT = N'Failed to deliver to ''';
			set @StartPos = charindex(@SEARCH_TEXT, @DESCRIPTION, 1);
			if @StartPos > 0 begin -- then
				set @StartPos = @StartPos + len(@SEARCH_TEXT) + 1;
				set @EndPos   = charindex('''', @DESCRIPTION, @StartPos);
				set @RECIPIENT_ADDR = substring(@DESCRIPTION, @StartPos, @EndPos - @StartPos);
				set @RECIPIENT_ADDR = replace(@RECIPIENT_ADDR, nchar(10), '');
				set @RECIPIENT_ADDR = replace(@RECIPIENT_ADDR, nchar(13), '');
				set @RECIPIENT_ADDR = rtrim(ltrim(@RECIPIENT_ADDR));
			end -- if;
		end -- if;
	end -- if;
	if @TARGET_TRACKER_KEY is not null begin -- then
		--print cast(@ID as char(36)) + ' <' + cast(@TARGET_TRACKER_KEY as char(36)) + '> ' + @SEARCH_TEXT;
		-- 01/26/2013 Paul.  Don't use spCAMPAIGN_LOG_UpdateTracker so that the hit count does not get incremented. 
		if exists(select * from CAMPAIGN_LOG where TARGET_TRACKER_KEY = @TARGET_TRACKER_KEY and ACTIVITY_TYPE = N'targeted') begin -- then
			select @TARGET_ID         = TARGET_ID
			     , @TARGET_TYPE       = TARGET_TYPE
			  from CAMPAIGN_LOG
			 where TARGET_TRACKER_KEY = @TARGET_TRACKER_KEY
			   and ACTIVITY_TYPE      = N'targeted';
			if not exists(select * from CAMPAIGN_LOG where TARGET_TRACKER_KEY = @TARGET_TRACKER_KEY and ACTIVITY_TYPE = N'invalid email') begin -- then
				print 'CAMPAIGN_LOG invalid email: ' + cast(@TARGET_TRACKER_KEY as char(36));
				-- BEGIN Oracle Exception
					insert into CAMPAIGN_LOG
						( ID                 
						, CREATED_BY         
						, DATE_ENTERED       
						, MODIFIED_USER_ID   
						, DATE_MODIFIED      
						, CAMPAIGN_ID        
						, TARGET_TRACKER_KEY 
						, TARGET_ID          
						, TARGET_TYPE        
						, ACTIVITY_TYPE      
						, ACTIVITY_DATE      
						, RELATED_ID         
						, RELATED_TYPE       
						, HITS               
						, LIST_ID            
						, MARKETING_ID       
						, MORE_INFORMATION   
						)
					select	  newid()                 
						, @MODIFIED_USER_ID  
						,  getdate()         
						, @MODIFIED_USER_ID  
						,  getdate()         
						, CAMPAIGN_ID        
						, TARGET_TRACKER_KEY 
						, TARGET_ID          
						, TARGET_TYPE        
						, N'invalid email'   
						,  getdate()         
						, RELATED_ID         
						, RELATED_TYPE       
						, 1                  
						, LIST_ID            
						, MARKETING_ID       
						, MORE_INFORMATION   
					  from CAMPAIGN_LOG
					 where TARGET_TRACKER_KEY = @TARGET_TRACKER_KEY
					   and ACTIVITY_TYPE      = N'targeted';
				-- END Oracle Exception
			end -- if;
		end -- if;
		if @TARGET_TYPE = N'Contacts' begin -- then
			if exists(select * from CONTACTS where ID = @TARGET_ID and INVALID_EMAIL = 0 and DELETED = 0) begin -- then
				print 'CONTACTS invalid email: ' + cast(@TARGET_ID as char(36));
				update CONTACTS
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     =  getdate()        
				     , DATE_MODIFIED_UTC =  getutcdate()     
				     , INVALID_EMAIL     = 1
				 where ID                = @TARGET_ID
				   and INVALID_EMAIL     = 0
				   and DELETED           = 0;
			end -- if;
		end else if @TARGET_TYPE = N'Prospects' begin -- then
			if exists(select * from PROSPECTS where ID = @TARGET_ID and INVALID_EMAIL = 0 and DELETED = 0) begin -- then
				print 'PROSPECTS invalid email: ' + cast(@TARGET_ID as char(36));
				update PROSPECTS
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     =  getdate()        
				     , DATE_MODIFIED_UTC =  getutcdate()     
				     , INVALID_EMAIL     = 1
				 where ID                = @TARGET_ID
				   and INVALID_EMAIL     = 0
				   and DELETED           = 0;
			end -- if;
		end else if @TARGET_TYPE = N'Leads' begin -- then
			if exists(select * from LEADS where ID = @TARGET_ID and INVALID_EMAIL = 0 and DELETED = 0) begin -- then
				print 'LEADS invalid email: ' + cast(@TARGET_ID as char(36));
				update LEADS
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     =  getdate()        
				     , DATE_MODIFIED_UTC =  getutcdate()     
				     , INVALID_EMAIL     = 1
				 where ID                = @TARGET_ID
				   and INVALID_EMAIL     = 0
				   and DELETED           = 0;
			end -- if;
		-- 10/27/2017 Paul.  Add Accounts as email source. 
		end else if @TARGET_TYPE = N'Accounts' begin -- then
			if exists(select * from ACCOUNTS where ID = @TARGET_ID and INVALID_EMAIL = 0 and DELETED = 0) begin -- then
				print 'ACCOUNTS invalid email: ' + cast(@TARGET_ID as char(36));
				update ACCOUNTS
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     =  getdate()        
				     , DATE_MODIFIED_UTC =  getutcdate()     
				     , INVALID_EMAIL     = 1
				 where ID                = @TARGET_ID
				   and INVALID_EMAIL     = 0
				   and DELETED           = 0;
			end -- if;
		end -- if;
	end else if @RECIPIENT_ADDR is not null begin -- then
		-- print cast(@ID as char(36)) + ' <' + @RECIPIENT_ADDR + '> ' + @SEARCH_TEXT;
		if exists(select * from CONTACTS where EMAIL1 = @RECIPIENT_ADDR and INVALID_EMAIL = 0 and DELETED = 0) begin -- then
			print 'CONTACTS invalid email: ' + @RECIPIENT_ADDR;
			if @TARGET_ID is null begin -- then
				select top 1 @TARGET_ID = ID
				  from CONTACTS
				 where INVALID_EMAIL     = 0
				   and DELETED           = 0;
				set @TARGET_TYPE = N'Contacts';
			end -- if;
			update CONTACTS
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , INVALID_EMAIL     = 1
			 where EMAIL1            = @RECIPIENT_ADDR
			   and INVALID_EMAIL     = 0
			   and DELETED           = 0;
		end -- if;
		if exists(select * from LEADS where EMAIL1 = @RECIPIENT_ADDR and INVALID_EMAIL = 0 and DELETED = 0) begin -- then
			print 'LEADS invalid email: ' + @RECIPIENT_ADDR;
			if @TARGET_ID is null begin -- then
				select top 1 @TARGET_ID = ID
				  from LEADS
				 where INVALID_EMAIL     = 0
				   and DELETED           = 0;
				set @TARGET_TYPE = N'Leads';
			end -- if;
			update LEADS
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , INVALID_EMAIL     = 1
			 where EMAIL1            = @RECIPIENT_ADDR
			   and INVALID_EMAIL     = 0
			   and DELETED           = 0;
		end -- if;
		if exists(select * from PROSPECTS where EMAIL1 = @RECIPIENT_ADDR and INVALID_EMAIL = 0 and DELETED = 0) begin -- then
			print 'PROSPECTS invalid email: ' + @RECIPIENT_ADDR;
			if @TARGET_ID is null begin -- then
				select top 1 @TARGET_ID = ID
				  from PROSPECTS
				 where INVALID_EMAIL     = 0
				   and DELETED           = 0;
				set @TARGET_TYPE = N'Prospects';
			end -- if;
			update PROSPECTS
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , INVALID_EMAIL     = 1
			 where EMAIL1            = @RECIPIENT_ADDR
			   and INVALID_EMAIL     = 0
			   and DELETED           = 0;
		end -- if;
		if exists(select * from ACCOUNTS where EMAIL1 = @RECIPIENT_ADDR and INVALID_EMAIL = 0 and DELETED = 0) begin -- then
			print 'ACCOUNTS invalid email: ' + @RECIPIENT_ADDR;
			if @TARGET_ID is null begin -- then
				select top 1 @TARGET_ID = ID
				  from ACCOUNTS
				 where INVALID_EMAIL     = 0
				   and DELETED           = 0;
				set @TARGET_TYPE = N'Accounts';
			end -- if;
			update ACCOUNTS
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , INVALID_EMAIL     = 1
			 where EMAIL1            = @RECIPIENT_ADDR
			   and INVALID_EMAIL     = 0
			   and DELETED           = 0;
		end -- if;
		-- 10/27/2017 Paul.  Add Accounts as email source. 
	--end else begin
	--	print cast(@ID as char(36))  + ' * * * ' + @NAME;
	end -- if;
  end
GO

Grant Execute on dbo.spEMAILS_UndeliverableEmail to public;
GO

