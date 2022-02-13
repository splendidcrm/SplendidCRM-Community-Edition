if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwNOTE_ATTACHMENTS_Related')
	Drop View dbo.vwNOTE_ATTACHMENTS_Related;
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
-- 12/21/2007 Paul.  The NOTE_ATTACHMENT will have only one originating parent, and that will be the NOTE_ID. 
-- However, there can be several NOTES that point to the attachment. 
-- The join must therefore use NOTE_ATTACHMENT_ID. 
Create View dbo.vwNOTE_ATTACHMENTS_Related
as
select NOTE_ATTACHMENTS.ID
     , NOTE_ATTACHMENTS.NOTE_ID
     , NOTES.ID                 as RELATED_ID
     , NOTES.NAME               as RELATED_NAME
  from            NOTE_ATTACHMENTS
       inner join NOTES
               on NOTES.NOTE_ATTACHMENT_ID = NOTE_ATTACHMENTS.ID
              and NOTES.DELETED            = 0

GO

Grant Select on dbo.vwNOTE_ATTACHMENTS_Related to public;
GO

