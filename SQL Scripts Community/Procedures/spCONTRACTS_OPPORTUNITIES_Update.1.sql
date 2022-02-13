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
-- 11/27/2008 Paul.  This function is not supported in SplendidCRM Basic. 
-- 11/28/2008 Paul.  If the procedure already exists, then don't replace it.
-- 09/27/2009 Paul.  Keep the encryption text left-aligned so that it can be easily removed. 
if not exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCONTRACTS_OPPORTUNITIES_Update' and ROUTINE_TYPE = 'PROCEDURE') begin -- then
	exec('Create Procedure dbo.spCONTRACTS_OPPORTUNITIES_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @CONTRACT_ID       uniqueidentifier
	, @OPPORTUNITY_ID    uniqueidentifier
	)
as
  begin
	set nocount on
	
  end');
	 
	exec('Grant Execute on dbo.spCONTRACTS_OPPORTUNITIES_Update to public');
end -- if;
GO
 
