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
import { Redirect, Route, RouteComponentProps, RouteProps, withRouter } from 'react-router-dom';
import { observer }                           from 'mobx-react'             ;
// 2. Store and Types. 
// 3. Scripts. 
import { AuthenticatedMethod, LoginRedirect } from './scripts/Login'        ;
import { StartsWith }                         from './scripts/utility'      ;
// 4. Components and Views. 

type Props =
{
	computedMatch?: any
} & RouteProps & RouteComponentProps<any>;

@observer
class PrivateRoute extends React.Component<Props>
{
	constructor(props: Props)
	{
		super(props);
	}

	async componentDidMount()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', this.props.location.pathname + this.props.location.search);
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 0 && !StartsWith(this.props.location.pathname, '/Reload') )
			{
				LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
		}
	}

	public render()
	{
		const { component: Component, ...rest } = this.props;
		const match = this.props.computedMatch
		/*
		if ( match && match.params['MODULE_NAME'] )
		{
			if ( match.params['MODULE_NAME'] != 'Reload' && match.params['MODULE_NAME'] != 'Reset' )
				localStorage.setItem('ReactLastActiveModule', match.params['MODULE_NAME']);
		}
		else
		{
			localStorage.removeItem('ReactLastActiveModule');
		}
		*/
		// 05/30/2019 Paul.  Experiment with returning to the same location, no matter how deep. 
		localStorage.setItem('ReactLastActiveModule', this.props.location.pathname);
		return <Route {...rest} render={() => <Component {...this.props} {...match.params} />} />
	}
}

export default withRouter(PrivateRoute);
