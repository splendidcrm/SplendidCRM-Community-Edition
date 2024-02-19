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
import { RouteComponentProps }       from '../Router5'             ;
import { FontAwesomeIcon }           from '@fortawesome/react-fontawesome';
import { observer }                  from 'mobx-react'                   ;
import BootstrapTable                from 'react-bootstrap-table-next'   ;
import paginationFactory, { PaginationProvider, PaginationListStandalone, PaginationTotalStandalone } from 'react-bootstrap-table2-paginator';
// 2. Store and Types. 
import MODULE                        from '../types/MODULE'              ;
import ACL_FIELD_ACCESS              from '../types/ACL_FIELD_ACCESS'    ;
// 3. Scripts. 
import Sql                           from '../scripts/Sql'               ;
import L10n                          from '../scripts/L10n'              ;
import Security                      from '../scripts/Security'          ;
import Credentials                   from '../scripts/Credentials'       ;
import SplendidCache                 from '../scripts/SplendidCache'     ;
import { Crm_Config }                from '../scripts/Crm'               ;
import { ListView_LoadLayout, ListView_LoadStreamPaginated } from '../scripts/ListView';
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login';
import { Trim, inArray }             from '../scripts/utility'           ;
import { FromJsonDate }              from '../scripts/Formatting'        ;
// 4. Components and Views. 
import DumpSQL                       from '../components/DumpSQL'        ;
import ErrorComponent                from '../components/ErrorComponent' ;
import DateTime                      from '../GridComponents/DateTime'   ;
import Currency                      from '../GridComponents/Currency'   ;
import Tags                          from '../GridComponents/Tags'       ;
import HyperLink                     from '../GridComponents/HyperLink'  ;
import Hover                         from '../GridComponents/Hover'      ;
import Image                         from '../GridComponents/Image'      ;
import ImageButton                   from '../GridComponents/ImageButton';
import JavaScript                    from '../GridComponents/JavaScript' ;
import String                        from '../GridComponents/String'     ;

interface ISplendidStreamProps extends RouteComponentProps<any>
{
	MODULE_NAME             : string;
	ID?                     : string;
	GRID_NAME?              : string;
	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	hyperLinkCallback?      : (MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any) => void;
	scrollable?             : boolean;
	onLayoutLoaded?         : Function;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data) => void;
}

interface ISplendidStreamState
{
	layout                  : any;
	vwMain                  : any;
	columns                 : any;
	__total                 : number;
	__sql                   : string;
	GRID_NAME               : string;
	SEARCH_FILTER           : string;
	SEARCH_VALUES           : any;
	SELECT_FIELDS           : string;
	loaded                  : boolean;
	activePage              : number;
	TOP                     : number;
	error?                  : any;
}
@observer
class SplendidStream extends React.Component<ISplendidStreamProps, ISplendidStreamState>
{
	private _isMounted = false;

	private setStateAsync = (newState: Partial<ISplendidStreamState>) =>
	{
		return new Promise((resolve) =>
		{
			// 05/26/2019 Paul.  The component may be unmounted by the time the custom view is generated. 
			if ( this._isMounted )
			{
				newState.error = null;
				// 02/20/2022 Paul.  Latest version of TypeScript does not allow resolve to return undefined, so return null. 
				this.setState(newState as ISplendidStreamState, () => resolve(null) );
			}
		});
	}

