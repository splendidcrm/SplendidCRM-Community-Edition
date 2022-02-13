if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnCONFIG_String' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnCONFIG_String;
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
-- 10/22/2017 Paul.  Increase sized of result. 
Create Function dbo.fnCONFIG_String(@NAME nvarchar(60))
returns nvarchar(4000)
as
  begin
	declare @VALUE_varchar nvarchar(4000);
	select top 1 @VALUE_varchar = convert(nvarchar(4000), VALUE)
	  from CONFIG
	 where NAME = @NAME
	   and DELETED = 0;
	return @VALUE_varchar;
  end
GO

Grant Execute on dbo.fnCONFIG_String to public
GO

