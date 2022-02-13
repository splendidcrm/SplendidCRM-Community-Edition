if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAILS_OPPORTUNITIES')
	Drop View dbo.vwEMAILS_OPPORTUNITIES;
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
-- 10/28/2007 Paul.  The include the email parent, but not union all so that duplicates will get filtered. 
-- 09/09/2008 Paul.  Using a union causes a problem if there is an NTEXT custom field in the PROSPECTS_CSTM table. 
-- The text, ntext, or image data type cannot be selected as DISTINCT.
-- One solution would be to use UNION ALL, but then we would get duplicate records. 
-- So we still use UNION ALL, but also use an outer join to block duplicates. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwEMAILS_OPPORTUNITIES
as
select EMAILS.ID               as EMAIL_ID
     , EMAILS.NAME             as EMAIL_NAME
     , EMAILS.ASSIGNED_USER_ID as EMAIL_ASSIGNED_USER_ID
     , EMAILS.ASSIGNED_SET_ID  as EMAIL_ASSIGNED_SET_ID
     , vwOPPORTUNITIES.ID      as OPPORTUNITY_ID
     , vwOPPORTUNITIES.NAME    as OPPORTUNITY_NAME
     , vwOPPORTUNITIES.*
  from            EMAILS
       inner join EMAILS_OPPORTUNITIES
               on EMAILS_OPPORTUNITIES.EMAIL_ID = EMAILS.ID
              and EMAILS_OPPORTUNITIES.DELETED  = 0
       inner join vwOPPORTUNITIES
               on vwOPPORTUNITIES.ID            = EMAILS_OPPORTUNITIES.OPPORTUNITY_ID
 where EMAILS.DELETED = 0
union all
select EMAILS.ID               as EMAIL_ID
     , EMAILS.NAME             as EMAIL_NAME
     , EMAILS.ASSIGNED_USER_ID as EMAIL_ASSIGNED_USER_ID
     , EMAILS.ASSIGNED_SET_ID  as EMAIL_ASSIGNED_SET_ID
     , vwOPPORTUNITIES.ID      as OPPORTUNITY_ID
     , vwOPPORTUNITIES.NAME    as OPPORTUNITY_NAME
     , vwOPPORTUNITIES.*
  from            EMAILS
       inner join vwOPPORTUNITIES
               on vwOPPORTUNITIES.ID                  = EMAILS.PARENT_ID
  left outer join EMAILS_OPPORTUNITIES
               on EMAILS_OPPORTUNITIES.EMAIL_ID       = EMAILS.ID
              and EMAILS_OPPORTUNITIES.OPPORTUNITY_ID = vwOPPORTUNITIES.ID
              and EMAILS_OPPORTUNITIES.DELETED        = 0
 where EMAILS.DELETED     = 0
   and EMAILS.PARENT_TYPE = N'Opportunities'
   and EMAILS_OPPORTUNITIES.ID is null

GO

Grant Select on dbo.vwEMAILS_OPPORTUNITIES to public;
GO

