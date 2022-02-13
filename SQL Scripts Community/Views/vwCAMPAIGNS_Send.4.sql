if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCAMPAIGNS_Send')
	Drop View dbo.vwCAMPAIGNS_Send;
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
-- 08/18/2007 Paul.  The complex select statement automatically 
-- includes all selected prospect lists and it automatically excludes all exempt lists. 
-- 01/20/2008 Paul.  Only include active EMAIL_MARKETING records. 
-- 09/02/2008 Jake.  The EMAIL_MARKETING is not valid if the EMAIL_TEMPLATES is deleted. 
-- 09/01/2009 Paul.  Add TEAM_SET_ID so that the team filter will not fail. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwCAMPAIGNS_Send
as
select distinct
       EMAIL_MARKETING.CAMPAIGN_ID           as CAMPAIGN_ID
     , vwCAMPAIGNS_PROSPECT_LIST_Send.TEST   as TEST
     , EMAIL_MARKETING.ID                    as EMAIL_MARKETING_ID
     , vwPROSPECT_LISTS_Emails.ID            as PROSPECT_LIST_ID
     , vwPROSPECT_LISTS_Emails.RELATED_ID    as RELATED_ID
     , vwPROSPECT_LISTS_Emails.RELATED_TYPE  as RELATED_TYPE
     , vwPROSPECT_LISTS_Emails.RELATED_NAME  as RELATED_NAME
     , vwPROSPECT_LISTS_Emails.EMAIL1        as EMAIL1
     , (case vwCAMPAIGNS_PROSPECT_LIST_Send.TEST
        when 1 then getdate() 
        else EMAIL_MARKETING.DATE_START end) as SEND_DATE_TIME
     , cast(null as uniqueidentifier)        as ASSIGNED_USER_ID
     , cast(null as uniqueidentifier)        as TEAM_ID
     , cast(null as uniqueidentifier)        as TEAM_SET_ID
     , cast(null as nvarchar(200))           as TEAM_SET_NAME
     , cast(null as uniqueidentifier)        as ASSIGNED_SET_ID
     , cast(null as nvarchar(200))           as ASSIGNED_SET_NAME
     , cast(null as varchar(851))            as ASSIGNED_SET_LIST
  from            EMAIL_MARKETING
       inner join PROSPECT_LIST_CAMPAIGNS
               on PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID               = EMAIL_MARKETING.CAMPAIGN_ID
              and PROSPECT_LIST_CAMPAIGNS.DELETED                   = 0
       inner join EMAIL_TEMPLATES
               on EMAIL_TEMPLATES.ID                                = EMAIL_MARKETING.TEMPLATE_ID
              and EMAIL_TEMPLATES.DELETED                           = 0
       inner join vwPROSPECT_LISTS_Emails
               on vwPROSPECT_LISTS_Emails.ID                        = PROSPECT_LIST_CAMPAIGNS.PROSPECT_LIST_ID
       inner join vwCAMPAIGNS_PROSPECT_LIST_Send
               on vwCAMPAIGNS_PROSPECT_LIST_Send.PROSPECT_LIST_ID   = vwPROSPECT_LISTS_Emails.ID
              and vwCAMPAIGNS_PROSPECT_LIST_Send.ALL_PROSPECT_LISTS = isnull(EMAIL_MARKETING.ALL_PROSPECT_LISTS, 0)
              and (   vwCAMPAIGNS_PROSPECT_LIST_Send.CAMPAIGN_ID        = PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID
                   or vwCAMPAIGNS_PROSPECT_LIST_Send.EMAIL_MARKETING_ID = EMAIL_MARKETING.ID)
  left outer join vwPROSPECT_LISTS_ExemptEmails
               on vwPROSPECT_LISTS_ExemptEmails.RELATED_ID          = vwPROSPECT_LISTS_Emails.RELATED_ID
              and vwPROSPECT_LISTS_ExemptEmails.CAMPAIGN_ID         = PROSPECT_LIST_CAMPAIGNS.CAMPAIGN_ID
 where EMAIL_MARKETING.DELETED = 0
   and EMAIL_MARKETING.STATUS  = N'active'
   and vwPROSPECT_LISTS_ExemptEmails.RELATED_ID is null
GO

Grant Select on dbo.vwCAMPAIGNS_Send to public;
GO


