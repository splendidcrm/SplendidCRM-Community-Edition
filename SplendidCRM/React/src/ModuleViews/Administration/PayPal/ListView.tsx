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
import moment from 'moment';
import { RouteComponentProps, withRouter }          from '../Router5'                     ;
import { observer }                                 from 'mobx-react'                           ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'       ;
// 2. Store and Types. 
import MODULE                                       from '../../../types/MODULE'                ;
import { HeaderButtons }                            from '../../../types/HeaderButtons'         ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                 ;
import L10n                                         from '../../../scripts/L10n'                ;
import Security                                     from '../../../scripts/Security'            ;
import Credentials                                  from '../../../scripts/Credentials'         ;
import SplendidCache                                from '../../../scripts/SplendidCache'       ;
import SplendidDynamic                              from '../../../scripts/SplendidDynamic'     ;
import { EditView_LoadLayout }                      from '../../../scripts/EditView'            ;
import { Crm_Config, Crm_Modules }                  from '../../../scripts/Crm'                 ;
import { Admin_GetReactState }                      from '../../../scripts/Application'         ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'               ;
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'     ;
// 4. Components and Views. 
import SplendidGrid                                 from '../../../components/SplendidGrid'     ;
import SearchTabs                                   from '../../../components/SearchTabs'       ;
import ErrorComponent                               from '../../../components/ErrorComponent'   ;
import ExportHeader                                 from '../../../components/ExportHeader'     ;
import SearchView                                   from '../../../views/SearchView'            ;
import DynamicMassUpdate                            from '../../../views/DynamicMassUpdate'     ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';

const MODULE_NAME: string = 'PayPal';

interface IAdminListViewProps extends RouteComponentProps<any>
{
	RELATED_MODULE?       : string;
	GRID_NAME?            : string;
	TABLE_NAME?           : string;
	SORT_FIELD?           : string;
	SORT_DIRECTION?       : string;
	callback?             : Function;
	rowRequiredSearch?    : any;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IAdminListViewState
{
	searchLayout          : any;
	advancedLayout        : any;
	searchTabsEnabled     : boolean;
	duplicateSearchEnabled: boolean;
	searchMode            : string;
	showUpdatePanel       : boolean;
	enableMassUpdate      : boolean;
	selectedItems?        : any;
	error?                : any;
	rowDefaultSearch?     : any;
	// 04/09/2022 Paul.  Hide/show SearchView. 
	showSearchView        : string;
}

@observer
class PayPalListView extends React.Component<IAdminListViewProps, IAdminListViewState>
{
	private _isMounted = false;
	private searchView   = React.createRef<SearchView>();
	private splendidGrid = React.createRef<SplendidGrid>();
	private updatePanel  = React.createRef<DynamicMassUpdate>();
	private headerButtons = React.createRef<HeaderButtons>();

