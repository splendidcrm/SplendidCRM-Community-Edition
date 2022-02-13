if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTIMEZONES_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTIMEZONES_InsertOnly;
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
Create Procedure dbo.spTIMEZONES_InsertOnly
	( @ID                     uniqueidentifier
	, @MODIFIED_USER_ID       uniqueidentifier
	, @NAME                   nvarchar(100)
	, @STANDARD_NAME          nvarchar(100)
	, @STANDARD_ABBREVIATION  nvarchar(10)
	, @DAYLIGHT_NAME          nvarchar(100)
	, @DAYLIGHT_ABBREVIATION  nvarchar(10)
	, @BIAS                   int
	, @STANDARD_BIAS          int
	, @DAYLIGHT_BIAS          int
	, @STANDARD_YEAR          int
	, @STANDARD_MONTH         int
	, @STANDARD_WEEK          int
	, @STANDARD_DAYOFWEEK     int
	, @STANDARD_HOUR          int
	, @STANDARD_MINUTE        int
	, @DAYLIGHT_YEAR          int
	, @DAYLIGHT_MONTH         int
	, @DAYLIGHT_WEEK          int
	, @DAYLIGHT_DAYOFWEEK     int
	, @DAYLIGHT_HOUR          int
	, @DAYLIGHT_MINUTE        int
	, @TZID                   nvarchar(50) = null
	, @LINKED_TIMEZONE        nvarchar(50) = null
	)
as
  begin
	set nocount on
	
	if not exists(select * from TIMEZONES where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into TIMEZONES
			( ID                    
			, CREATED_BY            
			, DATE_ENTERED          
			, MODIFIED_USER_ID      
			, DATE_MODIFIED         
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
			)
		values
			( @ID                    
			, @MODIFIED_USER_ID      
			,  getdate()             
			, @MODIFIED_USER_ID      
			,  getdate()             
			, @NAME                  
			, @STANDARD_NAME         
			, @STANDARD_ABBREVIATION 
			, @DAYLIGHT_NAME         
			, @DAYLIGHT_ABBREVIATION 
			, @BIAS                  
			, @STANDARD_BIAS         
			, @DAYLIGHT_BIAS         
			, @STANDARD_YEAR         
			, @STANDARD_MONTH        
			, @STANDARD_WEEK         
			, @STANDARD_DAYOFWEEK    
			, @STANDARD_HOUR         
			, @STANDARD_MINUTE       
			, @DAYLIGHT_YEAR         
			, @DAYLIGHT_MONTH        
			, @DAYLIGHT_WEEK         
			, @DAYLIGHT_DAYOFWEEK    
			, @DAYLIGHT_HOUR         
			, @DAYLIGHT_MINUTE       
			, @TZID                  
			, @LINKED_TIMEZONE       
			);
	end else begin
		-- 01/01/2012 Paul.  We want to use the same InsertOnly data to update the TZID. 
		update TIMEZONES
		   set MODIFIED_USER_ID       = @MODIFIED_USER_ID      
		     , DATE_MODIFIED          =  getdate()             
		     , DATE_MODIFIED_UTC      =  getutcdate()          
		     , TZID                   = @TZID                  
		     , LINKED_TIMEZONE        = @LINKED_TIMEZONE       
		 where ID                     = @ID                    
		   and (   TZID            is null and @TZID            is not null
		        or LINKED_TIMEZONE is null and @LINKED_TIMEZONE is not null
		       );
	end -- if;
  end
GO
 
Grant Execute on dbo.spTIMEZONES_InsertOnly to public;
GO
 
