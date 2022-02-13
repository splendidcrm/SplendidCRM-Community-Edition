if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSUBSCRIPTIONS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSUBSCRIPTIONS_Update;
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
Create Procedure dbo.spSUBSCRIPTIONS_Update
	( @MODIFIED_USER_ID   uniqueidentifier
	, @ASSIGNED_USER_ID   uniqueidentifier
	, @PARENT_TYPE        nvarchar(25)
	, @PARENT_ID          uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	if not exists(select * from SUBSCRIPTIONS where ASSIGNED_USER_ID = @ASSIGNED_USER_ID and @PARENT_ID = PARENT_ID and DELETED = 0) begin -- then
		set @ID = newid();
		insert into SUBSCRIPTIONS
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, DATE_MODIFIED_UTC 
			, ASSIGNED_USER_ID  
			, PARENT_TYPE       
			, PARENT_ID         
			)
		values 	( @ID                
			, @MODIFIED_USER_ID  
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			,  getutcdate()      
			, @ASSIGNED_USER_ID  
			, @PARENT_TYPE       
			, @PARENT_ID         
			);
	end -- if;
  end
GO

Grant Execute on dbo.spSUBSCRIPTIONS_Update to public;
GO

