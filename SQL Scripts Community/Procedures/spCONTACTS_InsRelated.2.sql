if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCONTACTS_InsRelated' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCONTACTS_InsRelated;
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
Create Procedure dbo.spCONTACTS_InsRelated
	( @MODIFIED_USER_ID  uniqueidentifier
	, @CONTACT_ID        uniqueidentifier
	, @PARENT_TYPE       nvarchar(25)
	, @PARENT_ID         uniqueidentifier
	)
as
  begin
	set nocount on
	
	if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
		if @PARENT_TYPE = N'Accounts' begin -- then
			exec dbo.spACCOUNTS_CONTACTS_Update       @MODIFIED_USER_ID, @PARENT_ID , @CONTACT_ID;
		end else if @PARENT_TYPE = N'Calls' begin -- then
			exec dbo.spCALLS_CONTACTS_Update          @MODIFIED_USER_ID, @PARENT_ID , @CONTACT_ID, null, null;
		end else if @PARENT_TYPE = N'Bugs' begin -- then
			exec dbo.spCONTACTS_BUGS_Update           @MODIFIED_USER_ID, @CONTACT_ID, @PARENT_ID, null;
		end else if @PARENT_TYPE = N'Cases' begin -- then
			exec dbo.spCONTACTS_CASES_Update          @MODIFIED_USER_ID, @CONTACT_ID, @PARENT_ID, null;
		end else if @PARENT_TYPE = N'Contacts' begin -- then
			exec dbo.spCONTACTS_REPORTS_TO_Update     @MODIFIED_USER_ID, @CONTACT_ID, @PARENT_ID;
		end else if @PARENT_TYPE = N'Emails' begin -- then
			exec dbo.spEMAILS_CONTACTS_Update         @MODIFIED_USER_ID, @PARENT_ID , @CONTACT_ID;
		end else if @PARENT_TYPE = N'Meetings' begin -- then
			exec dbo.spMEETINGS_CONTACTS_Update       @MODIFIED_USER_ID, @PARENT_ID , @CONTACT_ID, null, null;
		end else if @PARENT_TYPE = N'Opportunities' begin -- then
			exec dbo.spOPPORTUNITIES_CONTACTS_Update  @MODIFIED_USER_ID, @PARENT_ID , @CONTACT_ID, null;
		end else if @PARENT_TYPE = N'ProspectLists' begin -- then
			exec dbo.spPROSPECT_LISTS_CONTACTS_Update @MODIFIED_USER_ID, @PARENT_ID , @CONTACT_ID;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spCONTACTS_InsRelated to public;
GO

