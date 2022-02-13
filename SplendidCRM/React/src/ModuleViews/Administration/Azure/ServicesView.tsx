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
import { Link, RouteComponentProps, withRouter }    from 'react-router-dom'                        ;
import { observer }                                 from 'mobx-react'                              ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'          ;
// 2. Store and Types. 
import { DetailComponent, IDetailViewProps }        from '../../../types/DetailComponent'          ;
import AdminModule                                  from '../../../types/AdminModule'              ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                    ;
import L10n                                         from '../../../scripts/L10n'                   ;
import Credentials                                  from '../../../scripts/Credentials'            ;
import SplendidCache                                from '../../../scripts/SplendidCache'          ;
import { DetailViewRelationships_LoadLayout }       from '../../../scripts/DetailViewRelationships';
import { Admin_GetReactState }                      from '../../../scripts/Application'            ;
import { SystemCacheRequest }                       from '../../../scripts/SystemCacheRequest'     ;
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'        ;
// 4. Components and Views. 
import ErrorComponent                               from '../../../components/ErrorComponent'      ;

interface IAdministrationViewState
{
	AZURE_MENU  : any;
	stateKey    : number;
	error       : any;
	recompileKey: string;
	item        : any;
	layout      : any;
	DETAIL_NAME : string;
}

@observer
class AzureServicesView extends React.Component<IDetailViewProps, IAdministrationViewState>
{
	constructor(props: IDetailViewProps)
	{
		super(props);
		Credentials.SetViewMode('AdministrationView');
		this.state =
		{
			AZURE_MENU  : null,
			stateKey    : 0,
			error       : null,
			recompileKey: 'recompile',
			item        : {},
			layout      : null,
			DETAIL_NAME : 'Azure.DetailView',
		};
	}

	async componentDidMount()
	{
		const { DETAIL_NAME } = this.state;
		try
		{
			if ( SplendidCache.AdminMenu == null )
			{
				await Admin_GetReactState(this.constructor.name + '.componentDidMount');
			}
			let layout = await DetailViewRelationships_LoadLayout(DETAIL_NAME);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', layout);

			let ADMIN_MENU = SplendidCache.AdminMenu;
			let AZURE_MENU: any[] = [];
			for ( let i: number = 0; i < ADMIN_MENU.length; i++ )
			{
				if ( ADMIN_MENU[i].NAME == 'AzureView' || ADMIN_MENU[i].NAME == 'AzureMonitoring' )
				{
					AZURE_MENU.push(ADMIN_MENU[i]);
				}
			}
			document.title = L10n.Term("Azure.LBL_AZURE_SETTINGS");
			window.scroll(0, 0);
			this.setState({ AZURE_MENU, layout });
			// 03/05/2019 Paul.  Don't turn on admin menu until the menu has been built. 
			if ( !Credentials.ADMIN_MODE )
			{
				Credentials.SetADMIN_MODE(true);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
		}
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
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
				const { MODULE_NAME, ID } = this.props;
				const { item, layout, DETAIL_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + DETAIL_NAME, item);
				if ( layout != null && error == null )
				{
					if ( item != null && this._areRelationshipsComplete )
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
			const { MODULE_NAME, ID } = this.props;
			const { item, layout, DETAIL_NAME, error } = this.state;
			if ( layout != null && error == null )
			{
				if ( item != null && this._areRelationshipsComplete )
				{
					this.props.onComponentComplete(MODULE_NAME, null, DETAIL_NAME, item);
				}
			}
		}
	}

	private ModuleActions = (adminModule: AdminModule) =>
	{
		const { stateKey } = this.state;
		const { MODULE_NAME, ADMIN_ROUTE } = adminModule;
		// 11/11/2019 Paul.  A null module means this is a blank. 
		if ( MODULE_NAME == null )
		{
			return null;
		}
		return null;
	}

	private ModuleStatus = (adminModule: AdminModule) =>
	{
		const { stateKey } = this.state;
		const { MODULE_NAME, ADMIN_ROUTE } = adminModule;
		// 11/11/2019 Paul.  A null module means this is a blank. 
		if ( MODULE_NAME == null )
		{
			return null;
		}
		return null;
	}

	private ExternalLink = (url: string, target: string, term: string) =>
	{
		return(<span>
			<a href={ url } target={ target }>{ L10n.Term(term) }</a>&nbsp;&nbsp;<FontAwesomeIcon icon='external-link-alt' color='#444444' />
		</span>
		);
	}

	private PrimaryAction = (adminModule: AdminModule) =>
	{
		const { MODULE_NAME, DISPLAY_NAME, ADMIN_ROUTE } = adminModule;
		// 11/11/2019 Paul.  A null module means this is a blank. 
		if ( MODULE_NAME == null )
		{
			return null;
		}
		else
		{
			return (<Link 
				className='tabDetailViewDL2Link' 
				to={ !Sql.IsEmptyString(ADMIN_ROUTE) ? '/Administration/' + MODULE_NAME + '/' + ADMIN_ROUTE : '/Administration/' + MODULE_NAME + '/List'  }>
				{ L10n.Term(DISPLAY_NAME).replace('&reg;', '\u00ae') }
			</Link>);
		}
	}

	public render()
	{
		const { AZURE_MENU, error, recompileKey, DETAIL_NAME, item } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			return (
			<div id="ctlAdministration">
				<ErrorComponent error={error} />
				{ AZURE_MENU
				? AZURE_MENU.map(adminPanel => (
					<div>
						<div className='h3Row' style={ {display: 'flex', justifyContent: 'center', flexDirection: 'column'} }>
							<h3>{ adminPanel.TITLE }</h3>
						</div>
						<div className='tabDetailView2' style={ {width: '100%', display: 'flex', flexFlow: 'row wrap'} }>
							{ adminPanel.MODULES.map((adminModule: AdminModule) => (
								<div style={ {width: '100%', display: 'flex', flexFlow: 'row wrap', flex: '1 0 50%'} }>
									<div className='tabDetailViewDL2' style={ {width: '40%'} }>
										{ adminModule.MODULE_NAME
										? <img 
											style={ {borderWidth: '0', height: '16px', width: '16px', verticalAlign: 'text-bottom'} }
											src={ Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/' + adminModule.ICON_NAME }
										/>
										: null
										}
										&nbsp;
										{ this.PrimaryAction(adminModule) }
										{ this.ModuleActions(adminModule) }
									</div>
									<div className='tabDetailViewDF2' style={ {width: '60%'} }>
										<div>{ !Sql.IsEmptyString(adminModule.DESCRIPTION) ? L10n.Term(adminModule.DESCRIPTION) : null }</div>
										{ this.ModuleStatus(adminModule) }
									</div>
								</div>))
							}
							{ adminPanel.MODULES.length % 2 == 1
							? <div style={ {width: '100%', display: 'flex', flexFlow: 'row wrap', flex: '1 0 50%'} }>
								<div className='tabDetailViewDL2' style={ {width: '40%'} }></div>
								<div className='tabDetailViewDF2' style={ {width: '60%'} }></div>
							</div>
							: null
							}
						</div>
					</div>))
				: null
				}
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

export default withRouter(AzureServicesView);
