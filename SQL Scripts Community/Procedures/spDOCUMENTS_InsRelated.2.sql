if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDOCUMENTS_InsRelated' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDOCUMENTS_InsRelated;
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
Create Procedure dbo.spDOCUMENTS_InsRelated
	( @MODIFIED_USER_ID  uniqueidentifier
	, @DOCUMENT_ID       uniqueidentifier
	, @PARENT_TYPE       nvarchar(25)
	, @PARENT_ID         uniqueidentifier
	)
as
  begin
	set nocount on
	
	if dbo.fnIsEmptyGuid(@PARENT_ID) = 0 begin -- then
		if @PARENT_TYPE = N'Accounts' begin -- then
			exec dbo.spACCOUNTS_DOCUMENTS_Update @MODIFIED_USER_ID, @PARENT_ID, @DOCUMENT_ID;
		end else if @PARENT_TYPE = N'Contacts' begin -- then
			exec dbo.spCONTACTS_DOCUMENTS_Update @MODIFIED_USER_ID, @PARENT_ID, @DOCUMENT_ID;
		end else if @PARENT_TYPE = N'Contracts' begin -- then
			exec dbo.spCONTRACTS_DOCUMENTS_Update @MODIFIED_USER_ID, @PARENT_ID, @DOCUMENT_ID;
		-- 10/09/2014 Paul.  The PARENT_ID comes before the DOCUMENT_ID for Bugs, Cases and Quotes. 
		end else if @PARENT_TYPE = N'Bugs' begin -- then
			exec dbo.spDOCUMENTS_BUGS_Update @MODIFIED_USER_ID, @PARENT_ID, @DOCUMENT_ID;
		end else if @PARENT_TYPE = N'Cases' begin -- then
			exec dbo.spDOCUMENTS_CASES_Update @MODIFIED_USER_ID, @PARENT_ID, @DOCUMENT_ID;
		end else if @PARENT_TYPE = N'Quotes' begin -- then
			exec dbo.spDOCUMENTS_QUOTES_Update @MODIFIED_USER_ID, @PARENT_ID, @DOCUMENT_ID;
		end else if @PARENT_TYPE = N'Leads' begin -- then
			exec dbo.spLEADS_DOCUMENTS_Update @MODIFIED_USER_ID, @PARENT_ID, @DOCUMENT_ID;
		end else if @PARENT_TYPE = N'Opportunities' begin -- then
			exec dbo.spOPPORTUNITIES_DOCUMENTS_Update @MODIFIED_USER_ID, @PARENT_ID, @DOCUMENT_ID;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spDOCUMENTS_InsRelated to public;
GO

