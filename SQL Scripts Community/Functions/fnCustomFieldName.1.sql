if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnCustomFieldName' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnCustomFieldName;
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
Create Function dbo.fnCustomFieldName(@COLUMN_NAME nvarchar(255))
returns nvarchar(255)
as
  begin
	declare @CUSTOM_NAME nvarchar(255);
	-- 01/06/2006 Paul.  Use lowercase as the column name will be made uppercase later. 
	set @CUSTOM_NAME = @COLUMN_NAME + N'_c';
	return @CUSTOM_NAME;
  end
GO

Grant Execute on dbo.fnCustomFieldName to public
GO

