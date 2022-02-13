if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMPLOYEES_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMPLOYEES_Update;
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
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
Create Procedure dbo.spEMPLOYEES_Update
	( @ID                     uniqueidentifier output
	, @MODIFIED_USER_ID       uniqueidentifier
	, @FIRST_NAME             nvarchar(30)
	, @LAST_NAME              nvarchar(30)
	, @REPORTS_TO_ID          uniqueidentifier
	, @DESCRIPTION            nvarchar(max)
	, @TITLE                  nvarchar(50)
	, @DEPARTMENT             nvarchar(50)
	, @PHONE_HOME             nvarchar(50)
	, @PHONE_MOBILE           nvarchar(50)
	, @PHONE_WORK             nvarchar(50)
	, @PHONE_OTHER            nvarchar(50)
	, @PHONE_FAX              nvarchar(50)
	, @EMAIL1                 nvarchar(100)
	, @EMAIL2                 nvarchar(100)
	, @ADDRESS_STREET         nvarchar(150)
	, @ADDRESS_CITY           nvarchar(100)
	, @ADDRESS_STATE          nvarchar(100)
	, @ADDRESS_POSTALCODE     nvarchar(9)
	, @ADDRESS_COUNTRY        nvarchar(25)
	, @EMPLOYEE_STATUS        nvarchar(25)
	, @MESSENGER_ID           nvarchar(25)
	, @MESSENGER_TYPE         nvarchar(25)
	)
as
  begin
	set nocount on
	
	-- 11/24/2017 Paul.  Provide a way to format phone numbers.  
	declare @TEMP_PHONE_HOME      nvarchar(25);
	declare @TEMP_PHONE_MOBILE    nvarchar(25);
	declare @TEMP_PHONE_WORK      nvarchar(25);
	declare @TEMP_PHONE_OTHER     nvarchar(25);
	declare @TEMP_PHONE_FAX       nvarchar(25);
	set @TEMP_PHONE_HOME      = dbo.fnFormatPhone(@PHONE_HOME  );
	set @TEMP_PHONE_MOBILE    = dbo.fnFormatPhone(@PHONE_MOBILE);
	set @TEMP_PHONE_WORK      = dbo.fnFormatPhone(@PHONE_WORK  );
	set @TEMP_PHONE_OTHER     = dbo.fnFormatPhone(@PHONE_OTHER );
	set @TEMP_PHONE_FAX       = dbo.fnFormatPhone(@PHONE_FAX   );
	if not exists(select * from USERS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into USERS
			( ID                    
			, CREATED_BY            
			, DATE_ENTERED          
			, MODIFIED_USER_ID      
			, DATE_MODIFIED         
			, FIRST_NAME            
			, LAST_NAME             
			, REPORTS_TO_ID         
			, DESCRIPTION           
			, TITLE                 
			, DEPARTMENT            
			, PHONE_HOME            
			, PHONE_MOBILE          
			, PHONE_WORK            
			, PHONE_OTHER           
			, PHONE_FAX             
			, EMAIL1                
			, EMAIL2                
			, ADDRESS_STREET        
			, ADDRESS_CITY          
			, ADDRESS_STATE         
			, ADDRESS_COUNTRY       
			, ADDRESS_POSTALCODE    
			, EMPLOYEE_STATUS       
			, MESSENGER_ID          
			, MESSENGER_TYPE        
			)
		values
			( @ID                    
			, @MODIFIED_USER_ID      
			,  getdate()             
			, @MODIFIED_USER_ID      
			,  getdate()             
			, @FIRST_NAME            
			, @LAST_NAME             
			, @REPORTS_TO_ID         
			, @DESCRIPTION           
			, @TITLE                 
			, @DEPARTMENT            
			, @TEMP_PHONE_HOME       
			, @TEMP_PHONE_MOBILE     
			, @TEMP_PHONE_WORK       
			, @TEMP_PHONE_OTHER      
			, @TEMP_PHONE_FAX        
			, @EMAIL1                
			, @EMAIL2                
			, @ADDRESS_STREET        
			, @ADDRESS_CITY          
			, @ADDRESS_STATE         
			, @ADDRESS_COUNTRY       
			, @ADDRESS_POSTALCODE    
			, @EMPLOYEE_STATUS       
			, @MESSENGER_ID          
			, @MESSENGER_TYPE        
			);
	end else begin
		update USERS
		   set MODIFIED_USER_ID       = @MODIFIED_USER_ID      
		     , DATE_MODIFIED          =  getdate()             
		     , DATE_MODIFIED_UTC      =  getutcdate()          
		     , FIRST_NAME             = @FIRST_NAME            
		     , LAST_NAME              = @LAST_NAME             
		     , REPORTS_TO_ID          = @REPORTS_TO_ID         
		     , DESCRIPTION            = @DESCRIPTION           
		     , TITLE                  = @TITLE                 
		     , DEPARTMENT             = @DEPARTMENT            
		     , PHONE_HOME             = @TEMP_PHONE_HOME       
		     , PHONE_MOBILE           = @TEMP_PHONE_MOBILE     
		     , PHONE_WORK             = @TEMP_PHONE_WORK       
		     , PHONE_OTHER            = @TEMP_PHONE_OTHER      
		     , PHONE_FAX              = @TEMP_PHONE_FAX        
		     , EMAIL1                 = @EMAIL1                
		     , EMAIL2                 = @EMAIL2                
		     , ADDRESS_STREET         = @ADDRESS_STREET        
		     , ADDRESS_CITY           = @ADDRESS_CITY          
		     , ADDRESS_STATE          = @ADDRESS_STATE         
		     , ADDRESS_COUNTRY        = @ADDRESS_COUNTRY       
		     , ADDRESS_POSTALCODE     = @ADDRESS_POSTALCODE    
		     , EMPLOYEE_STATUS        = @EMPLOYEE_STATUS       
		     , MESSENGER_ID           = @MESSENGER_ID          
		     , MESSENGER_TYPE         = @MESSENGER_TYPE        
		 where ID                     = @ID                    ;
	end -- if;

	-- 04/21/2006 Paul.  Create the custom record if it does not exist. 
	-- This is necessary to compensate for spUSERS_InserNTLM not previous adding a custom record. 
	if not exists(select * from USERS_CSTM where ID_C = @ID) begin -- then
		insert into USERS_CSTM ( ID_C ) values ( @ID );
	end -- if;
  end
GO

Grant Execute on dbo.spEMPLOYEES_Update to public;
GO

