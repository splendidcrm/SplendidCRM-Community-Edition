if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSqlTablesCachedSystem')
	Drop View dbo.vwSqlTablesCachedSystem;
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
-- 09/24/2009 Paul.  Add the DASHLETS tables so that they are not audited. 
-- 01/17/2010 Paul.  Add ACL Fields. 
-- 12/04/2010 Paul.  Add PAYMENT_GATEWAYS, DISCOUNTS and RULES. 
-- 05/30/2014 Paul.  Add EDITVIEWS_RELATIONSHIPS. 
-- 12/17/2017 Paul.  Add MODULES_ARCHIVE_RELATED. 
-- 07/25/2019 Paul.  Add REACT_CUSTOM_VIEWS. 
Create View dbo.vwSqlTablesCachedSystem
as
select TABLE_NAME
  from vwSqlTables
 where TABLE_NAME in
( N'ACL_ACTIONS'
, N'ACL_FIELDS'
, N'ACL_FIELDS_ALIASES'
, N'ACL_ROLES'
, N'ACL_ROLES_ACTIONS'
, N'ACL_ROLES_USERS'
, N'CONFIG'
, N'CUSTOM_FIELDS'
, N'DASHLETS'
, N'DASHLETS_USERS'
, N'DETAILVIEWS'
, N'DETAILVIEWS_FIELDS'
, N'DETAILVIEWS_RELATIONSHIPS'
, N'DISCOUNTS'
, N'DYNAMIC_BUTTONS'
, N'EDITVIEWS'
, N'EDITVIEWS_FIELDS'
, N'EDITVIEWS_RELATIONSHIPS'
, N'FIELDS_META_DATA'
, N'GRIDVIEWS'
, N'GRIDVIEWS_COLUMNS'
, N'LANGUAGES'
, N'MODULES'
, N'MODULES_ARCHIVE_RELATED'
, N'PAYMENT_GATEWAYS'
, N'REACT_CUSTOM_VIEWS'
, N'RELATIONSHIPS'
, N'RULES'
, N'SHORTCUTS'
, N'TERMINOLOGY'
, N'TERMINOLOGY_ALIASES'
, N'TIMEZONES'
)
GO


Grant Select on dbo.vwSqlTablesCachedSystem to public;
GO

