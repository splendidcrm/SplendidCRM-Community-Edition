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
import posed from 'react-pose';
import { RouteComponentProps }                      from 'react-router-dom'               ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome' ;
import { Appear }                                   from 'react-lifecycle-appear'         ;
// 2. Store and Types. 
import ACL_ACCESS                                   from '../types/ACL_ACCESS'            ;
import { SubPanelHeaderButtons }                    from '../types/SubPanelHeaderButtons' ;
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'                 ;
import L10n                                         from '../scripts/L10n'                ;
import Credentials                                  from '../scripts/Credentials'         ;
import SplendidCache                                from '../scripts/SplendidCache'       ;
import { Crm_Config }                               from '../scripts/Crm'                 ;
import { AuthenticatedMethod }                      from '../scripts/Login'               ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest'     ;
// 4. Components and Views. 
import DumpSQL                                      from '../components/DumpSQL'          ;
import ErrorComponent                               from '../components/ErrorComponent'   ;
import SubPanelButtonsFactory                       from '../ThemeComponents/SubPanelButtonsFactory';

const CONTROL_VIEW_NAME: string = 'AccessView';

const Content = posed.div(
{
	open:
	{
		height: '100%'
	},
	closed:
	{
		height: 0
	}
});

interface IAccessViewProps
{
	ROLE_ID?         : string;
	USER_ID?         : string;
	EnableACLEditing?: boolean;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data) => void;
}

interface IAccessViewState
{
	vwMain     : any[];
	vwMainAdmin: any[];
	__total    : number;
	__sql      : string;
	error?     : any;
	open       : boolean;
	subPanelVisible: boolean;
}

export default class AccessView extends React.Component<IAccessViewProps, IAccessViewState>
{
	private _isMounted = false;
	private headerButtons        = React.createRef<SubPanelHeaderButtons>();
	private ACCESS_LIST_VALUES   = [];
	private IMPORT_LIST_VALUES   = [];
	private ARCHIVE_LIST_VALUES  = [];
	private OTHERS_LIST_VALUES   = [];

	public get data (): any
	{
		const { vwMain, vwMainAdmin } = this.state;
		let row: any = [];
		for ( let i: number = 0; i < vwMain.length; i++ )
		{
			row.push(vwMain[i]);
		}
		if ( vwMainAdmin != null )
		{
			for ( let i: number = 0; i < vwMainAdmin.length; i++ )
			{
				row.push(vwMainAdmin[i]);
			}
		}
		return row;
	}

	constructor(props: IAccessViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props.MODULE_NAME);
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		let open       : boolean = (localStorage.getItem(CONTROL_VIEW_NAME) == 'true') || props.EnableACLEditing || this.props.isPrecompile;

		this.ACCESS_LIST_VALUES .push(ACL_ACCESS.ENABLED );
		this.ACCESS_LIST_VALUES .push(ACL_ACCESS.DISABLED);

		this.IMPORT_LIST_VALUES .push(ACL_ACCESS.ALL     );
		this.IMPORT_LIST_VALUES .push(ACL_ACCESS.NONE    );

		this.ARCHIVE_LIST_VALUES.push(ACL_ACCESS.ARCHIVE );
		this.ARCHIVE_LIST_VALUES.push(ACL_ACCESS.VIEW    );
		this.ARCHIVE_LIST_VALUES.push(ACL_ACCESS.OWNER   );
		this.ARCHIVE_LIST_VALUES.push(ACL_ACCESS.NONE    );

		this.OTHERS_LIST_VALUES .push(ACL_ACCESS.ALL     );
		this.OTHERS_LIST_VALUES .push(ACL_ACCESS.OWNER   );
		this.OTHERS_LIST_VALUES .push(ACL_ACCESS.NONE    );

