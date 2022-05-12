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
import { RouteComponentProps, withRouter }                      from 'react-router-dom'                        ;
import { observer }                                             from 'mobx-react'                              ;
import { FontAwesomeIcon }                                      from '@fortawesome/react-fontawesome'          ;
// 2. Store and Types. 
import { DetailComponent }                                      from '../../types/DetailComponent'             ;
import ACL_ACCESS                                               from '../../types/ACL_ACCESS'                  ;
import { HeaderButtons }                                        from '../../types/HeaderButtons'               ;
import DETAILVIEWS_RELATIONSHIP                                 from '../../types/DETAILVIEWS_RELATIONSHIP'    ;
// 3. Scripts. 
import Sql                                                      from '../../scripts/Sql'                       ;
import L10n                                                     from '../../scripts/L10n'                      ;
import Security                                                 from '../../scripts/Security'                  ;
import Credentials                                              from '../../scripts/Credentials'               ;
import SplendidCache                                            from '../../scripts/SplendidCache'             ;
import SplendidDynamic_DetailView                               from '../../scripts/SplendidDynamic_DetailView';
import { Crm_Config }                                           from '../../scripts/Crm'                       ;
import { AuthenticatedMethod, LoginRedirect, GetMyUserProfile } from '../../scripts/Login'                     ;
import { DetailView_LoadItem, DetailView_LoadLayout, DetailView_ActivateTab }           from '../../scripts/DetailView'                ;
import { DeleteModuleItem }                                     from '../../scripts/ModuleUpdate'              ;
import { UpdateModule }                                         from '../../scripts/ModuleUpdate'              ;
import { CreateSplendidRequest, GetSplendidResult }             from '../../scripts/SplendidRequest'           ;
import { jsonReactState, Application_ClearStore }               from '../../scripts/Application'               ;
// 4. Components and Views. 
import ErrorComponent                                           from '../../components/ErrorComponent'         ;
import DumpSQL                                                  from '../../components/DumpSQL'                ;
import DynamicButtons                                           from '../../components/DynamicButtons'         ;
import AccessView                                               from '../../views/AccessView'                  ;
import DetailViewRelationships                                  from '../../views/DetailViewRelationships'     ;
import DynamicSubPanelView                                      from '../../views/DynamicSubPanelView'         ;
import HeaderButtonsFactory                                     from '../../ThemeComponents/HeaderButtonsFactory';
import PasswordPopupView                                        from './PasswordPopupView'                       ;
// 04/13/2022 Paul.  Add LayoutTabs to Pacific theme. 
import LayoutTabs                                               from '../../components/LayoutTabs'             ;

const MODULE_NAME: string = 'Users';

interface IDetailViewProps extends RouteComponentProps<any>
{
	LAYOUT_NAME? : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IDetailViewState
{
	__total                : number;
	__sql                  : string;
	item                   : any;
	layout                 : any;
	layoutMailOptions      : any;
	layoutGoogleAppsOptions: any;
	layoutICloudOptions    : any;
	layoutSignatures       : DETAILVIEWS_RELATIONSHIP;
	layoutACLRoles         : DETAILVIEWS_RELATIONSHIP;
	layoutTeams            : DETAILVIEWS_RELATIONSHIP;
	layoutLogins           : DETAILVIEWS_RELATIONSHIP;
	DETAIL_NAME            : string;
	SUB_TITLE              : any;
	error                  : any;
	bExchangeEnabled       : boolean;
	bGoogleAppsEnabled     : boolean;
	biCloudEnabled         : boolean;
	passwordOpen           : boolean;
	showAccessView         : boolean;
}

@observer
class MyAccountView extends React.Component<IDetailViewProps, IDetailViewState>
{
	private _isMounted     : boolean = false;
	private refMap         : Record<string, React.RefObject<DetailComponent<any, any>>>;
	private headerButtons    = React.createRef<HeaderButtons>();
	private passwordView     = React.createRef<PasswordPopupView>();

