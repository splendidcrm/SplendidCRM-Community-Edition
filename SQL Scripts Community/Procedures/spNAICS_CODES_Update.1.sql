if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spNAICS_CODES_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spNAICS_CODES_Update;
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
Create Procedure dbo.spNAICS_CODES_Update
	( @ID                 uniqueidentifier output
	, @MODIFIED_USER_ID   uniqueidentifier
	, @NAME               nvarchar(10)
	, @DESCRIPTION        nvarchar(400)
	)
as
  begin
	set nocount on
	
	if not exists(select * from NAICS_CODES where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into NAICS_CODES
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, DATE_MODIFIED_UTC 
			, NAME              
			, DESCRIPTION       
			)
		values 	( @ID                
			, @MODIFIED_USER_ID        
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			,  getutcdate()      
			, @NAME              
			, @DESCRIPTION       
			);
	end else begin
		update NAICS_CODES
		   set MODIFIED_USER_ID   = @MODIFIED_USER_ID  
		     , DATE_MODIFIED      =  getdate()         
		     , DATE_MODIFIED_UTC  =  getutcdate()      
		     , NAME               = @NAME              
		     , DESCRIPTION        = @DESCRIPTION       
		 where ID                 = @ID                ;
	end -- if;
  end
GO

Grant Execute on dbo.spNAICS_CODES_Update to public;
GO

