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
import { RouteComponentProps, withRouter } from 'react-router-dom'              ;
// 2. Store and Types. 
// 3. Scripts. 
import Credentials                         from '../scripts/Credentials'        ;
import { StartsWith }                      from '../scripts/utility'            ;
// 4. Components and Views. 

interface IResetViewProps extends RouteComponentProps<any>
{
}

class ResetView extends React.Component<IResetViewProps>
{
	async componentDidMount()
	{
		const { history, location } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', location.pathname + location.search);
		let sRedirectUrl: string = '';
		// 06/25/2019 Paul.  Remove the /Reset and continue along the path. 
		if ( location.pathname.length >= 6 )
		{
			// 10/11/2019 Paul.  Include the query parameters. 
			sRedirectUrl = location.pathname.substring(6) + location.search;
			if ( Credentials.bMOBILE_CLIENT )
			{
				if ( StartsWith(sRedirectUrl, '/android_asset/www') )
				{
					sRedirectUrl = sRedirectUrl.substring(18);
				}
				if ( sRedirectUrl == '/index.html' )
				{
					sRedirectUrl = '';
				}
			}
		}
		if ( sRedirectUrl == '' )
		{
			sRedirectUrl = '/Home';
		}
		// 08/05/2019 Paul.  Try and replace the /Reset so that the back button will work properly. 
		history.replace(sRedirectUrl);
	}

	public render()
	{
		const { history, location } = this.props;
		return (<div>{ location.pathname + location.search }</div>);
	}
}

export default withRouter(ResetView);
