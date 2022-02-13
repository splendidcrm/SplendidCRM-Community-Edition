if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPROSPECT_LISTS_SQL_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPROSPECT_LISTS_SQL_Update;
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
-- 01/14/2010 Paul.  The @ID will not be an output parameter as it will match the PROSPECT_LISTS table. 
Create Procedure dbo.spPROSPECT_LISTS_SQL_Update
	( @ID                uniqueidentifier
	, @MODIFIED_USER_ID  uniqueidentifier
	, @DYNAMIC_SQL       nvarchar(max)
	, @DYNAMIC_RDL       nvarchar(max)
	)
as
  begin
	set nocount on

	-- 01/14/2010 Paul.  The Primary Key will match the PROSPECT_LISTS table. 
	if not exists(select * from PROSPECT_LISTS_SQL where ID = @ID) begin -- then
		insert into PROSPECT_LISTS_SQL
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, DATE_MODIFIED_UTC
			, DYNAMIC_SQL      
			, DYNAMIC_RDL      
			)
		values 	( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			,  getutcdate()     
			, @DYNAMIC_SQL      
			, @DYNAMIC_RDL      
			);
	end else begin
		update PROSPECT_LISTS_SQL
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , DYNAMIC_SQL       = @DYNAMIC_SQL      
		     , DYNAMIC_RDL       = @DYNAMIC_RDL      
		 where ID                = @ID               ;
	end -- if;
  end
GO

Grant Execute on dbo.spPROSPECT_LISTS_SQL_Update to public;
GO

