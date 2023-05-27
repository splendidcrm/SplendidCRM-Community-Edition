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
import { FontAwesomeIcon }                   from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
import { DetailComponent }                   from '../types/DetailComponent'      ;
import ACL_FIELD_ACCESS                      from '../types/ACL_FIELD_ACCESS'     ;
// 3. Scripts. 
import Security                              from '../scripts/Security'           ;
import Sql                                   from '../scripts/Sql'                ;
import L10n                                  from '../scripts/L10n'               ;
import Credentials                           from '../scripts/Credentials'        ;
import SplendidCache                         from '../scripts/SplendidCache'      ;
import SplendidDynamic                       from '../scripts/SplendidDynamic'    ;
import { Crm_Config, Crm_Modules }           from '../scripts/Crm'                ;
import { DetailView_GetTabList, DetailView_ActivateTab } from '../scripts/DetailView';
import { isMobileDevice, isMobileLandscape, screenWidth, screenHeight } from '../scripts/utility';
// 4. Components and Views. 
import Blank                                 from '../DetailComponents/Blank'     ;
import SplendidButton                        from '../DetailComponents/Button'    ;
import CheckBox                              from '../DetailComponents/CheckBox'  ;
import SplendidFile                          from '../DetailComponents/File'      ;
import Header                                from '../DetailComponents/Header'    ;
import HyperLink                             from '../DetailComponents/HyperLink' ;
import IFrame                                from '../DetailComponents/IFrame'    ;
import Image                                 from '../DetailComponents/Image'     ;
import JavaScript                            from '../DetailComponents/JavaScript';
import Line                                  from '../DetailComponents/Line'      ;
import ModuleLink                            from '../DetailComponents/ModuleLink';
import SplendidString                        from '../DetailComponents/String'    ;
import Tags                                  from '../DetailComponents/Tags'      ;
import TextBox                               from '../DetailComponents/TextBox'   ;

export default class SplendidDynamic_DetailView
{
	// 04/18/2021 Paul.  Go back to using tables instead of flex due to the field overlap. 
	static AppendDetailViewFields(row: any, layout: any, refMap: any, sPanelClass: string, fieldDidMount: Function, Page_Command: Function): JSX.Element
	{
		return SplendidDynamic_DetailView.AppendDetailViewFields_Desktop(row, layout, refMap, sPanelClass, fieldDidMount, Page_Command);
		//return SplendidDynamic_DetailView.AppendDetailViewFields_Mobile(row, layout, refMap, sPanelClass, fieldDidMount, Page_Command);
	}

