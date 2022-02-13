if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEDITVIEWS_FIELDS_LstChange' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEDITVIEWS_FIELDS_LstChange;
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
-- 11/25/2006 Paul.  Create a procedure to convert a BoundList to a ChangeButton. 
-- This is because SugarCRM changed the Assigned To listbox to a Change field. 
-- 09/16/2012 Paul.  Increase ONCLICK_SCRIPT to nvarchar(max). 
Create Procedure dbo.spEDITVIEWS_FIELDS_LstChange
	( @EDIT_NAME         nvarchar( 50)
	, @FIELD_INDEX       int
	, @DATA_LABEL        nvarchar(150)
	, @DATA_FIELD        nvarchar(100)
	, @DATA_REQUIRED     bit
	, @FORMAT_TAB_INDEX  int
	, @DISPLAY_FIELD     nvarchar(100)
	, @ONCLICK_SCRIPT    nvarchar(max)
	, @COLSPAN           int
	)
as
  begin
	declare @ID uniqueidentifier;
	
	-- 11/25/2006 Paul.  First make sure that the data field exists. 
	-- BEGIN Oracle Exception
		select @ID = ID
		  from EDITVIEWS_FIELDS
		 where EDIT_NAME    = @EDIT_NAME
		   and DATA_FIELD   = @DATA_FIELD
		   and FIELD_TYPE   = N'ListBox'
		   and DELETED      = 0            
		   and DEFAULT_VIEW = 0            ;
	-- END Oracle Exception
	if dbo.fnIsEmptyGuid(@ID) = 0 begin -- then
		update EDITVIEWS_FIELDS
		   set MODIFIED_USER_ID =  null             
		     , DATE_MODIFIED    =  getdate()        
		     , DATE_MODIFIED_UTC=  getutcdate()     
		     , FIELD_TYPE       = N'ChangeButton'   
		     , DATA_LABEL       = @DATA_LABEL       
		     , CACHE_NAME       = null
		     , DISPLAY_FIELD    = @DISPLAY_FIELD    
		     , DATA_REQUIRED    = @DATA_REQUIRED    
		     , UI_REQUIRED      = @DATA_REQUIRED    
		     , ONCLICK_SCRIPT   = @ONCLICK_SCRIPT   
		     , FORMAT_TAB_INDEX = @FORMAT_TAB_INDEX 
		     , COLSPAN          = @COLSPAN          
		 where ID = @ID;
	end -- if;
	
	-- 11/25/2006 Paul.  Also change the default view. 
	-- BEGIN Oracle Exception
		select @ID = ID
		  from EDITVIEWS_FIELDS
		 where EDIT_NAME    = @EDIT_NAME
		   and DATA_FIELD   = @DATA_FIELD
		   and FIELD_TYPE   = N'ListBox'
		   and DELETED      = 0            
		   and DEFAULT_VIEW = 1            ;
	-- END Oracle Exception
	if dbo.fnIsEmptyGuid(@ID) = 0 begin -- then
		update EDITVIEWS_FIELDS
		   set MODIFIED_USER_ID =  null             
		     , DATE_MODIFIED    =  getdate()        
		     , DATE_MODIFIED_UTC=  getutcdate()     
		     , FIELD_TYPE       = N'ChangeButton'   
		     , DATA_LABEL       = @DATA_LABEL       
		     , CACHE_NAME       = null
		     , DISPLAY_FIELD    = @DISPLAY_FIELD    
		     , DATA_REQUIRED    = @DATA_REQUIRED    
		     , UI_REQUIRED      = @DATA_REQUIRED    
		     , ONCLICK_SCRIPT   = @ONCLICK_SCRIPT   
		     , FORMAT_TAB_INDEX = @FORMAT_TAB_INDEX 
		     , COLSPAN          = @COLSPAN          
		 where ID = @ID;
	end -- if;
  end
GO
 
Grant Execute on dbo.spEDITVIEWS_FIELDS_LstChange to public;
GO
 
