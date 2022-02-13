if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spOAUTH_TOKENS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spOAUTH_TOKENS_Update;
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
-- 04/13/2012 Paul.  Facebook has a 111 character access token. 
-- 09/05/2015 Paul.  Google now uses OAuth 2.0. 
-- 01/19/2017 Paul.  The Microsoft OAuth token can be large, but less than 2000 bytes. 
-- 12/02/2020 Paul.  The Microsoft OAuth token is now about 2400, so increase to 4000 characters.
Create Procedure dbo.spOAUTH_TOKENS_Update
	( @MODIFIED_USER_ID   uniqueidentifier
	, @ASSIGNED_USER_ID   uniqueidentifier
	, @NAME               nvarchar(50)
	, @TOKEN              nvarchar(4000)
	, @SECRET             nvarchar(50)
	, @TOKEN_EXPIRES_AT   datetime = null
	, @REFRESH_TOKEN      nvarchar(4000) = null
	)
as
  begin
	set nocount on

	declare @ID uniqueidentifier;
	
	exec dbo.spOAUTH_TOKENS_Delete @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @NAME;
	
	set @ID = newid();
	insert into OAUTH_TOKENS
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
		, TOKEN_EXPIRES_AT  
		, REFRESH_TOKEN     
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
		, @TOKEN_EXPIRES_AT  
		, @REFRESH_TOKEN     
		);
  end
GO

Grant Execute on dbo.spOAUTH_TOKENS_Update to public;
GO

