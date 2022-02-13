if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGNS_InvalidEmail' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGNS_InvalidEmail;
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
-- 01/26/2013 Paul.  Only update the record if INVALID_EMAIL is not set. 
-- 01/26/2013 Paul.  Do not update a deleted record. 
-- 10/27/2017 Paul.  Add Accounts as email source. 
Create Procedure dbo.spCAMPAIGNS_InvalidEmail
	( @MODIFIED_USER_ID  uniqueidentifier
	, @RELATED_ID        uniqueidentifier
	, @RELATED_TYPE      nvarchar(25)
	)
as
  begin
	set nocount on
	
	if @RELATED_TYPE = N'Contacts' begin -- then
		update CONTACTS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , INVALID_EMAIL     = 1
		 where ID                = @RELATED_ID
		   and INVALID_EMAIL     = 0
		   and DELETED           = 0;
	end else if @RELATED_TYPE = N'Prospects' begin -- then
		update PROSPECTS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , INVALID_EMAIL     = 1
		 where ID                = @RELATED_ID
		   and INVALID_EMAIL     = 0
		   and DELETED           = 0;
	end else if @RELATED_TYPE = N'Leads' begin -- then
		update LEADS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , INVALID_EMAIL     = 1
		 where ID                = @RELATED_ID
		   and INVALID_EMAIL     = 0
		   and DELETED           = 0;
	end else if @RELATED_TYPE = N'Accounts' begin -- then
		update ACCOUNTS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , INVALID_EMAIL     = 1
		 where ID                = @RELATED_ID
		   and INVALID_EMAIL     = 0
		   and DELETED           = 0;
	end -- if;
  end
GO

Grant Execute on dbo.spCAMPAIGNS_InvalidEmail to public;
GO

