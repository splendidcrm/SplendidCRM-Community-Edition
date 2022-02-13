if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPROJECTS_CASES_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPROJECTS_CASES_Delete;
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
-- 04/10/2013 Paul.  This file contained spPROJECTS_CONTACTS_Delete, so it needed to be changed to CASES. 
Create Procedure dbo.spPROJECTS_CASES_Delete
	( @MODIFIED_USER_ID uniqueidentifier
	, @PROJECT_ID       uniqueidentifier
	, @CASE_ID          uniqueidentifier
	)
as
  begin
	set nocount on
	
	update PROJECTS_CASES
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = @MODIFIED_USER_ID
	 where PROJECT_ID       = @PROJECT_ID
	   and CASE_ID          = @CASE_ID
	   and DELETED          = 0;
  end
GO

Grant Execute on dbo.spPROJECTS_CASES_Delete to public;
GO

