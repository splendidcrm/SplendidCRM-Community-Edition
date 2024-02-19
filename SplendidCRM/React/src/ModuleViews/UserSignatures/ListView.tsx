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
import { RouteComponentProps, withRouter }    from '../Router5'                          ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome'            ;
// 2. Store and Types. 
import MODULE                                 from '../../types/MODULE'                        ;
import { HeaderButtons }                      from '../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                    from '../../scripts/Sql'                         ;
import L10n                                   from '../../scripts/L10n'                        ;
import Credentials                            from '../../scripts/Credentials'                 ;
import SplendidCache                          from '../../scripts/SplendidCache'               ;
import SplendidDynamic                        from '../../scripts/SplendidDynamic'             ;
import { EditView_LoadLayout }                from '../../scripts/EditView'                    ;
import { Crm_Config, Crm_Modules }            from '../../scripts/Crm'                         ;
import { EndsWith }                           from '../../scripts/utility'                     ;
import { jsonReactState }                     from '../../scripts/Application'                 ;
import { AuthenticatedMethod, LoginRedirect } from '../../scripts/Login'                       ;
// 4. Components and Views. 
import SplendidGrid                           from '../../components/SplendidGrid'             ;
import SearchTabs                             from '../../components/SearchTabs'               ;
import SearchView                             from '../../views/SearchView'                    ;
import PreviewDashboard                       from '../../views/PreviewDashboard'              ;
import ExportHeader                           from '../../components/ExportHeader'             ;
import DynamicMassUpdate                      from '../../views/DynamicMassUpdate'             ;
import HeaderButtonsFactory                   from '../../ThemeComponents/HeaderButtonsFactory';
import Security from '../../scripts/Security';

interface IListViewProps extends RouteComponentProps<any>
{
	MODULE_NAME           : string;
	LAYOUT_NAME?          : string;
	RELATED_MODULE?       : string;
	GRID_NAME?            : string;
	TABLE_NAME?           : string;
	SORT_FIELD?           : string;
	SORT_DIRECTION?       : string;
	callback?             : Function;
	rowRequiredSearch?    : any;
	// 01/24/2020 Paul.  Use of this exact code in a dynamically loaded panel throws an Invariant Violation that we cannot location. 
	// So the solution is to provide cbCustomLoad input. 
	cbCustomLoad?         : (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) => any;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IListViewState
{
	GRID_NAME             : string;
	searchTabsEnabled     : boolean;
	duplicateSearchEnabled: boolean;
	searchMode            : string;
	showUpdatePanel       : boolean;
	enableMassUpdate      : boolean;
	archiveView           : boolean;
	PREVIEW_ID?           : string;
	selectedItems?        : any;
	error?                : any;
	// 04/09/2022 Paul.  Hide/show SearchView. 
	showSearchView        : string;
}

class UserSignaturesListView extends React.Component<IListViewProps, IListViewState>
{
	private _isMounted = false;
	private searchView    = React.createRef<SearchView>();
	private splendidGrid  = React.createRef<SplendidGrid>();
	private updatePanel   = React.createRef<DynamicMassUpdate>();
	private headerButtons = React.createRef<HeaderButtons>();

	constructor(props: IListViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props.MODULE_NAME);
		let archiveView: boolean = false;
		let GRID_NAME  : string = (props.LAYOUT_NAME ? props.LAYOUT_NAME : props.GRID_NAME);
		if ( props.location.pathname.indexOf('/ArchiveView') >= 0 )
		{
			archiveView = true;
			GRID_NAME   = props.MODULE_NAME + '.ArchiveView';
		}
		// 04/09/2022 Paul.  Hide/show SearchView. 
		let showSearchView: string = 'show';
		if ( SplendidCache.UserTheme == 'Pacific' )
		{
			showSearchView = localStorage.getItem(GRID_NAME + '.showSearchView');
			if ( Sql.IsEmptyString(showSearchView) )
				showSearchView = 'hide';
		}
		this.state =
		{
			GRID_NAME             ,
			searchTabsEnabled     : false,
			duplicateSearchEnabled: false,
			searchMode            : 'Basic',
			showUpdatePanel       : false,
			enableMassUpdate      : Crm_Modules.MassUpdate(props.MODULE_NAME),
			archiveView           ,
			error                 : null,
			showSearchView        ,
		};
	}

