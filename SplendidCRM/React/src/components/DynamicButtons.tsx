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
import { RouteComponentProps, withRouter, Link } from '../Router5'              ;
import { FontAwesomeIcon }                       from '@fortawesome/react-fontawesome';
import { observer }                              from 'mobx-react'                    ;
// 2. Store and Types. 
import ACL_ACCESS                                from '../types/ACL_ACCESS'           ;
import DYNAMIC_BUTTON                            from '../types/DYNAMIC_BUTTON'       ;
import MODULE                                    from '../types/MODULE'               ;
// 3. Scripts. 
import Sql                                       from '../scripts/Sql'                ;
import L10n                                      from '../scripts/L10n'               ;
import Security                                  from '../scripts/Security'           ;
import Credentials                               from '../scripts/Credentials'        ;
import SplendidCache                             from '../scripts/SplendidCache'      ;
import SplendidDynamic                           from '../scripts/SplendidDynamic'    ;
import { DynamicButtons_LoadLayout }             from '../scripts/DynamicButtons'     ;
import { Crm_Config, Crm_Modules }               from '../scripts/Crm'                ;
import { StartsWith, isMobileDevice, isMobileLandscape } from '../scripts/utility';
// 4. Components and Views. 
import ErrorComponent                            from '../components/ErrorComponent'  ;
import NavItem                                   from '../components/NavItem'         ;


interface IDynamicButtonsProps extends RouteComponentProps<any>
{
	ButtonStyle    : string;
	FrameStyle?    : any;
	ContentStyle?  : any;
	VIEW_NAME      : string;
	row            : object;
	Page_Command   : (sCommandName, sCommandArguments) => void;
	onLayoutLoaded?: () => void;
	// 07/02/2020 Paul.  Provide a way to override the default ButtonLink behavior. 
	onButtonLink?  : (lay: DYNAMIC_BUTTON) => void;

};

interface IDynamicButtonsState
{
	layout      : DYNAMIC_BUTTON[];
	disabled    : object;
	hidden      : object;
	bIsPostBack : boolean;
	busy        : boolean;
	error       : any;
}

@observer
class DynamicButtons extends React.Component<IDynamicButtonsProps, IDynamicButtonsState>
{
	constructor(props: IDynamicButtonsProps)
	{
		super(props);
		this.state =
		{
			layout     : [],
			disabled   : {},
			hidden     : {},
			bIsPostBack: false,
			busy       : false,
			error      : null
		};
	}

