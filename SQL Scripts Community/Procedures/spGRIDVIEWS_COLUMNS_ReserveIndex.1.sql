if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spGRIDVIEWS_COLUMNS_ReserveIndex' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spGRIDVIEWS_COLUMNS_ReserveIndex;
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
Create Procedure dbo.spGRIDVIEWS_COLUMNS_ReserveIndex
	( @MODIFIED_USER_ID            uniqueidentifier
	, @GRID_NAME                   nvarchar(50)
	, @RESERVE_INDEX               int
	)
as
  begin
	declare @MIN_INDEX int;
	-- BEGIN Oracle Exception
		select @MIN_INDEX = min(COLUMN_INDEX)
		  from GRIDVIEWS_COLUMNS
		 where GRID_NAME         = @GRID_NAME       
		   and DELETED           = 0                
		   and DEFAULT_VIEW      = 0                ;
	-- END Oracle Exception
	while @MIN_INDEX < @RESERVE_INDEX begin -- do
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX      = COLUMN_INDEX + 1 
		     , DATE_MODIFIED     =  getdate()       
		     , DATE_MODIFIED_UTC =  getutcdate()    
		     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
		 where GRID_NAME         = @GRID_NAME       
		   and DELETED           = 0                
		   and DEFAULT_VIEW      = 0                ;
		set @MIN_INDEX = @MIN_INDEX + 1;
	end -- while;

	-- BEGIN Oracle Exception
		select @MIN_INDEX = min(COLUMN_INDEX)
		  from GRIDVIEWS_COLUMNS
		 where GRID_NAME         = @GRID_NAME       
		   and DELETED           = 0                
		   and DEFAULT_VIEW      = 1                ;
	-- END Oracle Exception
	while @MIN_INDEX < @RESERVE_INDEX begin -- do
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX      = COLUMN_INDEX + 1 
		     , DATE_MODIFIED     =  getdate()       
		     , DATE_MODIFIED_UTC =  getutcdate()    
		     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
		 where GRID_NAME         = @GRID_NAME       
		   and DELETED           = 0                
		   and DEFAULT_VIEW      = 1                ;
		set @MIN_INDEX = @MIN_INDEX + 1;
	end -- while;
  end
GO
 
Grant Execute on dbo.spGRIDVIEWS_COLUMNS_ReserveIndex to public;
GO
 
