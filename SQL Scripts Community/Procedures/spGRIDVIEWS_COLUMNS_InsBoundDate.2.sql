if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spGRIDVIEWS_COLUMNS_InsBoundDate' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spGRIDVIEWS_COLUMNS_InsBoundDate;
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
-- 04/28/2006 Paul.  Added URL_MODULE.
-- 05/02/2006 Paul.  Add URL_ASSIGNED_FIELD to support ACL. 
-- 07/24/2006 Paul.  Increase the HEADER_TEXT to 150 to allow a fully-qualified (NAME+MODULE_NAME+LIST_NAME) TERMINOLOGY name. 
-- 11/24/2006 Paul.  COLUMN_TYPE should be of national character type. 
-- 09/12/2010 Paul.  Add default parameter MODULE_TYPE to ease migration to EffiProz. 
-- 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
-- 03/01/2014 Paul.  Increase size of DATA_FORMAT. 
-- 02/24/2022 Paul.  Allow a field to be added to the end using an index of -1. 
Create Procedure dbo.spGRIDVIEWS_COLUMNS_InsBoundDate
	( @GRID_NAME                   nvarchar( 50)
	, @COLUMN_INDEX                int
	, @HEADER_TEXT                 nvarchar(150)
	, @DATA_FIELD                  nvarchar( 50)
	, @SORT_EXPRESSION             nvarchar( 50)
	, @ITEMSTYLE_WIDTH             nvarchar( 10)
	, @DATA_FORMAT                 nvarchar( 25)
	)
as
  begin

	declare @ID        uniqueidentifier;
	declare @COLUMN_ID uniqueidentifier;
	
	-- 02/24/2022 Paul.  Allow a field to be added to the end using an index of -1. 
	declare @TEMP_COLUMN_INDEX int;	
	set @TEMP_COLUMN_INDEX = @COLUMN_INDEX;
	if @COLUMN_INDEX is null or @COLUMN_INDEX = -1 begin -- then
		-- BEGIN Oracle Exception
			select @TEMP_COLUMN_INDEX = isnull(max(COLUMN_INDEX), 0) + 1
			  from GRIDVIEWS_COLUMNS
			 where GRID_NAME    = @GRID_NAME
			   and DELETED      = 0            
			   and DEFAULT_VIEW = 0            ;
		-- END Oracle Exception
		-- BEGIN Oracle Exception
			select @ID = ID
			  from GRIDVIEWS_COLUMNS
			 where GRID_NAME    = @GRID_NAME
			   and DATA_FIELD   = @DATA_FIELD
			   and DELETED      = 0            
			   and DEFAULT_VIEW = 0            ;
		-- END Oracle Exception
	end else begin
		-- BEGIN Oracle Exception
			select @ID = ID
			  from GRIDVIEWS_COLUMNS
			 where GRID_NAME    = @GRID_NAME
			   and COLUMN_INDEX = @COLUMN_INDEX
			   and DELETED      = 0            
			   and DEFAULT_VIEW = 0            ;
		-- END Oracle Exception
	end -- if;
	if not exists(select * from GRIDVIEWS_COLUMNS where ID = @ID) begin -- then
		-- GRID_NAME, COLUMN_INDEX, COLUMN_TYPE, HEADER_TEXT, DATA_FIELD, SORT_EXPRESSION, ITEMSTYLE_WIDTH
		exec dbo.spGRIDVIEWS_COLUMNS_Update
			  @COLUMN_ID out
			, null
			, @GRID_NAME
			, @TEMP_COLUMN_INDEX
			, N'TemplateColumn'
			, @HEADER_TEXT
			, @SORT_EXPRESSION
			, @ITEMSTYLE_WIDTH
			, null
			, null
			, null
			, null
			, @DATA_FIELD
			, @DATA_FORMAT
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
 
Grant Execute on dbo.spGRIDVIEWS_COLUMNS_InsBoundDate to public;
GO
 
