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
import { RouteComponentProps, withRouter }    from '../Router5'               ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome' ;
// 2. Store and Types. 
import MODULE                                 from '../types/MODULE'                ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'                 ;
import Credentials                            from '../scripts/Credentials'         ;
import SplendidCache                          from '../scripts/SplendidCache'       ;
import { Crm_Config }                         from '../scripts/Crm'                 ;
import { jsonReactState }                     from '../scripts/Application'         ;
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login';
// 4. Components and Views. 
import ErrorComponent                         from '../components/ErrorComponent'   ;
import SplendidStream                         from '../components/SplendidStream'   ;
import ModuleHeader                           from '../components/ModuleHeader'     ;
import SearchView                             from './SearchView'                   ;
import HeaderButtonsFactory                   from '../ThemeComponents/HeaderButtonsFactory';

interface IStreamViewProps extends RouteComponentProps<any>
{
	MODULE_NAME           : string;
	callback?             : Function;
}

interface IStreamViewState
{
	error?                : any;
}

class StreamView extends React.Component<IStreamViewProps, IStreamViewState>
{
	private searchView     = React.createRef<SearchView>();
	private splendidStream = React.createRef<SplendidStream>();

	constructor(props: IStreamViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props.MODULE_NAME);
		Credentials.SetViewMode('ListView');
		this.state =
		{
		};
	}

	async componentDidMount()
	{
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				if ( jsonReactState == null )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount jsonReactState is null');
				}
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
				// 08/22/2019 Paul.  This setState call seems to be critical to the loading of the grid. 
				this.setState({ error: null });
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

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	private _onSearchViewCallback = (sFILTER: string, row: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback');
		// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
		if ( this.splendidStream.current != null )
		{
			this.splendidStream.current.Search(sFILTER, row);
		}
	}

	private _onGridLayoutLoaded = () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGridLayoutLoaded');
		// 05/08/2019 Paul.  Once we have the Search callback, we can tell the SearchView to submit and it will get to the GridView. 
		// 07/13/2019 Paul.  Call SubmitSearch directly. It will fire _onSearchViewCallback with the filter. 
		if ( this.searchView.current != null )
		{
			this.searchView.current.SubmitSearch();
		}
	}

	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	private _onHyperLinkCallback = (MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any) =>
	{
		const { history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback: ' + MODULE_NAME, ID, URL);
		if ( !Sql.IsEmptyString(URL) )
		{
			history.push(URL);
		}
		else
		{
			history.push(`/Reset/${MODULE_NAME}/View/${ID}`);
		}
	}

	public render()
	{
		const { MODULE_NAME } = this.props;
		const { error } = this.state;
		if ( SplendidCache.IsInitialized )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
				<div>
					<div style={{ position: 'sticky' }}>
						{ headerButtons
						? React.createElement(headerButtons, { MODULE_NAME })
						: null
						}
						<ErrorComponent error={ error } />
						<div>
							<div className="card" style={{marginBottom: '0.5rem'}}>
								<div className="card-body">
									<SearchView
										key={ 'ActivityStream.SearchBasic' }
										EDIT_NAME={ 'ActivityStream.SearchBasic' }
										AutoSaveSearch={ Credentials.bSAVE_QUERY && Crm_Config.ToBoolean('save_query') }
										ShowSearchViews={ false }
										cbSearch={ this._onSearchViewCallback }
										history={ this.props.history }
										location={ this.props.location }
										match={ this.props.match }
										ref={ this.searchView }
									/>
								</div>
							</div> 
						 </div>
					</div>
					<SplendidStream
						onLayoutLoaded={ this._onGridLayoutLoaded }
						MODULE_NAME={ MODULE_NAME }
						hyperLinkCallback={ this._onHyperLinkCallback }
						scrollable
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.splendidStream }
					/>
				</div>
			);
		}
		else
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
			</div>);
		}
	}
}

export default withRouter(StreamView);
