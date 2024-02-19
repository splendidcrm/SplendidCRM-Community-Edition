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
import { XMLParser, XMLBuilder }                         from 'fast-xml-parser'                     ;
import 'react-datetime/css/react-datetime.css';
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                               from '../../../scripts/Sql'                ;
import L10n                                              from '../../../scripts/L10n'               ;
import Security                                          from '../../../scripts/Security'           ;
import Credentials                                       from '../../../scripts/Credentials'        ;
import SplendidCache                                     from '../../../scripts/SplendidCache'      ;
import { Crm_Config }                                    from '../../../scripts/Crm'                ;
import { dumpObj, uuidFast, EndsWith }                   from '../../../scripts/utility'            ;
import { CreateSplendidRequest, GetSplendidResult }      from '../../../scripts/SplendidRequest'    ;
// 4. Components and Views. 
import ErrorComponent                                    from '../../../components/ErrorComponent'  ;
import DynamicPopupView                                  from '../../../views/DynamicPopupView'     ;
import DumpXOML                                          from '../../../components/DumpXOML'        ;

let bDebug: boolean = false;

interface IXomlBuilderProps
{
	row                         : any         ;
	DATA_FIELD                  : string      ;
	PARENT_ID                   : string      ;
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
	oPreviewSQL                : string      ;
	oPreviewXOML               : string      ;
	// 07/04/2016 Paul.  Special case when not showing selected fields. 
	error?                     : any         ;
	MODULE                     : string      ;
	RELATED                    : string      ;
	SHOW_XOML                  : boolean     ;
	reportXml                  : any         ;
	reportXmlJson              : string      ;
	relatedModuleXml           : any         ;
	relatedModuleXmlJson       : any         ;
	relationshipXml            : any         ;
	relationshipXmlJson        : any         ;
	filterXml                  : any         ;
	filterXmlJson              : any         ;
	filterXmlEditIndex         : number      ;
	attachmentXml              : any         ;
	attachmentXmlEditIndex     : number      ;
	popupOpen                  : boolean     ;
	MODULES_LIST               : any[]       ;
	RELATED_LIST               : any[]       ;
	FILTER_COLUMN_SOURCE_LIST  : any[]       ;
	FILTER_COLUMN_LIST         : any[]       ;
	FILTER_COLUMN_LIST_NAMES   : any         ;
	FILTER_OPERATOR_LIST       : any[]       ;
	FILTER_ID                  : string      ;
	FILTER_COLUMN_SOURCE       : string      ;
	FILTER_COLUMN              : string      ;
	FILTER_OPERATOR            : string      ;
	FILTER_OPERATOR_TYPE       : string      ;
	RENDER_FORMAT_LIST         : string[]    ;
	REPORT_ID                  : string      ;
	REPORT_NAME                : string      ;
	REPORT_PARAMETERS          : string      ;
	RENDER_FORMAT              : string      ;
}

export default class XomlUserBuilder extends React.Component<IXomlBuilderProps, IQueryBuilderState>
{
	private _isMounted    : boolean = false;
	private themeURL      : string;
	private DATE_FORMAT   : string;
	private FILTER_COLUMN_LIST_CACHE: any = {};
	private FILTER_COLUMN_SOURCE_LIST_BASE: any[] = [];

