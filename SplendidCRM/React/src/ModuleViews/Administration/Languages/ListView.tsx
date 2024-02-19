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
import { ListView_LoadTable }                       from '../../../scripts/ListView'            ;
import { Admin_GetReactState, Admin_GetReactMenu }  from '../../../scripts/Application'         ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'               ;
import { AdminProcedure }                           from '../../../scripts/ModuleUpdate'        ;
// 4. Components and Views. 
import DumpSQL                                      from '../../../components/DumpSQL'          ;
import ErrorComponent                               from '../../../components/ErrorComponent'   ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';

interface ILanguagesListViewProps extends RouteComponentProps<any>
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

interface ILanguagesListViewState
{
	__sql?                : string;
	error?                : any;
	vwMain                : any;
}

@observer
export default class LanguagesListView extends React.Component<ILanguagesListViewProps, ILanguagesListViewState>
{
	private _isMounted           = false;
	private headerButtons        = React.createRef<HeaderButtons>();
	private themeURL             : string = null;

	constructor(props: ILanguagesListViewProps)
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
 	async componentDidUpdate(prevProps: ILanguagesListViewProps)
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

	private load = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load');
		try
		{
			let d = await ListView_LoadTable('LANGUAGES', 'DISPLAY_NAME', 'asc', '*', null, null, true);
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
		const { MODULE_NAME, history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
			case 'Add':
			{
				history.push(`/Reset/Administration/Languages/Edit/`);
				break;
			}
			case 'Cancel':
			{
				history.push(`/Reset/Administration`);
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

	private _onToggleEnabled = async (index: number) =>
	{
		const { vwMain } = this.state;
		try
		{
			let item: any = vwMain[index];
			let row: any = {};
			row.NAME = item['NAME'];
			if ( Sql.ToBoolean(item['ACTIVE']) )
				await AdminProcedure('spLANGUAGES_Disable', row);
			else
				await AdminProcedure('spLANGUAGES_Enable', row);
			await this.load();
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onToggleEnabled', error);
			if ( this._isMounted )
			{
				this.setState({ error });
			}
		}
	}

	private _onDelete = async (index: number) =>
	{
		const { vwMain } = this.state;
		try
		{
			if ( window.confirm(L10n.Term('.NTC_DELETE_CONFIRMATION')) )
			{
				let item: any = vwMain[index];
				let row: any = {};
				row.NAME = item['NAME'];
				await AdminProcedure('spLANGUAGES_Delete', row);
				await this.load();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onDelete', error);
			if ( this._isMounted )
			{
				this.setState({ error });
			}
		}
	}

	public render()
	{
		const { MODULE_NAME } = this.props;
		const { error, vwMain, __sql } = this.state;

		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = 'Administration.LBL_MANAGE_LANGUAGES';
			let HEADER_BUTTONS: string = '';
			HEADER_BUTTONS = MODULE_NAME + '.ListView';
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
							<td style={ {width: '20%' } }>{ L10n.Term('Terminology.LBL_LIST_LANG'        ) }</td>
							<td style={ {width: '30%' } }>{ L10n.Term('Terminology.LBL_LIST_NAME_NAME'   ) }</td>
							<td style={ {width: '30%' } }>{ L10n.Term('Terminology.LBL_LIST_DISPLAY_NAME') }</td>
							<td style={ {width: '5%'  } } align='right'>{ L10n.Term('Administration.LNK_ENABLED') }</td>
							<td style={ {width: '10%' } }></td>
							<td style={ {width: '5%'  } }></td>
							<td></td>
						</tr>
					</thead>
					<tbody>
				{ vwMain
				? vwMain.map((item, index) => 
					{
						return (
								<tr className={ index % 2 ? 'evenListRowS1' : 'oddListRowS1' }>
									<td>{ item['NAME'        ] }</td>
									<td>{ item['DISPLAY_NAME'] }</td>
									<td>{ item['NATIVE_NAME' ] }</td>
									<td align='right'>{ Sql.ToBoolean(item['ACTIVE']) ? L10n.Term('.LBL_YES') : L10n.Term('.LBL_NO') }</td>
									<td style={ {whiteSpace: 'nowrap'} }>
										<FontAwesomeIcon onClick={ (e) => { e.preventDefault(); this._onToggleEnabled(index); } } style={ {cursor: 'pointer'} } className='3x' icon={  (Sql.ToBoolean(item['ACTIVE']) ? 'minus' : 'plus') } />
										&nbsp;
										<a               onClick={ (e) => { e.preventDefault(); this._onToggleEnabled(index); } } style={ {cursor: 'pointer'} } className='listViewTdToolsS1'>{ Sql.ToBoolean(item['ACTIVE']) ? L10n.Term('Administration.LNK_DISABLE') : L10n.Term('Administration.LNK_ENABLE') }</a>
									</td>
									<td style={ {whiteSpace: 'nowrap'} }>
										<FontAwesomeIcon onClick={ (e) => { e.preventDefault(); this._onDelete(index); } } style={ {cursor: 'pointer'} } className='3x' icon='minus' />
										&nbsp;
										<a     onClick={ (e) => { e.preventDefault(); this._onDelete(index); } } className='listViewTdToolsS1' style={ {cursor: 'pointer'} }>{ L10n.Term('.LNK_DELETE') }</a>
									</td>
								</tr>
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

