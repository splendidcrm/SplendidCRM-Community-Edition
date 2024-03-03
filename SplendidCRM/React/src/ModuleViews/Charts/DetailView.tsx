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
import { RouteComponentProps, withRouter }            from '../Router5'                          ;
import { observer }                                   from 'mobx-react'                                ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome'            ;
import * as XMLParser                                 from 'fast-xml-parser'                           ;
// 2. Store and Types. 
import { HeaderButtons }                              from '../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                            from '../../scripts/Sql'                         ;
import L10n                                           from '../../scripts/L10n'                        ;
import Credentials                                    from '../../scripts/Credentials'                 ;
import SplendidCache                                  from '../../scripts/SplendidCache'               ;
import { AuthenticatedMethod, LoginRedirect }         from '../../scripts/Login'                       ;
import { DetailView_LoadItem }                        from '../../scripts/DetailView'                  ;
import { Crm_Config, Crm_Modules }                    from '../../scripts/Crm'                         ;
import { StartsWith, EndsWith }                       from '../../scripts/utility'                     ;
import { DeleteModuleItem }                           from '../../scripts/ModuleUpdate'                ;
import { CreateSplendidRequest, GetSplendidResult }   from '../../scripts/SplendidRequest'             ;
import { jsonReactState }                             from '../../scripts/Application'                 ;
import withScreenSizeHook                             from '../../scripts/ScreenSizeHook'              ;
// 4. Components and Views. 
import ErrorComponent                                 from '../../components/ErrorComponent'           ;
import DumpSQL                                        from '../../components/DumpSQL'                  ;
import HeaderButtonsFactory                           from '../../ThemeComponents/HeaderButtonsFactory';
import ChartView                                      from './ChartView'                               ;

let MODULE_NAME: string = 'Charts';

interface IDetailViewProps extends RouteComponentProps<any>
{
	ID?          : string;
	NAME?        : string;
	ReportDesign?: any;
	screenSize   : any;
}

interface IDetailViewState
{
	__sql                      : string ;
	item                       : any    ;
	SUB_TITLE                  : any    ;
	reportXml                  : any    ;
	reportXmlJson              : string ;
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
	error                      : any    ;
}

@observer
class DetailView extends React.Component<IDetailViewProps, IDetailViewState>
{
	private _isMounted     : boolean = false;
	private headerButtons  = React.createRef<HeaderButtons>();

