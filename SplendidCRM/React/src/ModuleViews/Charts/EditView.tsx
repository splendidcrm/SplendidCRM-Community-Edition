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
import * as qs from 'query-string';
import { RouteComponentProps, withRouter }          from 'react-router-dom'                          ;
import { Modal, ModalTitle }                        from 'react-bootstrap'                           ;
import { observer }                                 from 'mobx-react'                                ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'            ;
import * as XMLParser                               from 'fast-xml-parser'                           ;
// 2. Store and Types. 
import { EditComponent }                            from '../../types/EditComponent'                 ;
import { HeaderButtons }                            from '../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                          from '../../scripts/Sql'                         ;
import L10n                                         from '../../scripts/L10n'                        ;
import Security                                     from '../../scripts/Security'                    ;
import Credentials                                  from '../../scripts/Credentials'                 ;
import SplendidCache                                from '../../scripts/SplendidCache'               ;
import SplendidDynamic_EditView                     from '../../scripts/SplendidDynamic_EditView'    ;
import { Crm_Config, Crm_Modules }                  from '../../scripts/Crm'                         ;
import { StartsWith, EndsWith }                     from '../../scripts/utility'                     ;
import { AuthenticatedMethod, LoginRedirect }       from '../../scripts/Login'                       ;
import { sPLATFORM_LAYOUT }                         from '../../scripts/SplendidInitUI'              ;
import { EditView_LoadItem, EditView_LoadLayout }   from '../../scripts/EditView'                    ;
import { CreateSplendidRequest, GetSplendidResult } from '../../scripts/SplendidRequest'             ;
import { jsonReactState }                           from '../../scripts/Application'                 ;
// 4. Components and Views. 
import ErrorComponent                               from '../../components/ErrorComponent'           ;
import DumpSQL                                      from '../../components/DumpSQL'                  ;
import DynamicButtons                               from '../../components/DynamicButtons'           ;
import HeaderButtonsFactory                         from '../../ThemeComponents/HeaderButtonsFactory';
import QueryBuilder                                 from '../../ReportDesigner/QueryBuilder'         ;
import ChartView                                    from './ChartView'                               ;

let MODULE_NAME: string = 'Charts';

interface IEditViewProps extends RouteComponentProps<any>
{
	ID?                : string;
	LAYOUT_NAME        : string;
	rowDefaultSearch?  : any;
	onLayoutLoaded?    : any;
	onSubmit?          : any;
	DuplicateID?       : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IEditViewState
{
	__sql                      : string ;
	item                       : any    ;
	layout                     : any    ;
	EDIT_NAME                  : string ;
	DUPLICATE                  : boolean;
	LAST_DATE_MODIFIED         : Date   ;
	SUB_TITLE                  : any    ;
	editedItem                 : any    ;
	dependents                 : Record<string, Array<any>>;
	showReportPopup            : boolean;
	activeTab                  : string ;
	reportXml                  : any    ;
	reportXmlJson              : string ;
	MODULE_COLUMN_SOURCE_LIST  : any[]  ;
	SERIES_COLUMN_LIST         : any[]  ;
	SERIES_COLUMN_LIST_NAMES   : any    ;
	SERIES_OPERATOR_LIST       : any[]  ;
	CATEGORY_OPERATOR_LIST     : any[]  ;
	MODULE_COLUMN_SOURCE       : string ;
	SERIES_COLUMN              : string ;
	SERIES_OPERATOR            : string ;
	SERIES_OPERATOR_TYPE       : string ;
	CATEGORY_COLUMN            : string ;
	CATEGORY_OPERATOR          : string ;
	CATEGORY_OPERATOR_TYPE     : string ;
	filterXml                  : any    ;
	relatedModuleXml           : any    ;
	relationshipXml            : any    ;
	queryBuilderReady          : boolean;
	error                      : any    ;
}

// 09/18/2019 Paul.  Give class a unique name so that it can be debugged.  Without the unique name, Chrome gets confused.
@observer
export default class ChartsEditView extends React.Component<IEditViewProps, IEditViewState>
{
	private _isMounted           : boolean = false;
	private themeURL             : string;
	private refMap               : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons        = React.createRef<HeaderButtons>();
	private queryBuilder         = React.createRef<QueryBuilder>();
	private SERIES_COLUMN_LIST_CACHE: any = {};

	public get data (): any
	{
		const { MODULE_COLUMN_SOURCE, SERIES_COLUMN, SERIES_OPERATOR, CATEGORY_COLUMN, CATEGORY_OPERATOR } = this.state;
		let row  : any = {};
		let chart: any = { MODULE_COLUMN_SOURCE, SERIES_COLUMN, SERIES_OPERATOR, CATEGORY_COLUMN, CATEGORY_OPERATOR };
		SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		// 04/01/2020 Paul.  We need to include the ReportDesign, which may not have been edited, so could be in item, or editedItem. 
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem, row, this.queryBuilder.current.data, chart);
		return currentItem;
	}

