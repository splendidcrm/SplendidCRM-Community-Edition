if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spOAUTHKEYS_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spOAUTHKEYS_Delete;
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
Create Procedure dbo.spOAUTHKEYS_Delete
	( @MODIFIED_USER_ID uniqueidentifier
	, @ASSIGNED_USER_ID uniqueidentifier
	, @NAME             nvarchar(25)
	)
as
  begin
	set nocount on
	
	-- 04/08/2012 Paul.  When the OAuth key is deleted, the access tokens become invalid, so delete them. 
	exec dbo.spOAUTH_TOKENS_Delete @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @NAME;
	
	-- BEGIN Oracle Exception
		update OAUTHKEYS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ASSIGNED_USER_ID = @ASSIGNED_USER_ID
		   and NAME             = @NAME
		   and DELETED          = 0;
	-- END Oracle Exception
  end
GO

Grant Execute on dbo.spOAUTHKEYS_Delete to public;
GO

