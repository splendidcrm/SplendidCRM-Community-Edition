if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDYNAMIC_BUTTONS_InsButton' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDYNAMIC_BUTTONS_InsButton;
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
-- 09/12/2010 Paul.  Add default parameter EXCLUDE_MOBILE to ease migration to EffiProz. 
-- 03/14/2014 Paul.  Allow hidden buttons to be created. 
-- 09/10/2015 Paul.  ChatMessages buttons use -1, so we need to support auto numbering. 
-- 03/06/2018 Paul.  CONTROL_TEXT is a better uniqueness indicator than ONCLICK_SCRIPT.  Fixes problem with MailMerge button not getting created. 
Create Procedure dbo.spDYNAMIC_BUTTONS_InsButton
	( @VIEW_NAME           nvarchar(50)
	, @CONTROL_INDEX       int
	, @MODULE_NAME         nvarchar(25)
	, @MODULE_ACCESS_TYPE  nvarchar(100)
	, @TARGET_NAME         nvarchar(25)
	, @TARGET_ACCESS_TYPE  nvarchar(100)
	, @COMMAND_NAME        nvarchar(50)
	, @ARGUMENT_FIELD      nvarchar(200)
	, @CONTROL_TEXT        nvarchar(150)
	, @CONTROL_TOOLTIP     nvarchar(150)
	, @CONTROL_ACCESSKEY   nvarchar(150)
	, @ONCLICK_SCRIPT      nvarchar(255)
	, @MOBILE_ONLY         bit
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	
	declare @TEMP_CONTROL_INDEX int;	
	set @TEMP_CONTROL_INDEX = @CONTROL_INDEX;
	if @CONTROL_INDEX is null or @CONTROL_INDEX = -1 begin -- then
		-- BEGIN Oracle Exception
			select @TEMP_CONTROL_INDEX = isnull(max(CONTROL_INDEX), 0) + 1
			  from DYNAMIC_BUTTONS
			 where VIEW_NAME    = @VIEW_NAME   
			   and DELETED      = 0            
			   and DEFAULT_VIEW = 0            ;
		-- END Oracle Exception
		-- BEGIN Oracle Exception
			select top 1 @ID = ID
			  from DYNAMIC_BUTTONS
			 where VIEW_NAME    = @VIEW_NAME   
			   and (COMMAND_NAME = @COMMAND_NAME or CONTROL_TEXT = @CONTROL_TEXT)
			   and DELETED      = 0            
			   and DEFAULT_VIEW = 0            ;
		-- END Oracle Exception
	end else begin
		-- BEGIN Oracle Exception
			select top 1 @ID = ID
			  from DYNAMIC_BUTTONS
			 where VIEW_NAME     = @VIEW_NAME    
			   and CONTROL_INDEX = @CONTROL_INDEX
			   and DELETED       = 0             
			   and DEFAULT_VIEW  = 0             ;
		-- END Oracle Exception
	end -- if;
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		exec dbo.spDYNAMIC_BUTTONS_Update
			  @ID out
			, null                 -- MODIFIED_USER_ID    
			, @VIEW_NAME           
			, @TEMP_CONTROL_INDEX       
			, N'Button'            -- CONTROL_TYPE
			, @MODULE_NAME         
			, @MODULE_ACCESS_TYPE  
			, @TARGET_NAME         
			, @TARGET_ACCESS_TYPE  
			, @CONTROL_TEXT        
			, @CONTROL_TOOLTIP     
			, @CONTROL_ACCESSKEY   
			, N'button'            -- CONTROL_CSSCLASS
			, null                 -- TEXT_FIELD          
			, @ARGUMENT_FIELD      
			, @COMMAND_NAME        
			, null                 -- URL_FORMAT
			, null                 -- URL_TARGET
			, @ONCLICK_SCRIPT      
			, @MOBILE_ONLY         
			, 0                    -- ADMIN_ONLY          
			, null                 -- EXCLUDE_MOBILE      
			, null                 -- HIDDEN              
			;
	end -- if;
  end
GO

Grant Execute on dbo.spDYNAMIC_BUTTONS_InsButton to public;
GO

