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
import { FontAwesomeIcon }                   from '@fortawesome/react-fontawesome'      ;
// 2. Store and Types. 
import { EditComponent }                     from '../types/EditComponent'              ;
import ACL_FIELD_ACCESS                      from '../types/ACL_FIELD_ACCESS'           ;
// 3. Scripts. 
import Sql                                   from './Sql'                               ;
import L10n                                  from './L10n'                              ;
import Security                              from '../scripts/Security'                 ;
import Credentials                           from '../scripts/Credentials'              ;
import SplendidCache                         from '../scripts/SplendidCache'            ;
import SplendidDynamic                       from '../scripts/SplendidDynamic'          ;
import { EditView_GetTabList, EditView_ActivateTab } from '../scripts/EditView'         ;
import { Crm_Config, Crm_Modules }           from './Crm'                               ;
import { isMobileDevice, isMobileLandscape, screenWidth, screenHeight } from './utility';
// 4. Components and Views. 
import Blank                                 from '../EditComponents/Blank'             ;
import Header                                from '../EditComponents/Header'            ;
import TextBox                               from '../EditComponents/TextBox'           ;
import HtmlEditor                            from '../EditComponents/HtmlEditor'        ;
import ZipCodePopup                          from '../EditComponents/ZipCodePopup'      ;
import CheckBox                              from '../EditComponents/CheckBox'          ;
import CheckBoxList                          from '../EditComponents/CheckBoxList'      ;
import Label                                 from '../EditComponents/Label'             ;
import Hidden                                from '../EditComponents/Hidden'            ;
import DatePicker                            from '../EditComponents/DatePicker'        ;
import DateTimeEdit                          from '../EditComponents/DateTimeEdit'      ;
import DateTimePicker                        from '../EditComponents/DateTimePicker'    ;
import TimePicker                            from '../EditComponents/TimePicker'        ;
import DateTimeNewRecord                     from '../EditComponents/DateTimeNewRecord' ;
import DateRange                             from '../EditComponents/DateRange'         ;
import ListBox                               from '../EditComponents/ListBox'           ;
import ModuleAutoComplete                    from '../EditComponents/ModuleAutoComplete';
import ModulePopup                           from '../EditComponents/ModulePopup'       ;
import ChangeButton                          from '../EditComponents/ChangeButton'      ;
import TeamSelect                            from '../EditComponents/TeamSelect'        ;
import UserSelect                            from '../EditComponents/UserSelect'        ;
import TagSelect                             from '../EditComponents/TagSelect'         ;
import NAICSCodeSelect                       from '../EditComponents/NAICSCodeSelect'   ;
import SplendidFile                          from '../EditComponents/File'              ;
import SplendidImage                         from '../EditComponents/Image'             ;
import Picture                               from '../EditComponents/Picture'           ;
import Password                              from '../EditComponents/Password'          ;
import Radio                                 from '../EditComponents/Radio'             ;
import SplendidButton                        from '../EditComponents/Button'            ;
import CRON                                  from '../EditComponents/CRON'              ;

export default class SplendidDynamic_EditView
{
	static HideLayoutField(layout, DATA_FIELD: string, hidden: boolean)
	{
		for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
		{
			let lay = layout[nLayoutIndex];
			if ( DATA_FIELD == lay.DATA_FIELD )
			{
				lay.hidden = hidden;
				break;
			}
		}
	}

	static SetRequiredFlag(layout, DATA_FIELD: string, required: boolean)
	{
		for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
		{
			let lay = layout[nLayoutIndex];
			if ( DATA_FIELD == lay.DATA_FIELD )
			{
				lay.UI_REQUIRED = required;
				break;
			}
		}
	}

	// 04/18/2021 Paul.  Go back to using tables instead of flex due to the field overlap. 
	static AppendEditViewFields(row, layout, refMap, callback, createDependency, fieldDidMount, onChange, onUpdate, onSubmit, sPanelClass: string, Page_Command: Function, isSearchView?: boolean, CONTROL_VIEW_NAME? : string): JSX.Element[]
	{
		return SplendidDynamic_EditView.AppendEditViewFields_Desktop(row, layout, refMap, callback, createDependency, fieldDidMount, onChange, onUpdate, onSubmit, sPanelClass, Page_Command, isSearchView, CONTROL_VIEW_NAME)
		//return SplendidDynamic_EditView.AppendEditViewFields_Mobile(row, layout, refMap, callback, createDependency, fieldDidMount, onChange, onUpdate, onSubmit, sPanelClass, Page_Command, isSearchView, CONTROL_VIEW_NAME)
	}