	constructor(props: IAdminListViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor');

		let dtTODAY: moment.Moment = moment();
		dtTODAY.hours(0);
		dtTODAY.minutes(0);
		dtTODAY.seconds(0);
		dtTODAY.milliseconds(0);

		let rowDefaultSearch: any = {};
		rowDefaultSearch.END_DATE   = dtTODAY.clone();
		rowDefaultSearch.START_DATE = dtTODAY.add(-7, 'days');
		// 04/09/2022 Paul.  Hide/show SearchView. 
		let showSearchView: string = 'show';
		if ( SplendidCache.UserTheme == 'Pacific' )
		{
			showSearchView = localStorage.getItem(this.constructor.name + '.showSearchView');
			if ( Sql.IsEmptyString(showSearchView) )
				showSearchView = 'hide';
		}
		this.state =
		{
			searchLayout          : null,
			advancedLayout        : null,
			searchTabsEnabled     : false,
			duplicateSearchEnabled: false,
			searchMode            : 'Basic',
			showUpdatePanel       : false,
			enableMassUpdate      : Crm_Modules.MassUpdate(MODULE_NAME),
			error                 : null,
			rowDefaultSearch      ,
			showSearchView        ,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				// 07/06/2020 Paul.  Admin_GetReactState will also generate an exception, but catch anyway. 
				if ( !(Security.IS_ADMIN() || SplendidCache.AdminUserAccess(MODULE_NAME, 'list') >= 0) )
				{
					throw(L10n.Term('.LBL_INSUFFICIENT_ACCESS'));
				}
				// 10/27/2019 Paul.  In case of single page refresh, we need to make sure that the AdminMenu has been loaded. 
				if ( SplendidCache.AdminMenu == null )
				{
					await Admin_GetReactState(this.constructor.name + '.componentDidMount');
				}
				if ( !Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(true);
				}
				// 10/30/2019 Paul.  Must wait until we get the admin menu to get the module. 
				// 02/02/2020 Paul.  Ignore missing during DynamicLayout. 
				let searchLayout   : any = EditView_LoadLayout(MODULE_NAME + '.SearchBasic'     , true);
				let advancedLayout : any = EditView_LoadLayout(MODULE_NAME + '.SearchAdvanced'  , true);
				let duplicateLayout: any = EditView_LoadLayout(MODULE_NAME + '.SearchDuplicates', true);
				let module         : MODULE  = SplendidCache.Module(MODULE_NAME, this.constructor.name + '.componentDidMount');
				let showUpdatePanel: boolean = false;
				if ( module == null )
				{
					console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount' + MODULE_NAME + ' not found or accessible.');
				}
				// 11/22/2020 Paul.  Missing else. 
				else
				{
					showUpdatePanel = module.MASS_UPDATE_ENABLED;
				}
				document.title = L10n.Term(MODULE_NAME + ".LBL_LIST_FORM_TITLE");
				// 04/26/2020 Paul.  Reset scroll every time we set the title. 
				window.scroll(0, 0);
				this.setState(
				{
					searchLayout          ,
					advancedLayout        ,
					searchTabsEnabled     : !!advancedLayout,
					duplicateSearchEnabled: !!duplicateLayout,
					showUpdatePanel
				});
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

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	private _onComponentComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data): void => 
	{
		const { error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + LAYOUT_NAME, data);
		if ( this.props.onComponentComplete )
		{
			if ( error == null )
			{
				let vwMain = null;
				this.props.onComponentComplete(MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data);
			}
		}
	}

	private _onSearchTabChange = (key) =>
	{
		// 04/09/2022 Paul.  Hide/show SearchView. 
		if ( key == 'Hide' )
		{
			let { showSearchView } = this.state;
			showSearchView = 'hide';
			localStorage.setItem(this.constructor.name + '.showSearchView', showSearchView);
			this.setState({ showSearchView });
		}
		else
		{
			// 11/03/2020 Paul.  When switching between tabs, re-apply the search as some advanced settings may not have been applied. 
			this.setState( {searchMode: key}, () =>
			{
				if ( this.searchView.current != null )
				{
					this.searchView.current.SubmitSearch();
				}
			});
		}
	}

	// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
	private _onSearchViewCallback = (sFILTER: string, row: any, oSORT?: any) =>
	{
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback');
		// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
		if ( this.splendidGrid.current != null )
		{
			this.splendidGrid.current.Search(sFILTER, row, oSORT);
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
	}

	private _onGridLayoutLoaded = () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGridLayoutLoaded');
		// 05/08/2019 Paul.  Once we have the Search callback, we can tell the SearchView to submit and it will get to the GridView. 
		// 07/13/2019 Paul.  Call SubmitSearch directly. 
		// 07/15/2023 Paul.  Dont' need to search twice. 
		/*
		if ( this.searchView.current != null )
		{
			this.searchView.current.SubmitSearch();
		}
		else if ( this.splendidGrid.current != null )
		{
			this.splendidGrid.current.Search(null, null);
		}
		*/
	}

	private _onSelectionChanged = (value: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged: ' + MODULE_NAME, value);
		this.setState({ selectedItems: value }, () =>
		{
			if ( this.updatePanel.current != null )
			{
				this.updatePanel.current.SelectionChanged(value);
			}
		});
	}

	private _onUpdateComplete = (sCommandName) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdateComplete: ' + MODULE_NAME, sCommandName);
		if ( this.searchView.current != null )
		{
			// 04/26/2020 Paul.  Clear selection after update. 
			if ( sCommandName == 'MassDelete' || sCommandName == 'MassUpdate' )
			{
				if ( this.splendidGrid.current != null )
				{
					this.splendidGrid.current.onDeselectAll(null);
				}
			}
			this.searchView.current.SubmitSearch();
		}
	}

	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	private _onHyperLinkCallback = (MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any) =>
	{
		const { history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback: ' + MODULE_NAME, ID);
		if ( !Sql.IsEmptyString(URL) )
		{
			history.push(URL);
		}
		else
		{
			let admin: string = '';
			let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onHyperLinkCallback');
			if ( module.IS_ADMIN )
			{
				admin = '/Administration';
			}
			history.push(`/Reset${admin}/${MODULE_NAME}/View/${ID}`);
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
			case 'Create':
			{
				let admin: string = '';
				let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onHyperLinkCallback');
				if ( module.IS_ADMIN )
				{
					admin = '/Administration';
				}
				history.push(`/Reset${admin}/${MODULE_NAME}/Edit`);
				break;
			}
			// 04/09/2022 Paul.  Hide/show SearchView. 
			case 'toggleSearchView':
			{
				let showSearchView: string = (this.state.showSearchView == 'show' ? 'hide' : 'show');
				localStorage.setItem(this.constructor.name + '.showSearchView', showSearchView);
				this.setState({ showSearchView });
				break;
			}
			default:
			{
				if ( this._isMounted )
				{
					this.setState( {error: sCommandName + ' is not supported at this time'} );
				}
				break;
			}
		}
	}

	private _onExport = async (EXPORT_RANGE: string, EXPORT_FORMAT: string) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onExport', EXPORT_RANGE, EXPORT_FORMAT);
		if ( this._isMounted )
		{
			if ( this.splendidGrid.current != null )
			{
				this.splendidGrid.current.ExportModule(EXPORT_RANGE, EXPORT_FORMAT);
			}
		}
	}

