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
import { RouteComponentProps, withRouter }       from 'react-router-dom'                       ;
import { FontAwesomeIcon }                       from '@fortawesome/react-fontawesome'         ;
// 2. Store and Types. 
import { HeaderButtons }                         from '../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                       from '../scripts/Sql'                         ;
import L10n                                      from '../scripts/L10n'                        ;
import Security                                  from '../scripts/Security'                    ;
import Credentials                               from '../scripts/Credentials'                 ;
import SplendidCache                             from '../scripts/SplendidCache'               ;
import SearchBuilder                             from '../scripts/SearchBuilder'               ;
import SplendidDynamic                           from '../scripts/SplendidDynamic'             ;
import { Crm_Config }                            from '../scripts/Crm'                         ;
import { base64ArrayBuffer }                     from '../scripts/utility'                     ;
import { formatDate, FromJsonDate }              from '../scripts/Formatting'                  ;
import { screenWidth, screenHeight, StartsWith } from '../scripts/utility'                     ;
import { ListView_LoadModule }                   from '../scripts/ListView'                    ;
import { UpdateModule, UpdateModuleTable }       from '../scripts/ModuleUpdate'                ;
import { jsonReactState }                        from '../scripts/Application'                 ;
import { AuthenticatedMethod, LoginRedirect }    from '../scripts/Login'                       ;
import SignalRStore                              from '../SignalR/SignalRStore'                ;
// 4. Components and Views. 
import HeaderButtonsFactory                      from '../ThemeComponents/HeaderButtonsFactory';
import PopupView                                 from '../views/PopupView'                     ;

const MODULE_NAME       : string = 'ChatDashboard';

interface IChatDashboardViewProps extends RouteComponentProps<any>
{
}

interface IChatDashboardViewState
{
	nClientWidth           : number;
	nClientHeight          : number;
	nHeight                : number;
	error?                 : any;
	CURRENT_CHAT_CHANNEL_ID: string;
	dtChannels             : any[];
	dtMessages             : any[];
	showDescription        : any;
	showImage              : any;
	txtSearch              : string;
	popupOpen              : boolean;
	PARENT_ID              : string;
	PARENT_TYPE            : string;
	PARENT_NAME            : string;
	MESSAGE                : string;
	hidUploadNAME          : string;
	hidUploadTYPE          : string;
	hidUploadDATA          : string;
}

class ChatDashboardView extends React.Component<IChatDashboardViewProps, IChatDashboardViewState>
{
	private _isMounted        : boolean = false;
	private tabMenuRect       : Record<string, DOMRect> = {};
	private headerButtons     = React.createRef<HeaderButtons>();
	private sLongDatePattern  : string = null;
	private nHeaderHeight     : number = 100;
	private nChatInputHeight  : number = 60;
	private nSearchInputHeight: number = 30;
	private nCopyrightHeight  : number = 40;
	private divChatDashboard_fileUpload = React.createRef<HTMLInputElement>();