	// 04/18/2021 Paul.  Create a separate desktop render that uses tables instead of div to prevent field overlap in UI. 
	static AppendDetailViewFields_Desktop(row: any, layout: any, refMap: any, sPanelClass: string, fieldDidMount: Function, Page_Command: Function): JSX.Element
	{
		let fragmentChildren: any[] = [];
		let fragment = React.createElement(React.Fragment, {}, fragmentChildren);
		// 03/19/2020 Paul.  We need to dynamically create a unique baseId as the Leads.EditView.Inline and Contacts.EditView.Inline are both on the Accounts.DetailView page, leading to a naming confict. 
		let baseId: string = 'ctlDetailView';
		if ( layout != null && layout.length > 0 )
		{
			let DETAIL_NAME   : string   = Sql.ToString(layout[0].DETAIL_NAME );
			baseId = 'ctlDetailView_' + DETAIL_NAME.replace(/\./g, '_');
		}

		// 12/06/2014 Paul.  Use new mobile flag. 
		let sTheme        : string  = Security.USER_THEME();
		let bIsMobile     : boolean = isMobileDevice();
		let bStackedTheme : boolean = SplendidDynamic.StackedLayout(sTheme) && sPanelClass != 'tabPreviewView';
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
			let arrTabs: any[] = DetailView_GetTabList(layout);
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
					DetailView_ActivateTab(layout, arrTabs[0].nLayoutIndex);
				}
				bTabsEnabled = true;
			}
		}
		//console.log('AppendDetailViewFields_Desktop (' +  width + ', ' + height + ') ' + (bIsMobile ? 'mobile' : ''));
		// 04/15/2022 Paul.  We need a separate panel index instead of simply using count of main children. 
		let nPanelIndex: number = 0;
		let tblMainChildren: Array<JSX.Element> = [];
		let tblMainProps: any = { className: sPanelClass, id: baseId + '_tblMain' + nPanelIndex.toString(), key: baseId + '_tblMain' + nPanelIndex.toString(), style: {} };
		let tblMain = React.createElement('table', tblMainProps, tblMainChildren);
		fragmentChildren.push(tblMain);
		nPanelIndex++;
		if ( bStackedLayout )
		{
			tblMainProps.style.borderSpacing = '0px';
		}
		try
		{
			// 10/17/2012 Paul.  Exit if the Main does not exist.  This is a sign that the user has navigated elsewhere. 
			if (tblMain == null)
				return;
			let tblBodyChildren: Array<JSX.Element> = [];
			let tbody = React.createElement('tbody', { key: 'tbody' }, tblBodyChildren);
			tblMainChildren.push(tbody);
			let trChildren = [];
			let tr = null;
			let nColumn = 0;
			let bEnableTeamManagement   : boolean = Crm_Config.enable_team_management();
			let bEnableDynamicTeams     : boolean = Crm_Config.enable_dynamic_teams();
			let bEnableDynamicAssignment: boolean = Crm_Config.enable_dynamic_assignment();
			let bEnableTaxLineItems     : boolean = Crm_Config.ToBoolean('Orders.TaxLineItems');
			// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
			let oNumberFormat = Security.NumberFormatInfo();
			// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
			let ERASED_FIELDS: string[] = [];
			if ( Crm_Config.enable_data_privacy() )
			{
				if ( row['ERASED_FIELDS'] !== undefined )
				{
					ERASED_FIELDS = Sql.ToString(row['ERASED_FIELDS']).split(',');
				}
			}
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			let themeURL   : string  = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
			let legacyIcons: boolean = Crm_Config.ToBoolean('enable_legacy_icons');
	
			// 11/12/2019 Paul.  Declare DATA_COLUMNS outside loop so that we can calculate the padding. 
			let DATA_COLUMNS        : number = 2;
			let sFlexLabelFieldWidth: string = '100%';
			for (let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++)
			{
				let lay = layout[nLayoutIndex];
				let DETAIL_NAME : string = Sql.ToString (lay.DETAIL_NAME );
				let FIELD_INDEX : number = Sql.ToInteger(lay.FIELD_INDEX );
				let FIELD_TYPE  : string = Sql.ToString (lay.FIELD_TYPE  );
				let DATA_LABEL  : string = Sql.ToString (lay.DATA_LABEL  );
				let DATA_FIELD  : string = Sql.ToString (lay.DATA_FIELD  );
				let DATA_FORMAT : string = Sql.ToString (lay.DATA_FORMAT );
				let URL_FIELD   : string = Sql.ToString (lay.URL_FIELD   );
				//let URL_FORMAT  : string = Sql.ToString (lay.URL_FORMAT  );
				//let URL_TARGET  : string = Sql.ToString (lay.URL_TARGET  );
				let LIST_NAME   : string = Sql.ToString (lay.LIST_NAME   );
				let COLSPAN     : number = Sql.ToInteger(lay.COLSPAN     );
				let LABEL_WIDTH : string = Sql.ToString (lay.LABEL_WIDTH );
				let FIELD_WIDTH : string = Sql.ToString (lay.FIELD_WIDTH );
				//let VIEW_NAME   : string = Sql.ToString (lay.VIEW_NAME   );
				let MODULE_NAME : string = Sql.ToString (lay.MODULE_NAME );
				let TOOL_TIP    : string = Sql.ToString (lay.TOOL_TIP    );
				//let MODULE_TYPE : string = Sql.ToString (lay.MODULE_TYPE );
				//let PARENT_FIELD: string = Sql.ToString (lay.PARENT_FIELD);
				//console.log((new Date()).toISOString() + ' ' + DETAIL_NAME + '\t' + FIELD_INDEX.toString() + '\t' + FIELD_TYPE + '\t' + DATA_LABEL + '\t' + DATA_FIELD + '\t' + URL_FIELD);
				// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
				let bIsHidden   : boolean = lay.hidden;

				// 02/28/2014 Paul.  We are going to start using the data column in the Preview panel. 
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

				let sGridLabel: string = 'tabDetailViewDL';
				let sGridInput: string = 'tabDetailViewDF';
				if ( (DATA_FIELD == 'TEAM_NAME' || DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( !bEnableTeamManagement )
					{
						FIELD_TYPE = 'Blank';
					}
					else if ( bEnableDynamicTeams )
					{
						DATA_LABEL = '.LBL_TEAM_SET_NAME';
						DATA_FIELD = 'TEAM_SET_NAME'     ;
						// 10/08/2022 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
						lay.DATA_LABEL = '.LBL_TEAM_SET_NAME';
						lay.DATA_FIELD = 'TEAM_SET_NAME'     ;
					}
				}
				// 10/08/2022 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment.  Should have been added long ago to match ASP.NET code. 
				else if ( DATA_FIELD == 'ASSIGNED_TO' || DATA_FIELD == 'ASSIGNED_TO_NAME' || DATA_FIELD == 'ASSIGNED_SET_NAME' )
				{
					// 12/17/2017 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
					if ( bEnableDynamicAssignment && !(DATA_FORMAT.toLowerCase().indexOf('single') >= 0) )
					{
						DATA_LABEL = '.LBL_ASSIGNED_SET_NAME';
						DATA_FIELD = 'ASSIGNED_SET_NAME';
						// 10/08/2022 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
						lay.DATA_LABEL = '.LBL_ASSIGNED_SET_NAME';
						lay.DATA_FIELD = 'ASSIGNED_SET_NAME';
					}
					else if ( DATA_FIELD == 'ASSIGNED_SET_NAME' )
					{
						DATA_LABEL = '.LBL_ASSIGNED_TO';
						DATA_FIELD = 'ASSIGNED_TO_NAME';
						// 10/08/2022 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
						lay.DATA_LABEL = '.LBL_ASSIGNED_TO';
						lay.DATA_FIELD = 'ASSIGNED_TO_NAME';
					}
				}
				// 10/08/2022 Paul.  Allow each product to have a default tax rate. 
				else if ( DATA_FIELD == 'TAX_CLASS' )
				{
					if ( bEnableTaxLineItems )
					{
						// 08/28/2009 Paul.  If dynamic teams are enabled, then always use the set name. 
						DATA_LABEL = 'ProductTemplates.LBL_TAXRATE_ID';
						DATA_FIELD = 'TAXRATE_ID';
						LIST_NAME  = 'TaxRates';
						// 10/08/2022 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
						lay.DATA_LABEL = 'ProductTemplates.LBL_TAXRATE_ID';
						lay.DATA_FIELD = 'TAXRATE_ID';
						lay.LIST_NAME  = 'TaxRates';
					}
				}
				// 04/04/2010 Paul.  Hide the Exchange Folder field if disabled for this module or user. 
				else if ( DATA_FIELD == 'EXCHANGE_FOLDER' )
				{
					// 01/09/2021 Paul.  We need to hide the EXCHANGE_FOLDER field if the user does not have Exchange enabled. 
					if ( !Crm_Modules.ExchangeFolders(MODULE_NAME) || !Security.HasExchangeAlias() )
					{
						FIELD_TYPE = 'Blank';
					}
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
						let style: any = tblMain.props.style;
						style.display = (lay.ActiveTab ? 'table' : 'none');
						nPanelIndex++;
					}
					else
					{
						// 04/15/2022 Paul.  Don't need the separator line if using separate tab. 
						//let divSeparator = React.createElement('div', { style: {flexBasis: '100%', height: 0} });
						//tblMainChildren.push(divSeparator);
					
						tblMainChildren = [];
						tblMain = React.createElement('table', { className: sPanelClass, id: baseId + '_tblMain' + nPanelIndex.toString(), key: baseId + '_tblMain' + nPanelIndex.toString(), style: {display: (lay.ActiveTab ? 'table' : 'none')} }, tblMainChildren);
						fragmentChildren.push(tblMain);
						tblBodyChildren = [];
						tbody = React.createElement('tbody', { key: 'tbody' + nLayoutIndex }, tblBodyChildren);
						tblMainChildren.push(tbody);
						nPanelIndex++;
					}

					nColumn = 0;
					trChildren = [];
					tr = null;
					continue;
				}
				// 09/02/2012 Paul.  A separator will create a new table. We need to match the outer and inner layout. 
				// 08/04/2019 Paul.  Line works like a Separator. 
				else if ( FIELD_TYPE == 'Separator' || FIELD_TYPE == 'Line' )
				{
					// 11/12/2019 Paul.  Add remaining cells. 
					// 04/19/2021 Paul.  This does not apply to desktop mode. 
					/*
					for ( let i = 0; i < tblBodyChildren.length % DATA_COLUMNS; i++ )
					{
						trChildren = [];
						tr = React.createElement('tr', { }, trChildren);
						tblBodyChildren.push(tr);
					}
					*/
					
					if ( sTheme != 'Pacific' )
					{
						// 10/27/2020 Paul.  Need to force a break using flex.  Requires that the container be allowed to wrap. 
						// https://tobiasahlin.com/blog/flexbox-break-to-new-row/
						let divSeparator = React.createElement('div', { style: {flexBasis: '100%', height: 0} });
						// 04/16/20222 Paul.  Separator needs to be added to fragment (same as tblMain), otherwise it goes into the table in an invalid position. 
						fragmentChildren.push(divSeparator);
					}
					
					tblMainChildren = [];
					tblMain = React.createElement('table', { className: sPanelClass, id: baseId + '_tblMain' + nPanelIndex.toString(), key: baseId + '_tblMain' + nPanelIndex.toString(), style: {} }, tblMainChildren);
					// 04/16/2022 Paul.  Separators usually start a new table or division, so separators after active tab need to be treated as a set. 
					if ( bTabsEnabled )
					{
						let style: any = tblMain.props.style;
						style.display = (lay.ActiveTab ? 'table' : 'none');
						nPanelIndex++;
					}
					fragmentChildren.push(tblMain);
					tblBodyChildren = [];
					tbody = React.createElement('tbody', { key: 'tbody' + nLayoutIndex }, tblBodyChildren);
					tblMainChildren.push(tbody);
					nPanelIndex++;
					nColumn = 0;
					trChildren = [];
					tr = null;
					continue;
				}
				// 08/08/2019 Paul.  We no longer force a new row every other loop, just let flex wrap with 50% columns. 
				// 04/18/2021 Paul.  Going back to old table code. 
				if ( nColumn % DATA_COLUMNS == 0 || tr == null || bIsMobile )
				{
					trChildren = [];
					// 08/25/2019 Paul.  This is the correct place to handle colspan. 
					if ( COLSPAN == 3 )
					{
						sFlexLabelFieldWidth  = '100%';
					}
					tr = React.createElement('tr', { key: FIELD_TYPE + 'row' + nLayoutIndex }, trChildren);
					tblBodyChildren.push(tr);
				}
				let bIsReadable: boolean = true;
				if ( MODULE_NAME == null && layout.length > 0 )
				{
					let arrDETAIL_NAME: string[] = DETAIL_NAME.split('.');
					if ( arrDETAIL_NAME.length > 0 )
					{
						MODULE_NAME = arrDETAIL_NAME[0];
					}
				}
				// 06/16/2010 Paul.  sDATA_FIELD may be empty. 
				if ( SplendidCache.bEnableACLFieldSecurity && !Sql.IsEmptyString(DATA_FIELD) )
				{
					let gASSIGNED_USER_ID = null;
					if ( row != null )
					{
						gASSIGNED_USER_ID = Sql.ToGuid(row.ASSIGNED_USER_ID);
					}
					let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
				}
				if ( !bIsReadable )
				{
					FIELD_TYPE = 'Blank';
				}

				// 06/21/2015 Paul.  The Seven theme has labels stacked above values. 
				let tdLabelChildren = [];
				let tdLabel = null;
				let tdFieldChildren = [];
				let tdField = null;
				let sLabelID = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
				let sFieldID = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex);
				// 10/29/2020 Paul.  A header needs to be able to modify the label width. 
				// 10/29/2020 Paul.  Can't seem to override the class once the element is created. 
				// 04/20/2021 Paul.  We want to match the old system so keep the style. 
				//if ( FIELD_TYPE == 'Header' )
				//	sGridLabel = null;
				let tdLabelProps: any = { id: sLabelID, className: sGridLabel, style: { width: LABEL_WIDTH } };
				// 04/16/2022 Paul.  need to move colSpan to prevent it from being attached to div tag. 
				let tdFieldProps: any = { className: sGridInput, id: sFieldID, key: sFieldID, style: { width: FIELD_WIDTH } };
				// 04/19/2021 Paul.  Manually calculate responsive features. 
				if ( bStackedLayout )
				{
					// 04/16/2022 Paul.  Remove width if using stacked. 
					tdLabelProps.style = {};
					tdFieldProps.style = {};
					let tdStackChildren = [];
					let tdStackProps: any = { style: {} };
					if ( bStackedTheme )
					{
						tdStackProps.className = 'tabStackedDetailViewDF';
						tdLabelProps.className = 'tabStackedDetailViewDL';
					}
					//else
					{
						tdLabelProps.style.textAlign  = 'inherit';
						tdStackProps.style.padding    = '0px';
					}
					if ( sTheme == 'Pacific' )
					{
						// 04/04/2022 Paul.  Change to css selector: .tabStackedDetailViewDF > .tabDetailViewDF
						//tdFieldProps.style.minHeight    = '2.1em';
						//tdFieldProps.style.borderBottom = '.0625rem dotted #d9d9d9';
						tdStackProps.style.paddingLeft  = '1em';
						tdStackProps.style.paddingRight = '1em';
						// 04/16/2022 Paul.  We seem to need to force the width when multiple panels are displayed. 
						tdStackProps.style.width        = sFlexLabelFieldWidth;
						if ( DATA_COLUMNS > 1 && COLSPAN <= 1 )
						{
							if ( (nColumn < DATA_COLUMNS - 1) )
							{
								tdStackProps.style.borderRight = '.0625rem solid #93a4b3';
							}
						}
					}
					if ( COLSPAN > 1 )
					{
						// 04/16/2022 Paul.  colspan is typically 3 for 2 column layout, so we need to reduce by 1 when stacked. 
						tdStackProps.colSpan = COLSPAN - 1;
					}
					let tdStack = React.createElement('td', tdStackProps, tdStackChildren);
					trChildren.push(tdStack);
					tdLabel = React.createElement('div', tdLabelProps, tdLabelChildren);
					tdStackChildren.push(tdLabel)
					tdField = React.createElement('div', tdFieldProps, tdFieldChildren);
					tdStackChildren.push(tdField);
				}
				else
				{
					if ( COLSPAN > 0 )
					{
						tdFieldProps.colSpan = COLSPAN;
					}
					// 11/12/2019 Paul.  Default top align looks terrible. 
					// 12/17/2019 Paul.  Baseline looks better than center, especially for multi-line controls such as Teams and Tags. 
					// 03/19/2020 Paul.  Remove inner span around label so that it will follow the right alignment of the style. 
					// 03/19/2020 Paul.  flex is preventing style from aligning right.  Not sure we need flex in the label. // display: 'flex', alignItems: 'baseline'
					tdLabel = React.createElement('td', tdLabelProps, tdLabelChildren);
					trChildren.push(tdLabel)
					tdField = React.createElement('td', tdFieldProps, tdFieldChildren);
					trChildren.push(tdField);
				}
				// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
				if ( !bIsHidden )
				{
					// 04/28/2019 Paul.  Header text goes in the field column, leaving the label column blank. 
					if ( DATA_LABEL != null && FIELD_TYPE != 'Header' )
					{
						if ( FIELD_TYPE != 'Blank' )
						{
							if ( DATA_LABEL.indexOf('.') >= 0 )
							{
								let txt = L10n.Term(DATA_LABEL);
								// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
								// 01/13/2020 Paul.  Allow the label to contain HTML. 
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
							else if ( !Sql.IsEmptyString(DATA_LABEL) )
							{
								// 06/21/2015 Paul.  Label can contain raw text. 
								let sLabel = row[DATA_LABEL];
								if ( sLabel === undefined )
								{
									sLabel = Sql.ToString(DATA_LABEL);
								}
								if ( !Sql.IsEmptyString(sLabel) )
								{
									let txt = sLabel;
									// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
									txt = Sql.ReplaceEntities(txt);
									tdLabelChildren.push(txt);
								}
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
						// 04/15/2022 Paul.  Stacked layout needs nbsp for label. 
						else if ( bStackedLayout )
						{
							let nbsp = React.createElement('span', {}, ['\u00a0']);
							tdLabelChildren.push(nbsp);
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
						console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamicDetailView ' + DETAIL_NAME + '.' + DATA_FIELD + ' already exists in refMap.');
					}
				}
				let ref = React.createRef<DetailComponent<any, any>>();
				refMap[key] = ref;
				if ( FIELD_TYPE == 'HyperLink' )
				{
					let lnkProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let lnk = React.createElement(HyperLink, lnkProps);
					tdFieldChildren.push(lnk);
				}
				// 01/10/2023 Paul.  Correct the field type name, it is not ModueLink. 
				else if ( FIELD_TYPE == 'ModuleLink' )
				{
					let lnkProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let lnk = React.createElement(ModuleLink, lnkProps);
					tdFieldChildren.push(lnk);
				}
				else if ( FIELD_TYPE == 'String' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt = React.createElement(SplendidString, txtProps);
					tdFieldChildren.push(txt);
				}
				else if ( FIELD_TYPE == 'TextBox' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt = React.createElement(TextBox, txtProps);
					tdFieldChildren.push(txt);
				}
				// 05/27/2016 Paul.  Add support for Image type. 
				else if ( FIELD_TYPE == 'Image' )
				{
					let imgProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let img = React.createElement(Image, imgProps);
					tdFieldChildren.push(img);
				}
				// 05/27/2016 Paul.  Add support for File type. 
				else if ( FIELD_TYPE == 'File' )
				{
					let imgProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let img = React.createElement(SplendidFile, imgProps);
					tdFieldChildren.push(img);
				}
				else if ( FIELD_TYPE == 'CheckBox' )
				{
					let chkProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let chk = React.createElement(CheckBox, chkProps);
					tdFieldChildren.push(chk);
				}
				else if ( FIELD_TYPE == 'Blank' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt = React.createElement(Blank, txtProps);
					tdFieldChildren.push(txt);
				}
				// 09/03/2012 Paul.  A header is similar to a label, but without the data field. 
				else if ( FIELD_TYPE == 'Header' )
				{
					// 10/29/2020 Paul.  Match behavior of EditView that places the header in the label column. 
					tdLabelChildren.pop();
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt = React.createElement(Header, txtProps);
					// 10/29/2020 Paul.  Overriding the initial class does not work, so we will need to override above. 
					tdLabelProps.className   = '';
					tdLabelChildren.push(txt);
				}
				// 06/21/2015 Paul.  We are not ready to support javascript. 
				// 02/25/2016 Paul.  Add support for JavaScript for OfficeAddin. 
				else if ( FIELD_TYPE == 'JavaScript' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt = React.createElement(JavaScript, txtProps);
					tdFieldChildren.push(txt);
				}
				// 05/14/2016 Paul.  Add Tags module. 
				else if ( FIELD_TYPE == 'Tags' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt = React.createElement(Tags, txtProps);
					tdFieldChildren.push(txt);
				}
				// 07/31/2019 Paul.  Add Button module. 
				else if ( FIELD_TYPE == 'Button' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden, Page_Command };
					let txt = React.createElement(SplendidButton, txtProps);
					tdFieldChildren.push(txt);
				}
				else
				{
					tdFieldChildren.push('Unsupported field type: ' + FIELD_TYPE);
				}
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				// 05/17/2018 Chase. Not sure if needed.
				/*if (SplendidDynamic.BootstrapLayout()) {
					// 04/08/2017 Paul.  An empty field will cause problems for grid flow. 
					// 01/11/2018 Paul.  Adding nbsp to innerHTML is causing the hyperlinks to fail.  Instead, add text node. 
					tdLabelChildren.push(' ');
					tdFieldChildren.push(' ');
				}*/
				if ( COLSPAN > 0 )
				{
					nColumn += COLSPAN;
				}
				else if ( COLSPAN == 0 )
				{
					nColumn++;
				}
				if ( nColumn >= DATA_COLUMNS )
				{
					nColumn = 0;
				}
			}
			// 11/12/2019 Paul.  Add remaining cells. 
			// 04/18/2021 Paul.  Not needed for desktop layout. 
			/*
			for ( let i = 0; i < tblBodyChildren.length % DATA_COLUMNS; i++ )
			{
				trChildren = [];
				if ( bStackedLayout )
					tr = React.createElement('tr', { className: 'tabStackedDetailViewDF' }, trChildren);
				else
					tr = React.createElement('tr', { }, trChildren);
				tblBodyChildren.push(tr);
			}
			*/
			// 11/12/2019 Paul.  I don't think we will use the same style of JavaScript custom code. 
			/*
			// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
			for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay = layout[nLayoutIndex];
				let sFORM_SCRIPT = lay.SCRIPT;
				if ( !Sql.IsEmptyString(sFORM_SCRIPT) )
				{
					// 11/24/2017 Paul.  Need to replace all occurrences. 
					sFORM_SCRIPT = sFORM_SCRIPT.replace(/SPLENDID_DETAILVIEW_LAYOUT_ID/g, 'ctlDetailView');
					// 01/18/2018 Paul.  If wrapped, then treat FORM_SCRIPT as a function. 
					sFORM_SCRIPT = Trim(sFORM_SCRIPT);
					if ( StartsWith(sFORM_SCRIPT, '(') && EndsWith(sFORM_SCRIPT, ')') )
					{
						//console.log((new Date()).toISOString() + ' ' + 'Evaluating form script as function.');
						let fnFORM_SCRIPT = eval(sFORM_SCRIPT);
						if ( typeof (fnFORM_SCRIPT) == 'function' )
						{
							// 01/18/2018 Paul.  Execute the script, but if an object is returned, then it just created a function, not execute it. 
							let fnFORM_SCRIPT_Init = fnFORM_SCRIPT();
							if ( fnFORM_SCRIPT_Init !== undefined && typeof (fnFORM_SCRIPT_Init.Initialize) == 'function' )
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
						eval(sFORM_SCRIPT);
					}
				}
				break;
			}
			*/
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendDetailViewFields', error);
		}
		return fragment;
	}

	static AppendDetailViewFields_Mobile(row: any, layout: any, refMap: any, sPanelClass: string, fieldDidMount: Function, Page_Command: Function): JSX.Element
	{
		let tblMainChildren: Array<JSX.Element> = [];
		// 03/19/2020 Paul.  We need to dynamically create a unique baseId as the Leads.EditView.Inline and Contacts.EditView.Inline are both on the Accounts.DetailView page, leading to a naming confict. 
		let baseId: string = 'ctlDetailView';
		if ( layout != null && layout.length > 0 )
		{
			let DETAIL_NAME   : string   = Sql.ToString(layout[0].DETAIL_NAME );
			baseId = 'ctlDetailView_' + DETAIL_NAME.replace(/\./g, '_');
		}
		let tblMain = React.createElement('div', { className: '', key: baseId + '_tblMain' }, tblMainChildren);
		try
		{
			// 10/17/2012 Paul.  Exit if the Main does not exist.  This is a sign that the user has navigated elsewhere. 
			if (tblMain == null)
				return;
			let tblBodyChildren: Array<JSX.Element> = [];
			let tbody = React.createElement('div', { className: sPanelClass, key: 'tbody', width: '100%', style: { display: 'flex', flexDirection: 'row', flexWrap: 'wrap'} }, tblBodyChildren);
			tblMainChildren.push(tbody);
			let trChildren = [];
			let tr = null;
			let nColumn = 0;
			let bEnableTeamManagement = Crm_Config.enable_team_management();
			let bEnableDynamicTeams   = Crm_Config.enable_dynamic_teams();
			// 12/06/2014 Paul.  Use new mobile flag. 
			let bIsMobile = isMobileDevice();
			if ( isMobileLandscape() )
			{
				bIsMobile = false;
			}
			let sTheme = Security.USER_THEME();
			// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
			let oNumberFormat = Security.NumberFormatInfo();
			// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
			let ERASED_FIELDS: string[] = [];
			if ( Crm_Config.enable_data_privacy() )
			{
				if ( row['ERASED_FIELDS'] !== undefined )
				{
					ERASED_FIELDS = Sql.ToString(row['ERASED_FIELDS']).split(',');
				}
			}
			let bStackedLayout: boolean = SplendidDynamic.StackedLayout(sTheme) && sPanelClass != 'tabPreviewView';
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			let themeURL   : string  = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
			let legacyIcons: boolean = Crm_Config.ToBoolean('enable_legacy_icons');
	
			// 11/12/2019 Paul.  Declare DATA_COLUMNS outside loop so that we can calculate the padding. 
			let DATA_COLUMNS        : number = 2;
			let sFlexLabelFieldWidth: string = '100%';
			for (let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++)
			{
				let lay = layout[nLayoutIndex];
				let DETAIL_NAME : string = Sql.ToString (lay.DETAIL_NAME );
				let FIELD_INDEX : number = Sql.ToInteger(lay.FIELD_INDEX );
				let FIELD_TYPE  : string = Sql.ToString (lay.FIELD_TYPE  );
				let DATA_LABEL  : string = Sql.ToString (lay.DATA_LABEL  );
				let DATA_FIELD  : string = Sql.ToString (lay.DATA_FIELD  );
				//let DATA_FORMAT : string = Sql.ToString (lay.DATA_FORMAT );
				let URL_FIELD   : string = Sql.ToString (lay.URL_FIELD   );
				//let URL_FORMAT  : string = Sql.ToString (lay.URL_FORMAT  );
				//let URL_TARGET  : string = Sql.ToString (lay.URL_TARGET  );
				//let LIST_NAME   : string = Sql.ToString (lay.LIST_NAME   );
				let COLSPAN     : number = Sql.ToInteger(lay.COLSPAN     );
				let LABEL_WIDTH : string = Sql.ToString (lay.LABEL_WIDTH );
				let FIELD_WIDTH : string = Sql.ToString (lay.FIELD_WIDTH );
				//let VIEW_NAME   : string = Sql.ToString (lay.VIEW_NAME   );
				let MODULE_NAME : string = Sql.ToString (lay.MODULE_NAME );
				let TOOL_TIP    : string = Sql.ToString (lay.TOOL_TIP    );
				//let MODULE_TYPE : string = Sql.ToString (lay.MODULE_TYPE );
				//let PARENT_FIELD: string = Sql.ToString (lay.PARENT_FIELD);
				//console.log((new Date()).toISOString() + ' ' + DETAIL_NAME + '\t' + FIELD_INDEX.toString() + '\t' + FIELD_TYPE + '\t' + DATA_LABEL + '\t' + DATA_FIELD + '\t' + URL_FIELD);
				// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
				let bIsHidden   : boolean = lay.hidden;

				// 02/28/2014 Paul.  We are going to start using the data column in the Preview panel. 
				DATA_COLUMNS = Sql.ToInteger(lay.DATA_COLUMNS);
				if ( DATA_COLUMNS == 0 )
				{
					DATA_COLUMNS = 2;
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
					LABEL_WIDTH = (nLABEL_WIDTH * DATA_COLUMNS) + '%';
					FIELD_WIDTH = (nFIELD_WIDTH * DATA_COLUMNS) + '%';
				}

				let sGridLabel: string = 'tabDetailViewDL';
				let sGridInput: string = 'tabDetailViewDF';
				if ( bStackedLayout )
				{
					sGridLabel = 'tabStackedEditViewDL';
					sGridInput = null;
				}
				if ( (DATA_FIELD == 'TEAM_NAME' || DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( !bEnableTeamManagement )
					{
						FIELD_TYPE = 'Blank';
					}
					else if ( bEnableDynamicTeams )
					{
						DATA_LABEL = '.LBL_TEAM_SET_NAME';
						DATA_FIELD = 'TEAM_SET_NAME'     ;
					}
				}
				// 04/04/2010 Paul.  Hide the Exchange Folder field if disabled for this module or user. 
				if ( DATA_FIELD == 'EXCHANGE_FOLDER' )
				{
					// 01/09/2021 Paul.  We need to hide the EXCHANGE_FOLDER field if the user does not have Exchange enabled. 
					if ( !Crm_Modules.ExchangeFolders(MODULE_NAME) || !Security.HasExchangeAlias() )
					{
						FIELD_TYPE = 'Blank';
					}
				}
				// 09/02/2012 Paul.  A separator will create a new table. We need to match the outer and inner layout. 
				// 08/04/2019 Paul.  Line works like a Separator. 
				if ( FIELD_TYPE == 'Separator' || FIELD_TYPE == 'Line' )
				{
					// 11/12/2019 Paul.  Add remaining cells. 
					for ( let i = 0; i < tblBodyChildren.length % DATA_COLUMNS; i++ )
					{
						trChildren = [];
						if ( bStackedLayout )
							tr = React.createElement('div', { className: 'tabStackedDetailViewDF', style: { flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '5px 10px 5px 10px' } }, trChildren);
						else
							tr = React.createElement('div', { style: { display: 'flex', flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '5px 10px 5px 10px' } }, trChildren);
						tblBodyChildren.push(tr);
					}
					
					// 10/27/2020 Paul.  Need to force a break using flex.  Requires that the container be allowed to wrap. 
					// https://tobiasahlin.com/blog/flexbox-break-to-new-row/
					let divSeparator = React.createElement('div', { style: {flexBasis: '100%', height: 0} });
					tblMainChildren.push(divSeparator);
					
					tblBodyChildren = [];
					tbody = React.createElement('div', { className: 'tabDetailView', key: 'tbody' + nLayoutIndex, width: '100%', style: { display: 'flex', flexDirection: 'row', flexWrap: 'wrap' } }, tblBodyChildren);
					tblMainChildren.push(tbody);
					nColumn = 0;
					trChildren = [];
					tr = null;
					continue;
				}
				// 08/08/2019 Paul.  We no longer force a new row every other loop, just let flex wrap with 50% columns. 
				//if ( nColumn % DATA_COLUMNS == 0 || tr == null || bIsMobile )
				{
					trChildren = [];
					// 08/25/2019 Paul.  This is the correct place to handle colspan. 
					if ( COLSPAN == 3 )
					{
						sFlexLabelFieldWidth  = '100%';
					}
					if ( bStackedLayout )
						tr = React.createElement('div', { className: 'tabStackedDetailViewDF', key: FIELD_TYPE + 'row' + nLayoutIndex, style: { flexDirection: 'row', flexWrap: 'wrap', 'flex': '1 0 ' + sFlexLabelFieldWidth} }, trChildren);
					else
						tr = React.createElement('div', { key: FIELD_TYPE + 'row' + nLayoutIndex, style: { display: 'flex', flexDirection: 'row', flexWrap: 'wrap', 'flex': '1 0 ' + sFlexLabelFieldWidth} }, trChildren);
					tblBodyChildren.push(tr);
				}
				let bIsReadable: boolean = true;
				if ( MODULE_NAME == null && layout.length > 0 )
				{
					let arrDETAIL_NAME: string[] = DETAIL_NAME.split('.');
					if ( arrDETAIL_NAME.length > 0 )
					{
						MODULE_NAME = arrDETAIL_NAME[0];
					}
				}
				// 06/16/2010 Paul.  sDATA_FIELD may be empty. 
				if ( SplendidCache.bEnableACLFieldSecurity && !Sql.IsEmptyString(DATA_FIELD) )
				{
					let gASSIGNED_USER_ID = null;
					if ( row != null )
					{
						gASSIGNED_USER_ID = Sql.ToGuid(row.ASSIGNED_USER_ID);
					}
					let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
				}
				if ( !bIsReadable )
				{
					FIELD_TYPE = 'Blank';
				}

				// 06/21/2015 Paul.  The Seven theme has labels stacked above values. 
				let tdLabelChildren = [];
				let tdLabel = null;
				let tdFieldChildren = [];
				let tdField = null;
				let sLabelID = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
				// 10/29/2020 Paul.  A header needs to be able to modify the label width. 
				// 10/29/2020 Paul.  Can't seem to override the class once the element is created. 
				if ( FIELD_TYPE == 'Header' )
					sGridLabel = null;
				let tdLabelProps: any = { id: sLabelID, className: sGridLabel, style: { width: LABEL_WIDTH } };

				// 11/12/2019 Paul.  Default top align looks terrible. 
				// 12/17/2019 Paul.  Baseline looks better than center, especially for multi-line controls such as Teams and Tags. 
				// 03/19/2020 Paul.  Remove inner span around label so that it will follow the right alignment of the style. 
				// 03/19/2020 Paul.  flex is preventing style from aligning right.  Not sure we need flex in the label. // display: 'flex', alignItems: 'baseline'
				tdLabel = React.createElement('div', tdLabelProps, tdLabelChildren);
				trChildren.push(tdLabel)
				// 05/17/2018 Chase. Not sure if needed
				/*if ( COLSPAN > 0 )
					{
					nColumn++;
					if ( DATA_COLUMNS == 1 )
					{
						// 04/08/2017 Paul.  Unchanged from default. 
						//sGridLabel = ' col-md-3 col-sm-3 col-xs-12';
						//sGridInput = 'col-md-9 col-sm-9 col-xs-12';
					}
					else if ( DATA_COLUMNS == 2 )
					{
						// 04/08/2017 Paul.  Take rest of columns. 
						//sGridLabel = ' col-md-2 col-sm-2 col-xs-12';
						sGridInput = 'col-md-10 col-sm-10 col-xs-12';
					}
					else
					{
						// 04/08/2017 Paul.  Take rest of columns. 
						//sGridLabel = ' col-md-1 col-sm-1 col-xs-12';
						sGridInput = 'col-md-11 col-sm-11 col-xs-12';
					}
				}*/
				let sFieldID = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex);
				tdField = React.createElement('div', { className: sGridInput, id: sFieldID, key: sFieldID, style: { width: FIELD_WIDTH, display: 'flex', flexDirection: 'row', flexWrap: 'wrap'} }, tdFieldChildren);
				trChildren.push(tdField);
				// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
				if ( !bIsHidden )
				{
					// 04/28/2019 Paul.  Header text goes in the field column, leaving the label column blank. 
					if ( DATA_LABEL != null && FIELD_TYPE != 'Header' )
					{
						if ( FIELD_TYPE != 'Blank' )
						{
							if ( DATA_LABEL.indexOf('.') >= 0 )
							{
								let txt = L10n.Term(DATA_LABEL);
								// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
								// 01/13/2020 Paul.  Allow the label to contain HTML. 
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
							else if ( !Sql.IsEmptyString(DATA_LABEL) )
							{
								// 06/21/2015 Paul.  Label can contain raw text. 
								let sLabel = row[DATA_LABEL];
								if ( sLabel === undefined )
								{
									sLabel = Sql.ToString(DATA_LABEL);
								}
								if ( !Sql.IsEmptyString(sLabel) )
								{
									let txt = sLabel;
									// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
									txt = Sql.ReplaceEntities(txt);
									tdLabelChildren.push(txt);
								}
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
						console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamicDetailView ' + DETAIL_NAME + '.' + DATA_FIELD + ' already exists in refMap.');
					}
				}
				let ref = React.createRef<DetailComponent<any, any>>();
				refMap[key] = ref;
				if ( FIELD_TYPE == 'HyperLink' )
				{
					let lnkProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let lnk = React.createElement(HyperLink, lnkProps);
					tdFieldChildren.push(lnk);
				}
				// 01/10/2023 Paul.  Correct the field type name, it is not ModueLink. 
				else if ( FIELD_TYPE == 'ModuleLink' )
				{
					let lnkProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let lnk = React.createElement(ModuleLink, lnkProps);
					tdFieldChildren.push(lnk);
				}
				else if ( FIELD_TYPE == 'String' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt = React.createElement(SplendidString, txtProps);
					tdFieldChildren.push(txt);
				}
				else if ( FIELD_TYPE == 'TextBox' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt = React.createElement(TextBox, txtProps);
					tdFieldChildren.push(txt);
				}
				// 05/27/2016 Paul.  Add support for Image type. 
				else if ( FIELD_TYPE == 'Image' )
				{
					let imgProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let img = React.createElement(Image, imgProps);
					tdFieldChildren.push(img);
				}
				// 05/27/2016 Paul.  Add support for File type. 
				else if ( FIELD_TYPE == 'File' )
				{
					let imgProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let img = React.createElement(SplendidFile, imgProps);
					tdFieldChildren.push(img);
				}
				else if ( FIELD_TYPE == 'CheckBox' )
				{
					let chkProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let chk = React.createElement(CheckBox, chkProps);
					tdFieldChildren.push(chk);
				}
				else if ( FIELD_TYPE == 'Blank' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt = React.createElement(Blank, txtProps);
					tdFieldChildren.push(txt);
				}
				// 09/03/2012 Paul.  A header is similar to a label, but without the data field. 
				else if ( FIELD_TYPE == 'Header' )
				{
					// 10/29/2020 Paul.  Match behavior of EditView that places the header in the label column. 
					tdLabelChildren.pop();
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt = React.createElement(Header, txtProps);
					// 10/29/2020 Paul.  Overriding the initial class does not work, so we will need to override above. 
					tdLabelProps.className   = '';
					tdLabelProps.style.width = (nLABEL_WIDTH + nFIELD_WIDTH * 2) + '%';
					tdLabelChildren.push(txt);
				}
				// 06/21/2015 Paul.  We are not ready to support javascript. 
				// 02/25/2016 Paul.  Add support for JavaScript for OfficeAddin. 
				else if ( FIELD_TYPE == 'JavaScript' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt = React.createElement(JavaScript, txtProps);
					tdFieldChildren.push(txt);
				}
				// 05/14/2016 Paul.  Add Tags module. 
				else if ( FIELD_TYPE == 'Tags' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt = React.createElement(Tags, txtProps);
					tdFieldChildren.push(txt);
				}
				// 07/31/2019 Paul.  Add Button module. 
				else if ( FIELD_TYPE == 'Button' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden, Page_Command };
					let txt = React.createElement(SplendidButton, txtProps);
					tdFieldChildren.push(txt);
				}
				else
				{
					tdFieldChildren.push('Unsupported field type: ' + FIELD_TYPE);
				}
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				// 05/17/2018 Chase. Not sure if needed.
				/*if (SplendidDynamic.BootstrapLayout()) {
					// 04/08/2017 Paul.  An empty field will cause problems for grid flow. 
					// 01/11/2018 Paul.  Adding nbsp to innerHTML is causing the hyperlinks to fail.  Instead, add text node. 
					tdLabelChildren.push(' ');
					tdFieldChildren.push(' ');
				}*/
				nColumn++;
			}
			// 11/12/2019 Paul.  Add remaining cells. 
			for ( let i = 0; i < tblBodyChildren.length % DATA_COLUMNS; i++ )
			{
				trChildren = [];
				if ( bStackedLayout )
					tr = React.createElement('div', { className: 'tabStackedDetailViewDF', style: { flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '5px 10px 5px 10px' } }, trChildren);
				else
					tr = React.createElement('div', { style: { display: 'flex', flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '5px 10px 5px 10px' } }, trChildren);
				tblBodyChildren.push(tr);
			}
			// 11/12/2019 Paul.  I don't think we will use the same style of JavaScript custom code. 
			/*
			// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
			for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay = layout[nLayoutIndex];
				let sFORM_SCRIPT = lay.SCRIPT;
				if ( !Sql.IsEmptyString(sFORM_SCRIPT) )
				{
					// 11/24/2017 Paul.  Need to replace all occurrences. 
					sFORM_SCRIPT = sFORM_SCRIPT.replace(/SPLENDID_DETAILVIEW_LAYOUT_ID/g, 'ctlDetailView');
					// 01/18/2018 Paul.  If wrapped, then treat FORM_SCRIPT as a function. 
					sFORM_SCRIPT = Trim(sFORM_SCRIPT);
					if ( StartsWith(sFORM_SCRIPT, '(') && EndsWith(sFORM_SCRIPT, ')') )
					{
						//console.log((new Date()).toISOString() + ' ' + 'Evaluating form script as function.');
						let fnFORM_SCRIPT = eval(sFORM_SCRIPT);
						if ( typeof (fnFORM_SCRIPT) == 'function' )
						{
							// 01/18/2018 Paul.  Execute the script, but if an object is returned, then it just created a function, not execute it. 
							let fnFORM_SCRIPT_Init = fnFORM_SCRIPT();
							if ( fnFORM_SCRIPT_Init !== undefined && typeof (fnFORM_SCRIPT_Init.Initialize) == 'function' )
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
						eval(sFORM_SCRIPT);
					}
				}
				break;
			}
			*/
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendDetailViewFields', error);
		}
		return tblMain;
	}
}

