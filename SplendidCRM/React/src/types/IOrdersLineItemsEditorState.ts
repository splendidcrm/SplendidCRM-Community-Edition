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

export default interface IOrdersLineItemsEditorState
{
	bEnableTaxLineItems?  : boolean;
	bEnableTaxShipping?   : boolean;
	bShowTax?             : boolean;
	bEnableSalesTax?      : boolean;
	bDisableExchangeRate? : boolean;
	oNumberFormat?        : any;

	CURRENCY_ID?          : string;
	// 11/12/2022 Paul.  We can't dynamically convert to a number as it will prevent editing. 
	EXCHANGE_RATE?        : string;
	TAXRATE_ID?           : string;
	SHIPPER_ID?           : string;

	CURRENCY_ID_LIST?     : any[];
	TAXRATE_ID_LIST?      : any[];
	SHIPPER_ID_LIST?      : any[];

	SUBTOTAL?             : number;
	DISCOUNT?             : number;
	// 11/12/2022 Paul.  We can't dynamically convert to a number as it will prevent editing. 
	SHIPPING?             : string;
	TAX?                  : number;
	TOTAL?                : number;
}

