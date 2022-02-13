if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSHORTCUTS_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSHORTCUTS_InsertOnly;
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
-- 04/28/2006 Paul.  Added SHORTCUT_MODULE to help with ACL. 
-- 04/28/2006 Paul.  Added SHORTCUT_ACLTYPE to help with ACL. 
-- 07/24/2006 Paul.  Increase the DISPLAY_NAME to 150 to allow a fully-qualified (NAME+MODULE_NAME+LIST_NAME) TERMINOLOGY name. 
-- 06/02/2012 Paul.  Auto-number the shortcut order. 
-- 09/28/2015 Paul.  Also allow -1 to indicate auto-number. 
Create Procedure dbo.spSHORTCUTS_InsertOnly
	( @MODIFIED_USER_ID  uniqueidentifier
	, @MODULE_NAME       nvarchar( 25)
	, @DISPLAY_NAME      nvarchar(150)
	, @RELATIVE_PATH     nvarchar(255)
	, @IMAGE_NAME        nvarchar( 50)
	, @SHORTCUT_ENABLED  bit
	, @SHORTCUT_ORDER    int
	, @SHORTCUT_MODULE   nvarchar( 25)
	, @SHORTCUT_ACLTYPE  nvarchar(100)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- 09/28/2015 Paul.  Oracle typically has an issue with modifying input parameters. 
	declare @TEMP_SHORTCUT_ORDER    int;
	set @TEMP_SHORTCUT_ORDER = @SHORTCUT_ORDER;
	if @TEMP_SHORTCUT_ORDER is null or @TEMP_SHORTCUT_ORDER = -1 begin -- then
		-- BEGIN Oracle Exception
			select @TEMP_SHORTCUT_ORDER = isnull(max(SHORTCUT_ORDER) + 1, 0)
			  from vwSHORTCUTS
			 where MODULE_NAME   = @MODULE_NAME  ;
		-- END Oracle Exception
	end -- if;
	
	-- BEGIN Oracle Exception
		select @ID = ID
		  from SHORTCUTS
		 where MODULE_NAME   = @MODULE_NAME  
		   and DISPLAY_NAME  = @DISPLAY_NAME 
		   and RELATIVE_PATH = @RELATIVE_PATH
		   and DELETED       = 0             ;
	-- END Oracle Exception
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into SHORTCUTS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, MODULE_NAME      
			, DISPLAY_NAME     
			, RELATIVE_PATH    
			, IMAGE_NAME       
			, SHORTCUT_ENABLED 
			, SHORTCUT_ORDER   
			, SHORTCUT_MODULE  
			, SHORTCUT_ACLTYPE 
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
			, @IMAGE_NAME       
			, @SHORTCUT_ENABLED 
			, @TEMP_SHORTCUT_ORDER
			, @SHORTCUT_MODULE  
			, @SHORTCUT_ACLTYPE 
			);
	end -- if;
  end
GO
 
Grant Execute on dbo.spSHORTCUTS_InsertOnly to public;
GO
 
