if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEDITVIEWS_RELATIONSHIPS_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly;
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
Create Procedure dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly
	( @EDIT_NAME               nvarchar(50)
	, @MODULE_NAME             nvarchar(50)
	, @CONTROL_NAME            nvarchar(100)
	, @RELATIONSHIP_ENABLED    bit
	, @RELATIONSHIP_ORDER      int
	, @NEW_RECORD_ENABLED      bit
	, @EXISTING_RECORD_ENABLED bit
	, @TITLE                   nvarchar(100)
	, @ALTERNATE_VIEW          nvarchar(50)
	)
as
  begin
	if not exists(select * from EDITVIEWS_RELATIONSHIPS where EDIT_NAME = @EDIT_NAME and CONTROL_NAME = @CONTROL_NAME and DELETED = 0) begin -- then
		insert into EDITVIEWS_RELATIONSHIPS
			( ID                 
			, CREATED_BY         
			, DATE_ENTERED       
			, MODIFIED_USER_ID   
			, DATE_MODIFIED      
			, EDIT_NAME          
			, MODULE_NAME        
			, CONTROL_NAME       
			, RELATIONSHIP_ORDER 
			, RELATIONSHIP_ENABLED
			, NEW_RECORD_ENABLED     
			, EXISTING_RECORD_ENABLED
			, TITLE              
			, ALTERNATE_VIEW     
			)
		values 
			( newid()             
			, null                
			,  getdate()          
			, null                
			,  getdate()          
			, @EDIT_NAME          
			, @MODULE_NAME        
			, @CONTROL_NAME       
			, @RELATIONSHIP_ORDER 
			, @RELATIONSHIP_ENABLED
			, @NEW_RECORD_ENABLED     
			, @EXISTING_RECORD_ENABLED
			, @TITLE              
			, @ALTERNATE_VIEW     
			);
	end -- if;
  end
GO
 
Grant Execute on dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly to public;
GO
 