	constructor(props: IChatDashboardViewProps)
	{
		super(props);
		Credentials.SetViewMode('DashboardView');
		let nClientWidth : number = screenWidth();
		let nClientHeight: number = screenHeight();
		let CURRENT_CHAT_CHANNEL_ID: string = Sql.ToGuid(localStorage.getItem('LastChatChannel'));
		this.state =
		{
			nClientWidth           ,
			nClientHeight          ,
			nHeight                : nClientHeight,
			CURRENT_CHAT_CHANNEL_ID,
			dtChannels             : [],
			dtMessages             : null,
			showDescription        : {},
			showImage              : {},
			txtSearch              : '',
			popupOpen              : false,
			PARENT_ID              : null,
			PARENT_TYPE            : null,
			PARENT_NAME            : null,
			MESSAGE                : null,
			hidUploadNAME          : null,
			hidUploadTYPE          : null,
			hidUploadDATA          : null,
		};
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
				document.title = L10n.Term(MODULE_NAME + ".LBL_LIST_FORM_TITLE");
				window.scroll(0, 0);
				await this.load();
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			}
			window.addEventListener("resize", this.updateDimensions);
			if ( SignalRStore.chatManager )
			{
				SignalRStore.chatManager.on('newMessage', this.newMessage);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	async componentDidUpdate(prevProps: IChatDashboardViewProps)
	{
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
		window.removeEventListener("resize", this.updateDimensions);
		if ( SignalRStore.chatManager )
		{
			SignalRStore.chatManager.off('newMessage', this.newMessage);
		}
	}

	private newMessage = (CHAT_CHANNEL_ID, ID, NAME, DESCRIPTION, DATE_ENTERED, PARENT_ID, PARENT_TYPE, PARENT_NAME, CREATED_BY_ID, CREATED_BY, CREATED_BY_PICTURE, NOTE_ATTACHMENT_ID, FILENAME, FILE_EXT, FILE_MIME_TYPE, FILE_SIZE, ATTACHMENT_READY) =>
	{
		let { dtMessages } = this.state;
		let row: any = { CHAT_CHANNEL_ID, ID, NAME, DESCRIPTION, DATE_ENTERED, PARENT_ID, PARENT_TYPE, PARENT_NAME, CREATED_BY_ID, CREATED_BY, CREATED_BY_PICTURE, NOTE_ATTACHMENT_ID, FILENAME, FILE_EXT, FILE_MIME_TYPE, FILE_SIZE, ATTACHMENT_READY };
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.newMessage', row);
		if ( dtMessages == null )
		{
			dtMessages = [];
		}
		dtMessages.splice(0, 0, row);
		this.setState({ dtMessages });
	}

	private updateDimensions = () =>
	{
		let nClientWidth : number = screenWidth();
		let nClientHeight: number = screenHeight();
		this.setState(
		{
			nClientWidth ,
			nClientHeight,
		});
	}

	private load = async () =>
	{
		let { CURRENT_CHAT_CHANNEL_ID } = this.state;
		try
		{
			let sMODULE_NAME   : string = 'ChatChannels';
			let sSORT_FIELD    : string = 'NAME';
			let sSORT_DIRECTION: string = 'asc';
			let sSELECT_FIELDS : string = 'ID, NAME, PARENT_ID, PARENT_TYPE, PARENT_NAME';
			let sSEARCH_FILTER : string = '';
			let d = await ListView_LoadModule(sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT_FIELDS, sSEARCH_FILTER, null);
			if ( d != null && d.results != null )
			{
				let dtChannels: any[] = d.results;
				let dtMessages: any[] = null;
				if ( Sql.IsEmptyGuid(CURRENT_CHAT_CHANNEL_ID) && dtChannels.length > 0 )
				{
					CURRENT_CHAT_CHANNEL_ID = dtChannels[0].ID;
				}
				if ( !Sql.IsEmptyGuid(CURRENT_CHAT_CHANNEL_ID) )
				{
					dtMessages = await this.LoadChannel(CURRENT_CHAT_CHANNEL_ID);
				}
				this.setState(
				{
					CURRENT_CHAT_CHANNEL_ID,
					dtChannels,
					dtMessages,
				});
			}
		}
		catch(error)
		{
			this.setState({ error });
		}
	}

	private LoadChannel = async (sCHAT_CHANNEL_ID: string) =>
	{
		const { txtSearch } = this.state;
		let dtMessages: any[] = null;
		try
		{
			let sMODULE_NAME   : string = 'ChatMessages';
			let sSORT_FIELD    : string = 'DATE_ENTERED';
			let sSORT_DIRECTION: string = 'desc';
			let sSELECT_FIELDS : string = 'ID, NAME, DESCRIPTION, DATE_ENTERED, PARENT_ID, PARENT_TYPE, PARENT_NAME, CREATED_BY, CREATED_BY_PICTURE, NOTE_ATTACHMENT_ID, FILENAME, FILE_EXT, FILE_MIME_TYPE, FILE_SIZE, ATTACHMENT_READY';
			let sSEARCH_FILTER : string = 'CHAT_CHANNEL_ID eq \'' + sCHAT_CHANNEL_ID + '\'';
			if ( !Sql.IsEmptyString(txtSearch) )
			{
				let oSearchBuilder = new SearchBuilder();
				oSearchBuilder.Init(txtSearch);
				sSEARCH_FILTER += oSearchBuilder.BuildQuery(' and ', 'DESCRIPTION', txtSearch);
			}
			let d = await ListView_LoadModule(sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT_FIELDS, sSEARCH_FILTER, null);
			if ( d != null && d.results != null )
			{
				dtMessages = d.results;
			}
		}
		catch(error)
		{
			this.setState({ error });
		}
		return dtMessages;
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { history } = this.props;
		switch ( sCommandName )
		{
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

	private _onChangeChannel = async (sCHAT_CHANNEL_ID: string) =>
	{
		localStorage.setItem('LastChatChannel', sCHAT_CHANNEL_ID);
		let dtMessages = await this.LoadChannel(sCHAT_CHANNEL_ID);
		this.setState(
		{
			CURRENT_CHAT_CHANNEL_ID: sCHAT_CHANNEL_ID,
			dtMessages             : dtMessages,
			error                  : null,
		});
	}

	private _onParentClick = (row) =>
	{
		const { history } = this.props;
		history.push(`/Reset/${row.PARENT_TYPE}/View/${row.PARENT_ID}`);
	}

	private _onShowDescription = (ID: string, show: boolean) =>
	{
		let { showDescription } = this.state;
		showDescription[ID] = show;
		this.setState({ showDescription });
	}

	private _onShowImage = (ID: string, show: boolean) =>
	{
		let { showImage } = this.state;
		showImage[ID] = show;
		this.setState({ showImage });
	}

	private getFileSize = (row) =>
	{
		let lFILE_SIZE : number = row.FILE_SIZE;
		let sSIZE_UNITS: string = 'B';
		if ( lFILE_SIZE > 1024 )
		{
			lFILE_SIZE /= 1024;
			sSIZE_UNITS = 'KB';
			if ( lFILE_SIZE > 1024 )
			{
				lFILE_SIZE /= 1024;
				sSIZE_UNITS = 'MB';
				if ( lFILE_SIZE > 1024 )
				{
					lFILE_SIZE /= 1024;
					sSIZE_UNITS = 'GB';
					if ( lFILE_SIZE > 1024 )
					{
						lFILE_SIZE /= 1024;
						sSIZE_UNITS = 'TB';
					}
				}
			}
		}
		let sFILE_SIZE: string = Math.floor(lFILE_SIZE).toString() + sSIZE_UNITS;
		return sFILE_SIZE;
	}

	private _onMESSAGE_Change = (e) =>
	{
		this.setState({ MESSAGE: e.target.value, error: null });
	}

	private _onSearchChange = (e) =>
	{
		this.setState({ txtSearch: e.target.value, error: null });
	}

	private _onPARENT_TYPE_Change = (e) =>
	{
		this.setState({ PARENT_TYPE: e.target.value, error: null });
	}

	private _onSelectParent = (value: { Action: string, ID: string, NAME: string, PROCESS_NOTES: string }) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectParent', value);
		if ( value.Action == 'SingleSelect' )
		{
			this.setState({ popupOpen: false, PARENT_ID: value.ID, PARENT_NAME: value.NAME });
		}
		else if ( value.Action == 'Close' )
		{
			this.setState({ popupOpen: false });
		}
	}

	private _onPARENT_NAME_Clear = () =>
	{
		this.setState({ PARENT_ID: '', PARENT_NAME: '', error: null });
	}

	private _onPARENT_NAME_Select = () =>
	{
		this.setState({ popupOpen: true, error: null });
	}

	private _onFILE_Clear = () =>
	{
		this.setState({ hidUploadNAME: '', hidUploadTYPE: '', hidUploadDATA: '' });
		if ( this.divChatDashboard_fileUpload.current )
		{
			this.divChatDashboard_fileUpload.current.value = '';
		}
	}

	private _onFILE_Upload = (e) =>
	{
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
						let hidUploadNAME: string = file.name;
						let hidUploadTYPE: string = file.type;
						let hidUploadDATA: string = base64ArrayBuffer(arrayBuffer);
						this.setState(
						{
							hidUploadNAME,
							hidUploadTYPE,
							hidUploadDATA,
							error        : null,
						});
					};
					reader.readAsArrayBuffer(file);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onAttachment', error);
		}
	}

