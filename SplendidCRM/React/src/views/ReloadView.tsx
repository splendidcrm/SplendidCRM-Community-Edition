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
import { FontAwesomeIcon }                 from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                 from '../scripts/Sql'                ;
import Credentials                         from '../scripts/Credentials'        ;
import SplendidCache                       from '../scripts/SplendidCache'      ;
import { SplendidUI_Init }                 from '../scripts/SplendidInitUI'     ;
import { StartsWith }                      from '../scripts/utility'            ;
import { Crm_Config }                      from '../scripts/Crm'                ;
import Security from '../scripts/Security';
// 4. Components and Views. 

interface IReloadViewProps extends RouteComponentProps<any>
{
}

class ReloadView extends React.Component<IReloadViewProps>
{
	private timerID = null;
	private sRedirectUrl: string = '';
	private resetCount = 0;

	async componentDidMount()
	{
		const { history, location } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', location.pathname + location.search);
		// 06/25/2019 Paul.  Remove the /Reload and continue along the path. 
		if ( location.pathname.length >= 7 )
		{
			// 10/11/2019 Paul.  Include the query parameters. 
			this.sRedirectUrl = location.pathname.substring(7) + location.search;
			if ( Credentials.bMOBILE_CLIENT )
			{
				if ( StartsWith(this.sRedirectUrl, '/android_asset/www') )
				{
					this.sRedirectUrl = this.sRedirectUrl.substring(18);
				}
				if ( this.sRedirectUrl == '/index.html' )
				{
					this.sRedirectUrl = '';
				}
			}
		}
		if ( this.sRedirectUrl == '' )
		{
			this.sRedirectUrl = '/Home';
		}
		if ( SplendidCache.IsInitialized )
		{
			// 08/05/2019 Paul.  Try and replace the /Reset so that the back button will work properly. 
			history.replace(this.sRedirectUrl);
		}
		else
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount Start', location.pathname);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount sRedirectUrl', this.sRedirectUrl);
			let status = await SplendidUI_Init('ReloadView ' + this.sRedirectUrl);
			//SplendidCache.VerifyReactState();
			if ( status )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount Done', this.sRedirectUrl);
				//let status = await IsAuthenticated('ReloadView.componentDidMount');
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount IsAuthenticated', status);
				// 06/28/2019 Paul.  Still having an issue whereby terminology is not fully loaded before we redirect.  Try to bounce through reset. 
				// 08/05/2019 Paul.  Try and replace the /Reset so that the back button will work properly. 
				// 11/03/2021 Paul.  It is not worth the effort to try to run the Admin Wizard, so keep that code in ASP.Net code. 
				//if ( Security.IS_ADMIN() && Sql.IsEmptyString(Crm_Config.ToString("Configurator.LastRun")) )
				//{
				//	history.replace('/Administration/Configurator');
				//}
				//else
				// 11/03/2021 Paul.  Do run the User Wizard if a new user. 
				if ( Sql.IsEmptyString(Credentials.sORIGINAL_TIMEZONE_ID) && !Crm_Config.ToBoolean("disableUserWizard") )
				{
					history.replace('/Users/Wizard');
				}
				else
				{
					history.replace('/Reset' + this.sRedirectUrl);
				}
			}
			else
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount Init returned not ready, auto-reset in 5 seconds');
				// 01/21/2020 Paul.  Give it 5 more seconds. 
				// 10/31/2021 Paul.  Reduce to 1 second, but repeat 5 times. 
				this.resetCount = 0;
				this.timerID = setInterval(this.ResetTimer, 1000);
			}
		}
	}

	componentWillUnmount()
	{
		if ( this.timerID != null )
		{
			clearInterval(this.timerID);
		}
	}

	ResetTimer = () =>
	{
		const { history } = this.props;
		this.resetCount++;
		// 10/31/2021 Paul.  Reduce to 1 second, but repeat 5 times. 
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.ReseTimer', this.resetCount, SplendidCache.IsInitialized);
		if ( this.resetCount >= 5 || SplendidCache.IsInitialized )
		{
			clearInterval(this.timerID);
			this.timerID = null;
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.ReseTimer sORIGINAL_TIMEZONE_ID', Credentials.sORIGINAL_TIMEZONE_ID);
			// 11/03/2021 Paul.  It is not worth the effort to try to run the Admin Wizard, so keep that code in ASP.Net code. 
			//if ( SplendidCache.IsInitialized && Security.IS_ADMIN() && Sql.IsEmptyString(Crm_Config.ToString("Configurator.LastRun")) )
			//{
			//	history.replace('/Administration/Configurator');
			//}
			//else
			// 11/03/2021 Paul.  Do run the User Wizard if a new user. 
			if ( SplendidCache.IsInitialized && Sql.IsEmptyString(Credentials.sORIGINAL_TIMEZONE_ID) && !Crm_Config.ToBoolean("disableUserWizard") )
			{
				history.replace('/Users/Wizard');
			}
			else
			{
				history.replace('/Reset' + this.sRedirectUrl);
			}
		}
	}

	public render()
	{
		const { history, location } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', location.pathname);
		return (
		<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
			<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
		</div>);
	}
}

export default withRouter(ReloadView);
