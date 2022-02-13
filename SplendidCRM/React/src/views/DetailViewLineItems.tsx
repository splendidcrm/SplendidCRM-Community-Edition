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
import { RouteComponentProps, withRouter } from 'react-router-dom'          ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                 from '../scripts/Sql'            ;
import { Crm_Modules }                     from '../scripts/Crm'            ;
import { ListView_LoadTablePaginated }     from '../scripts/ListView'       ;
// 4. Components and Views. 
import SplendidGrid                        from '../components/SplendidGrid';

interface IDetailViewLineItemsProps extends RouteComponentProps<any>
{
	MODULE_NAME: string;
	ID         : string;
}

interface IDetailViewLineItemsState
{
	TABLE_NAME    : string;
	RELATED_MODULE: string;
	PRIMARY_FIELD : string;
	GRID_NAME     : string;
}

class DetailViewLineItems extends React.Component<IDetailViewLineItemsProps, IDetailViewLineItemsState>
{
	private splendidGrid = React.createRef<SplendidGrid>();

	constructor(props: IDetailViewLineItemsProps)
	{
		super(props);
		let TABLE_NAME     = null;
		let RELATED_MODULE = null;
		let PRIMARY_FIELD  = null;
		let GRID_NAME      = null;
		TABLE_NAME     = Crm_Modules.TableName(props.MODULE_NAME) + '_LINE_ITEMS';
		PRIMARY_FIELD  = Crm_Modules.SingularTableName(Crm_Modules.TableName(props.MODULE_NAME)) + '_ID';
		RELATED_MODULE = props.MODULE_NAME + 'LineItems';
		GRID_NAME      = props.MODULE_NAME + '.LineItems';
		if ( props.MODULE_NAME == 'Opportunities' )
		{
			TABLE_NAME     = 'REVENUE_LINE_ITEMS';
			RELATED_MODULE = 'RevenueLineItems';
		}
		this.state =
		{
			TABLE_NAME    ,
			RELATED_MODULE,
			PRIMARY_FIELD ,
			GRID_NAME     ,
		};
	}

	private _onGridLayoutLoaded = () =>
	{
		//console.log((new Date()).toISOString() + ' ' + 'DetailViewLineItems._onGridLayoutLoaded');
	}

	private Load = async (sTABLE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE: boolean, archiveView: boolean) =>
	{
		let arrSELECT: string[] = sSELECT.split(',');
		if ( arrSELECT.indexOf('LINE_ITEM_TYPE') < 0 )
		{
			arrSELECT.push('LINE_ITEM_TYPE');
		}
		if ( arrSELECT.indexOf('DESCRIPTION') < 0 )
		{
			arrSELECT.push('DESCRIPTION');
		}
		sSELECT = arrSELECT.join(',');
		let d = await ListView_LoadTablePaginated(sTABLE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, null, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
		if ( d.results )
		{
			// 06/23/2020 Paul.  The comments were not getting displayed. 
			for ( let i: number = 0; i < d.results.length; i++ )
			{
				if ( d.results[i]['LINE_ITEM_TYPE'] == 'Comment' )
				{
					d.results[i]['NAME'] = Sql.ToString(d.results[i]['DESCRIPTION']);
				}
			}
		}
		return d;
	}

	public render()
	{
		const { MODULE_NAME, ID } = this.props;
		const { TABLE_NAME, RELATED_MODULE, PRIMARY_FIELD, GRID_NAME } = this.state;
		return (
			<div>
				<SplendidGrid
					onLayoutLoaded={ this._onGridLayoutLoaded }
					MODULE_NAME={ MODULE_NAME }
					TABLE_NAME={ TABLE_NAME }
					RELATED_MODULE={ RELATED_MODULE }
					PRIMARY_FIELD={ PRIMARY_FIELD }
					PRIMARY_ID={ ID }
					GRID_NAME={ GRID_NAME }
					SORT_FIELD="POSITION"
					SORT_DIRECTION="asc"
					ADMIN_MODE={ false }
					cbCustomLoad={ this.Load }
					deferLoad={ false }
					enableSelection={ false }
					readonly={ true }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.splendidGrid }
				/>
			</div>
		);
	}
}

export default withRouter(DetailViewLineItems);
