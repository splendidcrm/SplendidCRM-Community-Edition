if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnSqlIndexColumns' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnSqlIndexColumns;
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
-- 09/06/2010 Paul.  Help with migration with EffiProz. 
Create Function dbo.fnSqlIndexColumns(@TABLE_NAME sysname, @object_id int, @index_id tinyint)
returns varchar(4000)
as 
  begin
	declare @colnames    varchar(4000);
	declare @thisColID   int;
	declare @thisColName sysname;
	
	set @colnames = index_col(@table_name, @index_id, 1) + (case indexkey_property(@object_id, @index_id, 1, 'IsDescending') when 1 then ' DESC' else '' end);
	set @thisColID   = 2;
	set @thisColName = index_col(@table_name, @index_id, @thisColID) + (case indexkey_property(@object_id, @index_id, @thisColID, 'IsDescending') when 1 then ' DESC' else '' end);

	while @thisColName is not null begin -- do
		set @thisColID   = @thisColID + 1;
		set @colnames    = @colnames + ', ' + @thisColName;
		set @thisColName = index_col(@table_name, @index_id, @thisColID) + (case indexkey_property(@object_id, @index_id, @thisColID, 'IsDescending') when 1 then ' DESC' else '' end);
	end -- while;
	return upper(@colNames);
  end
GO

Grant Execute on dbo.fnSqlIndexColumns to public
GO

