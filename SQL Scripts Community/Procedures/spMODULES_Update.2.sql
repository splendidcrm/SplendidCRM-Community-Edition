if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_Update;
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
-- 09/08/2009 Paul.  Custom Paging can be enabled /disabled per module. 
-- 12/02/2009 Paul.  Add the ability to disable Mass Updates. 
-- 01/13/2010 Paul.  Allow default search to be disabled. 
-- 04/01/2010 Paul.  Add Exchange Sync flag. 
-- 04/04/2010 Paul.  Add Exchange Folders flag. 
-- 04/05/2010 Paul.  Add Exchange Create Parent flag. Need to be able to disable Account creation. 
-- 06/18/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
-- 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
-- 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
Create Procedure dbo.spMODULES_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @MODULE_NAME       nvarchar(25)
	, @DISPLAY_NAME      nvarchar(50)
	, @RELATIVE_PATH     nvarchar(50)
	, @MODULE_ENABLED    bit
	, @TAB_ENABLED       bit
	, @MOBILE_ENABLED    bit
	, @TAB_ORDER         int
	, @PORTAL_ENABLED    bit
	, @CUSTOM_ENABLED    bit
	, @REPORT_ENABLED    bit
	, @IMPORT_ENABLED    bit
	, @SYNC_ENABLED      bit
	, @IS_ADMIN          bit
	, @CUSTOM_PAGING     bit
	, @TABLE_NAME        nvarchar(30)
	, @MASS_UPDATE_ENABLED           bit = null
	, @DEFAULT_SEARCH_ENABLED        bit = null
	, @EXCHANGE_SYNC                 bit = null
	, @EXCHANGE_FOLDERS              bit = null
	, @EXCHANGE_CREATE_PARENT        bit = null
	, @REST_ENABLED                  bit = null
	, @DUPLICATE_CHECHING_ENABLED    bit = null
	, @RECORD_LEVEL_SECURITY_ENABLED bit = null
	)
as
  begin

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
			, MOBILE_ENABLED   
			, TAB_ORDER        
			, PORTAL_ENABLED   
			, CUSTOM_ENABLED   
			, REPORT_ENABLED   
			, IMPORT_ENABLED   
			, SYNC_ENABLED     
			, REST_ENABLED     
			, IS_ADMIN         
			, CUSTOM_PAGING    
			, TABLE_NAME       
			, MASS_UPDATE_ENABLED
			, DEFAULT_SEARCH_ENABLED
			, EXCHANGE_SYNC    
			, EXCHANGE_FOLDERS 
			, EXCHANGE_CREATE_PARENT
			, DUPLICATE_CHECHING_ENABLED
			, RECORD_LEVEL_SECURITY_ENABLED
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
			, @MOBILE_ENABLED   
			, @TAB_ORDER        
			, @PORTAL_ENABLED   
			, @CUSTOM_ENABLED   
			, @REPORT_ENABLED   
			, @IMPORT_ENABLED   
			, @SYNC_ENABLED     
			, @REST_ENABLED     
			, @IS_ADMIN         
			, @CUSTOM_PAGING    
			, @TABLE_NAME       
			, @MASS_UPDATE_ENABLED
			, @DEFAULT_SEARCH_ENABLED
			, @EXCHANGE_SYNC    
			, @EXCHANGE_FOLDERS 
			, @EXCHANGE_CREATE_PARENT
			, @DUPLICATE_CHECHING_ENABLED
			, @RECORD_LEVEL_SECURITY_ENABLED
			);
		exec dbo.spACL_ACTIONS_InsertOnly 'admin' , @MODULE_NAME, 'module',  1;
		exec dbo.spACL_ACTIONS_InsertOnly 'access', @MODULE_NAME, 'module', 89;
		exec dbo.spACL_ACTIONS_InsertOnly 'view'  , @MODULE_NAME, 'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly 'list'  , @MODULE_NAME, 'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly 'edit'  , @MODULE_NAME, 'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly 'delete', @MODULE_NAME, 'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly 'import', @MODULE_NAME, 'module', 90;
		exec dbo.spACL_ACTIONS_InsertOnly 'export', @MODULE_NAME, 'module', 90;
	end else begin
		update MODULES
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , DISPLAY_NAME      = @DISPLAY_NAME     
		     , RELATIVE_PATH     = @RELATIVE_PATH    
		     , MODULE_ENABLED    = @MODULE_ENABLED   
		     , TAB_ENABLED       = @TAB_ENABLED      
		     , MOBILE_ENABLED    = @MOBILE_ENABLED   
		     , TAB_ORDER         = @TAB_ORDER        
		     , PORTAL_ENABLED    = @PORTAL_ENABLED   
		     , CUSTOM_ENABLED    = @CUSTOM_ENABLED   
		     , REPORT_ENABLED    = @REPORT_ENABLED   
		     , IMPORT_ENABLED    = @IMPORT_ENABLED   
		     , SYNC_ENABLED      = @SYNC_ENABLED     
		     , REST_ENABLED      = @REST_ENABLED     
		     , IS_ADMIN          = @IS_ADMIN         
		     , CUSTOM_PAGING     = @CUSTOM_PAGING    
		     , TABLE_NAME        = @TABLE_NAME       
		     , MASS_UPDATE_ENABLED           = @MASS_UPDATE_ENABLED
		     , DEFAULT_SEARCH_ENABLED        = isnull(@DEFAULT_SEARCH_ENABLED       , 1)
		     , EXCHANGE_SYNC                 = isnull(@EXCHANGE_SYNC                , 0)
		     , EXCHANGE_FOLDERS              = isnull(@EXCHANGE_FOLDERS             , 0)
		     , EXCHANGE_CREATE_PARENT        = isnull(@EXCHANGE_CREATE_PARENT       , 0)
		     , DUPLICATE_CHECHING_ENABLED    = isnull(@DUPLICATE_CHECHING_ENABLED   , 0)
		     , RECORD_LEVEL_SECURITY_ENABLED = isnull(@RECORD_LEVEL_SECURITY_ENABLED, 0)
		 where ID                            = @ID;
	end -- if;

	-- 09/09/2009 Paul.  Correct any ordering problems. 
	exec dbo.spMODULES_TAB_ORDER_Reorder @MODIFIED_USER_ID;
  end
GO
 
Grant Execute on dbo.spMODULES_Update to public;
GO
 

