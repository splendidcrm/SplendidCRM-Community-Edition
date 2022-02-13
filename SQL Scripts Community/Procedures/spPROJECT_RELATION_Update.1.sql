if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPROJECT_RELATION_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPROJECT_RELATION_Update;
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
-- 09/08/2012 Paul.  Project Relations data for Accounts, Bugs, Cases, Contacts, Opportunities and Quotes moved to separate tables. 
Create Procedure dbo.spPROJECT_RELATION_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @PROJECT_ID        uniqueidentifier
	, @RELATION_TYPE     nvarchar(25)
	, @RELATION_ID       uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- 11/13/2005 Paul.  Project tasks store their relationship in the PARENT_ID field. 
	if @RELATION_TYPE = N'ProjectTask' begin -- then
		update PROJECT_TASK
		   set PARENT_ID         = @ID               
		     , MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		 where ID                = @RELATION_ID
		   and DELETED           = 0;
	end else if @RELATION_TYPE = N'Accounts' begin -- then
		-- BEGIN Oracle Exception
			select @ID = ID
			  from PROJECTS_ACCOUNTS
			 where PROJECT_ID        = @PROJECT_ID
			   and ACCOUNT_ID        = @RELATION_ID
			   and DELETED           = 0;
		-- END Oracle Exception
		
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
			insert into PROJECTS_ACCOUNTS
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, PROJECT_ID       
				, ACCOUNT_ID       
				)
			values
				( @ID               
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @PROJECT_ID       
				, @RELATION_ID      
				);
		end -- if;
	end else if @RELATION_TYPE = N'Bugs' begin -- then
		-- BEGIN Oracle Exception
			select @ID = ID
			  from PROJECTS_BUGS
			 where PROJECT_ID        = @PROJECT_ID
			   and BUG_ID            = @RELATION_ID
			   and DELETED           = 0;
		-- END Oracle Exception
		
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
			insert into PROJECTS_BUGS
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, PROJECT_ID       
				, BUG_ID           
				)
			values
				( @ID               
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @PROJECT_ID       
				, @RELATION_ID      
				);
		end -- if;
	end else if @RELATION_TYPE = N'Cases' begin -- then
		-- BEGIN Oracle Exception
			select @ID = ID
			  from PROJECTS_CASES
			 where PROJECT_ID        = @PROJECT_ID
			   and CASE_ID           = @RELATION_ID
			   and DELETED           = 0;
		-- END Oracle Exception
		
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
			insert into PROJECTS_CASES
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, PROJECT_ID       
				, CASE_ID          
				)
			values
				( @ID               
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @PROJECT_ID       
				, @RELATION_ID      
				);
		end -- if;
	end else if @RELATION_TYPE = N'Contacts' begin -- then
		-- BEGIN Oracle Exception
			select @ID = ID
			  from PROJECTS_CONTACTS
			 where PROJECT_ID        = @PROJECT_ID
			   and CONTACT_ID        = @RELATION_ID
			   and DELETED           = 0;
		-- END Oracle Exception
		
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
			insert into PROJECTS_CONTACTS
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, PROJECT_ID       
				, CONTACT_ID       
				)
			values
				( @ID               
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @PROJECT_ID       
				, @RELATION_ID      
				);
		end -- if;
	end else if @RELATION_TYPE = N'Opportunities' begin -- then
		-- BEGIN Oracle Exception
			select @ID = ID
			  from PROJECTS_OPPORTUNITIES
			 where PROJECT_ID        = @PROJECT_ID
			   and OPPORTUNITY_ID    = @RELATION_ID
			   and DELETED           = 0;
		-- END Oracle Exception
		
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
			insert into PROJECTS_OPPORTUNITIES
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, PROJECT_ID       
				, OPPORTUNITY_ID   
				)
			values
				( @ID               
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @PROJECT_ID       
				, @RELATION_ID      
				);
		end -- if;
	end else if @RELATION_TYPE = N'Quotes' begin -- then
		-- BEGIN Oracle Exception
			select @ID = ID
			  from PROJECTS_QUOTES
			 where PROJECT_ID        = @PROJECT_ID
			   and QUOTE_ID          = @RELATION_ID
			   and DELETED           = 0;
		-- END Oracle Exception
		
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
			insert into PROJECTS_QUOTES
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, PROJECT_ID       
				, QUOTE_ID         
				)
			values
				( @ID               
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @PROJECT_ID       
				, @RELATION_ID      
				);
		end -- if;
	end else begin
		-- BEGIN Oracle Exception
			select @ID = ID
			  from PROJECT_RELATION
			 where PROJECT_ID        = @PROJECT_ID
			   and RELATION_ID       = @RELATION_ID
			   and DELETED           = 0;
		-- END Oracle Exception
		
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
			insert into PROJECT_RELATION
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, PROJECT_ID       
				, RELATION_TYPE    
				, RELATION_ID      
				)
			values
				( @ID               
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @PROJECT_ID       
				, @RELATION_TYPE    
				, @RELATION_ID      
				);
		end -- if;
	end -- if;
  end
GO
 
Grant Execute on dbo.spPROJECT_RELATION_Update to public;
GO
 
