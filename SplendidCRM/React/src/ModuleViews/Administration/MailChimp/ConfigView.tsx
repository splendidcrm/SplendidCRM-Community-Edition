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
import React from 'react';
import qs from 'query-string';
import { RouteComponentProps }                      from '../Router5'                         ;
import { Modal }                                    from 'react-bootstrap'                          ;
import { observer }                                 from 'mobx-react'                               ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'           ;
// 2. Store and Types. 
import { EditComponent }                            from '../../../types/EditComponent'             ;
import { HeaderButtons }                            from '../../../types/HeaderButtons'             ;
// 3. Scripts. 
import L10n                                         from '../../../scripts/L10n'                    ;
import Sql                                          from '../../../scripts/Sql'                     ;
import Credentials                                  from '../../../scripts/Credentials'             ;
import SplendidCache                                from '../../../scripts/SplendidCache'           ;
import { Admin_GetReactState }                      from '../../../scripts/Application'             ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'                   ;
import SplendidDynamic_EditView                     from '../../../scripts/SplendidDynamic_EditView';
import { EditView_LoadLayout }                      from '../../../scripts/EditView'                ;
import { ListView_LoadTable }                       from '../../../scripts/ListView'                ;
import { UpdateAdminConfig }                        from '../../../scripts/ModuleUpdate'            ;
import { Crm_Config }                               from '../../../scripts/Crm'                     ;
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'         ;
// 4. Components and Views. 
import ErrorComponent                               from '../../../components/ErrorComponent'       ;
import DynamicButtons                               from '../../../components/DynamicButtons'       ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';

const MODULE_NAME: string = 'MailChimp';

interface IMailChimpConfigViewProps extends RouteComponentProps<any>
{
	callback?         : Function;
	rowDefaultSearch? : any;
	onLayoutLoaded?   : Function;
	onSubmit?         : Function;
}

interface IMailChimpConfigViewState
{
	item                : any;
	layout              : any;
	EDIT_NAME           : string;
	BUTTON_NAME         : string;
	MODULE_TITLE        : string;
	DUPLICATE           : boolean;
	LAST_DATE_MODIFIED  : Date;
	editedItem         : any;
	dependents          : Record<string, Array<any>>;
	error?              : any;
}

@observer
export default class MailChimpConfigView extends React.Component<IMailChimpConfigViewProps, IMailChimpConfigViewState>
{
	private _isMounted = false;
	private refMap: Record<string, React.RefObject<EditComponent<any, any>>>;
	private dynamicButtonsTop    = React.createRef<HeaderButtons>();

	public get data (): any
	{
		let row: any = {};
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		if ( nInvalidFields == 0 )
		{
		}
		return row;
	}

