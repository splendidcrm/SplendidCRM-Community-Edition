if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAIL_CLIENT_SYNC_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAIL_CLIENT_SYNC_Update;
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
-- 03/28/2010 Paul.  Exchange Web Services returns dates in local time, so lets store both local time and UTC time. 
-- 03/28/2010 Paul.  REMOTE_KEY does not need to be an nvarchar.  
-- 04/01/2010 Paul.  Add the MODULE_NAME so that the LastModifiedTime can be filtered by module. 
-- 04/04/2010 Paul.  Add PARENT_ID so that the LastModifiedTime can be filtered by record. 
-- 08/31/2010 Paul.  The EMAILS_SYNC table was renamed to EMAIL_CLIENT_SYNC to prevent conflict with Offline Client sync tables. 
Create Procedure dbo.spEMAIL_CLIENT_SYNC_Update
	( @MODIFIED_USER_ID         uniqueidentifier
	, @ASSIGNED_USER_ID         uniqueidentifier
	, @LOCAL_ID                 uniqueidentifier
	, @REMOTE_KEY               varchar(800)
	, @MODULE_NAME              nvarchar(25)
	, @PARENT_ID                uniqueidentifier
	, @REMOTE_DATE_MODIFIED     datetime
	, @REMOTE_DATE_MODIFIED_UTC datetime
	)
as
  begin
	set nocount on

	declare @ID                      uniqueidentifier;
	-- 06/03/2010 Paul.  Place the larger field name first to ease Oracle conversion. 
	declare @LOCAL_DATE_MODIFIED_UTC datetime;
	declare @LOCAL_DATE_MODIFIED     datetime;

	-- BEGIN Oracle Exception
		select @LOCAL_DATE_MODIFIED     = DATE_MODIFIED
		     , @LOCAL_DATE_MODIFIED_UTC = DATE_MODIFIED_UTC
		  from vwEMAILS
		 where ID = @LOCAL_ID;
	-- END Oracle Exception
	-- BEGIN Oracle Exception
		select @ID = ID
		  from EMAIL_CLIENT_SYNC
		 where ASSIGNED_USER_ID = @ASSIGNED_USER_ID 
		   and REMOTE_KEY       = @REMOTE_KEY 
		   and LOCAL_ID         = @LOCAL_ID 
		   and DELETED          = 0;
	-- END Oracle Exception
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into EMAIL_CLIENT_SYNC
			( ID                      
			, CREATED_BY              
			, DATE_ENTERED            
			, MODIFIED_USER_ID        
			, DATE_MODIFIED           
			, DATE_MODIFIED_UTC       
			, ASSIGNED_USER_ID        
			, LOCAL_ID                
			, REMOTE_KEY              
			, MODULE_NAME             
			, PARENT_ID               
			, LOCAL_DATE_MODIFIED     
			, REMOTE_DATE_MODIFIED    
			, LOCAL_DATE_MODIFIED_UTC 
			, REMOTE_DATE_MODIFIED_UTC
			)
		values
			( @ID                      
			, @MODIFIED_USER_ID        
			,  getdate()               
			, @MODIFIED_USER_ID        
			,  getdate()               
			,  getutcdate()            
			, @ASSIGNED_USER_ID        
			, @LOCAL_ID                
			, @REMOTE_KEY              
			, @MODULE_NAME             
			, @PARENT_ID               
			, @LOCAL_DATE_MODIFIED     
			, @REMOTE_DATE_MODIFIED    
			, @LOCAL_DATE_MODIFIED_UTC 
			, @REMOTE_DATE_MODIFIED_UTC
			);
	end else begin
		update EMAIL_CLIENT_SYNC
		   set MODIFIED_USER_ID         = @MODIFIED_USER_ID        
		     , DATE_MODIFIED            =  getdate()               
		     , DATE_MODIFIED_UTC        =  getutcdate()            
		     , LOCAL_DATE_MODIFIED      = @LOCAL_DATE_MODIFIED     
		     , REMOTE_DATE_MODIFIED     = @REMOTE_DATE_MODIFIED    
		     , LOCAL_DATE_MODIFIED_UTC  = @LOCAL_DATE_MODIFIED_UTC 
		     , REMOTE_DATE_MODIFIED_UTC = @REMOTE_DATE_MODIFIED_UTC
		 where ID                       = @ID                      ;
	end -- if;
  end
GO

Grant Execute on dbo.spEMAIL_CLIENT_SYNC_Update to public;
GO


