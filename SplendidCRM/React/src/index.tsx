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
// 02/26/2022 Paul.  Remove core-js as we don't seem to be using any of its features. 
// 02/26/2022 Paul.  Remove react-hot-loader as we do not need hot loading and it should not be used in production. 
// 02/26/2022 Paul.  Remove whatwg-fetch as it is no londer needed as we require latest browsers. 
import React                                       from 'react'                  ;
import ReactDOM                                    from 'react-dom/client'       ;
import { createBrowserRouter, RouterProvider, redirect }     from  'react-router-dom'      ;
import { resetRoutes, publicRoutes, privateRoutes, cleanupRoutes, redirectRoutes, SplendidRedirect, SplendidRoute }  from './routes';
import { Provider }                                from 'mobx-react'             ;
import { RouterStore, syncHistoryWithStore }       from 'mobx-react-router'      ;
import { createBrowserHistory, createHashHistory } from 'history'                ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                         from './scripts/Sql'          ;
import Credentials                                 from './scripts/Credentials'  ;
import SplendidCache                               from './scripts/SplendidCache';
import { StartsWith, EndsWith }                    from './scripts/utility'      ;
import SignalRStore                                from './SignalR/SignalRStore' ;
// 4. Components and Views. 
import App                                         from './App'                  ;
import PrivateRoute                                from './PrivateRoute'         ;
import PublicRouteFC                               from './PublicRouteFC'        ;
import RedirectView                                from './views/RedirectView'   ;
// 5. Styles and Themes. 
import 'bootstrap/dist/css/bootstrap.min.css';
import 'react-bootstrap-table-next/dist/react-bootstrap-table2.min.css';
import 'react-bootstrap-table2-paginator/dist/react-bootstrap-table2-paginator.min.css';
import 'react-treeview/react-treeview.css';
// 09/10/2019 Paul.  This style is required to get the model popups to fill the screen. 
import './styles/gentelella/custom.css';
import './index.scss';

declare global
{
	interface Document
	{
		components: any;
		getComponentById(id: string);
	}
	interface Window
	{
		[key: string]: any;
	}
}


Credentials.LoadCredentials();

const routingStore = new RouterStore();
let baseUrl = '/';
if (document.getElementsByTagName('base')[0])
{
	baseUrl = document.getElementsByTagName('base')[0].getAttribute('href');
}
console.log((new Date()).toISOString() + ' ' + 'baseUrl = ' + baseUrl);
let history = null;
// 11/12/2020 Paul.  iOS issue: Blocked attempt to use history.pushState() to chante session history from URL. 
// 11/14/2020 Paul.  If you are using react-router, make sure you use the HashRouter and not the BrowserRouter, 
// since the UIWebView loads via the file system, push state will not work and will result is file not found.
// https://gist.github.com/twilson63/f32d798bc8aaed6a020011f4a1543e20
if ( window.cordova && window.cordova.platformId == 'ios' )
{
	history = syncHistoryWithStore(createHashHistory(), routingStore);
}
else
{
	history = syncHistoryWithStore(createBrowserHistory(), routingStore);
}

let sRemoteServer = '';
// 07/01/2023 Paul.  ASP.NET Core will not have /React in the base. 
let sReactBase    = '';
if ( baseUrl.toLowerCase().indexOf('/react') >= 0 )
{
	sReactBase = 'React/';
}
// 10/12/2019 Paul.  Include query string to allow deep links. 
let pathname = window.location.pathname + window.location.search;
//console.log((new Date()).toISOString() + ' ' + 'window.location', window.location);
//console.log((new Date()).toISOString() + ' ' + 'window.location.pathname = ' + window.location.pathname);
//console.log((new Date()).toISOString() + ' ' + 'window.location.hash = ' + window.location.hash);
if ( EndsWith(pathname, 'default.aspx') )
{
	pathname = pathname.substring(0, pathname.indexOf('default.aspx', 1));
}
// 11/12/2020 Paul.  Detect iOS. 
if ( window.location.pathname.indexOf('/www/index.html') > 0 || ( window.cordova && (window.cordova.platformId == 'android' || window.cordova.platformId == 'ios' || window.location.pathname == '/android_asset/www/index.html')) )
{
	pathname      = '';
	sRemoteServer = '';
	//console.log((new Date()).toISOString() + ' index.tsx Android');
}
else if ( process.env.PATH )
{
	//console.log((new Date()).toISOString() + ' ' + 'process.env.PATH = ' + process.env.PATH);
	pathname = process.env.PATH;
	sRemoteServer = pathname.substring(0, pathname.indexOf('/', 1) + 1);
}
// 05/21/2023 Paul.  SplendidApp uses ASP.Net Core and will not have /React in the URL. 
// 09/20/2023 Paul.  Start at position 0, otherwise ASP.Net 4.8 apps with site at root will fail. 
else if ( pathname.toLowerCase().indexOf('/react', 0) >= 0 )
{
	// 04/28/2020 Paul.  Allow for /react, or other case issues. 
	sRemoteServer = window.location.origin + pathname.substring(0, pathname.toLowerCase().indexOf('/react', 0) + 1);
}
else
{
	// 05/21/2023 Paul.  baseUrl is working with SplendidApp, so use directly. 
	sRemoteServer = window.location.origin + baseUrl;
}
// 04/28/2020 Paul.  Allow for /react, or other case issues. 
if ( StartsWith(pathname.toLowerCase(), baseUrl.toLowerCase()) )
{
	// 06/23/2019 Paul.  Keep the leading slash. 
	// 01/20/2024 paul.  history may no longer be relative. 
	//pathname = pathname.substring(baseUrl.length - 1);
}
if ( !EndsWith(sRemoteServer, '/') )
{
	sRemoteServer += '/';
}
if ( Credentials.bMOBILE_CLIENT )
{
	sRemoteServer = '';
}
//console.log((new Date()).toISOString() + ' index.tsx ' + 'pathname', pathname);
//console.log((new Date()).toISOString() + ' index.tsx ' + 'sRemoteServer', sRemoteServer);
Credentials.SetREMOTE_SERVER(sRemoteServer);
// 07/01/2023 Paul.  ASP.NET Core will not have /React in the base. 
Credentials.SetREACT_BASE(sReactBase);

