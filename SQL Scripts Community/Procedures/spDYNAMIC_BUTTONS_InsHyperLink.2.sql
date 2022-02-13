if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDYNAMIC_BUTTONS_InsHyperLink' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDYNAMIC_BUTTONS_InsHyperLink;
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
Create Procedure dbo.spDYNAMIC_BUTTONS_InsHyperLink
	( @VIEW_NAME           nvarchar(50)
	, @CONTROL_INDEX       int
	, @MODULE_NAME         nvarchar(25)
	, @MODULE_ACCESS_TYPE  nvarchar(100)
	, @TARGET_NAME         nvarchar(25)
	, @TARGET_ACCESS_TYPE  nvarchar(100)
	, @URL_FORMAT          nvarchar(255)
	, @TEXT_FIELD          nvarchar(200)
	, @CONTROL_TEXT        nvarchar(150)
	, @CONTROL_TOOLTIP     nvarchar(150)
	, @CONTROL_ACCESSKEY   nvarchar(150)
	, @ONCLICK_SCRIPT      nvarchar(255)
	, @URL_TARGET          nvarchar( 20)
	, @MOBILE_ONLY         bit
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	
	-- BEGIN Oracle Exception
		select @ID = ID
		  from DYNAMIC_BUTTONS
		 where VIEW_NAME     = @VIEW_NAME    
		   and CONTROL_INDEX = @CONTROL_INDEX
		   and DELETED       = 0             
		   and DEFAULT_VIEW  = 0             ;
	-- END Oracle Exception
	if not exists(select * from DYNAMIC_BUTTONS where ID = @ID) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_Update
			  @ID out
			, null                 -- MODIFIED_USER_ID    
			, @VIEW_NAME           
			, @CONTROL_INDEX       
			, N'HyperLink'         -- CONTROL_TYPE
			, @MODULE_NAME         
			, @MODULE_ACCESS_TYPE  
			, @TARGET_NAME         
			, @TARGET_ACCESS_TYPE  
			, @CONTROL_TEXT        
			, @CONTROL_TOOLTIP     
			, @CONTROL_ACCESSKEY   
			, N'listViewTdLinkS1'  -- CONTROL_CSSCLASS
			, @TEXT_FIELD          
			, null                 -- @ARGUMENT_FIELD
			, null                 -- COMMAND_NAME        
			, @URL_FORMAT          
			, @URL_TARGET          
			, @ONCLICK_SCRIPT      
			, @MOBILE_ONLY         
			, 0                    -- ADMIN_ONLY          
			, null                 -- EXCLUDE_MOBILE      
			, null                 -- HIDDEN      
			;
	end -- if;
  end
GO

Grant Execute on dbo.spDYNAMIC_BUTTONS_InsHyperLink to public;
GO

