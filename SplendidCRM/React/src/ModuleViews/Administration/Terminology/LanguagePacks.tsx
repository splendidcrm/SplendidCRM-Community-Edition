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
import posed                                        from 'react-pose'                             ;
import { RouteComponentProps, withRouter }          from 'react-router-dom'                       ;
import { observer }                                 from 'mobx-react'                             ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'         ;
import { Appear }                                   from 'react-lifecycle-appear'                 ;
// 2. Store and Types. 
import ACL_FIELD_ACCESS                             from '../../../types/ACL_FIELD_ACCESS'        ;
import DETAILVIEWS_RELATIONSHIP                     from '../../../types/DETAILVIEWS_RELATIONSHIP';
import RELATIONSHIPS                                from '../../../types/RELATIONSHIPS'           ;
import { SubPanelHeaderButtons }                    from '../../../types/SubPanelHeaderButtons'   ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                   ;
import L10n                                         from '../../../scripts/L10n'                  ;
import Security                                     from '../../../scripts/Security'              ;
import Credentials                                  from '../../../scripts/Credentials'           ;
import SplendidCache                                from '../../../scripts/SplendidCache'         ;
import SplendidDynamic                              from '../../../scripts/SplendidDynamic'       ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'                 ;
import { Crm_Config, Crm_Modules }                  from '../../../scripts/Crm'                   ;
import { Trim, EndsWith }                           from '../../../scripts/utility'               ;
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'       ;
// 4. Components and Views. 
import ErrorComponent                               from '../../../components/ErrorComponent'     ;
import SplendidGrid                                 from '../../../components/SplendidGrid'       ;
import DynamicButtons                               from '../../../components/DynamicButtons'     ;
import SearchView                                   from '../../../views/SearchView'              ;
import SubPanelButtonsFactory                       from '../../../ThemeComponents/SubPanelButtonsFactory';

const MODULE_NAME: string = 'Terminology';

const Content = posed.div(
{
	open:
	{
		height: '100%'
	},
	closed:
	{
		height: 0
	}
});

interface ISubPanelViewProps extends RouteComponentProps<any>
{
	PARENT_TYPE      : string;
	row              : any;
	layout           : DETAILVIEWS_RELATIONSHIP;
	CONTROL_VIEW_NAME: string;
	disableView?     : boolean;
	disableEdit?     : boolean;
	disableRemove?   : boolean;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data) => void;
}

interface ISubPanelViewState
{
	PARENT_ID        : string;
	RELATED_MODULE?  : string;
	GRID_NAME?       : string;
	TABLE_NAME?      : string;
	SORT_FIELD?      : string;
	SORT_DIRECTION?  : string;
	PRIMARY_FIELD?   : string;
	PRIMARY_ID?      : string;
	JOIN_TABLE       : string;
	PARENT_ID_FIELD  : string;
	showCancel       : boolean;
	showFullForm     : boolean;
	showTopButtons   : boolean;
	showBottomButtons: boolean;
	showSearch       : boolean;
	showInlineEdit   : boolean;
	multiSelect      : boolean;
	popupOpen        : boolean;
	archiveView      : boolean;
	item?            : any;
	dependents?      : Record<string, Array<any>>;
	error?           : any;
	open             : boolean;
	customView       : any;
	subPanelVisible  : boolean;
}

@observer
class LanguagePacks extends React.Component<ISubPanelViewProps, ISubPanelViewState>
{
	private _isMounted = false;

	private searchView           = React.createRef<SearchView>();
	private splendidGrid         = React.createRef<SplendidGrid>();
	private dynamicButtonsTop    = React.createRef<DynamicButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private headerButtons        = React.createRef<SubPanelHeaderButtons>();
	private themeURL: string = null;
	private legacyIcons: boolean = false;

