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
import { RouteComponentProps, withRouter }            from 'react-router-dom'                             ;
import { observer }                                   from 'mobx-react'                                   ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome'               ;
// 2. Store and Types. 
import ACL_FIELD_ACCESS                               from '../../../types/ACL_FIELD_ACCESS'              ;
import { EditComponent }                              from '../../../types/EditComponent'                 ;
import { HeaderButtons }                              from '../../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                            from '../../../scripts/Sql'                         ;
import L10n                                           from '../../../scripts/L10n'                        ;
import Security                                       from '../../../scripts/Security'                    ;
import Credentials                                    from '../../../scripts/Credentials'                 ;
import SplendidCache                                  from '../../../scripts/SplendidCache'               ;
import SplendidDynamic_DetailView                     from '../../../scripts/SplendidDynamic_DetailView'  ;
import { Crm_Config }                                 from '../../../scripts/Crm'                         ;
import { Admin_GetReactState }                        from '../../../scripts/Application'                 ;
import { AuthenticatedMethod, LoginRedirect }         from '../../../scripts/Login'                       ;
import { DetailView_LoadItem, DetailView_LoadLayout } from '../../../scripts/DetailView'                  ;
import { CreateSplendidRequest, GetSplendidResult }   from '../../../scripts/SplendidRequest'             ;
// 4. Components and Views. 
import ErrorComponent                                 from '../../../components/ErrorComponent'           ;
import DumpSQL                                        from '../../../components/DumpSQL'                  ;
import DynamicButtons                                 from '../../../components/DynamicButtons'           ;
import HeaderButtonsFactory                           from '../../../ThemeComponents/HeaderButtonsFactory';

const MODULE_NAME: string = 'ACLRoles';

interface IAdminEditViewProps extends RouteComponentProps<any>
{
	ID                : string;
	LAYOUT_NAME?      : string;
	callback?         : any;
	rowDefaultSearch? : any;
	onLayoutLoaded?   : any;
	onSubmit?         : any;
	DuplicateID?      : string;
}

interface IAdminEditViewState
{
	__total             : number;
	__sql               : string;
	vwMain              : any;
	vwACL_FIELDS_ALIASES: any;
	item                : any;
	layout              : any;
	ACL_MODULES         : any[];
	SELECTED_MODULE     : string;
	EDIT_NAME           : string;
	DETAIL_NAME         : string;
	DUPLICATE           : boolean;
	LAST_DATE_MODIFIED  : Date;
	SUB_TITLE           : any;
	editedItem          : any;
	dependents          : Record<string, Array<any>>;
	error?              : any;
}

@observer
export default class ACLRolesFieldSecurity extends React.Component<IAdminEditViewProps, IAdminEditViewState>
{
	private _isMounted   : boolean = false;
	private refMap       : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons        = React.createRef<HeaderButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private PERMISSION_LIST_VALUES = [];

