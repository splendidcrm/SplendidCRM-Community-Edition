/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// CANNOT READ PROPERTIES OF NULL (READING 'USECONTEXT')
//export { SplendidHistory, RouteComponentProps, withRouter, Link, Route, Navigate } from 'splendid-router-dom';

// 1. React and fabric. 
import * as React from 'react';
import { useLocation, useNavigate, useParams, useMatches } from  'react-router-dom';
// 2. Store and Types. 
// 3. Scripts. 
import { StartsWith, EndsWith }                            from './scripts/utility';

declare global
{
  interface Window
  {
    splendidBaseUrl: string;
    reactHistory: SplendidHistory;
  }
}

// 12/30/2023 Paul.  Create Router V5 wrapper to minimize code changes during upgrade. 
export interface RouteComponentProps<T> {
	location?: ReturnType<typeof useLocation>;
	params?  : Record<string, string>;
	navigate?: ReturnType<typeof useNavigate>;
	match?   : ReturnType<typeof useMatches>;
	history? : any;
	// 01/15/2024 Paul.  children is not longer automatically included. 
	children?: React.ReactNode;
	// 02/03/2024 Paul.  Use alternate name for ref to allow forwarding. 
	// https://gist.github.com/gaearon/1a018a023347fe1c2476073330cc5509
	withRef? : React.RefObject<any>;
}

export class SplendidHistory
{
	private navigate: ReturnType<typeof useNavigate>;

	public constructor(navigate: ReturnType<typeof useNavigate>)
	{
		this.navigate = navigate;
	}
	
	public push(to: string)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.push', to);
		this.navigate(to, { relative: 'route', replace: false, unstable_flushSync: true, unstable_viewTransition: true });
		let url = window.splendidBaseUrl + to;
		if ( EndsWith(window.splendidBaseUrl, '/') && StartsWith(to, '/') )
		{
			url = window.splendidBaseUrl + to.substr(1);
		}
		window.reactHistory.push(url);
	}
	
	public replace(to: string)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.replace', to);
		this.navigate(to, { relative: 'route', replace: true, unstable_flushSync: true, unstable_viewTransition: true });
		let url = window.splendidBaseUrl + to;
		if ( EndsWith(window.splendidBaseUrl, '/') && StartsWith(to, '/') )
		{
			url = window.splendidBaseUrl + to.substr(1);
		}
		window.reactHistory.replace(url);
	}
}

export const withRouter = <Props extends RouteComponentProps<any>>(Component: React.ComponentClass<Props>) => {
	return (props: Props) => {
		//console.log('withRouter start: ' + Component.name, props, Component);
		let location: any = { pathname: ''};
		let navigate: any = function(to: string, options: any) { console.log('withRouter Dummy navigate: ', to); };
		let match   : any = [];
		// 02/11/2024 Paul.  use of ...params in withRouter() is causing router params to overwrite existing properties of sub-components. 
		// Encountered this problem with BusinessProcessEditView DynamicPopupView. 
		// 02/11/2024 Paul.  Non-page view should not include params as it will overwrite MODULE_NAME. 
		let params  : any = null;
		const sComponentName: string = Component.name;
		// 04/03/2024 Paul.  Must include all components that use query parameters. 
		if ( EndsWith(sComponentName, 'View') || sComponentName == 'DashboardEditor' || sComponentName == 'UnifiedSearch' )
		{
			// 02/11/2024 Paul.  SearchView and QuickCreate cannot accept parameters, otherwise embedded EditView will try to load item. 
			let isSearchView  = false;
			let isQuickCreate = false;
			if ( sComponentName == 'DynamicEditView' )
			{
				isSearchView  = (props as any).isSearchView ;
				isQuickCreate = (props as any).isQuickCreate;
			}
			if ( !isSearchView
			  && !isQuickCreate
			  && sComponentName.indexOf('PopupView'   ) < 0
			  && sComponentName.indexOf('SubPanelView') < 0
			   )
			{
				params = useParams();
				//console.log('withRouter useParams', sComponentName);
			}
		}
		try
		{
			location = useLocation();
		}
		catch(e)
		{
			console.error('withRouter location:', e, params, location, navigate, match);
		}
		try
		{
			navigate = useNavigate();
		}
		catch(e)
		{
			console.error('withRouter navigate:', e, params, location, navigate, match);
		}
		try
		{
			match    = useMatches();
		}
		catch(e)
		{
			console.error('withRouter match:', e, params, location, navigate, match);
		}
		// 01/21/2024. Paul.  Convert history.push() to navigate() to avoid having to change 300 files. 
		const history: SplendidHistory = new SplendidHistory(navigate);
		//console.log('withRouter final: ', Component.name, params, location);
		// 02/11/2024 Paul.  Experimenting with properties replacing params. 
		return (
			<Component
				{ ...params }
				{ ...(props as Props) }
				history={ history }
				location={ location }
				params={ params }
				navigate={ navigate }
				match={ match }
				ref={ props.withRef }
			/>
		);
	};
};

export { Link, Route, Navigate } from  'react-router-dom';
