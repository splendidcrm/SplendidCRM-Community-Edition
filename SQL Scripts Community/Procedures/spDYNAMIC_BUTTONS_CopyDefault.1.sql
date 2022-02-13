if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDYNAMIC_BUTTONS_CopyDefault' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDYNAMIC_BUTTONS_CopyDefault;
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
-- 04/13/2008 Paul.  Manually insert the ID to ease migration to Oracle. 
-- 03/14/2014 Paul.  Allow hidden buttons to be created. 
Create Procedure dbo.spDYNAMIC_BUTTONS_CopyDefault
	( @SOURCE_VIEW_NAME    nvarchar(50)
	, @NEW_VIEW_NAME       nvarchar(50)
	, @MODULE_NAME         nvarchar(25)
	)
as
  begin
	set nocount on
	
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = @NEW_VIEW_NAME and DELETED = 0) begin -- then
		insert into DYNAMIC_BUTTONS
			( ID
			, DATE_ENTERED      
			, DATE_MODIFIED     
			, VIEW_NAME         
			, CONTROL_INDEX     
			, CONTROL_TYPE      
			, DEFAULT_VIEW      
			, MODULE_NAME       
			, MODULE_ACCESS_TYPE
			, TARGET_NAME       
			, TARGET_ACCESS_TYPE
			, MOBILE_ONLY       
			, ADMIN_ONLY        
			, EXCLUDE_MOBILE    
			, HIDDEN            
			, CONTROL_TEXT      
			, CONTROL_TOOLTIP   
			, CONTROL_ACCESSKEY 
			, CONTROL_CSSCLASS  
			, TEXT_FIELD        
			, ARGUMENT_FIELD    
			, COMMAND_NAME      
			, URL_FORMAT        
			, URL_TARGET        
			, ONCLICK_SCRIPT    
			)
		select	   newid()
			,  getdate()
			,  getdate()
			, @NEW_VIEW_NAME
			,  CONTROL_INDEX     
			,  CONTROL_TYPE      
			,  DEFAULT_VIEW      
			, @MODULE_NAME       
			,  MODULE_ACCESS_TYPE
			,  TARGET_NAME       
			,  TARGET_ACCESS_TYPE
			,  MOBILE_ONLY       
			,  ADMIN_ONLY        
			,  EXCLUDE_MOBILE    
			,  HIDDEN            
			,  CONTROL_TEXT      
			,  CONTROL_TOOLTIP   
			,  CONTROL_ACCESSKEY 
			,  CONTROL_CSSCLASS  
			,  TEXT_FIELD        
			,  ARGUMENT_FIELD    
			,  COMMAND_NAME      
			,  URL_FORMAT        
			,  URL_TARGET        
			,  ONCLICK_SCRIPT    
		  from DYNAMIC_BUTTONS
		 where VIEW_NAME = @SOURCE_VIEW_NAME
		   and DELETED   = 0;
	end -- if;
  end
GO

Grant Execute on dbo.spDYNAMIC_BUTTONS_CopyDefault to public;
GO

