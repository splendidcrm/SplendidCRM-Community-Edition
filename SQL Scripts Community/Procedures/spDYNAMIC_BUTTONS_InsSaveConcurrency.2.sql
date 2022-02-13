if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDYNAMIC_BUTTONS_InsSaveConcurrency' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency;
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
Create Procedure dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency
	( @VIEW_NAME           nvarchar(50)
	, @CONTROL_INDEX       int
	, @MODULE_NAME         nvarchar(25)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	declare @TEMP_CONTROL_INDEX int;	
	set @TEMP_CONTROL_INDEX = @CONTROL_INDEX;
	
	if @CONTROL_INDEX = -1 begin -- then
		-- BEGIN Oracle Exception
			select @ID = ID
			  from DYNAMIC_BUTTONS
			 where VIEW_NAME     = @VIEW_NAME    
			   and COMMAND_NAME  = N'SaveConcurrency'
			   and DELETED       = 0             
			   and DEFAULT_VIEW  = 0             ;
		-- END Oracle Exception
	end else begin
		-- BEGIN Oracle Exception
			select @ID = ID
			  from DYNAMIC_BUTTONS
			 where VIEW_NAME     = @VIEW_NAME    
			   and CONTROL_INDEX = @CONTROL_INDEX
			   and DELETED       = 0             
			   and DEFAULT_VIEW  = 0             ;
		-- END Oracle Exception
	end -- if;
	if not exists(select * from DYNAMIC_BUTTONS where ID = @ID) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_Update
			  @ID out
			, null                         -- MODIFIED_USER_ID    
			, @VIEW_NAME                   
			, @TEMP_CONTROL_INDEX          
			, N'Button'                    -- CONTROL_TYPE
			, @MODULE_NAME                 
			, N'edit'                      -- MODULE_ACCESS_TYPE
			, null                         -- TARGET_NAME         
			, null                         -- TARGET_ACCESS_TYPE  
			, N'.LBL_SAVE_CONCURRENCY_LABEL' -- CONTROL_TEXT        
			, N'.LBL_SAVE_CONCURRENCY_TITLE' -- CONTROL_TOOLTIP     
			, null                         -- CONTROL_ACCESSKEY   
			, N'button'                    -- CONTROL_CSSCLASS
			, null                         -- TEXT_FIELD          
			, null                         -- ARGUMENT_FIELD      
			, N'SaveConcurrency'           -- COMMAND_NAME        
			, null                         -- URL_FORMAT
			, null                         -- URL_TARGET
			, null                         -- ONCLICK_SCRIPT      
			, null                         -- MOBILE_ONLY         
			, 0                            -- ADMIN_ONLY          
			, null                         -- EXCLUDE_MOBILE      
			, 1                            -- HIDDEN              
			;
	end -- if;
  end
GO

Grant Execute on dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency to public;
GO

