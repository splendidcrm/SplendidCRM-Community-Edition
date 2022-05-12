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
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome';
import { Appear }                                   from 'react-lifecycle-appear'        ;
// 2. Store and Types. 
import ACL_FIELD_ACCESS                             from '../types/ACL_FIELD_ACCESS'     ;
import IDashletProps                                from '../types/IDashletProps'        ;
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'                ;
import L10n                                         from '../scripts/L10n'               ;
import Security                                     from '../scripts/Security'           ;
import Credentials                                  from '../scripts/Credentials'        ;
import SplendidCache                                from '../scripts/SplendidCache'      ;
import SplendidDynamic                              from '../scripts/SplendidDynamic'    ;
import { Trim, EndsWith }                           from '../scripts/utility'            ;
import { Crm_Config, Crm_Modules }                  from '../scripts/Crm'                ;
import { EditView_LoadLayout }                      from '../scripts/EditView'           ;
import { formatDate, FromJsonDate }                 from '../scripts/Formatting'         ;
import { ListView_LoadTablePaginated }              from '../scripts/ListView'           ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest'    ;
// 4. Components and Views. 
import SplendidGrid                                 from '../components/SplendidGrid'    ;
import SearchView                                   from '../views/SearchView'           ;

const MODULE_NAME   : string = 'Activities';
const GRID_NAME     : string = MODULE_NAME + '.My' + MODULE_NAME;
const TABLE_NAME    : string = 'vw' + MODULE_NAME.toUpperCase() + '_MyList';
const SORT_FIELD    : string = 'DATE_START';
const SORT_DIRECTION: string = 'asc';

interface IMyTeamActivitiesState
{
	DEFAULT_SETTINGS : any;
	optionsVisible   : boolean;
	enableSearch     : boolean;
	lstTHROUGH       : any[];
	THROUGH          : string;
	txtTHROUGH       : string;
	error?           : string;
	dashletVisible   : boolean;
}

export default class MyTeamActivities extends React.Component<IDashletProps, IMyTeamActivitiesState>
{
	private searchView   = React.createRef<SearchView>();
	private splendidGrid = React.createRef<SplendidGrid>();
	private themeURL: string = null;
	// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
	private legacyIcons: boolean = false;

