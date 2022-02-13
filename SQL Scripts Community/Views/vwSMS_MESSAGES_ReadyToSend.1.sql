if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSMS_MESSAGES_ReadyToSend')
	Drop View dbo.vwSMS_MESSAGES_ReadyToSend;
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
Create View dbo.vwSMS_MESSAGES_ReadyToSend
as
select SMS_MESSAGES.ID
     , SMS_MESSAGES.FROM_NUMBER
     , SMS_MESSAGES.TO_NUMBER
     , SMS_MESSAGES.NAME
     , SMS_MESSAGES.TYPE
     , SMS_MESSAGES.STATUS
     , SMS_MESSAGES.PARENT_TYPE
     , SMS_MESSAGES.PARENT_ID
     , SMS_MESSAGES.DATE_MODIFIED
     , SMS_MESSAGES.MODIFIED_USER_ID
     , SMS_MESSAGES.MAILBOX_ID
  from            SMS_MESSAGES
  left outer join OUTBOUND_SMS
               on OUTBOUND_SMS.ID      = SMS_MESSAGES.MAILBOX_ID
              and OUTBOUND_SMS.DELETED = 0
 where SMS_MESSAGES.DELETED = 0
   and SMS_MESSAGES.TYPE    = N'out'
   and (SMS_MESSAGES.STATUS = N'draft' or SMS_MESSAGES.STATUS is null)

GO

Grant Select on dbo.vwSMS_MESSAGES_ReadyToSend to public;
GO

 
