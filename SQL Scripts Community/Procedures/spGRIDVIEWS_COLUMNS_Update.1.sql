if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spGRIDVIEWS_COLUMNS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spGRIDVIEWS_COLUMNS_Update;
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
-- 04/28/2006 Paul.  Add URL_MODULE to support ACL. 
-- 05/02/2006 Paul.  Add URL_ASSIGNED_FIELD to support ACL. 
-- 07/24/2006 Paul.  Increase the HEADER_TEXT to 150 to allow a fully-qualified (NAME+MODULE_NAME+LIST_NAME) TERMINOLOGY name. 
-- 11/22/2006 Paul.  Prevent index from overlapping. This is needed to simplify inserting the TEAM field. 
-- 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
-- 08/02/2010 Paul.  Increase the size of the URL_FIELD and URL_FORMAT so that we can add a javascript info column. 
-- 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
-- 10/30/2013 Paul.  Increase size of URL_TARGET. 
-- 03/01/2014 Paul.  Increase size of DATA_FORMAT. 
Create Procedure dbo.spGRIDVIEWS_COLUMNS_Update
	( @ID                          uniqueidentifier output
	, @MODIFIED_USER_ID            uniqueidentifier
	, @GRID_NAME                   nvarchar( 50)
	, @COLUMN_INDEX                int
	, @COLUMN_TYPE                 nvarchar( 25)
	, @HEADER_TEXT                 nvarchar(150)
	, @SORT_EXPRESSION             nvarchar( 50)
	, @ITEMSTYLE_WIDTH             nvarchar( 10)
	, @ITEMSTYLE_CSSCLASS          nvarchar( 50)
	, @ITEMSTYLE_HORIZONTAL_ALIGN  nvarchar( 10)
	, @ITEMSTYLE_VERTICAL_ALIGN    nvarchar( 10)
	, @ITEMSTYLE_WRAP              bit
	, @DATA_FIELD                  nvarchar( 50)
	, @DATA_FORMAT                 nvarchar( 25)
	, @URL_FIELD                   nvarchar(max)
	, @URL_FORMAT                  nvarchar(max)
	, @URL_TARGET                  nvarchar( 60)
	, @LIST_NAME                   nvarchar( 50)
	, @URL_MODULE                  nvarchar( 25)
	, @URL_ASSIGNED_FIELD          nvarchar( 30)
	, @MODULE_TYPE                 nvarchar( 25) = null
	, @PARENT_FIELD                nvarchar( 30) = null
	)
as
  begin
	-- 01/09/2006 Paul.  Can't convert EDIT_NAME and FIELD_INDEX into an ID
	-- as it would prevent the Layout Manager from working properly. 
	if not exists(select * from GRIDVIEWS_COLUMNS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		-- 11/22/2006 Paul.  Prevent index from overlapping. 
		if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = @GRID_NAME and COLUMN_INDEX = @COLUMN_INDEX and DEFAULT_VIEW = 0 and DELETED = 0) begin -- then
			update GRIDVIEWS_COLUMNS
			   set COLUMN_INDEX  = COLUMN_INDEX + 1
			 where GRID_NAME     = @GRID_NAME
			   and COLUMN_INDEX >= @COLUMN_INDEX
			   and DEFAULT_VIEW  = 0
			   and DELETED       = 0;
		end -- if;
		insert into GRIDVIEWS_COLUMNS
			( ID                         
			, CREATED_BY                 
			, DATE_ENTERED               
			, MODIFIED_USER_ID           
			, DATE_MODIFIED              
			, GRID_NAME                  
			, COLUMN_INDEX               
			, COLUMN_TYPE                
			, HEADER_TEXT                
			, SORT_EXPRESSION            
			, ITEMSTYLE_WIDTH            
			, ITEMSTYLE_CSSCLASS         
			, ITEMSTYLE_HORIZONTAL_ALIGN 
			, ITEMSTYLE_VERTICAL_ALIGN   
			, ITEMSTYLE_WRAP             
			, DATA_FIELD                 
			, DATA_FORMAT                
			, URL_FIELD                  
			, URL_FORMAT                 
			, URL_TARGET                 
			, LIST_NAME                  
			, URL_MODULE                 
			, URL_ASSIGNED_FIELD         
			, MODULE_TYPE                
			, PARENT_FIELD               
			)
		values 
			( @ID                         
			, @MODIFIED_USER_ID           
			,  getdate()                  
			, @MODIFIED_USER_ID           
			,  getdate()                  
			, @GRID_NAME                  
			, @COLUMN_INDEX               
			, @COLUMN_TYPE                
			, @HEADER_TEXT                
			, @SORT_EXPRESSION            
			, @ITEMSTYLE_WIDTH            
			, @ITEMSTYLE_CSSCLASS         
			, @ITEMSTYLE_HORIZONTAL_ALIGN 
			, @ITEMSTYLE_VERTICAL_ALIGN   
			, @ITEMSTYLE_WRAP             
			, @DATA_FIELD                 
			, @DATA_FORMAT                
			, @URL_FIELD                  
			, @URL_FORMAT                 
			, @URL_TARGET                 
			, @LIST_NAME                  
			, @URL_MODULE                 
			, @URL_ASSIGNED_FIELD         
			, @MODULE_TYPE                
			, @PARENT_FIELD               
			);
	end else begin
		update GRIDVIEWS_COLUMNS
		   set MODIFIED_USER_ID            = @MODIFIED_USER_ID           
		     , DATE_MODIFIED               =  getdate()                  
		     , DATE_MODIFIED_UTC           =  getutcdate()               
		     , GRID_NAME                   = @GRID_NAME                  
		     , COLUMN_INDEX                = @COLUMN_INDEX               
		     , COLUMN_TYPE                 = @COLUMN_TYPE                
		     , HEADER_TEXT                 = @HEADER_TEXT                
		     , SORT_EXPRESSION             = @SORT_EXPRESSION            
		     , ITEMSTYLE_WIDTH             = @ITEMSTYLE_WIDTH            
		     , ITEMSTYLE_CSSCLASS          = @ITEMSTYLE_CSSCLASS         
		     , ITEMSTYLE_HORIZONTAL_ALIGN  = @ITEMSTYLE_HORIZONTAL_ALIGN 
		     , ITEMSTYLE_VERTICAL_ALIGN    = @ITEMSTYLE_VERTICAL_ALIGN   
		     , ITEMSTYLE_WRAP              = @ITEMSTYLE_WRAP             
		     , DATA_FIELD                  = @DATA_FIELD                 
		     , DATA_FORMAT                 = @DATA_FORMAT                
		     , URL_FIELD                   = @URL_FIELD                  
		     , URL_FORMAT                  = @URL_FORMAT                 
		     , URL_TARGET                  = @URL_TARGET                 
		     , LIST_NAME                   = @LIST_NAME                  
		     , URL_MODULE                  = @URL_MODULE                 
		     , URL_ASSIGNED_FIELD          = @URL_ASSIGNED_FIELD         
		     , MODULE_TYPE                 = @MODULE_TYPE                
		     , PARENT_FIELD                = @PARENT_FIELD               
		 where ID                          = @ID                         ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spGRIDVIEWS_COLUMNS_Update to public;
GO
 
