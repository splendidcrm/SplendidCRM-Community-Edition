if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spFIELDS_META_DATA_DeleteByName' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spFIELDS_META_DATA_DeleteByName;
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
-- 03/29/2011 Paul.  Ease migration to Oracle. 
-- 04/18/2016 Paul.  Allow disable recompile so that we can do in the background. 
Create Procedure dbo.spFIELDS_META_DATA_DeleteByName
	( @MODIFIED_USER_ID  uniqueidentifier
	, @CUSTOM_MODULE     nvarchar(255)
	, @NAME              nvarchar(255)
	, @DISABLE_RECOMPILE bit = null
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from FIELDS_META_DATA
		 where @CUSTOM_MODULE = CUSTOM_MODULE
		   and @NAME          = NAME
		   and DELETED        = 0;
	-- END Oracle Exception

	if dbo.fnIsEmptyGuid(@ID) = 0 begin -- then
		exec dbo.spFIELDS_META_DATA_Delete @ID, @MODIFIED_USER_ID, @DISABLE_RECOMPILE;
	end -- if;
  end
GO

Grant Execute on dbo.spFIELDS_META_DATA_DeleteByName to public;
GO

