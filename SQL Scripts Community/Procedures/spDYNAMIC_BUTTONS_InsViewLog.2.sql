if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDYNAMIC_BUTTONS_InsViewLog' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDYNAMIC_BUTTONS_InsViewLog;
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
-- 03/14/2014 Paul.  Allow hidden buttons to be created. 
Create Procedure dbo.spDYNAMIC_BUTTONS_InsViewLog
	( @VIEW_NAME           nvarchar(50)
	, @CONTROL_INDEX       int
	, @MODULE_NAME         nvarchar(25)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	
	-- BEGIN Oracle Exception
		select @ID = ID
		  from DYNAMIC_BUTTONS
		 where VIEW_NAME     = @VIEW_NAME    
		   and COMMAND_NAME  = N'ViewLog'    
		   and DELETED       = 0             
		   and DEFAULT_VIEW  = 0             ;
	-- END Oracle Exception
	if not exists(select * from DYNAMIC_BUTTONS where ID = @ID) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_Update
			  @ID out
			, null                    -- MODIFIED_USER_ID    
			, @VIEW_NAME           
			, @CONTROL_INDEX       
			, N'Button'               -- CONTROL_TYPE
			, @MODULE_NAME         
			, N'view'                 -- MODULE_ACCESS_TYPE  
			, null                    -- TARGET_NAME         
			, null                    -- TARGET_ACCESS_TYPE  
			, N'.LNK_VIEW_CHANGE_LOG' -- CONTROL_TEXT        
			, N'.LNK_VIEW_CHANGE_LOG' -- CONTROL_TOOLTIP     
			, null                    -- CONTROL_ACCESSKEY   
			, N'button'               -- CONTROL_CSSCLASS
			, null                    -- TEXT_FIELD          
			, null                    -- ARGUMENT_FIELD      
			, N'ViewLog'              -- COMMAND_NAME        
			, null                    -- URL_FORMAT
			, null                    -- URL_TARGET
			, N'return PopupAudit();' -- ONCLICK_SCRIPT      
			, 0                       -- MOBILE_ONLY         
			, 0                       -- ADMIN_ONLY          
			, 1                       -- EXCLUDE_MOBILE
			, null                    -- HIDDEN              
			;
	end -- if;
  end
GO

Grant Execute on dbo.spDYNAMIC_BUTTONS_InsViewLog to public;
GO

