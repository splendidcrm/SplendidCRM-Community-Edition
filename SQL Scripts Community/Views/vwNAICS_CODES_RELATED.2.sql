if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwNAICS_CODES_RELATED')
	Drop View dbo.vwNAICS_CODES_RELATED;
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
Create View dbo.vwNAICS_CODES_RELATED
as
select NAICS_CODES_RELATED.PARENT_ID      as PARENT_ID
     , NAICS_CODES_RELATED.NAICS_CODE_ID  as NAICS_CODE_ID
     , NAICS_CODES.NAME                  as NAICS_CODE_NAME
  from      NAICS_CODES_RELATED
 inner join NAICS_CODES
         on NAICS_CODES.ID      = NAICS_CODES_RELATED.NAICS_CODE_ID
        and NAICS_CODES.DELETED = 0
 where NAICS_CODES_RELATED.DELETED = 0

GO

Grant Select on dbo.vwNAICS_CODES_RELATED to public;
GO

