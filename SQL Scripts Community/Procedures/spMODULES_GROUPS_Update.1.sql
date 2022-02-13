if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_GROUPS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_GROUPS_Update;
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
-- 02/24/2010 Paul.  We need to specify an order to the modules for the tab menu. 
Create Procedure dbo.spMODULES_GROUPS_Update
	( @MODIFIED_USER_ID   uniqueidentifier
	, @GROUP_NAME         nvarchar(25)
	, @MODULE_NAME        nvarchar(50)
	, @MODULE_ORDER       int
	, @MODULE_MENU        bit
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from MODULES_GROUPS
		 where GROUP_NAME        = @GROUP_NAME
		   and MODULE_NAME       = @MODULE_NAME
		   and DELETED           = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into MODULES_GROUPS
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, DATE_MODIFIED_UTC 
			, GROUP_NAME        
			, MODULE_NAME       
			, MODULE_ORDER      
			, MODULE_MENU       
			)
		values 	( @ID                
			, @MODIFIED_USER_ID  
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			,  getutcdate()      
			, @GROUP_NAME        
			, @MODULE_NAME       
			, @MODULE_ORDER      
			, @MODULE_MENU       
			);
	end -- if;
  end
GO

Grant Execute on dbo.spMODULES_GROUPS_Update to public;
GO

