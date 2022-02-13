if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDASHLETS_USERS_InitDisable' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDASHLETS_USERS_InitDisable;
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
-- 09/24/2009 Paul.  The new Silverlight charts exceeded the control name length of 50. 
Create Procedure dbo.spDASHLETS_USERS_InitDisable
	( @MODIFIED_USER_ID uniqueidentifier
	, @ASSIGNED_USER_ID uniqueidentifier
	, @DETAIL_NAME      nvarchar(50)
	, @MODULE_NAME      nvarchar(50)
	, @CONTROL_NAME     nvarchar(100)
	)
as
  begin
	set nocount on

	declare @ID uniqueidentifier;
	exec dbo.spDASHLETS_USERS_Init @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @DETAIL_NAME;

	-- BEGIN Oracle Exception
		select @ID = ID
		  from DASHLETS_USERS
		 where ASSIGNED_USER_ID     = @ASSIGNED_USER_ID 
		   and DETAIL_NAME          = @DETAIL_NAME      
		   and MODULE_NAME          = @MODULE_NAME      
		   and CONTROL_NAME         = @CONTROL_NAME     
		   and DELETED              = 0                 ;
	-- END Oracle Exception

	exec dbo.spDASHLETS_USERS_Disable @ID, @MODIFIED_USER_ID;
  end
GO

Grant Execute on dbo.spDASHLETS_USERS_InitDisable to public;
GO