	constructor(props: ISubPanelViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + props.PARENT_TYPE, props.layout);
		let archiveView: boolean = false;
		let GRID_NAME  : string = MODULE_NAME + '.' + props.layout.CONTROL_NAME;
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		
		// 11/05/2020 Paul.  A customer wants to be able to have subpanels default to open. 
		let rawOpen    : string  = localStorage.getItem(props.CONTROL_VIEW_NAME);
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		let open       : boolean = (rawOpen == 'true' || this.props.isPrecompile);
		if ( rawOpen == null )
		{
			open = true;
		}
		this.state =
		{
			PARENT_ID        : props.row.ID,
			RELATED_MODULE   : MODULE_NAME,
			GRID_NAME        ,
			TABLE_NAME       : props.layout.TABLE_NAME,
			SORT_FIELD       : 'Name',
			SORT_DIRECTION   : 'asc',
			PRIMARY_FIELD    : props.layout.PRIMARY_FIELD,
			PRIMARY_ID       : props.row.ID,
			JOIN_TABLE       : null,
			PARENT_ID_FIELD  : null,
			showCancel       : true,
			showFullForm     : true,
			showTopButtons   : true,
			showBottomButtons: true,
			showSearch       : false,
			showInlineEdit   : false,
			multiSelect      : false,
			popupOpen        : false,
			archiveView      ,
			item             : {},
			dependents       : {},
			error            : null,
			open             ,
			customView       : null,
			subPanelVisible  : Sql.ToBoolean(props.isPrecompile),  // 08/31/2021 Paul.  Must show sub panel during precompile to allow it to continue. 
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
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
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
		const { CONTROL_VIEW_NAME } = this.props;
		const { error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + LAYOUT_NAME, data);
		if ( this.props.onComponentComplete )
		{
			if ( error == null )
			{
				this.props.onComponentComplete(MODULE_NAME, RELATED_MODULE, CONTROL_VIEW_NAME, data);
			}
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
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { showSearch, showInlineEdit } = this.state;
		const { PARENT_ID, RELATED_MODULE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		try
		{
			if ( this._isMounted )
			{
				// 04/20/2020 Paul.  SearchOpen and SearchHistory are on the Activities panels. 
				if ( sCommandName == 'Search' || EndsWith(sCommandName, '.Search') || EndsWith(sCommandName, '.SearchOpen') || EndsWith(sCommandName, '.SearchHistory') )
				{
					this.setState({ showSearch: !showSearch, showInlineEdit: false, error: '' });
				}
				else
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command: Unknown command ' + sCommandName);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private editViewCallback = (key, newValue) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.editViewCallback ' + DATA_FIELD, DATA_VALUE);
		let item = this.state.item;
		if ( item == null )
			item = {};
		item[key] = newValue;
		if ( this._isMounted )
		{
			this.setState({ item });
		}
	}

	private onToggleCollapse = (open) =>
	{
		const { CONTROL_VIEW_NAME } = this.props;
		this.setState({ open }, () =>
		{
			if ( open )
			{
				localStorage.setItem(CONTROL_VIEW_NAME, 'true');
			}
			else
			{
				// 11/10/2020 Paul.  Save false instead of remove so that config value default_subpanel_open will work properly. 
				//localStorage.removeItem(CONTROL_VIEW_NAME);
				localStorage.setItem(CONTROL_VIEW_NAME, 'false');
			}
		});
	}

	private _onButtonsLoaded = async () =>
	{
		if ( this.dynamicButtonsTop.current != null )
		{
		}
		if ( this.dynamicButtonsBottom.current != null )
		{
		}
	}

	private BootstrapColumns = (sLIST_MODULE_NAME, layout, sPRIMARY_MODULE, sPRIMARY_ID) =>
	{
		const { disableView, disableEdit, disableRemove } = this.props;
		const readonly   : boolean = false;
		const isPopupView: boolean = false;
		const RELATED_MODULE: string = 'Terminology';
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
		let bEnableDynamicAssignment = Crm_Config.enable_dynamic_assignment();
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
					if ( bEnableTeamManagement )
					{
						// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
						// 04/03/2021 Paul.  Apply single rule. 
						if ( bEnableDynamicTeams && DATA_FORMAT != '1' && Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('single') < 0 )
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
			formatter      : this.downloadColumnFormatter,
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

	private downloadColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		return (
			<span style={ { whiteSpace: 'nowrap'} }>
			{ !Sql.IsEmptyString(row['URL'])
			? 
				<a href={ row['URL'] } download={ row['URL'] } className='listViewTdToolsS1' target='SplendidLanguagePackDownload'>
					<FontAwesomeIcon icon='save' size='lg' />
				</a>
			: null
			}
			</span>
		);
	}

	private _onHyperLinkCallback = async (MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback: ' + MODULE_NAME, NAME, URL, row);
		try
		{
			let obj: any = {};
			obj['Truncate'      ] = this.props.row.bTruncate     ;
			obj['ForceUTF8'     ] = this.props.row.bForceUTF8    ;
			obj['URL'           ] = row.URL;
			let sBody: string = JSON.stringify(obj);
			let res = await CreateSplendidRequest('Administration/Terminology/Rest.svc/ImportLanguagePackURL', 'POST', 'application/json; charset=utf-8', sBody);
			let json = await GetSplendidResult(res);
			if ( this._isMounted )
			{
				this.setState( {error: 'Import Complete' });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback', error);
			this.setState({ error });
		}
	}

	private Load = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load', rowSEARCH_VALUES);
		if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
		{
			sSORT_FIELD     = '';
			sSORT_DIRECTION = '';
		}
		let obj = new Object();
		obj['$top'         ] = nTOP            ;
		obj['$skip'        ] = nSKIP           ;
		obj['$orderby'     ] = sSORT_FIELD + ' ' + sSORT_DIRECTION;
		obj['$select'      ] = sSELECT         ;
		obj['$filter'      ] = sFILTER         ;
		obj['$searchvalues'] = rowSEARCH_VALUES;
		let sBody: string = JSON.stringify(obj);
		let res = await CreateSplendidRequest('Administration/Terminology/Rest.svc/GetSugarLanguagePacks', 'POST', 'application/octet-stream', sBody);
	
		let json = await GetSplendidResult(res);
		json.d.__total = json.__total;
		json.d.__sql = json.__sql;
		return (json.d);
	}

	public render()
	{
		const { PARENT_TYPE, row, layout, CONTROL_VIEW_NAME, disableView, disableEdit, disableRemove } = this.props;
		const { RELATED_MODULE, GRID_NAME, TABLE_NAME, SORT_FIELD, SORT_DIRECTION, PRIMARY_FIELD, PRIMARY_ID, error, showCancel, showFullForm, showTopButtons, showBottomButtons, showSearch, showInlineEdit, item, popupOpen, multiSelect, archiveView, open, customView, subPanelVisible } = this.state;
		let cssSearch = { display: (showSearch ? 'inline' : 'none') };
		if ( SplendidCache.IsInitialized  )
		{
			Credentials.sUSER_THEME;
			let headerButtons = SubPanelButtonsFactory(SplendidCache.UserTheme);
			let MODULE_NAME      : string = RELATED_MODULE;
			let MODULE_TITLE     : string = L10n.Term(layout.TITLE);
			let EDIT_NAME        : string = MODULE_NAME + '.SearchSubpanel';
			return (
				<React.Fragment>
					<Appear onAppearOnce={ (ioe) => this.setState({ subPanelVisible: true }) }>
						{ headerButtons
						? React.createElement(headerButtons, { MODULE_NAME, ID: null, MODULE_TITLE, CONTROL_VIEW_NAME, error, ButtonStyle: 'ListHeader', VIEW_NAME: GRID_NAME, row: item, Page_Command: this.Page_Command, showButtons: !showInlineEdit, onToggle: this.onToggleCollapse, isPrecompile: this.props.isPrecompile, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
						: null
						}
					</Appear>
					<Content pose={ open ? 'open' : 'closed' } style={ {overflow: (open ? 'visible' : 'hidden')} }>
						{ open && subPanelVisible
						? <React.Fragment>
							<div style={ cssSearch }>
								<div className="card" style={{marginBottom: '0.5rem'}}>
									<div className="card-body">
										<SearchView
											key={ EDIT_NAME }
											EDIT_NAME={ EDIT_NAME }
											AutoSaveSearch={ false }
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
							<SplendidGrid
								onLayoutLoaded={ this._onGridLayoutLoaded }
								MODULE_NAME={ PARENT_TYPE }
								RELATED_MODULE={ RELATED_MODULE }
								GRID_NAME={ GRID_NAME }
								TABLE_NAME={ TABLE_NAME }
								SORT_FIELD={ SORT_FIELD }
								SORT_DIRECTION={ SORT_DIRECTION }
								PRIMARY_FIELD={ PRIMARY_FIELD }
								PRIMARY_ID={ PRIMARY_ID }
								ADMIN_MODE={ false }
								deleteRelated={ false }
								archiveView={ false }
								deferLoad={ true }
								disableView={ true }
								disableEdit={ true }
								disableRemove={ true }
								enableSelection={ false }
								AutoSaveSearch={ false }
								cbCustomLoad={ this.Load }
								cbCustomColumns={ this.BootstrapColumns }
								hyperLinkCallback={ this._onHyperLinkCallback }
								onComponentComplete={ this._onComponentComplete }
								scrollable
								history={ this.props.history }
								location={ this.props.location }
								match={ this.props.match }
								ref={ this.splendidGrid }
							/>
						</React.Fragment>
						: null
						}
					</Content>
				</React.Fragment>
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

export default withRouter(LanguagePacks);
