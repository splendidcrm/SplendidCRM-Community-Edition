if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_InsertOnly;
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
-- 04/24/2006 Paul.  Add IS_ADMIN to simplify ACL management. 
-- 04/24/2006 Paul.  When a module is inserted, also make sure to add the ACL_ACTIONS. 
-- 05/02/2006 Paul.  Add TABLE_NAME as direct table queries are required by SOAP and we need a mapping. 
-- 05/20/2006 Paul.  Add REPORT_ENABLED if the module can be the basis of a report. ACL rules will still apply. 
-- 10/06/2006 Paul.  Add IMPORT_ENABLED if the module can allow importing. 
-- 09/17/2008 Paul.  We need to be able to enable a few mobile modules. 
-- 01/13/2010 Paul.  Add the MASS_UPDATE_ENABLED flag. 
-- 04/01/2010 Paul.  Add Exchange Sync flag. 
-- 05/02/2010 Paul.  Need to be able to set the default for EXCHANGE_FOLDERS and EXCHANGE_CREATE_PARENT.
-- 09/12/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
-- 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
Create Procedure dbo.spMODULES_InsertOnly
	( @MODIFIED_USER_ID       uniqueidentifier
	, @MODULE_NAME            nvarchar(25)
	, @DISPLAY_NAME           nvarchar(50)
	, @RELATIVE_PATH          nvarchar(50)
	, @MODULE_ENABLED         bit
	, @TAB_ENABLED            bit
	, @TAB_ORDER              int
	, @PORTAL_ENABLED         bit
	, @CUSTOM_ENABLED         bit
	, @REPORT_ENABLED         bit
	, @IMPORT_ENABLED         bit
	, @IS_ADMIN               bit
	, @TABLE_NAME             nvarchar(30)
	, @MOBILE_ENABLED         bit = null
	, @MASS_UPDATE_ENABLED    bit = null
	, @EXCHANGE_SYNC          bit = null
	, @EXCHANGE_FOLDERS       bit = null
	, @EXCHANGE_CREATE_PARENT bit = null
	, @REST_ENABLED           bit = null
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	

	-- BEGIN Oracle Exception
		select @ID = ID
		  from MODULES
		 where MODULE_NAME = @MODULE_NAME
		   and DELETED      = 0          ;
	-- END Oracle Exception
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into MODULES
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, MODULE_NAME      
			, DISPLAY_NAME     
			, RELATIVE_PATH    
			, MODULE_ENABLED   
			, TAB_ENABLED      
			, TAB_ORDER        
			, PORTAL_ENABLED   
			, CUSTOM_ENABLED   
			, REPORT_ENABLED   
			, IMPORT_ENABLED   
			, IS_ADMIN         
			, TABLE_NAME       
			, MOBILE_ENABLED   
			, MASS_UPDATE_ENABLED
			, EXCHANGE_SYNC    
			, EXCHANGE_FOLDERS      
			, EXCHANGE_CREATE_PARENT
			, REST_ENABLED     
			, DUPLICATE_CHECHING_ENABLED
			)
		values 
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODULE_NAME      
			, @DISPLAY_NAME     
			, @RELATIVE_PATH    
			, @MODULE_ENABLED   
			, @TAB_ENABLED      
			, @TAB_ORDER        
			, @PORTAL_ENABLED   
			, @CUSTOM_ENABLED   
			, @REPORT_ENABLED   
			, @IMPORT_ENABLED   
			, @IS_ADMIN         
			, @TABLE_NAME       
			, @MOBILE_ENABLED   
			, @MASS_UPDATE_ENABLED
			, @EXCHANGE_SYNC    
			, @EXCHANGE_FOLDERS      
			, @EXCHANGE_CREATE_PARENT
			, @REST_ENABLED     
			, null
			);

		exec dbo.spACL_ACTIONS_InsertOnly 'admin' , @MODULE_NAME, 'module',  1;
		exec dbo.spACL_ACTIONS_InsertOnly 'access', @MODULE_NAME, 'module', 89;
		exec dbo.spACL_ACTIONS_InsertOnly 'view'  , @MODULE_NAME, 'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly 'list'  , @MODULE_NAME, 'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly 'edit'  , @MODULE_NAME, 'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly 'delete', @MODULE_NAME, 'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly 'import', @MODULE_NAME, 'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly 'export', @MODULE_NAME, 'module', 90;
	end -- if;

  end
GO
 
Grant Execute on dbo.spMODULES_InsertOnly to public;
GO
 

