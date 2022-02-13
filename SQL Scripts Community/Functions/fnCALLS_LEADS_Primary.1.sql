if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnCALLS_LEADS_Primary' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnCALLS_LEADS_Primary;
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
Create Function dbo.fnCALLS_LEADS_Primary(@CALL_ID uniqueidentifier)
returns uniqueidentifier
as
  begin
	declare @LEAD_ID uniqueidentifier;
	select top 1
	       @LEAD_ID = LEAD_ID 
	  from      CALLS_LEADS
	 inner join LEADS
	         on LEADS.ID      = CALLS_LEADS.LEAD_ID
	        and LEADS.DELETED = 0
	 where CALLS_LEADS.CALL_ID = @CALL_ID
	   and CALLS_LEADS.DELETED = 0
	 order by rtrim(isnull(LEADS.LAST_NAME, N'') + N', ' + isnull(LEADS.FIRST_NAME, N''));
	return @LEAD_ID;
  end
GO

Grant Execute on dbo.fnCALLS_LEADS_Primary to public
GO

