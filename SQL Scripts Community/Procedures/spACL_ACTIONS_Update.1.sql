if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACL_ACTIONS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACL_ACTIONS_Update;
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
Create Procedure dbo.spACL_ACTIONS_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(150)
	, @CATEGORY          nvarchar(100)
	, @ACLTYPE           nvarchar(100)
	, @ACLACCESS         int
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		select @ID = ID
		  from ACL_ACTIONS
		 where NAME      = @NAME    
		   and CATEGORY  = @CATEGORY
		   and DELETED   = 0        ;
	-- END Oracle Exception

	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into ACL_ACTIONS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, NAME             
			, CATEGORY         
			, ACLTYPE          
			, ACLACCESS        
			)
		values 	( @ID               
			, @MODIFIED_USER_ID       
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @NAME             
			, @CATEGORY         
			, @ACLTYPE          
			, @ACLACCESS        
			);
	end else begin
		update ACL_ACTIONS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , ACLTYPE           = @ACLTYPE          
		     , ACLACCESS         = @ACLACCESS        
		 where ID                = @ID               ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spACL_ACTIONS_Update to public;
GO
 
