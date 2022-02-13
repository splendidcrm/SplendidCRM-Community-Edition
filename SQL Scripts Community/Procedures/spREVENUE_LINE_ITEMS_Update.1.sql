if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spREVENUE_LINE_ITEMS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spREVENUE_LINE_ITEMS_Update;
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
Create Procedure dbo.spREVENUE_LINE_ITEMS_Update
	( @ID                   uniqueidentifier output
	, @MODIFIED_USER_ID     uniqueidentifier
	, @OPPORTUNITY_ID       uniqueidentifier
	, @LINE_GROUP_ID        uniqueidentifier
	, @LINE_ITEM_TYPE       nvarchar(25)
	, @POSITION             int
	, @NAME                 nvarchar(150)
	, @MFT_PART_NUM         nvarchar(50)
	, @VENDOR_PART_NUM      nvarchar(50)
	, @PRODUCT_TEMPLATE_ID  uniqueidentifier
	, @TAX_CLASS            nvarchar(25)
	, @QUANTITY             float
	, @COST_PRICE           money
	, @LIST_PRICE           money
	, @UNIT_PRICE           money
	, @DESCRIPTION          nvarchar(max)
	, @PARENT_TEMPLATE_ID   uniqueidentifier
	, @DISCOUNT_ID          uniqueidentifier
	, @DISCOUNT_PRICE       money
	, @PRICING_FORMULA      nvarchar( 25)
	, @PRICING_FACTOR       float
	, @TAXRATE_ID           uniqueidentifier
	, @OPPORTUNITY_TYPE     nvarchar(255)
	, @LEAD_SOURCE          nvarchar(50)
	, @DATE_CLOSED          datetime
	, @NEXT_STEP            nvarchar(100)
	, @SALES_STAGE          nvarchar(25)
	, @PROBABILITY          float(53)
	)
as
  begin
	set nocount on
	
  end
GO

Grant Execute on dbo.spREVENUE_LINE_ITEMS_Update to public;
GO

