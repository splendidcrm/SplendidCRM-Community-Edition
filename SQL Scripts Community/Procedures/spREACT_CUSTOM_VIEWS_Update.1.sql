if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spREACT_CUSTOM_VIEWS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spREACT_CUSTOM_VIEWS_Update;
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
-- 12/06/2021 Paul.  spSUGARFAVORITES_UpdateName does not apply to REACT_CUSTOM_VIEWS. 
Create Procedure dbo.spREACT_CUSTOM_VIEWS_Update
	( @ID                 uniqueidentifier output
	, @MODIFIED_USER_ID   uniqueidentifier
	, @NAME               nvarchar(100)
	, @MODULE_NAME        nvarchar(50)
	, @CATEGORY           nvarchar(25)
	, @CONTENT            nvarchar(max)
	)
as
  begin
	set nocount on
	
	if exists(select * from REACT_CUSTOM_VIEWS where NAME = @NAME and MODULE_NAME = @MODULE_NAME and CATEGORY = @CATEGORY and (ID <> @ID or @ID is null)) begin -- then
		raiserror(N'spREACT_CUSTOM_VIEWS_Update: A custom view for module %s and category %s', 16, 1, @MODULE_NAME, @CATEGORY);
		return;
	end -- if;
	if not exists(select * from REACT_CUSTOM_VIEWS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into REACT_CUSTOM_VIEWS
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, DATE_MODIFIED_UTC 
			, NAME              
			, MODULE_NAME       
			, CATEGORY          
			, CONTENT           
			)
		values 	( @ID                
			, @MODIFIED_USER_ID        
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			,  getutcdate()      
			, @NAME              
			, @MODULE_NAME       
			, @CATEGORY          
			, @CONTENT           
			);
	end else begin
		update REACT_CUSTOM_VIEWS
		   set MODIFIED_USER_ID   = @MODIFIED_USER_ID  
		     , DATE_MODIFIED      =  getdate()         
		     , DATE_MODIFIED_UTC  =  getutcdate()      
		     , NAME               = @NAME              
		     , MODULE_NAME        = @MODULE_NAME       
		     , CATEGORY           = @CATEGORY          
		     , CONTENT            = @CONTENT           
		 where ID                 = @ID                ;
		
		-- 12/06/2021 Paul.  spSUGARFAVORITES_UpdateName does not apply to REACT_CUSTOM_VIEWS. 
	end -- if;
  end
GO

Grant Execute on dbo.spREACT_CUSTOM_VIEWS_Update to public;
GO

