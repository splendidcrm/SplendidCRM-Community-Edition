if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_LOGINS_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_LOGINS_InsertOnly;
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
-- 08/27/2008 Paul.  PostgreSQL does not allow modifying input parameters.  Use a local temp variable. 
Create Procedure dbo.spUSERS_LOGINS_InsertOnly
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @USER_ID           uniqueidentifier
	, @USER_NAME         nvarchar(60)
	, @LOGIN_TYPE        nvarchar(25)
	, @LOGIN_STATUS      nvarchar(25)
	, @ASPNET_SESSIONID  nvarchar(50)
	, @REMOTE_HOST       nvarchar(100)
	, @SERVER_HOST       nvarchar(100)
	, @TARGET            nvarchar(255)
	, @RELATIVE_PATH     nvarchar(255)
	, @USER_AGENT        nvarchar(255)
	)
as
  begin
	set nocount on
	
	declare @TEMP_USER_ID uniqueidentifier;
	set @TEMP_USER_ID = @USER_ID;
	-- 03/02/2008 Paul.  Even though the login has failed, 
	-- try and find the user that attempted the login. 
	if dbo.fnIsEmptyGuid(@TEMP_USER_ID) = 1 begin -- then
		-- BEGIN Oracle Exception
			select @TEMP_USER_ID = ID
			  from vwUSERS_Login
			 where lower(USER_NAME) = lower(@USER_NAME);
		-- END Oracle Exception
	end -- if;

	set @ID = newid();
	insert into USERS_LOGINS
		( ID               
		, CREATED_BY       
		, DATE_ENTERED     
		, MODIFIED_USER_ID 
		, DATE_MODIFIED    
		, USER_ID          
		, USER_NAME        
		, LOGIN_TYPE       
		, LOGIN_DATE       
		, LOGIN_STATUS     
		, ASPNET_SESSIONID 
		, REMOTE_HOST      
		, SERVER_HOST      
		, TARGET           
		, RELATIVE_PATH    
		, USER_AGENT       
		)
	values 	( @ID               
		, @MODIFIED_USER_ID       
		,  getdate()        
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @TEMP_USER_ID     
		, @USER_NAME        
		, @LOGIN_TYPE       
		,  getdate()        
		, @LOGIN_STATUS     
		, @ASPNET_SESSIONID 
		, @REMOTE_HOST      
		, @SERVER_HOST      
		, @TARGET           
		, @RELATIVE_PATH    
		, @USER_AGENT       
		);
  end
GO

Grant Execute on dbo.spUSERS_LOGINS_InsertOnly to public;
GO

