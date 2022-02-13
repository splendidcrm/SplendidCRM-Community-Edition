if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spLEADS_DOCUMENTS_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spLEADS_DOCUMENTS_Delete;
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
Create Procedure dbo.spLEADS_DOCUMENTS_Delete
	( @MODIFIED_USER_ID uniqueidentifier
	, @LEAD_ID          uniqueidentifier
	, @DOCUMENT_ID      uniqueidentifier
	)
as
  begin
	set nocount on
	
	update LEADS_DOCUMENTS
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
	 where LEAD_ID           = @LEAD_ID
	   and DOCUMENT_ID       = @DOCUMENT_ID
	   and DELETED           = 0;
  end
GO

Grant Execute on dbo.spLEADS_DOCUMENTS_Delete to public;
GO

