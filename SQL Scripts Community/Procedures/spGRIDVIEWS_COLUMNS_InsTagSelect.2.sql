if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spGRIDVIEWS_COLUMNS_InsTagSelect' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spGRIDVIEWS_COLUMNS_InsTagSelect;
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
Create Procedure dbo.spGRIDVIEWS_COLUMNS_InsTagSelect
	( @GRID_NAME                   nvarchar( 50)
	, @COLUMN_INDEX                int
	, @ITEMSTYLE_WIDTH             nvarchar( 10)
	)
as
  begin
	declare @ID                uniqueidentifier;
	declare @HEADER_TEXT       nvarchar(150);
	declare @DATA_FIELD        nvarchar( 50);
	declare @SORT_EXPRESSION   nvarchar( 50);
	
	set @HEADER_TEXT     = N'.LBL_LIST_TAG_SET_NAME';
	set @DATA_FIELD      = N'TAG_SET_NAME';
	set @SORT_EXPRESSION = N'TAG_SET_NAME';

	-- 08/20/2016 Paul.  Insert only means that the grid and index is unique. 
	-- BEGIN Oracle Exception
		select @ID = ID
		  from GRIDVIEWS_COLUMNS
		 where GRID_NAME    = @GRID_NAME
		   and COLUMN_INDEX = @COLUMN_INDEX
		   and DELETED      = 0            
		   and DEFAULT_VIEW = 0            ;
	-- END Oracle Exception
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_Update
			  @ID out
			, null               -- MODIFIED_USER_ID
			, @GRID_NAME         -- GRID_NAME
			, @COLUMN_INDEX      -- COLUMN_INDEX
			, N'TemplateColumn'  -- COLUMN_TYPE
			, @HEADER_TEXT       -- HEADER_TEXT
			, @SORT_EXPRESSION   -- SORT_EXPRESSION
			, @ITEMSTYLE_WIDTH   -- ITEMSTYLE_WIDTH
			, null               -- ITEMSTYLE_CSSCLASS
			, null               -- ITEMSTYLE_HORIZONTAL_ALIGN
			, null               -- ITEMSTYLE_VERTICAL_ALIGN
			, null               -- ITEMSTYLE_WRAP    
			, @DATA_FIELD        -- DATA_FIELD        
			, N'Tags'            -- DATA_FORMAT       
			, null               -- URL_FIELD         
			, null               -- URL_FORMAT        
			, null               -- URL_TARGET        
			, null               -- LIST_NAME         
			, null               -- URL_MODULE        
			, null               -- URL_ASSIGNED_FIELD
			, null               -- MODULE_TYPE       
			, null               -- PARENT_FIELD      
			;
	end -- if;
  end
GO

Grant Execute on dbo.spGRIDVIEWS_COLUMNS_InsTagSelect to public;
GO

