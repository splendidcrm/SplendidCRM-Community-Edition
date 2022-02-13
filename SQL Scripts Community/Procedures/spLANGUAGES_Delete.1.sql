if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spLANGUAGES_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spLANGUAGES_Delete;
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
-- 05/20/2008 Paul.  Delete using the NAME. 
-- 08/07/2013 Paul.  Add Oracle Exception. 
Create Procedure dbo.spLANGUAGES_Delete
	( @MODIFIED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(10)
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update LANGUAGES
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where lower(NAME)      = lower(@NAME)
		   and DELETED          = 0;
	-- END Oracle Exception
	
	-- 05/20/2008 Paul.  When a language is deleted, so are all of its terms. 
	-- BEGIN Oracle Exception
		update TERMINOLOGY
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where lower(LANG)      = lower(@NAME)
		   and DELETED          = 0;
	-- END Oracle Exception
  end
GO
 
Grant Execute on dbo.spLANGUAGES_Delete to public;
GO
 
 
