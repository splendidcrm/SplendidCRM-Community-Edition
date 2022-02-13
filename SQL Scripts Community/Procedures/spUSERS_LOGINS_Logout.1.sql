if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_LOGINS_Logout' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_LOGINS_Logout;
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
Create Procedure dbo.spUSERS_LOGINS_Logout
	( @ID                uniqueidentifier
	, @MODIFIED_USER_ID  uniqueidentifier
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update USERS_LOGINS
		   set MODIFIED_USER_ID = @MODIFIED_USER_ID
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , LOGOUT_DATE      = getdate()
		 where ID               = @ID
		   and LOGOUT_DATE is null;
	-- END Oracle Exception
  end
GO

Grant Execute on dbo.spUSERS_LOGINS_Logout to public;
GO

