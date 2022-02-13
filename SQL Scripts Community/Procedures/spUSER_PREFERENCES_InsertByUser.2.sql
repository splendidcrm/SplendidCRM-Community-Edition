if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSER_PREFERENCES_InsertByUser' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSER_PREFERENCES_InsertByUser;
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
-- 08/27/2008 Paul.  PostgreSQL does not allow modifying input parameters.  Use a local temp variable. 
-- 10/21/2008 Paul.  Increase USER_NAME to 60 to match table. 
Create Procedure dbo.spUSER_PREFERENCES_InsertByUser
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @USER_NAME         nvarchar(60)
	, @CATEGORY          nvarchar(255)
	)
as
  begin
	set nocount on

	declare @ASSIGNED_USER_ID uniqueidentifier;
	declare @TEMP_USER_NAME   nvarchar(60);
	declare @TEMP_CATEGORY    nvarchar(255);
	-- 01/25/2007 Paul.  Convert to lowercase to support Oracle. 	
	set @TEMP_CATEGORY  = lower(@CATEGORY );
	set @TEMP_USER_NAME = lower(@USER_NAME);

	-- BEGIN Oracle Exception
		select @ASSIGNED_USER_ID = ID
		  from USERS
		 where lower(USER_NAME) = @TEMP_USER_NAME
		   and DELETED          = 0;
	-- END Oracle Exception

	exec dbo.spUSER_PREFERENCES_Insert @ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @TEMP_CATEGORY;
  end
GO

Grant Execute on dbo.spUSER_PREFERENCES_InsertByUser to public;
GO