	private Grid_Command = async (sCommandName: string, sCommandArguments: any) =>
	{
		// 11/11/2020 Paul.  We need to send the grid sort event to the SearchView. 
		if ( sCommandName == 'sort' )
		{
			if ( this.searchView.current != null && sCommandArguments != null )
			{
				this.searchView.current.UpdateSortState(sCommandArguments.sortField, sCommandArguments.sortOrder);
			}
		}
		else if ( this.updatePanel.current != null )
		{
			this.updatePanel.current.Page_Command(sCommandName, sCommandArguments);
		}
	}

	private Load = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load', rowSEARCH_VALUES);
		if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
		{
			sSORT_FIELD     = '';
			sSORT_DIRECTION = '';
		}
		let json: any = {};
		json.d = {};
		json.d.__total = 0;
		json.d.__sql   = null;
		json.d.results = [];
		// 07/15/2023 Paul.  PayPal does not have an enabled flag. ClientID and ClientSecret are used to determine if enabled. 
		//if ( Crm_Config.ToBoolean(MODULE_NAME + '.Enabled') )
		{
			let obj = new Object();
			obj['$top'         ] = nTOP            ;
			obj['$skip'        ] = nSKIP           ;
			obj['$orderby'     ] = sSORT_FIELD + ' ' + sSORT_DIRECTION;
			obj['$select'      ] = sSELECT         ;
			obj['$filter'      ] = sFILTER         ;
			obj['$searchvalues'] = rowSEARCH_VALUES;
			let sBody: string = JSON.stringify(obj);
			let res = await CreateSplendidRequest('Administration/PayPalTransactions/Rest.svc/Transactions', 'POST', 'application/octet-stream', sBody);
			
			json = await GetSplendidResult(res);
			json.d.__total = json.__total;
			json.d.__sql = json.__sql;
			for ( let i: number = 0; i < json.d.results.length; i++ )
			{
				let row: any = json.d.results[i];
				row.ID = row['TRANSACTION_ID'];
			}
		}
		return (json.d);
	}

