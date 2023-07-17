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
import { RouteComponentProps, withRouter }    from 'react-router-dom'             ;
import { observer }                           from 'mobx-react'                   ;
import BootstrapTable                         from 'react-bootstrap-table-next'   ;
import paginationFactory, { PaginationProvider, PaginationListStandalone, PaginationTotalStandalone } from 'react-bootstrap-table2-paginator';
// 2. Store and Types. 
import ACL_FIELD_ACCESS                       from '../types/ACL_FIELD_ACCESS'    ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'               ;
import L10n                                   from '../scripts/L10n'              ;
import Security                               from '../scripts/Security'          ;
import Credentials                            from '../scripts/Credentials'       ;
import SplendidCache                          from '../scripts/SplendidCache'     ;
import { Crm_Config }                         from '../scripts/Crm'               ;
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'             ;
// 4. Components and Views. 
import ErrorComponent                         from '../components/ErrorComponent' ;
import DateTime                               from '../GridComponents/DateTime'   ;
import Currency                               from '../GridComponents/Currency'   ;
import Tags                                   from '../GridComponents/Tags'       ;
import HyperLink                              from '../GridComponents/HyperLink'  ;
import Hover                                  from '../GridComponents/Hover'      ;
import Image                                  from '../GridComponents/Image'      ;
import ImageButton                            from '../GridComponents/ImageButton';
import JavaScript                             from '../GridComponents/JavaScript' ;
import String                                 from '../GridComponents/String'     ;

interface IResultsPaginateResponsesProps extends RouteComponentProps<any>
{
	ANSWERED                : any[];
	DATE_ENTERED_NAME       : string;
	ANSWER_TEXT_NAME        : string;
	tableClasses?           : string;
	dateColumnClasses?      : string;
	textColumnClasses?      : string;
	viewColumnClasses?      : string;
}

interface IResultsPaginateResponsesState
{
	vwMain                  : any;
	columns                 : any;
	__total                 : number;
	loaded                  : boolean;
	activePage              : number;
	TOP                     : number;
	error?                  : any;
}
@observer
class ResultsPaginateResponses extends React.Component<IResultsPaginateResponsesProps, IResultsPaginateResponsesState>
{
	private _isMounted = false;

	private setStateAsync = (newState: Partial<IResultsPaginateResponsesState>) =>
	{
		return new Promise((resolve) =>
		{
			// 05/26/2019 Paul.  The component may be unmounted by the time the custom view is generated. 
			if ( this._isMounted )
			{
				newState.error = null;
				// 02/25/2022 Paul.  Latest version of TypeScript does not allow resolve to return undefined, so return null. 
				this.setState(newState as IResultsPaginateResponsesState, () => resolve(null) );
			}
		});
	}

	constructor(props: IResultsPaginateResponsesProps)
	{
		super(props);
		let nTOP = Crm_Config.ToInteger('list_max_entries_per_page');
		if ( nTOP <= 0 )
		{
			nTOP = 25;
		}
		this.state =
		{
			vwMain          : null,
			columns         : [],
			__total         : (props.ANSWERED ? props.ANSWERED.length : 0),
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount');
		await this.preload();
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private preload = async () =>
	{
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.preload');
			if ( status == 1 )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.preload Authenticated');
				await this.Load();
			}
			else
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.preload Not authenticated, redirect to login');
				LoginRedirect(this.props.history, this.constructor.name + '.preload');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.preload', error);
			this.setState({ error });
		}
	}

