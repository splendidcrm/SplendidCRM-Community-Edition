if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSER_PREFERENCES_Insert' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSER_PREFERENCES_Insert;
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
Create Procedure dbo.spUSER_PREFERENCES_Insert
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @CATEGORY          nvarchar(255)
	)
as
  begin
	set nocount on

	declare @TEMP_CATEGORY nvarchar(255);
	-- 01/25/2007 Paul.  Convert to lowercase to support Oracle. 	
	set @TEMP_CATEGORY = lower(@CATEGORY);
	-- BEGIN Oracle Exception
		select @ID = ID
		  from USER_PREFERENCES
		 where  CATEGORY         = @TEMP_CATEGORY
		   and (ASSIGNED_USER_ID = @ASSIGNED_USER_ID or ASSIGNED_USER_ID is null and @ASSIGNED_USER_ID is null)
		   and  DELETED          = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into USER_PREFERENCES
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, CATEGORY         
			, ASSIGNED_USER_ID 
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @CATEGORY         
			, @ASSIGNED_USER_ID 
			);
	end -- if;
  end
GO

Grant Execute on dbo.spUSER_PREFERENCES_Insert to public;
GO

