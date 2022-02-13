if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDASHBOARDS_PANELS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDASHBOARDS_PANELS_Update;
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
Create Procedure dbo.spDASHBOARDS_PANELS_Update
	( @ID                 uniqueidentifier output
	, @MODIFIED_USER_ID   uniqueidentifier
	, @DASHBOARD_ID       uniqueidentifier
	, @DASHBOARD_APP_ID   uniqueidentifier
	, @PANEL_ORDER        int
	, @ROW_INDEX          int
	, @COLUMN_WIDTH       int
	)
as
  begin
	set nocount on
	
	if not exists(select * from DASHBOARDS_PANELS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into DASHBOARDS_PANELS
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, DATE_MODIFIED_UTC 
			, DASHBOARD_ID      
			, DASHBOARD_APP_ID  
			, PANEL_ORDER       
			, ROW_INDEX         
			, COLUMN_WIDTH      
			)
		values 	( @ID                
			, @MODIFIED_USER_ID  
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			,  getutcdate()      
			, @DASHBOARD_ID      
			, @DASHBOARD_APP_ID  
			, @PANEL_ORDER       
			, @ROW_INDEX         
			, @COLUMN_WIDTH      
			);
	end else begin
		update DASHBOARDS_PANELS
		   set MODIFIED_USER_ID   = @MODIFIED_USER_ID  
		     , DATE_MODIFIED      =  getdate()         
		     , DATE_MODIFIED_UTC  =  getutcdate()      
		     , DASHBOARD_ID       = @DASHBOARD_ID      
		     , DASHBOARD_APP_ID   = @DASHBOARD_APP_ID  
		     , PANEL_ORDER        = @PANEL_ORDER       
		     , ROW_INDEX          = @ROW_INDEX         
		     , COLUMN_WIDTH       = @COLUMN_WIDTH      
		 where ID                 = @ID                ;
	end -- if;
  end
GO

Grant Execute on dbo.spDASHBOARDS_PANELS_Update to public;
GO