	public validate(): boolean
	{
		let row: any = {};
		let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem, row);
		if ( this.queryBuilder.current != null && !this.queryBuilder.current.validate() )
		{
			this.setState({ error: this.queryBuilder.current.error() });
		}
		return (nInvalidFields == 0);
	}

	public clear(): void
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		SplendidDynamic_EditView.Clear(this.refMap);
		if ( this._isMounted )
		{
			this.setState({ editedItem: {} });
		}
	}

	constructor(props: IEditViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props.ID);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
		let item = (props.rowDefaultSearch ? props.rowDefaultSearch : null);
		let EDIT_NAME = MODULE_NAME + '.EditView' + sPLATFORM_LAYOUT;
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}
		this.state =
		{
			__sql                      : null,
			item                       ,
			layout                     : null,
			EDIT_NAME                  ,
			DUPLICATE                  : false,
			LAST_DATE_MODIFIED         : null,
			SUB_TITLE                  : null,
			editedItem                 : null,
			dependents                 : {},
			showReportPopup            : false,
			activeTab                  : 'ModuleFilter',
			reportXml                  : {},
			reportXmlJson              : null,
			MODULE_COLUMN_SOURCE_LIST  : [],
			SERIES_COLUMN_LIST         : [],
			SERIES_COLUMN_LIST_NAMES   : {},
			SERIES_OPERATOR_LIST       : [],
			CATEGORY_OPERATOR_LIST     : [],
			MODULE_COLUMN_SOURCE       : null,
			SERIES_COLUMN              : null,
			SERIES_OPERATOR            : null,
			SERIES_OPERATOR_TYPE       : null,
			CATEGORY_COLUMN            : null,
			CATEGORY_OPERATOR          : null,
			CATEGORY_OPERATOR_TYPE     : null,
			filterXml                  : null,
			relatedModuleXml           : null,
			relationshipXml            : null,
			queryBuilderReady          : false,
			error                      : null,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		this._isMounted = true;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount');
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
				await this.load();
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

	async componentDidUpdate(prevProps: IEditViewProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate Reset ' + this.state.EDIT_NAME, this.props.location,  prevProps.location);
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		else
		{
			if ( this.props.onComponentComplete )
			{
				const { ID } = this.props;
				const { item, layout, EDIT_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + EDIT_NAME, item);
				if ( layout != null && error == null )
				{
					if ( ID == null || item != null )
					{
						this.props.onComponentComplete(MODULE_NAME, null, EDIT_NAME, item);
					}
				}
			}
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private load = async () =>
	{
		const { ID, DuplicateID } = this.props;
		const { EDIT_NAME } = this.state;
		try
		{
			// 10/12/2019 Paul.  Add support for parent assignment during creation. 
			let rowDefaultSearch: any = this.props.rowDefaultSearch;
			if ( Sql.IsEmptyGuid(ID) && Sql.IsEmptyGuid(DuplicateID) )
			{
				// 03/19/2020 Paul.  If we initialize rowDefaultSearch, then we need to set assigned and team values. 
				rowDefaultSearch = {};
				rowDefaultSearch['ASSIGNED_SET_LIST'] = Security.USER_ID()  ;
				rowDefaultSearch['ASSIGNED_USER_ID' ] = Security.USER_ID()  ;
				rowDefaultSearch['ASSIGNED_TO'      ] = Security.USER_NAME();
				rowDefaultSearch['ASSIGNED_TO_NAME' ] = Security.FULL_NAME();
				rowDefaultSearch['TEAM_ID'          ] = Security.TEAM_ID()  ;
				rowDefaultSearch['TEAM_NAME'        ] = Security.TEAM_NAME();
				rowDefaultSearch['TEAM_SET_LIST'    ] = Security.TEAM_ID()  ;
				rowDefaultSearch['TEAM_SET_NAME'    ] = Security.TEAM_ID()  ;
				rowDefaultSearch['SHOW_QUERY'       ] = Crm_Config.ToBoolean('show_sql');
				// 04/21/2020 Paul.  Set default name and dimensions. 
				rowDefaultSearch['NAME'             ] = 'untitled';
				rowDefaultSearch['CHART_TYPE'       ] = 'Column';
			}
			const layout = EditView_LoadLayout(EDIT_NAME);
			
			let MODULE: string = null;
			let lstModules: any[] = L10n.GetList('ReportingModules');
			if ( lstModules != null && lstModules.length > 0 )
			{
				MODULE = lstModules[0];
				if ( rowDefaultSearch != null )
					rowDefaultSearch['MODULE_NAME'] = MODULE;
			}

			let results: any = await this.getQueryBuilderState(null, MODULE, null, this.constructor.name + '.load');
			let MODULE_COLUMN_SOURCE_LIST: any[]  = results.FILTER_COLUMN_SOURCE_LIST;
			let SERIES_COLUMN_LIST       : any[]  = results.FILTER_COLUMN_LIST       ;
			let SERIES_COLUMN_LIST_NAMES : any    = results.FILTER_COLUMN_LIST_NAMES ;

			let MODULE_COLUMN_SOURCE: string = '';
			let SERIES_COLUMN       : string = null;
			let CATEGORY_COLUMN     : string = null;
			if ( MODULE_COLUMN_SOURCE_LIST != null && MODULE_COLUMN_SOURCE_LIST.length > 0 )
			{
				MODULE_COLUMN_SOURCE = MODULE_COLUMN_SOURCE_LIST[0].MODULE_NAME;
				// 05/15/2021 Paul.  Cache the SERIES_COLUMN_LIST. 
				this.SERIES_COLUMN_LIST_CACHE[MODULE_COLUMN_SOURCE] = SERIES_COLUMN_LIST;
			}
			if ( SERIES_COLUMN_LIST != null && SERIES_COLUMN_LIST.length > 0 )
			{
				SERIES_COLUMN   = SERIES_COLUMN_LIST[0].NAME;
				CATEGORY_COLUMN = SERIES_COLUMN_LIST[0].NAME;
			}

			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', layout);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			if ( this._isMounted )
			{
				this.setState(
				{
					layout                   : layout,
					item                     : (rowDefaultSearch ? rowDefaultSearch : null),
					editedItem               : null,
					MODULE_COLUMN_SOURCE_LIST,
					SERIES_COLUMN_LIST       ,
					SERIES_COLUMN_LIST_NAMES ,
					MODULE_COLUMN_SOURCE     ,
					SERIES_COLUMN            ,
					SERIES_OPERATOR          : null,
					SERIES_OPERATOR_TYPE     : null,
					CATEGORY_COLUMN          ,
					CATEGORY_OPERATOR        : null,
					CATEGORY_OPERATOR_TYPE   : null,
				}, () =>
				{
					this.initCharOperators();
				});
				if ( !Sql.IsEmptyString(DuplicateID) )
				{
					await this.LoadItem(MODULE_NAME, DuplicateID);
				}
				else
				{
					await this.LoadItem(MODULE_NAME, ID);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private LoadItem = async (sMODULE_NAME: string, sID: string) =>
	{
		let { MODULE_COLUMN_SOURCE_LIST, SERIES_COLUMN_LIST, SERIES_COLUMN_LIST_NAMES, MODULE_COLUMN_SOURCE, SERIES_COLUMN, SERIES_OPERATOR_LIST, SERIES_OPERATOR, SERIES_OPERATOR_TYPE, CATEGORY_OPERATOR_LIST, CATEGORY_OPERATOR_TYPE, CATEGORY_COLUMN, CATEGORY_OPERATOR } = this.state;

		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
 
				let options: any = 
				{
					attributeNamePrefix: ''     ,
					textNodeName       : 'Value',
					ignoreAttributes   : false  ,
					ignoreNameSpace    : true   ,
					parseAttributeValue: true   ,
					trimValues         : false  ,
				};
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_LoadItem(sMODULE_NAME, sID);
				let item                 : any    = d.results;
				let LAST_DATE_MODIFIED   : Date   = null;
				let reportXml            : any    = null;
				let reportXmlJson        : string = null;
				if ( item != null )
				{
					// 05/21/2021 Paul. RDL returned from vwCHARTS_Edit, so we don't need a separate query. 
					//let res  = await CreateSplendidRequest('ReportDesigner/Rest.svc/GetChartDesign?ID=' + sID, 'GET');
					//let json = await GetSplendidResult(res);
					//item['ReportDesign'] = json;
					item['SHOW_QUERY'  ] = Crm_Config.ToBoolean('show_sql');
					// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
					if ( item['DATE_MODIFIED'] !== undefined )
					{
						LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
					}
					let sRDL: string = Sql.ToString(item['RDL']);
					if ( !Sql.IsEmptyString(sRDL) && StartsWith(sRDL, '<?xml') )
					{
						reportXml = XMLParser.parse(sRDL, options);
						if ( reportXml.Report != null )
						{
							if ( reportXml.Report.CustomProperties != null && reportXml.Report.CustomProperties.CustomProperty != null && Array.isArray(reportXml.Report.CustomProperties.CustomProperty) )
							{
								for ( let i = 0; i < reportXml.Report.CustomProperties.CustomProperty.length; i++ )
								{
									let customProperty: any = reportXml.Report.CustomProperties.CustomProperty[i];
									switch ( customProperty.Name )
									{
										case 'crm:Module'    :  item['MODULE_NAME'] = customProperty.Value;  break;
										case 'crm:Related'   :  item['RELATED'    ] = customProperty.Value;  break;
									}
								}
							}
							let results: any = await this.getQueryBuilderState('', item['MODULE_NAME'], item['RELATED'], this.constructor.name + '.LoadItem');
							MODULE_COLUMN_SOURCE_LIST = results.FILTER_COLUMN_SOURCE_LIST;
							SERIES_COLUMN_LIST        = results.FILTER_COLUMN_LIST       ;
							SERIES_COLUMN_LIST_NAMES  = results.FILTER_COLUMN_LIST_NAMES ;
							if ( MODULE_COLUMN_SOURCE_LIST != null && MODULE_COLUMN_SOURCE_LIST.length > 0 )
							{
								MODULE_COLUMN_SOURCE = MODULE_COLUMN_SOURCE_LIST[0].MODULE_NAME;
								// 05/15/2021 Paul.  Cache the SERIES_COLUMN_LIST. 
								this.SERIES_COLUMN_LIST_CACHE[MODULE_COLUMN_SOURCE] = SERIES_COLUMN_LIST;
							}
							
							if ( reportXml.Report.Body != null 
							  && reportXml.Report.Body.ReportItems != null
							  && reportXml.Report.Body.ReportItems.Chart != null
							   )
							{
								if ( reportXml.Report.Body.ReportItems.Chart.ChartData != null
								  && reportXml.Report.Body.ReportItems.Chart.ChartData.ChartSeriesCollection != null
								  && reportXml.Report.Body.ReportItems.Chart.ChartData.ChartSeriesCollection.ChartSeries != null
								   )
								{
									let chartSeries: any = reportXml.Report.Body.ReportItems.Chart.ChartData.ChartSeriesCollection.ChartSeries;
									if ( chartSeries.Type != null )
									{
										let sChartType: string = Sql.ToString(chartSeries.Type);
										if ( sChartType == 'Column'
										  || sChartType == 'Bar'
										  || sChartType == 'Line'
										  || sChartType == 'Shape'
										  || sChartType == 'Area'
										   )
										{
											item['CHART_TYPE'] = sChartType;
										}
									}
									if ( chartSeries.ChartDataPoints != null
									  && chartSeries.ChartDataPoints.ChartDataPoint != null
									  && chartSeries.ChartDataPoints.ChartDataPoint.ChartDataPointValues != null
									  && chartSeries.ChartDataPoints.ChartDataPoint.ChartDataPointValues.Y != null
									   )
									{
										let sYField: string = Sql.ToString(chartSeries.ChartDataPoints.ChartDataPoint.ChartDataPointValues.Y);
										// 05/26/2021 Paul.  Must determine the operator before it is changed due to *. 
										let sSeriesOperator: string = "sum";
										if      ( StartsWith(sYField, "=Avg("    ) ) sSeriesOperator = "avg";
										else if ( StartsWith(sYField, "=Sum("    ) ) sSeriesOperator = "sum";
										else if ( StartsWith(sYField, "=Min("    ) ) sSeriesOperator = "min";
										else if ( StartsWith(sYField, "=Max("    ) ) sSeriesOperator = "max";
										else if ( StartsWith(sYField, "=Count(*)") ) sSeriesOperator = "count";
										else if ( StartsWith(sYField, "=Count("  ) ) sSeriesOperator = "count_not_empty";
										SERIES_OPERATOR      = sSeriesOperator;

										if ( sYField.indexOf('*') >= 0 )
										{
											sYField = chartSeries.Name;
										}	
										let sFieldName: string = this.LookupDateField(reportXml, sYField);
										// 11/08/2011 Paul.  If the item does not exist, then add it. 
										if ( !Sql.IsEmptyString(sFieldName) )
										{
											let bFound: boolean = false;
											for ( let i: number = 0; i < SERIES_COLUMN_LIST.length; i++ )
											{
												if ( SERIES_COLUMN_LIST[i].NAME == sFieldName )
												{
													SERIES_OPERATOR_TYPE   = SERIES_COLUMN_LIST[i]['CsType'].toLowerCase();
													SERIES_OPERATOR_LIST   = L10n.GetList('series_' + SERIES_OPERATOR_TYPE + '_operator_dom');
													bFound = true;
													break;
												}
											}
											if ( !bFound )
											{
												SERIES_COLUMN_LIST.push({ NAME: sFieldName, DISPLAY_NAME: sFieldName });
											}
											SERIES_COLUMN = sFieldName;
										}
									}
								}
								if ( reportXml.Report.Body.ReportItems.Chart.ChartCategoryHierarchy != null
								  && reportXml.Report.Body.ReportItems.Chart.ChartCategoryHierarchy.ChartMembers != null
								  && reportXml.Report.Body.ReportItems.Chart.ChartCategoryHierarchy.ChartMembers.ChartMember != null
								  && reportXml.Report.Body.ReportItems.Chart.ChartCategoryHierarchy.ChartMembers.ChartMember.Group != null
								  && reportXml.Report.Body.ReportItems.Chart.ChartCategoryHierarchy.ChartMembers.ChartMember.Group.GroupExpressions != null
								  && reportXml.Report.Body.ReportItems.Chart.ChartCategoryHierarchy.ChartMembers.ChartMember.Group.GroupExpressions.GroupExpression != null
								   )
								{
									let sXField: string = reportXml.Report.Body.ReportItems.Chart.ChartCategoryHierarchy.ChartMembers.ChartMember.Group.GroupExpressions.GroupExpression;
									let sFieldName: string = this.LookupDateField(reportXml, sXField);
									// 11/08/2011 Paul.  If the item does not exist, then add it. 
									if ( !Sql.IsEmptyString(sFieldName) )
									{
										let bFound: boolean = false;
										for ( let i: number = 0; i < SERIES_COLUMN_LIST.length; i++ )
										{
											if ( SERIES_COLUMN_LIST[i].NAME == sFieldName )
											{
												CATEGORY_OPERATOR_TYPE   = SERIES_COLUMN_LIST[i]['CsType'].toLowerCase();
												CATEGORY_OPERATOR_LIST   = L10n.GetList('category_' + CATEGORY_OPERATOR_TYPE + '_operator_dom');
												bFound = true;
												break;
											}
										}
										if ( !bFound )
										{
											SERIES_COLUMN_LIST.push({ NAME: sFieldName, DISPLAY_NAME: sFieldName });
										}
										CATEGORY_COLUMN = sFieldName;
									}
									CATEGORY_COLUMN = sFieldName;
									
									if ( reportXml.Report.Body.ReportItems.Chart.ChartAreas != null
									  && reportXml.Report.Body.ReportItems.Chart.ChartAreas.ChartArea != null
									  && reportXml.Report.Body.ReportItems.Chart.ChartAreas.ChartArea.ChartCategoryAxes != null
									  && reportXml.Report.Body.ReportItems.Chart.ChartAreas.ChartArea.ChartCategoryAxes.ChartAxis != null
									  && reportXml.Report.Body.ReportItems.Chart.ChartAreas.ChartArea.ChartCategoryAxes.ChartAxis.Style != null
									  && reportXml.Report.Body.ReportItems.Chart.ChartAreas.ChartArea.ChartCategoryAxes.ChartAxis.Style.Format != null
									   )
									{
										let sCategoryOperator: string = '';
										let sCategoryAxesFormat: string  = reportXml.Report.Body.ReportItems.Chart.ChartAreas.ChartArea.ChartCategoryAxes.ChartAxis.Style.Format;
										if ( sCategoryAxesFormat.indexOf("d") >= 0 )
											sCategoryOperator = "day";
										else if ( sCategoryAxesFormat.indexOf("w") >= 0 )
											sCategoryOperator = "week";
										else if ( sCategoryAxesFormat.indexOf("M") >= 0 )
											sCategoryOperator = "month";
										else if ( sCategoryAxesFormat.indexOf("q") >= 0 )
											sCategoryOperator = "quarter";
										else if ( sCategoryAxesFormat.indexOf("y") >= 0 )
											sCategoryOperator = "year";
										CATEGORY_OPERATOR = sCategoryOperator;
									}
								}
							}
						}
					}
				}
				if ( this._isMounted )
				{
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState(
					{
						item                     ,
						SUB_TITLE                ,
						__sql                    : d.__sql,
						LAST_DATE_MODIFIED       ,
						reportXml                ,
						reportXmlJson            ,
						MODULE_COLUMN_SOURCE_LIST,
						SERIES_COLUMN_LIST       ,
						SERIES_COLUMN_LIST_NAMES ,
						MODULE_COLUMN_SOURCE     ,
						SERIES_COLUMN            ,
						SERIES_OPERATOR_LIST     ,
						SERIES_OPERATOR          ,
						SERIES_OPERATOR_TYPE     ,
						CATEGORY_COLUMN          ,
						CATEGORY_OPERATOR_LIST   ,
						CATEGORY_OPERATOR        ,
						CATEGORY_OPERATOR_TYPE   ,
					});
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.setState({ error });
			}
		}
	}

	private LookupDateField = (reportXml: any, sFieldID: string) =>
	{
		let sDataField: string = null;
		if ( sFieldID.indexOf("Fields!") > 0 )
		{
			let sFieldName: string = sFieldID.split('!')[1];
			sFieldName = sFieldName.replace(".Value", "");
			sFieldID = sFieldName.replace(")", "");
		}
		// sDataField = this.SelectNodeValue("DataSets/DataSet/Fields/Field[@Name='" + sFieldName + "']/DataField");
		if ( reportXml.Report != null
		  && reportXml.Report.DataSets != null
		  && reportXml.Report.DataSets.DataSet != null
		  && reportXml.Report.DataSets.DataSet.Fields != null
		  && reportXml.Report.DataSets.DataSet.Fields.Field != null
			)
		{
			if ( Array.isArray(reportXml.Report.DataSets.DataSet.Fields.Field) )
			{
				for ( let i: number = 0; i < reportXml.Report.DataSets.DataSet.Fields.Field.length; i++ )
				{
					let field: any = reportXml.Report.DataSets.DataSet.Fields.Field[i];
					if ( field.Name == sFieldID )
					{
						sDataField = field.DataField;
						break;
					}
				}
			}
		}
		return sDataField;
	}

	private LookupDateFieldType = (reportXml: any, sFieldID: string) =>
	{
		let sTypeName: string = null;
		if ( sFieldID.indexOf("Fields!") > 0 )
		{
			let sFieldName: string = sFieldID.split('!')[1];
			sFieldName = sFieldName.replace(".Value", "");
			sFieldID = sFieldName.replace(")", "");
		}
		// sTypeName = this.SelectNodeValue("DataSets/DataSet/Fields/Field[@Name='" + sFieldID + "']/rd:TypeName");
		if ( reportXml.Report != null
		  && reportXml.Report.DataSets != null
		  && reportXml.Report.DataSets.DataSet != null
		  && reportXml.Report.DataSets.DataSet.Fields != null
		  && reportXml.Report.DataSets.DataSet.Fields.Field != null
			)
		{
			if ( Array.isArray(reportXml.Report.DataSets.DataSet.Fields.Field) )
			{
				for ( let i: number = 0; i < reportXml.Report.DataSets.DataSet.Fields.Field.length; i++ )
				{
					let field: any = reportXml.Report.DataSets.DataSet.Fields.Field[i];
					if ( field.Name == sFieldID )
					{
						sTypeName = field['TypeName'];
						break;
					}
				}
			}
		}
		return sTypeName;
	}

	private moduleChanged = async (Modules: string, MODULE: string, RELATED: string, bClearFilters: boolean) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moduleChanged ' + MODULE, RELATED);
		try
		{
			let results: any = await this.getQueryBuilderState(Modules, MODULE, RELATED, this.constructor.name + '.moduleChanged');
			let MODULE_COLUMN_SOURCE_LIST: any[] = results.FILTER_COLUMN_SOURCE_LIST;
			let SERIES_COLUMN_LIST       : any[] = results.FILTER_COLUMN_LIST       ;
			let SERIES_COLUMN_LIST_NAMES : any   = results.FILTER_COLUMN_LIST_NAMES ;
			let MODULE_COLUMN_SOURCE     : string = null;
			let SERIES_COLUMN            : string = null;
			let CATEGORY_COLUMN          : string = null;
			if ( MODULE_COLUMN_SOURCE_LIST != null && MODULE_COLUMN_SOURCE_LIST.length > 0 )
			{
				MODULE_COLUMN_SOURCE = MODULE_COLUMN_SOURCE_LIST[0].MODULE_NAME;
				// 05/15/2021 Paul.  Cache the SERIES_COLUMN_LIST. 
				this.SERIES_COLUMN_LIST_CACHE[MODULE_COLUMN_SOURCE] = SERIES_COLUMN_LIST;
			}
			else
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.moduleChanged (missing MODULE_COLUMN_SOURCE_LIST) ' + MODULE, RELATED);
			}
			if ( SERIES_COLUMN_LIST != null && SERIES_COLUMN_LIST.length > 0 )
			{
				SERIES_COLUMN   = SERIES_COLUMN_LIST[0].NAME;
				// 06/04/2021 Paul.  Must update column when list changes. 
				CATEGORY_COLUMN = SERIES_COLUMN_LIST[0].NAME;
			}
			else
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.moduleChanged (missing SERIES_COLUMN_LIST) ' + MODULE, RELATED);
			}
			this.setState(
			{
				MODULE_COLUMN_SOURCE_LIST,
				MODULE_COLUMN_SOURCE     ,
				SERIES_COLUMN_LIST       ,
				SERIES_COLUMN_LIST_NAMES ,
				SERIES_COLUMN            ,
				CATEGORY_COLUMN          ,
			}, () =>
			{
				this.initCharOperators();
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getQueryBuilderState ' + MODULE + ', ' + RELATED, caller);
		try
		{
			let res  = await CreateSplendidRequest('Reports/Rest.svc/GetQueryBuilderState?Modules=' + Sql.ToString(Modules) + '&MODULE_NAME=' + Sql.ToString(MODULE) + '&RELATED=' + Sql.ToString(RELATED), 'GET');
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

	private getReportingFilterColumns = async (MODULE_NAME: string, TABLE_ALIAS: string) =>
	{
		try
		{
			let res  = await CreateSplendidRequest('Reports/Rest.svc/GetReportingFilterColumns?MODULE_NAME=' + MODULE_NAME + '&TABLE_ALIAS=' + TABLE_ALIAS, 'GET');
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

	private getFilterColumn = (MODULE_COLUMN_SOURCE: string, SERIES_COLUMN: string) =>
	{
		const { MODULE_COLUMN_SOURCE_LIST, SERIES_COLUMN_LIST } = this.state;
		if ( Sql.IsEmptyString(MODULE_COLUMN_SOURCE) )
		{
			if ( MODULE_COLUMN_SOURCE_LIST.length > 0 )
			{
				MODULE_COLUMN_SOURCE = MODULE_COLUMN_SOURCE_LIST[0].MODULE_NAME;
			}
		}
		if ( Sql.IsEmptyString(SERIES_COLUMN) )
		{
			if ( SERIES_COLUMN_LIST.length > 0 )
			{
				SERIES_COLUMN = SERIES_COLUMN_LIST[0].NAME;
			}
		}
		let sColumnName: string = Sql.ToString(SERIES_COLUMN).split('.')[1];
		if ( SERIES_COLUMN_LIST.length > 0 )
		{
			for ( let i: number = 0; i < SERIES_COLUMN_LIST.length; i++ )
			{
				let row: any = SERIES_COLUMN_LIST[i];
				if ( row['ColumnName'] == sColumnName )
				{
					return row;
				}
			}
		}
		return null;
	}

	private moduleColumnSourceChanged = async (MODULE_COLUMN_SOURCE: string) =>
	{
		let arrModule              : string[] = MODULE_COLUMN_SOURCE.split(' ');
		let sModule                : string   = arrModule[0];
		let sTableAlias            : string   = arrModule[1];
		let SERIES_COLUMN          : string   = '';
		let SERIES_COLUMN_LIST     : any[]    = null;
		let SERIES_OPERATOR_TYPE   : string   = '';
		let SERIES_OPERATOR        : string   = '';
		let SERIES_OPERATOR_LIST   : string[] = null;
		let CATEGORY_COLUMN        : string   = '';
		let CATEGORY_OPERATOR_TYPE : string   = '';
		let CATEGORY_OPERATOR      : string   = '';
		let CATEGORY_OPERATOR_LIST : string[] = null;

		// 05/15/2021 Paul.  Cache the SERIES_COLUMN_LIST. 
		SERIES_COLUMN_LIST = this.SERIES_COLUMN_LIST_CACHE[MODULE_COLUMN_SOURCE];
		if ( SERIES_COLUMN_LIST == null )
		{
			SERIES_COLUMN_LIST = await this.getReportingFilterColumns(sModule, sTableAlias);
			this.SERIES_COLUMN_LIST_CACHE[MODULE_COLUMN_SOURCE] = SERIES_COLUMN_LIST;
		}
		if ( SERIES_COLUMN_LIST!= null && SERIES_COLUMN_LIST.length > 0 )
		{
			let row: any = SERIES_COLUMN_LIST[0];
			SERIES_COLUMN          = row['NAME'];
			SERIES_OPERATOR_TYPE   = row['CsType'].toLowerCase();
			SERIES_OPERATOR        = '';
			SERIES_OPERATOR_LIST   = L10n.GetList('series_' + SERIES_OPERATOR_TYPE + '_operator_dom');
			if ( SERIES_OPERATOR_LIST && SERIES_OPERATOR_LIST.length > 0 )
			{
				SERIES_OPERATOR = SERIES_OPERATOR_LIST[0];
			}
			CATEGORY_COLUMN          = row['NAME'];
			CATEGORY_OPERATOR_TYPE   = row['CsType'].toLowerCase();
			CATEGORY_OPERATOR        = '';
			CATEGORY_OPERATOR_LIST   = L10n.GetList('category_' + CATEGORY_OPERATOR_TYPE + '_operator_dom');
			if ( CATEGORY_OPERATOR_LIST && CATEGORY_OPERATOR_LIST.length > 0 )
			{
				CATEGORY_OPERATOR = CATEGORY_OPERATOR_LIST[0];
			}
		}
		this.setState(
		{
			SERIES_COLUMN_LIST     ,
			SERIES_COLUMN          ,
			SERIES_OPERATOR_LIST   ,
			SERIES_OPERATOR        ,
			SERIES_OPERATOR_TYPE   ,

			CATEGORY_COLUMN        ,
			CATEGORY_OPERATOR_LIST ,
			CATEGORY_OPERATOR      ,
			CATEGORY_OPERATOR_TYPE ,
		});
	}

	private initCharOperators = () =>
	{
		const { MODULE_COLUMN_SOURCE, SERIES_COLUMN } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.initCharOperators ' + MODULE_COLUMN_SOURCE + ' ' + SERIES_COLUMN);
		let SERIES_OPERATOR_TYPE   : string   = '';
		let SERIES_OPERATOR        : string   = '';
		let SERIES_OPERATOR_LIST   : string[] = null;
		let CATEGORY_OPERATOR_TYPE : string   = '';
		let CATEGORY_OPERATOR      : string   = '';
		let CATEGORY_OPERATOR_LIST : string[] = null;
		let row: any = this.getFilterColumn(MODULE_COLUMN_SOURCE, SERIES_COLUMN);
		if ( row != null )
		{
			SERIES_OPERATOR_TYPE   = row['CsType'].toLowerCase();
			SERIES_OPERATOR        = '';
			SERIES_OPERATOR_LIST   = L10n.GetList('series_' + SERIES_OPERATOR_TYPE + '_operator_dom');
			if ( SERIES_OPERATOR_LIST && SERIES_OPERATOR_LIST.length > 0 )
			{
				SERIES_OPERATOR = SERIES_OPERATOR_LIST[0];
			}
			CATEGORY_OPERATOR_TYPE = row['CsType'].toLowerCase();
			CATEGORY_OPERATOR      = '';
			CATEGORY_OPERATOR_LIST = L10n.GetList('category_' + CATEGORY_OPERATOR_TYPE + '_operator_dom');
			if ( CATEGORY_OPERATOR_LIST && CATEGORY_OPERATOR_LIST.length > 0 )
			{
				CATEGORY_OPERATOR = CATEGORY_OPERATOR_LIST[0];
			}
		}
		this.setState(
		{
			SERIES_OPERATOR_LIST   ,
			SERIES_OPERATOR        ,
			SERIES_OPERATOR_TYPE   ,
			CATEGORY_OPERATOR_LIST ,
			CATEGORY_OPERATOR      ,
			CATEGORY_OPERATOR_TYPE ,
		});
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		if ( DATA_FIELD == 'filterXml' )
		{
			this.setState({ filterXml: DATA_VALUE });
		}
		else if ( DATA_FIELD == 'relatedModuleXml' )
		{
			this.setState({ relatedModuleXml: DATA_VALUE });
		}
		else if ( DATA_FIELD == 'relationshipXml' )
		{
			this.setState({ relationshipXml: DATA_VALUE });
		}
		else
		{
			let item = this.state.editedItem;
			if ( item == null )
				item = {};
			item[DATA_FIELD] = DATA_VALUE;
			if ( this._isMounted )
			{
				this.setState({ editedItem: item }, async () =>
				{
					if ( DATA_FIELD == 'MODULE_NAME' )
					{
						await this.moduleChanged(null, DATA_VALUE, null, true);
					}
					else if ( DATA_FIELD == 'RELATED' )
					{
						await this.moduleChanged(null, item['MODULE_NAME'], DATA_VALUE, true);
					}
				});
			}
		}
	}

	private _createDependency = (DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string): void =>
	{
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			dependents[PARENT_FIELD].push( {DATA_FIELD, PROPERTY_NAME} );
		}
		else
		{
			dependents[PARENT_FIELD] = [ {DATA_FIELD, PROPERTY_NAME} ]
		}
		if ( this._isMounted )
		{
			this.setState({ dependents: dependents });
		}
	}

	private _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate ' + PARENT_FIELD, DATA_VALUE);
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			let dependentIds = dependents[PARENT_FIELD];
			for ( let i = 0; i < dependentIds.length; i++ )
			{
				let ref = this.refMap[dependentIds[i].DATA_FIELD];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, DATA_VALUE, dependentIds[i].PROPERTY_NAME, item);
				}
			}
		}
	}

	// 06/15/2018 Paul.  The SearchView will register for the onSubmit event. 
	private _onSubmit = (): void =>
	{
		try
		{
			if ( this.props.onSubmit )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit');
				this.props.onSubmit();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', error);
			this.setState({ error });
		}
	}

	private UpdateModule = async (row: any, sID: string) =>
	{
		let sMODULE_NAME: string = 'Charts';
		if ( !Credentials.ValidateCredentials )
		{
			throw new Error('Invalid connection information.');
		}
		else if ( row == null )
		{
			throw new Error(this.constructor.name + '.UpdateModule: row is invalid.');
		}
		else
		{
			let sBody: string = JSON.stringify(row);
			let sUrl : string = 'Charts/Rest.svc/UpdateModule';
			let res = await CreateSplendidRequest(sUrl + '?ModuleName=' + sMODULE_NAME, 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			sID = json.d;
		}
		return sID;
	}

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, history, location } = this.props;
		const { LAST_DATE_MODIFIED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Save':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				case 'Print':
				{
					if ( this.validate() )
					{
						let isDuplicate = location.pathname.includes('Duplicate');
						// 04/01/2020 Paul.  We need to include the ReportDesign, which may not have been edited, so could be in item, or editedItem. 
						row = this.data;
						row.ID = (isDuplicate ? null : ID);
						delete row['SHOW_QUERY'];
						if ( LAST_DATE_MODIFIED != null )
						{
							row['LAST_DATE_MODIFIED'] = LAST_DATE_MODIFIED;
						}
						if ( sCommandName == 'SaveDuplicate' || sCommandName == 'SaveConcurrency' )
						{
							row[sCommandName] = true;
						}
						try
						{
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.Busy();
							}
							row.ID = await this.UpdateModule(row, isDuplicate ? null : ID);
							if ( sCommandName == 'Print' )
							{
								if ( this.headerButtons.current != null )
								{
									this.headerButtons.current.NotBusy();
								}
								let URL: string = Credentials.RemoteServer + 'Charts/render.aspx?ID=' + row.ID;
								window.location.href = URL;
							}
							else
							{
								//history.push(`/Reset/${MODULE_NAME}/View/` + row.ID);
								history.push(`/Reset/${MODULE_NAME}/List`);
							}
						}
						catch(error)
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.NotBusy();
							}
							if ( this._isMounted )
							{
								if ( error.message.includes('.ERR_DUPLICATE_EXCEPTION') )
								{
									if ( this.headerButtons.current != null )
									{
										this.headerButtons.current.ShowButton('SaveDuplicate', true);
									}
									this.setState( {error: L10n.Term(error.message) } );
								}
								else if ( error.message.includes('.ERR_CONCURRENCY_OVERRIDE') )
								{
									if ( this.headerButtons.current != null )
									{
										this.headerButtons.current.ShowButton('SaveConcurrency', true);
									}
									this.setState( {error: L10n.Term(error.message) } );
								}
								else
								{
									this.setState({ error });
								}
							}
						}
					}
					break;
				}
				case 'Cancel':
				{
					if ( Sql.IsEmptyString(ID) )
					{
						history.push(`/Reset/${MODULE_NAME}/List`);
					}
					else
					{
						//history.push(`/Reset/${MODULE_NAME}/View/${ID}`);
						// 04/01/2020 Paul.  We typically return to list instead of running reoprt. 
						history.push(`/Reset/${MODULE_NAME}/List`);
					}
					break;
				}
				case 'Run':
				{
					this.setState({ showReportPopup: true });
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
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private _onCloseReportPopup = () =>
	{
		this.setState({ showReportPopup: false });
	}

	private _onTabChange = (key) =>
	{
		this.setState({ activeTab: key });
	}

	private _onMODULE_COLUMN_SOURCE_LIST_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let MODULE_COLUMN_SOURCE: string = event.target.value;
		this.setState({ MODULE_COLUMN_SOURCE });
		this.moduleColumnSourceChanged(MODULE_COLUMN_SOURCE);
	}

	private _onSERIES_COLUMN_LIST_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { MODULE_COLUMN_SOURCE } = this.state;
		let SERIES_COLUMN          : string   = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSERIES_COLUMN_LIST_Change ' + MODULE_COLUMN_SOURCE + ' ' + SERIES_COLUMN);
		let SERIES_OPERATOR_TYPE   : string   = '';
		let SERIES_OPERATOR        : string   = '';
		let SERIES_OPERATOR_LIST   : string[] = null;
		let row: any = this.getFilterColumn(MODULE_COLUMN_SOURCE, SERIES_COLUMN);
		if ( row != null )
		{
			SERIES_OPERATOR_TYPE   = row['CsType'].toLowerCase();
			SERIES_OPERATOR        = '';
			SERIES_OPERATOR_LIST   = L10n.GetList('series_' + SERIES_OPERATOR_TYPE + '_operator_dom');
			if ( SERIES_OPERATOR_LIST && SERIES_OPERATOR_LIST.length > 0 )
			{
				SERIES_OPERATOR = SERIES_OPERATOR_LIST[0];
			}
		}
		this.setState(
		{
			SERIES_COLUMN          ,
			SERIES_OPERATOR_LIST   ,
			SERIES_OPERATOR        ,
			SERIES_OPERATOR_TYPE   ,
		});
	}

	private _onSERIES_OPERATOR_LIST_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let SERIES_OPERATOR: string = event.target.value;
		this.setState({ SERIES_OPERATOR });
	}

	private _onCATEGORY_COLUMN_LIST_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { MODULE_COLUMN_SOURCE } = this.state;
		let CATEGORY_COLUMN: string = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onCATEGORY_COLUMN_LIST_Change ' + MODULE_COLUMN_SOURCE + ' ' + SERIES_COLUMN);
		let CATEGORY_OPERATOR_TYPE : string   = '';
		let CATEGORY_OPERATOR      : string   = '';
		let CATEGORY_OPERATOR_LIST : string[] = null;
		let row: any = this.getFilterColumn(MODULE_COLUMN_SOURCE, CATEGORY_COLUMN);
		if ( row != null )
		{
			CATEGORY_OPERATOR_TYPE = row['CsType'].toLowerCase();
			CATEGORY_OPERATOR      = '';
			CATEGORY_OPERATOR_LIST = L10n.GetList('category_' + CATEGORY_OPERATOR_TYPE + '_operator_dom');
			if ( CATEGORY_OPERATOR_LIST && CATEGORY_OPERATOR_LIST.length > 0 )
			{
				CATEGORY_OPERATOR = CATEGORY_OPERATOR_LIST[0];
			}
		}
		this.setState(
		{
			CATEGORY_COLUMN        ,
			CATEGORY_OPERATOR_LIST ,
			CATEGORY_OPERATOR      ,
			CATEGORY_OPERATOR_TYPE ,
		});
	}

	private _onCATEGORY_OPERATOR_LIST_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let CATEGORY_OPERATOR: string = event.target.value;
		this.setState({ CATEGORY_OPERATOR });
	}

	private _onCHART_TYPE_Change = (CHART_TYPE) =>
	{
		let item = this.state.editedItem;
		if ( item == null )
			item = {};
		item['CHART_TYPE'] = CHART_TYPE;
		this.setState({ editedItem: item });
	}

	private _onQueryBuilderComponentComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, row) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onQueryBuilderComponentComplete');
		this.setState({ queryBuilderReady: true });
	}

	public render()
	{
		const { ID, DuplicateID } = this.props;
		const { item, layout, EDIT_NAME, SUB_TITLE, showReportPopup, activeTab, error, __sql } = this.state;
		const { MODULE_COLUMN_SOURCE_LIST, MODULE_COLUMN_SOURCE } = this.state;
		const { SERIES_COLUMN_LIST, SERIES_OPERATOR_LIST, SERIES_COLUMN, SERIES_OPERATOR, SERIES_OPERATOR_TYPE } = this.state;
		const { CATEGORY_OPERATOR_LIST, CATEGORY_COLUMN, CATEGORY_OPERATOR, CATEGORY_OPERATOR_TYPE } = this.state;
		const { filterXml, relatedModuleXml, relationshipXml, queryBuilderReady } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render: ' + EDIT_NAME, layout, item);
		// 09/09/2019 Paul.  We need to wait until item is loaded, otherwise fields will not get populated. 
		if ( layout == null || (item == null && (!Sql.IsEmptyString(ID) || !Sql.IsEmptyString(DuplicateID))) )
		{
			if ( error )
			{
				return (<ErrorComponent error={ error } />);
			}
			else
			{
				return null;
			}
		}
		this.refMap = {};
		let onSubmit = (this.props.onSubmit ? this._onSubmit : null);
		if ( SplendidCache.IsInitialized )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<React.Fragment>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: true, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<DumpSQL SQL={ __sql } />
				{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, null, this._createDependency, null, this._onChange, this._onUpdate, onSubmit, 'tabForm', this.Page_Command) }

				<ul id='pnlSearchTabs' className='tablist' style={ {paddingBottom: '5px'} }>
					<li>
						<a id='linkRulesWizard1' onClick={ (e) => { e.preventDefault(); return this._onTabChange('ModuleFilter'); } } href='#' className={ activeTab == 'ModuleFilter' ? 'current' : null }>{ L10n.Term('Reports.LBL_TABS_FILTERS') }</a>
					</li>
					<li>
						<a id='linkRulesWizard2' onClick={ (e) => { e.preventDefault(); return this._onTabChange('ChartType'); } } href='#' className={ activeTab == 'ChartType' ? 'current' : null }>{ L10n.Term('Charts.LBL_TABS_CHART_TYPE') }</a>
					</li>
				</ul>
				<div style={ {display: (activeTab == 'ModuleFilter' ? 'block' : 'none')} }>
					{ !Sql.IsEmptyString(currentItem['MODULE_NAME'])
					? <QueryBuilder
						row={ currentItem }
						DATA_FIELD='RDL'
						DisplayColumns={ [SERIES_COLUMN, CATEGORY_COLUMN] }
						UseSQLParameters={ true }
						DesignChart={ true }
						ShowRelated={ true }
						onChanged={ this._onChange }
						onComponentComplete={ this._onQueryBuilderComponentComplete }
						ref={ this.queryBuilder }
					/>
					: null
					}
				</div>
				<div style={ {display: (activeTab == 'ChartType' ? 'block' : 'none')} }>
					<table cellSpacing={ 0 } cellPadding={ 0 } style={ {borderWidth: '0px', borderCollapse: 'collapse'} }>
						<tr id="ctlQueryBuilder_trModule">
							<td className="dataLabel">
								{ L10n.Term("Reports.LBL_MODULE_NAME") }
							</td>
							<td className="dataField">
								<select
									id="ctlQueryBuilder_lstMODULE_COLUMN_SOURCE"
									tabIndex={ 10 }
									value={ MODULE_COLUMN_SOURCE }
									onChange={ this. _onMODULE_COLUMN_SOURCE_LIST_Change }
								>
									{ MODULE_COLUMN_SOURCE_LIST
									? MODULE_COLUMN_SOURCE_LIST.map((item, index) => 
									{ return (
										<option key={ 'ctlQueryBuilder_lstMODULE_COLUMN_SOURCE_' + item.MODULE_NAME } value={ item.MODULE_NAME }>{ item.DISPLAY_NAME }</option>);
									})
									: null
									}
									</select>
								<span id="ctlQueryBuilder_lblMODULE_COLUMN_SOURCE">{ MODULE_COLUMN_SOURCE }</span>
							</td>
						</tr>
					</table>
					<table className="tabForm" cellSpacing={ 1 } cellPadding={ 0 } style={ {border: 'none', width: '100%' } }>
						<tr>
							<td>
								<table style={ {border: 'none'} }>
									<tr>
										<td>
											<span className="radio">
												<input id="ctl00_cntBody_ctlEditView_ctlQueryBuilder_radChartTypeColumn" type="radio" value="radChartTypeColumn" checked={ currentItem['CHART_TYPE'] == 'Column' } onChange={ () => this. _onCHART_TYPE_Change('Column') } />
											</span>
											<img src={ this.themeURL + "images/ChartTypeColumn.gif" } style={ {borderWidth: '0px', height: '36px', width: '36px'} } /><br />
											{ L10n.ListTerm('dom_chart_types', 'Column') }
										</td>
										<td>
											<span className="radio">
												<input id="ctl00_cntBody_ctlEditView_ctlQueryBuilder_radChartTypeBar" type="radio" value="radChartTypeBar" checked={ currentItem['CHART_TYPE'] == 'Bar' } onChange={ () => this. _onCHART_TYPE_Change('Bar') } />
											</span>
											<img src={ this.themeURL + "images/ChartTypeBar.gif" } style={ {borderWidth: '0px', height: '36px', width: '36px'} } /><br />
											{ L10n.ListTerm('dom_chart_types', 'Bar') }
										</td>
										<td>
											<span className="radio">
												<input id="ctl00_cntBody_ctlEditView_ctlQueryBuilder_radChartTypeLine" type="radio" value="radChartTypeLine" checked={ currentItem['CHART_TYPE'] == 'Line' } onChange={ () => this. _onCHART_TYPE_Change('Line') } />
											</span>
											<img src={ this.themeURL + "images/ChartTypeLine.gif" } style={ {borderWidth: '0px', height: '36px', width: '36px'} } /><br />
											{ L10n.ListTerm('dom_chart_types', 'Line') }
										</td>
										<td>
											<span className="radio">
												<input id="ctl00_cntBody_ctlEditView_ctlQueryBuilder_radChartTypeShape" type="radio" value="radChartTypeShape" checked={ currentItem['CHART_TYPE'] == 'Shape' } onChange={ () => this. _onCHART_TYPE_Change('Shape') } />
											</span>
											<img src={ this.themeURL + "images/ChartTypeShape.gif" } style={ {borderWidth: '0px', height: '36px', width: '36px'} } /><br />
											{ L10n.ListTerm('dom_chart_types', 'Shape') }
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td><table style={ {borderWidth: '0px'} }>
								<tr>
									<td colSpan={ 2 }>
										<span>{ L10n.Term('Charts.LBL_SERIES') }</span>
									</td>
								</tr><tr>
									<td valign="top">
										<select
											id="ctlQueryBuilder_lstSERIES_COLUMN"
											tabIndex={ 11 }
											value={ SERIES_COLUMN }
											onChange={ this._onSERIES_COLUMN_LIST_Change }
										>
										{ SERIES_COLUMN_LIST
										? SERIES_COLUMN_LIST.map((item, index) => 
										{ return (
											<option key={ 'ctlQueryBuilder_lblSERIES_COLUMN_' + item.NAME } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
										})
										: null
										}
										</select><br />
										<span id="ctlQueryBuilder_lblSERIES_COLUMN">{ SERIES_COLUMN }</span>
									</td>
									<td valign="top">
										{ SERIES_OPERATOR_LIST
										? <div>
											<select
												id="ctlQueryBuilder_lstSERIES_OPERATOR"
												tabIndex={ 12 }
												value={ SERIES_OPERATOR }
												onChange={ this._onSERIES_OPERATOR_LIST_Change }
											>
											{ SERIES_OPERATOR_LIST.map((item, index) => 
												{ return (
													<option key={ 'ctlQueryBuilder_lstSERIES_OPERATOR_' + item } value={ item }>{ L10n.ListTerm('series_' + SERIES_OPERATOR_TYPE + '_operator_dom', item) }</option>);
												})
											}
											</select>
										</div>
										: null
										}
										<div>
											<span id="ctlQueryBuilder_lblSERIES_OPERATOR_TYPE">{ SERIES_OPERATOR_TYPE }</span>
											<img src={ this.themeURL + "images/spacer.gif" } style={ {borderWidth: '0px', width: '4px'} } />
											<span id="ctlQueryBuilder_lblSERIES_OPERATOR">{ SERIES_OPERATOR }</span>
										</div>
									</td>
								</tr>
								<tr>
									<td colSpan={ 2 }>
										<span>{ L10n.Term('Charts.LBL_CATEGORY') }</span>
									</td>
								</tr>
								<tr>
									<td valign="top">
										<select
											id="ctlQueryBuilder_lstCATEGORY_COLUMN"
											tabIndex={ 11 }
											value={ CATEGORY_COLUMN }
											onChange={ this._onCATEGORY_COLUMN_LIST_Change }
										>
										{ SERIES_COLUMN_LIST
										? SERIES_COLUMN_LIST.map((item, index) => 
										{ return (
											<option key={ 'ctlQueryBuilder_lblCATEGORY_COLUMN_' + item.NAME } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
										})
										: null
										}
										</select><br />
										<span id="ctlQueryBuilder_lblCATEGORY_COLUMN">{ CATEGORY_COLUMN }</span>
									</td>
									<td valign="top">
										{ CATEGORY_OPERATOR_LIST
										? <div>
											<select
												id="ctlQueryBuilder_lstCATEGORY_OPERATOR"
												tabIndex={ 12 }
												value={ CATEGORY_OPERATOR }
												onChange={ this._onCATEGORY_OPERATOR_LIST_Change }
											>
											{ CATEGORY_OPERATOR_LIST.map((item, index) => 
												{ return (
													<option key={ 'ctlQueryBuilder_lstCATEGORY_OPERATOR_' + item } value={ item }>{ L10n.ListTerm('category_' + CATEGORY_OPERATOR_TYPE + '_operator_dom', item) }</option>);
												})
											}
											</select>
										</div>
										: null
										}
										<div>
											<span id="ctlQueryBuilder_lblCATEGORY_OPERATOR_TYPE">{ CATEGORY_OPERATOR_TYPE }</span>
											<img src={ this.themeURL + "images/spacer.gif" } style={ {borderWidth: '0px', width: '4px'} } />
											<span id="ctlQueryBuilder_lblCATEGORY_OPERATOR">{ CATEGORY_OPERATOR }</span>
										</div>
									</td>
								</tr>
							</table></td>
						</tr>
					</table>
				</div>
				{ queryBuilderReady
				? <ChartView
					ID={ ID }
					key={ 'ChartView.' + currentItem['NAME'] + '.' + currentItem['CHART_TYPE'] + '.' + SERIES_COLUMN + '.' + CATEGORY_COLUMN }
					CHART_NAME={ currentItem['NAME'] }
					CHART_TYPE={ currentItem['CHART_TYPE'] }
					MODULE={ currentItem['MODULE_NAME'] } 
					RELATED={ currentItem['RELATED'] } 
					MODULE_COLUMN_SOURCE={ MODULE_COLUMN_SOURCE }
					SERIES_COLUMN={ SERIES_COLUMN } 
					SERIES_OPERATOR={ SERIES_OPERATOR } 
					CATEGORY_COLUMN={ CATEGORY_COLUMN }
					CATEGORY_OPERATOR={ CATEGORY_OPERATOR }
					filterXml={ filterXml }
					relatedModuleXml={ relatedModuleXml }
					relationshipXml={ relationshipXml }
				/>
				: null
				}
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

// 07/18/2019 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 

