if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSYSTEM_SYNC_LOG_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSYSTEM_SYNC_LOG_InsertOnly;
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
Create Procedure dbo.spSYSTEM_SYNC_LOG_InsertOnly
	( @MODIFIED_USER_ID  uniqueidentifier
	, @USER_ID           uniqueidentifier
	, @MACHINE           nvarchar(60)
	, @REMOTE_URL        nvarchar(255)
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
	insert into SYSTEM_SYNC_LOG
		( ID               
		, CREATED_BY       
		, DATE_ENTERED     
		, MODIFIED_USER_ID 
		, DATE_MODIFIED    
		, DATE_MODIFIED_UTC
		, USER_ID          
		, MACHINE          
		, REMOTE_URL       
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
		,  getutcdate()     
		, @USER_ID          
		, @MACHINE          
		, @REMOTE_URL       
		, @ERROR_TYPE       
		, @FILE_NAME        
		, @METHOD           
		, @LINE_NUMBER      
		, @MESSAGE          
		);
  end
GO

Grant Execute on dbo.spSYSTEM_SYNC_LOG_InsertOnly to public;
GO

