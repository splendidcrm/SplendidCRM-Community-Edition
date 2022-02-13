if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDASHLETS_USERS_Init' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDASHLETS_USERS_Init;
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
Create Procedure dbo.spDASHLETS_USERS_Init
	( @MODIFIED_USER_ID uniqueidentifier
	, @ASSIGNED_USER_ID uniqueidentifier
	, @DETAIL_NAME      nvarchar(50)
	)
as
  begin
	set nocount on

	-- 07/10/2009 Paul.  If there are no relationships, then copy the default relationships. 	
	-- 08/01/2009 Paul.  Make sure to ignore deleted records. 
	if not exists(select * from DASHLETS_USERS where ASSIGNED_USER_ID = @ASSIGNED_USER_ID and DETAIL_NAME = @DETAIL_NAME and DELETED = 0) begin -- then
		insert into DASHLETS_USERS
			( CREATED_BY          
			, DATE_ENTERED        
			, MODIFIED_USER_ID    
			, DATE_MODIFIED       
			, ASSIGNED_USER_ID    
			, DETAIL_NAME         
			, MODULE_NAME         
			, CONTROL_NAME        
			, DASHLET_ORDER       
			, DASHLET_ENABLED     
			, TITLE               
			)
		select	  MODIFIED_USER_ID    
			, DATE_MODIFIED       
			, @MODIFIED_USER_ID   
			, getdate()           
			, @ASSIGNED_USER_ID   
			, DETAIL_NAME         
			, MODULE_NAME         
			, CONTROL_NAME        
			, RELATIONSHIP_ORDER  
			, RELATIONSHIP_ENABLED
			, TITLE               
		  from DETAILVIEWS_RELATIONSHIPS
		 where DETAIL_NAME = @DETAIL_NAME
		   and DELETED     = 0;
	end -- if;

	exec dbo.spDASHLETS_USERS_Reorder @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @DETAIL_NAME;
  end
GO

Grant Execute on dbo.spDASHLETS_USERS_Init to public;
GO

