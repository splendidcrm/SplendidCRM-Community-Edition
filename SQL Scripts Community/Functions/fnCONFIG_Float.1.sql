if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnCONFIG_Float' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnCONFIG_Float;
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
Create Function dbo.fnCONFIG_Float(@NAME nvarchar(32))
returns float
as
  begin
	declare @VALUE_varchar nvarchar(10);
	declare @VALUE_float     float;
	select top 1 @VALUE_varchar = convert(nvarchar(10), VALUE)
	  from CONFIG
	 where NAME = @NAME
	   and DELETED = 0;
	-- 11/18/2006 Paul.  We cannot convert ntext to int, but we can go from nvarchar to int. 
	set @VALUE_float = convert(float, @VALUE_varchar);
	return @VALUE_float;
  end
GO

Grant Execute on dbo.fnCONFIG_Float to public
GO

