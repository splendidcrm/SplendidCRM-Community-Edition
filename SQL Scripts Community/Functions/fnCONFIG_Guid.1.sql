if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnCONFIG_Guid' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnCONFIG_Guid;
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
-- 04/23/2017 Paul.  Deleted flag was not being checked. 
Create Function dbo.fnCONFIG_Guid(@NAME nvarchar(60))
returns uniqueidentifier
as
  begin
	declare @VALUE_varchar nvarchar(255);
	declare @VALUE_guid    uniqueidentifier;
	select top 1 @VALUE_varchar = convert(nvarchar(255), VALUE)
	  from CONFIG
	 where NAME = @NAME
	   and DELETED = 0;
	set @VALUE_guid = convert(uniqueidentifier, @VALUE_varchar);
	return @VALUE_guid;
  end
GO

Grant Execute on dbo.fnCONFIG_Guid to public
GO

