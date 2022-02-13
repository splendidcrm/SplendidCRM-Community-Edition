if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSUGARFAVORITES_UpdateName' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSUGARFAVORITES_UpdateName;
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
Create Procedure dbo.spSUGARFAVORITES_UpdateName
	( @MODIFIED_USER_ID   uniqueidentifier
	, @RECORD_ID          uniqueidentifier
	, @NAME               nvarchar(255)
	)
as
  begin
	set nocount on
	
	-- BEGIN Oracle Exception
		update SUGARFAVORITES
		   set NAME              = @NAME
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where RECORD_ID         = @RECORD_ID
		   and DELETED           = 0
		   and (@NAME < NAME or @NAME > NAME);
	-- END Oracle Exception
  end
GO

Grant Execute on dbo.spSUGARFAVORITES_UpdateName to public;
GO