	constructor(props: IAdminEditViewProps)
	{
		super(props);
		let EDIT_NAME   = MODULE_NAME + '.EditView';
		let DETAIL_NAME = MODULE_NAME + '.DetailView';
		
		this.PERMISSION_LIST_VALUES .push(ACL_FIELD_ACCESS.NOT_SET               );
		this.PERMISSION_LIST_VALUES .push(ACL_FIELD_ACCESS.READ_WRITE            );
		this.PERMISSION_LIST_VALUES .push(ACL_FIELD_ACCESS.READ_OWNER_WRITE      );
		this.PERMISSION_LIST_VALUES .push(ACL_FIELD_ACCESS.READ_ONLY             );
		this.PERMISSION_LIST_VALUES .push(ACL_FIELD_ACCESS.OWNER_READ_OWNER_WRITE);
		this.PERMISSION_LIST_VALUES .push(ACL_FIELD_ACCESS.NONE                  );

		this.state =
		{
			__total             : 0,
			__sql               : null,
			vwMain              : [],
			vwACL_FIELDS_ALIASES: [],
			item                : (props.rowDefaultSearch ? props.rowDefaultSearch : null),
			layout              : null,
			ACL_MODULES         : [],
			SELECTED_MODULE     : '',
			EDIT_NAME           ,
			DETAIL_NAME         ,
			DUPLICATE           : false,
			LAST_DATE_MODIFIED  : null,
			SUB_TITLE           : null,
			editedItem          : null,
			dependents          : {},
			error               : null
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

	async componentDidUpdate(prevProps: IAdminEditViewProps)
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
		const { ID, rowDefaultSearch, DuplicateID } = this.props;
		const { DETAIL_NAME } = this.state;
		try
		{
			const layout = DetailView_LoadLayout(DETAIL_NAME);
			if ( this._isMounted )
			{
				let res  = await CreateSplendidRequest('Administration/Rest.svc/GetAclAccessByModule', 'GET');
				let json = await GetSplendidResult(res);
				let ACL_MODULES = [];
				for ( let i: number = 0; i < json.d.results.length; i++ )
				{
					let row: any = json.d.results[i];
					if ( !Sql.ToBoolean(row['IS_ADMIN']) && row['MODULE_NAME'] != 'Teams' )
					{
						ACL_MODULES.push(row);
					}
				}

				res  = await CreateSplendidRequest('Administration/Rest.svc/GetAclFieldAliases', 'GET');
				json = await GetSplendidResult(res);
				let vwACL_FIELDS_ALIASES: any[]  = json.d.results;
				
				res  = await CreateSplendidRequest('Administration/Rest.svc/GetAclAccessFieldSecurity?ROLE_ID=' + ID + '&MODULE_NAME=', 'GET');
				json = await GetSplendidResult(res);
				let __total          : number = Sql.ToInteger(json.__total);
				let __sql            : string = Sql.ToString (json.__sql  );
				let vwMain           : any[]  = json.d.results;
				this.setState(
				{
					__total             ,
					__sql               ,
					vwMain              ,
					vwACL_FIELDS_ALIASES,
					ACL_MODULES         ,
					layout              : layout,
					item                : (rowDefaultSearch ? rowDefaultSearch : null),
					editedItem          : null
				}, () =>
				{
					if ( this.props.onLayoutLoaded )
					{
						this.props.onLayoutLoaded();
					}
				});
				if ( !Sql.IsEmptyString(DuplicateID) )
				{
					await this.LoadItem(MODULE_NAME, DuplicateID);
				}
				else
				{
					await this.LoadItem(MODULE_NAME, ID);
				}
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
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await DetailView_LoadItem(sMODULE_NAME, sID, true, false);
				let item: any = d.results;
				let LAST_DATE_MODIFIED: Date = null;
				// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
				if ( item != null && item['DATE_MODIFIED'] !== undefined )
				{
					LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
				}
				if ( this._isMounted )
				{
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState({ item, SUB_TITLE, LAST_DATE_MODIFIED });
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.setState({ error });
			}
		}
	}

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, history, location } = this.props;
		const { vwMain, SELECTED_MODULE, LAST_DATE_MODIFIED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Save':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				{
					let isDuplicate = location.pathname.includes('Duplicate');
					row = {
						ID: isDuplicate ? null : ID
					};
					if ( !Sql.IsEmptyString(SELECTED_MODULE) )
					{
						row.ROLE_ID      = ID             ;
						row.MODULE_NAME  = SELECTED_MODULE;
						row.AccessRights = vwMain         ;
						if ( LAST_DATE_MODIFIED != null )
						{
							row['LAST_DATE_MODIFIED'] = LAST_DATE_MODIFIED;
						}
						if ( sCommandName == 'SaveDuplicate' || sCommandName == 'SaveConcurrency' )
						{
							row[sCommandName] = true;
						}
						try
						{
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.Busy();
							}
							let sBody: string = JSON.stringify(row);
							let res = await CreateSplendidRequest('Administration/Rest.svc/UpdateAclAccessFieldSecurity', 'POST', 'application/octet-stream', sBody);
							let json = await GetSplendidResult(res);
							history.push(`/Reset/Administration/${MODULE_NAME}/View/` + ID);
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
								if ( error.message.includes('.ERR_DUPLICATE_EXCEPTION') )
								{
									if ( this.headerButtons.current != null )
									{
										this.headerButtons.current.ShowButton('SaveDuplicate', true);
									}
									this.setState( {error: L10n.Term(error.message) } );
								}
								else if ( error.message.includes('.ERR_CONCURRENCY_OVERRIDE') )
								{
									if ( this.headerButtons.current != null )
									{
										this.headerButtons.current.ShowButton('SaveConcurrency', true);
									}
									this.setState( {error: L10n.Term(error.message) } );
								}
								else
								{
									this.setState({ error });
								}
							}
						}
					}
					break;
				}
				case 'Cancel':
				{
					if ( Sql.IsEmptyString(ID) )
						history.push(`/Reset/Administration/${MODULE_NAME}/List`);
					else
						history.push(`/Reset/Administration/${MODULE_NAME}/View/${ID}`);
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
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private NormalizeAccessValue = (sACCESS_TYPE: string, nACCESS: number) =>
	{
		if ( sACCESS_TYPE == 'access' )
		{
			// 04/25/2006 Paul.  Be flexible with the values, so don't compare directly to 89 and -98.
			if ( nACCESS > 0 )
				nACCESS = 89;
			else
				nACCESS = -98;
		}
		else if ( sACCESS_TYPE == 'permission' )
		{
			if      ( nACCESS >ACL_FIELD_ACCESS.READ_OWNER_WRITE      ) nACCESS = ACL_FIELD_ACCESS.READ_WRITE            ;
			else if ( nACCESS >ACL_FIELD_ACCESS.READ_ONLY             ) nACCESS = ACL_FIELD_ACCESS.READ_OWNER_WRITE      ;
			else if ( nACCESS >ACL_FIELD_ACCESS.OWNER_READ_OWNER_WRITE) nACCESS = ACL_FIELD_ACCESS.READ_ONLY             ;
			else if ( nACCESS >ACL_FIELD_ACCESS.OWNER_READ_ONLY       ) nACCESS = ACL_FIELD_ACCESS.OWNER_READ_OWNER_WRITE;
			else if ( nACCESS >ACL_FIELD_ACCESS.NOT_SET               ) nACCESS = ACL_FIELD_ACCESS.OWNER_READ_ONLY       ;
			else if ( nACCESS >ACL_FIELD_ACCESS.NONE                  ) nACCESS = ACL_FIELD_ACCESS.NOT_SET               ;
			else                                                        nACCESS = ACL_FIELD_ACCESS.NONE                  ;
		}
		return nACCESS;
	}

	private AccessClassName = (sACCESS_TYPE: string, nACCESS: number) =>
	{
		let sClass: string = 'aclNormal';
		if ( sACCESS_TYPE == 'access' )
		{
			if ( nACCESS > 0 )
				sClass = 'aclEnabled';
			else
				sClass = 'aclDisabled';
		}
		else if ( sACCESS_TYPE == 'permission' )
		{
			nACCESS = this.NormalizeAccessValue(sACCESS_TYPE, nACCESS);
			if      ( nACCESS == ACL_FIELD_ACCESS.READ_WRITE             ) sClass = "aclAll"   ;
			else if ( nACCESS == ACL_FIELD_ACCESS.READ_OWNER_WRITE       ) sClass = "aclOwner" ;
			else if ( nACCESS == ACL_FIELD_ACCESS.READ_ONLY              ) sClass = "aclOwner" ;
			else if ( nACCESS == ACL_FIELD_ACCESS.OWNER_READ_OWNER_WRITE ) sClass = "aclOwner" ;
			else if ( nACCESS == ACL_FIELD_ACCESS.OWNER_READ_ONLY        ) sClass = "aclOwner" ;
			else if ( nACCESS == ACL_FIELD_ACCESS.NOT_SET                ) sClass = "";
			else if ( nACCESS == ACL_FIELD_ACCESS.NONE                   ) sClass = "aclNone"  ;
		}
		return sClass;
	}

	private AccessLabel = (sACCESS_TYPE: string, nACCESS: number) =>
	{
		let sACCESS: string = '';
		if ( sACCESS_TYPE == 'access' )
		{
			if ( nACCESS > 0 )
				sACCESS = 'ACLActions.LBL_ACCESS_ENABLED';
			else
				sACCESS = 'ACLActions.LBL_ACCESS_DISABLED';
		}
		else if ( sACCESS_TYPE == 'permission' )
		{
			nACCESS = this.NormalizeAccessValue(sACCESS_TYPE, nACCESS);
			if      ( nACCESS == ACL_FIELD_ACCESS.READ_WRITE             ) sACCESS = "ACLActions.LBL_FIELD_ACCESS_READ_WRITE"            ;
			else if ( nACCESS == ACL_FIELD_ACCESS.READ_OWNER_WRITE       ) sACCESS = "ACLActions.LBL_FIELD_ACCESS_READ_OWNER_WRITE"      ;
			else if ( nACCESS == ACL_FIELD_ACCESS.READ_ONLY              ) sACCESS = "ACLActions.LBL_FIELD_ACCESS_READ_ONLY"             ;
			else if ( nACCESS == ACL_FIELD_ACCESS.OWNER_READ_OWNER_WRITE ) sACCESS = "ACLActions.LBL_FIELD_ACCESS_OWNER_READ_OWNER_WRITE";
			else if ( nACCESS == ACL_FIELD_ACCESS.OWNER_READ_ONLY        ) sACCESS = "ACLActions.LBL_FIELD_ACCESS_OWNER_READ"            ;
			else if ( nACCESS == ACL_FIELD_ACCESS.NOT_SET                ) sACCESS = "ACLActions.LBL_FIELD_ACCESS_NOT_SET"               ;
			else if ( nACCESS == ACL_FIELD_ACCESS.NONE                   ) sACCESS = "ACLActions.LBL_FIELD_ACCESS_NONE"                  ;
			else  sACCESS = 'not found ' + nACCESS.toString();
		}
		return L10n.Term(sACCESS);
	}

	private RenderColumnAlias = (item: any) =>
	{
		const { vwACL_FIELDS_ALIASES } = this.state;
		let sFIELD_NAME  : string = Sql.ToString(item['FIELD_NAME' ]);
		let sMODULE_NAME : string = Sql.ToString(item['MODULE_NAME']);

		let arrALIASES: string[] = [];
		if ( vwACL_FIELDS_ALIASES != null )
		{
			for ( let i: number = 0; i < vwACL_FIELDS_ALIASES.length; i++ )
			{
				let row: any = vwACL_FIELDS_ALIASES[i];
				if ( row['NAME'] == sFIELD_NAME )
				{
					if ( row['MODULE_NAME'] == null || row['MODULE_NAME'] == sMODULE_NAME )
					{
						arrALIASES.push(row['ALIAS_NAME']);
					}
				}
			}
		}
		if ( arrALIASES.length > 0 )
		{
			return (<React.Fragment>
				<div>{ sFIELD_NAME }</div>
				{
					arrALIASES.map((item, index) =>
					{
						return (<div>{ item }</div>);
					})
				}
			</React.Fragment>);
		}
		else
		{
			return sFIELD_NAME;
		}
	}

	private RenderFieldAlias = (item: any) =>
	{
		const { vwACL_FIELDS_ALIASES } = this.state;
		let sFIELD_NAME  : string = Sql.ToString(item['FIELD_NAME' ]);
		let sMODULE_NAME : string = Sql.ToString(item['MODULE_NAME']);
		let sDISPLAY_NAME: string = L10n.Term(L10n.BuildTermName(sMODULE_NAME, sFIELD_NAME));
		let arrALIASES: string[] = [];
		if ( vwACL_FIELDS_ALIASES != null )
		{
			for ( let i: number = 0; i < vwACL_FIELDS_ALIASES.length; i++ )
			{
				let rowAlias: any = vwACL_FIELDS_ALIASES[i];
				if ( rowAlias['NAME'] == sFIELD_NAME )
				{
					if ( rowAlias['MODULE_NAME'] == null || rowAlias['MODULE_NAME'] == sMODULE_NAME )
					{
						let sALIAS_FIELD_NAME : string = Sql.ToString(rowAlias['ALIAS_NAME'       ]);
						let sALIAS_MODULE_NAME: string = Sql.ToString(rowAlias['ALIAS_MODULE_NAME']);
						let sALIAS_NAME       : string= L10n.Term(L10n.BuildTermName(sALIAS_MODULE_NAME, sALIAS_FIELD_NAME));
						arrALIASES.push(sALIAS_NAME );
					}
				}
			}
		}
		if ( arrALIASES.length > 0 )
		{
			return (<React.Fragment>
				<div>{ sDISPLAY_NAME }</div>
				{
					arrALIASES.map((item, index) =>
					{
						return (<div>{ item }</div>);
					})
				}
			</React.Fragment>);
		}
		else
		{
			return sDISPLAY_NAME;
		}
	}

	protected _onSelectChange = (item: any, event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let { vwMain } = this.state;
		let value = Sql.ToInteger(event.target.value);
		item['ACLACCESS'] = value;
		item['Editing'  ] = false;
		this.setState({ vwMain });
	}

	private RenderAccessType = (item: any) =>
	{
		let name: string = 'permission';
		let sFIELD_NAME  : string = Sql.ToString(item['FIELD_NAME']);
		if ( Sql.ToBoolean(item['Editing']) )
		{
			return <select
				onChange={ (event: React.ChangeEvent<HTMLSelectElement>) => this._onSelectChange(item, event) }
				value={ this.NormalizeAccessValue(name, Sql.ToInteger(item['ACLACCESS'])) }
				className={ this.AccessClassName(name, Sql.ToInteger(item['ACLACCESS'])) }
			>
				{
					this.PERMISSION_LIST_VALUES.map((item, index) => 
					{
						let ENUM_NAME: string = ACL_FIELD_ACCESS.GetName(name, item);
						return (<option value={ item }>{ L10n.Term('ACLActions.LBL_FIELD_ACCESS_' + ENUM_NAME) }</option>);
					})
				}
			</select>;
		}
		else
		{
			return (<div
				className={ this.AccessClassName(name, Sql.ToInteger(item['ACLACCESS'])) }
			>
				{ L10n.Term(this.AccessLabel(name, Sql.ToInteger(item['ACLACCESS']))) }
			</div>);
		}
	}

	protected _onDoubleClickAdmin = (name: string, item: any) =>
	{
		let { vwMain, SELECTED_MODULE } = this.state;
		if ( !Sql.IsEmptyString(SELECTED_MODULE) )
		{
			item['Editing'] = !Sql.ToBoolean(item['Editing']);
			this.setState({ vwMain });
		}
	}

	private _onModuleChange = async (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { ID } = this.props;
		try
		{
			let SELECTED_MODULE: string = event.target.value;
			let res  = await CreateSplendidRequest('Administration/Rest.svc/GetAclAccessFieldSecurity?ROLE_ID=' + ID + '&MODULE_NAME=' + SELECTED_MODULE, 'GET');
			let json = await GetSplendidResult(res);
			let __total          : number = Sql.ToInteger(json.__total);
			let __sql            : string = Sql.ToString (json.__sql  );
			let vwMain           : any[]  = json.d.results;
			this.setState(
			{
				__total        ,
				__sql          ,
				vwMain         ,
				SELECTED_MODULE,
			}, () =>
			{
				this._onButtonsLoaded();
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private _onButtonsLoaded = () =>
	{
		const { SELECTED_MODULE } = this.state;
		if ( this.headerButtons.current != null )
		{
			this.headerButtons.current.ShowButton('Save'  , !Sql.IsEmptyString(SELECTED_MODULE));
			this.headerButtons.current.ShowButton('Cancel', !Sql.IsEmptyString(SELECTED_MODULE));
		}
		if ( this.dynamicButtonsBottom.current != null )
		{
			this.dynamicButtonsBottom.current.ShowButton('Save'  , !Sql.IsEmptyString(SELECTED_MODULE));
			this.dynamicButtonsBottom.current.ShowButton('Cancel', !Sql.IsEmptyString(SELECTED_MODULE));
		}
	}

	public render()
	{
		const { ID, DuplicateID, callback } = this.props;
		const { vwMain, SELECTED_MODULE, ACL_MODULES, item, layout, EDIT_NAME, SUB_TITLE, error } = this.state;
		const { __total, __sql } = this.state;
		if ( layout == null || (item == null && (!Sql.IsEmptyString(ID) || !Sql.IsEmptyString(DuplicateID))) )
		{
			if ( error )
			{
				return (<ErrorComponent error={error} />);
			}
			else
			{
				return null;
			}
		}
		this.refMap = {};
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<div>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: true, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<div id={!!callback ? null : "content"}>
					<div>
						{ L10n.ListTerm('moduleList', 'Modules') }&nbsp;&nbsp;
						<select onChange={ this._onModuleChange } value={ SELECTED_MODULE }>
							<option value=''></option>
							{
								ACL_MODULES.map((item, index) => 
								{
								let MODULE_NAME : string = item['MODULE_NAME' ];
								let DISPLAY_NAME: string = L10n.Term(item['DISPLAY_NAME']);
								return (<option value={ MODULE_NAME }>{ DISPLAY_NAME }</option>);
								})
							}
						</select>
						{ SplendidDynamic_DetailView.AppendDetailViewFields(item, layout, this.refMap, 'tabDetailView', null, this.Page_Command) }
					</div>
					<br />
					<b>{ L10n.Term('ACLRoles.LBL_EDIT_VIEW_DIRECTIONS') }</b>
					<br />
					<DumpSQL SQL={ __sql } />
					{ vwMain
					? <table id='ctlAccessView_grdACL' className='tabDetailView' cellSpacing={ 1 } cellPadding={ 0 } style={ {width: '100%', border: 'collapse', lineHeight: '15px', borderSpacing: '4px'} }>
						<tr className='listViewThS1' style={ {lineHeight: '15px'} }>
							{ Sql.IsEmptyString(SELECTED_MODULE)
							? <td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLRoles.LBL_LIST_MODULE_NAME'  ) }</td>
							: null
							}
							{ Sql.IsEmptyString(SELECTED_MODULE)
							? <td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLRoles.LBL_LIST_VIEW_NAME'    ) }</td>
							: null
							}
							<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLRoles.LBL_LIST_COLUMN_NAME'  ) }</td>
							<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLRoles.LBL_LIST_FIELD_NAME'   ) }</td>
							<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_FIELD_PERMISSION') }</td>
						</tr>
						{
							vwMain.map((item, index) => 
							{
								return (
						<tr className='tabDetailViewDF'>
							{ Sql.IsEmptyString(SELECTED_MODULE)
							? <td className='tabDetailViewDL' style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ item['MODULE_NAME'] }</td>
							: null
							}
							{ Sql.IsEmptyString(SELECTED_MODULE)
							? <td className='tabDetailViewDL' style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ item['VIEW_NAME'  ] }</td>
							: null
							}
							<td className='tabDetailViewDL' style={ {textAlign: 'right', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderColumnAlias( item) }</td>
							<td className='tabDetailViewDL' style={ {textAlign: 'right', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderFieldAlias ( item) }</td>
							<td onDoubleClick={ () =>  this._onDoubleClickAdmin('permission' , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderAccessType ( item) }</td>
						</tr>
								);
							})
						}
					</table>
					: null
					}
					<br />
				</div>
				{ !callback && headerButtons
				? <DynamicButtons
					ButtonStyle="EditHeader"
					VIEW_NAME={ EDIT_NAME }
					row={ item }
					Page_Command={ this.Page_Command }
					onLayoutLoaded={ this._onButtonsLoaded }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.dynamicButtonsBottom }
				/>
				: null
				}
				<br />
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

