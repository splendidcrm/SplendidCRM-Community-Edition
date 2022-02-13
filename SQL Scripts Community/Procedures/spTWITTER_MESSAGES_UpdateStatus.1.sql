if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTWITTER_MESSAGES_UpdateStatus' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTWITTER_MESSAGES_UpdateStatus;
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
-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
Create Procedure dbo.spTWITTER_MESSAGES_UpdateStatus
	( @ID                uniqueidentifier
	, @MODIFIED_USER_ID  uniqueidentifier
	, @STATUS            nvarchar(25)
	, @TWITTER_ID        bigint
	)
as
  begin
	set nocount on

	declare @DATE_SENT datetime;
	set @DATE_SENT = getdate();
	if @STATUS = N'sent' begin -- then
		update TWITTER_MESSAGES
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , TYPE              = N'sent'
		     , STATUS            = @STATUS           
		     , TWITTER_ID        = isnull(@TWITTER_ID, TWITTER_ID)
		     , DATE_START        = dbo.fnStoreDateOnly(@DATE_SENT)
		     , TIME_START        = dbo.fnStoreTimeOnly(@DATE_SENT)
		 where ID                = @ID               
		   and DELETED           = 0;
	end else begin
		update TWITTER_MESSAGES
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , STATUS            = @STATUS           
		     , TWITTER_ID        = isnull(@TWITTER_ID, TWITTER_ID)
		 where ID                = @ID               
		   and DELETED           = 0;
	end -- if;

	-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
	update TWITTER_MESSAGES_CSTM
	   set ID_C             = ID_C
	 where ID_C             = @ID;
  end
GO

Grant Execute on dbo.spTWITTER_MESSAGES_UpdateStatus to public;
GO

