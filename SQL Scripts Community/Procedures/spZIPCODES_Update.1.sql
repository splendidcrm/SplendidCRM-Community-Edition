if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spZIPCODES_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spZIPCODES_Update;
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
Create Procedure dbo.spZIPCODES_Update
	( @ID                 uniqueidentifier output
	, @MODIFIED_USER_ID   uniqueidentifier
	, @NAME               nvarchar(20)
	, @CITY               nvarchar(100)
	, @STATE              nvarchar(100)
	, @COUNTRY            nvarchar(100)
	, @LONGITUDE          decimal(10, 6)
	, @LATITUDE           decimal(10, 6)
	, @TIMEZONE_ID        uniqueidentifier
	)
as
  begin
	set nocount on
	
	if not exists(select * from ZIPCODES where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into ZIPCODES
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, DATE_MODIFIED_UTC 
			, NAME              
			, CITY              
			, STATE             
			, COUNTRY           
			, LONGITUDE         
			, LATITUDE          
			, TIMEZONE_ID       
			)
		values 	( @ID                
			, @MODIFIED_USER_ID        
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			,  getutcdate()      
			, @NAME              
			, @CITY              
			, @STATE             
			, @COUNTRY           
			, @LONGITUDE         
			, @LATITUDE          
			, @TIMEZONE_ID       
			);
	end else begin
		update ZIPCODES
		   set MODIFIED_USER_ID   = @MODIFIED_USER_ID  
		     , DATE_MODIFIED      =  getdate()         
		     , DATE_MODIFIED_UTC  =  getutcdate()      
		     , NAME               = @NAME              
		     , CITY               = @CITY              
		     , STATE              = @STATE             
		     , COUNTRY            = @COUNTRY           
		     , LONGITUDE          = @LONGITUDE         
		     , LATITUDE           = @LATITUDE          
		     , TIMEZONE_ID        = @TIMEZONE_ID       
		 where ID                 = @ID                ;
	end -- if;
  end
GO

Grant Execute on dbo.spZIPCODES_Update to public;
GO

