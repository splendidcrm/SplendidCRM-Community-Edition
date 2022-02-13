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
import Credentials                                     from '../scripts/Credentials'     ;

// 10/16/2021 Paul.  Add support for user currency. 
export default class C10n
{
		public static ToCurrency(f: number): number
		{
			// 05/10/2006 Paul.  Short-circuit the math if USD. 
			// This is more to prevent bugs than to speed calculations. 
			if ( Credentials.bUSER_CurrencyUSDollars || Credentials.dUSER_CurrencyCONVERSION_RATE <= 0 )
				return f;
			return f * Credentials.dUSER_CurrencyCONVERSION_RATE;
		}

		public static FromCurrency(f: number): number
		{
			// 05/10/2006 Paul.  Short-circuit the math if USD. 
			// This is more to prevent bugs than to speed calculations. 
			if ( Credentials.bUSER_CurrencyUSDollars || Credentials.dUSER_CurrencyCONVERSION_RATE <= 0 )
				return f;
			return f / Credentials.dUSER_CurrencyCONVERSION_RATE;
		}
}

