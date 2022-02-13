if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_LAST_IMPORT_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_LAST_IMPORT_Update;
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
Create Procedure dbo.spUSERS_LAST_IMPORT_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @BEAN_TYPE         nvarchar(25)
	, @BEAN_ID           uniqueidentifier
	)
as
  begin
	set nocount on
	
	if not exists(select * from USERS_LAST_IMPORT where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into USERS_LAST_IMPORT
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, ASSIGNED_USER_ID 
			, BEAN_TYPE        
			, BEAN_ID          
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @ASSIGNED_USER_ID 
			, @BEAN_TYPE        
			, @BEAN_ID          
			);
	end else begin
		update USERS_LAST_IMPORT
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , ASSIGNED_USER_ID  = @ASSIGNED_USER_ID 
		     , BEAN_TYPE         = @BEAN_TYPE        
		     , BEAN_ID           = @BEAN_ID          
		 where ID                = @ID               ;
	end -- if;
  end
GO

Grant Execute on dbo.spUSERS_LAST_IMPORT_Update to public;
GO

