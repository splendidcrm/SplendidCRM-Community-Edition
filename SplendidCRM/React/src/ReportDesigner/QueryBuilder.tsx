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
import { XMLParser, XMLBuilder }                         from 'fast-xml-parser'               ;
import DateTime                                          from 'react-datetime'                ;
import 'react-datetime/css/react-datetime.css';
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                               from '../scripts/Sql'                ;
import L10n                                              from '../scripts/L10n'               ;
import Security                                          from '../scripts/Security'           ;
import Credentials                                       from '../scripts/Credentials'        ;
import SplendidCache                                     from '../scripts/SplendidCache'      ;
import StringBuilder                                     from '../scripts/StringBuilder'      ;
import { formatDate, FromJsonDate }                      from '../scripts/Formatting'         ;
import { Crm_Config, Crm_Modules }                       from '../scripts/Crm'                ;
import { dumpObj, uuidFast, Trim, StartsWith, EndsWith } from '../scripts/utility'            ;
import { CreateSplendidRequest, GetSplendidResult }      from '../scripts/SplendidRequest'    ;
import { ValidateDateParts }                             from '../scripts/utility'            ;
import { EditView_LoadLayout, EditView_FindField }       from '../scripts/EditView'           ;
// 4. Components and Views. 
import DynamicPopupView                                  from '../views/DynamicPopupView'     ;
import ErrorComponent                                    from '../components/ErrorComponent'  ;

let bDebug: boolean = false;
const ControlChars = { CrLf: '\r\n', Cr: '\r', Lf: '\n', Tab: '\t' };

