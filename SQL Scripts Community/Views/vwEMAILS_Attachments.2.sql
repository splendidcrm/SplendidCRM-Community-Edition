if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAILS_Attachments')
	Drop View dbo.vwEMAILS_Attachments;
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
-- 07/30/2006 Paul.  System.Net.Mail in .NET 2.0 requires the mime type for the attachments. 
-- 12/05/2006 Paul.  Literals should be in unicode to reduce conversions at runtime. 
-- 05/12/2017 Paul.  Need to optimize for Azure. 
Create View dbo.vwEMAILS_Attachments
as
select NOTES.ID
     , NOTES.NAME
     , NOTES.FILENAME
     , NOTES.FILE_MIME_TYPE
     , NOTES.NOTE_ATTACHMENT_ID
     , NOTES.PARENT_ID          as EMAIL_ID
  from      NOTES
 inner join NOTE_ATTACHMENTS
         on NOTE_ATTACHMENTS.ID      = NOTES.NOTE_ATTACHMENT_ID
        and NOTE_ATTACHMENTS.DELETED = 0
        and NOTE_ATTACHMENTS.ATTACHMENT_LENGTH > 0
 where NOTES.DELETED            = 0
   and NOTES.PARENT_TYPE        = N'Emails'
   and NOTES.FILENAME           is not null

GO

Grant Select on dbo.vwEMAILS_Attachments to public;
GO


