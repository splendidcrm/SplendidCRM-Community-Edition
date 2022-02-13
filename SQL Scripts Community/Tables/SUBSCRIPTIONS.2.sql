
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
-- 10/09/2015 Paul.  A SugarCRM will not have the ASSIGNED_USER_ID field, so add it. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SUBSCRIPTIONS' and COLUMN_NAME = 'ASSIGNED_USER_ID') begin -- then
	print 'alter table SUBSCRIPTIONS add ASSIGNED_USER_ID uniqueidentifier null';
	alter table SUBSCRIPTIONS add ASSIGNED_USER_ID uniqueidentifier null;
	update SUBSCRIPTIONS
	   set ASSIGNED_USER_ID = CREATED_BY;

	create index IDX_SUBSCRIPTIONS_USER_RECORD on dbo.SUBSCRIPTIONS (ASSIGNED_USER_ID, DELETED, PARENT_ID  )
	create index IDX_SUBSCRIPTIONS_USER_MODULE on dbo.SUBSCRIPTIONS (ASSIGNED_USER_ID, DELETED, PARENT_TYPE)
end -- if;
GO

