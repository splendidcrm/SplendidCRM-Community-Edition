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
import * as React from 'react';
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'      ;
// 2. Store and Types. 
import IOrdersLineItemsEditorProps                  from './IOrdersLineItemsEditorProps'       ;
import IOrdersLineItemsEditorState                  from './IOrdersLineItemsEditorState'       ;
import EDITVIEWS_FIELD                              from './EDITVIEWS_FIELD'                   ;
import DETAILVIEWS_FIELD                            from '../types/DETAILVIEWS_FIELD'          ;
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'                      ;
import L10n                                         from '../scripts/L10n'                     ;
import Security                                     from '../scripts/Security'                 ;
import SplendidCache                                from '../scripts/SplendidCache'            ;
import { AutoComplete_ModuleMethod }                from '../scripts/ListView'                 ;
import { EditView_RemoveField }                     from '../scripts/EditView'                 ;
import { Crm_Config }                               from '../scripts/Crm'                      ;
import { formatDate, formatCurrency, formatNumber } from '../scripts/Formatting'               ;
import { ConvertEditViewFieldToDetailViewField  }   from '../scripts/ConvertLayoutField'       ;
import { DiscountPrice, DiscountValue }             from '../scripts/OrderUtils'               ;
// 4. Components and Views. 
import EditViewLineItems                            from '../views/EditViewLineItems'          ;

export default abstract class OrdersLineItemsEditor<P extends IOrdersLineItemsEditorProps, S extends IOrdersLineItemsEditorState> extends React.Component<P, S>
{
	protected lineItems = React.createRef<EditViewLineItems>();

	public abstract get data(): any;

	protected InitLayout(layout: EDITVIEWS_FIELD[])
	{
		const { row } = this.props;

		// 07/11/2010 Paul.  Options allow multi-select. 
		let bEnableOptions      : boolean = Crm_Config.ToBoolean('ProductCatalog.EnableOptions');
		// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
		// Place init code in InitializeComponent as it occurs before LoadLineItems. 
		let bEnableTaxLineItems : boolean = Crm_Config.ToBoolean('Orders.TaxLineItems'         );
		let bEnableTaxShipping  : boolean = Crm_Config.ToBoolean('Orders.TaxShipping'          );
		let bShowTax            : boolean = Crm_Config.ToBoolean('Orders.ShowTaxColumn'        );
		// 12/14/2013 Paul.  Move Show flags to config. 
		let bShowCostPrice      : boolean = Crm_Config.ToBoolean('Orders.ShowCostPriceColumn'  );
		let bShowListPrice      : boolean = Crm_Config.ToBoolean('Orders.ShowListPriceColumn'  );
		// 11/30/2015 Paul.  Allow Tax to be disabled and to hide MFT Part Number. 
		let bShowMftPartNum     : boolean = Crm_Config.ToBoolean('Orders.ShowMftPartNumColumn' );
		let bEnableSalesTax     : boolean = Crm_Config.ToBoolean('Orders.EnableSalesTax'       );
		// 04/14/2016 Paul.  Allow exchange rate to be hidden. 
		let bDisableExchangeRate: boolean = Crm_Config.ToBoolean('Orders.DisableExchangeRate'  );
		let oNumberFormat = Security.NumberFormatInfo();

		let CURRENCY_ID          : string = null;
		// 11/12/2022 Paul.  We can't dynamically convert to a number as it will prevent editing. 
		let EXCHANGE_RATE        : string = '1';
		let TAXRATE_ID           : string = null;
		let SHIPPER_ID           : string = null;
		let SUBTOTAL             : number = 0;
		let DISCOUNT             : number = 0;
		// 11/12/2022 Paul.  We can't dynamically convert to a number as it will prevent editing. 
		let SHIPPING             : string = '0';
		let TAX                  : number = 0;
		let TOTAL                : number = 0;
		if ( row != null )
		{
			CURRENCY_ID   = Sql.ToString (row['CURRENCY_ID'  ]);
			EXCHANGE_RATE = Sql.ToDecimal(row['EXCHANGE_RATE']).toString();
			TAXRATE_ID    = Sql.ToString (row['TAXRATE_ID'   ]);
			SHIPPER_ID    = Sql.ToString (row['SHIPPER_ID'   ]);
			SUBTOTAL      = Sql.ToDecimal(row['SUBTOTAL'     ]);
			DISCOUNT      = Sql.ToDecimal(row['DISCOUNT'     ]);
			SHIPPING      = formatNumber(Sql.ToDecimal(row['SHIPPING']), oNumberFormat);
			TAX           = Sql.ToDecimal(row['TAX'          ]);
			TOTAL         = Sql.ToDecimal(row['TOTAL'        ]);
		}
		if ( Sql.IsEmptyGuid(CURRENCY_ID) )
		{
			CURRENCY_ID = Crm_Config.ToString('default_currency');
		}

		let CURRENCY_ID_LIST     : any[] = [];
		let TAXRATE_ID_LIST      : any[] = [];
		let SHIPPER_ID_LIST      : any[] = [];
		let arrLIST: string[] = L10n.GetList('Currencies');
		for ( let i = 0; i < arrLIST.length; i++ )
		{
			let opt4 = { NAME: arrLIST[i], DISPLAY_NAME: L10n.ListTerm('Currencies', arrLIST[i]) };
			CURRENCY_ID_LIST.push(opt4);
		}
		arrLIST = L10n.GetList('TaxRates');
		let opt1 = { NAME: '', DISPLAY_NAME: L10n.Term('.LBL_NONE') };
		TAXRATE_ID_LIST.push(opt1);
		for ( let i = 0; i < arrLIST.length; i++ )
		{
			let opt4 = { NAME: arrLIST[i], DISPLAY_NAME: L10n.ListTerm('TaxRates', arrLIST[i]) };
			TAXRATE_ID_LIST.push(opt4);
		}
		arrLIST = L10n.GetList('Shippers');
		opt1 = { NAME: '', DISPLAY_NAME: L10n.Term('.LBL_NONE') };
		SHIPPER_ID_LIST.push(opt1);
		for ( let i = 0; i < arrLIST.length; i++ )
		{
			let opt4 = { NAME: arrLIST[i], DISPLAY_NAME: L10n.ListTerm('Shippers', arrLIST[i]) };
			SHIPPER_ID_LIST.push(opt4);
		}
		this.setState(
		{
			bEnableTaxLineItems  ,
			bEnableTaxShipping   ,
			bShowTax             ,
			bEnableSalesTax      ,
			bDisableExchangeRate ,
			oNumberFormat        ,
			CURRENCY_ID          ,
			EXCHANGE_RATE        ,
			TAXRATE_ID           ,
			SHIPPER_ID           ,
			CURRENCY_ID_LIST     ,
			TAXRATE_ID_LIST      ,
			SHIPPER_ID_LIST      ,
			SUBTOTAL             ,
			DISCOUNT             ,
			SHIPPING             ,
			TAX                  ,
			TOTAL                ,
		});

		if ( layout != null )
		{
			// 06/24/2020 Paul.  Hiding the layout item still allows the table cell to be created.  We need to remove from layout. 
			if ( !(bShowMftPartNum) )
			{
				EditView_RemoveField(layout, 'MFT_PART_NUM');
			}
			if ( !(bShowCostPrice) )
			{
				EditView_RemoveField(layout, 'COST_PRICE');
			}
			if ( !(bShowListPrice) )
			{
				EditView_RemoveField(layout, 'LIST_PRICE');
			}
			if ( !(bEnableSalesTax && !bEnableTaxLineItems) )
			{
				EditView_RemoveField(layout, 'TAX_CLASS');
			}
			if ( !(bEnableSalesTax && bEnableTaxLineItems) )
			{
				EditView_RemoveField(layout, 'TAXRATE_ID');
			}
			if ( !(bEnableSalesTax && bShowTax) )
			{
				EditView_RemoveField(layout, 'TAX');
			}
		}
	}

