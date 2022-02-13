/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 1. React and fabric. 
// 2. Store and Types. 
// 3. Scripts. 
import Sql    from './Sql';

// 02/21/2021 Paul.  DiscountPrice() will return dDISCOUNT_PRICE unmodified if formula is blank or fixed. 
export function DiscountPrice(sPRICING_FORMULA: string, fPRICING_FACTOR: number, dCOST_PRICE: number, dLIST_PRICE: number, dDISCOUNT_PRICE: number)
{
	if ( fPRICING_FACTOR > 0 )
	{
		switch ( sPRICING_FORMULA )
		{
			case "Fixed"             :
				break;
			case "ProfitMargin"      :
				dDISCOUNT_PRICE = dCOST_PRICE * 100 / (100 - fPRICING_FACTOR);
				break;
			case "PercentageMarkup"  :
				dDISCOUNT_PRICE = dCOST_PRICE * (1 + (fPRICING_FACTOR /100));
				break;
			case "PercentageDiscount":
				dDISCOUNT_PRICE = (dLIST_PRICE * (1 - (fPRICING_FACTOR /100))*100)/100;
				break;
			case "FixedDiscount":
				dDISCOUNT_PRICE = dLIST_PRICE - fPRICING_FACTOR;
				break;
			case "IsList"            :
				dDISCOUNT_PRICE = dLIST_PRICE;
				break;
		}
	}
	return dDISCOUNT_PRICE;
}

export function DiscountValue(sPRICING_FORMULA, fPRICING_FACTOR, dLIST_PRICE)
{
	let dDISCOUNT_VALUE = 0.0;
	if ( fPRICING_FACTOR > 0 )
	{
		switch ( sPRICING_FORMULA )
		{
			case 'PercentageDiscount':
				dDISCOUNT_VALUE = (dLIST_PRICE * (Sql.ToDecimal(fPRICING_FACTOR) /100)*100)/100;
				break;
			case 'FixedDiscount'     :
				dDISCOUNT_VALUE = Sql.ToDecimal(fPRICING_FACTOR);
				break;
		}
	}
	return dDISCOUNT_VALUE;
}

