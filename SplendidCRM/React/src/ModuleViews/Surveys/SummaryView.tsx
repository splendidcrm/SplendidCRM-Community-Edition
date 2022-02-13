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
import { RouteComponentProps, withRouter }            from 'react-router-dom'                          ;
import { observer }                                   from 'mobx-react'                                ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome'            ;
// 2. Store and Types. 
import { IDetailViewProps, DetailComponent }          from '../../types/DetailComponent'               ;
import ACL_ACCESS                                     from '../../types/ACL_ACCESS'                    ;
import { HeaderButtons }                              from '../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                            from '../../scripts/Sql'                         ;
import L10n                                           from '../../scripts/L10n'                        ;
import Security                                       from '../../scripts/Security'                    ;
import Credentials                                    from '../../scripts/Credentials'                 ;
import SplendidCache                                  from '../../scripts/SplendidCache'               ;
import { Crm_Config, Crm_Modules }                    from '../../scripts/Crm'                         ;
import { AuthenticatedMethod, LoginRedirect }         from '../../scripts/Login'                       ;
import { sPLATFORM_LAYOUT }                           from '../../scripts/SplendidInitUI'              ;
import { DetailView_LoadItem }                        from '../../scripts/DetailView'                  ;
import { isMobileDevice }                             from '../../scripts/utility'                     ;
import { LoadSurveyTheme, RenumberPages, RenumberQuestions, OneQuestionPerPage, MergeHiddenQuestions } from '../../scripts/SurveyUtils'          ;
import { DeleteModuleItem, ArchiveMoveData, ArchiveRecoverData, ExecProcedure } from '../../scripts/ModuleUpdate';
import { jsonReactState }                             from '../../scripts/Application'                 ;
// 4. Components and Views. 
import ErrorComponent                                 from '../../components/ErrorComponent'           ;
import DumpSQL                                        from '../../components/DumpSQL'                  ;
import AuditView                                      from '../../views/AuditView'                     ;
import HeaderButtonsFactory                           from '../../ThemeComponents/HeaderButtonsFactory';
import SurveyQuestionFactory                          from '../../SurveyComponents'                    ;

interface IDetailViewState
{
	__total         : number;
	__sql           : string;
	item            : any;
	MODULE_NAME     : string;  // 03/01/2019 Paul.  Parents module will be converted to actual module. 
	DETAIL_NAME     : string;
	SUB_TITLE       : any;
	auditOpen       : boolean;
	activitiesOpen  : boolean;
	archiveView     : boolean;
	archiveExists   : boolean;
	error           : any;
}

@observer
class SurveysSummaryView extends React.Component<IDetailViewProps, IDetailViewState>
{
	private _isMounted     : boolean = false;
	private refMap         : Record<string, React.RefObject<DetailComponent<any, any>>>;
	private auditView      = React.createRef<AuditView>();
	private headerButtons  = React.createRef<HeaderButtons>();

