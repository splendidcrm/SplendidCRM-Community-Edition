if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spGRIDVIEWS_COLUMNS_UpdateFormat' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spGRIDVIEWS_COLUMNS_UpdateFormat;
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
Create Procedure dbo.spGRIDVIEWS_COLUMNS_UpdateFormat
	( @MODIFIED_USER_ID            uniqueidentifier
	, @GRID_NAME                   nvarchar(50)
	, @DATA_FIELD                  nvarchar( 50)
	, @DATA_FORMAT                 nvarchar( 25)
	)
as
  begin
	update GRIDVIEWS_COLUMNS
	   set MODIFIED_USER_ID            = @MODIFIED_USER_ID 
	     , DATE_MODIFIED               =  getdate()        
	     , DATE_MODIFIED_UTC           =  getutcdate()     
	     , DATA_FORMAT                 = @DATA_FORMAT
	 where GRID_NAME                   = @GRID_NAME
	   and DATA_FIELD                  = @DATA_FIELD
	   and DELETED                     = 0            ;
  end
GO
 
Grant Execute on dbo.spGRIDVIEWS_COLUMNS_UpdateFormat to public;
GO
 
