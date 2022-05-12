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
import { Appear }                          from 'react-lifecycle-appear'        ;
// 2. Store and Types. 
import IDashletProps                       from '../types/IDashletProps'        ;
// 3. Scripts. 
import Sql                                 from '../scripts/Sql'                ;
import L10n                                from '../scripts/L10n'               ;
import Security                            from '../scripts/Security'           ;
import Credentials                         from '../scripts/Credentials'        ;
import SplendidCache                       from '../scripts/SplendidCache'      ;
import { Crm_Config }                      from '../scripts/Crm'                ;
import { EditView_LoadLayout }             from '../scripts/EditView'           ;
import { ListView_LoadTable }              from '../scripts/ListView'           ;
// 4. Components and Views. 
import SplendidGrid                        from '../components/SplendidGrid'    ;
import SearchView                          from '../views/SearchView'           ;

interface IBaseMyFavoriteDashletProps extends IDashletProps
{
	MODULE_NAME          : string;
	SORT_FIELD           : string;
	SORT_DIRECTION       : string;
}

interface IBaseMyFavoriteDashletState
{
	GRID_NAME            : string;
	TABLE_NAME           : string;
	DEFAULT_SETTINGS     : any;
	optionsVisible       : boolean;
	enableSearch         : boolean;
	favoritesLoaded      : boolean;
	arrFAVORITE_RECORD_ID: string[];
}

export default class BaseMyFavoriteDashlet extends React.Component<IBaseMyFavoriteDashletProps, IBaseMyFavoriteDashletState>
{
	private _isMounted = false;
	private searchView   = React.createRef<SearchView>();
	private splendidGrid = React.createRef<SplendidGrid>();
	// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
	private themeURL   : string  = null;
	private legacyIcons: boolean = false;

	constructor(props: IBaseMyFavoriteDashletProps)
	{
		super(props);
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.themeURL    = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		let GRID_NAME: string = props.MODULE_NAME + '.My' + props.MODULE_NAME;
		let sTABLE_NAME: string = 'vw' + props.MODULE_NAME.toUpperCase() + '_MyList';
		if ( props.MODULE_NAME == 'Project' )
		{
			GRID_NAME = props.MODULE_NAME + '.My' + props.MODULE_NAME + 's';
			sTABLE_NAME = 'vw' + (props.MODULE_NAME + 's').toUpperCase() + '_MyList';
		}
		else if ( props.MODULE_NAME == 'ProjectTask' )
		{
			GRID_NAME = props.MODULE_NAME + '.My' + props.MODULE_NAME + 's';
			sTABLE_NAME = 'vwPROJECT_TASKS_MyList';
		}
		
		let objDEFAULT_SETTINGS: any = (!Sql.IsEmptyString(props.DEFAULT_SETTINGS) ? Sql.ParseFormData(props.DEFAULT_SETTINGS) : null);
		// 02/22/2020 Paul.  My Favorites does not require user assignment. 
		/*
		if ( objDEFAULT_SETTINGS === undefined || objDEFAULT_SETTINGS == null )
		{
			objDEFAULT_SETTINGS = {};
			objDEFAULT_SETTINGS.ASSIGNED_USER_ID = Security.USER_ID();
			objDEFAULT_SETTINGS.ASSIGNED_TO = Security.USER_NAME();
			objDEFAULT_SETTINGS.ASSIGNED_SET_LIST = Security.USER_ID();
			objDEFAULT_SETTINGS.ASSIGNED_SET_NAME = Security.USER_NAME();
		}
		*/
		let layout = null;
		if ( !Sql.IsEmptyString(props.SETTINGS_EDITVIEW) )
		{
			layout = EditView_LoadLayout(props.SETTINGS_EDITVIEW);
		}
		this.state =
		{
			GRID_NAME            ,
			TABLE_NAME           : sTABLE_NAME,
			DEFAULT_SETTINGS     : objDEFAULT_SETTINGS,
			optionsVisible       : false,
			enableSearch         : (layout != null),
			favoritesLoaded      : false,
			arrFAVORITE_RECORD_ID: null,
			
		}
	}

	async componentDidMount()
	{
		this._isMounted = true;
		// 07/30/2021 Paul.  Loaded when panel appears. 
		//await this.loadFavorites();
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}
	
	private loadFavorites = async (): Promise<any> =>
	{
		const { MODULE_NAME } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadFavorites ' + MODULE_NAME);
		
		let sSEARCH_FILTER = 'FAVORITE_MODULE = \'' + MODULE_NAME + '\' and FAVORITE_USER_ID = \'' + Security.USER_ID() + '\'';
		let d = await ListView_LoadTable('SUGARFAVORITES', 'FAVORITE_RECORD_ID', 'asc', 'FAVORITE_RECORD_ID', sSEARCH_FILTER, null, false);
		let arrFAVORITE_RECORD_ID = new Array();
		let rows = d.results;
		for ( var nRowIndex = 0; nRowIndex < rows.length; nRowIndex++ )
		{
			var row = rows[nRowIndex];
			arrFAVORITE_RECORD_ID.push(row['FAVORITE_RECORD_ID']);
		}
		// 06/01/2019 Paul.  The component may be unmounted by the time the custom view is generated. 
		if ( this._isMounted )
		{
			this.setState({ favoritesLoaded: true, arrFAVORITE_RECORD_ID: arrFAVORITE_RECORD_ID });
		}
	}

