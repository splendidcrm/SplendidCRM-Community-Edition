if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCURRENCIES_UpdateRateByISO' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCURRENCIES_UpdateRateByISO;
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
Create Procedure dbo.spCURRENCIES_UpdateRateByISO
	( @MODIFIED_USER_ID       uniqueidentifier
	, @ISO4217                nvarchar(3)
	, @CONVERSION_RATE        float(53)
	, @SYSTEM_CURRENCY_LOG_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	if exists(select * from CURRENCIES where DELETED = 0 and ISO4217 = @ISO4217 and CONVERSION_RATE <> @CONVERSION_RATE) begin -- then
		update CURRENCIES
		   set MODIFIED_USER_ID       = @MODIFIED_USER_ID      
		     , DATE_MODIFIED          =  getdate()             
		     , DATE_MODIFIED_UTC      =  getutcdate()          
		     , CONVERSION_RATE        = @CONVERSION_RATE       
		     , SYSTEM_CURRENCY_LOG_ID = @SYSTEM_CURRENCY_LOG_ID
		 where ISO4217                = @ISO4217               ;
	end -- if;
  end
GO

Grant Execute on dbo.spCURRENCIES_UpdateRateByISO to public;
GO

