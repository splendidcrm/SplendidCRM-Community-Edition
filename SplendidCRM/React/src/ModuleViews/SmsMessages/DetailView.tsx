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
import { RouteComponentProps, withRouter }            from '../Router5'                          ;
import { observer }                                   from 'mobx-react'                                ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome'            ;
// 2. Store and Types. 
import { IDetailViewProps, DetailComponent }          from '../../types/DetailComponent'               ;
import ACL_ACCESS                                     from '../../types/ACL_ACCESS'                    ;
import DETAILVIEWS_FIELD                              from '../../types/DETAILVIEWS_FIELD'             ;
import { HeaderButtons }                              from '../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                            from '../../scripts/Sql'                         ;
import L10n                                           from '../../scripts/L10n'                        ;
import Security                                       from '../../scripts/Security'                    ;
import Credentials                                    from '../../scripts/Credentials'                 ;
import SplendidCache                                  from '../../scripts/SplendidCache'               ;
import SplendidDynamic_DetailView                     from '../../scripts/SplendidDynamic_DetailView'  ;
import { Crm_Config, Crm_Modules }                    from '../../scripts/Crm'                         ;
import { XssFilter }                                  from '../../scripts/EmailUtils'                  ;
import { AuthenticatedMethod, LoginRedirect }         from '../../scripts/Login'                       ;
import { sPLATFORM_LAYOUT }                           from '../../scripts/SplendidInitUI'              ;
import { DetailView_LoadItem, DetailView_LoadLayout, DetailView_ActivateTab } from '../../scripts/DetailView'                  ;
import { DeleteModuleItem, ArchiveMoveData, ArchiveRecoverData } from '../../scripts/ModuleUpdate'     ;
import { jsonReactState }                             from '../../scripts/Application'                 ;
// 4. Components and Views. 
import ErrorComponent                                 from '../../components/ErrorComponent'           ;
import DumpSQL                                        from '../../components/DumpSQL'                  ;
import DetailViewRelationships                        from '../../views/DetailViewRelationships'       ;
import AuditView                                      from '../../views/AuditView'                     ;
import ActivitiesPopupView                            from '../../views/ActivitiesPopupView'           ;
import HeaderButtonsFactory                           from '../../ThemeComponents/HeaderButtonsFactory';
import LayoutTabs                                     from '../../components/LayoutTabs'               ;

interface IDetailViewState
{
	__total         : number;
	__sql           : string;
	item            : any;
	layout          : any;
	MODULE_NAME     : string;
	MODULE_TITLE    : string;
	DETAIL_NAME     : string;
	BUTTON_LAYOUT   : string;
	SUB_TITLE       : any;
	EMAIL_TYPE      : string;
	auditOpen       : boolean;
	activitiesOpen  : boolean;
	archiveView     : boolean;
	archiveExists   : boolean;
	error           : any;
}

// 02/05/2023 Paul.  Add support for SMS Messages. 
@observer
class SmsMessagesDetailView extends React.Component<IDetailViewProps, IDetailViewState>
{
	private _isMounted     : boolean = false;
	private refMap         : Record<string, React.RefObject<DetailComponent<any, any>>>;
	private auditView      = React.createRef<AuditView>();
	private activitiesView = React.createRef<ActivitiesPopupView>();
	private headerButtons  = React.createRef<HeaderButtons>();

	constructor(props: IDetailViewProps)
	{
		super(props);
		let archiveView: boolean = false;
		if ( props.location.pathname.indexOf('/ArchiveView') >= 0 )
		{
			archiveView = true;
		}
		let DETAIL_NAME  : string = props.MODULE_NAME + (archiveView ? '.ArchiveView' : '.DetailView') + sPLATFORM_LAYOUT;
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			DETAIL_NAME = props.LAYOUT_NAME;
		}
		this.state =
		{
			__total         : 0,
			__sql           : null,
			item            : null,
			layout          : null,
			MODULE_NAME     : props.MODULE_NAME,
			MODULE_TITLE    : null,
			DETAIL_NAME     ,
			BUTTON_LAYOUT   : DETAIL_NAME,
			SUB_TITLE       : null,
			EMAIL_TYPE      : 'draft',
			auditOpen       : false,
			activitiesOpen  : false,
			archiveView     ,
			archiveExists   : false,
			error           : null,
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
				if ( jsonReactState == null )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount jsonReactState is null');
				}
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
				await this.preload();
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

