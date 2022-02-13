if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSYSTEM_CURRENCY_LOG_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSYSTEM_CURRENCY_LOG_InsertOnly;
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
Create Procedure dbo.spSYSTEM_CURRENCY_LOG_InsertOnly
	( @ID                   uniqueidentifier output
	, @MODIFIED_USER_ID     uniqueidentifier
	, @SERVICE_NAME         nvarchar(50)
	, @SOURCE_ISO4217       nvarchar(3)
	, @DESTINATION_ISO4217  nvarchar(3)
	, @CONVERSION_RATE      float(53)
	, @RAW_CONTENT          nvarchar(max)
	)
as
  begin
	set nocount on
	
	set @ID = newid();
	insert into SYSTEM_CURRENCY_LOG
		( ID                  
		, CREATED_BY          
		, DATE_ENTERED        
		, MODIFIED_USER_ID    
		, DATE_MODIFIED       
		, DATE_MODIFIED_UTC   
		, SERVICE_NAME        
		, SOURCE_ISO4217      
		, DESTINATION_ISO4217 
		, CONVERSION_RATE     
		, RAW_CONTENT         
		)
	values 	( @ID                  
		, @MODIFIED_USER_ID    
		,  getdate()           
		, @MODIFIED_USER_ID    
		,  getdate()           
		,  getutcdate()        
		, @SERVICE_NAME        
		, @SOURCE_ISO4217      
		, @DESTINATION_ISO4217 
		, @CONVERSION_RATE     
		, @RAW_CONTENT         
		);
  end
GO

Grant Execute on dbo.spSYSTEM_CURRENCY_LOG_InsertOnly to public;
GO

