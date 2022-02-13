if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spOAUTHKEYS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spOAUTHKEYS_Update;
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
-- 04/09/2012 Paul.  Twitter has a 40 character verifier. 
-- 04/13/2012 Paul.  Facebook has a 111 character access token. 
Create Procedure dbo.spOAUTHKEYS_Update
	( @MODIFIED_USER_ID   uniqueidentifier
	, @ASSIGNED_USER_ID   uniqueidentifier
	, @NAME               nvarchar(25)
	, @TOKEN              nvarchar(200)
	, @SECRET             nvarchar(50)
	, @VERIFIER           nvarchar(50)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	
	exec dbo.spOAUTHKEYS_Delete @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @NAME;
	
	set @ID = newid();
	insert into OAUTHKEYS
		( ID                
		, CREATED_BY        
		, DATE_ENTERED      
		, MODIFIED_USER_ID  
		, DATE_MODIFIED     
		, DATE_MODIFIED_UTC 
		, ASSIGNED_USER_ID  
		, NAME              
		, TOKEN             
		, SECRET            
		, VERIFIER          
		)
	values 	( @ID                
		, @MODIFIED_USER_ID        
		,  getdate()         
		, @MODIFIED_USER_ID  
		,  getdate()         
		,  getutcdate()      
		, @ASSIGNED_USER_ID  
		, @NAME              
		, @TOKEN             
		, @SECRET            
		, @VERIFIER          
		);
  end
GO

Grant Execute on dbo.spOAUTHKEYS_Update to public;
GO

