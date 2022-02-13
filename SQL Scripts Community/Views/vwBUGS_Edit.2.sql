if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwBUGS_Edit')
	Drop View dbo.vwBUGS_Edit;
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
-- 07/04/2007 Paul.  The Releases list references the fields as IDs, but we need to use them as text values in the detail and grid views. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 08/01/2009 Paul.  Move FOUND_IN_RELEASE_ID and FIXED_IN_RELEASE_ID to base view so that it can be used everywhere. 
Create View dbo.vwBUGS_Edit
as
select *
  from vwBUGS

GO

Grant Select on dbo.vwBUGS_Edit to public;
GO

