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
// 4. Components and Views. 
import SplendidGrid                        from '../components/SplendidGrid'    ;
import SearchView                          from '../views/SearchView'           ;

const MODULE_NAME   : string = 'Calls';
const GRID_NAME     : string = MODULE_NAME + '.My' + MODULE_NAME;
const TABLE_NAME    : string = 'vw' + MODULE_NAME.toUpperCase() + '_MyList';
const SORT_FIELD    : string = 'DATE_START';
const SORT_DIRECTION: string = 'desc';

interface IMyCallsState
{
	DEFAULT_SETTINGS : any;
	optionsVisible   : boolean;
	enableSearch     : boolean;
	dashletVisible   : boolean;
}

export default class MyCalls extends React.Component<IDashletProps, IMyCallsState>
{
	private searchView   = React.createRef<SearchView>();
	private splendidGrid = React.createRef<SplendidGrid>();
	// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
	private themeURL   : string  = null;
	private legacyIcons: boolean = false;

	constructor(props: IDashletProps)
	{
		super(props);
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.themeURL    = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		let objDEFAULT_SETTINGS: any = (!Sql.IsEmptyString(props.DEFAULT_SETTINGS) ? Sql.ParseFormData(props.DEFAULT_SETTINGS) : null);
		if ( objDEFAULT_SETTINGS === undefined || objDEFAULT_SETTINGS == null )
		{
			objDEFAULT_SETTINGS = {};
			objDEFAULT_SETTINGS.ASSIGNED_USER_ID = Security.USER_ID();
			objDEFAULT_SETTINGS.ASSIGNED_TO = Security.USER_NAME();
			objDEFAULT_SETTINGS.ASSIGNED_SET_LIST = Security.USER_ID();
			objDEFAULT_SETTINGS.ASSIGNED_SET_NAME = Security.USER_NAME();
		}
		let layout = null;
		if ( !Sql.IsEmptyString(props.SETTINGS_EDITVIEW) )
		{
			layout = EditView_LoadLayout(props.SETTINGS_EDITVIEW);
		}
		this.state =
		{
			DEFAULT_SETTINGS: objDEFAULT_SETTINGS,
			optionsVisible  : false,
			enableSearch    : (layout != null),
			dashletVisible  : false,
		}
	}

	componentDidMount()
	{
	}

	private _onRefresh = async (e) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRefresh');
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

	// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
	private _onSearchViewCallback = (sFILTER: string, row: any, oSORT?: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback');
		// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
		if ( this.splendidGrid.current != null )
		{
			this.splendidGrid.current.Search(sFILTER, row, oSORT);
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
		const { TITLE, SETTINGS_EDITVIEW } = this.props;
		const { optionsVisible, enableSearch, DEFAULT_SETTINGS, dashletVisible } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', SETTINGS_EDITVIEW, DEFAULT_SETTINGS);
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		// 01/06/2021 Paul.  AutoSaveSearch enabled. 
		// 07/30/2021 Paul.  Load when the panel appears. 
		return (
		<div style={ {display: 'flex', flexGrow: 1} }>
			<div className="card" style={ {flexGrow: 1, margin: '.5em', overflowX: 'auto'} }>
				<Appear onAppearOnce={ (ioe) => this.setState({ dashletVisible: true }) }>
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
				{ dashletVisible
				? <div style={ {clear: 'both'} }>
					<hr />
					{ enableSearch
					? <div style={ {display: (optionsVisible ? 'inline' : 'none')} }>
						<SearchView
							EDIT_NAME={ SETTINGS_EDITVIEW }
							AutoSaveSearch={ true }
							rowDefaultSearch={ DEFAULT_SETTINGS }
							cbSearch={ this._onSearchViewCallback }
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
