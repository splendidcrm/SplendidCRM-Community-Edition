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
import { RouteComponentProps, withRouter }           from 'react-router-dom'                          ;
import { FontAwesomeIcon }                           from '@fortawesome/react-fontawesome'            ;
import { Modal }                                     from 'react-bootstrap'                           ;
// 2. Store and Types. 
import MODULE                                        from '../../types/MODULE'                        ;
import ACL_FIELD_ACCESS                              from '../../types/ACL_FIELD_ACCESS'              ;
import { HeaderButtons }                             from '../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                           from '../../scripts/Sql'                         ;
import L10n                                          from '../../scripts/L10n'                        ;
import Security                                      from '../../scripts/Security'                    ;
import Credentials                                   from '../../scripts/Credentials'                 ;
import SplendidCache                                 from '../../scripts/SplendidCache'               ;
import SplendidDynamic                               from '../../scripts/SplendidDynamic'             ;
import { EditView_LoadLayout }                       from '../../scripts/EditView'                    ;
import { Crm_Config, Crm_Modules }                   from '../../scripts/Crm'                         ;
import { Trim, EndsWith }                            from '../../scripts/utility'                     ;
import { ListView_LoadModulePaginated }              from '../../scripts/ListView'                    ;
import { AuthenticatedMethod, LoginRedirect }        from '../../scripts/Login'                       ;
import { Dashboards_LoadPanels, DashboardAddReport } from '../../scripts/Dashboard'                   ;
import { jsonReactState }                            from '../../scripts/Application'                 ;
// 4. Components and Views. 
import SplendidGrid                                  from '../../components/SplendidGrid'             ;
import SearchTabs                                    from '../../components/SearchTabs'               ;
import SearchView                                    from '../../views/SearchView'                    ;
import PreviewDashboard                              from '../../views/PreviewDashboard'              ;
import ExportHeader                                  from '../../components/ExportHeader'             ;
import DynamicMassUpdate                             from '../../views/DynamicMassUpdate'             ;
import ListHeader                                    from '../../components/ListHeader'               ;
import HeaderButtonsFactory                          from '../../ThemeComponents/HeaderButtonsFactory';

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
	SELECTED_REPORT_ID    : string;
	error?                : any;
	// 04/09/2022 Paul.  Hide/show SearchView. 
	showSearchView        : string;
}

class ChartsListView extends React.Component<IListViewProps, IListViewState>
{
	private _isMounted = false;
	private themeURL   : string = null;
	private legacyIcons: boolean = false;
	private searchView     = React.createRef<SearchView>();
	private splendidGrid   = React.createRef<SplendidGrid>();
	private updatePanel    = React.createRef<DynamicMassUpdate>();
	private headerButtons  = React.createRef<HeaderButtons>();

	constructor(props: IListViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props.MODULE_NAME);
		let archiveView: boolean = false;
		let GRID_NAME  : string = (props.LAYOUT_NAME ? props.LAYOUT_NAME : props.GRID_NAME);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
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
			SELECTED_REPORT_ID    : null,
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

	private editviewColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		const { MODULE_NAME } = this.props;
		// 05/01/2019 Paul.  The edit button should be hidden if a process is pending on the record. 
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		// 08/11/2019 Paul.  Make sure the user has permission to create a record before loading the layout. 
		// sASSIGNED_USER_ID_FIELD is almost always ASSIGNED_USER_ID, but it is ACITIVTY_ASSIGNED_USER_ID for activities. 
		// Another exception is when using delete or remove with a relationship whereby the parent module assigned field is used. 
		let disableView    : boolean = false;
		let disableEdit    : boolean = false;
		let enableFavorites: boolean = true ;
		let enableFollowing: boolean = false;
		if ( row['CHART_TYPE'] == 'Freeform' )
		{
			disableEdit = true;
		}
		
