if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCONTACTS_USERS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCONTACTS_USERS_Update;
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
-- 11/13/2009 Paul.  Remove the unnecessary update as it will reduce offline client conflicts. 
-- 09/18/2015 Paul.  Add SERVICE_NAME to separate Exchange Folders from Contacts Sync. 
Create Procedure dbo.spCONTACTS_USERS_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @CONTACT_ID        uniqueidentifier
	, @USER_ID           uniqueidentifier
	, @SERVICE_NAME      nvarchar(25) = null
	)
as
  begin
	set nocount on
	
	-- 02/09/2006 Paul.  SugarCRM uses the CONTACTS_USERS table to allow each user to 
	-- choose the contacts they want sync'd with Outlook. 
	declare @ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from CONTACTS_USERS
		 where CONTACT_ID        = @CONTACT_ID
		   and USER_ID            = @USER_ID
		   and (SERVICE_NAME is null and @SERVICE_NAME is null or SERVICE_NAME = @SERVICE_NAME)
		   and DELETED           = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into CONTACTS_USERS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, CONTACT_ID       
			, USER_ID          
			, SERVICE_NAME     
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @CONTACT_ID       
			, @USER_ID          
			, @SERVICE_NAME     
			);
	end -- if;
  end
GO
 
Grant Execute on dbo.spCONTACTS_USERS_Update to public;
GO
 
