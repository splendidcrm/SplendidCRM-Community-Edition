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
import { RouteComponentProps, withRouter }       from '../Router5'                      ;
// 2. Store and Types. 
import MODULE                                    from '../../../types/MODULE'                 ;
// 3. Scripts. 
import Sql                                       from '../../../scripts/Sql'                  ;
import L10n                                      from '../../../scripts/L10n'                 ;
import Security                                  from '../../../scripts/Security'             ;
import Credentials                               from '../../../scripts/Credentials'          ;
import SplendidCache                             from '../../../scripts/SplendidCache'        ;
import { ListView_LoadLayout }                   from '../../../scripts/ListView'             ;
import { EditView_LoadLayout }                   from '../../../scripts/EditView'             ;
import { DetailView_LoadLayout }                 from '../../../scripts/DetailView'           ;
import { Admin_GetReactState }                   from '../../../scripts/Application'          ;
import { AuthenticatedMethod, LoginRedirect }    from '../../../scripts/Login'                ;
import { screenWidth, screenHeight }             from '../../../scripts/utility'              ;
// 4. Components and Views. 
import ErrorComponent                            from '../../../components/ErrorComponent'    ;
import DynamicListView                           from '../../../views/DynamicListView'        ;
import DynamicEditView                           from '../../../views/DynamicEditView'        ;
import DynamicDetailView                         from '../../../views/DynamicDetailView'      ;
import DynamicPopupView                          from '../../../views/DynamicPopupView'       ;
import DynamicAdminListView                      from '../../../views/DynamicAdminListView'   ;
import DynamicAdminEditView                      from '../../../views/DynamicAdminEditView'   ;
import DynamicAdminDetailView                    from '../../../views/DynamicAdminDetailView' ;
import AdminConfigView                           from '../../../views/AdminConfigView'        ;
import AdminReadOnlyConfigView                   from '../../../views/AdminReadOnlyConfigView';

interface IPrecompileProps extends RouteComponentProps<any>
{
}

interface IPrecompileState
{
	lstModulePages     : any[];
	currentIndex       : number;
	nextPageTimeout    : number;  // milliseconds. 
	error              : any;
	clientHeight       : number;
}

class Precompile extends React.Component<IPrecompileProps, IPrecompileState>
{
	private _isMounted          : boolean = false;
	private _bContinuePrecompile: boolean = true;
	private lstFiles            : HTMLSelectElement = null;

