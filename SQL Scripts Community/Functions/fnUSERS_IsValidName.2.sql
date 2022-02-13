if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnUSERS_IsValidName' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnUSERS_IsValidName;
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
Create Function dbo.fnUSERS_IsValidName(@ID uniqueidentifier, @USER_NAME nvarchar(20))
returns bit
as
  begin
	declare @IsValid bit;
	set @IsValid = 1;
	if exists(select USER_NAME
	            from dbo.USERS
	           where USER_NAME = @USER_NAME 
	             and USER_NAME is not null  -- 12/06/2005. Don't let an employee be treated as a duplicate. 
	             and DELETED   = 0
	             and (ID <> @ID or @ID is null)
	         ) begin -- then
		set @IsValid = 0;
	end -- if;
	return @IsValid;
  end
GO

Grant Execute on dbo.fnUSERS_IsValidName to public
GO

