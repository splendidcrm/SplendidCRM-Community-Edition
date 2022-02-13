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
import { RouteComponentProps, withRouter }          from 'react-router-dom'                     ;
import { observer }                                 from 'mobx-react'                           ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'       ;
// 2. Store and Types. 
import MODULE                                       from '../../../types/MODULE'                ;
import { HeaderButtons }                            from '../../../types/HeaderButtons'         ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                 ;
import L10n                                         from '../../../scripts/L10n'                ;
import Security                                     from '../../../scripts/Security'            ;
import Credentials                                  from '../../../scripts/Credentials'         ;
import SplendidCache                                from '../../../scripts/SplendidCache'       ;
import SplendidDynamic                              from '../../../scripts/SplendidDynamic'     ;
import { ListView_LoadModule }                      from '../../../scripts/ListView'            ;
import { Crm_Config, Crm_Modules }                  from '../../../scripts/Crm'                 ;
import { Admin_GetReactState }                      from '../../../scripts/Application'         ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'               ;
import { AdminProcedure }                           from '../../../scripts/ModuleUpdate'        ;
// 4. Components and Views. 
import DumpSQL                                      from '../../../components/DumpSQL'          ;
import ErrorComponent                               from '../../../components/ErrorComponent'   ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';
import ListHeader                                   from '../../../components/ListHeader'       ;
import SearchView                                   from '../../../views/SearchView'            ;
import DraggableRow                                 from '../Dropdown/DraggableRow'             ;

const MODULE_NAME: string = 'Workflows';

interface ISequenceViewProps extends RouteComponentProps<any>
{
	RELATED_MODULE?       : string;
	GRID_NAME?            : string;
	TABLE_NAME?           : string;
	SORT_FIELD?           : string;
	SORT_DIRECTION?       : string;
	callback?             : Function;
	rowRequiredSearch?    : any;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface ISequenceViewState
{
	__sql?                : string;
	error?                : any;
	rowDefaultSearch      : any;
	vwMain                : any;
	editIndex             : number;
	editNAME              : string;
	editDISPLAY_NAME      : string;
}

@observer
export default class SequenceView extends React.Component<ISequenceViewProps, ISequenceViewState>
{
	private _isMounted    = false;
	private searchView    = React.createRef<SearchView>();
	private headerButtons = React.createRef<HeaderButtons>();
	private themeURL      : string = null;

