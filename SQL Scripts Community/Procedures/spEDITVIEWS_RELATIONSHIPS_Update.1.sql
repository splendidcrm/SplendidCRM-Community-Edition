if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEDITVIEWS_RELATIONSHIPS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEDITVIEWS_RELATIONSHIPS_Update;
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
-- 03/14/2016 Paul.  The new layout editor needs to update the RELATIONSHIP_ENABLED field. 
Create Procedure dbo.spEDITVIEWS_RELATIONSHIPS_Update
	( @ID                      uniqueidentifier output
	, @MODIFIED_USER_ID        uniqueidentifier
	, @EDIT_NAME               nvarchar(50)
	, @MODULE_NAME             nvarchar(50)
	, @CONTROL_NAME            nvarchar(100)
	, @RELATIONSHIP_ORDER      int
	, @NEW_RECORD_ENABLED      bit
	, @EXISTING_RECORD_ENABLED bit
	, @TITLE                   nvarchar(100)
	, @ALTERNATE_VIEW          nvarchar(50)
	, @RELATIONSHIP_ENABLED    bit = null
	)
as
  begin
	-- 01/09/2006 Paul.  Can't convert EDIT_NAME and FIELD_INDEX into an ID
	-- as it would prevent the Layout Manager from working properly. 
	if not exists(select * from EDITVIEWS_RELATIONSHIPS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
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
			( @ID                 
			, @MODIFIED_USER_ID   
			,  getdate()          
			, @MODIFIED_USER_ID   
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
	end else begin
		update EDITVIEWS_RELATIONSHIPS
		   set MODIFIED_USER_ID        = @MODIFIED_USER_ID   
		     , DATE_MODIFIED           =  getdate()          
		     , DATE_MODIFIED_UTC       =  getutcdate()       
		     , EDIT_NAME               = @EDIT_NAME          
		     , MODULE_NAME             = @MODULE_NAME        
		     , CONTROL_NAME            = @CONTROL_NAME       
		     , RELATIONSHIP_ORDER      = @RELATIONSHIP_ORDER 
		     , NEW_RECORD_ENABLED      = @NEW_RECORD_ENABLED     
		     , EXISTING_RECORD_ENABLED = @EXISTING_RECORD_ENABLED
		     , TITLE                   = @TITLE              
		     , ALTERNATE_VIEW          = @ALTERNATE_VIEW     
		     , RELATIONSHIP_ENABLED    = isnull(@RELATIONSHIP_ENABLED, RELATIONSHIP_ENABLED)
		 where ID                      = @ID                 ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spEDITVIEWS_RELATIONSHIPS_Update to public;
GO
 