	protected FieldVisibility = (LINE_ITEM_TYPE: string, DATA_FIELD: string) =>
	{
		let bVisible = true;
		if ( LINE_ITEM_TYPE == 'Comment' )
		{
			bVisible = (DATA_FIELD == 'DESCRIPTION');
		}
		/*
		switch ( DATA_FIELD )
		{
			case 'QUANTITY'           :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'NAME'               :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'PRODUCT_TEMPLATE_ID':  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'SELECT_NAME'        :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'DESCRIPTION'        :  break;
			case 'MFT_PART_NUM'       :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'TAX_CLASS'          :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'TAXRATE_ID'         :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'TAX'                :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'COST_PRICE'         :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'LIST_PRICE'         :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'UNIT_PRICE'         :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'EXTENDED_PRICE'     :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'DISCOUNT_ID'        :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'DISCOUNT_NAME'      :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'DISCOUNT_PRICE'     :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'PRICING_FORMULA'    :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'PRICING_FACTOR'     :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'DATE_CLOSED'        :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'OPPORTUNITY_TYPE'   :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'LEAD_SOURCE'        :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'NEXT_STEP'          :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'SALES_STAGE'        :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'PROBABILITY'        :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
			case 'btnComment'         :  bVisible = (LINE_ITEM_TYPE != 'Comment');  break;
		}
		*/
		return bVisible;
	}

	protected ConvertField = (MODULE_NAME: string, edit: EDITVIEWS_FIELD): DETAILVIEWS_FIELD =>
	{
		let detail: DETAILVIEWS_FIELD = ConvertEditViewFieldToDetailViewField(MODULE_NAME, edit);
		let DATA_FIELD: string = edit.DATA_FIELD;
		switch ( DATA_FIELD )
		{
			case 'TAX'             :
			case 'COST_PRICE'      :
			case 'LIST_PRICE'      :
			case 'UNIT_PRICE'      :
			case 'EXTENDED_PRICE'  :
			case 'DISCOUNT_PRICE'  :
				detail.DATA_FORMAT = '{0:c}';
				break;
		}
		return detail;
	}

