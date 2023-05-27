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
// 2. Store and Types. 
import IOrdersLineItemsEditorProps from '../../types/IOrdersLineItemsEditorProps';
import IOrdersLineItemsEditorState from '../../types/IOrdersLineItemsEditorState';
import OrdersLineItemsEditor       from '../../types/OrdersLineItemsEditor'      ;
import EDITVIEWS_FIELD             from '../../types/EDITVIEWS_FIELD'            ;
// 3. Scripts. 
import Sql                         from '../../scripts/Sql'                      ;
import L10n                        from '../../scripts/L10n'                     ;
import { EditView_LoadLayout }     from '../../scripts/EditView'                 ;
import { formatCurrency }          from '../../scripts/Formatting'               ;
import { EditView_LoadItem }       from '../../scripts/EditView'                 ;
// 4. Components and Views. 
import EditViewLineItems           from '../../views/EditViewLineItems'          ;

const MODULE_NAME: string = 'Payments';

interface IPaymentsLineItemsState extends IOrdersLineItemsEditorState
{
	layout         : EDITVIEWS_FIELD[];
	ALLOCATED?     : number;
}

export default class PaymentsLineItems extends OrdersLineItemsEditor<IOrdersLineItemsEditorProps, IPaymentsLineItemsState>
{
	public get data (): any
	{
		let obj: any = null;
		if ( this.lineItems.current )
		{
			obj = this.lineItems.current.data;
		}
		return obj;
	}

	constructor(props: IOrdersLineItemsEditorProps)
	{
		super(props);
		this.state =
		{
			layout: null,
		};
	}

	async componentDidMount()
	{
		try
		{
			const layout: EDITVIEWS_FIELD[] = EditView_LoadLayout(MODULE_NAME + '.LineItems');
			this.InitLayout(layout);
			this.setState({ layout });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
		}
	}

	public PaymentSummary = () =>
	{
		const { ALLOCATED, oNumberFormat } = this.state;
		return (
			<div id='ctlEditLineItemsView_ctlSummaryPanel' className='tabForm' style={ {display: 'flex', flexFlow: 'row wrap', width: '100%'} }>
				<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 65%'} }></div>
				<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 35%'} }>
					<span className='dataLabel' style={ {width: '30%'} }>{ L10n.Term(MODULE_NAME + '.LBL_ALLOCATED') }</span>
					<div className='dataField' style={ {width: '70%'} }>
						<input
							id={ 'ALLOCATED' }
							key={ 'ALLOCATED' }
							value={ formatCurrency(ALLOCATED, oNumberFormat) }
							type='text'
							style={ {backgroundColor: '#DDDDDD'} }
							readOnly={ true }
						/>
					</div>
				</div>
			</div>
		);
	}

	private _onLineEditChange = (lineEditIndex: number, LineItems: any[]) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLineEditChange', LineItems);
	}

	private _onUpdateLineItem = (LineItems: any[]) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdateLineItem', LineItems);
		this.UpdateAllocations();
	}

	private _onDeleteLineItem = (LineItems: any[]) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDeleteLineItem', LineItems);
		this.UpdateAllocations();
	}

	protected _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any) =>
	{
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
					let lineEdited: any = Object.assign({}, this.lineItems.current.LineEdited);
					if ( PARENT_FIELD == 'AMOUNT_DUE' )
					{
						this.lineItems.current.UpdateLineEdited(lineEdited);
					}
					else if ( PARENT_FIELD == 'AMOUNT' )
					{
						this.lineItems.current.UpdateLineEdited(lineEdited);
						this.UpdateAllocations();
					}
					else if ( PARENT_FIELD == 'INVOICE_ID' )
					{
						EditView_LoadItem('Invoices', DATA_VALUE).then((d) =>
						{
							this.UpdateInvoice(d.results);
						});
					}
					else if ( PARENT_FIELD == 'INVOICE_NAME' )
					{
						//AutoComplete_ModuleMethod('Products/ProductCatalog', 'GetItemDetailsByName', {gCURRENCY_ID: CURRENCY_ID, sNAME: lineEdited['NAME']}).then((d) =>
						//{
						//	this.UpdateInvoice(d.results);
						//});
					}
					else if ( PARENT_FIELD == 'LineItems' )
					{
						this.lineItems.current.UpdateLineEdited(lineEdited);
						this.UpdateAllocations();
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', error);
		}
	}

	private UpdateAllocations = () =>
	{
		const { onChanged } = this.props;

		let LineItems: any[] = [];
		if ( this.lineItems.current )
		{
			LineItems = this.lineItems.current.LineItems;
		}

		let dALLOCATED: number = 0;
		// 10/09/2022 Paul.  Allocations will included edited when line is updated. 
		//if ( this.lineItems.current.LineEdited )
		//	dALLOCATED = Sql.ToDecimal(this.lineItems.current.LineEdited['AMOUNT']);
		for ( let i = 0; i < LineItems.length; i++ )
		{
			let row = LineItems[i];
			// 10/09/2022 Paul.  Allow an item to be manually added.  Require either a product ID or a name. 
			if ( !Sql.IsEmptyString(row['INVOICE_NAME']) || !Sql.IsEmptyGuid(row['INVOICE_ID']) )
			{
				let dAMOUNT: number = Sql.ToDecimal(row['AMOUNT']);
				dALLOCATED += dAMOUNT;
			}
		}
		this.setState( {ALLOCATED: dALLOCATED} );
		if ( onChanged )
			onChanged('AMOUNT', dALLOCATED);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateAllocations ' + dALLOCATED, LineItems);
	}

	private UpdateInvoice = (item) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateInvoice', item);
		try
		{
			if ( this.lineItems.current )
			{
				let lineEdited: any = Object.assign({}, this.lineItems.current.LineEdited);
				lineEdited['INVOICE_NAME'       ] = Sql.ToString (item.NAME               );
				lineEdited['INVOICE_ID'         ] = Sql.ToString (item.ID                 );
				lineEdited['AMOUNT_DUE'         ] = Sql.ToDecimal(item.AMOUNT_DUE         );
				lineEdited['AMOUNT_DUE_USDOLLAR'] = Sql.ToDecimal(item.AMOUNT_DUE_USDOLLAR);
				lineEdited['AMOUNT'             ] = Sql.ToDecimal(item.AMOUNT_DUE         );
				lineEdited['AMOUNT_USDOLLAR'    ] = Sql.ToDecimal(item.AMOUNT_DUE_USDOLLAR);
				
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateInvoice lineEdited', lineEdited);
				this.lineItems.current.UpdateLineEdited(lineEdited);
				this.UpdateAllocations();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateItem', error);
		}
	}

	public render()
	{
		const { ID, row } = this.props;
		const { layout } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', layout);
		if ( layout )
		{
			return (
				<div id='ctlEditLineItemsView'>
					<EditViewLineItems
						MODULE_NAME={ MODULE_NAME }
						ID={ ID }
						row={ row }
						layout={ layout }
						disableComments={ true }
						disableMovement={ true }
						onChanged={ this._onChange }
						onUpdate={ this._onUpdate }
						onFieldDidMount={ this._onFieldDidMount }
						onLineEditChange={ this._onLineEditChange }
						onUpdateLineItem={ this._onUpdateLineItem }
						onDeleteLineItem={ this._onDeleteLineItem }
						FieldVisibility={ this.FieldVisibility }
						ConvertField={ this.ConvertField }
						ValidateLineItem={ this.ValidateLineItem }
						ref={ this.lineItems }
					/>
					{ this.PaymentSummary() }
				</div>
			);
		}
		else
		{
			return null;
		}
	}
}

