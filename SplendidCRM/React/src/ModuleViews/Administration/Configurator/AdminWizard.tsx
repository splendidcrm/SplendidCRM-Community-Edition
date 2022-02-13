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
import { RouteComponentProps, withRouter }             from 'react-router-dom'                         ;
import { observer }                                    from 'mobx-react'                               ;
import { FontAwesomeIcon }                             from '@fortawesome/react-fontawesome'           ;
// 2. Store and Types. 
import { EditComponent }                               from '../../../types/EditComponent'             ;
import { HeaderButtons }                               from '../../../types/HeaderButtons'             ;
import EDITVIEWS_FIELD                                 from '../../../types/EDITVIEWS_FIELD'           ;
// 3. Scripts. 
import L10n                                            from '../../../scripts/L10n'                    ;
import Sql                                             from '../../../scripts/Sql'                     ;
import Security                                        from '../../../scripts/Security'                ;
import Credentials                                     from '../../../scripts/Credentials'             ;
import SplendidCache                                   from '../../../scripts/SplendidCache'           ;
import { StartsWith, base64ArrayBuffer }               from '../../../scripts/utility'                 ;
import { Crm_Config }                                  from '../../..//scripts/Crm'                    ;
import { Admin_GetReactState }                         from '../../../scripts/Application'             ;
import { AuthenticatedMethod, LoginRedirect, GetUserProfile } from '../../../scripts/Login'                   ;
import SplendidDynamic_EditView                        from '../../../scripts/SplendidDynamic_EditView';
import { EditView_LoadLayout }                         from '../../../scripts/EditView'                ;
import { ListView_LoadTable }                          from '../../../scripts/ListView'                ;
import { UpdateAdminConfig }                           from '../../../scripts/ModuleUpdate'            ;
import { CreateSplendidRequest, GetSplendidResult }    from '../../../scripts/SplendidRequest'         ;
import { Application_ClearStore }                      from '../../../scripts/Application'             ;
// 4. Components and Views. 
import ErrorComponent                                  from '../../../components/ErrorComponent'       ;

interface IAdminConfigViewProps extends RouteComponentProps<any>
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

interface IAdminConfigViewState
{
	item              : any;
	layoutCompany     : EDITVIEWS_FIELD[];
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
class ConfiguratorAdminWizard extends React.Component<IAdminConfigViewProps, IAdminConfigViewState>
{
	private _isMounted = false;
	private headerButtons = React.createRef<HeaderButtons>();

