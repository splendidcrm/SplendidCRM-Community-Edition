if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spGRIDVIEWS_COLUMNS_InsField' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spGRIDVIEWS_COLUMNS_InsField;
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
-- 09/12/2010 Paul.  Add default parameter MODULE_TYPE to ease migration to EffiProz. 
-- 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
Create Procedure dbo.spGRIDVIEWS_COLUMNS_InsField
	( @GRID_NAME                   nvarchar( 50)
	, @COLUMN_INDEX                int
	, @HEADER_TEXT                 nvarchar(150)
	, @DATA_FIELD                  nvarchar( 50)
	, @SORT_EXPRESSION             nvarchar( 50)
	, @ITEMSTYLE_WIDTH             nvarchar( 10)
	)
as
  begin

	declare @ID uniqueidentifier;
	
	-- BEGIN Oracle Exception
		select @ID = ID
		  from GRIDVIEWS_COLUMNS
		 where GRID_NAME    = @GRID_NAME 
		   and DATA_FIELD   = @DATA_FIELD
		   and DELETED      = 0          
		   and DEFAULT_VIEW = 0          ;
	-- END Oracle Exception
	if not exists(select * from GRIDVIEWS_COLUMNS where ID = @ID) begin -- then
		set @ID = null;
		-- GRID_NAME, COLUMN_INDEX, COLUMN_TYPE, HEADER_TEXT, DATA_FIELD, SORT_EXPRESSION, ITEMSTYLE_WIDTH
		exec dbo.spGRIDVIEWS_COLUMNS_Update
			  @ID out
			, null
			, @GRID_NAME
			, @COLUMN_INDEX
			, 'BoundColumn'
			, @HEADER_TEXT
			, @SORT_EXPRESSION
			, @ITEMSTYLE_WIDTH
			, null
			, null
			, null
			, null
			, @DATA_FIELD
			, null             -- DATA_FORMAT       
			, null             -- URL_FIELD         
			, null             -- URL_FORMAT        
			, null             -- URL_TARGET        
			, null             -- LIST_NAME         
			, null             -- URL_MODULE        
			, null             -- URL_ASSIGNED_FIELD
			, null             -- MODULE_TYPE       
			, null             -- PARENT_FIELD      
			;
	end -- if;
  end
GO
 
Grant Execute on dbo.spGRIDVIEWS_COLUMNS_InsField to public;
GO
 
