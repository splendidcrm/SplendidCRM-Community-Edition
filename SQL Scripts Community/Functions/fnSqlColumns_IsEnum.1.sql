if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnSqlColumns_IsEnum' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnSqlColumns_IsEnum;
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
-- 02/09/2007 Paul.  Use the EDITVIEWS_FIELDS to determine if a column is an enum. 
-- 09/16/2010 Paul.  CsType can be SqlDbType.DateTime. 
-- 12/12/2010 Paul.  EffiProz needs the ColumnName field to be greater than 35 due to an internal variable. 
-- 09/13/2011 Paul.  The Workflow EditView will append _AUDIT to the table name, so we need to remove that. 
-- Workflow EditView appends _AUDIT to prevent the inclusion of addtional fields in the base view, such as CITY in the vwACCOUNTS view. 
Create Function dbo.fnSqlColumns_IsEnum(@ModuleView nvarchar(50), @ColumnName nvarchar(50), @CsType nvarchar(20))
returns bit
as
  begin
	declare @IS_ENUM bit;
	declare @TableView nvarchar(50)
	set @IS_ENUM = 0;
	set @TableView = @ModuleView;
	if right(@TableView, 6) = '_AUDIT' begin -- then
		set @TableView = substring(@TableView, 1, len(@TableView) - 6);
	end -- if;
	if @CsType = N'string' or @CsType = N'ansistring' begin -- then
		if exists(select *
		            from      EDITVIEWS_FIELDS
		           inner join EDITVIEWS
		                   on EDITVIEWS.NAME      = EDITVIEWS_FIELDS.EDIT_NAME
		                  and EDITVIEWS.VIEW_NAME = @TableView + N'_Edit'
		                  and EDITVIEWS.DELETED   = 0
		           where EDITVIEWS_FIELDS.DELETED = 0
	                     and EDITVIEWS_FIELDS.FIELD_TYPE   = N'ListBox'
		             and EDITVIEWS_FIELDS.DEFAULT_VIEW = 0
		             and EDITVIEWS_FIELDS.DATA_FIELD   = @ColumnName
		             and EDITVIEWS_FIELDS.CACHE_NAME is not null) begin -- then
			set @IS_ENUM = 1;
		end -- if;
	end -- if;
	return @IS_ENUM;
  end
GO

Grant Execute on dbo.fnSqlColumns_IsEnum to public
GO

