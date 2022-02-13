if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEDITVIEWS_FIELDS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEDITVIEWS_FIELDS_Update;
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
-- 07/24/2006 Paul.  Increase the DATA_LABEL to 150 to allow a fully-qualified (NAME+MODULE_NAME+LIST_NAME) TERMINOLOGY name. 
-- 11/22/2006 Paul.  Prevent index from overlapping. This is needed to simplify inserting the TEAM field. 
-- 05/17/2009 Paul.  Add support for a generic module popup. 
-- 05/17/2009 Paul.  PostgreSQL does not allow modifying input parameters.  Use a local temp variable. 
-- 06/12/2009 Paul.  Add TOOL_TIP for help hover.
-- 08/26/2009 Paul.  Add support for TeamSelect, which has very few optional parameters. 
-- 09/12/2009 Paul.  Add FIELD_VALIDATOR_ID it can be edited with the DynamicLayout editor. 
-- 01/19/2010 Paul.  Add support for new DATA_FORMAT field. 
-- 09/13/2010 Paul.  Add relationship fields. 
-- 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
-- 09/16/2012 Paul.  Increase ONCLICK_SCRIPT to nvarchar(max). 
-- 11/21/2021 Paul.  React Client allows Module Type for ChangeButton. 
Create Procedure dbo.spEDITVIEWS_FIELDS_Update
	( @ID                      uniqueidentifier output
	, @MODIFIED_USER_ID        uniqueidentifier
	, @EDIT_NAME               nvarchar( 50)
	, @FIELD_INDEX             int
	, @FIELD_TYPE              nvarchar( 25)
	, @DATA_LABEL              nvarchar(150)
	, @DATA_FIELD              nvarchar(100)
	, @DISPLAY_FIELD           nvarchar(100)
	, @CACHE_NAME              nvarchar( 50)
	, @DATA_REQUIRED           bit
	, @UI_REQUIRED             bit
	, @ONCLICK_SCRIPT          nvarchar(max)
	, @FORMAT_SCRIPT           nvarchar(255)
	, @FORMAT_TAB_INDEX        int
	, @FORMAT_MAX_LENGTH       int
	, @FORMAT_SIZE             int
	, @FORMAT_ROWS             int
	, @FORMAT_COLUMNS          int
	, @COLSPAN                 int
	, @ROWSPAN                 int
	, @MODULE_TYPE             nvarchar( 25) = null
	, @TOOL_TIP                nvarchar(150) = null
	, @FIELD_VALIDATOR_ID      uniqueidentifier = null
	, @FIELD_VALIDATOR_MESSAGE nvarchar(150) = null
	, @DATA_FORMAT             nvarchar(100) = null
	, @RELATED_SOURCE_MODULE_NAME   nvarchar(50) = null
	, @RELATED_SOURCE_VIEW_NAME     nvarchar(50) = null
	, @RELATED_SOURCE_ID_FIELD      nvarchar(30) = null
	, @RELATED_SOURCE_NAME_FIELD    nvarchar(100) = null
	, @RELATED_VIEW_NAME            nvarchar(50) = null
	, @RELATED_ID_FIELD             nvarchar(30) = null
	, @RELATED_NAME_FIELD           nvarchar(100) = null
	, @RELATED_JOIN_FIELD           nvarchar(30) = null
	, @PARENT_FIELD                 nvarchar(30) = null
	)
