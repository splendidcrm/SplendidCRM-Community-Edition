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
import { RouteComponentProps, withRouter }    from '../Router5'          ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'            ;
import Credentials                            from '../scripts/Credentials'    ;
import SplendidCache                          from '../scripts/SplendidCache'  ;
import SearchBuilder                          from '../scripts/SearchBuilder'  ;
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'          ;
import { ListView_LoadLayout, ListView_LoadModulePaginated } from '../scripts/ListView'       ;
// 4. Components and Views. 
import SplendidGrid                           from '../components/SplendidGrid';

interface IUnifiedSearchViewProps extends RouteComponentProps<any>
{
	MODULE_NAME : string;
	search      : string;
	cbHideModule: Function;
}

interface IUnifiedSearchViewState
{
	GRID_NAME  : string;
	error?     : any;
}

class UnifiedSearchView extends React.Component<IUnifiedSearchViewProps, IUnifiedSearchViewState>
{
	private Search;
	private splendidGrid = React.createRef<SplendidGrid>();

	constructor(props: IUnifiedSearchViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props.MODULE_NAME);
		let GRID_NAME = props.MODULE_NAME + '.Search';
		this.state =
		{
			GRID_NAME,
			error    : null
		};
	}

	async componentDidMount()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount');
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	private BuildFilter = () =>
	{
		const { MODULE_NAME, search } = this.props;
		const { GRID_NAME } = this.state;

		const layout = ListView_LoadLayout(GRID_NAME);
		let arrSearchFields = Sql.SearchGridColumns(layout);

		let ControlChars = { CrLf: '\r\n' };
		let oSearchBuilder = new SearchBuilder();
		oSearchBuilder.Init(search);
		let row = null;
		let sFILTER = '( 1 = 1' + ControlChars.CrLf;
		for ( let i = 0; i < arrSearchFields.length; i++ )
		{
			// 05/21/2019 Paul.  The REST API does not support sub-queries, so we will simply search TAG_SET_NAME. 
			/*
			if ( arrSearchFields[i] == 'TAG_SET_NAME' )
			{
				sFILTER += '        ' + (i == 0 ? 'and ' : ' or ') + ' ID in (select BEAN_ID       ' + ControlChars.CrLf;
				sFILTER += '                     from vwTAG_BEAN_REL' + ControlChars.CrLf;
				sFILTER += oSearchBuilder.BuildQuery('                    where', 'TAG_NAME');
				sFILTER += '                  )' + ControlChars.CrLf;
			}
			else
			*/
			// 10/29/2022 Paul.  Makes no sense to search for ID. 
			if ( arrSearchFields[i] != 'ID' )
			{
				sFILTER += oSearchBuilder.BuildQuery('        ' + (i == 0 ? 'and ' : ' or '), arrSearchFields[i]) + ControlChars.CrLf;
			}
		}
		sFILTER += ')' + ControlChars.CrLf;
		return sFILTER;
	}

	private _onGridLayoutLoaded = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGridLayoutLoaded', sFILTER);
		// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
		if ( this.splendidGrid.current != null )
		{
			// 01/06/2021 Paul.  SplendidGrid no longer passed the sFILTER value, so just computer inside the Load method. 
			this.splendidGrid.current.Search(null, null);
		}
	}

	// 01/06/2021 Paul.  We need to use a custom load as we are building sFILTER instead of using rowSEARCH_VALUES. 
	private Load = async (sTABLE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE: boolean, archiveView: boolean) =>
	{
		const { MODULE_NAME, cbHideModule } = this.props;
		sFILTER = this.BuildFilter();
		let d = await ListView_LoadModulePaginated(MODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
		if ( d.results != null && d.results.length == 0 )
		{
			if ( cbHideModule != null )
			{
				cbHideModule(MODULE_NAME, d.__sql);
			}
		}
		return d;
	}

	public render()
	{
		const { MODULE_NAME } = this.props;
		const { GRID_NAME, error } = this.state;
		return SplendidCache.IsInitialized && (
			<div>
				<SplendidGrid
					onLayoutLoaded={ this._onGridLayoutLoaded }
					MODULE_NAME={ MODULE_NAME }
					GRID_NAME={ GRID_NAME }
					ADMIN_MODE={ false }
					cbCustomLoad={ this.Load }
					deferLoad={ true }
					scrollable
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.splendidGrid }
				/>
			</div>
		);
	}
}

export default withRouter(UnifiedSearchView);
