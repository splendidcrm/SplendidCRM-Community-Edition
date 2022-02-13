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
-- 03/28/2010 Paul.  Exchange Web Services returns dates in local time, so lets store both local time and UTC time. 
-- 03/28/2010 Paul.  REMOTE_KEY does not need to be an nvarchar.  
-- 04/01/2010 Paul.  Add the MODULE_NAME so that the LastModifiedTime can be filtered by module. 
-- 04/04/2010 Paul.  Add PARENT_ID so that the LastModifiedTime can be filtered by record. 
-- 07/24/2010 Paul.  Instead of managing collation in code, it is better to change the collation on the field in the database. 
-- 08/31/2010 Paul.  The EMAILS_SYNC table was renamed to EMAIL_CLIENT_SYNC to prevent conflict with Offline Client sync tables. 