	private _onSubmit = async () =>
	{
		const { CURRENT_CHAT_CHANNEL_ID, PARENT_ID, PARENT_TYPE, PARENT_NAME, MESSAGE, hidUploadNAME, hidUploadTYPE, hidUploadDATA } = this.state;

		try
		{
			let row: any = {};
			let sNOTE_ATTACHMENT_ID: string = null;
			if ( !Sql.IsEmptyString(hidUploadDATA) )
			{
				let arrFileParts: string[] = hidUploadNAME.split('.');
				row.DESCRIPTION    = hidUploadNAME;
				row.FILENAME       = hidUploadNAME;
				row.FILE_EXT       = arrFileParts[arrFileParts.length - 1];
				row.FILE_MIME_TYPE = hidUploadTYPE;
				row.FILE_DATA      = hidUploadDATA;
				// 05/19/2023 Paul.  Use returned attachment ID. 
				sNOTE_ATTACHMENT_ID = await UpdateModuleTable('vwNOTE_ATTACHMENTS', row, null);
			}
			row = {};
			row.CHAT_CHANNEL_ID    = CURRENT_CHAT_CHANNEL_ID;
			if ( !Sql.IsEmptyGuid(sNOTE_ATTACHMENT_ID) )
				row.NOTE_ATTACHMENT_ID = sNOTE_ATTACHMENT_ID;
			row.ID                 = null;
			row.NAME               = null;
			row.DESCRIPTION        = MESSAGE;
			row.PARENT_ID          = null;
			row.PARENT_TYPE        = null;
			if ( !Sql.IsEmptyGuid(PARENT_ID) )
			{
				row.PARENT_ID       = PARENT_ID  ;
				row.PARENT_TYPE     = PARENT_TYPE;
			}
			row.ID = await UpdateModule('ChatMessages', row, null);
			this.setState(
			{
				PARENT_ID    : '',
				PARENT_TYPE  : '',
				PARENT_NAME  : '',
				MESSAGE      : '',
				hidUploadNAME: '',
				hidUploadTYPE: '',
				hidUploadDATA: '',
				error        : null,
			});
		}
		catch(error)
		{
			this.setState({ error });
		}
	}