	async componentDidMount()
	{
		const { MODULE_NAME } = this.props;
		this._isMounted = true;
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
				// 02/02/2020 Paul.  Ignore missing during DynamicLayout. 
				let advancedLayout : any = EditView_LoadLayout(MODULE_NAME + '.SearchAdvanced'  , true);
				let duplicateLayout: any = EditView_LoadLayout(MODULE_NAME + '.SearchDuplicates', true);
				let showUpdatePanel: boolean = false;
				let module         : MODULE  = SplendidCache.Module(MODULE_NAME, this.constructor.name + '.componentDidMount');
				if ( module == null )
				{
					console.error(MODULE_NAME + ' not found or accessible.');
				}
				else
				{
					showUpdatePanel = module.MASS_UPDATE_ENABLED;
				}
				document.title = L10n.Term(MODULE_NAME + ".LBL_LIST_FORM_TITLE");
				// 04/26/2020 Paul.  Reset scroll every time we set the title. 
				window.scroll(0, 0);
				this.setState(
				{
					searchTabsEnabled     : !!advancedLayout,
					duplicateSearchEnabled: !!duplicateLayout,
					showUpdatePanel       : showUpdatePanel,
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
			const { GRID_NAME } = this.state;
			let { showSearchView } = this.state;
			showSearchView = 'hide';
			localStorage.setItem(GRID_NAME + '.showSearchView', showSearchView);
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback', sFILTER, row);
		// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
		if ( this.splendidGrid.current != null )
		{
			// 05/28/2020 Paul.  Force the list to only show signatures for the current user. 
			row['USER_ID'] = Security.USER_ID();
			this.splendidGrid.current.Search(sFILTER, row, oSORT);
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

	private _onSelectionChanged = (value: any) =>
	{
		const { MODULE_NAME } = this.props;
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
		const { MODULE_NAME } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdateComplete: ' + MODULE_NAME, sCommandName);
		if ( this.searchView.current != null )
		{
			// 04/26/2020 Paul.  Clear selection after update. 
			if ( sCommandName == 'MassDelete' || sCommandName == 'MassUpdate' || sCommandName == 'Sync' || sCommandName == 'Unsync' || 'Archive.MoveData' || 'Archive.RecoverData' )
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback: ' + MODULE_NAME, ID, URL);
		if ( !Sql.IsEmptyString(URL) )
		{
			if ( URL.indexOf('ArchiveView=1') >= 0 )
			{
				URL = URL.replace('ArchiveView=1', '');
				if ( EndsWith(URL, '?') )
				{
					URL = URL.substr(0, URL.length - 1);
				}
				if ( this.ArchiveViewEnabled() )
				{
					URL = URL.replace('/View/', '/ArchiveView/');
				}
			}
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
			if ( this.ArchiveViewEnabled() )
			{
				history.push(`/Reset${admin}/${MODULE_NAME}/ArchiveView/${ID}`);
			}
			else
			{
				history.push(`/Reset${admin}/${MODULE_NAME}/View/${ID}`);
			}
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { MODULE_NAME, history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
			case 'Create':
			{
				let admin: string = '';
				let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '.Page_Command');
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
				const { GRID_NAME } = this.state;
				let showSearchView: string = (this.state.showSearchView == 'show' ? 'hide' : 'show');
				localStorage.setItem(GRID_NAME + '.showSearchView', showSearchView);
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

	private ArchiveView = () =>
	{
		return this.state.archiveView;
	}

	private ArchiveViewEnabled = () =>
	{
		const { MODULE_NAME } = this.props;
		return this.ArchiveView() && Crm_Modules.ArchiveEnabled(MODULE_NAME);
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
		const { MODULE_NAME } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Grid_Command', sCommandName, sCommandArguments);
		if ( sCommandName == 'Preview' )
		{
			this.setState({ PREVIEW_ID: sCommandArguments });
		}
		// 11/11/2020 Paul.  We need to send the grid sort event to the SearchView. 
		else if ( sCommandName == 'sort' )
		{
			if ( this.searchView.current != null && sCommandArguments != null )
			{
				this.searchView.current.UpdateSortState(sCommandArguments.sortField, sCommandArguments.sortOrder);
			}
		}
		else
		{
			if ( this.updatePanel.current != null )
			{
				this.updatePanel.current.Page_Command(sCommandName, sCommandArguments);
			}
		}
	}

	public render()
	{
		const { MODULE_NAME, RELATED_MODULE, TABLE_NAME, SORT_FIELD, SORT_DIRECTION, rowRequiredSearch } = this.props;
		const { GRID_NAME, error, searchTabsEnabled, duplicateSearchEnabled, searchMode, showUpdatePanel, enableMassUpdate, PREVIEW_ID, showSearchView } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		// 05/06/2019 Paul.  The trick to having the SearchView change with the tabs is to change the key. 
		// 06/25/2019 Paul.  The SplendidGrid is getting a componentDidUpdate event instead of componentDidMount, so try specifying a key. 
		if ( SplendidCache.IsInitialized )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = (this.ArchiveViewEnabled() ? '.LBL_ARCHIVE_VIEW' : '.moduleList.Home');
			let HEADER_BUTTONS: string = '';
			if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
			{
				HEADER_BUTTONS = MODULE_NAME + '.ListView';
			}
			// 01/24/2020 Paul.  Use of this exact code in a dynamically loaded panel throws an Invariant Violation that we cannot location. 
			// So the solution is to provide cbCustomLoad input. 
			return (
			<div style={ {display: 'flex', flexDirection: 'row', flexWrap: 'nowrap', width: '100%'} }>
				<div id='divListView' style={ {width: '100%'} }>
					{ headerButtons
					? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, error, enableHelp: true, helpName: 'index', ButtonStyle: 'ModuleHeader', VIEW_NAME: HEADER_BUTTONS, Page_Command: this.Page_Command, showButtons: true, showProcess: false, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
					: null
					}
					<div style={ {display: (showSearchView == 'show' ? 'block' : 'none')} }>
						{ searchTabsEnabled
						? <SearchTabs searchMode={ searchMode } duplicateSearchEnabled={ duplicateSearchEnabled } onTabChange={ this._onSearchTabChange } />
						: null
						}
						<SearchView
							key={ MODULE_NAME + '.Search' + searchMode }
							EDIT_NAME={ MODULE_NAME + '.Search' + searchMode }
							AutoSaveSearch={ Credentials.bSAVE_QUERY && Crm_Config.ToBoolean('save_query') }
							ShowSearchViews={ true }
							ShowDuplicateFilter={ searchMode == 'Duplicates' }
							cbSearch={ this._onSearchViewCallback }
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
							ref={ this.searchView }
						/>
					</div>
					<ExportHeader
						MODULE_NAME={ MODULE_NAME }
						onExport={ this._onExport }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
					/>
					<SplendidGrid
						onLayoutLoaded={ this._onGridLayoutLoaded }
						MODULE_NAME={ MODULE_NAME }
						RELATED_MODULE={ RELATED_MODULE }
						GRID_NAME={ GRID_NAME }
						TABLE_NAME={ TABLE_NAME }
						SORT_FIELD={ SORT_FIELD }
						SORT_DIRECTION={ SORT_DIRECTION }
						ADMIN_MODE={ false }
						AutoSaveSearch={ Credentials.bSAVE_QUERY && Crm_Config.ToBoolean('save_query') }
						archiveView={ this.ArchiveViewEnabled() }
						deferLoad={ true }
						enableExportHeader={ true }
						enableSelection={ enableMassUpdate || SplendidCache.GetUserAccess(MODULE_NAME, 'export', this.constructor.name + '.render') >= 0 }
						enableFavorites={ true }
						enableFollowing={ true }
						selectionChanged={ this._onSelectionChanged }
						hyperLinkCallback={ this._onHyperLinkCallback }
						enableMassUpdate={ enableMassUpdate }
						rowRequiredSearch={ rowRequiredSearch }
						cbCustomLoad={ this.props.cbCustomLoad }
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
						key={ MODULE_NAME + '.UpdatePanel' }
						MODULE_NAME={ MODULE_NAME }
						onUpdateComplete={ this._onUpdateComplete }
						archiveView={ this.ArchiveViewEnabled() }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.updatePanel }
						/>
					: null
					}
				</div>
				<PreviewDashboard MODULE_NAME={ MODULE_NAME } ID={ PREVIEW_ID } />
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

export default withRouter(UserSignaturesListView);
