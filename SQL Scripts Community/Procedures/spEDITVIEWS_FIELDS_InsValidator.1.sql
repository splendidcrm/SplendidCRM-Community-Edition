if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEDITVIEWS_FIELDS_InsValidator' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEDITVIEWS_FIELDS_InsValidator;
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
-- 02/21/2017 Paul.  Allow a field to be added to the end using an index of -1. 
-- 03/19/2020 Paul.  The FIELD_INDEX is not needed, so remove from update statement. 
Create Procedure dbo.spEDITVIEWS_FIELDS_InsValidator
	( @EDIT_NAME                   nvarchar(50)
	, @FIELD_INDEX                 int
	, @FIELD_VALIDATOR_NAME        nvarchar(50)
	, @DATA_FIELD                  nvarchar(100)
	, @FIELD_VALIDATOR_MESSAGE     nvarchar(150)
	)
as
  begin
	set nocount on
	
	declare @FIELD_VALIDATOR_ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @FIELD_VALIDATOR_ID = ID
		  from FIELD_VALIDATORS
		 where NAME    = @FIELD_VALIDATOR_NAME
		   and DELETED = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@FIELD_VALIDATOR_ID) = 1 begin -- then
		raiserror(N'spEDITVIEWS_FIELDS_InsValidator: Could not find validator %s.', 16, 1, @FIELD_VALIDATOR_NAME);
	end else begin
		update EDITVIEWS_FIELDS
		   set DATE_MODIFIED               =  getdate()        
		     , DATE_MODIFIED_UTC           =  getutcdate()     
		     , FIELD_VALIDATOR_ID          = @FIELD_VALIDATOR_ID
		     , FIELD_VALIDATOR_MESSAGE     = @FIELD_VALIDATOR_MESSAGE
		 where EDIT_NAME                   = @EDIT_NAME
		   and DATA_FIELD                  = @DATA_FIELD
		   and DELETED                     = 0
		   and DEFAULT_VIEW                = 0
		   and FIELD_VALIDATOR_ID is null;
	end -- if;
  end
GO

Grant Execute on dbo.spEDITVIEWS_FIELDS_InsValidator to public;
GO

