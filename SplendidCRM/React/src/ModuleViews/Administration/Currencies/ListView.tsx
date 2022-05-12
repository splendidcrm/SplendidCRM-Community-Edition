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
import { RouteComponentProps, withRouter }            from 'react-router-dom'                     ;
import { observer }                                   from 'mobx-react'                           ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome'       ;
// 2. Store and Types. 
import ACL_FIELD_ACCESS                               from '../../../types/ACL_FIELD_ACCESS'      ;
import MODULE                                         from '../../../types/MODULE'                ;
import { HeaderButtons }                              from '../../../types/HeaderButtons'         ;
// 3. Scripts. 
import Sql                                            from '../../../scripts/Sql'                 ;
import L10n                                           from '../../../scripts/L10n'                ;
import Security                                       from '../../../scripts/Security'            ;
import Credentials                                    from '../../../scripts/Credentials'         ;
import SplendidCache                                  from '../../../scripts/SplendidCache'       ;
import SplendidDynamic                                from '../../../scripts/SplendidDynamic'     ;
import { EditView_LoadLayout }                        from '../../../scripts/EditView'            ;
import { Crm_Config, Crm_Modules }                    from '../../../scripts/Crm'                 ;
import { Admin_GetReactState }                        from '../../../scripts/Application'         ;
import { AuthenticatedMethod, LoginRedirect }         from '../../../scripts/Login'               ;
import { Trim, EndsWith }                             from '../../../scripts/utility'             ;
import { CreateSplendidRequest, GetSplendidResult }   from '../../../scripts/SplendidRequest'     ;
// 4. Components and Views. 
import SplendidGrid                                   from '../../../components/SplendidGrid'     ;
import SearchTabs                                     from '../../../components/SearchTabs'       ;
import ErrorComponent                                 from '../../../components/ErrorComponent'   ;
import ListHeader                                     from '../../../components/ListHeader'       ;
import SearchView                                     from '../../../views/SearchView'            ;
import DynamicMassUpdate                              from '../../../views/DynamicMassUpdate'     ;
import HeaderButtonsFactory                           from '../../../ThemeComponents/HeaderButtonsFactory';

interface IAdminListViewProps extends RouteComponentProps<any>
{
	MODULE_NAME           : string;
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
	// 04/09/2022 Paul.  Hide/show SearchView. 
	showSearchView        : string;
}

@observer
class CurrenciesListView extends React.Component<IAdminListViewProps, IAdminListViewState>
{
	private _isMounted = false;
	private themeURL   : string = null;
	private legacyIcons: boolean = false;
	private searchView   = React.createRef<SearchView>();
	private splendidGrid = React.createRef<SplendidGrid>();
	private updatePanel  = React.createRef<DynamicMassUpdate>();
	private headerButtons = React.createRef<HeaderButtons>();

	constructor(props: IAdminListViewProps)
	{
		super(props);
		Credentials.SetViewMode('AdminListView');
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props.MODULE_NAME);
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
			enableMassUpdate      : Crm_Modules.MassUpdate(props.MODULE_NAME),
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
		// 05/08/2019 Paul.  Once we have the Search callback, we can tell the SearchView to submit and it will get to the GridView. 
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

