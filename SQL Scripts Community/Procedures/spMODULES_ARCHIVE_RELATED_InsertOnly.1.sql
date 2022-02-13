if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_ARCHIVE_RELATED_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_ARCHIVE_RELATED_InsertOnly;
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
Create Procedure dbo.spMODULES_ARCHIVE_RELATED_InsertOnly
	( @MODULE_NAME        nvarchar(25)
	, @RELATED_NAME       nvarchar(25)
	, @RELATED_ORDER      int
	)
as
  begin
	set nocount on
	
	declare @ID                uniqueidentifier;
	declare @MODIFIED_USER_ID  uniqueidentifier;
	if not exists(select * from MODULES_ARCHIVE_RELATED where MODULE_NAME = @MODULE_NAME and RELATED_NAME = @RELATED_NAME and DELETED = 0) begin -- then
		set @ID = newid();
		insert into MODULES_ARCHIVE_RELATED
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, DATE_MODIFIED_UTC 
			, MODULE_NAME       
			, RELATED_NAME      
			, RELATED_ORDER     
			)
		values 	( @ID                
			, @MODIFIED_USER_ID        
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			,  getutcdate()      
			, @MODULE_NAME       
			, @RELATED_NAME      
			, @RELATED_ORDER     
			);
	end -- if;
  end
GO

Grant Execute on dbo.spMODULES_ARCHIVE_RELATED_InsertOnly to public;
GO