	public validate(): boolean
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.Validate(this.refMap);
		return (nInvalidFields == 0);
	}

	public clear(): void
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		SplendidDynamic_EditView.Clear(this.refMap);
		if ( this._isMounted )
		{
			this.setState({ editedItem: {} });
		}
	}

	constructor(props: IMailChimpConfigViewProps)
	{
		super(props);
		let EDIT_NAME   : string = MODULE_NAME + '.ConfigView';
		let BUTTON_NAME : string = MODULE_NAME + '.ConfigView';
		let MODULE_TITLE: string = L10n.Term(MODULE_NAME + '.LBL_MAILCHIMP_SETTINGS');
		Credentials.SetViewMode('AdministrationView');
		this.state =
		{
			item                : (props.rowDefaultSearch ? props.rowDefaultSearch : null),
			layout              : null,
			EDIT_NAME           ,
			BUTTON_NAME         ,
			MODULE_TITLE        ,
			DUPLICATE           : false,
			LAST_DATE_MODIFIED  : null,
			editedItem         : null,
			dependents          : {},
			error               : null,
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
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', status);
			if ( status == 1 )
			{
				// 10/27/2019 Paul.  In case of single page refresh, we need to make sure that the AdminMenu has been loaded. 
				if ( SplendidCache.AdminMenu == null )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount Admin_GetReactState');
					await Admin_GetReactState(this.constructor.name + '.componentDidMount');
				}
				if ( !Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(true);
				}
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

	async componentDidUpdate(prevProps: IMailChimpConfigViewProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}
	
	private load = async () =>
	{
		const { rowDefaultSearch } = this.props;
		const { EDIT_NAME } = this.state;
		try
		{
			let layout = EditView_LoadLayout(EDIT_NAME);
			if ( this._isMounted )
			{
				// 06/19/2018 Paul.  Always clear the item when setting the layout. 
				this.setState(
				{
					layout: layout,
					item: (rowDefaultSearch ? rowDefaultSearch : null),
					editedItem: null
				}, () =>
				{
					if ( this.props.onLayoutLoaded )
					{
						this.props.onLayoutLoaded();
					}
				});
				await this.LoadItem(layout);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private EditViewFields = (layout: any) =>
	{
		let arrSelectFields = new Array();
		if ( layout.length > 0 )
		{
			for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay = layout[nLayoutIndex];
				let DATA_FIELD = lay.DATA_FIELD;
				arrSelectFields.push('\'' + DATA_FIELD + '\'');
			}
		}
		return arrSelectFields.join(',');
	}

	private LoadItem = async (layout: any) =>
	{
		try
		{
			let sFILTER = 'NAME in (' + this.EditViewFields(layout) + ')';
			const rows = await ListView_LoadTable('CONFIG', 'NAME', 'asc', 'NAME,VALUE', sFILTER, null, true);
			let item = {};
			if ( rows.results )
			{
				for ( let i = 0; i < rows.results.length; i++ )
				{
					let row = rows.results[i];
					item[row.NAME] = row.VALUE;
				}
			}
			if ( this._isMounted )
			{
				this.setState({ layout, item, editedItem: item });
				
				let queryParams: any = qs.parse(location.search);
				if ( !Sql.IsEmptyString(queryParams['error']) )
				{
					this.setState({ error: queryParams['error'] });
				}
				else if ( !Sql.IsEmptyString(queryParams['code']) )
				{
					let code: string = queryParams['code'];
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem code', AUTHORIZATION_CODE);
					let redirect_url: string = window.location.origin + window.location.pathname;
					let obj: any =
					{
						code        ,
						redirect_url,
					};
					// 11/09/2019 Paul.  We cannot use ADAL because we are using the response_type=code style of authentication (confidential) that ADAL does not support. 
					let sBody: string = JSON.stringify(obj);
					let res  = await CreateSplendidRequest('Administration/MailChimp/Rest.svc/GetAccessToken', 'POST', 'application/octet-stream', sBody);
					let json = await GetSplendidResult(res);
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Save token', json);
					item['MailChimp.OAuthAccessToken'] = json.d;
					SplendidDynamic_EditView.SetRefValue(this.refMap, 'MailChimp.OAuthAccessToken', json.d);
					this.setState({ item, editedItem: item, error: L10n.Term('OAuth.LBL_TEST_SUCCESSFUL') });
					//this.props.history.replace('/Administration/MailChimp/ConfigView');
					this.props.history.replace('ConfigView');
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
			this.setState({ error });
		}
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange()' + DATA_FIELD, DATA_VALUE);
		let { layout } = this.state;
		let item = this.state.editedItem;
		if ( item == null )
			item = {};
		item[DATA_FIELD] = DATA_VALUE;
		this.setState({ editedItem: item });
	}

	private _createDependency = (DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string): void =>
	{
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			dependents[PARENT_FIELD].push( {DATA_FIELD, PROPERTY_NAME} );
		}
		else
		{
			dependents[PARENT_FIELD] = [ {DATA_FIELD, PROPERTY_NAME} ]
		}
		if ( this._isMounted )
		{
			this.setState({ dependents: dependents });
		}
	}

	private _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate()' + PARENT_FIELD, DATA_VALUE);
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			let dependentIds = dependents[PARENT_FIELD];
			for ( let i = 0; i < dependentIds.length; i++ )
			{
				let ref = this.refMap[dependentIds[i].DATA_FIELD];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, DATA_VALUE, dependentIds[i].PROPERTY_NAME, item);
				}
			}
		}
	}

	// 06/15/2018 Paul.  The SearchView will register for the onSubmit event. 
	private _onSubmit = (): void =>
	{
		try
		{
			if ( this.props.onSubmit )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit');
				this.props.onSubmit();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', error);
			this.setState({ error });
		}
	}

	private Save = async() =>
	{
		const { history } = this.props;
		let row: any = {};
		// 08/27/2019 Paul.  Keep the old to handle password issues. 
		//let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		Object.keys(this.refMap).map((key) =>
		{
			let ref = this.refMap[key];
			let data = ref.current.data;
			// 07/05/2019 Paul.  Data may be an array of key/value pairs.  This is true of TeamSelect and UserSelect. 
			if ( data )
			{
				if ( Array.isArray(data) )
				{
					for ( let i = 0; i < data.length; i++  )
					{
						if ( data[i].key )
						{
							row[data[i].key] = data[i].value;
						}
					}
				}
				else if ( data.key )
				{
					// 04/08/2019 Paul.  Password fields that have not been modified will not be sent. 
					if ( data.value != Sql.sEMPTY_PASSWORD )
					{
						row[data.key] = data.value;
					}
					if ( data.files && Array.isArray(data.files) )
					{
						if ( row.Files === undefined )
						{
							row.Files = new Array();
						}
						for ( let i = 0; i < data.files.length; i++ )
						{
							row.Files.push(data.files[i]);
						}
					}
				}
			}
		});
		try
		{
			if ( this.dynamicButtonsTop.current != null )
			{
				this.dynamicButtonsTop.current.EnableButton('Save', false);
			}
			await UpdateAdminConfig(row);
			return true;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Save', error);
			if ( this.dynamicButtonsTop.current != null )
			{
				this.dynamicButtonsTop.current.EnableButton('Save', true);
			}
			if ( this._isMounted )
			{
				this.setState({ error });
			}
			return false;
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Save':
				{
					this.Save();
					history.push('/Administration');
					break;
				}
				case 'Authorize':
				{
					// 11/09/2019 Paul.  Save before authorize as the OAuth protocol will navigate away. 
					if ( this.Save() )
					{
						if ( this.dynamicButtonsTop.current != null )
						{
							this.dynamicButtonsTop.current.EnableButton(sCommandName, false);
						}
						try
						{
							let item: any = this.data;
							let OAUTH_CLIENT_ID : string = item['MailChimp.ClientID' ];
							let sREDIRECT_URL   : string = (window.location.origin + window.location.pathname);
							let authenticateUrl : string = 'https://login.mailchimp.com/oauth2/authorize?response_type=code&client_id=' + OAUTH_CLIENT_ID + '&redirect_uri=' + sREDIRECT_URL;
							window.location.href = authenticateUrl;
						}
						catch(error)
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
							if ( this._isMounted )
							{
								this.setState({ error });
							}
						}
						if ( this.dynamicButtonsTop.current != null )
						{
							this.dynamicButtonsTop.current.EnableButton(sCommandName, true);
						}
					}
					break;
				}
				case 'Test':
				{
					let sBody: string = JSON.stringify(this.data);
					CreateSplendidRequest('Administration/' + MODULE_NAME + '/Rest.svc/Test', 'POST', 'application/octet-stream', sBody).then((res) =>
					{
						GetSplendidResult(res).then((json) =>
						{
							//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Test', json);
							this.setState( {error: json.d} );
						})
						.catch((error) =>
						{
							this.setState({ error });
						});
					})
					.catch((error) =>
					{
						this.setState({ error });
					});
					break;
				}
				case 'Cancel':
				{
					history.push(`/Reset/Administration`);
					break;
				}
				default:
					break;
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	public render()
	{
		const { callback } = this.props;
		const { item, layout, BUTTON_NAME, MODULE_TITLE, error } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render: ' + EDIT_NAME + ' ' + BUTTON_NAME, layout, item);
		if ( layout == null || item == null )
		{
			return null;
		}
		this.refMap = {};
		let onSubmit = (this.props.onSubmit ? this._onSubmit : null);
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu && layout && BUTTON_NAME )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<div>
				<ErrorComponent error={error} />
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, ButtonStyle: 'EditHeader', VIEW_NAME: BUTTON_NAME, row: item, Page_Command: this.Page_Command, showButtons: true, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.dynamicButtonsTop })
				: null
				}
				<div id={!!callback ? null : "content"}>
					{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, callback, this._createDependency, null, this._onChange, this._onUpdate, onSubmit, 'tabForm', this.Page_Command) }
					<br />
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

