if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnCONFIG_Boolean' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnCONFIG_Boolean;
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
Create Function dbo.fnCONFIG_Boolean(@NAME nvarchar(32))
returns bit
as
  begin
	declare @VALUE bit;
	select top 1 @VALUE = (case lower(convert(nvarchar(20), VALUE)) when '1' then 1 when 'true' then 1 else 0 end)
	  from CONFIG
	 where NAME = @NAME
	   and DELETED = 0;
	if @VALUE is null begin -- then
		set @VALUE = 0;
	end -- if;
	return @VALUE;
  end
GO

Grant Execute on dbo.fnCONFIG_Boolean to public
GO