	constructor(props: IAdminConfigViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor');
		Credentials.SetViewMode('AdminWizard');
		// 02/24/2021 Paul.  This view may be hard-coded in the routes table, so we may need to pull the MODULE_NAME from the URL. 
		let MODULE_NAME: string = props.MODULE_NAME;
		let EDIT_NAME  : string = 'Configurator.AdminWizard.Company';
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
		this.state =
		{
			item              : {},
			layoutCompany     : null,
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
		const { MODULE_NAME, EDIT_NAME } = this.state;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				// 07/06/2020 Paul.  Admin_GetReactState will also generate an exception, but catch anyway. 
				if ( !(Security.IS_ADMIN() || SplendidCache.AdminUserAccess(MODULE_NAME, 'edit') >= 0) )
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
				document.title = L10n.Term('Administration.LBL_CONFIGURE_UPDATER');
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

	async componentDidUpdate(prevProps: IAdminConfigViewProps)
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
				const { item, layoutCompany, EDIT_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + DETAIL_NAME, item);
				if ( layoutCompany != null && error == null )
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
		const { rowDefaultSearch } = this.props;
		try
		{
			const layoutCompany: EDITVIEWS_FIELD[] = EditView_LoadLayout('Configurator.AdminWizard.Company');
			const layoutLocale : EDITVIEWS_FIELD[] = EditView_LoadLayout('Configurator.AdminWizard.Locale' );
			const layoutMail   : EDITVIEWS_FIELD[] = EditView_LoadLayout('Configurator.AdminWizard.Mail'   );
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load Company', layoutCompany);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load Locale ', layoutLocale );
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load Mail   ', layoutMail   );
			if ( this._isMounted )
			{
				// 06/19/2018 Paul.  Always clear the item when setting the layout. 
				this.setState(
				{
					layoutCompany,
					layoutLocale ,
					layoutMail   ,
					item         : (rowDefaultSearch ? rowDefaultSearch : null),
					editedItem   : null
				}, () =>
				{
					if ( this.props.onLayoutLoaded )
					{
						this.props.onLayoutLoaded();
					}
				});
				await this.LoadItem(layoutCompany, layoutLocale, layoutMail);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private EditViewFields = (layout: EDITVIEWS_FIELD[]) =>
	{
		var arrSelectFields = new Array();
		if ( layout != null && layout.length > 0 )
		{
			for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				var lay = layout[nLayoutIndex];
				// 04/15/2021 Paul.  Ignore non-data field types, such as Header. 
				if ( lay.DATA_FIELD != null )
				{
					let DATA_FIELD = lay.DATA_FIELD;
					arrSelectFields.push('\'' + DATA_FIELD + '\'');
				}
			}
		}
		return arrSelectFields;
	}

	private LoadItem = async (layoutCompany: EDITVIEWS_FIELD[], layoutLocale: EDITVIEWS_FIELD[], layoutMail: EDITVIEWS_FIELD[]) =>
	{
		try
		{
			let arrSelectFields: string[] = [];
			arrSelectFields = arrSelectFields.concat(this.EditViewFields(layoutCompany), this.EditViewFields(layoutLocale), this.EditViewFields(layoutMail));
			if ( arrSelectFields.length == 0 )
			{
				arrSelectFields.push('company_name'        );
				arrSelectFields.push('header_logo_image'   );
				arrSelectFields.push('header_logo_width'   );
				arrSelectFields.push('header_logo_height'  );
				arrSelectFields.push('header_logo_style'   );
				arrSelectFields.push('header_home_image'   );
				arrSelectFields.push('Configurator.LastRun')
				arrSelectFields.push('default_language'    );
				arrSelectFields.push('default_date_format' );
				arrSelectFields.push('default_time_format' );
				arrSelectFields.push('default_currency'    );
				arrSelectFields.push('default_timezone'    );
				arrSelectFields.push('fromname'            );
				arrSelectFields.push('fromaddress'         );
				arrSelectFields.push('smtpserver'          );
				arrSelectFields.push('smtpport'            );
				arrSelectFields.push('smtpuser'            );
				arrSelectFields.push('smtppass'            );
				arrSelectFields.push('smtpauth_req'        );
				arrSelectFields.push('smtpssl'             );
			}
			let sSelectFields: string = arrSelectFields.join(',');
			let sFILTER = 'NAME in (' + sSelectFields + ')';
			let rows = await ListView_LoadTable('CONFIG', 'NAME', 'asc', 'NAME,VALUE', sFILTER, null, true);
			let item = {};
			if ( rows.results )
			{
				for ( let i = 0; i < rows.results.length; i++ )
				{
					let row = rows.results[i];
					item[row.NAME] = row.VALUE;
				}
			}
			let LANGUAGE_LIST   : string[] = L10n.GetList('Languages' );
			let CURRENCY_LIST   : string[] = L10n.GetList('Currencies');
			let DATE_FORMAT_LIST: string[] = L10n.GetList('DateFormat.' + item['default_language']);
			let TIME_FORMAT_LIST: string[] = L10n.GetList('TimeFormat.' + item['default_language']);
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
					row = {};
					if ( nWizardPanel == 0 )
					{
						row['company_name'        ] = item['company_name'        ];
						row['header_logo_image'   ] = item['header_logo_image'   ];
						row['header_logo_width'   ] = item['header_logo_width'   ];
						row['header_logo_height'  ] = item['header_logo_height'  ];
						row['header_logo_style'   ] = item['header_logo_style'   ];
						row['header_home_image'   ] = item['header_home_image'   ];
						row['Configurator.LastRun'] = (new Date()).toISOString();
						SplendidCache.SetConfigValue('Configurator.LastRun', row['Configurator.LastRun']);
					}
					else if ( nWizardPanel == 1 )
					{
						row['default_language'    ] = item['default_language'    ];
						row['default_date_format' ] = item['default_date_format' ];
						row['default_time_format' ] = item['default_time_format' ];
						row['default_currency'    ] = item['default_currency'    ];
						row['default_timezone'    ] = item['default_timezone'    ];
					}
					else if ( nWizardPanel == 2 )
					{
						row['fromname'            ] = item['fromname'            ];
						row['fromaddress'         ] = item['fromaddress'         ];
						row['smtpserver'          ] = item['smtpserver'          ];
						row['smtpport'            ] = item['smtpport'            ];
						row['smtpuser'            ] = item['smtpuser'            ];
						row['smtppass'            ] = item['smtppass'            ];
						row['smtpauth_req'        ] = item['smtpauth_req'        ];
						row['smtpssl'             ] = item['smtpssl'             ];
					}
					try
					{
						if ( this.headerButtons.current != null )
						{
							this.headerButtons.current.Busy();
						}
						await UpdateAdminConfig(row);
						// 10/31/2021 Paul.  Instead of reloading state now, just let next login take care of it. 
						if ( nWizardPanel == 0 )
						{
							await Application_ClearStore();
						}
						
						if ( nWizardPanel < 2 )
						{
							nWizardPanel++;
							this.setState({ nWizardPanel });
						}
						if ( sCommandName == 'Continue' )
						{
							// 11/03/2021 Paul.  Amdin Wizard is never used on app first start, so we never need to go to User Wizard. 
							//let user: any = await GetUserProfile();
							//if ( Sql.IsEmptyString(user.ORIGINAL_TIMEZONE_ID) )
							//{
							//	history.push(`/Reset/Users/Wizard`);
							//}
							//else
							{
								history.push(`/Reload/Home`);
							}
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
				case 'Cancel':
				{
					history.push(`/Reset/Administration`);
					break;
				}
				case 'Skip':
				{
					// 10/30/2021 Paul.  If the user wants to skip, then we will not present the admin config again. 
					row = {};
					row['Configurator.LastRun'] = (new Date()).toISOString();
					SplendidCache.SetConfigValue('Configurator.LastRun', row['Configurator.LastRun']);
					try
					{
						if ( this.headerButtons.current != null )
						{
							this.headerButtons.current.Busy();
						}
						await UpdateAdminConfig(row);
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
				case "SmtpType.Gmail":
				{
					item['smtpserver'          ]= "smtp.gmail.com";
					item['smtpport'            ] = "587";
					item['smtpauth_req'        ] = true;
					item['smtpssl'             ] = true;
					this.setState({ item, error: '' });
					break;
				}
				case "SmtpType.Yahoo":
				{
					item['smtpserver'          ] = "plus.smtp.mail.yahoo.com";
					item['smtpport'            ] = "465";
					item['smtpauth_req'        ] = true;
					item['smtpssl'             ] = true;
					this.setState({ item, error: '' });
					break;
				}
				case "SmtpType.Other":
				{
					item['smtpserver'          ] = '';
					item['smtpport'            ] = "25";
					this.setState({ item, error: '' });
					break;
				}
				case "Smtp.Clear":
				{
					item['smtpserver'          ] = '';
					item['smtpport'            ] = "25";
					item['smtpauth_req'        ] = true;
					item['smtpssl'             ] = false;
					item['smtpuser'            ] = '';
					item['smtppass'            ] = '';
					this.setState({ item, error: '' });
					break;
				}
				case "Smtp.Test":
				{
					try
					{
						let obj: any = {};
						obj.from_addr         = item['fromaddress'  ];
						obj.from_name         = item['fromname'     ];
						obj.mail_sendtype     = item['mail_sendtype'];
						obj.mail_smtpuser     = item['smtpuser'     ];
						obj.mail_smtppass     = item['smtppass'     ];
						obj.mail_smtpserver   = item['smtpserver'   ];
						obj.mail_smtpport     = item['smtpport'     ];
						obj.mail_smtpauth_req = item['smtpauth_req' ];
						obj.mail_smtpssl      = item['smtpssl'      ];
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
				default:
				{
					this.setState( {error: 'Unknown command: ' + sCommandName} );
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
		if ( sFIELD_NAME == 'default_language' )
		{
			let DATE_FORMAT_LIST: string[] = L10n.GetList('DateFormat.' + item['default_language']);
			let TIME_FORMAT_LIST: string[] = L10n.GetList('TimeFormat.' + item['default_language']);
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

	private _onCHECKBOX_Changed = (e, sFIELD_NAME: string): void =>
	{
		let { item } = this.state;
		if ( item == null )
			item = {};
		item[sFIELD_NAME] = e.target.checked;
		this.setState({ item, error: '' });
	}

	private _onLogoImageChange = (e): void =>
	{
		let { item } = this.state;
		if ( item == null )
			item = {};
		try
		{
			let FILE_NAME: string = e.target.value;
			let files = e.target.files;
			if ( files.length > 0 )
			{
				let file = files[0];
				let nMaxSize: number = Crm_Config.ToInteger('upload_maxsize');
				if ( file.size > nMaxSize )
				{
					let error = 'uploaded file was too big: max filesize: ' + nMaxSize;
					this.setState({ error });
				}
				else
				{
					// http://www.javascripture.com/FileReader
					let reader = new FileReader();
					reader.onload = () =>
					{
						let arrayBuffer = reader.result;
						let DATA: string = base64ArrayBuffer(arrayBuffer);
						item['header_logo_image'] = 'data:' + file.type + ';base64,' + DATA;
						this.setState({ item, error: '' });
					};
					reader.readAsArrayBuffer(file);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onLogoImageChange', error);
		}
	}

	private _onHomeImageChange = (e): void =>
	{
		let { item } = this.state;
		if ( item == null )
			item = {};
		try
		{
			let FILE_NAME: string = e.target.value;
			let files = e.target.files;
			if ( files.length > 0 )
			{
				let file = files[0];
				let nMaxSize: number = Crm_Config.ToInteger('upload_maxsize');
				if ( file.size > nMaxSize )
				{
					let error = 'uploaded file was too big: max filesize: ' + nMaxSize;
					this.setState({ error });
				}
				else
				{
					// http://www.javascripture.com/FileReader
					let reader = new FileReader();
					reader.onload = () =>
					{
						let arrayBuffer = reader.result;
						let DATA: string = base64ArrayBuffer(arrayBuffer);
						item['header_home_image'] = 'data:' + file.type + ';base64,' + DATA;
						this.setState({ item, error: '' });
					};
					reader.readAsArrayBuffer(file);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onHomeImageChange', error);
		}
	}

	public render()
	{
		const { item, layoutCompany, error } = this.state;
		const { nWizardPanel } = this.state;
		if ( layoutCompany == null || item == null )
		{
			return null;
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.remder');
		if ( SplendidCache.IsInitialized )
		{
			Credentials.sUSER_THEME;
			const currentItem = Object.assign({}, this.state.item);
			let header_logo_width : number = Sql.ToInteger(currentItem['header_logo_width' ]);
			if ( header_logo_width == 0 )
				header_logo_width = 60;
			let header_logo_height: number = Sql.ToInteger(currentItem['header_logo_height']);
			if ( header_logo_height == 0 )
				header_logo_height = 207;
			let header_logo_image: string = Sql.ToString(currentItem['header_logo_image']);
			if ( !Sql.IsEmptyString(header_logo_image) )
			{
				// 10/28/2021 Paul.  Allow logo to be stored in config table as base64. 
				if ( !StartsWith(header_logo_image, 'data:image/') && !StartsWith(header_logo_image, 'http') && !StartsWith(header_logo_image, '~/') )
				{
					header_logo_image = '~/Include/images/' + header_logo_image;
				}
			}
			else
			{
				header_logo_image = '~/Include/images/SplendidCRM_Logo.gif';
			}
			if ( StartsWith(header_logo_image, '~/') )
			{
				header_logo_image = header_logo_image.replace('~/', Credentials.RemoteServer);
			}
			let header_home_image: string = Sql.ToString(currentItem['header_home_image']);
			if ( !Sql.IsEmptyString(header_home_image) )
			{
				if ( !StartsWith(header_home_image, 'data:image/') && !StartsWith(header_home_image, 'http') && !StartsWith(header_home_image, '~/') )
				{
					header_home_image = '~/Include/images/' + header_home_image;
				}
			}
			else
			{
				header_home_image = '~/Include/images/SplendidCRM_Icon.gif';
			}
			if ( StartsWith(header_home_image, '~/') )
			{
				header_home_image = header_home_image.replace('~/', Credentials.RemoteServer);
			}
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
											<span>{ L10n.Term("Configurator.LBL_WIZARD_SYSTEM_TITLE") }</span>
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
														<span>{ L10n.Term("Configurator.LBL_COMPANY_NAME") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="company_name" size={ 40 } value={ currentItem['company_name'] } onChange={ (e) => this._onTEXT_Changed(e, 'company_name') } />
													</td>
												</tr>
												<tr>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("Configurator.LBL_HEADER_LOGO_IMAGE") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="header_logo_image" size={ 40 } value={ currentItem['header_logo_image'] } onChange={ (e) => this._onTEXT_Changed(e, 'header_logo_image') } />
													</td>
													<td style={ {width: '50%'} }>
														<input type="file" id="UPLOAD_LOGO_IMAGE" size={ 30 } onChange={ this._onLogoImageChange } />
													</td>
												</tr>
												<tr>
													<td>
														<span>{ L10n.Term("Configurator.LBL_HEADER_LOGO_WIDTH") }</span>
													</td>
													<td>
														<input id="header_logo_width" size={ 10 } value={ currentItem['header_logo_width'] } onChange={ (e) => this._onTEXT_Changed(e, 'header_logo_width') } />
													</td>
													<td rowSpan={ 3 }>
														<img id="imgCompanyLogo"
															style={ {height: (header_logo_height.toString() + 'px'), width: (header_logo_width.toString() + 'px'), borderWidth: '0px', marginLeft: '10px'} }
															title={ currentItem['company_name'] }
															src={ header_logo_image }
														/>
													</td>
												</tr>
												<tr>
													<td>
														<span>{ L10n.Term("Configurator.LBL_HEADER_LOGO_HEIGHT") }</span>
													</td>
													<td>
														<input id="header_logo_height" size={ 10 } value={ currentItem['header_logo_height'] } onChange={ (e) => this._onTEXT_Changed(e, 'header_logo_height') } />
													</td>
												</tr>
												<tr>
													<td>
														<span>{ L10n.Term("Configurator.LBL_HEADER_LOGO_STYLE") }</span>
													</td>
													<td>
														<input id="header_logo_style" size={ 20 } value={ currentItem['header_logo_style'] } onChange={ (e) => this._onTEXT_Changed(e, 'header_logo_style') } />
													</td>
												</tr>
												<tr>
													<td>
														<span>{ L10n.Term("Configurator.LBL_ATLANTIC_HOME_IMAGE") }</span>
													</td>
													<td>
														<input id="header_home_image" size={ 40 } value={ currentItem['header_home_image'] } onChange={ (e) => this._onTEXT_Changed(e, 'header_home_image') } />
													</td>
													<td style={ {width: '50%'} }>
														<input type="file" id="UPLOAD_ATLANTIC_IMAGE" size={ 30 } onChange={ this._onHomeImageChange } />
													</td>
												</tr>
												<tr>
													<td>&nbsp;</td>
													<td>&nbsp;</td>
													<td rowSpan={ 3 }>
														<img
															id="imgAtlanticLogo"
															className='otherHome'
															style={ {borderWidth: '0px'} }
															src={ header_home_image }
														/>
													</td>
												</tr>
												<tr>
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
											<span>{ L10n.Term("Configurator.LBL_WIZARD_LOCALE_TITLE") }</span>
										</h2>
									</td>
								</tr>
								<tr style={ {height: '10px'} }>
									<td style={ {paddingLeft: '20px'} }>
										<span style={ {fontStyle: 'italic'} }>{ L10n.Term("Configurator.LBL_WIZARD_LOCALE_DESC") }</span>
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
														<select id="default_language" value={ currentItem['default_language'] } onChange={ (e) => this._onTEXT_Changed(e, 'default_language') }>
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
														<select id="default_currency" value={ currentItem['default_currency'] } onChange={ (e) => this._onTEXT_Changed(e, 'default_currency') }>
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
														<select id="default_date_format" value={ currentItem['default_date_format'] } onChange={ (e) => this._onTEXT_Changed(e, 'default_date_format') }>
														{ this.state.DATE_FORMAT_LIST
														? this.state.DATE_FORMAT_LIST.map((item, index) => 
															{
																return (<option id={ 'DATE_FORMAT' + ' _' + index.toString() } key={ 'DATE_FORMAT' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('DateFormat.' + currentItem['default_language'], item) }</option>);
															})
														: null
														}
														</select>
													</td>
													<td>
														<span>{ L10n.Term("Users.LBL_TIME_FORMAT") }</span>
													</td>
													<td>
														<select id="TIME_FORMAT" value={ currentItem['default_time_format'] } onChange={ (e) => this._onTEXT_Changed(e, 'default_time_format') }>
														{ this.state.TIME_FORMAT_LIST
														? this.state.TIME_FORMAT_LIST.map((item, index) => 
															{
																return (<option id={ 'TIME_FORMAT' + ' _' + index.toString() } key={ 'TIME_FORMAT' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('TimeFormat.' + currentItem['default_language'], item) }</option>);
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
														<select id="default_timezone" value={ currentItem['default_timezone'] } onChange={ (e) => this._onTEXT_Changed(e, 'default_timezone') }>
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
											<span>{ L10n.Term("Configurator.LBL_MAIL_SMTP_SETTINGS") }</span>
										</h2>
									</td>
								</tr>
								<tr style={ {height: '10px'} }>
									<td style={ {paddingLeft: '20px'} }>
										<span style={ {fontStyle: 'italic'} }>{ L10n.Term("Configurator.LBL_WIZARD_SMTP_DESC") }</span>
									</td>
								</tr>
								<tr>
									<td valign="top" style={ {paddingLeft: '20px'} }>
										<table cellPadding={ 2 }>
											<tbody>
												<tr>
													<td colSpan={ 4 }>
														<button onClick={ (e) => { e.preventDefault(); this.Page_Command('SmtpType.Gmail', null); } } className="button">{ "  " + L10n.Term("Configurator.LBL_SMTPTYPE_GMAIL") + "  " }</button>
														&nbsp;
														<button onClick={ (e) => { e.preventDefault(); this.Page_Command('SmtpType.Yahoo', null); } } className="button">{ "  " + L10n.Term("Configurator.LBL_SMTPTYPE_YAHOO") + "  " }</button>
														&nbsp;
														<button onClick={ (e) => { e.preventDefault(); this.Page_Command('SmtpType.Other', null); } } className="button">{ "  " + L10n.Term("Configurator.LBL_SMTPTYPE_OTHER") + "  " }</button>
													</td>
												</tr>
												<tr>
													<td style={ {width: '15%'} } valign="top">
														<span>{ L10n.Term("EmailMan.LBL_NOTIFY_FROMNAME") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="fromname" size={ 25 } maxLength={ 128 } value={ currentItem['fromname'] } onChange={ (e) => this._onTEXT_Changed(e, 'fromname') } />
													</td>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("EmailMan.LBL_NOTIFY_FROMADDRESS") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="fromaddress" size={ 25 } maxLength={ 128 } value={ currentItem['fromaddress'] } onChange={ (e) => this._onTEXT_Changed(e, 'fromaddress') } />
													</td>
												</tr>
												<tr>
													<td style={ {width: '15%'} } valign="top">
														<span>{ L10n.Term("EmailMan.LBL_MAIL_SMTPSERVER") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="smtpserver" size={ 25 } maxLength={ 64 } value={ currentItem['smtpserver'] } onChange={ (e) => this._onTEXT_Changed(e, 'smtpserver') } />
													</td>
													<td style={ {width: '15%'} }>
														<span>{ L10n.Term("EmailMan.LBL_MAIL_SMTPPORT") }</span>
													</td>
													<td style={ {width: '35%'} }>
														<input id="smtpport" size={ 10 } maxLength={ 10 } value={ currentItem['smtpport'] } onChange={ (e) => this._onTEXT_Changed(e, 'smtpport') } />
													</td>
												</tr>
												<tr>
													<td>
														<span>{ L10n.Term("EmailMan.LBL_MAIL_SMTPAUTH_REQ") }</span>
													</td>
													<td>
														<input type="checkbox" id="smtpauth_req" className="checkbox" checked={ Sql.ToBoolean(currentItem['smtpauth_req']) } onChange={ (e) => this._onCHECKBOX_Changed(e, 'smtpauth_req') } />
													</td>
													<td>
														<span>{ L10n.Term("EmailMan.LBL_MAIL_SMTPSSL") }</span>
													</td>
													<td>
														<input type="checkbox" id="smtpssl" className="checkbox" checked={ Sql.ToBoolean(currentItem['smtpssl']) } onChange={ (e) => this._onCHECKBOX_Changed(e, 'smtpssl') } />
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
														<button onClick={ (e) => { e.preventDefault(); this.Page_Command('Smtp.Clear', null); } } className="button">{ "  " + L10n.Term("Configurator.LBL_CLEAR_BUTTON_TITLE") + "  " }</button>
														&nbsp;
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

export default withRouter(ConfiguratorAdminWizard);

