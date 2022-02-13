
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
-- 12/19/2017 Paul.  ACCOUNTS_CASES use was ended back in 2005. The table needs to be removed as it causes problems with archiving. 
if exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ACCOUNTS_CASES') begin -- then
	-- 12/19/2017 Paul.  Just in case some customers have used this relationship table, only delete if empty. 
	if not exists(select * from ACCOUNTS_CASES) begin -- then
		print 'drop table ACCOUNTS_CASES';
		drop table ACCOUNTS_CASES;
	end -- if;
end -- if;
GO

-- 04/24/2018 Paul.  ACCOUNTS_CASES use was ended back in 2005. The table needs to be removed as it causes problems with archiving. 
if exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ACCOUNTS_CASES_AUDIT') begin -- then
	-- 04/24/2018 Paul.  Just in case some customers have used this relationship table, only delete if empty. 
	if not exists(select * from ACCOUNTS_CASES_AUDIT) begin -- then
		print 'drop table ACCOUNTS_CASES_AUDIT';
		drop table ACCOUNTS_CASES_AUDIT;
	end -- if;
end -- if;
GO

-- 04/06/2020 Paul.  Delete related views. 
if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACCOUNTS_CASES')
	Drop View dbo.vwACCOUNTS_CASES;
GO

if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACCOUNTS_CASES_ARCHIVE')
	Drop View dbo.vwACCOUNTS_CASES_ARCHIVE;
GO

