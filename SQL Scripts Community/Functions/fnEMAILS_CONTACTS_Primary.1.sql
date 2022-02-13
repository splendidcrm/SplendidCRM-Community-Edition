if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnEMAILS_CONTACTS_Primary' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnEMAILS_CONTACTS_Primary;
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
Create Function dbo.fnEMAILS_CONTACTS_Primary(@EMAIL_ID uniqueidentifier)
returns uniqueidentifier
as
  begin
	declare @CONTACT_ID uniqueidentifier;
	select top 1
	       @CONTACT_ID = CONTACT_ID 
	  from      EMAILS_CONTACTS
	 inner join CONTACTS
	         on CONTACTS.ID      = EMAILS_CONTACTS.CONTACT_ID
	        and CONTACTS.DELETED = 0
	 where EMAILS_CONTACTS.EMAIL_ID = @EMAIL_ID
	   and EMAILS_CONTACTS.DELETED = 0
	 order by rtrim(isnull(CONTACTS.LAST_NAME, N'') + N', ' + isnull(CONTACTS.FIRST_NAME, N''));
	return @CONTACT_ID;
  end
GO

Grant Execute on dbo.fnEMAILS_CONTACTS_Primary to public
GO

