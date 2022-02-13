
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
-- 04/21/2006 Paul.  RELATIONSHIP_ROLE_COLUMN_VALUE was increased to nvarchar(50) in SugarCRM 4.0.
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'RELATIONSHIPS' and COLUMN_NAME = 'RELATIONSHIP_ROLE_COLUMN_VALUE' and CHARACTER_MAXIMUM_LENGTH < 50) begin -- then
	print 'alter table RELATIONSHIPS alter column RELATIONSHIP_ROLE_COLUMN_VALUE nvarchar(50) null';
	alter table RELATIONSHIPS alter column RELATIONSHIP_ROLE_COLUMN_VALUE nvarchar(50) null;
end -- if;
GO

