if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_ARCHIVE_LOG_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_ARCHIVE_LOG_InsertOnly;
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
Create Procedure dbo.spMODULES_ARCHIVE_LOG_InsertOnly
	( @MODIFIED_USER_ID  uniqueidentifier
	, @TABLE_NAME        nvarchar(50)
	, @ARCHIVE_ACTION    nvarchar(25)
	)
as
  begin

	declare @MODULE_NAME   nvarchar(25);
	declare @ARCHIVE_TOKEN varchar(255);
	select @MODULE_NAME = MODULE_NAME
	  from MODULES
	 where TABLE_NAME = @TABLE_NAME;

	exec dbo.spSqlGetTransactionToken @ARCHIVE_TOKEN out;

	insert into MODULES_ARCHIVE_LOG
		( ID               
		, CREATED_BY       
		, DATE_ENTERED     

		, MODIFIED_USER_ID 
		, DATE_MODIFIED    
		, MODULE_NAME      
		, TABLE_NAME       
		, ARCHIVE_ACTION   
		, ARCHIVE_TOKEN    
		)
	values 
		(  newid()          
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @MODULE_NAME      
		, @TABLE_NAME       
		, @ARCHIVE_ACTION   
		, @ARCHIVE_TOKEN    
		);
  end
GO

Grant Execute on dbo.spMODULES_ARCHIVE_LOG_InsertOnly to public;
GO

