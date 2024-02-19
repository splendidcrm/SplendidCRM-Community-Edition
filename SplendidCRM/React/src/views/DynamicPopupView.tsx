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
import { RouteComponentProps, withRouter }    from '../Router5'              ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome';
import { observer }                           from 'mobx-react'                    ;
// 2. Store and Types. 
// 3. Scripts. 
import Credentials                            from '../scripts/Credentials'        ;
import SplendidCache                          from '../scripts/SplendidCache'      ;
import { DynamicLayout_Module }               from '../scripts/DynamicLayout'      ;
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'              ;
// 4. Components and Views. 
import ErrorComponent                         from '../components/ErrorComponent'  ;
import PopupView                              from './PopupView'                   ;

interface IDynamicPopupViewProps extends RouteComponentProps<any>
{
	MODULE_NAME        : string;
	// 09/09/2022 Paul.  Provide a way to select an alternate layout.  Only works for custom layouts. 
	CUSTOM_LAYOUT_NAME?: string;
	rowDefaultSearch?  : any;
	callback           : Function;
	isOpen             : boolean;
	showProcessNotes?  : boolean;
	multiSelect?       : boolean;
	ClearDisabled?     : boolean;
	isSearchView?      : boolean;
	// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
	fromLayoutName?    : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data) => void;
}

interface IDynamicPopupViewState
{
	customView?: any;
	error?     : any;
}

@observer
class DynamicPopupView extends React.Component<IDynamicPopupViewProps, IDynamicPopupViewState>
{
	private _isMounted = false;

	constructor(props: IDynamicPopupViewProps)
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', this.props.MODULE_NAME);
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				// 09/09/2022 Paul.  Provide a way to select an alternate layout.  Only works for custom layouts. 
				let sLAYOUT_NAME = (this.props.CUSTOM_LAYOUT_NAME ? this.props.CUSTOM_LAYOUT_NAME : 'PopupView');
				let customView = await DynamicLayout_Module(this.props.MODULE_NAME, 'ListViews', sLAYOUT_NAME);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + (customView ? 'custom' : 'default') + ' view ' + this.props.MODULE_NAME + '.' + sLAYOUT_NAME);
				// 05/26/2019 Paul.  The component may be unmounted by the time the custom view is generated. 
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

	componentDidUpdate(prevProps: IDynamicPopupViewProps)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', this.props.MODULE_NAME);
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	public render()
	{
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
			return React.createElement(customView, { key: this.props.MODULE_NAME, ...this.props });
		}
		else if ( SplendidCache.IsInitialized && Credentials.bIsAuthenticated )
		{
			// 06/26/2019 Paul.  Specify a key so that SplendidGrid will get componentDidMount when changing views. 
			return <PopupView key={ this.props.MODULE_NAME } {...this.props} />;
		}
		else
		{
			return null;
		}
	}
}

export default withRouter(DynamicPopupView);
