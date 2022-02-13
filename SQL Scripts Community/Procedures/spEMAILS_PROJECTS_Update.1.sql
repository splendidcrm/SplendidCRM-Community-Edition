if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_PROJECTS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILS_PROJECTS_Update;
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
Create Procedure dbo.spEMAILS_PROJECTS_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @EMAIL_ID          uniqueidentifier
	, @PROJECT_ID        uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from EMAILS_PROJECTS
		 where EMAIL_ID          = @EMAIL_ID
		   and PROJECT_ID        = @PROJECT_ID
		   and DELETED           = 0;
	-- END Oracle Exception
	
	if not exists(select * from EMAILS_PROJECTS where ID = @ID) begin -- then
		set @ID = newid();
		insert into EMAILS_PROJECTS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, EMAIL_ID         
			, PROJECT_ID       
			)
		values 	( @ID               
			, @MODIFIED_USER_ID       
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @EMAIL_ID         
			, @PROJECT_ID       
			);
	end -- if;
  end
GO
 
Grant Execute on dbo.spEMAILS_PROJECTS_Update to public;
GO

