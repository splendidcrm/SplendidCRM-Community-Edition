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
import { RouteComponentProps, withRouter }           from 'react-router-dom'              ;
import { FontAwesomeIcon }                           from '@fortawesome/react-fontawesome';
import { observer }                                  from 'mobx-react'                    ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                           from '../scripts/Sql'                ;
import L10n                                          from '../scripts/L10n'               ;
import Credentials                                   from '../scripts/Credentials'        ;
import SplendidCache                                 from '../scripts/SplendidCache'      ;
import { Application_GetReactLoginState }            from '../scripts/Application'        ;
import { DynamicLayout_Module }                      from '../scripts/DynamicLayout'      ;
// 4. Components and Views. 
import { RouterStore }                               from 'mobx-react-router'             ;
import ErrorComponent                                from '../components/ErrorComponent'  ;
import LoginView                                     from './LoginView'                   ;

interface ILoginViewProps extends RouteComponentProps<any>
{
	routing?             : RouterStore;
	initState            : any;
}

interface ILoginViewState
{
	customView?      : any;
	error?           : any;
}

// 12/07/2022 Paul.  Allow the LoginView to be customized. 
@observer
class DynamicLoginView extends React.Component<ILoginViewProps, ILoginViewState>
{
	private _isMounted = false;

	constructor(props: ILoginViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor');
		this.state = {};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		this._isMounted = true;
		try
		{
			SplendidCache.Reset();
			if ( !Credentials.bMOBILE_CLIENT || !Sql.IsEmptyString(Credentials.RemoteServer) )
				await Application_GetReactLoginState();
			let customView = await DynamicLayout_Module('Home', 'EditViews', 'LoginView');
			if ( this._isMounted )
			{
				this.setState({ customView });
			}
		}
		catch(error)
		{
			this.setState({ error: error.message });
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	public render()
	{
		const { customView, error } = this.state;
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
		else if ( customView )
		{
			return React.createElement(customView, { ...this.props });
		}
		else
		{
			return <LoginView { ...this.props } />;
		}
	}
}

export default withRouter(DynamicLoginView);