	constructor(props: IPrecompileProps)
	{
		super(props);
		Credentials.SetViewMode('HomeView');
		this.state =
		{
			lstModulePages     : null,
			currentIndex       : null,
			nextPageTimeout    : 600,
			error              : null,
			clientHeight       : screenHeight(),
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		try
		{
			document.title = 'Precompile';
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				// 07/06/2020 Paul.  Admin_GetReactState will also generate an exception, but catch anyway. 
				if ( !(Security.IS_ADMIN() || SplendidCache.AdminUserAccess('Administration', 'access') >= 0) )
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
				let lstMODULES: MODULE[] = SplendidCache.MODULES;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', lstMODULES);
				if ( lstMODULES != null )
				{
					let queryParams    : any = qs.parse(location.search);
					let adminOnly      : boolean = Sql.ToBoolean(queryParams['adminOnly'  ]);
					let ignoreAzure    : boolean = Sql.ToBoolean(queryParams['ignoreAzure']);
					let nextPageTimeout: number  = Sql.ToInteger(queryParams['delay'      ]);
					let modules        : string[] = [];
					if ( !Sql.IsEmptyString(queryParams['modules']) )
						modules = Sql.ToString (queryParams['modules']).split(',');
					let currentIndex   : number  = null;
					let lstModulePages : any[]   = [];
					let layout         : any     = null;
					// 02/06/2024 Paul.  Provide a way to detect Azure enabled. 
					let bAzureRestExists: boolean = Sql.ToBoolean(SplendidCache.Config('AzureRestExists'))
					// 04/10/2021 Paul.  Make two passes so that admin modules can be placed at the end. 
					for ( let MODULE_NAME in lstMODULES )
					{
						if ( MODULE_NAME == 'ActivityStream' 
						  || MODULE_NAME == 'Calendar' 
						  || MODULE_NAME == 'CampaignLog' 
						  || MODULE_NAME == 'ChatDashboard' 
						  || MODULE_NAME == 'CreditCards' 
						  || MODULE_NAME == 'Dashboard' 
						  || MODULE_NAME == 'DashboardPanels' 
						  || MODULE_NAME == 'EmailClient' 
						  || MODULE_NAME == 'Feeds' 
						  || MODULE_NAME == 'Home' 
						  || MODULE_NAME == 'Images' 
						  || MODULE_NAME == 'InvoicesLineItems' 
						  || MODULE_NAME == 'OrdersLineItems' 
						  || MODULE_NAME == 'QuotesLineItems' 
						  || MODULE_NAME == 'RevenueLineItems' 
						  || MODULE_NAME == 'PaymentsLineItems' 
						  || MODULE_NAME == 'MailMerge' 
						  || MODULE_NAME == 'ProductCatalog' 
						  || MODULE_NAME == 'ReportRules' 
						  || MODULE_NAME == 'ReportDesigner' 
						  || MODULE_NAME == 'SurveyQuestionResults' 
						//  || MODULE_NAME == 'CloudServices' // 04/14/2021.  This is allowed because it is an azure module. 
						   )
						{
							continue;
						}
						// 04/18/2021 Paul.  Allow lists to be filtered. 
						if ( modules.length > 0 && !modules.includes(MODULE_NAME) )
						{
							continue;
						}
						// 02/11/2022 Paul.  ReportDesigner is converted to Reports in router, so we must do so here as well. 
						if ( MODULE_NAME == 'ReportDesigner' )
							MODULE_NAME = 'Reports';
						let module: MODULE = lstMODULES[MODULE_NAME];
						let RELATIVE_PATH: string = module.RELATIVE_PATH;
						RELATIVE_PATH = RELATIVE_PATH.replace('~/', '');
						if ( !module.IS_ADMIN )
						{
							let obj:any = {};
							// 11/28/2021 Paul.  DocumentRevisions does not have a ListView. 
							layout = ListView_LoadLayout(MODULE_NAME + '.ListView', true);
							if ( layout )
							{
								obj = {};
								obj.IS_ADMIN     = false;
								obj.MODULE_NAME  = module.MODULE_NAME;
								obj.LAYOUT_TYPE  = 'ListView';
								obj.lnkName      = MODULE_NAME + '/ ';
								// 07/08/2023 Paul.  ASP.NET Core will not have /React in the base. 
								obj.lnkReactTest = Credentials.RemoteServer + Credentials.ReactBase + RELATIVE_PATH;
								obj.lnkAspTest   = Credentials.RemoteServer +           RELATIVE_PATH;
								lstModulePages.push(obj);
							}
							
							layout = ListView_LoadLayout(MODULE_NAME + '.PopupView', true);
							if ( layout )
							{
								obj = {};
								obj.IS_ADMIN     = false;
								obj.MODULE_NAME  = module.MODULE_NAME;
								obj.LAYOUT_TYPE  = 'PopupView';
								obj.lnkName      = MODULE_NAME + '/ ';
								obj.lnkReactTest = Credentials.RemoteServer + Credentials.ReactBase + RELATIVE_PATH;
								obj.lnkAspTest   = Credentials.RemoteServer +            RELATIVE_PATH;
								lstModulePages.push(obj);
							}
							
							layout = DetailView_LoadLayout(MODULE_NAME + '.DetailView', true);
							if ( layout )
							{
								obj = {};
								obj.IS_ADMIN      = false;
								obj.MODULE_NAME   = module.MODULE_NAME;
								obj.LAYOUT_TYPE   = 'DetailView';
								obj.LAST_ID       = null;
								obj.lnkName       = MODULE_NAME + '/ ';
								obj.lnkReactTest  = Credentials.RemoteServer + Credentials.ReactBase + RELATIVE_PATH;
								obj.lnkAspTest    = Credentials.RemoteServer +            RELATIVE_PATH;
								obj.lnkReactTest += 'View/';
								obj.lnkAspTest   += 'view.aspx?ID=';
								obj.lnkName      += 'View/ ';
								lstModulePages.push(obj);
							}
							
							layout = EditView_LoadLayout(MODULE_NAME + '.EditView', true);
							if ( layout )
							{
								obj = {};
								obj.IS_ADMIN      = false;
								obj.MODULE_NAME   = module.MODULE_NAME;
								obj.LAYOUT_TYPE   = 'EditView';
								obj.LAST_ID       = null;
								obj.lnkName       = MODULE_NAME + '/ ';
								obj.lnkReactTest  = Credentials.RemoteServer + Credentials.ReactBase + RELATIVE_PATH;
								obj.lnkAspTest    = Credentials.RemoteServer +            RELATIVE_PATH;
								obj.lnkReactTest += 'Edit/';
								obj.lnkAspTest   += 'edit.aspx?ID=';
								obj.lnkName      += 'Edit/ ';
								lstModulePages.push(obj);
							}
						}
					}
					let nStartIndex: number = 0;
					if ( adminOnly )
					{
						nStartIndex = lstModulePages.length;
					}
					if ( nextPageTimeout <= 0 )
						nextPageTimeout = 600;
					for ( let MODULE_NAME in lstMODULES )
					{
						// 04/18/2021 Paul.  Allow lists to be filtered. 
						if ( modules.length > 0 && !modules.includes(MODULE_NAME) )
						{
							continue;
						}
						let module: MODULE = lstMODULES[MODULE_NAME];
						// 04/14/2021 Paul.  Use of relative path is required for Azure modules that are an extra level deep. 
						let RELATIVE_PATH: string = module.RELATIVE_PATH;
						RELATIVE_PATH = RELATIVE_PATH.replace('~/', '');
						// 02/06/2024 Paul.  Provide a way to detect Azure enabled. 
						if ( ignoreAzure || !bAzureRestExists )
						{
							if ( RELATIVE_PATH.indexOf('Azure') >= 0 )
							{
								continue;
							}
						}
						if ( module.IS_ADMIN )
						{
							let obj:any = {};
							layout = ListView_LoadLayout(MODULE_NAME + '.ListView', true);
							if ( layout )
							{
								obj = {};
								obj.IS_ADMIN     = true;
								obj.MODULE_NAME  = module.MODULE_NAME;
								obj.LAYOUT_TYPE  = 'ListView';
								obj.lnkName      = 'Administration/' + MODULE_NAME + '/ ';
								obj.lnkReactTest = Credentials.RemoteServer + Credentials.ReactBase + RELATIVE_PATH;
								obj.lnkAspTest   = Credentials.RemoteServer +            RELATIVE_PATH;
								lstModulePages.push(obj);
							}
							
							layout = DetailView_LoadLayout(MODULE_NAME + '.DetailView', true);
							if ( layout )
							{
								obj = {};
								obj.IS_ADMIN      = true;
								obj.MODULE_NAME   = module.MODULE_NAME;
								obj.LAYOUT_TYPE   = 'DetailView';
								obj.LAST_ID       = null;
								obj.lnkName       = 'Administration/' + MODULE_NAME + '/ ';
								obj.lnkReactTest  = Credentials.RemoteServer + Credentials.ReactBase + RELATIVE_PATH;
								obj.lnkAspTest    = Credentials.RemoteServer +            RELATIVE_PATH;
								obj.lnkReactTest += 'View/';
								obj.lnkAspTest   += 'view.aspx?ID=';
								obj.lnkName      += 'View/ ';
								lstModulePages.push(obj);
							}
							
							layout = EditView_LoadLayout(MODULE_NAME + '.EditView', true);
							if ( layout )
							{
								obj = {};
								obj.IS_ADMIN      = true;
								obj.MODULE_NAME   = module.MODULE_NAME;
								obj.LAYOUT_TYPE   = 'EditView';
								obj.LAST_ID       = null;
								obj.lnkName       = 'Administration/' + MODULE_NAME + '/ ';
								obj.lnkReactTest  = Credentials.RemoteServer + Credentials.ReactBase + RELATIVE_PATH;
								obj.lnkAspTest    = Credentials.RemoteServer +            RELATIVE_PATH;
								obj.lnkReactTest += 'Edit/';
								obj.lnkAspTest   += 'edit.aspx?ID=';
								obj.lnkName      += 'Edit/ ';
								lstModulePages.push(obj);
							}
							
							layout = EditView_LoadLayout(MODULE_NAME + '.ConfigView', true);
							if ( layout )
							{
								obj = {};
								obj.IS_ADMIN      = true;
								obj.MODULE_NAME   = module.MODULE_NAME;
								obj.LAYOUT_TYPE   = 'ConfigView';
								obj.LAST_ID       = null;
								obj.lnkName       = 'Administration/' + MODULE_NAME + '/ ';
								obj.lnkReactTest  = Credentials.RemoteServer + Credentials.ReactBase + RELATIVE_PATH;
								obj.lnkAspTest    = Credentials.RemoteServer +            RELATIVE_PATH;
								obj.lnkReactTest += 'ConfigView';
								obj.lnkAspTest   += 'config.aspx';
								obj.lnkName      += 'ConfigView';
								lstModulePages.push(obj);
							}
							// 04/26/2022 Paul.  ReadOnlyConfigView may not exist. 
							layout = EditView_LoadLayout(MODULE_NAME + '.ReadOnlyConfigView', true);
							if ( layout )
							{
								obj = {};
								obj.IS_ADMIN      = true;
								obj.MODULE_NAME   = module.MODULE_NAME;
								obj.LAYOUT_TYPE   = 'ReadOnlyConfigView';
								obj.LAST_ID       = null;
								obj.lnkName       = 'Administration/' + MODULE_NAME + '/ ';
								obj.lnkReactTest  = Credentials.RemoteServer + Credentials.ReactBase + RELATIVE_PATH;
								obj.lnkAspTest    = Credentials.RemoteServer +            RELATIVE_PATH;
								obj.lnkReactTest += '';
								obj.lnkAspTest   += 'default.aspx';
								obj.lnkName      += '';
								lstModulePages.push(obj);
							}
						}
					}
					if ( lstModulePages.length > 0 )
						currentIndex = nStartIndex;
					this.setState({ nextPageTimeout, lstModulePages, currentIndex });
					window.addEventListener("resize", this.updateDimensions);
				}
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
		window.removeEventListener("resize", this.updateDimensions);
	}

	private updateDimensions = () =>
	{
		if ( this.lstFiles != null )
		{
			let rect = this.lstFiles.getBoundingClientRect();
			let clientHeight: number = Math.floor(screenHeight() - rect.top - 10);
			if ( this.state.clientHeight != clientHeight )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.updateDimensions', clientHeight);
				this.setState({ clientHeight });
			}
		}
	}

	private refFiles = (element) =>
	{
		if ( element != null )
		{
			this.lstFiles = element;
			let rect = this.lstFiles.getBoundingClientRect();
			let clientHeight: number = Math.floor(screenHeight() - rect.top - 10);
			if ( this.state.clientHeight != clientHeight )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.refFiles', clientHeight);
				this.setState({ clientHeight });
			}
		}
	}

