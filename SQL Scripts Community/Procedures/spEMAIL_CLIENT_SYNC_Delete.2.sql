if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAIL_CLIENT_SYNC_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAIL_CLIENT_SYNC_Delete;
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
-- 04/01/2010 Paul.  Add the MODULE_NAME so that the LastModifiedTime can be filtered by module. 
-- 08/31/2010 Paul.  The EMAILS_SYNC table was renamed to EMAIL_CLIENT_SYNC to prevent conflict with Offline Client sync tables. 
Create Procedure dbo.spEMAIL_CLIENT_SYNC_Delete
	( @MODIFIED_USER_ID         uniqueidentifier
	, @ASSIGNED_USER_ID         uniqueidentifier
	, @LOCAL_ID                 uniqueidentifier
	, @REMOTE_KEY               varchar(800)
	, @MODULE_NAME              nvarchar(25)
	)
as
  begin
	set nocount on

	update EMAIL_CLIENT_SYNC
	   set DELETED           = 1
	     , DATE_MODIFIED     =  getdate()               
	     , DATE_MODIFIED_UTC =  getutcdate()            
	     , MODIFIED_USER_ID  = @MODIFIED_USER_ID        
	 where ASSIGNED_USER_ID  = @ASSIGNED_USER_ID 
	   and REMOTE_KEY        = @REMOTE_KEY 
	   and LOCAL_ID          = @LOCAL_ID 
	   and DELETED           = 0;
  end
GO

Grant Execute on dbo.spEMAIL_CLIENT_SYNC_Delete to public;
GO


