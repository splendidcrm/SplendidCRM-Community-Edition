if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTIMEZONES_UpdateByName' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTIMEZONES_UpdateByName;
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
-- 02/22/2007 Paul.  Only update timezone data if it has changed. This is so that we can verify the expected changes. 
-- 04/08/2010 Paul.  Only update the abbreviation if it is provided. 
Create Procedure dbo.spTIMEZONES_UpdateByName
	( @MODIFIED_USER_ID       uniqueidentifier
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
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from TIMEZONES
		 where NAME    = @NAME
		   and DELETED = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		print N'Inserting Time Zone: ' + @NAME;
		set @ID = newid();
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
			);
	end else begin
		set @ID = null;
		-- BEGIN Oracle Exception
			select @ID = ID
			  from TIMEZONES
			 where NAME    = @NAME
			   and DELETED = 0
			   and (   1 = 0
			        or STANDARD_NAME          <> @STANDARD_NAME          
			--        or STANDARD_ABBREVIATION  <> @STANDARD_ABBREVIATION  
			        or DAYLIGHT_NAME          <> @DAYLIGHT_NAME          
			--        or DAYLIGHT_ABBREVIATION  <> @DAYLIGHT_ABBREVIATION  
			        or BIAS                   <> @BIAS                   
			        or STANDARD_BIAS          <> @STANDARD_BIAS          
			        or DAYLIGHT_BIAS          <> @DAYLIGHT_BIAS          
			        or STANDARD_YEAR          <> @STANDARD_YEAR          
			        or STANDARD_MONTH         <> @STANDARD_MONTH         
			        or STANDARD_WEEK          <> @STANDARD_WEEK          
			        or STANDARD_DAYOFWEEK     <> @STANDARD_DAYOFWEEK     
			        or STANDARD_HOUR          <> @STANDARD_HOUR          
			        or STANDARD_MINUTE        <> @STANDARD_MINUTE        
			        or DAYLIGHT_YEAR          <> @DAYLIGHT_YEAR          
			        or DAYLIGHT_MONTH         <> @DAYLIGHT_MONTH         
			        or DAYLIGHT_WEEK          <> @DAYLIGHT_WEEK          
			        or DAYLIGHT_DAYOFWEEK     <> @DAYLIGHT_DAYOFWEEK     
			        or DAYLIGHT_HOUR          <> @DAYLIGHT_HOUR          
			        or DAYLIGHT_MINUTE        <> @DAYLIGHT_MINUTE        
			       );
		-- END Oracle Exception
		if dbo.fnIsEmptyGuid(@ID) = 0 begin -- then
			print N'Updating Time Zone: ' + @NAME;
			-- 04/08/2010 Paul.  Only update the abbreviation if it is provided. 
			update TIMEZONES
			   set MODIFIED_USER_ID       = @MODIFIED_USER_ID      
			     , DATE_MODIFIED          =  getdate()             
			     , DATE_MODIFIED_UTC      =  getutcdate()          
	--		     , NAME                   = @NAME                  
			     , STANDARD_NAME          = @STANDARD_NAME         
			     , STANDARD_ABBREVIATION  = isnull(@STANDARD_ABBREVIATION, STANDARD_ABBREVIATION)
			     , DAYLIGHT_NAME          = @DAYLIGHT_NAME         
			     , DAYLIGHT_ABBREVIATION  = isnull(@DAYLIGHT_ABBREVIATION, DAYLIGHT_ABBREVIATION)
			     , BIAS                   = @BIAS                  
			     , STANDARD_BIAS          = @STANDARD_BIAS         
			     , DAYLIGHT_BIAS          = @DAYLIGHT_BIAS         
			     , STANDARD_YEAR          = @STANDARD_YEAR         
			     , STANDARD_MONTH         = @STANDARD_MONTH        
			     , STANDARD_WEEK          = @STANDARD_WEEK         
			     , STANDARD_DAYOFWEEK     = @STANDARD_DAYOFWEEK    
			     , STANDARD_HOUR          = @STANDARD_HOUR         
			     , STANDARD_MINUTE        = @STANDARD_MINUTE       
			     , DAYLIGHT_YEAR          = @DAYLIGHT_YEAR         
			     , DAYLIGHT_MONTH         = @DAYLIGHT_MONTH        
			     , DAYLIGHT_WEEK          = @DAYLIGHT_WEEK         
			     , DAYLIGHT_DAYOFWEEK     = @DAYLIGHT_DAYOFWEEK    
			     , DAYLIGHT_HOUR          = @DAYLIGHT_HOUR         
			     , DAYLIGHT_MINUTE        = @DAYLIGHT_MINUTE       
			 where ID                     = @ID                    ;
		end -- if;
	end -- if;
  end
GO
 
Grant Execute on dbo.spTIMEZONES_UpdateByName to public;
GO
 