	private _onMultiSelectChange = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMultiSelectChange', event.target.selectedIndex);
		let currentIndex: number = event.target.selectedIndex;
		if ( currentIndex < 0 )
			currentIndex = null;
		this.setState(
		{
			currentIndex,
		});
	}

	private _onStopPrecompile = () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onStopPrecompile');
		this._bContinuePrecompile = false;
	}

	private _onContinuePrecompile = () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onContinuePrecompile');
		this._bContinuePrecompile = true;
		this.setState(
		{
			currentIndex: this.state.currentIndex + 1
		});
	}

	private _onComponentComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data): void => 
	{
		let { nextPageTimeout, lstModulePages, currentIndex } = this.state;
		let LAYOUT_TYPE : string  = null;
		MODULE_NAME  = lstModulePages[currentIndex].MODULE_NAME ;
		LAYOUT_TYPE  = lstModulePages[currentIndex].LAYOUT_TYPE ;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + MODULE_NAME + '.' + LAYOUT_TYPE);
		if ( LAYOUT_TYPE == 'ListView' )
		{
			if ( data.length > 0 && data[0].ID !== undefined )
			{
				if ( currentIndex + 1 < lstModulePages.length )
				{
					if ( lstModulePages[currentIndex + 1].MODULE_NAME == MODULE_NAME )
					{
						if ( lstModulePages[currentIndex + 1].LAYOUT_TYPE == 'EditView' || lstModulePages[currentIndex + 1].LAYOUT_TYPE == 'DetailView'  )
						{
							lstModulePages[currentIndex + 1].LAST_ID = data[0].ID;
						}
					}
				}
				if ( currentIndex + 2 < lstModulePages.length )
				{
					if ( lstModulePages[currentIndex + 2].MODULE_NAME == MODULE_NAME )
					{
						if ( lstModulePages[currentIndex + 2].LAYOUT_TYPE == 'EditView' || lstModulePages[currentIndex + 2].LAYOUT_TYPE == 'DetailView'  )
						{
							lstModulePages[currentIndex + 2].LAST_ID = data[0].ID;
						}
					}
				}
			}
		}
		if ( this._bContinuePrecompile )
		{
			if ( currentIndex + 1 < lstModulePages.length && this._isMounted )
			{
				setTimeout(() =>
				{
					if ( this._isMounted )
					{
						if ( lstModulePages[currentIndex + 1].LAYOUT_TYPE == 'DetailView' && lstModulePages[currentIndex + 1].LAST_ID == null )
						{
							if ( currentIndex + 2 < lstModulePages.length )
							{
								this.setState({ currentIndex: currentIndex + 2 });
							}
						}
						else
						{
							this.setState({ currentIndex: currentIndex + 1 });
						}
					}
				}, nextPageTimeout);
			}
		}
	}

	private _onPopupChange = (value: { Action: string, ID: string, NAME: string }) =>
	{
		// 04/12/2021 Paul.  No need to do anything here as it will never get called. 
	}

	public render()
	{
		const { lstModulePages, currentIndex, error, clientHeight } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', lstModules);

		let lnkReactTest: string  = '';
		let lnkAspTest  : string  = '';
		let lnkName     : string  = null;
		let IS_ADMIN    : boolean = false;
		let MODULE_NAME : string  = null;
		let LAYOUT_TYPE : string  = null;
		let LAST_ID     : string  = null;
		if ( lstModulePages && currentIndex != null )
		{
			IS_ADMIN     = lstModulePages[currentIndex].IS_ADMIN    ;
			MODULE_NAME  = lstModulePages[currentIndex].MODULE_NAME ;
			LAYOUT_TYPE  = lstModulePages[currentIndex].LAYOUT_TYPE ;
			LAST_ID      = lstModulePages[currentIndex].LAST_ID     ;
			lnkReactTest = lstModulePages[currentIndex].lnkReactTest;
			lnkAspTest   = lstModulePages[currentIndex].lnkAspTest  ;
			lnkName      = lstModulePages[currentIndex].lnkName     ;
			if ( !Sql.IsEmptyString(LAST_ID) )
			{
				if ( LAYOUT_TYPE == 'EditView' || LAYOUT_TYPE == 'DetailView' )
				{
					lnkReactTest += LAST_ID;
					lnkAspTest   += LAST_ID;
					lnkName      += LAST_ID;
				}
			}
		}

		return (<table id='tblLayoutFrame' cellPadding={ 0 } cellSpacing={ 0 } style={ {width: '100%', height: '95vh', border: 'none', borderCollapse: 'collapse'} }>
	<tr>
		<td width='10%' valign='top'>
			<div style={ {marginTop: '6px', marginBottom: '4px', fontSize: '14px'} }>
				<div style={ {margin: '4px', height: '2em', overflow: 'hidden'} }>{ lnkName }</div>
				<div style={ {margin: '4px', whiteSpace: 'nowrap'} }>
					<a id='lnkReactTest' href={ lnkReactTest } target='PrecompileReactTest'>React</a> &nbsp; <a id='lnkReactTest' href={ lnkAspTest   } target='PrecompileAspTest'>ASP.NET</a>
				</div>
			</div>
			<div style={ {whiteSpace: 'nowrap'} }>
				<button className='button' style={ {margin: '2px'} } onClick={ this._onStopPrecompile     }>Cancel</button>
				<button className='button' style={ {margin: '2px'} } onClick={ this._onContinuePrecompile }>Continue</button><br />
			</div>
			{ lstModulePages
			? <select
				id='lstFiles'
				multiple={ false }
				value={ currentIndex != null ? currentIndex.toString() : null }
				onChange={ this._onMultiSelectChange }
				size={ 4 }
				style={ {width: '200px', height: clientHeight + 'px'} }
				ref={ (element) => this.refFiles(element) }
				>
				{
					lstModulePages.map((item, index) => 
					{
						return (<option key={ 'lstFiles_' + index.toString() } id={ 'lstFiles' + index.toString() } value={ index.toString() }>{ item.MODULE_NAME + ' - ' + item.LAYOUT_TYPE }</option>);
					})
				}
			</select>
			: null
			}
		</td>
		<td valign='top'>
			{ error != null
			? <ErrorComponent error={error} />
			: null
			}
			<div id='divPrecompileOutput' key={ currentIndex }>
				{ lstModulePages && currentIndex != null
				? <React.Fragment>
					{ IS_ADMIN
					? <React.Fragment>
						{ LAYOUT_TYPE == 'ListView'
						? <DynamicAdminListView
							MODULE_NAME={ MODULE_NAME }
							isPrecompile={ true }
							onComponentComplete={ this._onComponentComplete }
						/>
						: null
						}
						{ LAYOUT_TYPE == 'PopupView'
						? <DynamicPopupView
							MODULE_NAME={ MODULE_NAME }
							isOpen={ false }
							isPrecompile={ true }
							callback={ this._onPopupChange }
							onComponentComplete={ this._onComponentComplete }
						/>
						: null
						}
						{ LAYOUT_TYPE == 'EditView'
						? <DynamicAdminEditView
							MODULE_NAME={ MODULE_NAME }
							ID={ LAST_ID }
							isPrecompile={ true }
							onComponentComplete={ this._onComponentComplete }
						/>
						: null
						}
						{ LAYOUT_TYPE == 'DetailView'
						? !Sql.IsEmptyString(LAST_ID)
						? <DynamicAdminDetailView
							MODULE_NAME={ MODULE_NAME }
							ID={ LAST_ID }
							isPrecompile={ true }
							onComponentComplete={ this._onComponentComplete }
						/>
						: <div style={ {marginTop: '6px', marginBottom: '4px', fontSize: '14px', color: 'red'} }>
							Cannot render without ID
						</div>
						: null
						}
						{ LAYOUT_TYPE == 'ConfigView'
						? <AdminConfigView
							MODULE_NAME={ MODULE_NAME }
							isPrecompile={ true }
							onComponentComplete={ this._onComponentComplete }
						/>
						: null
						}
						{ LAYOUT_TYPE == 'ReadOnlyConfigView'
						? <AdminReadOnlyConfigView
							MODULE_NAME={ MODULE_NAME }
							isPrecompile={ true }
							onComponentComplete={ this._onComponentComplete }
						/>
						: null
						}
					</React.Fragment>
					: <React.Fragment>
						{ LAYOUT_TYPE == 'ListView'
						? <DynamicListView
							MODULE_NAME={ MODULE_NAME }
							isPrecompile={ true }
							onComponentComplete={ this._onComponentComplete }
						/>
						: null
						}
						{ LAYOUT_TYPE == 'PopupView'
						? <DynamicPopupView
							MODULE_NAME={ MODULE_NAME }
							isOpen={ false }
							isPrecompile={ true }
							callback={ this._onPopupChange }
							onComponentComplete={ this._onComponentComplete }
						/>
						: null
						}
						{ LAYOUT_TYPE == 'EditView'
						? <DynamicEditView
							MODULE_NAME={ MODULE_NAME }
							ID={ LAST_ID } LAYOUT_NAME={ MODULE_NAME + '.EditView' }
							isPrecompile={ true }
							onComponentComplete={ this._onComponentComplete }
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
						/>
						: null
						}
						{ LAYOUT_TYPE == 'DetailView'
						? !Sql.IsEmptyString(LAST_ID)
						? <DynamicDetailView
							MODULE_NAME={ MODULE_NAME }
							ID={ LAST_ID }
							isPrecompile={ true }
							onComponentComplete={ this._onComponentComplete }
						/>
						: <div style={ {marginTop: '6px', marginBottom: '4px', fontSize: '14px', color: 'red'} }>
							Cannot render without ID
						</div>
						: null
						}
					</React.Fragment>
					}
				</React.Fragment>
				: null
				}
			</div>
		</td>
	</tr>
</table>
		);
	}
}

export default withRouter(Precompile);