const sLastActiveModule: string = Sql.ToString(localStorage.getItem('ReactLastActiveModule'));
// 06/14/2019 Paul.  Ignore LastActiveModule if deep URL provided. 
// 11/12/2020 Paul.  iOS issue: Blocked attempt to use history.pushState() to chante session history from URL. 
try
{
	if ( !Sql.IsEmptyString(pathname) )
	{
		console.log((new Date()).toISOString() + ' ' + 'Starting at ' + pathname);
		// 06/22/2019 Paul.  Routing should be automatic. 
		if ( pathname.toLowerCase() == '/login' && StartsWith(window.location.hash, '#id_token') )
		{
			//console.log('index.tsx: ADAL Login with ' + window.location.hash);
			//history.push(pathname + window.location.hash);
		}
		// 11/06/2019 Paul.  Multiple entry points will use #id_token, so don't filter pathname. 
		else if ( StartsWith(window.location.hash, '#id_token') )
		{
			//console.log('index.tsx: ADAL Authenticate with ' + window.location.hash);
			history.push(pathname + window.location.hash);
		}
		else if ( !StartsWith(pathname, '/Reload') )
		{
			//console.log('index.tsx: ' + pathname);
			// 05/22/2023 Paul.  We are having an issue of the pathname being treated as a module name.  It only seems to happen with url http://localhost/SplendidCRM
			if ( pathname + '/' == baseUrl )
			{
				// 04/26/2024 Paul.  Core is not redirecting properly this early. 
				if ( pathname.toLowerCase().indexOf('/react', 0) >= 0 )
				{
					history.push('/Home');
				}
				else
				{
					history.push(pathname + '/Home');
				}
			}
			else
				history.push(pathname);
		}
	}
	else if ( !Sql.IsEmptyString(sLastActiveModule) )
	{
		//console.log('index.tsx: Starting at Last Active Module ' + sLastActiveModule);
		// 05/30/2019 Paul.  Experiment with returning to the same location, no matter how deep. 
		// 05/22/2023 Paul.  We are having an issue of the sLastActiveModule being treated as a module name.  It only seems to happen with url http://localhost/SplendidCRM
		if ( sLastActiveModule + '/' == baseUrl )
			history.push('/Home');
		else
			history.push(sLastActiveModule);
	}
	else
	{
		//console.log('index.tsx: Starting at Home ');
		history.push('/Home');
	}
}
catch(e)
{
	alert(e.message);
}

const stores =
{
	routing      : routingStore ,
	credentials  : Credentials  ,
	splendidCache: SplendidCache,
	signalRStore : SignalRStore ,
};

// https://www.telerik.com/blogs/react-basics-how-to-use-react-router-v6
const redirects_direct = redirectRoutes().map((r: SplendidRedirect) =>
{
	return {
		path: r.from,
		loader: () =>
		{
			console.log((new Date()).toISOString() + ' redirecting: ', r.to);
			redirect(r.to);
		}
	};
});
const redirects = redirectRoutes().map((r: SplendidRedirect) =>
{
	return {
		path: r.from,
		element: <RedirectView from={ r.from } to={ r.to } />,
	};
});
//console.log((new Date()).toISOString() + ' redirects', redirects);
const privates = privateRoutes().map((r: SplendidRoute) =>
{
	return {
		path: r.path,
		element: <PrivateRoute />,
		children: [r]
	};
});
const publics = publicRoutes().map((r: SplendidRoute) =>
{
	return {
		path: r.path,
		element: <PublicRouteFC />,
		children: [r]
	};
});


const allRoutes = [
	...resetRoutes(),
	...redirects,
	...privates,
	...publics,
	...cleanupRoutes(),
];
//console.log((new Date()).toISOString() + ' allRoutes', allRoutes);

// https://reactrouter.com/en/main/upgrading/v6-data
const router = createBrowserRouter(allRoutes, { basename: baseUrl });
window.splendidBaseUrl = baseUrl;
window.reactHistory = history;

function render()
{
	const root = ReactDOM.createRoot(document.getElementById('root')!);
	root.render(
		<Provider {...stores}>
			<App>
				<RouterProvider router={ router } />
			</App>
		</Provider>
	);
}

if (!window.cordova)
{
	render();
}
else
{
	document.addEventListener('deviceready', render, false);
	// 03/05/2022 Paul.  divFooterCopyright is not flowing below content on Android, so just hide. 
	window.onload = function()
	{
		let divFooterCopyright = document.getElementById('divFooterCopyright');
		if ( divFooterCopyright )
		{
			divFooterCopyright.style.display = 'none';
		}
	}
}
