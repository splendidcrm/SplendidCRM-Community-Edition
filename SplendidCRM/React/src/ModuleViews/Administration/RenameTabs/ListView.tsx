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
import { ListView_LoadTable }                       from '../../../scripts/ListView'            ;
import { Crm_Config, Crm_Modules }                  from '../../../scripts/Crm'                 ;
import { Admin_GetReactState }                      from '../../../scripts/Application'         ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'               ;
import { AdminProcedure }                           from '../../../scripts/ModuleUpdate'        ;
// 4. Components and Views. 
import DumpSQL                                      from '../../../components/DumpSQL'          ;
import ErrorComponent                               from '../../../components/ErrorComponent'   ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';
import SearchView                                   from './SearchView'                         ;

// 02/22/2022 Paul.  RenameTabs modifies the Terminology table. 
const MODULE_NAME: string = 'Terminology';

interface IRenameTabsListViewProps extends RouteComponentProps<any>
{
	//MODULE_NAME           : string;
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

interface IRenameTabsListViewState
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
export default class RenameTabsListView extends React.Component<IRenameTabsListViewProps, IRenameTabsListViewState>
{
	private _isMounted    = false;
	private searchView    = React.createRef<SearchView>();
	private headerButtons = React.createRef<HeaderButtons>();
	private themeURL      : string = null;

	constructor(props: IRenameTabsListViewProps)
	{
		super(props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		let rowDefaultSearch: any = {};
		rowDefaultSearch.LANG = Crm_Config.ToString('default_language');
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', rowDefaultSearch);
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
		this._isMounted = true;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', this.state.rowDefaultSearch);
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
				document.title = L10n.Term('Administration.LBL_RENAME_TABS');
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
 	async componentDidUpdate(prevProps: IRenameTabsListViewProps)
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

	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	private _onComponentComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data): void => 
	{
		const { error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + LAYOUT_NAME, data);
		if ( this.props.onComponentComplete )
		{
			if ( error == null )
			{
				let vwMain = null;
				this.props.onComponentComplete(MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data);
			}
		}
	}

	// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
	private _onSearchViewCallback = (sFILTER: string, row: any, oSORT?: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback ' + sFILTER, row);
		try
		{
			this.setState(
			{
				rowDefaultSearch: row,
			}, () =>
			{
				// 02/18/2021 Paul.  We are having an issue with the lang not getting set when page is reloaded, so set manually. 
				if ( sFILTER == null )
				{
					sFILTER = "LANG = '" + Crm_Config.ToString('default_language') + "'";
				}
				ListView_LoadTable('vwMODULES_RenameTabs', 'NAME', 'asc', 'NAME,DISPLAY_NAME', sFILTER, null, true).then((d) =>
				{
					this.setState(
					{
						rowDefaultSearch: row,
						vwMain          : d.results,
						__sql           : d.__sql,
					});
				})
				.catch((error) =>
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
					this.setState({ error });
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
		const { history } = this.props;
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
			row = Object.assign({}, vwMain[editIndex]);
			row.LANG         = rowDefaultSearch['LANG'     ].value;
			row.LIST_NAME    = 'moduleList';
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
					SplendidCache.NAV_MENU_CHANGE++;
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

	public render()
	{
		const { error, vwMain, editIndex, editNAME, editDISPLAY_NAME, __sql, showSearchView } = this.state;
		let { rowDefaultSearch } = this.state;

		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render');
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = 'Administration.LBL_RENAME_TABS';
			let HEADER_BUTTONS: string = '';
			if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
			{
				HEADER_BUTTONS = MODULE_NAME + '.ListView';
			}
			// 02/18/2021 Paul.  We are having an issue with the lang not getting set when page is reloaded, so set manually. 
			if ( Sql.IsEmptyString(rowDefaultSearch.LANG) )
			{
				rowDefaultSearch.LANG = Crm_Config.ToString('default_language');
			}
			return (
			<div>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, error, enableHelp: true, helpName: 'index', ButtonStyle: 'ModuleHeader', VIEW_NAME: HEADER_BUTTONS, Page_Command: this.Page_Command, showButtons: true, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<div style={ {display: (showSearchView == 'show' ? 'block' : 'none')} }>
					<SearchView
						key='Terminology.RenameTabs'
						EDIT_NAME='Terminology.RenameTabs'
						AutoSaveSearch={ false }
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
					return (<tr className={ index % 2 ? 'evenListRowS1' : 'oddListRowS1' }>
						<td>
							{ item['NAME'] }
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
							</React.Fragment>
							}
						</td>
					</tr>);
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