	constructor(props: IDetailViewProps)
	{
		super(props);
		let DETAIL_NAME = MODULE_NAME + '.DetailView';
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			DETAIL_NAME = props.LAYOUT_NAME;
		}
		let layoutSignatures: DETAILVIEWS_RELATIONSHIP =
		{
			MODULE_NAME   : 'UserSignatures'                  ,
			CONTROL_NAME  : 'UserSignatures'                  ,
			TITLE         : 'UserSignatures.LBL_MY_SIGNATURES',
			TABLE_NAME    : 'vwUSERS_SIGNATURES'              ,
			PRIMARY_FIELD : 'USER_ID'                         ,
			SORT_FIELD    : 'NAME'                            ,
			SORT_DIRECTION: 'asc'                             ,
			initialOpen   : localStorage.getItem('Users.UserSignatures') == 'true',
		};
		let layoutACLRoles: DETAILVIEWS_RELATIONSHIP =
		{
			MODULE_NAME   : 'ACLRoles'                        ,
			CONTROL_NAME  : 'ACLRoles'                        ,
			TITLE         : 'ACLRoles.LBL_LIST_FORM_TITLE'    ,
			TABLE_NAME    : 'vwUSERS_ACL_ROLES'               ,
			PRIMARY_FIELD : 'USER_ID'                         ,
			SORT_FIELD    : 'ROLE_NAME'                       ,
			SORT_DIRECTION: 'asc'                             ,
			initialOpen   : localStorage.getItem('Users.ACLRoles') == 'true',
		};
		let layoutTeams: DETAILVIEWS_RELATIONSHIP =
		{
			MODULE_NAME   : 'Teams'                           ,
			CONTROL_NAME  : 'Teams'                           ,
			TITLE         : 'Users.LBL_MY_TEAMS'              ,
			TABLE_NAME    : 'vwUSERS_TEAM_MEMBERSHIPS'        ,
			PRIMARY_FIELD : 'USER_ID'                         ,
			SORT_FIELD    : 'TEAM_NAME'                       ,
			SORT_DIRECTION: 'asc'                             ,
			initialOpen   : localStorage.getItem('Users.Teams') == 'true',
		};
		let layoutLogins: DETAILVIEWS_RELATIONSHIP =
		{
			MODULE_NAME   : 'Users'                           ,
			CONTROL_NAME  : 'Logins'                          ,
			TITLE         : 'Users.LBL_LOGINS'                ,
			TABLE_NAME    : 'vwUSERS_LOGINS'                  ,
			PRIMARY_FIELD : 'USER_ID'                         ,
			SORT_FIELD    : 'LOGIN_DATE'                      ,
			SORT_DIRECTION: 'desc'                            ,
			initialOpen   : localStorage.getItem('Users.Logins') == 'true',
		};
		Credentials.SetViewMode('AdministrationView');
		let bExchangeEnabled  : boolean = Crm_Config.ToBoolean('Exchange.ServerURL');
		let bGoogleAppsEnabled: boolean = Crm_Config.ToBoolean('GoogleApps.Enabled');
		let biCloudEnabled    : boolean = Crm_Config.ToBoolean('iCloud.Enabled'    );
		//if ( bExchangeEnabled   ) console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor Exchange Enabled'  );
		//if ( bGoogleAppsEnabled ) console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor GoogleApps Enabled');
		//if ( biCloudEnabled     ) console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor iCloud Enabled'    );
		// 01/10/2022 Paul.  Provide a way to hide the access view. 
		let showAccessView: boolean = Security.IS_ADMIN() || !Crm_Config.ToBoolean('hide_user_access_view');
		this.state =
		{
			__total                : 0,
			__sql                  : null,
			item                   : null,
			layout                 : null,
			layoutMailOptions      : null,
			layoutGoogleAppsOptions: null,
			layoutICloudOptions    : null,
			layoutSignatures       ,
			layoutACLRoles         ,
			layoutTeams            ,
			layoutLogins           ,
			DETAIL_NAME            ,
			SUB_TITLE              : null,
			error                  : null,
			bExchangeEnabled       ,
			bGoogleAppsEnabled     ,
			biCloudEnabled         ,
			passwordOpen           : false,
			showAccessView         ,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
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
				// 01/23/2021 Paul.  Don't change the Admin mode as this panel can be used by both admins and non-admins. 
				//if ( Credentials.ADMIN_MODE )
				//{
				//	Credentials.SetADMIN_MODE(false);
				//}
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

	async componentDidUpdate(prevProps: IDetailViewProps)
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
				const { item, layout, DETAIL_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + DETAIL_NAME, item);
				if ( layout != null && error == null )
				{
					if ( item != null && this._areRelationshipsComplete && this._areManualRelationshipsComplete )
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.onRelationshipsComplete ' + LAYOUT_NAME, vwMain);
		this._areRelationshipsComplete = true;
		if ( this.props.onComponentComplete )
		{
			const { item, layout, DETAIL_NAME, error } = this.state;
			if ( layout != null && error == null )
			{
				if ( item != null && this._areRelationshipsComplete && this._areManualRelationshipsComplete )
				{
					this.props.onComponentComplete(MODULE_NAME, null, DETAIL_NAME, item);
				}
			}
		}
	}

	private _areManualRelationshipsComplete: boolean = false;

	private onManualRelationshipsComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain): void =>
	{
		const { layoutSignatures, layoutACLRoles, layoutTeams, layoutLogins } = this.state;
		let nCompleted: number= 0;
		let items: any[] = [layoutSignatures, layoutACLRoles, layoutTeams];
		if ( SplendidCache.AdminUserAccess('Users', 'view') >= 0 )
		{
			items.push(layoutLogins);
		}
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
			const { item, layout, DETAIL_NAME, error } = this.state;
			if ( this.props.isPrecompile )
			{
				console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.onManualRelationshipsComplete ' + LAYOUT_NAME + ' ' + nCompleted.toString() + ' of ' + items.length.toString());
			}
			if ( layout != null && error == null )
			{
				if ( item != null && this._areRelationshipsComplete && this._areManualRelationshipsComplete )
				{
					this.props.onComponentComplete(MODULE_NAME, null, DETAIL_NAME, item);
				}
			}
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private load = async () =>
	{
		const { DETAIL_NAME } = this.state;
		try
		{
			const layout                  = DetailView_LoadLayout(DETAIL_NAME              );
			const layoutMailOptions       = DetailView_LoadLayout('Users.MailOptions'      );
			const layoutGoogleAppsOptions = DetailView_LoadLayout('Users.GoogleAppsOptions');
			const layoutICloudOptions     = DetailView_LoadLayout('Users.iCloudOptions'    );
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			if ( this._isMounted )
			{
				this.setState(
				{
					layout                 ,
					layoutMailOptions      ,
					layoutGoogleAppsOptions,
					layoutICloudOptions    ,
					item                   : null
				});
				await this.LoadItem(MODULE_NAME, Security.USER_ID());
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private LoadItem = async (sMODULE_NAME: string, sID: string) =>
	{
		try
		{
			// 11/19/2019 Paul.  Change to allow return of SQL. 
			//const d = await DetailView_LoadItem(sMODULE_NAME, sID, false, false);
			// 10/05/2020 Paul.  Use the GetMyUserProfile call just in case the User module has been disabled for the user. 
			const d: any = await GetMyUserProfile();
			let item: any = d.results;
			if ( this._isMounted )
			{
				let SUB_TITLE: string = null;
				if ( item != null )
				{
					let LANG = Sql.ToString(item['LANG']);
					let objLanguage = SplendidCache.Languages(LANG);
					if ( objLanguage != null )
					{
						item['LANGUAGE'] = Sql.ToString(objLanguage['NATIVE_NAME']);
					}
				
					let TIMEZONE_ID = Sql.ToString(item['TIMEZONE_ID']);
					let objTimezone = SplendidCache.Timezones(TIMEZONE_ID);
					if ( objTimezone != null )
					{
						item['TIMEZONE'] = Sql.ToString(objTimezone['NAME']);
					}
				
					let CURRENCY_ID = Sql.ToString(item['CURRENCY_ID']);
					let objCurrency = SplendidCache.Currencies(CURRENCY_ID);
					if ( objCurrency != null )
					{
						item['CURRENCY'] = Sql.ToString(objCurrency['NAME_SYMBOL']);
					}
					// 04/29/2019 Paul.  Manually add to the list so that we do not need to request an update. 
					let sNAME = Sql.ToString(item['NAME']);
					if ( !Sql.IsEmptyString(sNAME) )
					{
						SplendidCache.AddLastViewed(sMODULE_NAME, sID, sNAME);
					}
					SUB_TITLE = item.NAME + ' (' + item.USER_NAME + ')';
				}
				document.title = L10n.Term('.moduleList.' + MODULE_NAME) + ' - ' + SUB_TITLE;
				// 04/26/2020 Paul.  Reset scroll every time we set the title. 
				window.scroll(0, 0);
				this.setState({ item, SUB_TITLE, __sql: item.__sql });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
			this.setState({ error });
		}
	}

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		let ID: string = Security.USER_ID();
		switch ( sCommandName )
		{
			case 'Edit':
			{
				history.push(`/Reset/${MODULE_NAME}/Edit/${ID}`);
				break;
			}
			case 'Duplicate':
			{
				history.push(`/Reset/${MODULE_NAME}/Duplicate/${ID}`);
				break;
			}
			case 'Cancel':
			{
				history.push(`/Reset/Home`);
				break;
			}
			case 'EditMyAccount':
			{
				history.push(`/Reset/Users/EditMyAccount`);
				break;
			}
			// 10/09/2020 Paul.  ResetDefaults was never previously coded. 
			case 'ResetDefaults':
			{
				try
				{
					if ( this.headerButtons.current != null )
					{
						this.headerButtons.current.Busy();
					}
					// 10/09/2020 Paul.  Prevent concurrency issue by getting latest values before reset. 
					const d: any = await GetMyUserProfile();
					let item                : any     = d.results;
					let default_theme       : string  = Crm_Config.ToString ('default_theme'       );
					let default_language    : string  = Crm_Config.ToString ('default_language'    );
					let default_date_format : string  = Crm_Config.ToString ('default_date_format' );
					let default_time_format : string  = Crm_Config.ToString ('default_time_format' );
					let default_timezone    : string  = Crm_Config.ToString ('default_timezone'    );
					let default_currency    : string  = Crm_Config.ToString ('default_currency'    );
					let save_query          : boolean = Crm_Config.ToBoolean('save_query'          );
					let group_tabs          : boolean = Crm_Config.ToBoolean('group_tabs'          );
					let subpanel_tabs       : boolean = Crm_Config.ToBoolean('subpanel_tabs'       );
					if ( Sql.IsEmptyString(default_theme) )
						default_theme = 'Arctic';
					item['THEME'        ] = default_theme      ;
					item['LANG'         ] = default_language   ;
					item['DATE_FORMAT'  ] = default_date_format;
					item['TIME_FORMAT'  ] = default_time_format;
					item['TIMEZONE_ID'  ] = default_timezone   ;
					item['CURRENCY_ID'  ] = default_currency   ;
					item['SAVE_QUERY'   ] = save_query         ;
					item['GROUP_TABS'   ] = group_tabs         ;
					item['SUBPANEL_TABS'] = subpanel_tabs      ;

					// 07/09/2020 Paul.  Even though USERS is an admin table, all updating will be run through the primary API instead of the Admin API.
					// This is so that we can keep all the password processing code in one location. 
					await UpdateModule(MODULE_NAME, item, ID, false);
					SplendidCache.IsInitialized = false;
					// 07/14/2021 Paul.  Use indexedDB to cache session state. 
					// 10/30/2021 Paul.  Must wait for clear to finish before reloading. 
					await Application_ClearStore();
					history.push(`/Reload/${MODULE_NAME}/MyAccount`);
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
					if ( this.headerButtons.current != null )
					{
						this.headerButtons.current.NotBusy();
					}
					if ( this._isMounted )
					{
						this.setState({ error });
					}
				}
				break;
			}
			// 01/09/2022 Paul.  Add support for ChangePassword. 
			case 'ChangePassword':
			{
				this.setState({ passwordOpen: true });
				break;
			}
			default:
			{
				if ( this._isMounted )
				{
					this.setState( {error: this.constructor.name + ': ' + sCommandName + ' is not supported at this time'} );
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
			this.headerButtons.current.ShowButton('EditMyAccount' , true );
			this.headerButtons.current.ShowButton('Edit'          , false);
			this.headerButtons.current.ShowButton('Duplicate'     , false);
			this.headerButtons.current.ShowButton('ChangePassword', true );
			// 10/09/2020 Paul.  ResetDefaults was never previously coded. 
			this.headerButtons.current.ShowButton('ResetDefaults' , true );
		}
	}

	// 01/09/2022 Paul.  Add support for ChangePassword. 
	private _onPasswordClose = () =>
	{
		this.setState({ passwordOpen: false });
	}

	// 04/13/2022 Paul.  Add LayoutTabs to Pacific theme. 
	private _onTabChange = (nActiveTabIndex) =>
	{
		let { layout } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTabChange', nActiveTabIndex);
		DetailView_ActivateTab(layout, nActiveTabIndex);
		this.setState({ layout });
	}

	public render()
	{
		const { item, layout, layoutMailOptions, layoutGoogleAppsOptions, layoutICloudOptions, layoutSignatures, layoutACLRoles, layoutTeams, layoutLogins, DETAIL_NAME, SUB_TITLE, error } = this.state;
		const { bExchangeEnabled, bGoogleAppsEnabled, biCloudEnabled, passwordOpen, showAccessView } = this.state;
		const { __total, __sql } = this.state;
		let ID: string = Security.USER_ID();
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		// 05/15/2018 Paul.  Defer process button logic. 
		// 06/26/2019 Paul.  Specify a key so that SplendidGrid will get componentDidMount when changing views. 
		let manualLayouts = [layoutSignatures, layoutACLRoles, layoutTeams];
		if ( SplendidCache.AdminUserAccess('Users', 'view') >= 0 )
		{
			manualLayouts.push(layoutLogins);
		}
		// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
		const styCheckbox = { transform: 'scale(1.5)', display: 'inline', marginTop: '2px', marginBottom: '6px' };
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		if ( Crm_Config.ToBoolean('enable_legacy_icons') )
		{
			styCheckbox.transform = 'scale(1.0)';
			styCheckbox.marginBottom = '2px';
		}
		this.refMap = {};
		if ( SplendidCache.IsInitialized && layout && item )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			// 04/13/2022 Paul.  Add LayoutTabs to Pacific theme. 
			return (
			<div>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, enableFavorites: false, error, enableHelp: true, helpName: 'DetailView', ButtonStyle: 'ModuleHeader', VIEW_NAME: DETAIL_NAME + '.MyAccount', row: item, Page_Command: this.Page_Command, showButtons: true, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons, showProcess: false })
				: null
				}
				<DumpSQL SQL={ __sql } />
				<PasswordPopupView
					USER_ID={ ID }
					isOpen={ passwordOpen }
					callback={ this._onPasswordClose }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.passwordView }
				/>
				<div id='divMain'>
					<table className='tabDetailView'>
						<tbody><tr>
							<td style={ {width: '15%', verticalAlign: 'top'} } className='tabDetailViewDL'>{ L10n.Term('Users.LBL_NAME') }</td>
							<td style={ {width: '35%', verticalAlign: 'top'} } className='tabDetailViewDF'>{ item.FULL_NAME }</td>
							<td style={ {width: '15%', verticalAlign: 'top'} } className='tabDetailViewDL'>{ L10n.Term('Users.LBL_USER_NAME') }</td>
							<td style={ {width: '35%', verticalAlign: 'top'} } className='tabDetailViewDF'>{ item.USER_NAME }</td>
						</tr>
						<tr>
							<td style={ {verticalAlign: 'top'} } className='tabDetailViewDL'>{ L10n.Term('Users.LBL_STATUS') }</td>
							<td style={ {verticalAlign: 'top'} } className='tabDetailViewDF'>{ L10n.ListTerm('user_status_dom', item.STATUS) }</td>
							{ Crm_Config.enable_team_management()
							? <td id='tdDEFAULT_TEAM_Label' style={ {verticalAlign: 'top'} } className='tabDetailViewDL'>{ L10n.Term('Users.LBL_DEFAULT_TEAM') }</td>
							: null
							}
							{ Crm_Config.enable_team_management()
							? <td id='tdDEFAULT_TEAM_Field' style={ {verticalAlign: 'top'} } className='tabDetailViewDF'>{ item.DEFAULT_TEAM_NAME }</td>
							: null
							}
						</tr>
						<tr>
							<td style={ {verticalAlign: 'top'} } className='tabDetailViewDL'>{ L10n.Term('Users.LBL_PICTURE') }</td>
							<td style={ {verticalAlign: 'top'} } className='tabDetailViewDF'><img id='imgPICTURE' style={ {width: '36px', height: '36px'} } src={ item.PICTURE } /></td>
							<td style={ {verticalAlign: 'top'} } className='tabDetailViewDL'></td>
							<td style={ {verticalAlign: 'top'} } className='tabDetailViewDF'></td>
						</tr></tbody>
					</table>
				</div>
				<div id='divUserSettings'>
					<table className='tabDetailView'>
						<tbody><tr>
							<th colSpan={ 3 } className='dataLabel'><h4>{ L10n.Term('Users.LBL_USER_SETTINGS') }</h4></th>
						</tr>
						{ Security.IS_ADMIN()
						? <tr>
							<td style={ {width: '20%'} } className='tabDetailViewDL'>{ L10n.Term('Users.LBL_ADMIN') }</td>
							<td style={ {width: '15%'} } className='tabDetailViewDF'><input type='checkbox' id='chkIS_ADMIN' disabled={ true } className='checkbox' style={ styCheckbox } checked={ item.IS_ADMIN } /></td>
							<td style={ {width: '65%'} } className='tabDetailViewDF'>{ L10n.Term('Users.LBL_ADMIN_TEXT') }</td>
						</tr>
						: null
						}
						{ SplendidCache.AdminUserAccess('Users', 'view') >= 0
						? <tr>
							<td style={ {width: '20%'} } className='tabDetailViewDL'>{ L10n.Term('Users.LBL_ADMIN_DELEGATE') }</td>
							<td style={ {width: '15%'} } className='tabDetailViewDF'><input type='checkbox' id='chkIS_ADMIN_DELEGATE' disabled={ true } className='checkbox' style={ styCheckbox } checked={ item.IS_ADMIN_DELEGATE } /></td>
							<td style={ {width: '65%'} } className='tabDetailViewDF'>{ L10n.Term('Users.LBL_ADMIN_DELEGATE_TEXT') }</td>
						</tr>
						: null
						}
						{ false
						? <tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_PORTAL_ONLY') }</td>
							<td className='tabDetailViewDF'><input type='checkbox' id='chkPORTAL_ONLY' disabled={ true } className='checkbox' style={ styCheckbox } checked={ item.PORTAL_ONLY } /></td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_PORTAL_ONLY_TEXT') }</td>
						</tr>
						: null
						}
						{ true
						? <tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_RECEIVE_NOTIFICATIONS') }</td>
							<td className='tabDetailViewDF'><input type='checkbox' id='chkRECEIVE_NOTIFICATIONS' disabled={ true } className='checkbox' style={ styCheckbox } checked={ item.RECEIVE_NOTIFICATIONS } /></td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_RECEIVE_NOTIFICATIONS_TEXT') }</td>
						</tr>
						: null
						}
						<tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_THEME') }</td>
							<td className='tabDetailViewDF'>{ item.THEME }</td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_THEME_TEXT') }</td>
						</tr>
						<tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_LANGUAGE') }</td>
							<td className='tabDetailViewDF'>{ item.LANGUAGE }</td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_LANGUAGE_TEXT') }</td>
						</tr>
						<tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_DATE_FORMAT') }</td>
							<td className='tabDetailViewDF'>{ item.DATE_FORMAT }</td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_DATE_FORMAT_TEXT') }</td>
						</tr>
						<tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_TIME_FORMAT') }</td>
							<td className='tabDetailViewDF'>{ item.TIME_FORMAT }</td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_TIME_FORMAT_TEXT') }</td>
						</tr>
						<tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_TIMEZONE') }</td>
							<td className='tabDetailViewDF'>{ item.TIMEZONE }</td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_TIMEZONE_TEXT') }</td>
						</tr>
						<tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_CURRENCY') }</td>
							<td className='tabDetailViewDF'>{ item.CURRENCY }</td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_CURRENCY_TEXT') }</td>
						</tr>
						{ false
						? <tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_REMINDER') }</td>
							<td className='tabDetailViewDF'>
								<input type='checkbox' id='chkREMINDER' disabled={ true } className='checkbox' style={ styCheckbox } checked={ item.REMINDER } />
							</td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_REMINDER_TEXT') }</td>
						</tr>
						: null
						}
						<tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_SAVE_QUERY') }</td>
							<td className='tabDetailViewDF'><input type='checkbox' id='chkSAVE_QUERY' disabled={ true } className='checkbox' style={ styCheckbox } checked={ item.SAVE_QUERY } /></td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_SAVE_QUERY_TEXT') }</td>
						</tr>
						<tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_GROUP_TABS') }</td>
							<td className='tabDetailViewDF'><input type='checkbox' id='chkGROUP_TABS' disabled={ true } className='checkbox' style={ styCheckbox } checked={ item.GROUP_TABS } /></td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_GROUP_TABS_TEXT') }</td>
						</tr>
						<tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_SUBPANEL_TABS') }</td>
							<td className='tabDetailViewDF'><input type='checkbox' id='chkSUBPANEL_TABS' disabled={ true } className='checkbox' style={ styCheckbox } checked={ item.SUBPANEL_TABS } /></td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_SUBPANEL_TABS_TEXT') }</td>
						</tr>
						{ Security.IS_ADMIN()
						? <tr>
							<td className='tabDetailViewDL'>{ L10n.Term('Users.LBL_SYSTEM_GENERATED_PASSWORD') }</td>
							<td className='tabDetailViewDF'><input type='checkbox' id='chkSYSTEM_GENERATED_PASSWORD' disabled={ true } className='checkbox' style={ styCheckbox } checked={ item.SYSTEM_GENERATED_PASSWORD } /></td>
							<td className='tabDetailViewDF'>{ L10n.Term('Users.LBL_SYSTEM_GENERATED_PASSWORD') }</td>
						</tr>
						: null
						}
						</tbody>
					</table>
				</div>
				<LayoutTabs layout={ layout } onTabChange={ this._onTabChange } />
				<div id='content'>
					<h4>{ L10n.Term('Users.LBL_USER_INFORMATION') }</h4>
					{ SplendidDynamic_DetailView.AppendDetailViewFields(item, layout, this.refMap, 'tabDetailView', null, this.Page_Command) }
				</div>
				<div id='divMailOptions' style={ {marginTop: '10px'} }>
					<h4>{ L10n.Term('Users.LBL_MAIL_OPTIONS_TITLE') }</h4>
					{ bExchangeEnabled
					? <DynamicButtons
						ButtonStyle='ListHeader'
						VIEW_NAME='Users.ExchangeSync'
						row={ item }
						Page_Command={ this.Page_Command }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
					/>
					: null
					}
					{ SplendidDynamic_DetailView.AppendDetailViewFields(item, layoutMailOptions, this.refMap, 'tabDetailView', null, this.Page_Command) }
				</div>
				{ bGoogleAppsEnabled
				? <div id='pnlGoogleAppsOptions' style={ {marginTop: '10px'} }>
					<h4>{ L10n.Term('Users.LBL_GOOGLEAPPS_OPTIONS_TITLE') }</h4>
					{ !Sql.IsEmptyString(item.GOOGLEAPPS_USERNAME)
					? <DynamicButtons
						ButtonStyle='ListHeader'
						VIEW_NAME='Users.GoogleSync'
						row={ item }
						Page_Command={ this.Page_Command }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
					/>
					: null
					}
					{ SplendidDynamic_DetailView.AppendDetailViewFields(item, layoutGoogleAppsOptions, this.refMap, 'tabDetailView', null, this.Page_Command) }
				</div>
				: null
				}
				{ biCloudEnabled
				? <div id='pnlICloudOptions' style={ {marginTop: '10px'} }>
					<h4>{ L10n.Term('Users.LBL_ICLOUD_OPTIONS_TITLE') }</h4>
					{ !Sql.IsEmptyString(item.ICLOUD_USERNAME)
					? <DynamicButtons
						ButtonStyle='ListHeader'
						VIEW_NAME='Users.iCloudSync'
						row={ item }
						Page_Command={ this.Page_Command }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
					/>
					: null
					}
					{ SplendidDynamic_DetailView.AppendDetailViewFields(item, layoutICloudOptions, this.refMap, 'tabDetailView', null, this.Page_Command) }
				</div>
				: null
				}
				<br />
				{ showAccessView
				? <AccessView USER_ID={ Security.USER_ID() } />
				: null
				}
				<br />
				{
					manualLayouts.map(layout => (
						<DynamicSubPanelView key={ 'Users.' + layout.CONTROL_NAME + '.SubPanel' } PARENT_TYPE={ MODULE_NAME } row={ item } layout={ layout } CONTROL_VIEW_NAME={ MODULE_NAME + '.' + layout.CONTROL_NAME } isPrecompile={ this.props.isPrecompile } onComponentComplete={ this.onManualRelationshipsComplete } />
					))
				}
				<DetailViewRelationships key={ MODULE_NAME + '_DetailViewRelationships' } PARENT_TYPE={ MODULE_NAME } DETAIL_NAME={ DETAIL_NAME } row={ item } isPrecompile={ this.props.isPrecompile } onComponentComplete={ this.onRelationshipsComplete } />
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
				<FontAwesomeIcon icon='spinner' spin={ true } size='5x' />
			</div>);
		}
	}
}

export default withRouter(MyAccountView);
