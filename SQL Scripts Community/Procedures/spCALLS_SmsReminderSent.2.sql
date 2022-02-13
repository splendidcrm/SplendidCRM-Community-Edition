if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCALLS_SmsReminderSent' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCALLS_SmsReminderSent;
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
Create Procedure dbo.spCALLS_SmsReminderSent
	( @ID                 uniqueidentifier
	, @MODIFIED_USER_ID   uniqueidentifier
	, @INVITEE_TYPE       nvarchar(25)
	, @INVITEE_ID         uniqueidentifier
	)
as
  begin
	set nocount on
	
	if @INVITEE_TYPE = N'Users' begin -- then
		update CALLS_USERS
		   set SMS_REMINDER_SENT   = 1
		     , MODIFIED_USER_ID    = @MODIFIED_USER_ID
		     , DATE_MODIFIED       = getdate()
		     , DATE_MODIFIED_UTC   = getutcdate()
		 where CALL_ID             = @ID
		   and USER_ID             = @INVITEE_ID
		   and DELETED             = 0;
	end else if @INVITEE_TYPE = N'Contacts' begin -- then
		update CALLS_CONTACTS
		   set SMS_REMINDER_SENT   = 1
		     , MODIFIED_USER_ID    = @MODIFIED_USER_ID
		     , DATE_MODIFIED       = getdate()
		     , DATE_MODIFIED_UTC   = getutcdate()
		 where CALL_ID             = @ID
		   and CONTACT_ID          = @INVITEE_ID
		   and DELETED             = 0;
	end else if @INVITEE_TYPE = N'Leads' begin -- then
		update CALLS_LEADS
		   set SMS_REMINDER_SENT   = 1
		     , MODIFIED_USER_ID    = @MODIFIED_USER_ID
		     , DATE_MODIFIED       = getdate()
		     , DATE_MODIFIED_UTC   = getutcdate()
		 where CALL_ID             = @ID
		   and LEAD_ID             = @INVITEE_ID
		   and DELETED             = 0;
	end -- if;
  end
GO

Grant Execute on dbo.spCALLS_SmsReminderSent to public;
GO

