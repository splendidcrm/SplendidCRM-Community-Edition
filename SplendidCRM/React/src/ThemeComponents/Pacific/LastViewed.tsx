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
import { RouteComponentProps, withRouter }  from '../Router5'                   ;
import { observer }                         from 'mobx-react'                         ;
// 2. Store and Types. 
import MODULE                               from '../../types/MODULE'                 ;
// 3. Scripts. 
import Sql                                  from '../../scripts/Sql'                  ;
import L10n                                 from '../../scripts/L10n'                 ;
import SplendidCache                        from '../../scripts/SplendidCache'        ;
import Credentials                          from '../../scripts/Credentials'          ;
import { Crm_Config }                       from '../../scripts/Crm'                  ;
import { StartsWith, ActiveModuleFromPath } from '../../scripts/utility'              ;
// 4. Components and Views.

interface ILastViewedProps extends RouteComponentProps<any>
{
}

interface ILastViewedState
{
	bIsAuthenticated   : boolean;
	nHistoryMaxViewed? : number;
	activeModule       : string;
}

@observer
class ArcticLastViewed extends React.Component<ILastViewedProps, ILastViewedState>
{
	constructor(props: ILastViewedProps)
	{
		super(props);
		let activeModule: string = ActiveModuleFromPath(this.props.location.pathname, this.constructor.name + '.constructor');
		this.state =
		{
			bIsAuthenticated   : false,
			nHistoryMaxViewed  : 10,
			activeModule       ,
		};
	}

	async componentDidMount()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount');
		// 05/28/2019 Paul.  Use a passive IsAuthenticated check (instead of active server query), so that we do not have multiple simultaneous requests. 
		let bAuthenticated: boolean = Credentials.bIsAuthenticated;
		if ( !bAuthenticated )
		{
			// 05/02/2019 Paul.  Each view will be responsible for checking authenticated. 
		}
		else
		{
			// 05/29/2019 Paul.  We can't get these values in the constructor as the user may not be authenticated and therefore would not exist. 
			this.setState({ bIsAuthenticated: bAuthenticated });
		}
	}

	async componentDidUpdate(prevProps: ILastViewedProps)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', this.props.location.pathname, prevProps.location.pathname, txtQuickSearch);
		// 12/10/2019 Paul.  With a deep link, the cache will not be loaded, so the activeModule will not be set. 
		if ( this.props.location.pathname != prevProps.location.pathname || Sql.IsEmptyString(this.state.activeModule) )
		{
			let activeModule: string = ActiveModuleFromPath(this.props.location.pathname, this.constructor.name + '.componentDidUpdate');
			if ( activeModule != this.state.activeModule )
			{
				this.setState({ activeModule });
			}
		}
	}

	async componentWillUpdate(nextProps: ILastViewedProps)
	{
		const { bIsAuthenticated } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentWillUpdate', this.props.location.pathname, nextProps.location.pathname, txtQuickSearch);
		// 05/28/2019 Paul.  Use a passive IsAuthenticated check (instead of active server query), so that we do not have multiple simultaneous requests. 
		// 05/28/2019 Paul.  Track the authentication change so that we an clear the menus appropriately. 
		let bAuthenticated: boolean = Credentials.bIsAuthenticated;
		if ( bIsAuthenticated != bAuthenticated )
		{
			let nHistoryMaxViewed = Crm_Config.ToInteger('history_max_viewed');
			if ( nHistoryMaxViewed == 0 )
			{
				nHistoryMaxViewed = 10;
			}
			this.setState(
			{
				bIsAuthenticated : bAuthenticated, 
				nHistoryMaxViewed: nHistoryMaxViewed,
			});
		}
	}

	private _onLastViewed = (item) =>
	{
		const { activeModule } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLastViewed ' + sMODULE_NAME, item);
		let module:MODULE = SplendidCache.Module(activeModule, this.constructor.name + '._onLastViewed');
		if ( module.IS_ADMIN )
			this.props.history.push('/Reset/Administration/' + activeModule + '/View/' + item.ID)
		else
			this.props.history.push('/Reset/' + activeModule + '/View/' + item.ID)
	}

	public render()
	{
		const { bIsAuthenticated, activeModule, nHistoryMaxViewed } = this.state;
	
		//03/06/2019. Chase. Referencing ADMIN_MODE triggers re-renders when it's updated;
		Credentials.ADMIN_MODE;
		// 04/29/2019 Paul.  When LastViewed, LAST_VIEWED or SAVED_SEARCH changes, increment this number.  It is watched in the LastViewed. 
		SplendidCache.NAV_MENU_CHANGE;

		let links = [];
		let bLoading = StartsWith(this.props.location.pathname, '/Reload');
		if ( SplendidCache.IsInitialized && bIsAuthenticated && !bLoading )
		{
			links = SplendidCache.LastViewed(activeModule);
			if ( links === undefined || links == null )
				return [];
			if ( links.length > nHistoryMaxViewed )
				links = links.slice(0, nHistoryMaxViewed);
		}
		return SplendidCache.IsInitialized && (
			<div id='divLastViewed' className='lastView' style={ {width: '100%'} }>
				<h1><span>{ L10n.Term('.LBL_LAST_VIEWED') }</span></h1>
				{
					links && links.map((item) => 
					(
						<div className='lastViewRecentViewed' style={ {cursor: 'pointer'} } onClick={ (e) => this._onLastViewed(item) }>
							<a key={ 'last_' + item.ID } href='#' title={ item.NAME } className='lastViewLink' onClick={ (e) => { e.preventDefault(); this._onLastViewed(item); } }>{ item.NAME }</a>
						</div>
					))
				}
			</div>
		);
	}
}

export default withRouter(ArcticLastViewed);

