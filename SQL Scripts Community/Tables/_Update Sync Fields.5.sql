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

-- 05/11/2014 Paul.  Disabling triggers is not working. We are still getting events from the audit tables. Instead, remove all CRM triggers. 
if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSqlTables') begin -- then
	exec dbo.spSqlDropAllAuditTriggers;
end -- if;
GO

-- 11/16/2009 Paul.  The DATE_MODIFIED_UTC field must be created before the views are created. 
exec dbo.spSqlUpdateSyncdTables;

-- 04/27/2014 Paul.  We do not need to add the triggers here.  They will be added after the procedures. 
GO


