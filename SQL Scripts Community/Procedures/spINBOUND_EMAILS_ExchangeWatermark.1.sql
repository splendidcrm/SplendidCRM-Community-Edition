if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spINBOUND_EMAILS_ExchangeWatermark' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spINBOUND_EMAILS_ExchangeWatermark;
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
-- 01/28/2017 Paul.  EXCHANGE_WATERMARK for support of Exchange and Office365.
-- 07/19/2023 Paul.  Increase size of EXCHANGE_WATERMARK to 1000.  Badly formed token. 
Create Procedure dbo.spINBOUND_EMAILS_ExchangeWatermark
	( @ID                 uniqueidentifier
	, @MODIFIED_USER_ID   uniqueidentifier
	, @EXCHANGE_WATERMARK varchar(1000)
	)
as
  begin
	set nocount on

	update INBOUND_EMAILS
	   set MODIFIED_USER_ID   = @MODIFIED_USER_ID 
	     , DATE_MODIFIED      = getdate()         
	     , DATE_MODIFIED_UTC  = getutcdate()      
	     , EXCHANGE_WATERMARK = @EXCHANGE_WATERMARK   
	 where ID                 = @ID               
	   and DELETED            = 0;
  end
GO
 
Grant Execute on dbo.spINBOUND_EMAILS_ExchangeWatermark to public;
GO
 
