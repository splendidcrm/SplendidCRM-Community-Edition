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
import { RouteComponentProps, withRouter }    from 'react-router-dom'            ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'              ;
import { Crm_Config }                         from '../scripts/Crm'              ;
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'            ;
// 4. Components and Views. 
import ErrorComponent                         from '../components/ErrorComponent';

interface IRootViewProps extends RouteComponentProps<any>
{
}

interface IRootViewState
{
	error?: any;
}

class RootView extends React.Component<IRootViewProps, IRootViewState>
{
	constructor(props: IRootViewProps)
	{
		super(props);
		this.state = {};
	}

	async componentDidMount()
	{
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				const { history } = this.props;
				let home: string = Crm_Config.ToString('default_module');
				if ( !Sql.IsEmptyString(home) && home != 'Home')
				{
					// 02/08/2021 Paul.  Should have a leading slash. 
					home = home.replace('~/', '');
					history.push('/' + home);
				}
				else
				{
					history.push('/Home');
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

	public render()
	{
		const { error } = this.state;
		if ( error )
		{
			return <ErrorComponent error={error} />;
		}
		else
		{
			return (<div>
			</div>);
		}
	}
}

export default withRouter(RootView);
