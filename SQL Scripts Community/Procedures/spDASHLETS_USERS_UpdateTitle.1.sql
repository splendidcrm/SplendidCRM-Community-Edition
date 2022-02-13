if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDASHLETS_USERS_UpdateTitle' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDASHLETS_USERS_UpdateTitle;
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
Create Procedure dbo.spDASHLETS_USERS_UpdateTitle
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @TITLE            nvarchar(100)
	)
as
  begin
	set nocount on

	if @TITLE is not null begin -- then
		-- BEGIN Oracle Exception
			update DASHLETS_USERS
			   set TITLE             = @TITLE
			     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			 where ID                = @ID
			   and DELETED           = 0;
		-- END Oracle Exception
	end -- if;
  end
GO

Grant Execute on dbo.spDASHLETS_USERS_UpdateTitle to public;
GO

