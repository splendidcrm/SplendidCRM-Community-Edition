if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spGRIDVIEWS_COLUMNS_UpdateStyle' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spGRIDVIEWS_COLUMNS_UpdateStyle;
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
Create Procedure dbo.spGRIDVIEWS_COLUMNS_UpdateStyle
	( @MODIFIED_USER_ID            uniqueidentifier
	, @GRID_NAME                   nvarchar(50)
	, @COLUMN_INDEX                int
	, @ITEMSTYLE_WIDTH             nvarchar(10)
	, @ITEMSTYLE_CSSCLASS          nvarchar(50)
	, @ITEMSTYLE_HORIZONTAL_ALIGN  nvarchar(10)
	, @ITEMSTYLE_VERTICAL_ALIGN    nvarchar(10)
	, @ITEMSTYLE_WRAP              bit
	)
as
  begin
	update GRIDVIEWS_COLUMNS
	   set MODIFIED_USER_ID            = @MODIFIED_USER_ID 
	     , DATE_MODIFIED               =  getdate()        
	     , DATE_MODIFIED_UTC           =  getutcdate()     
	     , ITEMSTYLE_WIDTH             = isnull(@ITEMSTYLE_WIDTH           , ITEMSTYLE_WIDTH           )
	     , ITEMSTYLE_CSSCLASS          = isnull(@ITEMSTYLE_CSSCLASS        , ITEMSTYLE_CSSCLASS        )
	     , ITEMSTYLE_HORIZONTAL_ALIGN  = isnull(@ITEMSTYLE_HORIZONTAL_ALIGN, ITEMSTYLE_HORIZONTAL_ALIGN)
	     , ITEMSTYLE_VERTICAL_ALIGN    = isnull(@ITEMSTYLE_VERTICAL_ALIGN  , ITEMSTYLE_VERTICAL_ALIGN  )
	     , ITEMSTYLE_WRAP              = isnull(@ITEMSTYLE_WRAP            , ITEMSTYLE_WRAP            )
	 where GRID_NAME                   = @GRID_NAME
	   and COLUMN_INDEX                = @COLUMN_INDEX
	   and DELETED                     = 0            
	   and DEFAULT_VIEW                = 0            ;
  end
GO
 
Grant Execute on dbo.spGRIDVIEWS_COLUMNS_UpdateStyle to public;
GO
 
