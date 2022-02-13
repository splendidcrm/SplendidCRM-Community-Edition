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
-- 11/27/2008 Paul.  Quotes are not supported on SplendidCRM Basic.
-- 11/28/2008 Paul.  If the view already exists, then don't replace it.
-- 09/27/2009 Paul.  Keep the encryption text left-aligned so that it can be easily removed. 
-- 11/26/2009 Paul.  This view might be used by the offline client (in Opportunity Create), we need the team fields. 
-- 11/26/2009 Paul.  Make sure to drop the view if it already exists and does not have the TEAM_ID field. 
-- 10/23/2010 Paul.  The Community Edition view needs a stub for ASSIGNED_USER_ID to prevent exception. 
if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwQUOTES') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'vwQUOTES' and COLUMN_NAME = 'TEAM_ID') begin -- then
		Drop View dbo.vwQUOTES;
	end -- if;
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'vwQUOTES' and COLUMN_NAME = 'ASSIGNED_USER_ID') begin -- then
		Drop View dbo.vwQUOTES;
	end -- if;
end -- if;

if not exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwQUOTES') begin -- then
	exec('Create View dbo.vwQUOTES
as
select cast(null as uniqueidentifier) as ID
     , cast(null as uniqueidentifier) as BILLING_ACCOUNT_ID
     , cast(null as nvarchar(100))    as BILLING_ACCOUNT_NAME
     , cast(null as money)            as TOTAL_USDOLLAR
     , cast(null as uniqueidentifier) as TEAM_ID
     , cast(null as uniqueidentifier) as TEAM_SET_ID
     , cast(null as uniqueidentifier) as ASSIGNED_USER_ID
');

	exec('Grant Select on dbo.vwQUOTES to public');
end -- if;
GO