	private BootstrapColumns = (sLIST_MODULE_NAME, layout, sPRIMARY_MODULE, sPRIMARY_ID) =>
	{
		const { RELATED_MODULE } = this.props;
		let readonly      : boolean = true;
		let isPopupView   : boolean = false;
		let disableView   : boolean = true;
		let disableEdit   : boolean = true;
		let disableRemove : boolean = true;
		// 04/20/2017 Paul.  Build DataTables columns. 
		let arrDataTableColumns = [];
		let objDataColumn: any = {};
		if ( !readonly && !isPopupView )
		{
			// 05/28/2020 Paul.  Use RELATED_MODULE instead of cbRemove to determine of the related formatter is used. 
			if ( !Sql.IsEmptyString(RELATED_MODULE) )
			{
				// 06/19/2020 Paul.  Don't create column in related view and 
				// 10/12/2020 Paul.  Add width attribute. 
				if ( !disableView || !disableEdit || !disableRemove )
				{
					objDataColumn =
					{
						key            : 'editview',
						text           : null,
						dataField      : 'empty1',
						formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.editviewRelatedFormatter: null),
						headerClasses  : 'listViewThS2',
						headerStyle    : {padding: 0, margin: 0},
						headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader            : null),
						sort           : false,
						isDummyField   : true,
						attrs          : { width: '1%' },
						formatExtraData:
						{
							data:
							{
								GRID_NAME: sLIST_MODULE_NAME,
								DATA_FIELD: null,
								fnRender: null,
								layout: layout
							}
						}
					};
					// 01/07/2018 Paul.  Force first column to be displayed. 
					arrDataTableColumns.push(objDataColumn);
				}
			}
			else
			{
				objDataColumn =
				{
					key            : 'editview',
					text           : null,
					dataField      : 'empty1',
					formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.editviewColumnFormatter : null),
					headerClasses  : 'listViewThS2',
					headerStyle    : {padding: 0, margin: 0},
					headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader            : null),
					sort           : false,
					isDummyField   : true,
					attrs          : { width: '1%' },
					formatExtraData:
					{
						data:
						{
							GRID_NAME: sLIST_MODULE_NAME,
							DATA_FIELD: null,
							fnRender: null,
							layout: layout
						}
					}
				};
				// 01/07/2018 Paul.  Force first column to be displayed. 
				arrDataTableColumns.push(objDataColumn);
			}
		}

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
				// 11/02/2020 Paul.  Apply layout defined style. 
				let ITEMSTYLE_CSSCLASS         = Sql.ToString(lay.ITEMSTYLE_CSSCLASS);
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
					// 11/02/2020 Paul.  Apply layout defined style. 
					objDataColumn =
					{
						key            : 'column' + nLayoutIndex,
						text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField      : DATA_FIELD,
						classes        : ITEMSTYLE_CSSCLASS,
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
					// 11/02/2020 Paul.  Apply layout defined style. 
					objDataColumn =
					{
						key            : 'column' + nLayoutIndex,
						text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField      : DATA_FIELD,
						classes        : ITEMSTYLE_CSSCLASS,
						style          : (Sql.ToBoolean(ITEMSTYLE_WRAP) ? null : {whiteSpace: 'nowrap'}),
						headerClasses  : 'listViewThS2',
						headerStyle    : {whiteSpace: 'nowrap'},
						headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader            : null),
						formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.boundColumnFormatter    : null),
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
		
		// 11/04/2020 Paul.  Legacy icons means that the remove is on the right. 
		if ( !readonly && !isPopupView && this.legacyIcons )
		{
			// 05/28/2020 Paul.  Use RELATED_MODULE instead of cbRemove to determine of the related formatter is used. 
			if ( !Sql.IsEmptyString(RELATED_MODULE) )
			{
				// 06/19/2020 Paul.  Don't create column in related view and 
				// 10/12/2020 Paul.  Add width attribute. 
				if ( !disableView || !disableEdit || !disableRemove )
				{
					objDataColumn =
					{
						key            : 'editview',
						text           : null,
						dataField      : 'empty1',
						formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.editviewRelatedFormatterLegacy : null),
						headerClasses  : 'listViewThS2',
						headerStyle    : {padding: 0, margin: 0},
						headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader            : null),
						sort           : false,
						isDummyField   : true,
						attrs          : { width: '1%' },
						formatExtraData:
						{
							data:
							{
								GRID_NAME: sLIST_MODULE_NAME,
								DATA_FIELD: null,
								fnRender: null,
								layout: layout
							}
						}
					};
					// 01/07/2018 Paul.  Force first column to be displayed. 
					arrDataTableColumns.push(objDataColumn);
				}
			}
		}
		objDataColumn =
		{
			key            : 'editview',
			text           : null,
			dataField      : 'empty1',
			formatter      : this.updateRateColumnFormatter,
			headerClasses  : 'listViewThS2',
			headerStyle    : {padding: 0, margin: 0},
			headerFormatter: null,
			sort           : false,
			isDummyField   : true,
			attrs          : { width: '1%' },
			formatExtraData: {
				data: {
					GRID_NAME: sLIST_MODULE_NAME,
					DATA_FIELD: null,
					fnRender: null,
					layout: layout
				}
			}
		};
		arrDataTableColumns.push(objDataColumn);
		return arrDataTableColumns;
	}

	private onUpdateRate = async (row) =>
	{
		try
		{
			let data: any = { ISO4217: row['ISO4217'] } ;
			let sBody: string = JSON.stringify(data);
			let res = await CreateSplendidRequest('Administration/CurrencyLayer/Rest.svc/UpdateRate', 'POST', 'application/json; charset=utf-8', sBody);
			let json = await GetSplendidResult(res);
			if ( this.searchView.current != null )
			{
				this.searchView.current.SubmitSearch();
			}
		}
		catch(error)
		{
			this.setState({ error });
		}
	}

	private updateRateColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		const { MODULE_NAME } = this.props;
		let nEDIT_ACLACCESS  : number = SplendidCache.AdminUserAccess(MODULE_NAME, 'edit');
		// 03/17/2021 Paul.  We typcially disable if not subscribed to CurrencyLayer, but we don't have access to this key in the React client. 
		if ( Sql.IsEmptyString(Crm_Config.ToString('CurrencyLayer.AccessKey')) )
		{
			//nEDIT_ACLACCESS = -1;
		}
		return (
			<span style={ { whiteSpace: 'nowrap'} }>
				{ nEDIT_ACLACCESS >= 0
				? <a href='#' onClick={ (e) => { e.preventDefault(); this.onUpdateRate(row); } } className='listViewTdToolsS1'>
					<img src={ this.themeURL + 'CurrencyLayer.png'} alt={ L10n.Term('Currencies.LBL_UPDATE_RATE') } style={ {padding: '3px', width: '24px', height: '24px', borderWidth: '0px'} } />
					{ L10n.Term('Currencies.LBL_UPDATE_RATE') }
				</a>
				: null
				}
			</span>
		);
	}

	public render()
	{
		const { MODULE_NAME, RELATED_MODULE, GRID_NAME, TABLE_NAME, SORT_FIELD, SORT_DIRECTION, rowRequiredSearch } = this.props;
		const { error, searchLayout, advancedLayout, searchTabsEnabled, duplicateSearchEnabled, searchMode, showUpdatePanel, enableMassUpdate, showSearchView } = this.state;
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
						AutoSaveSearch={ Credentials.bSAVE_QUERY && Crm_Config.ToBoolean('save_query') }
						ShowSearchViews={ false }
						cbSearch={ this._onSearchViewCallback }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.searchView }
					/>
				</div>
				: null
				}
				<ListHeader MODULE_NAME={ MODULE_NAME } />
				<SplendidGrid
					onLayoutLoaded={ this._onGridLayoutLoaded }
					MODULE_NAME={ MODULE_NAME }
					RELATED_MODULE={ RELATED_MODULE }
					GRID_NAME={ GRID_NAME }
					TABLE_NAME={ TABLE_NAME }
					SORT_FIELD={ SORT_FIELD }
					SORT_DIRECTION={ SORT_DIRECTION }
					ADMIN_MODE={ true }
					AutoSaveSearch={ Credentials.bSAVE_QUERY && Crm_Config.ToBoolean('save_query') }
					deferLoad={ true }
					enableSelection={ enableMassUpdate || SplendidCache.AdminUserAccess(MODULE_NAME, 'export', this.constructor.name + '.render') >= 0 }
					selectionChanged={ this._onSelectionChanged }
					hyperLinkCallback={ this._onHyperLinkCallback }
					cbCustomColumns={ this.BootstrapColumns }
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

export default withRouter(CurrenciesListView);
