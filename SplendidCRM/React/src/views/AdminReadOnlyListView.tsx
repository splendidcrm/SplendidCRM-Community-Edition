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
import { RouteComponentProps, withRouter }    from 'react-router-dom'               ;
import { observer }                           from 'mobx-react'                     ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome' ;
// 2. Store and Types. 
import { HeaderButtons }                      from '../types/HeaderButtons'         ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'                 ;
import L10n                                   from '../scripts/L10n'                ;
import Security                               from '../scripts/Security'            ;
import Credentials                            from '../scripts/Credentials'         ;
import SplendidCache                          from '../scripts/SplendidCache'       ;
import SplendidDynamic                        from '../scripts/SplendidDynamic'     ;
import { Admin_GetReactState }                from '../scripts/Application'         ;
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'               ;
// 4. Components and Views. 
import SplendidGrid                           from '../components/SplendidGrid'     ;
import SearchView                             from './SearchView'                   ;
import ExportHeader                           from '../components/ExportHeader'     ;
import HeaderButtonsFactory                   from '../ThemeComponents/HeaderButtonsFactory';

interface IAdminReadOnlyListViewProps extends RouteComponentProps<any>
{
	MODULE_NAME    : string;
	RELATED_MODULE?: string;
	GRID_NAME?     : string;
	TABLE_NAME?    : string;
	SORT_FIELD?    : string;
	SORT_DIRECTION?: string;
	PRIMARY_FIELD? : string;
	PRIMARY_ID?    : string;
	callback?      : Function;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IAdminReadOnlyListViewState
{
	MODULE_NAME    : string;
	error          : any;
}

@observer
class AdminReadOnlyListView extends React.Component<IAdminReadOnlyListViewProps, IAdminReadOnlyListViewState>
{
	private _isMounted = false;
	private searchView    = React.createRef<SearchView>();
	private splendidGrid  = React.createRef<SplendidGrid>();
	private headerButtons = React.createRef<HeaderButtons>();

	constructor(props: IAdminReadOnlyListViewProps)
	{
		super(props);
		Credentials.SetViewMode('AdminListView');
		// 10/30/2020 Paul.  We have added manual routing to this view, so we need to determine the module from the url. 
		let MODULE_NAME: string = props.MODULE_NAME;
		if ( Sql.IsEmptyString(MODULE_NAME) )
		{
			let arrPathname: string[] = props.location.pathname.split('/');
			// 02/24/2021 Paul.  We need two passes as the React State may not be loaded and MODULES cache may be empty. 
			for ( let i: number = 0; i < arrPathname.length; i++ )
			{
				if ( i > 0 && arrPathname[i - 1].toLowerCase() == 'administration' )
				{
					MODULE_NAME = arrPathname[i];
					break;
				}
			}
			if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
			{
				// 02/24/2021 Paul.  Start at the end and work backwards for deeper sub module. 
				for ( let i: number = arrPathname.length - 1; i >= 0; i-- )
				{
					if ( !Sql.IsEmptyString(arrPathname[i]) )
					{
						let MODULE = SplendidCache.Module(arrPathname[i], this.constructor.name + '.constructor');
						if ( MODULE != null )
						{
							MODULE_NAME = arrPathname[i];
							break;
						}
					}
				}
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', MODULE_NAME);
		this.state =
		{
			MODULE_NAME,
			error: null
		};
	}

	async componentDidMount()
	{
		const { MODULE_NAME } = this.state;
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
				document.title = L10n.Term(MODULE_NAME + ".LBL_LIST_FORM_TITLE");
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback');
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
		// 07/13/2019 Paul.  Call SubmitSearch directly. 
		if ( this.searchView.current != null )
		{
			this.searchView.current.SubmitSearch();
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

	private _onExport = async (EXPORT_RANGE: string, EXPORT_FORMAT: string) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onExport', EXPORT_RANGE, EXPORT_FORMAT);
		if ( this._isMounted )
		{
			if ( this.splendidGrid.current != null )
			{
				this.splendidGrid.current.ExportModule(EXPORT_RANGE, EXPORT_FORMAT);
			}
		}
	}

	public render()
	{
		const { RELATED_MODULE, GRID_NAME, TABLE_NAME, SORT_FIELD, SORT_DIRECTION, PRIMARY_FIELD, PRIMARY_ID } = this.props;
		const { MODULE_NAME, error } = this.state;
		let EDIT_NAME = MODULE_NAME + '.SearchBasic';
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = '.moduleList.Home';
			let HEADER_BUTTONS: string = '';
			if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
			{
				HEADER_BUTTONS = MODULE_NAME + '.ListView';
			}
			return (
			<div>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, error, enableHelp: true, helpName: 'index', ButtonStyle: 'ModuleHeader', VIEW_NAME: HEADER_BUTTONS, Page_Command: this.Page_Command, showButtons: false, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				{ !PRIMARY_ID
				? <SearchView
					EDIT_NAME={ EDIT_NAME }
					cbSearch={ this._onSearchViewCallback }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.searchView }
				/>
				: null
				}
				<ExportHeader
					MODULE_NAME={ MODULE_NAME }
					onExport={ this._onExport }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
				/>
				<SplendidGrid
					onLayoutLoaded={ this._onGridLayoutLoaded }
					MODULE_NAME={ MODULE_NAME }
					RELATED_MODULE={ RELATED_MODULE }
					GRID_NAME={ GRID_NAME }
					TABLE_NAME={ TABLE_NAME }
					SORT_FIELD='DATE_ENTERED'
					SORT_DIRECTION='desc'
					PRIMARY_FIELD={ PRIMARY_FIELD }
					PRIMARY_ID={ PRIMARY_ID }
					ADMIN_MODE={ true }
					deferLoad={ true }
					enableExportHeader={ true }
					onComponentComplete={ this._onComponentComplete }
					scrollable
					readonly
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.splendidGrid }
				/>
			</div>
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

export default withRouter(AdminReadOnlyListView);