		this.state =
		{
			vwMain     : null,
			vwMainAdmin: null,
			__total    : 0,
			__sql      : null,
			error      : null,
			open       ,
			// 08/31/2021 Paul.  Must show sub panel during precompile to allow it to continue. 
			// 05/26/2023 Paul.  When edting, need to show initially, otherwise it not getting displayed at all. 
			subPanelVisible  : props.EnableACLEditing || Sql.ToBoolean(props.isPrecompile),
		};
	}

	async componentDidMount()
	{
		const { USER_ID, ROLE_ID } = this.props;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				let res  = null;
				if ( !Sql.IsEmptyGuid(USER_ID) )
				{
					res = await CreateSplendidRequest('Administration/Rest.svc/GetAclAccessByUser?USER_ID=' + USER_ID, 'GET');
				}
				else if ( !Sql.IsEmptyGuid(ROLE_ID) )
				{
					res = await CreateSplendidRequest('Administration/Rest.svc/GetAclAccessByRole?ROLE_ID=' + ROLE_ID, 'GET');
				}
				else
				{
					res = await CreateSplendidRequest('Administration/Rest.svc/GetAclAccessByModule', 'GET');
				}
				let json = await GetSplendidResult(res);
				if ( this._isMounted )
				{
					let __total          : number = Sql.ToInteger(json.__total);
					let __sql            : string = Sql.ToString (json.__sql  );
					let IS_ADMIN_DELEGATE: boolean = Sql.ToBoolean(json.IS_ADMIN_DELEGATE);
					let vwMain           : any[]  = [];
					// 03/15/2021 Paul.  Admin panel is only displayed if enabled. 
					let vwMainAdmin      : any[]  = (Crm_Config.ToBoolean('allow_admin_roles') && (IS_ADMIN_DELEGATE || Sql.IsEmptyGuid(USER_ID)) ? [] : null);
					if ( json.d.results )
					{
						for ( let i: number = 0; i < json.d.results.length; i++ )
						{
							let row: any = json.d.results[i];
							let IS_ADMIN   : boolean = Sql.ToBoolean(row['IS_ADMIN'   ]);
							let MODULE_NAME: string  = Sql.ToString (row['MODULE_NAME']);
							if ( !IS_ADMIN && MODULE_NAME != 'Teams' )
							{
								vwMain.push(row);
							}
							// 03/15/2021 Paul.  Admin panel is only displayed if enabled. 
							else if ( Crm_Config.ToBoolean('allow_admin_roles') && (IS_ADMIN_DELEGATE || Sql.IsEmptyGuid(USER_ID)) )
							{
								vwMainAdmin.push(row);
							}
						}
					}
					this.setState({ vwMain, vwMainAdmin, __total, __sql });
				}
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
		else if ( sACCESS_TYPE == 'import' )
		{
			// 04/25/2006 Paul.  Be flexible with the values, so don't compare directly to 90 and -99.
			if ( nACCESS > 0 )
				nACCESS = 90;
			else
				nACCESS = -99;
		}
		// 09/26/2017 Paul.  Add Archive access right. 
		else if ( sACCESS_TYPE == 'archive' )
		{
			if ( nACCESS > 90 )
				nACCESS = 91;
			else if ( nACCESS > 75 )
				nACCESS = 90;
			else if ( nACCESS > 0 )
				nACCESS = 75;
			else
				nACCESS = -99;
		}
		else
		{
			// 04/25/2006 Paul.  Be flexible with the values, so don't compare directly to 90, 75 and -99.
			if ( nACCESS > 75 )
				nACCESS = 90;
			else if ( nACCESS > 0 )
				nACCESS = 75;
			else
				nACCESS = -99;
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
		else if ( sACCESS_TYPE == 'import' )
		{
			if ( nACCESS > 0 )
				sClass = 'aclAll';
			else
				sClass = 'aclNone';
		}
		// 09/26/2017 Paul.  Add Archive access right. 
		else if ( sACCESS_TYPE == 'archive' )
		{
			if ( nACCESS > 75 )
				sClass = 'aclAll';
			else if ( nACCESS > 0 )
				sClass = 'aclOwner';
			else
				sClass = 'aclNone';
		}
		else
		{
			if ( nACCESS > 75 )
				sClass = 'aclAll';
			else if ( nACCESS > 0 )
				sClass = 'aclOwner';
			else
				sClass = 'aclNone';
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
		else if ( sACCESS_TYPE == 'import' )
		{
			if ( nACCESS > 0 )
				sACCESS = 'ACLActions.LBL_ACCESS_ALL';
			else
				sACCESS = 'ACLActions.LBL_ACCESS_NONE';
		}
		// 09/26/2017 Paul.  Add Archive access right. 
		else if ( sACCESS_TYPE == 'archive' )
		{
			if ( nACCESS > 90 )
				sACCESS = 'ACLActions.LBL_ACCESS_ARCHIVE';
			else if ( nACCESS > 75 )
				sACCESS = 'ACLActions.LBL_ACCESS_VIEW';
			else if ( nACCESS > 0 )
				sACCESS = 'ACLActions.LBL_ACCESS_OWNER';
			else
				sACCESS = 'ACLActions.LBL_ACCESS_NONE';
		}
		else
		{
			if ( nACCESS > 75 )
				sACCESS = 'ACLActions.LBL_ACCESS_ALL';
			else if ( nACCESS > 0 )
				sACCESS = 'ACLActions.LBL_ACCESS_OWNER';
			else
				sACCESS = 'ACLActions.LBL_ACCESS_NONE';
		}
		return L10n.Term(sACCESS);
	}

	private onToggleCollapse = (open) =>
	{
		this.setState({ open }, () =>
		{
			if ( open )
			{
				localStorage.setItem(CONTROL_VIEW_NAME, 'true');
			}
			else
			{
				// 11/10/2020 Paul.  Save false instead of remove so that config value default_subpanel_open will work properly. 
				//localStorage.removeItem(CONTROL_VIEW_NAME);
				localStorage.setItem(CONTROL_VIEW_NAME, 'false');
			}
		});
	}

	protected _onSelectChange = (name: string, item: any, event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let { vwMain, vwMainAdmin } = this.state;
		let value = Sql.ToInteger(event.target.value);
		item['ACLACCESS_' + name.toUpperCase()] = value;
		this.setState({ vwMain, vwMainAdmin });
	}

	protected RenderCell = (name: string, LIST_VALUES: any[], item: any) =>
	{
		const { EnableACLEditing } = this.props;
		if ( EnableACLEditing && Sql.ToBoolean(item['ACLACCESS_' + name.toUpperCase() + '_Editing']) )
		{
			let id: string = item['MODULE_NAME'] + '_' + name + 'link';
			return(<select
				id={ id }
				key={ id }
				onChange={ (event: React.ChangeEvent<HTMLSelectElement>) => this._onSelectChange(name, item, event) }
				value={ this.NormalizeAccessValue(name, Sql.ToInteger(item['ACLACCESS_' + name.toUpperCase()])) }
				className={ this.AccessClassName(name, Sql.ToInteger(item['ACLACCESS_' + name.toUpperCase()])) }
			>
				{
					LIST_VALUES.map((item, index) => 
					{
						let ENUM_NAME: string = ACL_ACCESS.GetName(name, item);
						return (<option id={ id + '_' + index.toString() } key={ id + '_' + index.toString() } value={ item }>{ L10n.Term('ACLActions.LBL_ACCESS_' + ENUM_NAME) }</option>);
					})
				}
			</select>);
		}
		else
		{
			return (<div
				id={ item['MODULE_NAME'] + '_' + name + 'link' }
				className={ this.AccessClassName(name, Sql.ToInteger(item['ACLACCESS_' + name.toUpperCase()])) }
			>
				{ this.AccessLabel(name , Sql.ToInteger(item['ACLACCESS_' + name.toUpperCase()])) }
			</div>);
		}
	}

	protected _onDoubleClick = (name: string, item: any) =>
	{
		let { vwMain, vwMainAdmin } = this.state;
		item['ACLACCESS_' + name.toUpperCase() + '_Editing'] = !Sql.ToBoolean(item['ACLACCESS_' + name.toUpperCase() + '_Editing']);
		this.setState({ vwMain, vwMainAdmin });
	}

	protected _onDoubleClickAdmin = (name: string, item: any) =>
	{
		let { vwMain, vwMainAdmin } = this.state;
		item['ACLACCESS_' + name.toUpperCase() + '_Editing'] = !Sql.ToBoolean(item['ACLACCESS_' + name.toUpperCase() + '_Editing']);
		this.setState({ vwMain, vwMainAdmin });
	}

	public render()
	{
		const { EnableACLEditing } = this.props;
		const { vwMain, vwMainAdmin, __sql, error, open, subPanelVisible } = this.state;
		if ( SplendidCache.IsInitialized )
		{
			Credentials.sUSER_THEME;
			let headerButtons = SubPanelButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE     : string = L10n.Term('Users.LBL_ACCESS_RIGHTS');
			// 07/30/2021 Paul.  Load when the panel appears. 
			return (
				<React.Fragment>
					<Appear onAppearOnce={ (ioe) => this.setState({ subPanelVisible: true }) }>
						{ headerButtons && !EnableACLEditing
						? React.createElement(headerButtons, { MODULE_NAME: 'AccessView', ID: null, MODULE_TITLE, CONTROL_VIEW_NAME, error, ButtonStyle: 'ListHeader', VIEW_NAME: 'ActivityStream.Subpanel', row: null, Page_Command: null, showButtons: false, onToggle: this.onToggleCollapse, isPrecompile: this.props.isPrecompile, history: null, location: null, match: null, ref: this.headerButtons })
						: null
						}
					</Appear>
					<Content pose={ open ? 'open' : 'closed' } style={ {overflow: (open ? 'visible' : 'hidden')} }>
						{ open && subPanelVisible
						? <React.Fragment>
						<ErrorComponent error={ error } />
						<DumpSQL SQL={ __sql } />
						{ vwMain
						? <table id='ctlAccessView_grdACL' className='tabDetailView' cellSpacing={ 1 } cellPadding={ 0 } style={ {width: '100%', border: 'collapse', lineHeight: '15px', borderSpacing: '4px'} }>
							<tr className='tabDetailViewDL' style={ {lineHeight: '15px'} }>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>&nbsp;</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_ACCESS' ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_VIEW'   ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_LIST'   ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_EDIT'   ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_DELETE' ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_IMPORT' ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_EXPORT' ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_ARCHIVE') }</td>
							</tr>
							{
								vwMain.map((item, index) => 
								{
									return (
							<tr className='tabDetailViewDF'>
								<td className='tabDetailViewDL' style={ {whiteSpace: 'nowrap', border: '1px solid black'} }>{ L10n.Term(item['DISPLAY_NAME']) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClick('access' , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('access' , this.ACCESS_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClick('view'   , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('view'   , this.OTHERS_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClick('list'   , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('list'   , this.OTHERS_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClick('edit'   , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('edit'   , this.OTHERS_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClick('delete' , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('delete' , this.OTHERS_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClick('import' , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('import' , this.IMPORT_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClick('export' , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('export' , this.OTHERS_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClick('archive', item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('archive', this.ARCHIVE_LIST_VALUES, item) }</td>
							</tr>
									);
								})
							}
						</table>
						: null
						}
						<br />
						{ vwMainAdmin
						? <table id='ctlAccessView_grdACL' className='tabDetailView' cellSpacing={ 1 } cellPadding={ 0 } style={ {width: '100%', border: 'collapse', lineHeight: '15px', borderSpacing: '4px'} }>
							<tr className='tabDetailViewDL' style={ {lineHeight: '15px'} }>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>&nbsp;</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_ACCESS' ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_VIEW'   ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_LIST'   ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_EDIT'   ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_DELETE' ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_IMPORT' ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_EXPORT' ) }</td>
								<td style={ {whiteSpace: 'nowrap', textAlign: 'center', border: '1px solid black'} }>{ L10n.Term('ACLActions.LBL_ACTION_ARCHIVE') }</td>
							</tr>
							{
								vwMainAdmin.map((item, index) => 
								{
									return (
							<tr className='tabDetailViewDF'>
								<td className='tabDetailViewDL' style={ {whiteSpace: 'nowrap', border: '1px solid black'} }>{ L10n.Term(item['DISPLAY_NAME']) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClickAdmin('access' , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('access' , this.ACCESS_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClickAdmin('view'   , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('view'   , this.OTHERS_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClickAdmin('list'   , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('list'   , this.OTHERS_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClickAdmin('edit'   , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('edit'   , this.OTHERS_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClickAdmin('delete' , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('delete' , this.OTHERS_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClickAdmin('import' , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('import' , this.IMPORT_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClickAdmin('export' , item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('export' , this.OTHERS_LIST_VALUES , item) }</td>
								<td onDoubleClick={ () =>  this._onDoubleClickAdmin('archive', item) } style={ {textAlign: 'center', width: '12%', whiteSpace: 'nowrap', border: '1px solid black'} }>{ this.RenderCell('archive', this.ARCHIVE_LIST_VALUES, item) }</td>
							</tr>
									);
								})
							}
						</table>
						: null
						}
						</React.Fragment>
						: null
						}
					</Content>
				</React.Fragment>
			);
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


