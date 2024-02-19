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
import { RouteComponentProps, withRouter }          from '../Router5'                         ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'           ;
// 2. Store and Types. 
import { EditComponent }                            from '../../../types/EditComponent'             ;
import MODULE                                       from '../../../types/MODULE'                    ;
import ACL_ACCESS                                   from '../../../types/ACL_ACCESS'                ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                     ;
import L10n                                         from '../../../scripts/L10n'                    ;
import Security                                     from '../../../scripts/Security'                ;
import SplendidCache                                from '../../../scripts/SplendidCache'           ;
import SplendidDynamic                              from '../../../scripts/SplendidDynamic'         ;
import SplendidDynamic_EditView                     from '../../../scripts/SplendidDynamic_EditView';
import { Crm_Modules }                              from '../../../scripts/Crm'                     ;
import { EditView_LoadLayout }                      from '../../../scripts/EditView'                ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'                   ;
import { MassDeleteModule, MassUpdateModule, MassSync, MassUnsync, ArchiveMoveData, ArchiveRecoverData } from '../../../scripts/ModuleUpdate';
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'     ;
// 4. Components and Views. 
import ErrorComponent                               from '../../../components/ErrorComponent'        ;
import DynamicButtons                               from '../../../components/DynamicButtons'        ;
import Collapsable                                  from '../../../components/Collapsable'           ;

interface IMassUpdateProps extends RouteComponentProps<any>
{
	MODULE_NAME      : string;
	onUpdateComplete?: Function;
	archiveView?     : boolean;
}

interface IMassUpdateState
{
	item?            : any;
	layout           : any;
	initialOpen      : boolean;
	bADMIN_MODE      : boolean;
	dependents?      : Record<string, Array<any>>;
	selectedItems?   : any;
	error?           : any;
}

export default class ExchangeMassUpdate extends React.Component<IMassUpdateProps, IMassUpdateState>
{
	private _isMounted   : boolean = false;
	private refMap       : Record<string, React.RefObject<EditComponent<any, any>>>;
	private dynamicButtons = React.createRef<DynamicButtons>();

	constructor(props: IMassUpdateProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + props.MODULE_NAME);
		// 07/20/2019 Paul.  We need to pass a flag to the EditComponents to tell them not to initialize User and Team values. 
		let rowInitialValues: any = {};
		
