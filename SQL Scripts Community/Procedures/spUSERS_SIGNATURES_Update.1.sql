if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_SIGNATURES_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_SIGNATURES_Update;
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
-- 09/10/2012 Paul.  Add PRIMARY_SIGNATURE. 
Create Procedure dbo.spUSERS_SIGNATURES_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @USER_ID           uniqueidentifier
	, @NAME              nvarchar(255)
	, @SIGNATURE         nvarchar(max)
	, @SIGNATURE_HTML    nvarchar(max)
	, @PRIMARY_SIGNATURE bit
	)
as
  begin
	set nocount on

	declare @TEMP_PRIMARY_SIGNATURE bit;
	set @TEMP_PRIMARY_SIGNATURE = @PRIMARY_SIGNATURE;
	-- 09/10/2012 Paul.  If there are no existing signatures, then make this the primary. 
	if not exists(select * from USERS_SIGNATURES where USER_ID = @USER_ID and DELETED = 0) begin -- then
		set @TEMP_PRIMARY_SIGNATURE = 1;
	end -- if;

	if not exists(select * from USERS_SIGNATURES where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into USERS_SIGNATURES
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, USER_ID          
			, NAME             
			, SIGNATURE        
			, SIGNATURE_HTML   
			, PRIMARY_SIGNATURE
			)
		values 	( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @USER_ID          
			, @NAME             
			, @SIGNATURE        
			, @SIGNATURE_HTML   
			, @TEMP_PRIMARY_SIGNATURE
			);
	end else begin
		update USERS_SIGNATURES
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , USER_ID           = @USER_ID          
		     , NAME              = @NAME             
		     , SIGNATURE         = @SIGNATURE        
		     , SIGNATURE_HTML    = @SIGNATURE_HTML   
		     , PRIMARY_SIGNATURE = @TEMP_PRIMARY_SIGNATURE
		 where ID                = @ID               ;
	end -- if;

	-- 09/10/2012 Paul.  If this signature is primary, then all others are not. 
	if @PRIMARY_SIGNATURE = 1 begin -- then
		update USERS_SIGNATURES
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID
		     , DATE_MODIFIED     =  getdate()
		     , DATE_MODIFIED_UTC =  getutcdate()
		     , PRIMARY_SIGNATURE =  0
		 where USER_ID           = @USER_ID
		   and ID                <> @ID    ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spUSERS_SIGNATURES_Update to public;
GO

