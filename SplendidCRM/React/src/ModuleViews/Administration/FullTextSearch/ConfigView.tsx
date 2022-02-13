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
import { RouteComponentProps, withRouter }          from 'react-router-dom'                         ;
import { observer }                                 from 'mobx-react'                               ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'           ;
// 2. Store and Types. 
import { EditComponent }                            from '../../../types/EditComponent'             ;
import { HeaderButtons }                            from '../../../types/HeaderButtons'             ;
// 3. Scripts. 
import L10n                                         from '../../../scripts/L10n'                    ;
import Sql                                          from '../../../scripts/Sql'                     ;
import Security                                     from '../../../scripts/Security'                ;
import Credentials                                  from '../../../scripts/Credentials'             ;
import SplendidCache                                from '../../../scripts/SplendidCache'           ;
import { Admin_GetReactState }                      from '../../../scripts/Application'             ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'                   ;
import { ListView_LoadTable }                       from '../../../scripts/ListView'                ;
import { formatDate }                               from '../../../scripts/Formatting'              ;
import { AdminProcedure }                           from '../../../scripts/ModuleUpdate'            ;
// 4. Components and Views. 
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';

interface IAdminConfigViewProps extends RouteComponentProps<any>
{
	MODULE_NAME       : string;
	ID?               : string;
	LAYOUT_NAME?      : string;
	MODULE_TITLE?     : string;
	callback?         : Function;
	rowDefaultSearch? : any;
	onLayoutLoaded?   : Function;
	onSubmit?         : Function;
}

interface IAdminConfigViewState
{
	item              : any;
	layout            : any;
	MODULE_NAME       : string;
	EDIT_NAME         : string;
	BUTTON_NAME       : string;
	MODULE_TITLE      : string;
	DUPLICATE         : boolean;
	LAST_DATE_MODIFIED: Date;
	editedItem       : any;
	dependents        : Record<string, Array<any>>;
	error?            : any;
}

@observer
export default class FullTextSearchConfigView extends React.Component<IAdminConfigViewProps, IAdminConfigViewState>
{
	private _isMounted = false;
	private headerButtons = React.createRef<HeaderButtons>();

