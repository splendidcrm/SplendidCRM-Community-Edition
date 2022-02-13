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
-- 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
if not exists (select * from LEADS_OPPORTUNITIES) begin -- then
	if exists (select * from LEADS where OPPORTUNITY_ID is not null and DELETED = 0) begin -- then
		insert into LEADS_OPPORTUNITIES
			( CREATED_BY
			, MODIFIED_USER_ID
			, DATE_MODIFIED
			, DATE_MODIFIED_UTC
			, LEAD_ID
			, OPPORTUNITY_ID
			)
		select MODIFIED_USER_ID
		     , MODIFIED_USER_ID
		     , DATE_MODIFIED
		     , getutcdate()
		     , ID
		     , OPPORTUNITY_ID
		  from LEADS
		 where OPPORTUNITY_ID is not null
		   and DELETED = 0;
	end -- if;
end -- if;
GO


