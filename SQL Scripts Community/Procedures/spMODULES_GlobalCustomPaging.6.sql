if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_GlobalCustomPaging' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_GlobalCustomPaging;
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
Create Procedure dbo.spMODULES_GlobalCustomPaging
	( @MODIFIED_USER_ID  uniqueidentifier
	)
as
  begin
	set nocount on
	
	exec dbo.spCONFIG_Update @MODIFIED_USER_ID, 'system', 'allow_custom_paging', 'true';

	-- 09/28/2009 Paul.  All modules will get enabled. 
	update MODULES
	   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
	     , DATE_MODIFIED     =  getdate()        
	     , DATE_MODIFIED_UTC =  getutcdate()     
	     , CUSTOM_PAGING     = 1
	 where DELETED           = 0;
  end
GO
 
-- exec dbo.spMODULES_GlobalCustomPaging null;

Grant Execute on dbo.spMODULES_GlobalCustomPaging to public;
GO
 