	private Load = async () =>
	{
		const { ANSWERED } = this.props;
		const { TOP, activePage } = this.state;
		try
		{
			let columns = this.BootstrapColumns();
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.Search');
			if ( status == 1 )
			{
				let results: any[] = (ANSWERED ? this.props.ANSWERED.slice(TOP * (activePage - 1), TOP) : []);
				this.createKeys(results);
				await this.setStateAsync(
				{
					columns: columns,
					vwMain: results,
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Load', error);
			this.setState({ error });
		}
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
		let hyperLinkCallback          = null;
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

	private detailsColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		const { history } = this.props;
		let MODULE_NAME     : string = 'SurveyResults';
		let SURVEY_RESULT_ID: string = Sql.ToString(row['SURVEY_RESULT_ID']);
		let DISPLAY_NAME    : string = L10n.Term('Surveys.LBL_DETAILS');
		// 07/08/2023 Paul.  ASP.NET Core will not have /React in the base. 
		let URL             : string = Credentials.RemoteServer + Credentials.ReactBase + MODULE_NAME + '/View/' + SURVEY_RESULT_ID;
		return (
			<a href={ URL } onClick={ (e) => { e.preventDefault(); history.push(`/Reset/${MODULE_NAME}/View/${SURVEY_RESULT_ID}`); } } style={ {cursor: 'pointer'} }>{ DISPLAY_NAME }</a>
		);
	}

	private BootstrapColumns = () =>
	{
		const { DATE_ENTERED_NAME, ANSWER_TEXT_NAME } = this.props;
		const { dateColumnClasses, textColumnClasses, viewColumnClasses } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.BootstrapColumns', this.props);
		// 04/20/2017 Paul.  Build DataTables columns. 
		let arrDataTableColumns = [];
		let objDataColumn: any = {};
		objDataColumn =
		{
			key            : 'columnDate',
			text           : null,
			dataField      : DATE_ENTERED_NAME,
			classes        : (dateColumnClasses ? dateColumnClasses : 'SurveyResultsTextResponses SurveyResultsTextResponsesDate'),
			formatter      : this.templateColumnFormatter,
			sort           : false,
			isDummyField   : false,
			formatExtraData:
			{
				data:
				{
					DATA_FIELD  : DATE_ENTERED_NAME,
					COLUMN_INDEX: 1,
					layout      : 
					{
						COLUMN_TYPE    : 'TemplateColumn',
						DATA_FORMAT    : 'DateTime',
						DATA_FIELD     : DATE_ENTERED_NAME,
					}
				}
			}
		};
		arrDataTableColumns.push(objDataColumn);

		objDataColumn =
		{
			key            : 'columnText',
			text           : null,
			dataField      : ANSWER_TEXT_NAME,
			classes        : (textColumnClasses ? textColumnClasses : 'SurveyResultsTextResponses SurveyResultsTextResponsesText'),
			formatter      : this.boundColumnFormatter,
			sort           : false,
			isDummyField   : false,
			formatExtraData:
			{
				data:
				{
					DATA_FIELD  : ANSWER_TEXT_NAME,
					COLUMN_INDEX: 2,
					layout      : 
					{
						COLUMN_TYPE    : 'BoundColumn',
						DATA_FORMAT    : null,
						DATA_FIELD     : ANSWER_TEXT_NAME,
					}
				}
			}
		};
		arrDataTableColumns.push(objDataColumn);

		objDataColumn =
		{
			key            : 'details',
			text           : null,
			dataField      : 'SURVEY_RESULT_ID',
			classes        : (viewColumnClasses ? viewColumnClasses : 'SurveyResultsTextResponses SurveyResultsTextResponsesView'),
			formatter      : this.detailsColumnFormatter,
			sort           : false,
			isDummyField   : true,
			formatExtraData:
			{
				data:
				{
					DATA_FIELD  : 'SURVEY_RESULT_ID',
					COLUMN_INDEX: 3,
					layout      : 
					{
						COLUMN_TYPE    : 'TemplateColumn',
						DATA_FORMAT    : 'HyperLink',
						DATA_FIELD     : 'Surveys.LBL_DETAILS',
						URL_FIELD      : 'SURVEY_RESULT_ID',
						URL_FORMAT     : '~/SurveyResults/View/{0}',
					}
				}
			}
		};
		arrDataTableColumns.push(objDataColumn);
		return arrDataTableColumns;
	}

	private _onPageChange = async (page, sizePerPage) =>
	{
		const { ANSWERED } = this.props;
		const { TOP } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onPageChange', page);
		await this.setStateAsync({ activePage: page });
		try
		{
			let results: any[] = (ANSWERED ? this.props.ANSWERED.slice(TOP * (page - 1), TOP) : []);
			this.createKeys(results);
			await this.setStateAsync({ vwMain: results });
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
		const { tableClasses } = this.props;
		const { vwMain, activePage, columns, TOP, error } = this.state;
		const { __total } = this.state;
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
							<table cellSpacing={ 1 } cellPadding={ 3 } style={ {width: '100%'} }>
								<tr className='SurveyResultsPagination'>
									<td style={ {textAlign: 'right'} }>
										<span style={ {cursor: 'pointer'} } onClick={ () => this._onPrevPage(paginationProps) }>
											&lt;
											<span style={ {margin: '3px'} }>{ paginationProps.prePageText }</span>
										</span>
										<span style={ {margin: '3px'} }>
											({ paginationProps.paginationTotalRenderer(paginationProps.pageStartIndex + (paginationProps.page - 1) * paginationProps.sizePerPage, Math.min(paginationProps.page * paginationProps.sizePerPage, paginationProps.totalSize), paginationProps.totalSize) })
										</span>
										<span style={ {cursor: 'pointer'} } onClick={ () => this._onNextPage(paginationProps) }>
											<span style={ {margin: '3px'} }>{ paginationProps.nextPageText }</span>
											&gt;
										</span>
									</td>
								</tr>
							</table>
							{ false ? <PaginationTotalStandalone { ...paginationProps } /> : null }
							{ false ? <PaginationListStandalone  { ...paginationProps } /> : null }
							<BootstrapTable
								keyField='ID_key'
								data={ vwMain }
								classes={ tableClasses ? tableClasses : 'SurveyResultsAllResponses'}
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

export default withRouter(ResultsPaginateResponses);
