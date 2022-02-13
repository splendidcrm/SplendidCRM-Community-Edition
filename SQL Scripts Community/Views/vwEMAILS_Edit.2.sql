if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAILS_Edit')
	Drop View dbo.vwEMAILS_Edit;
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
-- 04/17/2006 Paul.  Return DESCRIPTION_HTML.  This is the primary field now that we have and HTML editor. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 06/05/2014 Paul.  Move _IDS and _EMAILS to base view so that they can be accessed via REST API. 
Create View dbo.vwEMAILS_Edit
as
select vwEMAILS.*
     , EMAILS.TO_ADDRS
     , EMAILS.CC_ADDRS
     , EMAILS.BCC_ADDRS
     , EMAILS.TO_ADDRS_NAMES
     , EMAILS.CC_ADDRS_NAMES
     , EMAILS.BCC_ADDRS_NAMES
  from            vwEMAILS
  left outer join EMAILS
               on EMAILS.ID = vwEMAILS.ID

GO

Grant Select on dbo.vwEMAILS_Edit to public;
GO

 