as
  begin
	-- 05/17/2009 Paul.  PostgreSQL does not allow modifying input parameters.  Use a local temp variable. 
	declare @TEMP_DATA_LABEL              nvarchar(150);
	declare @TEMP_DATA_FIELD              nvarchar(100);
	declare @TEMP_DISPLAY_FIELD           nvarchar(100);
	declare @TEMP_CACHE_NAME              nvarchar( 50);
	declare @TEMP_DATA_REQUIRED           bit;
	declare @TEMP_UI_REQUIRED             bit;
	-- 10/01/2013 Paul.  ONCLICK_SCRIPT was increased to max. 
	declare @TEMP_ONCLICK_SCRIPT          nvarchar(max);
	declare @TEMP_FORMAT_SCRIPT           nvarchar(255);
	declare @TEMP_FORMAT_TAB_INDEX        int;
	declare @TEMP_FORMAT_MAX_LENGTH       int;
	declare @TEMP_FORMAT_SIZE             int;
	declare @TEMP_FORMAT_ROWS             int;
	declare @TEMP_FORMAT_COLUMNS          int;
	declare @TEMP_COLSPAN                 int;
	declare @TEMP_ROWSPAN                 int;
	declare @TEMP_MODULE_TYPE             nvarchar( 25);
	declare @TEMP_TOOL_TIP                nvarchar(150);
	declare @TEMP_FIELD_VALIDATOR_ID      uniqueidentifier;
	declare @TEMP_FIELD_VALIDATOR_MESSAGE nvarchar(150);
	declare @TEMP_DATA_FORMAT             nvarchar(100);
	declare @TEMP_RELATED_SOURCE_MODULE_NAME   nvarchar(50);
	declare @TEMP_RELATED_SOURCE_VIEW_NAME     nvarchar(50);
	declare @TEMP_RELATED_SOURCE_ID_FIELD      nvarchar(30);
	declare @TEMP_RELATED_SOURCE_NAME_FIELD    nvarchar(100);
	declare @TEMP_RELATED_VIEW_NAME            nvarchar(50);
	declare @TEMP_RELATED_ID_FIELD             nvarchar(30);
	declare @TEMP_RELATED_NAME_FIELD           nvarchar(100);
	declare @TEMP_RELATED_JOIN_FIELD           nvarchar(30);
	declare @TEMP_PARENT_FIELD                 nvarchar(30);

	set @TEMP_DATA_LABEL              = @DATA_LABEL             ;
	set @TEMP_DATA_FIELD              = @DATA_FIELD             ;
	set @TEMP_DISPLAY_FIELD           = @DISPLAY_FIELD          ;
	set @TEMP_CACHE_NAME              = @CACHE_NAME             ;
	set @TEMP_DATA_REQUIRED           = @DATA_REQUIRED          ;
	set @TEMP_UI_REQUIRED             = @UI_REQUIRED            ;
	set @TEMP_ONCLICK_SCRIPT          = @ONCLICK_SCRIPT         ;
	set @TEMP_FORMAT_SCRIPT           = @FORMAT_SCRIPT          ;
	set @TEMP_FORMAT_TAB_INDEX        = @FORMAT_TAB_INDEX       ;
	set @TEMP_FORMAT_MAX_LENGTH       = @FORMAT_MAX_LENGTH      ;
	set @TEMP_FORMAT_SIZE             = @FORMAT_SIZE            ;
	set @TEMP_FORMAT_ROWS             = @FORMAT_ROWS            ;
	set @TEMP_FORMAT_COLUMNS          = @FORMAT_COLUMNS         ;
	set @TEMP_COLSPAN                 = @COLSPAN                ;
	set @TEMP_ROWSPAN                 = @ROWSPAN                ;
	set @TEMP_MODULE_TYPE             = @MODULE_TYPE            ;
	-- 01/24/2010 Paul.  The tool tip was not being saved to the temp field. 
	set @TEMP_TOOL_TIP                = @TOOL_TIP               ;
	set @TEMP_FIELD_VALIDATOR_ID      = @FIELD_VALIDATOR_ID     ;
	set @TEMP_FIELD_VALIDATOR_MESSAGE = @FIELD_VALIDATOR_MESSAGE;
	set @TEMP_DATA_FORMAT             = @DATA_FORMAT            ;
	set @TEMP_RELATED_SOURCE_MODULE_NAME   = @RELATED_SOURCE_MODULE_NAME  ;
	set @TEMP_RELATED_SOURCE_VIEW_NAME     = @RELATED_SOURCE_VIEW_NAME    ;
	set @TEMP_RELATED_SOURCE_ID_FIELD      = @RELATED_SOURCE_ID_FIELD     ;
	set @TEMP_RELATED_SOURCE_NAME_FIELD    = @RELATED_SOURCE_NAME_FIELD   ;
	set @TEMP_RELATED_VIEW_NAME            = @RELATED_VIEW_NAME           ;
	set @TEMP_RELATED_ID_FIELD             = @RELATED_ID_FIELD            ;
	set @TEMP_RELATED_NAME_FIELD           = @RELATED_NAME_FIELD          ;
	set @TEMP_RELATED_JOIN_FIELD           = @RELATED_JOIN_FIELD          ;
	set @TEMP_PARENT_FIELD                 = @PARENT_FIELD                ;

	-- 03/19/2009 Paul.  We need to clear fields when using Blank. 
	if @FIELD_TYPE = N'Blank' begin -- then
		set @TEMP_DATA_LABEL              = null;
		set @TEMP_DATA_FIELD              = null;
		set @TEMP_DISPLAY_FIELD           = null;
		set @TEMP_CACHE_NAME              = null;
		set @TEMP_DATA_REQUIRED           = null;
		set @TEMP_UI_REQUIRED             = null;
		set @TEMP_ONCLICK_SCRIPT          = null;
		set @TEMP_FORMAT_SCRIPT           = null;
		set @TEMP_FORMAT_TAB_INDEX        = null;
		set @TEMP_FORMAT_MAX_LENGTH       = null;
		set @TEMP_FORMAT_SIZE             = null;
		set @TEMP_FORMAT_ROWS             = null;
		set @TEMP_FORMAT_COLUMNS          = null;
		set @TEMP_ROWSPAN                 = null;
		set @TEMP_TOOL_TIP                = null;
		set @TEMP_FIELD_VALIDATOR_ID      = null;
		set @TEMP_FIELD_VALIDATOR_MESSAGE = null;
		set @TEMP_DATA_FORMAT             = null;
		set @TEMP_RELATED_SOURCE_MODULE_NAME   = null;
		set @TEMP_RELATED_SOURCE_VIEW_NAME     = null;
		set @TEMP_RELATED_SOURCE_ID_FIELD      = null;
		set @TEMP_RELATED_SOURCE_NAME_FIELD    = null;
		set @TEMP_RELATED_VIEW_NAME            = null;
		set @TEMP_RELATED_ID_FIELD             = null;
		set @TEMP_RELATED_NAME_FIELD           = null;
		set @TEMP_RELATED_JOIN_FIELD           = null;
		set @TEMP_PARENT_FIELD                 = null;
	end -- if;
	-- 11/24/2011 Sabarish.  Module Type was getting cleared for ModuleAutoComplete and Label. 
	-- 11/21/2021 Paul.  React Client allows Module Type for ChangeButton. 
	if @FIELD_TYPE <> N'ModulePopup' and @FIELD_TYPE <> N'ModuleAutoComplete' and @FIELD_TYPE <> N'Label' and @FIELD_TYPE <> N'ChangeButton' begin -- then
		set @TEMP_MODULE_TYPE        = null;
	end -- if;
	if @FIELD_TYPE = N'TeamSelect' begin -- then
		set @TEMP_DATA_LABEL         = N'.LBL_TEAM_SET_NAME';
		set @TEMP_DATA_FIELD         = N'TEAM_SET_NAME';
		set @TEMP_DISPLAY_FIELD      = null;
		set @TEMP_ONCLICK_SCRIPT     = null;
	end -- if;
	if @FIELD_TYPE <> N'TextBox' begin -- then
		set @TEMP_FIELD_VALIDATOR_ID      = null;
		set @TEMP_FIELD_VALIDATOR_MESSAGE = null;
	end -- if;

	-- 01/09/2006 Paul.  Can't convert EDIT_NAME and FIELD_INDEX into an ID
	-- as it would prevent the Layout Manager from working properly. 
	if not exists(select * from EDITVIEWS_FIELDS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		-- 11/22/2006 Paul.  Prevent index from overlapping. 
		if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = @EDIT_NAME and FIELD_INDEX = @FIELD_INDEX and DEFAULT_VIEW = 0 and DELETED = 0) begin -- then
			update EDITVIEWS_FIELDS
			   set FIELD_INDEX   = FIELD_INDEX + 1
			 where EDIT_NAME     = @EDIT_NAME
			   and FIELD_INDEX  >= @FIELD_INDEX
			   and DEFAULT_VIEW  = 0
			   and DELETED       = 0;
		end -- if;
		insert into EDITVIEWS_FIELDS
			( ID                     
			, CREATED_BY             
			, DATE_ENTERED           
			, MODIFIED_USER_ID       
			, DATE_MODIFIED          
			, EDIT_NAME              
			, FIELD_INDEX            
			, FIELD_TYPE             
			, DATA_LABEL             
			, DATA_FIELD             
			, DISPLAY_FIELD          
			, CACHE_NAME             
			, DATA_REQUIRED          
			, UI_REQUIRED            
			, ONCLICK_SCRIPT         
			, FORMAT_SCRIPT          
			, FORMAT_TAB_INDEX       
			, FORMAT_MAX_LENGTH      
			, FORMAT_SIZE            
			, FORMAT_ROWS            
			, FORMAT_COLUMNS         
			, COLSPAN                
			, ROWSPAN                
			, MODULE_TYPE            
			, TOOL_TIP               
			, FIELD_VALIDATOR_ID     
			, FIELD_VALIDATOR_MESSAGE
			, DATA_FORMAT            
			, RELATED_SOURCE_MODULE_NAME  
			, RELATED_SOURCE_VIEW_NAME    
			, RELATED_SOURCE_ID_FIELD     
			, RELATED_SOURCE_NAME_FIELD   
			, RELATED_VIEW_NAME           
			, RELATED_ID_FIELD            
			, RELATED_NAME_FIELD          
			, RELATED_JOIN_FIELD          
			, PARENT_FIELD                
			)
		values 
			( @ID                          
			, @MODIFIED_USER_ID            
			,  getdate()                   
			, @MODIFIED_USER_ID            
			,  getdate()                   
			, @EDIT_NAME                   
			, @FIELD_INDEX                 
			, @FIELD_TYPE                  
			, @TEMP_DATA_LABEL             
			, @TEMP_DATA_FIELD             
			, @TEMP_DISPLAY_FIELD          
			, @TEMP_CACHE_NAME             
			, @TEMP_DATA_REQUIRED          
			, @TEMP_UI_REQUIRED            
			, @TEMP_ONCLICK_SCRIPT         
			, @TEMP_FORMAT_SCRIPT          
			, @TEMP_FORMAT_TAB_INDEX       
			, @TEMP_FORMAT_MAX_LENGTH      
			, @TEMP_FORMAT_SIZE            
			, @TEMP_FORMAT_ROWS            
			, @TEMP_FORMAT_COLUMNS         
			, @TEMP_COLSPAN                
			, @TEMP_ROWSPAN                
			, @TEMP_MODULE_TYPE            
			, @TEMP_TOOL_TIP               
			, @TEMP_FIELD_VALIDATOR_ID     
			, @TEMP_FIELD_VALIDATOR_MESSAGE
			, @TEMP_DATA_FORMAT            
			, @TEMP_RELATED_SOURCE_MODULE_NAME  
			, @TEMP_RELATED_SOURCE_VIEW_NAME    
			, @TEMP_RELATED_SOURCE_ID_FIELD     
			, @TEMP_RELATED_SOURCE_NAME_FIELD   
			, @TEMP_RELATED_VIEW_NAME           
			, @TEMP_RELATED_ID_FIELD            
			, @TEMP_RELATED_NAME_FIELD          
			, @TEMP_RELATED_JOIN_FIELD          
			, @TEMP_PARENT_FIELD                
			);
	end else begin
		update EDITVIEWS_FIELDS
		   set MODIFIED_USER_ID        = @MODIFIED_USER_ID            
		     , DATE_MODIFIED           =  getdate()                   
		     , DATE_MODIFIED_UTC       =  getutcdate()                
		     , EDIT_NAME               = @EDIT_NAME                   
		     , FIELD_INDEX             = @FIELD_INDEX                 
		     , FIELD_TYPE              = @FIELD_TYPE                  
		     , DATA_LABEL              = @TEMP_DATA_LABEL             
		     , DATA_FIELD              = @TEMP_DATA_FIELD             
		     , DISPLAY_FIELD           = @TEMP_DISPLAY_FIELD          
		     , CACHE_NAME              = @TEMP_CACHE_NAME             
		     , DATA_REQUIRED           = @TEMP_DATA_REQUIRED          
		     , UI_REQUIRED             = @TEMP_UI_REQUIRED            
		     , ONCLICK_SCRIPT          = @TEMP_ONCLICK_SCRIPT         
		     , FORMAT_SCRIPT           = @TEMP_FORMAT_SCRIPT          
		     , FORMAT_TAB_INDEX        = @TEMP_FORMAT_TAB_INDEX       
		     , FORMAT_MAX_LENGTH       = @TEMP_FORMAT_MAX_LENGTH      
		     , FORMAT_SIZE             = @TEMP_FORMAT_SIZE            
		     , FORMAT_ROWS             = @TEMP_FORMAT_ROWS            
		     , FORMAT_COLUMNS          = @TEMP_FORMAT_COLUMNS         
		     , COLSPAN                 = @TEMP_COLSPAN                
		     , ROWSPAN                 = @TEMP_ROWSPAN                
		     , MODULE_TYPE             = @TEMP_MODULE_TYPE            
		     , TOOL_TIP                = @TEMP_TOOL_TIP               
		     , FIELD_VALIDATOR_ID      = @TEMP_FIELD_VALIDATOR_ID     
		     , FIELD_VALIDATOR_MESSAGE = @TEMP_FIELD_VALIDATOR_MESSAGE
		     , DATA_FORMAT             = @TEMP_DATA_FORMAT            
		     , RELATED_SOURCE_MODULE_NAME   = @TEMP_RELATED_SOURCE_MODULE_NAME  
		     , RELATED_SOURCE_VIEW_NAME     = @TEMP_RELATED_SOURCE_VIEW_NAME    
		     , RELATED_SOURCE_ID_FIELD      = @TEMP_RELATED_SOURCE_ID_FIELD     
		     , RELATED_SOURCE_NAME_FIELD    = @TEMP_RELATED_SOURCE_NAME_FIELD   
		     , RELATED_VIEW_NAME            = @TEMP_RELATED_VIEW_NAME           
		     , RELATED_ID_FIELD             = @TEMP_RELATED_ID_FIELD            
		     , RELATED_NAME_FIELD           = @TEMP_RELATED_NAME_FIELD          
		     , RELATED_JOIN_FIELD           = @TEMP_RELATED_JOIN_FIELD          
		     , PARENT_FIELD                 = @TEMP_PARENT_FIELD                
		 where ID                 = @ID                ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spEDITVIEWS_FIELDS_Update to public;
GO
 
