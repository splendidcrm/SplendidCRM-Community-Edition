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
import { RouteComponentProps }       from '../Router5'                 ;
import { observer }                  from 'mobx-react'                       ;
import BootstrapTable                from 'react-bootstrap-table-next'       ;
import { FontAwesomeIcon }           from '@fortawesome/react-fontawesome'   ;
import paginationFactory, { PaginationProvider, PaginationListStandalone, PaginationTotalStandalone } from 'react-bootstrap-table2-paginator';
import * as XMLParser                from 'fast-xml-parser'                  ;
// 2. Store and Types. 
import MODULE                        from '../types/MODULE'                  ;
import ACL_ACCESS                    from '../types/ACL_ACCESS'              ;
import ACL_FIELD_ACCESS              from '../types/ACL_FIELD_ACCESS'        ;
// 3. Scripts. 
import Sql                           from '../scripts/Sql'                   ;
import L10n                          from '../scripts/L10n'                  ;
import Security                      from '../scripts/Security'              ;
import Credentials                   from '../scripts/Credentials'           ;
import SplendidCache                 from '../scripts/SplendidCache'         ;
import SplendidDynamic               from '../scripts/SplendidDynamic'       ;
import { Crm_Config, Crm_Modules }   from '../scripts/Crm'                   ;
import { ListView_LoadLayout, ListView_LoadModulePaginated, ListView_LoadTablePaginated, ListView_ExportModule } from '../scripts/ListView';
import { AddToFavorites, RemoveFromFavorites, AddSubscription, RemoveSubscription } from '../scripts/ModuleUpdate';
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'        ;
import { Trim, inArray }             from '../scripts/utility'               ;
import { UpdateSavedSearch }         from '../scripts/ModuleUpdate'          ;
// 4. Components and Views. 
import DumpSQL                       from '../components/DumpSQL'            ;
import ErrorComponent                from '../components/ErrorComponent'     ;
import DynamicButtons                from '../components/DynamicButtons'     ;
import DateTime                      from '../GridComponents/DateTime'       ;
import Currency                      from '../GridComponents/Currency'       ;
import Tags                          from '../GridComponents/Tags'           ;
import HyperLink                     from '../GridComponents/HyperLink'      ;
import Hover                         from '../GridComponents/Hover'          ;
import Image                         from '../GridComponents/Image'          ;
import ImageButton                   from '../GridComponents/ImageButton'    ;
import JavaScript                    from '../GridComponents/JavaScript'     ;
import String                        from '../GridComponents/String'         ;
import LinkButton                    from '../GridComponents/LinkButton'     ;
import CheckBox                      from '../GridComponents/CheckBox'       ;
// 03/25/2022 Paul.  Add field chooser. 
import ListViewFieldChooser          from '../DynamicLayoutComponents/ListView/FieldChooser';
import NavItem                       from '../components/NavItem'            ;

interface ISplendidGridProps extends RouteComponentProps<any>
{
	MODULE_NAME             : string;
	RELATED_MODULE?         : string;
	GRID_NAME?              : string;
	TABLE_NAME?             : string;
	SORT_FIELD?             : string;
	SORT_DIRECTION?         : string;
	PRIMARY_FIELD?          : string;
	PRIMARY_ID?             : string;
	// 10/12/2020 Paul.  ADMIN_MENU is incorrect.  Use ADMIN_MODE instead. 
	ADMIN_MODE?             : boolean;
	selectionChanged?       : Function;
	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	hyperLinkCallback?      : (MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any) => void;
	scrollable?             : boolean;
	deferLoad?              : boolean;
	isPopupView?            : boolean;
	onLayoutLoaded?         : Function;
	readonly?               : boolean;
	enableSelection?        : boolean;
	cbRemove?               : (row: any) => void;
	cbShowRemove?           : (row: any) => boolean;
	deleteRelated?          : boolean;
	cbCustomLoad?           : (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) => any;
	cbCustomColumns?        : (sLIST_MODULE_NAME, layout, sPRIMARY_MODULE, sPRIMARY_ID) => any[];
	disableView?            : boolean;
	disableEdit?            : boolean;
	disableRemove?          : boolean;
	enableFavorites?        : boolean;
	enableFollowing?        : boolean;
	archiveView?            : boolean;
	enableMassUpdate?       : boolean;
	disablePagination?      : boolean;
	Page_Command?           : (sCommandName, sCommandArguments) => void;
	rowRequiredSearch?      : any;
	disableInitialLoading?  : boolean;
	ignoreMissingLayout?    : boolean;
	AutoSaveSearch?         : boolean;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data) => void;
	// 04/10/2022 Paul.  Move Pacific Export to pagination header. 
	enableExportHeader? : boolean;
}

interface ISplendidGridState
{
	layout                  : any;
	layoutAvailable?        : any;
	vwMain                  : any;
	columns                 : any;
	__total                 : number;
	__sql                   : string;
	SORT_FIELD              : string;
	SORT_DIRECTION          : string;
	GRID_NAME               : string;
	SEARCH_FILTER           : string;
	SEARCH_VALUES           : any;
	SELECT_FIELDS           : any;
	OnMainClicked           : Function;
	// 01/30/2013 Paul.  We need more data to sort relationship data.
	TABLE_NAME              : string;
	RELATED_MODULE          : string;
	PRIMARY_FIELD           : string;
	PRIMARY_ID              : string;
	// 08/31/2014 Paul.  Provide a way for the Offline Client to hide View and Edit buttons. 
	//HIDE_VIEW_EDIT          : boolean;
	// 02/27/2016 Paul.  Provide a way to hide the delete for LineItems. 
	//HIDE_DELETE             : boolean;
	SHOW_CONFLICTS          : boolean;
	loaded                  : boolean;
	activePage              : number;
	selectedItems           : any;
	selectedKeys            : any;
	checkedCount            : number;
	allChecked              : boolean;
	TOP                     : number;
	enableFavorites?        : boolean;
	enableFollowing?        : boolean;
	error?                  : any;
	// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
	tableKey?               : string;
	loading                 : boolean;
	exporting               : boolean;
	isOpenFieldChooser      : boolean;
	columnsChangedKey       : number;
	nSelectionKey           : number;
	// 04/10/2022 Paul.  Move Pacific Export to pagination header. 
	EXPORT_RANGE            : string;
	EXPORT_FORMAT           : string;
	EXPORT_RANGE_LIST       : any[];
	EXPORT_FORMAT_LIST      : any[];
}

@observer
class SplendidGrid extends React.Component<ISplendidGridProps, ISplendidGridState>
{
	private _isMounted = false;
	private dynamicButtons = React.createRef<DynamicButtons>();
	private themeURL: string = null;
	private legacyIcons: boolean = false;
	private searchCount: number  = 0;
	private chkPacificSelection: HTMLInputElement = null;

	private setStateAsync = (newState: Partial<ISplendidGridState>) =>
	{
		return new Promise((resolve) =>
		{
			// 05/26/2019 Paul.  The component may be unmounted by the time the custom view is generated. 
			if ( this._isMounted )
			{
				newState.error = null;
				// 02/20/2022 Paul.  Latest version of TypeScript does not allow resolve to return undefined, so return null. 
				this.setState(newState as ISplendidGridState, () => resolve(null) );
			}
		});
	}

