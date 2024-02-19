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
import { RouteComponentProps, withRouter }      from '../Router5'                       ;
import { FontAwesomeIcon }                      from '@fortawesome/react-fontawesome'         ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                      from '../scripts/Sql'                         ;
import L10n                                     from '../scripts/L10n'                        ;
import Security                                 from '../scripts/Security'                    ;
import Credentials                              from '../scripts/Credentials'                 ;
import SplendidCache                            from '../scripts/SplendidCache'               ;
import { formatDate, FromJsonDate, ToJsonDate } from '../scripts/Formatting'                  ;
import { GetInviteesList }                      from '../scripts/CalendarView'                ;
// 4. Components and Views. 
import SplendidGrid                             from '../components/SplendidGrid'             ;
import ErrorComponent                           from '../components/ErrorComponent'           ;

interface IInviteesViewProps extends RouteComponentProps<any>
{
	MODULE_NAME           : string;
	DATE_START            : any;
	DURATION_HOURS        : number;
	DURATION_MINUTES      : number;
	onAddInvitee          : (INVITEE_ID: string) => void;
}

interface IInviteesViewState
{
	FIRST_NAME            : string;
	LAST_NAME             : string;
	EMAIL                 : string;
	error?                : any;
}

class InviteesView extends React.Component<IInviteesViewProps, IInviteesViewState>
{
	private _isMounted = false;
	private splendidGrid  = React.createRef<SplendidGrid>();
	private dtSCHEDULE_START: moment.Moment = moment();
	private dtSCHEDULE_END  : moment.Moment = moment();
	private dtDATE_START    : moment.Moment = null;
	private dtDATE_END      : moment.Moment = null;
	private themeUrl        : string = null;

	constructor(props: IInviteesViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props.MODULE_NAME);
		this.themeUrl = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.UpdateScheduleTime();
		this.state =
		{
			FIRST_NAME            : null,
			LAST_NAME             : null,
			EMAIL                 : null,
			error                 : null,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		try
		{
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

	shouldComponentUpdate(nextProps: IInviteesViewProps, nextState: IInviteesViewState)
	{
		const { DATE_START, DURATION_HOURS, DURATION_MINUTES } = this.props;
		if ( nextProps.DATE_START != this.props.DATE_START || nextProps.DURATION_HOURS != this.props.DURATION_HOURS || nextProps.DURATION_MINUTES != this.props.DURATION_MINUTES )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate DATE_START', DATE_START, nextProps, nextState);
			this.UpdateScheduleTime();
			return true;
		}
		else if ( nextState.FIRST_NAME != this.state.FIRST_NAME || nextState.LAST_NAME != this.state.LAST_NAME || nextState.EMAIL != this.state.EMAIL )
		{
			return true;
		}
		else if ( nextState.error != this.state.error )
		{
			return true;
		}
		return false;
	}

	private UpdateScheduleTime = () =>
	{
		const { DATE_START, DURATION_HOURS, DURATION_MINUTES } = this.props;
		this.dtSCHEDULE_START = moment();
		this.dtSCHEDULE_START.minutes(Math.floor(this.dtSCHEDULE_START.minutes()/15) * 15);
		this.dtSCHEDULE_START.seconds(0);
		this.dtSCHEDULE_START.milliseconds(0);
		this.dtSCHEDULE_END.add(9, 'hours');
		if ( DATE_START )
		{
			if ( typeof (DATE_START) == 'string' && DATE_START.substr(0, 7) === '\\/Date(' )
				this.dtDATE_START = moment(FromJsonDate(DATE_START));
			else
				this.dtDATE_START = moment(DATE_START);
			this.dtDATE_END = moment(this.dtDATE_START);
			this.dtDATE_END.add(DURATION_HOURS, 'hours');
			this.dtDATE_END.add(DURATION_MINUTES, 'minutes');
			this.dtSCHEDULE_START = moment(this.dtDATE_START);
			this.dtSCHEDULE_START.subtract(4, 'hours');
			this.dtSCHEDULE_END = moment(this.dtSCHEDULE_START);
			this.dtSCHEDULE_END.add(9, 'hours');
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateScheduleTime', formatDate(this.dtSCHEDULE_START, Security.USER_TIME_FORMAT()), formatDate(this.dtSCHEDULE_END, Security.USER_TIME_FORMAT()));
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateScheduleTime', formatDate(this.dtDATE_START    , Security.USER_TIME_FORMAT()), formatDate(this.dtDATE_END    , Security.USER_TIME_FORMAT()));
	}

	// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
	private _onSearchViewCallback = (sFILTER: string, row: any, oSORT?: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback', sFILTER, row);
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
		// 07/13/2019 Paul.  Call SubmitSearch directly. It will fire _onSearchViewCallback with the filter. 
	}

	private Grid_Command = async (sCommandName, sCommandArguments) =>
	{
		const { MODULE_NAME } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Grid_Command', sCommandName, sCommandArguments);
	}

	private Load = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		let sFIRST_NAME: string = Sql.ToString(this.state.FIRST_NAME);
		let sLAST_NAME : string = Sql.ToString(this.state.LAST_NAME );
		let sEMAIL     : string = Sql.ToString(this.state.EMAIL     );
		let sDATE_START: string = (this.dtDATE_START ? ToJsonDate(this.dtDATE_START.toDate()) : '');
		let sDATE_END  : string = (this.dtDATE_END   ? ToJsonDate(this.dtDATE_END  .toDate()) : '');
		let sORDER_BY  : string = sSORT_FIELD + ' ' + sSORT_DIRECTION;
		let d = await GetInviteesList(sFIRST_NAME, sLAST_NAME, sEMAIL, sDATE_START, sDATE_END, nTOP, nSKIP, sORDER_BY);
		return d;
	}

	private _onFirstNameChange = (e): void =>
	{
		let value = e.target.value;
		this.setState({ FIRST_NAME: value });
	}

	private _onLastNameChange = (e): void =>
	{
		let value = e.target.value;
		this.setState({ LAST_NAME: value });
	}

	private _onEmailChange = (e): void =>
	{
		let value = e.target.value;
		this.setState({ EMAIL: value });
	}

	private _onKeyDown = (event) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' && this.splendidGrid.current )
		{
			this.splendidGrid.current.Search(null, null);
		}
	}

