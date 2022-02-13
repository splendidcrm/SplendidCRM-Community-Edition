if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnTHREADS_Last' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnTHREADS_Last;
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
Create Function dbo.fnTHREADS_Last(@FORUM_ID uniqueidentifier)
returns uniqueidentifier
as
  begin
	declare @THREAD_ID uniqueidentifier;
	select top 1
	       @THREAD_ID = ID 
	  from THREADS
	 where FORUM_ID = @FORUM_ID
	   and DELETED = 0
	 order by DATE_ENTERED;
	return @THREAD_ID;
  end
GO

Grant Execute on dbo.fnTHREADS_Last to public
GO

