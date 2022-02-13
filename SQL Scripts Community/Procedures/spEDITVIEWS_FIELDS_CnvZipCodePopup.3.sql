if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEDITVIEWS_FIELDS_CnvZipCodePopup' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup;
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
Create Procedure dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup
	( @EDIT_NAME         nvarchar( 50)
	, @DATA_FIELD        nvarchar(100)
	)
as
  begin
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = @EDIT_NAME and DATA_FIELD = @DATA_FIELD and FIELD_TYPE = N'TextBox' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set FIELD_TYPE        = N'ZipCodePopup'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = @EDIT_NAME
		   and DATA_FIELD        = @DATA_FIELD
		   and FIELD_TYPE        = N'TextBox'
		   and DELETED           = 0;
	end -- if;
  end
GO

Grant Execute on dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup to public;
GO