	async componentDidUpdate(prevProps: IDetailViewProps)
	{
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
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

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private preload = async () =>
	{
		const { ID } = this.props;
		const { MODULE_NAME } = this.state;
		try
		{
			let sMODULE_NAME = MODULE_NAME;
			await this.load(sMODULE_NAME, ID);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.preload', error);
			this.setState({ error });
		}
	}

	private load = async (sMODULE_NAME: string, sID: string) =>
	{
		const { DETAIL_NAME } = this.state;
		try
		{
			const layout = DetailView_LoadLayout(DETAIL_NAME);
			if ( this._isMounted )
			{
				if ( layout != null )
				{
					for ( let i = 0; i < layout.length; i++ )
					{
						let lay: DETAILVIEWS_FIELD = layout[i];
						if ( (lay.DATA_FIELD == 'DESCRIPTION' || lay.DATA_FIELD == 'DESCRIPTION_HTML') && lay.FIELD_TYPE == 'TextBox' )
						{
							lay.DATA_FORMAT = 'raw';
							break;
						}
					}
				}
				this.setState({ layout: layout, item: null });
				await this.LoadItem(sMODULE_NAME, sID);
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
		const { archiveView } = this.state;
		try
		{
			const d = await DetailView_LoadItem(sMODULE_NAME, sID, false, archiveView);
			if ( this._isMounted )
			{
				let item         : any    = d.results;
				let SUB_TITLE    : string = null;
				let EMAIL_TYPE   : string = null;
				let MODULE_TITLE : string = L10n.Term('.moduleList.' + sMODULE_NAME);
				let BUTTON_LAYOUT: string = this.state.DETAIL_NAME;
				if ( item != null )
				{
					EMAIL_TYPE   = Sql.ToString(item['TYPE'  ]).toLowerCase();
					SUB_TITLE    = Sql.ToString(item['NAME'  ]);
					SUB_TITLE = XssFilter(SUB_TITLE, Crm_Config.ToString('email_xss'));
					item['NAME'] = SUB_TITLE;
					document.title = L10n.Term('.moduleList.' + sMODULE_NAME) + ' - ' + SUB_TITLE;
					window.scroll(0, 0);
					switch ( EMAIL_TYPE )
					{
						case 'archived':
							MODULE_TITLE  = L10n.Term('SmsMessages.LBL_ARCHIVED_MODULE_NAME');
							BUTTON_LAYOUT = sMODULE_NAME + '.InboundView';
							break;
						case 'inbound' :
							MODULE_TITLE  = L10n.Term('SmsMessages.LBL_INBOUND_TITLE'       );
							BUTTON_LAYOUT = sMODULE_NAME + '.InboundView';
							break;
						case 'out'     :
							MODULE_TITLE  = L10n.Term('SmsMessages.LBL_LIST_FORM_SENT_TITLE');
							break;
						case 'sent'    :
							MODULE_TITLE  = L10n.Term('SmsMessages.LBL_LIST_FORM_SENT_TITLE');
							BUTTON_LAYOUT = sMODULE_NAME + '.InboundView';
							break;
						case 'campaign':
							MODULE_TITLE  = L10n.Term('SmsMessages.LBL_LIST_FORM_SENT_TITLE');
							break;
						default        :
							EMAIL_TYPE    = 'draft';
							MODULE_TITLE  = L10n.Term('SmsMessages.LBL_COMPOSE_MODULE_NAME' );
							// 04/16/2021 Paul.  Do not redirect during precompile as it stops it. 
							if ( !this.props.isPrecompile )
							{
								this.props.history.push('/Reset/' + sMODULE_NAME + '/Edit/' + sID);
							}
							break;
					}
				}
				this.setState(
				{
					item         ,
					BUTTON_LAYOUT,
					MODULE_TITLE ,
					SUB_TITLE    ,
					EMAIL_TYPE   ,
					__sql        : d.__sql
				});
				if ( item != null )
				{
					let sNAME = Sql.ToString(item['NAME']);
					if ( !Sql.IsEmptyString(sNAME) )
					{
						SplendidCache.AddLastViewed(sMODULE_NAME, sID, sNAME);
					}
				}
			}
		}
		catch(error)
		{
			if ( !archiveView )
			{
				try
				{
					const d = await DetailView_LoadItem(sMODULE_NAME, sID, false, true);
					if ( this._isMounted )
					{
						let item: any = d.results;
						Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
						let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
						this.setState({ SUB_TITLE, __sql: d.__sql, archiveExists: true, error: L10n.Term('.LBL_ARCHIVED_RECORD') });
					}
				}
				catch(errorArchive)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error, errorArchive);
					this.setState({ error });
				}
			}
			else
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.setState({ error });
			}
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, history } = this.props;
		const { MODULE_NAME } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
			case 'Forward':
			{
				history.push(`/Reset/${MODULE_NAME}/Duplicate/${ID}?type=forward`);
				break;
			}
			case 'Reply':
			{
				history.push(`/Reset/${MODULE_NAME}/Duplicate/${ID}?type=reply`);
				break;
			}
			case 'Reply All':
			{
				history.push(`/Reset/${MODULE_NAME}/Duplicate/${ID}?type=replyall`);
				break;
			}
			case 'Edit':
			{
				history.push(`/Reset/${MODULE_NAME}/Edit/${ID}`);
				break;
			}
			case 'Duplicate':
			{
				history.push(`/Reset/${MODULE_NAME}/Duplicate/${ID}`);
				break;
			}
			case 'Convert':
			{
				let sNewModule: string = sCommandArguments;
				if ( !Sql.IsEmptyString(sNewModule) )
				{
					history.push(`/Reset/${sNewModule}/Convert/${MODULE_NAME}/${ID}`);
				}
				else
				{
					this.setState( {error: 'NewModule is null'} );
				}
				break;
			}
			case 'Archive.ViewData':
			{
				history.push(`/Reset/${MODULE_NAME}/ArchiveView/${ID}`);
				break;
			}
			case 'Archive.MoveData':
			{
				await this._onArchiveMoveData();
				break;
			}
			case 'Archive.RecoverData':
			{
				await this._onArchiveRecoverData();
				break;
			}
			case 'Cancel':
			{
				history.push(`/Reset/${MODULE_NAME}/List`);
				break;
			}
			case 'Delete':
			{
				try
				{
					await DeleteModuleItem(MODULE_NAME, ID);
					history.push(`/Reset/${MODULE_NAME}/List`);
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
					this.setState({ error });
				}
				break;
			}
			case 'ViewLog':
			{
				if ( this.auditView.current != null )
				{
					await this.auditView.current.loadData();
					this.setState({ auditOpen: true });
				}
				break;
			}
			case 'ViewRelatedActivities':
			{
				if ( this.activitiesView.current != null )
				{
					let bIncludeRelationships: boolean = Sql.ToString(sCommandArguments).indexOf('IncludeRelationships=1') >= 0;
					await this.activitiesView.current.loadData(bIncludeRelationships);
					this.setState({ activitiesOpen: true });
				}
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

	private _onArchiveMoveData = async () =>
	{
		const { ID, history } = this.props;
		const { MODULE_NAME } = this.props;
		let arrID_LIST = [];
		arrID_LIST.push(ID);
		try
		{
			if ( this.headerButtons.current != null )
			{
				this.headerButtons.current.Busy();
			}
			await ArchiveMoveData(MODULE_NAME, arrID_LIST);
			history.push(`/Reset/${MODULE_NAME}/ArchiveView/${ID}`);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onArchiveMoveData', error);
			this.setState({ error });
		}
		finally
		{
			if ( this.headerButtons.current != null )
			{
				this.headerButtons.current.NotBusy();
			}
		}
	}

	private _onArchiveRecoverData = async () =>
	{
		const { MODULE_NAME, ID, history } = this.props;
		let arrID_LIST = [];
		arrID_LIST.push(ID);
		try
		{
			if ( this.headerButtons.current != null )
			{
				this.headerButtons.current.Busy();
			}
			await ArchiveRecoverData(MODULE_NAME, arrID_LIST);
			history.push(`/Reset/${MODULE_NAME}/View/${ID}`);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onArchiveRecoverData', error);
			this.setState({ error });
		}
		finally
		{
			if ( this.headerButtons.current != null )
			{
				this.headerButtons.current.NotBusy();
			}
		}
	}

	private ArchiveView = () =>
	{
		return this.state.archiveView;
	}

	private ArchiveViewEnabled = () =>
	{
		const { MODULE_NAME } = this.props;
		return this.ArchiveView() && Crm_Modules.ArchiveEnabled(MODULE_NAME);
	}

	private _onButtonsLoaded = async () =>
	{
		const { item, MODULE_NAME, EMAIL_TYPE } = this.state;
		if ( this.headerButtons.current != null )
		{
			let nACLACCESS_Archive: number = SplendidCache.GetUserAccess  (MODULE_NAME, 'archive', this.constructor.name + '._onButtonsLoaded');
			let nEDIT_ACLACCESS   : number = SplendidCache.GetRecordAccess(item, MODULE_NAME, "edit"  , 'ASSIGNED_USER_ID');
			let nDELETE_ACLACCESS : number = SplendidCache.GetRecordAccess(item, MODULE_NAME, "remove", 'ASSIGNED_USER_ID');
			this.headerButtons.current.ShowButton('Archive.MoveData'   , (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) && !this.ArchiveView() && Crm_Modules.ArchiveEnabled(MODULE_NAME));
			this.headerButtons.current.ShowButton('Archive.RecoverData', (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) &&  this.ArchiveView() && Crm_Modules.ArchiveEnabled(MODULE_NAME));
			switch ( EMAIL_TYPE )
			{
				case 'archived':
					this.headerButtons.current.ShowButton("Duplicate", (nEDIT_ACLACCESS   >= 0));
					this.headerButtons.current.ShowButton("Edit"     , (nEDIT_ACLACCESS   >= 0));
					this.headerButtons.current.ShowButton("Delete"   , (nDELETE_ACLACCESS >= 0));
					break;
				case 'inbound' :
					this.headerButtons.current.ShowButton("Duplicate", (nEDIT_ACLACCESS   >= 0));
					this.headerButtons.current.ShowButton("Edit"     , (nEDIT_ACLACCESS   >= 0));
					this.headerButtons.current.ShowButton("Delete"   , (nDELETE_ACLACCESS >= 0));
					break;
				case 'out'     :
					// 01/21/2006 Paul.  Sent emails cannot be edited or duplicated. 
					// 12/20/2006 Paul.  Messages have type "out" when they are ready to send. 
					this.headerButtons.current.ShowButton('Edit'     , false                   );
					// 11/05/2020 Paul.  Allow duplicate if send error. 
					this.headerButtons.current.ShowButton('Duplicate', false);
					this.headerButtons.current.ShowButton("Delete"   , (nDELETE_ACLACCESS >= 0));
					break;
				case 'sent'    :
					// 12/20/2006 Paul.  Sent emails cannot be edited or duplicated. 
					this.headerButtons.current.ShowButton('Edit'     , false                   );
					this.headerButtons.current.ShowButton('Duplicate', false                   );
					this.headerButtons.current.ShowButton("Delete"   , (nDELETE_ACLACCESS >= 0));
					break;
				case 'campaign':
					// 12/20/2006 Paul.  Sent emails cannot be edited or duplicated. 
					this.headerButtons.current.ShowButton('Edit'     , false                   );
					this.headerButtons.current.ShowButton('Duplicate', false                   );
					this.headerButtons.current.ShowButton("Delete"   , (nDELETE_ACLACCESS >= 0));
					break;
				default        :
					this.headerButtons.current.ShowButton('Duplicate', false                   );
					break;
			}
		}
	}

	private _onAuditClose = () =>
	{
		this.setState({ auditOpen: false });
	}

	private _onActivitiesClose = () =>
	{
		this.setState({ activitiesOpen: false });
	}

	private _onTabChange = (nActiveTabIndex) =>
	{
		let { layout } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTabChange', nActiveTabIndex);
		DetailView_ActivateTab(layout, nActiveTabIndex);
		this.setState({ layout });
	}

	public render()
	{
		const { ID } = this.props;
		const { item, layout, MODULE_NAME, MODULE_TITLE, DETAIL_NAME, BUTTON_LAYOUT, SUB_TITLE, auditOpen, activitiesOpen, archiveExists, error } = this.state;
		const { __total, __sql } = this.state;
		this.refMap = {};
		if ( SplendidCache.IsInitialized && layout && item )
		{
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<React.Fragment>
				<AuditView
					isOpen={ auditOpen }
					callback={ this._onAuditClose }
					MODULE_NAME={ MODULE_NAME }
					NAME={ item.NAME }
					ID={ ID }
					ref={ this.auditView }
				/>
				<ActivitiesPopupView
					isOpen={ activitiesOpen }
					callback={ this._onActivitiesClose }
					PARENT_TYPE={ MODULE_NAME }
					PARENT_ID={ ID }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.activitiesView }
				/>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_TITLE, MODULE_NAME, ID, SUB_TITLE, enableFavorites: true, error, enableHelp: true, helpName: 'DetailView', ButtonStyle: 'ModuleHeader', VIEW_NAME: BUTTON_LAYOUT, row: item, Page_Command: this.Page_Command, showButtons: true, showProcess: true, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<DumpSQL SQL={ __sql } />
				<LayoutTabs layout={ layout } onTabChange={ this._onTabChange } />
				<div id="content">
					{ SplendidDynamic_DetailView.AppendDetailViewFields(item, layout, this.refMap, 'tabDetailView', null, this.Page_Command) }
					<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 100%'} }>
						<div id='ctlDetailView_SmsMessages_DetailView_ATTACHMENTS_LABEL' className='tabDetailViewDL' style={ {width: '15%'} }>
							{ L10n.Term('SmsMessages.LBL_ATTACHMENT') }
						</div>
						<div id='ctlDetailView_SmsMessages_DetailView_ATTACHMENT' className='tabDetailViewDF' style={ {width: '85%'} }>
						{ item && item.ATTACHMENTS
						? item.ATTACHMENTS.map((attachment, index) => 
							{
								return (
								<div>
									<a id={ attachment.NOTE_ATTACHMENT_ID } key={ attachment.NOTE_ATTACHMENT_ID } href={ Credentials.RemoteServer + 'Notes/Attachment.aspx?ID=' + attachment.NOTE_ATTACHMENT_ID } target='_blank'>{ attachment.FILENAME }</a>
								</div>);
							})
						: null
						}
						</div>
					</div>
					<br />
					<DetailViewRelationships key={ this.props.MODULE_NAME + '_DetailViewRelationships' } PARENT_TYPE={ this.props.MODULE_NAME } DETAIL_NAME={ DETAIL_NAME } row={ item } isPrecompile={ this.props.isPrecompile } onComponentComplete={ this.onRelationshipsComplete } />
				</div>
			</React.Fragment>
			);
		}
		else if ( archiveExists )
		{
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			if ( headerButtons )
				return React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, enableFavorites: false, error, enableHelp: false, helpName: null, ButtonStyle: 'ModuleHeader', VIEW_NAME: '.ArchiveExists', row: item, Page_Command: this.Page_Command, showButtons: true, showProcess: false, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons });
			else
				return (<ErrorComponent error={error} />);
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

export default withRouter(SmsMessagesDetailView);
