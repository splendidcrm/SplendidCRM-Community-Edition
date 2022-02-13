if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnTERMINOLOGY_Changed' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnTERMINOLOGY_Changed;
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
-- 07/24/2006 Paul.  Increase the MODULE_NAME to 25 to match the size in the MODULES table.
-- 01/14/2010 Paul.  In order to detect a case-significant change in the DISPLAY_NAME, first convert to binary. 
-- http://vyaskn.tripod.com/case_sensitive_search_in_sql_server.htm
-- 03/06/2012 Paul.  Increase size of the NAME field so that it can include a date formula. 
Create Function dbo.fnTERMINOLOGY_Changed
	( @NAME              nvarchar(150)
	, @LANG              nvarchar(10)
	, @MODULE_NAME       nvarchar(25)
	, @LIST_NAME         nvarchar(50)
	, @LIST_ORDER        int
	, @DISPLAY_NAME      nvarchar(max)
	)
returns bit
as
  begin
	declare @Changed bit;
	set @Changed = 0;
	if not exists(select *
	                from TERMINOLOGY
	               where DELETED = 0
	                 and (NAME         = @NAME         or (NAME         is null and @NAME         is null))
	                 and (LANG         = @LANG         or (LANG         is null and @LANG         is null))
	                 and (MODULE_NAME  = @MODULE_NAME  or (MODULE_NAME  is null and @MODULE_NAME  is null))
	                 and (LIST_NAME    = @LIST_NAME    or (LIST_NAME    is null and @LIST_NAME    is null))
	                 and (cast(DISPLAY_NAME as varbinary(4000)) = cast(@DISPLAY_NAME as varbinary(4000)) or (DISPLAY_NAME is null and @DISPLAY_NAME is null))
	                 and isnull(LIST_ORDER, 0) = isnull(@LIST_ORDER, 0)) begin -- then
		set @Changed = 1;
	end -- if;
	return @Changed;
  end
GO

Grant Execute on dbo.fnTERMINOLOGY_Changed to public
GO