		let initialOpen : boolean = Sql.ToBoolean(localStorage.getItem(props.MODULE_NAME + '.MassUpdate'));
		let module      : MODULE  = SplendidCache.Module(props.MODULE_NAME, this.constructor.name + '.constructor');
		if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
			initialOpen = false;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor rowInitialValues', rowInitialValues);
		this.state =
		{
			layout     : null            ,
			item       : rowInitialValues,
			dependents : {}              ,
			initialOpen: initialOpen     ,
			bADMIN_MODE: module.IS_ADMIN ,
			error      : null            ,
		};
	}

	async componentDidMount()
	{
		const { MODULE_NAME } = this.props;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				let layout = EditView_LoadLayout(MODULE_NAME + '.MassUpdate');
				this.setState({ layout: layout });
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
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	public Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { item } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		if ( this.state.error != null )
		{
			this.setState({ error: null });
		}
		try
		{
			switch ( sCommandName )
			{
				case 'MassUpdate'          :  await this._onMassUpdate       (sCommandArguments);  break;  // All modules. 
				case 'MassDelete'          :  await this._onMassDelete       (sCommandArguments);  break;  // All modules. 
				case 'Archive.MoveData'    :  await this._onArchiveMoveData  (sCommandArguments);  break;  // All primary non-admin modules. 
				case 'Archive.RecoverData' :  await this._onArchiveRecoverData(sCommandArguments);  break;  // All primary non-admin modules. 

				case 'Sync'                :  await this._onSync             (sCommandArguments);  break;  // Accounts, Bugs, Cases, Contacts, Leads, Opportunities, Project. 
				case 'Unsync'              :  await this._onUnsync           (sCommandArguments);  break;  // Accounts, Bugs, Cases, Contacts, Leads, Opportunities, Project. 

				case 'MassDisable'         :  await this._onMassDisable      (sCommandArguments);  break;  // Exchange only. 
				case 'MassEnable'          :  await this._onMassEnable       (sCommandArguments);  break;  // Exchange only. 
				case 'MassPublic'          :  break;  // SimpleStorage only. 
				case 'MassPrivate'         :  break;  // SimpleStorage only. 
				case 'Import'              :  break;  // PayPal and PayTrace. 
				case 'ToggleMassUpdate'    :  this.setState({ initialOpen: !this.state.initialOpen });  break;
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private onToggleCollapse = (open) =>
	{
		const { MODULE_NAME } = this.props;
		if ( open )
		{
			localStorage.setItem(MODULE_NAME + '.MassUpdate', 'true');
		}
		else
		{
			localStorage.removeItem(MODULE_NAME + '.MassUpdate');
		}
	}

	public SelectionChanged = (value: any) =>
	{
		const { MODULE_NAME } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged: ' + MODULE_NAME, value);
		if ( this._isMounted )
		{
			this.setState({ selectedItems: value, error: null });
		}
	}

	private ValidateOne = () =>
	{
		const { selectedItems } = this.state;
		let nSelectedCount = 0;
		for ( let id in selectedItems )
		{
			nSelectedCount++;
		}
		if ( nSelectedCount < 1 )
		{
			if ( this._isMounted )
			{
				this.setState({ error: L10n.Term('.LBL_LISTVIEW_NO_SELECTED') });
			}
			return false;
		}
		return true;
	}

	private ValidateTwo = () =>
	{
		const { selectedItems } = this.state;
		let nSelectedCount = 0;
		for ( let id in selectedItems )
		{
			nSelectedCount++;
		}
		if ( nSelectedCount < 2 )
		{
			if ( this._isMounted )
			{
				this.setState({ error: L10n.Term('.LBL_LISTVIEW_TWO_REQUIRED') });
			}
			return false;
		}
		return true;
	}

	private _onMassUpdate = async (sCommandArguments) =>
	{
		const { MODULE_NAME, onUpdateComplete } = this.props;
		const { bADMIN_MODE, item, selectedItems } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassUpdate', selectedItems, item);
		if ( this.ValidateOne() )
		{
			let arrID_LIST = [];
			for ( let id in selectedItems )
			{
				arrID_LIST.push(id);
			}
			try
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.Busy();
				}
				let row: any = {};
				let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
				await MassUpdateModule(MODULE_NAME, row, arrID_LIST, bADMIN_MODE);
				if ( onUpdateComplete != null )
				{
					onUpdateComplete('MassUpdate');
				}
				// 04/25/2020 Paul.  Clear after update. 
				SplendidDynamic_EditView.Clear(this.refMap);
				if ( this._isMounted )
				{
					this.setState({ item: {} });
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassUpdate', error);
				this.setState({ error });
			}
			finally
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.NotBusy();
				}
			}
		}
	}

	// 07/16/2019 Paul.  Add support for MassDelete. 
	private _onMassDelete = async (sCommandArguments) =>
	{
		const { MODULE_NAME, onUpdateComplete } = this.props;
		const { bADMIN_MODE, selectedItems } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassDelete', selectedItems);
		if ( this.ValidateOne() )
		{
			// 08/11/2020 Paul.  Confirm delete. 
			if ( window.confirm(L10n.Term('.NTC_DELETE_CONFIRMATION')) )
			{
				let arrID_LIST = [];
				for ( let id in selectedItems )
				{
					arrID_LIST.push(id);
				}
				try
				{
					if ( this.dynamicButtons.current != null )
					{
						this.dynamicButtons.current.Busy();
					}
					await MassDeleteModule(MODULE_NAME, arrID_LIST, bADMIN_MODE);
					if ( onUpdateComplete != null )
					{
						onUpdateComplete('MassDelete');
					}
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassDelete', error);
					this.setState({ error });
				}
				finally
				{
					if ( this.dynamicButtons.current != null )
					{
						this.dynamicButtons.current.NotBusy();
					}
				}
			}
		}
	}

	// 07/16/2019 Paul.  Add support for Rest API for ArchiveMoveData/ArchiveRecoverData. 
	private _onArchiveMoveData = async (sCommandArguments) =>
	{
		const { MODULE_NAME, onUpdateComplete } = this.props;
		const { selectedItems } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onArchiveMoveData', selectedItems);
		if ( this.ValidateOne() )
		{
			let arrID_LIST = [];
			for ( let id in selectedItems )
			{
				arrID_LIST.push(id);
			}
			try
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.Busy();
				}
				await ArchiveMoveData(MODULE_NAME, arrID_LIST);
				if ( onUpdateComplete != null )
				{
					onUpdateComplete('Archive.MoveData');
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onArchiveMoveData', error);
				this.setState({ error });
			}
			finally
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.NotBusy();
				}
			}
		}
	}

	private _onArchiveRecoverData = async (sCommandArguments) =>
	{
		const { MODULE_NAME, onUpdateComplete } = this.props;
		const { selectedItems } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onArchiveRecoverData', selectedItems);
		if ( this.ValidateOne() )
		{
			let arrID_LIST = [];
			for ( let id in selectedItems )
			{
				arrID_LIST.push(id);
			}
			try
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.Busy();
				}
				await ArchiveRecoverData(MODULE_NAME, arrID_LIST);
				if ( onUpdateComplete != null )
				{
					onUpdateComplete('Archive.RecoverData');
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onArchiveRecoverData', error);
				this.setState({ error });
			}
			finally
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.NotBusy();
				}
			}
		}
	}

	// 07/16/2019 Paul.  Add support for Rest API for MassSync/MassUnsync. 
	private _onSync = async (sCommandArguments) =>
	{
		const { MODULE_NAME, onUpdateComplete } = this.props;
		const { selectedItems } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSync', selectedItems);
		if ( this.ValidateOne() )
		{
			let arrID_LIST = [];
			for ( let id in selectedItems )
			{
				arrID_LIST.push(id);
			}
			try
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.Busy();
				}
				await MassSync(MODULE_NAME, arrID_LIST);
				if ( onUpdateComplete != null )
				{
					onUpdateComplete('Sync');
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSync', error);
				this.setState({ error });
			}
			finally
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.NotBusy();
				}
			}
		}
	}

	private _onUnsync = async (sCommandArguments) =>
	{
		const { MODULE_NAME } = this.props;
		const { selectedItems } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUnsync', selectedItems);
		if ( this.ValidateOne() )
		{
			let arrID_LIST = [];
			for ( let id in selectedItems )
			{
				arrID_LIST.push(id);
			}
			try
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.Busy();
				}
				await MassUnsync(MODULE_NAME, arrID_LIST);
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUnsync', error);
				this.setState({ error });
			}
			finally
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.NotBusy();
				}
			}
		}
	}

	private _onMassEnable = async (sCommandArguments) =>
	{
		const { MODULE_NAME, onUpdateComplete } = this.props;
		const { bADMIN_MODE, item, selectedItems } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassEnable', selectedItems, item);
		if ( this.ValidateOne() )
		{
			let arrID_LIST = [];
			for ( let id in selectedItems )
			{
				arrID_LIST.push(id);
			}
			try
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.Busy();
				}
				let data: any =
				{
					ID_LIST: arrID_LIST,
					ENABLE : true,
				};
				let sBody: string = JSON.stringify(data);
				let res = await CreateSplendidRequest('Administration/Exchange/Rest.svc/MassEnable', 'POST', 'application/octet-stream', sBody);
				let json = await GetSplendidResult(res);
				if ( onUpdateComplete != null )
				{
					onUpdateComplete('MassEnable');
				}
				// 04/25/2020 Paul.  Clear after update. 
				SplendidDynamic_EditView.Clear(this.refMap);
				if ( this._isMounted )
				{
					this.setState({ item: {} });
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassEnable', error);
				this.setState({ error });
			}
			finally
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.NotBusy();
				}
			}
		}
	}

	// 07/16/2019 Paul.  Add support for MassDelete. 
	private _onMassDisable = async (sCommandArguments) =>
	{
		const { MODULE_NAME, onUpdateComplete } = this.props;
		const { bADMIN_MODE, selectedItems } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassDisable', selectedItems);
		if ( this.ValidateOne() )
		{
			let arrID_LIST = [];
			for ( let id in selectedItems )
			{
				arrID_LIST.push(id);
			}
			try
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.Busy();
				}
				let data: any =
				{
					ID_LIST: arrID_LIST,
					ENABLE : false,
				};
				let sBody: string = JSON.stringify(data);
				let res = await CreateSplendidRequest('Administration/Exchange/Rest.svc/MassEnable', 'POST', 'application/octet-stream', sBody);
				let json = await GetSplendidResult(res);
				if ( onUpdateComplete != null )
				{
					onUpdateComplete('MassDisable');
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassDisable', error);
				this.setState({ error });
			}
			finally
			{
				if ( this.dynamicButtons.current != null )
				{
					this.dynamicButtons.current.NotBusy();
				}
			}
		}
	}

	private editViewCallback = (key, newValue) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.editViewCallback ' + DATA_FIELD, DATA_VALUE);
		let { item  } = this.state;
		if ( item == null )
			item = {};
		item[key] = newValue;
		if ( this._isMounted )
		{
			this.setState({ item });
		}
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		let { item } = this.state;
		if ( item == null )
			item = {};
		item[DATA_FIELD] = DATA_VALUE;
		if ( this._isMounted )
		{
			this.setState({ item });
		}
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate ' + PARENT_FIELD, DATA_VALUE);
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

	private _onSubmit = (): void =>
	{
		console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit');
		try
		{
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', error);
			this.setState({ error });
		}
	}

	private _onButtonsLoaded = async () =>
	{
		const { MODULE_NAME, archiveView } = this.props;
		if ( this.dynamicButtons.current != null )
		{
			let nACLACCESS_Archive: number = SplendidCache.GetUserAccess(MODULE_NAME, 'archive', this.constructor.name + '_onButtonsLoaded');
			let nACLACCESS_Delete : number = SplendidCache.GetUserAccess(MODULE_NAME, 'delete' , this.constructor.name + '_onButtonsLoaded');
			let nACLACCESS_Edit   : number = SplendidCache.GetUserAccess(MODULE_NAME, 'edit'   , this.constructor.name + '_onButtonsLoaded');
			this.dynamicButtons.current.ShowButton('MassUpdate'         , nACLACCESS_Edit   >= 0);
			this.dynamicButtons.current.ShowButton('MassDelete'         , nACLACCESS_Delete >= 0);
			this.dynamicButtons.current.ShowButton('Archive.MoveData'   , (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) && !archiveView && Crm_Modules.ArchiveEnabled(MODULE_NAME));
			this.dynamicButtons.current.ShowButton('Archive.RecoverData', (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) &&  archiveView && Crm_Modules.ArchiveEnabled(MODULE_NAME));
			this.dynamicButtons.current.ShowButton('Sync'               , Crm_Modules.ExchangeFolders(MODULE_NAME) && Security.HasExchangeAlias());
			this.dynamicButtons.current.ShowButton('Unsync'             , Crm_Modules.ExchangeFolders(MODULE_NAME) && Security.HasExchangeAlias());
		}
	}

	public render()
	{
		const { MODULE_NAME, archiveView } = this.props;
		const { error, layout, item, initialOpen } = this.state;
		this.refMap = {};
		// 07/10/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( SplendidCache.IsInitialized )
		{
			this.refMap = {};
			if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
			{
				if ( initialOpen )
				{
					return (<React.Fragment>
						<table className="MassUpdateHeaderFrame" cellSpacing="1" cellPadding="0" style={ {width: '100%', border: 'none'} }>
							<tbody><tr>
								<td style={ {width: '99%', whiteSpace: 'nowrap'} }>
									<span className="MassUpdateHeaderName">{ L10n.Term('.LBL_MASS_UPDATE_TITLE') }</span>
								</td>
								<td>
									<input type="submit" className="MassUpdateHeaderFirstButton" value={ '  ' + L10n.Term('.LBL_UPDATE') + '  ' } title={ L10n.Term('.LBL_UPDATE') } onClick={ () => this.Page_Command('MassUpdate', null) } />
								</td>
								<td style={ {verticalAlign: 'center'} }>
									<span style={ {cursor: 'pointer', margin: '6px'} } onClick={ () => this.Page_Command('ToggleMassUpdate', null) }>
										<FontAwesomeIcon icon="times" size='2x' />
									</span>
								</td>
							</tr></tbody>
						</table>
						<ErrorComponent error={ error } />
						{ layout && !archiveView
						? SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, this.editViewCallback, this._createDependency, null, this._onChange, this._onUpdate, this._onSubmit, 'tabForm tabMassUpdate', this.Page_Command, false)
						: null
						}
					</React.Fragment>);
				}
				else
				{
					return null;
				}
			}
			else
			{
				// 10/28/2020 Paul.  Must use ArchiveView buttons when in archive view. 
				return (<Collapsable key={ MODULE_NAME + '.MassUpdate.Title' } name={ L10n.Term('.LBL_MASS_UPDATE_TITLE') } initialOpen={ initialOpen } onToggle={ (open) => this.onToggleCollapse(open) }>
					<DynamicButtons
						key={ MODULE_NAME + '.MassUpdate.Buttons' }
						ButtonStyle="MassUpdateHeader"
						VIEW_NAME={ MODULE_NAME + '.MassUpdate' + (archiveView ? '.ArchiveView' : '') }
						row={ null }
						Page_Command={ this.Page_Command }
						onLayoutLoaded={ this._onButtonsLoaded }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.dynamicButtons }
					/>
					<ErrorComponent error={ error } />
					{ layout && !archiveView
					? SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, this.editViewCallback, this._createDependency, null, this._onChange, this._onUpdate, this._onSubmit, 'tabForm tabMassUpdate', this.Page_Command, false)
					: null
					}
				</Collapsable>);
			}
		}
		else
		{
			return null;
		}
	}
}

