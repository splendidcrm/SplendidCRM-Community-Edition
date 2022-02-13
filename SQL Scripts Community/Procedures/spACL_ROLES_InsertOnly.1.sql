if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACL_ROLES_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACL_ROLES_InsertOnly;
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
Create Procedure dbo.spACL_ROLES_InsertOnly
	( @ID                uniqueidentifier
	, @NAME              nvarchar(150)
	, @DESCRIPTION       nvarchar(max)
	)
as
  begin
	set nocount on
	
	if not exists(select * from ACL_ROLES where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into ACL_ROLES
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, NAME             
			, DESCRIPTION      
			)
		values 	( @ID               
			, null               
			,  getdate()        
			, null               
			,  getdate()        
			, @NAME             
			, @DESCRIPTION      
			);
	end -- if;

	if not exists(select * from ACL_ROLES_CSTM where ID_C = @ID) begin -- then
		insert into ACL_ROLES_CSTM ( ID_C ) values ( @ID );
	end -- if;

  end
GO
 
Grant Execute on dbo.spACL_ROLES_InsertOnly to public;
GO
 
