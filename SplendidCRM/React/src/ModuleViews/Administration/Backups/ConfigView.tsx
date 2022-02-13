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
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IAdminConfigViewState
{
	NAME              : string;
	MODULE_NAME       : string;
	BUTTON_NAME       : string;
	MODULE_TITLE      : string;
	DUPLICATE         : boolean;
	LAST_DATE_MODIFIED: Date;
	dependents        : Record<string, Array<any>>;
	error?            : any;
}

@observer
export default class BackupsConfigView extends React.Component<IAdminConfigViewProps, IAdminConfigViewState>
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

		let BUTTON_NAME: string = null;
		let MODULE_TITLE: string = L10n.Term('Administration.LBL_BACKUPS_TITLE');
		if ( !Sql.IsEmptyString(props.MODULE_TITLE) )
		{
			MODULE_TITLE = props.MODULE_TITLE;
		}
		Credentials.SetViewMode('AdminConfigView');
		this.state =
		{
			NAME              : null,
			MODULE_NAME       ,
			BUTTON_NAME       ,
			MODULE_TITLE      ,
			DUPLICATE         : false,
			LAST_DATE_MODIFIED: null,
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
		const { MODULE_NAME } = this.state;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				if ( !Security.IS_ADMIN() )
				{
					throw(L10n.Term('.LBL_INSUFFICIENT_ACCESS'));
				}
				if ( SplendidCache.AdminMenu == null )
				{
					await Admin_GetReactState(this.constructor.name + '.componentDidMount');
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
		try
		{
			if ( this._isMounted )
			{
				let sDate: string = formatDate((new Date()), 'YYYYMMDDHHmm');
				let NAME: string = 'SplendidCRM_db_' + sDate + '.bak';
				this.setState(
				{
					NAME,
				}, () =>
				{
					if ( this.props.onLayoutLoaded )
					{
						this.props.onLayoutLoaded();
					}
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { history } = this.props;
		const { NAME } = this.state;
		switch (sCommandName)
		{
			case 'Save':
			case 'Next':
			{
				try
				{
					if ( this.headerButtons.current != null )
					{
						this.headerButtons.current.Busy();
					}
					// 12/31/2007 Paul.  The NAME is not required.  If not provided, it will be generated. 
					let data: any =
					{
						FILENAME: NAME,
						TYPE    : 'FULL'
					};
					let d: any = await AdminProcedure('spSqlBackupDatabase', data);
					if ( this._isMounted )
					{
						this.setState( {error: L10n.Term("Administration.LBL_DONE") + " " + d.FILENAME });
					}
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
					this.setState({ error });
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
			case 'Back':
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

	private _onButtonsLoaded = async () =>
	{
		if ( this.headerButtons.current != null )
		{
		}
	}

	private _onNAME_Change = (e) =>
	{
		this.setState({ NAME: e.target.value });
	}

	public render()
	{
		const { callback } = this.props;
		const { NAME, MODULE_NAME, BUTTON_NAME, MODULE_TITLE, error } = this.state;
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<div>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: BUTTON_NAME, row: {}, Page_Command: this.Page_Command, showButtons: true, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<div id={!!callback ? null : "content"}>
					<div>
						{ L10n.Term("Administration.LBL_BACKUP_DATABASE_INSTRUCTIONS") }
					</div>
					<table className="tabForm" cellSpacing={ 1 } cellPadding={ 0 } style={ {width: '100%', border: 'none'} }>
						<tr>
							<td>
								<table cellSpacing={ 0 } cellPadding={ 0 } style={ {border: 'none'} }>
									<tr>
										<td className="dataLabel">{ L10n.Term("Administration.LBL_BACKUP_FILENAME") }</td>
										<td className="dataField">
											<input type='text' size={ 70 } maxLength={ 255 } value={ NAME } onChange={ this._onNAME_Change } />
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<table cellSpacing={ 0 } cellPadding={ 0 } style={ {width: '100%', border: 'none'} }>
						<tr>
							<td align="left" >
								<input type="submit" value={ "  " + L10n.Term(".LBL_BACK_BUTTON_LABEL") + "  " } id="btnBack" title="Back" className="button" onClick={ (e) => this.Page_Command('Back', null) } />
							</td>
							<td align="right">
								<input type="submit" value={ "  " + L10n.Term(".LBL_NEXT_BUTTON_LABEL") + "  " } id="btnNext" title="Next" className="button" onClick={ (e) => this.Page_Command('Next', null) } />
							</td>
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