	// 04/23/2020 Paul.  A customer needs to know if the PopupView is being called from a SearchView or and EditView. 
	// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
	static AppendEditViewFields_Desktop(row, layout, refMap, callback, createDependency, fieldDidMount, onChange, onUpdate, onSubmit, sPanelClass: string, Page_Command: Function, isSearchView?: boolean, CONTROL_VIEW_NAME? : string): JSX.Element[]
	{
		//console.log((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView.AppendEditViewFields', row);
		let arrPanels      : Array<JSX.Element> = [];
		// 07/22/2019 Paul.  Apply ACL Field Security. 
		let MODULE_NAME : string = null;
		// 03/19/2020 Paul.  We need to dynamically create a unique baseId as the Leads.EditView.Inline and Contacts.EditView.Inline are both on the Accounts.DetailView page, leading to a naming confict. 
		let baseId: string = 'ctlEditView';
		// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
		if ( !Sql.IsEmptyString(CONTROL_VIEW_NAME) )
		{
			baseId += '_' + CONTROL_VIEW_NAME;
		}
		if ( layout != null && layout.length > 0 )
		{
			let EDIT_NAME   : string   = Sql.ToString(layout[0].EDIT_NAME );
			// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
			baseId += '_' + EDIT_NAME.replace(/\./g, '_');
			let arrEDIT_NAME: string[] = EDIT_NAME.split('.');
			if ( arrEDIT_NAME.length > 0 )
			{
				MODULE_NAME = arrEDIT_NAME[0];
			}
		}

		// 12/06/2014 Paul.  Use new mobile flag. 
		let sTheme        : string  = Security.USER_THEME();
		let bIsMobile     : boolean = isMobileDevice();
		let bStackedTheme : boolean = SplendidDynamic.StackedLayout(sTheme)
		let bStackedLayout: boolean = bStackedTheme;
		// 04/19/2021 Paul.  Manually calculate responsive features. 
		let bResponsiveOneColumn: boolean = false;
		let width : number = screenWidth();
		let height: number = screenHeight();
		if ( height > width )
		{
			// portrait
			if ( width < 992 )
			{
				bResponsiveOneColumn = true;
			}
			if ( width < 540 )
			{
				bStackedLayout       = true;
			}
		}
		else
		{
			// landscape 
			if ( width < 900 )
			{
				bResponsiveOneColumn = true;
			}
			if ( width < 540 )
			{
				bStackedLayout       = true;
			}
		}
		// 04/14/2022 Paul.  Add LayoutTabs to Pacific theme. 
		let objTabs: any = {};
		let bTabsEnabled: boolean = false;
		if ( sTheme == 'Pacific' )
		{
			let arrTabs: any[] = EditView_GetTabList(layout);
			if ( arrTabs != null && arrTabs.length > 0 )
			{
				let nActiveTabs: number = 0;
				for ( let i: number = 0; i < arrTabs.length; i++ )
				{
					let tab: any = arrTabs[i];
					objTabs[tab.nLayoutIndex] = tab;
					// 04/14/2022 Paul.  Make sure at least one tab is active. 
					if ( layout[tab.nLayoutIndex].ActiveTab )
					{
						nActiveTabs++;
					}
				}
				if ( nActiveTabs == 0 )
				{
					EditView_ActivateTab(layout, arrTabs[0].nLayoutIndex);
				}
				bTabsEnabled = true;
			}
		}
		//console.log('AppendEditViewFields_Desktop (' +  width + ', ' + height + ') ' + (bIsMobile ? 'mobile' : ''));
		// 04/15/2022 Paul.  We need a separate panel index instead of simply using count of main children. 
		let nPanelIndex: number = 0;
		let tabFormChildren = [];
		let tabForm = React.createElement('div', { style: {width: '100%'}, className: (sPanelClass == 'tabForm' ? sPanelClass : null)}, tabFormChildren);
		arrPanels.push(tabForm);
		// 11/13/2019 Paul.  The width is in the skin, so we need to apply manually. 
		let tblMainChildren: Array<JSX.Element> = [];
		let tblMainProps: any = { className: (sPanelClass == 'tabForm' ? 'tabEditView' : null), id: baseId + '_tblMain' + nPanelIndex.toString(), key: baseId + '_tblMain', style: { width: '100%' } };
		let tblMain = React.createElement('table', tblMainProps, tblMainChildren);
		tabFormChildren.push(tblMain);
		nPanelIndex++;
		if ( bStackedLayout )
		{
			tblMainProps.style.borderSpacing = '0px';
		}
		if ( layout == null )
		{
			return arrPanels;
		}
		let _onChange = (callback ? callback : onChange);
		try
		{
			let tblBodyChildren: Array<JSX.Element> = [];
			let tbody = React.createElement('tbody', { key: 'tbody' }, tblBodyChildren);
			tblMainChildren.push(tbody);

			let trChildren: Array<JSX.Element>;
			let tr                      : any     = null;
			let nColIndex               : number  = 0;
			let tdLabelChildren         : any[]   = [];
			let tdLabelProps            : any     = {};
			let tdLabel                 : any     = null;
			let tdFieldChildren         : any[]   = [];
			let tdFieldProps            : any     = { style: {} };
			let tdField                 : any     = null;
			let bEnableTeamManagement   : boolean = Crm_Config.enable_team_management();
			let bRequireTeamManagement  : boolean = Crm_Config.require_team_management();
			let bEnableDynamicTeams     : boolean = Crm_Config.enable_dynamic_teams();
			// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			let bEnableDynamicAssignment: boolean = Crm_Config.enable_dynamic_assignment();
			let bRequireUserAssignment  : boolean = Crm_Config.require_user_assignment();
			// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 

			// 08/31/2012 Paul.  Add support for speech. 
			let bEnableSpeech           : boolean = Crm_Config.enable_speech();
			let sUSER_AGENT             : string  = navigator.userAgent;
			if ( sUSER_AGENT == 'Chrome' || sUSER_AGENT.indexOf('Android') > 0 || sUSER_AGENT.indexOf('iPad') > 0 || sUSER_AGENT.indexOf('iPhone') > 0 )
			{
				bEnableSpeech = Crm_Config.enable_speech();
			}
			// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
			let oNumberFormat : any    = Security.NumberFormatInfo();
			// 05/30/2018 Paul.  Make sure to use let so that callbacks get the proper scope variable. 
			// https://www.pluralsight.com/guides/javascript-callbacks-variable-scope-problem
			// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
			let bEnableTaxLineItems: boolean = Crm_Config.ToBoolean('Orders.TaxLineItems');
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			let themeURL   : string  = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
			let legacyIcons: boolean = Crm_Config.ToBoolean('enable_legacy_icons');

			// 11/12/2019 Paul.  Declare DATA_COLUMNS outside loop so that we can calculate the padding. 
			let DATA_COLUMNS        : number = 2;
			let sFlexLabelFieldWidth: string = '100%';
			for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay = layout[nLayoutIndex];
				//alert(dumpObj(lay, 'EditViewUI.LoadView layout'));
				let EDIT_NAME                  = lay.EDIT_NAME;
				let FIELD_TYPE                 = lay.FIELD_TYPE;
				let DATA_LABEL                 = lay.DATA_LABEL;
				let DATA_FIELD                 = lay.DATA_FIELD;
				let DATA_FORMAT                = lay.DATA_FORMAT;
				let DISPLAY_FIELD              = lay.DISPLAY_FIELD;
				//let CACHE_NAME                 = lay.CACHE_NAME;
				//let LIST_NAME                  = lay.LIST_NAME;
				// 12/05/2012 Paul.  UI_REQUIRED is not used on SQLite, so use the DATA_REQUIRED value. 
				let UI_REQUIRED                = Sql.ToBoolean(lay.UI_REQUIRED) || Sql.ToBoolean(lay.DATA_REQUIRED);
				let ONCLICK_SCRIPT             = lay.ONCLICK_SCRIPT;
				//let FORMAT_SCRIPT              = lay.FORMAT_SCRIPT;
				//let FORMAT_TAB_INDEX           = Sql.ToInteger(lay.FORMAT_TAB_INDEX);
				//let FORMAT_MAX_LENGTH          = Sql.ToInteger(lay.FORMAT_MAX_LENGTH);
				//let FORMAT_SIZE                = Sql.ToInteger(lay.FORMAT_SIZE);
				//let FORMAT_ROWS                = Sql.ToInteger(lay.FORMAT_ROWS);
				//let FORMAT_COLUMNS             = Sql.ToInteger(lay.FORMAT_COLUMNS);
				let COLSPAN                    = Sql.ToInteger(lay.COLSPAN);
				//let ROWSPAN                    = Sql.ToInteger(lay.ROWSPAN);
				let LABEL_WIDTH                = lay.LABEL_WIDTH;
				let FIELD_WIDTH                = lay.FIELD_WIDTH;
				//let VIEW_NAME                  = lay.VIEW_NAME;
				//let FIELD_VALIDATOR_ID         = lay.FIELD_VALIDATOR_ID;
				//let FIELD_VALIDATOR_MESSAGE    = lay.FIELD_VALIDATOR_MESSAGE;
				//let UI_VALIDATOR               = lay.UI_VALIDATOR;
				//let VALIDATION_TYPE            = lay.VALIDATION_TYPE;
				//let REGULAR_EXPRESSION         = lay.REGULAR_EXPRESSION;
				//let DATA_TYPE                  = lay.DATA_TYPE;
				//let MININUM_VALUE              = lay.MININUM_VALUE;
				//let MAXIMUM_VALUE              = lay.MAXIMUM_VALUE;
				//let COMPARE_OPERATOR           = lay.COMPARE_OPERATOR;
				let MODULE_TYPE                = lay.MODULE_TYPE;
				//let FIELD_VALIDATOR_NAME       = lay.FIELD_VALIDATOR_NAME;
				let TOOL_TIP                   = lay.TOOL_TIP;
				//let VALID_RELATED              = false;
				//let RELATED_SOURCE_MODULE_NAME = lay.RELATED_SOURCE_MODULE_NAME;
				//let RELATED_SOURCE_VIEW_NAME   = lay.RELATED_SOURCE_VIEW_NAME;
				//let RELATED_SOURCE_ID_FIELD    = lay.RELATED_SOURCE_ID_FIELD;
				//let RELATED_SOURCE_NAME_FIELD  = lay.RELATED_SOURCE_NAME_FIELD;
				//let RELATED_VIEW_NAME          = lay.RELATED_VIEW_NAME;
				//let RELATED_ID_FIELD           = lay.RELATED_ID_FIELD;
				//let RELATED_NAME_FIELD         = lay.RELATED_NAME_FIELD;
				//let RELATED_JOIN_FIELD         = lay.RELATED_JOIN_FIELD;
				//let PARENT_FIELD               = lay.PARENT_FIELD;
				// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
				let bIsHidden: boolean            = lay.hidden;
				
				DATA_COLUMNS = Sql.ToInteger(lay.DATA_COLUMNS);
				if ( DATA_COLUMNS == 0 )
				{
					DATA_COLUMNS = 2;
				}
				if ( bResponsiveOneColumn )
				{
					DATA_COLUMNS = 1;
					COLSPAN      = 0;
				}
				// 07/01/2023 Paul.  Report Parameters does not include width. 
				if ( LABEL_WIDTH == null )
				{
					LABEL_WIDTH = '15%';
				}
				if ( FIELD_WIDTH == null )
				{
					FIELD_WIDTH = '35%';
				}
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				// 04/19/2019 Paul.  Calculate flex width. 
				sFlexLabelFieldWidth = Math.floor(100 / DATA_COLUMNS) + '%';
				// 04/19/2019 Paul.  Convert to single sell width by multiplying by columns. 
				let nLABEL_WIDTH = parseInt(LABEL_WIDTH.replace('%', ''));
				let nFIELD_WIDTH = parseInt(FIELD_WIDTH.replace('%', ''));
				// 08/25/2019 Paul.  With COLSPAN 3, we need to assume that it is the only field on the row. 
				if ( COLSPAN == 3 )
				{
					LABEL_WIDTH = nLABEL_WIDTH + '%';
					FIELD_WIDTH = (nLABEL_WIDTH * (DATA_COLUMNS - 1) + nFIELD_WIDTH * DATA_COLUMNS) + '%';
				}
				else
				{
					LABEL_WIDTH = nLABEL_WIDTH + '%';
					FIELD_WIDTH = nFIELD_WIDTH + '%';
				}

				let sGridLabel = 'dataLabel';
				let sGridInput = 'dataField';
				let bIsReadable  : boolean = true;
				let bIsWriteable : boolean = true;
				if ( SplendidCache.bEnableACLFieldSecurity )
				{
					let gASSIGNED_USER_ID: string = null;
					if ( row != null )
					{
						gASSIGNED_USER_ID = Sql.ToGuid(row.ASSIGNED_USER_ID);
					}
					let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
					// 02/16/2011 Paul.  We should allow a Read-Only field to be searchable, so always allow writing if the name contains Search. 
					bIsWriteable = acl.IsWriteable() || EDIT_NAME.indexOf(".Search") >= 0;
					if ( !bIsWriteable )
					{
						// 11/11/2020 Paul.  No longer need this warning. 
						//console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView NOT WRITEABLE', MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					}
				}
				if ( !bIsReadable )
				{
					FIELD_TYPE = 'Blank';
				}
				
				if ( ( DATA_FIELD == 'TEAM_ID' || DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( !bEnableTeamManagement )
					{
						FIELD_TYPE = 'Blank';
						// 10/24/2012 Paul.  Clear the label to prevent a term lookup. 
						DATA_LABEL  = null;
						DATA_FIELD  = null;
						UI_REQUIRED = false;
					}
					else
					{
						if ( bEnableDynamicTeams )
						{
							// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
							// 10/20/2017 Paul.  Don't convert MyPipelineBySalesStage. 
							if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
							{
								DATA_LABEL     = '.LBL_TEAM_SET_NAME';
								DATA_FIELD     = 'TEAM_SET_NAME';
								FIELD_TYPE     = 'TeamSelect';
								ONCLICK_SCRIPT = '';
								// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
								lay.DATA_LABEL     = '.LBL_TEAM_SET_NAME';
								lay.DATA_FIELD     = 'TEAM_SET_NAME';
								lay.FIELD_TYPE     = 'TeamSelect';
								lay.ONCLICK_SCRIPT = '';
							}
						}
						else
						{
							// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
							if ( FIELD_TYPE == 'TeamSelect' )
							{
								DATA_LABEL     = 'Teams.LBL_TEAM';
								DATA_FIELD     = 'TEAM_ID';
								DISPLAY_FIELD  = 'TEAM_NAME';
								FIELD_TYPE     = 'ModulePopup';
								MODULE_TYPE    = 'Teams';
								ONCLICK_SCRIPT = '';
								// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
								lay.DATA_LABEL     = 'Teams.LBL_TEAM';
								lay.DATA_FIELD     = 'TEAM_ID';
								lay.DISPLAY_FIELD  = 'TEAM_NAME';
								lay.FIELD_TYPE     = 'ModulePopup';
								lay.MODULE_TYPE    = 'Teams';
								lay.ONCLICK_SCRIPT = '';
							}
						}
						// 11/25/2006 Paul.  Override the required flag with the system value. 
						// 01/01/2008 Paul.  If Team Management is not required, then let the admin decide. 
						// 97/06/2017 Paul.  Don't show required flag in search or popup. 
						// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
						// 06/19/2021 Paul.  WorkflowAlertShells does not require Team or User. 
						if ( bRequireTeamManagement && EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.MassUpdate') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('WorkflowAlertShells') < 0 )
						{
							UI_REQUIRED = true;
						}
					}
				}
				// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( (DATA_FIELD == 'ASSIGNED_USER_ID' || DATA_FIELD == 'ASSIGNED_SET_NAME') )
				{
					// 01/06/2018 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					if ( bEnableDynamicAssignment && DATA_FORMAT != "1" )
					{
						if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
						{
							DATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
							DATA_FIELD     = 'ASSIGNED_SET_NAME'     ;
							FIELD_TYPE     = 'UserSelect'            ;
							ONCLICK_SCRIPT = ''                      ;
							// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
							lay.DATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
							lay.DATA_FIELD     = 'ASSIGNED_SET_NAME'     ;
							lay.FIELD_TYPE     = 'UserSelect'            ;
							lay.ONCLICK_SCRIPT = ''                      ;
						}
					}
					else
					{
						if ( FIELD_TYPE == 'UserSelect' )
						{
							DATA_LABEL     = '.LBL_ASSIGNED_TO';
							DATA_FIELD     = 'ASSIGNED_USER_ID';
							DISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
							FIELD_TYPE     = 'ModulePopup'     ;
							MODULE_TYPE    = 'Users'           ;
							ONCLICK_SCRIPT = ''                ;
							// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
							lay.DATA_LABEL     = '.LBL_ASSIGNED_TO';
							lay.DATA_FIELD     = 'ASSIGNED_USER_ID';
							lay.DISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
							lay.FIELD_TYPE     = 'ModulePopup'     ;
							lay.MODULE_TYPE    = 'Users'           ;
							lay.ONCLICK_SCRIPT = ''                ;
						}
					}
					// 06/19/2021 Paul.  bRequireUserAssignment is the correct flag here, not bRequireTeamManagement, but also, same rules for not in Search, MassUpdate or Popup. 
					// 06/19/2021 Paul.  WorkflowAlertShells does not require Team or User. 
					// 06/08/2022 Paul.  layout.EDIT_NAME was incorrect. 
					if ( bRequireUserAssignment && EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.MassUpdate') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('WorkflowAlertShells') < 0 )
					{
						UI_REQUIRED = true;
					}
				}
				// 04/04/2010 Paul.  Hide the Exchange Folder field if disabled for this module or user. 
				else if ( DATA_FIELD == 'EXCHANGE_FOLDER' )
				{
					// 01/09/2021 Paul.  We need to hide the EXCHANGE_FOLDER field if the user does not have Exchange enabled. 
					if ( !Crm_Modules.ExchangeFolders(MODULE_NAME) || !Security.HasExchangeAlias() )
					{
						FIELD_TYPE = 'Blank';
						DATA_LABEL = '';
					}
				}
				// 12/13/2013 Paul.  Allow each product to have a default tax rate. 
				else if ( DATA_FIELD == 'TAX_CLASS' )
				{
					if ( bEnableTaxLineItems )
					{
						// 07/22/2019 Paul.  Also correct these values in the ListBox component as changing the cache here will make no difference. 
						DATA_LABEL = "ProductTemplates.LBL_TAXRATE_ID";
						DATA_FIELD = "TAXRATE_ID";
						//CACHE_NAME = "TaxRates";
					}
				}
				
				if ( FIELD_TYPE == 'Blank' )
				{
					UI_REQUIRED = false;
				}
				// 04/14/2022 Paul.  Add LayoutTabs to Pacific theme. 
				if ( !bTabsEnabled && FIELD_TYPE == 'Header' && DATA_FORMAT == 'tab-only' )
				{
					// 04/14/2022 Paul.  Ignore the layout field if tabs not enabled (i.e. not Pacific) and this is only to be used as a tab. 
					continue;
				}
				else if ( bTabsEnabled && objTabs[nLayoutIndex] )
				{
					// 04/14/2022 Paul.  We don't want an empty panel, so if current panel is empty, then continue to use and correct the display style. 
					if ( nLayoutIndex == 0 )
					{
						let style: any = tabForm.props.style;
						style.display = (lay.ActiveTab ? 'inherit' : 'none');
						nPanelIndex++;
					}
					else
					{
						tabFormChildren = [];
						tabForm = React.createElement('div', { style: {width: '100%', display: (lay.ActiveTab ? 'inherit' : 'none')}, className: (sPanelClass == 'tabForm' ? sPanelClass : null)}, tabFormChildren);
						arrPanels.push(tabForm);
						tblMainChildren = [];
						tblMainProps = { className: (sPanelClass == 'tabForm' ? 'tabEditView' : null), id: baseId + '_tblMain' + nPanelIndex.toString(), key: baseId + '_tblMain_' + nPanelIndex.toString(), style: {width: '100%', marginTop: '5px'} };
						tblMain = React.createElement('table', tblMainProps, tblMainChildren);
						tabFormChildren.push(tblMain);
						if ( bStackedLayout )
						{
							tblMainProps.style.borderSpacing = '0px';
						}
						tblBodyChildren = [];
						tbody = React.createElement('tbody', { key: 'tbody' + nLayoutIndex }, tblBodyChildren);
						tblMainChildren.push(tbody);
						nPanelIndex++;
					}
					nColIndex = 0;
					tr = null;
					continue;
				}
				// 09/02/2012 Paul.  A separator will create a new table. We need to match the outer and inner layout. 
				else if ( FIELD_TYPE == 'Separator' )
				{
					// 11/12/2019 Paul.  Add remaining cells. 
					// 04/19/2021 Paul.  This does not apply to desktop mode. 
					/*
					for ( let i = 0; i < tblBodyChildren.length % DATA_COLUMNS; i++ )
					{
						trChildren = [];
						tr = React.createElement('tr', trChildren);
						tblBodyChildren.push(tr);
					}
					*/
					
					tabFormChildren = [];
					tabForm = React.createElement('div', { style: {width: '100%'}, className: (sPanelClass == 'tabForm' ? sPanelClass : null)}, tabFormChildren);
					// 04/16/2022 Paul.  Separators usually start a new table or division, so separators after active tab need to be treated as a set. 
					if ( bTabsEnabled )
					{
						let style: any = tabForm.props.style;
						style.display = (lay.ActiveTab ? 'inherit' : 'none');
					}
					arrPanels.push(tabForm);
					tblMainChildren = [];
					tblMainProps = { className: (sPanelClass == 'tabForm' ? 'tabEditView' : null), id: baseId + '_tblMain' + nPanelIndex.toString(), key: baseId + '_tblMain_' + nPanelIndex.toString(), style: {width: '100%', marginTop: '5px'} };
					tblMain = React.createElement('table', tblMainProps, tblMainChildren);
					tabFormChildren.push(tblMain);
					if ( bStackedLayout )
					{
						tblMainProps.style.borderSpacing = '0px';
					}
					// 04/16/2022 Paul.  Separators usually start a new table or division, so separators after active tab need to be treated as a set. 
					if ( bTabsEnabled )
					{
						tblMainProps.style.display = (lay.ActiveTab ? 'table' : 'none');
						nPanelIndex++;
					}
					tblBodyChildren = [];
					tbody = React.createElement('tbody', { key: 'tbody' + nLayoutIndex }, tblBodyChildren);
					tblMainChildren.push(tbody);
					nColIndex = 0;
					tr = null;
					continue;
				}
				// 09/03/2012 Paul.  We are going to ignore address buttons. 
				else if ( FIELD_TYPE == 'AddressButtons' )
				{
					continue;
				}
				// 11/17/2007 Paul.  On a mobile device, each new field is on a new row. 
				// 12/02/2005 Paul.  COLSPAN == -1 means that a new column should not be created. 
				// 12/06/2014 Paul.  Use new mobile flag. 
				// 02/26/2016 Paul.  We do not want the 1 column layout for the search panel on an OfficeAddin. 
				if ( (COLSPAN >= 0 && nColIndex == 0) || tr == null || (bIsMobile && EDIT_NAME.indexOf('.SearchSubpanel.OfficeAddin') < 0) )
				{
					// 11/25/2005 Paul.  Don't pre-create a row as we don't want a blank
					// row at the bottom.  Add rows just before they are needed. 
					trChildren = [];
					// 08/25/2019 Paul.  This is the correct place to handle colspan. 
					// 04/04/2022 Paul.  sFlexLabelFieldWidth is only used for Stacked layout. 
					//if ( COLSPAN == 3 )
					//{
					//	sFlexLabelFieldWidth  = '100%';
					//}
					tr = React.createElement('tr', { key: FIELD_TYPE + 'row' + nLayoutIndex }, trChildren);
					tblBodyChildren.push(tr);
				}
				// 06/20/2009 Paul.  The label and the field will be on separate rows for a NewRecord form. 
				let trLabelChildren = trChildren;
				let trLabel = tr;
				let trFieldChildren = trChildren;
				let trField = tr;
				if ( COLSPAN >= 0 || tdLabel == null || tdField == null )
				{
					// 06/21/2015 Paul.  The Seven theme has labels stacked above values. 
					if ( bStackedLayout )
					{
						tdLabelProps = { className: sGridLabel, style: {} };
						tdFieldProps = { className: sGridInput, style: {} };
						
						tdLabelChildren = [];
						tdLabelProps.id  = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
						tdLabelProps.key = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
						
						tdFieldChildren = [];
						tdFieldProps.key = FIELD_TYPE + 'tdfield' + nLayoutIndex;
						tdFieldProps.id  = FIELD_TYPE + 'tdfield' + nLayoutIndex;
						
						let tdStackChildren = [];
						let tdStackProps: any = { style: {} };
						if ( bStackedTheme )
						{
							// 04/04/2022 Paul.  Columns are not getting equal width. 
							tdStackProps.style.width = sFlexLabelFieldWidth;
							tdStackProps.className   = 'tabStackedEditViewDF';
							tdLabelProps.className   = 'tabStackedEditViewDL';
							// 04/04/2022 Paul.  Can't seem to select the Serach view with existing css, so add new class. 
							if ( sTheme == 'Pacific' && isSearchView )
							{
								tdStackProps.className = 'tabStackedEditViewDF tabStackedEditViewDFSearch';
								tdLabelProps.className = 'tabStackedEditViewDL tabStackedEditViewDLSearch';
							}
							// 04/04/2022 Paul.  Must support colspan in the normal way. 
							if ( COLSPAN > 0 )
							{
								tdStackProps.colSpan = (COLSPAN + 1) / 2;
							}
						}
						//else
						{
							tdLabelProps.style.lineHeight = 'inherit';
							tdLabelProps.style.textAlign  = 'inherit';
							tdStackProps.style.padding    = '0px';
						}
						if ( sTheme == 'Pacific' && !isSearchView )
						{
							tdStackProps.style.paddingLeft  = '1em';
							tdStackProps.style.paddingRight = '1em';
							// 04/16/2022 Paul.  We seem to need to force the width when multiple panels are displayed. 
							tdStackProps.style.width        = sFlexLabelFieldWidth;
							if ( DATA_COLUMNS > 1 && COLSPAN <= 1 )
							{
								if ( (nColIndex < DATA_COLUMNS - 1) )
								{
									tdStackProps.style.borderRight = '.0625rem solid #93a4b3';
								}
							}
						}
						// 03/19/2020 Paul.  Center instead of baseline or top. 
						
						let tdStack = React.createElement('td', tdStackProps, tdStackChildren);
						trChildren.push(tdStack);
						// 08/25/2019 Paul.  For ChangeButton with PARENT_TYPE, we need to have the control handle it as there is an interaction between label and field. 
						if ( !(FIELD_TYPE == 'ChangeButton' && DATA_LABEL == 'PARENT_TYPE') )
						{
							tdLabel = React.createElement('div', tdLabelProps, tdLabelChildren);
							tdStackChildren.push(tdLabel);
						}

						tdField = React.createElement('div', tdFieldProps, tdFieldChildren);
						if ( FIELD_TYPE != 'Header' )
						{
							tdStackChildren.push(tdField);
						}
					}
					else
					{
						tdLabelChildren = [];
						tdLabelProps = { style: {} };
						tdLabelProps.id  = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
						tdLabelProps.key = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
						tdLabelProps.className = sGridLabel;
						// 11/12/2019 Paul.  Default top align looks terrible. 
						// 12/17/2019 Paul.  Baseline looks better than center, especially for multi-line controls such as Teams and Tags. 
						// 03/19/2020 Paul.  Center instead of baseline or top. 
						tdLabelProps.style = { width: LABEL_WIDTH };
						if ( FIELD_TYPE == 'Header' )
						{
							if ( !bStackedLayout )
								tdLabelProps.colSpan = 2;
						}
						
						tdFieldChildren = [];
						tdFieldProps = { style: {} };
						// 08/25/2019 Paul.  For ChangeButton with PARENT_TYPE, we need to have the control handle it as there is an interaction between label and field. 
						if ( !(FIELD_TYPE == 'ChangeButton' && DATA_LABEL == 'PARENT_TYPE') )
						{
							tdLabel = React.createElement('td', tdLabelProps, tdLabelChildren);
							trLabelChildren.push(tdLabel);
						}
						else
						{
							// 08/25/2019 Paul.  And give 100% of the cell to the control to manage. 
							//FIELD_WIDTH = (nFIELD_WIDTH + nLABEL_WIDTH).toString() + '%';
							// 05/06/2021 Paul.  Need to force the span as the label and field use the same cell. 
							COLSPAN = 3;
						}

						tdFieldProps.key = FIELD_TYPE + 'tdfield' + nLayoutIndex;
						tdFieldProps.id  = FIELD_TYPE + 'tdfield' + nLayoutIndex;
						tdFieldProps.className = sGridInput;
						if ( COLSPAN > 0 )
						{
							tdFieldProps.colSpan = (COLSPAN + 1) / 2;
						}
						// 11/28/2005 Paul.  Don't use the field width if COLSPAN is specified as we want it to take the rest of the table.  The label width will be sufficient. 
						if ( COLSPAN == 0 )
						{
							tdFieldProps.style = { width: FIELD_WIDTH };
						}
						tdField = React.createElement('td', tdFieldProps, tdFieldChildren);
						if ( FIELD_TYPE != 'Header' )
						{
							trLabelChildren.push(tdField);
						}
					}
					// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
					if ( !bIsHidden )
					{
						// 04/28/2019 Paul.  Header text goes in the field column, leaving the label column blank. 
						if ( DATA_LABEL != null && FIELD_TYPE != 'Header' )
						{
							if ( DATA_LABEL.indexOf('.') >= 0 )
							{
								let txt = L10n.Term(DATA_LABEL);
								// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
								// 01/29/2020 Paul.  Allow the label to contain HTML. 
								// 03/19/2020 Paul.  Make sure that tag exists, otherwise labels will not be aligned right. 
								if ( txt.indexOf('</span>') >= 0 )
								{
									let html = React.createElement('span', { dangerouslySetInnerHTML: { __html: txt } });
									tdLabelChildren.push(html);
								}
								else
								{
									txt = Sql.ReplaceEntities(txt);
									tdLabelChildren.push(txt);
								}
							}
							else if ( !Sql.IsEmptyString(DATA_LABEL) && row != null )
							{
								// 06/21/2015 Paul.  Label can contain raw text. 
								let sLabel = row[DATA_LABEL];
								if ( sLabel === undefined )
								{
									sLabel = Sql.ToString(DATA_LABEL);
								}
								else
								{
									sLabel = Sql.ToString(sLabel) + ':';
								}
								// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
								let txt = Sql.ReplaceEntities(sLabel);
								tdLabelChildren.push(txt);
							}
							// 07/24/2019 Paul.  Tool tip as simple hover. 
							if ( !Sql.IsEmptyString(TOOL_TIP) )
							{
								let sTOOL_TIP = TOOL_TIP;
								if ( TOOL_TIP.indexOf('.') >= 0 )
								{
									sTOOL_TIP = L10n.Term(TOOL_TIP);
								}
								let text = React.createElement('span', {className: 'reactTooltipText'}, sTOOL_TIP   );
								// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
								let icon = null;
								if ( legacyIcons )
									icon = React.createElement('img', {src: (themeURL + 'tooltip_inline.gif')}, null        );
								else
									icon = React.createElement(FontAwesomeIcon, {icon: 'question' }, null        );
								let tip  = React.createElement('span', {className: 'reactTooltip'    }, [icon, text]);
								tdLabelChildren.push(tip);
							}
						}
						// 08/06/2020 Paul.  Hidden fields cannot be required. 
						if ( UI_REQUIRED && FIELD_TYPE != 'Hidden' )
						{
							let lblRequired = React.createElement('span', { className: 'required', key: FIELD_TYPE + 'lblrequired' + nLayoutIndex }, L10n.Term('.LBL_REQUIRED_SYMBOL'));
							tdLabelChildren.push(lblRequired);
						}
					}
				}
				let key = baseId + '_FieldIndex_' + lay.FIELD_INDEX;
				if ( !Sql.IsEmptyString(DATA_FIELD) )
				{
					if ( refMap[DATA_FIELD] == null )
					{
						key = DATA_FIELD;
					}
					else
					{
						console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView ' + EDIT_NAME + '.' + DATA_FIELD + ' already exists in refMap.');
					}
				}
				let ref = React.createRef<EditComponent<any, any>>();
				refMap[key] = ref;
				//alert(DATA_FIELD);
				try
				{

					if ( FIELD_TYPE == 'Blank' )
					{
						tdLabelChildren.push('\u00a0');
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(Blank, txtProps);
						tdFieldChildren.push(txt);
					}
					// 09/03/2012 Paul.  A header is similar to a label, but without the data field. 
					else if ( FIELD_TYPE == 'Header' )
					{
						tdLabelChildren.pop();
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(Header, txtProps);
						// 04/18/2021 Paul.  Remove this from Desktop mode. 
						//tdLabelProps.style.width = (nLABEL_WIDTH + nFIELD_WIDTH * 2) + '%';
						tdLabelChildren.push(txt);
						// 08/08/2019 Paul.  We need to reset the table so that the next field will start on a new line. 
						// 10/31/2019 Paul.  A header does not force a new line.  This is so a header can be at the top of each column, like Billing and Shipping for Quotes. 
						// 04/20/2021 Paul.  Reset the row. 
						if ( COLSPAN == 3 )
						{
							tr = null;
							nColIndex = 0;
						}
					}
					else if ( FIELD_TYPE == 'Hidden' )
					{
						// 02/28/2008 Paul.  When the hidden field is the first in the row, we end up with a blank row. 
						// Just ignore for now as IE does not have a problem with the blank row. 
						COLSPAN = -1;
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(Hidden, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'ModuleAutoComplete' )
					{
						// 11/21/2021 Paul.  Use Page_Command to send AutoComplete selection event. 
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden, Page_Command };
						let txt = React.createElement(ModuleAutoComplete, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'ModulePopup' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden, isSearchView };
						// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
						if ( DATA_FIELD == 'PRODUCT_TEMPLATE_ID' )
						{
							txtProps.allowCustomName = true;
						}
						let txt = React.createElement(ModulePopup, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'ChangeButton' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(ChangeButton, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'TeamSelect' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(TeamSelect, txtProps);
						tdFieldChildren.push(txt);
					}
					// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( FIELD_TYPE == 'UserSelect' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(UserSelect, txtProps);
						tdFieldChildren.push(txt);
					}
					// 05/14/2016 Paul.  Add Tags module. 
					else if ( FIELD_TYPE == 'TagSelect' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(TagSelect, txtProps);
						tdFieldChildren.push(txt);
					}
					// 06/07/2017 Paul.  Add NAICSCodes module. 
					else if ( FIELD_TYPE == 'NAICSCodeSelect' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(NAICSCodeSelect, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'TextBox' )
					{
						// 11/02/2019 Paul.  layout changes are not detected, so we need to send the hidden field as a separate property. 
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						// 09/27/2020 Paul.  We need to be able to disable the default grow on TextBox. 
						if ( nLayoutIndex+1 < layout.length )
						{
							let layNext = layout[nLayoutIndex + 1];
							if ( Sql.ToInteger(layNext.COLSPAN) == -1 )
							{
								txtProps.bDisableFlexGrow = true;
							}
						}
						let txt = React.createElement(TextBox, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'HtmlEditor' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(HtmlEditor, txtProps);
						tdFieldChildren.push(txt);
					}
					// 04/14/2016 Paul.  Add ZipCode lookup. 
					else if ( FIELD_TYPE == 'ZipCodePopup' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(ZipCodePopup, txtProps);
						tdFieldChildren.push(txt);
					}
					// 05/24/2017 Paul.  Need support for DateRange for new Dashboard. 
					else if ( FIELD_TYPE == 'DateRange' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(DateRange, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'DatePicker' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(DatePicker, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'DateTimeEdit' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(DateTimeEdit, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'DateTimeNewRecord' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(DateTimeNewRecord, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'DateTimePicker' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(DateTimePicker, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'TimePicker' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(TimePicker, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'ListBox' )
					{
						let lstProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lst = React.createElement(ListBox, lstProps);
						tdFieldChildren.push(lst);
					}
					// 08/01/2013 Paul.  Add support for CheckBoxList. 
					else if ( FIELD_TYPE == 'CheckBoxList' )
					{
						let lstProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lst = React.createElement(CheckBoxList, lstProps);
						tdFieldChildren.push(lst);
					}
					// 08/01/2013 Paul.  Add support for Radio. 
					else if ( FIELD_TYPE == 'Radio' )
					{
						let chkProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let chk = React.createElement(Radio, chkProps);
						tdFieldChildren.push(chk);
					}
					else if ( FIELD_TYPE == 'CheckBox' )
					{
						let chkProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let chk = React.createElement(CheckBox, chkProps);
						tdFieldChildren.push(chk);
					}
					else if ( FIELD_TYPE == 'Label' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lbl = React.createElement(Label, lblProps);
						tdFieldChildren.push(lbl);
					}
					// 05/27/2016 Paul.  Add support for File type. 
					else if ( FIELD_TYPE == 'File' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lbl = React.createElement(SplendidFile, lblProps);
						tdFieldChildren.push(lbl);
					}
					// 11/04/2019 Paul.  Add support for Button type. 
					else if ( FIELD_TYPE == 'Button' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden, Page_Command };
						let lbl = React.createElement( SplendidButton, lblProps );
						tdFieldChildren.push( lbl );
					}
					// 07/01/2020 Paul.  Add support for Image type. 
					else if ( FIELD_TYPE == 'Image' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lbl = React.createElement(SplendidImage, lblProps);
						tdFieldChildren.push(lbl);
					}
					// 07/02/2020 Paul.  Add support for Picture type. 
					else if ( FIELD_TYPE == 'Picture' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lbl = React.createElement(Picture, lblProps);
						tdFieldChildren.push(lbl);
					}
					// 07/04/2020 Paul.  Add support for Password type. 
					else if ( FIELD_TYPE == 'Password' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lbl = React.createElement(Password, lblProps);
						tdFieldChildren.push(lbl);
					}
					// 03/28/2021 Paul.  Add support for CRON type. 
					else if ( FIELD_TYPE == 'CRON' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lbl = React.createElement(CRON, lblProps);
						tdFieldChildren.push(lbl);
					}
					else
					{
						//08/31/2012 Paul.  Add debugging code. 
						console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView.AppendEditViewFields() Unknown field type: ' + FIELD_TYPE);
					}
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendEditViewFields ' + FIELD_TYPE + ' ' + DATA_FIELD, error);
				}
				// 12/02/2007 Paul.  Each view can now have its own number of data columns. 
				// This was needed so that search forms can have 4 data columns. The default is 2 columns. 
				if ( COLSPAN > 0 )
				{
					nColIndex += COLSPAN;
				}
				else if ( COLSPAN == 0 )
				{
					nColIndex++;
				}
				if ( nColIndex >= DATA_COLUMNS )
				{
					nColIndex = 0;
				}
			}
			// 11/12/2019 Paul.  Add remaining cells. 
			// 04/18/2021 Paul.  Not needed for desktop layout. 
			/*
			for ( let i = 0; i < tblBodyChildren.length % DATA_COLUMNS; i++ )
			{
				trChildren = [];
				if ( SplendidDynamic.StackedLayout(sTheme) )
					tr = React.createElement('div', { className: 'tabStackedEditViewDF', style: { flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '1px 5px' } }, trChildren);
				else
					tr = React.createElement('div', { style: { display: 'flex', flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '1px 5px' } }, trChildren);
				tblBodyChildren.push(tr);
			}
			*/
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendEditViewFields', error);
		}
		return arrPanels;
	}

	// 04/23/2020 Paul.  A customer needs to know if the PopupView is being called from a SearchView or and EditView. 
	// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
	static AppendEditViewFields_Mobile(row, layout, refMap, callback, createDependency, fieldDidMount, onChange, onUpdate, onSubmit, sPanelClass: string, Page_Command: Function, isSearchView?: boolean, CONTROL_VIEW_NAME? : string): JSX.Element[]
	{
		//console.log((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView.AppendEditViewFields', row);
		let arrPanels      : Array<JSX.Element> = [];
		let tblMainChildren: Array<JSX.Element> = [];
		// 07/22/2019 Paul.  Apply ACL Field Security. 
		let MODULE_NAME : string = null;
		// 03/19/2020 Paul.  We need to dynamically create a unique baseId as the Leads.EditView.Inline and Contacts.EditView.Inline are both on the Accounts.DetailView page, leading to a naming confict. 
		let baseId: string = 'ctlEditView';
		// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
		if ( !Sql.IsEmptyString(CONTROL_VIEW_NAME) )
		{
			baseId += '_' + CONTROL_VIEW_NAME;
		}
		if ( layout != null && layout.length > 0 )
		{
			let EDIT_NAME   : string   = Sql.ToString(layout[0].EDIT_NAME );
			// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
			baseId += '_' + EDIT_NAME.replace(/\./g, '_');
			let arrEDIT_NAME: string[] = EDIT_NAME.split('.');
			if ( arrEDIT_NAME.length > 0 )
			{
				MODULE_NAME = arrEDIT_NAME[0];
			}
		}

		// 11/13/2019 Paul.  The width is in the skin, so we need to apply manually. 
		let tblMain = React.createElement('div', { className: sPanelClass, key: baseId + '_tblMain', style: {width: '100%'} }, tblMainChildren);
		arrPanels.push(tblMain);
		if ( layout == null )
		{
			return arrPanels;
		}
		let _onChange = (callback ? callback : onChange);
		try
		{
			let tblBodyChildren: Array<JSX.Element> = [];
			let tbody = React.createElement('div', { className: (sPanelClass == 'tabForm' ? 'tabEditView' : null), key: 'tbody', style: {display: 'flex', flexDirection: 'row', flexWrap: 'wrap', width: '100%'} }, tblBodyChildren);
			tblMainChildren.push(tbody);

			let trChildren: Array<JSX.Element>;
			let tr                      : any     = null;
			let nColIndex               : number  = 0;
			let tdLabelChildren         : any[]   = [];
			let tdLabelProps            : any     = {};
			let tdLabel                 : any     = null;
			let tdFieldChildren         : any[]   = [];
			let tdFieldProps            : any     = { style: {} };
			let tdField                 : any     = null;
			let bEnableTeamManagement   : boolean = Crm_Config.enable_team_management();
			let bRequireTeamManagement  : boolean = Crm_Config.require_team_management();
			let bEnableDynamicTeams     : boolean = Crm_Config.enable_dynamic_teams();
			// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			let bEnableDynamicAssignment: boolean = Crm_Config.enable_dynamic_assignment();
			let bRequireUserAssignment  : boolean = Crm_Config.require_user_assignment();
			// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 

			// 08/31/2012 Paul.  Add support for speech. 
			let bEnableSpeech           : boolean = Crm_Config.enable_speech();
			let sUSER_AGENT             : string  = navigator.userAgent;
			if ( sUSER_AGENT == 'Chrome' || sUSER_AGENT.indexOf('Android') > 0 || sUSER_AGENT.indexOf('iPad') > 0 || sUSER_AGENT.indexOf('iPhone') > 0 )
			{
				bEnableSpeech = Crm_Config.enable_speech();
			}
			// 12/06/2014 Paul.  Use new mobile flag. 
			let bIsMobile = isMobileDevice();
			if ( isMobileLandscape() )
			{
				bIsMobile = false;
			}
			let sTheme        : string = Security.USER_THEME();
			// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
			let oNumberFormat : any    = Security.NumberFormatInfo();
			// 05/30/2018 Paul.  Make sure to use let so that callbacks get the proper scope variable. 
			// https://www.pluralsight.com/guides/javascript-callbacks-variable-scope-problem
			// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
			let bEnableTaxLineItems: boolean = Crm_Config.ToBoolean('Orders.TaxLineItems');
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			let themeURL   : string  = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
			let legacyIcons: boolean = Crm_Config.ToBoolean('enable_legacy_icons');

			// 11/12/2019 Paul.  Declare DATA_COLUMNS outside loop so that we can calculate the padding. 
			let DATA_COLUMNS        : number = 2;
			let sFlexLabelFieldWidth: string = '100%';
			for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay = layout[nLayoutIndex];
				//alert(dumpObj(lay, 'EditViewUI.LoadView layout'));
				let EDIT_NAME                  = lay.EDIT_NAME;
				let FIELD_TYPE                 = lay.FIELD_TYPE;
				let DATA_LABEL                 = lay.DATA_LABEL;
				let DATA_FIELD                 = lay.DATA_FIELD;
				let DATA_FORMAT                = lay.DATA_FORMAT;
				let DISPLAY_FIELD              = lay.DISPLAY_FIELD;
				//let CACHE_NAME                 = lay.CACHE_NAME;
				//let LIST_NAME                  = lay.LIST_NAME;
				// 12/05/2012 Paul.  UI_REQUIRED is not used on SQLite, so use the DATA_REQUIRED value. 
				let UI_REQUIRED                = Sql.ToBoolean(lay.UI_REQUIRED) || Sql.ToBoolean(lay.DATA_REQUIRED);
				let ONCLICK_SCRIPT             = lay.ONCLICK_SCRIPT;
				//let FORMAT_SCRIPT              = lay.FORMAT_SCRIPT;
				//let FORMAT_TAB_INDEX           = Sql.ToInteger(lay.FORMAT_TAB_INDEX);
				//let FORMAT_MAX_LENGTH          = Sql.ToInteger(lay.FORMAT_MAX_LENGTH);
				//let FORMAT_SIZE                = Sql.ToInteger(lay.FORMAT_SIZE);
				//let FORMAT_ROWS                = Sql.ToInteger(lay.FORMAT_ROWS);
				//let FORMAT_COLUMNS             = Sql.ToInteger(lay.FORMAT_COLUMNS);
				let COLSPAN                    = Sql.ToInteger(lay.COLSPAN);
				//let ROWSPAN                    = Sql.ToInteger(lay.ROWSPAN);
				let LABEL_WIDTH                = lay.LABEL_WIDTH;
				let FIELD_WIDTH                = lay.FIELD_WIDTH;
				//let VIEW_NAME                  = lay.VIEW_NAME;
				//let FIELD_VALIDATOR_ID         = lay.FIELD_VALIDATOR_ID;
				//let FIELD_VALIDATOR_MESSAGE    = lay.FIELD_VALIDATOR_MESSAGE;
				//let UI_VALIDATOR               = lay.UI_VALIDATOR;
				//let VALIDATION_TYPE            = lay.VALIDATION_TYPE;
				//let REGULAR_EXPRESSION         = lay.REGULAR_EXPRESSION;
				//let DATA_TYPE                  = lay.DATA_TYPE;
				//let MININUM_VALUE              = lay.MININUM_VALUE;
				//let MAXIMUM_VALUE              = lay.MAXIMUM_VALUE;
				//let COMPARE_OPERATOR           = lay.COMPARE_OPERATOR;
				let MODULE_TYPE                = lay.MODULE_TYPE;
				//let FIELD_VALIDATOR_NAME       = lay.FIELD_VALIDATOR_NAME;
				let TOOL_TIP                   = lay.TOOL_TIP;
				//let VALID_RELATED              = false;
				//let RELATED_SOURCE_MODULE_NAME = lay.RELATED_SOURCE_MODULE_NAME;
				//let RELATED_SOURCE_VIEW_NAME   = lay.RELATED_SOURCE_VIEW_NAME;
				//let RELATED_SOURCE_ID_FIELD    = lay.RELATED_SOURCE_ID_FIELD;
				//let RELATED_SOURCE_NAME_FIELD  = lay.RELATED_SOURCE_NAME_FIELD;
				//let RELATED_VIEW_NAME          = lay.RELATED_VIEW_NAME;
				//let RELATED_ID_FIELD           = lay.RELATED_ID_FIELD;
				//let RELATED_NAME_FIELD         = lay.RELATED_NAME_FIELD;
				//let RELATED_JOIN_FIELD         = lay.RELATED_JOIN_FIELD;
				//let PARENT_FIELD               = lay.PARENT_FIELD;
				// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
				let bIsHidden: boolean            = lay.hidden;
				
				DATA_COLUMNS = Sql.ToInteger(lay.DATA_COLUMNS);
				if ( DATA_COLUMNS == 0 )
					DATA_COLUMNS = 2;
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				// 04/19/2019 Paul.  Calculate flex width. 
				sFlexLabelFieldWidth = Math.floor(100 / DATA_COLUMNS) + '%';
				// 04/19/2019 Paul.  Convert to single sell width by multiplying by columns. 
				let nLABEL_WIDTH = parseInt(LABEL_WIDTH.replace('%', ''));
				let nFIELD_WIDTH = parseInt(FIELD_WIDTH.replace('%', ''));
				// 08/25/2019 Paul.  With COLSPAN 3, we need to assume that it is the only field on the row. 
				if ( COLSPAN == 3 )
				{
					LABEL_WIDTH = nLABEL_WIDTH + '%';
					FIELD_WIDTH = (nLABEL_WIDTH * (DATA_COLUMNS - 1) + nFIELD_WIDTH * DATA_COLUMNS) + '%';
				}
				else
				{
					LABEL_WIDTH = (nLABEL_WIDTH * DATA_COLUMNS) + '%';
					FIELD_WIDTH = (nFIELD_WIDTH * DATA_COLUMNS) + '%';
				}

				let sGridLabel = 'dataLabel';
				let sGridInput = 'dataField';
				let bIsReadable  : boolean = true;
				let bIsWriteable : boolean = true;
				if ( SplendidCache.bEnableACLFieldSecurity )
				{
					let gASSIGNED_USER_ID: string = null;
					if ( row != null )
					{
						gASSIGNED_USER_ID = Sql.ToGuid(row.ASSIGNED_USER_ID);
					}
					let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
					// 02/16/2011 Paul.  We should allow a Read-Only field to be searchable, so always allow writing if the name contains Search. 
					bIsWriteable = acl.IsWriteable() || EDIT_NAME.indexOf(".Search") >= 0;
					if ( !bIsWriteable )
					{
						// 11/11/2020 Paul.  No longer need this warning. 
						//console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView NOT WRITEABLE', MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					}
				}
				if ( !bIsReadable )
				{
					FIELD_TYPE = 'Blank';
				}
				
				if ( ( DATA_FIELD == 'TEAM_ID' || DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( !bEnableTeamManagement )
					{
						FIELD_TYPE = 'Blank';
						// 10/24/2012 Paul.  Clear the label to prevent a term lookup. 
						DATA_LABEL  = null;
						DATA_FIELD  = null;
						UI_REQUIRED = false;
					}
					else
					{
						if ( bEnableDynamicTeams )
						{
							// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
							// 10/20/2017 Paul.  Don't convert MyPipelineBySalesStage. 
							if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
							{
								DATA_LABEL     = '.LBL_TEAM_SET_NAME';
								DATA_FIELD     = 'TEAM_SET_NAME';
								FIELD_TYPE     = 'TeamSelect';
								ONCLICK_SCRIPT = '';
								// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
								lay.DATA_LABEL     = '.LBL_TEAM_SET_NAME';
								lay.DATA_FIELD     = 'TEAM_SET_NAME';
								lay.FIELD_TYPE     = 'TeamSelect';
								lay.ONCLICK_SCRIPT = '';
							}
						}
						else
						{
							// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
							if ( FIELD_TYPE == 'TeamSelect' )
							{
								DATA_LABEL     = 'Teams.LBL_TEAM';
								DATA_FIELD     = 'TEAM_ID';
								DISPLAY_FIELD  = 'TEAM_NAME';
								FIELD_TYPE     = 'ModulePopup';
								MODULE_TYPE    = 'Teams';
								ONCLICK_SCRIPT = '';
								// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
								lay.DATA_LABEL     = 'Teams.LBL_TEAM';
								lay.DATA_FIELD     = 'TEAM_ID';
								lay.DISPLAY_FIELD  = 'TEAM_NAME';
								lay.FIELD_TYPE     = 'ModulePopup';
								lay.MODULE_TYPE    = 'Teams';
								lay.ONCLICK_SCRIPT = '';
							}
						}
						// 11/25/2006 Paul.  Override the required flag with the system value. 
						// 01/01/2008 Paul.  If Team Management is not required, then let the admin decide. 
						// 97/06/2017 Paul.  Don't show required flag in search or popup. 
						// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
						if ( bRequireTeamManagement && EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.MassUpdate') < 0 && EDIT_NAME.indexOf('.Popup') < 0 )
						{
							UI_REQUIRED = true;
						}
					}
				}
				// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( (DATA_FIELD == 'ASSIGNED_USER_ID' || DATA_FIELD == 'ASSIGNED_SET_NAME') )
				{
					// 01/06/2018 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					if ( bEnableDynamicAssignment && DATA_FORMAT != "1" )
					{
						if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
						{
							DATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
							DATA_FIELD     = 'ASSIGNED_SET_NAME'     ;
							FIELD_TYPE     = 'UserSelect'            ;
							ONCLICK_SCRIPT = ''                      ;
							// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
							lay.DATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
							lay.DATA_FIELD     = 'ASSIGNED_SET_NAME'     ;
							lay.FIELD_TYPE     = 'UserSelect'            ;
							lay.ONCLICK_SCRIPT = ''                      ;
						}
					}
					else
					{
						if ( FIELD_TYPE == 'UserSelect' )
						{
							DATA_LABEL     = '.LBL_ASSIGNED_TO';
							DATA_FIELD     = 'ASSIGNED_USER_ID';
							DISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
							FIELD_TYPE     = 'ModulePopup'     ;
							MODULE_TYPE    = 'Users'           ;
							ONCLICK_SCRIPT = ''                ;
							// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
							lay.DATA_LABEL     = '.LBL_ASSIGNED_TO';
							lay.DATA_FIELD     = 'ASSIGNED_USER_ID';
							lay.DISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
							lay.FIELD_TYPE     = 'ModulePopup'     ;
							lay.MODULE_TYPE    = 'Users'           ;
							lay.ONCLICK_SCRIPT = ''                ;
						}
					}
					if ( bRequireTeamManagement )
					{
						UI_REQUIRED = true;
					}
				}
				// 04/04/2010 Paul.  Hide the Exchange Folder field if disabled for this module or user. 
				else if ( DATA_FIELD == 'EXCHANGE_FOLDER' )
				{
					// 01/09/2021 Paul.  We need to hide the EXCHANGE_FOLDER field if the user does not have Exchange enabled. 
					if ( !Crm_Modules.ExchangeFolders(MODULE_NAME) || !Security.HasExchangeAlias() )
					{
						FIELD_TYPE = 'Blank';
						DATA_LABEL = '';
					}
				}
				// 12/13/2013 Paul.  Allow each product to have a default tax rate. 
				else if ( DATA_FIELD == 'TAX_CLASS' )
				{
					if ( bEnableTaxLineItems )
					{
						// 07/22/2019 Paul.  Also correct these values in the ListBox component as changing the cache here will make no difference. 
						DATA_LABEL = "ProductTemplates.LBL_TAXRATE_ID";
						DATA_FIELD = "TAXRATE_ID";
						//CACHE_NAME = "TaxRates";
					}
				}
				
				if ( FIELD_TYPE == 'Blank' )
				{
					UI_REQUIRED = false;
				}
				// 09/02/2012 Paul.  A separator will create a new table. We need to match the outer and inner layout. 
				if ( FIELD_TYPE == 'Separator' )
				{
					// 11/12/2019 Paul.  Add remaining cells. 
					for ( let i = 0; i < tblBodyChildren.length % DATA_COLUMNS; i++ )
					{
						trChildren = [];
						if ( SplendidDynamic.StackedLayout(sTheme) )
							tr = React.createElement('div', { className: 'tabStackedEditViewDF', style: { flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '1px 5px' } }, trChildren);
						else
							tr = React.createElement('div', { style: { display: 'flex', flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '1px 5px' } }, trChildren);
						tblBodyChildren.push(tr);
					}
					
					// 10/27/2020 Paul.  Need to force a break using flex.  Requires that the container be allowed to wrap. 
					// https://tobiasahlin.com/blog/flexbox-break-to-new-row/
					let divSeparator = React.createElement('div', { style: {flexBasis: '100%', height: 0} });
					arrPanels.push(divSeparator);
					
					tblMainChildren = [];
					tblMain = React.createElement('div', { className: sPanelClass, key: baseId + '_tblMain', style: {width: '100%'} }, tblMainChildren);
					arrPanels.push(tblMain);

					tblBodyChildren = [];
					tbody = React.createElement('div', { className: 'tabEditView', key: 'tbody' + nLayoutIndex, style: {display: 'flex', flexDirection: 'row', flexWrap: 'wrap', width: '100%'} }, tblBodyChildren);
					tblMainChildren.push(tbody);
					nColIndex = 0;
					tr = null;
					continue;
				}
				// 09/03/2012 Paul.  We are going to ignore address buttons. 
				else if ( FIELD_TYPE == 'AddressButtons' )
				{
					continue;
				}
				// 11/17/2007 Paul.  On a mobile device, each new field is on a new row. 
				// 12/02/2005 Paul.  COLSPAN == -1 means that a new column should not be created. 
				// 12/06/2014 Paul.  Use new mobile flag. 
				// 02/26/2016 Paul.  We do not want the 1 column layout for the search panel on an OfficeAddin. 
				//if ( (COLSPAN >= 0 && nColIndex == 0) || tr == null || (bIsMobile && EDIT_NAME.indexOf('.SearchSubpanel.OfficeAddin') < 0) )
				// 04/19/2019 Paul.  With flex, we will create a new row for each field. 
				if ( COLSPAN >=0 || tr == null )
				{
					// 11/25/2005 Paul.  Don't pre-create a row as we don't want a blank
					// row at the bottom.  Add rows just before they are needed. 
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					//if ( !SplendidDynamic.BootstrapLayout() )
					//{
					//	tr = React.createElement('tr');
					//	tbody.appendChild(tr);
					//}
					//else
					{
						trChildren = [];
						// 08/25/2019 Paul.  This is the correct place to handle colspan. 
						if ( COLSPAN == 3 )
						{
							sFlexLabelFieldWidth  = '100%';
						}
						if ( SplendidDynamic.StackedLayout(sTheme) )
							tr = React.createElement('div', { className: 'tabStackedEditViewDF', key: FIELD_TYPE + 'row' + nLayoutIndex, style: { flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '1px 5px' } }, trChildren);
						else
							tr = React.createElement('div', { key: FIELD_TYPE + 'row' + nLayoutIndex, style: { display: 'flex', flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '1px 5px' } }, trChildren);
						tblBodyChildren.push(tr);
					}
				}
				// 06/20/2009 Paul.  The label and the field will be on separate rows for a NewRecord form. 
				let trLabelChildren = trChildren;
				let trLabel = tr;
				let trFieldChildren = trChildren;
				let trField = tr;
				if ( COLSPAN >= 0 || tdLabel == null || tdField == null )
				{
					// 06/21/2015 Paul.  The Seven theme has labels stacked above values. 
					if ( SplendidDynamic.StackedLayout(sTheme) )
					{
						tdLabelChildren = [];
						tdLabelProps.id  = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
						tdLabelProps.key = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
						tdLabelProps.className = 'tabStackedEditViewDL';
						// 03/19/2020 Paul.  Center instead of baseline or top. 
						tdLabelProps.style = { width: '100%', display: 'flex', alignItems: 'center'};
						
						// 08/25/2019 Paul.  For ChangeButton with PARENT_TYPE, we need to have the control handle it as there is an interaction between label and field. 
						// 08/25/2019 Paul.  For ChangeButton with PARENT_TYPE, we need to have the control handle it as there is an interaction between label and field. 
						if ( !(FIELD_TYPE == 'ChangeButton' && DATA_LABEL == 'PARENT_TYPE') )
						{
							tdLabel = React.createElement('span', tdLabelProps, tdLabelChildren);
							trLabelChildren.push(tdLabel);
						}

						tdFieldChildren = [];
						tdFieldProps.key = FIELD_TYPE + 'tdfield' + nLayoutIndex;
						tdFieldProps.id  = FIELD_TYPE + 'tdfield' + nLayoutIndex;
						// 03/19/2020 Paul.  Center instead of top. 
						tdFieldProps.style = { width: '100%', display: 'flex', flexDirection: 'row', flexWrap: 'wrap', alignItems: 'center'};
						tdField = React.createElement('div', tdFieldProps, tdFieldChildren);
						trLabelChildren.push(tdField);
					}
					else
					{
						tdLabelChildren = [];
						tdLabelProps.id  = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
						tdLabelProps.key = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
						tdLabelProps.className = sGridLabel;
						// 11/12/2019 Paul.  Default top align looks terrible. 
						// 12/17/2019 Paul.  Baseline looks better than center, especially for multi-line controls such as Teams and Tags. 
						// 03/19/2020 Paul.  Center instead of baseline or top. 
						tdLabelProps.style = { width: LABEL_WIDTH, display: 'flex', alignItems: 'center'};
							
						// 08/25/2019 Paul.  For ChangeButton with PARENT_TYPE, we need to have the control handle it as there is an interaction between label and field. 
						if ( !(FIELD_TYPE == 'ChangeButton' && DATA_LABEL == 'PARENT_TYPE') )
						{
							tdLabel = React.createElement('span', tdLabelProps, tdLabelChildren);
							trLabelChildren.push(tdLabel);
						}
						else
						{
							// 08/25/2019 Paul.  And give 100% of the cell to the control to manage. 
							FIELD_WIDTH = '100%';
						}

						tdFieldChildren = [];
						tdFieldProps.key = FIELD_TYPE + 'tdfield' + nLayoutIndex;
						tdFieldProps.id  = FIELD_TYPE + 'tdfield' + nLayoutIndex;
						tdFieldProps.className = sGridInput;
						// 03/19/2020 Paul.  Center instead of top. 
						tdFieldProps.style = { width: FIELD_WIDTH, display: 'flex', flexDirection: 'row', flexWrap: 'wrap', alignItems: 'center'};
						// 04/18/2019 Paul.  Try to use flex to put all related fields on the same line. 
						//tdFieldProps.style = {display: 'flex'};
						tdField = React.createElement('div', tdFieldProps, tdFieldChildren);
						trLabelChildren.push(tdField);
					}
					// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
					if ( !bIsHidden )
					{
						// 04/28/2019 Paul.  Header text goes in the field column, leaving the label column blank. 
						if ( DATA_LABEL != null && FIELD_TYPE != 'Header' )
						{
							if ( DATA_LABEL.indexOf('.') >= 0 )
							{
								let txt = L10n.Term(DATA_LABEL);
								// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
								// 01/29/2020 Paul.  Allow the label to contain HTML. 
								// 03/19/2020 Paul.  Make sure that tag exists, otherwise labels will not be aligned right. 
								if ( txt.indexOf('</span>') >= 0 )
								{
									let html = React.createElement('span', { dangerouslySetInnerHTML: { __html: txt } });
									tdLabelChildren.push(html);
								}
								else
								{
									txt = Sql.ReplaceEntities(txt);
									tdLabelChildren.push(txt);
								}
							}
							else if ( !Sql.IsEmptyString(DATA_LABEL) && row != null )
							{
								// 06/21/2015 Paul.  Label can contain raw text. 
								let sLabel = row[DATA_LABEL];
								if ( sLabel === undefined )
								{
									sLabel = Sql.ToString(DATA_LABEL);
								}
								else
								{
									sLabel = Sql.ToString(sLabel) + ':';
								}
								// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
								let txt = Sql.ReplaceEntities(sLabel);
								tdLabelChildren.push(txt);
							}
							// 07/24/2019 Paul.  Tool tip as simple hover. 
							if ( !Sql.IsEmptyString(TOOL_TIP) )
							{
								let sTOOL_TIP = TOOL_TIP;
								if ( TOOL_TIP.indexOf('.') >= 0 )
								{
									sTOOL_TIP = L10n.Term(TOOL_TIP);
								}
								let text = React.createElement('span', {className: 'reactTooltipText'}, sTOOL_TIP   );
								// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
								let icon = null;
								if ( legacyIcons )
									icon = React.createElement('img', {src: (themeURL + 'tooltip_inline.gif')}, null        );
								else
									icon = React.createElement(FontAwesomeIcon, {icon: 'question' }, null        );
								let tip  = React.createElement('span', {className: 'reactTooltip'    }, [icon, text]);
								tdLabelChildren.push(tip);
							}
						}
						// 08/06/2020 Paul.  Hidden fields cannot be required. 
						if ( UI_REQUIRED && FIELD_TYPE != 'Hidden' )
						{
							let lblRequired = React.createElement('span', { className: 'required', key: FIELD_TYPE + 'lblrequired' + nLayoutIndex }, L10n.Term('.LBL_REQUIRED_SYMBOL'));
							tdLabelChildren.push(lblRequired);
						}
					}
				}
				let key = baseId + '_FieldIndex_' + lay.FIELD_INDEX;
				if ( !Sql.IsEmptyString(DATA_FIELD) )
				{
					if ( refMap[DATA_FIELD] == null )
					{
						key = DATA_FIELD;
					}
					else
					{
						console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView ' + EDIT_NAME + '.' + DATA_FIELD + ' already exists in refMap.');
					}
				}
				let ref = React.createRef<EditComponent<any, any>>();
				refMap[key] = ref;
				//alert(DATA_FIELD);
				try
				{

					if ( FIELD_TYPE == 'Blank' )
					{
						tdLabelChildren.push('\u00a0');
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(Blank, txtProps);
						tdFieldChildren.push(txt);
					}
					// 09/03/2012 Paul.  A header is similar to a label, but without the data field. 
					else if ( FIELD_TYPE == 'Header' )
					{
						tdLabelChildren.pop();
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(Header, txtProps);
						tdLabelProps.style.width = (nLABEL_WIDTH + nFIELD_WIDTH * 2) + '%';
						tdLabelChildren.push(txt);
						// 08/08/2019 Paul.  We need to reset the table so that the next field will start on a new line. 
						// 10/31/2019 Paul.  A header does not force a new line.  This is so a header can be at the top of each column, like Billing and Shipping for Quotes. 
					}
					else if ( FIELD_TYPE == 'Hidden' )
					{
						// 02/28/2008 Paul.  When the hidden field is the first in the row, we end up with a blank row. 
						// Just ignore for now as IE does not have a problem with the blank row. 
						COLSPAN = -1;
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(Hidden, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'ModuleAutoComplete' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(ModuleAutoComplete, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'ModulePopup' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden, isSearchView };
						// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
						if ( DATA_FIELD == 'PRODUCT_TEMPLATE_ID' )
						{
							txtProps.allowCustomName = true;
						}
						let txt = React.createElement(ModulePopup, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'ChangeButton' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(ChangeButton, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'TeamSelect' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(TeamSelect, txtProps);
						tdFieldChildren.push(txt);
					}
					// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( FIELD_TYPE == 'UserSelect' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(UserSelect, txtProps);
						tdFieldChildren.push(txt);
					}
					// 05/14/2016 Paul.  Add Tags module. 
					else if ( FIELD_TYPE == 'TagSelect' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(TagSelect, txtProps);
						tdFieldChildren.push(txt);
					}
					// 06/07/2017 Paul.  Add NAICSCodes module. 
					else if ( FIELD_TYPE == 'NAICSCodeSelect' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(NAICSCodeSelect, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'TextBox' )
					{
						// 11/02/2019 Paul.  layout changes are not detected, so we need to send the hidden field as a separate property. 
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						// 09/27/2020 Paul.  We need to be able to disable the default grow on TextBox. 
						if ( nLayoutIndex+1 < layout.length )
						{
							let layNext = layout[nLayoutIndex + 1];
							if ( Sql.ToInteger(layNext.COLSPAN) == -1 )
							{
								txtProps.bDisableFlexGrow = true;
							}
						}
						let txt = React.createElement(TextBox, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'HtmlEditor' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(HtmlEditor, txtProps);
						tdFieldChildren.push(txt);
					}
					// 04/14/2016 Paul.  Add ZipCode lookup. 
					else if ( FIELD_TYPE == 'ZipCodePopup' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(ZipCodePopup, txtProps);
						tdFieldChildren.push(txt);
					}
					// 05/24/2017 Paul.  Need support for DateRange for new Dashboard. 
					else if ( FIELD_TYPE == 'DateRange' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(DateRange, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'DatePicker' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(DatePicker, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'DateTimeEdit' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(DateTimeEdit, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'DateTimeNewRecord' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(DateTimeNewRecord, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'DateTimePicker' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(DateTimePicker, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'TimePicker' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let txt = React.createElement(TimePicker, txtProps);
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'ListBox' )
					{
						let lstProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lst = React.createElement(ListBox, lstProps);
						tdFieldChildren.push(lst);
					}
					// 08/01/2013 Paul.  Add support for CheckBoxList. 
					else if ( FIELD_TYPE == 'CheckBoxList' )
					{
						let lstProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lst = React.createElement(CheckBoxList, lstProps);
						tdFieldChildren.push(lst);
					}
					// 08/01/2013 Paul.  Add support for Radio. 
					else if ( FIELD_TYPE == 'Radio' )
					{
						let chkProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let chk = React.createElement(Radio, chkProps);
						tdFieldChildren.push(chk);
					}
					else if ( FIELD_TYPE == 'CheckBox' )
					{
						let chkProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let chk = React.createElement(CheckBox, chkProps);
						tdFieldChildren.push(chk);
					}
					else if ( FIELD_TYPE == 'Label' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lbl = React.createElement(Label, lblProps);
						tdFieldChildren.push(lbl);
					}
					// 05/27/2016 Paul.  Add support for File type. 
					else if ( FIELD_TYPE == 'File' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lbl = React.createElement(SplendidFile, lblProps);
						tdFieldChildren.push(lbl);
					}
					// 11/04/2019 Paul.  Add support for Button type. 
					else if ( FIELD_TYPE == 'Button' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden, Page_Command };
						let lbl = React.createElement( SplendidButton, lblProps );
						tdFieldChildren.push( lbl );
					}
					// 07/01/2020 Paul.  Add support for Image type. 
					else if ( FIELD_TYPE == 'Image' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lbl = React.createElement(SplendidImage, lblProps);
						tdFieldChildren.push(lbl);
					}
					// 07/02/2020 Paul.  Add support for Picture type. 
					else if ( FIELD_TYPE == 'Picture' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lbl = React.createElement(Picture, lblProps);
						tdFieldChildren.push(lbl);
					}
					// 07/04/2020 Paul.  Add support for Password type. 
					else if ( FIELD_TYPE == 'Password' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lbl = React.createElement(Password, lblProps);
						tdFieldChildren.push(lbl);
					}
					// 03/28/2021 Paul.  Add support for CRON type. 
					else if ( FIELD_TYPE == 'CRON' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
						let lbl = React.createElement(CRON, lblProps);
						tdFieldChildren.push(lbl);
					}
					else
					{
						//08/31/2012 Paul.  Add debugging code. 
						console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView.AppendEditViewFields() Unknown field type: ' + FIELD_TYPE);
					}
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendEditViewFields ' + FIELD_TYPE + ' ' + DATA_FIELD, error);
				}
				// 12/02/2007 Paul.  Each view can now have its own number of data columns. 
				// This was needed so that search forms can have 4 data columns. The default is 2 columns. 
				if ( COLSPAN > 0 )
				{
					nColIndex += COLSPAN;
				}
				else if ( COLSPAN == 0 )
				{
					nColIndex++;
				}
				if ( nColIndex >= DATA_COLUMNS )
				{
					nColIndex = 0;
				}
			}
			// 11/12/2019 Paul.  Add remaining cells. 
			for ( let i = 0; i < tblBodyChildren.length % DATA_COLUMNS; i++ )
			{
				trChildren = [];
				if ( SplendidDynamic.StackedLayout(sTheme) )
					tr = React.createElement('div', { className: 'tabStackedEditViewDF', style: { flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '1px 5px' } }, trChildren);
				else
					tr = React.createElement('div', { style: { display: 'flex', flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '1px 5px' } }, trChildren);
				tblBodyChildren.push(tr);
			}
			// 11/12/2019 Paul.  I don't think we will use the same style of JavaScript custom code. 
			/*
			// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
			for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay = layout[nLayoutIndex];
				let FORM_SCRIPT = lay.SCRIPT;
				if ( !Sql.IsEmptyString(FORM_SCRIPT) )
				{
					// 11/24/2017 Paul.  Need to replace all occurrences. 
					FORM_SCRIPT = FORM_SCRIPT.replace(/SPLENDID_EDITVIEW_LAYOUT_ID/g, 'ctlEditView');
					// 01/18/2018 Paul.  If wrapped, then treat FORM_SCRIPT as a function. 
					FORM_SCRIPT = Trim(FORM_SCRIPT);
					if ( StartsWith(FORM_SCRIPT, '(') && EndsWith(FORM_SCRIPT, ')') )
					{
						//console.log((new Date()).toISOString() + ' ' + 'Evaluating form script as function.');
						let fnFORM_SCRIPT = eval(FORM_SCRIPT);
						if ( typeof (fnFORM_SCRIPT) == 'function' )
						{
							// 01/18/2018 Paul.  Execute the script, but if an object is returned, then it just created a function, not execute it. 
							let fnFORM_SCRIPT_Init = fnFORM_SCRIPT();
							if (fnFORM_SCRIPT_Init !== undefined && typeof (fnFORM_SCRIPT_Init.Initialize) == 'function')
							{
								//console.log((new Date()).toISOString() + ' ' + 'Executing form script Initialize function.');
								fnFORM_SCRIPT_Init.Initialize();
							}
							else
							{
								//console.log((new Date()).toISOString() + ' ' + 'Executed form script as function.');
								fnFORM_SCRIPT_Init = null;
							}
						}
						else
						{
							//console.log((new Date()).toISOString() + ' ' + 'Form script not a function and will not be executed.');
						}
					}
					else
					{
						//console.log((new Date()).toISOString() + ' ' + 'Executing form script as raw script.');
						eval(FORM_SCRIPT);
					}
				}
				break;
			}
			*/
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendEditViewFields', error);
		}
		return arrPanels;
	}

	static BuildDataRow(row: any, refMap: Record<string, React.RefObject<EditComponent<any, any>>>): number
	{
		let nInvalidFields: number = 0;
		Object.keys(refMap).map((key) =>
		{
			let ref = refMap[key];
			if ( !ref.current.validate() )
			{
				nInvalidFields++;
			}
			else
			{
				let data = ref.current.data;
				// 07/05/2019 Paul.  Data may be an array of key/value pairs.  This is true of TeamSelect and UserSelect. 
				if ( data )
				{
					if ( Array.isArray(data) )
					{
						for ( let i = 0; i < data.length; i++  )
						{
							if ( data[i].key )
							{
								row[data[i].key] = data[i].value;
							}
						}
					}
					else if ( data.key )
					{
						row[data.key] = data.value;
						if ( data.files && Array.isArray(data.files) )
						{
							if ( row.Files === undefined )
							{
								row.Files = new Array();
							}
							for ( let i = 0; i < data.files.length; i++ )
							{
								row.Files.push(data.files[i]);
							}
						}
					}
				}
			}
		});
		return nInvalidFields;
	}

	static Validate(refMap: Record<string, React.RefObject<EditComponent<any, any>>>): number
	{
		let nInvalidFields = 0;
		Object.keys(refMap).map((key) =>
		{
			let ref = refMap[key];
			if ( !ref.current.validate() )
			{
				nInvalidFields++;
			}
		});
		return nInvalidFields;
	}

	static Clear(refMap: Record<string, React.RefObject<EditComponent<any, any>>>): void
	{
		Object.keys(refMap).map((key) =>
		{
			let ref = refMap[key];
			ref.current.clear();
		});
	}

	static SetRefValue(refMap: Record<string, React.RefObject<EditComponent<any, any>>>, DATA_FIELD: string, DATA_VALUE: any)
	{
		Object.keys(refMap).map((key) =>
		{
			let ref = refMap[key];
			if ( key == DATA_FIELD )
			{
				ref.current.updateDependancy(null, DATA_VALUE, 'value', null);
			}
		});
	}

	static GetRefValue(refMap: Record<string, React.RefObject<EditComponent<any, any>>>, DATA_FIELD: string)
	{
		let value = null;
		Object.keys(refMap).map((key) =>
		{
			let ref = refMap[key];
			if ( key == DATA_FIELD )
			{
				let data: any = ref.current.data;
				if ( data != null )
				{
					value = data.value;
				}
			}
		});
		return value;
	}
}

