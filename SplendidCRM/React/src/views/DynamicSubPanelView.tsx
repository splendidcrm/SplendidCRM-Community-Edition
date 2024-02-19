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
import { RouteComponentProps, withRouter }    from '../Router5'                 ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome'   ;
import { observer }                           from 'mobx-react'                       ;
// 2. Store and Types. 
import DETAILVIEWS_RELATIONSHIP               from '../types/DETAILVIEWS_RELATIONSHIP';
// 3. Scripts. 
import SplendidCache                          from '../scripts/SplendidCache'         ;
import Credentials                            from '../scripts/Credentials'           ;
import { DynamicLayout_Module }               from '../scripts/DynamicLayout'         ;
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'                 ;
// 4. Components and Views. 
import ErrorComponent                         from '../components/ErrorComponent'     ;
import SubPanelView                           from './SubPanelView'                   ;
import SubPanelStreamView                     from './SubPanelStreamView'             ;

interface IDynamicSubPanelViewProps extends RouteComponentProps<any>
{
	PARENT_TYPE      : string;
	row              : any;
	layout           : DETAILVIEWS_RELATIONSHIP;
	CONTROL_VIEW_NAME: string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data) => void;
	// 03/30/2022 Paul.  Pacific theme needs collapse notification. 
	onComponentCollapse?: (CONTROL_VIEW_NAME: string, open: boolean) => void;
}

interface IDynamicSubPanelViewState
{
	customView?: any;
	error?     : any;
}

@observer
class DynamicSubPanelView extends React.Component<IDynamicSubPanelViewProps, IDynamicSubPanelViewState>
{
	private _isMounted = false;

	constructor(props: IDynamicSubPanelViewProps)
	{
		super(props);
		this.state = {};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { PARENT_TYPE, row, layout } = this.props;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', layout.CONTROL_NAME);
				let customView = await DynamicLayout_Module(PARENT_TYPE, 'SubPanels', layout.CONTROL_NAME);
				if ( this._isMounted )
				{
					this.setState({ customView });
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

	componentDidUpdate(prevProps: IDynamicSubPanelViewProps)
	{
		const { PARENT_TYPE, layout } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', PARENT_TYPE + '.' + layout.CONTROL_NAME);
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	public render()
	{
		const { PARENT_TYPE, row, layout } = this.props;
		const { customView, error } = this.state;
		// 06/27/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( error )
		{
			return <ErrorComponent error={error} />;
		}
		else if ( customView === undefined )
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
			</div>);
		}
		else if ( SplendidCache.IsInitialized && customView )
		{
			// 06/26/2019 Paul.  Specify a key so that SplendidGrid will get componentDidMount when changing views. 
			return React.createElement(customView, { key: this.props.PARENT_TYPE, ...this.props });
		}
		else if ( SplendidCache.IsInitialized && Credentials.bIsAuthenticated )
		{
			// 06/26/2019 Paul.  Specify a key so that SplendidGrid will get componentDidMount when changing views. 
			// 03/30/2022 Paul.  Pacific theme needs collapse notification. 
			if ( layout.CONTROL_NAME == 'ActivityStream' )
				return <SubPanelStreamView key={ PARENT_TYPE + '.' + layout.CONTROL_NAME } MODULE_NAME={ PARENT_TYPE } ID={ row.ID } row={ row } CONTROL_VIEW_NAME={ PARENT_TYPE + '.' + layout.CONTROL_NAME } isPrecompile={ this.props.isPrecompile } onComponentComplete={ this.props.onComponentComplete } onComponentCollapse={ this.props.onComponentCollapse } />;
			else
				return <SubPanelView key={ PARENT_TYPE + '.' + layout.CONTROL_NAME } { ...this.props } />;
		}
		else
		{
			return null;
		}
	}
}

export default withRouter(DynamicSubPanelView);