	private _onSubmitKeyDown = async (event) =>
	{
		if ( event.key == 'Enter' )
		{
			this._onSubmit();
		}
	}

	private _onSearchKeyDown = async (event) =>
	{
		const { CURRENT_CHAT_CHANNEL_ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchKeyDown', event, event.key);
		if ( event.key == 'Enter' && !Sql.IsEmptyGuid(CURRENT_CHAT_CHANNEL_ID) )
		{
			let dtMessages = await this.LoadChannel(CURRENT_CHAT_CHANNEL_ID);
			this.setState(
			{
				dtMessages,
				error     : null,
			});
		}
	}

	// 05/13/2023 Paul.  Missing handler for search button. 
	private _onSearch = async (event) =>
	{
		const { CURRENT_CHAT_CHANNEL_ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearch', event, event.key);
		if ( !Sql.IsEmptyGuid(CURRENT_CHAT_CHANNEL_ID) )
		{
			let dtMessages = await this.LoadChannel(CURRENT_CHAT_CHANNEL_ID);
			this.setState(
			{
				dtMessages,
				error     : null,
			});
		}
	}

	private panelRef = (element, name) =>
	{
		if ( element != null )
		{
			let rect = element.getBoundingClientRect();
			this.tabMenuRect[name] = rect;
			if ( name == 'divMainPageContent' )
			{
				this.nHeaderHeight = rect.y;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.panelRef ' + name, rect);
			}
			else if ( name == 'divChatDashboard_divSearch' )
			{
				this.nSearchInputHeight = rect.height;
			}
			else if ( name == 'divChatDashboard_ChatInputCell' )
			{
				this.nChatInputHeight = rect.height;
			}
		}
	}

	public render()
	{
		const { error, nClientHeight } = this.state;
		const { CURRENT_CHAT_CHANNEL_ID, dtChannels, dtMessages, showDescription, showImage, txtSearch } = this.state;
		const { popupOpen, PARENT_TYPE, PARENT_NAME, MESSAGE } = this.state;
		if ( SplendidCache.IsInitialized )
		{
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = '.moduleList.Home';
			let HEADER_BUTTONS: string = '';
			if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
			{
				HEADER_BUTTONS = MODULE_NAME + '.ListView';
			}
			let objDateRules: any = {};
			let arrRecordTypes: string[] = L10n.GetList('record_type_display');
			if ( arrRecordTypes == null )
				arrRecordTypes = [];
			if ( Sql.IsEmptyString(this.sLongDatePattern) )
			{
				this.sLongDatePattern = L10n.Term('Calendar.LongDatePattern');
				this.sLongDatePattern  = this.sLongDatePattern.replace('yyyy', 'YYYY').replace('yy', 'YY');
				this.sLongDatePattern  = this.sLongDatePattern.replace('dddd', 'DDDD').replace('dd', 'DD').replace('d', 'D').replace('DDDD', 'dddd');
			}
			let nDashboardHeight: number = nClientHeight    - this.nHeaderHeight     - this.nCopyrightHeight  ;
			let nChannelsHeight : number = nDashboardHeight - this.nChatInputHeight  ;
			let nMessagesHeight : number = nDashboardHeight - this.nChatInputHeight  - this.nSearchInputHeight;
			return (
<div style={ {display: 'flex', flexDirection: 'row', flexWrap: 'nowrap', width: '100%'} }>
	<PopupView
		isOpen={ popupOpen }
		callback={ this._onSelectParent }
		MODULE_NAME={ PARENT_TYPE }
		showProcessNotes={ true }
	/>
	<div id='divListView' style={ {width: '100%'} }>
		{ headerButtons
		? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, error, enableHelp: true, helpName: 'index', ButtonStyle: 'ModuleHeader', VIEW_NAME: HEADER_BUTTONS, Page_Command: this.Page_Command, showButtons: true, showProcess: false, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
		: null
		}
		<div id="divMainPageContent" ref={ (element) => this.panelRef(element, 'divMainPageContent') }>
			<div id="divMainLayoutPanel">
				<div id="divChatDashboard" style={ {width: '100%', height: nDashboardHeight + 'px'} } ref={ (element) => this.panelRef(element, 'divChatDashboard') }>
					<table cellPadding={ 0 } cellSpacing={ 0 } style={ {width: '100%', height: '100%'} }>
						<tr>
							<td id="divChatDashboard_ChatChannelsCell" className="ChatChannelsCell" valign='top'>
								<div id="divChatDashboard_divChannels" className="ChatChannelsDiv" style={ {height: nChannelsHeight + 'px'} } ref={ (element) => this.panelRef(element, 'divChatDashboard_divChannels') }>
									{ dtChannels.map((channel) =>
									{
										return(<div id={ channel.ID }
											className={ "ChatChannels" + (channel.ID == CURRENT_CHAT_CHANNEL_ID ? 'Active' : 'Inactive')}
											onClick={ (e) => this._onChangeChannel(channel.ID) }
										>{ channel.NAME }
										</div>);
									})}
								</div>
							</td>
							<td className="ChatMessagesCell" valign='top'>
								<div id="divChatDashboard_divSearch"
									ref={ (element) => this.panelRef(element, 'divChatDashboard_divSearch') }
									style={ {display: 'flex', flexWrap: 'nowrap'} }
								>
									<input id="divChatDashboard_txtSearch"
										type="search"
										className="ChatInputText"
										style={ {width: '95%'} }
										value={ txtSearch }
										onChange={ this._onSearchChange }
										onKeyDown={ this._onSearchKeyDown }
									/>
									<button id="divChatDashboard_btnSearch" className="ChatInputSubmit" onClick={ this._onSearch }>{ L10n.Term('.LBL_SEARCH_BUTTON_LABEL') }</button>
								</div>
								<div id="divChatDashboard_divMessages" className="ChatMessagesDiv" style={ {height: nMessagesHeight + 'px'} } ref={ (element) => this.panelRef(element, 'divChatDashboard_divMessages') }>
									{ dtMessages
									? dtMessages.map((row) =>
										{
											let dtDATE_ENTERED: Date   = FromJsonDate(row.DATE_ENTERED)
											let sDATE_ENTERED : string = formatDate(dtDATE_ENTERED, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
		
											dtDATE_ENTERED.setHours(0, 0, 0, 0);
											let sDateValueID: string = 'ChatMessages_Day_' + dtDATE_ENTERED.getTime().toString();
											let bAddDateRule: boolean = !objDateRules[sDateValueID];
											objDateRules[sDateValueID] = true;
											return(<React.Fragment>
											{ bAddDateRule
											? <div id={ sDateValueID }>
												<table style={ {width: '100%', border: 'none'} }>
													<tr>
														<td>
															<hr className="ChatMessagesDateRule" />
														</td>
														<td className="ChatMessagesLastDate" style={ {width: '1px', padding: '0px 10px', whiteSpace: 'nowrap'} }>{ formatDate(dtDATE_ENTERED, this.sLongDatePattern) }</td>
														<td>
															<hr className="ChatMessagesDateRule" />
														</td>
													</tr>
												</table>
											</div>
											: null
											}
											<div className="ChatMessagesRow" id={ row.ID }>
												<div>
													<img className="ChatMessagesPicture" src={ Sql.IsEmptyString(row.CREATED_BY_PICTURE) ? Credentials.sREMOTE_SERVER + 'Include/images/SplendidCRM_Icon.gif' : row.CREATED_BY_PICTURE } />
												</div>
												<div className="ChatMessagesIdentity">
													<span className="ChatMessagesCreatedBy">{ row.CREATED_BY }</span>
													<span className="ChatMessagesDateEntered">{ sDATE_ENTERED }</span>
													<span className="ChatMessagesParent">
													{ !Sql.IsEmptyString(row.PARENT_TYPE) && !Sql.IsEmptyGuid(row.PARENT_ID)
													? <a href={ Credentials.sREMOTE_SERVER + row.PARENT_TYPE + '/View/' + row.PARENT_ID } onClick={ (e) => { e.preventDefault(); this._onParentClick(row); } }>{ row.PARENT_NAME }</a>
													: null
													}
													</span>
												</div>
												{ Sql.ToBoolean(row.ATTACHMENT_READY)
												? <div id={ row.ID + '_FILENAME' }>
													<a href={ Credentials.sREMOTE_SERVER + 'Notes/attachment.aspx?ID=' + row.NOTE_ATTACHMENT_ID } className='ChatMessagesFilename'>{ row.FILENAME }</a>
													<img src={ Credentials.sREMOTE_SERVER + 'App_Themes/Atlantic/images/mime-' + Sql.ToString(row.FILE_EXT).replace('.', '') + '.gif' } className='ChatMessagesMimeType' />
													<span className='ChatMessagesFileSize'>{ this.getFileSize(row) }</span>
													<span className='ChatMessagesFileType'>{  Sql.ToString(row.FILE_EXT).toUpperCase() }</span>
													{ StartsWith(row.FILE_MIME_TYPE, 'image')
													? <React.Fragment>
														{ showImage[row.ID]
														? <img id={ row.NOTE_ATTACHMENT_ID } src={ Credentials.sREMOTE_SERVER + 'Notes/attachment.aspx?ID=' + row.NOTE_ATTACHMENT_ID } />
														: null
														}
														{ showImage[row.ID]
														? <a href='#' className='ChatMessagesLess' onClick={ (e) => { e.preventDefault(); this._onShowImage(row.ID, false); } }>{ L10n.Term('ChatDashboard.LBL_LESS') }</a>
														: <a href='#' className='ChatMessagesMore' onClick={ (e) => { e.preventDefault(); this._onShowImage(row.ID, true ); } }>{ L10n.Term('ChatDashboard.LBL_MORE') }</a>
														}
													</React.Fragment>
													: null
													}
												</div>
												: null
												}
												<div id={ row.ID + "NAME" } className="ChatMessagesDescription">{ row.NAME }</div>
												{ row.NAME != row.DESCRIPTION
												? <React.Fragment>
													{ showDescription[row.ID]
													? <div id={ row.ID + "DESCRIPTION" } className="ChatMessagesDescription">{ row.DESCRIPTION }</div>
													: null
													}
													{ showDescription[row.ID]
													? <a href='#' className='ChatMessagesLess' onClick={ (e) => { e.preventDefault(); this._onShowDescription(row.ID, false); } }>{ L10n.Term('ChatDashboard.LBL_LESS') }</a>
													: <a href='#' className='ChatMessagesMore' onClick={ (e) => { e.preventDefault(); this._onShowDescription(row.ID, true ); } }>{ L10n.Term('ChatDashboard.LBL_MORE') }</a>
													}
												</React.Fragment>
												: null
												}
												<div className="ChatMessagesClearFloat"></div>
											</div>
											</React.Fragment>);
										})
									: null
									}
								</div>
							</td>
						</tr>
						<tr style={ {height: this.nChatInputHeight + 'px'} }>
							<td id="divChatDashboard_ChatUserCell" className="ChatUserCell">
								<div>
									<img className="ChatUserPicture" src={ Sql.IsEmptyString(Security.PICTURE()) ? Credentials.sREMOTE_SERVER + 'Include/images/SplendidCRM_Icon.gif' : Security.PICTURE() } />
								</div>
								<div className="ChatUserName">{ Security.USER_NAME() }</div>
							</td>
							<td id='divChatDashboard_ChatInputCell' className="ChatInputCell" ref={ (element) => this.panelRef(element, 'divChatDashboard_divMessage') }>
								<div id="divChatDashboard_divMessage"
									ref={ (element) => this.panelRef(element, 'divChatDashboard_divMessage') }
									style={ {display: 'flex', flexWrap: 'nowrap'} }
								>
									<input id="divChatDashboard_txtMessage"
										className="ChatInputText"
										style={ {width: '90%'} }
										value={ MESSAGE }
										onChange={ this._onMESSAGE_Change }
										onKeyDown={ this._onSubmitKeyDown }
									/>
									<button id="divChatDashboard_btnSubmit" className="ChatInputSubmit" onClick={ this._onSubmit }>{ L10n.Term('.LBL_SUBMIT_BUTTON_LABEL') }</button>
								</div>
								<div id="divChatDashboard_divParent" className="ChatParentPanel">
									<table cellPadding={ 0 } cellSpacing={ 0 } style={ {width: '100%', border: 'none'} }>
										<tr>
											<td width='20%'>
												<span className="ChatParentLabel">{ L10n.Term('ChatMessages.LBL_UPLOAD_FILE') }</span>
												<input id="divChatDashboard_fileUpload" className="ChatFileUpload" type="file" onChange={ (e) => this._onFILE_Upload(e) } ref={ this.divChatDashboard_fileUpload } />
												<button className="ChatParentClear" onClick={ this._onFILE_Clear }>{ L10n.Term('.LBL_CLEAR_BUTTON_LABEL') }</button>
											</td>
											<td width='10%' id="divChatDashboard_divParentSelect" style={ {whiteSpace: 'nowrap'} }>
												<span className="ChatParentLabel">{ L10n.Term('ChatMessages.LBL_PARENT_NAME') }</span>
												<select id="divChatDashboard_PARENT_TYPE" className="ChatParentType" value={ PARENT_TYPE } onChange={ (e) => this._onPARENT_TYPE_Change(e) }>
													{ arrRecordTypes.map((item) =>
													{
														return(<option value={ item }>{ L10n.ListTerm('record_type_display', item) }</option>);
													})}
												</select>
											</td>
											<td width="70%">
												<div  style={ {display: 'flex', flexWrap: 'nowrap', alignItems: 'center'} }>
													<input id="divChatDashboard_PARENT_NAME" className="ChatParentName" disabled={ true } style={ {width: '90%'} } value={ PARENT_NAME } />
													<button className="ChatParentSelect" onClick={ this._onPARENT_NAME_Select }>{ L10n.Term('.LBL_SELECT_BUTTON_LABEL') }</button>
													<button className="ChatParentClear"  onClick={ this._onPARENT_NAME_Clear  }>{ L10n.Term('.LBL_CLEAR_BUTTON_LABEL' ) }</button>
												</div>
											</td>
										</tr>
									</table>
									<span id="divChatDashboard_lblSubmitError" className="error" style={ {padding: '2px', fontSize: '1.5em'} }>{ (error && error.message) ? error.message : error }</span>
								</div>
							</td>
						</tr>
					</table>
				</div>
			</div>
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

export default withRouter(ChatDashboardView);