	public render()
	{
		const { RELATED_MODULE, GRID_NAME, TABLE_NAME, SORT_FIELD, SORT_DIRECTION, rowRequiredSearch } = this.props;
		const { error, searchLayout, advancedLayout, searchTabsEnabled, duplicateSearchEnabled, searchMode, showUpdatePanel, enableMassUpdate, rowDefaultSearch, showSearchView } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = '.moduleList.Home';
			let HEADER_BUTTONS: string = '';
			if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
			{
				HEADER_BUTTONS = MODULE_NAME + '.ListView';
			}
			return (
			<div>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, error, enableHelp: true, helpName: 'index', ButtonStyle: 'ModuleHeader', VIEW_NAME: HEADER_BUTTONS, Page_Command: this.Page_Command, showButtons: true, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				{ searchLayout != null || advancedLayout != null
				? <div style={ {display: (showSearchView == 'show' ? 'block' : 'none')} }>
					{ searchTabsEnabled
					? <SearchTabs
						searchMode={ searchMode }
						duplicateSearchEnabled={ duplicateSearchEnabled }
						onTabChange={ this._onSearchTabChange }
					/>
					: null
					}
					<SearchView
						key={ MODULE_NAME + '.Search' + searchMode }
						EDIT_NAME={ MODULE_NAME + '.Search' + searchMode }
						rowDefaultSearch={ rowDefaultSearch }
						AutoSaveSearch={ false }
						ShowSearchViews={ false }
						onLayoutLoaded={ this._onLayoutLoaded }
						cbSearch={ this._onSearchViewCallback }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.searchView }
					/>
				</div>
				: null
				}
				<ExportHeader
					MODULE_NAME={ MODULE_NAME }
					onExport={ this._onExport }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
				/>
				<SplendidGrid
					MODULE_NAME={ MODULE_NAME }
					RELATED_MODULE={ RELATED_MODULE }
					GRID_NAME={ GRID_NAME }
					TABLE_NAME={ TABLE_NAME }
					SORT_FIELD={ SORT_FIELD }
					SORT_DIRECTION={ SORT_DIRECTION }
					ADMIN_MODE={ true }
					AutoSaveSearch={ false }
					deferLoad={ true }
					enableExportHeader={ true }
					disableEdit={ true }
					enableSelection={ enableMassUpdate || SplendidCache.AdminUserAccess(MODULE_NAME, 'export', this.constructor.name + '.render') >= 0 }
					cbCustomLoad={ this.Load }
					onLayoutLoaded={ this._onGridLayoutLoaded }
					selectionChanged={ this._onSelectionChanged }
					hyperLinkCallback={ this._onHyperLinkCallback }
					enableMassUpdate={ enableMassUpdate }
					rowRequiredSearch={ rowRequiredSearch }
					onComponentComplete={ this._onComponentComplete }
					Page_Command={ this.Grid_Command }
					scrollable
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.splendidGrid }
				/>
				{ showUpdatePanel
				? <DynamicMassUpdate
					key={ MODULE_NAME + '.ModuleUpdate' }
					MODULE_NAME={ MODULE_NAME }
					onUpdateComplete={ this._onUpdateComplete }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.updatePanel }
					/>
				: null
				}
			</div>
			);
		}
		else if ( error )
		{
			return (<ErrorComponent error={error} />);
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

export default withRouter(PayPalListView);
