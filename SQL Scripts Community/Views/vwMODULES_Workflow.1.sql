if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_Workflow')
	Drop View dbo.vwMODULES_Workflow;
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
-- 06/23/2010 Paul.  Add Reports module. 
-- 08/13/2014 Paul.  Add relative path for generation of CampaignLog. 
-- 01/29/2019 Paul.  Include Teams in workflow. 
Create View dbo.vwMODULES_Workflow
as
select MODULE_NAME
     , DISPLAY_NAME
     , TABLE_NAME
     , RELATIVE_PATH
  from vwMODULES
 where MODULE_ENABLED = 1
   and ((REPORT_ENABLED = 1 and IS_ADMIN = 0) or MODULE_NAME in (N'CreditCards', N'Notes', N'Users', N'Reports', 'Teams'))
GO

-- select * from vwMODULES_Workflow order by 1

Grant Select on dbo.vwMODULES_Workflow to public;
GO