	async componentDidMount()
	{
		const { VIEW_NAME, onLayoutLoaded } = this.props;
		try
		{
			// 05/04/2019 Paul.  Search views do not have dynamic buttons. 
			if ( VIEW_NAME && VIEW_NAME.indexOf('.Search') < 0 )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount ' + VIEW_NAME);
				let layout = DynamicButtons_LoadLayout(VIEW_NAME);
				this.setState({ layout }, () =>
				{
					if ( onLayoutLoaded != null )
					{
						onLayoutLoaded();
					}
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	private LoadButtons = () =>
	{
		const { row, ButtonStyle, ContentStyle } = this.props;
		const { layout, disabled, hidden, bIsPostBack } = this.state;
		// 06/10/2018 Paul.  No sense returning a blank div with .5em margin if there are no buttons. 
		if ( layout == null || layout.length == 0 )
		{
			return null;
		}
		let bIsMobile: boolean = isMobileDevice();
		if ( isMobileLandscape() )
		{
			bIsMobile = false;
		}
		let gASSIGNED_USER_ID: string = null;
		if ( row != null )
		{
			gASSIGNED_USER_ID = Sql.ToGuid(row['ASSIGNED_USER_ID']);
		}
		let sTheme                   : string  = SplendidCache.UserTheme;
		let bShowUnassigned          : boolean = Crm_Config.ToBoolean('show_unassigned');
		let bMoreListItems           : boolean = false;
		let pnlDynamicButtonsChildren = [];
		let style                    : any = (ContentStyle ? ContentStyle : {});
		style.display = (ButtonStyle == 'ModuleHeader' ? 'block' : 'inline-block');
		style.marginTop     = '6px';
		style.marginBottom  = '2px';
		let pnlDynamicButtons         = null;
		let nButtonStart: number = 0;
		let themeURL    : string = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
		if ( SplendidDynamic.StackedLayout(sTheme) && (ButtonStyle == 'ModuleHeader' || ButtonStyle == 'ListHeader' || ButtonStyle == 'MassUpdateHeader') )
		{
			if ( sTheme == 'Pacific' && ButtonStyle == 'ListHeader' )
			{
				// 05/06/2022 Paul.  If only one button, then no need for Actions dropdown. 
				if ( layout.length == 1 )
				{
					pnlDynamicButtons = React.createElement('div', { id: 'pnlDynamicButtons', key: 'pnlDynamicButtons', alignRight: true, style: { paddingRight: '1em'}, children: null}, pnlDynamicButtonsChildren);
				}
				else
				{
					let actionTitleChildren = [];
					let actionTitle = React.createElement('div', {className: ButtonStyle + 'FirstButton', style: {}}, actionTitleChildren);
					let actions = React.createElement('span', {style: {}}, L10n.Term('.LBL_ACTIONS'));
					actionTitleChildren.push(actions);
					let iDown = React.createElement(FontAwesomeIcon, { icon: 'caret-down' });
					let more = React.createElement('span', {className: ButtonStyle + 'MoreButton', style: {}}, iDown);
					actionTitleChildren.push(more);
					let navItem = React.createElement(NavItem, { id: 'pnlDynamicButtons', key: 'pnlDynamicButtons', title: actionTitle, alignRight: true, style: { paddingRight: '1em'}, children: null}, pnlDynamicButtonsChildren);
					pnlDynamicButtons = navItem;
				}
			}
			else
			{
				// 10/26/2021 Paul.  Several buttons may be hidden, so loop until we find the first available button. 
				while ( layout.length > nButtonStart )
				{
					// 10/26/2021 Paul.  For the Seven theme, we need to account for the first button possibly being hidden. 
					let lay: DYNAMIC_BUTTON = layout[nButtonStart];
					let CONTROL_TYPE       : string  = Sql.ToString (lay.CONTROL_TYPE      );
					let MODULE_NAME        : string  = Sql.ToString (lay.MODULE_NAME       );
					let MODULE_ACCESS_TYPE : string  = Sql.ToString (lay.MODULE_ACCESS_TYPE);
					let TARGET_NAME        : string  = Sql.ToString (lay.TARGET_NAME       );
					let TARGET_ACCESS_TYPE : string  = Sql.ToString (lay.TARGET_ACCESS_TYPE);
					let MOBILE_ONLY        : boolean = Sql.ToBoolean(lay.MOBILE_ONLY       );
					let ADMIN_ONLY         : boolean = Sql.ToBoolean(lay.ADMIN_ONLY        );
					let CONTROL_TEXT       : string  = Sql.ToString (lay.CONTROL_TEXT      );
					let HIDDEN             : boolean = Sql.ToBoolean(lay.HIDDEN            );
					let EXCLUDE_MOBILE     : boolean = Sql.ToBoolean(lay.EXCLUDE_MOBILE    );
					let COMMAND_NAME       : string = Sql.ToString (lay.COMMAND_NAME);
					let MODULE_ACLACCESS  = (Sql.IsEmptyString(lay.MODULE_ACLACCESS) ? 0 : Sql.ToInteger(lay.MODULE_ACLACCESS));
					let nTARGET_ACLACCESS = (Sql.IsEmptyString(lay.TARGET_ACLACCESS) ? 0 : Sql.ToInteger(lay.TARGET_ACLACCESS));
					if ( MODULE_ACLACCESS < 0 || nTARGET_ACLACCESS < 0 )
					{
						nButtonStart++;
						continue;
					}
					let bVisible: boolean = true;
					bVisible = (!EXCLUDE_MOBILE || !bIsMobile) && (MOBILE_ONLY && bIsMobile || !MOBILE_ONLY) && (ADMIN_ONLY && Security.IS_ADMIN() || !ADMIN_ONLY) && (!HIDDEN || Sql.ToInteger(hidden[COMMAND_NAME]) <= 0);
					if ( bVisible && !Sql.IsEmptyString(MODULE_NAME) && !Sql.IsEmptyString(MODULE_ACCESS_TYPE) )
					{
						let nACLACCESS = SplendidCache.GetUserAccess(MODULE_NAME, MODULE_ACCESS_TYPE, this.constructor.name + '.LoadButtons');
						bVisible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((Security.USER_ID() == gASSIGNED_USER_ID) || (!bIsPostBack && row == null) || (row != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
						if ( bVisible && !Sql.IsEmptyString(TARGET_NAME) && !Sql.IsEmptyString(TARGET_ACCESS_TYPE) )
						{
							nACLACCESS = SplendidCache.GetUserAccess(TARGET_NAME, TARGET_ACCESS_TYPE, this.constructor.name + '.LoadButtons');
							bVisible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((Security.USER_ID() == gASSIGNED_USER_ID) || (!bIsPostBack && row == null) || (row != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
						}
					}
					if ( !bVisible || (hidden[COMMAND_NAME] == null && HIDDEN) || Sql.ToInteger(hidden[COMMAND_NAME]) > 0 )
					{
						nButtonStart++;
						continue;
					}
					else if ( Sql.IsEmptyString(COMMAND_NAME) && !Sql.IsEmptyString(CONTROL_TEXT) && (!bVisible || (hidden[CONTROL_TEXT] == null && HIDDEN) || Sql.ToInteger(hidden[CONTROL_TEXT]) > 0) )
					{
						nButtonStart++;
						continue;
					}
					lay = layout[nButtonStart];
					let sCONTROL_TEXT: string = '  ' + L10n.Term(lay.CONTROL_TEXT) + '  ';
					if ( ButtonStyle == 'ListHeader' && (COMMAND_NAME.indexOf('.Create') > 0) )
					{
						sCONTROL_TEXT = '  +  ';
					}
					let titleChildren = [];
					let title: any = React.createElement('span', {style: {verticalAlign: 'bottom'}}, titleChildren);
					// 12/13/2019 Paul.  Only change search to icon for Seven theme. 
					// 01/05/2022 Paul.  First button might be a button link. 
					let onClick = this._onButtonClick;
					if ( CONTROL_TYPE == 'ButtonLink' )
					{
						if ( this.props.onButtonLink )
							onClick = this.props.onButtonLink;
						else
							onClick = this._onButtonLink;
					}

					if ( ButtonStyle == 'ListHeader' && COMMAND_NAME.indexOf('.Search') > 0 )
					{
						let iNavSearch = React.createElement(FontAwesomeIcon, { icon: 'search' });
						// 01/05/2022 Paul.  First button might be a button link. 
						let first = React.createElement('input', {type: 'button', className: ButtonStyle + 'FirstButton', style: {}, onClick: (e) => onClick(lay)}, iNavSearch);
						titleChildren.push(first);
					}
					else
					{
						// 01/05/2022 Paul.  First button might be a button link. 
						let first = React.createElement('input', {type: 'submit', className: ButtonStyle + 'FirstButton', style: {}, value: sCONTROL_TEXT, onClick: (e) => onClick(lay)});
						titleChildren.push(first);
					}
					if ( layout.length > 1 )
					{
						if ( sTheme == 'Pacific' && ButtonStyle == 'ModuleHeader' )
						{
							// 04/02/2022 Paul.  Create an outer div to include the first button and the action navItem. 
							let pacificChildren = [];
							let pacific = React.createElement('div', {style: {display: 'flex', flexDirection: 'row', flexWrap: 'nowrap'}}, pacificChildren);
							// 04/02/2022 Paul.  Write title in a div to correct spacing alignment issues. 
							let firstDivChildren = [];
							let firstDiv = React.createElement('div', {}, firstDivChildren);
							pacificChildren.push(firstDiv);
							firstDivChildren.push(title);
							
							let actionTitleChildren = [];
							let actionTitle = React.createElement('div', {className: ButtonStyle + 'FirstButton', style: {}}, actionTitleChildren);
							let actions = React.createElement('span', {style: {}}, L10n.Term('.LBL_ACTIONS'));
							actionTitleChildren.push(actions);
							let iDown = React.createElement(FontAwesomeIcon, { icon: 'caret-down' });
							let more = React.createElement('span', {className: ButtonStyle + 'MoreButton', style: {}}, iDown);
							actionTitleChildren.push(more);
							let navItem = React.createElement(NavItem, { id: 'pnlDynamicButtons', key: 'pnlDynamicButtons', title: actionTitle, alignRight: true, children: null}, pnlDynamicButtonsChildren);
							pacificChildren.push(navItem);
							pnlDynamicButtons = pacific;
						}
						else
						{
							if ( ButtonStyle == 'ListHeader' )
							{
								let more = React.createElement('input', {type: 'image', className: ButtonStyle + 'MoreButton', style: {verticalAlign: 'bottom', height: '26px'}, src: themeURL + 'images/subpanel_more.gif', onClick: (e) => { e.preventDefault() }});
								titleChildren.push(more);
							}
							else
							{
								let more = React.createElement('input', {type: 'image', className: ButtonStyle + 'MoreButton', style: {verticalAlign: 'bottom'}, src: themeURL + 'images/moreWhite.gif', onClick: (e) => { e.preventDefault() }});
								titleChildren.push(more);
							}
							// 02/25/2022 Paul.  NavDropdownProps requires children parameter, though it does not seem to be used.  This error appeared with bootstrap 5. 
							let navItem = React.createElement(NavItem, { id: 'pnlDynamicButtons', key: 'pnlDynamicButtons', title: title, alignRight: true, children: null}, pnlDynamicButtonsChildren);
							//pnlDynamicButtons = React.createElement(Nav, {className: 'ml-auto', navbar: true}, [navItem]);
							pnlDynamicButtons = navItem;
						}
					}
					else
					{
						pnlDynamicButtons = title;
					}
					bMoreListItems = true;
					nButtonStart++;
					break;
				}
			}
		}
		else if ( SplendidDynamic.StackedLayout(sTheme) && (ButtonStyle == 'DataGrid') )
		{
			if ( layout.length > 0 )
			{
				let more = null
				if ( sTheme == 'Pacific' )
				{
					more = <div className='GridBulkAction'>
						<span style={ {marginRight: '10px'} }>{ L10n.Term('.LBL_BULK_ACTION') }</span>
						<FontAwesomeIcon icon='caret-down' size='lg' />
					</div>;
				}
				else
				{
					let titleChildren = [];
					let title = React.createElement('span', {style: {verticalAlign: 'top'}}, titleChildren);
					more = React.createElement('input', {type: 'image', className: ButtonStyle + 'MoreButton', style: {verticalAlign: 'top', width: '20px', height: '20px'}, src: themeURL + 'images/datagrid_more.gif', onClick: (e) => { e.preventDefault() }});
					titleChildren.push(more);
				}
				// 02/25/2022 Paul.  NavDropdownProps requires children parameter, though it does not seem to be used.  This error appeared with bootstrap 5. 
				let navItem = React.createElement(NavItem, { id: 'pnlDynamicButtons', key: 'pnlDynamicButtons', title: more, style: {textAlign: 'left', verticalAlign: 'top', padding: 0, margin: 0}, children: null }, pnlDynamicButtonsChildren);
				//pnlDynamicButtons = React.createElement(Nav, {className: 'ml-auto', navbar: true}, [navItem]);
				pnlDynamicButtons = navItem;
			}
		}
		else
		{
			pnlDynamicButtons = React.createElement('div', { id: 'pnlDynamicButtons', className: 'button-panel', role: 'group', key: 'pnlDynamicButtons', style }, pnlDynamicButtonsChildren);
		}
		for ( let iButton = nButtonStart; iButton < layout.length; iButton++ )
		{
			let lay: DYNAMIC_BUTTON = layout[iButton];
			// 03/06/2016 Paul.  COMMAND_NAME might be null, so we have to use Sql.ToString() so that we can use indexOf. 
			let VIEW_NAME          : string  = Sql.ToString (lay.VIEW_NAME         );
			let CONTROL_TYPE       : string  = Sql.ToString (lay.CONTROL_TYPE      );
			let MODULE_NAME        : string  = Sql.ToString (lay.MODULE_NAME       );
			let MODULE_ACCESS_TYPE : string  = Sql.ToString (lay.MODULE_ACCESS_TYPE);
			let TARGET_NAME        : string  = Sql.ToString (lay.TARGET_NAME       );
			let TARGET_ACCESS_TYPE : string  = Sql.ToString (lay.TARGET_ACCESS_TYPE);
			let MOBILE_ONLY        : boolean = Sql.ToBoolean(lay.MOBILE_ONLY       );
			let ADMIN_ONLY         : boolean = Sql.ToBoolean(lay.ADMIN_ONLY        );
			let CONTROL_TEXT       : string  = Sql.ToString (lay.CONTROL_TEXT      );
			let CONTROL_TOOLTIP    : string  = Sql.ToString (lay.CONTROL_TOOLTIP   );
			let CONTROL_CSSCLASS   : string  = Sql.ToString (lay.CONTROL_CSSCLASS  );
			let TEXT_FIELD         : string  = Sql.ToString (lay.TEXT_FIELD        );
			let ARGUMENT_FIELD     : string  = Sql.ToString (lay.ARGUMENT_FIELD    );
			let COMMAND_NAME       : string  = Sql.ToString (lay.COMMAND_NAME      );
			let URL_FORMAT         : string  = Sql.ToString (lay.URL_FORMAT        );
			let URL_TARGET         : string  = Sql.ToString (lay.URL_TARGET        );
			let ONCLICK_SCRIPT     : string  = Sql.ToString (lay.ONCLICK_SCRIPT    );
			// 03/14/2014 Paul.  Allow hidden buttons to be created. 
			let HIDDEN             : boolean = Sql.ToBoolean(lay.HIDDEN            );
			// 07/28/2010 Paul.  We need a flag to exclude a button from a mobile device. 
			let EXCLUDE_MOBILE     : boolean = Sql.ToBoolean(lay.EXCLUDE_MOBILE    );
			// 04/30/2017 Paul.  Apply access rights. 
			let MODULE_ACLACCESS  = (Sql.IsEmptyString(lay.MODULE_ACLACCESS) ? 0 : Sql.ToInteger(lay.MODULE_ACLACCESS));
			let nTARGET_ACLACCESS = (Sql.IsEmptyString(lay.TARGET_ACLACCESS) ? 0 : Sql.ToInteger(lay.TARGET_ACLACCESS));
			if ( MODULE_ACLACCESS < 0 || nTARGET_ACLACCESS < 0 )
			{
				continue;
			}
			let sCONTROL_ID = '';
			if ( !Sql.IsEmptyString(COMMAND_NAME) )
			{
				sCONTROL_ID = 'btnDynamicButtons_' + COMMAND_NAME;
			}
			else if ( !Sql.IsEmptyString(CONTROL_TEXT) )
			{
				sCONTROL_ID = 'btnDynamicButtons_' + CONTROL_TEXT;
				if ( CONTROL_TEXT.indexOf('.') >= 0 )
				{
					sCONTROL_ID = CONTROL_TEXT.split('.')[1];
					sCONTROL_ID = sCONTROL_ID.replace('LBL_', '');
					sCONTROL_ID = sCONTROL_ID.replace('_BUTTON_LABEL', '');
				}
			}
			// 06/06/2015 Paul.  Change standard MassUpdate command to a command to toggle visibility. 
			if ( ButtonStyle == 'DataGrid' && COMMAND_NAME == 'MassUpdate' )
			{
				CONTROL_TEXT       = L10n.Term('.LBL_MASS_UPDATE_TITLE');
				CONTROL_TOOLTIP    = L10n.Term('.LBL_MASS_UPDATE_TITLE');
				COMMAND_NAME       = 'ToggleMassUpdate';
				ONCLICK_SCRIPT     = null;
				MODULE_ACCESS_TYPE = null;
				// 05/07/2017 Paul.  Don't display MassUpdate toggle if it is disabled for the module. 
				let MODULE = VIEW_NAME.split('.')[0];
				if ( !Sql.IsEmptyString(MODULE) && !(!bIsMobile && Crm_Modules.MassUpdate(MODULE)) )
					HIDDEN = true;
			}
			if ( !Sql.IsEmptyString(sCONTROL_ID) )
			{
				//sCONTROL_ID = sCONTROL_ID.Trim();
				// 12/24/2012 Paul.  Use regex global replace flag. 
				sCONTROL_ID = sCONTROL_ID.replace(/\s/g, '_');
				sCONTROL_ID = sCONTROL_ID.replace(/\./g, '_');
			}
			try
			{
				let btnChildren: any[] = [];
				// 10/11/2019 Paul.  Manually add spacing around buttons so that the do not look like one solid botton. 
				let btnProps   : any = { style: { marginRight: '2px', marginBottom: '2px' }, key: ButtonStyle + MODULE_NAME + iButton };
				let btn        : JSX.Element = null;
				// 04/02/2022 Paul.  Bottom margin leaves white line with Pacific theme. 
				if ( sTheme == 'Pacific' && (ButtonStyle == 'ListHeader' || ButtonStyle == 'DataGrid') )
				{
					btnProps.style.marginBottom = '0px';
				}

				// 11/21/2008 Paul.  On post back, we need to re-create the buttons, but don't change the visiblity flag. 
				// The problem is that we don't have the record at this early stage, so we cannot properly evaluate gASSIGNED_USER_ID. 
				// This is not an issue because .NET will restore the previous visibility state on post back. 
				let bVisible   : boolean = true;
				// 07/28/2010 Paul.  We need a flag to exclude a button from a mobile device. 
				// 03/14/2014 Paul.  Allow hidden buttons to be created. 
				// 10/30/2020 Paul.  Need to counter the HIDDEN value with the dynamic hidden[] setting. 
				bVisible         = (!EXCLUDE_MOBILE || !bIsMobile) && (MOBILE_ONLY && bIsMobile || !MOBILE_ONLY) && (ADMIN_ONLY && Security.IS_ADMIN() || !ADMIN_ONLY) && (!HIDDEN || Sql.ToInteger(hidden[COMMAND_NAME]) <= 0);
				if ( bVisible && !Sql.IsEmptyString(MODULE_NAME) && !Sql.IsEmptyString(MODULE_ACCESS_TYPE) )
				{
					let nACLACCESS = SplendidCache.GetUserAccess(MODULE_NAME, MODULE_ACCESS_TYPE, this.constructor.name + '.LoadButtons');
					// 08/11/2008 John.  Fix owner access rights. 
					// 10/27/2008 Brian.  Only show button if show_unassigned is enabled.
					// 11/21/2008 Paul.  We need to make sure that an owner can create a new record. 
					bVisible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((Security.USER_ID() == gASSIGNED_USER_ID) || (!bIsPostBack && row == null) || (row != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
					if ( bVisible && !Sql.IsEmptyString(TARGET_NAME) && !Sql.IsEmptyString(TARGET_ACCESS_TYPE) )
					{
						// 08/11/2008 John.  Fix owner access rights.
						nACLACCESS = SplendidCache.GetUserAccess(TARGET_NAME, TARGET_ACCESS_TYPE, this.constructor.name + '.LoadButtons');
						// 11/21/2008 Paul.  We need to make sure that an owner can create a new record. 
						bVisible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((Security.USER_ID() == gASSIGNED_USER_ID) || (!bIsPostBack && row == null) || (row != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
					}
				}
				if ( CONTROL_TYPE == 'Button' )
				{
					if ( Sql.IsEmptyString(COMMAND_NAME) )
					{
						COMMAND_NAME = ONCLICK_SCRIPT.replace('return false;', '');
						COMMAND_NAME = COMMAND_NAME.replace('Popup();', 's.Select');
						COMMAND_NAME = COMMAND_NAME.replace('Opportunitys', 'Opportunities');
					}
					if ( COMMAND_NAME.indexOf('.Create') > 0 || COMMAND_NAME.indexOf('.Select') > 0 )
					{
						ARGUMENT_FIELD = 'ID,NAME';
					}
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
					{
						btnProps.id = sCONTROL_ID;
					}
					// 03/14/2014 Paul.  Allow hidden buttons to be created. 
					// 08/18/2019 Paul.  Only use original HIDDEN field the first time. 
					// 04/28/2020 Paul.  Apply visibility flag. 
					if ( !bVisible || (hidden[COMMAND_NAME] == null && HIDDEN) || Sql.ToInteger(hidden[COMMAND_NAME]) > 0 )
					{
						btnProps.style.display = 'none';
					}
					// 07/05/2020 Paul.  Some buttons are identified with the CONTROL_TEXT
					else if ( Sql.IsEmptyString(COMMAND_NAME) && !Sql.IsEmptyString(CONTROL_TEXT) && (!bVisible || (hidden[CONTROL_TEXT] == null && HIDDEN) || Sql.ToInteger(hidden[CONTROL_TEXT]) > 0) )
					{
						btnProps.style.display = 'none';
					}

					btnProps.disabled = (Sql.ToInteger(disabled[COMMAND_NAME]) > 0);
					btnProps.onClick = () =>
					{
						this._onButtonClick(lay);
					}
					// 12/13/2019 Paul.  Only change search to icon for Seven theme. 
					/*
					if ( iButton == 1 && ButtonStyle == 'ListHeader' && COMMAND_NAME.indexOf('.Search') > 0 && layout.length == 2 )  // && sPLATFORM_LAYOUT == '.OfficeAddin'
					{
						let iNavSearch = React.createElement(FontAwesomeIcon, { icon: 'search', key: 'li' + btnProps.key });
						btnChildren.push(iNavSearch);
						//btnProps.size = 'tiny';
						// 04/05/2021 Paul.  Use class property instead of hard coded 'button'. 
						btnProps.className = CONTROL_CSSCLASS;
						btn = React.createElement('button', btnProps, btnChildren);
						pnlDynamicButtonsChildren.push(btn);
					}
					else
					*/
					{
						if ( bMoreListItems )
						{
							let props: any =
							{
								type: 'submit',
								className: ButtonStyle + 'OtherButton',
								value: L10n.Term(CONTROL_TEXT),
								onClick: (e) => { e.preventDefault(); this._onButtonClick(lay); }
							};
							if ( (hidden[COMMAND_NAME] == null && HIDDEN) || Sql.ToInteger(hidden[COMMAND_NAME]) > 0 )
							{
								// 11/29/2021 Paul.  style was not previously defined. 
								props.style = {};
								props.style.display = 'none';
							}
							let li = React.createElement('input', props);
							pnlDynamicButtonsChildren.push(li);
						}
						else
						{
							// 04/05/2021 Paul.  Use class property instead of hard coded 'button'. 
							btnProps.className = CONTROL_CSSCLASS;
							if ( SplendidDynamic.StackedLayout(sTheme) )
							{
								if ( sTheme == 'Pacific' && layout.length == 1 )
									btnProps.className = ButtonStyle + 'FirstButton';
								else
									btnProps.className = ButtonStyle + 'OtherButton';
							}
							//btnProps.size = 'tiny';
							if ( CONTROL_TEXT == '+' )
							{
								let glyph = React.createElement(FontAwesomeIcon, { icon: 'plus' });
								btnChildren.push(glyph);
								btn = React.createElement('button', btnProps, btnChildren);
								pnlDynamicButtonsChildren.push(btn);
							}
							else
							{
								// 12/10/2019 Paul.  Button does not look right.  Use input type submit. 
								btnProps.type  = 'submit';
								btnProps.value = '  ' + L10n.Term(CONTROL_TEXT) + '  ';
								btn = React.createElement('input', btnProps);
								pnlDynamicButtonsChildren.push(btn);
							}
						}
					}
				}
				else if ( CONTROL_TYPE == 'HyperLink' )
				{
					let lnkProps: any = {};
					let lnk: JSX.Element = null;
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
					{
						lnkProps.id = sCONTROL_ID;
					}
					lnkProps.toolTip   = (CONTROL_TOOLTIP.length > 0) ? L10n.Term(CONTROL_TOOLTIP) : '';
					lnkProps.className = CONTROL_CSSCLASS;
					//lnk.href            = String_Format(URL_FORMAT, objTEXT_FIELD);
					//btn.Command        += Page_Command;
					lnkProps.CommandName = COMMAND_NAME;
					//btn.OnClientClick   = ONCLICK_SCRIPT;
					lnkProps.href  = '#';
					lnkProps.style = {};
					lnkProps.style.marginRight = '3px';
					lnkProps.style.marginLeft  = '3px';
					if ( Sql.ToInteger(hidden[COMMAND_NAME]) > 0 )
					{
						lnkProps.style.display = 'none';
					}
					if ( !(Sql.ToInteger(disabled[URL_FORMAT]) > 0) )
					{
						lnkProps.style.cursor = 'pointer';
						lnkProps.onClick = (e) =>
						{
							e.preventDefault();
							this._onHyperLink(lay);
						}
					}
					// 04/28/2020 Paul.  Apply visibility flag. 
					if ( !bVisible || (hidden[COMMAND_NAME] == null && HIDDEN) || Sql.ToInteger(hidden[COMMAND_NAME]) > 0 )
					{
						btnProps.style.display = 'none';
					}
					if ( bMoreListItems )
					{
						let props: any =
						{
							type: 'submit',
							className: ButtonStyle + 'OtherButton',
								value: L10n.Term(CONTROL_TEXT),
							onClick: (e) => { e.preventDefault(); this._onHyperLink(lay); }
						};
						lnk = React.createElement('input', props);
					}
					else
					{
						lnk = React.createElement('a', lnkProps, L10n.Term(CONTROL_TEXT));
					}
					pnlDynamicButtonsChildren.push(lnk);
				}
				else if ( CONTROL_TYPE == 'ButtonLink' )
				{
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
					{
						btnProps.id = sCONTROL_ID;
					}
					btnProps.onClick = (event) =>
					{
						event.preventDefault();
						// 07/02/2020 Paul.  Provide a way to override the default ButtonLink behavior. 
						if ( this.props.onButtonLink )
							this.props.onButtonLink(lay);
						else
							this._onButtonLink(lay);
					}
					// 04/28/2020 Paul.  Apply visibility flag. 
					if ( !bVisible || (hidden[COMMAND_NAME] == null && HIDDEN) || Sql.ToInteger(hidden[COMMAND_NAME]) > 0 )
					{
						btnProps.style.display = 'none';
					}
					if ( bMoreListItems )
					{
						let props: any =
						{
							type: 'submit',
							className: ButtonStyle + 'OtherButton',
							value: L10n.Term(CONTROL_TEXT),
							onClick: (e) => { e.preventDefault(); this._onButtonLink(lay); }
						};
						let li = React.createElement('input', props);
						pnlDynamicButtonsChildren.push(li);
					}
					else
					{
						//btnProps.size = 'tiny';
						// 04/05/2021 Paul.  Use class property instead of hard coded 'button'. 
						btnProps.className = CONTROL_CSSCLASS;
						if ( SplendidDynamic.StackedLayout(sTheme) )
						{
							btnProps.className = ButtonStyle + 'OtherButton';
						}
						// 12/10/2019 Paul.  Button does not look right.  Use input type submit. 
						btnProps.type  = 'submit';
						btnProps.value = '  ' + L10n.Term(CONTROL_TEXT) + '  ';
						btn = React.createElement('input', btnProps);
						pnlDynamicButtonsChildren.push(btn);
					}
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadButtons ' + CONTROL_TEXT, error);
				this.setState({ error });
			}
		}
		return pnlDynamicButtons;
	}

	private ReplaceTextValues = (URL: string, TEXT_FIELD: string) =>
	{
		const { row } = this.props;
		if ( !Sql.IsEmptyString(URL) )
		{
			let arrTEXT_FIELD = new Array();
			let objTEXT_FIELD = new Array();
			if ( !Sql.IsEmptyString(TEXT_FIELD) )
			{
				arrTEXT_FIELD = TEXT_FIELD.split(' ');
				objTEXT_FIELD = TEXT_FIELD.split(' ');
				for ( let i = 0; i < arrTEXT_FIELD.length; i++ )
				{
					if ( arrTEXT_FIELD[i].length > 0 )
					{
						objTEXT_FIELD[i] = '';
						if ( row != null )
						{
							if ( row[arrTEXT_FIELD[i]] != null )
							{
								objTEXT_FIELD[i] = row[arrTEXT_FIELD[i]];
							}
						}
						// 05/24/2024 Paul.  Allow security properties to be included. 
						if ( arrTEXT_FIELD[i].indexOf(".") > 0 )
						{
							const sFieldName = arrTEXT_FIELD[i].toLowerCase();
							if      ( sFieldName == "security.user_id"           ) objTEXT_FIELD[i] = Security.USER_ID()          ;
							else if ( sFieldName == "security.user_name"         ) objTEXT_FIELD[i] = Security.USER_NAME()        ;
							else if ( sFieldName == "security.team_id"           ) objTEXT_FIELD[i] = Security.TEAM_ID()          ;
							else if ( sFieldName == "security.team_name"         ) objTEXT_FIELD[i] = Security.TEAM_NAME()        ;
							else if ( sFieldName == "security.primary_role_id"   ) objTEXT_FIELD[i] = Security.PRIMARY_ROLE_ID()  ;
							else if ( sFieldName == "security.primary_role_name" ) objTEXT_FIELD[i] = Security.PRIMARY_ROLE_NAME();
						}
					}
				}
			}
			for ( let i = 0; i <objTEXT_FIELD.length; i++ )
			{
				URL = URL.replace('{' + i + '}', objTEXT_FIELD[i]);
			}
		}
		return URL;
	}

	private _onButtonClick = (lay: DYNAMIC_BUTTON) =>
	{
		const { row, ButtonStyle, Page_Command } = this.props;
		let COMMAND_NAME  : string  = Sql.ToString(lay.COMMAND_NAME   );
		let MODULE_NAME   : string  = Sql.ToString (lay.MODULE_NAME   );
		let ARGUMENT_FIELD: string  = Sql.ToString(lay.ARGUMENT_FIELD );
		let ONCLICK_SCRIPT: string  = Sql.ToString (lay.ONCLICK_SCRIPT);
		if ( ButtonStyle == 'DataGrid' && COMMAND_NAME == 'MassUpdate' )
		{
			COMMAND_NAME       = 'ToggleMassUpdate';
		}
		if ( Sql.IsEmptyString(COMMAND_NAME) )
		{
			COMMAND_NAME = ONCLICK_SCRIPT.replace('return false;', '');
			COMMAND_NAME = COMMAND_NAME.replace('Popup();', 's.Select');
			COMMAND_NAME = COMMAND_NAME.replace('Opportunitys', 'Opportunities');
		}
		if ( COMMAND_NAME.indexOf('.Create') > 0 || COMMAND_NAME.indexOf('.Select') > 0 )
		{
			ARGUMENT_FIELD = 'ID,NAME';
		}
		let oARGUMENT_VALUE = null;
		if ( !Sql.IsEmptyString(ARGUMENT_FIELD) )
		{
			oARGUMENT_VALUE = new Object();
			oARGUMENT_VALUE['PARENT_MODULE'] = MODULE_NAME;
			// 04/14/2016 Paul.  In order to inherit assigned user and team, might as well send the entire row. 
			oARGUMENT_VALUE['PARENT_row'] = row;
			let arrFields = ARGUMENT_FIELD.split(',');
			for ( let n = 0; n < arrFields.length; n++ )
			{
				if (row[arrFields[n]] != null)
				{
					oARGUMENT_VALUE[arrFields[n]] = row[arrFields[n]];
					//btn.CommandArgument = oARGUMENT_VALUE;
				}
			}
		}
		// 08/06/2020 Paul.  Confirm delete. 
		if ( ONCLICK_SCRIPT.indexOf('ConfirmDelete()') >= 0 )
		{
			if ( window.confirm(L10n.Term('.NTC_DELETE_CONFIRMATION')) )
			{
				Page_Command(COMMAND_NAME, oARGUMENT_VALUE);
			}
		}
		else
		{
			Page_Command(COMMAND_NAME, oARGUMENT_VALUE);
		}
	}

	private _onHyperLink = (lay: DYNAMIC_BUTTON) =>
	{
		let URL_FORMAT: string   = lay.URL_FORMAT;
		let TEXT_FIELD: string   = lay.TEXT_FIELD;
		let URL       : string   = Sql.ToString(URL_FORMAT);
		let arrURL    : string[] = URL.split('/');
		let URL_MODULE: string   = null;
		if ( arrURL.length > 1 )
		{
			URL_MODULE = arrURL[1];
		}
		if ( !Sql.IsEmptyString(URL_MODULE) )
		{
			// ~/Administration/QuickBooks/default.aspx?ShowSynchronized=1
			URL = URL.replace('default.aspx?ShowSynchronized=1', 'Synchronized');
			URL = URL.replace('~/'           , ''     );
			URL = URL.replace('default.aspx' , 'List' );
			URL = URL.replace('view.aspx?ID=', 'View/');
			URL = URL.replace('edit.aspx?ID=', 'Edit/');
			URL = URL.replace('.aspx?ID='    , '/'    );
			URL = this.ReplaceTextValues(URL, TEXT_FIELD);
			this.props.history.push('/Reset/' + URL);
		}
		else
		{
			let error: string = 'Unknown URL: ' + URL;
			this.setState({ error });
		}
	}

	private _onButtonLink = (lay: DYNAMIC_BUTTON) =>
	{
		const { Page_Command, row } = this.props;
		let VIEW_NAME     : string   = lay.VIEW_NAME     ;
		let TARGET_NAME   : string   = lay.TARGET_NAME   ;
		let COMMAND_NAME  : string   = lay.COMMAND_NAME  ;
		let URL_FORMAT    : string   = lay.URL_FORMAT    ;
		let TEXT_FIELD    : string   = lay.TEXT_FIELD    ;
		let ONCLICK_SCRIPT: string   = lay.ONCLICK_SCRIPT;
		let URL           : string     = Sql.ToString(URL_FORMAT);
		let URL_MODULE    : string   = null;
		let VIEW_MODULE   : string   = null;
		let arrVIEW_NAME  : string[] = VIEW_NAME.split('.');
		VIEW_MODULE = arrVIEW_NAME[0];

		URL = URL.replace('../../', '~/');
		URL = URL.replace('../'   , '~/');
		// 10/11/2019 Paul.  Check against URL so that we don't have to also check URL_FORMAT. 
		if ( StartsWith(URL, '~/') )
		{
			let arrURL: string[] = URL.split('/');
			URL_MODULE = arrURL[1];
		}
		else if ( !Sql.IsEmptyString(URL_FORMAT) && URL_FORMAT != '#' )
		{
			URL_MODULE = VIEW_MODULE;
			// 04/26/2020 Paul.  Must check for Admin module. 
			let module:MODULE = SplendidCache.Module(URL_MODULE, this.constructor.name + '._onButtonLink');
			if ( module.IS_ADMIN )
			{
				URL = '~/Administration/' + URL_MODULE + '/' + URL;
			}
			else
			{
				URL = '~/' + URL_MODULE + '/' + URL;
			}
		}
		if ( !Sql.IsEmptyString(URL_MODULE) )
		{
			if ( URL.indexOf('convert.aspx?ID=') >= 0 )
			{
				// 09/18/2019 Paul.  Use Target. 
				URL = TARGET_NAME + '/Convert/' + VIEW_MODULE + '/{0}';
			}
			else if ( URL.indexOf('ChatMessages/default.aspx') >= 0 )
			{
				URL = URL.replace('~/'                     , ''           );
				URL = URL.replace('default.aspx?PARENT_ID={0}&PARENT_TYPE=', '') + '/{0}';
			}
			// 10/11/2019 Paul.  Remove default.aspx. 
			else if ( URL.indexOf('RulesWizard/') >= 0 )
			{
				URL = URL.replace('~/'                     , ''           );
				// 05/01/2021 Paul.   Keep the Module= query parameter. 
				URL = URL.replace('edit.aspx'              , 'Edit'       );
				// 06/14/2021 Paul.  Still need to convert Cancel to a page command. 
				if ( COMMAND_NAME == 'Cancel' )
				{
					Page_Command(COMMAND_NAME, null);
					return;
				}
			}
			else if ( URL.indexOf('Reports/view.aspx') >= 0 )
			{
				URL = URL.replace('~/'                     , ''           );
				URL = URL.replace('view.aspx?ID='          , 'View/'      );
				URL = URL.replace('&'                      , '/'          );
				URL = URL.replace('='                      , '/'          );
			}
			else if ( URL.indexOf('Reports/attachment.aspx') >= 0 )
			{
				URL = URL.replace('~/'                     , ''           );
				URL = URL.replace('attachment.aspx?ID='    , 'Attachment/');
				let ID: string = (row ? row['ID'] : '00000000-0000-0000-0000-000000000000');
				URL = URL.replace('&'                      , '/' + VIEW_MODULE + '/' + ID + '/?');
			}
			else if ( URL.indexOf('Reports/SignaturePopup.aspx') >= 0 )
			{
				URL = URL.replace('~/'                     , ''           );
				URL = URL.replace('SignaturePopup.aspx?ID=', 'Signature/' );
				let ID: string = (row ? row['ID'] : '00000000-0000-0000-0000-000000000000');
				URL = URL.replace('&'                      , '/' + VIEW_MODULE + '/' + ID + '/?');
			}
			else if ( URL.indexOf('EditMyAccount.aspx') >= 0 )
			{
				// 10/08/2020 Paul.  MyAccount editing is no longer under Administration.
				//URL = URL.replace('~/'                     , ''           );
				//URL = URL.replace('.aspx'                  , ''           );
				URL = 'Users/EditMyAccount';
			}
			else if ( URL.indexOf('edit.aspx?UID=') >= 0 && arrVIEW_NAME.length == 3 )
			{
				URL = URL.replace('~/'                     , ''           );
				URL = URL.replace('edit.aspx?UID='         , arrVIEW_NAME[2] + '/Edit/');
			}
			else if ( URL.indexOf('edit.aspx?HID=') >= 0 && arrVIEW_NAME.length == 3 )
			{
				URL = URL.replace('~/'                     , ''           );
				URL = 'Administration/' + URL.replace('edit.aspx?HID='    , arrVIEW_NAME[2] + '/Edit/');
			}
			else if ( URL.indexOf('export.aspx?ID={0}') >= 0 )
			{
				URL = URL.replace('~/'                     , Credentials.RemoteServer);
				URL = this.ReplaceTextValues(URL, TEXT_FIELD);
				window.location.href = URL;
				// 08/29/2019 Paul.  Must return to prevent command being cancelled and internal routing to occur. 
				return;
			}
			// ../Reports/render.aspx?ID=F40989FE-24F5-4352-BB32-A23713EA6EC8&ORDER_ID={0}
			else if ( URL_FORMAT.indexOf('Reports/render.aspx?ID=') >= 0 )
			{
				URL = URL.replace('~/'                     , Credentials.RemoteServer);
				URL = this.ReplaceTextValues(URL, TEXT_FIELD);
				//console.log((new Date()).toISOString() + ' ' + URL);
				window.location.href = URL;
				// 08/29/2019 Paul.  Must return to prevent command being cancelled and internal routing to occur. 
				return;
			}
			else if ( URL_FORMAT.indexOf('vCard.aspx?ID=') >= 0 )
			{
				URL = Credentials.RemoteServer + TARGET_NAME + '/vCard.aspx?ID={0}';
				URL = this.ReplaceTextValues(URL, TEXT_FIELD);
				//console.log((new Date()).toISOString() + ' ' + URL);
				window.location.href = URL;
				// 08/29/2019 Paul.  Must return to prevent command being cancelled and internal routing to occur. 
				return;
			}
			else if ( VIEW_NAME.indexOf('.MassUpdate') >= 0 )
			{
				Page_Command(COMMAND_NAME, URL_FORMAT);
				return;
			}
			else if ( COMMAND_NAME == 'ViewRelatedActivities' )
			{
				Page_Command(COMMAND_NAME, URL_FORMAT);
				return;
			}
			// 10/29/2020 Paul.  Import cancel needs to go back to the ImportView so that it can redirect to the base module. 
			else if ( COMMAND_NAME == 'Cancel' && VIEW_MODULE == 'Import' )
			{
				Page_Command(COMMAND_NAME, null);
				return;
			}
			/*
			~/Administration/Azure/AzureAppUpdates/edit.aspx?AZURE_APP_PRICE_ID={0}
			~/Activities/popup.aspx?PARENT_ID={0}&IncludeRelationships=1
			../Posts/edit.aspx?THREAD_ID={0}
			../Posts/edit.aspx?QUOTE=1&THREAD_ID={0}
			../Orders/edit.aspx?OPPORTUNITY_ID={0}
			../Invoices/edit.aspx?ORDER_ID={0}
			../Emails/edit.aspx?KBDOCUMENT_ID={0}
			*/
			else
			{
				URL = URL.replace('~/'                     , ''           );
				URL = URL.replace('default.aspx'           , 'List'       );
				URL = URL.replace('view.aspx?ID='          , 'View/'      );
				URL = URL.replace('edit.aspx?ID='          , 'Edit/'      );
				URL = URL.replace('edit.aspx?DuplicateID=' , 'Duplicate/' );
				URL = URL.replace('edit.aspx'              , 'Edit'       );
				URL = URL.replace('.aspx?ID='              , '/'          );
			}

			URL = this.ReplaceTextValues(URL, TEXT_FIELD);
			//if ( ONCLICK_SCRIPT != null && ONCLICK_SCRIPT.length > 0 )
			//	btn.OnClientClick   = String.Format(ONCLICK_SCRIPT, objTEXT_FIELD);
			//else
			//	btn.OnClientClick   = 'window.location.href='' + Sql.EscapeJavaScript(String_Format(URL_FORMAT, objTEXT_FIELD)) + ''; return false;';
			//btn.onclick = new Function('function('' + sLayoutPanel + '', '' + COMMAND_NAME + '', null)');
			this.props.history.push('/Reset/' + URL);
		}
		else
		{
			let error: string = 'Unknown URL: ' + URL;
			this.setState({ error });
		}
	}

	// 10/30/2020 Paul.  We need a busy indicator for long-running tasks such as Archive. 
	public Busy = () =>
	{
		this.DisableAll();
		this.setState({ busy: true });
	}

	public NotBusy = () =>
	{
		this.EnableAll();
		this.setState({ busy: false });
	}

	public DisableAll = () =>
	{
		const { layout } = this.state;
		let { disabled } = this.state;
		if ( layout != null )
		{
			for (let iButton = 0; iButton < layout.length; iButton++)
			{
				let lay = layout[iButton];
				let COMMAND_NAME = Sql.ToString(lay.COMMAND_NAME);
				disabled[COMMAND_NAME] = Sql.ToInteger(disabled[COMMAND_NAME]) + 1;
			}
			this.setState({ disabled, bIsPostBack: true });
		}
	}

	public EnableAll = () =>
	{
		const { layout } = this.state;
		let { disabled } = this.state;
		if ( layout != null )
		{
			for (let iButton = 0; iButton < layout.length; iButton++)
			{
				let lay = layout[iButton];
				let COMMAND_NAME = Sql.ToString(lay.COMMAND_NAME);
				disabled[COMMAND_NAME] = Sql.ToInteger(disabled[COMMAND_NAME]) - 1;
			}
			this.setState({ disabled, bIsPostBack: true });
		}
	}

	public EnableButton = (COMMAND_NAME: string, bEnabled: boolean) =>
	{
		const { layout } = this.state;
		let { disabled } = this.state;
		if ( layout != null )
		{
			disabled[COMMAND_NAME] = (bEnabled ? 0 : 1);
			this.setState({ disabled, bIsPostBack: true });
		}
	}

	public HideAll = () =>
	{
		const { layout } = this.state;
		let { hidden } = this.state;
		if ( layout != null )
		{
			for (let iButton = 0; iButton < layout.length; iButton++)
			{
				let lay: DYNAMIC_BUTTON = layout[iButton];
				let COMMAND_NAME  : string = Sql.ToString(lay.COMMAND_NAME);
				let ONCLICK_SCRIPT: string = Sql.ToString(lay.ONCLICK_SCRIPT);
				// 07/05/2020 paul.  Need to use the OnClick name if command is empty. 
				if ( Sql.IsEmptyString(COMMAND_NAME) )
				{
					COMMAND_NAME = ONCLICK_SCRIPT.replace('return false;', '');
					COMMAND_NAME = COMMAND_NAME.replace('Popup();', 's.Select');
					COMMAND_NAME = COMMAND_NAME.replace('Opportunitys', 'Opportunities');
				}
				hidden[COMMAND_NAME] = Sql.ToInteger(hidden[COMMAND_NAME]) + 1;
			}
			this.setState({ hidden, bIsPostBack: true });
		}
	}

	public ShowAll = () =>
	{
		const { layout } = this.state;
		let { hidden } = this.state;
		if ( layout != null )
		{
			for (let iButton = 0; iButton < layout.length; iButton++)
			{
				let lay: DYNAMIC_BUTTON = layout[iButton];
				let COMMAND_NAME: string = Sql.ToString(lay.COMMAND_NAME);
				let ONCLICK_SCRIPT: string = Sql.ToString(lay.ONCLICK_SCRIPT);
				// 07/05/2020 paul.  Need to use the OnClick name if command is empty. 
				if ( Sql.IsEmptyString(COMMAND_NAME) )
				{
					COMMAND_NAME = ONCLICK_SCRIPT.replace('return false;', '');
					COMMAND_NAME = COMMAND_NAME.replace('Popup();', 's.Select');
					COMMAND_NAME = COMMAND_NAME.replace('Opportunitys', 'Opportunities');
				}
				hidden[COMMAND_NAME] = Sql.ToInteger(hidden[COMMAND_NAME]) - 1;
			}
			this.setState({ hidden, bIsPostBack: true });
		}
	}

	public ShowButton = (COMMAND_NAME: string, bVisible: boolean) =>
	{
		const { layout } = this.state;
		let { hidden } = this.state;
		if ( layout != null )
		{
			hidden[COMMAND_NAME] = (bVisible ? 0 : 1);
			this.setState({ hidden, bIsPostBack: true });
		}
	}

	public ShowHyperLink = (sURL: string, bVisible: boolean) =>
	{
		const { layout } = this.state;
		let { hidden } = this.state;
		if ( layout != null )
		{
			for (let iButton = 0; iButton < layout.length; iButton++)
			{
				let lay = layout[iButton];
				let URL_FORMAT = Sql.ToString(lay.URL_FORMAT);
				if ( URL_FORMAT == sURL )
				{
					hidden[URL_FORMAT] = (bVisible ? 0 : 1);
					break;
				}
			}
			this.setState({ hidden, bIsPostBack: true });
		}
	}

	public SetControlClass = (COMMAND_NAME: string, CONTROL_CSSCLASS: string) =>
	{
		let { layout } = this.state;
		if ( layout != null )
		{
			for (let iButton = 0; iButton < layout.length; iButton++)
			{
				let lay = layout[iButton];
				let sCOMMAND_NAME = Sql.ToString(lay.COMMAND_NAME);
				if ( COMMAND_NAME == sCOMMAND_NAME )
				{
					lay.CONTROL_CSSCLASS = CONTROL_CSSCLASS;
					break;
				}
			}
			this.setState({ layout });
		}
	}

	public render()
	{
		const { FrameStyle } = this.props;
		const { error, layout, busy } = this.state;
		if ( layout )
		{
			return (
				<div style={ FrameStyle }>
					{ this.LoadButtons() }
					<ErrorComponent error={error} />
					{ busy
					? <div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
						<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
					</div>
					: null
					}
				</div>
			);
		}
		else
		{
			return (<div></div>);
		}
	}
}

// 07/17/2019 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 
export default DynamicButtons;
