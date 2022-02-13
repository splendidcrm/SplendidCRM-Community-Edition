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
import { RouteComponentProps, withRouter }             from 'react-router-dom'                      ;
import { observer }                                    from 'mobx-react'                            ;
import { FontAwesomeIcon }                             from '@fortawesome/react-fontawesome'        ;
// 2. Store and Types. 
import { EditComponent }                               from '../../types/EditComponent'             ;
import { HeaderButtons }                               from '../../types/HeaderButtons'             ;
import EDITVIEWS_FIELD                                 from '../../types/EDITVIEWS_FIELD'           ;
// 3. Scripts. 
import L10n                                            from '../../scripts/L10n'                    ;
import Sql                                             from '../../scripts/Sql'                     ;
import Security                                        from '../../scripts/Security'                ;
import Credentials                                     from '../../scripts/Credentials'             ;
import SplendidCache                                   from '../../scripts/SplendidCache'           ;
import SplendidDynamic_EditView                        from '../../scripts/SplendidDynamic_EditView';
import { Crm_Config }                                  from '../..//scripts/Crm'                    ;
import { AuthenticatedMethod, LoginRedirect, GetMyUserProfile } from '../../scripts/Login'          ;
import { EditView_LoadLayout }                         from '../../scripts/EditView'                ;
import { Application_ClearStore }                      from '../../scripts/Application'             ;
import { UpdateModule }                                from '../../scripts/ModuleUpdate'            ;
import { CreateSplendidRequest, GetSplendidResult }    from '../../scripts/SplendidRequest'         ;
// 4. Components and Views. 
import ErrorComponent                                  from '../../components/ErrorComponent'       ;

interface IUserWizardProps extends RouteComponentProps<any>
{
	MODULE_NAME       : string;
	ID?               : string;
	LAYOUT_NAME?      : string;
	callback?         : Function;
	rowDefaultSearch? : any;
	onLayoutLoaded?   : Function;
	onSubmit?         : Function;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data) => void;
}

interface IUserWizardState
{
	item              : any;
	layoutProfile     : EDITVIEWS_FIELD[];
	layoutLocale      : EDITVIEWS_FIELD[];
	layoutMail        : EDITVIEWS_FIELD[];
	MODULE_NAME       : string;
	EDIT_NAME         : string;
	editedItem        : any;
	dependents        : Record<string, Array<any>>;
	error?            : any;
	nWizardPanel      : number;
	LANGUAGE_LIST     : string[];
	CURRENCY_LIST     : string[];
	DATE_FORMAT_LIST  : string[];
	TIME_FORMAT_LIST  : string[];
	TIMEZONE_LIST     : string[];
}

@observer
class UserWizard extends React.Component<IUserWizardProps, IUserWizardState>
{
	private _isMounted = false;
	private headerButtons = React.createRef<HeaderButtons>();

