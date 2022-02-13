if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACCOUNTS_OPPORTUNITIES_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACCOUNTS_OPPORTUNITIES_Update;
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
-- 02/19/2008 Paul.  Move relationship management to spACCOUNTS_OPPORTUNITIES_Update. 
-- There should only be one active relationship, but don't update if nothing changed. 
-- 02/19/2008 Paul.  Now that we are using triggers, we need to minimize unnecessary updates.
-- 11/13/2009 Paul.  Remove the unnecessary update as it will reduce offline client conflicts. 
Create Procedure dbo.spACCOUNTS_OPPORTUNITIES_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @ACCOUNT_ID        uniqueidentifier
	, @OPPORTUNITY_ID    uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from ACCOUNTS_OPPORTUNITIES
		 where OPPORTUNITY_ID    = @OPPORTUNITY_ID
		   and ACCOUNT_ID        = @ACCOUNT_ID
		   and DELETED           = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		-- 02/19/2008 Paul.  An opportunity can only have one account, so delete if any others exist. 
		if exists(select * from ACCOUNTS_OPPORTUNITIES where DELETED = 0 and OPPORTUNITY_ID = @OPPORTUNITY_ID) begin -- then
			update ACCOUNTS_OPPORTUNITIES
			   set DELETED          = 1
			     , MODIFIED_USER_ID = @MODIFIED_USER_ID 
			     , DATE_MODIFIED    =  getdate()        
			     , DATE_MODIFIED_UTC=  getutcdate()     
			 where DELETED          = 0
			   and OPPORTUNITY_ID   = @OPPORTUNITY_ID;
		end -- if;
		set @ID = newid();
		insert into ACCOUNTS_OPPORTUNITIES
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, OPPORTUNITY_ID   
			, ACCOUNT_ID       
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @OPPORTUNITY_ID   
			, @ACCOUNT_ID       
			);
	end -- if;
  end
GO
 
Grant Execute on dbo.spACCOUNTS_OPPORTUNITIES_Update to public;
GO
 