	constructor(props: ISequenceViewProps)
	{
		super(props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.state =
		{
			error                 : null,
			rowDefaultSearch      : null,
			vwMain                : null,
			editIndex             : -1,
			editNAME              : null,
			editDISPLAY_NAME      : null,
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
				// 07/06/2020 Paul.  Admin_GetReactState will also generate an exception, but catch anyway. 
				if ( !(Security.IS_ADMIN() || SplendidCache.AdminUserAccess(MODULE_NAME, 'list') >= 0) )
				{
					throw(L10n.Term('.LBL_INSUFFICIENT_ACCESS'));
				}
				// 10/27/2019 Paul.  In case of single page refresh, we need to make sure that the AdminMenu has been loaded. 
				if ( SplendidCache.AdminMenu == null )
				{
					await Admin_GetReactState(this.constructor.name + '.componentDidMount');
				}
				if ( !Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(true);
				}
				document.title = L10n.Term('Workflows.LBL_LIST_FORM_TITLE');
				// 04/26/2020 Paul.  Reset scroll every time we set the title. 
				window.scroll(0, 0);
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

	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
 	async componentDidUpdate(prevProps: ISequenceViewProps)
	{
		if ( this.props.onComponentComplete )
		{
			const { RELATED_MODULE, GRID_NAME } = this.props;
			const { vwMain, error } = this.state;
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + GRID_NAME, vwMain);
			if ( vwMain != null && error == null )
			{
				this.props.onComponentComplete(MODULE_NAME, RELATED_MODULE, GRID_NAME, vwMain);
			}
		}
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
	private _onSearchViewCallback = (sFILTER: string, row: any, oSORT?: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback');
		try
		{
			this.setState(
			{
				rowDefaultSearch: row,
			}, () =>
			{
				ListView_LoadModule('Workflows', 'LIST_ORDER_Y', 'asc', 'ID,NAME,TYPE,BASE_MODULE,STATUS,LIST_ORDER_Y', sFILTER, row).then((d) =>
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback ' + MODULE_TYPE + ' ' + DATA_FIELD, d.results);
					this.setState(
					{
						vwMain: d.results,
						__sql : d.__sql,
					});
				})
				.catch((error) =>
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback', error);
				});
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback', error);
			this.setState({ error });
		}
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		let { rowDefaultSearch } = this.state;
		if ( rowDefaultSearch == null )
			rowDefaultSearch = {};
		rowDefaultSearch[DATA_FIELD] = DATA_VALUE;
		this.setState({ rowDefaultSearch });
		if ( this.searchView && this.searchView.current )
		{
			this.searchView.current.SubmitSearch();
		}
	}

	private _onSearchLayoutLoaded = () =>
	{
		if ( this.searchView && this.searchView.current )
		{
			this.searchView.current.SubmitSearch();
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
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

	private moveDraggableRow = (dragIndex: number, hoverIndex: number) =>
	{
		let { vwMain } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moveDraggableRow', dragIndex, hoverIndex);
		/*
		const row = vwMain.splice(dragIndex, 1)[0];
		vwMain.splice(hoverIndex, 0, row);
		if ( this._isMounted )
		{
			this.setState({ vwMain, error: null });
		}
		*/
	}

	private moveDraggableItem = (id: string, hoverColIndex: number, hoverRowIndex: number, didDrop: boolean) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moveDraggableItem ' + id, hoverColIndex, hoverRowIndex);
	}

	private addSourceItem = (id: string, hoverColIndex: number, hoverRowIndex: number) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.addSourceItem', id, hoverColIndex, hoverRowIndex);
	}

	private addSourceRow = (id: string, hoverIndex: number) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.addSourceRow', id, hoverIndex);
	}

	private removeRow = (index: number) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.removeRow', index);
		this.searchView.current.SubmitSearch();
	}

	private dropComplete = async (sourceIndex: number, dropIndex: number) =>
	{
		let { rowDefaultSearch, vwMain } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.dropComplete', sourceIndex, dropIndex);
		try
		{
			if ( sourceIndex != dropIndex )
			{
				let row: any = {};
				row.BASE_MODULE  = rowDefaultSearch['BASE_MODULE'].value;
				row.OLD_INDEX    = vwMain[sourceIndex].LIST_ORDER_Y;
				row.NEW_INDEX    = vwMain[dropIndex  ].LIST_ORDER_Y;

				await AdminProcedure('spWORKFLOWS_ORDER_MoveItem', row);
				this.searchView.current.SubmitSearch();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.dropComplete', error);
			if ( this._isMounted )
			{
				this.setState({ error });
			}
		}
	}

	public render()
	{
		const { error, rowDefaultSearch, vwMain, editIndex, editNAME, editDISPLAY_NAME, __sql } = this.state;

		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = MODULE_NAME + '.LBL_LIST_FORM_TITLE';
			let HEADER_BUTTONS: string = '';
			if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
			{
				HEADER_BUTTONS = MODULE_NAME + '.ListView';
			}
			return (
			<div>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, error, enableHelp: true, helpName: 'index', ButtonStyle: 'ModuleHeader', VIEW_NAME: HEADER_BUTTONS, Page_Command: this.Page_Command, showButtons: true, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<div>
					<SearchView
						key={ MODULE_NAME + '.SearchSequence' }
						EDIT_NAME={ MODULE_NAME + '.SearchSequence' }
						AutoSaveSearch={ false }
						disableClear={ true }
						rowDefaultSearch={ rowDefaultSearch }
						cbSearch={ this._onSearchViewCallback }
						onChange={ this._onChange }
						onLayoutLoaded={ this._onSearchLayoutLoaded }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.searchView }
					/>
				</div>
				<br />
				<ListHeader TITLE='Workflows.LNK_WORKFLOWS_SEQUENCE' />
				<DumpSQL SQL={ __sql } />
				<table className='table-hover listView' cellSpacing={ 1 } cellPadding={ 3 } style={ {width: '100%'} }>
					<thead>
						<tr className='listViewThS1'>
							<td style={ {width: '20pt'} }></td>
							<td style={ {width: '39%', whiteSpace: 'nowrap'} }>{ L10n.Term('Workflows.LBL_LIST_NAME'        ) }</td>
							<td style={ {width: '25%', whiteSpace: 'nowrap'} }>{ L10n.Term('Workflows.LBL_LIST_TYPE'        ) }</td>
							<td style={ {width: '25%', whiteSpace: 'nowrap'} }>{ L10n.Term('Workflows.LBL_LIST_BASE_MODULE' ) }</td>
							<td style={ {width: '10%', whiteSpace: 'nowrap'} }>{ L10n.Term('Workflows.LBL_LIST_STATUS'      ) }</td>
							<td style={ {width: '9%' , whiteSpace: 'nowrap'} }>{ L10n.Term('Workflows.LBL_LIST_LIST_ORDER_Y') }</td>
							<td></td>
						</tr>
					</thead>
					<tbody>
				{ vwMain
				? vwMain.map((item, index) => 
					{
						return (
					<DraggableRow
						index={ index }
						id={ index + '_row' }
						key={ index + '_row' }
						className={ index % 2 ? 'evenListRowS1' : 'oddListRowS1' }
						moveDraggableRow={ this.moveDraggableRow }
						moveDraggableItem={ this.moveDraggableItem }
						addSourceItem={ this.addSourceItem }
						addSourceRow={ this.addSourceRow }
						removeRow={ this.removeRow } 
						dropComplete={ this.dropComplete }
						length={ 1 }>
						<React.Fragment>
							<td>{                                      item['NAME'        ]  }</td>
							<td>{ L10n.ListTerm('workflow_type_dom'  , item['TYPE'        ]) }</td>
							<td>{ L10n.ListTerm('WorkflowModules'    , item['BASE_MODULE' ]) }</td>
							<td>{ L10n.ListTerm('workflow_status_dom', (Sql.ToBoolean(item['STATUS']) ? 'True' : 'False')) }</td>
							<td>{                                      item['LIST_ORDER_Y']  }</td>
						</React.Fragment>
					</DraggableRow>
					);
					})
				: null
				}
					</tbody>
				</table>
			</div>
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

