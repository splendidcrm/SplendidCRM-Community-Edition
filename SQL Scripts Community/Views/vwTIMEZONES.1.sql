if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwTIMEZONES')
	Drop View dbo.vwTIMEZONES;
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
-- 01/02/2012 Paul.  Add iCal TZID. 
-- 03/26/2013 Paul.  iCloud uses linked_timezone values from http://tzinfo.rubyforge.org/doc/. 
Create View dbo.vwTIMEZONES
as
select ID                   
     , NAME                 
     , STANDARD_NAME        
     , STANDARD_ABBREVIATION
     , DAYLIGHT_NAME        
     , DAYLIGHT_ABBREVIATION
     , BIAS                 
     , STANDARD_BIAS        
     , DAYLIGHT_BIAS        
     , STANDARD_YEAR        
     , STANDARD_MONTH       
     , STANDARD_WEEK        
     , STANDARD_DAYOFWEEK   
     , STANDARD_HOUR        
     , STANDARD_MINUTE      
     , DAYLIGHT_YEAR        
     , DAYLIGHT_MONTH       
     , DAYLIGHT_WEEK        
     , DAYLIGHT_DAYOFWEEK   
     , DAYLIGHT_HOUR        
     , DAYLIGHT_MINUTE      
     , TZID
     , LINKED_TIMEZONE
  from TIMEZONES
 where DELETED = 0

GO

Grant Select on dbo.vwTIMEZONES to public;
GO

