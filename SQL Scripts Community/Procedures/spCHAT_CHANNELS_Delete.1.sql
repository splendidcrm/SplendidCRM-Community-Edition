if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCHAT_CHANNELS_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCHAT_CHANNELS_Delete;
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
Create Procedure dbo.spCHAT_CHANNELS_Delete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update CHAT_MESSAGES
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
		 where CHAT_CHANNEL_ID   = @ID
		   and DELETED           = 0;
	-- END Oracle Exception

	-- BEGIN Oracle Exception
		update NOTE_ATTACHMENTS
		   set DELETED           = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where NOTE_ID          in (select ID from NOTES where PARENT_ID = @ID and DELETED = 0)
		   and DELETED          = 0;
	-- END Oracle Exception

	-- BEGIN Oracle Exception
		update NOTES
		   set DELETED           = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where PARENT_ID        = @ID
		   and DELETED          = 0;
	-- END Oracle Exception

	-- BEGIN Oracle Exception
		update CHAT_CHANNELS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
		 where ID                = @ID
		   and DELETED           = 0;
	-- END Oracle Exception

	-- 10/13/2015 Paul.  We need to delete all favorite records. 
	-- BEGIN Oracle Exception
		update SUGARFAVORITES
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
		 where RECORD_ID         = @ID
		   and DELETED           = 0;
	-- END Oracle Exception
  end
GO

Grant Execute on dbo.spCHAT_CHANNELS_Delete to public;
GO

