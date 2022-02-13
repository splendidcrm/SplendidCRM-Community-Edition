if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnCustomTableName' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnCustomTableName;
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
-- 12/16/2006 Paul.  Not all module names can be easily converted to a custom module name.  Use the MODULES table to convert. 
Create Function dbo.fnCustomTableName(@MODULE_NAME nvarchar(255))
returns nvarchar(255)
as
  begin
	declare @CUSTOM_NAME nvarchar(255);
	select top 1 @CUSTOM_NAME = TABLE_NAME + N'_CSTM'
	  from MODULES
	 where MODULE_NAME = @MODULE_NAME;

	if @CUSTOM_NAME is null begin -- then
		set @CUSTOM_NAME = @MODULE_NAME + N'_CSTM';
	end -- if;
	return @CUSTOM_NAME;
  end
GO

Grant Execute on dbo.fnCustomTableName to public
GO

