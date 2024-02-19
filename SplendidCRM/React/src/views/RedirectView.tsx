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
import React                                         from 'react'                         ;
import { RouteComponentProps, withRouter, Navigate } from '../Router5'                    ;
// 2. Store and Types. 
// 3. Scripts. 
// 4. Components and Views. 
import MainContent                                   from '../ThemeComponents/MainContent';

interface IRedirectViewProps extends RouteComponentProps<any>
{
	from: string;
	to  : string;
}

interface IRedirectViewPropsState
{
	sRedirectUrl: string | null;
}

class RedirectView extends React.Component<IRedirectViewProps, IRedirectViewPropsState>
{
	constructor(props: IRedirectViewProps)
	{
		super(props);
		this.state =
		{
			sRedirectUrl: null
		};
	}

	async componentDidMount()
	{
		const { history, location, match, from, to } = this.props;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', this.props);
		let sRedirectUrl: string = to;
		if ( from.indexOf('*') >= 0 || from.indexOf(':') >= 0 )
		{
			for ( let i = 0; i < match.length; i++ )
			{
				for ( const paramName in match[i].params )
				{
					if ( paramName === '*' )
						sRedirectUrl = sRedirectUrl.replace(paramName, match[i].params[paramName]);
					else
						sRedirectUrl = sRedirectUrl.replace(':' + paramName, match[i].params[paramName]);
				}
			}
		}
		// 02/10/2024 Paul.  replace not actually being followed. 
		history.replace(sRedirectUrl);
		// 02/10/2024 Paul.  Navigate component seems to work. 
		this.setState({ sRedirectUrl });
	}

	public render()
	{
		const { location } = this.props;
		const { sRedirectUrl } = this.state;

		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', this.props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render children', this.props.children);
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', sRedirectUrl);
		return (<MainContent>
			<div style={ {fontSize: '20px', fontWeight: 'bold', padding: '20px'} }>
				RedirectView: { JSON.stringify(location) } <br />
				{ sRedirectUrl
				? <Navigate to={ sRedirectUrl } replace={ true } />
				: null
				}
			</div>
		</MainContent>);
	}
}

export default withRouter(RedirectView);
