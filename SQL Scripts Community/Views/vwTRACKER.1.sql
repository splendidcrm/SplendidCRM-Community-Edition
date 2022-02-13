if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwTRACKER')
	Drop View dbo.vwTRACKER;
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
-- 08/17/2005 Paul.  Oracle is having a problem returning 0 as an integer. 
-- Just add the column in code. 
-- 02/01/2006 Paul.  DB2 does not like comments in the middle of the Create View statement. 
-- 03/08/2012 Paul.  Add ACTION to the tracker table so that we can create quick user activity reports. 
Create View dbo.vwTRACKER
as
select USER_ID
     , MODULE_NAME
     , ITEM_ID
     , ITEM_SUMMARY
     , DATE_ENTERED
     , DATE_MODIFIED
     , ACTION
  from TRACKER

GO

Grant Select on dbo.vwTRACKER to public;
GO