	public get data(): any
	{
		const { RELATED, filterXml, attachmentXml, relatedModuleXml, relationshipXml } = this.state;
		let row: any = { RELATED, filterXml, attachmentXml, relatedModuleXml, relationshipXml };
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

	constructor(props: IXomlBuilderProps)
	{
		super(props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
		this.DATE_FORMAT = Security.USER_DATE_FORMAT();
		let error: any = 'Loading modules.';

		let RENDER_FORMAT_LIST: string[] = L10n.GetList('report_render_format');
		let RENDER_FORMAT: string = '';
		if ( RENDER_FORMAT_LIST != null && RENDER_FORMAT_LIST.length > 0 )
		{
			RENDER_FORMAT = RENDER_FORMAT_LIST[0];
		}
		this.state =
		{
			oPreviewSQL                : null,
			oPreviewXOML               : null,
			error                      ,
			MODULE                     : null,
			RELATED                    : null,
			SHOW_XOML                 : Sql.ToBoolean(localStorage.getItem('XomlBuilder.SHOW_XOML')),
			reportXml                  : {},
			reportXmlJson              : null,
			relatedModuleXml           : null,
			relatedModuleXmlJson       : null,
			relationshipXml            : null,
			relationshipXmlJson        : null,
			filterXml                  : null,
			filterXmlJson              : null,
			filterXmlEditIndex         : -1,
			attachmentXml              : null,
			attachmentXmlEditIndex     : -1,
			popupOpen                  : false,
			MODULES_LIST               : [],
			RELATED_LIST               : [],
			FILTER_COLUMN_SOURCE_LIST  : [],
			FILTER_COLUMN_LIST         : [],
			FILTER_COLUMN_LIST_NAMES   : {},
			FILTER_OPERATOR_LIST       : [],
			FILTER_ID                  : null,
			FILTER_COLUMN_SOURCE       : null,
			FILTER_COLUMN              : null,
			FILTER_OPERATOR            : null,
			FILTER_OPERATOR_TYPE       : null,
			RENDER_FORMAT_LIST         ,
			REPORT_ID                  : null,
			REPORT_NAME                : null,
			REPORT_PARAMETERS          : null,
			RENDER_FORMAT              ,
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
				// 02/18/2024 Paul.  parser v4 creates object for Value. 
				// 02/18/2024 Paul.  When tag name is also Value, v4 creates an array, which is wrong and bad. 
				//<CustomProperties>
				//	<CustomProperty>
				//		<Name>crm:Module</Name>
				//		<Value>Accounts</Value>
				//	</CustomProperty>
				//	<CustomProperty>
				//		<Name>crm:Related</Name>
				//		<Value>
				//	</Value>
				//	</CustomProperty>
				//</CustomProperties>
				//textNodeName       : 'Value',
				ignoreAttributes   : false  ,
				ignoreNameSpace    : true   ,
				parseAttributeValue: true   ,
				trimValues         : false  ,
			};
			// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
			const parser = new XMLParser(options);

			let MODULE               : string  = (row ? row['BASE_MODULE'] : null);
			let RELATED              : string  = null;
			let reportXml            : any     = null;
			let reportXmlJson        : string  = null;
			let relatedModuleXml     : any     = null;
			let relatedModuleXmlJson : any     = null;
			let relationshipXml      : any     = null;
			let relationshipXmlJson  : any     = null;
			let filterXml            : any     = null;
			let attachmentXml        : any     = null;
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
							case 'crm:Module'        :  MODULE           = sValue;  break;
							case 'crm:Related'       :  RELATED          = sValue;  break;
							case 'crm:RelatedModules':
								// 05/15/2021 Paul.  Ignore data from file and just use latest QueryBuilderState. 
								//sValue = this.decodeHTML(sValue);
								//relatedModuleXml = parser.parse(sValue);
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
							case 'crm:ReportAttachments'       :
								sValue = this.decodeHTML(sValue);
								// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
								attachmentXml        = parser.parse(sValue);
								// 05/14/2021 Paul.  If there is only one, convert to an array. 
								if ( attachmentXml.ReportAttachments && attachmentXml.ReportAttachments.Report && !Array.isArray(attachmentXml.ReportAttachments.Report) )
								{
									let Attachment1: any = attachmentXml.ReportAttachments.Report;
									attachmentXml.ReportAttachments.Report = [];
									attachmentXml.ReportAttachments.Report.push(Attachment1);
								}
								//attachmentXmlJson = dumpObj(attachmentXml, 'attachmentXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
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

			RELATED_LIST.unshift({ MODULE_NAME: '', DISPLAY_NAME: L10n.Term('.LBL_NONE') })
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
				// 06/17/2021 Paul.  We also need to cache FILTER_COLUMN_SOURCE_LIST to speed rest. 
				this.FILTER_COLUMN_SOURCE_LIST_BASE = FILTER_COLUMN_SOURCE_LIST;
				FILTER_COLUMN_SOURCE = FILTER_COLUMN_SOURCE_LIST[0].MODULE_NAME;
				// 05/15/2021 Paul.  Cache the FILTER_COLUMN_LIST. 
				this.FILTER_COLUMN_LIST_CACHE[FILTER_COLUMN_SOURCE] = FILTER_COLUMN_LIST;
			}
			if ( FILTER_COLUMN_LIST != null && FILTER_COLUMN_LIST.length > 0 )
			{
				FILTER_COLUMN = FILTER_COLUMN_LIST[0].NAME;
			}

			let oPreviewSQL : string = await this.getReportSQL(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, DisplayColumns);
			let oPreviewXOML: string = await this.getWorkflowXOML(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, attachmentXml);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', this.designerModules);
			this.setState(
			{
				oPreviewSQL              ,
				oPreviewXOML             ,
				error                    : null,
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
				attachmentXml            ,
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
				filterXmlEditIndex       : -1,
				attachmentXmlEditIndex   : -1,
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

	shouldComponentUpdate(nextProps: IXomlBuilderProps, nextState: IQueryBuilderState)
	{
		if ( this.props.row != null && nextProps.row != null )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate', this.props.row, nextProps.row);
			if ( this.props.row['BASE_MODULE'] != nextProps.row['BASE_MODULE'] && nextProps.row['BASE_MODULE'] != this.state.MODULE )
			{
				let MODULE: string = nextProps.row['BASE_MODULE'];
				this.moduleChanged(nextProps.Modules, MODULE, '', true);
			}
			else if ( this.props.DesignWorkflow && this.props.row['TYPE'] != nextProps.row['TYPE'] )
			{
				let MODULE: string = nextProps.row['BASE_MODULE'];
				this.moduleChanged(nextProps.Modules, MODULE, '', true);
			}
			else if ( JSON.stringify(this.props.DisplayColumns) != JSON.stringify(nextProps.DisplayColumns) )
			{
				let { MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, attachmentXml } = this.state;
				this.getReportSQL(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, nextProps.DisplayColumns).then((oPreviewSQL: string) =>
				{
					this.getWorkflowXOML(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, attachmentXml).then((oPreviewXOML: string) =>
					{
						this.setState(
						{
							oPreviewSQL ,
							oPreviewXOML,
						});
					});
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
		const { relatedModuleXml, relationshipXml, attachmentXml } = this.state
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moduleChanged ' + MODULE, RELATED);
		let { filterXml, filterXmlJson, filterXmlEditIndex } = this.state;
		try
		{
			let results: any = await this.getQueryBuilderState(Modules, MODULE, RELATED, this.constructor.name + '.moduleChanged');
			let MODULES_LIST             : any[] = results.MODULES_LIST             ;
			let RELATED_LIST             : any[] = results.RELATED_LIST             ;
			let FILTER_COLUMN_SOURCE_LIST: any[] = results.FILTER_COLUMN_SOURCE_LIST;
			let FILTER_COLUMN_LIST       : any[] = results.FILTER_COLUMN_LIST       ;
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
			if ( bClearFilters )
			{
				filterXml          = null;
				filterXmlJson      = '';
				filterXmlEditIndex = -1;
			}
			// 05/15/2021 Paul.  Cache the FILTER_COLUMN_LIST. 
			this.FILTER_COLUMN_LIST_CACHE[FILTER_COLUMN_SOURCE_LIST[0].MODULE_NAME] = FILTER_COLUMN_LIST;
			let oPreviewSQL : string = await this.getReportSQL(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, DisplayColumns);
			let oPreviewXOML: string = await this.getWorkflowXOML(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, attachmentXml);
			this.setState(
			{
				MODULE                   ,
				RELATED                  ,
				MODULES_LIST             ,
				RELATED_LIST             ,
				FILTER_COLUMN_SOURCE_LIST,
				FILTER_COLUMN_SOURCE     ,
				FILTER_COLUMN_LIST       ,
				FILTER_COLUMN            ,
				filterXml                ,
				filterXmlJson            ,
				filterXmlEditIndex       ,
				oPreviewSQL              ,
				oPreviewXOML             ,
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
			let res  = await CreateSplendidRequest('Administration/WorkflowAlertShells/Rest.svc/GetQueryBuilderState?Modules=' + Sql.ToString(Modules) + '&MODULE_NAME=' + Sql.ToString(MODULE) + '&RELATED=' + Sql.ToString(RELATED) + '&TYPE=' + Sql.ToString(TYPE), 'GET');
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

	private getWorkflowFilterColumns = async (MODULE_NAME: string, TABLE_ALIAS: string) =>
	{
		const { DesignWorkflow } = this.props;
		try
		{
			let url : string = (DesignWorkflow ? 'Administration/WorkflowAlertShells/Rest.svc/GetWorkflowFilterColumns' : 'Reports/Rest.svc/getWorkflowFilterColumns');
			let res  = await CreateSplendidRequest(url + '?MODULE_NAME=' + MODULE_NAME + '&TABLE_ALIAS=' + TABLE_ALIAS, 'GET');
			let json = await GetSplendidResult(res);
			let obj: any = json.d;
			return obj.results;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.getWorkflowFilterColumns', error);
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
			let res  = await CreateSplendidRequest('Administration/Workflows/Rest.svc/BuildReportSQL', 'POST', 'application/octet-stream', sBody);
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

	private getWorkflowXOML = async (MODULE: string, RELATED: string, filterXml: any, relatedModuleXml: any, relationshipXml: any, attachmentXml: any) =>
	{
		const { PARENT_ID, row } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getWorkflowXOML', row);
		let oPreviewXOML: string = null;
		try
		{
			// 06/19/2021 Paul.  Include the EditView row as the following are needed: ALERT_TYPE, ALERT_TEXT, SOURCE_TYPE, CUSTOM_TEMPLATE_ID. 
			let obj: any = Object.assign({}, row, 
			{
				// 06/05/2021 Paul.  Keep using MODULE to match Reports. 
				MODULE          ,
				RELATED         ,
				PARENT_ID       ,
				filterXml       ,
				relatedModuleXml,
				relationshipXml ,
				attachmentXml   ,
			});
			// 06/19/2021 Paul.  Since the field is required when enabled, we are getting the first item in list even when disabled, so clear it. 
			if ( obj['SOURCE_TYPE'] == 'normal message' )
				obj.CUSTOM_TEMPLATE_ID = null;
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Administration/WorkflowAlertShells/Rest.svc/BuildAlertXOML', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getWorkflowXOML', json);
			oPreviewXOML = json.d;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.getWorkflowXOML', error);
			this.setState({ error });
		}
		return oPreviewXOML;
	}

	private decodeHTML = (html) =>
	{
		var txt = document.createElement('textarea');
		txt.innerHTML = html;
		return txt.value;
	}

	private _onChange_SHOW_XOML = (ev: React.ChangeEvent<HTMLInputElement>) =>
	{
		let SHOW_XOML = ev.target.checked;
		localStorage.setItem('XomlBuilder.SHOW_XOML', SHOW_XOML ? 'true' : 'false');
		this.setState({ SHOW_XOML });
	}

	private ResetSearchText = () =>
	{
		let { FILTER_COLUMN_LIST } = this.state;
		let RELATED                : string = '';
		let FILTER_COLUMN_SOURCE   : string = '';
		let FILTER_COLUMN          : string = '';
		let FILTER_OPERATOR        : string = '';
		let FILTER_OPERATOR_TYPE   : string = '';
		let FILTER_OPERATOR_LIST   : string[] = null;
		// 06/17/2021 Paul.  We also need to cache FILTER_COLUMN_SOURCE_LIST to speed rest. 
		let FILTER_COLUMN_SOURCE_LIST: any[] = this.FILTER_COLUMN_SOURCE_LIST_BASE;

		if ( FILTER_COLUMN_SOURCE_LIST != null && FILTER_COLUMN_SOURCE_LIST.length > 0 )
		{
			FILTER_COLUMN_SOURCE = FILTER_COLUMN_SOURCE_LIST[0].MODULE_NAME;
			FILTER_COLUMN_LIST   = this.FILTER_COLUMN_LIST_CACHE[FILTER_COLUMN_SOURCE];
		}
		if ( FILTER_COLUMN_LIST != null && FILTER_COLUMN_LIST.length > 0 )
		{
			FILTER_COLUMN = FILTER_COLUMN_LIST[0].NAME;
		}
		if ( FILTER_OPERATOR_LIST != null && FILTER_OPERATOR_LIST.length > 0 )
		{
			FILTER_OPERATOR = FILTER_OPERATOR_LIST[0];
		}
		let arrModule         : string[] = FILTER_COLUMN_SOURCE.split(' ');
		let sModule           : string   = arrModule[0];
		let sTableAlias       : string   = arrModule[1];
		if ( sTableAlias == "USERS_ALL" || sTableAlias == "TEAMS" || sTableAlias == "ACL_ROLES" )
		{
			FILTER_OPERATOR_TYPE = 'workflow_alert';
			FILTER_OPERATOR_LIST    = L10n.GetList(FILTER_OPERATOR_TYPE + '_operator_dom');
			if ( FILTER_OPERATOR_LIST && FILTER_OPERATOR_LIST.length > 0 )
			{
				FILTER_OPERATOR = FILTER_OPERATOR_LIST[0];
			}
		}
		else
		{
			let row: any = this.getFilterColumn(FILTER_COLUMN_SOURCE, FILTER_COLUMN);
			// 06/17/2021 Paul.  Operator list will be empty if column not found. 
			if ( row != null )
			{
				FILTER_OPERATOR_TYPE = 'workflow_alert';
				FILTER_OPERATOR_LIST    = L10n.GetList(FILTER_OPERATOR_TYPE + '_operator_dom');
				if ( FILTER_OPERATOR_LIST && FILTER_OPERATOR_LIST.length > 0 )
				{
					FILTER_OPERATOR = FILTER_OPERATOR_LIST[0];
				}
			}
		}
		
		// 06/16/2021 Paul.  Must reset all search values. 
		this.setState(
		{
			RELATED                  ,
			FILTER_ID                : '',
			FILTER_COLUMN_SOURCE_LIST,
			FILTER_COLUMN_LIST       ,
			FILTER_COLUMN_SOURCE     ,
			FILTER_COLUMN            ,
			FILTER_OPERATOR_LIST     ,
			FILTER_OPERATOR          ,
			FILTER_OPERATOR_TYPE     ,
			filterXmlEditIndex       : -1   ,
			error                    : null ,
		}, () =>
		{
			this.BindSearchText();
		});
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

	private filterRelatedChanged = async (RELATED: string) =>
	{
		const { MODULE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.filterRelatedChanged ' + RELATED);
		try
		{
			let results: any = await this.getQueryBuilderState(this.props.Modules, MODULE, RELATED, this.constructor.name + '.filterRelatedChanged');
			let MODULES_LIST             : any[] = results.MODULES_LIST             ;
			let RELATED_LIST             : any[] = results.RELATED_LIST             ;
			let FILTER_COLUMN_SOURCE_LIST: any[] = results.FILTER_COLUMN_SOURCE_LIST;
			let FILTER_COLUMN_LIST       : any[] = results.FILTER_COLUMN_LIST       ;
			let FILTER_COLUMN_SOURCE     : string = null;
			let FILTER_COLUMN            : string = null;
			let FILTER_OPERATOR_TYPE     : string = null;
			let FILTER_OPERATOR_LIST     : string[] = [];
			let FILTER_OPERATOR          : string = null;
			if ( FILTER_COLUMN_SOURCE_LIST != null && FILTER_COLUMN_SOURCE_LIST.length > 0 )
			{
				FILTER_COLUMN_SOURCE = FILTER_COLUMN_SOURCE_LIST[0].MODULE_NAME;
				// 05/15/2021 Paul.  Cache the FILTER_COLUMN_LIST. 
				this.FILTER_COLUMN_LIST_CACHE[FILTER_COLUMN_SOURCE] = FILTER_COLUMN_LIST;
			}
			// 06/04/2021 Paul.  Must update column when list changes. 
			if ( FILTER_COLUMN_LIST != null && FILTER_COLUMN_LIST.length > 0 )
			{
				this.FILTER_COLUMN_LIST_CACHE[RELATED] = FILTER_COLUMN_LIST;
				FILTER_COLUMN = FILTER_COLUMN_LIST[0].NAME;
			}
			if ( FILTER_COLUMN_LIST!= null && FILTER_COLUMN_LIST.length > 0 )
			{
				FILTER_OPERATOR_TYPE = 'workflow_alert';
				FILTER_OPERATOR_LIST    = L10n.GetList(FILTER_OPERATOR_TYPE + '_operator_dom');
				if ( FILTER_OPERATOR_LIST && FILTER_OPERATOR_LIST.length > 0 )
				{
					FILTER_OPERATOR = FILTER_OPERATOR_LIST[0];
				}
			}
			this.setState(
			{
				FILTER_COLUMN_SOURCE_LIST,
				FILTER_COLUMN_SOURCE     ,
				FILTER_COLUMN_LIST       ,
				FILTER_COLUMN            ,
				FILTER_OPERATOR_TYPE     ,
				FILTER_OPERATOR_LIST     ,
				FILTER_OPERATOR          ,
			}, () =>
			{
				this.BindSearchText();
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.filterRelatedChanged', error);
			this.setState({ error });
		}
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
			FILTER_COLUMN_LIST = await this.getWorkflowFilterColumns(sModule, sTableAlias);
			this.FILTER_COLUMN_LIST_CACHE[FILTER_COLUMN_SOURCE] = FILTER_COLUMN_LIST;
		}
		if ( FILTER_COLUMN_LIST!= null && FILTER_COLUMN_LIST.length > 0 )
		{
			let row: any = FILTER_COLUMN_LIST[0];
			let FILTER_COLUMN          : string = row['NAME'];
			let FILTER_OPERATOR_TYPE   : string = 'workflow_alert';
			let FILTER_OPERATOR        : string = '';
			let FILTER_OPERATOR_LIST   : string[] = L10n.GetList(FILTER_OPERATOR_TYPE + '_operator_dom');
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
			let FILTER_OPERATOR_TYPE   : string = 'workflow_alert';
			let FILTER_OPERATOR        : string = '';
			let FILTER_OPERATOR_LIST   : string[] = L10n.GetList(FILTER_OPERATOR_TYPE + '_operator_dom');
			if ( FILTER_OPERATOR_LIST && FILTER_OPERATOR_LIST.length > 0 )
			{
				FILTER_OPERATOR = FILTER_OPERATOR_LIST[0];
			}
			this.setState(
			{
				FILTER_OPERATOR_LIST     ,
				FILTER_OPERATOR          ,
				FILTER_OPERATOR_TYPE     ,
			}, () =>
			{
				this.BindSearchText();
			});
		}
	}

	private filterOperatorListName = (item, FILTER_OPERATOR_TYPE) =>
	{
		let sListName: string = FILTER_OPERATOR_TYPE + '_operator_dom';
		return sListName;
	}

	private BindSearchText = () =>
	{
	}

	private _onFiltersEdit = async (index: number) =>
	{
		let { filterXml } = this.state;

		let FILTER_ID                  : string  = '';
		let FILTER_COLUMN_SOURCE       : string  = '';
		let FILTER_COLUMN              : string  = '';
		let FILTER_OPERATOR            : string  = '';
		let FILTER_OPERATOR_TYPE       : string  = '';
		let RELATED                    : string  = '';
		if ( filterXml && filterXml.Filters && filterXml.Filters.Filter && index < filterXml.Filters.Filter.length )
		{
			let sFILTER_ID        : string   = '';
			let sACTION_TYPE      : string   = '';
			let sRELATIONSHIP_NAME: string   = '';
			let sMODULE_NAME      : string   = '';
			let sDATA_FIELD       : string   = '';
			let sDATA_TYPE        : string   = '';
			let sOPERATOR         : string   = '';
			let sSEARCH_TEXT1     : string   = '';
			let sSEARCH_TEXT2     : string   = '';
			let arrSEARCH_TEXT    : string[] = [];
			let SEARCH_TEXT_VALUES: any = null;

			sACTION_TYPE         = Sql.ToString(filterXml.Filters.Filter[index]['ACTION_TYPE'         ]);
			sRELATIONSHIP_NAME   = Sql.ToString(filterXml.Filters.Filter[index]['RELATIONSHIP_NAME'   ]);
			sFILTER_ID           = Sql.ToString(filterXml.Filters.Filter[index]['ID'                  ]);
			sMODULE_NAME         = Sql.ToString(filterXml.Filters.Filter[index]['MODULE_NAME'         ]);
			sDATA_FIELD          = Sql.ToString(filterXml.Filters.Filter[index]['DATA_FIELD'          ]);
			sDATA_TYPE           = Sql.ToString(filterXml.Filters.Filter[index]['DATA_TYPE'           ]);
			sOPERATOR            = Sql.ToString(filterXml.Filters.Filter[index]['OPERATOR'            ]);
			//sSEARCH_TEXT         = Sql.ToString(filterXml.Filters.Filter[index]['SEARCH_TEXT'         ]);
			SEARCH_TEXT_VALUES   = filterXml.Filters.Filter[index]['SEARCH_TEXT_VALUES'];
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

			RELATED                 = sRELATIONSHIP_NAME;
			FILTER_COLUMN           = sDATA_FIELD ;
			FILTER_ID               = sFILTER_ID  ;
			FILTER_COLUMN_SOURCE    = sMODULE_NAME;
			FILTER_COLUMN           = sDATA_FIELD ;
			FILTER_OPERATOR         = sOPERATOR   ;
			FILTER_OPERATOR_TYPE    = sDATA_TYPE  ;
		}
		let MODULE: string = '';
		if ( !Sql.IsEmptyString(RELATED) )
			MODULE = RELATED;
		else
			MODULE = FILTER_COLUMN_SOURCE;
		let arrModule         : string[] = MODULE.split(' ');
		let sModule           : string   = arrModule[0];
		let sTableAlias       : string   = arrModule[1];
		let FILTER_COLUMN_LIST: any[]    = null;
		FILTER_COLUMN_LIST = this.FILTER_COLUMN_LIST_CACHE[MODULE];
		if ( FILTER_COLUMN_LIST == null )
		{
			FILTER_COLUMN_LIST = await this.getWorkflowFilterColumns(sModule, sTableAlias);
			this.FILTER_COLUMN_LIST_CACHE[MODULE] = FILTER_COLUMN_LIST;
		}
		let FILTER_OPERATOR_LIST   : string[] = L10n.GetList(FILTER_OPERATOR_TYPE + '_operator_dom');
		this.setState(
		{
			FILTER_ID               ,
			FILTER_COLUMN_SOURCE    ,
			FILTER_COLUMN           ,
			FILTER_OPERATOR         ,
			FILTER_OPERATOR_TYPE    ,
			RELATED                 ,
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
		let { MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, attachmentXml } = this.state;
		try
		{
			if ( filterXml && filterXml.Filters && filterXml.Filters.Filter && index < filterXml.Filters.Filter.length )
			{
				filterXml.Filters.Filter.splice(index, 1);
				let filterXmlJson = dumpObj(filterXml, 'filterXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
				this.ResetSearchText();
				let oPreviewSQL : string = await this.getReportSQL(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, DisplayColumns);
				let oPreviewXOML: string = await this.getWorkflowXOML(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, attachmentXml);
				this.setState(
				{
					filterXml    ,
					filterXmlJson,
					oPreviewSQL  ,
					oPreviewXOML ,
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onFiltersRemove', error);
			this.setState({ error });
		}
	}

	private _onFiltersUpdate = async () =>
	{
		const { DisplayColumns } = this.props;
		const { MODULE, RELATED, FILTER_ID, FILTER_COLUMN_SOURCE, FILTER_COLUMN, FILTER_OPERATOR, FILTER_COLUMN_LIST } = this.state;

		let { filterXml, relatedModuleXml, relationshipXml, filterXmlEditIndex, attachmentXml } = this.state;
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
				let sFILTER_ID        : string = FILTER_ID;
				let sUSER_TYPE        : string = '';
				let sRELATIONSHIP_NAME: string = RELATED             ;
				let sMODULE_NAME      : string = !Sql.IsEmptyString(RELATED) ? Sql.ToString(RELATED) : Sql.ToString(FILTER_COLUMN_SOURCE);
				let sDATA_FIELD       : string = FILTER_COLUMN       ;
				let sOPERATOR         : string = FILTER_OPERATOR     ;
				let sSEARCH_TEXT      : string = FILTER_COLUMN       ;
				let sRECIPIENT_NAME   : string = FILTER_COLUMN       ;
				let arrModule         : string[] = sMODULE_NAME.split(' ');
				let sModule           : string = arrModule[0];
				let sTableAlias       : string = arrModule[1];
				if ( sTableAlias == "USERS_ALL" )
					sUSER_TYPE = "specific_user";
				else if ( sTableAlias == "TEAMS" )
					sUSER_TYPE = "specific_team";
				else if ( sTableAlias == "ACL_ROLES" )
					sUSER_TYPE = "specific_role";
				// 12/04/2008 Paul.  We don't need rel_user because a user can be looked up by record. 
				//else if ( sMODULE_NAME != BaseModule + " " + Sql.ToString(Application["Modules." + sModule + ".TableName"]) )
				//	sUSER_TYPE = "rel_user";
				// 10/11/2008 Paul.  Allow sending an alert to records based on ID, PARENT_ID, ACCOUNT_ID or CONTACT_ID. 
				else if ( EndsWith(sDATA_FIELD, ".ID") || EndsWith(sDATA_FIELD, ".PARENT_ID") || EndsWith(sDATA_FIELD, ".CONTACT_ID") || EndsWith(sDATA_FIELD, ".ACCOUNT_ID") )
					sUSER_TYPE = "record";
				// 06/20/2014 Paul.  Allow text columns to be added to the list of recipients. 
				else if ( EndsWith(sDATA_FIELD, ".CREATED_BY_ID") || EndsWith(sDATA_FIELD, ".MODIFIED_USER_ID") || EndsWith(sDATA_FIELD, ".ASSIGNED_USER_ID")|| EndsWith(sDATA_FIELD, ".TEAM_ID") )
					sUSER_TYPE = "current_user";
				else
					sUSER_TYPE = "custom_field";
				if ( FILTER_COLUMN_LIST != null )
				{
					for ( let i: number = 0; i < FILTER_COLUMN_LIST.length; i++ )
					{
						if ( FILTER_COLUMN_LIST[i].NAME == FILTER_COLUMN )
						{
							sRECIPIENT_NAME = FILTER_COLUMN_LIST[i].DISPLAY_NAME;
							break;
						}
					}
				}

				if ( filterXml.Filters.Filter[filterXmlEditIndex]['ID'] === undefined )
				{
					filterXml.Filters.Filter[filterXmlEditIndex]['ID'] = uuidFast();
				}
				if ( sTableAlias == "USERS_ALL" || sTableAlias == "TEAMS" || sTableAlias == "ACL_ROLES" )
				{
					filterXml.Filters.Filter[filterXmlEditIndex]['ACTION_TYPE'       ] = sUSER_TYPE        ;
					filterXml.Filters.Filter[filterXmlEditIndex]['RELATIONSHIP_NAME' ] = sRELATIONSHIP_NAME;
					filterXml.Filters.Filter[filterXmlEditIndex]['MODULE'            ] = sModule           ;
					filterXml.Filters.Filter[filterXmlEditIndex]['MODULE_NAME'       ] = sMODULE_NAME      ;
					filterXml.Filters.Filter[filterXmlEditIndex]['TABLE_NAME'        ] = ''                ;
					filterXml.Filters.Filter[filterXmlEditIndex]['DATA_FIELD'        ] = ''                ;
					filterXml.Filters.Filter[filterXmlEditIndex]['FIELD_NAME'        ] = ''                ;
					filterXml.Filters.Filter[filterXmlEditIndex]['DATA_TYPE'         ] = ''                ;
					filterXml.Filters.Filter[filterXmlEditIndex]['OPERATOR'          ] = sOPERATOR         ;
					filterXml.Filters.Filter[filterXmlEditIndex]['SEARCH_TEXT'       ] = sSEARCH_TEXT      ;
					filterXml.Filters.Filter[filterXmlEditIndex]['RECIPIENT_NAME'    ] = sRECIPIENT_NAME   ;
				}
				else
				{
					let arrDATA_FIELD: string[] = sDATA_FIELD.split('.');
					let sTABLE_NAME  : string   = arrDATA_FIELD[0];
					let sFIELD_NAME  : string   = arrDATA_FIELD[1];
					filterXml.Filters.Filter[filterXmlEditIndex]['ACTION_TYPE'       ] = sUSER_TYPE        ;
					filterXml.Filters.Filter[filterXmlEditIndex]['RELATIONSHIP_NAME' ] = sRELATIONSHIP_NAME;
					filterXml.Filters.Filter[filterXmlEditIndex]['MODULE'            ] = sModule           ;
					filterXml.Filters.Filter[filterXmlEditIndex]['MODULE_NAME'       ] = sMODULE_NAME      ;
					filterXml.Filters.Filter[filterXmlEditIndex]['TABLE_NAME'        ] = sTABLE_NAME       ;
					filterXml.Filters.Filter[filterXmlEditIndex]['DATA_FIELD'        ] = sDATA_FIELD       ;
					filterXml.Filters.Filter[filterXmlEditIndex]['FIELD_NAME'        ] = sFIELD_NAME       ;
					filterXml.Filters.Filter[filterXmlEditIndex]['DATA_TYPE'         ] = ''                ;
					filterXml.Filters.Filter[filterXmlEditIndex]['OPERATOR'          ] = sOPERATOR         ;
					filterXml.Filters.Filter[filterXmlEditIndex]['SEARCH_TEXT'       ] = ''                ;
					filterXml.Filters.Filter[filterXmlEditIndex]['RECIPIENT_NAME'    ] = ''                ;
				}
		
				let filterXmlJson = dumpObj(filterXml, 'filterXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
				this.setState(
				{
					filterXml              ,
					filterXmlJson          ,
					filterXmlEditIndex     : -1,
				}, async () =>
				{
					this.ResetSearchText();
					let oPreviewSQL : string = await this.getReportSQL(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, DisplayColumns);
					let oPreviewXOML: string = await this.getWorkflowXOML(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, attachmentXml);
					this.setState(
					{
						oPreviewSQL ,
						oPreviewXOML,
					});
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

	private _onRELATED_Change = async (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { MODULE } = this.state;
		let { filterXml } = this.state;
		let RELATED: string = event.target.value;
		this.setState(
		{
			RELATED,
		}, () =>
		{
			this.filterRelatedChanged(RELATED);
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

	private _onRENDER_FORMAT_Change = async (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let RENDER_FORMAT: string = event.target.value;
		this.setState({ RENDER_FORMAT });
	}

	private _onREPORT_PARAMETERS_Change = async (event) =>
	{
		let REPORT_PARAMETERS: string = event.target.value;
		this.setState({ REPORT_PARAMETERS });
	}

	private _onReportSelectChange = (value: { Action: string, ID: string, NAME: string }) =>
	{
		if ( value.Action == 'SingleSelect' )
		{
			try
			{
				this.setState({ popupOpen: false, REPORT_ID: value.ID, REPORT_NAME: value.NAME });
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

	private _onAttachmentsEdit = async (index: number) =>
	{
		let { attachmentXml } = this.state;

		let REPORT_ID         : string  = '';
		let REPORT_NAME       : string  = '';
		let REPORT_PARAMETERS : string  = '';
		let RENDER_FORMAT     : string  = '';
		if ( attachmentXml && attachmentXml.ReportAttachments && attachmentXml.ReportAttachments.Report && index < attachmentXml.ReportAttachments.Report.length )
		{
			REPORT_ID         = Sql.ToString(attachmentXml.ReportAttachments.Report[index]['REPORT_ID'        ]);
			REPORT_NAME       = Sql.ToString(attachmentXml.ReportAttachments.Report[index]['REPORT_NAME'      ]);
			REPORT_PARAMETERS = Sql.ToString(attachmentXml.ReportAttachments.Report[index]['REPORT_PARAMETERS']);
			RENDER_FORMAT     = Sql.ToString(attachmentXml.ReportAttachments.Report[index]['RENDER_FORMAT'    ]);
		}
		this.setState(
		{
			REPORT_ID             ,
			REPORT_NAME           ,
			REPORT_PARAMETERS     ,
			RENDER_FORMAT         ,
			attachmentXmlEditIndex: index,
		});
	}

	private _onAttachmentsRemove = async (index: number) =>
	{
		const { DisplayColumns } = this.props;
		let { MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, attachmentXml } = this.state;
		try
		{
			if ( attachmentXml && attachmentXml.ReportAttachments && attachmentXml.ReportAttachments.Report && index < attachmentXml.ReportAttachments.Report.length )
			{
				attachmentXml.ReportAttachments.Report.splice(index, 1);
				this.ResetAttachments();
				let oPreviewSQL : string = await this.getReportSQL(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, DisplayColumns);
				let oPreviewXOML: string = await this.getWorkflowXOML(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, attachmentXml);
				this.setState(
				{
					attachmentXml,
					oPreviewSQL  ,
					oPreviewXOML ,
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onAttachmentsRemove', error);
			this.setState({ error });
		}
	}

	private _onAttachmentsUpdate = async () =>
	{
		const { DisplayColumns } = this.props;
		const { MODULE, RELATED, REPORT_ID, REPORT_NAME, REPORT_PARAMETERS, RENDER_FORMAT } = this.state;
		let { filterXml, relatedModuleXml, relationshipXml, attachmentXml, attachmentXmlEditIndex } = this.state;
		try
		{
			if ( !Sql.IsEmptyGuid(REPORT_ID) )
			{
				if ( !attachmentXml )
				{
					attachmentXml = {};
				}
				if ( !attachmentXml.ReportAttachments )
				{
					attachmentXml.ReportAttachments = {};
				}
				if ( !attachmentXml.ReportAttachments.Report || !Array.isArray(attachmentXml.ReportAttachments.Report) )
				{
					attachmentXml.ReportAttachments.Report = [];
				}
				if ( attachmentXmlEditIndex == -1 )
				{
					attachmentXmlEditIndex = attachmentXml.ReportAttachments.Report.length;
					attachmentXml.ReportAttachments.Report.push({});
				}
				if ( attachmentXml.ReportAttachments.Report[attachmentXmlEditIndex] )
				{
					if ( attachmentXml.ReportAttachments.Report[attachmentXmlEditIndex]['ID'] === undefined )
					{
						attachmentXml.ReportAttachments.Report[attachmentXmlEditIndex]['ID'] = uuidFast();
					}
					attachmentXml.ReportAttachments.Report[attachmentXmlEditIndex]['REPORT_ID'        ] = REPORT_ID        ;
					attachmentXml.ReportAttachments.Report[attachmentXmlEditIndex]['REPORT_NAME'      ] = REPORT_NAME      ;
					attachmentXml.ReportAttachments.Report[attachmentXmlEditIndex]['REPORT_PARAMETERS'] = REPORT_PARAMETERS;
					attachmentXml.ReportAttachments.Report[attachmentXmlEditIndex]['RENDER_FORMAT'    ] = RENDER_FORMAT    ;
		
					this.setState(
					{
						attachmentXml          ,
						attachmentXmlEditIndex : -1,
					}, async () =>
					{
						this.ResetAttachments();
						let oPreviewSQL : string = await this.getReportSQL(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, DisplayColumns);
						let oPreviewXOML: string = await this.getWorkflowXOML(MODULE, RELATED, filterXml, relatedModuleXml, relationshipXml, attachmentXml);
						this.setState(
						{
							oPreviewSQL ,
							oPreviewXOML,
						});
						this.props.onChanged('attachmentXml', attachmentXml, null, null);
					});
				}
				else
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onAttachmentsUpdate invalid attachmentXmlEditIndex', attachmentXmlEditIndex);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onAttachmentsUpdate', error);
			this.setState({ error });
		}
	}

	private _onAttachmentsCancel = () =>
	{
		this.ResetAttachments();
	}

	private ResetAttachments = () =>
	{
		const { RENDER_FORMAT_LIST } = this.state;
		let RENDER_FORMAT: string = '';
		if ( RENDER_FORMAT_LIST != null && RENDER_FORMAT_LIST.length > 0 )
		{
			RENDER_FORMAT = RENDER_FORMAT_LIST[0];
		}
		this.setState(
		{
			REPORT_ID             : null,
			REPORT_NAME           : '',
			REPORT_PARAMETERS     : '',
			RENDER_FORMAT         ,
			attachmentXmlEditIndex: -1,
			error                 : null ,
		});
	}

	private _onSearchPopup = (): void =>
	{
		this.setState({ popupOpen: true });
	}

	public render()
	{
		const { oPreviewSQL, oPreviewXOML, error } = this.state;
		const { filterXml, filterXmlJson, attachmentXml } = this.state;
		const { RELATED, SHOW_XOML, RELATED_LIST, FILTER_COLUMN_SOURCE_LIST, FILTER_COLUMN_LIST, FILTER_OPERATOR_LIST } = this.state;
		const { popupOpen, FILTER_COLUMN_SOURCE, FILTER_COLUMN, FILTER_OPERATOR, FILTER_OPERATOR_TYPE } = this.state;
		const { RENDER_FORMAT_LIST, REPORT_ID, REPORT_NAME, REPORT_PARAMETERS, RENDER_FORMAT } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', attachmentXml);
		try
		{
			return (
<div id='divXomlBuilder'>
	<ErrorComponent error={error} />
	<DynamicPopupView
		isOpen={ popupOpen }
		isSearchView={ false }
		fromLayoutName={ '.PopupView' }
		callback={ this._onReportSelectChange }
		MODULE_NAME='Reports'
	/>
	<h4>{ L10n.Term('WorkflowAlertShells.LBL_REPORT_ATTACHMENTS') }</h4>
	<table className="tabForm" cellSpacing={ 1 } cellPadding={ 0 } style={ {width: '100%', borderWidth: '0px'} }>
		<tr>
			<td style={{ paddingTop: '5px', paddingBottom: '5px'} }>
				<table id='ctlXomlBuilder_dgReportAttachments' cellSpacing={ 0 } cellPadding={ 3 } style={ {borderCollapse: 'collapse', border: '1px solid black', width: '100%'} }>
					<tr>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('WorkflowAlertShells.LBL_LIST_REPORT_ID'    ) }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('WorkflowAlertShells.LBL_LIST_NAME'         ) }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('WorkflowAlertShells.LBL_LIST_PARAMETERS'   ) }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('WorkflowAlertShells.LBL_LIST_RENDER_FORMAT') }</td>
						<td style={ {border: '1px solid black'} }>&nbsp;</td>
					</tr>
				{ attachmentXml && attachmentXml.ReportAttachments && attachmentXml.ReportAttachments.Report && Array.isArray(attachmentXml.ReportAttachments.Report)
				? attachmentXml.ReportAttachments.Report.map((item, index) => 
				{ return (
					<tr>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item['REPORT_ID'        ]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item['REPORT_NAME'      ]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item['REPORT_PARAMETERS']) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item['RENDER_FORMAT'    ]) }</td>
						<td style={ {border: '1px solid black', width: '1%', whiteSpace: 'nowrap'} } align='left'>
							<input type='submit' className='button' value={ L10n.Term('.LBL_EDIT_BUTTON_LABEL'         ) } title={ L10n.Term('.LBL_EDIT_BUTTON_LABEL'         ) } onClick={ (e) => this._onAttachmentsEdit(index) } />
							&nbsp;
							<input type='submit' className='button' value={ L10n.Term('Reports.LBL_REMOVE_BUTTON_LABEL') } title={ L10n.Term('Reports.LBL_REMOVE_BUTTON_LABEL') } onClick={ (e) => this._onAttachmentsRemove(index) } />
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
				<table className="tabEditView" style={ {borderWidth: '0px', width: '100%'} }>
					<tr>
						<td valign="top" style={ {whiteSpace: 'nowrap'} }>
							{ L10n.Term("WorkflowAlertShells.LBL_REPORT_NAME") }&nbsp;
							<input id="ctlQueryBuilder_txtREPORT_NAME" type="text" value={ REPORT_NAME } disabled={ true } />
							<br />
							<span id="ctlQueryBuilder_lblREPORT_ID">{ REPORT_ID }</span>
						</td>
						<td valign="top">
							<input type='submit'
								className='button'
								value={ L10n.Term('.LBL_SELECT_BUTTON_LABEL') }
								title={ L10n.Term('.LBL_SELECT_BUTTON_TITLE') }
								onClick={ (e) => this._onSearchPopup() }
								style={ {marginLeft: '4px'} }
							/>
						</td>
						<td valign="top" style={ {whiteSpace: 'nowrap'} }>
							{ L10n.Term("WorkflowAlertShells.LBL_REPORT_PARAMETERS") }&nbsp;
							<textarea id="ctlQueryBuilder_txtREPORT_PARAMETERS" rows={ 2 } value={ REPORT_PARAMETERS } onChange={ this._onREPORT_PARAMETERS_Change } style={ {width: '300px'} } />
						</td>
						<td valign="top" style={ {whiteSpace: 'nowrap'} }>
							{ L10n.Term("WorkflowAlertShells.LBL_RENDER_FORMAT") }&nbsp;
							<select
								id="ctlQueryBuilder_lstRENDER_FORMAT"
								tabIndex={ 3 }
								value={ RENDER_FORMAT }
								onChange={ this._onRENDER_FORMAT_Change }
							>
							{ RENDER_FORMAT_LIST
							? RENDER_FORMAT_LIST.map((item, index) => 
							{ return (
								<option key={ 'ctlQueryBuilder_lstRENDER_FORMAT' + item } value={ item }>{ L10n.ListTerm('report_render_format', item) }</option>);
							})
							: null
							}
							</select>
						</td>
						<td valign="top">
							<input type='submit' value={ L10n.Term('.LBL_UPDATE_BUTTON_LABEL') } title={ L10n.Term('.LBL_UPDATE_BUTTON_TITLE') } className='button' onClick={ this._onAttachmentsUpdate } />
						</td>
						<td valign="top">
							<input type='submit' value={ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') } title={ L10n.Term('.LBL_CANCEL_BUTTON_TITLE') } className='button' onClick={ this._onAttachmentsCancel } />
						</td>
						<td style={ {width: '80%'} }></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	
	<br />
	
	<h4>{ L10n.Term('WorkflowAlertShells.LBL_ALERT_USER_TYPES') }</h4>
	<table className="tabForm" cellSpacing={ 1 } cellPadding={ 0 } style={ {width: '100%', borderWidth: '0px'} }>
		<tr>
			<td>
				<table cellSpacing={ 0 } cellPadding={ 0 } style={ {borderWidth: '0px', borderCollapse: 'collapse'} }>
					<tr>
						<td className="dataLabel" style={ {width: '15%'} }>
							{ L10n.Term("WorkflowActionShells.LBL_SHOW_XOML") }
						</td>
						<td className="dataField" style={ {width: '35%'} }>
							<span className="checkbox">
								<input id="ctlXomlBuilder_chkSHOW_XOML" type="checkbox" checked={ SHOW_XOML } onChange={ this._onChange_SHOW_XOML } />
							</span>
						</td>
						<td className="dataLabel" style={ {width: '15%'} }>
						</td>
						<td className="dataField" style={ {width: '35%'} }>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td style={{ paddingTop: '5px', paddingBottom: '5px'} }>
				<table id='ctlXomlBuilder_dgFilters' cellSpacing={ 0 } cellPadding={ 3 } style={ {borderCollapse: 'collapse', border: '1px solid black', width: '100%'} }>
					<tr>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('WorkflowAlertShells.LBL_LIST_ACTION_TYPE'      ) }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('WorkflowAlertShells.LBL_LIST_RELATIONSHIP_NAME') }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('WorkflowAlertShells.LBL_LIST_MODULE_NAME'      ) }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('WorkflowAlertShells.LBL_LIST_DATA_FIELD'       ) }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('WorkflowAlertShells.LBL_LIST_DATA_TYPE'        ) }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('WorkflowAlertShells.LBL_LIST_OPERATOR'         ) }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('WorkflowAlertShells.LBL_LIST_RECIPIENT_NAME'   ) }</td>
						<td style={ {border: '1px solid black'} }>{ L10n.Term('WorkflowAlertShells.LBL_LIST_SEARCH_TEXT'      ) }</td>
						<td style={ {border: '1px solid black'} }>&nbsp;</td>
					</tr>
				{ filterXml && filterXml.Filters && filterXml.Filters.Filter && Array.isArray(filterXml.Filters.Filter)
				? filterXml.Filters.Filter.map((item, index) => 
				{ return (
					<tr>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["ACTION_TYPE"      ]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["RELATIONSHIP_NAME"]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["MODULE_NAME"      ]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["DATA_FIELD"       ]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["DATA_TYPE"        ]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["OPERATOR"         ]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["RECIPIENT_NAME"   ]) }</td>
						<td style={ {border: '1px solid black'} }>{ Sql.ToString(item["SEARCH_TEXT"      ]) }</td>
						<td style={ {border: '1px solid black', width: '1%', whiteSpace: 'nowrap'} } align='left'>
							<input type='submit' className='button' value={ L10n.Term('.LBL_EDIT_BUTTON_LABEL'         ) } title={ L10n.Term('.LBL_EDIT_BUTTON_LABEL'         ) } onClick={ (e) => this._onFiltersEdit(index) } />
							&nbsp;
							<input type='submit' className='button' value={ L10n.Term('Reports.LBL_REMOVE_BUTTON_LABEL') } title={ L10n.Term('Reports.LBL_REMOVE_BUTTON_LABEL') } onClick={ (e) => this._onFiltersRemove(index) } />
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
								id="ctlQueryBuilder_lstRELATED"
								tabIndex={ 3 }
								value={ RELATED }
								onChange={ this._onRELATED_Change }
							>
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
						<td valign="top">
							<select
								id="ctlXomlBuilder_lstFILTER_COLUMN_SOURCE"
								tabIndex={ 10 }
								value={ FILTER_COLUMN_SOURCE }
								onChange={ this._onFILTER_COLUMN_SOURCE_LIST_Change }
							>
							{ FILTER_COLUMN_SOURCE_LIST
							? FILTER_COLUMN_SOURCE_LIST.map((item, index) => 
							{ return (
								<option key={ 'ctlXomlBuilder_lstFILTER_COLUMN_SOURCE_' + item.MODULE_NAME } value={ item.MODULE_NAME }>{ item.DISPLAY_NAME }</option>);
							})
							: null
							}
							</select>
							<br />
							<span id="ctlXomlBuilder_lblFILTER_COLUMN_SOURCE">{ FILTER_COLUMN_SOURCE }</span>
						</td>
						<td valign="top">
							<select
								id="ctlXomlBuilder_lstFILTER_COLUMN"
								tabIndex={ 11 }
								value={ FILTER_COLUMN }
								onChange={ this._onFILTER_COLUMN_LIST_Change }
							>
							{ FILTER_COLUMN_LIST
							? FILTER_COLUMN_LIST.map((item, index) => 
							{ return (
								<option key={ 'ctlXomlBuilder_lstFILTER_COLUMN_' + item.NAME } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
							})
							: null
							}
							</select>
							<br />
							<span id="ctlXomlBuilder_lblFILTER_COLUMN">{ FILTER_COLUMN }</span>
						</td>
						<td valign="top">
							<select
								id="ctlXomlBuilder_lstFILTER_OPERATOR"
								tabIndex={ 12 }
								value={ FILTER_OPERATOR }
								onChange={ this._onFILTER_OPERATOR_LIST_Change }
							>
							{ FILTER_OPERATOR_LIST
							? FILTER_OPERATOR_LIST.map((item, index) => 
							{ return (
								<option key={ 'ctlXomlBuilder_lstFILTER_OPERATOR_' + item } value={ item }>{ L10n.ListTerm(this.filterOperatorListName(item, FILTER_OPERATOR_TYPE), item) }</option>);
							})
							: null
							}
							</select>
							<div>
								<span id="ctlXomlBuilder_lblFILTER_OPERATOR">{ FILTER_OPERATOR }</span>
							</div>
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
	{ SHOW_XOML
	? <React.Fragment>
		<br />
		<table cellPadding={ 3 } cellSpacing={ 0 } style={ {width: '100%', backgroundColor: 'LightGrey', border: '1px solid black', marginBottom: '4px'} }>
			<tr>
				<td>
					<pre style={ {whiteSpace: 'pre-wrap'} }><b>{ oPreviewSQL }</b></pre>
				</td>
			</tr>
		</table>
		<DumpXOML XOML={ oPreviewXOML} default_xoml={ true } />
	</React.Fragment>
	: null
	}
	{ bDebug && SHOW_XOML
	? <div>
		<div id='divFilterXmlDump' dangerouslySetInnerHTML={ {__html: filterXmlJson } } style={ {marginTop: '20px', border: '1px solid black'} }></div>
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

