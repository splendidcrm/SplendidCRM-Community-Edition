if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGNS_OptOut' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGNS_OptOut;
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
Create Procedure dbo.spCAMPAIGNS_OptOut
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
		     , EMAIL_OPT_OUT     = 1
		 where ID                = @RELATED_ID;
	end else if @RELATED_TYPE = N'Prospects' begin -- then
		update PROSPECTS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , EMAIL_OPT_OUT     = 1
		 where ID                = @RELATED_ID;
	end else if @RELATED_TYPE = N'Leads' begin -- then
		update LEADS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , EMAIL_OPT_OUT     = 1
		 where ID                = @RELATED_ID;
	end -- if;
  end
GO

Grant Execute on dbo.spCAMPAIGNS_OptOut to public;
GO

