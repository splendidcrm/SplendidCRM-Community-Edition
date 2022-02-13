if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDASHBOARDS_PANELS_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDASHBOARDS_PANELS_InsertOnly;
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
Create Procedure dbo.spDASHBOARDS_PANELS_InsertOnly
	( @DASHBOARD_ID       uniqueidentifier
	, @DASHBOARD_APP_NAME nvarchar(150)
	, @PANEL_ORDER        int
	, @ROW_INDEX          int
	, @COLUMN_WIDTH       int
	)
as
  begin
	set nocount on
	
	declare @ID                 uniqueidentifier;
	declare @MODIFIED_USER_ID   uniqueidentifier;
	declare @DASHBOARD_APP_ID   uniqueidentifier;

	select @DASHBOARD_APP_ID = ID
	  from DASHBOARD_APPS
	 where NAME    = @DASHBOARD_APP_NAME
	   and DELETED = 0;

	if not exists(select * from DASHBOARDS_PANELS where DASHBOARD_ID = @DASHBOARD_ID and DASHBOARD_APP_ID = @DASHBOARD_APP_ID) begin -- then
		set @ID = newid();
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
	end -- if;
  end
GO

Grant Execute on dbo.spDASHBOARDS_PANELS_InsertOnly to public;
GO

