if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAIL_MARKETING')
	Drop View dbo.vwEMAIL_MARKETING;
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
-- 12/21/2007 Paul.  We need to use the inbound email to specify the RETURN_PATH. 
-- 09/02/2008 Jake.  The EMAIL_MARKETING is not valid if the EMAIL_TEMPLATES is deleted,
-- but we still want to display the EMAIL_MARKETING record, so use an outer join. 
-- 09/01/2009 Paul.  Add TEAM_SET_ID so that the team filter will not fail. 
-- 09/01/2009 Paul.  Alow the display of email marketing even if campaign record has been deleted. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 04/26/2012 Paul.  Add TEMPLATE_ASSIGNED_USER_ID. 
-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 04/10/2021 Paul.  React client requires DATE_MODIFIED_UTC in all tables. 
Create View dbo.vwEMAIL_MARKETING
as
select EMAIL_MARKETING.ID
     , EMAIL_MARKETING.NAME              
     , EMAIL_MARKETING.FROM_ADDR         
     , EMAIL_MARKETING.FROM_NAME         
     , EMAIL_MARKETING.REPLY_TO_NAME
     , EMAIL_MARKETING.REPLY_TO_ADDR
     , EMAIL_MARKETING.DATE_START        
     , EMAIL_MARKETING.TIME_START        
     , INBOUND_EMAILS.ID                as INBOUND_EMAIL_ID
     , INBOUND_EMAILS.FROM_NAME         as RETURN_NAME
     , INBOUND_EMAILS.FROM_ADDR         as RETURN_PATH
     , EMAIL_MARKETING.STATUS            
     , EMAIL_MARKETING.ALL_PROSPECT_LISTS
     , EMAIL_MARKETING.DATE_ENTERED
     , EMAIL_MARKETING.DATE_MODIFIED
     , EMAIL_MARKETING.DATE_MODIFIED_UTC
     , CAMPAIGNS.ID                     as CAMPAIGN_ID
     , CAMPAIGNS.NAME                   as CAMPAIGN_NAME
     , CAMPAIGNS.CAMPAIGN_TYPE          as CAMPAIGN_TYPE
     , CAMPAIGNS.ASSIGNED_USER_ID       as CAMPAIGN_ASSIGNED_USER_ID
     , CAMPAIGNS.ASSIGNED_SET_ID        as CAMPAIGN_ASSIGNED_SET_ID
     , EMAIL_TEMPLATES.ID               as TEMPLATE_ID
     , EMAIL_TEMPLATES.NAME             as TEMPLATE_NAME
     , EMAIL_TEMPLATES.ASSIGNED_USER_ID as TEMPLATE_ASSIGNED_USER_ID
     , EMAIL_TEMPLATES.ASSIGNED_SET_ID  as TEMPLATE_ASSIGNED_SET_ID
     , EMAIL_TEMPLATES.ASSIGNED_USER_ID as ASSIGNED_USER_ID
     , cast(null as uniqueidentifier)   as TEAM_ID
     , cast(null as nvarchar(128))      as TEAM_NAME
     , cast(null as uniqueidentifier)   as TEAM_SET_ID
     , cast(null as nvarchar(200))      as TEAM_SET_NAME
     , USERS_CREATED_BY.USER_NAME       as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME      as MODIFIED_BY
     , EMAIL_MARKETING.CREATED_BY       as CREATED_BY_ID
     , EMAIL_MARKETING.MODIFIED_USER_ID
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                   as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME    as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST    as ASSIGNED_SET_LIST
     , EMAIL_MARKETING_CSTM.*
  from            EMAIL_MARKETING
  left outer join CAMPAIGNS
               on CAMPAIGNS.ID             = EMAIL_MARKETING.CAMPAIGN_ID
              and CAMPAIGNS.DELETED        = 0
  left outer join EMAIL_TEMPLATES
               on EMAIL_TEMPLATES.ID       = EMAIL_MARKETING.TEMPLATE_ID       
              and EMAIL_TEMPLATES.DELETED  = 0
  left outer join INBOUND_EMAILS
               on INBOUND_EMAILS.ID        = INBOUND_EMAIL_ID
              and INBOUND_EMAILS.DELETED   = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = EMAIL_TEMPLATES.ASSIGNED_USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = EMAIL_MARKETING.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = EMAIL_MARKETING.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = EMAIL_TEMPLATES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
  left outer join EMAIL_MARKETING_CSTM
               on EMAIL_MARKETING_CSTM.ID_C = EMAIL_MARKETING.ID
 where EMAIL_MARKETING.DELETED = 0

GO

Grant Select on dbo.vwEMAIL_MARKETING to public;
GO

 
