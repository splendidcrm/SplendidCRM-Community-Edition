if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spGRIDVIEWS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spGRIDVIEWS_Update;
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
-- 11/22/2010 Paul.  Add support for Business Rules Framework. 
-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
-- 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
Create Procedure dbo.spGRIDVIEWS_Update
	( @ID                  uniqueidentifier output
	, @MODIFIED_USER_ID    uniqueidentifier
	, @NAME                nvarchar(50)
	, @MODULE_NAME         nvarchar(25)
	, @VIEW_NAME           nvarchar(50)
	, @PRE_LOAD_EVENT_ID   uniqueidentifier = null
	, @POST_LOAD_EVENT_ID  uniqueidentifier = null
	, @SCRIPT              nvarchar(max) = null
	, @SORT_FIELD          nvarchar(50) = null
	, @SORT_DIRECTION      nvarchar(10) = null
	)
as
  begin
	if not exists(select * from GRIDVIEWS where NAME = @NAME and DELETED = 0) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into GRIDVIEWS
			( ID                 
			, CREATED_BY         
			, DATE_ENTERED       
			, MODIFIED_USER_ID   
			, DATE_MODIFIED      
			, NAME               
			, MODULE_NAME        
			, VIEW_NAME          
			, PRE_LOAD_EVENT_ID  
			, POST_LOAD_EVENT_ID 
			, SCRIPT             
			, SORT_FIELD         
			, SORT_DIRECTION     
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
			, @PRE_LOAD_EVENT_ID  
			, @POST_LOAD_EVENT_ID 
			, @SCRIPT             
			, @SORT_FIELD         
			, @SORT_DIRECTION     
			);
	end else begin
		update GRIDVIEWS
		   set MODIFIED_USER_ID    = @MODIFIED_USER_ID   
		     , DATE_MODIFIED       =  getdate()          
		     , DATE_MODIFIED_UTC   =  getutcdate()       
		     , NAME                = @NAME               
		     , MODULE_NAME         = @MODULE_NAME        
		     , VIEW_NAME           = @VIEW_NAME          
		     , PRE_LOAD_EVENT_ID   = @PRE_LOAD_EVENT_ID  
		     , POST_LOAD_EVENT_ID  = @POST_LOAD_EVENT_ID 
		     , SCRIPT              = @SCRIPT             
		     , SORT_FIELD          = @SORT_FIELD         
		     , SORT_DIRECTION      = @SORT_DIRECTION     
		 where NAME                = @NAME               
		   and DELETED = 0                              ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spGRIDVIEWS_Update to public;
GO
 
