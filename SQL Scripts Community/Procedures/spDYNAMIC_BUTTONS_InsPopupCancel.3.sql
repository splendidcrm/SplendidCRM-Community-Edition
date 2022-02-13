if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDYNAMIC_BUTTONS_InsPopupCancel' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDYNAMIC_BUTTONS_InsPopupCancel;
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
Create Procedure dbo.spDYNAMIC_BUTTONS_InsPopupCancel
	( @VIEW_NAME           nvarchar(50)
	, @CONTROL_INDEX       int
	, @MODULE_NAME         nvarchar(25)
	, @MODULE_ACCESS_TYPE  nvarchar(100)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	declare @TARGET_NAME         nvarchar(25);
	declare @TARGET_ACCESS_TYPE  nvarchar(100);
	declare @ONCLICK_SCRIPT      nvarchar(255);
	declare @TEXT_FIELD          nvarchar(200);
	declare @CONTROL_TEXT        nvarchar(150);
	declare @CONTROL_TOOLTIP     nvarchar(150);
	declare @CONTROL_ACCESSKEY   nvarchar(150);
	declare @ARGUMENT_FIELD      nvarchar(200);
	declare @COMMAND_NAME        varchar(50);
	declare @MOBILE_ONLY         bit;

	-- BEGIN Oracle Exception
		select @ID = ID
		  from DYNAMIC_BUTTONS
		 where VIEW_NAME     = @VIEW_NAME    
		   and CONTROL_INDEX = @CONTROL_INDEX
		   and DELETED       = 0             
		   and DEFAULT_VIEW  = 0             ;
	-- END Oracle Exception

	-- 04/29/2008 Paul.  Popups should return false so that the button does not actually submit the form. 
	set @ONCLICK_SCRIPT    = N'Cancel(); return false;';
	set @CONTROL_TEXT      = N'.LBL_CANCEL_BUTTON_LABEL';
	set @CONTROL_TOOLTIP   = N'.LBL_CANCEL_BUTTON_TITLE';
	set @CONTROL_ACCESSKEY = N'.LBL_CANCEL_BUTTON_KEY'  ;
	set @COMMAND_NAME      = N'Cancel';

	if not exists(select * from DYNAMIC_BUTTONS where ID = @ID) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_Update
			  @ID out
			, null                 -- MODIFIED_USER_ID    
			, @VIEW_NAME           
			, @CONTROL_INDEX       
			, N'Button'            -- CONTROL_TYPE
			, @MODULE_NAME         
			, @MODULE_ACCESS_TYPE  
			, @TARGET_NAME         
			, @TARGET_ACCESS_TYPE  
			, @CONTROL_TEXT        
			, @CONTROL_TOOLTIP     
			, @CONTROL_ACCESSKEY   
			, N'button'            -- CONTROL_CSSCLASS
			, @TEXT_FIELD          
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

Grant Execute on dbo.spDYNAMIC_BUTTONS_InsPopupCancel to public;
GO