	constructor(props: IDashletProps)
	{
		super(props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		let objDEFAULT_SETTINGS: any = (!Sql.IsEmptyString(props.DEFAULT_SETTINGS) ? Sql.ParseFormData(props.DEFAULT_SETTINGS) : null);
		if ( objDEFAULT_SETTINGS === undefined || objDEFAULT_SETTINGS == null )
		{
			let team = null;
			if ( Crm_Config.enable_team_management() && Crm_Config.enable_team_hierarchy() )
			{
				team = SplendidCache.GetSelectedTeamHierarchy();
			}
			// 10/21/2020 Paul.  Do not apply self as filter if a hierarchy filter is already in place. 
			if ( team == null )
			{
				objDEFAULT_SETTINGS = {};
				objDEFAULT_SETTINGS.TEAM_ID       = Security.TEAM_ID()  ;
				objDEFAULT_SETTINGS.TEAM_NAME     = Security.TEAM_NAME();
				objDEFAULT_SETTINGS.TEAM_SET_LIST = Security.TEAM_ID()  ;
				objDEFAULT_SETTINGS.TEAM_SET_NAME = Security.TEAM_NAME();
			}
		}
		let layout = null;
		if ( !Sql.IsEmptyString(props.SETTINGS_EDITVIEW) )
		{
			layout = EditView_LoadLayout(props.SETTINGS_EDITVIEW);
		}
		let lstTHROUGH: any[] = L10n.GetList('appointment_filter_dom');
		let THROUGH   : string = (lstTHROUGH.length > 0 ? lstTHROUGH[0] : null);
		let txtTHROUGH: string = formatDate(this.GetThroughDate(THROUGH), Security.USER_DATE_FORMAT());
		this.state =
		{
			DEFAULT_SETTINGS: objDEFAULT_SETTINGS,
			optionsVisible  : false,
			enableSearch    : (layout != null),
			lstTHROUGH      ,
			THROUGH         ,
			txtTHROUGH      ,
			dashletVisible  : false,
		}
	}

	componentDidMount()
	{
	}

	private GetThroughDate = (THROUGH: string) =>
	{
		let dtDATE_START: moment.Moment = null;
		let dtZONE_NOW  : moment.Moment = moment();
		let dtZONE_TODAY: moment.Moment = moment();
		dtZONE_TODAY.hours(0);
		dtZONE_TODAY.minutes(0);
		dtZONE_TODAY.seconds(0);
		dtZONE_TODAY.milliseconds(0);
		dtDATE_START = dtZONE_TODAY;
		switch ( THROUGH )
		{
			case 'today'          :  dtDATE_START = dtZONE_TODAY;  break;
			case 'tomorrow'       :  dtDATE_START = dtDATE_START.add(1, 'days');  break;
			// 12/16/2020 Paul.  Must specify days when adding. 
			case 'this Saturday'  :  dtDATE_START = dtDATE_START.add(6 - dtDATE_START.day(), 'days');  break;
			case 'next Saturday'  :  dtDATE_START = dtDATE_START.add(6 - dtDATE_START.day(), 'days').add(7, 'days');  break;
			case 'last this_month':  dtDATE_START = dtDATE_START.endOf('month');  break;
			case 'last next_month':  dtDATE_START = dtDATE_START.add(1, 'months').endOf('month');  break;
		}
		return dtDATE_START;
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

	private _onTHROUGH_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let THROUGH: string = event.target.value;
		let txtTHROUGH: string = formatDate(this.GetThroughDate(THROUGH), Security.USER_DATE_FORMAT());
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTHROUGH_Change', THROUGH);
		this.setState(
		{
			THROUGH   ,
			txtTHROUGH,
		});
		// 12/16/2020 Paul.  Submit after change. 
		if ( this.searchView.current != null )
		{
			this.searchView.current.SubmitSearch();
		}
		else if ( this.splendidGrid.current != null )
		{
			this.splendidGrid.current.Search(null, null);
		}
	}

	private Load = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		const { THROUGH } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load ' + TABLE_NAME);
		// 10/23/2020 Paul.  The DATE_START field is not normally returned as part of the layout, so we have to add manually. 
		let arrSELECT: string[] = sSELECT.split(',');
		if ( arrSELECT.indexOf('DATE_START') < 0 )
		{
			arrSELECT.push('DATE_START');
		}
		if ( arrSELECT.indexOf('ACCEPT_STATUS') < 0 )
		{
			arrSELECT.push('ACCEPT_STATUS');
		}
		sSELECT = arrSELECT.join(',');
		// 12/16/2020 Paul.  Increase by 1 day to include activities on the end day. 
		rowSEARCH_VALUES['DATE_START'] = { FIELD_TYPE: 'DateRange', value: {key: 'DATE_START', before: this.GetThroughDate(THROUGH).add(1, 'days')} };

		let d = await ListView_LoadTablePaginated(TABLE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
		return d;
	}

	private onCloseActivity = (row) =>
	{
		let ID           : string = Sql.ToString(row['ID'           ]);
		let ACTIVITY_TYPE: string = Sql.ToString(row['ACTIVITY_TYPE']);
		this.props.history.push('/Reset/' + ACTIVITY_TYPE + '/Edit/' + ID + '?Status=Close');
	}

	private closeColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		let nEDIT_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, MODULE_NAME, "edit"  , 'ASSIGNED_USER_ID');
		return (
			<span style={ { whiteSpace: 'nowrap'} }>
				{ nEDIT_ACLACCESS >= 0
				? <a href='#' onClick={ (e) => { e.preventDefault(); this.onCloseActivity(row); } }>
					<img src={ this.themeURL + 'close_inline.gif'} alt={ L10n.Term('Activities.LBL_LIST_CLOSE') } style={ {padding: '3px', width: '24px', height: '24px', borderWidth: '0px'} } />
				</a>
				: null
				}
			</span>
		);
	}

	public closeHeader = (column, colIndex, { sortElement, filterElement }) =>
	{
		return (<div>{ L10n.Term('Activities.LBL_LIST_CLOSE') }</div>);
	}

	private dateColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		let dtDATE_START: Date   = FromJsonDate(row['DATE_START']);
		let DATE_START  : string = formatDate(dtDATE_START, Security.USER_DATE_FORMAT());  //  + ' ' + Security.USER_TIME_FORMAT()
		let now         : Date   = new Date();
		return (
			<span style={ { whiteSpace: 'nowrap'} }>
				<span className={ dtDATE_START < now ? 'overdueTask' : 'futureTask' }>{ DATE_START }</span>
			</span>
		);
	}

	public dateHeader = (column, colIndex, { sortElement, filterElement }) =>
	{
		return (<div>{ L10n.Term('Activities.LBL_LIST_DATE') } { sortElement }</div>);
	}

	private onUpdateStatus = async (row: any, STATUS: string) =>
	{
		let ID: string = Sql.ToString(row['ID']);
		try
		{
			let sBody: string = JSON.stringify({ ID, STATUS });
			let res = await CreateSplendidRequest('Rest.svc/UpdateActivityStatus', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			this._onRefresh(null);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.onUpdateStatus', error);
			this.setState({ error: error.message });
		}
	}

	private acceptColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		let nEDIT_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, MODULE_NAME, "edit"  , 'ASSIGNED_USER_ID');
		let ACCEPT_STATUS    : string = Sql.ToString(row['ACCEPT_STATUS']).toLowerCase();
		return (
			<span style={ { whiteSpace: 'nowrap'} }>
				{ nEDIT_ACLACCESS >= 0 && ACCEPT_STATUS == 'none'
				? <React.Fragment>
					<a href='#' onClick={ (e) => { e.preventDefault(); this.onUpdateStatus(row, 'Accept'); } }>
						<img src={ this.themeURL + 'accept_inline.gif'} alt={ L10n.ListTerm('dom_meeting_accept_options', 'accept') } style={ {padding: '3px', width: '24px', height: '24px', borderWidth: '0px'} } />
					</a>
					<a href='#' onClick={ (e) => { e.preventDefault(); this.onUpdateStatus(row, 'Tentative'); } }>
						<img src={ this.themeURL + 'tentative_inline.gif'} alt={ L10n.ListTerm('dom_meeting_accept_options', 'tentative') } style={ {padding: '3px', width: '24px', height: '24px', borderWidth: '0px'} } />
					</a>
					<a href='#' onClick={ (e) => { e.preventDefault(); this.onUpdateStatus(row, 'Decline'); } }>
						<img src={ this.themeURL + 'decline_inline.gif'} alt={ L10n.ListTerm('dom_meeting_accept_options', 'decline') } style={ {padding: '3px', width: '24px', height: '24px', borderWidth: '0px'} } />
					</a>
				</React.Fragment>
				: <React.Fragment>
					{ L10n.ListTerm('dom_meeting_accept_status', ACCEPT_STATUS) }
				</React.Fragment>
				}
			</span>
		);
	}

	public acceptHeader = (column, colIndex, { sortElement, filterElement }) =>
	{
		return (<div>{ L10n.Term('Activities.LBL_ACCEPT_THIS') }</div>);
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
			formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.editviewColumnFormatter : null),
			headerClasses  : 'listViewThS2',
			headerStyle    : {padding: 0, margin: 0},
			headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader : null),
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
		// 01/07/2018 Paul.  Force first column to be displayed. 
		arrDataTableColumns.push(objDataColumn);
		objDataColumn =
		{
			key            : 'editview',
			text           : null,
			dataField      : 'empty1',
			formatter      : this.closeColumnFormatter,
			headerClasses  : 'listViewThS2',
			headerStyle    : {padding: 0, margin: 0},
			headerFormatter: this.closeHeader,
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
		// 10/23/2020 Paul.  Add Date and Activity Status. 
		// 06/03/2021 Paul.  Must specify date field in order to enable support. 
		objDataColumn =
		{
			key            : 'editview',
			text           : null,
			dataField      : 'DATE_START',
			formatter      : this.dateColumnFormatter,
			headerClasses  : 'listViewThS2',
			headerStyle    : {padding: 0, margin: 0},
			headerFormatter: this.dateHeader,
			sort           : true,
			isDummyField   : true,
			attrs          : { width: '15%' },
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
		objDataColumn =
		{
			key            : 'editview',
			text           : null,
			dataField      : 'empty1',
			formatter      : this.acceptColumnFormatter,
			headerClasses  : 'listViewThS2',
			headerStyle    : {padding: 0, margin: 0},
			headerFormatter: this.acceptHeader,
			sort           : false,
			isDummyField   : true,
			attrs          : { width: '5%' },
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

	public render()
	{
		const { TITLE, SETTINGS_EDITVIEW } = this.props;
		const { optionsVisible, enableSearch, DEFAULT_SETTINGS, txtTHROUGH, lstTHROUGH, THROUGH, error, dashletVisible } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', SETTINGS_EDITVIEW, DEFAULT_SETTINGS);
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		// 01/06/2021 Paul.  AutoSaveSearch enabled. 
		// 07/30/2021 Paul.  Load when the panel appears. 
		return (
		<div style={ {display: 'flex', flexGrow: 1} }>
			<div className="card" style={ {flexGrow: 1, margin: '.5em', overflowX: 'auto'} }>
				<Appear onAppearOnce={ (ioe) => this.setState({ dashletVisible: true }) }>
					<div className="card-body DashletHeader" style={ {display: 'flex'} }>
						<h3 style={ {flexGrow: 1, float: 'left'} }>
							{ L10n.Term(TITLE) }
						</h3>
						<span style={ {flexGrow: 2} }>
							{ L10n.Term('Activities.LBL_TODAY') }
							&nbsp;
							<select
								id='lstTHROUGH'
								onChange={ this._onTHROUGH_Change }
								value={ THROUGH }
								style={ {width: 'auto', margin: 2} }
								>
								{
									lstTHROUGH.map((item, index) => 
									{
										return (<option key={ '_lstTHROUGH_' + index.toString() } id={ '_lstTHROUGH' + index.toString() } value={ item }>{ L10n.ListTerm('appointment_filter_dom', item) }</option>);
									})
								}
							</select>
							&nbsp;
							{ txtTHROUGH }
							&nbsp;
							{ !Sql.IsEmptyString(error)
							? <span className='error'>{ error }</span>
							: null
							}
						</span>
						<span style={ {flexGrow: 1} }>
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
						cbCustomLoad={ this.Load }
						cbCustomColumns={ this.BootstrapColumns }
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