	constructor(props: ISplendidGridProps)
	{
		super(props);
		let nTOP = Crm_Config.ToInteger('list_max_entries_per_page');
		if ( nTOP <= 0 )
		{
			nTOP = 25;
		}
		let enableFavorites: boolean = props.enableFavorites && !Crm_Config.ToBoolean('disable_favorites');
		// 08/06/2020 Paul.  Flag should be all lower case. 
		let enableFollowing: boolean = props.enableFollowing && !Crm_Config.ToBoolean('disable_following') && Crm_Config.ToBoolean('enable_activity_streams') && Crm_Modules.StreamEnabled(props.MODULE_NAME);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');

		// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
		let SORT_FIELD    : string = (props.SORT_FIELD     ? props.SORT_FIELD     : 'NAME');
		let SORT_DIRECTION: string = (props.SORT_DIRECTION ? props.SORT_DIRECTION : 'asc' );
		let GRID_NAME     : string = (props.GRID_NAME      ? props.GRID_NAME      : props.MODULE_NAME + (!!props.isPopupView ? '.PopupView' : '.ListView'));
		let GRIDVIEW      : any    = SplendidCache.GridViews(GRID_NAME, true);
		if ( GRIDVIEW )
		{
			if ( Sql.IsEmptyString(props.SORT_FIELD) && !Sql.IsEmptyString(GRIDVIEW.SORT_FIELD) )
			{
				SORT_FIELD     = GRIDVIEW.SORT_FIELD    ;
				SORT_DIRECTION = GRIDVIEW.SORT_DIRECTION;
			}
		}
		// 04/10/2022 Paul.  Move Pacific Export to pagination header. 
		let EXPORT_RANGE            : string = 'All'  ;
		let EXPORT_FORMAT           : string = 'Excel';
		let EXPORT_RANGE_LIST       : any[]  = [];
		let EXPORT_FORMAT_LIST      : any[]  = [];
		EXPORT_RANGE_LIST.push({ DISPLAY_NAME: L10n.Term('.LBL_LISTVIEW_OPTION_ENTIRE'  ), NAME: 'All'     });
		EXPORT_RANGE_LIST.push({ DISPLAY_NAME: L10n.Term('.LBL_LISTVIEW_OPTION_CURRENT' ), NAME: 'Page'    });
		// 03/18/2021 Paul.  Lists without selection checkboxes should not allow Selected option. 
		if ( props.enableSelection )
			EXPORT_RANGE_LIST.push({ DISPLAY_NAME: L10n.Term('.LBL_LISTVIEW_OPTION_SELECTED'), NAME: 'Selected'});
		
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_XML_SPREADSHEET'  ), NAME: 'Excel'   });
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_XML'              ), NAME: 'xml'     });
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_CUSTOM_CSV'       ), NAME: 'csv'     });
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_CUSTOM_TAB'       ), NAME: 'tab'     });
		this.state =
		{
			layout          : null,
			vwMain          : null,
			columns         : [],
			__total         : 0,
			__sql           : null,
			SORT_FIELD      ,
			SORT_DIRECTION  ,
			GRID_NAME       ,
			SELECT_FIELDS   : {},
			SEARCH_FILTER   : '',
			SEARCH_VALUES   : null,
			OnMainClicked   : null,
			TABLE_NAME      : Sql.ToString(props.TABLE_NAME     ),
			RELATED_MODULE  : Sql.ToString(props.RELATED_MODULE),
			PRIMARY_FIELD   : Sql.ToString(props.PRIMARY_FIELD  ),
			PRIMARY_ID      : Sql.ToString(props.PRIMARY_ID     ),
			//HIDE_VIEW_EDIT  : false,
			//HIDE_DELETE     : false,
			SHOW_CONFLICTS  : false,
			loaded          : false,
			activePage      : 1,
			selectedItems   : {},
			selectedKeys    : [],
			checkedCount    : 0,
			allChecked      : false,
			TOP             : nTOP,
			enableFavorites ,
			enableFollowing ,
			error           : null,
			tableKey        : props.GRID_NAME,
			loading         : !Sql.ToBoolean(props.disableInitialLoading),
			exporting       : false,
			isOpenFieldChooser: false,
			columnsChangedKey: 0,
			nSelectionKey    : 0,
			EXPORT_RANGE      ,
			EXPORT_FORMAT     ,
			EXPORT_RANGE_LIST ,
			EXPORT_FORMAT_LIST,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		this._isMounted = true;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', this.state.GRID_NAME);
		await this.preload();
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

 	async componentDidUpdate(prevProps: ISplendidGridProps)
	{
		const { MODULE_NAME, SORT_DIRECTION, TABLE_NAME, RELATED_MODULE, PRIMARY_FIELD, PRIMARY_ID, selectionChanged, isPopupView } = this.props;
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			let GRID_NAME      = (this.props.GRID_NAME      ? this.props.GRID_NAME      : MODULE_NAME + (isPopupView ? '.PopupView' : '.ListView'));
			let SORT_FIELD     = (this.props.SORT_FIELD     ? this.props.SORT_FIELD     : 'NAME');
			let SORT_DIRECTION = (this.props.SORT_DIRECTION ? this.props.SORT_DIRECTION : 'asc' );
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', GRID_NAME);
			// 05/27/2018 Paul.  If the location changes, then we need an all new state. 
			let nTOP = Crm_Config.ToInteger('list_max_entries_per_page');
			await this.setStateAsync({
				layout                  : null,
				vwMain                  : null,
				columns                 : [],
				__total                 : 0,
				SORT_FIELD              ,
				SORT_DIRECTION          ,
				GRID_NAME               ,
				SELECT_FIELDS           : {},
				SEARCH_FILTER           : '',
				SEARCH_VALUES           : null,
				OnMainClicked           : null,
				TABLE_NAME              : Sql.ToString(TABLE_NAME    ),
				RELATED_MODULE          : Sql.ToString(RELATED_MODULE),
				PRIMARY_FIELD           : Sql.ToString(PRIMARY_FIELD ),
				PRIMARY_ID              : Sql.ToString(PRIMARY_ID    ),
				//HIDE_VIEW_EDIT          : false,
				//HIDE_DELETE             : false,
				SHOW_CONFLICTS          : false,
				loaded                  : false,
				activePage              : 1,
				selectedItems           : {},
				selectedKeys            : [],
				allChecked              : false,
				TOP                     : nTOP,
			});
			// 06/24/2019 Paul.  When changing between list views, componentDidMount will fire, so we need the same preload. 
			await this.preload();
		}
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		else
		{
			if ( this.props.onComponentComplete )
			{
				const { GRID_NAME, layout, vwMain, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + GRID_NAME, vwMain);
				if ( layout != null && vwMain != null && error == null )
				{
					this.props.onComponentComplete(MODULE_NAME, RELATED_MODULE, GRID_NAME, vwMain);
				}
			}
		}
	}

	private preload = async () =>
	{
		const { MODULE_NAME } = this.props;
		const { GRID_NAME } = this.state;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.preload');
			if ( status == 1 )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.preload Authenticated', MODULE_NAME);
				await this.Load(MODULE_NAME, GRID_NAME);
			}
			else
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.preload Not authenticated, redirect to login', MODULE_NAME);
				LoginRedirect(this.props.history, this.constructor.name + '.preload');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.preload ', error);
			this.setState({ error });
		}
	}

	private Load = async (sMODULE_NAME: string, GRID_NAME: string) =>
	{
		const { match, ignoreMissingLayout } = this.props;
		const { SORT_FIELD, SORT_DIRECTION, RELATED_MODULE } = this.state;
		let sSORT_FIELD = SORT_FIELD;
		let sSORT_DIRECTION = SORT_DIRECTION;
		/*
		this.setState({ MODULE_NAME: sMODULE_NAME, GRID_NAME: GRID_NAME, SEARCH_FILTER: '', SEARCH_VALUES: null });
		*/
		// 07/29/2019 Pa8l.  I don't recall the reason for this correction. 
		if ( Sql.IsEmptyString(sSORT_FIELD) && Sql.IsEmptyString(RELATED_MODULE) )
		{
			if ( sMODULE_NAME == 'Quotes' )
			{
				sSORT_FIELD = 'QUOTE_NUM';
				sSORT_DIRECTION = 'desc';
				this.setState({ SORT_FIELD: sSORT_FIELD, SORT_DIRECTION: sSORT_DIRECTION });
			}
			else if ( sMODULE_NAME == 'Orders' )
			{
				sSORT_FIELD = 'ORDER_NUM';
				sSORT_DIRECTION = 'desc';
				this.setState({ SORT_FIELD: sSORT_FIELD, SORT_DIRECTION: sSORT_DIRECTION });
			}
			else if ( sMODULE_NAME == 'Invoices' )
			{
				sSORT_FIELD = 'INVOICE_NUM';
				sSORT_DIRECTION = 'desc';
				this.setState({ SORT_FIELD: sSORT_FIELD, SORT_DIRECTION: sSORT_DIRECTION });
			}
		}
		//this.OnMainClicked = bLIST_VIEW_ENABLE_SELECTION ? SelectionUI_chkMain_Clicked : null;

		try
		{
			const layout = ListView_LoadLayout(GRID_NAME, ignoreMissingLayout);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load layout', layout);
			// 03/25/2022 Paul.  Add support for field chooser. 
			const layoutAvailable = ListView_LoadLayout(GRID_NAME + '.Available', true);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load layoutAvailable', GRID_NAME + '.Available', layoutAvailable);
			// 06/19/2018 Paul.  Make sure to clear the data when loading the layout. 
			let SELECT_FIELDS = this.GridColumns(layout);
			let columns: any[] = null;
			if ( this.props.cbCustomColumns )
			{
				columns = this.props.cbCustomColumns(GRID_NAME, layout, sMODULE_NAME, null);
			}
			else
			{
				columns = this.BootstrapColumns(GRID_NAME, layout, sMODULE_NAME, null);
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load', arrSELECT_FIELDS, columns);
			await this.setStateAsync({
				layout       ,
				layoutAvailable,
				__total      : 0,
				vwMain       : null,
				SELECT_FIELDS,
				columns      ,
			});
			if ( this.props.onLayoutLoaded )
			{
				this.props.onLayoutLoaded();
			}
			// 04/27/2019 Paul.  Always defer load, otherwise the main lists will query twice. 
			if ( !this.props.deferLoad )
			{
				await this.Sort(sSORT_FIELD, sSORT_DIRECTION);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Load', error);
			this.setState({ error });
		}
	}

	private GridColumns = (layout) =>
	{
		const { MODULE_NAME, TABLE_NAME } = this.props;
		// 08/06/2020 Paul.  Additional conditions applied to flags. 
		const { enableFavorites, enableFollowing } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.GridColumns', layout);
		let arrSelectFields = Sql.SelectGridColumns(layout);

		// 05/01/2019 Paul.  The Edit button will be hidden if a process is pending. 
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '.GridColumns');
		if ( module != null )
		{
			if ( Sql.ToBoolean(module.PROCESS_ENABLED) )
			{
				if ( TABLE_NAME == Crm_Modules.TableName(MODULE_NAME) )
				{
					arrSelectFields.push('PENDING_PROCESS_ID');
				}
			}
		}
		else
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.GridColumns module not found', MODULE_NAME);
		}
		if ( enableFavorites )
		{
			arrSelectFields.push('FAVORITE_RECORD_ID');
		}
		if ( enableFollowing )
		{
			arrSelectFields.push('SUBSCRIPTION_PARENT_ID');
		}
		return arrSelectFields.join(',');
	}

	private formatKey = (ID, i) =>
	{
		return ID + '_' + i.toString();
	}

	private createKeys = (results: Array<any>) =>
	{
		const { selectedItems } = this.state;
		// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
		let selectedKeys = [];
		if ( results != null )
		{
			for ( let i = 0; i < results.length; i++ )
			{
				let row = results[i];
				// 12/25/2019 Paul.  For performance, we will want to pre-process each row and create arrERASED_FIELDS for each row. 
				if ( Crm_Config.enable_data_privacy() )
				{
					if ( row['ERASED_FIELDS'] !== undefined )
					{
						let arrERASED_FIELDS: string[] = Sql.ToString(row['ERASED_FIELDS']).split(',');
						row['arrERASED_FIELDS'] = arrERASED_FIELDS;
					}
				}
				row.ID_key = this.formatKey(row.ID, i);
				// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
				if ( selectedItems[row.ID] )
				{
					selectedKeys.push(row.ID_key);
				}
			}
		}
		return selectedKeys;
	}

	public boundColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		// 05/27/2018 Paul.  We will need all the layout fields in the render function. 
		let lay = formatExtraData.data.layout;
		return React.createElement(String, { layout: lay, row: row, multiLine: false });
	}

	public templateColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		const { hyperLinkCallback, ADMIN_MODE, isPopupView, Page_Command } = this.props;
		// 05/27/2018 Paul.  We will need all the layout fields in the render function.  
		let lay = formatExtraData.data.layout;
		let COLUMN_TYPE                = lay.COLUMN_TYPE;
		let COLUMN_INDEX               = lay.COLUMN_INDEX;
		let HEADER_TEXT                = lay.HEADER_TEXT;
		let SORT_EXPRESSION            = lay.SORT_EXPRESSION;
		let ITEMSTYLE_WIDTH            = lay.ITEMSTYLE_WIDTH;
		let ITEMSTYLE_CSSCLASS         = lay.ITEMSTYLE_CSSCLASS;
		let ITEMSTYLE_HORIZONTAL_ALIGN = lay.ITEMSTYLE_HORIZONTAL_ALIGN;
		let ITEMSTYLE_VERTICAL_ALIGN   = lay.ITEMSTYLE_VERTICAL_ALIGN;
		// 10/30/2020 Paul.  ITEMSTYLE_WRAP defaults to true. 
		let ITEMSTYLE_WRAP             = (lay.ITEMSTYLE_WRAP == null ? true : lay.ITEMSTYLE_WRAP);
		let DATA_FIELD                 = lay.DATA_FIELD;
		let DATA_FORMAT                = lay.DATA_FORMAT;
		let URL_FIELD                  = lay.URL_FIELD;
		let URL_FORMAT                 = lay.URL_FORMAT;
		let URL_TARGET                 = lay.URL_TARGET;
		let LIST_NAME                  = lay.LIST_NAME;
		let URL_MODULE                 = lay.URL_MODULE;
		let URL_ASSIGNED_FIELD         = lay.URL_ASSIGNED_FIELD;
		let VIEW_NAME                  = lay.VIEW_NAME;
		let MODULE_NAME                = lay.MODULE_NAME;
		let MODULE_TYPE                = lay.MODULE_TYPE;
		let PARENT_FIELD               = lay.PARENT_FIELD;

		let DATA_VALUE = '';
		if ( row[DATA_FIELD] != null || row[DATA_FIELD] === undefined )
		{
			// 12/01/2012 Paul.  Users cannot be viewed or edited. 
			// 12/04/2012 Paul.  We are going to allow users to be viewed and edited. 
			// 12/05/2012 Paul.  Only allow Users module if in Admin mode. 
			// 07/09/2019 Paul.  User selection is allowed in a popup. 
			try
			{
				// 10/12/2020 Paul.  ADMIN_MENU is incorrect.  Use ADMIN_MODE instead. 
				// 10/14/2020 Paul.  An admin can click on a user link. 
				if ( DATA_FORMAT == 'HyperLink' && (isPopupView || ADMIN_MODE || Security.IS_ADMIN() || URL_MODULE != 'Users') )
				{
					return React.createElement(HyperLink, { layout: lay, row: row, hyperLinkCallback });
				}
				else if ( DATA_FORMAT == 'Date' )
				{
					return React.createElement(DateTime, { layout: lay, row: row, dateOnly: true });
				}
				else if ( DATA_FORMAT == 'DateTime' )
				{
					return React.createElement(DateTime, { layout: lay, row: row, dateOnly: false });
				}
				else if ( DATA_FORMAT == 'Currency' )
				{
					let oNumberFormat = Security.NumberFormatInfo();
					if ( Crm_Config.ToString('currency_format') == 'c0' )
					{
						oNumberFormat.CurrencyDecimalDigits = 0;
					}
					return React.createElement(Currency, { layout: lay, row: row, numberFormat: oNumberFormat });
				}
				else if ( DATA_FORMAT == 'MultiLine' )
				{
					return React.createElement(String, { layout: lay, row: row, multiLine: true });
				}
				else if ( DATA_FORMAT == 'Image' )
				{
					return React.createElement(Image, { layout: lay, row: row });
				}
				else if ( DATA_FORMAT == 'JavaScript' )
				{
					return React.createElement(JavaScript, { layout: lay, row: row });
				}
				else if ( DATA_FORMAT == 'Hover' )
				{
					return React.createElement(Hover, { layout: lay, row: row });
				}
				else if ( DATA_FORMAT == 'ImageButton' )
				{
					return React.createElement(ImageButton, { layout: lay, row: row, Page_Command: Page_Command });
				}
				// 01/18/2020 Paul.  New LinkButton is only supported in React Client. 
				else if ( DATA_FORMAT == 'LinkButton' )
				{
					return React.createElement(LinkButton, { layout: lay, row: row, Page_Command: Page_Command });
				}
				// 11/10/2020 Paul.  New CheckBox is only supported in React Client. 
				else if ( DATA_FORMAT == 'CheckBox' )
				{
					return React.createElement(CheckBox, { layout: lay, row: row });
				}
				// 05/15/2016 Paul.  Add Tags module. 
				else if ( DATA_FORMAT == 'Tags' )
				{
					return React.createElement(Tags, { layout: lay, row: row });
				}
				else
				{
					return React.createElement(String, { layout: lay, row: row, multiLine: false });
				}
			}
			catch(error)
			{
				DATA_VALUE = error.message;
			}
		}
		return DATA_VALUE;
	}

	public _onEdit = (row) =>
	{
		const { history, MODULE_NAME, ADMIN_MODE } = this.props;
		let admin = '';
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onEdit');
		if ( module.IS_ADMIN )
		{
			admin = '/Administration';
		}
		history.push(`/Reset${admin}/${MODULE_NAME}/Edit/${row.ID}`);
		return false;
	}

	public _onView = (row) =>
	{
		const { history, MODULE_NAME, ADMIN_MODE } = this.props;
		let admin = '';
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onView');
		if ( module.IS_ADMIN )
		{
			admin = '/Administration';
		}
		history.push(`/Reset${admin}/${MODULE_NAME}/View/${row.ID}`);
		return false;
	}

	// 12/05/2021 Paul.  User should be able to open a new table by right-click on item name.  Change from span to anchor. 
	public getEditUrl = (row): string =>
	{
		const { history, MODULE_NAME, ADMIN_MODE } = this.props;
		let admin = '';
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '.getEditUrl');
		if ( module.IS_ADMIN )
		{
			admin = 'Administration/';
		}
		// 07/01/2023 Paul.  ASP.NET Core will not have /React in the base. 
		let url: string = Credentials.RemoteServer + Credentials.ReactBase + `${admin}${MODULE_NAME}/Edit/${row.ID}`;
		return url;
	}

	public getViewUrl = (row): string =>
	{
		const { history, MODULE_NAME, ADMIN_MODE } = this.props;
		let admin = '';
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onView');
		if ( module.IS_ADMIN )
		{
			admin = 'Administration/';
		}
		// 07/01/2023 Paul.  ASP.NET Core will not have /React in the base. 
		let url: string = Credentials.RemoteServer + Credentials.ReactBase + `${admin}${MODULE_NAME}/View/${row.ID}`;
		return url;
	}

	public _onChangeFavorites = async (row, rowIndex) =>
	{
		const { MODULE_NAME } = this.props;
		let { vwMain } = this.state;
		try
	{
			if ( Sql.IsEmptyGuid(row['FAVORITE_RECORD_ID']) )
			{
				// Include/javascript/Utilities.asmx/AddToFavorites
				await AddToFavorites(MODULE_NAME, row['ID']);
				vwMain[rowIndex]['FAVORITE_RECORD_ID'] = row['ID'];
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.setState( {vwMain, tableKey: this.state.tableKey + '*'} );
			}
			else
			{
				await RemoveFromFavorites(MODULE_NAME, row['ID']);
				vwMain[rowIndex]['FAVORITE_RECORD_ID'] = null;
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.setState( {vwMain, tableKey: this.state.tableKey + '*'} );
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeFavorites', error);
			this.setState({ error });
		}
		return false;
	}

	public _onChangeFollowing = async (row, rowIndex) =>
	{
		const { MODULE_NAME } = this.props;
		let { vwMain } = this.state;
		try
		{
			if ( Sql.IsEmptyGuid(row['SUBSCRIPTION_PARENT_ID']) )
			{
				// Include/javascript/Utilities.asmx/AddSubscription
				await AddSubscription(MODULE_NAME, row['ID']);
				vwMain[rowIndex]['SUBSCRIPTION_PARENT_ID'] = row['ID'];
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.setState( {vwMain, tableKey: this.state.tableKey + '*'} );
			}
			else
			{
				await RemoveSubscription(MODULE_NAME, row['ID']);
				vwMain[rowIndex]['SUBSCRIPTION_PARENT_ID'] = null;
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.setState( {vwMain, tableKey: this.state.tableKey + '*'} );
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeFollowing', error);
			this.setState({ error });
		}
		return false;
	}

	public editviewColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		// 04/13/2021 Paul.  Disable edit in archiveView. 
		const { MODULE_NAME, disableView, disableEdit, archiveView } = this.props;
		// 08/06/2020 Paul.  Additional conditions applied to flags. 
		const { enableFavorites, enableFollowing } = this.state;
		// 05/01/2019 Paul.  The edit button should be hidden if a process is pending on the record. 
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		// 08/11/2019 Paul.  Make sure the user has permission to create a record before loading the layout. 
		// sASSIGNED_USER_ID_FIELD is almost always ASSIGNED_USER_ID, but it is ACITIVTY_ASSIGNED_USER_ID for activities. 
		// Another exception is when using delete or remove with a relationship whereby the parent module assigned field is used. 
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
		// 10/23/2020 Paul.  Show activity type icon. 
		let ACTIVITY_TYPE: string = null;
		if ( MODULE_NAME == 'Activities' )
		{
			ACTIVITY_TYPE = Sql.ToString(row['ACTIVITY_TYPE']);
		}
		// 12/05/2021 Paul.  User should be able to open a new table by right-click on item name.  Change from span to anchor. 
		return (
			<span style={ { whiteSpace: 'nowrap'} }>
				{ MODULE_NAME == 'Activities' && !Sql.IsEmptyString(ACTIVITY_TYPE)
				? <img src={ this.themeURL + ACTIVITY_TYPE + '.gif'} alt={ L10n.ListTerm('moduleList', ACTIVITY_TYPE) } style={ {padding: '3px', borderWidth: '0px'} } />
				: null
				}
				{ nVIEW_ACLACCESS >= 0 && enableFavorites && Sql.IsEmptyGuid(row['FAVORITE_RECORD_ID'])
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onChangeFavorites(row, rowIndex) } title={ L10n.Term('.LBL_ADD_TO_FAVORITES'     ) }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'favorites_add.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon={ { prefix: 'far', iconName: 'star' } } size="lg" color='#FFB518' />
					}
				</span>
				: null
				}
				{ nVIEW_ACLACCESS >= 0 && enableFavorites && !Sql.IsEmptyGuid(row['FAVORITE_RECORD_ID'])
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onChangeFavorites(row, rowIndex) } title={ L10n.Term('.LBL_REMOVE_FROM_FAVORITES') }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'favorites_remove.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon={ { prefix: 'fas', iconName: 'star' } } size='lg' color='#FFB518' />
					}
				</span>
				: null
				}
				{ nVIEW_ACLACCESS >= 0 && enableFollowing && Sql.IsEmptyGuid(row['SUBSCRIPTION_PARENT_ID'])
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onChangeFollowing(row, rowIndex) } title={ L10n.Term('.LBL_FOLLOW'   ) }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'follow.png'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon={ { prefix: 'far', iconName: 'arrow-alt-circle-right' } } size="lg" color='#EF7B00' />
					}
				</span>
				: null
				}
				{ nVIEW_ACLACCESS >= 0 && enableFollowing && !Sql.IsEmptyGuid(row['SUBSCRIPTION_PARENT_ID'])
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onChangeFollowing(row, rowIndex) } title={ L10n.Term('.LBL_FOLLOWING') }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'following.png'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon={ { prefix: 'fas', iconName: 'arrow-alt-circle-right' } } size='lg' color='#EF7B00' />
					}
				</span>
				: null
				}
				{ !disableView && nVIEW_ACLACCESS >= 0
				? <a href={ this.getViewUrl(row) } style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ (e) => { e.preventDefault(); this._onView(row); } } title={ L10n.Term('.LNK_VIEW') }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'view_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon='file' size='lg' />
					}
				</a>
				: null
				}
				{ !(disableEdit || archiveView) && nEDIT_ACLACCESS >= 0 && Sql.IsEmptyGuid(row.PENDING_PROCESS_ID)
				? <a href={ this.getEditUrl(row) } style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ (e) => { e.preventDefault(); this._onEdit(row); } } title={ L10n.Term('.LNK_EDIT') }>
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

	private _onEditRelated = (row) =>
	{
		const { history, RELATED_MODULE, ADMIN_MODE } = this.props;
		let admin = '';
		let module:MODULE = SplendidCache.Module(RELATED_MODULE, this.constructor.name + '._onEditRelated');
		if ( module.IS_ADMIN )
		{
			admin = '/Administration';
		}
		history.push(`/Reset${admin}/${RELATED_MODULE}/Edit/${row.ID}`);
		return false;
	}

	private _onViewRelated = (row) =>
	{
		const { history, RELATED_MODULE, ADMIN_MODE } = this.props;
		let admin = '';
		let module:MODULE = SplendidCache.Module(RELATED_MODULE, this.constructor.name + '._onViewRelated');
		if ( module.IS_ADMIN )
		{
			admin = '/Administration';
		}
		history.push(`/Reset${admin}/${RELATED_MODULE}/View/${row.ID}`);
		return false;
	}

	private _onRemoveRelated = (row) =>
	{
		const { cbRemove } = this.props;
		if ( cbRemove )
		{
			cbRemove(row);
		}
		return false;
	}

	// 08/18/2019 Paul.  A related view will have separate access rigths based on the related module and related assigned field. 
	public editviewRelatedFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		// 04/13/2021 Paul.  Disable edit in archiveView. 
		const { RELATED_MODULE, disableView, disableEdit, disableRemove, cbRemove, deleteRelated, cbShowRemove, archiveView } = this.props;
		// 05/01/2019 Paul.  The edit button should be hidden if a process is pending on the record. 
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		// 08/11/2019 Paul.  Make sure the user has permission to create a record before loading the layout. 
		// sASSIGNED_USER_ID_FIELD is almost always ASSIGNED_USER_ID, but it is ACITIVTY_ASSIGNED_USER_ID for activities. 
		// Another exception is when using delete or remove with a relationship whereby the parent module assigned field is used. 
		// 11/04/2020 Paul.  Should default to ASSIGNED_USER_ID. 
		let sASSIGNED_USER_ID_FIELD: string = 'ASSIGNED_USER_ID';
		if ( RELATED_MODULE == 'Activities' )
		{
			sASSIGNED_USER_ID_FIELD = Crm_Modules.SingularTableName(Crm_Modules.TableName(RELATED_MODULE)) + '_ASSIGNED_USER_ID';
		}
		let nVIEW_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "view"  , sASSIGNED_USER_ID_FIELD);
		let nEDIT_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "edit"  , sASSIGNED_USER_ID_FIELD);
		let nDELETE_ACLACCESS: number = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "remove", sASSIGNED_USER_ID_FIELD);
		// 08/18/2019 Paul.  Activities are deleted not removed. 
		if ( RELATED_MODULE == 'Activities' )
		{
			nDELETE_ACLACCESS = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "delete", sASSIGNED_USER_ID_FIELD);
		}
		// 11/02/2020 Paul.  We don't want to combine favorites and disableView. 
		//if ( disableView )
		//{
		//	nVIEW_ACLACCESS = -1;
		//}
		//if ( disableEdit )
		//{
		//	nEDIT_ACLACCESS = -1;
		//}
		if ( disableRemove )
		{
			nDELETE_ACLACCESS = -1;
		}
		let sRemoveTitle: string = L10n.Term('.LNK_REMOVE');
		if ( deleteRelated )
		{
			sRemoveTitle = L10n.Term('.LNK_DELETE');
		}
		// 10/12/2020 Paul.  Add activity type. 
		let ACTIVITY_TYPE: string = null;
		if ( RELATED_MODULE == 'Activities' )
		{
			ACTIVITY_TYPE = Sql.ToString(row['ACTIVITY_TYPE']);
		}
		return (
			<span style={ {whiteSpace: 'nowrap'} }>
				{ RELATED_MODULE == 'Activities' && !Sql.IsEmptyString(ACTIVITY_TYPE)
				? <img src={ this.themeURL + ACTIVITY_TYPE + '.gif'} alt={ L10n.ListTerm('moduleList', ACTIVITY_TYPE) } style={ {padding: '3px', borderWidth: '0px'} } />
				: null
				}
				{ !disableView && nVIEW_ACLACCESS >= 0
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onViewRelated(row) } title={ L10n.Term('.LNK_VIEW') }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'view_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon='file' size='lg' />
					}
				</span>
				: null
				}
				{ !this.legacyIcons && !(disableEdit || archiveView) && nEDIT_ACLACCESS >= 0 && Sql.IsEmptyGuid(row.PENDING_PROCESS_ID)
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onEditRelated(row) } title={ L10n.Term('.LNK_EDIT') }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'edit_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon='edit' size='lg' />
					}
				</span>
				: null
				}
				{ !this.legacyIcons && nDELETE_ACLACCESS >= 0 && Sql.IsEmptyGuid(row.PENDING_PROCESS_ID) && cbRemove && (!cbShowRemove || cbShowRemove(row))
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={() => this._onRemoveRelated(row) } title={ sRemoveTitle }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'delete_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon='times' size='lg' />
					}
				</span>
				: null
				}
			</span>
		);
	}

	// 11/04/2020 Paul.  Legacy icons means that the remove is on the right. 
	public editviewRelatedFormatterLegacy = (cell, row, rowIndex, formatExtraData) =>
	{
		// 04/13/2021 Paul.  Disable edit in archiveView. 
		const { RELATED_MODULE, disableView, disableEdit, disableRemove, cbRemove, deleteRelated, cbShowRemove, archiveView } = this.props;
		// 05/01/2019 Paul.  The edit button should be hidden if a process is pending on the record. 
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		// 08/11/2019 Paul.  Make sure the user has permission to create a record before loading the layout. 
		// sASSIGNED_USER_ID_FIELD is almost always ASSIGNED_USER_ID, but it is ACITIVTY_ASSIGNED_USER_ID for activities. 
		// Another exception is when using delete or remove with a relationship whereby the parent module assigned field is used. 
		// 11/04/2020 Paul.  Should default to ASSIGNED_USER_ID. 
		let sASSIGNED_USER_ID_FIELD: string = 'ASSIGNED_USER_ID';
		if ( RELATED_MODULE == 'Activities' )
		{
			sASSIGNED_USER_ID_FIELD = Crm_Modules.SingularTableName(Crm_Modules.TableName(RELATED_MODULE)) + '_ASSIGNED_USER_ID';
		}
		let nVIEW_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "view"  , sASSIGNED_USER_ID_FIELD);
		let nEDIT_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "edit"  , sASSIGNED_USER_ID_FIELD);
		let nDELETE_ACLACCESS: number = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "remove", sASSIGNED_USER_ID_FIELD);
		// 08/18/2019 Paul.  Activities are deleted not removed. 
		if ( RELATED_MODULE == 'Activities' )
		{
			nDELETE_ACLACCESS = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "delete", sASSIGNED_USER_ID_FIELD);
		}
		// 11/02/2020 Paul.  We don't want to combine favorites and disableView. 
		//if ( disableView )
		//{
		//	nVIEW_ACLACCESS = -1;
		//}
		//if ( disableEdit )
		//{
		//	nEDIT_ACLACCESS = -1;
		//}
		if ( disableRemove )
		{
			nDELETE_ACLACCESS = -1;
		}
		let sRemoveTitle: string = L10n.Term('.LNK_REMOVE');
		if ( deleteRelated )
		{
			sRemoveTitle = L10n.Term('.LNK_DELETE');
		}
		// 10/12/2020 Paul.  Add activity type. 
		let ACTIVITY_TYPE: string = null;
		if ( RELATED_MODULE == 'Activities' )
		{
			ACTIVITY_TYPE = Sql.ToString(row['ACTIVITY_TYPE']);
		}
		return (
			<span style={ {whiteSpace: 'nowrap'} }>
				{ !(disableEdit || archiveView) && nEDIT_ACLACCESS >= 0 && Sql.IsEmptyGuid(row.PENDING_PROCESS_ID)
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onEditRelated(row) } title={ L10n.Term('.LNK_EDIT') }>
					{ L10n.Term('.LNK_EDIT') }
					&nbsp;
					{ this.legacyIcons
					? <img src={ this.themeURL + 'edit_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon='edit' size='lg' />
					}
				</span>
				: null
				}
				{ nDELETE_ACLACCESS >= 0 && Sql.IsEmptyGuid(row.PENDING_PROCESS_ID) && cbRemove && (!cbShowRemove || cbShowRemove(row))
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={() => this._onRemoveRelated(row) } title={ sRemoveTitle }>
					{ sRemoveTitle }
					&nbsp;
					{ this.legacyIcons
					? <img src={ this.themeURL + 'delete_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon='times' size='lg' />
					}
				</span>
				: null
				}
			</span>
		);
	}

	private _onButtonsLoaded = async () =>
	{
		const { MODULE_NAME, archiveView } = this.props;
		if ( this.dynamicButtons.current != null )
		{
			let nACLACCESS_Archive: number = SplendidCache.GetUserAccess(MODULE_NAME, 'archive', this.constructor.name + '_onButtonsLoaded');
			let nACLACCESS_Delete : number = SplendidCache.GetUserAccess(MODULE_NAME, 'delete' , this.constructor.name + '_onButtonsLoaded');
			let nACLACCESS_Edit   : number = SplendidCache.GetUserAccess(MODULE_NAME, 'edit'   , this.constructor.name + '_onButtonsLoaded');
			this.dynamicButtons.current.ShowButton('MassUpdate'         , nACLACCESS_Edit   >= 0);
			this.dynamicButtons.current.ShowButton('MassDelete'         , nACLACCESS_Delete >= 0);
			this.dynamicButtons.current.ShowButton('Archive.MoveData'   , (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) && !archiveView && Crm_Modules.ArchiveEnabled(MODULE_NAME));
			this.dynamicButtons.current.ShowButton('Archive.RecoverData', (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) &&  archiveView && Crm_Modules.ArchiveEnabled(MODULE_NAME));
			this.dynamicButtons.current.ShowButton('Sync'               , Crm_Modules.ExchangeFolders(MODULE_NAME) && Security.HasExchangeAlias());
			this.dynamicButtons.current.ShowButton('Unsync'             , Crm_Modules.ExchangeFolders(MODULE_NAME) && Security.HasExchangeAlias());
		}
	}

	public renderHeader = (column, colIndex, { sortElement, filterElement }) =>
	{
		const { MODULE_NAME, enableSelection, enableMassUpdate, Page_Command, archiveView, isPopupView } = this.props;
		if ( enableSelection && colIndex == 0 )
		{
			// 04/07/2022 Paul.  MassUpdate buttons have been moved to pagination line for the Pacific theme. 
			let sTheme: string = SplendidCache.UserTheme;
			if ( enableMassUpdate && Page_Command && SplendidDynamic.StackedLayout(sTheme) && sTheme != 'Pacific' )
			{
				// 10/28/2020 Paul.  Must use ArchiveView buttons when in archive view. 
				return (<DynamicButtons
					ButtonStyle='DataGrid'
					VIEW_NAME={ MODULE_NAME + '.MassUpdate' + (archiveView ? '.ArchiveView' : '') }
					row={ null }
					Page_Command={ Page_Command }
					onLayoutLoaded={ this._onButtonsLoaded }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.dynamicButtons }
				/>);
			}
			// 07/03/2021 Paul.  SurveyQuestions.PopupView is not showing the header of the first column. 
			else if ( isPopupView && column.text != null )
			{
				if ( column.text != null && column.text.indexOf('<br') >= 0 )
				{
					// 01/18/2020 Paul.  Allow the <br/> tag. 
					return (<div><span dangerouslySetInnerHTML={ {__html: column.text} } /> { sortElement }</div>);
				}
				else
				{
					return (<div>{ column.text} { sortElement }</div>);
				}
			}
			else
			{
				return (<div></div>);
			}
		}
		else
		{
			if ( column.text != null && column.text.indexOf('<br') >= 0 )
			{
				// 01/18/2020 Paul.  Allow the <br/> tag. 
				return (<div><span dangerouslySetInnerHTML={ {__html: column.text} } /> { sortElement }</div>);
			}
			else
			{
				return (<div>{ column.text} { sortElement }</div>);
			}
		}
	}

	private BootstrapColumns = (sLIST_MODULE_NAME, layout, sPRIMARY_MODULE, sPRIMARY_ID) =>
	{
		const { readonly, isPopupView, RELATED_MODULE, disableView, disableEdit, disableRemove } = this.props;
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
						formatter      : this.editviewRelatedFormatter,
						headerClasses  : 'listViewThS2',
						headerStyle    : {padding: 0, margin: 0},
						headerFormatter: this.renderHeader,
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
					formatter      : this.editviewColumnFormatter,
					headerClasses  : 'listViewThS2',
					headerStyle    : {padding: 0, margin: 0},
					headerFormatter: this.renderHeader,
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
		let bEnableDynamicAssignment = Crm_Config.enable_dynamic_assignment();
		// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
		let oNumberFormat = Security.NumberFormatInfo();
		if ( Crm_Config.ToString('currency_format') == 'c0' )
		{
			oNumberFormat.CurrencyDecimalDigits = 0;
		}
		let sTheme: string = SplendidCache.UserTheme;
		if ( layout != null )
		{
			for ( let nLayoutIndex = 0; layout != null && nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay = layout[nLayoutIndex];
				// 08/21/2022 Paul.  Don't swap TEAM_SET_NAME on Users.Teams panel.
				let GRID_NAME                  = lay.GRID_NAME                 ;
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
					if ( bEnableTeamManagement )
					{
						// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
						// 04/03/2021 Paul.  Apply single rule. 
						// 08/21/2022 Paul.  Don't swap TEAM_SET_NAME on Users.Teams panel.
						if ( bEnableDynamicTeams && DATA_FORMAT != '1' && Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('single') < 0 && GRID_NAME.indexOf('.Teams') < 0 )
						{
							HEADER_TEXT = '.LBL_LIST_TEAM_SET_NAME';
							DATA_FIELD  = 'TEAM_SET_NAME';
						}
						else
						{
							HEADER_TEXT = '.LBL_LIST_TEAM_NAME';
							DATA_FIELD  = 'TEAM_NAME';
						}
					}
					else
					{
						// 10/24/2012 Paul.  Clear the sort so that there would be no term lookup. 
						HEADER_TEXT     = null;
						SORT_EXPRESSION = null;
						COLUMN_TYPE     = 'Hidden';
					}
				}
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				// 04/03/2021 Paul.  Dynamic Assignment must be managed here as well as in SplendidGrid. 
				else if ( DATA_FIELD == 'ASSIGNED_TO' || DATA_FIELD == 'ASSIGNED_TO_NAME' || DATA_FIELD == 'ASSIGNED_SET_NAME' )
				{
					// 12/17/2017 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
					if ( bEnableDynamicAssignment && Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('single') < 0 )
					{
						HEADER_TEXT = '.LBL_LIST_ASSIGNED_SET_NAME';
						DATA_FIELD  = 'ASSIGNED_SET_NAME';
					}
					else if ( DATA_FIELD == 'ASSIGNED_SET_NAME' )
					{
						HEADER_TEXT = '.LBL_LIST_ASSIGNED_USER';
						DATA_FIELD  = 'ASSIGNED_TO_NAME';
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
					// 04/06/2022 Paul.  Only Seven theme supports preview at this time. 
					bIsReadable = bIsReadable && SplendidDynamic.StackedLayout(SplendidCache.UserTheme) && sTheme == 'Seven';
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
						headerFormatter: this.renderHeader,
						formatter      : this.templateColumnFormatter,
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
					//if ( SplendidCache.UserTheme == 'Arctic' )
					//{
					//	objDataColumn.headerStyle.paddingTop    = '10px';
					//	objDataColumn.headerStyle.paddingBottom = '10px';
					//}
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
						headerFormatter: this.renderHeader,
						formatter      : this.boundColumnFormatter,
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
					//if ( SplendidCache.UserTheme == 'Arctic' )
					//{
					//	objDataColumn.headerStyle.paddingTop    = '10px';
					//	objDataColumn.headerStyle.paddingBottom = '10px';
					//}
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
						formatter      : this.editviewRelatedFormatterLegacy,
						headerClasses  : 'listViewThS2',
						headerStyle    : {padding: 0, margin: 0},
						headerFormatter: this.renderHeader,
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
		return arrDataTableColumns;
	}

	private Sort = async (sSORT_FIELD: string, sSORT_DIRECTION: string) =>
	{
		const { MODULE_NAME, ADMIN_MODE, cbCustomLoad, archiveView, rowRequiredSearch } = this.props;
		const { layout, SEARCH_FILTER, SELECT_FIELDS, SEARCH_VALUES, RELATED_MODULE, TABLE_NAME, PRIMARY_FIELD, PRIMARY_ID, TOP } = this.state;
		// 02/23/2021 Paul.  The activePage state value will not be updated locally, so use a local variable instead to prevent stale page number. 
		let activePage: number = 1;
		// 05/06/2021 Paul.  Track browser history changes so that we can determine if last event was a POP event. 
		if ( this.searchCount == 0 && SplendidCache.lastHistoryAction == 'POP' && this.state.GRID_NAME.indexOf('.ListView') >= 0 )
		{
			activePage = SplendidCache.getGridLastPage(this.state.GRID_NAME);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Sort ' + this.state.GRID_NAME + ' Last Page = ' + activePage);
		}
		else
		{
			SplendidCache.setGridLastPage(this.state.GRID_NAME, activePage);
		}
		this.searchCount++;
		// 08/10/2020 Paul.  Convert to sort expression. 
		if ( layout )
		{
			for ( let i: number = 0; i < layout.length; i++ )
			{
				if ( layout[i].DATA_FIELD == sSORT_FIELD )
				{
					sSORT_FIELD = layout[i].SORT_EXPRESSION;
					break;
				}
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Sort', SEARCH_FILTER);
		await this.setStateAsync({ activePage, SORT_FIELD: sSORT_FIELD, SORT_DIRECTION: sSORT_DIRECTION, loading: true });
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.Sort');
			if ( status == 1 )
			{
				// 06/10/2018 Paul.  If RELATED_MODULE is specified, then we need to filter by PRIMARY_FIELD. 
				let rowSEARCH_VALUES: any = SEARCH_VALUES;
				// 01/20/2020 Paul.  Required values are always applied. 
				if ( rowRequiredSearch )
				{
					rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
					if ( rowSEARCH_VALUES == null )
					{
						rowSEARCH_VALUES = {};
					}
					for ( let sField in rowRequiredSearch )
					{
						rowSEARCH_VALUES[sField] =
						{
							FIELD_TYPE : 'Hidden',
							DATA_FORMAT: null,
							value      : rowRequiredSearch[sField]
						};
					}
				}
				// 01/30/2013 Paul.  Sorting a relationship view tasks extra effort.  We need to clear the layout panel and render again as a relationship panel. 
				// 06/10/2018 Paul.  If TABLE_NAME is specified, then use the LoadTable function. 
				// 08/30/2019 Paul.  ActivitiesPopup needs to use a custom load method. 
				if ( cbCustomLoad )
				{
					// 06/23/2020 Paul.  Use table name if provided. 
					if ( !Sql.IsEmptyString(TABLE_NAME) )
					{
						// 06/23/2020 Paul.  If RELATED_MODULE is specified, then we need to filter by PRIMARY_FIELD. 
						if ( !Sql.IsEmptyString(RELATED_MODULE) )
						{
							//if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
							//	sSEARCH_FILTER += ' and ';
							//sSEARCH_FILTER += PRIMARY_FIELD + ' eq \'' + PRIMARY_ID + '\'';
							// 11/18/2019 Paul.  Best to send Search Filter or Search Values, but not both. 
							rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
							if ( rowSEARCH_VALUES == null )
							{
								rowSEARCH_VALUES = {};
							}
							rowSEARCH_VALUES[PRIMARY_FIELD] = { FIELD_TYPE: 'Hidden', value: PRIMARY_ID };
						}
						let d = await cbCustomLoad(TABLE_NAME, sSORT_FIELD, sSORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView);
						// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
						let selectedKeys = this.createKeys(d.results);
						// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
						await this.setStateAsync(
						{
							__total     : d.__total,
							__sql       : d.__sql,
							vwMain      : d.results,
							loading     : false,
							tableKey    : this.state.tableKey + '*',
							selectedKeys,
						});
					}
					else
					{
						let d = await cbCustomLoad(MODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView);
						// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
						let selectedKeys = this.createKeys(d.results);
						// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
						await this.setStateAsync(
						{
							__total     : d.__total,
							__sql       : d.__sql,
							vwMain      : d.results,
							loading     : false,
							tableKey    : this.state.tableKey + '*',
							selectedKeys,
						});
					}
				}
				else if ( !Sql.IsEmptyString(TABLE_NAME) )
				{
					//let sSEARCH_FILTER = SEARCH_FILTER;
					// 06/10/2018 Paul.  If RELATED_MODULE is specified, then we need to filter by PRIMARY_FIELD. 
					if ( !Sql.IsEmptyString(RELATED_MODULE) )
					{
						//if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
						//	sSEARCH_FILTER += ' and ';
						//sSEARCH_FILTER += PRIMARY_FIELD + ' eq \'' + PRIMARY_ID + '\'';
						// 11/18/2019 Paul.  Best to send Search Filter or Search Values, but not both. 
						rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
						if ( rowSEARCH_VALUES == null )
						{
							rowSEARCH_VALUES = {};
						}
						rowSEARCH_VALUES[PRIMARY_FIELD] = { FIELD_TYPE: 'Hidden', value: PRIMARY_ID };
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Sort: ' + SELECT_FIELDS, sSEARCH_FILTER);
					let d = await ListView_LoadTablePaginated(TABLE_NAME, sSORT_FIELD, sSORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView);
					// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
					let selectedKeys = this.createKeys(d.results);
					// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
					await this.setStateAsync(
					{
						__total     : d.__total,
						__sql       : d.__sql,
						vwMain      : d.results,
						loading     : false,
						tableKey    : this.state.tableKey + '*',
						selectedKeys,
					});
				}
				else
				{
					// 05/21/2018 Paul.  SEARCH_FILTER is not getting quickly enough. 
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Sort: ' + SELECT_FIELDS, SEARCH_FILTER);
					try
					{
						let d = await ListView_LoadModulePaginated(MODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView);
						// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
						let selectedKeys = this.createKeys(d.results);
						// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
						await this.setStateAsync(
						{
							__total     : d.__total,
							__sql       : d.__sql,
							vwMain      : d.results,
							loading     : false,
							tableKey    : this.state.tableKey + '*',
							selectedKeys,
						});
					}
					catch(error)
					{
						console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Sort', error);
						this.setState({ error: this.constructor.name + '.Sort: ' + error.message, loading: false });
					}
				}
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.Sort');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Sort ', error);
			this.setState({ error: this.constructor.name + '.Sort: ' + error.message, loading: false });
		}
	}

	// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
	// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
	public Search = async (sSEARCH_FILTER: string, rowSEARCH_VALUES: any, oSORT?: any) =>
	{
		const { MODULE_NAME, ADMIN_MODE, cbCustomLoad, archiveView, rowRequiredSearch } = this.props;
		const { layout, SEARCH_FILTER, SEARCH_VALUES, SELECT_FIELDS, RELATED_MODULE, TABLE_NAME, PRIMARY_FIELD, PRIMARY_ID, TOP } = this.state;
		// 02/23/2021 Paul.  The activePage state value will not be updated locally, so use a local variable instead to prevent stale page number. 
		let activePage: number = 1;
		// 05/06/2021 Paul.  Track browser history changes so that we can determine if last event was a POP event. 
		if ( this.searchCount == 0 && SplendidCache.lastHistoryAction == 'POP' && this.state.GRID_NAME.indexOf('.ListView') >= 0 )
		{
			activePage = SplendidCache.getGridLastPage(this.state.GRID_NAME);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Search ' + this.state.GRID_NAME + ' Last Page = ' + activePage);
		}
		else
		{
			SplendidCache.setGridLastPage(this.state.GRID_NAME, activePage);
		}
		this.searchCount++;
		let { SORT_FIELD, SORT_DIRECTION } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Search', sSEARCH_FILTER, rowSEARCH_VALUES);
		await this.setStateAsync({ activePage, SEARCH_FILTER: sSEARCH_FILTER, SEARCH_VALUES: rowSEARCH_VALUES, loading: true });
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.Search');
			if ( status == 1 )
			{
				// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
				if ( oSORT )
				{
					SORT_FIELD     = oSORT.SORT_FIELD    ;
					SORT_DIRECTION = oSORT.SORT_DIRECTION;
				}
				// 01/20/2020 Paul.  Required values are always applied. 
				if ( rowRequiredSearch )
				{
					rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
					if ( rowSEARCH_VALUES == null )
					{
						rowSEARCH_VALUES = {};
					}
					for ( let sField in rowRequiredSearch )
					{
						rowSEARCH_VALUES[sField] =
						{
							FIELD_TYPE : 'Hidden',
							DATA_FORMAT: null,
							value      : rowRequiredSearch[sField]
						};
					}
				}
				// 01/30/2013 Paul.  Sorting a relationship view tasks extra effort.  We need to clear the layout panel and render again as a relationship panel. 
				// 06/10/2018 Paul.  If TABLE_NAME is specified, then use the LoadTable function. 
				// 08/30/2019 Paul.  ActivitiesPopup needs to use a custom load method. 
				if ( cbCustomLoad )
				{
					let d = await cbCustomLoad(MODULE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView);
					// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
					let selectedKeys = this.createKeys(d.results);
					// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
					await this.setStateAsync(
					{
						__total       : d.__total,
						__sql         : d.__sql,
						vwMain        : d.results,
						loading       : false,
						tableKey      : this.state.tableKey + '*',
						SORT_FIELD    ,
						SORT_DIRECTION,
						selectedKeys  ,
					});
				}
				else if (!Sql.IsEmptyString(TABLE_NAME))
				{
					// 06/10/2018 Paul.  If RELATED_MODULE is specified, then we need to filter by PRIMARY_FIELD. 
					if ( !Sql.IsEmptyString(RELATED_MODULE) )
					{
						// 05/21/2018 Paul.  SEARCH_FILTER is not getting quickly enough, so use parameters. 
						//if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
						//	sSEARCH_FILTER += ' and ';
						//sSEARCH_FILTER += PRIMARY_FIELD + ' eq \'' + PRIMARY_ID + '\'';
						// 11/18/2019 Paul.  Best to send Search Filter or Search Values, but not both. 
						rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
						if ( rowSEARCH_VALUES == null )
						{
							rowSEARCH_VALUES = [];
						}
						rowSEARCH_VALUES[PRIMARY_FIELD] = { FIELD_TYPE: 'Hidden', value: PRIMARY_ID };
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Search: ' + SELECT_FIELDS, sSEARCH_FILTER);
					let d = await ListView_LoadTablePaginated(TABLE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView);
					// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
					let selectedKeys = this.createKeys(d.results);
					// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
					// 05/06/2021 Paul.  activePage may not have been set to 1. 
					await this.setStateAsync(
					{
						__total       : d.__total,
						__sql         : d.__sql,
						vwMain        : d.results,
						activePage    ,
						loading       : false,
						tableKey      : this.state.tableKey + '*',
						SORT_FIELD    ,
						SORT_DIRECTION,
						selectedKeys  ,
					});
				}
				else
				{
					// 05/21/2018 Paul.  SEARCH_FILTER is not getting quickly enough, so use parameters. 
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Search: ' + SELECT_FIELDS, sSEARCH_FILTER);
					let d = await ListView_LoadModulePaginated(MODULE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView);
					// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
					let selectedKeys = this.createKeys(d.results);
					// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
					// 05/06/2021 Paul.  activePage may not have been set to 1. 
					await this.setStateAsync(
					{
						__total       : d.__total,
						__sql         : d.__sql,
						vwMain        : d.results,
						activePage    ,
						loading       : false,
						tableKey      : this.state.tableKey + '*',
						SORT_FIELD    ,
						SORT_DIRECTION,
						selectedKeys  ,
					});
				}
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.Search');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Search', error);
			this.setState({ error, loading: false });
		}
	}

	// https://github.com/react-bootstrap-table/react-bootstrap-table2/tree/master/docs#onTableChange
	private handleTableChange = (type, { sortField, sortOrder }) =>
	{
		const { MODULE_NAME, AutoSaveSearch, Page_Command } = this.props;
		const { SORT_FIELD, SORT_DIRECTION, SEARCH_VALUES } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handleTableChange', sortField, SEARCH_VALUES);
		if ( type == 'sort' )
		{
			// 05/08/2019 Paul.  Block sort event if values have not changed. 
			// This should prevent the double query when list first loaded. 
			if ( SORT_FIELD != sortField || SORT_DIRECTION != sortOrder)
			{
				this.Sort(sortField, sortOrder);
				// 11/11/2020 Paul.  We need to send the grid sort event to the SearchView. 
				if ( Page_Command )
				{
					Page_Command('sort', { sortField, sortOrder } );
				}
				// 11/09/2020 Paul.  Auto save the search with the new sort field. 
				if ( AutoSaveSearch )
				{
					let arrSearchFilter = SEARCH_VALUES;
					let arrSavedSearchFields = new Array();
					for ( let DATA_FIELD in arrSearchFilter )
					{
						let objField: any = new Object();
						arrSavedSearchFields.push(objField);
						objField['@Name'] = DATA_FIELD;
						objField['@Type'] = arrSearchFilter[DATA_FIELD].FIELD_TYPE;
						objField.Value    = arrSearchFilter[DATA_FIELD].value;
					}

					let objSavedSearch: any = new Object();
					objSavedSearch.SavedSearch                    = new Object();
					objSavedSearch.SavedSearch.SortColumn         = new Object();
					objSavedSearch.SavedSearch.SortColumn.Value   = 'NAME';
					objSavedSearch.SavedSearch.SortOrder          = new Object();
					objSavedSearch.SavedSearch.SortOrder.Value    = 'asc';
					objSavedSearch.SavedSearch.SearchFields       = new Object();
					objSavedSearch.SavedSearch.SearchFields.Field = arrSavedSearchFields;
					objSavedSearch.SavedSearch.SortColumn.Value   = sortField;
					objSavedSearch.SavedSearch.SortOrder.Value    = sortOrder;

					// https://www.npmjs.com/package/fast-xml-parser
					let options: any = 
					{
						attributeNamePrefix: '@',
						textNodeName       : 'Value',
						ignoreAttributes   : false,
						ignoreNameSpace    : true,
						parseAttributeValue: true,
						trimValues         : false,

					};
					let parser = new XMLParser.j2xParser(options);
					let sXML: string = '<?xml version="1.0" encoding="UTF-8"?>' + parser.parse(objSavedSearch);
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handleTableChange', sortField, SEARCH_VALUES, sXML);
					try
					{
						UpdateSavedSearch(null, MODULE_NAME, sXML, null, null);
					}
					catch(e)
					{
					}
					// 05/15/2019 Paul.  Update cache afterward in case there is an error. 
					SplendidCache.UpdateDefaultSavedSearch(MODULE_NAME, sXML, null);
				}
			}
		}
	}

	private _onPageChange = async (page, sizePerPage) =>
	{
		const { MODULE_NAME, ADMIN_MODE, cbCustomLoad, archiveView, rowRequiredSearch } = this.props;
		const { layout, SORT_FIELD, SORT_DIRECTION, SEARCH_FILTER, SEARCH_VALUES, SELECT_FIELDS, RELATED_MODULE, TABLE_NAME, PRIMARY_FIELD, PRIMARY_ID, TOP } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onPageChange', page);
		// 05/06/2021 Paul.  Track browser history changes so that we can determine if last event was a POP event. 
		SplendidCache.setGridLastPage(this.state.GRID_NAME, page);
		await this.setStateAsync({ activePage: page, loading: true });
		try
		{
			let rowSEARCH_VALUES: any = SEARCH_VALUES;
			// 01/20/2020 Paul.  Required values are always applied. 
			if ( rowRequiredSearch )
			{
				rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
				if ( rowSEARCH_VALUES == null )
				{
					rowSEARCH_VALUES = {};
				}
				for ( let sField in rowRequiredSearch )
				{
					rowSEARCH_VALUES[sField] =
					{
						FIELD_TYPE : 'Hidden',
						DATA_FORMAT: null,
						value      : rowRequiredSearch[sField]
					};
				}
			}
			// 06/10/2018 Paul.  If TABLE_NAME is specified, then use the LoadTable function. 
			// 08/30/2019 Paul.  ActivitiesPopup needs to use a custom load method. 
			if ( cbCustomLoad )
			{
				let d = await cbCustomLoad(MODULE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (page - 1), ADMIN_MODE, archiveView);
				// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
				let selectedKeys = this.createKeys(d.results);
				await this.setStateAsync(
				{
					__total     : d.__total,
					__sql       : d.__sql,
					vwMain      : d.results,
					loading     : false,
					selectedKeys,
				});
			}
			else if ( !Sql.IsEmptyString(TABLE_NAME) )
			{
				//let sSEARCH_FILTER: string = SEARCH_FILTER;
				// 06/10/2018 Paul.  If RELATED_MODULE is specified, then we need to filter by PRIMARY_FIELD. 
				if ( !Sql.IsEmptyString(RELATED_MODULE) )
				{
					//if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
					//	sSEARCH_FILTER += ' and ';
					//sSEARCH_FILTER += PRIMARY_FIELD + ' eq \'' + PRIMARY_ID + '\'';
					// 11/18/2019 Paul.  Best to send Search Filter or Search Values, but not both. 
					rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
					if ( rowSEARCH_VALUES == null )
					{
						rowSEARCH_VALUES = {};
					}
					rowSEARCH_VALUES[PRIMARY_FIELD] = { FIELD_TYPE: 'Hidden', value: PRIMARY_ID };
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handlePaginationChange: ' + SELECT_FIELDS, sSEARCH_FILTER);
				let d = await ListView_LoadTablePaginated(TABLE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (page - 1), ADMIN_MODE, archiveView);
				// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
				let selectedKeys = this.createKeys(d.results);
				await this.setStateAsync(
				{
					__total     : d.__total,
					__sql       : d.__sql,
					vwMain      : d.results,
					loading     : false,
					selectedKeys,
				});
			}
			else
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handlePaginationChange: ' + SELECT_FIELDS, SEARCH_FILTER);
				let d = await ListView_LoadModulePaginated(MODULE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (page - 1), ADMIN_MODE, archiveView);
				// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
				let selectedKeys = this.createKeys(d.results);
				await this.setStateAsync(
				{
					__total     : d.__total,
					__sql       : d.__sql,
					vwMain      : d.results,
					loading     : false,
					selectedKeys,
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '. handlePaginationChange', error);
			this.setState({ error, loading: false });
		}
	}

	private _onNextPage = ({page, onPageChange, sizePerPage, totalSize}) =>
	{
		if ( page * sizePerPage < totalSize )
		{
			onPageChange(page + 1);
		}
	}

	private _onPrevPage = ({page, onPageChange}) =>
	{
		if ( page > 1 )
		{
			onPageChange(page - 1);
		}
	}

	private _renderPageTotal = (from, to, totalSize) =>
	{
		return (<span className='react-bootstrap-table-pagination-total'>
			{ from } - { to } { L10n.Term('.LBL_LIST_OF') } { totalSize }</span>);
	}

	private _onSelectionChanged = (row, isSelect, rowIndex, e) =>
	{
		const { selectionChanged } = this.props;
		let { selectedItems, selectedKeys } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged ' + isSelect.toString(), row);
		if ( isSelect )
		{
			selectedItems[row.ID] = true;
			if ( !selectedKeys.find(x => x == row.ID_key) )
			{
				selectedKeys.push(row.ID_key);
			}
		}
		else
		{
			delete selectedItems[row.ID];
			selectedKeys = selectedKeys.filter(x => x !== row.ID_key);
		}
		// 03/15/2021 Paul.  selectedKeys only lists items on current page, not total count. 
		let checkedCount = Object.keys(selectedItems).length;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged', selectedKeys);
		this.setState({ selectedItems, selectedKeys, checkedCount }, () =>
		{
			if ( selectionChanged )
			{
				selectionChanged(selectedItems);
			}
		});
		return true;
	}

	private _onBootstrapSelectPage = (isSelect, rows, e) =>
	{
		const { selectionChanged } = this.props;
		const { vwMain } = this.state;
		let { selectedItems, selectedKeys } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onBootstrapSelectPage ' + isSelect.toString(), rows);
		if ( vwMain != null )
		{
			for ( let i = 0; i < rows.length; i++ )
			{
				let row = rows[i];
				if ( isSelect )
				{
					selectedItems[row.ID] = true;
					if ( !selectedKeys.find(x => x == row.ID_key) )
					{
						selectedKeys.push(row.ID_key);
					}
				}
				else
				{
					delete selectedItems[row.ID];
					selectedKeys = selectedKeys.filter(x => x !== row.ID_key);
				}
			}
		}
		// 03/15/2021 Paul.  selectedKeys only lists items on current page, not total count. 
		let checkedCount = Object.keys(selectedItems).length;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onBootstrapSelectPage', selectedKeys);
		this.setState({ selectedItems, selectedKeys, checkedCount }, () =>
		{
			if ( selectionChanged )
			{
				selectionChanged(selectedItems);
			}
		});
	}

	private _onSelectPage = (e) =>
	{
		const { selectionChanged } = this.props;
		const { vwMain } = this.state;
		let { nSelectionKey } = this.state;
		let { selectedItems, selectedKeys } = this.state;
		// 04/07/2022 Paul.  e may be null. 
		if ( e != null )
		{
			e.preventDefault();
		}
		if ( vwMain != null )
		{
			for ( let i = 0; i < vwMain.length; i++ )
			{
				let row = vwMain[i];
				selectedItems[row.ID] = true;
				if ( !selectedKeys.find(x => x == row.ID_key) )
				{
					selectedKeys.push(row.ID_key);
				}
			}
		}
		// 03/15/2021 Paul.  selectedKeys only lists items on current page, not total count. 
		let checkedCount = Object.keys(selectedItems).length;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectPage', selectedKeys);
		// 04/07/2022 Paul.  Use selection key to force checkbox to update. 
		nSelectionKey++;
		this.setState({ selectedItems, selectedKeys, checkedCount, nSelectionKey }, () =>
		{
			if ( selectionChanged )
			{
				selectionChanged(selectedItems);
			}
		});
	}

	private _onSelectAll = async (e) =>
	{
		const { MODULE_NAME, ADMIN_MODE, cbCustomLoad, archiveView, rowRequiredSearch, selectionChanged } = this.props;
		const { layout, SORT_FIELD, SORT_DIRECTION, SEARCH_FILTER, SEARCH_VALUES, RELATED_MODULE, TABLE_NAME, PRIMARY_FIELD, PRIMARY_ID, TOP, __total } = this.state;
		let { nSelectionKey } = this.state;
		e.preventDefault();
		try
		{
			let selectedItems = {};
			let selectedKeys = [];
			let nPageTotal = __total / TOP;
			let SELECT_FIELDS = 'ID';
			// 07/15/2019 Paul.  To select all, we need to to fetch all pages so that we can re-format the row keys. 
			await this.setStateAsync({ loading: true });
			// 11/27/2020 Paul.  +1 to get the last page. 
			for ( let page = 1; page <= (nPageTotal+1) && this._isMounted; page++ )
			{
				let rowSEARCH_VALUES: any = SEARCH_VALUES;
				// 01/20/2020 Paul.  Required values are always applied. 
				if ( rowRequiredSearch )
				{
					rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
					if ( rowSEARCH_VALUES == null )
					{
						rowSEARCH_VALUES = {};
					}
					for ( let sField in rowRequiredSearch )
					{
						rowSEARCH_VALUES[sField] =
						{
							FIELD_TYPE : 'Hidden',
							DATA_FORMAT: null,
							value      : rowRequiredSearch[sField]
						};
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectAll page ' + page);
				let results = null;
				// 06/10/2018 Paul.  If TABLE_NAME is specified, then use the LoadTable function. 
				// 08/30/2019 Paul.  ActivitiesPopup needs to use a custom load method. 
				if ( cbCustomLoad )
				{
					let d = await cbCustomLoad(MODULE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (page - 1), ADMIN_MODE, archiveView);
					// 11/27/2020 Paul.  Must set local results for selected items to get counted. 
					results = d.results;
					// 11/27/2020 Paul.  SelectAll should not change the current page. 
					//await this.setStateAsync({ __total: d.__total, __sql: d.__sql, vwMain: d.results });
				}
				else if ( !Sql.IsEmptyString(TABLE_NAME) )
				{
					//let sSEARCH_FILTER: string = SEARCH_FILTER;
					// 06/10/2018 Paul.  If RELATED_MODULE is specified, then we need to filter by PRIMARY_FIELD. 
					if ( !Sql.IsEmptyString(RELATED_MODULE) )
					{
						//if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
						//	sSEARCH_FILTER += ' and ';
						//sSEARCH_FILTER += PRIMARY_FIELD + ' eq \'' + PRIMARY_ID + '\'';
						rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
						if ( rowSEARCH_VALUES == null )
						{
							rowSEARCH_VALUES = {};
						}
						rowSEARCH_VALUES[PRIMARY_FIELD] = { FIELD_TYPE: 'Hidden', value: PRIMARY_ID };
					}
					let d = await ListView_LoadTablePaginated(TABLE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (page - 1), ADMIN_MODE, archiveView);
					results = d.results;
				}
				else
				{
					let d = await ListView_LoadModulePaginated(MODULE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (page - 1), ADMIN_MODE, archiveView);
					results = d.results;
				}
				if ( results != null )
				{
					for ( let i = 0; i < results.length && this._isMounted; i++ )
					{
						let row = results[i];
						row.ID_key = this.formatKey(row.ID, i);
						selectedItems[row.ID] = true;
						selectedKeys.push(row.ID_key);
					}
				}
			}
			if ( this._isMounted )
			{
				// 11/27/2020 Paul.  Update selected count. 
				// 03/15/2021 Paul.  selectedKeys only lists items on current page, not total count. 
				let checkedCount = Object.keys(selectedItems).length;
				// 12/01/2020 Paul.  Must alert container that the selection has changed. 
				// 04/07/2022 Paul.  Use selection key to force checkbox to update. 
				nSelectionKey++;
				this.setState({ selectedItems, selectedKeys, checkedCount, nSelectionKey, loading: false }, () =>
				{
					if ( selectionChanged )
					{
						selectionChanged(selectedItems);
					}
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectAll', error);
			this.setState({ error, loading: false });
		}
	}

	// 07/18/2019 Paul.  This method can be called externally. 
	public onDeselectAll = (e) =>
	{
		const { selectionChanged } = this.props;
		let { nSelectionKey } = this.state;
		if ( e != null )
		{
			e.preventDefault();
		}
		// 04/07/2022 Paul.  Use selection key to force checkbox to update. 
		nSelectionKey++;
		this.setState({ selectedItems: {}, selectedKeys: [], checkedCount: 0, nSelectionKey }, () =>
		{
			if ( selectionChanged )
			{
				selectionChanged({});
			}
		});
	}

	private rowClasses = (row, rowIndex) =>
	{
		return (rowIndex % 2 ? 'evenListRowS1' : 'oddListRowS1');
	}

	public ExportModule = async (EXPORT_RANGE: string, EXPORT_FORMAT: string) =>
	{
		const { MODULE_NAME, ADMIN_MODE, archiveView } = this.props;
		const { SORT_FIELD, SORT_DIRECTION, TOP, SELECT_FIELDS, SEARCH_VALUES, activePage, selectedItems } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.ExportModule', EXPORT_RANGE, EXPORT_FORMAT);
		try
		{
			let sFILTER       : string   = null;
			let SELECTED_ITEMS: string[] = [];
			for ( let id in selectedItems )
			{
				SELECTED_ITEMS.push(id);
			}
			// 11/02/2020 Paul.  Provide spinner to export. 
			this.setState({ exporting: true });
			let d = await ListView_ExportModule(MODULE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, sFILTER, SEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView, EXPORT_RANGE, EXPORT_FORMAT, SELECTED_ITEMS);
			//await this.setStateAsync({ __total: d.__total, __sql: d.__sql });
			//window.open(Credentials.RemoteServer + 'Import/ExportFile.aspx?FileID=' + d.ExportFileName);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onExport', d);
			// 11/10/2020 Paul.  Clear export error after success. 
			this.setState({ error: '', exporting: false });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ExportModule', error);
			this.setState({ error, exporting: false });
		}
	}

	// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
	// https://www.gitmemory.com/issue/react-bootstrap-table/react-bootstrap-table2/793/465645955
	private selectionRenderer = ( sel ) =>
	{
		const { mode, checked, disabled, rowIndex, rowKey } = sel;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.selectionRenderer', sel);
		let className = 'selection-input-4';
		let styCheckbox: any = {};
		if ( this.legacyIcons )
		{
			styCheckbox.transform = 'scale(1.0)';
		}
		return React.createElement('input', { type: mode, checked, disabled, className, style: styCheckbox, onChange: function onChange() {} });
	}
	
	private selectionHeaderRenderer = ( sel ) =>
	{
		const { mode, checked, indeterminate } = sel;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.selectionHeaderRenderer', sel);
		let sTheme: string = SplendidCache.UserTheme;
		if ( sTheme == 'Pacific' )
		{
			return null;
		}
		else
		{
			let className = 'selection-input-4';
			let styCheckbox: any = {};
			if ( this.legacyIcons )
			{
				styCheckbox.transform = 'scale(1.0)';
			}
			return React.createElement('input', { type: mode, checked, className, style: styCheckbox, ref: function ref(input: any)
			{
				if ( input )
					input.indeterminate = indeterminate;
			}});
		}
	}

	// 03/25/2022 Paul.  Add field chooser. 
	private _onChooseColumns = () =>
	{
		this.setState({ isOpenFieldChooser: true });
	}

	private _onFieldChooserCallback = (action: string, layoutDisplay: any, layoutHidden: any) =>
	{
		const { MODULE_NAME } = this.props;
		const { GRID_NAME, SORT_FIELD, SORT_DIRECTION } = this.state;
		if ( action == 'Cancel' )
		{
			this.setState({ isOpenFieldChooser: false });
		}
		else if ( action == 'Save' )
		{
			let layout          = layoutDisplay;
			let layoutAvailable = layoutHidden ;
			let SELECT_FIELDS   = this.GridColumns(layout);
			let columns: any[]  = null;
			if ( this.props.cbCustomColumns )
			{
				columns = this.props.cbCustomColumns(GRID_NAME, layout, MODULE_NAME, null);
			}
			else
			{
				columns = this.BootstrapColumns(GRID_NAME, layout, MODULE_NAME, null);
			}
			this.setState(
			{
				layout            ,
				layoutAvailable   ,
				__total           : 0,
				vwMain            : null,
				SELECT_FIELDS     ,
				columns           ,
				isOpenFieldChooser: false,
				columnsChangedKey : (this.state.columnsChangedKey + 1)
			}, () =>
			{
				if ( this.props.onLayoutLoaded )
				{
					this.props.onLayoutLoaded();
				}
				if ( !this.props.deferLoad )
				{
					this.Sort(SORT_FIELD, SORT_DIRECTION);
				}
			});
		}
	}

	private isPageSelected = () =>
	{
		const { vwMain, selectedItems } = this.state;
		let pageSelectionCount: number = 0;
		if ( vwMain != null )
		{
			for ( let i = 0; i < vwMain.length; i++ )
			{
				let row = vwMain[i];
				if ( selectedItems[row.ID] )
				{
					pageSelectionCount++;
				}
			}
		}
		let isPageSelected: boolean = pageSelectionCount > 0 && pageSelectionCount == vwMain.length;
		return isPageSelected;
	}

	private _onPacificSelection = (e) =>
	{
		const { enableSelection } = this.props;
		const { vwMain, selectedItems } = this.state;
		if ( enableSelection )
		{
			let isPageSelected: boolean = this.isPageSelected();
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onPacificSelection', isPageSelected);
			if ( isPageSelected )
				this.onDeselectAll(null);
			else
				this._onSelectPage(null);
		}
	}

	private refPacificSelection = (element) =>
	{
		const { enableSelection } = this.props;
		const { vwMain, selectedItems } = this.state;
		this.chkPacificSelection = element;
		if ( this.chkPacificSelection != null && enableSelection )
		{
			// 04/07/2022 Paul.  The chkPacificSelection indicates if all items on current page are selected. 
			let pageCount: number = 0;
			if ( vwMain != null )
			{
				for ( let i = 0; i < vwMain.length; i++ )
				{
					let row = vwMain[i];
					if ( selectedItems[row.ID] )
					{
						pageCount++;
					}
				}
			}

			let checked      : boolean = pageCount > 0 && pageCount == vwMain.length;
			let indeterminate: boolean = pageCount > 0 && pageCount <  vwMain.length;
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.refPacificSelection ' + checked.toString(), indeterminate);
			//this.chkPacificSelection.checked       = checked;
			this.chkPacificSelection.indeterminate = indeterminate;
		}
	}

	// 04/10/2022 Paul.  Move Pacific Export to pagination header. 
	private _onEXPORT_RANGE_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let EXPORT_RANGE: string = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onEXPORT_RANGE_Change', EXPORT_RANGE);
		this.setState({ EXPORT_RANGE });
	}

	private _onEXPORT_FORMAT_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let EXPORT_FORMAT: string = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onEXPORT_FORMAT_Change', EXPORT_FORMAT);
		this.setState({ EXPORT_FORMAT });
	}

	private _onExport = async (e) =>
	{
		const { EXPORT_RANGE, EXPORT_FORMAT } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onExport', EXPORT_RANGE, EXPORT_FORMAT);
		this.ExportModule(EXPORT_RANGE, EXPORT_FORMAT);
	}

	// 04/23/2022 Paul.  Add no data indicator. 
	private emptyDataMessage = () =>
	{
		return (
			<div style={ {fontSize: '1.5em'} }>{ L10n.Term('.LBL_NO_DATA') }</div>
		);
	}

	public render()
	{
		const { readonly, enableSelection, disablePagination, MODULE_NAME, enableMassUpdate, Page_Command, archiveView, enableExportHeader } = this.props;
		const { loaded, vwMain, activePage, layout, layoutAvailable, columns, selectedItems, selectedKeys, allChecked, SORT_FIELD, SORT_DIRECTION, PRIMARY_ID, TOP, checkedCount, error, tableKey, loading, exporting } = this.state;
		const { __total, __sql, isOpenFieldChooser, GRID_NAME, columnsChangedKey, nSelectionKey } = this.state;
		// 04/10/2022 Paul.  Move Pacific Export to pagination header. 
		const { EXPORT_RANGE, EXPORT_FORMAT, EXPORT_RANGE_LIST, EXPORT_FORMAT_LIST } = this.state;
		// 05/22/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( SplendidCache.IsInitialized && vwMain )
		{
			let sTheme: string = SplendidCache.UserTheme;
			let defaultSorted = [];
			if ( SORT_DIRECTION && SORT_FIELD )
			{
				defaultSorted.push({ dataField: SORT_FIELD, order: SORT_DIRECTION });
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render defaultSorted', defaultSorted);
			// https://react-bootstrap-table.github.io/react-bootstrap-table2/docs/row-select-props.html#selectrowmode-string
			// Selection Management
			// https://react-bootstrap-table.github.io/react-bootstrap-table2/storybook/index.html?selectedKind=Row%20Selection&selectedStory=Selection%20Management&full=0&addons=1&stories=1&panelRight=0&addonPanel=storybook%2Factions%2Factions-panel
			// https://react-bootstrap-table.github.io/react-bootstrap-table2/docs/basic-row-select.html
			// 10/14/2020 Paul.  Checkbox with is taking too much space. Try to set the style. 
			// https://react-bootstrap-table.github.io/react-bootstrap-table2/docs/row-select-props.html#selectrowselectcolumnstyle-object-function
			let selectRow: any =
			{
				mode                   : 'checkbox',
				selected               : selectedKeys,
				onSelect               : this._onSelectionChanged,
				onSelectAll            : this._onBootstrapSelectPage,
				hideSelectColumn       : !enableSelection,
				selectColumnStyle      : { width: '1%' },
				selectionRenderer      : this.selectionRenderer,
				selectionHeaderRenderer: this.selectionHeaderRenderer,
			};
			// 07/08/2019 Paul.  set custom to false to show the paginator at the top and the bottom of the table. 
			let pagination = paginationFactory(
			{
				custom                 : true,
				page                   : activePage,
				pageStartIndex         : 1,
				sizePerPage            : TOP,
				paginationSize         : TOP,
				totalSize              : __total,
				showTotal              : true,
				hideSizePerPage        : true,
				withFirstAndLast       : false,
				alwaysShowAllBtns      : true,
				prePageText            : L10n.Term('.LNK_LIST_PREVIOUS'),
				prePageTitle           : L10n.Term('.LNK_LIST_PREVIOUS'),
				nextPageText           : L10n.Term('.LNK_LIST_NEXT'    ),
				nextPageTitle          : L10n.Term('.LNK_LIST_NEXT'    ),
				firstPageText          : L10n.Term('.LNK_LIST_FIRST'   ),
				firstPageTitle         : L10n.Term('.LNK_LIST_FIRST'   ),
				lastPageText           : L10n.Term('.LNK_LIST_LAST'    ),
				lastPageTitle          : L10n.Term('.LNK_LIST_LAST'    ),
				paginationTotalRenderer: this._renderPageTotal,
				onPageChange           : this._onPageChange,
			});
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + this.state.GRID_NAME + ' Active Page = ' + activePage);
			let lblSelectedLabel = '';
			if ( enableSelection )
			{
				lblSelectedLabel = L10n.Term('.LBL_SELECTED').replace('{0}', checkedCount);
			}
			let titleSelection: any = null;
			if ( sTheme == 'Pacific' )
			{
				let isPageSelected: boolean = this.isPageSelected();
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render titleSelection checked =', isPageSelected);
				// 04/07/2022 Paul.  Use selection key to force checkbox to update. 
				titleSelection = <div className='GridSelectionCount'>
									<input type='checkbox'
										key={ 'chkPacificSelection_' + nSelectionKey.toString() }
										checked={ isPageSelected }
										className='selection-input-4' 
										style={ {transform: 'scale(1.5)', verticalAlign: 'text-top', marginLeft: '5px', marginRight: '10px'} }
										onClick={ this._onPacificSelection }
										ref={ (element) => this.refPacificSelection(element) }
									/>
									<span style={ {marginRight: '10px'} }>{ checkedCount > 0 ? lblSelectedLabel : null }</span>
									<FontAwesomeIcon icon='caret-down' size='lg' />
								</div>;
			}
			// LBL_LISTVIEW_NO_SELECTED
			// LBL_SELECT_PAGE
			// LBL_SELECT_ALL
			// LBL_DESELECT_ALL
			// 07/08/2019 Paul.  PaginationListStandalone
			// https://react-bootstrap-table.github.io/react-bootstrap-table2/storybook/index.html?selectedKind=Pagination&selectedStory=Standalone%20Pagination%20List&full=0&addons=1&stories=1&panelRight=0&addonPanel=storybook%2Factions%2Factions-panel
			return (<React.Fragment key={ 'columnsChangedKey_' + columnsChangedKey.toString() }>
				{ loading || exporting
				? <div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
					<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
				</div>
				: null
				}
				<PaginationProvider pagination={ pagination }>
				{
					({
						paginationProps,
						paginationTableProps
					}) => (
						<div>
							<DumpSQL SQL={ __sql } />
							{ error != null
							? <ErrorComponent error={error} />
							: null
							}
							{ layoutAvailable
							? <ListViewFieldChooser
								ViewName={ GRID_NAME }
								LayoutType='ListView'
								isOpen={ isOpenFieldChooser }
								callback={ this._onFieldChooserCallback }
								layoutDisplay={ layout }
								layoutHidden={ layoutAvailable }
							/>
							: null
							}
							{ !disablePagination
							? <table className='listView' cellSpacing={ 1 } cellPadding={ 3 } style={ {width: '100%'} }>
								<tr className='listViewPaginationTdS1'>
									<td>
										{ sTheme == 'Pacific' && (enableSelection || (enableMassUpdate && Page_Command))
										? <div style={ {display: 'flex', flexDirection: 'row', flexWrap: 'nowrap', justifyContent: 'left'} }>
											{ enableSelection
											? <NavItem title={ titleSelection }>
												<input type='submit' onClick={ this._onSelectPage } className='ListHeaderOtherButton' style={ {marginRight: '2px', marginBottom: '0px'} } value={ L10n.Term('.LBL_SELECT_PAGE' ) } />
												<input type='submit' onClick={ this._onSelectAll  } className='ListHeaderOtherButton' style={ {marginRight: '2px', marginBottom: '0px'} } value={ L10n.Term('.LBL_SELECT_ALL'  ) } />
												<input type='submit' onClick={ this.onDeselectAll } className='ListHeaderOtherButton' style={ {marginRight: '2px', marginBottom: '0px'} } value={ L10n.Term('.LBL_DESELECT_ALL') } />
											</NavItem>
											: null
											}
											{ enableMassUpdate && Page_Command
											? <DynamicButtons
												ButtonStyle='DataGrid'
												VIEW_NAME={ MODULE_NAME + '.MassUpdate' + (archiveView ? '.ArchiveView' : '') }
												row={ null }
												Page_Command={ Page_Command }
												onLayoutLoaded={ this._onButtonsLoaded }
												history={ this.props.history }
												location={ this.props.location }
												match={ this.props.match }
												ref={ this.dynamicButtons }
											/>
											: null
											}
										</div>
										: null
										}
									</td>
									<td style={ {textAlign: 'right'} } className='react-bootstrap-table-pagination-total pageNumbers'>
										{ enableExportHeader && sTheme == 'Pacific'
										? <React.Fragment>
											<select
												id='lstEXPORT_RANGE'
												onChange={ this._onEXPORT_RANGE_Change }
												value={ EXPORT_RANGE }
												style={ {width: 'auto', margin: 2} }
												>
												{
													EXPORT_RANGE_LIST.map((item, index) => 
													{
														return (<option key={ '_ctlEditView_EXPORT_RANGE_' + index.toString() } id={ '_ctlEditView_EXPORT_RANGE' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
													})
												}
											</select>
											<select
												id='lstEXPORT_FORMAT'
												onChange={ this._onEXPORT_FORMAT_Change }
												value={ EXPORT_FORMAT }
												style={ {width: 'auto', margin: 2} }
												>
												{
													EXPORT_FORMAT_LIST.map((item, index) => 
													{
														return (<option key={ '_ctlEditView_EXPORT_FORMAT_' + index.toString() } id={ '_ctlEditViewEXPORT_FORMAT' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
													})
												}
											</select>
											<button className='button' onClick={ this._onExport } style={ {marginRight: '8px'} }>
												<FontAwesomeIcon icon={ { prefix: 'fas', iconName: 'file-export' } } size="lg" style={ {paddingRight: '4px'} } />
												{ L10n.Term('.LBL_EXPORT_BUTTON_LABEL') }
											</button>
										</React.Fragment>
										: null
										}
										{ layoutAvailable
										? <button className='button' style={ {marginRight: '8px'} } onClick={ this._onChooseColumns }>
											<FontAwesomeIcon icon={ { prefix: 'fas', iconName: 'list' } } size="lg" />
											&nbsp;{ L10n.Term('.LBL_AVAILABLE_COLUMNS') }
										</button>
										: null
										}
										<span className='paginationButtonPrevious' style={ {cursor: 'pointer'} } onClick={ () => this._onPrevPage(paginationProps) }>
											<img className='paginationButtonPrevious' src={ this.themeURL + (paginationProps.page > 1 ? 'previous.gif' : 'previous_off.gif') } />
											<span style={ {margin: '3px'} }>{ paginationProps.prePageText }</span>
										</span>
										<span style={ {margin: '3px'} }>
											({ paginationProps.paginationTotalRenderer(paginationProps.pageStartIndex + (paginationProps.page - 1) * paginationProps.sizePerPage, Math.min(paginationProps.page * paginationProps.sizePerPage, paginationProps.totalSize), paginationProps.totalSize) })
										</span>
										<span className='paginationButtonNext' style={ {cursor: 'pointer'} } onClick={ () => this._onNextPage(paginationProps) }>
											<span style={ {margin: '3px'} }>{ paginationProps.nextPageText }</span>
											<img className='paginationButtonNext' src={ this.themeURL + (paginationProps.page * paginationProps.sizePerPage < paginationProps.totalSize ? 'next.gif' : 'next_off.gif') } />
										</span>
									</td>
								</tr>
							</table>
							: null
							}
							{ false ? <PaginationTotalStandalone { ...paginationProps } /> : null }
							{ false ? <PaginationListStandalone  { ...paginationProps } /> : null }
							<BootstrapTable
								key={ tableKey }
								keyField='ID_key'
								data={ vwMain }
								classes='listView'
								bordered={ false }
								headerClasses='listViewThS1'
								remote
								columns={ columns }
								selectRow={ selectRow }
								defaultSorted={ defaultSorted }
								onTableChange={ this.handleTableChange }
								bootstrap4 compact hover
								wrapperClasses={ 'bg-white' }
								rowClasses={ this.rowClasses }
								noDataIndication={ this.emptyDataMessage }
								{ ...paginationTableProps }
							/>
							{ enableSelection && sTheme != 'Pacific'
							? <div>
								<a href='#' onClick={ this._onSelectPage } className="listViewCheckLink">{ L10n.Term('.LBL_SELECT_PAGE' ) }</a>
								&nbsp;-&nbsp;
								<a href='#' onClick={ this._onSelectAll  } className="listViewCheckLink">{ L10n.Term('.LBL_SELECT_ALL'  ) }</a>
								&nbsp;-&nbsp;
								<a href='#' onClick={ this.onDeselectAll } className="listViewCheckLink">{ L10n.Term('.LBL_DESELECT_ALL') }</a>
								&nbsp;&nbsp;
								{ lblSelectedLabel }
							</div>
							: null
							}
						</div>
					)
				}
				</PaginationProvider>
			</React.Fragment>);
		}
		else if ( error != null )
		{
			return (<ErrorComponent error={error} />);
		}
		else if ( loading )
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
			</div>);
		}
		return null;
	}

}

// 07/13/2019 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 
export default SplendidGrid;
