if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spNOTES_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spNOTES_Delete;
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
-- 12/21/2007 Paul.  Only delete the attachment if there are no active records pointing to it. 
-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
Create Procedure dbo.spNOTES_Delete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on

	declare @NOTE_ATTACHMENT_ID uniqueidentifier;
	-- BEGIN Oracle Exception
		delete from TRACKER
		 where ITEM_ID          = @ID
		   and USER_ID          = @MODIFIED_USER_ID;
	-- END Oracle Exception
	
	exec dbo.spPARENT_Delete @ID, @MODIFIED_USER_ID;
	
	-- BEGIN Oracle Exception
		select @NOTE_ATTACHMENT_ID = NOTE_ATTACHMENT_ID
		  from NOTES
		 where ID               = @ID
		   and DELETED          = 0;
	-- END Oracle Exception

	-- BEGIN Oracle Exception
		update NOTES
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID
		   and DELETED          = 0;

		-- 01/30/2019 Paul.  Trigger audit record so delete workflow will have access to custom fields. 
		update NOTES_CSTM
		   set ID_C             = ID_C
		 where ID_C             = @ID;
	-- END Oracle Exception

	if dbo.fnIsEmptyGuid(@NOTE_ATTACHMENT_ID) = 0 begin -- then
		-- 12/21/2007 Paul.  Only delete the attachment if there are no active records pointing to it. 
		if not exists(select * from vwNOTE_ATTACHMENTS_Related where ID = @NOTE_ATTACHMENT_ID) begin -- then
			-- BEGIN Oracle Exception
				update NOTE_ATTACHMENTS
				   set DELETED          = 1
				     , DATE_MODIFIED    = getdate()
				     , DATE_MODIFIED_UTC= getutcdate()
				     , MODIFIED_USER_ID = @MODIFIED_USER_ID
				 where NOTE_ID          = @ID
				   and DELETED          = 0;
			-- END Oracle Exception
		end -- if;	
	end -- if;	

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

Grant Execute on dbo.spNOTES_Delete to public;
GO

