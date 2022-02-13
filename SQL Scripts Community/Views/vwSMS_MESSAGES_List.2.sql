if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSMS_MESSAGES_List')
	Drop View dbo.vwSMS_MESSAGES_List;
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
Create View dbo.vwSMS_MESSAGES_List
as
select vwSMS_MESSAGES.*
     , (case when vwSMS_MESSAGES.TYPE = N'out' and vwSMS_MESSAGES.STATUS = N'send_error' then N'SmsMessages.LBL_NOT_SENT'
             else N'.dom_sms_types.' + vwSMS_MESSAGES.TYPE
        end) as TYPE_TERM
     , (select count(*) from vwSMS_MESSAGES_Attachments where PARENT_ID = vwSMS_MESSAGES.ID) as ATTACHMENT_COUNT
  from vwSMS_MESSAGES

GO

Grant Select on dbo.vwSMS_MESSAGES_List to public;
GO


