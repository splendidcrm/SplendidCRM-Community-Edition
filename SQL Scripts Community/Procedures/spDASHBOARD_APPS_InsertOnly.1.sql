if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDASHBOARD_APPS_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDASHBOARD_APPS_InsertOnly;
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
Create Procedure dbo.spDASHBOARD_APPS_InsertOnly
	( @NAME                nvarchar(150)
	, @CATEGORY            nvarchar(25)
	, @MODULE_NAME         nvarchar(50)
	, @TITLE               nvarchar(100)
	, @SETTINGS_EDITVIEW   nvarchar( 50)
	, @SCRIPT_URL          nvarchar(2083)
	, @IS_ADMIN            bit
	)
as
  begin
	if not exists(select * from DASHBOARD_APPS where NAME = @NAME and DELETED = 0) begin -- then
		insert into DASHBOARD_APPS
			( ID                 
			, CREATED_BY         
			, DATE_ENTERED       
			, MODIFIED_USER_ID   
			, DATE_MODIFIED      
			, NAME               
			, CATEGORY           
			, MODULE_NAME        
			, TITLE              
			, SETTINGS_EDITVIEW  
			, SCRIPT_URL         
			, IS_ADMIN           
			, APP_ENABLED        
			)
		values 
			(  newid()            
			,  null               
			,  getdate()          
			,  null               
			,  getdate()          
			, @NAME               
			, @CATEGORY           
			, @MODULE_NAME        
			, @TITLE              
			, @SETTINGS_EDITVIEW  
			, @SCRIPT_URL         
			, @IS_ADMIN           
			, 1                   
			);
	end -- if;
  end
GO

Grant Execute on dbo.spDASHBOARD_APPS_InsertOnly to public;
GO

