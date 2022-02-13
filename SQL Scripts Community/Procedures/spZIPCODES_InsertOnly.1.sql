if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spZIPCODES_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spZIPCODES_InsertOnly;
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
Create Procedure dbo.spZIPCODES_InsertOnly
	( @NAME               nvarchar(20)
	, @CITY               nvarchar(100)
	, @STATE              nvarchar(100)
	, @COUNTRY            nvarchar(100)
	, @LONGITUDE          decimal(10, 6)
	, @LATITUDE           decimal(10, 6)
	)
as
  begin
	set nocount on
	
	declare @ID                uniqueidentifier;
	declare @MODIFIED_USER_ID  uniqueidentifier;
	declare @TEMP_COUNTRY      nvarchar(100);
	set @TEMP_COUNTRY = @COUNTRY;
	if @TEMP_COUNTRY is null begin -- then
		set @TEMP_COUNTRY = N'US';
	end -- if;
	if not exists(select * from ZIPCODES where NAME = @NAME and DELETED = 0) begin -- then
		set @ID = newid();
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
			, @TEMP_COUNTRY      
			, @LONGITUDE         
			, @LATITUDE          
			);
	end -- if;
  end
GO

Grant Execute on dbo.spZIPCODES_InsertOnly to public;
GO

