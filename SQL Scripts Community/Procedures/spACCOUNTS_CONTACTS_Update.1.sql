if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACCOUNTS_CONTACTS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACCOUNTS_CONTACTS_Update;
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
-- 02/19/2008 Paul.  Move relationship management to spACCOUNTS_CONTACTS_Update. 
-- There should only be one active relationship, but don't update if nothing changed. 
-- 08/26/2008 Paul.  When @ACCOUNT_ID is null, we will clear the existing relationship. 
-- Make sure that this procedure gets called from spCONTACTS_Update. 
-- 02/19/2008 Paul.  Now that we are using triggers, we need to minimize unnecessary updates.
-- 11/13/2009 Paul.  Remove the unnecessary update as it will reduce offline client conflicts. 
-- 02/15/2011 Paul.  Duplicate records may have been created.  Use spACCOUNTS_CONTACTS_Update to remove duplicate records. 
Create Procedure dbo.spACCOUNTS_CONTACTS_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @ACCOUNT_ID        uniqueidentifier
	, @CONTACT_ID        uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	declare @COUNT int;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from ACCOUNTS_CONTACTS
		 where CONTACT_ID        = @CONTACT_ID
		   and ACCOUNT_ID        = @ACCOUNT_ID
		   and DELETED           = 0;
	-- END Oracle Exception

	-- 02/15/2011 Paul.  If a relationship exists, check and see if there are multiple account assignments. 
	if dbo.fnIsEmptyGuid(@ID) = 0 begin -- then
		-- BEGIN Oracle Exception
			select @COUNT = count(*)
			  from ACCOUNTS_CONTACTS
			 where CONTACT_ID        = @CONTACT_ID
			   and DELETED           = 0;
		-- END Oracle Exception
		if @COUNT > 1 begin -- then
			set @ID = null;
		end -- if;
	end -- if;

	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		-- 02/19/2008 Paul.  A contact can only have one account, so delete if any others exist. 
		if exists(select * from ACCOUNTS_CONTACTS where DELETED = 0 and CONTACT_ID = @CONTACT_ID) begin -- then
			update ACCOUNTS_CONTACTS
			   set DELETED          = 1
			     , MODIFIED_USER_ID = @MODIFIED_USER_ID
			     , DATE_MODIFIED    =  getdate()       
			     , DATE_MODIFIED_UTC=  getutcdate()    
			 where DELETED          = 0
			   and CONTACT_ID       = @CONTACT_ID;
		end -- if;
		-- 08/26/2008 Paul.  Only insert account if it exists. 
		if dbo.fnIsEmptyGuid(@ACCOUNT_ID) = 0 begin -- then
			set @ID = newid();
			insert into ACCOUNTS_CONTACTS
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, CONTACT_ID       
				, ACCOUNT_ID       
				)
			values
				( @ID               
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @CONTACT_ID       
				, @ACCOUNT_ID       
				);
		end -- if;
	end -- if;
  end
GO
 
Grant Execute on dbo.spACCOUNTS_CONTACTS_Update to public;
GO
 
