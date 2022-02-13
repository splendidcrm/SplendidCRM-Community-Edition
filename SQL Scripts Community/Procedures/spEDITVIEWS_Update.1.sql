if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEDITVIEWS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEDITVIEWS_Update;
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
-- 12/02/2007 Paul.  Add field for data columns. 
-- 10/30/2010 Paul.  Add support for Business Rules Framework. 
-- 11/11/2010 Paul.  Change to Pre Load and Post Load. 
-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
Create Procedure dbo.spEDITVIEWS_Update
	( @ID                  uniqueidentifier output
	, @MODIFIED_USER_ID    uniqueidentifier
	, @NAME                nvarchar(50)
	, @MODULE_NAME         nvarchar(25)
	, @VIEW_NAME           nvarchar(50)
	, @LABEL_WIDTH         nvarchar(10)
	, @FIELD_WIDTH         nvarchar(10)
	, @DATA_COLUMNS        int
	, @NEW_EVENT_ID        uniqueidentifier = null
	, @PRE_LOAD_EVENT_ID   uniqueidentifier = null
	, @POST_LOAD_EVENT_ID  uniqueidentifier = null
	, @VALIDATION_EVENT_ID uniqueidentifier = null
	, @PRE_SAVE_EVENT_ID   uniqueidentifier = null
	, @POST_SAVE_EVENT_ID  uniqueidentifier = null
	, @SCRIPT              nvarchar(max) = null
	)
as
  begin
	if not exists(select * from EDITVIEWS where NAME = @NAME and DELETED = 0) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into EDITVIEWS
			( ID                 
			, CREATED_BY         
			, DATE_ENTERED       
			, MODIFIED_USER_ID   
			, DATE_MODIFIED      
			, NAME               
			, MODULE_NAME        
			, VIEW_NAME          
			, LABEL_WIDTH        
			, FIELD_WIDTH        
			, DATA_COLUMNS       
			, NEW_EVENT_ID       
			, PRE_LOAD_EVENT_ID  
			, POST_LOAD_EVENT_ID 
			, VALIDATION_EVENT_ID
			, PRE_SAVE_EVENT_ID  
			, POST_SAVE_EVENT_ID 
			, SCRIPT             
			)
		values 
			( @ID                 
			, @MODIFIED_USER_ID   
			,  getdate()          
			, @MODIFIED_USER_ID   
			,  getdate()          
			, @NAME               
			, @MODULE_NAME        
			, @VIEW_NAME          
			, @LABEL_WIDTH        
			, @FIELD_WIDTH        
			, @DATA_COLUMNS       
			, @NEW_EVENT_ID       
			, @PRE_LOAD_EVENT_ID  
			, @POST_LOAD_EVENT_ID 
			, @VALIDATION_EVENT_ID
			, @PRE_SAVE_EVENT_ID  
			, @POST_SAVE_EVENT_ID 
			, @SCRIPT             
			);
	end else begin
		update EDITVIEWS
		   set MODIFIED_USER_ID    = @MODIFIED_USER_ID   
		     , DATE_MODIFIED       =  getdate()          
		     , DATE_MODIFIED_UTC   =  getutcdate()       
		     , NAME                = @NAME               
		     , MODULE_NAME         = @MODULE_NAME        
		     , VIEW_NAME           = @VIEW_NAME          
		     , LABEL_WIDTH         = @LABEL_WIDTH        
		     , FIELD_WIDTH         = @FIELD_WIDTH        
		     , DATA_COLUMNS        = @DATA_COLUMNS       
		     , NEW_EVENT_ID        = @NEW_EVENT_ID       
		     , PRE_LOAD_EVENT_ID   = @PRE_LOAD_EVENT_ID  
		     , POST_LOAD_EVENT_ID  = @POST_LOAD_EVENT_ID 
		     , VALIDATION_EVENT_ID = @VALIDATION_EVENT_ID
		     , PRE_SAVE_EVENT_ID   = @PRE_SAVE_EVENT_ID  
		     , POST_SAVE_EVENT_ID  = @POST_SAVE_EVENT_ID 
		     , SCRIPT              = @SCRIPT             
		 where NAME                = @NAME               
		   and DELETED             = 0                   ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spEDITVIEWS_Update to public;
GO
 
