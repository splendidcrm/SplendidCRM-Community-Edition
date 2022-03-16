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
import { Admin_GetReactState, Admin_GetReactMenu }  from '../../../scripts/Application'         ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'               ;
import { AdminProcedure }                           from '../../../scripts/ModuleUpdate'        ;
// 4. Components and Views. 
import DumpSQL                                      from '../../../components/DumpSQL'          ;
import ErrorComponent                               from '../../../components/ErrorComponent'   ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';
import DraggableRow                                 from '../Dropdown/DraggableRow'             ;

// 02/22/2022 Paul.  ConfigureTabs modifies the Modules table. 
const MODULE_NAME: string = 'Modules';

interface IConfigureTabsListViewProps extends RouteComponentProps<any>
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

interface IConfigureTabsListViewState
{
	__sql?                : string;
	error?                : any;
	vwMain                : any;
}

@observer
export default class ConfigureTabsListView extends React.Component<IConfigureTabsListViewProps, IConfigureTabsListViewState>
{
	private _isMounted    = false;
	private headerButtons = React.createRef<HeaderButtons>();
	private themeURL      : string = null;

	constructor(props: IConfigureTabsListViewProps)
	{
		super(props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.state =
		{
			error                 : null,
			vwMain                : null,
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
				document.title = L10n.Term('Administration.LBL_CONFIGURE_TABS');
				// 04/26/2020 Paul.  Reset scroll every time we set the title. 
				window.scroll(0, 0);
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

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
 	async componentDidUpdate(prevProps: IConfigureTabsListViewProps)
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

	private load = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load');
		try
		{
			let d = await ListView_LoadTable('vwMODULES_CONFIGURE_TABS', 'MODULE_ENABLED, TAB_ENABLED, TAB_ORDER, MODULE_NAME', 'asc', '*', null, null, true);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load ' + MODULE_TYPE + ' ' + DATA_FIELD, d.results);
			this.setState(
			{
				vwMain: d.results,
				__sql : d.__sql,
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
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
	}

	private dropComplete = async (sourceIndex: number, dropIndex: number) =>
	{
		let { vwMain } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.dropComplete', sourceIndex, dropIndex);
		try
		{
			if ( sourceIndex != dropIndex )
			{
				let row: any = {};
				row.OLD_INDEX    = vwMain[sourceIndex].TAB_ORDER;
				row.NEW_INDEX    = vwMain[dropIndex  ].TAB_ORDER;

				await AdminProcedure('spMODULES_TAB_ORDER_MoveItem', row);
				await this.load();
				// 02/20/2021 Paul.  We are reloading the menu, but it will not update until TopNav code is written to update menu stored in state. 
				await Admin_GetReactMenu(this.constructor.name + '.dropComplete');
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

	private _onToggleTabEnabled = async (index: number) =>
	{
		const { vwMain } = this.state;
		try
		{
			let item: any = vwMain[index];
			let row: any = {};
			row.ID = item['ID'];
			if ( Sql.ToBoolean(item['TAB_ENABLED']) )
				await AdminProcedure('spMODULES_TAB_Hide', row);
			else
				await AdminProcedure('spMODULES_TAB_Show', row);
			await this.load();
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onToggleTabEnabled', error);
			if ( this._isMounted )
			{
				this.setState({ error });
			}
		}
	}

	private _onToggleMobileEnabled = async (index: number) =>
	{
		const { vwMain } = this.state;
		try
		{
			let item: any = vwMain[index];
			let row: any = {};
			row.ID = item['ID'];
			if ( Sql.ToBoolean(item['MOBILE_ENABLED']) )
				await AdminProcedure('spMODULES_TAB_HideMobile', row);
			else
				await AdminProcedure('spMODULES_TAB_ShowMobile', row);
			await this.load();
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onToggleMobileEnabled', error);
			if ( this._isMounted )
			{
				this.setState({ error });
			}
		}
	}

	private _onToggleModuleEnabled = async (index: number) =>
	{
		const { vwMain } = this.state;
		try
		{
			let item: any = vwMain[index];
			let row: any = {};
			row.ID = item['ID'];
			if ( Sql.ToBoolean(item['MODULE_ENABLED']) )
				await AdminProcedure('spMODULES_Disable', row);
			else
				await AdminProcedure('spMODULES_Enable', row);
			await this.load();
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onToggleMobileEnabled', error);
			if ( this._isMounted )
			{
				this.setState({ error });
			}
		}
	}

	public render()
	{
		const { error, vwMain, __sql } = this.state;

		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = 'Administration.LBL_CONFIGURE_TABS';
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
				<DumpSQL SQL={ __sql } />
				<table className='table-hover listView' cellSpacing={ 1 } cellPadding={ 3 } style={ {width: '100%'} }>
					<thead>
						<tr className='listViewThS1'>
							<td style={ {width: '20pt'} }></td>
							<td style={ {width: '49%' } }>{ L10n.Term('Dropdown.LBL_KEY'            ) }</td>
							<td style={ {width: '5%'  } }>{ L10n.Term('Administration.LBL_TAB_ORDER') }</td>
							<td style={ {width: '10%' } }></td>
							<td style={ {width: '5%'  } }>{ L10n.Term('Administration.LBL_VISIBLE'  ) }</td>
							<td style={ {width: '10%' } }></td>
							<td style={ {width: '5%'  } }>{ L10n.Term('Administration.LBL_MOBILE'   ) }</td>
							<td style={ {width: '10%' } }></td>
							<td style={ {width: '5%'  } }>{ L10n.Term('Administration.LNK_ENABLED'  ) }</td>
							<td></td>
						</tr>
					</thead>
					<tbody>
				{ vwMain
				? vwMain.map((item, index) => 
					{
						if ( !Sql.ToBoolean(item['TAB_ENABLED']) )
						{
							return (
									<tr className=' nodrag nodrop'>
										<td>&nbsp;</td>
										<td>{ item['MODULE_NAME'] }</td>
										<td>{ item['TAB_ORDER'  ] }</td>
										<td align='right'>{ Sql.ToBoolean(item['TAB_ENABLED']) ? L10n.Term('.LBL_YES') : L10n.Term('.LBL_NO') }</td>
										<td style={ {whiteSpace: 'nowrap'} }>
											<input onClick={ (e) => { e.preventDefault(); this._onToggleTabEnabled(index); } } className='listViewTdToolsS1' type='image' src={ this.themeURL + (Sql.ToBoolean(item['TAB_ENABLED']) ? 'minus_inline.gif' : 'plus_inline.gif') } style={ {borderWidth: '0px', height: '16px', width: '16px', margin: '2px', verticalAlign: 'middle'} } />
											<a     onClick={ (e) => { e.preventDefault(); this._onToggleTabEnabled(index); } } className='listViewTdToolsS1' style={ {cursor: 'pointer'} }>{ Sql.ToBoolean(item['TAB_ENABLED']) ? L10n.Term('Administration.LNK_HIDE') : L10n.Term('Administration.LNK_SHOW') }</a>
										</td>
										<td align='right'>{ Sql.ToBoolean(item['MOBILE_ENABLED']) ? L10n.Term('.LBL_YES') : L10n.Term('.LBL_NO') }</td>
										<td style={ {whiteSpace: 'nowrap'} }>
											<input onClick={ (e) => { e.preventDefault(); this._onToggleMobileEnabled(index); } } className='listViewTdToolsS1' type='image' src={ this.themeURL + (Sql.ToBoolean(item['MOBILE_ENABLED']) ? 'minus_inline.gif' : 'plus_inline.gif') } style={ {borderWidth: '0px', height: '16px', width: '16px', margin: '2px', verticalAlign: 'middle'} } />
											<a     onClick={ (e) => { e.preventDefault(); this._onToggleMobileEnabled(index); } } className='listViewTdToolsS1' style={ {cursor: 'pointer'} }>{ Sql.ToBoolean(item['MOBILE_ENABLED']) ? L10n.Term('Administration.LNK_HIDE') : L10n.Term('Administration.LNK_SHOW') }</a>
										</td>
										<td align='right'>{ Sql.ToBoolean(item['MODULE_ENABLED']) ? L10n.Term('.LBL_YES') : L10n.Term('.LBL_NO') }</td>
										<td style={ {whiteSpace: 'nowrap'} }>
											<input onClick={ (e) => { e.preventDefault(); this._onToggleModuleEnabled(index); } } className='listViewTdToolsS1' type='image' src={ this.themeURL + (Sql.ToBoolean(item['MODULE_ENABLED']) ? 'minus_inline.gif' : 'plus_inline.gif') } style={ {borderWidth: '0px', height: '16px', width: '16px', margin: '2px', verticalAlign: 'middle'} } />
											<a     onClick={ (e) => { e.preventDefault(); this._onToggleModuleEnabled(index); } } className='listViewTdToolsS1' style={ {cursor: 'pointer'} }>{ Sql.ToBoolean(item['MODULE_ENABLED']) ? L10n.Term('Administration.LNK_DISABLE') : L10n.Term('Administration.LNK_ENABLE') }</a>
										</td>
									</tr>
							);
						}
						else
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
										<td>{ item['MODULE_NAME'] }</td>
										<td>{ item['TAB_ORDER'  ] }</td>
										<td align='right'>{ Sql.ToBoolean(item['TAB_ENABLED']) ? L10n.Term('.LBL_YES') : L10n.Term('.LBL_NO') }</td>
										<td style={ {whiteSpace: 'nowrap'} }>
											<input onClick={ (e) => { e.preventDefault(); this._onToggleTabEnabled(index); } } className='listViewTdToolsS1' type='image' src={ this.themeURL + (Sql.ToBoolean(item['TAB_ENABLED']) ? 'minus_inline.gif' : 'plus_inline.gif') } style={ {borderWidth: '0px', height: '16px', width: '16px', margin: '2px', verticalAlign: 'middle'} } />
											<a     onClick={ (e) => { e.preventDefault(); this._onToggleTabEnabled(index); } } className='listViewTdToolsS1' style={ {cursor: 'pointer'} }>{ Sql.ToBoolean(item['TAB_ENABLED']) ? L10n.Term('Administration.LNK_HIDE') : L10n.Term('Administration.LNK_SHOW') }</a>
										</td>
										<td align='right'>{ Sql.ToBoolean(item['MOBILE_ENABLED']) ? L10n.Term('.LBL_YES') : L10n.Term('.LBL_NO') }</td>
										<td style={ {whiteSpace: 'nowrap'} }>
											<input onClick={ (e) => { e.preventDefault(); this._onToggleMobileEnabled(index); } } className='listViewTdToolsS1' type='image' src={ this.themeURL + (Sql.ToBoolean(item['MOBILE_ENABLED']) ? 'minus_inline.gif' : 'plus_inline.gif') } style={ {borderWidth: '0px', height: '16px', width: '16px', margin: '2px', verticalAlign: 'middle'} } />
											<a     onClick={ (e) => { e.preventDefault(); this._onToggleMobileEnabled(index); } } className='listViewTdToolsS1' style={ {cursor: 'pointer'} }>{ Sql.ToBoolean(item['MOBILE_ENABLED']) ? L10n.Term('Administration.LNK_HIDE') : L10n.Term('Administration.LNK_SHOW') }</a>
										</td>
										<td align='right'>{ Sql.ToBoolean(item['MODULE_ENABLED']) ? L10n.Term('.LBL_YES') : L10n.Term('.LBL_NO') }</td>
										<td style={ {whiteSpace: 'nowrap'} }>
											<input onClick={ (e) => { e.preventDefault(); this._onToggleModuleEnabled(index); } } className='listViewTdToolsS1' type='image' src={ this.themeURL + (Sql.ToBoolean(item['MODULE_ENABLED']) ? 'minus_inline.gif' : 'plus_inline.gif') } style={ {borderWidth: '0px', height: '16px', width: '16px', margin: '2px', verticalAlign: 'middle'} } />
											<a     onClick={ (e) => { e.preventDefault(); this._onToggleModuleEnabled(index); } } className='listViewTdToolsS1' style={ {cursor: 'pointer'} }>{ Sql.ToBoolean(item['MODULE_ENABLED']) ? L10n.Term('Administration.LNK_DISABLE') : L10n.Term('Administration.LNK_ENABLE') }</a>
										</td>
									</React.Fragment>
								</DraggableRow>
							);
						}
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

