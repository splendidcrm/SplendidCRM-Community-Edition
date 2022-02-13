if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTERMINOLOGY_ALIASES_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTERMINOLOGY_ALIASES_Update;
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
-- 07/24/2006 Paul.  Increase the MODULE_NAME to 25 to match the size in the MODULES table.
Create Procedure dbo.spTERMINOLOGY_ALIASES_Update
	( @ID                 uniqueidentifier output
	, @MODIFIED_USER_ID   uniqueidentifier
	, @ALIAS_NAME         nvarchar(50)
	, @ALIAS_MODULE_NAME  nvarchar(25)
	, @ALIAS_LIST_NAME    nvarchar(50)
	, @NAME               nvarchar(50)
	, @MODULE_NAME        nvarchar(25)
	, @LIST_NAME          nvarchar(50)
	)
as
  begin
	set nocount on
	
	if not exists(select * from TERMINOLOGY_ALIASES where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into TERMINOLOGY_ALIASES
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, ALIAS_NAME        
			, ALIAS_MODULE_NAME 
			, ALIAS_LIST_NAME   
			, NAME              
			, MODULE_NAME       
			, LIST_NAME         
			)
		values 	( @ID                
			, @MODIFIED_USER_ID        
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			, @ALIAS_NAME        
			, @ALIAS_MODULE_NAME 
			, @ALIAS_LIST_NAME   
			, @NAME              
			, @MODULE_NAME       
			, @LIST_NAME         
			);
	end else begin
		update TERMINOLOGY_ALIASES
		   set MODIFIED_USER_ID   = @MODIFIED_USER_ID  
		     , DATE_MODIFIED      =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , ALIAS_NAME         = @ALIAS_NAME        
		     , ALIAS_MODULE_NAME  = @ALIAS_MODULE_NAME 
		     , ALIAS_LIST_NAME    = @ALIAS_LIST_NAME   
		     , NAME               = @NAME              
		     , MODULE_NAME        = @MODULE_NAME       
		     , LIST_NAME          = @LIST_NAME         
		 where ID                 = @ID                ;
	end -- if;
  end
GO

Grant Execute on dbo.spTERMINOLOGY_ALIASES_Update to public;
GO