	private _onRefresh = async (e) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRefresh');
		await this.loadFavorites();
		// 07/13/2019 Paul.  Call SubmitSearch directly. 
		if ( this.searchView.current != null )
		{
			this.searchView.current.SubmitSearch();
		}
		else if ( this.splendidGrid.current != null )
		{
			this.splendidGrid.current.Search(null, null);
		}
	}

	private _onLayoutLoaded = () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLayoutLoaded');
		// 07/13/2019 Paul.  Call SubmitSearch directly. 
		if ( this.searchView.current != null )
		{
			this.searchView.current.SubmitSearch();
		}
		else if ( this.splendidGrid.current != null )
		{
			this.splendidGrid.current.Search(null, null);
		}
	}

	private _onSearchPreprocess = (commandText: string, row: any) =>
	{
		const { arrFAVORITE_RECORD_ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchPreprocess(): ' + commandText, row);
		// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
		if ( this.splendidGrid.current != null )
		{
			// 02/22/2020 Paul.  Filter on ID, not arrFAVORITE_RECORD_ID. 
			row.ID = arrFAVORITE_RECORD_ID;
			let sSEARCH_FILTER = commandText;
			if ( arrFAVORITE_RECORD_ID.length > 0 )
			{
				if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
					sSEARCH_FILTER += ' and ';
				sSEARCH_FILTER += 'ID in (';
				for ( var i = 0; i < arrFAVORITE_RECORD_ID.length; i++ )
				{
					if ( i > 0 )
						sSEARCH_FILTER += ', ';
					sSEARCH_FILTER += '\'' + arrFAVORITE_RECORD_ID[i] + '\'';
				}
				sSEARCH_FILTER += ')';
			}
			else
			{
				// 07/31/2017 Paul.  If there are no favorites, then we want to show nothing. 
				if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
					sSEARCH_FILTER += ' and ';
				sSEARCH_FILTER += 'ID is null';
				// 02/22/2020 Paul.  Set ID to null so that the filter will become (ID is null). 
				row.ID = null;
			}
			this.splendidGrid.current.Search(sSEARCH_FILTER, row);
		}
		else
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchPreprocess(): this.Search is not defined.');
		}
	}

	private _onGridLayoutLoaded = () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGridLayoutLoaded');
		// 05/31/2019 Paul.  Once we have the Search callback, we can tell the SearchView to submit and it will get to the GridView. 
		// 07/13/2019 Paul.  Call SubmitSearch directly. 
		if ( this.searchView.current != null )
		{
			this.searchView.current.SubmitSearch();
		}
		else if ( this.splendidGrid.current != null )
		{
			this.splendidGrid.current.Search(null, null);
		}
	}

	public render()
	{
		const { MODULE_NAME, SORT_FIELD, SORT_DIRECTION, TITLE, SETTINGS_EDITVIEW } = this.props;
		const { GRID_NAME, TABLE_NAME, DEFAULT_SETTINGS, optionsVisible, enableSearch, favoritesLoaded } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + MODULE_NAME, SETTINGS_EDITVIEW, DEFAULT_SETTINGS);
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		// 01/06/2021 Paul.  AutoSaveSearch enabled. 
		// 07/30/2021 Paul.  Load when the panel appears. 
		return (
		<div style={ {display: 'flex', flexGrow: 1} }>
			<div className="card" style={ {flexGrow: 1, margin: '.5em', overflowX: 'auto'} }>
				<Appear onAppearOnce={ (ioe) => this.loadFavorites() }>
					<div className="card-body DashletHeader">
						<h3 style={ {float: 'left'} }>{ L10n.Term(TITLE) }</h3>
						<span
							style={ {cursor: 'pointer', float: 'right', textDecoration: 'none', marginLeft: '.5em'} }
							onClick={ (e) => this._onRefresh(e) }
						>
							{ this.legacyIcons
							? <img src={ this.themeURL + 'refresh.gif'} style={ {borderWidth: '0px'} } />
							: <FontAwesomeIcon icon="sync" size="lg" />
							}
						</span>
						<span
							style={ {cursor: 'pointer', float: 'right', textDecoration: 'none', marginLeft: '.5em'} }
							onClick={ () => this.setState({ optionsVisible: !optionsVisible }) }
						>
							{ this.legacyIcons
							? <img src={ this.themeURL + 'edit.gif'} style={ {borderWidth: '0px'} } />
							: <FontAwesomeIcon icon="cog" size="lg" />
							}
						</span>
					</div>
				</Appear>
				{ favoritesLoaded
				? <div style={ {clear: 'both'} }>
					<hr />
					{ enableSearch
					? <div style={ {display: (optionsVisible ? 'inline' : 'none')} }>
						<SearchView
							key={ SETTINGS_EDITVIEW }
							EDIT_NAME={ SETTINGS_EDITVIEW }
							AutoSaveSearch={ true }
							rowDefaultSearch={ DEFAULT_SETTINGS }
							cbSearch={ this._onSearchPreprocess }
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
							ref={ this.searchView }
						/>
					</div>
					: null
					}
					<SplendidGrid
						onLayoutLoaded={ this._onGridLayoutLoaded }
						MODULE_NAME={ MODULE_NAME }
						GRID_NAME={ GRID_NAME }
						TABLE_NAME={ TABLE_NAME }
						SORT_FIELD={ SORT_FIELD }
						SORT_DIRECTION={ SORT_DIRECTION }
						ADMIN_MODE={ false }
						deferLoad={ true }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.splendidGrid }
					/>
				</div>
				: null
				}
			</div>
		</div>);
	}
}
