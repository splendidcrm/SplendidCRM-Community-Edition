if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCALLS_Edit')
	Drop View dbo.vwCALLS_Edit;
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
-- 11/08/2008 Paul.  Move description to base view. 
Create View dbo.vwCALLS_Edit
as
select vwCALLS.*
     , (case when vwCALLS.REMINDER_TIME > 0 then 1 else 0 end) as SHOULD_REMIND
  from            vwCALLS
  left outer join CALLS
               on CALLS.ID = vwCALLS.ID

GO

Grant Select on dbo.vwCALLS_Edit to public;
GO

 
