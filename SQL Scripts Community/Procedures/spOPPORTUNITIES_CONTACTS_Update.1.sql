if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spOPPORTUNITIES_CONTACTS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spOPPORTUNITIES_CONTACTS_Update;
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
Create Procedure dbo.spOPPORTUNITIES_CONTACTS_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @OPPORTUNITY_ID    uniqueidentifier
	, @CONTACT_ID        uniqueidentifier
	, @CONTACT_ROLE      nvarchar(50)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from OPPORTUNITIES_CONTACTS
		 where CONTACT_ID        = @CONTACT_ID
		   and OPPORTUNITY_ID    = @OPPORTUNITY_ID
		   and DELETED           = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into OPPORTUNITIES_CONTACTS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, CONTACT_ID       
			, OPPORTUNITY_ID   
			, CONTACT_ROLE     
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @CONTACT_ID       
			, @OPPORTUNITY_ID   
			, @CONTACT_ROLE     
			);
	end else begin
		update OPPORTUNITIES_CONTACTS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , CONTACT_ROLE      = @CONTACT_ROLE     
		 where ID                = @ID               ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spOPPORTUNITIES_CONTACTS_Update to public;
GO
 