	constructor(props: IUserWizardProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor');
		Credentials.SetViewMode('UserWizard');
		let MODULE_NAME: string = 'Users';
		let EDIT_NAME  : string = MODULE_NAME + '.UserWizard.Profile';
		if ( Sql.IsEmptyString(MODULE_NAME) )
		{
		}
		this.state =
		{
			item              : {},
			layoutProfile     : null,
			layoutLocale      : null,
			layoutMail        : null,
			MODULE_NAME       ,
			EDIT_NAME         ,
			editedItem        : null,
			dependents        : {},
			error             : null,
			nWizardPanel      : 0,
			LANGUAGE_LIST     : [],
			CURRENCY_LIST     : [],
			DATE_FORMAT_LIST  : [],
			TIME_FORMAT_LIST  : [],
			TIMEZONE_LIST     : [],
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
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
				document.title = L10n.ListTerm('moduleList', 'Users');
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

	async componentDidUpdate(prevProps: IUserWizardProps)
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
				const { item, layoutProfile, EDIT_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + DETAIL_NAME, item);
				if ( layoutProfile != null && error == null )
				{
					if ( item != null )
					{
						this.props.onComponentComplete(MODULE_NAME, null, EDIT_NAME, item);
					}
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
		try
		{
			let layoutProfile: EDITVIEWS_FIELD[] = EditView_LoadLayout('Users.UserWizard.Profile');
			let layoutLocale : EDITVIEWS_FIELD[] = EditView_LoadLayout('Users.UserWizard.Locale' );
			let layoutMail   : EDITVIEWS_FIELD[] = EditView_LoadLayout('Users.UserWizard.Mail'   );
			if ( this._isMounted )
			{
				this.setState(
				{
					layoutProfile,
					layoutLocale ,
					layoutMail   ,
					editedItem   : null,
				});
				await this.LoadItem();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private LoadItem = async () =>
	{
		try
		{
			// 11/19/2019 Paul.  Change to allow return of SQL. 
			let d: any = null;
			d = await GetMyUserProfile();
			let item: any = d.results;
			if ( item != null )
			{
				// 11/09/2020 Paul.  We need to initialize default values if the current value is null. 
				// This will allow the theme to be disabled while ensuring that the default is used. 
				if ( item['LANG'         ] == null ) item['LANG'         ] = Crm_Config.ToString ('default_language'     );
				if ( item['THEME'        ] == null ) item['THEME'        ] = Crm_Config.ToString ('default_theme'        );
				if ( item['DATE_FORMAT'  ] == null ) item['DATE_FORMAT'  ] = Crm_Config.ToString ('default_date_format'  );
				if ( item['TIME_FORMAT'  ] == null ) item['TIME_FORMAT'  ] = Crm_Config.ToString ('default_time_format'  );
				if ( item['CURRENCY_ID'  ] == null ) item['CURRENCY_ID'  ] = Crm_Config.ToString ('default_currency'     );
				if ( item['TIMEZONE_ID'  ] == null ) item['TIMEZONE_ID'  ] = Crm_Config.ToString ('default_timezone'     );
			}
			let LANGUAGE_LIST   : string[] = L10n.GetList('Languages' );
			let CURRENCY_LIST   : string[] = L10n.GetList('Currencies');
			let DATE_FORMAT_LIST: string[] = L10n.GetList('DateFormat.' + item['LANG']);
			let TIME_FORMAT_LIST: string[] = L10n.GetList('TimeFormat.' + item['LANG']);
			let TIMEZONE_LIST   : string[] = L10n.GetList('TimeZones');
			this.setState(
			{
				item            ,
				LANGUAGE_LIST   ,
				CURRENCY_LIST   ,
				DATE_FORMAT_LIST,
				TIME_FORMAT_LIST,
				TIMEZONE_LIST   ,
			});
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
		let { item, nWizardPanel, error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments)
		if ( item == null )
			item = {};
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Next':
				case 'Continue':
				{
					if ( error != null || error == '' )
					{
						this.setState({ error: '' });
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command item', item)
					if ( Sql.IsEmptyString(item['LAST_NAME']) )
					{
						this.setState({ error: L10n.Term("Users.LBL_LAST_NAME") + ' ' + L10n.Term('.NTC_REQUIRED') });
						return;
					}
					if ( Sql.IsEmptyString(item['EMAIL1']) )
					{
						this.setState({ error: L10n.Term("Users.LBL_EMAIL") + ' ' + L10n.Term('.NTC_REQUIRED') });
						return;
					}
					// 12/07/2021 Paul.  Must include the ID in the row for it to get used. 
					row =
					{
						ID: Security.USER_ID()
					};
					if ( nWizardPanel == 0 )
					{
						row['FIRST_NAME'          ] = item['FIRST_NAME'          ];
						row['LAST_NAME'           ] = item['LAST_NAME'           ];
						row['EMAIL1'              ] = item['EMAIL1'              ];
						row['PHONE_WORK'          ] = item['PHONE_WORK'          ];
						row['PHONE_MOBILE'        ] = item['PHONE_MOBILE'        ];
						row['ADDRESS_STREET'      ] = item['ADDRESS_STREET'      ];
						row['ADDRESS_CITY'        ] = item['ADDRESS_CITY'        ];
						row['ADDRESS_STATE'       ] = item['ADDRESS_STATE'       ];
						row['ADDRESS_POSTALCODE'  ] = item['ADDRESS_POSTALCODE'  ];
						row['ADDRESS_COUNTRY'     ] = item['ADDRESS_COUNTRY'     ];
					}
					else if ( nWizardPanel == 1 )
					{
						row['LANG'                ] = item['LANG'                ];
						row['CURRENCY_ID'         ] = item['CURRENCY_ID'         ];
						row['DATE_FORMAT'         ] = item['DATE_FORMAT'         ];
						row['TIME_FORMAT'         ] = item['TIME_FORMAT'         ];
						row['TIMEZONE_ID'         ] = item['TIMEZONE_ID'         ];
					}
					else if ( nWizardPanel == 2 )
					{
						row['MAIL_SMTPUSER'       ] = item['MAIL_SMTPUSER'       ];
						row['MAIL_SMTPPASS'       ] = item['MAIL_SMTPPASS'       ];
					}
					try
					{
						if ( this.headerButtons.current != null )
						{
							this.headerButtons.current.Busy();
						}
						await UpdateModule('Users', row, Security.USER_ID(), false);
						// 10/31/2021 Paul.  Instead of reloading state now, just let next login take care of it. 
						if ( nWizardPanel == 1 )
						{
							await Application_ClearStore();
							// 12/08/2021 Paul.  SplendidApp will not define EmailMan, so use this to skip mail settings. 
							if ( L10n.Term("EmailMan.LBL_MAIL_SMTPSERVER") == 'EmailMan.LBL_MAIL_SMTPSERVER' )
							{
								history.push(`/Reload/Home`);
								return;
							}
						}
						
						if ( nWizardPanel < 2 )
						{
							nWizardPanel++;
							this.setState({ nWizardPanel });
						}
						if ( sCommandName == 'Continue' )
						{
							history.push(`/Reload/Home`);
						}
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
					finally
					{
						if ( this.headerButtons.current != null )
						{
							this.headerButtons.current.NotBusy();
						}
					}
					break;
				}
				case 'Skip':
				{
					// 10/30/2021 Paul.  If the user wants to skip, then we will not present the profile config again. 
					// 02/10/2022 Paul.  Must include the ID in the row for it to get used. 
					row =
					{
						ID: Security.USER_ID()
					};
					row['TIMEZONE_ID'] = Credentials.sUSER_TIMEZONE_ID;
					if ( Sql.IsEmptyString(row['TIMEZONE_ID']) )
						row['TIMEZONE_ID'] = Crm_Config.ToString ('default_timezone');
					if ( !Sql.IsEmptyString(row['TIMEZONE_ID']) )
					{
						Credentials.sORIGINAL_TIMEZONE_ID = row['TIMEZONE_ID'];
						try
						{
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.Busy();
							}
							await UpdateModule('Users', row, Security.USER_ID(), false);
						}
						catch(error)
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
						}
						finally
						{
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.NotBusy();
							}
						}
					}
					history.push(`/Reset/Home`);
					break;
				}
				case 'Back':
				{
					if ( nWizardPanel > 0 )
					{
						nWizardPanel--;
						this.setState({ nWizardPanel });
					}
					break;
				}
				case "Smtp.Test":
				{
					try
					{
						let obj: any = {};
						obj.mail_sendtype     = 'smtp';
						obj.mail_smtpuser     = item['smtpuser'];
						obj.mail_smtppass     = item['smtppass'];
						let sBody: string = JSON.stringify(obj);
						let res  = await CreateSplendidRequest('Administration/EmailMan/Rest.svc/SendTestMessage', 'POST', 'application/octet-stream', sBody);
						let json = await GetSplendidResult(res);
						
						let error: string = json.d;
						error =  error.replace(/<br \/>/g, ' ');
						this.setState({ error });
					}
					catch(error)
					{
						console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command', error);
						this.setState({ error });
					}
					break;
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private _onTEXT_Changed = (e, sFIELD_NAME: string): void =>
	{
		let { item } = this.state;
		if ( item == null )
			item = {};
		item[sFIELD_NAME] = e.target.value;
		if ( sFIELD_NAME == 'LANG' )
		{
			let DATE_FORMAT_LIST: string[] = L10n.GetList('DateFormat.' + item['LANG']);
			let TIME_FORMAT_LIST: string[] = L10n.GetList('TimeFormat.' + item['LANG']);
			this.setState(
			{
				item            ,
				DATE_FORMAT_LIST,
				TIME_FORMAT_LIST,
				error           : ''
			});
		}
		else
		{
			this.setState({ item, error: '' });
		}
	}

	public render()
	{
		const { item, layoutProfile, error } = this.state;
		const { nWizardPanel } = this.state;
		if ( layoutProfile == null || item == null )
		{
			return null;
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.remder');
		if ( SplendidCache.IsInitialized )
		{
			Credentials.sUSER_THEME;
			const currentItem = Object.assign({}, this.state.item);
			return (
<div id="divAdminWizard">
	<div>
		<div>
			<ErrorComponent error={ error } />

			<table cellPadding={ 20 } style={ {width: '820px', marginLeft: 'auto', marginRight: 'auto'} }>
				<tr>
					<td>
						<table id="tblSystemName" className='tabForm' cellPadding={ 4 } cellSpacing={ 1 } style={ {width: '100%', height: '440px', display: (nWizardPanel == 0 ? null : 'none')} }>
							<tbody>
								<tr style={ {paddingTop: '20px', height: '20px'} }>
									<td style={ {paddingLeft: '20px', paddingTop: '10px'} }>
										<h2>
											<span>{ L10n.Term("Configurator.LBL_WIZARD_USER_SETTINGS_DESC") }</span>
										</h2>
									</td>
								</tr>
								<tr style={ {height: '10px'} }>
									<td style={ {paddingLeft: '20px'} }>
										<span style={ {fontStyle: 'italic'} }>{ L10n.Term("Configurator.LBL_WIZARD_SYSTEM_DESC") }</span>
									</td>
								</tr>
								<tr>
									<td valign="top" style={ {paddingLeft: '20px'} }>
										<table cellPadding={ 2 }>
											<tbody>
												<tr>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("Users.LBL_FIRST_NAME") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="company_name" size={ 25 } maxLength={ 30 } value={ currentItem['FIRST_NAME'] } onChange={ (e) => this._onTEXT_Changed(e, 'FIRST_NAME') }/>
													</td>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("Users.LBL_LAST_NAME") }</span>
														<span className="required">{ L10n.Term('.LBL_REQUIRED_SYMBOL') }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="LAST_NAME" size={ 25 } maxLength={ 30 } value={ currentItem['LAST_NAME'] } onChange={ (e) => this._onTEXT_Changed(e, 'LAST_NAME') }/>
														&nbsp;
														{ Sql.IsEmptyString(currentItem['LAST_NAME'])
														? <span className="required">{ L10n.Term('.NTC_REQUIRED') }</span>
														: null
														}
													</td>
												</tr>
												<tr>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("Users.LBL_EMAIL") }</span>
														<span className="required">{ L10n.Term('.LBL_REQUIRED_SYMBOL') }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="EMAIL1" size={ 25 } maxLength={ 100 } value={ currentItem['EMAIL1'] } onChange={ (e) => this._onTEXT_Changed(e, 'EMAIL1') }/>
														&nbsp;
														{ Sql.IsEmptyString(currentItem['EMAIL1'])
														? <span className="required">{ L10n.Term('.NTC_REQUIRED') }</span>
														: null
														}
													</td>
													<td style={ {width: '15%'} }>
													</td>
													<td style={ {width: '35%'} }>
													</td>
												</tr>
												<tr>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("Users.LBL_OFFICE_PHONE") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="OFFICE_PHONE" size={ 25 } maxLength={ 30 } value={ currentItem['OFFICE_PHONE'] } onChange={ (e) => this._onTEXT_Changed(e, 'OFFICE_PHONE') }/>
													</td>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("Users.LBL_MOBILE_PHONE") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="PHONE_MOBILE" size={ 25 } maxLength={ 30 } value={ currentItem['PHONE_MOBILE'] } onChange={ (e) => this._onTEXT_Changed(e, 'PHONE_MOBILE') }/>
													</td>
												</tr>
												<tr>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("Users.LBL_PRIMARY_ADDRESS") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<textarea id="ADDRESS_STREET" rows={ 2 } cols={ 30 } value={ currentItem['ADDRESS_STREET'] } onChange={ (e) => this._onTEXT_Changed(e, 'ADDRESS_STREET') }/>
													</td>
													<td style={ {width: '15%'} }>
													</td>
													<td style={ {width: '35%'} }>
													</td>
												</tr>
												<tr>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("Users.LBL_CITY") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="ADDRESS_CITY" size={ 25 } maxLength={ 30 } value={ currentItem['ADDRESS_CITY'] } onChange={ (e) => this._onTEXT_Changed(e, 'ADDRESS_CITY') }/>
													</td>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("Users.LBL_STATE") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="ADDRESS_STATE" size={ 25 } maxLength={ 30 } value={ currentItem['ADDRESS_STATE'] } onChange={ (e) => this._onTEXT_Changed(e, 'ADDRESS_STATE') }/>
													</td>
												</tr>
												<tr>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("Users.LBL_POSTAL_CODE") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="ADDRESS_POSTALCODE" size={ 25 } maxLength={ 30 } value={ currentItem['ADDRESS_POSTALCODE'] } onChange={ (e) => this._onTEXT_Changed(e, 'ADDRESS_POSTALCODE') }/>
													</td>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("Users.LBL_COUNTRY") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="ADDRESS_COUNTRY" size={ 25 } maxLength={ 30 } value={ currentItem['ADDRESS_COUNTRY'] } onChange={ (e) => this._onTEXT_Changed(e, 'ADDRESS_COUNTRY') }/>
													</td>
												</tr>
											</tbody>
										</table>
									</td>
								</tr>
								<tr style={ {height: '20px'} }>
									<td valign="bottom" align="right" style={ {paddingRight: '20px'} }>
										<button onClick={ (e) => { e.preventDefault(); this.Page_Command('Skip', null); } } className="button" style={ {display: (nWizardPanel == 0 ? 'inline' : 'none')} }>{ "  " + L10n.Term("Configurator.LBL_SKIP_BUTTON") + "  " }</button>
										<button onClick={ (e) => { e.preventDefault(); this.Page_Command('Back', null); } } className="button" style={ {display: (nWizardPanel > 0  ? 'inline' : 'none')} }>{ "  " + L10n.Term("Configurator.LBL_BACK_BUTTON") + "  " }</button>
										&nbsp;
										<button id="btnSystemNameNext" onClick={ (e) => { e.preventDefault(); this.Page_Command('Next', null); } } className="button">{ "  " + L10n.Term("Configurator.LBL_NEXT_BUTTON") + "  " }</button>
									</td>
								</tr>
							</tbody>
						</table>

						<table id="tblSystemLocale" className='tabForm' cellPadding={ 4 } cellSpacing={ 1 } style={ {width: '100%', height: '440px', display: (nWizardPanel == 1 ? null : 'none')} }>
							<tbody>
								<tr style={ {paddingTop: '20px', height: '20px'} }>
									<td style={ {paddingLeft: '20px', paddingTop: '10px'} }>
										<h2>
											<span>{ L10n.Term("Configurator.LBL_WIZARD_USER_LOCALE_TITLE") }</span>
										</h2>
									</td>
								</tr>
								<tr style={ {height: '10px'} }>
									<td style={ {paddingLeft: '20px'} }>
										<span style={ {fontStyle: 'italic'} }>{ L10n.Term("Configurator.LBL_WIZARD_USER_LOCALE_DESC") }</span>
									</td>
								</tr>
								<tr>
									<td valign="top" style={ {paddingLeft: '20px'} }>
										<table cellPadding={ 2 }>
											<tbody>
												<tr>
													<td style={ {width: '15%'} } valign="top">
														<span>{ L10n.Term("Users.LBL_LANGUAGE") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<select id="LANG" value={ currentItem['LANG'] } onChange={ (e) => this._onTEXT_Changed(e, 'LANG') }>
														{ this.state.LANGUAGE_LIST
														? this.state.LANGUAGE_LIST.map((item, index) => 
															{
																return (<option id={ 'LANGUAGE' + ' _' + index.toString() } key={ 'LANGUAGE' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('Languages', item) }</option>);
															})
														: null
														}
														</select>
													</td>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("Users.LBL_CURRENCY") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<select id="CURRENCY_ID" value={ currentItem['CURRENCY_ID'] } onChange={ (e) => this._onTEXT_Changed(e, 'CURRENCY_ID') }>
														{ this.state.CURRENCY_LIST
														? this.state.CURRENCY_LIST.map((item, index) => 
															{
																return (<option id={ 'CURRENCY' + ' _' + index.toString() } key={ 'CURRENCY' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('Currencies', item) }</option>);
															})
														: null
														}
														</select>
													</td>
												</tr>
												<tr>
													<td>
														<span>{ L10n.Term("Users.LBL_DATE_FORMAT") }</span>
													</td>
													<td>
														<select id="DATE_FORMAT" value={ currentItem['DATE_FORMAT'] } onChange={ (e) => this._onTEXT_Changed(e, 'DATE_FORMAT') }>
														{ this.state.DATE_FORMAT_LIST
														? this.state.DATE_FORMAT_LIST.map((item, index) => 
															{
																return (<option id={ 'DATE_FORMAT' + ' _' + index.toString() } key={ 'DATE_FORMAT' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('DateFormat.' + currentItem['LANG'], item) }</option>);
															})
														: null
														}
														</select>
													</td>
													<td>
														<span>{ L10n.Term("Users.LBL_TIME_FORMAT") }</span>
													</td>
													<td>
														<select id="TIME_FORMAT" value={ currentItem['TIME_FORMAT'] } onChange={ (e) => this._onTEXT_Changed(e, 'TIME_FORMAT') }>
														{ this.state.TIME_FORMAT_LIST
														? this.state.TIME_FORMAT_LIST.map((item, index) => 
															{
																return (<option id={ 'TIME_FORMAT' + ' _' + index.toString() } key={ 'TIME_FORMAT' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('TimeFormat.' + currentItem['LANG'], item) }</option>);
															})
														: null
														}
														</select>
													</td>
												</tr>
												<tr>
													<td>
														<span>{ L10n.Term("Users.LBL_TIMEZONE") }</span>
													</td>
													<td>
														<select id="TIMEZONE_ID" value={ currentItem['TIMEZONE_ID'] } onChange={ (e) => this._onTEXT_Changed(e, 'TIMEZONE_ID') }>
														{ this.state.TIMEZONE_LIST
														? this.state.TIMEZONE_LIST.map((item, index) => 
															{
																return (<option id={ 'TIMEZONE' + ' _' + index.toString() } key={ 'TIMEZONE' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('TimeZones', item) }</option>);
															})
														: null
														}
														</select>
													</td>
												</tr>
											</tbody>
										</table>
									</td>
								</tr>
								<tr style={ {height: '10px'} }>
									<td valign="bottom" align="right" style={ {paddingRight: '20px'} }>
										<button onClick={ (e) => { e.preventDefault(); this.Page_Command('Back', null); } } className="button">{ "  " + L10n.Term("Configurator.LBL_BACK_BUTTON") + "  " }</button>
										&nbsp;
										<button onClick={ (e) => { e.preventDefault(); this.Page_Command('Next', null); } } className="button">{ "  " + L10n.Term("Configurator.LBL_NEXT_BUTTON") + "  " }</button>
									</td>
								</tr>
							</tbody>
						</table>

						<table id="tblMailSettings" className='tabForm' cellPadding={ 4 } cellSpacing={ 1 } style={ {width: '100%', height: '440px', display: (nWizardPanel == 2 ? null : 'none')} }>
							<tbody>
								<tr style={ {paddingTop: '20px', height: '20px'} }>
									<td style={ {paddingLeft: '20px', paddingTop: '10px'} }>
										<h2>
											<span>{ L10n.Term("Configurator.LBL_WIZARD_USER_MAIL_TITLE") }</span>
										</h2>
									</td>
								</tr>
								<tr style={ {height: '10px'} }>
									<td style={ {paddingLeft: '20px'} }>
										<span style={ {fontStyle: 'italic'} }>{ L10n.Term("Configurator.LBL_WIZARD_USER_MAIL_DESC") }</span>
									</td>
								</tr>
								<tr>
									<td valign="top" style={ {paddingLeft: '20px'} }>
										<table cellPadding={ 2 }>
											<tbody>
												<tr>
													<td style={ {width: '15%'} } valign="top">
														<span>{ L10n.Term("EmailMan.LBL_MAIL_SMTPSERVER") }</span>
													</td>
													<td style={ {width: '85%'} }>
														<span>{ currentItem['smtpserver'] }</span>
													</td>
												</tr>
												<tr>
													<td>
														<span>{ L10n.Term("EmailMan.LBL_MAIL_SMTPUSER") }</span>
													</td>
													<td>
														<input id="smtpuser" size={ 25 } maxLength={ 64 } value={ currentItem['smtpuser'] } onChange={ (e) => this._onTEXT_Changed(e, 'smtpuser') } />
													</td>
													<td>
														<span>{ L10n.Term("EmailMan.LBL_MAIL_SMTPPASS") }</span>
													</td>
													<td>
														<input id="password" size={ 25 } maxLength={ 64 } type="password" value={ currentItem['smtppass'] } onChange={ (e) => this._onTEXT_Changed(e, 'smtppass') } />
													</td>
												</tr>
												<tr>
													<td colSpan={ 4 }>
														<button onClick={ (e) => { e.preventDefault(); this.Page_Command('Smtp.Test' , null); } } className="button">{ "  " + L10n.Term("Configurator.LBL_EMAIL_TEST_OUTBOUND_SETTINGS") + "  " }</button>
													</td>
												</tr>
											</tbody>
										</table>
									</td>
								</tr>
								<tr style={ {height: '20px'} }>
									<td valign="bottom" align="right" style={ {paddingRight: '20px'} }>
										<button onClick={ (e) => { e.preventDefault(); this.Page_Command('Back'    , null); } } className="button">{ "  " + L10n.Term("Configurator.LBL_BACK_BUTTON") + "  " }</button>
										&nbsp;
										<button onClick={ (e) => { e.preventDefault(); this.Page_Command('Continue', null); } } className="button">{ "  " + L10n.Term("Configurator.LBL_CONTINUE_BUTTON") + "  " }</button>
									</td>
								</tr>
							</tbody>
						</table>
					</td>
				</tr>
			</table>
		</div>
	</div>
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

export default withRouter(UserWizard);

