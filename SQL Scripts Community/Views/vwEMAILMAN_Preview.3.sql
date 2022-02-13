if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAILMAN_Preview')
	Drop View dbo.vwEMAILMAN_Preview;
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
-- 01/12/2008 Paul.  Preview is different in that it does not filter on queue date. 
-- 08/23/2011 Paul.  Campaign emails are being sent to invalid email addresses even after being marked as invalid. 
-- Filter invalid emails at runtime. 
-- 10/06/2011 Paul.  Invalid email had wrong condition. 
-- 03/30/2013 Paul.  All campaign emails should be created with the template Assigned User and Team ID. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwEMAILMAN_Preview
as
select vwEMAILMAN_List.*
     , EMAIL_TEMPLATES.SUBJECT
     , EMAIL_TEMPLATES.BODY
     , EMAIL_TEMPLATES.BODY_HTML
     , EMAIL_TEMPLATES.ASSIGNED_USER_ID
     , EMAIL_TEMPLATES.TEAM_ID
     , EMAIL_TEMPLATES.TEAM_SET_ID
     , EMAIL_TEMPLATES.ASSIGNED_SET_ID
  from      vwEMAILMAN_List
 inner join EMAIL_TEMPLATES
         on EMAIL_TEMPLATES.ID = vwEMAILMAN_List.EMAIL_TEMPLATE_ID
 where INVALID_EMAIL = 0

GO

Grant Select on dbo.vwEMAILMAN_Preview to public;
GO

