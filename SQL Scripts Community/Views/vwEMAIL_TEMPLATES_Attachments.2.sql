if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAIL_TEMPLATES_Attachments')
	Drop View dbo.vwEMAIL_TEMPLATES_Attachments;
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
Create View dbo.vwEMAIL_TEMPLATES_Attachments
as
select ID
     , NAME
     , FILENAME
     , FILE_MIME_TYPE
     , NOTE_ATTACHMENT_ID
     , PARENT_ID          as EMAIL_TEMPLATE_ID
  from vwNOTES
 where PARENT_TYPE        = N'EmailTemplates'
   and ATTACHMENT_READY   = 1
   and NOTE_ATTACHMENT_ID is not null
   and FILENAME           is not null

GO

Grant Select on dbo.vwEMAIL_TEMPLATES_Attachments to public;
GO