	constructor(props: IAdminConfigViewProps)
	{
		super(props);
		let MODULE_NAME: string = props.MODULE_NAME;
		if ( Sql.IsEmptyString(MODULE_NAME) )
		{
			let arrPathname: string[] = props.location.pathname.split('/');
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

		let EDIT_NAME: string = MODULE_NAME + '.ConfigView';
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}
		let BUTTON_NAME: string = EDIT_NAME;
		let layoutButtons = SplendidCache.DynamicButtons(BUTTON_NAME);
		if ( layoutButtons == null )
		{
			if ( SplendidCache.DynamicButtons(MODULE_NAME + '.EditView') )
				BUTTON_NAME = MODULE_NAME + '.EditView';
		}
		let MODULE_TITLE: string = L10n.Term('FullTextSearch.LBL_FULLTEXTSEARCH_SETTINGS');
		if ( !Sql.IsEmptyString(props.MODULE_TITLE) )
		{
			MODULE_TITLE = props.MODULE_TITLE;
		}
		Credentials.SetViewMode('AdminConfigView');
		this.state =
		{
			item              : (props.rowDefaultSearch ? props.rowDefaultSearch : null),
			layout            : null,
			MODULE_NAME       ,
			EDIT_NAME         ,
			BUTTON_NAME       ,
			MODULE_TITLE      ,
			DUPLICATE         : false,
			LAST_DATE_MODIFIED: null,
			editedItem       : null,
			dependents        : {},
			error             : null
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
				if ( !(Security.IS_ADMIN() || SplendidCache.AdminUserAccess(MODULE_NAME, 'edit') >= 0) )
				{
					throw(L10n.Term('.LBL_INSUFFICIENT_ACCESS'));
				}
				if ( SplendidCache.AdminMenu == null )
				{
					await Admin_GetReactState(this.constructor.name + '.componentDidMount');
					let BUTTON_NAME: string = MODULE_NAME + '.ConfigView';
					let layoutButtons = SplendidCache.DynamicButtons(BUTTON_NAME);
					if ( layoutButtons == null )
					{
						if ( SplendidCache.DynamicButtons(MODULE_NAME + '.EditView') )
							BUTTON_NAME = MODULE_NAME + '.EditView';
					}
					if ( BUTTON_NAME != this.state.BUTTON_NAME )
					{
						this.setState({ BUTTON_NAME })
					}
				}
				if ( !Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(true);
				}
				document.title = L10n.ListTerm('moduleList', 'Administration');
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
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
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
		const { MODULE_NAME, EDIT_NAME } = this.state;
		try
		{
			const layout = {};
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

	private LoadItem = async (layout: any) =>
	{
		try
		{
			let rows = await ListView_LoadTable('vwFULLTEXT_Properties', 'SQL_SERVER_VERSION', 'asc', '*', null, null, true);
			let item = {};
			if ( rows.results )
			{
				if ( rows.results.length > 0 )
				{
					let row = rows.results[0];
					item['SQL_SERVER_VERSION'     ] = Sql.ToString (row["SQL_SERVER_VERSION"  ]);
					item['SQL_SERVER_EDITION'     ] = Sql.ToString (row["SQL_SERVER_EDITION"  ]);
					item['FULLTEXT_INSTALLED'     ] = Sql.ToBoolean(row["FULLTEXT_INSTALLED"  ]);
					item['FULLTEXT_CATALOG_EXISTS'] = Sql.ToInteger(row["FULLTEXT_CATALOG_ID" ]);
					item['OFFICE_SUPPORTED'       ] = Sql.ToBoolean(row["OFFICE_DOCUMENT_TYPE"]);
					item['PDF_SUPPORTED'          ] = Sql.ToBoolean(row["PDF_DOCUMENT_TYPE"   ]);
					item['FULLTEXT_SUPPORTED'     ] = item['SQL_SERVER_VERSION'].indexOf('SQL Server') >= 0;
				}
			}
			rows = await ListView_LoadTable('vwFULLTEXT_DOCUMENT_TYPES', 'DOCUMENT_TYPE', 'asc', 'DOCUMENT_TYPE', null, null, true);
			if ( rows.results )
			{
				let DOCUMENT_TYPES: string = '';
				for ( let i: number = 0; i < rows.results.length; i++ )
				{
					let row = rows.results[i];
					DOCUMENT_TYPES =+ Sql.ToString (row["DOCUMENT_TYPE"]) + '\r\n';
				}
				item['DOCUMENT_TYPES'] = DOCUMENT_TYPES;
			}
			rows = await ListView_LoadTable('vwFULLTEXT_INDEXES', 'TABLE_NAME', 'asc', 'TABLE_NAME', null, null, true);
			if ( rows.results )
			{
				let INDEXED_TABLES: string = '';
				for ( let i: number = 0; i < rows.results.length; i++ )
				{
					let row = rows.results[i];
					INDEXED_TABLES =+ Sql.ToString (row["TABLE_NAME"]) + '\r\n';
				}
				item['INDEXED_TABLES'] = INDEXED_TABLES;
			}
			rows = await ListView_LoadTable('vwFULLTEXT_CATALOGS', 'LAST_POPULATION_DATE', 'asc', '*', null, null, true);
			if ( rows.results )
			{
				if ( rows.results.length > 0 )
				{
					let row = rows.results[0];
					item['POPULATE_STATUS'     ] = Sql.ToString (row["POPULATE_STATUS"     ]);
					item['POPULATION_COUNT'    ] = Sql.ToString (row["ITEM_COUNT"          ]);
					item['LAST_POPULATION_DATE'] = formatDate(row["LAST_POPULATION_DATE"], Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
				}
			}
			if ( this._isMounted )
			{
				this.setState({ item });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
			this.setState({ error });
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { history } = this.props;
		const { MODULE_NAME } = this.state;
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Enable':
				case 'Disable':
				case 'RebuildIndex':
				{
					let data: any =
					{
						OPERATION: sCommandName,
					};
					await AdminProcedure('spFULLTEXT_ConfigCatalog', data);
					await this.LoadItem(this.state.layout);
					break;
				}
				case 'Test':
				{
					history.push(`/Reset/Administration/FullTextSearch/ListView`);
					break;
				}
				case 'Cancel':
				{
					history.push(`/Reset/Administration`);
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

	private _onButtonsLoaded = async () =>
	{
		const { item } = this.state;
		if ( this.headerButtons.current != null )
		{
			let bIsFullTextInstalled: boolean =  Sql.ToBoolean    (item["FULLTEXT_INSTALLED"]);
			let bIndexedTables      : boolean = !Sql.IsEmptyString(item["INDEXED_TABLES"    ]);
			this.headerButtons.current.ShowButton("Enable"      , !bIndexedTables && bIsFullTextInstalled);
			this.headerButtons.current.ShowButton("Disable"     ,  bIndexedTables);
			this.headerButtons.current.ShowButton("Test"        ,  bIndexedTables);
			this.headerButtons.current.ShowButton("RebuildIndex",  bIndexedTables);
		}
	}

	public render()
	{
		const { callback } = this.props;
		const { item, layout, MODULE_NAME, EDIT_NAME, BUTTON_NAME, MODULE_TITLE, error } = this.state;
		if ( layout == null || item == null )
		{
			return null;
		}
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu && layout && BUTTON_NAME )
		{
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<div>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: BUTTON_NAME, row: item, Page_Command: this.Page_Command, showButtons: true, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<div id={!!callback ? null : "content"}>
					<table className="tabForm" cellSpacing={ 1 } cellPadding={ 0 } style={ {width: '100%', border: 'none'} }>
						<tr>
							<td className="dataLabel" valign="top" style={ {width: '30%'} }><span>{ L10n.Term("FullTextSearch.LBL_FULLTEXT_SUPPORTED") }</span></td>
							<td className="dataLabel" valign="top" style={ {width: '20%'} }><span id="FULLTEXT_SUPPORTED">{ Sql.ToBoolean(item['FULLTEXT_SUPPORTED']) ? L10n.Term('.LBL_YES') : L10n.Term('.LBL_NO') }</span></td>
							<td className="dataField" valign="middle" colSpan={ 2 }>
								<span id="SUPPORTED_INSTRUCTIONS" dangerouslySetInnerHTML={ { __html: L10n.Term("FullTextSearch.LBL_SUPPORTED_INSTRUCTIONS") } }></span><br />
								<span id="SQL_SERVER_VERSION">{ item['SQL_SERVER_VERSION'] }</span><br />
								<span id="SQL_SERVER_EDITION">{ item['SQL_SERVER_EDITION'] }</span><br />
							</td>
						</tr>
						<tr>
							<td className="dataLabel" valign="top" style={ {width: '30%'} }><span>{ L10n.Term("FullTextSearch.LBL_FULLTEXT_INSTALLED") }</span></td>
							<td className="dataLabel" valign="top" style={ {width: '20%'} }><span id="FULLTEXT_INSTALLED">{ Sql.ToBoolean(item['FULLTEXT_INSTALLED']) ? L10n.Term('.LBL_YES') : L10n.Term('.LBL_NO') }</span></td>
							<td className="dataField" valign="middle" colSpan={ 2 }><span id="INSTALLED_INSTRUCTIONS" dangerouslySetInnerHTML={ { __html: L10n.Term("FullTextSearch.LBL_INSTALLED_INSTRUCTIONS") } }></span></td>
						</tr><tr>
							<td className="dataLabel" valign="top" style={ {width: '30%'} }><span>{ L10n.Term("FullTextSearch.LBL_OFFICE_SUPPORTED") }</span></td>
							<td className="dataLabel" valign="top" style={ {width: '20%'} }><span id="OFFICE_SUPPORTED">{ Sql.ToBoolean(item['OFFICE_SUPPORTED']) ? L10n.Term('.LBL_YES') : L10n.Term('.LBL_NO') }</span></td>
							<td className="dataField" valign="middle" colSpan={ 2 }><span id="OFFICE_INSTRUCTIONS" dangerouslySetInnerHTML={ { __html: L10n.Term("FullTextSearch.LBL_OFFICE_INSTRUCTIONS") } }></span></td>
						</tr><tr>
							<td className="dataLabel" valign="top" style={ {width: '30%'} }><span>{ L10n.Term("FullTextSearch.LBL_PDF_SUPPORTED") }</span></td>
							<td className="dataLabel" valign="top" style={ {width: '20%'} }><span id="PDF_SUPPORTED">{ Sql.ToBoolean(item['PDF_SUPPORTED']) ? L10n.Term('.LBL_YES') : L10n.Term('.LBL_NO') }</span></td>
							<td className="dataField" valign="middle" colSpan={ 2 }><span id="PDF_INSTRUCTIONS" dangerouslySetInnerHTML={ { __html: L10n.Term("FullTextSearch.LBL_PDF_INSTRUCTIONS") } }></span></td>
						</tr><tr>
							<td className="dataLabel" valign="top" style={ {width: '30%'} }><span>{ L10n.Term("FullTextSearch.LBL_FULLTEXT_CATALOG_EXISTS") }</span></td>
							<td className="dataLabel" valign="top" style={ {width: '20%'} }><span id="FULLTEXT_CATALOG_EXISTS">{ Sql.ToInteger(item['FULLTEXT_CATALOG_ID']) > 0 ? L10n.Term('.LBL_YES') : L10n.Term('.LBL_NO') }</span></td>
							<td className="dataField" valign="middle" colSpan={ 2 }><span id="CATALOG_INSTRUCTIONS" dangerouslySetInnerHTML={ { __html: L10n.Term("FullTextSearch.LBL_CATALOG_INSTRUCTIONS") } }></span></td>
						</tr><tr>
							<td className="dataLabel" valign="top" style={ {width: '30%'} }><span>{ L10n.Term("FullTextSearch.LBL_SUPPORTED_DOCUMENT_TYPES") }</span></td>
							<td className="dataLabel" valign="top" style={ {width: '20%'} }><textarea rows={ 6 } cols={ 10 } readOnly={ true } id="DOCUMENT_TYPES">{ item['DOCUMENT_TYPES'] }</textarea></td>
							<td className="dataLabel" valign="top" style={ {width: '30%'} }><span>{ L10n.Term("FullTextSearch.LBL_INDEXED_TABLES")}</span></td>
							<td className="dataLabel" valign="top" style={ {width: '20%'} }><textarea rows={ 6 } cols={ 30 } readOnly={ true } id="INDEXED_TABLES">{ item['INDEXED_TABLES'] }</textarea></td>
						</tr><tr>
							<td className="dataLabel" valign="top" style={ {width: '30%'} }><span>{ L10n.Term("FullTextSearch.LBL_POPULATION_STATUS") }</span></td>
							<td className="dataLabel" valign="top" style={ {width: '20%'} }><span id="POPULATION_STATUS">{ item['POPULATION_STATUS'] }</span></td>
							<td className="dataLabel" valign="top" style={ {width: '30%'} }><span>{ L10n.Term("FullTextSearch.LBL_POPULATION_COUNT") }</span></td>
							<td className="dataLabel" valign="top" style={ {width: '20%'} }><span id="POPULATION_COUNT">{ item['POPULATION_COUNT'] }</span></td>
						</tr><tr>
							<td className="dataLabel" valign="top" style={ {width: '30%'} }><span>{ L10n.Term("FullTextSearch.LBL_LAST_POPULATION_DATE") }</span></td>
							<td className="dataLabel" valign="top" style={ {width: '20%'} }><span id="LAST_POPULATION_DATE">{ item['LAST_POPULATION_DATE'] }</span></td>
							<td className="dataLabel" valign="top" style={ {width: '30%'} }></td>
							<td className="dataField" valign="top" style={ {width: '20%'} }></td>
						</tr>
					</table>
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

