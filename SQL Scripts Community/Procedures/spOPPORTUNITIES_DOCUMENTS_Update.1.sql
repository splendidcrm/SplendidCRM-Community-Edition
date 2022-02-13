if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spOPPORTUNITIES_DOCUMENTS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spOPPORTUNITIES_DOCUMENTS_Update;
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
Create Procedure dbo.spOPPORTUNITIES_DOCUMENTS_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @OPPORTUNITY_ID    uniqueidentifier
	, @DOCUMENT_ID       uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ID                   uniqueidentifier;
	declare @DOCUMENT_REVISION_ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from OPPORTUNITIES_DOCUMENTS
		 where OPPORTUNITY_ID = @OPPORTUNITY_ID
		   and DOCUMENT_ID    = @DOCUMENT_ID
		   and DELETED     = 0;
	-- END Oracle Exception
	-- BEGIN Oracle Exception
		select @DOCUMENT_REVISION_ID = DOCUMENT_REVISION_ID
		  from DOCUMENTS
		 where ID      = @DOCUMENT_ID
		   and DELETED = 0;
	-- END Oracle Exception

	
	if @ID is null begin -- then
		set @ID = newid();
		insert into OPPORTUNITIES_DOCUMENTS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, OPPORTUNITY_ID   
			, DOCUMENT_ID      
			, DOCUMENT_REVISION_ID
			)
		values 	( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @OPPORTUNITY_ID   
			, @DOCUMENT_ID      
			, @DOCUMENT_REVISION_ID
			);
	end -- if;
  end
GO
 
Grant Execute on dbo.spOPPORTUNITIES_DOCUMENTS_Update to public;
GO
 
