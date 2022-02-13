if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnEDITVIEWS_FIELDS_MultiSelect' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnEDITVIEWS_FIELDS_MultiSelect;
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
-- 10/13/2011 Paul.  Special list of EditViews for the search area with IS_MULTI_SELECT. 
-- 09/11/2013 Paul.  A CheckBoxList is also a multi-select. 
Create Function dbo.fnEDITVIEWS_FIELDS_MultiSelect(@MODULE_NAME nvarchar(25), @DATA_FIELD nvarchar(100), @FIELD_TYPE nvarchar(25))
returns bit
as
  begin
	declare @IS_MULTI_SELECT bit;
	set @IS_MULTI_SELECT = 0;
	if @FIELD_TYPE = N'ListBox' or @FIELD_TYPE = N'CheckBoxList' begin -- then
		set @IS_MULTI_SELECT = 0;
		if exists(select *
		            from EDITVIEWS_FIELDS
		           where DELETED      = 0
		             and DEFAULT_VIEW = 0
		             and EDIT_NAME    = @MODULE_NAME + N'.EditView'
		             and DATA_FIELD   = @DATA_FIELD
		             and FIELD_TYPE   in (N'ListBox', N'CheckBoxList')
		             and FORMAT_ROWS  > 0
		         ) begin -- then
			set @IS_MULTI_SELECT = 1;
		end -- if;
	end -- if;
	return @IS_MULTI_SELECT;
  end
GO

Grant Execute on dbo.fnEDITVIEWS_FIELDS_MultiSelect to public
GO

