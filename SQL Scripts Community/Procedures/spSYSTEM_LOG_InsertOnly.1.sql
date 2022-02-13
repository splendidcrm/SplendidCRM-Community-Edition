if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSYSTEM_LOG_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSYSTEM_LOG_InsertOnly;
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
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
Create Procedure dbo.spSYSTEM_LOG_InsertOnly
	( @MODIFIED_USER_ID  uniqueidentifier
	, @USER_ID           uniqueidentifier
	, @USER_NAME         nvarchar(255)
	, @MACHINE           nvarchar(60)
	, @ASPNET_SESSIONID  nvarchar(50)
	, @REMOTE_HOST       nvarchar(100)
	, @SERVER_HOST       nvarchar(100)
	, @TARGET            nvarchar(255)
	, @RELATIVE_PATH     nvarchar(255)
	, @PARAMETERS        nvarchar(2000)
	, @ERROR_TYPE        nvarchar(25)
	, @FILE_NAME         nvarchar(255)
	, @METHOD            nvarchar(450)
	, @LINE_NUMBER       int
	, @MESSAGE           nvarchar(max)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	set @ID = newid();
	insert into SYSTEM_LOG
		( ID               
		, CREATED_BY       
		, DATE_ENTERED     
		, MODIFIED_USER_ID 
		, DATE_MODIFIED    
		, USER_ID          
		, USER_NAME        
		, MACHINE          
		, ASPNET_SESSIONID 
		, REMOTE_HOST      
		, SERVER_HOST      
		, TARGET           
		, RELATIVE_PATH    
		, PARAMETERS       
		, ERROR_TYPE       
		, FILE_NAME        
		, METHOD           
		, LINE_NUMBER      
		, MESSAGE          
		)
	values 	( @ID               
		, @MODIFIED_USER_ID       
		,  getdate()        
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @USER_ID          
		, @USER_NAME        
		, @MACHINE          
		, @ASPNET_SESSIONID 
		, @REMOTE_HOST      
		, @SERVER_HOST      
		, @TARGET           
		, @RELATIVE_PATH    
		, @PARAMETERS       
		, @ERROR_TYPE       
		, @FILE_NAME        
		, @METHOD           
		, @LINE_NUMBER      
		, @MESSAGE          
		);
  end
GO

Grant Execute on dbo.spSYSTEM_LOG_InsertOnly to public;
GO

