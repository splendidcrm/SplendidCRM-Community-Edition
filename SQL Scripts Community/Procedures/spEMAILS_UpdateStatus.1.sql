if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_UpdateStatus' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILS_UpdateStatus;
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
Create Procedure dbo.spEMAILS_UpdateStatus
	( @ID                uniqueidentifier
	, @MODIFIED_USER_ID  uniqueidentifier
	, @STATUS            nvarchar(25)
	)
as
  begin
	set nocount on

	-- 12/20/2006 Paul.  Set the date and time when the message was sent. 
	declare @DATE_SENT datetime;
	set @DATE_SENT = getdate();
	-- 12/19/2006 Paul.  If email was successfully sent, then change type to sent. 
	if @STATUS = N'sent' begin -- then
		update EMAILS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , TYPE              = N'sent'
		     , STATUS            = @STATUS           
		     , DATE_START        = dbo.fnStoreDateOnly(@DATE_SENT)
		     , TIME_START        = dbo.fnStoreTimeOnly(@DATE_SENT)
		 where ID                = @ID               
		   and DELETED           = 0;
	end else begin
		update EMAILS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , STATUS            = @STATUS           
		 where ID                = @ID               
		   and DELETED           = 0;
	end -- if;
	
  end
GO
 
Grant Execute on dbo.spEMAILS_UpdateStatus to public;
GO
 
