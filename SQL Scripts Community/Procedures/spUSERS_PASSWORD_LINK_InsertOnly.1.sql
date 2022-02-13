if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_PASSWORD_LINK_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_PASSWORD_LINK_InsertOnly;
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
Create Procedure dbo.spUSERS_PASSWORD_LINK_InsertOnly
	( @ID                 uniqueidentifier output
	, @MODIFIED_USER_ID   uniqueidentifier
	, @USER_NAME          nvarchar(60)
	)
as
  begin
	set nocount on
	
	set @ID = newid();
	insert into USERS_PASSWORD_LINK
		( ID                
		, CREATED_BY        
		, DATE_ENTERED      
		, MODIFIED_USER_ID  
		, DATE_MODIFIED     
		, DATE_MODIFIED_UTC 
		, USER_NAME         
		)
	values 	( @ID                
		, @MODIFIED_USER_ID        
		,  getdate()         
		, @MODIFIED_USER_ID  
		,  getdate()         
		,  getutcdate()      
		, @USER_NAME         
		);
  end
GO

Grant Execute on dbo.spUSERS_PASSWORD_LINK_InsertOnly to public;
GO

