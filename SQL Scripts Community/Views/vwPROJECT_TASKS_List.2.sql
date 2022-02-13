if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROJECT_TASKS_List')
	Drop View dbo.vwPROJECT_TASKS_List;
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
-- 05/02/2006 Paul.  DB2 is particular about how * is used.  
Create View dbo.vwPROJECT_TASKS_List
as
select vwPROJECT_TASKS.*
     , (case STATUS when N'Completed' then 0
                    when N'Deferred'  then 0
                    else 1
        end) as CAN_CLOSE
  from vwPROJECT_TASKS

GO

Grant Select on dbo.vwPROJECT_TASKS_List to public;
GO