	constructor(props: ISplendidStreamProps)
	{
		super(props);
		let nTOP = Crm_Config.ToInteger('list_max_entries_per_page');
		if ( nTOP <= 0 )
		{
			nTOP = 25;
		}
		this.state =
		{
			layout          : null,
			vwMain          : null,
			columns         : [],
			__total         : 0,
			__sql           : null,
			GRID_NAME       : (props.GRID_NAME      ? props.GRID_NAME      : props.MODULE_NAME + '.ActivityStream.ListView'),
			SELECT_FIELDS   : '',
			SEARCH_FILTER   : '',
			SEARCH_VALUES   : null,
			loaded          : false,
			activePage      : 1,
			TOP             : nTOP,
			error           : null,
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

 	async componentDidUpdate(prevProps: ISplendidStreamProps)
	{
		const { MODULE_NAME } = this.props;
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			let GRID_NAME      = (this.props.GRID_NAME      ? this.props.GRID_NAME      : MODULE_NAME + '.ActivityStream.ListView');
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', GRID_NAME);
			// 05/27/2018 Paul.  If the location changes, then we need an all new state. 
			let nTOP = Crm_Config.ToInteger('list_max_entries_per_page');
			await this.setStateAsync({
				layout                  : null,
				vwMain                  : null,
				columns                 : [],
				__total                 : 0,
				GRID_NAME               ,
				SELECT_FIELDS           : '',
				SEARCH_FILTER           : '',
				SEARCH_VALUES           : null,
				loaded                  : false,
				activePage              : 1,
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
				const { MODULE_NAME, ID } = this.props;
				const { vwMain, layout, GRID_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + GRID_NAME, layout, vwMain);
				// 04/12/2021 Paul.  layout may be null. 
				if ( error == null )
				{
					if ( vwMain != null )
					{
						this.props.onComponentComplete(MODULE_NAME, null, GRID_NAME, vwMain);
					}
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
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.preload', error);
			this.setState({ error });
		}
	}

	private Load = async (sMODULE_NAME: string, GRID_NAME: string) =>
	{
		const { MODULE_NAME, ID, onLayoutLoaded} = this.props;
		const { SELECT_FIELDS, SEARCH_FILTER, SEARCH_VALUES, TOP, activePage } = this.state;
		try
		{
			const layout = ListView_LoadLayout(GRID_NAME);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load layout', layout);
			// 06/19/2018 Paul.  Make sure to clear the data when loading the layout. 
			let arrSELECT_FIELDS = this.GridColumns(layout);
			let columns = this.BootstrapColumns(GRID_NAME, layout, sMODULE_NAME, null);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load', arrSELECT_FIELDS, columns);
			await this.setStateAsync(
			{
				layout: layout,
				__total: 0,
				vwMain: null,
				SELECT_FIELDS: arrSELECT_FIELDS,
				columns: columns
			});
			if ( onLayoutLoaded )
			{
				onLayoutLoaded();
			}
			// 12/26/2019 Paul.  If the onLayoutLoaded propery is not provided, then we need to perform the initial search. 
			else
			{
				let status = await AuthenticatedMethod(this.props, this.constructor.name + '.Search');
				if ( status == 1 )
				{
					// 05/21/2018 Paul.  SEARCH_FILTER is not getting quickly enough, so use parameters. 
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Search: ' + MODULE_NAME + ' ' + ID);
					let d = await ListView_LoadStreamPaginated(MODULE_NAME, ID, SELECT_FIELDS, SEARCH_FILTER, SEARCH_VALUES, TOP, TOP * (activePage - 1));
					this.createKeys(d.results);
					await this.setStateAsync({ __total: d.__total, __sql: d.__sql, vwMain: d.results });
				}
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
		const { MODULE_NAME } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.GridColumns', layout);
		let arrSelectFields = Sql.SelectGridColumns(layout);
		return arrSelectFields.join(',');
	}

	private formatKey = (ID, i) =>
	{
		return ID + '_' + i.toString();
	}

	private createKeys = (results: Array<any>) =>
	{
		if ( results != null )
		{
			for ( let i = 0; i < results.length; i++ )
			{
				let row = results[i];
				row.ID_key = this.formatKey(row.ID, i);
			}
		}
	}

	private boundColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		// 05/27/2018 Paul.  We will need all the layout fields in the render function. 
		let lay = formatExtraData.data.layout;
		return React.createElement(String, { layout: lay, row: row, multiLine: false });
	}

	private templateColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		const { hyperLinkCallback } = this.props;
		// 05/27/2018 Paul.  We will need all the layout fields in the render function.  
		let lay = formatExtraData.data.layout;
		let DATA_FIELD                 = lay.DATA_FIELD;
		let DATA_FORMAT                = lay.DATA_FORMAT;
		let URL_MODULE                 = lay.URL_MODULE;

		let DATA_VALUE = '';
		if ( row[DATA_FIELD] != null || row[DATA_FIELD] === undefined )
		{
			try
			{
				if ( DATA_FORMAT == 'HyperLink' && (URL_MODULE != 'Users') )
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
				// 08/26/2014 Paul.  Ignore ImageButton. 
				else if ( DATA_FORMAT == 'ImageButton' )
				{
					return React.createElement(ImageButton, { layout: lay, row: row });
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

	private _onEdit = (row) =>
	{
		const { history, MODULE_NAME } = this.props;
		history.push(`/Reset/${MODULE_NAME}/Edit/${row.ID}`);
		return false;
	}

	private _onView = (row) =>
	{
		const { history, MODULE_NAME } = this.props;
		history.push(`/Reset/${MODULE_NAME}/View/${row.ID}`);
		return false;
	}

	private streamPictureFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		const { MODULE_NAME } = this.props;
		return (
			<div className='ActivityStreamPicture'>
				{ !Sql.IsEmptyGuid(row['CREATED_BY_ID']) && Sql.IsEmptyString(row['CREATED_BY_PICTURE'])
				? <img className='ActivityStreamPicture' src={ Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/ActivityStreamUser.gif' } />
				: null
				}
				{ !Sql.IsEmptyGuid(row['CREATED_BY_ID']) && !Sql.IsEmptyString(row['CREATED_BY_PICTURE'])
				? <img className='ActivityStreamPicture' src={ Sql.ToString(row['CREATED_BY_PICTURE']) } />
				: null
				}
				{ Sql.IsEmptyGuid(row['CREATED_BY_ID'])
				? <div className={ 'ModuleHeaderModule ModuleHeaderModule' + MODULE_NAME + ' ListHeaderModule' } />
				: null
				}
			</div>
		);
	}

	private _onHyperLink = (MODULE_NAME, ID) =>
	{
		const { history } = this.props;
		history.push(`/Reset/${MODULE_NAME}/View/${ID}`);
		return false;
	}

	private StreamFormatDescription = (row): any =>
	{
		const { MODULE_NAME } = this.props;
		let sSTREAM_ACTION        = Sql.ToString(row['STREAM_ACTION']).toUpperCase();
		if ( Sql.IsEmptyString(sSTREAM_ACTION) )
			sSTREAM_ACTION = 'UPDATED';
		
		let cssCursor = { cursor: 'pointer' };
		let nodes = [];
		let name = row['NAME'];
		let erased = <span className='Erased'>{ L10n.Term('DataPrivacy.LBL_ERASED_VALUE') }</span>;
		if ( name == '{Erased}' )
		{
			name = erased;
		}
		let sMODULE_NAME: string = MODULE_NAME;
		if ( sMODULE_NAME == 'ActivityStream' )
		{
			sMODULE_NAME = Sql.ToString(row['MODULE_NAME']);
		}
		if ( sSTREAM_ACTION == 'CREATED' )
		{
			return (
				<div className='ActivityStreamDescription'>
					{ L10n.Term('ActivityStream.LBL_CREATED') }
					&nbsp;<span className='ActivityStreamLink' onClick={ () => this._onHyperLink(sMODULE_NAME, row['ID']) } style={ cssCursor }>{ name }</span>
					&nbsp;{ L10n.ListTerm('moduleListSingular', sMODULE_NAME) }
				</div>
			);
		}
		else if ( sSTREAM_ACTION == 'UPDATED' )
		{
			let sSTREAM_COLUMNS: string = L10n.Term('ActivityStream.LBL_NONE');
			if ( !Sql.IsEmptyString(row[row['STREAM_COLUMNS']]) )
			{
				let sb = '';
				let arrSTREAM_COLUMNS: string[] = Sql.ToString(row['STREAM_COLUMNS']).split(' ');
				for ( let j = 0; j < arrSTREAM_COLUMNS.length && j < 5; j++ )
				{
					if ( sb.length > 0 )
						sb += ', ';
					sb += L10n.TableColumnName(sMODULE_NAME, arrSTREAM_COLUMNS[j]);
				}
				if ( arrSTREAM_COLUMNS.length > 5 )
				{
					sb += ', ' + L10n.Term('ActivityStream.LBL_MORE');
				}
				sSTREAM_COLUMNS = sb;
			}
			return (
				<div className='ActivityStreamDescription'>
					{ L10n.Term('ActivityStream.LBL_UPDATED') }
					&nbsp;<span className='ActivityStreamUpdateFields'>{ sSTREAM_COLUMNS }</span>
					&nbsp;{ L10n.Term('ActivityStream.LBL_ON') }
					&nbsp;<span className='ActivityStreamLink' onClick={ () => this._onHyperLink(sMODULE_NAME, row['ID']) } style={ cssCursor }>{ name }</span>
				</div>
			);
		}
		else if ( sSTREAM_ACTION == 'DELETED' )
		{
			return (
				<div className='ActivityStreamDescription'>
					{ L10n.Term('ActivityStream.LBL_DELETED') }
					&nbsp;<span>{ name }</span>
					&nbsp;{ L10n.ListTerm('moduleListSingular', sMODULE_NAME) }
				</div>
			);
		}
		else if ( sSTREAM_ACTION == 'POST' )
		{
			return (
				<div className='ActivityStreamDescription'>
					<span>{ row['NAME'] }</span>
				</div>
			);
		}
		else if ( sSTREAM_ACTION == 'LINKED' )
		{
			let relatedName = row['STREAM_RELATED_NAME'];
			if ( relatedName == '{Erased}' )
			{
				relatedName = erased;
			}
			return (
				<div className='ActivityStreamDescription'>
					{ L10n.Term('ActivityStream.LBL_LINKED') }
					&nbsp;<span className='ActivityStreamLink' onClick={ () => this._onHyperLink(sMODULE_NAME, row['ID']) } style={ cssCursor }>{ name }</span>
					&nbsp;{ L10n.Term('ActivityStream.LBL_TO') }
					&nbsp;{ L10n.ListTerm('moduleListSingular', row['STREAM_RELATED_MODULE']) }
					&nbsp;<span className='ActivityStreamLink' onClick={ () => this._onHyperLink(row['STREAM_RELATED_MODULE'], row['STREAM_RELATED_ID']) } style={ cssCursor }>{ relatedName }</span>
				</div>
			);
		}
		else if ( sSTREAM_ACTION == 'UNLINKED' )
		{
			let relatedName = row['STREAM_RELATED_NAME'];
			if ( relatedName == '{Erased}' )
			{
				relatedName = erased;
			}
			return (
				<div className='ActivityStreamDescription'>
					{ L10n.Term('ActivityStream.LBL_UNLINKED') }
					&nbsp;<span className='ActivityStreamLink' onClick={ () => this._onHyperLink(sMODULE_NAME, row['ID']) } style={ cssCursor }>{ name }</span>
					&nbsp;{ L10n.Term('ActivityStream.LBL_FROM') }
					&nbsp;{ L10n.ListTerm('moduleListSingular', row['STREAM_RELATED_MODULE']) }
					&nbsp;<span className='ActivityStreamLink' onClick={ () => this._onHyperLink(row['STREAM_RELATED_MODULE'], row['STREAM_RELATED_ID']) } style={ cssCursor }>{ relatedName }</span>
				</div>
			);
		}
		return nodes;
	}

	private streamDescriptionFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		let STREAM_DATE: string = FromJsonDate(row['STREAM_DATE'], Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
		return (
			<div>
				{ this.StreamFormatDescription(row) }
				<div className='ActivityStreamIdentity'>
					<span className='ActivityStreamCreatedBy'>{ row['CREATED_BY'] }</span>
					<span className='ActivityStreamDateEntered'>{ STREAM_DATE }</span>
				</div>
			</div>
		);
	}

	private renderHeader = (column, colIndex, { sortElement, filterElement }) =>
	{
		return (<div>{ column.text} { sortElement }</div>);
	}

	private BootstrapColumns = (sLIST_MODULE_NAME, layout, sPRIMARY_MODULE, sPRIMARY_ID) =>
	{
		// 04/20/2017 Paul.  Build DataTables columns. 
		let arrDataTableColumns = [];
		let objDataColumn: any = {};
		objDataColumn =
		{
			key            : 'streampicture',
			text           : null,
			dataField      : 'empty1',
			formatter      : this.streamPictureFormatter,
			headerFormatter: this.renderHeader,
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
		arrDataTableColumns.push(objDataColumn);
		objDataColumn =
		{
			key            : 'streamdescription',
			text           : null,
			dataField      : 'empty1',
			formatter      : this.streamDescriptionFormatter,
			headerFormatter: this.renderHeader,
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
				let ITEMSTYLE_HORIZONTAL_ALIGN = lay.ITEMSTYLE_HORIZONTAL_ALIGN;
				let ITEMSTYLE_VERTICAL_ALIGN   = lay.ITEMSTYLE_VERTICAL_ALIGN  ;
				let DATA_FIELD                 = lay.DATA_FIELD                ;
				let DATA_FORMAT                = lay.DATA_FORMAT               ;
				let MODULE_NAME                = lay.MODULE_NAME               ;

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
				// 08/20/2016 Paul.  The hidden field is a DATA_FORMAT, not a COLUMN_TYPE, but keep COLUMN_TYPE just in case anyone used it. 
				// 07/22/2019 Paul.  Apply ACL Field Security. 
				if ( !bIsReadable || COLUMN_TYPE == 'Hidden' || DATA_FORMAT == 'Hidden' )
				{
					continue;  // 04/23/2017 Paul.  Return instead of continue as we are in a binding function. 
				}
				// 04/10/2017 Paul.  Hide unsupported formats. 
				else if ( COLUMN_TYPE == 'TemplateColumn' && (DATA_FORMAT == 'Hover' || DATA_FORMAT == 'ImageButton' || DATA_FORMAT == 'Hidden') )
				{
					continue;  // 04/23/2017 Paul.  Return instead of continue as we are in a binding function. 
				}
				if ( COLUMN_TYPE == 'TemplateColumn' )
				{
					// 04/20/2017 Paul.  Build DataTables columns. 
					objDataColumn =
					{
						key         : 'column' + nLayoutIndex,
						text        : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField   : DATA_FIELD,
						classes     : '',
						formatter   : this.templateColumnFormatter,
						sort        : (SORT_EXPRESSION != null),
						isDummyField: false,
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
					if ( DATA_FIELD == 'NAME' )
					{
						objDataColumn.classes = ' all';
					}
					objDataColumn.classes = Trim(objDataColumn.classes);

					arrDataTableColumns.push(objDataColumn);
				}
				else if ( COLUMN_TYPE == 'BoundColumn' )
				{
					// 04/20/2017 Paul.  Build DataTables columns. 
					objDataColumn =
					{
						key         : 'column' + nLayoutIndex,
						text        : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField   : DATA_FIELD,
						classes     : '',
						formatter   : this.boundColumnFormatter,
						sort        : (SORT_EXPRESSION != null),
						isDummyField: false,
						formatExtraData: {
							data: {
								GRID_NAME   : sLIST_MODULE_NAME,
								DATA_FIELD  : DATA_FIELD,
								COLUMN_INDEX: COLUMN_INDEX,
								layout      : lay
							}
						}
					};
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
		return arrDataTableColumns;
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments)
	}

	// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
	public Search = async (sSEARCH_FILTER: string, rowSEARCH_VALUES: any) =>
	{
		const { MODULE_NAME, ID } = this.props;
		const { SELECT_FIELDS, TOP } = this.state;
		// 02/23/2021 Paul.  The activePage state value will not be updated locally, so use a local variable instead to prevent stale page number. 
		let activePage: number = 1;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Search', sSEARCH_FILTER, rowSEARCH_VALUES);
		await this.setStateAsync({ activePage, SEARCH_FILTER: sSEARCH_FILTER, SEARCH_VALUES: rowSEARCH_VALUES });
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.Search');
			if ( status == 1 )
			{
				// 05/21/2018 Paul.  SEARCH_FILTER is not getting quickly enough, so use parameters. 
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Search: ' + MODULE_NAME + ' ' + ID);
				let d = await ListView_LoadStreamPaginated(MODULE_NAME, ID, SELECT_FIELDS, sSEARCH_FILTER, rowSEARCH_VALUES, TOP, TOP * (activePage - 1));
				this.createKeys(d.results);
				await this.setStateAsync({ __total: d.__total, __sql: d.__sql, vwMain: d.results });
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.Search');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Search', error);
			this.setState({ error });
		}
	}

	private _onPageChange = async (page, sizePerPage) =>
	{
		const { MODULE_NAME, ID } = this.props;
		const { SEARCH_FILTER, SELECT_FIELDS, TOP } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onPageChange', page);
		await this.setStateAsync({ activePage: page });
		try
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onPageChange: ' + MODULE_NAME + ' ' + ID);
			let d = await ListView_LoadStreamPaginated(MODULE_NAME, ID, SELECT_FIELDS, SEARCH_FILTER, null, TOP, TOP * (page - 1));
			this.createKeys(d.results);
			await this.setStateAsync({ __total: d.__total, vwMain: d.results });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.handlePaginationChange', error);
			this.setState({ error });
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

	public render()
	{
		const { vwMain, activePage, columns, TOP, error } = this.state;
		const { __total, __sql } = this.state;
		// 05/22/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( SplendidCache.IsInitialized && vwMain )
		{
			let defaultSorted = [];
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render defaultSorted', defaultSorted);
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
			// https://react-bootstrap-table.github.io/react-bootstrap-table2/storybook/index.html?selectedKind=Pagination&selectedStory=Standalone%20Pagination%20List&full=0&addons=1&stories=1&panelRight=0&addonPanel=storybook%2Factions%2Factions-panel
			let themeURL: string = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
			return (
				<PaginationProvider pagination={ pagination }>
				{
					({
						paginationProps,
						paginationTableProps
					}) => (
						<div>
							<DumpSQL SQL={ __sql } />
							<table className='listView' cellSpacing={ 1 } cellPadding={ 3 } style={ {width: '100%'} }>
								<tr className='listViewPaginationTdS1'>
									<td style={ {textAlign: 'right'} } className='react-bootstrap-table-pagination-total pageNumbers'>
										<span className='paginationButtonPrevious' style={ {cursor: 'pointer'} } onClick={ () => this._onPrevPage(paginationProps) }>
											<img className='paginationButtonPrevious' src={ themeURL + (paginationProps.page > 1 ? 'previous.gif' : 'previous_off.gif') } />
											<span style={ {margin: '3px'} }>{ paginationProps.prePageText }</span>
										</span>
										<span style={ {margin: '3px'} }>
											({ paginationProps.paginationTotalRenderer(paginationProps.pageStartIndex + (paginationProps.page - 1) * paginationProps.sizePerPage, Math.min(paginationProps.page * paginationProps.sizePerPage, paginationProps.totalSize), paginationProps.totalSize) })
										</span>
										<span className='paginationButtonNext' style={ {cursor: 'pointer'} } onClick={ () => this._onNextPage(paginationProps) }>
											<span style={ {margin: '3px'} }>{ paginationProps.nextPageText }</span>
											<img className='paginationButtonNext' src={ themeURL + (paginationProps.page * paginationProps.sizePerPage < paginationProps.totalSize ? 'next.gif' : 'next_off.gif') } />
										</span>
									</td>
								</tr>
							</table>
							{ false ? <PaginationTotalStandalone { ...paginationProps } /> : null }
							{ false ? <PaginationListStandalone  { ...paginationProps } /> : null }
							<BootstrapTable
								keyField='ID_key'
								data={ vwMain }
								classes='listView'
								bordered={ false }
								remote
								columns={ columns }
								defaultSorted={ defaultSorted }
								bootstrap4 compact hover
								wrapperClasses={ 'bg-white' }
								{ ...paginationTableProps }
							/>
						</div>
					)
				}
					</PaginationProvider>
			);
		}
		else if ( error != null )
		{
			return (<ErrorComponent error={error} />);
		}
		return null;
	}

}

// 07/13/2019 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 
export default SplendidStream;
