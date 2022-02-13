
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
-- 08/24/2013 Paul.  Add EXTENSION_C in preparation for Asterisk click-to-call. 
-- 09/20/2013 Paul.  Move EXTENSION to the main table. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USERS_CSTM' and COLUMN_NAME = 'EXTENSION_C') begin -- then
	print 'Remove USERS_CSTM.EXTENSION_C'
	-- exec dbo.spFIELDS_META_DATA_Insert null, null, 'EXTENSION', 'Extension:', 'EXTENSION', 'Users', 'varchar', 25, 0, 0, null, null, 0;
	exec dbo.spFIELDS_META_DATA_DeleteByName null, 'Users', 'EXTENSION_C';
end -- if;
GO

