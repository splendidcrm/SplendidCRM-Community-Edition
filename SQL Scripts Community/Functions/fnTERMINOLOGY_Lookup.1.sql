if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnTERMINOLOGY_Lookup' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnTERMINOLOGY_Lookup;
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
-- 03/06/2012 Paul.  Increase size of the NAME field so that it can include a date formula. 
Create Function dbo.fnTERMINOLOGY_Lookup
	( @NAME              nvarchar(150)
	, @LANG              nvarchar(10)
	, @MODULE_NAME       nvarchar(25)
	, @LIST_NAME         nvarchar(50)
	)
returns nvarchar(2000)
as
  begin
	declare @DISPLAY_NAME nvarchar(max);
	if @LIST_NAME is not null begin -- then
		set @DISPLAY_NAME = (select top 1 DISPLAY_NAME
		                       from TERMINOLOGY
		                      where LANG        = @LANG
		                        and NAME        = @NAME
		                        and LIST_NAME   = @LIST_NAME
		                        and DELETED     = 0
		                    );
	end else if @MODULE_NAME is not null begin -- then
		set @DISPLAY_NAME = (select top 1 DISPLAY_NAME
		                       from TERMINOLOGY
		                      where LANG        = @LANG
		                        and NAME        = @NAME
		                        and MODULE_NAME = @MODULE_NAME
		                        and DELETED     = 0
		                    );
	end else begin
		set @DISPLAY_NAME = (select top 1 DISPLAY_NAME
		                       from TERMINOLOGY
		                      where LANG        = @LANG
		                        and NAME        = @NAME
		                        and MODULE_NAME is null
		                        and DELETED     = 0
		                    );
	end -- if;
	return @DISPLAY_NAME;
  end
GO

Grant Execute on dbo.fnTERMINOLOGY_Lookup to public
GO

