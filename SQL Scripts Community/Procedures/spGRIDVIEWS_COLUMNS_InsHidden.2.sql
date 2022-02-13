if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spGRIDVIEWS_COLUMNS_InsHidden' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spGRIDVIEWS_COLUMNS_InsHidden;
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
Create Procedure dbo.spGRIDVIEWS_COLUMNS_InsHidden
	( @GRID_NAME                   nvarchar( 50)
	, @DATA_FIELD                  nvarchar( 50)
	)
as
  begin
	declare @ID                uniqueidentifier;
	declare @COLUMN_INDEX      int;
	
	-- 08/20/2016 Paul.  We only need one record for the hidden field, so the index is not important. 
	-- BEGIN Oracle Exception
		select @ID = ID
		  from GRIDVIEWS_COLUMNS
		 where GRID_NAME    = @GRID_NAME
		   and DATA_FIELD   = @DATA_FIELD
		   and DELETED      = 0            
		   and DEFAULT_VIEW = 0            ;
	-- END Oracle Exception
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		-- BEGIN Oracle Exception
			select @COLUMN_INDEX = isnull(max(COLUMN_INDEX), 0) + 1
			  from GRIDVIEWS_COLUMNS
			 where GRID_NAME    = @GRID_NAME
			   and DELETED      = 0            
			   and DEFAULT_VIEW = 0            ;
		-- END Oracle Exception

		exec dbo.spGRIDVIEWS_COLUMNS_Update
			  @ID out
			, null               -- MODIFIED_USER_ID
			, @GRID_NAME         -- GRID_NAME
			, @COLUMN_INDEX      -- COLUMN_INDEX
			, N'TemplateColumn'  -- COLUMN_TYPE
			, null               -- HEADER_TEXT
			, null               -- SORT_EXPRESSION
			, null               -- ITEMSTYLE_WIDTH
			, null               -- ITEMSTYLE_CSSCLASS
			, null               -- ITEMSTYLE_HORIZONTAL_ALIGN
			, null               -- ITEMSTYLE_VERTICAL_ALIGN
			, null               -- ITEMSTYLE_WRAP    
			, @DATA_FIELD        -- DATA_FIELD        
			, N'Hidden'          -- DATA_FORMAT       
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

Grant Execute on dbo.spGRIDVIEWS_COLUMNS_InsHidden to public;
GO

