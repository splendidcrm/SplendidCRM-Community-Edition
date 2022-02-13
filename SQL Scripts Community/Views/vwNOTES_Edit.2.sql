if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwNOTES_Edit')
	Drop View dbo.vwNOTES_Edit;
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
-- 01/23/2010 Paul.  The SOAP interface needs access to the TEAM_SET_LIST
-- 10/25/2010 Paul.  TEAM_SET_LIST was moved to the base view as it is needed by the RulesWizard. 
Create View dbo.vwNOTES_Edit
as
select *
  from vwNOTES

GO

Grant Select on dbo.vwNOTES_Edit to public;
GO