		let nVIEW_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, MODULE_NAME, "view"  , 'ASSIGNED_USER_ID');
		let nEDIT_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, MODULE_NAME, "edit"  , 'ASSIGNED_USER_ID');
		// 11/02/2020 Paul.  We don't want to combine favorites and disableView. 
		//if ( disableView )
		//{
		//	nVIEW_ACLACCESS = -1;
		//}
		//if ( disableEdit )
		//{
		//	nEDIT_ACLACCESS = -1;
		//}
		// 12/05/2021 Paul.  User should be able to open a new table by right-click on item name.  Change from span to anchor. 
		if ( this.splendidGrid.current )
		{
			return (
				<span style={ { whiteSpace: 'nowrap'} }>
					{ nVIEW_ACLACCESS >= 0 && enableFavorites && Sql.IsEmptyGuid(row['FAVORITE_RECORD_ID'])
					? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this.splendidGrid.current._onChangeFavorites(row, rowIndex) } title={ L10n.Term('.LNK_VIEW') }>
						{ this.legacyIcons
						? <img src={ this.themeURL + 'favorites_add.gif'} style={ {borderWidth: '0px'} } />
						: <FontAwesomeIcon icon={ { prefix: 'far', iconName: 'star' } } size="lg" color='#FFB518' />
						}
					</span>
					: null
					}
					{ nVIEW_ACLACCESS >= 0 && enableFavorites && !Sql.IsEmptyGuid(row['FAVORITE_RECORD_ID'])
					? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this.splendidGrid.current._onChangeFavorites(row, rowIndex) } title={ L10n.Term('.LNK_VIEW') }>
						{ this.legacyIcons
						? <img src={ this.themeURL + 'favorites_remove.gif'} style={ {borderWidth: '0px'} } />
						: <FontAwesomeIcon icon={ { prefix: 'fas', iconName: 'star' } } size='lg' color='#FFB518' />
						}
					</span>
					: null
					}
					{ nVIEW_ACLACCESS >= 0 && enableFollowing && Sql.IsEmptyGuid(row['SUBSCRIPTION_PARENT_ID'])
					? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this.splendidGrid.current._onChangeFollowing(row, rowIndex) } title={ L10n.Term('.LNK_VIEW') }>
						{ this.legacyIcons
						? <img src={ this.themeURL + 'follow.png'} style={ {borderWidth: '0px'} } />
						: <FontAwesomeIcon icon={ { prefix: 'far', iconName: 'arrow-alt-circle-right' } } size="lg" color='#EF7B00' />
						}
					</span>
					: null
					}
					{ nVIEW_ACLACCESS >= 0 && enableFollowing && !Sql.IsEmptyGuid(row['SUBSCRIPTION_PARENT_ID'])
					? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this.splendidGrid.current._onChangeFollowing(row, rowIndex) } title={ L10n.Term('.LNK_VIEW') }>
						{ this.legacyIcons
						? <img src={ this.themeURL + 'following.png'} style={ {borderWidth: '0px'} } />
						: <FontAwesomeIcon icon={ { prefix: 'fas', iconName: 'arrow-alt-circle-right' } } size='lg' color='#EF7B00' />
						}
					</span>
					: null
					}
					{ !disableView && nVIEW_ACLACCESS >= 0
					? <a href={ this.splendidGrid.current.getViewUrl(row) } style={ {padding: '3px', textDecoration: 'none'} } onClick={ (e) => { e.preventDefault(); this.splendidGrid.current._onView(row); } } title={ L10n.Term('.LNK_VIEW') }>
						{ this.legacyIcons
						? <img src={ this.themeURL + 'view_inline.gif'} style={ {borderWidth: '0px'} } />
						: <FontAwesomeIcon icon='file' size='lg' />
						}
					</a>
					: null
					}
					{ !disableEdit && nEDIT_ACLACCESS >= 0 && Sql.IsEmptyGuid(row.PENDING_PROCESS_ID)
					? <a href={ this.splendidGrid.current.getEditUrl(row) } style={ {padding: '3px', textDecoration: 'none'} } onClick={ (e) => { e.preventDefault(); this.splendidGrid.current._onEdit(row); } } title={ L10n.Term('.LNK_EDIT') }>
						{ this.legacyIcons
						? <img src={ this.themeURL + 'edit_inline.gif'} style={ {borderWidth: '0px'} } />
						: <FontAwesomeIcon icon='edit' size='lg' />
						}
					</a>
					: null
					}
				</span>
			);
		}
		else
		{
			return null;
		}
	}

	private exportColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		const { MODULE_NAME } = this.props;
		let nEDIT_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, MODULE_NAME, "edit"  , 'ASSIGNED_USER_ID');
		let nEXPORT_ACLACCESS: number = SplendidCache.GetRecordAccess(row, MODULE_NAME, "export", 'ASSIGNED_USER_ID');
		return (<span>
			{ nEDIT_ACLACCESS >= 0 && row['CHART_TYPE'] != 'Freeform'
			? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onDuplicate(row) } className='listViewTdToolsS1'>{ L10n.Term('.LBL_DUPLICATE_BUTTON_LABEL') }</span>
			: null
			}
			<span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onAddDashlet(row) } className='listViewTdToolsS1'>{ L10n.Term('Charts.LNK_ADD_DASHLET') }</span>
			{ Security.IS_ADMIN() && nEXPORT_ACLACCESS >= 0
			? <span>
				<img src={ this.themeURL + 'export.gif' } style={ {borderWidth: '0px', height: '10px', width: '10px', paddingLeft: '4px'} } />
				<span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onExportRDL(row) } className='listViewTdToolsS1'>{ L10n.Term('.LBL_EXPORT') }</span>
			</span>
			: null
			}
			{ Security.IS_ADMIN() && nEXPORT_ACLACCESS >= 0 && false
			? <span>
				<img src={ this.themeURL + 'export.gif' } style={ {borderWidth: '0px', height: '10px', width: '10px', paddingLeft: '4px'} } />
				<span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onExportSQL(row) } className='listViewTdToolsS1'>{ L10n.Term('Charts.LBL_EXPORT_SQL') }</span>
			</span>
			: null
			}
		</span>);
	}

	private BootstrapColumns = (sLIST_MODULE_NAME, layout, sPRIMARY_MODULE, sPRIMARY_ID) =>
	{
		// 04/20/2017 Paul.  Build DataTables columns. 
		let arrDataTableColumns = [];
		let objDataColumn: any = {};
		objDataColumn =
		{
			key            : 'editview',
			text           : null,
			dataField      : 'empty1',
			formatter      : this.editviewColumnFormatter,
			headerClasses  : 'listViewThS2',
			headerStyle    : {padding: 0, margin: 0},
			headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader : null),
			sort           : false,
			isDummyField   : true,
			formatExtraData: {
				data: {
					GRID_NAME: sLIST_MODULE_NAME,
					DATA_FIELD: null,
					fnRender: null,
					layout: layout
				}
			}
		};
		// 01/07/2018 Paul.  Force first column to be displayed. 
		arrDataTableColumns.push(objDataColumn);
		// 03/24/2020 Paul.  Manually add NAME bound column.
		objDataColumn =
		{
			key            : 'column' + 'NAME',
			text           : L10n.Term('Charts.LBL_LIST_CHART_NAME'),
			dataField      : 'NAME',
			classes        : 'listViewTdLinkS1',
			style          : null,
			headerClasses  : 'listViewThS2',
			headerStyle    : {whiteSpace: 'nowrap'},
			headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader           : null),
			formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.templateColumnFormatter: null),
			sort           : true,
			isDummyField   : false,
			attrs          : { width: '35%' },
			formatExtraData: {
				data: {
					GRID_NAME   : sLIST_MODULE_NAME,
					DATA_FIELD  : 'NAME',
					COLUMN_INDEX: 1,
					layout      : 
					{
						COLUMN_TYPE       : 'TemplateColumn',
						DATA_FIELD        : 'NAME',
						DATA_FORMAT       : 'HyperLink',
						URL_FIELD         : 'ID',
						URL_FORMAT        : '~/Charts/edit.aspx?id={0}',
						URL_MODULE        : 'Charts',
						URL_ASSIGNED_FIELD: 'ASSIGNED_USER_ID',
						SORT_EXPRESSION   : 'NAME',
						ITEMSTYLE_CSSCLASS: 'listViewTdLinkS1',
						HEADER_TEXT       : 'Charts.LBL_LIST_CHART_NAME',
					}
				}
			}
		};
		// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
		// 04/24/2022 Paul.  Move Arctic style override to style.css. 
		arrDataTableColumns.push(objDataColumn);

		// 03/24/2020 Paul.  Manually add MODULE_NAME, CHART_TYPE as a bound columns. 
		objDataColumn =
		{
			key            : 'column' + 'MODULE_NAME',
			text           : L10n.Term('Charts.LBL_LIST_MODULE_NAME'),
			dataField      : 'MODULE_NAME',
			classes        : 'listViewTdLinkS1',
			style          : null,
			headerClasses  : 'listViewThS2',
			headerStyle    : {whiteSpace: 'nowrap'},
			headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader         : null),
			formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.boundColumnFormatter : null),
			sort           : false,
			isDummyField   : false,
			attrs          : { width: '15%' },
			formatExtraData: {
				data: {
					GRID_NAME   : sLIST_MODULE_NAME,
					DATA_FIELD  : 'MODULE_NAME',
					COLUMN_INDEX: 1,
					layout      : 
					{
						COLUMN_TYPE    : 'BoundColumn',
						DATA_FIELD     : 'MODULE_NAME',
						SORT_EXPRESSION: 'MODULE_NAME',
						HEADER_TEXT    : 'Charts.LBL_LIST_MODULE_NAME',
					}
				}
			}
		};
		// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
		// 04/24/2022 Paul.  Move Arctic style override to style.css. 
		arrDataTableColumns.push(objDataColumn);

		let bEnableTeamManagement = Crm_Config.enable_team_management();
		let bEnableDynamicTeams = Crm_Config.enable_dynamic_teams();
		// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
		let oNumberFormat = Security.NumberFormatInfo();
		if ( Crm_Config.ToString('currency_format') == 'c0' )
		{
			oNumberFormat.CurrencyDecimalDigits = 0;
		}
		if ( layout != null )
		{
			for ( let nLayoutIndex = 0; layout != null && nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay = layout[nLayoutIndex];
				let COLUMN_TYPE                = lay.COLUMN_TYPE               ;
				let COLUMN_INDEX               = lay.COLUMN_INDEX              ;
				let HEADER_TEXT                = lay.HEADER_TEXT               ;
				let SORT_EXPRESSION            = lay.SORT_EXPRESSION           ;
				let ITEMSTYLE_WIDTH            = lay.ITEMSTYLE_WIDTH           ;
				let ITEMSTYLE_CSSCLASS         = lay.ITEMSTYLE_CSSCLASS        ;
				let ITEMSTYLE_HORIZONTAL_ALIGN = lay.ITEMSTYLE_HORIZONTAL_ALIGN;
				let ITEMSTYLE_VERTICAL_ALIGN   = lay.ITEMSTYLE_VERTICAL_ALIGN  ;
				// 10/30/2020 Paul.  ITEMSTYLE_WRAP defaults to true. 
				let ITEMSTYLE_WRAP             = (lay.ITEMSTYLE_WRAP == null ? true : lay.ITEMSTYLE_WRAP);
				let DATA_FIELD                 = lay.DATA_FIELD                ;
				let DATA_FORMAT                = lay.DATA_FORMAT               ;
				let URL_FIELD                  = lay.URL_FIELD                 ;
				let URL_FORMAT                 = lay.URL_FORMAT                ;
				let URL_TARGET                 = lay.URL_TARGET                ;
				let LIST_NAME                  = lay.LIST_NAME                 ;
				let URL_MODULE                 = lay.URL_MODULE                ;
				let URL_ASSIGNED_FIELD         = lay.URL_ASSIGNED_FIELD        ;
				let VIEW_NAME                  = lay.VIEW_NAME                 ;
				let MODULE_NAME                = lay.MODULE_NAME               ;
				let MODULE_TYPE                = lay.MODULE_TYPE               ;
				let PARENT_FIELD               = lay.PARENT_FIELD              ;

				if ( (DATA_FIELD == 'TEAM_NAME' || DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( bEnableTeamManagement && bEnableDynamicTeams )
					{
						HEADER_TEXT = '.LBL_LIST_TEAM_SET_NAME';
						DATA_FIELD  = 'TEAM_SET_NAME';
					}
					else if ( !bEnableTeamManagement )
					{
						// 10/24/2012 Paul.  Clear the sort so that there would be no term lookup. 
						HEADER_TEXT     = null;
						SORT_EXPRESSION = null;
						COLUMN_TYPE     = 'Hidden';
					}
				}
				// 01/18/2010 Paul.  A field is either visible or not.  At this time, we will not only show a field to its owner. 
				let bIsReadable: boolean = true;
				// 08/02/2010 Paul.  The JavaScript and Hover fields will not have a data field. 
				if ( SplendidCache.bEnableACLFieldSecurity && !Sql.IsEmptyString(DATA_FIELD) )
				{
					let gASSIGNED_USER_ID: string = null;
					let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
				}

				if (   COLUMN_TYPE == 'BoundColumn'
				  && ( DATA_FORMAT == 'Date'
					|| DATA_FORMAT == 'DateTime'
					|| DATA_FORMAT == 'Currency'
					|| DATA_FORMAT == 'Image'
					|| DATA_FORMAT == 'MultiLine'
					// 08/26/2014 Paul.  Ignore ImageButton. 
					|| DATA_FORMAT == 'ImageButton'
				   )
				)
				{
					COLUMN_TYPE = 'TemplateColumn';
				}
				if ( DATA_FORMAT == 'ImageButton' && URL_FORMAT == 'Preview' )
				{
					bIsReadable = bIsReadable && SplendidDynamic.StackedLayout(SplendidCache.UserTheme);
				}
				// 08/20/2016 Paul.  The hidden field is a DATA_FORMAT, not a COLUMN_TYPE, but keep COLUMN_TYPE just in case anyone used it. 
				// 07/22/2019 Paul.  Apply ACL Field Security. 
				if ( !bIsReadable || COLUMN_TYPE == 'Hidden' || DATA_FORMAT == 'Hidden' )
				{
					continue;  // 04/23/2017 Paul.  Return instead of continue as we are in a binding function. 
				}
				if ( COLUMN_TYPE == 'TemplateColumn' )
				{
					// 04/20/2017 Paul.  Build DataTables columns. 
					// 01/22/2020 Paul.  Apply wrap flag. 
					objDataColumn =
					{
						key            : 'column' + nLayoutIndex,
						text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField      : DATA_FIELD,
						classes        : '',
						style          : (Sql.ToBoolean(ITEMSTYLE_WRAP) ? null : {whiteSpace: 'nowrap'}),
						headerClasses  : 'listViewThS2',
						headerStyle    : {whiteSpace: 'nowrap'},
						headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader            : null),
						formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.templateColumnFormatter : null),
						sort           : (SORT_EXPRESSION != null),
						isDummyField   : false,
						formatExtraData:
						{
							data:
							{
								GRID_NAME   : sLIST_MODULE_NAME,
								DATA_FIELD  : DATA_FIELD,
								COLUMN_INDEX: COLUMN_INDEX,
								layout      : lay
							}
						}
					};
					// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
					// 04/24/2022 Paul.  Move Arctic style override to style.css. 
					if ( ITEMSTYLE_HORIZONTAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_HORIZONTAL_ALIGN;
					}
					if ( ITEMSTYLE_VERTICAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_VERTICAL_ALIGN;
					}
					if ( ITEMSTYLE_WIDTH != null )
					{
						objDataColumn.attrs = { width: ITEMSTYLE_WIDTH };
					}
					// 07/25/2017 Paul.  Try and force the NAME column to always be displayed on mobile portrait mode. 
					// https://datatables.net/extensions/responsive/classes
					if ( DATA_FIELD == "NAME" )
					{
						objDataColumn.classes = ' all';
					}
					objDataColumn.classes = Trim(objDataColumn.classes);

					arrDataTableColumns.push(objDataColumn);
				}
				else if ( COLUMN_TYPE == 'BoundColumn' )
				{
					// 04/20/2017 Paul.  Build DataTables columns. 
					// 01/22/2020 Paul.  Apply wrap flag. 
					objDataColumn =
					{
						key            : 'column' + nLayoutIndex,
						text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField      : DATA_FIELD,
						classes        : '',
						style          : (Sql.ToBoolean(ITEMSTYLE_WRAP) ? null : {whiteSpace: 'nowrap'}),
						headerClasses  : 'listViewThS2',
						headerStyle    : {whiteSpace: 'nowrap'},
						headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader         : null),
						formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.boundColumnFormatter : null),
						sort           : (SORT_EXPRESSION != null),
						isDummyField   : false,
						formatExtraData: {
							data: {
								GRID_NAME   : sLIST_MODULE_NAME,
								DATA_FIELD  : DATA_FIELD,
								COLUMN_INDEX: COLUMN_INDEX,
								layout      : lay
							}
						}
					};
					// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
					// 04/24/2022 Paul.  Move Arctic style override to style.css. 
					if ( ITEMSTYLE_HORIZONTAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_HORIZONTAL_ALIGN;
					}
					if ( ITEMSTYLE_VERTICAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_VERTICAL_ALIGN;
					}
					if ( ITEMSTYLE_WIDTH != null )
					{
						objDataColumn.attrs = { width: ITEMSTYLE_WIDTH };
					}
					objDataColumn.classes = Trim(objDataColumn.classes);
					arrDataTableColumns.push(objDataColumn);
				}
			}
			// 05/17/2018 Paul.  Defer finalize. 
			//if ( this.BootstrapColumnsFinalize != null )
			//	arrDataTableColumns = this.BootstrapColumnsFinalize(sLIST_MODULE_NAME, arrDataTableColumns);
		}
		objDataColumn =
		{
			key            : 'column' + 'CHART_TYPE',
			text           : L10n.Term('Charts.LBL_LIST_CHART_TYPE'),
			dataField      : 'CHART_TYPE',
			classes        : 'listViewTdLinkS1',
			style          : null,
			headerClasses  : 'listViewThS2',
			headerStyle    : {whiteSpace: 'nowrap'},
			headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader         : null),
			formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.boundColumnFormatter : null),
			sort           : false,
			isDummyField   : false,
			attrs          : { width: '15%' },
			formatExtraData: {
				data: {
					GRID_NAME   : sLIST_MODULE_NAME,
					DATA_FIELD  : 'CHART_TYPE',
					COLUMN_INDEX: 1,
					layout      : 
					{
						COLUMN_TYPE    : 'BoundColumn',
						DATA_FIELD     : 'CHART_TYPE',
						SORT_EXPRESSION: 'CHART_TYPE',
						HEADER_TEXT    : 'Charts.LBL_LIST_CHART_TYPE',
						LIST_NAME      : 'dom_chart_types',
					}
				}
			}
		};
		// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
		// 04/24/2022 Paul.  Move Arctic style override to style.css. 
		arrDataTableColumns.push(objDataColumn);

		// 03/24/2020 Paul.  Last column combines all the actions. 
		objDataColumn =
		{
			key            : 'editview',
			text           : null,
			dataField      : 'empty2',
			formatter      : this.exportColumnFormatter,
			style          : {whiteSpace: 'nowrap', textAlign: 'right'},
			headerClasses  : 'listViewThS2',
			headerStyle    : {padding: 0, margin: 0},
			headerFormatter: null,
			sort           : false,
			isDummyField   : true,
			formatExtraData: {
				data: {
					GRID_NAME: sLIST_MODULE_NAME,
					DATA_FIELD: null,
					fnRender: null,
					layout: layout
				}
			}
		};
		// 01/07/2018 Paul.  Force first column to be displayed. 
		arrDataTableColumns.push(objDataColumn);
		return arrDataTableColumns;
	}

	private _onDuplicate = (row) =>
	{
		this.props.history.push('/Charts/Duplicate/' + row.ID);
	}

	private _onExportRDL = (row) =>
	{
		window.location.href = Credentials.RemoteServer + 'Charts/ExportRDL.aspx?id=' + row.ID;
	}

	private _onExportSQL = (row) =>
	{
		window.location.href = Credentials.RemoteServer + 'Charts/ExportSQL.aspx?id=' + row.ID;
	}

	private _onAddDashlet = (row) =>
	{
		this.setState({ SELECTED_REPORT_ID: row.ID });
	}

	private _onClosePopup = () =>
	{
		this.setState({ SELECTED_REPORT_ID: null });
	}

	private load = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		let arrSELECT: string[] = sSELECT.split(',');
		if ( arrSELECT.indexOf('ID'          ) < 0 ) arrSELECT.push('ID'          );
		if ( arrSELECT.indexOf('NAME'        ) < 0 ) arrSELECT.push('NAME'        );
		if ( arrSELECT.indexOf('MODULE_NAME' ) < 0 ) arrSELECT.push('MODULE_NAME' );
		if ( arrSELECT.indexOf('CHART_TYPE' ) < 0 ) arrSELECT.push('CHART_TYPE' );
		sSELECT = arrSELECT.join(',');
		let d = await ListView_LoadModulePaginated(sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, null, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
		return d;
	}

	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	private _onHomeDashboardSelect = async (MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any) =>
	{
		const { SELECTED_REPORT_ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHomeDashboardSelect: ' + MODULE_NAME, ID, NAME, URL);
		try
		{
			await DashboardAddReport(ID, 'Home', SELECTED_REPORT_ID);
			Dashboards_LoadPanels(ID, true);
		}
		catch(error)
		{
			this.setState({ error });
		}
		this.setState({ SELECTED_REPORT_ID: null });
	}

	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	private _onDashboardSelect = async (MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any) =>
	{
		const { SELECTED_REPORT_ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDashboardSelect: ' + MODULE_NAME, ID, NAME, URL);
		try
		{
			await DashboardAddReport(ID, 'Dashboard', SELECTED_REPORT_ID);
			Dashboards_LoadPanels(ID, true);
		}
		catch(error)
		{
			this.setState({ error });
		}
		this.setState({ SELECTED_REPORT_ID: null });
	}

	public render()
	{
		const { MODULE_NAME, RELATED_MODULE, TABLE_NAME, SORT_FIELD, SORT_DIRECTION, rowRequiredSearch } = this.props;
		const { GRID_NAME, error, searchTabsEnabled, duplicateSearchEnabled, searchMode, showUpdatePanel, enableMassUpdate, PREVIEW_ID, SELECTED_REPORT_ID, showSearchView } = this.state;
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
				<Modal show={ SELECTED_REPORT_ID != null } onHide={ this._onClosePopup }>
					<Modal.Body style={{ minHeight: '80vh', minWidth: '80vw' }}>
						<ListHeader TITLE='Dashboard.LBL_HOME_PAGE_DASHBOARDS' />
						<SplendidGrid
							MODULE_NAME='Dashboard'
							GRID_NAME='Dashboard.PopupView'
							SORT_FIELD='NAME'
							SORT_DIRECTION='asc'
							ADMIN_MODE={ false }
							archiveView={ false }
							deferLoad={ false }
							isPopupView={ true }
							enableSelection={ false }
							enableFavorites={ false }
							enableFollowing={ false }
							hyperLinkCallback={ this._onHomeDashboardSelect }
							enableMassUpdate={ false }
							rowRequiredSearch={ {CATEGORY: 'Home', ASSIGNED_USER_ID: Security.USER_ID()} }
							scrollable
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
						/>
						<ListHeader TITLE='Dashboard.LBL_DASHBOARDS' />
						<SplendidGrid
							MODULE_NAME='Dashboard'
							GRID_NAME='Dashboard.PopupView'
							SORT_FIELD='NAME'
							SORT_DIRECTION='asc'
							ADMIN_MODE={ false }
							archiveView={ false }
							deferLoad={ false }
							isPopupView={ true }
							enableSelection={ false }
							enableFavorites={ false }
							enableFollowing={ false }
							hyperLinkCallback={ this._onDashboardSelect }
							enableMassUpdate={ false }
							rowRequiredSearch={ {CATEGORY: 'Dashboard', ASSIGNED_USER_ID: Security.USER_ID()} }
							scrollable
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
						/>
					</Modal.Body>
					<Modal.Footer>
						<button className='button' onClick={ this._onClosePopup }>{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }</button>
					</Modal.Footer>
				</Modal>
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
						cbCustomLoad={ this.load }
						cbCustomColumns={ this.BootstrapColumns }
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

export default withRouter(ChartsListView);
