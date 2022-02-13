if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spOPPORTUNITIES_New' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spOPPORTUNITIES_New;
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
-- 01/01/2008 Paul.  Automatically apply the assigned user. 
-- 06/20/2009 Paul.  We need to get and assign the default team otherwise the new record 
-- will not be displayed if the Team Required flag is set. 
-- 11/28/2009 Paul.  Add UTC date. 
-- 01/14/2010 Paul.  Add support for Team Sets. 
-- 10/05/2010 Paul.  Increase the size of the NAME field. 
-- 01/16/2012 Paul.  Assigned User ID and Team ID are now parameters. 
-- 05/01/2013 Paul.  Add Contacts field to support B2C. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spOPPORTUNITIES_New
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ACCOUNT_ID        uniqueidentifier
	, @NAME              nvarchar(150)
	, @AMOUNT            money
	, @CURRENCY_ID       uniqueidentifier
	, @DATE_CLOSED       datetime
	, @SALES_STAGE       nvarchar(25)
	, @ASSIGNED_USER_ID  uniqueidentifier = null
	, @TEAM_ID           uniqueidentifier = null
	, @TEAM_SET_LIST     varchar(8000) = null
	, @B2C_CONTACT_ID    uniqueidentifier = null
	, @ASSIGNED_SET_LIST varchar(8000) = null
	)
as
  begin
	set nocount on
	
	declare @TEAM_SET_ID         uniqueidentifier;
	declare @ASSIGNED_SET_ID     uniqueidentifier;
	-- 09/19/2005 Paul.  Convert currency to USD. 
	declare @AMOUNT_USDOLLAR     money;

	-- 01/16/2012 Paul.  Normalize the team set by placing the primary ID first, then order list by ID and the name by team names. 
	-- 01/16/2012 Paul.  Use a team set so that team name changes can propagate. 
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;

	set @AMOUNT_USDOLLAR = @AMOUNT;
	-- BEGIN Oracle Exception
		select @AMOUNT_USDOLLAR = @AMOUNT / CONVERSION_RATE
		  from CURRENCIES
		 where ID = @CURRENCY_ID;
	-- END Oracle Exception
	

	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
	end -- if;
	insert into OPPORTUNITIES
		( ID               
		, CREATED_BY       
		, DATE_ENTERED     
		, MODIFIED_USER_ID 
		, DATE_MODIFIED    
		, DATE_MODIFIED_UTC
		, ASSIGNED_USER_ID 
		, NAME             
		, AMOUNT           
		, AMOUNT_USDOLLAR  
		, CURRENCY_ID      
		, DATE_CLOSED      
		, SALES_STAGE      
		, TEAM_ID          
		, TEAM_SET_ID      
		, B2C_CONTACT_ID   
		, ASSIGNED_SET_ID  
		)
	values
		( @ID               
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @MODIFIED_USER_ID 
		,  getutcdate()     
		,  getdate()        
		, @ASSIGNED_USER_ID 
		, @NAME             
		, @AMOUNT           
		, @AMOUNT_USDOLLAR  
		, @CURRENCY_ID      
		, @DATE_CLOSED      
		, @SALES_STAGE      
		, @TEAM_ID          
		, @TEAM_SET_ID      
		, @B2C_CONTACT_ID   
		, @ASSIGNED_SET_ID  
		);

	-- 03/04/2006 Paul.  Add record to custom table. 
	if not exists(select * from OPPORTUNITIES_CSTM where ID_C = @ID) begin -- then
		insert into OPPORTUNITIES_CSTM ( ID_C ) values ( @ID );
	end -- if;

	-- Assign any new account. 
	if dbo.fnIsEmptyGuid(@ACCOUNT_ID) = 0 begin -- then
		exec dbo.spACCOUNTS_OPPORTUNITIES_Update @MODIFIED_USER_ID, @ACCOUNT_ID, @ID;
	end -- if;

  end
GO

Grant Execute on dbo.spOPPORTUNITIES_New to public;
GO

