if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_RELATED_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILS_RELATED_Update;
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
Create Procedure dbo.spEMAILS_RELATED_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @EMAIL_ID          uniqueidentifier
	, @PARENT_TYPE       nvarchar(25)
	, @PARENT_ID         uniqueidentifier
	)
as
  begin
	set nocount on
	
	if @PARENT_ID is not null begin -- then
		if          @PARENT_TYPE = N'Accounts' begin -- then
			exec dbo.spEMAILS_ACCOUNTS_Update      @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Bugs' begin -- then
			exec dbo.spEMAILS_BUGS_Update          @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Cases' begin -- then
			exec dbo.spEMAILS_CASES_Update         @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Contacts' begin -- then
			exec dbo.spEMAILS_CONTACTS_Update      @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Leads' begin -- then
			exec dbo.spEMAILS_LEADS_Update         @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Opportunities' begin -- then
			exec dbo.spEMAILS_OPPORTUNITIES_Update @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Project' begin -- then
			exec dbo.spEMAILS_PROJECTS_Update      @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'ProjectTask' begin -- then
			exec dbo.spEMAILS_PROJECT_TASKS_Update @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Prospects' begin -- then
			exec dbo.spEMAILS_PROSPECTS_Update     @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Quotes' begin -- then
			exec dbo.spEMAILS_QUOTES_Update        @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Tasks' begin -- then
			exec dbo.spEMAILS_TASKS_Update         @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Users' begin -- then
			exec dbo.spEMAILS_USERS_Update         @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		-- 02/13/2009 Paul.  Add relationship to Contracts. 
		end else if @PARENT_TYPE = N'Contracts' begin -- then
			exec dbo.spEMAILS_CONTRACTS_Update     @MODIFIED_USER_ID, @EMAIL_ID, @PARENT_ID;
		end -- if;
	end -- if;
  end
GO
 
Grant Execute on dbo.spEMAILS_RELATED_Update to public;
GO
 