	constructor(props: IDetailViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props.ID);
		this.state =
		{
			__sql                      : null,
			item                       : null,
			SUB_TITLE                  : null,
			reportXml                  : {},
			reportXmlJson              : null,
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
			error                      : null,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { ID } = this.props;
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
				if ( !Sql.IsEmptyGuid(ID) )
				{
					await this.load();
				}
				else
				{
					this.setState({ SUB_TITLE: this.props.NAME });
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

	async componentDidUpdate(prevProps: IDetailViewProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private load = async () =>
	{
		const { ID } = this.props;
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
			const d = await DetailView_LoadItem(MODULE_NAME, ID, false, false);
			if ( this._isMounted )
			{
				let item: any = d.results;
				// 11/23/2020 Paul.  Update document title. 
				Sql.SetPageTitle(MODULE_NAME, item, 'NAME');
				let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');

				let reportXml                  : any    = null;
				let reportXmlJson              : string = null;
				let MODULE_COLUMN_SOURCE_LIST  : any[]  = [];
				let SERIES_COLUMN_LIST         : any[]  = [];
				let SERIES_COLUMN_LIST_NAMES   : any    = {};
				let SERIES_OPERATOR_LIST       : any[]  = [];
				let CATEGORY_OPERATOR_LIST     : any[]  = [];
				let MODULE_COLUMN_SOURCE       : string = null;
				let SERIES_COLUMN              : string = null;
				let SERIES_OPERATOR            : string = null;
				let SERIES_OPERATOR_TYPE       : string = null;
				let CATEGORY_COLUMN            : string = null;
				let CATEGORY_OPERATOR          : string = null;
				let CATEGORY_OPERATOR_TYPE     : string = null;
				let filterXml                  : any    = null;
				let relatedModuleXml           : any    = null;
				let relationshipXml            : any    = null;
				if ( item != null )
				{
					// 04/29/2019 Paul.  Manually add to the list so that we do not need to request an update. 
					let sNAME = Sql.ToString(item['NAME']);
					if ( !Sql.IsEmptyString(sNAME) )
					{
						SplendidCache.AddLastViewed(MODULE_NAME, ID, sNAME);
					}
					
					let sRDL: string = Sql.ToString(item['RDL']);
					if ( !Sql.IsEmptyString(sRDL) && StartsWith(sRDL, '<?xml') && Sql.ToString(item['CHART_TYPE']) != 'Freeform' )
					{
						reportXml = XMLParser.parse(sRDL, options);
						if ( reportXml.Report != null )
						{
							if ( reportXml.Report.CustomProperties != null && reportXml.Report.CustomProperties.CustomProperty != null && Array.isArray(reportXml.Report.CustomProperties.CustomProperty) )
							{
								for ( let i = 0; i < reportXml.Report.CustomProperties.CustomProperty.length; i++ )
								{
									let customProperty: any = reportXml.Report.CustomProperties.CustomProperty[i];
									let sName : string = customProperty.Name;
									let sValue: string = customProperty.Value;
									switch ( sName )
									{
										case 'crm:Module'    :  item['MODULE_NAME'] = customProperty.Value;  break;
										case 'crm:Related'   :  item['RELATED'    ] = customProperty.Value;  break;
										case 'crm:RelatedModules':
											// 05/15/2021 Paul.  Ignore data from file and just use latest QueryBuilderState. 
											sValue = this.decodeHTML(sValue);
											relatedModuleXml = XMLParser.parse(sValue, options);
											// 05/14/2021 Paul.  If there is only one, convert to an array. 
											if ( relatedModuleXml.Relationships && relatedModuleXml.Relationships.Relationship && !Array.isArray(relatedModuleXml.Relationships.Relationship) )
											{
												let relationship1: any = relatedModuleXml.Relationships.Relationship;
												relatedModuleXml.Relationships.Relationship = [];
												relatedModuleXml.Relationships.Relationship.push(relationship1);
											}
											break;
										case 'crm:Relationships' :
											// 05/15/2021 Paul.  Ignore data from file and just use latest QueryBuilderState. 
											sValue = this.decodeHTML(sValue);
											relationshipXml  = XMLParser.parse(sValue, options);
											// 05/14/2021 Paul.  If there is only one, convert to an array. 
											if ( relationshipXml.Relationships && relationshipXml.Relationships.Relationship && !Array.isArray(relationshipXml.Relationships.Relationship) )
											{
												let relationship1: any = relationshipXml.Relationships.Relationship;
												relationshipXml.Relationships.Relationship = [];
												relationshipXml.Relationships.Relationship.push(relationship1);
											}
											break;
										case 'crm:Filters'       :
											sValue = this.decodeHTML(sValue);
											filterXml        = XMLParser.parse(sValue, options);
											// 05/14/2021 Paul.  If there is only one, convert to an array. 
											if ( filterXml.Filters && filterXml.Filters.Filter && !Array.isArray(filterXml.Filters.Filter) )
											{
												let Filter1: any = filterXml.Filters.Filter;
												filterXml.Filters.Filter = [];
												filterXml.Filters.Filter.push(Filter1);
											}
											break;
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
				this.setState(
				{
					item                     ,
					SUB_TITLE                ,
					__sql                    : d.__sql,
					reportXml                ,
					reportXmlJson            ,
					MODULE_COLUMN_SOURCE     ,
					SERIES_COLUMN            ,
					SERIES_OPERATOR          ,
					SERIES_OPERATOR_TYPE     ,
					CATEGORY_COLUMN          ,
					CATEGORY_OPERATOR        ,
					CATEGORY_OPERATOR_TYPE   ,
					filterXml                ,
					relatedModuleXml         ,
					relationshipXml          ,
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private decodeHTML = (html) =>
	{
		var txt = document.createElement('textarea');
		txt.innerHTML = html;
		return txt.value;
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

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
			case 'Delete':
			{
				try
				{
					await DeleteModuleItem(MODULE_NAME, ID);
					history.push(`/Reset/${MODULE_NAME}/List`);
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
					this.setState({ error });
				}
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

	private _onButtonsLoaded = async () =>
	{
		// 08/12/2019 Paul.  Here is where we can disable buttons immediately after they were loaded. 
		if ( this.headerButtons.current != null )
		{
			this.headerButtons.current.ShowButton('Submit', false);
		}
	}

	public render()
	{
		const { ID, ReportDesign, screenSize } = this.props;
		const { __sql, item, SUB_TITLE, error } = this.state;
		const { MODULE_COLUMN_SOURCE, SERIES_COLUMN, SERIES_OPERATOR, SERIES_OPERATOR_TYPE } = this.state;
		const { CATEGORY_COLUMN, CATEGORY_OPERATOR, CATEGORY_OPERATOR_TYPE } = this.state;
		const { filterXml, relatedModuleXml, relationshipXml } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render screenSize', screenSize);
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		// 05/15/2018 Paul.  Defer process button logic. 
		// 06/26/2019 Paul.  Specify a key so that SplendidGrid will get componentDidMount when changing views. 
		if ( SplendidCache.IsInitialized && (item || ReportDesign) )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let height     : number = screenSize.height - 180;
			let VIEW_NAME  : string = null;
			let sSCRIPT_URL: string = Credentials.RemoteServer + 'Charts/view_embedded.aspx';
			if ( !Sql.IsEmptyGuid(ID) )
			{
				VIEW_NAME = 'Charts.DetailView';
				sSCRIPT_URL += '?ID=' + ID;
			}
			else
			{
				height = screenSize.height - 220;
				sSCRIPT_URL += '?ReportDesign=' + encodeURIComponent(ReportDesign);
			}
			return (
			<React.Fragment>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, hideTitle: Sql.IsEmptyGuid(ID), enableFavorites: !Sql.IsEmptyGuid(ID), error, enableHelp: !Sql.IsEmptyGuid(ID), helpName: 'DetailView', ButtonStyle: 'ModuleHeader', VIEW_NAME, row: item, Page_Command: this.Page_Command, showButtons: !Sql.IsEmptyGuid(ID), showProcess: false, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<DumpSQL SQL={ __sql } />
				{ MODULE_COLUMN_SOURCE && SERIES_COLUMN && CATEGORY_COLUMN && CATEGORY_OPERATOR && filterXml
				? <ChartView
					ID={ ID }
					key={ 'ChartView.' + item['NAME'] + '.' + item['CHART_TYPE'] + '.' + SERIES_COLUMN + '.' + CATEGORY_COLUMN }
					CHART_NAME={ item['NAME'] }
					CHART_TYPE={ item['CHART_TYPE'] }
					MODULE={ item['MODULE_NAME'] } 
					RELATED={ item['RELATED'] } 
					MODULE_COLUMN_SOURCE={ MODULE_COLUMN_SOURCE }
					SERIES_COLUMN={ SERIES_COLUMN } 
					SERIES_OPERATOR={ SERIES_OPERATOR } 
					CATEGORY_COLUMN={ CATEGORY_COLUMN }
					CATEGORY_OPERATOR={ CATEGORY_OPERATOR }
					filterXml={ filterXml }
					relatedModuleXml={ relatedModuleXml }
					relationshipXml={ relationshipXml }
				/>
				: <div style={ {display: 'flex', flexGrow: 1} }>
					<iframe src={ sSCRIPT_URL } className="embed-responsive-item" width="100%" height={ height.toString() + 'px'}></iframe>
				</div>
				}
			</React.Fragment>
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

// 02/04/2024 Paul.  Prepare for v18 by swapping order. 
export default withScreenSizeHook(withRouter(DetailView));