	constructor(props: IDetailViewProps)
	{
		super(props);
		let archiveView: boolean = false;
		if ( props.location.pathname.indexOf('/ArchiveView') >= 0 )
		{
			archiveView = true;
		}
		// 07/18/2021 Paul.  SummaryView will just use the same DetailView buttons. 
		let DETAIL_NAME: string = props.MODULE_NAME + '.DetailView' + sPLATFORM_LAYOUT;
		this.state =
		{
			__total         : 0,
			__sql           : null,
			item            : null,
			MODULE_NAME     : props.MODULE_NAME,
			DETAIL_NAME     ,
			SUB_TITLE       : null,
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
				const { item, DETAIL_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate ' + DETAIL_NAME, item);
				if ( error == null )
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
			const { item, DETAIL_NAME, error } = this.state;
			if ( error == null )
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
			let link = document.createElement('link');
			link.href = Credentials.RemoteServer + 'Surveys/summary.css';
			link.rel  = 'stylesheet';
			link.type = 'text/css';
	
			let bStylesheetExists = false;
			let arrLinks = document.getElementsByTagName('link');
			for ( let i = 0; i < arrLinks.length; i++ )
			{
				let sLink: string = arrLinks[i].href;
				if ( sLink == link.href )
				{
					bStylesheetExists = true;
					break;
				}
			}
			if ( !bStylesheetExists )
			{
				document.head.appendChild(link);
			}
			await this.load(MODULE_NAME, ID);
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
			await this.LoadItem(sMODULE_NAME, sID);
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
			// 11/19/2019 Paul.  Change to allow return of SQL. 
			const d = await DetailView_LoadItem(sMODULE_NAME, sID, false, archiveView);
			if ( this._isMounted )
			{
				let item: any = d.results;
				if ( item != null )
				{
					let SURVEY_THEME_ID: string = item['SURVEY_THEME_ID'];
					if ( Sql.IsEmptyGuid(SURVEY_THEME_ID) )
						SURVEY_THEME_ID = Crm_Config.ToString('Surveys.DefaultTheme');
					LoadSurveyTheme(SURVEY_THEME_ID);
					// 12/27/2015 Paul.  On a mobile device, place each question on it's own page. 
					// By creating the mobile pages here, not much else needs to change. 
					// 01/01/2016 Paul.  Catalin wants to force page navigation for each question, just like mobile navigation. 
					if ( isMobileDevice() || Sql.ToString(item.SURVEY_STYLE) == 'One Question Per Page' )
					{
						item.SURVEY_PAGES = OneQuestionPerPage(item.SURVEY_PAGES);
					}
					// 11/10/2018 Paul.  Hidden questions will remain on the page, but we need to prevent them from being on their own page. 
					// So move them to the first page. 
					MergeHiddenQuestions(item.SURVEY_PAGES);
					RenumberPages(item);
					if ( item.SURVEY_PAGES != null )
					{
						for ( let i: number = 0; i < item.SURVEY_PAGES.length; i++ )
						{
							let page: any = item.SURVEY_PAGES[i];
							RenumberQuestions(page);
						}
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', item);
				// 11/23/2020 Paul.  Update document title. 
				Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
				let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
				this.setState({ item, SUB_TITLE, __sql: d.__sql });
				// 04/29/2019 Paul.  Manually add to the list so that we do not need to request an update. 
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
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
			// 12/18/2019 Paul.  Display archived message if the record has been archived. 
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
					// 12/18/2019 Paul.  Display original error, not the archive error. 
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

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, history } = this.props;
		const { MODULE_NAME } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
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
			// 02/10/2021 Paul.  Enable support for Archive.ViewData. 
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
			// 10/24/2014 Paul.  Need to provide a way to delete all survey results. 
			case 'Survey.DeleteResults':
			{
				try
				{
					let obj: any = { ID };
					await ExecProcedure('spSURVEYS_DeleteResults', obj);
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
		const { MODULE_NAME } = this.state;
		// 08/12/2019 Paul.  Here is where we can disable buttons immediately after they were loaded. 
		if ( this.headerButtons.current != null )
		{
			let nACLACCESS_Archive: number = SplendidCache.GetUserAccess(MODULE_NAME, 'archive', this.constructor.name + '._onButtonsLoaded');
			this.headerButtons.current.ShowButton('Archive.MoveData'   , (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) && !this.ArchiveView() && Crm_Modules.ArchiveEnabled(MODULE_NAME));
			this.headerButtons.current.ShowButton('Archive.RecoverData', (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) &&  this.ArchiveView() && Crm_Modules.ArchiveEnabled(MODULE_NAME));
			// 08/13/2019 Paul.  PersonalInfo only applies to Accounts, Contacts, Leads and Prospects. 
			this.headerButtons.current.ShowButton('PersonalInfo'       , Crm_Config.enable_data_privacy());
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

	public render()
	{
		const { ID } = this.props;
		const { item, MODULE_NAME, DETAIL_NAME, SUB_TITLE, auditOpen, activitiesOpen, archiveExists, error } = this.state;
		const { __total, __sql } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', item);
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		// 05/15/2018 Paul.  Defer process button logic. 
		// 06/26/2019 Paul.  Specify a key so that SplendidGrid will get componentDidMount when changing views. 
		this.refMap = {};
		if ( SplendidCache.IsInitialized && item )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
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
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, enableFavorites: true, error, enableHelp: true, helpName: 'DetailView', ButtonStyle: 'ModuleHeader', VIEW_NAME: MODULE_NAME + '.DetailView', LINK_NAME: MODULE_NAME + '.SummaryView', row: item, Page_Command: this.Page_Command, showButtons: true, showProcess: true, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<DumpSQL SQL={ __sql } />
				<div id="content">
					<div id='divSurveyTitle' className='SurveyTitle'>{ item['NAME'] }</div>
					<div id='divSurveyPages'>
					{ item.SURVEY_PAGES
					? item.SURVEY_PAGES.map((rowSURVEY_PAGE, index) => 
					{
						return (
						<div className='SurveyPage'>
							<div id={ rowSURVEY_PAGE.ID + '_Title' } className='SurveyPageTitle'>
								{ rowSURVEY_PAGE.NAME }
							</div>
							{ !Sql.IsEmptyString(rowSURVEY_PAGE.DESCRIPTION)
							? <div id={ rowSURVEY_PAGE.ID + '_Description' } className='SurveyPageDescription'>
								{ rowSURVEY_PAGE.DESCRIPTION }
							</div>
							: null
							}
							{ rowSURVEY_PAGE.SURVEY_QUESTIONS
							? rowSURVEY_PAGE.SURVEY_QUESTIONS.map((rowQUESTION, index) => 
							{
								// 11/10/2018 Paul.  Provide a way to get a hidden value for lead population. 
								if ( rowQUESTION.QUESTION_TYPE == 'Plain Text' || rowQUESTION.QUESTION_TYPE == 'Image' || rowQUESTION.QUESTION_TYPE == 'Hidden' )
									return (null);
								else
								{
									let question: any = SurveyQuestionFactory(rowQUESTION);
									return (
									<table cellPadding={ 0 } cellSpacing={ 0 } className='SurveyPageBody SurveyQuestionFrame' style={ {width: '100%', border: 'none'} }>
										<tbody>
											<tr>
												<td valign='top'>
													{ question
													? <div id={ rowQUESTION.ID + '_Frame' } className='SurveyQuestionSummaryFrame'>
														{ React.createElement(question, { row: rowQUESTION, displayMode: 'Summary' }) }
													</div>
													: null
													}
												</td>
											</tr>
										</tbody>
									</table>
									);
								}
							})
							: null
							}
						</div>
						);
					})
					: null
					}
					</div>
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

export default withRouter(SurveysSummaryView);