interface IQueryBuilderProps
{
	row                         : any         ;
	DATA_FIELD                  : string      ;
	onChanged                   : (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any) => void;
	bReportDesignerWorkflowMode?: boolean     ;
	Modules?                    : string      ;
	UseSQLParameters?           : boolean     ;
	UserSpecific?               : boolean     ;
	PrimaryKeyOnly?             : boolean     ;
	DesignChart?                : boolean     ;
	DesignWorkflow?             : boolean     ;
	ShowRelated?                : boolean     ;
	ShowModule?                 : boolean     ;
	DisplayColumns?             : string[]    ;
	onComponentComplete?        : (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IQueryBuilderState
{
	oPreviewSQL                : any         ;
	// 07/04/2016 Paul.  Special case when not showing selected fields. 
	error?                     : any         ;
	REPORT_NAME                : string      ;
	MODULE                     : string      ;
	RELATED                    : string      ;
	SHOW_QUERY                 : boolean     ;
	reportXml                  : any         ;
	reportXmlJson              : string      ;
	relatedModuleXml           : any         ;
	relatedModuleXmlJson       : any         ;
	relationshipXml            : any         ;
	relationshipXmlJson        : any         ;
	filterXml                  : any         ;
	filterXmlJson              : any         ;
	filterXmlEditIndex         : number      ;
	popupOpen                  : boolean     ;
	MODULES_LIST               : any[]       ;
	RELATED_LIST               : any[]       ;
	FILTER_COLUMN_SOURCE_LIST  : any[]       ;
	FILTER_COLUMN_LIST         : any[]       ;
	FILTER_COLUMN_LIST_NAMES   : any         ;
	FILTER_OPERATOR_LIST       : any[]       ;
	FILTER_SEARCH_LIST_NAME    : string      ;
	FILTER_SEARCH_DROPDOWN_LIST: any[]       ;
	FILTER_SEARCH_LISTBOX_LIST : any[]       ;
	FILTER_SEARCH_DROPDOWN     : string      ;
	FILTER_SEARCH_LISTBOX      : string[]    ;
	FILTER_ID                  : string      ;
	FILTER_COLUMN_SOURCE       : string      ;
	FILTER_COLUMN              : string      ;
	FILTER_OPERATOR            : string      ;
	FILTER_OPERATOR_TYPE       : string      ;
	FILTER_SEARCH_ID           : string      ;
	FILTER_SEARCH_DATA_TYPE    : string      ;
	FILTER_SEARCH_TEXT         : string      ;
	FILTER_SEARCH_TEXT2        : string      ;
	FILTER_SEARCH_START_DATE   : string      ;
	FILTER_SEARCH_END_DATE     : string      ;
	FILTER_SEARCH_MODULE_TYPE  : string      ;
	FILTER_SEARCH_MODE         : string      ;
}

export default class QueryBuilder extends React.Component<IQueryBuilderProps, IQueryBuilderState>
{
	private _isMounted    : boolean = false;
	private themeURL      : string;
	private DATE_FORMAT   : string;
	private FILTER_COLUMN_LIST_CACHE: any = {};

	public get data(): any
	{
		// 01/18/2022 Paul.  ProspectLists uses MODULE and the primary module field.  None of the other modules use this field directly. 
		const { MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml } = this.state;
		let row: any = { MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml };
		return row;
	}

	public validate(): boolean
	{
		let bValid: boolean = true;
		return bValid;
	}

	public error(): any
	{
		return this.state.error;
	}

	constructor(props: IQueryBuilderProps)
	{
		super(props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
		this.DATE_FORMAT = Security.USER_DATE_FORMAT();
		let error: any = 'Loading modules.';
		this.state =
		{
			oPreviewSQL                : null,
			error                      ,
			REPORT_NAME                : null,
			MODULE                     : null,
			RELATED                    : null,
			SHOW_QUERY                 : Sql.ToBoolean(localStorage.getItem('QueryBuilder.SHOW_QUERY')),
			reportXml                  : {},
			reportXmlJson              : null,
			relatedModuleXml           : null,
			relatedModuleXmlJson       : null,
			relationshipXml            : null,
			relationshipXmlJson        : null,
			filterXml                  : null,
			filterXmlJson              : null,
			filterXmlEditIndex         : -1,
			popupOpen                  : false,
			MODULES_LIST               : [],
			RELATED_LIST               : [],
			FILTER_COLUMN_SOURCE_LIST  : [],
			FILTER_COLUMN_LIST         : [],
			FILTER_COLUMN_LIST_NAMES   : {},
			FILTER_OPERATOR_LIST       : [],
			FILTER_SEARCH_LIST_NAME    : null,
			FILTER_SEARCH_DROPDOWN_LIST: [],
			FILTER_SEARCH_LISTBOX_LIST : [],
			FILTER_SEARCH_DROPDOWN     : null,
			FILTER_SEARCH_LISTBOX      : [],
			FILTER_ID                  : null,
			FILTER_COLUMN_SOURCE       : null,
			FILTER_COLUMN              : null,
			FILTER_OPERATOR            : null,
			FILTER_OPERATOR_TYPE       : null,
			FILTER_SEARCH_ID           : null,
			FILTER_SEARCH_DATA_TYPE    : null,
			FILTER_SEARCH_TEXT         : null,
			FILTER_SEARCH_TEXT2        : null,
			FILTER_SEARCH_START_DATE   : null,
			FILTER_SEARCH_END_DATE     : null,
			FILTER_SEARCH_MODULE_TYPE  : null,
			FILTER_SEARCH_MODE         : null,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	// As soon as the render method has been executed the componentDidMount function is called. 
	async componentDidMount()
	{
		const { row, DATA_FIELD, DisplayColumns } = this.props;
		this._isMounted = true;
		try
		{
			let options: any = 
			{
				attributeNamePrefix: ''     ,
				// 02/17/2024 Paul.  parser v4 creates object for Value.  
				// 02/17/2024 Paul.  Name and Value at same level causes confusion. 
				//textNodeName       : 'Value',
				ignoreAttributes   : false  ,
				ignoreNameSpace    : true   ,
				parseAttributeValue: true   ,
				trimValues         : false  ,
			};
			// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
			const parser = new XMLParser(options);

			let REPORT_NAME          : string  = null;
			let MODULE               : string  = (row ? row['MODULE_NAME'] : null);
			let RELATED              : string  = null;
			let reportXml            : any     = null;
			let reportXmlJson        : string  = null;
			let relatedModuleXml     : any     = null;
			let relatedModuleXmlJson : any     = null;
			let relationshipXml      : any     = null;
			let relationshipXmlJson  : any     = null;
			let filterXml            : any     = null;
			let filterXmlJson        : any     = null;
			if ( !Sql.IsEmptyString(row[DATA_FIELD]) )
			{
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				reportXml     = parser.parse(row[DATA_FIELD]);
				// 05/20/2020 Paul.  A single record will not come in as an array, so convert to an array. 
				if ( reportXml.Filters && reportXml.Filters.Filter && !Array.isArray(reportXml.Filters.Filter) )
				{
					let table1: any = reportXml.Filters.Filter;
					reportXml.Filters.Filter = [];
					reportXml.Filters.Filter.push(table1);
				}
				if ( reportXml.Report && reportXml.Report.CustomProperties && Array.isArray(reportXml.Report.CustomProperties.CustomProperty) )
				{
					let arrCustomProperty: any[] = reportXml.Report.CustomProperties.CustomProperty;
					for ( let i: number = 0; i < arrCustomProperty.length; i++ )
					{
						let prop: any = arrCustomProperty[i];
						let sName : string = prop.Name;
						let sValue: string = prop.Value;
						switch ( sName )
						{
							case 'crm:ReportName'    :  REPORT_NAME      = sValue;  break;
							case 'crm:Module'        :  MODULE           = sValue;  break;
							case 'crm:Related'       :  RELATED          = sValue;  break;
							case 'crm:RelatedModules':
								// 05/15/2021 Paul.  Ignore data from file and just use latest QueryBuilderState. 
								//sValue = this.decodeHTML(sValue);
								//relatedModuleXml = XMLParser.parse(sValue, options);
								//// 05/14/2021 Paul.  If there is only one, convert to an array. 
								//if ( relatedModuleXml.Relationships && relatedModuleXml.Relationships.Relationship && !Array.isArray(relatedModuleXml.Relationships.Relationship) )
								//{
								//	let relationship1: any = relatedModuleXml.Relationships.Relationship;
								//	relatedModuleXml.Relationships.Relationship = [];
								//	relatedModuleXml.Relationships.Relationship.push(relationship1);
								//}
								//relatedModuleXmlJson = dumpObj(relatedModuleXml, 'relatedModuleXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
								break;
							case 'crm:Relationships' :
								// 05/15/2021 Paul.  Ignore data from file and just use latest QueryBuilderState. 
								//sValue = this.decodeHTML(sValue);
								//relationshipXml  = parser.parse(sValue);
								//// 05/14/2021 Paul.  If there is only one, convert to an array. 
								//if ( relationshipXml.Relationships && relationshipXml.Relationships.Relationship && !Array.isArray(relationshipXml.Relationships.Relationship) )
								//{
								//	let relationship1: any = relationshipXml.Relationships.Relationship;
								//	relationshipXml.Relationships.Relationship = [];
								//	relationshipXml.Relationships.Relationship.push(relationship1);
								//}
								//relationshipXmlJson = dumpObj(relationshipXml, 'relationshipXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
								break;
							case 'crm:Filters'       :
								sValue = this.decodeHTML(sValue);
								// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
								filterXml        = parser.parse(sValue);
								// 05/14/2021 Paul.  If there is only one, convert to an array. 
								if ( filterXml.Filters && filterXml.Filters.Filter && !Array.isArray(filterXml.Filters.Filter) )
								{
									let Filter1: any = filterXml.Filters.Filter;
									filterXml.Filters.Filter = [];
									filterXml.Filters.Filter.push(Filter1);
								}
								filterXmlJson = dumpObj(filterXml, 'filterXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
								break;
						}
					}
				}
				reportXmlJson = dumpObj(reportXml, 'reportXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
			}

			let results: any = await this.getQueryBuilderState(this.props.Modules, MODULE, null, this.constructor.name + '.componentDidMount');
			let MODULES_LIST             : any[]  = results.MODULES_LIST             ;
			let RELATED_LIST             : any[]  = results.RELATED_LIST             ;
			let FILTER_COLUMN_SOURCE_LIST: any[]  = results.FILTER_COLUMN_SOURCE_LIST;
			let FILTER_COLUMN_LIST       : any[]  = results.FILTER_COLUMN_LIST       ;
			let FILTER_COLUMN_LIST_NAMES : any    = results.FILTER_COLUMN_LIST_NAMES ;
			let sRelatedModules          : string = results.RelatedModules           ;
			let sRelationships           : string = results.Relationships            ;
			if ( !Sql.IsEmptyString(sRelatedModules) )
			{
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				relatedModuleXml = parser.parse(sRelatedModules);
				// 05/14/2021 Paul.  If there is only one, convert to an array. 
				if ( relatedModuleXml.Relationships && relatedModuleXml.Relationships.Relationship && !Array.isArray(relatedModuleXml.Relationships.Relationship) )
				{
					let relationship1: any = relatedModuleXml.Relationships.Relationship;
					relatedModuleXml.Relationships.Relationship = [];
					relatedModuleXml.Relationships.Relationship.push(relationship1);
				}
				relatedModuleXmlJson = dumpObj(relatedModuleXml, 'relatedModuleXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
			}
			if ( !Sql.IsEmptyString(sRelationships) )
			{
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				relationshipXml  = parser.parse(sRelationships);
				// 05/14/2021 Paul.  If there is only one, convert to an array. 
				if ( relationshipXml.Relationships && relationshipXml.Relationships.Relationship && !Array.isArray(relationshipXml.Relationships.Relationship) )
				{
					let relationship1: any = relationshipXml.Relationships.Relationship;
					relationshipXml.Relationships.Relationship = [];
					relationshipXml.Relationships.Relationship.push(relationship1);
				}
				relationshipXmlJson = dumpObj(relationshipXml, 'relationshipXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
			}

			let FILTER_COLUMN_SOURCE: string = '';
			let FILTER_COLUMN       : string = '';
			if ( FILTER_COLUMN_SOURCE_LIST != null && FILTER_COLUMN_SOURCE_LIST.length > 0 )
			{
				FILTER_COLUMN_SOURCE = FILTER_COLUMN_SOURCE_LIST[0].MODULE_NAME;
				// 05/15/2021 Paul.  Cache the FILTER_COLUMN_LIST. 
				this.FILTER_COLUMN_LIST_CACHE[FILTER_COLUMN_SOURCE] = FILTER_COLUMN_LIST;
			}
			if ( FILTER_COLUMN_LIST != null && FILTER_COLUMN_LIST.length > 0 )
			{
				FILTER_COLUMN = FILTER_COLUMN_LIST[0].NAME;
			}

			let oPreviewSQL: any = await this.getReportSQL(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, DisplayColumns);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', this.designerModules);
			this.setState(
			{
				oPreviewSQL              ,
				error                    : null,
				REPORT_NAME              ,
				MODULE                   ,
				RELATED                  ,
				reportXml                ,
				reportXmlJson            ,
				relatedModuleXml         ,
				relatedModuleXmlJson     ,
				relationshipXml          ,
				relationshipXmlJson      ,
				filterXml                ,
				filterXmlJson            ,
				MODULES_LIST             ,
				RELATED_LIST             ,
				FILTER_COLUMN_SOURCE_LIST,
				FILTER_COLUMN_LIST       ,
				FILTER_COLUMN_LIST_NAMES ,
				FILTER_ID                : '',
				FILTER_COLUMN_SOURCE     ,
				FILTER_COLUMN            ,
				FILTER_OPERATOR          : '',
				FILTER_OPERATOR_TYPE     : '',
				FILTER_SEARCH_ID         : '',
				FILTER_SEARCH_DATA_TYPE  : '',
				FILTER_SEARCH_TEXT       : '',
				filterXmlEditIndex       : -1,
			}, () =>
			{
				this.filterColumnChanged(FILTER_COLUMN_SOURCE, FILTER_COLUMN);
				this.props.onChanged('filterXml'       , filterXml       , null, null);
				this.props.onChanged('relatedModuleXml', relatedModuleXml, null, null);
				this.props.onChanged('relationshipXml' , relationshipXml , null, null);
			});
			if ( oPreviewSQL && !Sql.IsEmptyString(oPreviewSQL) )
			{
				this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL, null, null);
			}
			if ( this.props.onComponentComplete )
			{
				this.props.onComponentComplete(null, null, null, null);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	shouldComponentUpdate(nextProps: IQueryBuilderProps, nextState: IQueryBuilderState)
	{
		if ( this.props.row != null && nextProps.row != null )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate', this.props.row, nextProps.row);
			if ( this.props.row['MODULE_NAME'] != nextProps.row['MODULE_NAME'] && nextProps.row['MODULE_NAME'] != this.state.MODULE )
			{
				let MODULE: string = nextProps.row['MODULE_NAME'];
				this.moduleChanged(nextProps.Modules, MODULE, '', true);
			}
			else if ( this.props.DesignWorkflow && this.props.row['TYPE'] != nextProps.row['TYPE'] )
			{
				let MODULE: string = nextProps.row['MODULE_NAME'];
				this.moduleChanged(nextProps.Modules, MODULE, '', true);
			}
			else if ( JSON.stringify(this.props.DisplayColumns) != JSON.stringify(nextProps.DisplayColumns) )
			{
				let { MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml } = this.state;
				this.getReportSQL(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, nextProps.DisplayColumns).then((oPreviewSQL: string) =>
				{
					this.setState({ oPreviewSQL });
				})
				.catch((error) =>
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate', error);
				});
			}
		}
		return true;
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private moduleChanged = async (Modules: string, MODULE: string, RELATED: string, bClearFilters: boolean) =>
	{
		const { DisplayColumns } = this.props;
		const { relatedModuleXml, relationshipXml } = this.state
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moduleChanged ' + MODULE, RELATED);
		let { filterXml, filterXmlJson, filterXmlEditIndex } = this.state;
		try
		{
			let results: any = await this.getQueryBuilderState(Modules, MODULE, RELATED, this.constructor.name + '.moduleChanged');
			let MODULES_LIST             : any[] = results.MODULES_LIST             ;
			let RELATED_LIST             : any[] = results.RELATED_LIST             ;
			let FILTER_COLUMN_SOURCE_LIST: any[] = results.FILTER_COLUMN_SOURCE_LIST;
			let FILTER_COLUMN_LIST       : any[] = results.FILTER_COLUMN_LIST       ;
			let FILTER_COLUMN_LIST_NAMES : any    = results.FILTER_COLUMN_LIST_NAMES ;
			let FILTER_COLUMN_SOURCE     : string = null;
			let FILTER_COLUMN            : string = null;
			if ( FILTER_COLUMN_SOURCE_LIST != null && FILTER_COLUMN_SOURCE_LIST.length > 0 )
			{
				FILTER_COLUMN_SOURCE = FILTER_COLUMN_SOURCE_LIST[0].MODULE_NAME;
				// 05/15/2021 Paul.  Cache the FILTER_COLUMN_LIST. 
				this.FILTER_COLUMN_LIST_CACHE[FILTER_COLUMN_SOURCE] = FILTER_COLUMN_LIST;
			}
			// 06/04/2021 Paul.  Must update column when list changes. 
			if ( FILTER_COLUMN_LIST != null && FILTER_COLUMN_LIST.length > 0 )
			{
				FILTER_COLUMN = FILTER_COLUMN_LIST[0].NAME;
			}
			let options: any = 
			{
				attributeNamePrefix: ''     ,
				// 02/17/2024 Paul.  parser v4 creates object for Value.  
				// 02/17/2024 Paul.  Name and Value at same level causes confusion. 
				//textNodeName       : 'Value',
				ignoreAttributes   : false  ,
				ignoreNameSpace    : true   ,
				parseAttributeValue: true   ,
				trimValues         : false  ,
			};
			// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
			const parser = new XMLParser(options);

			// 02/09/2022 Paul.  Must also update relationship data. 
			let relatedModuleXml     : any     = null;
			let relatedModuleXmlJson : any     = null;
			let relationshipXml      : any     = null;
			let relationshipXmlJson  : any     = null;
			let sRelatedModules          : string = results.RelatedModules           ;
			let sRelationships           : string = results.Relationships            ;
			if ( !Sql.IsEmptyString(sRelatedModules) )
			{
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				relatedModuleXml = parser.parse(sRelatedModules);
				// 05/14/2021 Paul.  If there is only one, convert to an array. 
				if ( relatedModuleXml.Relationships && relatedModuleXml.Relationships.Relationship && !Array.isArray(relatedModuleXml.Relationships.Relationship) )
				{
					let relationship1: any = relatedModuleXml.Relationships.Relationship;
					relatedModuleXml.Relationships.Relationship = [];
					relatedModuleXml.Relationships.Relationship.push(relationship1);
				}
				relatedModuleXmlJson = dumpObj(relatedModuleXml, 'relatedModuleXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
			}
			if ( !Sql.IsEmptyString(sRelationships) )
			{
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				relationshipXml  = parser.parse(sRelationships);
				// 05/14/2021 Paul.  If there is only one, convert to an array. 
				if ( relationshipXml.Relationships && relationshipXml.Relationships.Relationship && !Array.isArray(relationshipXml.Relationships.Relationship) )
				{
					let relationship1: any = relationshipXml.Relationships.Relationship;
					relationshipXml.Relationships.Relationship = [];
					relationshipXml.Relationships.Relationship.push(relationship1);
				}
				relationshipXmlJson = dumpObj(relationshipXml, 'relationshipXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
			}
			if ( bClearFilters )
			{
				filterXml          = null;
				filterXmlJson      = '';
				filterXmlEditIndex = -1;
			}
			// 05/15/2021 Paul.  Cache the FILTER_COLUMN_LIST. 
			this.FILTER_COLUMN_LIST_CACHE[FILTER_COLUMN_SOURCE_LIST[0].MODULE_NAME] = FILTER_COLUMN_LIST;
			let oPreviewSQL: string = await this.getReportSQL(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, DisplayColumns);
			this.setState(
			{
				MODULE                   ,
				RELATED                  ,
				MODULES_LIST             ,
				RELATED_LIST             ,
				FILTER_COLUMN_SOURCE_LIST,
				FILTER_COLUMN_SOURCE     ,
				FILTER_COLUMN_LIST       ,
				FILTER_COLUMN_LIST_NAMES ,
				FILTER_COLUMN            ,
				filterXml                ,
				filterXmlJson            ,
				filterXmlEditIndex       ,
				relatedModuleXml         ,  // 02/09/2022 Paul.  Must also update relationship data. 
				relatedModuleXmlJson     ,
				relationshipXml          ,
				relationshipXmlJson      ,
				oPreviewSQL              ,
			}, () =>
			{
				this.filterColumnChanged(null, null);
				this.props.onChanged('filterXml'       , filterXml       , null, null);
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.moduleChanged', error);
			this.setState({ error });
		}
	}

	private getQueryBuilderState = async (Modules: string, MODULE: string, RELATED: string, caller?: string) =>
	{
		const { DesignWorkflow } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getQueryBuilderState ' + MODULE + ', ' + RELATED, caller);
		try
		{
			let TYPE: string = Sql.ToString(this.props.row['TYPE']);
			let url : string = (DesignWorkflow ? 'Administration/Workflows' : 'Reports');
			let res  = await CreateSplendidRequest(url + '/Rest.svc/GetQueryBuilderState?Modules=' + Sql.ToString(Modules) + '&MODULE_NAME=' + Sql.ToString(MODULE) + '&RELATED=' + Sql.ToString(RELATED) + '&TYPE=' + Sql.ToString(TYPE), 'GET');
			let json = await GetSplendidResult(res);
			return json.d;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.getQueryBuilderState', error);
			this.setState({ error });
		}
		return null;
	}

	private getReportingModules = async () =>
	{
		try
		{
			let res  = await CreateSplendidRequest('Reports/Rest.svc/GetReportingModules?Modules=' + Sql.ToString(this.props.Modules), 'GET');
			let json = await GetSplendidResult(res);
			let obj: any = json.d;
			return obj.results;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.getReportingModules', error);
			this.setState({ error });
		}
		return null;
	}

	private getModuleRelationships = async (MODULE_NAME: string) =>
	{
		try
		{
			let res  = await CreateSplendidRequest('Reports/Rest.svc/GetModuleRelationships?MODULE_NAME=' + MODULE_NAME, 'GET');
			let json = await GetSplendidResult(res);
			let obj: any = json.d;
			return obj.results;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.getModuleRelationships', error);
			this.setState({ error });
		}
		return null;
	}

	private getModuleFilterSource = async (MODULE_NAME: string, RELATED: string) =>
	{
		try
		{
			let res  = await CreateSplendidRequest('Reports/Rest.svc/GetModuleFilterSource?MODULE_NAME=' + MODULE_NAME + '&RELATED=' + RELATED, 'GET');
			let json = await GetSplendidResult(res);
			let obj: any = json.d;
			return obj.results;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.getModuleFilterSource', error);
			this.setState({ error });
		}
		return null;
	}

	private getReportingFilterColumns = async (MODULE_NAME: string, TABLE_ALIAS: string) =>
	{
		const { DesignWorkflow } = this.props;
		try
		{
			let url : string = (DesignWorkflow ? 'Administration/Workflows/Rest.svc/GetWorkflowFilterColumns' : 'Reports/Rest.svc/GetReportingFilterColumns');
			let res  = await CreateSplendidRequest(url + '?MODULE_NAME=' + MODULE_NAME + '&TABLE_ALIAS=' + TABLE_ALIAS, 'GET');
			let json = await GetSplendidResult(res);
			let obj: any = json.d;
			return obj.results;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.getReportingFilterColumns', error);
			this.setState({ error });
		}
		return null;
	}

	private getReportSQL = async (MODULE: string, RELATED: string, filterXml: any, relatedModuleXml: any, relationshipXml: any, DisplayColumns: string[]) =>
	{
		const { DesignWorkflow, row } = this.props;
		let PrimaryKeyOnly   = Sql.ToBoolean(this.props.PrimaryKeyOnly  );
		let UseSQLParameters = Sql.ToBoolean(this.props.UseSQLParameters);
		let DesignChart      = Sql.ToBoolean(this.props.DesignChart     );
		let UserSpecific     = Sql.ToBoolean(this.props.UserSpecific    );

		let oPreviewSQL: string = null;
		try
		{
			let obj: any =
			{
				// 06/05/2021 Paul.  Keep using MODULE to match Reports. 
				MODULE          ,
				RELATED         ,
				PrimaryKeyOnly  ,
				UseSQLParameters,
				DesignChart     ,
				UserSpecific    ,
				filterXml       ,
				relatedModuleXml,
				relationshipXml ,
			};
			if ( DesignWorkflow && row )
			{
				obj.TYPE = row.TYPE;
			}
			if ( Array.isArray(DisplayColumns) )
			{
				let displayColumnsXml: any = {};
				displayColumnsXml.DisplayColumns = {};
				displayColumnsXml.DisplayColumns.DisplayColumn = [];
				for ( let i: number = 0; i < DisplayColumns.length; i++ )
				{
					if ( !Sql.IsEmptyString(DisplayColumns[i]) )
					{
						let displayColumn: any = {};
						displayColumn.Label = DisplayColumns[i];
						displayColumn.Field = DisplayColumns[i];
					
						let arrField: string[] = DisplayColumns[i].split('.');
						if ( arrField.length == 2 )
						{
							displayColumn.Label = L10n.TableColumnName(arrField[0], arrField[1]);
						}
						displayColumnsXml.DisplayColumns.DisplayColumn.push(displayColumn);
					}
				}
				obj.displayColumnsXml = displayColumnsXml;
			}
			// 11/09/2019 Paul.  We cannot use ADAL because we are using the response_type=code style of authentication (confidential) that ADAL does not support. 
			let sBody: string = JSON.stringify(obj);
			let url : string = (DesignWorkflow ? 'Administration/Workflows' : 'Reports');
			let res  = await CreateSplendidRequest(url + '/Rest.svc/BuildReportSQL', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getReportSQL', json);
			oPreviewSQL = json.d;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.getReportSQL', error);
			this.setState({ error });
		}
		return oPreviewSQL;
	}

	/*
	private ACLFilter = (bUseSQLParameters: boolean, sbJoin: StringBuilder, sbWhere: StringBuilder, sMODULE_NAME: string, sACCESS_TYPE: string, sASSIGNED_USER_ID_Field: string, bIsCaseSignificantDB: boolean) =>
	{
		// 12/07/2006 Paul.  Not all views use ASSIGNED_USER_ID as the assigned field.  Allow an override. 
		// 11/25/2006 Paul.  Administrators should not be restricted from seeing items because of the team rights.
		// This is so that an administrator can fix any record with a bad team value. 
		// 11/27/2009 Paul.  We need a dynamic way to determine if the module record can be assigned or placed in a team. 
		// Teamed and Assigned flags are automatically determined based on the existence of TEAM_ID and ASSIGNED_USER_ID fields. 
		let bModuleIsTeamed       : boolean = Crm_Config.ToBoolean("Modules." + sMODULE_NAME + ".Teamed"  );
		let bModuleIsAssigned     : boolean = Crm_Config.ToBoolean("Modules." + sMODULE_NAME + ".Assigned");
		let bEnableTeamManagement : boolean = Crm_Config.enable_team_management();
		let bRequireTeamManagement: boolean = Crm_Config.require_team_management();
		let bRequireUserAssignment: boolean = Crm_Config.require_user_assignment();
		// 11/27/2009 Paul.  Allow dynamic teams to be turned off. 
		let bEnableDynamicTeams   : boolean = Crm_Config.enable_dynamic_teams();
		// 02/13/2018 Paul.  Allow team hierarchy. 
		let bEnableTeamHierarchy  : boolean = Crm_Config.enable_team_hierarchy();
		let bIsAdmin              : boolean = Security.IS_ADMIN();
		if ( bModuleIsTeamed )
		{
			// 02/10/2008 Kerry.  Remove debug code to force non-admin. 
			if ( bIsAdmin )
				bRequireTeamManagement = false;

			let con: any = null;
			{
				if ( bEnableTeamManagement )
				{
					if ( bEnableDynamicTeams )
					{
						// 08/31/2009 Paul.  Dynamic Teams are handled just like regular teams except using a different view. 
						if ( bRequireTeamManagement )
							sbJoin.Append("       inner ");
						else
							sbJoin.Append("  left outer ");
						// 02/13/2018 Paul.  Allow team hierarchy. 
						if ( !bEnableTeamHierarchy )
						{
							// 11/27/2009 Paul.  Use Sql.MetadataName() so that the view name can exceed 30 characters, but still be truncated for Oracle. 
							// 11/27/2009 Paul.  vwTEAM_SET_MEMBERSHIPS_Security has a distinct clause to reduce duplicate rows. 
							// 12/07/2009 Paul.  Must include the module when referencing the TEAM_SET_ID. 
							// 03/08/2011 Paul.  We need to make sure not to exceed 30 characters in the alias name. 
							sbJoin.AppendLine("join " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_Security") + " " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ControlChars.CrLf);
							sbJoin.AppendLine("               on " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_SET_ID = " + sMODULE_NAME + ".TEAM_SET_ID" + ControlChars.CrLf);
							// 05/05/2010 Paul.  We need to hard-code the value of the MEMBERSHIP_USER_ID as there is no practical way to use a runtime-value. 
							// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
							if ( bUseSQLParameters )
								sbJoin.AppendLine("              and " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_USER_ID     = @MEMBERSHIP_USER_ID" + ControlChars.CrLf);
							else
								sbJoin.AppendLine("              and " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_USER_ID     = '" + Security.USER_ID() + "'" + ControlChars.CrLf);
						}
						else
						{
							if ( Sql.IsOracle(con) )
							{
								sbJoin.AppendLine("join table(" + Sql.MetadataName(con, "fnTEAM_SET_HIERARCHY_MEMBERSHIPS") + "(@MEMBERSHIP_USER_ID))  " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME));
								sbJoin.AppendLine("               on " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_SET_ID = TEAM_SET_ID");
							}
							else
							{
								let fnPrefix: string = (Sql.IsSQLServer(con) ? "dbo." : '');
								sbJoin.AppendLine("join " + fnPrefix + Sql.MetadataName(con, "fnTEAM_SET_HIERARCHY_MEMBERSHIPS") + "(@MEMBERSHIP_USER_ID)  " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME));
								sbJoin.AppendLine("               on " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_SET_ID = TEAM_SET_ID");
							}
						}
					}
					else
					{
						if ( bRequireTeamManagement )
							sbJoin.Append("       inner ");
						else
							sbJoin.Append("  left outer ");
						// 02/13/2018 Paul.  Allow team hierarchy. 
						if ( !bEnableTeamHierarchy )
						{
							// 03/08/2011 Paul.  We need to make sure not to exceed 30 characters in the alias name. 
							sbJoin.AppendLine("join vwTEAM_MEMBERSHIPS  " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME));
							sbJoin.AppendLine("               on " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_ID = " + sMODULE_NAME + ".TEAM_ID");
							// 05/05/2010 Paul.  We need to hard-code the value of the MEMBERSHIP_USER_ID as there is no practical way to use a runtime-value. 
							// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
							if ( bUseSQLParameters )
								sbJoin.AppendLine("              and " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_USER_ID = @MEMBERSHIP_USER_ID");
							else
								sbJoin.AppendLine("              and " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_USER_ID = '" + Security.USER_ID() + "'");
						}
						else
						{
							if ( Sql.IsOracle(con) )
							{
								sbJoin.AppendLine("join table(fnTEAM_HIERARCHY_MEMBERSHIPS(@MEMBERSHIP_USER_ID))  " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME));
								sbJoin.AppendLine("               on " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_ID = TEAM_ID");
							}
							else
							{
								let fnPrefix: string = (Sql.IsSQLServer(con) ? "dbo." : '');
								sbJoin.AppendLine("join " + fnPrefix + "fnTEAM_HIERARCHY_MEMBERSHIPS(@MEMBERSHIP_USER_ID)  " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME));
								sbJoin.AppendLine("               on " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_ID = TEAM_ID");
							}
						}
						//Sql.AddParameter(cmd, "@MEMBERSHIP_USER_ID", Security.USER_ID);
					}
				}

				if ( bEnableTeamManagement && !bRequireTeamManagement && !bIsAdmin )
				{
					// 11/27/2009 Paul.  Dynamic Teams are handled just like regular teams except using a different view. 
					// 03/08/2011 Paul.  We need to make sure not to exceed 30 characters in the alias name. 
					if ( bEnableDynamicTeams )
						sbWhere.AppendLine("   and (" + sMODULE_NAME + ".TEAM_SET_ID is null or " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_SET_ID is not null)");
					else
						sbWhere.AppendLine("   and (" + sMODULE_NAME + ".TEAM_ID is null or " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_ID is not null)");
				}
			}
		}
		if ( bModuleIsAssigned )
		{
			let nACLACCESS: number = Security.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
			// 11/27/2009 Paul.  Make sure owner rule does not apply to admins. 
			if ( nACLACCESS == ACL_ACCESS.OWNER || (bRequireUserAssignment && !bIsAdmin) )
			{
				sASSIGNED_USER_ID_Field = sMODULE_NAME + "." + sASSIGNED_USER_ID_Field;
				let sFieldPlaceholder: string = "MEMBERSHIP_USER_ID";  //Sql.NextPlaceholder(cmd, sASSIGNED_USER_ID_Field);
				// 01/22/2007 Paul.  If ASSIGNED_USER_ID is null, then let everybody see it. 
				// This was added to work around a bug whereby the ASSIGNED_USER_ID was not automatically assigned to the creating user. 
				let bShowUnassigned: boolean = Crm_Config.show_unassigned();
				if ( bShowUnassigned )
				{
					if ( bIsCaseSignificantDB )
						sbWhere.AppendLine("   and (" + sASSIGNED_USER_ID_Field + " is null or upper(" + sASSIGNED_USER_ID_Field + ") = upper(@" + sFieldPlaceholder + "))");
					else
						sbWhere.AppendLine("   and (" + sASSIGNED_USER_ID_Field + " is null or "       + sASSIGNED_USER_ID_Field +  " = @"       + sFieldPlaceholder + ")" );
				}
				else
				{
					if ( bIsCaseSignificantDB )
						sbWhere.AppendLine("   and upper(" + sASSIGNED_USER_ID_Field + ") = upper(@" + sFieldPlaceholder + ")");
					else
						sbWhere.AppendLine("   and "       + sASSIGNED_USER_ID_Field +  " = @"       + sFieldPlaceholder      );
				}
				//Sql.AddParameter(cmd, "@" + sFieldPlaceholder, Security.USER_ID);
			}
		}
	}
	*/

	/*
	// 05/14/2021 Paul.  Convert to static method so that we can use in the React client. 
	public BuildReportSQL = (rdl: any, bPrimaryKeyOnly: boolean, bUseSQLParameters: boolean, bDesignChart: boolean, bUserSpecific: boolean, sBASE_MODULE: string, sBASE_RELATED: string, sbErrors: StringBuilder) =>
	{
		let con          : any     = null;
		let bIsOracle    : boolean = Sql.IsOracle    (con);
		let bIsDB2       : boolean = Sql.IsDB2       (con);
		let bIsMySQL     : boolean = Sql.IsMySQL     (con);
		let bIsPostgreSQL: boolean = Sql.IsPostgreSQL(con);
		
		let sb        : StringBuilder= new StringBuilder();
		let sbACLWhere: StringBuilder = new StringBuilder();
		if ( rdl != null && rdl.DocumentElement != null )
		{
			let sMODULE_TABLE: string = Crm_Config.ToString("Modules." + sBASE_MODULE + ".TableName");
			let nMaxLen: number = Math.max(sMODULE_TABLE.length, 15);
			let hashRequiredModules : any = {};
			let hashAvailableModules: any = {};
			// 02/05/2012 Paul.  Prevent duplicate columns. 
			let hashSelectColumns   : any = {};
			sb.Append("select ");
				
			let bSelectAll: boolean = true;
			// 05/29/2006 Paul.  If the module is used in a filter, then it is required. 
			let xmlDisplayColumns: any = rdl.GetCustomProperty("DisplayColumns");
			let nlFields         : any = xmlDisplayColumns.DocumentElement.SelectNodes("DisplayColumn/Field");
			for ( let xField: any in nlFields )
				nMaxLen = Math.max(nMaxLen, xField.InnerText.length);
				
			// 01/10/2010 Paul.  The ProspectList Dynamic SQL must only return an ID. 
			if ( bPrimaryKeyOnly && !bUseSQLParameters )
			{
				sb.AppendLine(sMODULE_TABLE + ".ID");
			}
			else
			{
				let sFieldSeparator: string = "";
				
				{
					for ( let xField: any in nlFields )
					{
						bSelectAll = false;
						let sMODULE_ALIAS: string = xField.InnerText.split('.')[0];
						if ( !hashRequiredModules.ContainsKey(sMODULE_ALIAS) )
						{
							hashRequiredModules.Add(sMODULE_ALIAS, null);
							// 02/05/2012 Paul.  Don't add the ID if this is a chart. 
							if ( !bDesignChart )
							{
								// 01/18/2012 Paul.  When a new module is encountered, take this opportunity to add a reference to the ID. 
								// 01/18/2012 Paul.  ReportViewer is not able to convert a Guid to a text string, so do it manually. 
								if ( Sql.IsSQLServer(con) || Sql.IsSybase(con) || Sql.IsSqlAnywhere(con) || Sql.IsEffiProz(con) )
								{
									let sIDField: string = "cast(" + sMODULE_ALIAS + ".ID as char(36))";
									sb.Append(sFieldSeparator + sIDField);
									if ( nMaxLen - sIDField.length > 0 )
										sb.Append(Sql.Space(nMaxLen - sIDField.length));
								}
								else
								{
									sb.Append(sFieldSeparator + sMODULE_ALIAS + ".ID");
									sb.Append(Sql.Space(nMaxLen - (sMODULE_ALIAS + ".ID").length));
								}
								sb.Append(" as \"" + Sql.MetadataName(con, sMODULE_ALIAS + ".ID") + "\"");
								sb.AppendLine();
								sFieldSeparator = "     , ";
							}
						}
						// 02/05/2012 Paul.  Prevent duplicate columns. 
						if ( !hashSelectColumns.ContainsKey(xField.InnerText) )
						{
							sb.Append(sFieldSeparator + xField.InnerText);
							sb.Append(Sql.Space(nMaxLen - xField.InnerText.length));
							// 03/08/2011 Paul.  We need to make sure not to exceed 30 characters in the alias name. 
							sb.Append(" as \"" + Sql.MetadataName(con, xField.InnerText) + "\"");
							sb.AppendLine();
							sFieldSeparator = "     , ";
							hashSelectColumns.Add(xField.InnerText, null);
						}
					}
					if ( bSelectAll )
					{
						sb.AppendLine("*");
					}
				}
			}
				
			// 05/29/2006 Paul.  If the module is used in a filter, then it is required. 
			let xmlFilters: any = rdl.GetCustomProperty("Filters");
			let nlFilters : any = xmlFilters.DocumentElement.SelectNodes("Filter");
			let xFilter   : any = null;
			for (xFilter in nlFilters )
			{
				let sDATA_FIELD  : null= XmlUtil.SelectSingleNode(xFilter, "DATA_FIELD");
				let sMODULE_ALIAS: null = sDATA_FIELD.split('.')[0];
				if ( !hashRequiredModules.ContainsKey(sMODULE_ALIAS) )
					hashRequiredModules.Add(sMODULE_ALIAS, null);
			}

			if ( hashRequiredModules.ContainsKey(sMODULE_TABLE) )
				hashRequiredModules.Remove(sMODULE_TABLE);
				
			sb.AppendLine("  from            vw" + sMODULE_TABLE + " " + Sql.Space(nMaxLen - sMODULE_TABLE.length) + sMODULE_TABLE);
			// 01/10/2010 Paul.  The Compaigns module will not need user-specific filtering. 
			if ( bUserSpecific || bUseSQLParameters )
			{
				// 04/17/2007 Paul.  Apply ACL rules. 
				if ( sMODULE_TABLE != "USERS" )
					this.ACLFilter(bUseSQLParameters, sb, sbACLWhere, sMODULE_TABLE, "list", "ASSIGNED_USER_ID", bIsOracle || bIsDB2);
			}
			hashAvailableModules.Add(sMODULE_TABLE, sMODULE_TABLE);
			if ( !Sql.IsEmptyString(sBASE_RELATED) )
			{
				let xmlRelatedModules : any    = rdl.GetCustomProperty("RelatedModules");
				let sRELATED          : string = sBASE_RELATED.split(' ')[0];
				let sRELATED_ALIAS    : string = sBASE_RELATED.split(' ')[1];
				// 10/26/2011 Paul.  Add the relationship so that we can have a unique lookup. 
				let sRELATIONSHIP_NAME: string = sBASE_RELATED.split(' ')[2];
					
				if ( hashRequiredModules.ContainsKey(sRELATED_ALIAS) )
					hashRequiredModules.Remove(sRELATED_ALIAS);

				// 10/26/2011 Paul.  Add the relationship so that we can have a unique lookup. 
				let xRelationship: any = xmlRelatedModules.DocumentElement.SelectSingleNode("Relationship[RELATIONSHIP_NAME=\'" + sRELATIONSHIP_NAME + "\']");
				if ( xRelationship != null )
				{
					sRELATIONSHIP_NAME                     = XmlUtil.SelectSingleNode(xRelationship, "RELATIONSHIP_NAME"             );
					//let sLHS_MODULE                    : string = XmlUtil.SelectSingleNode(xRelationship, "LHS_MODULE"                    );
					let sLHS_TABLE                     : string = XmlUtil.SelectSingleNode(xRelationship, "LHS_TABLE"                     );
					let sLHS_KEY                       : string = XmlUtil.SelectSingleNode(xRelationship, "LHS_KEY"                       );
					//let sRHS_MODULE                    : string = XmlUtil.SelectSingleNode(xRelationship, "RHS_MODULE"                    );
					let sRHS_TABLE                     : string = XmlUtil.SelectSingleNode(xRelationship, "RHS_TABLE"                     );
					let sRHS_KEY                       : string = XmlUtil.SelectSingleNode(xRelationship, "RHS_KEY"                       );
					let sJOIN_TABLE                    : string = XmlUtil.SelectSingleNode(xRelationship, "JOIN_TABLE"                    );
					let sJOIN_KEY_LHS                  : string = XmlUtil.SelectSingleNode(xRelationship, "JOIN_KEY_LHS"                  );
					let sJOIN_KEY_RHS                  : string = XmlUtil.SelectSingleNode(xRelationship, "JOIN_KEY_RHS"                  );
					// 11/20/2008 Paul.  Quotes, Orders and Invoices have a relationship column. 
					let sRELATIONSHIP_ROLE_COLUMN      : string = XmlUtil.SelectSingleNode(xRelationship, "RELATIONSHIP_ROLE_COLUMN"      );
					let sRELATIONSHIP_ROLE_COLUMN_VALUE: string = XmlUtil.SelectSingleNode(xRelationship, "RELATIONSHIP_ROLE_COLUMN_VALUE");
					if ( Sql.IsEmptyString(sJOIN_TABLE) )
					{
						nMaxLen = Math.max(nMaxLen, sRHS_TABLE.length + sRHS_KEY.length + 1);
						sb.AppendLine("       inner join vw" + sRHS_TABLE + " "            + Sql.Space(nMaxLen - sRHS_TABLE.length                      ) + sRHS_TABLE);
						sb.AppendLine("               on "   + sRHS_TABLE + "." + sRHS_KEY + Sql.Space(nMaxLen - sRHS_TABLE.length - sRHS_KEY.length - 1) + " = " + sLHS_TABLE + "." + sLHS_KEY);
						// 05/05/2010 Paul.  The Compaigns module will not need user-specific filtering. 
						if ( bUserSpecific || bUseSQLParameters )
						{
							// 04/17/2007 Paul.  Apply ACL rules. 
							if ( sRHS_TABLE != "USERS" )
								this.ACLFilter(bUseSQLParameters, sb, sbACLWhere, sRHS_TABLE, "list", "ASSIGNED_USER_ID", bIsOracle || bIsDB2);
						}
					}
					else
					{
						nMaxLen = Math.max(nMaxLen, sJOIN_TABLE.length + sJOIN_KEY_LHS.length + 1);
						nMaxLen = Math.max(nMaxLen, sRHS_TABLE.length + sRHS_KEY.length      + 1);
						sb.AppendLine("       inner join vw" + sJOIN_TABLE + " "                 + Sql.Space(nMaxLen - sJOIN_TABLE.length                           ) + sJOIN_TABLE);
						sb.AppendLine("               on "   + sJOIN_TABLE + "." + sJOIN_KEY_LHS + Sql.Space(nMaxLen - sJOIN_TABLE.length - sJOIN_KEY_LHS.length - 1) + " = " + sLHS_TABLE  + "." + sLHS_KEY     );
						// 10/31/2009 Paul.  The value should be escaped. 
						if ( !Sql.IsEmptyString(sRELATIONSHIP_ROLE_COLUMN) && !Sql.IsEmptyString(sRELATIONSHIP_ROLE_COLUMN_VALUE) )
							sb.AppendLine("              and "   + sJOIN_TABLE + "." + sRELATIONSHIP_ROLE_COLUMN + " = N'" + Sql.EscapeSQL(sRELATIONSHIP_ROLE_COLUMN_VALUE) + "'");
						sb.AppendLine("       inner join vw" + sRHS_TABLE + " "                  + Sql.Space(nMaxLen - sRHS_TABLE.length                            ) + sRHS_TABLE);
						sb.AppendLine("               on "   + sRHS_TABLE + "." + sRHS_KEY       + Sql.Space(nMaxLen - sRHS_TABLE.length - sRHS_KEY.length - 1      ) + " = " + sJOIN_TABLE + "." + sJOIN_KEY_RHS);
						// 05/05/2010 Paul.  The Compaigns module will not need user-specific filtering. 
						if ( bUserSpecific || bUseSQLParameters )
						{
							// 04/17/2007 Paul.  Apply ACL rules. 
							if ( sRHS_TABLE != "USERS" )
								this.ACLFilter(bUseSQLParameters, sb, sbACLWhere, sRHS_TABLE, "list", "ASSIGNED_USER_ID", bIsOracle || bIsDB2);
						}
					}
					if ( !hashAvailableModules.ContainsKey(sRHS_TABLE) )
						hashAvailableModules.Add(sRHS_TABLE, sRHS_TABLE);
				}
			}
			if ( hashRequiredModules.Count > 0 )
			{
				let xmlRelationships: any = rdl.GetCustomProperty("Relationships");
				for ( let sMODULE_ALIAS: string in hashRequiredModules.Keys )
				{
					let xRelationship: any = xmlRelationships.DocumentElement.SelectSingleNode("Relationship[MODULE_ALIAS=\'" + sMODULE_ALIAS + "\']");
					if ( xRelationship != null )
					{
						let sRELATIONSHIP_NAME: string = XmlUtil.SelectSingleNode(xRelationship, "RELATIONSHIP_NAME");
						//let sLHS_MODULE       : string = XmlUtil.SelectSingleNode(xRelationship, "LHS_MODULE"       );
						let sLHS_TABLE        : string = XmlUtil.SelectSingleNode(xRelationship, "LHS_TABLE"        );
						let sLHS_KEY          : string = XmlUtil.SelectSingleNode(xRelationship, "LHS_KEY"          );
						//let sRHS_MODULE       : string = XmlUtil.SelectSingleNode(xRelationship, "RHS_MODULE"       );
						let sRHS_TABLE        : string = XmlUtil.SelectSingleNode(xRelationship, "RHS_TABLE"        );
						let sRHS_KEY          : string = XmlUtil.SelectSingleNode(xRelationship, "RHS_KEY"          );
						nMaxLen = Math.max(nMaxLen, sLHS_TABLE.length );
						nMaxLen = Math.max(nMaxLen, sMODULE_ALIAS.length + sLHS_KEY.length + 1);
						sb.AppendLine("  left outer join vw" + sLHS_TABLE + " "               + Sql.Space(nMaxLen - sLHS_TABLE.length                        ) + sMODULE_ALIAS);
						sb.AppendLine("               on "   + sMODULE_ALIAS + "." + sLHS_KEY + Sql.Space(nMaxLen - sMODULE_ALIAS.length - sLHS_KEY.length - 1) + " = " + sRHS_TABLE + "." + sRHS_KEY);
						// 05/05/2010 Paul.  The Compaigns module will not need user-specific filtering. 
						if ( bUserSpecific || bUseSQLParameters )
						{
							// 04/17/2007 Paul.  Apply ACL rules. 
							if ( sLHS_TABLE != "USERS" )
								this.ACLFilter(bUseSQLParameters, sb, sbACLWhere, sMODULE_ALIAS, "list", "ASSIGNED_USER_ID", bIsOracle || bIsDB2);
						}
						// 07/13/2006 Paul.  The key needs to be the alias, and the value is the main table. 
						// This is because the same table may be referenced more than once, 
						// such as the Users table to display the last modified user and the assigned to user. 
						if ( !hashAvailableModules.ContainsKey(sMODULE_ALIAS) )
							hashAvailableModules.Add(sMODULE_ALIAS, sLHS_TABLE);
					}
				}
			}
			sb.AppendLine(" where 1 = 1");
			sb.Append(sbACLWhere.toString());
			try
			{
				rdl.SetSingleNode("DataSets/DataSet/Query/QueryParameters", '');
				let xQueryParameters: any = rdl.SelectNode("DataSets/DataSet/Query/QueryParameters");
				xQueryParameters.RemoveAll();
				if ( xmlFilters.DocumentElement != null )
				{
					let nParameterIndex: number = 0;
					// 10/25/2014 Paul.  Filters that use NOT should protect against NULL values. 
					// 10/25/2014 Paul.  Coalesce works across all database platforms, so use instead of isnull. 
					let sISNULL: string = "coalesce";
					//if ( bIsOracle )
					//	sISNULL = "nvl";
					//else if ( bIsMySQL || bIsDB2 )
					//	sISNULL = "ifnull";
					//else if ( bIsPostgreSQL )
					//	sISNULL = "coalesce";
					for ( let xFilter: any in xmlFilters.DocumentElement )
					{
						let sMODULE_NAME   : string = XmlUtil.SelectSingleNode(xFilter, "MODULE_NAME");
						let sDATA_FIELD    : string = XmlUtil.SelectSingleNode(xFilter, "DATA_FIELD" );
						let sDATA_TYPE     : string = XmlUtil.SelectSingleNode(xFilter, "DATA_TYPE"  );
						let sOPERATOR      : string = XmlUtil.SelectSingleNode(xFilter, "OPERATOR"   );
						// 07/04/2006 Paul.  We need to use the parameter index in the parameter name 
						// because a parameter can be used more than once and we need a unique name. 
						let sPARAMETER_NAME: string = RdlDocument.RdlParameterName(sDATA_FIELD, nParameterIndex, false);
						let sSECONDARY_NAME: string = RdlDocument.RdlParameterName(sDATA_FIELD, nParameterIndex, true );
						let sSEARCH_TEXT1  : string = '';
						let sSEARCH_TEXT2  : string = '';
						// 03/14/2011 Paul.  Oracle does not like parameter names longer than 30 characters. 
						if ( bIsOracle && (sPARAMETER_NAME.length > 30 || sSECONDARY_NAME.length > 30) )
						{
							sPARAMETER_NAME = "@PARAMETER__" + nParameterIndex.toString("00") + "A";
							sSECONDARY_NAME = "@PARAMETER__" + nParameterIndex.toString("00") + "B";
						}
						
						let nlValues: any[] = xFilter.SelectNodes("SEARCH_TEXT_VALUES");
						let arrSEARCH_TEXT: string[] = [nlValues.length];
						let i: number = 0;
						for ( let xValue: any in nlValues )
						{
							arrSEARCH_TEXT[i++] = xValue.InnerText;
						}
						if ( arrSEARCH_TEXT.length > 0 )
							sSEARCH_TEXT1 = arrSEARCH_TEXT[0];
						if ( arrSEARCH_TEXT.length > 1 )
							sSEARCH_TEXT2 = arrSEARCH_TEXT[1];

						let sSQL: string = '';
						// 07/09/2007 Paul.  ansistring is treated the same as string. 
						let sCOMMON_DATA_TYPE: string = sDATA_TYPE;
						if ( sCOMMON_DATA_TYPE == "ansistring" )
							sCOMMON_DATA_TYPE = "string";
						switch ( sCOMMON_DATA_TYPE )
						{
							case "string":
							{
								// 07/16/2006 Paul.  Oracle and DB2 are case-significant.  Keep SQL Server code fast by not converting to uppercase. 
								if ( bIsOracle || bIsDB2 )
								{
									sSEARCH_TEXT1 = sSEARCH_TEXT1.toUpperCase();
									sSEARCH_TEXT2 = sSEARCH_TEXT2.toUpperCase();
									sDATA_FIELD   = "upper(" + sDATA_FIELD + ")";
								}
								// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
								// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
								if ( StartsWith(sSEARCH_TEXT1, "=") )
								{
									// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
									var sCAT_SEP = (bIsOracle ? " || " : " + ");
									sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.substr(1, sSEARCH_TEXT1.length - 1));
									switch ( sOPERATOR )
									{
										case "equals"         :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
										case "less"           :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
										case "less_equal"     :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sSEARCH_TEXT1);  break;
										case "greater"        :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
										case "greater_equal"  :  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sSEARCH_TEXT1);  break;
										case "contains"       :  sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
										case "starts_with"    :  sb.AppendLine("   and " + sDATA_FIELD + " like " +                     sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
										case "ends_with"      :  sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1);  break;
										case "like"           :  sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
										case "empty"          :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty"      :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										// 10/25/2014 Paul.  Filters that use NOT should protect against NULL values. 
										case "not_equals_str" :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " <> "   + sSEARCH_TEXT1);  break;
										case "not_contains"   :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
										case "not_starts_with":  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " +                     sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
										case "not_ends_with"  :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1);  break;
										case "not_like"       :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
									}
								}
								else if ( bUseSQLParameters )
								{
									switch ( sOPERATOR )
									{
										case "equals"        :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										// 07/23/2013 Paul.  Add greater and less than conditions. 
										case "less"          :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "less_equal"    :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "greater"       :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "greater_equal" :  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "contains"      :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
											sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
											// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
											break;
										case "starts_with"   :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
											sSQL =       Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
											// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
											break;
										case "ends_with"     :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
											sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1)      ;
											// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
											break;
										// 02/14/2013 Paul.  A customer wants to use like in string filters. 
										case "like"          :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
											sSQL = sSEARCH_TEXT1;
											// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
											break;
										case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										// 08/25/2011 Paul.  A customer wants more use of NOT in string filters. 
											// 10/25/2014 Paul.  Filters that use NOT should protect against NULL values. 
										case "not_equals_str"    :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " <> "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "not_contains"      :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
											sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
											// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
											break;
										case "not_starts_with"   :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
											sSQL =       Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
											// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
											break;
										case "not_ends_with"     :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
											sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1)      ;
											// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
											break;
										case "not_like"          :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
											sSQL = sSEARCH_TEXT1;
											// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
											break;
									}
								}
								else
								{
									switch ( sOPERATOR )
									{
										case "equals"        :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
										// 07/23/2013 Paul.  Add greater and less than conditions. 
										case "less"          :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
										case "less_equal"    :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
										case "greater"       :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
										case "greater_equal" :  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
										case "contains"      :
											sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
											// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											break;
										case "starts_with"   :
											sSQL =       Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
											// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											break;
										case "ends_with"     :
											sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1)      ;
											// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											break;
										// 02/14/2013 Paul.  A customer wants to use like in string filters. 
										case "like"          :
											sSQL = sSEARCH_TEXT1;
											// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											break;
										case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										case "not_equals_str":
											sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " <> "   + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");
											break;
										// 08/25/2011 Paul.  A customer wants more use of NOT in string filters. 
										case "not_contains"      :
											sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
											// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											break;
										case "not_starts_with"   :
											sSQL =       Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
											// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											break;
										case "not_ends_with"     :
											sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1)      ;
											// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											break;
										case "not_like"      :
											sSQL = sSEARCH_TEXT1;
											// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											break;
									}
								}
								break;
							}
							case "datetime":
							{
								let fnPrefix: string = "dbo.";
								if ( bIsOracle || bIsDB2 || bIsMySQL || bIsPostgreSQL )
								{
									fnPrefix = "";
								}
								// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
								// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
								if ( StartsWith(sSEARCH_TEXT1, "=") )
								{
									// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
									var sCAT_SEP = (bIsOracle ? " || " : " + ");
									sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.substr(1, sSEARCH_TEXT1.length - 1));
									if ( StartsWith(sSEARCH_TEXT2, "=") )
										sSEARCH_TEXT2 = RdlUtil.ReportColumnName(sSEARCH_TEXT2.substr(1, sSEARCH_TEXT2.length - 1));
									switch ( sOPERATOR )
									{
										case "on"               :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = "  + sSEARCH_TEXT1);  break;
										case "before"           :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") < "  + sSEARCH_TEXT1);  break;
										case "after"            :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") > "  + sSEARCH_TEXT1);  break;
										case "not_equals_str"   :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") <> " + sSEARCH_TEXT1);  break;
										case "between_dates"    :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
										case "tp_days_after"    :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('day', "    +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
										case "tp_weeks_after"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('week', "   +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
										case "tp_months_after"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('month', "  +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
										case "tp_years_after"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('year', "   +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
										case "tp_days_before"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('day', "    + "-" + sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
										case "tp_weeks_before"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('week', "   + "-" + sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
										case "tp_months_before" :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('month', "  + "-" + sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
										case "tp_years_before"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('year', "   + "-" + sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
										case "tp_minutes_after" :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('minute', " +       sSEARCH_TEXT1        + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('minute', " + "1+" + sSEARCH_TEXT1 + ", " + sDATA_FIELD + ")");  break;
										case "tp_hours_after"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('hour', "   +       sSEARCH_TEXT1        + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('hour', "   + "1+" + sSEARCH_TEXT1 + ", " + sDATA_FIELD + ")");  break;
										case "tp_minutes_before":  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('minute', " + "-" + sSEARCH_TEXT1 + "-1" + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('minute', " + "-"  + sSEARCH_TEXT1 + ", " + sDATA_FIELD + ")");  break;
										case "tp_hours_before"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('hour', "   + "-" + sSEARCH_TEXT1 + "-1" + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('hour', "   + "-"  + sSEARCH_TEXT1 + ", " + sDATA_FIELD + ")");  break;
										case "tp_days_old"      :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('day', "    +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
										case "tp_weeks_old"     :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('week', "   +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
										case "tp_months_old"    :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('month', "  +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
										case "tp_years_old"     :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('year', "   +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
									}
								}
								else if ( bUseSQLParameters )
								{
									if ( arrSEARCH_TEXT.length > 0 )
									{
										//CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat
										let dtSEARCH_TEXT1: Date = null;
										let dtSEARCH_TEXT2: Date = null;
										let nINTERVAL     : number = 0;
										// 11/16/2008 Paul.  Days old. 
										if ( !(EndsWith(sOPERATOR, "_after") || EndsWith(sOPERATOR, "_before") || EndsWith(sOPERATOR, "_old")) )
										{
											dtSEARCH_TEXT1 = DateTime.ParseExact(sSEARCH_TEXT1, "yyyy/MM/dd");
											dtSEARCH_TEXT2 = null;
											if ( arrSEARCH_TEXT.length > 1 )
												dtSEARCH_TEXT2 = DateTime.ParseExact(sSEARCH_TEXT2, "yyyy/MM/dd");
										}
										else
										{
											nINTERVAL = Sql.ToInteger(sSEARCH_TEXT1);
										}
										switch ( sOPERATOR )
										{
											case "on"               :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = "  + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1);  break;
											case "before"           :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") < "  + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1);  break;
											case "after"            :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") > "  + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1);  break;
											case "not_equals_str"   :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") <> " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1);  break;
											case "between_dates"    :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sPARAMETER_NAME + " and " + sSECONDARY_NAME);
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, dtSEARCH_TEXT1.ToShortDateString());
												rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, dtSEARCH_TEXT2.ToShortDateString());
												break;
											// 11/16/2008 Paul.  Days old. 
											case "tp_days_after"    :  sb.AppendLine("   and " + sPARAMETER_NAME + " > "       + fnPrefix + "fnDateAdd('day', "    +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_weeks_after"   :  sb.AppendLine("   and " + sPARAMETER_NAME + " > "       + fnPrefix + "fnDateAdd('week', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_months_after"  :  sb.AppendLine("   and " + sPARAMETER_NAME + " > "       + fnPrefix + "fnDateAdd('month', "  +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_years_after"   :  sb.AppendLine("   and " + sPARAMETER_NAME + " > "       + fnPrefix + "fnDateAdd('year', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_days_before"   :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('day', "    + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_weeks_before"  :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('week', "   + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_months_before" :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('month', "  + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_years_before"  :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('year', "   + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_minutes_after" :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('minute', " +   nINTERVAL   .ToString() + ", " + sDATA_FIELD + "                            ) and " + fnPrefix + "fnDateAdd('minute', " + (1+nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "GETDATE()");  break;
											case "tp_hours_after"   :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('hour', "   +   nINTERVAL   .ToString() + ", " + sDATA_FIELD + "                            ) and " + fnPrefix + "fnDateAdd('hour', "   + (1+nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "GETDATE()");  break;
											case "tp_minutes_before":  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('minute', " + (-nINTERVAL-1).ToString() + ", " + sDATA_FIELD + "                            ) and " + fnPrefix + "fnDateAdd('minute', " +  (-nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "GETDATE()");  break;
											case "tp_hours_before"  :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('hour', "   + (-nINTERVAL-1).ToString() + ", " + sDATA_FIELD + "                            ) and " + fnPrefix + "fnDateAdd('hour', "   +  (-nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "GETDATE()");  break;
											// 12/04/2008 Paul.  We need to be able to do an an equals. 
											case "tp_days_old"      :  sb.AppendLine("   and " + sPARAMETER_NAME + " = "       + fnPrefix + "fnDateAdd('day', "    +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_weeks_old"     :  sb.AppendLine("   and " + sPARAMETER_NAME + " = "       + fnPrefix + "fnDateAdd('week', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_months_old"    :  sb.AppendLine("   and " + sPARAMETER_NAME + " = "       + fnPrefix + "fnDateAdd('month', "  +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_years_old"     :  sb.AppendLine("   and " + sPARAMETER_NAME + " = "       + fnPrefix + "fnDateAdd('year', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
										}
									}
									else
									{
										switch ( sOPERATOR )
										{
											case "empty"          :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"      :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											case "is_before"      :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") < " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "is_after"       :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") > " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_yesterday"   :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "DATEADD(DAY, -1, TODAY())");  break;
											case "tp_today"       :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											case "tp_tomorrow"    :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "DATEADD(DAY, 1, TODAY())");  break;
											case "tp_last_7_days" :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sPARAMETER_NAME + " and " + sSECONDARY_NAME);
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "DATEADD(DAY, -7, TODAY())");
												rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "TODAY()");
												break;
											case "tp_next_7_days" :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sPARAMETER_NAME + " and " + sSECONDARY_NAME);
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");
												rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "DATEADD(DAY, 7, TODAY())");
												break;
											// 07/05/2006 Paul.  Month math must also include the year. 
											case "tp_last_month"  :  sb.AppendLine("   and month(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);
													                    sb.AppendLine("   and year("  + sDATA_FIELD + ") = " + sSECONDARY_NAME);
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "MONTH(DATEADD(MONTH, -1, TODAY()))");
												rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "YEAR(DATEADD(MONTH, -1, TODAY()))");
												break;
											case "tp_this_month"  :  sb.AppendLine("   and month(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);
													                    sb.AppendLine("   and year("  + sDATA_FIELD + ") = " + sSECONDARY_NAME);
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "MONTH(TODAY())");
												rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "YEAR(TODAY())");
												break;
											case "tp_next_month"  :  sb.AppendLine("   and month(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);
													                    sb.AppendLine("   and year("  + sDATA_FIELD + ") = " + sSECONDARY_NAME);
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "MONTH(DATEADD(MONTH, 1, TODAY()))");
												rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "YEAR(DATEADD(MONTH, 1, TODAY()))");
												break;
											case "tp_last_30_days":  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sPARAMETER_NAME + " and " + sSECONDARY_NAME);
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "DATEADD(DAY, -30, TODAY())");
												rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "TODAY()");
												break;
											case "tp_next_30_days":  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sPARAMETER_NAME + " and " + sSECONDARY_NAME);
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");
												rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "DATEADD(DAY, 30, TODAY())");
												break;
											case "tp_last_year"   :  sb.AppendLine("   and year(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "YEAR(DATEADD(YEAR, -1, TODAY()))");  break;
											case "tp_this_year"   :  sb.AppendLine("   and year(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "YEAR(TODAY())");  break;
											case "tp_next_year"   :  sb.AppendLine("   and year(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "YEAR(DATEADD(YEAR, 1, TODAY()))");  break;
										}
									}
								}
								else
								{
									if ( arrSEARCH_TEXT.length > 0 )
									{
										//CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat
										let dtSEARCH_TEXT1: Date = null;
										let dtSEARCH_TEXT2: Date = null;
										let nINTERVAL     : number = 0;
										// 11/16/2008 Paul.  Days old. 
										if ( !(EndsWith(sOPERATOR, "_after") || EndsWith(sOPERATOR, "_before") || EndsWith(sOPERATOR, "_old")) )
										{
											dtSEARCH_TEXT1 = DateTime.ParseExact(sSEARCH_TEXT1, "yyyy/MM/dd");
											dtSEARCH_TEXT2 = null;
											if ( arrSEARCH_TEXT.length > 1 )
											{
												dtSEARCH_TEXT2 = DateTime.ParseExact(sSEARCH_TEXT2, "yyyy/MM/dd");
												if ( bIsOracle )
													sSEARCH_TEXT2 = "to_date('" + dtSEARCH_TEXT2.ToString("yyyy-MM-dd") + "','YYYY-MM-DD')";
												else
													sSEARCH_TEXT2 = "'" + dtSEARCH_TEXT2.ToString("yyyy/MM/dd") + "'";
											}
											if ( bIsOracle )
												sSEARCH_TEXT1 = "to_date('" + dtSEARCH_TEXT1.ToString("yyyy-MM-dd") + "','YYYY-MM-DD')";
											else
												sSEARCH_TEXT1 = "'" + dtSEARCH_TEXT1.ToString("yyyy/MM/dd") + "'";
										}
										else
										{
											nINTERVAL = Sql.ToInteger(sSEARCH_TEXT1);
										}
										switch ( sOPERATOR )
										{
											case "on"               :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = "  + sSEARCH_TEXT1);  break;
											case "before"           :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") < "  + sSEARCH_TEXT1);  break;
											case "after"            :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") > "  + sSEARCH_TEXT1);  break;
											case "not_equals_str"   :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") <> " + sSEARCH_TEXT1);  break;
											case "between_dates"    :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
											// 11/16/2008 Paul.  Days old. 
											case "tp_days_after"    :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('day', "    +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_weeks_after"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('week', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_months_after"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('month', "  +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_years_after"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('year', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_days_before"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('day', "    + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
											case "tp_weeks_before"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('week', "   + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
											case "tp_months_before" :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('month', "  + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
											case "tp_years_before"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('year', "   + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
											case "tp_minutes_after" :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('minute', " +   nINTERVAL   .ToString() + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('minute', " + (1+nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  break;
											case "tp_hours_after"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('hour', "   +   nINTERVAL   .ToString() + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('hour', "   + (1+nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  break;
											case "tp_minutes_before":  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('minute', " + (-nINTERVAL-1).ToString() + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('minute', " +  (-nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  break;
											case "tp_hours_before"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('hour', "   + (-nINTERVAL-1).ToString() + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('hour', "   +  (-nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  break;
											// 12/04/2008 Paul.  We need to be able to do an an equals. 
											case "tp_days_old"      :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('day', "    +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_weeks_old"     :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('week', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_months_old"    :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('month', "  +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_years_old"     :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('year', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
										}
									}
									else
									{
										switch ( sOPERATOR )
										{
											case "empty"            :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"        :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											case "is_before"        :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") < " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"                  ));  break;
											case "is_after"         :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") > " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"                  ));  break;
											case "tp_yesterday"     :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "DATEADD(DAY, -1, TODAY())"));  break;
											case "tp_today"         :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"                  ));  break;
											case "tp_tomorrow"      :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "DATEADD(DAY, 1, TODAY())" ));  break;
											case "tp_last_7_days"   :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + RdlDocument.DbSpecificDate(sSplendidProvider, "DATEADD(DAY, -7, TODAY())") + " and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"));
												break;
											case "tp_next_7_days"   :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()" ) + " and " + RdlDocument.DbSpecificDate(sSplendidProvider, "DATEADD(DAY, 7, TODAY())"));
												break;
											// 07/05/2006 Paul.  Month math must also include the year. 
											case "tp_last_month"    :  sb.AppendLine("   and month(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "MONTH(DATEADD(MONTH, -1, TODAY()))"));
													                    sb.AppendLine("   and year("  + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "YEAR(DATEADD(MONTH, -1, TODAY()))" ));
												break;
											case "tp_this_month"    :  sb.AppendLine("   and month(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "MONTH(TODAY())"));
													                    sb.AppendLine("   and year("  + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "YEAR(TODAY())" ));
												break;
											case "tp_next_month"    :  sb.AppendLine("   and month(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "MONTH(DATEADD(MONTH, 1, TODAY()))"));
													                    sb.AppendLine("   and year("  + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "YEAR(DATEADD(MONTH, 1, TODAY()))" ));
												break;
											case "tp_last_30_days"  :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + RdlDocument.DbSpecificDate(sSplendidProvider, "DATEADD(DAY, -30, TODAY())") + " and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"));
												break;
											case "tp_next_30_days"  :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()") + " and " + RdlDocument.DbSpecificDate(sSplendidProvider, "DATEADD(DAY, 30, TODAY())"));
												break;
											case "tp_last_year"     :  sb.AppendLine("   and year(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "YEAR(DATEADD(YEAR, -1, TODAY()))"));  break;
											case "tp_this_year"     :  sb.AppendLine("   and year(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "YEAR(TODAY())"                   ));  break;
											case "tp_next_year"     :  sb.AppendLine("   and year(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "YEAR(DATEADD(YEAR, 1, TODAY()))" ));  break;
										}
									}
								}
								break;
							}
							case "int32":
							{
								// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
								// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
								if ( StartsWith(sSEARCH_TEXT1, "=") )
								{
									// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
									var sCAT_SEP = (bIsOracle ? " || " : " + ");
									sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.substr(1, sSEARCH_TEXT1.length - 1));
									if ( StartsWith(sSEARCH_TEXT2, "=") )
										sSEARCH_TEXT2 = RdlUtil.ReportColumnName(sSEARCH_TEXT2.substr(1, sSEARCH_TEXT2.length - 1));
									switch ( sOPERATOR )
									{
										case "equals"       :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
										case "less"         :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
										case "greater"      :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
										case "not_equals"   :  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
										case "between"      :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
										case "empty"        :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty"    :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "    + sSEARCH_TEXT1);  break;
										case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "    + sSEARCH_TEXT1);  break;
									}
								}
								else if ( bUseSQLParameters )
								{
									switch ( sOPERATOR )
									{
										case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "less"      :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "greater"   :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "not_equals":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "between"   :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sPARAMETER_NAME + "1 and " + sPARAMETER_NAME + "2");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1, sSEARCH_TEXT2);  break;
										case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										// 07/23/2013 Paul.  Add greater and less than conditions. 
										case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
									}
								}
								else
								{
									sSEARCH_TEXT1 = Sql.ToInteger(sSEARCH_TEXT1).ToString();
									sSEARCH_TEXT2 = Sql.ToInteger(sSEARCH_TEXT2).ToString();
									switch ( sOPERATOR )
									{
										case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
										case "less"      :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
										case "greater"   :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
										case "not_equals":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
										case "between"   :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
										case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										// 07/23/2013 Paul.  Add greater and less than conditions. 
										case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sSEARCH_TEXT1);  break;
										case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sSEARCH_TEXT1);  break;
									}
								}
								break;
							}
							case "decimal":
							{
								// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
								// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
								if ( StartsWith(sSEARCH_TEXT1, "=") )
								{
									// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
									var sCAT_SEP = (bIsOracle ? " || " : " + ");
									sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.substr(1, sSEARCH_TEXT1.length - 1));
									if ( StartsWith(sSEARCH_TEXT2, "=") )
										sSEARCH_TEXT2 = RdlUtil.ReportColumnName(sSEARCH_TEXT2.substr(1, sSEARCH_TEXT2.length - 1));
									switch ( sOPERATOR )
									{
										case "equals"       :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
										case "less"         :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
										case "greater"      :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
										case "not_equals"   :  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
										case "between"      :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
										case "empty"        :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty"    :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "    + sSEARCH_TEXT1);  break;
										case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "    + sSEARCH_TEXT1);  break;
									}
								}
								else if ( bUseSQLParameters )
								{
									switch ( sOPERATOR )
									{
										case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "less"      :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "greater"   :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "not_equals":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "between"   :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sPARAMETER_NAME + "1 and " + sPARAMETER_NAME + "2");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1, sSEARCH_TEXT2);  break;
										case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										// 07/23/2013 Paul.  Add greater and less than conditions. 
										case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
									}
								}
								else
								{
									sSEARCH_TEXT1 = Sql.ToDecimal(sSEARCH_TEXT1).ToString();
									sSEARCH_TEXT2 = Sql.ToDecimal(sSEARCH_TEXT2).ToString();
									switch ( sOPERATOR )
									{
										case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
										case "less"      :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
										case "greater"   :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
										case "not_equals":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
										case "between"   :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
										case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										// 07/23/2013 Paul.  Add greater and less than conditions. 
										case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sSEARCH_TEXT1);  break;
										case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sSEARCH_TEXT1);  break;
									}
								}
								break;
							}
							case "float":
							{
								// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
								// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
								if ( StartsWith(sSEARCH_TEXT1, "=") )
								{
									// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
									var sCAT_SEP = (bIsOracle ? " || " : " + ");
									sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.substr(1, sSEARCH_TEXT1.length - 1));
									if ( StartsWith(sSEARCH_TEXT2, "=") )
										sSEARCH_TEXT2 = RdlUtil.ReportColumnName(sSEARCH_TEXT2.substr(1, sSEARCH_TEXT2.length - 1));
									switch ( sOPERATOR )
									{
										case "equals"       :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
										case "less"         :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
										case "greater"      :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
										case "not_equals"   :  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
										case "between"      :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
										case "empty"        :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty"    :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "    + sSEARCH_TEXT1);  break;
										case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "    + sSEARCH_TEXT1);  break;
									}
								}
								else if ( bUseSQLParameters )
								{
									switch ( sOPERATOR )
									{
										case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "less"      :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "greater"   :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "not_equals":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "between"   :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sPARAMETER_NAME + "1 and " + sPARAMETER_NAME + "2");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1, sSEARCH_TEXT2);  break;
										case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										// 07/23/2013 Paul.  Add greater and less than conditions. 
										case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
									}
								}
								else
								{
									sSEARCH_TEXT1 = Sql.ToFloat(sSEARCH_TEXT1).ToString();
									sSEARCH_TEXT2 = Sql.ToFloat(sSEARCH_TEXT2).ToString();
									switch ( sOPERATOR )
									{
										case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
										case "less"      :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
										case "greater"   :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
										case "not_equals":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
										case "between"   :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
										case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										// 07/23/2013 Paul.  Add greater and less than conditions. 
										case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sSEARCH_TEXT1);  break;
										case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sSEARCH_TEXT1);  break;
									}
								}
								break;
							}
							case "bool":
							{
								// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
								// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
								if ( StartsWith(sSEARCH_TEXT1, "=") )
								{
									// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
									var sCAT_SEP = (bIsOracle ? " || " : " + ");
									sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.substr(1, sSEARCH_TEXT1.length - 1));
									switch ( sOPERATOR )
									{
										case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
										case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
									}
								}
								else if ( bUseSQLParameters )
								{
									switch ( sOPERATOR )
									{
										case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
									}
								}
								else
								{
									sSEARCH_TEXT1 = Sql.ToBoolean(sSEARCH_TEXT1) ? "1" : "0";
									switch ( sOPERATOR )
									{
										case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
										case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
									}
								}
								break;
							}
							case "guid":
							{
								// 07/16/2006 Paul.  Oracle and DB2 are case-significant.  Keep SQL Server code fast by not converting to uppercase. 
								if ( bIsOracle || bIsDB2 )
								{
									sSEARCH_TEXT1 = sSEARCH_TEXT1.toUpperCase();
									sSEARCH_TEXT2 = sSEARCH_TEXT2.toUpperCase();
									sDATA_FIELD   = "upper(" + sDATA_FIELD + ")";
								}
								// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
								// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
								if ( StartsWith(sSEARCH_TEXT1, "=") )
								{
									// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
									var sCAT_SEP = (bIsOracle ? " || " : " + ");
									sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.substr(1, sSEARCH_TEXT1.length - 1));
									if ( StartsWith(sSEARCH_TEXT2, "=") )
										sSEARCH_TEXT2 = RdlUtil.ReportColumnName(sSEARCH_TEXT2.substr(1, sSEARCH_TEXT2.length - 1));
									switch ( sOPERATOR )
									{
										case "is"             :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
										case "equals"         :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
										case "contains"       :  sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
										case "starts_with"    :  sb.AppendLine("   and " + sDATA_FIELD + " like " +                     sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
										case "ends_with"      :  sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1);  break;
										case "not_equals_str" :  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
										case "empty"          :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty"      :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										case "one_of":
										{
											// 12/03/2008 Paul.  arrSEARCH_TEXT should already be populated.  Do not pull from lstFILTER_SEARCH_LISTBOX. 
											if ( arrSEARCH_TEXT != null && arrSEARCH_TEXT.length > 0 )
											{
												sb.Append("   and " + sDATA_FIELD + " in (");
												for ( let j: number = 0; j < arrSEARCH_TEXT.length; j++ )
												{
													if ( j > 0 )
														sb.Append(", ");
													sb.Append("N'" + Sql.EscapeSQL(arrSEARCH_TEXT[j]) + "'");
												}
												sb.AppendLine(")");
											}
											break;
										}
									}
								}
								else if ( bUseSQLParameters )
								{
									switch ( sOPERATOR )
									{
										case "is"            :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "equals"        :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "contains"      :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
											if ( bIsMySQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
											break;
										case "starts_with"   :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											sSQL =       Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
											if ( bIsMySQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
											break;
										case "ends_with"     :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1)      ;
											if ( bIsMySQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
											break;
										case "not_equals_str":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										// 05/05/2010 Paul.  one_of was available in the UI, but was not generating the SQL. 
										case "one_of":
										{
											// 12/03/2008 Paul.  arrSEARCH_TEXT should already be populated.  Do not pull from lstFILTER_SEARCH_LISTBOX. 
											if ( arrSEARCH_TEXT != null && arrSEARCH_TEXT.length > 0 )
											{
												sb.Append("   and " + sDATA_FIELD + " in (");
												for ( let j: number = 0; j < arrSEARCH_TEXT.length; j++ )
												{
													if ( j > 0 )
														sb.Append(", ");
													sb.Append("N'" + Sql.EscapeSQL(arrSEARCH_TEXT[j]) + "'");
												}
												sb.AppendLine(")");
											}
											break;
										}
									}
								}
								else
								{
									switch ( sOPERATOR )
									{
										case "is"            :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + "'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
										case "equals"        :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + "'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
										case "contains"      :
											sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
											// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											break;
										case "starts_with"   :
											sSQL =       Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
											// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											break;
										case "ends_with"     :
											sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1)      ;
											// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
											if ( bIsMySQL || bIsPostgreSQL )
												sSQL = Sql.replaceAll(sSQL, '\\', '\\\\');  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
											break;
										case "not_equals_str":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + "'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
										case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										// 05/05/2010 Paul.  one_of was available in the UI, but was not generating the SQL. 
										case "one_of":
										{
											// 12/03/2008 Paul.  arrSEARCH_TEXT should already be populated.  Do not pull from lstFILTER_SEARCH_LISTBOX. 
											if ( arrSEARCH_TEXT != null && arrSEARCH_TEXT.length > 0 )
											{
												sb.Append("   and " + sDATA_FIELD + " in (");
												for ( let j: number = 0; j < arrSEARCH_TEXT.length; j++ )
												{
													if ( j > 0 )
														sb.Append(", ");
													sb.Append("N'" + Sql.EscapeSQL(arrSEARCH_TEXT[j]) + "'");
												}
												sb.AppendLine(")");
											}
											break;
										}
									}
								}
								break;
							}
							case "enum":
							{
								// 07/16/2006 Paul.  Oracle and DB2 are case-significant.  Keep SQL Server code fast by not converting to uppercase. 
								if ( bIsOracle || bIsDB2 )
								{
									sSEARCH_TEXT1 = sSEARCH_TEXT1.toUpperCase();
									sSEARCH_TEXT2 = sSEARCH_TEXT2.toUpperCase();
									sDATA_FIELD   = "upper(" + sDATA_FIELD + ")";
								}
								// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
								// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
								if ( StartsWith(sSEARCH_TEXT1, "=") )
								{
									// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
									var sCAT_SEP = (bIsOracle ? " || " : " + ");
									sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.substr(1, sSEARCH_TEXT1.length - 1));
									switch ( sOPERATOR )
									{
										// 02/09/2007 Paul.  enum uses is instead of equals operator. 
										case "is"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "   + sSEARCH_TEXT1);  break;
										case "one_of":
										{
											// 12/03/2008 Paul.  arrSEARCH_TEXT should already be populated.  Do not pull from lstFILTER_SEARCH_LISTBOX. 
											if ( arrSEARCH_TEXT != null && arrSEARCH_TEXT.length > 0 )
											{
												sb.Append("   and " + sDATA_FIELD + " in (");
												for ( let j: number = 0; j < arrSEARCH_TEXT.length; j++ )
												{
													if ( j > 0 )
														sb.Append(", ");
													sb.Append("'" + Sql.EscapeSQL(arrSEARCH_TEXT[j]) + "'");
												}
												sb.AppendLine(")");
											}
											break;
										}
										case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
									}
								}
								else if ( bUseSQLParameters )
								{
									switch ( sOPERATOR )
									{
										// 02/09/2007 Paul.  enum uses is instead of equals operator. 
										case "is"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										case "one_of":
										{
											// 12/03/2008 Paul.  arrSEARCH_TEXT should already be populated.  Do not pull from lstFILTER_SEARCH_LISTBOX. 
											if ( arrSEARCH_TEXT != null && arrSEARCH_TEXT.length > 0 )
											{
												sb.Append("   and " + sDATA_FIELD + " in (");
												for ( let j: number = 0; j < arrSEARCH_TEXT.length; j++ )
												{
													if ( j > 0 )
														sb.Append(", ");
													sb.Append(sPARAMETER_NAME + "_" + j.ToString("000"));
													rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME + "_" + j.ToString("000"), "string", Sql.ToString(arrSEARCH_TEXT[j]));
												}
												sb.AppendLine(")");
											}
											break;
										}
										case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
									}
								}
								else
								{
									switch ( sOPERATOR )
									{
										// 02/09/2007 Paul.  enum uses is instead of equals operator. 
										case "is"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "   + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
										case "one_of":
										{
											// 12/03/2008 Paul.  arrSEARCH_TEXT should already be populated.  Do not pull from lstFILTER_SEARCH_LISTBOX. 
											if ( arrSEARCH_TEXT != null && arrSEARCH_TEXT.length > 0 )
											{
												sb.Append("   and " + sDATA_FIELD + " in (");
												for ( let j: number = 0; j < arrSEARCH_TEXT.length; j++ )
												{
													if ( j > 0 )
														sb.Append(", ");
													sb.Append("N'" + Sql.EscapeSQL(arrSEARCH_TEXT[j]) + "'");
												}
												sb.AppendLine(")");
											}
											break;
										}
										case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
										case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
									}
								}
								break;
							}
						}
						nParameterIndex++;
					}
				}
				// 06/18/2006 Paul.  The element 'QueryParameters' in namespace 'http://schemas.microsoft.com/sqlserver/reporting/2005/01/reportdefinition' has incomplete content. List of possible elements expected: 'http://schemas.microsoft.com/sqlserver/reporting/2005/01/reportdefinition:QueryParameter'. 
				if ( xQueryParameters.ChildNodes.Count == 0 )
				{
					xQueryParameters.ParentNode.RemoveChild(xQueryParameters);
				}
			}
			catch(ex)
			{
				sbErrors.Append(ex.message);
			}
			// 06/15/2006 Paul.  Completely rebuild the Fields list based on the available modules. 
			rdl.SetSingleNode("DataSets/DataSet/Fields", '');
			let xFields: any = rdl.SelectNode("DataSets/DataSet/Fields");
			xFields.RemoveAll();
			// 07/13/2006 Paul.  The key is the alias and the value is the module. 
			// This is so that the same module can be referenced many times with many aliases. 
			for ( let sTableAlias: string in hashAvailableModules.Keys )
			{
				// 01/18/2012 Paul.  Add the ID so that the user can add Drillthrough actions. 
				rdl.CreateField(xFields, sTableAlias + ".ID", "System.Guid");
				// 07/22/2008 Paul.  Not really a bug fix, but just a better field name.  The hash table contains table names and not module names. 
				let sTABLE_NAME: string = Sql.ToString(hashAvailableModules[sTableAlias]);
				let dtColumns: any[] = SplendidCache.ReportingFilterColumns(sTABLE_NAME).Copy();
				for ( let row: any in dtColumns.Rows)
				{
					let sFieldName: string = sTableAlias + "." + Sql.ToString(row["NAME"]);
					let sCsType   : string = Sql.ToString(row["CsType"]);
					let sFieldType: string = '';
					switch ( sCsType )
					{
						case "Guid"      :  sFieldType = "System.Guid"    ;  break;
						case "string"    :  sFieldType = "System.String"  ;  break;
						case "ansistring":  sFieldType = "System.String"  ;  break;
						case "DateTime"  :  sFieldType = "System.DateTime";  break;
						case "bool"      :  sFieldType = "System.Boolean" ;  break;
						case "float"     :  sFieldType = "System.Double"  ;  break;
						case "decimal"   :  sFieldType = "System.Decimal" ;  break;
						case "short"     :  sFieldType = "System.Int16"   ;  break;
						case "Int32"     :  sFieldType = "System.Int32"   ;  break;
						case "Int64"     :  sFieldType = "System.Int64"   ;  break;
						default          :  sFieldType = "System.String"  ;  break;
					}
					rdl.CreateField(xFields, sFieldName, sFieldType);
				}
			}
		}
		let sReportSQL: string = sb.toString();
		rdl.SetSingleNode("DataSets/DataSet/Query/CommandText", sReportSQL);
		return sReportSQL;
	}
	*/

	private decodeHTML = (html) =>
	{
		var txt = document.createElement('textarea');
		txt.innerHTML = html;
		return txt.value;
	}

	private _onChange_SHOW_QUERY = (ev: React.ChangeEvent<HTMLInputElement>) =>
	{
		let SHOW_QUERY = ev.target.checked;
		localStorage.setItem('QueryBuilder.SHOW_QUERY', SHOW_QUERY ? 'true' : 'false');
		this.setState({ SHOW_QUERY });
	}

	private ResetSearchText = () =>
	{
		const { FILTER_COLUMN_SOURCE_LIST, FILTER_COLUMN_LIST } = this.state;
		let FILTER_COLUMN_SOURCE   : string = '';
		let FILTER_COLUMN          : string = '';
		let FILTER_OPERATOR        : string = '';
		let FILTER_OPERATOR_TYPE   : string = '';
		let FILTER_SEARCH_DATA_TYPE: string = '';
		let FILTER_OPERATOR_LIST   : string[] = null;
		if ( FILTER_COLUMN_SOURCE_LIST != null && FILTER_COLUMN_SOURCE_LIST.length > 0 )
		{
			FILTER_COLUMN_SOURCE = FILTER_COLUMN_SOURCE_LIST[0].MODULE_NAME;
		}
		if ( FILTER_COLUMN_LIST != null && FILTER_COLUMN_LIST.length > 0 )
		{
			FILTER_COLUMN = FILTER_COLUMN_LIST[0].NAME;
		}
		if ( FILTER_OPERATOR_LIST != null && FILTER_OPERATOR_LIST.length > 0 )
		{
			FILTER_OPERATOR = FILTER_OPERATOR_LIST[0];
		}
		let row: any = this.getFilterColumn(FILTER_COLUMN_SOURCE, FILTER_COLUMN);
		if ( row != null )
		{
			FILTER_OPERATOR_TYPE    = row['CsType'].toLowerCase();
			FILTER_SEARCH_DATA_TYPE = row['CsType'].toLowerCase();
			FILTER_OPERATOR         = '';
			FILTER_OPERATOR_LIST    = L10n.GetList(FILTER_OPERATOR_TYPE + '_operator_dom');
			if ( this.props.DesignWorkflow && !Sql.IsEmptyString(FILTER_COLUMN) && FILTER_COLUMN.indexOf('_AUDIT_OLD.') >= 0 )
			{
				FILTER_OPERATOR_LIST = ['changed', 'unchanged', 'increased', 'decreased', ...FILTER_OPERATOR_LIST];
			}
			if ( FILTER_OPERATOR_LIST && FILTER_OPERATOR_LIST.length > 0 )
			{
				FILTER_OPERATOR = FILTER_OPERATOR_LIST[0];
			}
		}
		// 06/16/2021 Paul.  Must reset all search values. 
		this.setState(
		{
			FILTER_COLUMN_SOURCE     ,
			FILTER_COLUMN            ,
			FILTER_OPERATOR_LIST     ,
			FILTER_OPERATOR          ,
			FILTER_OPERATOR_TYPE     ,
			FILTER_SEARCH_DATA_TYPE  ,
			FILTER_SEARCH_ID         : '',
			FILTER_SEARCH_TEXT       : '',
			FILTER_SEARCH_TEXT2      : '',
			FILTER_SEARCH_START_DATE : '',
			FILTER_SEARCH_END_DATE   : '',
			FILTER_SEARCH_MODULE_TYPE: '',
			FILTER_SEARCH_DROPDOWN   : '',
			FILTER_SEARCH_LISTBOX    : [],
			filterXmlEditIndex       : -1   ,
			error                    : null ,
		}, () =>
		{
			this.BindSearchText();
		});
	}

	private _onClick_btnAddFilter = () =>
	{
		this.ResetSearchText();
	}

	private getFilterColumn = (FILTER_COLUMN_SOURCE: string, FILTER_COLUMN: string) =>
	{
		const { FILTER_COLUMN_SOURCE_LIST, FILTER_COLUMN_LIST } = this.state;
		if ( Sql.IsEmptyString(FILTER_COLUMN_SOURCE) )
		{
			if ( FILTER_COLUMN_SOURCE_LIST.length > 0 )
			{
				FILTER_COLUMN_SOURCE = FILTER_COLUMN_SOURCE_LIST[0].MODULE_NAME;
			}
		}
		if ( Sql.IsEmptyString(FILTER_COLUMN) )
		{
			if ( FILTER_COLUMN_LIST.length > 0 )
			{
				FILTER_COLUMN = FILTER_COLUMN_LIST[0].NAME;
			}
		}
		let sColumnName: string = Sql.ToString(FILTER_COLUMN).split('.')[1];
		if ( FILTER_COLUMN_LIST.length > 0 )
		{
			for ( let i: number = 0; i < FILTER_COLUMN_LIST.length; i++ )
			{
				let row: any = FILTER_COLUMN_LIST[i];
				if ( row['ColumnName'] == sColumnName )
				{
					return row;
				}
			}
		}
		return null;
	}

	private filterColumnSourceChanged = async (FILTER_COLUMN_SOURCE: string) =>
	{
		let arrModule         : string[] = FILTER_COLUMN_SOURCE.split(' ');
		let sModule           : string   = arrModule[0];
		let sTableAlias       : string   = arrModule[1];
		let FILTER_COLUMN_LIST: any[]    = null;
		// 05/15/2021 Paul.  Cache the FILTER_COLUMN_LIST. 
		FILTER_COLUMN_LIST = this.FILTER_COLUMN_LIST_CACHE[FILTER_COLUMN_SOURCE];
		if ( FILTER_COLUMN_LIST == null )
		{
			FILTER_COLUMN_LIST = await this.getReportingFilterColumns(sModule, sTableAlias);
			this.FILTER_COLUMN_LIST_CACHE[FILTER_COLUMN_SOURCE] = FILTER_COLUMN_LIST;
		}
		if ( FILTER_COLUMN_LIST!= null && FILTER_COLUMN_LIST.length > 0 )
		{
			let row: any = FILTER_COLUMN_LIST[0];
			let FILTER_COLUMN          : string = row['NAME'];
			let FILTER_OPERATOR_TYPE   : string = row['CsType'].toLowerCase();
			let FILTER_SEARCH_DATA_TYPE: string = row['CsType'].toLowerCase();
			let FILTER_OPERATOR        : string = '';
			let FILTER_OPERATOR_LIST   : string[] = L10n.GetList(FILTER_OPERATOR_TYPE + '_operator_dom');
			if ( this.props.DesignWorkflow && !Sql.IsEmptyString(FILTER_COLUMN) && FILTER_COLUMN.indexOf('_AUDIT_OLD.') >= 0 )
			{
				FILTER_OPERATOR_LIST = ['changed', 'unchanged', 'increased', 'decreased', ...FILTER_OPERATOR_LIST];
			}
			if ( FILTER_OPERATOR_LIST && FILTER_OPERATOR_LIST.length > 0 )
			{
				FILTER_OPERATOR = FILTER_OPERATOR_LIST[0];
			}
			this.setState(
			{
				FILTER_COLUMN_LIST     ,
				FILTER_COLUMN          ,
				FILTER_OPERATOR_LIST   ,
				FILTER_OPERATOR        ,
				FILTER_OPERATOR_TYPE   ,
				FILTER_SEARCH_DATA_TYPE,
			}, () =>
			{
				this.BindSearchText();
			});
		}
	}

	private filterColumnChanged = (FILTER_COLUMN_SOURCE: string, FILTER_COLUMN: string) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.filterColumnChanged ' + FILTER_COLUMN_SOURCE + ' ' + FILTER_COLUMN);
		let row: any = this.getFilterColumn(FILTER_COLUMN_SOURCE, FILTER_COLUMN);
		if ( row != null )
		{
			let FILTER_OPERATOR_TYPE   : string = row['CsType'].toLowerCase();
			let FILTER_SEARCH_DATA_TYPE: string = row['CsType'].toLowerCase();
			let FILTER_OPERATOR        : string = '';
			let FILTER_OPERATOR_LIST   : string[] = L10n.GetList(FILTER_OPERATOR_TYPE + '_operator_dom');
			if ( this.props.DesignWorkflow && !Sql.IsEmptyString(FILTER_COLUMN) && FILTER_COLUMN.indexOf('_AUDIT_OLD.') >= 0 )
			{
				FILTER_OPERATOR_LIST = ['changed', 'unchanged', 'increased', 'decreased', ...FILTER_OPERATOR_LIST];
			}
			if ( FILTER_OPERATOR_LIST && FILTER_OPERATOR_LIST.length > 0 )
			{
				FILTER_OPERATOR = FILTER_OPERATOR_LIST[0];
			}
			this.setState(
			{
				FILTER_OPERATOR_LIST   ,
				FILTER_OPERATOR        ,
				FILTER_OPERATOR_TYPE   ,
				FILTER_SEARCH_DATA_TYPE,
			}, () =>
			{
				this.BindSearchText();
			});
		}
	}

	private filterOperatorListName = (item, FILTER_OPERATOR_TYPE) =>
	{
		let sListName: string = FILTER_OPERATOR_TYPE + '_operator_dom';
		if ( item == 'changed' || item == 'unchanged' || item == 'increased' || item == 'decreased' )
		{
			sListName = 'workflow_operator_dom';
		}
		return sListName;
	}

	private BindSearchText = () =>
	{
		const { FILTER_COLUMN_LIST_NAMES, FILTER_OPERATOR, FILTER_COLUMN_SOURCE, FILTER_COLUMN, FILTER_SEARCH_DATA_TYPE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.BindSearchText');
		let FILTER_SEARCH_MODE         : string = null;
		let FILTER_SEARCH_LIST_NAME    : string = null;
		let FILTER_SEARCH_DROPDOWN_LIST: any[]  = null;
		let FILTER_SEARCH_LISTBOX_LIST : any[]  = null;
		let FILTER_SEARCH_MODULE_TYPE  : string = null;
		// 07/06/2007 Paul.  ansistring is treated the same as string. 
		let sCOMMON_DATA_TYPE: string = FILTER_SEARCH_DATA_TYPE;
		if ( sCOMMON_DATA_TYPE == "ansistring" )
			sCOMMON_DATA_TYPE = "string";
		switch ( sCOMMON_DATA_TYPE )
		{
			case "string":
			{
				switch ( FILTER_OPERATOR )
				{
					case "equals"        :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "contains"      :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "starts_with"   :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "ends_with"     :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "not_equals_str":  FILTER_SEARCH_MODE = 'text' ;  break;
					case "empty"         :  break;
					case "not_empty"     :  break;
					// 08/25/2011 Paul.  A customer wants more use of NOT in string filters. 
					case "not_contains"   :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "not_starts_with":  FILTER_SEARCH_MODE = 'text' ;  break;
					case "not_ends_with"  :  FILTER_SEARCH_MODE = 'text' ;  break;
					// 02/14/2013 Paul.  A customer wants to use like in string filters. 
					case "like"           :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "not_like"       :  FILTER_SEARCH_MODE = 'text' ;  break;
					// 07/23/2013 Paul.  Add greater and less than conditions. 
					case "less"          :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "less_equal"    :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "greater"       :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "greater_equal" :  FILTER_SEARCH_MODE = 'text' ;  break;
				}
				break;
			}
			case "datetime":
			{
				switch ( FILTER_OPERATOR )
				{
					case "on"               :  FILTER_SEARCH_MODE = 'date' ;  break;
					case "before"           :  FILTER_SEARCH_MODE = 'date' ;  break;
					case "after"            :  FILTER_SEARCH_MODE = 'date' ;  break;
					case "between_dates"    :  FILTER_SEARCH_MODE = 'date2';  break;
					case "not_equals_str"   :  FILTER_SEARCH_MODE = 'date' ;  break;
					case "empty"            :  break;
					case "not_empty"        :  break;
					case "is_before"        :  break;
					case "is_after"         :  break;
					case "tp_yesterday"     :  break;
					case "tp_today"         :  break;
					case "tp_tomorrow"      :  break;
					case "tp_last_7_days"   :  break;
					case "tp_next_7_days"   :  break;
					case "tp_last_month"    :  break;
					case "tp_this_month"    :  break;
					case "tp_next_month"    :  break;
					case "tp_last_30_days"  :  break;
					case "tp_next_30_days"  :  break;
					case "tp_last_year"     :  break;
					case "tp_this_year"     :  break;
					case "tp_next_year"     :  break;
					case "changed"          :  break;
					case "unchanged"        :  break;
					case "increased"        :  break;
					case "decreased"        :  break;
					case "tp_minutes_after" :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_hours_after"   :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_days_after"    :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_weeks_after"   :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_months_after"  :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_years_after"   :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_minutes_before":  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_hours_before"  :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_days_before"   :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_weeks_before"  :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_months_before" :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_years_before"  :  FILTER_SEARCH_MODE = 'text' ;  break;
					// 12/04/2008 Paul.  We need to be able to do an an equals. 
					case "tp_days_old"      :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_weeks_old"     :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_months_old"    :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "tp_years_old"     :  FILTER_SEARCH_MODE = 'text' ;  break;
				}
				break;
			}
			case "int32":
			{
				switch ( FILTER_OPERATOR )
				{
					case "equals"    :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "less"      :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "greater"   :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "between"   :  FILTER_SEARCH_MODE = 'text2';  break;
					case "not_equals":  FILTER_SEARCH_MODE = 'text' ;  break;
					case "empty"     :  break;
					case "not_empty" :  break;
					// 07/23/2013 Paul.  Add greater and less than conditions. 
					case "less_equal"    :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "greater_equal" :  FILTER_SEARCH_MODE = 'text' ;  break;
				}
				break;
			}
			case "decimal":
			{
				switch ( FILTER_OPERATOR )
				{
					case "equals"    :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "less"      :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "greater"   :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "between"   :  FILTER_SEARCH_MODE = 'text2';  break;
					case "not_equals":  FILTER_SEARCH_MODE = 'text' ;  break;
					case "empty"     :  break;
					case "not_empty" :  break;
					// 07/23/2013 Paul.  Add greater and less than conditions. 
					case "less_equal"    :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "greater_equal" :  FILTER_SEARCH_MODE = 'text' ;  break;
				}
				break;
			}
			case "float":
			{
				switch ( FILTER_OPERATOR )
				{
					case "equals"    :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "less"      :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "greater"   :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "between"   :  FILTER_SEARCH_MODE = 'text2';  break;
					case "not_equals":  FILTER_SEARCH_MODE = 'text' ;  break;
					case "empty"     :  break;
					case "not_empty" :  break;
					// 07/23/2013 Paul.  Add greater and less than conditions. 
					case "less_equal"    :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "greater_equal" :  FILTER_SEARCH_MODE = 'text' ;  break;
				}
				break;
			}
			case "bool":
			{
				switch ( FILTER_OPERATOR )
				{
					case "equals"    :
						// 12/20/2006 Paul.  We need to populate the dropdown for booleans with 1 and 0. 
						FILTER_SEARCH_MODE          = 'dropdown';
						// 06/16/2021 Paul.  Must set the FILTER_SEARCH_LIST_NAME field. 
						FILTER_SEARCH_LIST_NAME     = 'yesno_dom';
						FILTER_SEARCH_DROPDOWN_LIST = L10n.GetList(FILTER_SEARCH_LIST_NAME);
						break;
					case "empty"     :  break;
					case "not_empty" :  break;
				}
				break;
			}
			case "guid":
			{
				switch ( FILTER_OPERATOR )
				{
					// 05/05/2010 Paul.  The Select button was not being made visible. 
					case "is"            :
					{
						let arrModule  : string[] = FILTER_COLUMN_SOURCE.split(' ');
						let sModule    : string   = arrModule[0];
						let arrColumn  : string[] = FILTER_COLUMN.split('.');
						let sColumnName: string   = arrColumn[0];
						if ( arrColumn.length > 1 )
							sColumnName = arrColumn[1];
							
						switch ( sColumnName )
						{
							case "ID"              :  FILTER_SEARCH_MODULE_TYPE = sModule;  break;
							case "CREATED_BY_ID"   :  FILTER_SEARCH_MODULE_TYPE = "Users";  break;
							case "MODIFIED_USER_ID":  FILTER_SEARCH_MODULE_TYPE = "Users";  break;
							case "ASSIGNED_USER_ID":  FILTER_SEARCH_MODULE_TYPE = "Users";  break;
							// 06/14/2021 Paul.  Include assigned and team sets. 
							case "ASSIGNED_SET_ID" :  FILTER_SEARCH_MODULE_TYPE = "Users";  break;
							case "TEAM_SET_ID"     :  FILTER_SEARCH_MODULE_TYPE = "Teams";  break;
							case "TEAM_ID"         :  FILTER_SEARCH_MODULE_TYPE = "Teams";  break;
							default:
							{
								let layout = EditView_LoadLayout(sModule + '.EditView');
								if ( layout != null )
								{
									let lay = EditView_FindField(layout, sColumnName);
									// 06/14/2021 Paul.  Layout field may not exist. 
									if ( lay != null )
										FILTER_SEARCH_MODULE_TYPE = lay.MODULE_TYPE;
									else
										console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.BindSearchText layout not found for ' + sModule + '.EditView', sColumnName);
								}
								break;
							}
						}
						if ( !Sql.IsEmptyString(FILTER_SEARCH_MODULE_TYPE) )
							FILTER_SEARCH_MODE = 'select';
						break;
					}
					case "equals"        :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "contains"      :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "starts_with"   :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "ends_with"     :  FILTER_SEARCH_MODE = 'text' ;  break;
					case "not_equals_str":  FILTER_SEARCH_MODE = 'text' ;  break;
					case "empty"         :  break;
					case "not_empty"     :  break;
					case "one_of"        :
					{
						// 05/20/2009 Paul.  If this is a one-of guid, then populate the listbox user or team names. 
						let arrModule  : string[] = FILTER_COLUMN_SOURCE.split(' ');
						let sModule    : string   = arrModule[0];
						let arrColumn  : string[] = FILTER_COLUMN.split('.');
						let sColumnName: string   = arrColumn[0];
						if ( arrColumn.length > 1 )
							sColumnName = arrColumn[1];
							
						FILTER_SEARCH_LIST_NAME = '';
						switch ( sColumnName )
						{
							case "CREATED_BY_ID"   :  FILTER_SEARCH_LIST_NAME = "AssignedUser";  break;
							case "MODIFIED_USER_ID":  FILTER_SEARCH_LIST_NAME = "AssignedUser";  break;
							case "ASSIGNED_USER_ID":  FILTER_SEARCH_LIST_NAME = "AssignedUser";  break;
							// 06/14/2021 Paul.  Include assigned and team sets. 
							case "ASSIGNED_SET_ID" :  FILTER_SEARCH_LIST_NAME = "AssignedUser";  break;
							case "TEAM_SET_ID"     :  FILTER_SEARCH_LIST_NAME = "Teams"       ;  break;
							case "TEAM_ID"         :  FILTER_SEARCH_LIST_NAME = "Teams"       ;  break;
						}
						if ( Sql.IsEmptyString(FILTER_SEARCH_LIST_NAME) )
						{
							FILTER_SEARCH_LISTBOX_LIST = null;
							FILTER_SEARCH_MODE = 'select';
						}
						else
						{
							FILTER_SEARCH_LISTBOX_LIST = L10n.GetList(FILTER_SEARCH_LIST_NAME);
							FILTER_SEARCH_MODE = 'listbox';
						}
						break;
					}
				}
				break;
			}
			case "enum":
			{
				// 02/09/2007 Paul.  If this is an enum, then populate the listbox with list names pulled from EDITVIEWS_FIELDS.
				let arrModule: string[] = FILTER_COLUMN_SOURCE.split(' ');
				let sModule  : string   = arrModule[0];
					
				let arrColumn  : string[] = FILTER_COLUMN.split('.');
				let sColumnName: string   = arrColumn[0];
				if ( arrColumn.length > 1 )
					sColumnName = arrColumn[1];
				
				let sMODULE_TABLE: string = Crm_Modules.TableName(sModule);
				FILTER_SEARCH_LIST_NAME = FILTER_COLUMN_LIST_NAMES[sMODULE_TABLE + '.' + sColumnName];
				if ( Sql.IsEmptyString(FILTER_SEARCH_LIST_NAME) )
				{
					FILTER_SEARCH_DROPDOWN_LIST = null;
					FILTER_SEARCH_LISTBOX_LIST  = null;
				}
				else
				{
					FILTER_SEARCH_DROPDOWN_LIST = L10n.GetList(FILTER_SEARCH_LIST_NAME);
					FILTER_SEARCH_LISTBOX_LIST  = FILTER_SEARCH_DROPDOWN_LIST;
					switch ( FILTER_OPERATOR )
					{
						case "is"            :  FILTER_SEARCH_MODE = 'dropdown';  break;
						case "one_of"        :  FILTER_SEARCH_MODE = 'listbox' ;  break;
						case "empty"         :  break;
						case "not_empty"     :  break;
					}
				}
				break;
			}
		}
		this.setState(
		{
			FILTER_SEARCH_MODE         ,
			FILTER_SEARCH_LIST_NAME    ,
			FILTER_SEARCH_DROPDOWN_LIST,
			FILTER_SEARCH_LISTBOX_LIST ,
			FILTER_SEARCH_MODULE_TYPE  ,
		});
	}

	private _onFiltersEdit = async (index: number) =>
	{
		let { filterXml } = this.state;

		let FILTER_ID                  : string  = '';
		let FILTER_COLUMN_SOURCE       : string  = '';
		let FILTER_COLUMN              : string  = '';
		let FILTER_OPERATOR            : string  = '';
		let FILTER_OPERATOR_TYPE       : string  = '';
		let FILTER_SEARCH_ID           : string  = '';
		let FILTER_SEARCH_DATA_TYPE    : string  = '';
		let FILTER_SEARCH_TEXT         : string  = '';
		let FILTER_SEARCH_TEXT2        : string  = '';
		let FILTER_SEARCH_START_DATE   : string  = '';
		let FILTER_SEARCH_END_DATE     : string  = '';
		let FILTER_SEARCH_LISTBOX      : string[] = [];
		if ( filterXml && filterXml.Filters && filterXml.Filters.Filter && index < filterXml.Filters.Filter.length )
		{
			let sFILTER_ID    : string   = '';
			let sMODULE_NAME  : string   = '';
			let sDATA_FIELD   : string   = '';
			let sDATA_TYPE    : string   = '';
			let sOPERATOR     : string   = '';
			let sSEARCH_TEXT1 : string   = '';
			let sSEARCH_TEXT2 : string   = '';
			let arrSEARCH_TEXT: string[] = [];
			let SEARCH_TEXT_VALUES: any = null;
			sFILTER_ID         = Sql.ToString(filterXml.Filters.Filter[index]['ID'                ]);
			sMODULE_NAME       = Sql.ToString(filterXml.Filters.Filter[index]['MODULE_NAME'       ]);
			sDATA_FIELD        = Sql.ToString(filterXml.Filters.Filter[index]['DATA_FIELD'        ]);
			sDATA_TYPE         = Sql.ToString(filterXml.Filters.Filter[index]['DATA_TYPE'         ]);
			sOPERATOR          = Sql.ToString(filterXml.Filters.Filter[index]['OPERATOR'          ]);
			//sSEARCH_TEXT       = Sql.ToString(filterXml.Filters.Filter[index]['SEARCH_TEXT'       ]);
			SEARCH_TEXT_VALUES = filterXml.Filters.Filter[index]['SEARCH_TEXT_VALUES'];
			if ( SEARCH_TEXT_VALUES != null )
			{
				if ( !Array.isArray(SEARCH_TEXT_VALUES) )
				{
					arrSEARCH_TEXT.push(SEARCH_TEXT_VALUES);
				}
				else
				{
					arrSEARCH_TEXT = SEARCH_TEXT_VALUES;
				}
			}
			if ( arrSEARCH_TEXT.length > 0 )
				sSEARCH_TEXT1 = arrSEARCH_TEXT[0];
			if ( arrSEARCH_TEXT.length > 1 )
				sSEARCH_TEXT2 = arrSEARCH_TEXT[1];

			// 07/06/2007 Paul.  ansistring is treated the same as string. 
			let sCOMMON_DATA_TYPE: string = sDATA_TYPE;
			if ( sCOMMON_DATA_TYPE == "ansistring" )
				sCOMMON_DATA_TYPE = "string";
			switch ( sCOMMON_DATA_TYPE )
			{
				case "string":
				{
					switch ( sOPERATOR )
					{
						case "equals"        :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "contains"      :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "starts_with"   :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "ends_with"     :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "not_equals_str":  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "empty"         :  break;
						case "not_empty"     :  break;
						// 08/25/2011 Paul.  A customer wants more use of NOT in string filters. 
						case "not_contains"   :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "not_starts_with":  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "not_ends_with"  :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						// 02/14/2013 Paul.  A customer wants to use like in string filters. 
						case "like"           :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "not_like"       :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						// 07/23/2013 Paul.  Add greater and less than conditions. 
						case "less"           :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "less_equal"     :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "greater"        :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "greater_equal"  :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
					}
					break;
				}
				case "datetime":
				{
					if ( arrSEARCH_TEXT.length > 0 )
					{
						let dtSEARCH_TEXT1: any = null;
						let dtSEARCH_TEXT2: any = null;
						if ( !(EndsWith(sOPERATOR, "_after") || EndsWith(sOPERATOR, "_before") || EndsWith(sOPERATOR, "_old")) )
						{
							
							dtSEARCH_TEXT1 = formatDate(sSEARCH_TEXT1, this.DATE_FORMAT);
							dtSEARCH_TEXT2 = null;
							if ( arrSEARCH_TEXT.length > 1 )
								dtSEARCH_TEXT2 = formatDate(sSEARCH_TEXT2, this.DATE_FORMAT);
						}
						switch ( sOPERATOR )
						{
							case "on"               :  FILTER_SEARCH_START_DATE = dtSEARCH_TEXT1;  break;
							case "before"           :  FILTER_SEARCH_START_DATE = dtSEARCH_TEXT1;  break;
							case "after"            :  FILTER_SEARCH_START_DATE = dtSEARCH_TEXT1;  break;
							case "not_equals_str"   :  FILTER_SEARCH_START_DATE = dtSEARCH_TEXT1;  break;
							case "between_dates"    :
								FILTER_SEARCH_START_DATE = dtSEARCH_TEXT1;
								if ( arrSEARCH_TEXT.length > 1 )
									FILTER_SEARCH_END_DATE = dtSEARCH_TEXT2;
								break;
							case "empty"            :  break;
							case "not_empty"        :  break;
							case "is_before"        :  break;
							case "is_after"         :  break;
							case "tp_yesterday"     :  break;
							case "tp_today"         :  break;
							case "tp_tomorrow"      :  break;
							case "tp_last_7_days"   :  break;
							case "tp_next_7_days"   :  break;
							case "tp_last_month"    :  break;
							case "tp_this_month"    :  break;
							case "tp_next_month"    :  break;
							case "tp_last_30_days"  :  break;
							case "tp_next_30_days"  :  break;
							case "tp_last_year"     :  break;
							case "tp_this_year"     :  break;
							case "tp_next_year"     :  break;
							case "changed"          :  break;
							case "unchanged"        :  break;
							case "increased"        :  break;
							case "decreased"        :  break;
							// 11/16/2008 Paul.  Days old 
							case "tp_minutes_after" :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_hours_after"   :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_days_after"    :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_weeks_after"   :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_months_after"  :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_years_after"   :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_minutes_before":  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_hours_before"  :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_days_before"   :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_weeks_before"  :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_months_before" :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_years_before"  :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							// 12/04/2008 Paul.  We need to be able to do an an equals. 
							case "tp_days_old"      :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_weeks_old"     :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_months_old"    :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
							case "tp_years_old"     :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						}
					}
					break;
				}
				case "int32":
				{
					switch ( sOPERATOR )
					{
						case "equals"    :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "less"      :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "greater"   :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "between"   :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  FILTER_SEARCH_TEXT2 = sSEARCH_TEXT2;  break;
						case "not_equals":  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "empty"     :  break;
						case "not_empty" :  break;
						// 07/23/2013 Paul.  Add greater and less than conditions. 
						case "less_equal"     :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "greater_equal"  :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
					}
					break;
				}
				case "decimal":
				{
					switch ( sOPERATOR )
					{
						case "equals"    :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "less"      :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "greater"   :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "between"   :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  FILTER_SEARCH_TEXT2 = sSEARCH_TEXT2;  break;
						case "not_equals":  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "empty"     :  break;
						case "not_empty" :  break;
						// 07/23/2013 Paul.  Add greater and less than conditions. 
						case "less_equal"     :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "greater_equal"  :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
					}
					break;
				}
				case "float":
				{
					switch ( sOPERATOR )
					{
						case "equals"    :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "less"      :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "greater"   :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "between"   :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  FILTER_SEARCH_TEXT2 = sSEARCH_TEXT2;  break;
						case "not_equals":  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "empty"     :  break;
						case "not_empty" :  break;
						// 07/23/2013 Paul.  Add greater and less than conditions. 
						case "less_equal"     :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
						case "greater_equal"  :  FILTER_SEARCH_TEXT = sSEARCH_TEXT1;  break;
					}
					break;
				}
				case "bool":
				{
					switch ( sOPERATOR )
					{
						case "equals"    :
							try
							{
								// 12/20/2006 Paul.  Catch and ignore the exception. 
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								//Utils.SetSelectedValue(lstFILTER_SEARCH_DROPDOWN, sSEARCH_TEXT1);
							}
							catch
							{
							}
							break;
						case "empty"     :  break;
						case "not_empty" :  break;
					}
					break;
				}
				case "guid":
				{
					switch ( sOPERATOR )
					{
						// 05/05/2010 Paul.  We store both the ID and the Name for a Guid IS. 
						case "is"            :  FILTER_SEARCH_ID = sSEARCH_TEXT1;  FILTER_SEARCH_TEXT = sSEARCH_TEXT2;  break;
						case "equals"        :  FILTER_SEARCH_TEXT  = sSEARCH_TEXT1;  break;
						case "contains"      :  FILTER_SEARCH_TEXT  = sSEARCH_TEXT1;  break;
						case "starts_with"   :  FILTER_SEARCH_TEXT  = sSEARCH_TEXT1;  break;
						case "ends_with"     :  FILTER_SEARCH_TEXT  = sSEARCH_TEXT1;  break;
						case "not_equals_str":  FILTER_SEARCH_TEXT  = sSEARCH_TEXT1;  break;
						case "empty"         :  break;
						case "not_empty"     :  break;
						case "one_of"        :
						{
							FILTER_SEARCH_LISTBOX = arrSEARCH_TEXT;
							// 05/20/2009 Paul.  If this is a one-of guid, then populate the listbox user or team names. 
							//foreach ( string s in arrSEARCH_TEXT )
							//{
							//	for ( int i = 0; i < FILTER_SEARCH_LISTBOX.length; i++ )
							//	{
							//		if ( s == FILTER_SEARCH_LISTBOX[i] )
							//			lstFILTER_SEARCH_LISTBOX.Items[i].Selected = true;
							//	}
							//}
							break;
						}
					}
					break;
				}
				case "enum":
				{
					switch ( sOPERATOR )
					{
						case "is"            :
							try
							{
								// 12/20/2006 Paul.  Catch and ignore the exception. 
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								//Utils.SetSelectedValue(lstFILTER_SEARCH_DROPDOWN, sSEARCH_TEXT1);
								FILTER_SEARCH_LISTBOX = [];
								FILTER_SEARCH_LISTBOX.push(sSEARCH_TEXT1);
							}
							catch
							{
							}
							break;
						case "one_of":
						{
							FILTER_SEARCH_LISTBOX = arrSEARCH_TEXT;
							//foreach ( string s in arrSEARCH_TEXT )
							//{
							//	for ( int i = 0; i < lstFILTER_SEARCH_LISTBOX.Items.Count; i++ )
							//	{
							//		if ( s == lstFILTER_SEARCH_LISTBOX.Items[i].Value )
							//			lstFILTER_SEARCH_LISTBOX.Items[i].Selected = true;
							//	}
							//}
							break;
						}
						case "empty"         :  break;
						case "not_empty"     :  break;
					}
					break;
				}
			}

			FILTER_ID               = sFILTER_ID  ;
			FILTER_COLUMN_SOURCE    = sMODULE_NAME;
			FILTER_COLUMN           = sDATA_FIELD ;
			FILTER_OPERATOR         = sOPERATOR   ;
			FILTER_OPERATOR_TYPE    = sDATA_TYPE  ;
			FILTER_SEARCH_DATA_TYPE = sDATA_TYPE  ;
			//FILTER_OPERATOR_TYPE    = Sql.ToString(filterXml.Filters.Filter[index]['FILTER_OPERATOR_TYPE'   ]);
			//FILTER_SEARCH_DATA_TYPE = Sql.ToString(filterXml.Filters.Filter[index]['FILTER_SEARCH_DATA_TYPE']);
		}
		// 06/15/2021 Paul.  Manual correct column list and BindSearchText(). 
		let arrModule         : string[] = FILTER_COLUMN_SOURCE.split(' ');
		let sModule           : string   = arrModule[0];
		let sTableAlias       : string   = arrModule[1];
		let FILTER_COLUMN_LIST: any[]    = null;
		FILTER_COLUMN_LIST = this.FILTER_COLUMN_LIST_CACHE[FILTER_COLUMN_SOURCE];
		if ( FILTER_COLUMN_LIST == null )
		{
			FILTER_COLUMN_LIST = await this.getReportingFilterColumns(sModule, sTableAlias);
			this.FILTER_COLUMN_LIST_CACHE[FILTER_COLUMN_SOURCE] = FILTER_COLUMN_LIST;
		}
		let FILTER_OPERATOR_LIST   : string[] = L10n.GetList(FILTER_OPERATOR_TYPE + '_operator_dom');
		this.setState(
		{
			FILTER_ID               ,
			FILTER_COLUMN_SOURCE    ,
			FILTER_COLUMN           ,
			FILTER_OPERATOR         ,
			FILTER_OPERATOR_TYPE    ,
			FILTER_SEARCH_ID        ,
			FILTER_SEARCH_DATA_TYPE ,
			FILTER_SEARCH_TEXT      ,
			FILTER_SEARCH_TEXT2     ,
			FILTER_SEARCH_START_DATE,
			FILTER_SEARCH_END_DATE  ,
			FILTER_SEARCH_LISTBOX   ,
			filterXmlEditIndex      : index,
			FILTER_COLUMN_LIST      ,
			FILTER_OPERATOR_LIST    ,
		}, async () =>
		{
			this.BindSearchText();
		});
	}

	private _onFiltersRemove = async (index: number) =>
	{
		const { DisplayColumns } = this.props;
		let { MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml } = this.state;
		if ( filterXml && filterXml.Filters && filterXml.Filters.Filter && index < filterXml.Filters.Filter.length )
		{
			filterXml.Filters.Filter.splice(index, 1);
			let filterXmlJson = dumpObj(filterXml, 'filterXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
			this.ResetSearchText();
			let oPreviewSQL: string = await this.getReportSQL(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, DisplayColumns);
			this.setState({ oPreviewSQL });

		}
	}

	private _onFiltersUpdate = async () =>
	{
		const { DisplayColumns } = this.props;
		const { MODULE, RELATED, FILTER_COLUMN_SOURCE, FILTER_COLUMN, FILTER_OPERATOR, FILTER_OPERATOR_TYPE, FILTER_SEARCH_MODE, FILTER_SEARCH_ID, FILTER_SEARCH_TEXT, FILTER_SEARCH_TEXT2, FILTER_SEARCH_DROPDOWN, FILTER_SEARCH_LISTBOX, FILTER_SEARCH_START_DATE, FILTER_SEARCH_END_DATE } = this.state;
		let { filterXml, relatedModuleXml, relationshipXml, filterXmlEditIndex } = this.state;
		try
		{
			if ( !filterXml )
			{
				filterXml = {};
			}
			if ( !filterXml.Filters )
			{
				filterXml.Filters = {};
			}
			if ( !filterXml.Filters.Filter || !Array.isArray(filterXml.Filters.Filter) )
			{
				filterXml.Filters.Filter = [];
			}
			if ( filterXmlEditIndex == -1 )
			{
				filterXmlEditIndex = filterXml.Filters.Filter.length;
				filterXml.Filters.Filter.push({});
			}
			if ( filterXml.Filters.Filter[filterXmlEditIndex] )
			{
				let SEARCH_TEXT       : string = null;
				let SEARCH_TEXT_VALUES: string[] = [];
				switch ( FILTER_SEARCH_MODE )
				{
					case 'text':
						SEARCH_TEXT        = FILTER_SEARCH_TEXT;
						SEARCH_TEXT_VALUES.push(SEARCH_TEXT);
						break;
					case 'text2':
						SEARCH_TEXT_VALUES.push(FILTER_SEARCH_TEXT);
						SEARCH_TEXT_VALUES.push(FILTER_SEARCH_TEXT2);
						SEARCH_TEXT        = SEARCH_TEXT_VALUES.join(', ');
						break;
					case 'date':
						SEARCH_TEXT        = formatDate(FILTER_SEARCH_START_DATE, this.DATE_FORMAT);
						SEARCH_TEXT_VALUES.push(SEARCH_TEXT);
						break;
					case 'date2':
						SEARCH_TEXT_VALUES.push(formatDate(FILTER_SEARCH_START_DATE, this.DATE_FORMAT));
						SEARCH_TEXT_VALUES.push(formatDate(FILTER_SEARCH_END_DATE  , this.DATE_FORMAT));
						SEARCH_TEXT        = SEARCH_TEXT_VALUES.join(', ');
						break;
					case 'select':
						SEARCH_TEXT        = FILTER_SEARCH_ID + ', ' + FILTER_SEARCH_TEXT;
						SEARCH_TEXT_VALUES.push(FILTER_SEARCH_ID);
						SEARCH_TEXT_VALUES.push(FILTER_SEARCH_TEXT);
						break;
					case 'dropdown':
						SEARCH_TEXT        = FILTER_SEARCH_DROPDOWN;
						SEARCH_TEXT_VALUES.push(FILTER_SEARCH_DROPDOWN);
						break;
					case 'listbox':
						SEARCH_TEXT        = FILTER_SEARCH_LISTBOX.join(', ');
						SEARCH_TEXT_VALUES = FILTER_SEARCH_LISTBOX;
						break;
				}
				
				if ( filterXml.Filters.Filter[filterXmlEditIndex]['ID'] === undefined )
				{
					filterXml.Filters.Filter[filterXmlEditIndex]['ID'] = uuidFast();
				}
				filterXml.Filters.Filter[filterXmlEditIndex]['MODULE_NAME'       ] = Sql.ToString(FILTER_COLUMN_SOURCE);
				filterXml.Filters.Filter[filterXmlEditIndex]['DATA_FIELD'        ] = Sql.ToString(FILTER_COLUMN       );
				filterXml.Filters.Filter[filterXmlEditIndex]['DATA_TYPE'         ] = Sql.ToString(FILTER_OPERATOR_TYPE);
				filterXml.Filters.Filter[filterXmlEditIndex]['OPERATOR'          ] = Sql.ToString(FILTER_OPERATOR     );
				filterXml.Filters.Filter[filterXmlEditIndex]['SEARCH_TEXT'       ] = SEARCH_TEXT       ;
				filterXml.Filters.Filter[filterXmlEditIndex]['SEARCH_TEXT_VALUES'] = SEARCH_TEXT_VALUES;
		
				let filterXmlJson = dumpObj(filterXml, 'filterXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
				this.setState(
				{
					filterXml              ,
					filterXmlJson          ,
					filterXmlEditIndex     : -1,
				}, async () =>
				{
					this.ResetSearchText();
					let oPreviewSQL: string = await this.getReportSQL(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, DisplayColumns);
					this.setState({ oPreviewSQL });
					this.props.onChanged('filterXml'       , filterXml       , null, null);
				});
			}
			else
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onFiltersUpdate invalid filterXmlEditIndex', filterXmlEditIndex);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onFiltersUpdate', error);
			this.setState({ error });
		}
	}

	private _onFiltersCancel = () =>
	{
		this.ResetSearchText();
	}

	private _onMODULE_Change = async (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { RELATED, filterXml, relatedModuleXml, relationshipXml } = this.state;
		let MODULE: string = event.target.value;
		this.setState({ MODULE }, () =>
		{
			this.moduleChanged(this.props.Modules, MODULE, RELATED, true);
			this.props.onChanged('MODULE_NAME', MODULE, null, null);
		});
	}

	private _onRELATED_Change = async (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { MODULE, relatedModuleXml, relationshipXml } = this.state;
		let { filterXml, filterXmlJson, filterXmlEditIndex } = this.state;
		let RELATED: string = event.target.value;
		// 05/6/2021 Paul.  RemoveInvalidFilters(). 
		if ( filterXml && filterXml.Filters && filterXml.Filters.Filter && Array.isArray(filterXml.Filters.Filter) )
		{
			let hashMODULES: any = {};
			let sTABLE_NAME: string = Crm_Modules.TableName(MODULE)
			hashMODULES[sTABLE_NAME] = MODULE;
			if ( !Sql.IsEmptyString(RELATED) )
			{
				let sRELATED      : string = RELATED.split(' ')[0];
				let sRELATED_ALIAS: string = RELATED.split(' ')[1];
				hashMODULES[sRELATED_ALIAS] = sRELATED;
			}
			if ( relationshipXml.Relationships && relationshipXml.Relationships.Relationship && Array.isArray(relationshipXml.Relationships.Relationship) )
			{
				for ( let j: number = 0; j < relationshipXml.Relationships.Relationship.length; j++ )
				{
					let rel: any = relationshipXml.Relationships.Relationship[j];
					hashMODULES[rel.MODULE_ALIAS] = rel.MODULE_NAME;
				}
			}
			
			for ( let i: number = filterXml.Filters.Filter.length - 1; i >= 0; i-- )
			{
				let filter: any = filterXml.Filters.Filter[i];
				let sMODULE_ALIAS: string = filter.MODULE_NAME.split(' ')[1];
				if ( hashMODULES[sMODULE_ALIAS] === undefined )
				{
					filterXml.Filters.Filter.splice(i, 1);
				}
			}
			filterXmlJson = dumpObj(filterXml, 'filterXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
		}
		this.setState(
		{
			RELATED,
			filterXml,
			filterXmlJson,
			filterXmlEditIndex: -1
		}, () =>
		{
			this.moduleChanged(this.props.Modules, MODULE, RELATED, false);
			this.props.onChanged('RELATED', RELATED, null, null);
			this.props.onChanged('filterXml'       , filterXml       , null, null);
		});
	}

	private _onFILTER_COLUMN_SOURCE_LIST_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let FILTER_COLUMN_SOURCE: string = event.target.value;
		this.setState({ FILTER_COLUMN_SOURCE });
		this.filterColumnSourceChanged(FILTER_COLUMN_SOURCE);
	}

	private _onFILTER_COLUMN_LIST_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { FILTER_COLUMN_SOURCE } = this.state;
		let FILTER_COLUMN: string = event.target.value;
		this.setState({ FILTER_COLUMN });
		this.filterColumnChanged(FILTER_COLUMN_SOURCE, FILTER_COLUMN);
	}

	private _onFILTER_OPERATOR_LIST_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let FILTER_OPERATOR: string = event.target.value;
		this.setState({ FILTER_OPERATOR }, () =>
		{
			this.BindSearchText();
		});
	}

	private _onFILTER_SEARCH_TEXT_Change = (event: React.ChangeEvent<HTMLInputElement>) =>
	{
		let FILTER_SEARCH_TEXT: string = event.target.value;
		this.setState({ FILTER_SEARCH_TEXT });
	}

	private _onFILTER_SEARCH_TEXT2_Change = (event: React.ChangeEvent<HTMLInputElement>) =>
	{
		let FILTER_SEARCH_TEXT2: string = event.target.value;
		this.setState({ FILTER_SEARCH_TEXT2 }), () =>
		{
			this.BindSearchText();
		};
	}

	private _onFILTER_SEARCH_DROPDOWN_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let FILTER_SEARCH_DROPDOWN: string = event.target.value;
		this.setState({ FILTER_SEARCH_DROPDOWN }, () =>
		{
			this.BindSearchText();
		});
	}

	private _onFILTER_SEARCH_LISTBOX_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let FILTER_SEARCH_LISTBOX: string[] = [];
		let selectedOptions = event.target.selectedOptions;
		for (let i = 0; i < selectedOptions.length; i++)
		{
			FILTER_SEARCH_LISTBOX.push(selectedOptions[i].value);
		}
		this.setState({ FILTER_SEARCH_LISTBOX }, () =>
		{
			this.BindSearchText();
		});
	}

	private _onFILTER_SEARCH_START_DATE_Change = (value: moment.Moment | string) =>
	{
		try
		{
			let mntValue: moment.Moment = null;
			if ( typeof(value) == 'string' )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange string ' + DATA_FIELD, value);
				if ( Sql.IsEmptyString(value) )
				{
					// 11/17/2019 Paul.  Increment the reset index as clearing the control causes a NaN situation. 
					this.setState({ FILTER_SEARCH_START_DATE: null, error: null });
				}
				else
				{
					let bValidDateParts: boolean = ValidateDateParts(value, this.DATE_FORMAT);
					// 08/05/2019 Paul.  A moment will be valid, even with a single numeric value.  So require 3 parts. 
					mntValue = moment(value, this.DATE_FORMAT);
					if ( bValidDateParts && mntValue.isValid() )
					{
						let DATA_VALUE: Date   = mntValue.toDate();
						this.setState({ FILTER_SEARCH_START_DATE: formatDate(DATA_VALUE, this.DATE_FORMAT), error: null });
					}
					else
					{
						this.setState({ error: L10n.Term('.ERR_INVALID_DATE') });
					}
				}
			}
			else if ( value instanceof moment )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange moment ' + DATA_FIELD, value);
				mntValue = moment(value);
				if ( mntValue.isValid() )
				{
					let DATA_VALUE: Date   = mntValue.toDate();
					this.setState({ FILTER_SEARCH_START_DATE: formatDate(DATA_VALUE, this.DATE_FORMAT), error: null });
				}
				else
				{
					this.setState({ error: L10n.Term('.ERR_INVALID_DATE') });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onFILTER_SEARCH_END_DATE_Change = (value: moment.Moment | string) =>
	{
		try
		{
			let mntValue: moment.Moment = null;
			if ( typeof(value) == 'string' )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange string ' + DATA_FIELD, value);
				if ( Sql.IsEmptyString(value) )
				{
					// 11/17/2019 Paul.  Increment the reset index as clearing the control causes a NaN situation. 
					this.setState({ FILTER_SEARCH_END_DATE: null, error: null });
				}
				else
				{
					let bValidDateParts: boolean = ValidateDateParts(value, this.DATE_FORMAT);
					// 08/05/2019 Paul.  A moment will be valid, even with a single numeric value.  So require 3 parts. 
					mntValue = moment(value, this.DATE_FORMAT);
					if ( bValidDateParts && mntValue.isValid() )
					{
						let DATA_VALUE: Date   = mntValue.toDate();
						this.setState({ FILTER_SEARCH_END_DATE: formatDate(DATA_VALUE, this.DATE_FORMAT), error: null });
					}
					else
					{
						this.setState({ error: L10n.Term('.ERR_INVALID_DATE') });
					}
				}
			}
			else if ( value instanceof moment )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange moment ' + DATA_FIELD, value);
				mntValue = moment(value);
				if ( mntValue.isValid() )
				{
					let DATA_VALUE: Date   = mntValue.toDate();
					this.setState({ FILTER_SEARCH_END_DATE: formatDate(DATA_VALUE, this.DATE_FORMAT), error: null });
				}
				else
				{
					this.setState({ error: L10n.Term('.ERR_INVALID_DATE') });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onSearchPopup = (): void =>
	{
		this.setState({ popupOpen: true });
	}

	private _onSelectChange = (value: { Action: string, ID: string, NAME: string }) =>
	{
		if ( value.Action == 'SingleSelect' )
		{
			try
			{
				this.setState({ popupOpen: false, FILTER_SEARCH_ID: value.ID, FILTER_SEARCH_TEXT: value.NAME });
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
			}
		}
		else if (value.Action == 'Close')
		{
			this.setState({ popupOpen: false });
		}
	}

	public render()
	{
		const { ShowRelated, ShowModule } = this.props;
		const { oPreviewSQL, error } = this.state;
		const { relatedModuleXmlJson, relationshipXmlJson, filterXml, filterXmlJson } = this.state;
		const { MODULE, RELATED, SHOW_QUERY, MODULES_LIST, RELATED_LIST, FILTER_COLUMN_SOURCE_LIST, FILTER_COLUMN_LIST, FILTER_OPERATOR_LIST } = this.state;
		const { popupOpen, FILTER_COLUMN_SOURCE, FILTER_COLUMN, FILTER_OPERATOR, FILTER_OPERATOR_TYPE, FILTER_SEARCH_ID, FILTER_SEARCH_DATA_TYPE, FILTER_SEARCH_TEXT, FILTER_SEARCH_TEXT2, FILTER_SEARCH_START_DATE, FILTER_SEARCH_END_DATE, FILTER_SEARCH_MODULE_TYPE } = this.state;
		const { FILTER_SEARCH_LIST_NAME, FILTER_SEARCH_DROPDOWN_LIST, FILTER_SEARCH_LISTBOX_LIST, FILTER_SEARCH_DROPDOWN, FILTER_SEARCH_LISTBOX, FILTER_SEARCH_MODE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', oReportDesign);
		try
		{
			let inputProps: any =
			{
				type        : 'text', 
				autoComplete: 'off',
				style       : {flex: '2 0 70%', width: '100%', minWidth: '100px'},
				disabled    : false,
				className   : null,  /* 12/10/2019 Paul.  Prevent the default form-control. */
			};
			// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
			let styCheckbox = { transform: 'scale(1.5)', display: 'inline', marginTop: '2px', marginBottom: '6px' };
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			if ( Crm_Config.ToBoolean('enable_legacy_icons') )
			{
				styCheckbox.transform = 'scale(1.0)';
				styCheckbox.marginBottom = '2px';
			}
			// 08/12/2023 Paul.  Use ErrorComponent as JSON.stringify is returning empty object. 
			return (
<div id='divQueryBuilder'>
	<ErrorComponent error={error} />
	<DynamicPopupView
		isOpen={ popupOpen }
		isSearchView={ false }
		fromLayoutName={ '.PopupView' }
		callback={ this._onSelectChange }
		MODULE_NAME={ FILTER_SEARCH_MODULE_TYPE }
	/>
	<table className="tabForm" cellSpacing={ 1 } cellPadding={ 0 } style={ {width: '100%', borderWidth: '0px'} }>
		<tr>
			<td>
				<table cellSpacing={ 0 } cellPadding={ 0 } style={ {borderWidth: '0px', borderCollapse: 'collapse'} }>
					<tr id="ctlQueryBuilder_trModule" style={ {display: (ShowModule === undefined || ShowModule ? 'inline' : 'none')} }>
						<td className="dataLabel" style={ {width: '15%'} }>
							{ L10n.Term("Reports.LBL_MODULE_NAME") }
						</td>
						<td className="dataField" style={ {width: '35%'} }>
							<select
								id="ctlQueryBuilder_lstMODULE"
								tabIndex={ 1 }
								value={ MODULE }
								onChange={ this._onMODULE_Change }
							>
							{ MODULES_LIST
							? MODULES_LIST.map((item, index) => 
							{ return (
								<option key={ 'ctlQueryBuilder_lstMODULE_' + item.MODULE_NAME } value={ item.MODULE_NAME }>{ item.DISPLAY_NAME }</option>);
							})
							: null
							}
							</select>
							<span id="ctlQueryBuilder_lblMODULE">{ MODULE }</span>
						</td>
					</tr>
					<tr id="ctlQueryBuilder_trRelated">
						<td className="dataLabel" style={ {width: '15%'} }>
							{ L10n.Term("Reports.LBL_RELATED") }
						</td>
						<td className="dataField" style={ {width: '35%'} }>
							<select
								id="ctlQueryBuilder_lstRELATED"
								tabIndex={ 3 }
								value={ RELATED }
								onChange={ this._onRELATED_Change }
							>
								<option key='ctlQueryBuilder_lstRELATED_None' value=''>{ L10n.Term('.LBL_NONE') }</option>
							{ RELATED_LIST
							? RELATED_LIST.map((item, index) => 
							{ return (
								<option key={ 'ctlQueryBuilder_lstRELATED_' + item.MODULE_NAME } value={ item.MODULE_NAME }>{ item.DISPLAY_NAME }</option>);
							})
							: null
							}
							</select>
							<span id="ctlQueryBuilder_lblRELATED">{ RELATED }</span>
						</td>
					</tr>
					<tr>
						<td className="dataLabel" style={ {width: '15%'} }>
							{ L10n.Term("Reports.LBL_ADD_FILTER_BUTTON_LABEL")  }
						</td>
						<td className="dataField" style={ {width: '35%'} }>
							<input type="submit" value={ L10n.Term("Reports.LBL_ADD_FILTER_BUTTON_LABEL") } id="ctlQueryBuilder_btnAddFilter" title={ L10n.Term("Reports.LBL_ADD_FILTER_BUTTON_LABEL") } className="button" onClick={ this._onClick_btnAddFilter } />
						</td>
						<td className="dataLabel" style={ {width: '15%'} }>
							{ L10n.Term("Reports.LBL_SHOW_QUERY") }
						</td>
						<td className="dataField" style={ {width: '35%'} }>
							<span className="checkbox">
								<input id="ctlQueryBuilder_chkSHOW_QUERY" type="checkbox" checked={ SHOW_QUERY } onChange={ this._onChange_SHOW_QUERY } />
							</span>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td style={{ paddingTop: '5px', paddingBottom: '5px'} }>
				<table id='ctlQueryBuilder_dgFilters' cellSpacing={ 0 } cellPadding={ 3 } style={ {borderCollapse: 'collapse', border: '1px solid black', width: '100%'} }>
					<tr>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('Reports.LBL_LIST_MODULE_NAME') }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('Reports.LBL_LIST_DATA_FIELD' ) }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('Reports.LBL_LIST_DATA_TYPE'  ) }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('Reports.LBL_LIST_OPERATOR'   ) }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('Reports.LBL_LIST_SEARCH_TEXT') }</td>
						<td style={ {border: '1px solid black'} }>&nbsp;</td>
					</tr>
				{ filterXml && filterXml.Filters && filterXml.Filters.Filter && Array.isArray(filterXml.Filters.Filter)
				? filterXml.Filters.Filter.map((item, index) => 
				{ return (
					<tr>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["MODULE_NAME"]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["DATA_FIELD" ]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["DATA_TYPE"  ]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["OPERATOR"   ]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["SEARCH_TEXT"]) }</td>
						<td style={ {border: '1px solid black', width: '1%', whiteSpace: 'nowrap'} } align='left'>
							<input type='submit' className='button' value={ L10n.Term('.LBL_EDIT_BUTTON_LABEL'       ) } title={ L10n.Term('.LBL_EDIT_BUTTON_LABEL'       ) } onClick={ (e) => this._onFiltersEdit(index) } />
							&nbsp;
							<input type='submit' className='button' value={ L10n.Term('Rules.LBL_REMOVE_BUTTON_LABEL') } title={ L10n.Term('Rules.LBL_REMOVE_BUTTON_LABEL') } onClick={ (e) => this._onFiltersRemove(index) } />
						</td>
					</tr>);
				})
				: null
				}
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table className="tabEditView" style={ {borderWidth: '0px'} }>
					<tr>
						<td valign="top">
							<select
								id="ctlQueryBuilder_lstFILTER_COLUMN_SOURCE"
								tabIndex={ 10 }
								value={ FILTER_COLUMN_SOURCE }
								onChange={ this._onFILTER_COLUMN_SOURCE_LIST_Change }
							>
							{ FILTER_COLUMN_SOURCE_LIST
							? FILTER_COLUMN_SOURCE_LIST.map((item, index) => 
							{ return (
								<option key={ 'ctlQueryBuilder_lstFILTER_COLUMN_SOURCE_' + item.MODULE_NAME } value={ item.MODULE_NAME }>{ item.DISPLAY_NAME }</option>);
							})
							: null
							}
							</select><br />
							<span id="ctlQueryBuilder_lblFILTER_COLUMN_SOURCE">{ FILTER_COLUMN_SOURCE }</span>
						</td>
						<td valign="top">
							<select
								id="ctlQueryBuilder_lstFILTER_COLUMN"
								tabIndex={ 11 }
								value={ FILTER_COLUMN }
								onChange={ this._onFILTER_COLUMN_LIST_Change }
							>
							{ FILTER_COLUMN_LIST
							? FILTER_COLUMN_LIST.map((item, index) => 
							{ return (
								<option key={ 'ctlQueryBuilder_lblFILTER_COLUMN_' + item.NAME } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
							})
							: null
							}
							</select><br />
							<span id="ctlQueryBuilder_lblFILTER_COLUMN">{ FILTER_COLUMN }</span>
						</td>
						<td valign="top">
							<select
								id="ctlQueryBuilder_lstFILTER_OPERATOR"
								tabIndex={ 12 }
								value={ FILTER_OPERATOR }
								onChange={ this._onFILTER_OPERATOR_LIST_Change }
							>
							{ FILTER_OPERATOR_LIST
							? FILTER_OPERATOR_LIST.map((item, index) => 
							{ return (
								<option key={ 'ctlQueryBuilder_lstFILTER_OPERATOR_' + item } value={ item }>{ L10n.ListTerm(this.filterOperatorListName(item, FILTER_OPERATOR_TYPE), item) }</option>);
							})
							: null
							}
							</select>
							<div>
								<span id="ctlQueryBuilder_lblFILTER_OPERATOR_TYPE">{ FILTER_OPERATOR_TYPE }</span>
								<img src={ this.themeURL + "images/spacer.gif" } style={ {borderWidth: '0px', width: '4px'} } />
								<span id="ctlQueryBuilder_lblFILTER_OPERATOR">{ FILTER_OPERATOR }</span>
							</div>
							{ FILTER_OPERATOR == 'enum'
							? <div>{ FILTER_SEARCH_LIST_NAME }</div>
							: null
							}
						</td>
						<td valign="top" style={ {whiteSpace: 'nowrap'} }>
							<table cellSpacing={ 0 } cellPadding={ 0 } style={ {borderWidth: '0px', borderCollapse: 'collapse'} }>
								<tr>
									<td valign="top">
										{ FILTER_SEARCH_MODE == 'text' || FILTER_SEARCH_MODE == 'text2' || FILTER_SEARCH_MODE == 'select'
										? <input type="text" id="ctlQueryBuilder_txtFILTER_SEARCH_TEXT" value={ FILTER_SEARCH_TEXT } readOnly={ FILTER_SEARCH_MODE == 'select' } onChange={ this._onFILTER_SEARCH_TEXT_Change } />
										: null
										}
										{ FILTER_SEARCH_MODE == 'dropdown'
										? <select
											id="lstFILTER_SEARCH_DROPDOWN"
											value={ FILTER_SEARCH_DROPDOWN }
											onChange={ this._onFILTER_SEARCH_DROPDOWN_Change }
										>
										{ FILTER_SEARCH_DROPDOWN_LIST
										? FILTER_SEARCH_DROPDOWN_LIST.map((item, index) => 
										{ return (
											<option key={ 'ctlQueryBuilder_lstFILTER_SEARCH_DROPDOWN_' + item } value={ item }>{ L10n.ListTerm(FILTER_SEARCH_LIST_NAME, item) }</option>);
										})
										: null
										}
										</select>
										: null
										}
										{ FILTER_SEARCH_MODE == 'listbox'
										? <select
											id="lstFILTER_SEARCH_LISTBOX"
											multiple={ true }
											size={ 4 }
											value={ FILTER_SEARCH_LISTBOX }
											onChange={ this._onFILTER_SEARCH_LISTBOX_Change }
										>
										{ FILTER_SEARCH_LISTBOX_LIST
										? FILTER_SEARCH_LISTBOX_LIST.map((item, index) => 
										{ return (
											<option key={ 'ctlQueryBuilder_lstFILTER_SEARCH_LISTBOX_' + item } value={ item }>{ L10n.ListTerm(FILTER_SEARCH_LIST_NAME, item) }</option>);
										})
										: null
										}
										</select>
										: null
										}
										{ FILTER_SEARCH_MODE == 'date' || FILTER_SEARCH_MODE == 'date2'
										? <DateTime
											value={ FILTER_SEARCH_START_DATE != null ? moment(FILTER_SEARCH_START_DATE) : null }
											initialViewDate={ FILTER_SEARCH_START_DATE != null ? moment(FILTER_SEARCH_START_DATE) : null }
											onChange={ this._onFILTER_SEARCH_START_DATE_Change }
											dateFormat={ this.DATE_FORMAT }
											timeFormat={ false }
											input={ true }
											closeOnSelect={ true }
											strictParsing={ true }
											inputProps={ inputProps }
											locale={ Security.USER_LANG().substring(0, 2) }
										/>
										: null
										}
									</td>
									{ FILTER_SEARCH_MODE == 'text2' || FILTER_SEARCH_MODE == 'date2'
									? <td valign="top">
										<span style={ {paddingLeft: '4px', paddingRight: '4px', paddingTop: '8px'} }>{ L10n.Term('Schedulers.LBL_AND') }</span>
									</td>
									: null
									}
									<td valign="top">
										{ FILTER_SEARCH_MODE == 'text2'
										? <input type="text" id="ctlQueryBuilder_txtFILTER_SEARCH_TEXT2" value={ FILTER_SEARCH_TEXT2 } onChange={ this._onFILTER_SEARCH_TEXT2_Change } />
										: null
										}
										{ FILTER_SEARCH_MODE == 'date2'
										? <DateTime
											value={ FILTER_SEARCH_END_DATE != null ? moment(FILTER_SEARCH_END_DATE) : null }
											initialViewDate={ FILTER_SEARCH_END_DATE != null ? moment(FILTER_SEARCH_END_DATE) : null }
											onChange={ this._onFILTER_SEARCH_END_DATE_Change }
											dateFormat={ this.DATE_FORMAT }
											timeFormat={ false }
											input={ true }
											closeOnSelect={ true }
											strictParsing={ true }
											inputProps={ inputProps }
											locale={ Security.USER_LANG().substring(0, 2) }
										/>
										: null
										}
										{ FILTER_SEARCH_MODE == 'select'
										? <input type='submit'
											className='button'
											value={ L10n.Term('.LBL_SELECT_BUTTON_LABEL') }
											title={ L10n.Term('.LBL_SELECT_BUTTON_TITLE') }
											onClick={ (e) => this._onSearchPopup() }
											style={ {marginLeft: '4px'} }
										/>
										: null
										}
									</td>
								</tr>
							</table>
							<span id="ctlQueryBuilder_lblFILTER_ID"></span>
						</td>
						<td valign="top">
							<input type='submit' value={ L10n.Term('.LBL_UPDATE_BUTTON_LABEL') } title={ L10n.Term('.LBL_UPDATE_BUTTON_TITLE') } className='button' onClick={ this._onFiltersUpdate } />
						</td>
						<td valign="top">
							<input type='submit' value={ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') } title={ L10n.Term('.LBL_CANCEL_BUTTON_TITLE') } className='button' onClick={ this._onFiltersCancel } />
						</td>
						<td style={ {width: '80%'} }></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	{ SHOW_QUERY
	? <React.Fragment>
		<br />
		<table cellPadding={ 3 } cellSpacing={ 0 } style={ {width: '100%', backgroundColor: 'LightGrey', border: '1px solid black'} }>
			<tr>
				<td>
					<pre style={ {whiteSpace: 'pre-wrap'} }><b>{ oPreviewSQL }</b></pre>
				</td>
			</tr>
		</table>
	</React.Fragment>
	: null
	}
	{ bDebug && SHOW_QUERY
	? <div>
		<div id='divFilterXmlDump' dangerouslySetInnerHTML={ {__html: filterXmlJson } } style={ {marginTop: '20px', border: '1px solid black'} }></div>
	</div>
	: null
	}
	{ bDebug && SHOW_QUERY
	? <div>
		<div id='divFilterXmlDump' dangerouslySetInnerHTML={ {__html: relationshipXmlJson } } style={ {marginTop: '20px', border: '1px solid black'} }></div>
	</div>
	: null
	}
	{ bDebug && SHOW_QUERY
	? <div>
		<div id='divFilterXmlDump' dangerouslySetInnerHTML={ {__html: relatedModuleXmlJson } } style={ {marginTop: '20px', border: '1px solid black'} }></div>
	</div>
	: null
	}
</div>
			);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.render', error);
			return (<span>{ error.message }</span>);
		}
	}
}

