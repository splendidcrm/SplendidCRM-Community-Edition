if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACCOUNTS_CONTACTS_CopyAddress' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACCOUNTS_CONTACTS_CopyAddress;
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
Create Procedure dbo.spACCOUNTS_CONTACTS_CopyAddress
	( @ID_LIST          varchar(8000)
	, @MODIFIED_USER_ID uniqueidentifier
	, @ACCOUNT_ID       uniqueidentifier
	, @ADDRESS_TYPE     nvarchar(25)
	)
as
  begin
	set nocount on
	
	declare @ID                 uniqueidentifier;
	declare @CurrentPosR        int;
	declare @NextPosR           int;
	declare @ADDRESS_STREET     nvarchar(150);
	declare @ADDRESS_CITY       nvarchar(100);
	declare @ADDRESS_STATE      nvarchar(100);
	declare @ADDRESS_POSTALCODE nvarchar( 20);
	declare @ADDRESS_COUNTRY    nvarchar(100);

	-- BEGIN Oracle Exception
		if @ADDRESS_TYPE = N'Shipping' begin -- then
			select @ADDRESS_STREET     = SHIPPING_ADDRESS_STREET
			     , @ADDRESS_CITY       = SHIPPING_ADDRESS_CITY
			     , @ADDRESS_STATE      = SHIPPING_ADDRESS_STATE
			     , @ADDRESS_POSTALCODE = SHIPPING_ADDRESS_POSTALCODE
			     , @ADDRESS_COUNTRY    = SHIPPING_ADDRESS_COUNTRY
			  from vwACCOUNTS
			 where ID                  = @ACCOUNT_ID;
		end else begin
			select @ADDRESS_STREET     = BILLING_ADDRESS_STREET
			     , @ADDRESS_CITY       = BILLING_ADDRESS_CITY
			     , @ADDRESS_STATE      = BILLING_ADDRESS_STATE
			     , @ADDRESS_POSTALCODE = BILLING_ADDRESS_POSTALCODE
			     , @ADDRESS_COUNTRY    = BILLING_ADDRESS_COUNTRY
			  from vwACCOUNTS
			 where ID                  = @ACCOUNT_ID;
		end -- if;
	-- END Oracle Exception

	set @CurrentPosR = 1;
	while @CurrentPosR <= len(@ID_LIST) begin -- do
		-- 10/04/2006 Paul.  charindex should not use unicode parameters as it will limit all inputs to 4000 characters. 
		set @NextPosR = charindex(',', @ID_LIST,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@ID_LIST) + 1;
		end -- if;
		set @ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
		set @CurrentPosR = @NextPosR+1;
		if @ADDRESS_TYPE = N'Shipping' begin -- then
			update CONTACTS
			   set MODIFIED_USER_ID            = @MODIFIED_USER_ID  
			     , DATE_MODIFIED               =  getdate()         
			     , DATE_MODIFIED_UTC           =  getutcdate()      
			     , ALT_ADDRESS_STREET          = @ADDRESS_STREET    
			     , ALT_ADDRESS_CITY            = @ADDRESS_CITY      
			     , ALT_ADDRESS_STATE           = @ADDRESS_STATE     
			     , ALT_ADDRESS_POSTALCODE      = @ADDRESS_POSTALCODE
			     , ALT_ADDRESS_COUNTRY         = @ADDRESS_COUNTRY   
			 where ID                          = @ID                
			   and DELETED                     = 0                  ;
		end else begin
			update CONTACTS
			   set MODIFIED_USER_ID            = @MODIFIED_USER_ID  
			     , DATE_MODIFIED               =  getdate()         
			     , DATE_MODIFIED_UTC           =  getutcdate()      
			     , PRIMARY_ADDRESS_STREET      = @ADDRESS_STREET    
			     , PRIMARY_ADDRESS_CITY        = @ADDRESS_CITY      
			     , PRIMARY_ADDRESS_STATE       = @ADDRESS_STATE     
			     , PRIMARY_ADDRESS_POSTALCODE  = @ADDRESS_POSTALCODE
			     , PRIMARY_ADDRESS_COUNTRY     = @ADDRESS_COUNTRY   
			 where ID                          = @ID                
			   and DELETED                     = 0                  ;
		end -- if;
	end -- while;
  end
GO
 
Grant Execute on dbo.spACCOUNTS_CONTACTS_CopyAddress to public;
GO

