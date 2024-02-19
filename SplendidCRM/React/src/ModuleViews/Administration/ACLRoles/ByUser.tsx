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
import { RouteComponentProps }                      from '../Router5'                             ;
import { observer }                                 from 'mobx-react'                                   ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'               ;
// 2. Store and Types. 
import { HeaderButtons }                            from '../../../types/HeaderButtons'                 ;
import DETAILVIEWS_RELATIONSHIP                     from '../../../types/DETAILVIEWS_RELATIONSHIP'      ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                         ;
import L10n                                         from '../../../scripts/L10n'                        ;
import Security                                     from '../../../scripts/Security'                    ;
import Credentials                                  from '../../../scripts/Credentials'                 ;
import SplendidCache                                from '../../../scripts/SplendidCache'               ;
import SplendidDynamic                              from '../../../scripts/SplendidDynamic'             ;
import { Admin_GetReactState }                      from '../../../scripts/Application'                 ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'                       ;
// 4. Components and Views. 
import ErrorComponent                               from '../../../components/ErrorComponent'           ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';
import SearchView                                   from '../../../views/SearchView'                    ;
import AccessView                                   from '../../../views/AccessView'                    ;
import DetailViewRelationships                      from '../../../views/DetailViewRelationships'       ;
import UsersACLRoles                                from '../../Users/UsersACLRoles'                    ;

const MODULE_NAME: string = 'ACLRoles';

interface IACLRolesByUserProps extends RouteComponentProps<any>
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

interface IACLRolesByUserState
{
	__sql?                 : string;
	error?                 : any;
	rowDefaultSearch       : any;
	item                   : any;
	DETAIL_NAME            : string;
	layoutACLRoles         : DETAILVIEWS_RELATIONSHIP;
}

@observer
export default class ACLRolesByUser extends React.Component<IACLRolesByUserProps, IACLRolesByUserState>
{
	private _isMounted    = false;
	private searchView    = React.createRef<SearchView>();
	private headerButtons = React.createRef<HeaderButtons>();

	constructor(props: IACLRolesByUserProps)
	{
		super(props);
		let DETAIL_NAME: string = MODULE_NAME + '.ByUser';
		let layoutACLRoles: DETAILVIEWS_RELATIONSHIP =
		{
			MODULE_NAME   : 'ACLRoles'                        ,
			CONTROL_NAME  : 'ACLRoles'                        ,
			TITLE         : 'ACLRoles.LBL_LIST_FORM_TITLE'    ,
			TABLE_NAME    : 'vwUSERS_ACL_ROLES'               ,
			PRIMARY_FIELD : 'USER_ID'                         ,
			SORT_FIELD    : 'ROLE_NAME'                       ,
			SORT_DIRECTION: 'asc'                             ,
			initialOpen   : localStorage.getItem(DETAIL_NAME) == 'true',
		};
		this.state =
		{
			error                 : null,
			rowDefaultSearch      : null,
			item                  : null,
			DETAIL_NAME           ,
			layoutACLRoles        ,
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
				document.title = L10n.Term(MODULE_NAME + '.LBL_LIST_FORM_TITLE');
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

	async componentDidUpdate(prevProps: IACLRolesByUserProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		else
		{
			if ( this.props.onComponentComplete )
			{
				const { item, DETAIL_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + DETAIL_NAME, item);
				if ( error == null )
				{
					if ( this._areRelationshipsComplete && this._areManualRelationshipsComplete )
					{
						this.props.onComponentComplete(MODULE_NAME, null, DETAIL_NAME, item);
					}
				}
			}
		}
	}

	private _areRelationshipsComplete: boolean = false;

	private onRelationshipsComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain): void =>
	{
		this._areRelationshipsComplete = true;
		if ( this.props.onComponentComplete )
		{
			if ( this.props.isPrecompile )
			{
				console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.onRelationshipsComplete ' + LAYOUT_NAME, vwMain);
			}
			const { item, DETAIL_NAME, error } = this.state;
			if ( error == null )
			{
				if ( this._areRelationshipsComplete && this._areManualRelationshipsComplete )
				{
					this.props.onComponentComplete(MODULE_NAME, null, DETAIL_NAME, item);
				}
			}
		}
	}

	private _areManualRelationshipsComplete: boolean = false;

	private onManualRelationshipsComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain): void =>
	{
		const { layoutACLRoles } = this.state;
		let nCompleted: number= 0;
		let items: any[] = [layoutACLRoles];
		for ( let i: number = 0; i < items.length; i++ )
		{
			if ( 'Users.' + items[i].CONTROL_NAME == LAYOUT_NAME )
			{
				items[i].precompileCompleted = true;
			}
			if ( items[i].precompileCompleted )
			{
				nCompleted++;
			}
		}
		if ( nCompleted == items.length )
		{
			this._areManualRelationshipsComplete = true;
		}
		if ( this.props.onComponentComplete )
		{
			const { item, DETAIL_NAME, error } = this.state;
			if ( this.props.isPrecompile )
			{
				console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.onManualRelationshipsComplete ' + LAYOUT_NAME + ' ' + nCompleted.toString() + ' of ' + items.length.toString());
			}
			if ( error == null )
			{
				if ( this._areRelationshipsComplete && this._areManualRelationshipsComplete )
				{
					this.props.onComponentComplete(MODULE_NAME, null, DETAIL_NAME, item);
				}
			}
		}
	}

	// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
	private _onSearchViewCallback = (sFILTER: string, row: any, oSORT?: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback');
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		let { item } = this.state;
		if ( item == null )
			item = {};
		item[DATA_FIELD] = DATA_VALUE;
		this.setState({ item });
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

	public render()
	{
		const { error, rowDefaultSearch, item, DETAIL_NAME, layoutACLRoles } = this.state;

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
						key={ MODULE_NAME + '.SearchByUser' }
						EDIT_NAME={ MODULE_NAME + '.SearchByUser' }
						AutoSaveSearch={ false }
						disableClear={ true }
						rowDefaultSearch={ rowDefaultSearch }
						cbSearch={ this._onSearchViewCallback }
						onChange={ this._onChange }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.searchView }
					/>
				</div>
				<br />
				{ item
				? <div>
					<AccessView USER_ID={ item['ID'] } />
					<br />
					<UsersACLRoles  key={ 'Users.' + layoutACLRoles.CONTROL_NAME + item['ID'] } PARENT_TYPE='Users' row={ item } layout={ layoutACLRoles } CONTROL_VIEW_NAME={ MODULE_NAME + '.' + layoutACLRoles.CONTROL_NAME } isPrecompile={ this.props.isPrecompile } onComponentComplete={ this.onManualRelationshipsComplete } disableMakePrimary={ true } />
					<DetailViewRelationships key={ MODULE_NAME + '_DetailViewRelationships' + item['ID'] } PARENT_TYPE={ MODULE_NAME } DETAIL_NAME={ DETAIL_NAME } row={ item } isPrecompile={ this.props.isPrecompile } onComponentComplete={ this.onRelationshipsComplete } />
				</div>
				: null
				}
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

