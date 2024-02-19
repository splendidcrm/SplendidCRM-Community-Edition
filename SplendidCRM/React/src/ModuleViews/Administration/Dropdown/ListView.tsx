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
import { RouteComponentProps, withRouter }          from '../Router5'                     ;
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
import SearchView                                   from './SearchView'                         ;
import DraggableRow                                 from './DraggableRow'                       ;

interface IDropdownListViewProps extends RouteComponentProps<any>
{
	MODULE_NAME           : string;
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

interface IDropdownListViewState
{
	__sql?                : string;
	error?                : any;
	rowDefaultSearch      : any;
	vwMain                : any;
	editIndex             : number;
	editNAME              : string;
	editDISPLAY_NAME      : string;
	// 04/09/2022 Paul.  Hide/show SearchView. 
	showSearchView        : string;
}

@observer
export default class DropdownListView extends React.Component<IDropdownListViewProps, IDropdownListViewState>
{
	private _isMounted    = false;
	private searchView    = React.createRef<SearchView>();
	private headerButtons = React.createRef<HeaderButtons>();
	private themeURL      : string = null;

	constructor(props: IDropdownListViewProps)
	{
		super(props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		let rowDefaultSearch: any = {};
		rowDefaultSearch.LANG = Crm_Config.ToString('default_language');
		// 04/09/2022 Paul.  Hide/show SearchView. 
		let showSearchView: string = 'show';
		if ( SplendidCache.UserTheme == 'Pacific' )
		{
			showSearchView = localStorage.getItem(this.constructor.name + '.showSearchView');
			if ( Sql.IsEmptyString(showSearchView) )
				showSearchView = 'hide';
		}
		this.state =
		{
			error                 : null,
			rowDefaultSearch      ,
			vwMain                : null,
			editIndex             : -1,
			editNAME              : null,
			editDISPLAY_NAME      : null,
			showSearchView        ,
		};
	}

	async componentDidMount()
	{
		const { MODULE_NAME } = this.props;
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
				document.title = L10n.Term('Dropdown.LBL_LIST_FORM_TITLE');
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
 	async componentDidUpdate(prevProps: IDropdownListViewProps)
	{
		if ( this.props.onComponentComplete )
		{
			const { MODULE_NAME, RELATED_MODULE, GRID_NAME } = this.props;
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
				ListView_LoadModule('Terminology', 'LIST_ORDER', 'asc', '*', sFILTER, row).then((d) =>
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

	private _onSearchLayoutLoaded = () =>
	{
		if ( this.searchView && this.searchView.current )
		{
			this.searchView.current.SubmitSearch();
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { MODULE_NAME, history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
			case 'Create':
			{
				let admin: string = '';
				let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onHyperLinkCallback');
				if ( module.IS_ADMIN )
				{
					admin = '/Administration';
				}
				history.push(`/Reset${admin}/${MODULE_NAME}/Edit`);
				break;
			}
			// 04/09/2022 Paul.  Hide/show SearchView. 
			case 'toggleSearchView':
			{
				let showSearchView: string = (this.state.showSearchView == 'show' ? 'hide' : 'show');
				localStorage.setItem(this.constructor.name + '.showSearchView', showSearchView);
				this.setState({ showSearchView });
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

	private _onChangeNAME = (e): void =>
	{
		let value = e.target.value;
		this.setState({ editNAME: value });
	}

	private _onChangeDISPLAY_NAME = (e): void =>
	{
		let value = e.target.value;
		this.setState({ editDISPLAY_NAME: value });
	}

	private _onEdit = (index) =>
	{
		const { vwMain } = this.state;

		this.setState(
		{
			editNAME        : vwMain[index]['NAME'        ],
			editDISPLAY_NAME: vwMain[index]['DISPLAY_NAME'],
			editIndex       : index,
		});
	}

	private _onCancel = (index) =>
	{
		this.setState(
		{
			editNAME        : '',
			editDISPLAY_NAME: '',
			editIndex       : -1,
		});
	}

	private nextIndex = () =>
	{
		const { vwMain } = this.state;
		let maxIndex: number = 0
		if ( vwMain.length > 0 )
		{
			for ( let i: number = 0; i < vwMain.length; i++ )
			{
				maxIndex = Math.max(vwMain[i].LIST_ORDER, maxIndex);
			}
			maxIndex++;
		}
		return maxIndex;
	}

	private _onUpdate = async (index) =>
	{
		let { rowDefaultSearch, vwMain, editNAME, editDISPLAY_NAME, editIndex } = this.state;
		try
		{
			let row: any = {};
			if ( editIndex == -1 || vwMain == null )
			{
				row.ID           = null;
				row.LANG         = rowDefaultSearch['LANG'     ].value;
				row.MODULE_NAME  = null;
				row.LIST_NAME    = rowDefaultSearch['LIST_NAME'].value;
				// 02/17/2021 Paul.  Add past the last item. 
				row.LIST_ORDER   = (vwMain != null ? this.nextIndex() : 0);
			}
			else
			{
				row = Object.assign({}, vwMain[editIndex]);
				// 02/17/2021 Paul.  If the name has changed, then we need to delete the old and insert the new. 
				if ( row.NAME != editNAME )
				{
					await AdminProcedure('spTERMINOLOGY_LIST_Delete', row);
					row.ID = null;
				}
			}
			row.NAME         = editNAME;
			row.DISPLAY_NAME = editDISPLAY_NAME;

			let d = await AdminProcedure('spTERMINOLOGY_LIST_Insert', row);
			row.ID = d.ID;
			this.setState(
			{
				editNAME        : '',
				editDISPLAY_NAME: '',
				editIndex       : -1
			}, () =>
			{
				if ( row.LANG == Credentials.sUSER_LANG )
				{
					let sTerm: string = '.' + row.LIST_NAME + '.' + row.NAME;
					SplendidCache.SetTerminology(sTerm, row.DISPLAY_NAME);
				}
				this.searchView.current.SubmitSearch();
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', error);
			if ( this._isMounted )
			{
				this.setState({ error });
			}
		}
	}

	private _onAdd = async () =>
	{
		let { rowDefaultSearch, vwMain, editNAME, editDISPLAY_NAME, editIndex } = this.state;
		try
		{
			let row: any = {};
			row.ID           = null;
			row.LANG         = rowDefaultSearch['LANG'     ].value;
			row.MODULE_NAME  = null;
			row.LIST_NAME    = rowDefaultSearch['LIST_NAME'].value;
			// 02/17/2021 Paul.  Add past the last item. 
			row.LIST_ORDER   = this.nextIndex();
			row.NAME         = editNAME;
			row.DISPLAY_NAME = editDISPLAY_NAME;

			let d = await AdminProcedure('spTERMINOLOGY_LIST_Insert', row);
			row.ID = d.ID;
			this.setState(
			{
				editNAME        : '',
				editDISPLAY_NAME: '',
				editIndex       : -1
			}, () =>
			{
				this.searchView.current.SubmitSearch();
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', error);
			if ( this._isMounted )
			{
				this.setState({ error });
			}
		}
	}

	private _onDelete = async (index) =>
	{
		let { vwMain } = this.state;
		try
		{
			// 02/18/2021 Paul.  Confirm delete as it is immediate. 
			if ( window.confirm(L10n.Term('.NTC_DELETE_CONFIRMATION')) )
			{
				let row: any = {};
				row['ID'] = vwMain[index].ID;

				let d = await AdminProcedure('spTERMINOLOGY_LIST_Delete', row);

				this.searchView.current.SubmitSearch();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', error);
			if ( this._isMounted )
			{
				this.setState({ error });
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
				row.LANG         = rowDefaultSearch['LANG'     ].value;
				row.LIST_NAME    = rowDefaultSearch['LIST_NAME'].value;
				row.OLD_INDEX    = vwMain[sourceIndex].LIST_ORDER;
				row.NEW_INDEX    = vwMain[dropIndex  ].LIST_ORDER;

				await AdminProcedure('spTERMINOLOGY_LIST_MoveItem', row);
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
		const { MODULE_NAME } = this.props;
		const { error, rowDefaultSearch, vwMain, editIndex, editNAME, editDISPLAY_NAME, __sql, showSearchView } = this.state;

		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = 'Dropdown.LBL_LIST_FORM_TITLE';
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
				<div style={ {display: (showSearchView == 'show' ? 'block' : 'none')} }>
					<SearchView
						key={ MODULE_NAME + '.SearchBasic' }
						EDIT_NAME={ MODULE_NAME + '.SearchBasic' }
						AutoSaveSearch={ true }
						rowDefaultSearch={ rowDefaultSearch }
						cbSearch={ this._onSearchViewCallback }
						onLayoutLoaded={ this._onSearchLayoutLoaded }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.searchView }
					/>
				</div>
				<br />
				<DumpSQL SQL={ __sql } />
				<table className='table-hover listView' cellSpacing={ 1 } cellPadding={ 3 } style={ {width: '100%'} }>
					<thead>
						<tr className='listViewThS1'>
							<td style={ {width: '20pt'} }></td>
							<td style={ {width: '29%'} }>{ L10n.Term('Dropdown.LBL_KEY'  ) }</td>
							<td style={ {width: '50%'} }>{ L10n.Term('Dropdown.LBL_VALUE') }</td>
							<td style={ {width: '10%'} }></td>
							<td style={ {width: '20%'} }></td>
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
							<td>
								{ editIndex == index
								? <input id='txtNAME'         value={ editNAME         } onChange={ this._onChangeNAME         } />
								: item['NAME'        ]
								}
							</td>
							<td>
								{ editIndex == index
								? <input id='txtDISPLAY_NAME' value={ editDISPLAY_NAME } onChange={ this._onChangeDISPLAY_NAME } size={ 40 } />
								: item['DISPLAY_NAME']
								}
							</td>
							<td>{ item['LIST_ORDER'  ] }</td>
							<td align='right' style={ {whiteSpace: 'nowrap'} }>
								{ editIndex == index
								? <React.Fragment>
									<input onClick={ (e) => { e.preventDefault(); this._onUpdate(index); } } className='listViewTdToolsS1' type='image' src={ this.themeURL + 'accept_inline.gif' } style={ {borderWidth: '0px', height: '16px', width: '16px', margin: '2px', verticalAlign: 'middle'} } />
									<a     onClick={ (e) => { e.preventDefault(); this._onUpdate(index); } } className='listViewTdToolsS1' style={ {cursor: 'pointer'} }>{ L10n.Term('.LBL_UPDATE_BUTTON_LABEL') }</a>
									&nbsp;
									<input onClick={ (e) => { e.preventDefault(); this._onCancel(index); } } className='listViewTdToolsS1' type='image' src={ this.themeURL + 'decline_inline.gif'} style={ {borderWidth: '0px', height: '16px', width: '16px', margin: '2px', verticalAlign: 'middle'} } />
									<a     onClick={ (e) => { e.preventDefault(); this._onCancel(index); } } className='listViewTdToolsS1' style={ {cursor: 'pointer'} }>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }</a>
								</React.Fragment>
								: <React.Fragment>
									<input onClick={ (e) => { e.preventDefault(); this._onEdit(index  ); } } className='listViewTdToolsS1' type='image' src={ this.themeURL + 'edit_inline.gif'   } style={ {borderWidth: '0px', height: '16px', width: '16px', margin: '2px', verticalAlign: 'middle'} } />
									<a     onClick={ (e) => { e.preventDefault(); this._onEdit(index  ); } } className='listViewTdToolsS1' style={ {cursor: 'pointer'} }>{ L10n.Term('.LNK_EDIT') }</a>
									&nbsp;
									<input onClick={ (e) => { e.preventDefault(); this._onDelete(index); } } className='listViewTdToolsS1' type='image' src={ this.themeURL + 'delete_inline.gif' } style={ {borderWidth: '0px', height: '16px', width: '16px', margin: '2px', verticalAlign: 'middle'} } />
									<a     onClick={ (e) => { e.preventDefault(); this._onDelete(index); } } className='listViewTdToolsS1' style={ {cursor: 'pointer'} }>{ L10n.Term('.LNK_DELETE') }</a>
								</React.Fragment>
								}
							</td>
						</React.Fragment>
					</DraggableRow>
					);
					})
				: null
				}
				{ editIndex == -1
				?
					<tr>
						<td></td>
						<td>
							<input id='txtNAME'         value={ editNAME         } onChange={ this._onChangeNAME         } />
						</td>
						<td>
							<input id='txtDISPLAY_NAME' value={ editDISPLAY_NAME } onChange={ this._onChangeDISPLAY_NAME } size={ 40 } />
						</td>
						<td></td>
						<td>
							<input onClick={ (e) => { e.preventDefault(); this._onAdd(); } } id='btnInsert' type='submit' className='listViewTdToolsS1' value={ L10n.Term('.LBL_ADD_BUTTON_LABEL') } />
						</td>
						<td></td>
					</tr>
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

