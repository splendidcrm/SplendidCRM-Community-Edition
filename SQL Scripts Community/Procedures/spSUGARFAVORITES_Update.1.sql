if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSUGARFAVORITES_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSUGARFAVORITES_Update;
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
Create Procedure dbo.spSUGARFAVORITES_Update
	( @MODIFIED_USER_ID   uniqueidentifier
	, @ASSIGNED_USER_ID   uniqueidentifier
	, @MODULE             nvarchar(25)
	, @RECORD_ID          uniqueidentifier
	, @NAME               nvarchar(255)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	if not exists(select * from SUGARFAVORITES where ASSIGNED_USER_ID = @ASSIGNED_USER_ID and @RECORD_ID = RECORD_ID and DELETED = 0) begin -- then
		set @ID = newid();
		insert into SUGARFAVORITES
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, DATE_MODIFIED_UTC 
			, ASSIGNED_USER_ID  
			, MODULE            
			, RECORD_ID         
			, NAME              
			)
		values 	( @ID                
			, @MODIFIED_USER_ID        
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			,  getutcdate()      
			, @ASSIGNED_USER_ID  
			, @MODULE            
			, @RECORD_ID         
			, @NAME              
			);
	end -- if;
  end
GO

Grant Execute on dbo.spSUGARFAVORITES_Update to public;
GO