	protected _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE);
		if ( this.props.onChanged )
		{
			this.props.onChanged(DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE);
		}
		else
		{
		}
	}

	private UpdateItem = (item) =>
	{
		const { bEnableSalesTax, bEnableTaxLineItems } = this.state;
		try
		{
			if ( this.lineItems.current )
			{
				// 06/24/2020 Paul.  Edit a copy so that we can compare to original when we update. 
				let lineEdited: any = Object.assign({}, this.lineItems.current.LineEdited);
				if ( Sql.ToDecimal(lineEdited['QUANTITY']) == 0 )
				{
					lineEdited['QUANTITY'] = 1;
				}
				lineEdited['NAME'               ] = Sql.ToString (item.NAME        );
				lineEdited['PRODUCT_TEMPLATE_ID'] = Sql.ToString (item.ID          );
				lineEdited['DESCRIPTION'        ] = Sql.ToString (item.DESCRIPTION );
				lineEdited['MFT_PART_NUM'       ] = Sql.ToString (item.MFT_PART_NUM);
				// 06/30/2020 Paul.  Tax Class cannot be blank, though it is allowed to be blank in the admin Product Tempalte editor. 
				if ( !Sql.IsEmptyString(item.TAX_CLASS) )
					lineEdited['TAX_CLASS'          ] = Sql.ToString (item.TAX_CLASS   );
				lineEdited['TAXRATE_ID'         ] = Sql.ToGuid   (item.TAXRATE_ID  );
				lineEdited['COST_PRICE'         ] = Sql.ToDecimal(item.COST_PRICE  );
				lineEdited['LIST_PRICE'         ] = Sql.ToDecimal(item.LIST_PRICE  );
				lineEdited['UNIT_PRICE'         ] = Sql.ToDecimal(item.UNIT_PRICE  );
				lineEdited['COST_PRICE'         ] = Sql.ToDecimal(lineEdited['QUANTITY']) * Sql.ToDecimal(lineEdited['UNIT_PRICE']);
				if ( bEnableSalesTax )
				{
					// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
					if ( bEnableTaxLineItems )
					{
						lineEdited['TAX_CLASS'          ] = null;
					}
					else
					{
						lineEdited['TAXRATE_ID'         ] = null;
						lineEdited['TAX'                ] = 0;
					}
				}
				else
				{
					lineEdited['TAX_CLASS'          ] = null;
					lineEdited['TAXRATE_ID'         ] = null;
					lineEdited['TAX'                ] = 0;
				}
				// 02/10/2011 Paul.  Stop converting the Quantity to an integer. 
				lineEdited['EXTENDED_PRICE'     ] = Sql.ToDecimal(lineEdited['QUANTITY']) * Sql.ToDecimal(lineEdited['UNIT_PRICE']);
				if ( !Sql.IsEmptyGuid(lineEdited['DISCOUNT_ID']) )
				{
					this.UpdateDiscount(lineEdited, lineEdited['DISCOUNT_ID'], false);
				}
				if ( !Sql.IsEmptyString(lineEdited['PRICING_FORMULA']) )
				{
					this.UpdatePricingFormula(lineEdited, lineEdited['PRICING_FORMULA'], false);
				}
				else
				{
					lineEdited['PRICING_FACTOR'     ] = 0;
				}
				this.lineItems.current.UpdateLineEdited(lineEdited);
				this.UpdateTotals();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateItem', error);
		}
	}

	protected _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any) =>
	{
		const { bEnableSalesTax, bEnableTaxLineItems } = this.state;
		const { CURRENCY_ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate ' + PARENT_FIELD, DATA_VALUE, item);
		try
	{
			if ( this.props.onUpdate )
			{
				this.props.onUpdate(PARENT_FIELD, DATA_VALUE, item);
			}
			else
			{
				if ( this.lineItems.current )
				{
					// 06/24/2020 Paul.  Edit a copy so that we can compare to original when we update. 
					let lineEdited: any = Object.assign({}, this.lineItems.current.LineEdited);
					if ( PARENT_FIELD == 'QUANTITY' )
					{
						lineEdited['EXTENDED_PRICE'] = Sql.ToDecimal(lineEdited['QUANTITY']) * Sql.ToDecimal(lineEdited['UNIT_PRICE']);
						if ( bEnableSalesTax )
						{
							if ( bEnableTaxLineItems )
								this.UpdateTaxRate(lineEdited, lineEdited['TAXRATE_ID'], false);
							else
								this.UpdateTaxRate(lineEdited, lineEdited['TAX_CLASS'], false);
						}
						this.UpdateDiscount(lineEdited, lineEdited['DISCOUNT_ID'], false);
						this.lineItems.current.UpdateLineEdited(lineEdited);
					}
					else if ( PARENT_FIELD == 'UNIT_PRICE' )
					{
						lineEdited['EXTENDED_PRICE'] = Sql.ToDecimal(lineEdited['QUANTITY']) * Sql.ToDecimal(lineEdited['UNIT_PRICE']);
						if ( bEnableSalesTax )
						{
							if ( bEnableTaxLineItems )
								this.UpdateTaxRate(lineEdited, lineEdited['TAXRATE_ID'], false);
							else
								this.UpdateTaxRate(lineEdited, lineEdited['TAX_CLASS'], false);
						}
						this.UpdateDiscount(lineEdited, lineEdited['DISCOUNT_ID'], false);
						this.lineItems.current.UpdateLineEdited(lineEdited);
					}
					else if ( PARENT_FIELD == 'TAXRATE_ID' )
					{
						this.UpdateTaxRate(lineEdited, DATA_VALUE, true);
						this.lineItems.current.UpdateLineEdited(lineEdited);
					}
					else if ( PARENT_FIELD == 'TAX_CLASS' )
					{
						this.UpdateTaxClass(lineEdited, DATA_VALUE, true);
						this.lineItems.current.UpdateLineEdited(lineEdited);
					}
					else if ( PARENT_FIELD == 'DISCOUNT_ID' )
					{
						this.UpdateDiscount(lineEdited, DATA_VALUE, true);
						this.lineItems.current.UpdateLineEdited(lineEdited);
					}
					else if ( PARENT_FIELD == 'PRICING_FORMULA' )
					{
						this.UpdatePricingFormula(lineEdited, DATA_VALUE, true);
						this.lineItems.current.UpdateLineEdited(lineEdited);
					}
					// 10/08/2022 Paul.  Recalculate discount when PRICING_FACTOR changes. 
					else if ( PARENT_FIELD == 'PRICING_FACTOR' )
					{
						this.UpdatePricingFactor(lineEdited, DATA_VALUE, true);
						this.lineItems.current.UpdateLineEdited(lineEdited);
					}
					else if ( PARENT_FIELD == 'MFT_PART_NUM' )
					{
						AutoComplete_ModuleMethod('Products/ProductCatalog', 'GetItemDetailsByNumber', {gCURRENCY_ID: CURRENCY_ID, sMFT_PART_NUM: lineEdited['MFT_PART_NUM']}).then((d) =>
						{
							this.UpdateItem(d);
						});
					}
					else if ( PARENT_FIELD == 'PRODUCT_TEMPLATE_ID' )
					{
						AutoComplete_ModuleMethod('Products/ProductCatalog', 'GetItemDetailsByID', {gCURRENCY_ID: CURRENCY_ID, sID: lineEdited['PRODUCT_TEMPLATE_ID']}).then((d) =>
						{
							this.UpdateItem(d);
						});
					}
					else if ( PARENT_FIELD == 'NAME' )
					{
						AutoComplete_ModuleMethod('Products/ProductCatalog', 'GetItemDetailsByName', {gCURRENCY_ID: CURRENCY_ID, sNAME: lineEdited['NAME']}).then((d) =>
						{
							this.UpdateItem(d);
						});
					}
					else if ( PARENT_FIELD == 'LineItems' )
					{
						if ( Sql.IsEmptyString(lineEdited['PRICING_FORMULA']) )
						{
							lineEdited['PRICING_FACTOR'] = 0;
						}
						if ( lineEdited['LINE_ITEM_TYPE'] == 'Comment' )
						{
							lineEdited['NAME'               ] = '';
							lineEdited['MFT_PART_NUM'       ] = '';
							lineEdited['VENDOR_PART_NUM'    ] = '';
							lineEdited['PRODUCT_TEMPLATE_ID'] = '';
							// 07/11/2010 Paul.  Add PARENT_TEMPLATE_ID. 
							lineEdited['PARENT_TEMPLATE_ID' ] = '';
							// 07/15/2010 Paul.  Add GROUP_ID for options management. 
							// 08/13/2010 Paul.  Use LINE_GROUP_ID instead of GROUP_ID. 
							lineEdited['LINE_GROUP_ID'      ] = '';
							lineEdited['TAX_CLASS'          ] = '';
							// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
							lineEdited['TAXRATE_ID'         ] = '';
							lineEdited['TAX'                ] = '';
							lineEdited['QUANTITY'           ] = 0;
							lineEdited['COST_PRICE'         ] = 0;
							lineEdited['LIST_PRICE'         ] = 0;
							lineEdited['UNIT_PRICE'         ] = 0;
							lineEdited['EXTENDED_PRICE'     ] = 0;
							lineEdited['DISCOUNT_ID'        ] = '';
							lineEdited['DISCOUNT_NAME'      ] = '';
							lineEdited['DISCOUNT_PRICE'     ] = 0;
							lineEdited['PRICING_FORMULA'    ] = '';
							lineEdited['PRICING_FACTOR'     ] = 0;
						}
						else
						{
							// 11/30/2015 Paul.  Allow Tax to be disabled and to hide MFT Part Number. 
							if ( bEnableSalesTax )
							{
								// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
								if ( bEnableTaxLineItems )
								{
									lineEdited['TAX_CLASS'          ] = '';
								}
								else
								{
									lineEdited['TAXRATE_ID'         ] = '';
									lineEdited['TAX'                ] = 0;
								}
							}
							else
							{
								lineEdited['TAX_CLASS'          ] = '';
								lineEdited['TAXRATE_ID'         ] = '';
								lineEdited['TAX'                ] = 0;
							}
							// 02/10/2011 Paul.  Stop converting the Quantity to an integer. 
							lineEdited['EXTENDED_PRICE'     ] = Sql.ToDecimal(lineEdited['QUANTITY']) * Sql.ToDecimal(lineEdited['UNIT_PRICE']);
							if ( !Sql.IsEmptyGuid(lineEdited['DISCOUNT_ID']) )
							{
								this.UpdateDiscount(lineEdited, lineEdited['DISCOUNT_ID'], false);
							}
							if ( !Sql.IsEmptyString(lineEdited['PRICING_FORMULA']) )
							{
								this.UpdatePricingFormula(lineEdited, lineEdited['PRICING_FORMULA'], false);
							}
							else
							{
								lineEdited['PRICING_FACTOR'     ] = 0;
							}
							/*
							if ( !Sql.IsEmptyString(lineEdited['PRICING_FORMULA']) )
							{
								let sPRICING_FORMULA = Sql.ToString (lineEdited['PRICING_FORMULA']);
								let fPRICING_FACTOR  = Sql.ToFloat  (lineEdited['PRICING_FACTOR' ]);
								let dEXTENDED_PRICE  = Sql.ToDecimal(lineEdited['EXTENDED_PRICE' ]);
								let dDISCOUNT_VALUE  = 0.0;
								lineEdited['DISCOUNT_PRICE'   ] = DiscountValue(sPRICING_FORMULA, fPRICING_FACTOR, dEXTENDED_PRICE);
							}
							else
							{
								lineEdited['PRICING_FACTOR'     ] = 0;
							}
							*/
							// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
							// 11/30/2015 Paul.  Allow Tax to be disabled and to hide MFT Part Number. 
							if ( bEnableSalesTax && bEnableTaxLineItems )
							{
								lineEdited['TAX'         ] = 0;
								let gTAXRATE_ID = Sql.ToGuid(lineEdited['TAXRATE_ID']);
								if ( !Sql.IsEmptyGuid(gTAXRATE_ID) )
								{
									let rowTaxRate = SplendidCache.TaxRates(gTAXRATE_ID);
									if ( rowTaxRate != null )
									{
										lineEdited['TAX'         ] = (Sql.ToDecimal(lineEdited['EXTENDED_PRICE']) - Sql.ToDecimal(lineEdited['DISCOUNT_PRICE'])) * Sql.ToDecimal(rowTaxRate['VALUE']) / 100;
									}
								}
							}
						}
						this.lineItems.current.UpdateLineEdited(lineEdited);
						this.UpdateTotals();
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', error);
		}
	}

	private UpdateTaxRate = (lineEdited, gTAXRATE_ID, bOnChange) =>
	{
		const { bEnableTaxShipping, bEnableSalesTax, bEnableTaxLineItems } = this.state;
		const { oNumberFormat } = this.state;
		try
		{
			let dTAX      : number = 0.0;
			// 02/10/2011 Paul.  Stop converting the Quantity to an integer. 
			let nQUANTITY       : number = Sql.ToDecimal(lineEdited['QUANTITY'      ]);
			let dUNIT_PRICE     : number = Sql.ToDecimal(lineEdited['UNIT_PRICE'    ]);
			let dDISCOUNT_PRICE : number = Sql.ToDecimal(lineEdited['DISCOUNT_PRICE']);
			if ( bEnableSalesTax )
			{
				// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
				if ( bEnableTaxLineItems )
				{
					if ( !Sql.IsEmptyGuid(gTAXRATE_ID) )
					{
						let rowTaxRate = SplendidCache.TaxRates(gTAXRATE_ID);
						if ( rowTaxRate != null )
						{
							dTAX += (dUNIT_PRICE * nQUANTITY - dDISCOUNT_PRICE) * Sql.ToDouble(rowTaxRate['VALUE']) / 100;
						}
					}
				}
				lineEdited['TAX'] = dTAX;
			}
			if ( bOnChange )
			{
				lineEdited['TAXRATE_ID'] = gTAXRATE_ID;
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateTaxRate', error);
		}
	}

	private UpdateTaxClass = (lineEdited, sTAX_CLASS, bOnChange) =>
	{
		const { bEnableTaxShipping, bEnableSalesTax, bEnableTaxLineItems } = this.state;
		const { TAXRATE_ID, oNumberFormat } = this.state;
		try
		{
			let dTAX            : number = 0.0;
			let dTAX_RATE       : number = 0.0;
			// 02/10/2011 Paul.  Stop converting the Quantity to an integer. 
			let nQUANTITY       : number = Sql.ToDecimal(lineEdited['QUANTITY'      ]);
			let dUNIT_PRICE     : number = Sql.ToDecimal(lineEdited['UNIT_PRICE'    ]);
			let dDISCOUNT_PRICE : number = Sql.ToDecimal(lineEdited['DISCOUNT_PRICE']);
			if ( bEnableSalesTax )
			{
				// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
				if ( !bEnableTaxLineItems )
				{
					let gTAXRATE_ID = Sql.ToGuid(TAXRATE_ID);
					if ( !Sql.IsEmptyGuid(gTAXRATE_ID) )
					{
						let rowTaxRate = SplendidCache.TaxRates(gTAXRATE_ID);
						if ( rowTaxRate != null )
						{
							dTAX_RATE = Sql.ToDouble(rowTaxRate['VALUE']);
						}
					}
					let sTAX_CLASS = Sql.ToString(lineEdited['TAX_CLASS']);
					if ( sTAX_CLASS == 'Taxable' )
					{
						dTAX += (dUNIT_PRICE * nQUANTITY - dDISCOUNT_PRICE) * dTAX_RATE;
					}
				}
				lineEdited['TAX'] = dTAX;
			}
			if ( bOnChange )
			{
				lineEdited['TAX_CLASS'] = sTAX_CLASS;
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateTaxClass', error);
		}
	}

	private UpdateDiscount = (lineEdited, gDISCOUNT_ID, bOnChange) =>
	{
		const { oNumberFormat } = this.state;
		try
		{
			// 02/10/2011 Paul.  Stop converting the Quantity to an integer. 
			let nQUANTITY        : number = Sql.ToDecimal(lineEdited['QUANTITY'  ]);
			let dUNIT_PRICE      : number = Sql.ToDecimal(lineEdited['UNIT_PRICE']);
			let dDISCOUNT_VALUE  : number = 0.0;  // Sql.ToDecimal(txtDISCOUNT_PRICE.value);
			let sDISCOUNT_NAME   : string = '';
			let sPRICING_FORMULA : string = '';
			let fPRICING_FACTOR  : number = 0;
		
			// 08/15/2010 Paul.  In this area, we use the UNIT_PRICE instead of list or cost. 
			if ( !Sql.IsEmptyGuid(gDISCOUNT_ID) )
			{
				let rowDISCOUNT = SplendidCache.Discounts(gDISCOUNT_ID);
				if ( rowDISCOUNT != null )
				{
					sPRICING_FORMULA = Sql.ToString(rowDISCOUNT['PRICING_FORMULA']);
					fPRICING_FACTOR  = Sql.ToFloat (rowDISCOUNT['PRICING_FACTOR' ]);
					sDISCOUNT_NAME   = Sql.ToString(rowDISCOUNT['NAME'           ]);
					// 02/21/2021 Paul.  Move DiscountValue() to OrderUtils. 
					dDISCOUNT_VALUE  = DiscountValue(sPRICING_FORMULA, fPRICING_FACTOR, dUNIT_PRICE);
					lineEdited['DISCOUNT_ID'    ] = gDISCOUNT_ID    ;
					lineEdited['PRICING_FORMULA'] = sPRICING_FORMULA;
				}
			}
			// 08/15/2010 Paul.  The value we store is the discount amount and not the end-price. 
			lineEdited['DISCOUNT_PRICE' ] = formatNumber(nQUANTITY * dDISCOUNT_VALUE, oNumberFormat);
			lineEdited['EXTENDED_PRICE' ] = formatNumber(nQUANTITY * dUNIT_PRICE    , oNumberFormat);
			lineEdited['PRICING_FACTOR' ] = fPRICING_FACTOR;
			if ( bOnChange )
			{
				lineEdited['DISCOUNT_ID'    ] = gDISCOUNT_ID    ;
				lineEdited['PRICING_FORMULA'] = sPRICING_FORMULA;
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateDiscount', error);
		}
	}

	private UpdatePricingFormula = (lineEdited, sPRICING_FORMULA, bOnChange) =>
	{
		const { oNumberFormat } = this.state;
		try
		{
			if ( Sql.IsEmptyString(sPRICING_FORMULA) )
			{
				lineEdited['PRICING_FACTOR'] = 0;
			}
			let nQUANTITY        = Sql.ToDecimal(lineEdited['QUANTITY'      ]);
			let dUNIT_PRICE      = Sql.ToDecimal(lineEdited['UNIT_PRICE'    ]);
			let fPRICING_FACTOR  = Sql.ToFloat  (lineEdited['PRICING_FACTOR']);
			// 02/21/2021 Paul.  Move DiscountValue() to OrderUtils. 
			let dDISCOUNT_VALUE  = DiscountValue(sPRICING_FORMULA, fPRICING_FACTOR, dUNIT_PRICE);
		
			lineEdited['DISCOUNT_PRICE' ] = formatNumber(nQUANTITY * dDISCOUNT_VALUE, oNumberFormat);
			lineEdited['EXTENDED_PRICE' ] = formatNumber(nQUANTITY * dUNIT_PRICE    , oNumberFormat);
			if ( bOnChange )
			{
				lineEdited['DISCOUNT_ID'] = '';
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdatePricingFormula', error);
		}
	}

	// 10/08/2022 Paul.  Recalculate discount when PRICING_FACTOR changes. 
	private UpdatePricingFactor = (lineEdited, sPRICING_FACTOR, bOnChange) =>
	{
		const { oNumberFormat } = this.state;
		try
		{
			if ( Sql.IsEmptyString(sPRICING_FACTOR) )
			{
				sPRICING_FACTOR = 0;
			}
			let sPRICING_FORMULA = Sql.ToString (lineEdited['PRICING_FORMULA'])
			let nQUANTITY        = Sql.ToDecimal(lineEdited['QUANTITY'       ]);
			let dUNIT_PRICE      = Sql.ToDecimal(lineEdited['UNIT_PRICE'     ]);
			let fPRICING_FACTOR  = Sql.ToFloat  (sPRICING_FACTOR              );
			// 02/21/2021 Paul.  Move DiscountValue() to OrderUtils. 
			let dDISCOUNT_VALUE  = DiscountValue(sPRICING_FORMULA, fPRICING_FACTOR, dUNIT_PRICE);
		
			lineEdited['DISCOUNT_PRICE' ] = formatNumber(nQUANTITY * dDISCOUNT_VALUE, oNumberFormat);
			lineEdited['EXTENDED_PRICE' ] = formatNumber(nQUANTITY * dUNIT_PRICE    , oNumberFormat);
			if ( bOnChange )
			{
				lineEdited['DISCOUNT_ID'] = '';
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdatePricingFactor', error);
		}
	}

	private UpdateTotals = () =>
	{
		const { onChanged } = this.props;
		const { bEnableTaxShipping, bEnableSalesTax, bEnableTaxLineItems, oNumberFormat } = this.state;
		const { SHIPPING, TAXRATE_ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateTotals');

		let LineItems: any[] = [];
		if ( this.lineItems.current )
		{
			LineItems = this.lineItems.current.LineItems;
		}

		let dSUBTOTAL : number = 0.0;
		// 08/13/2010 Paul.  Discount is now computed per line item. 
		let dDISCOUNT : number = 0.0;
		let dSHIPPING : number = Sql.ToDecimal(SHIPPING);
		let dTAX      : number = 0.0;
		let dTOTAL    : number = 0.0;
		let dTAX_RATE : number = 0.0;
	
		if ( bEnableSalesTax )
		{
			let gTAXRATE_ID = TAXRATE_ID;
			if ( !Sql.IsEmptyGuid(gTAXRATE_ID) )
			{
				let rowTaxRate = SplendidCache.TaxRates(gTAXRATE_ID);
				if ( rowTaxRate != null )
				{
					dTAX_RATE = Sql.ToDouble(rowTaxRate['VALUE']) / 100;
				}
			}
		}
		for ( let i = 0; i < LineItems.length; i++ )
		{
			let row = LineItems[i];
			// 08/11/2007 Paul.  Allow an item to be manually added.  Require either a product ID or a name. 
			// 11/18/2010 Paul.  We do not need to check the DISCOUNT_ID as a discount cannot stand-alone. 
			if ( !Sql.IsEmptyString(row['NAME']) || !Sql.IsEmptyGuid(row['PRODUCT_TEMPLATE_ID']) )
			{
				let sLINE_ITEM_TYPE : string = Sql.ToString (row['LINE_ITEM_TYPE']);
				// 02/10/2011 Paul.  Stop converting the Quantity to an integer. 
				let nQUANTITY       : number = Sql.ToDecimal(row['QUANTITY'      ]);
				let dUNIT_PRICE     : number = Sql.ToDecimal(row['UNIT_PRICE'    ]);
				let dDISCOUNT_PRICE : number = Sql.ToDecimal(row['DISCOUNT_PRICE']);
				if ( sLINE_ITEM_TYPE != 'Comment' )
				{
					dSUBTOTAL += dUNIT_PRICE * nQUANTITY;
					// 08/13/2010 Paul.  Discount is now computed per line item. 
					// 08/15/2010 Paul.  Discount already includes quantity. 
					dDISCOUNT += dDISCOUNT_PRICE;
					// 11/30/2015 Paul.  Allow Tax to be disabled and to hide MFT Part Number. 
					if ( bEnableSalesTax )
					{
						// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
						if ( bEnableTaxLineItems )
						{
							let gTAXRATE_ID = Sql.ToGuid(row['TAXRATE_ID']);
							if ( !Sql.IsEmptyGuid(gTAXRATE_ID) )
							{
								let rowTaxRate = SplendidCache.TaxRates(gTAXRATE_ID);
								if ( rowTaxRate != null )
								{
									dTAX += (dUNIT_PRICE * nQUANTITY - dDISCOUNT_PRICE) * Sql.ToDouble(rowTaxRate['VALUE']) / 100;
								}
							}
						}
						else
						{
							let sTAX_CLASS = Sql.ToString(row['TAX_CLASS']);
							if ( sTAX_CLASS == 'Taxable' )
								dTAX += (dUNIT_PRICE * nQUANTITY - dDISCOUNT_PRICE) * dTAX_RATE;
						}
					}
				}
			}
		}
		// 08/02/2010 Paul.  Some states require that the shipping be taxes. We will use one flag for Quotes, Orders and Invoices. 
		if ( bEnableTaxShipping )
		{
			dTAX += dSHIPPING * dTAX_RATE;
		}
		dTOTAL = dSUBTOTAL - dDISCOUNT + dTAX + dSHIPPING;

		this.setState( {SUBTOTAL: dSUBTOTAL, DISCOUNT: dDISCOUNT, SHIPPING: formatNumber(dSHIPPING, oNumberFormat), TAX: dTAX, TOTAL: dTOTAL} );
		onChanged('SUBTOTAL', dSUBTOTAL);
		onChanged('DISCOUNT', dDISCOUNT);
		onChanged('SHIPPING', dSHIPPING);
		onChanged('TAX'     , dTAX     );
		onChanged('TOTAL'   , dTOTAL   );
	}

	private _onCURRENCY_ID_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { onChanged } = this.props;
		let CURRENCY_ID: string = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onCURRENCY_ID_Change', CURRENCY_ID);
		this.setState({ CURRENCY_ID });
		onChanged('CURRENCY_ID', CURRENCY_ID);
	}

	private _onEXCHANGE_RATE_Change = (e) =>
	{
		const { onChanged } = this.props;
		// 11/12/2022 Paul.  We can't dynamically convert to a number as it will prevent editing. 
		let EXCHANGE_RATE: string = e.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onEXCHANGE_RATE_Change', EXCHANGE_RATE);
		this.setState({ EXCHANGE_RATE });
		onChanged('EXCHANGE_RATE', Sql.ToDecimal(EXCHANGE_RATE));
	}

	private _onTAXRATE_ID_Change = (e) =>
	{
		const { onChanged } = this.props;
		let TAXRATE_ID: string = e.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTAXRATE_ID_Change', TAXRATE_ID);
		this.setState({ TAXRATE_ID });
		this.UpdateTotals();
		onChanged('TAXRATE_ID', TAXRATE_ID);
	}

	private _onTaxLookup = () =>
	{
	}

	private _onSHIPPER_ID_Change = (e) =>
	{
		const { onChanged } = this.props;
		let SHIPPER_ID: string = e.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSHIPPER_ID_Change', SHIPPER_ID);
		this.setState({ SHIPPER_ID });
		onChanged('SHIPPER_ID', SHIPPER_ID);
	}

	private _onSHIPPING_Change = (e) =>
	{
		const { onChanged } = this.props;
		// 11/12/2022 Paul.  We can't dynamically convert to a number as it will prevent editing. 
		let SHIPPING: string = e.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSHIPPING_Change', SHIPPING);
		// 05/20/2022 Paul.  Must wait to send change until after state has changed. 
		this.setState({ SHIPPING }, () =>
		{
			onChanged('SHIPPING', Sql.ToDecimal(SHIPPING));
			// 07/03/2022 Paul.  Don't update totals while editing as it resets the shipping value as well. 
			//this.UpdateTotals();
		});
	}

	private _onSHIPPING_Blur = (e) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSHIPPING_Blur');
		this.UpdateTotals();
	}

	protected _onFieldDidMount = (DATA_FIELD: string, component: any): void =>
	{
		if ( DATA_FIELD == 'EXTENDED_PRICE' )
		{
			component.updateDependancy(null, false, 'enabled', null);
		}
		else if ( DATA_FIELD == 'TAX' )
		{
			component.updateDependancy(null, false, 'enabled', null);
		}
	}

	public RenderLineHeader = (MODULE_NAME: string) =>
	{
		const { bEnableTaxLineItems, bEnableTaxShipping, bShowTax,  bEnableSalesTax, bDisableExchangeRate } = this.state;
		const { CURRENCY_ID, EXCHANGE_RATE, TAXRATE_ID, CURRENCY_ID_LIST, TAXRATE_ID_LIST, SHIPPER_ID, SHIPPER_ID_LIST } = this.state;
		return (
			<div id='ctlEditLineItemsView_ctlLineHeaderPanel' className='tabForm' style={ {display: 'flex', flexDirection: 'row', flexWrap: 'wrap', width: '100%'} }>
				{ !bDisableExchangeRate
				? <div style={ { display: 'flex', flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 20%' } }>
					<label key={ 'ctlEditView_CURRENCY_ID_Label' } className='dataLabel' style={ {width: '30%'} }>{ L10n.Term(MODULE_NAME + '.LBL_CURRENCY') }</label>
					<span className='dataField' style={ {width: '70%'} }>
						<select
							onChange={ this._onCURRENCY_ID_Change }
							value={ CURRENCY_ID }
							style={ {width: 'auto'} }
							>
							{
								CURRENCY_ID_LIST.map((item, index) => 
								{
									return (<option key={ '_ctlEditView_CURRENCY_ID_' + index.toString() } id={ '_ctlEditView_CURRENCY_ID' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
								})
							}
						</select>
					</span>
				</div>
				: null
				}
				<div style={ { display: 'flex', flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 20%' } }>
					<label key={ 'ctlEditView_EXCHANGE_RATE_Label' } className='dataLabel' style={ {width: '50%'} }>{ L10n.Term(MODULE_NAME + '.LBL_CONVERSION_RATE') }</label>
					<span className='dataField' style={ {width: '50%'} }>
						<input
							value={ EXCHANGE_RATE }
							type='text'
							autoComplete='off'
							style={ {width: '70px'} }
							onChange={ this._onEXCHANGE_RATE_Change }
						/>
					</span>
				</div>
				{ bEnableSalesTax && !bEnableTaxLineItems
				? <div style={ { display: 'flex', flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 30%' } }>
					<label key={ 'ctlEditView_TAXRATE_ID_Label' } className='dataLabel' style={ {width: '25%'} }>{ L10n.Term(MODULE_NAME + '.LBL_TAXRATE') }</label>
					<span className='dataField' style={ {width: '75%'} }>
						<select
							onChange={ this._onTAXRATE_ID_Change }
							value={ TAXRATE_ID }
							style={ {width: 'auto'} }
							>
							{
								TAXRATE_ID_LIST.map((item, index) => 
								{
									return (<option key={ '_ctlEditView_TAXRATE_ID_' + index.toString() } id={ '_ctlEditView_TAXRATE_ID' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
								})
							}
						</select>
						{ false
						? <button
							style={ {marginLeft: '4px'} }
							onClick={ this._onTaxLookup }
							className='button'>
							<FontAwesomeIcon icon='plus' className='d-lg-none' />
							<span className='d-none d-lg-inline'>{ L10n.Term('Orders.LBL_LOOKUP_TAX_TITLE') }</span>
						</button>
						: null
						}
					</span>
				</div>
				: null
				}
				<div style={ { display: 'flex', flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 30%' } }>
					<label key={ 'ctlEditView_SHIPPER_ID_Label' } className='dataLabel' style={ {width: '25%'} }>{ L10n.Term(MODULE_NAME + '.LBL_SHIPPER') }</label>
					<span className='dataField' style={ {width: '75%'} }>
						<select
							onChange={ this._onSHIPPER_ID_Change }
							value={ SHIPPER_ID }
							style={ {width: 'auto'} }
							>
							{
								SHIPPER_ID_LIST.map((item, index) => 
								{
									return (<option key={ '_ctlEditView_SHIPPER_ID_' + index.toString() } id={ '_ctlEditView_SHIPPER_ID' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
								})
							}
						</select>
					</span>
				</div>
			</div>
		);
	}

	public RenderSummary = (MODULE_NAME: string) =>
	{
		const { SUBTOTAL, DISCOUNT, SHIPPING, TAX, TOTAL, oNumberFormat } = this.state;
		return (
			<div id='ctlEditLineItemsView_ctlSummaryPanel' className='tabForm' style={ {display: 'flex', flexFlow: 'row wrap', width: '100%'} }>
				<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 65%'} }></div>
				<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 35%'} }>
					<span className='dataLabel' style={ {width: '30%'} }>{ L10n.Term(MODULE_NAME + '.LBL_SUBTOTAL') }</span>
					<div className='dataField' style={ {width: '70%'} }>
						<input
							id={ 'SUBTOTAL' }
							key={ 'SUBTOTAL' }
							value={ formatCurrency(SUBTOTAL, oNumberFormat) }
							type='text'
							style={ {backgroundColor: '#DDDDDD'} }
							readOnly={ true }
						/>
					</div>
				</div>
				<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 65%'} }></div>
				<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 35%'} }>
					<span className='dataLabel' style={ {width: '30%'} }>{ L10n.Term(MODULE_NAME + '.LBL_DISCOUNT') }</span>
					<div className='dataField' style={ {width: '70%'} }>
						<input
							id={ 'DISCOUNT' }
							key={ 'DISCOUNT' }
							value={ formatCurrency(SUBTOTAL, oNumberFormat) }
							type='text'
							style={ {backgroundColor: '#DDDDDD'} }
							readOnly={ true }
						/>
					</div>
				</div>
				<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 65%'} }></div>
				<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 35%'} }>
					<span className='dataLabel' style={ {width: '30%'} }>{ L10n.Term(MODULE_NAME + '.LBL_SHIPPING') }</span>
					<div className='dataField' style={ {width: '70%'} }>
						<input
							id={ 'SHIPPING' }
							key={ 'SHIPPING' }
							value={ SHIPPING }
							type='text'
							onChange={ this._onSHIPPING_Change }
							onBlur={ this._onSHIPPING_Blur }
						/>
					</div>
				</div>
				<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 65%'} }></div>
				<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 35%'} }>
					<span className='dataLabel' style={ {width: '30%'} }>{ L10n.Term(MODULE_NAME + '.LBL_TAX') }</span>
					<div className='dataField' style={ {width: '70%'} }>
						<input
							id={ 'TAX' }
							key={ 'TAX' }
							value={ formatCurrency(TAX, oNumberFormat) }
							type='text'
							style={ {backgroundColor: '#DDDDDD'} }
							readOnly={ true }
						/>
					</div>
				</div>
				<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 65%'} }></div>
				<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 35%'} }>
					<span className='dataLabel' style={ {width: '30%'} }>{ L10n.Term(MODULE_NAME + '.LBL_TOTAL') }</span>
					<div className='dataField' style={ {width: '70%'} }>
						<input
							id={ 'TOTAL' }
							key={ 'TOTAL' }
							value={ formatCurrency(TOTAL, oNumberFormat) }
							type='text'
							style={ {backgroundColor: '#DDDDDD'} }
							readOnly={ true }
						/>
					</div>
				</div>
			</div>
		);
	}

	public ValidateLineItem = (MODULE_NAME: string, layout: EDITVIEWS_FIELD[], lineEdited: any): void =>
	{
		if ( lineEdited['LINE_ITEM_TYPE'] != 'Comment' )
		{
			let arrRequiredFields: string[] = [];
			for ( let i: number = 0; i < layout.length; i++ )
			{
				let lay: any = layout[i];
				let UI_REQUIRED   : boolean = Sql.ToBoolean(lay.UI_REQUIRED) || Sql.ToBoolean(lay.DATA_REQUIRED);
				// 06/27/2020 Paul.  A hidden field cannot be required. 
				if ( UI_REQUIRED && !lay.hidden )
				{
					if ( Sql.IsEmptyString(lineEdited[lay.DATA_FIELD]) )
					{
						arrRequiredFields.push(lay.DATA_FIELD);
					}
					else if ( lay.DATA_FIELD == 'QUANTITY' )
					{
						if ( isNaN(lineEdited[lay.DATA_FIELD]) )
						{
							throw(L10n.Term('.ERR_INVALID_DECIMAL') + ' ' + lay.DATA_FIELD);
						}
					}
					else if ( lay.DATA_FIELD == 'UNIT_PRICE' )
					{
						if ( isNaN(lineEdited[lay.DATA_FIELD]) )
						{
							throw(L10n.Term('.ERR_INVALID_DECIMAL') + ' ' + lay.DATA_FIELD);
						}
					}
				}
			}
			if ( arrRequiredFields.length > 0 )
			{
				let sError: string = L10n.Term('.ERR_MISSING_REQUIRED_FIELDS') + ' ';
				for ( let i: number = 0; i < arrRequiredFields.length; i++ )
				{
					if ( i > 0 )
						sError += ', ';
					sError += L10n.TableColumnName(MODULE_NAME, arrRequiredFields[i]).replace(':', '');
				}
				throw(sError);
			}
		}
	}
}