	private _onSearch = (e) =>
	{
		e.preventDefault();
		if ( this.splendidGrid.current )
		{
			this.splendidGrid.current.Search(null, null);
		}
	}

	private _onAddInvitee = (INVITEE_ID) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onAddInvitee', INVITEE_ID);
		this.props.onAddInvitee(INVITEE_ID);
	}

	private scheduleColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		// 06/06/2020 Paul.  Only users have activities. 
		if ( Sql.ToString(row['INVITEE_TYPE']) == 'Users' )
		{
			let arrTimeRow: any[] = [];
			for ( let dtHOUR_START = moment(this.dtSCHEDULE_START); dtHOUR_START < this.dtSCHEDULE_END; dtHOUR_START.add(1, 'hours') )
			{
				arrTimeRow.push(<td className='schedulerTimeCell' colSpan={ 4 } style={ {padding: '0px'} }>{ formatDate(dtHOUR_START, Security.USER_TIME_FORMAT()) }</td>);
			}
			let invitee = row;
			let arrInviteeRow: any[] = [];
			if ( invitee && invitee.Activities && invitee.Activities.length > 0 )
			{
				for ( let dtHOUR_START = moment(this.dtSCHEDULE_START); dtHOUR_START < this.dtSCHEDULE_END; dtHOUR_START.add(15, 'minutes') )
				{
					let dtHOUR_END: moment.Moment  = moment(dtHOUR_START).add(15, 'minutes');
					let bOverlap: boolean = false;
					for ( let j: number = 0; j < invitee.Activities.length; j++ )
					{
						let activity: any = invitee.Activities[j];
						// vwMain.RowFilter = "   DATE_START >= #" + sHOUR_START_ServerTime + "# and DATE_START <  #" + sHOUR_END_ServerTime + "#" + ControlChars.CrLf
						//                  + "or DATE_END   >  #" + sHOUR_START_ServerTime + "# and DATE_END   <= #" + sHOUR_END_ServerTime + "#" + ControlChars.CrLf
						//                  + "or DATE_START <  #" + sHOUR_START_ServerTime + "# and DATE_END   >  #" + sHOUR_END_ServerTime + "#" + ControlChars.CrLf;
						if ( activity.dtDATE_START      >= dtHOUR_START && activity.dtDATE_START <  dtHOUR_END )
							bOverlap = true;
						else if ( activity.dtDATE_END   >  dtHOUR_START && activity.dtDATE_END   <= dtHOUR_END )
							bOverlap = true;
						else if ( activity.dtDATE_START <  dtHOUR_START && activity.dtDATE_END   >  dtHOUR_END )
							bOverlap = true;
					}
					let style: any = {padding: '0px'};
					if ( bOverlap )
					{
						if ( dtHOUR_START >= this.dtDATE_START && dtHOUR_START < this.dtDATE_END )
							style.backgroundColor = '#aa4d4d';
						else
							style.backgroundColor = '#4d5eaa';
					}
					else
					{
						if ( dtHOUR_START >= this.dtDATE_START && dtHOUR_START < this.dtDATE_END )
							style.backgroundColor = '#ffffff';
					}
					if ( dtHOUR_START.isSame(this.dtDATE_END) )
					{
						// 06/06/2020 Paul.  Not sure why, but bootstrap .table-bordered is over-riding our style. 
						style.borderLeft = '4px solid #ff0000';
						arrInviteeRow.push(<td className='schedulerSlotCellEndTime'   style={ style }></td>);
					}
					else if ( dtHOUR_START.isSame(this.dtDATE_START) )
					{
						// 06/06/2020 Paul.  Not sure why, but bootstrap .table-bordered is over-riding our style. 
						style.borderLeft = '4px solid #75af4f';
						arrInviteeRow.push(<td className='schedulerSlotCellStartTime' style={ style }></td>);
					}
					else
					{
						arrInviteeRow.push(<td className='schedulerSlotCellHour'      style={ style }></td>);
					}
				}
			}
			else
			{
				for ( let dtHOUR_START = moment(this.dtSCHEDULE_START); dtHOUR_START < this.dtSCHEDULE_END; dtHOUR_START.add(15, 'minutes') )
				{
					let dtHOUR_END: moment.Moment  = moment(dtHOUR_START).add(15, 'minutes');
					let style: any = {padding: '0px'};
					if ( dtHOUR_START >= this.dtDATE_START && dtHOUR_START < this.dtDATE_END )
						style.backgroundColor = '#ffffff';
					if ( dtHOUR_START.isSame(this.dtDATE_END) )
					{
						// 06/06/2020 Paul.  Not sure why, but bootstrap .table-bordered is over-riding our style. 
						style.borderLeft = '4px solid #ff0000';
						arrInviteeRow.push(<td className='schedulerSlotCellEndTime'   style={ style }></td>);
					}
					else if ( dtHOUR_START.isSame(this.dtDATE_START) )
					{
						// 06/06/2020 Paul.  Not sure why, but bootstrap .table-bordered is over-riding our style. 
						style.borderLeft = '4px solid #75af4f';
						arrInviteeRow.push(<td className='schedulerSlotCellStartTime' style={ style }></td>);
					}
					else
					{
						arrInviteeRow.push(<td className='schedulerSlotCellHour'      style={ style }></td>);
					}
				}
			}
			return (<div className='schedulerDiv'>
				<table cellPadding={ 0 } cellSpacing={ 0 } className='schedulerTable' style={ {width: '100%', border: 'unset'} }>
					<tr>
						{ arrTimeRow }
					</tr>
					<tr>
						{ arrInviteeRow }
					</tr>
				</table>
			</div>);
		}
		return null;
	}

	private typeColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		return (
		<span>
			<img title={ row['ATTACHMENT_COUNT'] } src={ this.themeUrl + row['INVITEE_TYPE'] + '.gif' } style={ {borderWidth: '0px', padding: '2px'} } />
		</span>);
	}

	private actionColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		return (
		<span>
			<input
				type='button'
				className='button'
				value={ L10n.Term('Meetings.LBL_ADD_BUTTON') }
				onClick={ (e) => { e.preventDefault(); this._onAddInvitee(row['ID']); } }
			/>
		</span>);
	}

	private BootstrapColumns = (sLIST_MODULE_NAME, layout, sPRIMARY_MODULE, sPRIMARY_ID) =>
	{
		let arrDataTableColumns = [];
		let objDataColumn: any = {};
		// 06/06/2020 Paul.  Manually add invitee fields. 
		objDataColumn =
		{
			key            : 'editview',
			text           : null,
			dataField      : 'empty2',
			formatter      : this.typeColumnFormatter,
			style          : {whiteSpace: 'nowrap'},
			headerClasses  : 'listViewThS2',
			headerStyle    : {padding: 0, margin: 0},
			headerFormatter: null,
			sort           : false,
			isDummyField   : true,
			attrs          : { width: '1%' },
			formatExtraData: {
				data: {
					GRID_NAME : sLIST_MODULE_NAME,
					DATA_FIELD: 'INVITEE_TYPE',
					fnRender  : null,
					layout    : layout
				}
			}
		};
		arrDataTableColumns.push(objDataColumn);
		objDataColumn =
		{
			key            : 'column' + 'NAME',
			text           : L10n.Term('Users.LBL_LIST_NAME'),
			dataField      : 'NAME',
			classes        : 'listViewTdLinkS1',
			style          : null,
			headerClasses  : 'listViewThS2',
			headerStyle    : {whiteSpace: 'nowrap'},
			headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader         : null),
			formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.boundColumnFormatter : null),
			sort           : false,
			isDummyField   : false,
			attrs          : { width: '15%' },
			formatExtraData: {
				data: {
					GRID_NAME   : sLIST_MODULE_NAME,
					DATA_FIELD  : 'NAME',
					COLUMN_INDEX: 1,
					layout      : 
					{
						COLUMN_TYPE    : 'BoundColumn',
						DATA_FIELD     : 'NAME',
						SORT_EXPRESSION: 'NAME',
						HEADER_TEXT    : 'Users.LBL_LIST_NAME',
					}
				}
			}
		};
		// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
		// 04/24/2022 Paul.  Move Arctic style override to style.css. 
		arrDataTableColumns.push(objDataColumn);

		objDataColumn =
		{
			key            : 'editview',
			text           : null,
			dataField      : 'empty2',
			formatter      : this.scheduleColumnFormatter,
			style          : {whiteSpace: 'nowrap', textAlign: 'right'},
			headerClasses  : 'listViewThS2',
			headerStyle    : {padding: 0, margin: 0},
			headerFormatter: null,
			sort           : false,
			isDummyField   : true,
			attrs          : { width: '50%' },
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
			key            : 'column' + 'EMAIL',
			text           : L10n.Term('Users.LBL_LIST_EMAIL'),
			dataField      : 'EMAIL',
			classes        : 'listViewTdLinkS1',
			style          : null,
			headerClasses  : 'listViewThS2',
			headerStyle    : {whiteSpace: 'nowrap'},
			headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader         : null),
			formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.boundColumnFormatter : null),
			sort           : false,
			isDummyField   : false,
			attrs          : { width: '15%' },
			formatExtraData: {
				data: {
					GRID_NAME   : sLIST_MODULE_NAME,
					DATA_FIELD  : 'EMAIL',
					COLUMN_INDEX: 1,
					layout      : 
					{
						COLUMN_TYPE    : 'BoundColumn',
						DATA_FIELD     : 'EMAIL',
						SORT_EXPRESSION: 'EMAIL',
						HEADER_TEXT    : 'Users.LBL_LIST_EMAIL',
					}
				}
			}
		};
		// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
		// 04/24/2022 Paul.  Move Arctic style override to style.css. 
		arrDataTableColumns.push(objDataColumn);
		objDataColumn =
		{
			key            : 'column' + 'PHONE',
			text           : L10n.Term('Users.LBL_LIST_PHONE_WORK'),
			dataField      : 'PHONE',
			classes        : 'listViewTdLinkS1',
			style          : {whiteSpace: 'nowrap'},
			headerClasses  : 'listViewThS2',
			headerStyle    : {whiteSpace: 'nowrap'},
			headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader         : null),
			formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.boundColumnFormatter : null),
			sort           : false,
			isDummyField   : false,
			attrs          : { width: '15%' },
			formatExtraData: {
				data: {
					GRID_NAME   : sLIST_MODULE_NAME,
					DATA_FIELD  : 'PHONE',
					COLUMN_INDEX: 1,
					layout      : 
					{
						COLUMN_TYPE    : 'BoundColumn',
						DATA_FIELD     : 'PHONE',
						SORT_EXPRESSION: 'PHONE',
						HEADER_TEXT    : 'Users.LBL_LIST_PHONE_WORK',
					}
				}
			}
		};
		// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
		// 04/24/2022 Paul.  Move Arctic style override to style.css. 
		arrDataTableColumns.push(objDataColumn);

		objDataColumn =
		{
			key            : 'editview',
			text           : null,
			dataField      : 'empty2',
			formatter      : this.actionColumnFormatter,
			style          : {whiteSpace: 'nowrap'},
			headerClasses  : 'listViewThS2',
			headerStyle    : {padding: 0, margin: 0},
			headerFormatter: null,
			sort           : false,
			isDummyField   : true,
			attrs          : { width: '4%' },
			formatExtraData: {
				data: {
					GRID_NAME : sLIST_MODULE_NAME,
					DATA_FIELD: 'ID',
					fnRender  : null,
					layout    : layout
				}
			}
		};
		arrDataTableColumns.push(objDataColumn);
		return arrDataTableColumns;
	}

	public render()
	{
		const { MODULE_NAME } = this.props;
		const { FIRST_NAME, LAST_NAME, EMAIL, error } = this.state;
		if ( SplendidCache.IsInitialized )
		{
			// 10/27/2020 Paul.  size is cause text field to overflow the parent, into the label on the right. 
			return (
			<div style={ {display: 'flex', flexDirection: 'row', flexWrap: 'nowrap', width: '100%'} }>
				<div id='divListView' style={ {width: '100%'} }>
					<h5 className='listViewSubHeadS1'>{ L10n.Term(MODULE_NAME + '.LBL_ADD_INVITEE') }</h5>
					<ErrorComponent error={ error } />
					<div>
						<table className='tabSearchForm' cellSpacing={ 1 } cellPadding={ 0 } style={ {border: 'none', width: '100%'} }>
							<tr>
								<td>
									<table style={ {border: 'none'} }>
										<tr>
											<td className='dataLabel'>
												{ L10n.Term(MODULE_NAME + '.LBL_FIRST_NAME') }
											</td>
											<td className='dataField'>
												<input
													type='text'
													style={ {minWidth: (35 * 5).toString() + 'px'} }
													value={ FIRST_NAME }
													onChange={ this._onFirstNameChange }
													onKeyDown={ this._onKeyDown }
												/>
											</td>
											<td className='dataLabel'>
												{ L10n.Term(MODULE_NAME + '.LBL_LAST_NAME') }
											</td>
											<td className='dataField'>
												<input
													type='text'
													style={ {minWidth: (35 * 5).toString() + 'px'} }
													value={ LAST_NAME }
													onChange={ this._onLastNameChange }
													onKeyDown={ this._onKeyDown }
												/>
											</td>
											<td className='dataLabel'>
												{ L10n.Term(MODULE_NAME + '.LBL_EMAIL') }
											</td>
											<td className='dataField'>
												<input
													type='text'
													style={ {minWidth: (35 * 5).toString() + 'px'} }
													value={ EMAIL }
													onChange={ this._onEmailChange }
													onKeyDown={ this._onKeyDown }
												/>
											</td>
											<td align='right'>
												<input
													type='submit'
													value={ L10n.Term('.LBL_SEARCH_BUTTON_LABEL') }
													title={ L10n.Term('.LBL_SEARCH_BUTTON_TITLE') }
													className='button'
													onClick={ this._onSearch }
												/>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</div>
					<SplendidGrid
						onLayoutLoaded={ this._onGridLayoutLoaded }
						MODULE_NAME={ MODULE_NAME }
						GRID_NAME={ MODULE_NAME + '.InviteesView' }
						TABLE_NAME='vwACTIVITIES_List'
						SORT_FIELD='INVITEE_TYPE desc, LAST_NAME asc, FIRST_NAME'
						SORT_DIRECTION='asc'
						ADMIN_MODE={ false }
						archiveView={ false }
						deferLoad={ true }
						disableEdit={ true }
						disableView={ true }
						enableSelection={ false }
						enableFavorites={ false }
						enableFollowing={ false }
						enableMassUpdate={ false }
						disableInitialLoading={ true }
						ignoreMissingLayout={ true }
						cbCustomColumns={ this.BootstrapColumns }
						cbCustomLoad={ this.Load }
						Page_Command={ this.Grid_Command }
						scrollable
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.splendidGrid }
					/>
				</div>
			</div>
			);
		}
		else
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon='spinner' spin={ true } size='5x' />
			</div>);
		}
	}
}

export default withRouter(InviteesView);
