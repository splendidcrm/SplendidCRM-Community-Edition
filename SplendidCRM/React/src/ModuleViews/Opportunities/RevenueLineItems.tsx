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
import { EditView_LoadLayout }     from '../../scripts/EditView'                 ;
// 4. Components and Views. 
import EditViewLineItems           from '../../views/EditViewLineItems'          ;

const MODULE_NAME: string = 'Opportunities';

interface IOpportunitiesLineItemsState extends IOrdersLineItemsEditorState
{
	layout         : EDITVIEWS_FIELD[];
}

export default class OpportunitiesLineItems extends OrdersLineItemsEditor<IOrdersLineItemsEditorProps, IOpportunitiesLineItemsState>
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
			const layout: EDITVIEWS_FIELD[] = EditView_LoadLayout('RevenueLineItems.LineItems');
			this.setState({ layout });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
		}
	}

	public render()
	{
		const { ID, row } = this.props;
		const { layout } = this.state;
		if ( layout )
		{
			return (
				<div id='ctlEditLineItemsView'>
					<EditViewLineItems
						MODULE_NAME={ MODULE_NAME }
						ID={ ID }
						row={ row }
						layout={ layout }
						onChanged={ this._onChange }
						onUpdate={ this._onUpdate }
						onFieldDidMount={ this._onFieldDidMount }
						FieldVisibility={ this.FieldVisibility }
						ConvertField={ this.ConvertField }
						ValidateLineItem={ this.ValidateLineItem }
						ref={ this.lineItems }
					/>
				</div>
			);
		}
		else
		{
			return null;
		}
	}
}

