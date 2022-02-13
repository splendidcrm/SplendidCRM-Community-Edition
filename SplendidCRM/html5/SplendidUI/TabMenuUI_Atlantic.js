/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function TabMenuUI_Atlantic(sLayoutPanel, sActionsPanel)
{
	this.LayoutPanel  = sLayoutPanel;
	this.ActionsPanel = sActionsPanel;
	this.divHeader_divError           = null;
	this.divHeader_divAuthenticated   = null;
	this.divHeader_spnWelcome         = null;
	this.divHeader_spnUserName        = null;
	this.divHeader_spnLogout          = null;
	this.divHeader_lnkLogout          = null;
	// 08/22/2014 Paul.  Add SyncNow for offline client. 
	this.divHeader_spnSyncNow         = null;
	this.divHeader_lnkSyncNow         = null;
	this.divHeader_divOnlineStatus    = null;
	this.divHeader_divOfflineCache    = null;
	this.divHeader_divSplendidStorage = null;
	this.lnkHeaderCacheAll            = null;
	this.lnkHeaderSystemLog           = null;
	this.lnkHeaderSplendidStorage     = null;
}

TabMenuUI_Atlantic.prototype.divError           = function() { return this.divHeader_divError          ; }
TabMenuUI_Atlantic.prototype.divAuthenticated   = function() { return this.divHeader_divAuthenticated  ; }
TabMenuUI_Atlantic.prototype.spnWelcome         = function() { return this.divHeader_spnWelcome        ; }
TabMenuUI_Atlantic.prototype.spnUserName        = function() { return this.divHeader_spnUserName       ; }
TabMenuUI_Atlantic.prototype.spnLogout          = function() { return this.divHeader_spnLogout         ; }
TabMenuUI_Atlantic.prototype.lnkLogout          = function() { return this.divHeader_lnkLogout         ; }
// 08/22/2014 Paul.  Add SyncNow for offline client. 
TabMenuUI_Atlantic.prototype.spnSyncNow         = function() { return this.divHeader_spnSyncNow        ; }
TabMenuUI_Atlantic.prototype.lnkSyncNow         = function() { return this.divHeader_lnkSyncNow        ; }
TabMenuUI_Atlantic.prototype.divOnlineStatus    = function() { return this.divHeader_divOnlineStatus   ; }
TabMenuUI_Atlantic.prototype.divOfflineCache    = function() { return this.divHeader_divOfflineCache   ; }
TabMenuUI_Atlantic.prototype.divSplendidStorage = function() { return this.divHeader_divSplendidStorage; }
TabMenuUI_Atlantic.prototype.lnkCacheAll        = function() { return this.lnkHeaderCacheAll           ; }
TabMenuUI_Atlantic.prototype.lnkSystemLog       = function() { return this.lnkHeaderSystemLog          ; }
TabMenuUI_Atlantic.prototype.lnkSplendidStorage = function() { return this.lnkHeaderSplendidStorage    ; }

TabMenuUI_Atlantic.prototype.RenderHeader = function()
{
	try
	{
		TabMenuUI_Clear('ctlHeader');
		TabMenuUI_Clear('ctlTabMenu');
		TabMenuUI_Clear('ctlAtlanticToolbar');
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'TabMenuUI_Atlantic.RenderHeader');
	}
}

// 12/06/2014 Paul.  LayoutMode is used on the Mobile view. 
TabMenuUI_Atlantic.prototype.ActivateTab = function(sMODULE_NAME, sID, sLAYOUT_MODE)
{
	if ( sMODULE_NAME != sMENU_ACTIVE_MODULE )
	{
		try
		{
			// 04/23/2013 Paul.  Disable Atlantic menu. 
			var tbl = document.getElementById('ctlAtlanticToolbar_ctlTabMenu_tabMenuInner' + sMENU_ACTIVE_MODULE);
			if ( tbl != null )
			{
				tbl.rows[0].cells[0].className = 'AtlanticOtherTab';
			}
			// 02/01/2013 Paul.  Render all action bars, just all but the active one. 
			var pnlModuleActions = document.getElementById('pnlModuleActionsBar' + sMENU_ACTIVE_MODULE);
			if ( pnlModuleActions != null )
			{
				pnlModuleActions.style.display    = 'none';
				pnlModuleActions.style.visibility = 'hidden';
			}

			sMENU_ACTIVE_MODULE = sMODULE_NAME;
			// 04/23/2013 Paul.  Enable Atlantic menu. 
			tbl = document.getElementById('ctlAtlanticToolbar_ctlTabMenu_tabMenuInner' + sMENU_ACTIVE_MODULE);
			if ( tbl != null )
			{
				tbl.rows[0].cells[0].className = 'AtlanticCurrentTab';
			}
			// 02/01/2013 Paul.  Render all action bars, just all but the active one. 
			var pnlModuleActions = document.getElementById('pnlModuleActionsBar' + sMENU_ACTIVE_MODULE);
			if ( pnlModuleActions != null )
			{
				pnlModuleActions.style.display    = 'block';
				pnlModuleActions.style.visibility = 'visible';
			}
		}
		catch(e)
		{
			SplendidError.SystemAlert(e, 'TabMenuUI_Atlantic.ActivateTab');
		}
	}
}

TabMenuUI_Atlantic.prototype.Render = function(sLayoutPanel, sActionsPanel, arrDetailViewRelationship, arrQuickCreate, result)
{
	var ctlAtlanticToolbar = document.getElementById('ctlAtlanticToolbar');
	if ( ctlAtlanticToolbar != null )
	{
		var bgPage = chrome.extension.getBackgroundPage();
		// 05/06/2013 Paul.  Clear pointers as the tags will be deleted. 
		this.divHeader_divError           = null;
		this.divHeader_divAuthenticated   = null;
		this.divHeader_spnWelcome         = null;
		this.divHeader_spnUserName        = null;
		this.divHeader_spnLogout          = null;
		this.divHeader_lnkLogout          = null;
		// 08/22/2014 Paul.  Add SyncNow for offline client. 
		this.divHeader_spnSyncNow         = null;
		this.divHeader_lnkSyncNow         = null;
		this.divHeader_divOnlineStatus    = null;
		this.divHeader_divOfflineCache    = null;
		this.divHeader_divSplendidStorage = null;
		this.lnkHeaderCacheAll            = null;
		this.lnkHeaderSystemLog           = null;
		this.lnkHeaderSplendidStorage     = null;
		if ( ctlAtlanticToolbar.childNodes != null )
		{
			while ( ctlAtlanticToolbar.childNodes.length > 0 )
			{
				ctlAtlanticToolbar.removeChild(ctlAtlanticToolbar.firstChild);
			}
		}

		//<table cellspacing="0" cellpadding="0" border="0" class="AtlanticToolbar">
		//	<tbody>
		//		<tr>
		//			<td nowrap="1">
		//				<div id="divTabMenu">
		//				</div>
		//			</td>
		//			<td width="100%" class="AtlanticTabRow">
		//				<img src="../Include/images/blank.gif" align="absmiddle" style="border-width:0px;height:1px;width:1px;" />
		//			</td>
		//		</tr>
		//	</tbody>
		//</table>
		var tblAtlanticToolbar = document.createElement('table');
		tblAtlanticToolbar.className   = 'AtlanticToolbar';
		tblAtlanticToolbar.cellSpacing = 0;
		tblAtlanticToolbar.cellPadding = 0;
		tblAtlanticToolbar.border      = 0;
		ctlAtlanticToolbar.appendChild(tblAtlanticToolbar);
		var tbodyAtlanticToolbar = document.createElement('tbody');
		tblAtlanticToolbar.appendChild(tbodyAtlanticToolbar);
		var trAtlanticToolbar = document.createElement('tr');
		tbodyAtlanticToolbar.appendChild(trAtlanticToolbar);
		var tdAtlanticToolbar = document.createElement('td');
		trAtlanticToolbar.appendChild(tdAtlanticToolbar);
		var tdAtlanticToolbar_ctlTabMenu = document.createElement('div');
		tdAtlanticToolbar_ctlTabMenu.id = 'divTabMenu';
		tdAtlanticToolbar_ctlTabMenu.style.whiteSpace = 'nowrap';
		tdAtlanticToolbar.appendChild(tdAtlanticToolbar_ctlTabMenu);
		this.divHeader_divError = document.createElement('div');
		this.divHeader_divError.id        = 'lblError';
		this.divHeader_divError.className = 'error';
		this.divHeader_divError.style.paddingLeft = '10px';
		tdAtlanticToolbar.appendChild(this.divHeader_divError);
		if ( SplendidError.sLastError != null )
			this.divHeader_divError.innerHTML = SplendidError.sLastError;

		var tdAtlanticToolbarEnd = document.createElement('td');
		tdAtlanticToolbarEnd.className = 'AtlanticTabRow';
		tdAtlanticToolbarEnd.width     = '100%';
		trAtlanticToolbar.appendChild(tdAtlanticToolbarEnd);
		var imgAtlanticToolbarEnd = document.createElement('img');
		imgAtlanticToolbarEnd.src   = sIMAGE_SERVER + 'App_Themes/Six/images/blank.gif';
		imgAtlanticToolbarEnd.align = 'absmiddle';
		imgAtlanticToolbarEnd.style.borderWidth = '0px';
		imgAtlanticToolbarEnd.style.height      = '1px';
		imgAtlanticToolbarEnd.style.width       = '1px';
		tdAtlanticToolbarEnd.appendChild(imgAtlanticToolbarEnd);

		//				<table id="ctlAtlanticToolbar_ctlTabMenu_tblSixMenu" class="AtlanticTabToolbarFrame" cellspacing="0" cellpadding="0" border="0">
		//					<tbody>
		//						<tr>
		var ctlAtlanticToolbar_ctlTabMenu_tblSixMenu = document.createElement('table');
		ctlAtlanticToolbar_ctlTabMenu_tblSixMenu.id          = 'ctlAtlanticToolbar_ctlTabMenu_tblSixMenu';
		ctlAtlanticToolbar_ctlTabMenu_tblSixMenu.className   = 'AtlanticTabToolbarFrame';
		ctlAtlanticToolbar_ctlTabMenu_tblSixMenu.cellSpacing = 0;
		ctlAtlanticToolbar_ctlTabMenu_tblSixMenu.cellPadding = 0;
		ctlAtlanticToolbar_ctlTabMenu_tblSixMenu.border      = 0;
		tdAtlanticToolbar_ctlTabMenu.appendChild(ctlAtlanticToolbar_ctlTabMenu_tblSixMenu);
		var ctlAtlanticToolbar_ctlTabMenu_tbodySixMenu = document.createElement('tbody');
		ctlAtlanticToolbar_ctlTabMenu_tblSixMenu.appendChild(ctlAtlanticToolbar_ctlTabMenu_tbodySixMenu);
		var ctlAtlanticToolbar_ctlTabMenu_trSixMenu = document.createElement('tr');
		ctlAtlanticToolbar_ctlTabMenu_tbodySixMenu.appendChild(ctlAtlanticToolbar_ctlTabMenu_trSixMenu);

		//	<td class="AtlanticOtherHome" style="background-image: url(../Include/images/SplendidCRM_Icon.gif);">
		//		<a title="Home" onclick="Reload();"><img src="../Include/images/blank.gif" alt="SplendidCRM" style="height:42px;width:42px;border-width:0px;" /></a>
		//	</td>
		// 05/19/2013 Paul.  Apply config customizations of header logo. 
		var sCompanyHomeImage  = bgPage.SplendidCache.Config('header_home_image');
		if ( Sql.IsEmptyString(sCompanyHomeImage) )
			sCompanyHomeImage = '~/Include/images/SplendidCRM_Icon.gif';
		if ( StartsWith(sCompanyHomeImage, '~/') )
			sCompanyHomeImage = sCompanyHomeImage.substring(2, sCompanyHomeImage.length);
		
		var ctlAtlanticToolbar_ctlTabMenu_tdSixMenu = document.createElement('td');
		ctlAtlanticToolbar_ctlTabMenu_tdSixMenu.className             = 'AtlanticOtherHome';
		ctlAtlanticToolbar_ctlTabMenu_tdSixMenu.style.backgroundImage = 'url(' + sIMAGE_SERVER + sCompanyHomeImage + ')';
		ctlAtlanticToolbar_ctlTabMenu_trSixMenu.appendChild(ctlAtlanticToolbar_ctlTabMenu_tdSixMenu);
		var ctlAtlanticToolbar_ctlTabMenu_Home = document.createElement('a');
		ctlAtlanticToolbar_ctlTabMenu_Home.tile    = 'Home';
		ctlAtlanticToolbar_ctlTabMenu_Home.onclick = Reload;
		ctlAtlanticToolbar_ctlTabMenu_tdSixMenu.appendChild(ctlAtlanticToolbar_ctlTabMenu_Home);
		var ctlAtlanticToolbar_ctlTabMenu_imgHome = document.createElement('img');
		ctlAtlanticToolbar_ctlTabMenu_imgHome.src    = sIMAGE_SERVER + 'App_Themes/Six/images/blank.gif';
		ctlAtlanticToolbar_ctlTabMenu_imgHome.alt    = 'SplendidCRM';
		// 08/31/2013 Paul.  img border attribute is deprecated.  Use style instead. 
		ctlAtlanticToolbar_ctlTabMenu_imgHome.style.height      = '42px';
		ctlAtlanticToolbar_ctlTabMenu_imgHome.style.width       = '42px';
		ctlAtlanticToolbar_ctlTabMenu_imgHome.style.borderWidth = '0px' ;
		ctlAtlanticToolbar_ctlTabMenu_Home.appendChild(ctlAtlanticToolbar_ctlTabMenu_imgHome);

		var lnkUnderMenu = null;
		var imgUnderMenu = null;
		// 02/23/2013 Paul.  Use object for hash table lookup. 
		var arrValidModules = new Object();
		for ( var i = 0; i < arrDetailViewRelationship.length; i++ )
		{
			arrValidModules[arrDetailViewRelationship[i].MODULE_NAME] = null;
		}
		var sUSER_AGENT = navigator.userAgent;
		var nMaxTabs = Crm.Config.ToInteger('atlantic_max_tabs');
		if ( nMaxTabs == 0 )
			nMaxTabs = 7;
		var td = null;
		var nDisplayedTabs = 0;
		var bActiveHighlighted = false;
		var arrMoreModules = new Array();
		for ( var i = 0; i < result.length; i++ )
		{
			var sMODULE_NAME = result[i].MODULE_NAME;
			// 04/30/2017 Paul.  Apply access rights. 
			var nEDIT_ACLACCESS = (Sql.IsEmptyString(result[i].EDIT_ACLACCESS) ? 0 : Sql.ToInteger(result[i].EDIT_ACLACCESS));
			// 11/15/2012 Paul.  The Surface app does not use the TabMenu DetailView relationship. 
			// 02/23/2013 Paul.  Use object for hash table lookup. 
			if ( arrDetailViewRelationship.length == 0 || arrValidModules[sMODULE_NAME] !== undefined )
			{
				if ( (nDisplayedTabs < nMaxTabs - 1) || (nDisplayedTabs == nMaxTabs - 1 && (bActiveHighlighted || (sMODULE_NAME == sMENU_ACTIVE_MODULE))) )
				{
					if ( sMODULE_NAME == sMENU_ACTIVE_MODULE )
						bActiveHighlighted = true;
					nDisplayedTabs++;
					
					var sDISPLAY_NAME  = result[i].DISPLAY_NAME ;
					var sRELATIVE_PATH = result[i].RELATIVE_PATH;
					td = document.createElement('td');
					td.vAlign = 'bottom';
					ctlAtlanticToolbar_ctlTabMenu_trSixMenu.appendChild(td);
					//<table id="ctlAtlanticToolbar_ctlTabMenu_tabMenuInnerContacts" class="AtlanticTabToolbarFrame" cellspacing="0" cellpadding="0">
					//	<tbody>
					//		<tr>
					//			<td class="AtlanticCurrentTab" nowrap="1"><a class="AtlanticCurrentTabLink" href="./">Contacts</a></td>
					//		</tr>
					//	</tbody>
					//</table>
					var tabMenuInner = document.createElement('table');
					tabMenuInner.id          = 'ctlAtlanticToolbar_ctlTabMenu_tabMenuInner' + sMODULE_NAME;
					tabMenuInner.className   = 'AtlanticTabToolbarFrame';
					tabMenuInner.cellSpacing = 0;
					tabMenuInner.cellPadding = 0;
					td.appendChild(tabMenuInner);
					var tabMenuInner_tbody = document.createElement('tbody');
					tabMenuInner.appendChild(tabMenuInner_tbody);
					var tabMenuInner_tr = document.createElement('tr');
					tabMenuInner_tbody.appendChild(tabMenuInner_tr);
					var tabMenuInner_td = document.createElement('td');
					if ( sMENU_ACTIVE_MODULE == sMODULE_NAME )
						tabMenuInner_td.className = 'AtlanticCurrentTab';
					else
						tabMenuInner_td.className = 'AtlanticOtherTab';
					tabMenuInner_td.style.whiteSpace = 'nowrap';
					tabMenuInner_tr.appendChild(tabMenuInner_td);
					
					var tabMenuInner_a = document.createElement('a');
					if ( sMENU_ACTIVE_MODULE == sMODULE_NAME )
						tabMenuInner_a.className = 'AtlanticCurrentTabLink';
					else
						tabMenuInner_a.className = 'AtlanticOtherTabLink';
					tabMenuInner_a.innerHTML = L10n.Term(sDISPLAY_NAME);
					tabMenuInner_a.href      = '#';
					tabMenuInner_a.onclick = BindArguments(function(sMODULE_NAME)
					{
						TabMenuUI_Clicked(sLayoutPanel, sActionsPanel, sMODULE_NAME);
					}, sMODULE_NAME);
					tabMenuInner_td.appendChild(tabMenuInner_a);
					
					// 05/18/2013 Paul.  HtmlGenericControl renders as <br></br>, which Chrome treats as <br><br>. 
					tabMenuInner_td.appendChild(document.createElement('br'));
					// 05/18/2013 Paul.  Add a hyperlink under the text to provide an iPad target for the dropdown menu. 
					lnkUnderMenu = document.createElement('a');
					lnkUnderMenu.style.borderWidth = '0px';
					lnkUnderMenu.style.height      = '4px';
					lnkUnderMenu.style.width       = '100%';
					lnkUnderMenu.vAlign            = 'bottom';
					lnkUnderMenu.href              = 'javascript:void(0);';
					tabMenuInner_td.appendChild(lnkUnderMenu);
					imgUnderMenu = document.createElement('img');
					imgUnderMenu.style.height      = '4px';
					// 08/31/2013 Paul.  Use 100% instead. 
					imgUnderMenu.style.width       = '100%';
					// 08/31/2013 Paul.  img border attribute is deprecated.  Use style instead. 
					imgUnderMenu.style.borderWidth = '0px';
					imgUnderMenu.src               = sIMAGE_SERVER + 'App_Themes/Six/images/blank.gif';
					imgUnderMenu.style.borderWidth = '0px';
					lnkUnderMenu.appendChild(imgUnderMenu);
					
					//if ( sUSER_AGENT == 'WIN' || sUSER_AGENT.indexOf('Android') > 0 || sUSER_AGENT.indexOf('iPad') > 0 || sUSER_AGENT.indexOf('iPhone') > 0 || sUSER_AGENT.indexOf('Touch') > 0 || sUSER_AGENT.indexOf('MSAppHost') > 0 )
					//{
					//	ctlActiveMenu.ActionsBar(sLayoutPanel, sActionsPanel, sMODULE_NAME, sDISPLAY_NAME, ctlTabMenu, (sMENU_ACTIVE_MODULE == sMODULE_NAME));
					//}
					// 04/30/2017 Paul.  Apply access rights. 
					ctlActiveMenu.ActionsPopup(sLayoutPanel, sActionsPanel, sMODULE_NAME, sDISPLAY_NAME, tabMenuInner, td, nEDIT_ACLACCESS);
				}
				else
				{
					arrMoreModules.push(result[i]);
				}
			}
		}

		if ( arrMoreModules.length > 0 )
		{
			td = document.createElement('td');
			td.vAlign = 'bottom';
			ctlAtlanticToolbar_ctlTabMenu_trSixMenu.appendChild(td);
			//				<table id="ctlAtlanticToolbar_ctlTabMenu_tblMore" class="tabToolbarFrame" cellspacing="0" cellpadding="0">
			//					<tbody><tr>
			//						<td class="otherTab" nowrap="1">
			//							<span id="ctlAtlanticToolbar_ctlTabMenu_labTabMenuMore" class="otherTabMoreArrow" style="padding-right:6px;">More</span>
			//							<img id="ctlAtlanticToolbar_ctlTabMenu_imgTabMenuMore" src="../App_Themes/Atlantic/images/more.gif" align="absmiddle" style="border-width:0px;height:20px;width:16px;">
			//						</td>
			//					</tr></tbody>
			//				</table>
			var ctlAtlanticToolbar_ctlTabMenu_tblMore = document.createElement('table');
			ctlAtlanticToolbar_ctlTabMenu_tblMore.id          = 'ctlAtlanticToolbar_ctlTabMenu_tblMore';
			ctlAtlanticToolbar_ctlTabMenu_tblMore.className   = 'AtlanticTabToolbarFrame';
			ctlAtlanticToolbar_ctlTabMenu_tblMore.cellSpacing = 0;
			ctlAtlanticToolbar_ctlTabMenu_tblMore.cellPadding = 0;
			td.appendChild(ctlAtlanticToolbar_ctlTabMenu_tblMore);
			var ctlAtlanticToolbar_ctlTabMenu_tbodyMore = document.createElement('tbody');
			ctlAtlanticToolbar_ctlTabMenu_tblMore.appendChild(ctlAtlanticToolbar_ctlTabMenu_tbodyMore);
			var ctlAtlanticToolbar_ctlTabMenu_trMore = document.createElement('tr');
			ctlAtlanticToolbar_ctlTabMenu_tbodyMore.appendChild(ctlAtlanticToolbar_ctlTabMenu_trMore);
			var ctlAtlanticToolbar_ctlTabMenu_tdMore = document.createElement('td');
			ctlAtlanticToolbar_ctlTabMenu_tdMore.className        = 'AtlanticOtherTab';
			ctlAtlanticToolbar_ctlTabMenu_tdMore.style.whiteSpace = 'nowrap';
			ctlAtlanticToolbar_ctlTabMenu_trMore.appendChild(ctlAtlanticToolbar_ctlTabMenu_tdMore);
			
			var ctlAtlanticToolbar_ctlTabMenu_labTabMenuMore = document.createElement('a');
			ctlAtlanticToolbar_ctlTabMenu_labTabMenuMore.id                 = 'ctlAtlanticToolbar_ctlTabMenu_labTabMenuMore';
			ctlAtlanticToolbar_ctlTabMenu_labTabMenuMore.className          = 'AtlanticOtherTabLink';
			ctlAtlanticToolbar_ctlTabMenu_labTabMenuMore.style.paddingRight = '6px';
			ctlAtlanticToolbar_ctlTabMenu_labTabMenuMore.innerHTML          = L10n.Term('.LBL_MORE');
			ctlAtlanticToolbar_ctlTabMenu_labTabMenuMore.href               = '#';
			ctlAtlanticToolbar_ctlTabMenu_tdMore.appendChild(ctlAtlanticToolbar_ctlTabMenu_labTabMenuMore);
			var ctlAtlanticToolbar_ctlTabMenu_imgTabMenuMore = document.createElement('img');
			ctlAtlanticToolbar_ctlTabMenu_imgTabMenuMore.id                = 'ctlAtlanticToolbar_ctlTabMenu_imgTabMenuMore';
			ctlAtlanticToolbar_ctlTabMenu_imgTabMenuMore.src               = sIMAGE_SERVER + 'App_Themes/Atlantic/images/more.gif';
			ctlAtlanticToolbar_ctlTabMenu_imgTabMenuMore.align             = 'absmiddle';
			ctlAtlanticToolbar_ctlTabMenu_imgTabMenuMore.style.borderWidth = '0px';
			ctlAtlanticToolbar_ctlTabMenu_imgTabMenuMore.style.height      = '20px';
			ctlAtlanticToolbar_ctlTabMenu_imgTabMenuMore.style.width       = '16px';
			ctlAtlanticToolbar_ctlTabMenu_tdMore.appendChild(ctlAtlanticToolbar_ctlTabMenu_imgTabMenuMore);
			
			// 05/18/2013 Paul.  HtmlGenericControl renders as <br></br>, which Chrome treats as <br><br>. 
			ctlAtlanticToolbar_ctlTabMenu_tdMore.appendChild(document.createElement('br'));
			// 05/18/2013 Paul.  Add a hyperlink under the text to provide an iPad target for the dropdown menu. 
			lnkUnderMenu = document.createElement('a');
			lnkUnderMenu.style.borderWidth = '0px';
			lnkUnderMenu.style.height      = '4px';
			lnkUnderMenu.style.width       = '100%';
			lnkUnderMenu.vAlign            = 'bottom';
			lnkUnderMenu.href              = 'javascript:void(0);';
			ctlAtlanticToolbar_ctlTabMenu_tdMore.appendChild(lnkUnderMenu);
			imgUnderMenu = document.createElement('img');
			imgUnderMenu.src               = sIMAGE_SERVER + 'App_Themes/Six/images/blank.gif';
			imgUnderMenu.style.height      = '4px';
			// 08/31/2013 Paul.  Use 100%. 
			imgUnderMenu.style.width       = '100%';
			imgUnderMenu.style.borderWidth = '0px';
			lnkUnderMenu.appendChild(imgUnderMenu);
			
			//<div id="ctl00_pnlModuleActionsMore" class="PanelHoverHidden" style="position: absolute; visibility: hidden; left: 454px; top: 47px; z-index: 1000; display: none;">
			//	<table cellpadding="0" cellspacing="0" class="ModuleActionsInnerTable">
			//		<tbody><tr>
			//			<td class="ModuleActionsInnerCell">
			//				<span class="ModuleActionsInnerHeader" style="font-weight:bold;">Actions</span>
			//				<a class="ModuleActionsMenuItems" href="../Calls/edit.aspx">Create Call</a>
			//				<a class="ModuleActionsMenuItems" href="../Meetings/edit.aspx">Create Meeting</a>
			//				<a class="ModuleActionsMenuItems" href="../Tasks/edit.aspx">Create Task</a>
			//				<a class="ModuleActionsMenuItems" href="../Calls/default.aspx">Calls</a>
			//				<a class="ModuleActionsMenuItems" href="../Meetings/default.aspx">Meetings</a>
			//				<a class="ModuleActionsMenuItems" href="../Tasks/default.aspx">Tasks</a>
			//			</td>
			//		</tr></tbody>
			//	</table>
			//</div>
			var pnlModuleActions = document.createElement('div');
			pnlModuleActions.id             = 'pnlModuleActionsMore';
			pnlModuleActions.className      = 'AtlanticPanelHoverHidden';
			pnlModuleActions.style.position = 'absolute';
			pnlModuleActions.style.zIndex   = 1000;
			td.appendChild(pnlModuleActions);

			// Actions Inner Table
			var tblModuleActionsInner = document.createElement('table');
			tblModuleActionsInner.cellPadding = 0;
			tblModuleActionsInner.cellSpacing = 0;
			tblModuleActionsInner.className   = 'AtlanticModuleActionsInnerTable';
			pnlModuleActions.appendChild(tblModuleActionsInner);
			var tbodyModuleActionsInner = document.createElement('tbody');
			tblModuleActionsInner.appendChild(tbodyModuleActionsInner);

			var trModuleActionsInner = document.createElement('tr');
			tbodyModuleActionsInner.appendChild(trModuleActionsInner);
			var tdModuleActionsInner = document.createElement('td');
			tdModuleActionsInner.className = 'AtlanticModuleActionsInnerCell';
			trModuleActionsInner.appendChild(tdModuleActionsInner);

			for ( var i in arrMoreModules )
			{
				var sMODULE_NAME  = arrMoreModules[i].MODULE_NAME;
				var sDISPLAY_NAME = arrMoreModules[i].DISPLAY_NAME;
				var aList = document.createElement('a');
				aList.className = 'AtlanticModuleActionsMenuItems';
				aList.href      = '#';
				aList.innerHTML = L10n.Term(sDISPLAY_NAME);
				// 10/27/2012 Paul.  Link was not working.  Change to use binding. 
				aList.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME, pnlModuleActions)
				{
					pnlModuleActions.style.display    = 'none';
					pnlModuleActions.style.visibility = 'hidden';
					TabMenuUI_Clicked(sLayoutPanel, sActionsPanel, sMODULE_NAME);
				}, sLayoutPanel, sActionsPanel, sMODULE_NAME, pnlModuleActions);
				tdModuleActionsInner.appendChild(aList);
			}

			TabMenuUI_PopupManagement(pnlModuleActions, ctlAtlanticToolbar_ctlTabMenu_tblMore);
		}

		//<table cellspacing="0" cellpadding="0" border="0" class="AtlanticToolbarUser">
		//	<tbody>
		//		<tr>
		//			<td valign="bottom" style="border-left: 1px solid #003564">
		//			</td>
		//		</tr>
		//	</tbody>
		//</table>
		td = document.createElement('td');
		td.vAlign = 'top';
		trAtlanticToolbar.appendChild(td);
		var tblAtlanticToolbarUser = document.createElement('table');
		tblAtlanticToolbarUser.className   = 'AtlanticToolbarUser';
		tblAtlanticToolbarUser.cellSpacing = 0;
		tblAtlanticToolbarUser.cellPadding = 0;
		tblAtlanticToolbarUser.border      = 0;
		td.appendChild(tblAtlanticToolbarUser);
		var tbodyAtlanticToolbarUser = document.createElement('tbody');
		tblAtlanticToolbarUser.appendChild(tbodyAtlanticToolbarUser);
		var trAtlanticToolbarUser = document.createElement('tr');
		tbodyAtlanticToolbarUser.appendChild(trAtlanticToolbarUser);
		var tdAtlanticToolbarUser = document.createElement('td');
		tdAtlanticToolbarUser.vAlign           = 'bottom';
		tdAtlanticToolbarUser.style.borderLeft = '1px solid #003564';
		trAtlanticToolbarUser.appendChild(tdAtlanticToolbarUser);

		// User Menu
		//				<table id="ctlAtlanticToolbar_tabToolbarUser" class="AtlanticTabToolbarFrame" cellspacing="0" cellpadding="0" height="100%">
		//					<tbody>
		//						<tr>
		//							<td class="AtlanticOtherUser" nowrap="nowrap">
		//								<span class="AtlanticOtherTabLink" style="padding-right:6px;">Paul Rony</span>
		//								<img class="AtlanticOtherTabMoreArrow" src="../App_Themes/Atlantic/images/more.gif" align="absmiddle" style="border-width:0px;height:20px;width:16px;">
		//							</td>
		//						</tr>
		//					</tbody>
		//				</table>
		var ctlAtlanticToolbar_tblToolbarUser = document.createElement('table');
		ctlAtlanticToolbar_tblToolbarUser.id          = 'ctlAtlanticToolbar_tblToolbarUser';
		ctlAtlanticToolbar_tblToolbarUser.className   = 'AtlanticTabToolbarFrame';
		ctlAtlanticToolbar_tblToolbarUser.cellSpacing = 0;
		ctlAtlanticToolbar_tblToolbarUser.cellPadding = 0;
		ctlAtlanticToolbar_tblToolbarUser.height      = '100%';
		tdAtlanticToolbarUser.appendChild(ctlAtlanticToolbar_tblToolbarUser);
		var ctlAtlanticToolbar_tbodyToolbarUser = document.createElement('tbody');
		ctlAtlanticToolbar_tblToolbarUser.appendChild(ctlAtlanticToolbar_tbodyToolbarUser);
		var ctlAtlanticToolbar_trToolbarUser = document.createElement('tr');
		ctlAtlanticToolbar_tbodyToolbarUser.appendChild(ctlAtlanticToolbar_trToolbarUser);
		var ctlAtlanticToolbar_tdToolbarUser = document.createElement('td');
		ctlAtlanticToolbar_tdToolbarUser.className        = 'AtlanticOtherUser';
		ctlAtlanticToolbar_tdToolbarUser.style.whiteSpace = 'nowrap';
		ctlAtlanticToolbar_tdToolbarUser.vAlign           = 'top';
		ctlAtlanticToolbar_trToolbarUser.appendChild(ctlAtlanticToolbar_tdToolbarUser);

		this.divHeader_divAuthenticated = document.createElement('div');
		this.divHeader_divAuthenticated.id               = 'divHeader_divAuthenticated';
		this.divHeader_divAuthenticated.style.display    = 'inline';
		this.divHeader_divAuthenticated.style.whiteSpace = 'nowrap';
		ctlAtlanticToolbar_tdToolbarUser.appendChild(this.divHeader_divAuthenticated);
		this.divHeader_spnUserName = document.createElement('span');
		this.divHeader_spnUserName.id                    = 'divHeader_spnUserName';
		this.divHeader_spnUserName.style.fontWeight      = 'bold';
		this.divHeader_spnUserName.className             = 'AtlanticOtherTabLink';
		this.divHeader_spnUserName.style.paddingRight    = '6px';
		this.divHeader_spnUserName.innerHTML             = Security.FULL_NAME();
		this.divHeader_divAuthenticated.appendChild(this.divHeader_spnUserName);
		var ctlAtlanticToolbar_imgToolbarUser = document.createElement('img');
		ctlAtlanticToolbar_imgToolbarUser.className         = 'AtlanticOtherTabMoreArrow';
		ctlAtlanticToolbar_imgToolbarUser.src               = sIMAGE_SERVER + 'App_Themes/Atlantic/images/more.gif';
		ctlAtlanticToolbar_imgToolbarUser.align             = 'absmiddle';
		ctlAtlanticToolbar_imgToolbarUser.style.borderWidth = '0px';
		ctlAtlanticToolbar_imgToolbarUser.style.height      = '20px';
		ctlAtlanticToolbar_imgToolbarUser.style.width       = '16px';
		this.divHeader_divAuthenticated.appendChild(ctlAtlanticToolbar_imgToolbarUser);
		
		this.divHeader_divOnlineStatus = document.createElement('div');
		this.divHeader_divOnlineStatus.id = 'divHeader_divOnlineStatus';
		ctlAtlanticToolbar_tdToolbarUser.appendChild(this.divHeader_divOnlineStatus);
		this.divHeader_divOnlineStatus.innerHTML = bgPage.GetIsOffline() ? L10n.Term('.LBL_OFFLINE') : L10n.Term('.LBL_ONLINE');
		
		// User Menu Hover
		//<div id="ctlAtlanticToolbar_pnlToolbarUserHover" class="PanelHoverHidden" style="position: absolute; visibility: hidden; left: 454px; top: 47px; z-index: 1000; display: none;">
		//	<table cellpadding="0" cellspacing="0" class="ModuleActionsInnerTable">
		//		<tbody>
		//			<tr>
		//				<td class="ModuleActionsInnerCell">
		//					<a id="ctlAtlanticToolbar_lnkMyAccount" class="AtlanticModuleActionsMenuItems" href="../Users/MyAccount.aspx">My Account</a>
		//					<a id="ctlAtlanticToolbar_lnkEmployees" class="AtlanticModuleActionsMenuItems" href="../Employees/default.aspx">Employees</a>
		//					<a id="ctlAtlanticToolbar_lnkAdmin"     class="AtlanticModuleActionsMenuItems" href="../Administration/default.aspx">Admin</a>
		//					<a id="ctlAtlanticToolbar_lnkTraining"  class="AtlanticModuleActionsMenuItems" href="../Home/TrainingPortal.aspx">Training</a>
		//					<a id="ctlAtlanticToolbar_lnkAbout"     class="AtlanticModuleActionsMenuItems" href="../Home/About.aspx">About</a>
		//					<a id="ctlAtlanticToolbar_lnkReload"    class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkReload", "", true, "", "", false, true))'>( Reload )</a>
		//				</td>
		//			</tr>
		//		</tbody>
		//	</table>
		//</div>
		if ( arrUserContextMenu != null )
		{
			var pnlToolbarUserHover = document.createElement('div');
			pnlToolbarUserHover.id             = 'ctlAtlanticToolbar_pnlToolbarUserHover';
			pnlToolbarUserHover.className      = 'AtlanticPanelHoverHidden';
			pnlToolbarUserHover.style.position = 'absolute';
			pnlToolbarUserHover.style.zIndex   = 1000;
			td.appendChild(pnlToolbarUserHover);

			// Actions Inner Table
			var ctlAtlanticToolbar_pnlToolbarUserInner = document.createElement('table');
			ctlAtlanticToolbar_pnlToolbarUserInner.cellPadding = 0;
			ctlAtlanticToolbar_pnlToolbarUserInner.cellSpacing = 0;
			ctlAtlanticToolbar_pnlToolbarUserInner.className   = 'AtlanticModuleActionsInnerTable';
			pnlToolbarUserHover.appendChild(ctlAtlanticToolbar_pnlToolbarUserInner);
			var ctlAtlanticToolbar_tbodyToolbarUserInner = document.createElement('tbody');
			ctlAtlanticToolbar_pnlToolbarUserInner.appendChild(ctlAtlanticToolbar_tbodyToolbarUserInner);

			var ctlAtlanticToolbar_trToolbarUserInner = document.createElement('tr');
			ctlAtlanticToolbar_tbodyToolbarUserInner.appendChild(ctlAtlanticToolbar_trToolbarUserInner);
			var ctlAtlanticToolbar_tdToolbarUserInner = document.createElement('td');
			ctlAtlanticToolbar_tdToolbarUserInner.className = 'AtlanticModuleActionsInnerCell';
			ctlAtlanticToolbar_trToolbarUserInner.appendChild(ctlAtlanticToolbar_tdToolbarUserInner);
			
			for ( var i = 0; i < arrUserContextMenu.length; i++ )
			{
				var a = document.createElement('a');
				a.id        = arrUserContextMenu[i].id;
				a.href      = '#';
				a.className = 'AtlanticModuleActionsMenuItems';
				a.appendChild(document.createTextNode(L10n.Term(arrUserContextMenu[i].text)));
				if ( arrUserContextMenu[i].action != null )
				{
					a.onclick = BindArguments(function(action)
					{
						pnlToolbarUserHover.style.display    = 'none';
						pnlToolbarUserHover.style.visibility = 'hidden';
						action();
					}, arrUserContextMenu[i].action);
				}
				ctlAtlanticToolbar_tdToolbarUserInner.appendChild(a);
			}
			this.lnkHeaderSystemLog       = document.getElementById('lnkHeaderSystemLog'      );
			this.lnkHeaderSplendidStorage = document.getElementById('lnkHeaderSplendidStorage');
			this.lnkHeaderCacheAll        = document.getElementById('lnkHeaderCacheAll'       );
			this.divHeader_lnkLogout      = document.getElementById('divHeader_lnkLogout'     );
			if ( this.divHeader_lnkLogout != null )
			{
				this.divHeader_lnkLogout.style.display = (bWINDOWS_AUTH ? 'none' : 'block');
				this.divHeader_lnkLogout.onclick = function()
				{
					LoginViewUI_PageCommand(sLayoutPanel, sActionsPanel, 'Logout', null, null);
				};
			}
			// 08/22/2014 Paul.  Add SyncNow for offline client. 
			this.divHeader_lnkSyncNow    = document.getElementById('divHeader_lnkSyncNow'    );
			if ( this.divHeader_lnkSyncNow != null )
			{
				// 12/01/2014 Paul.  We need to distinguish between Offline Client and Mobile Client. 
				this.divHeader_lnkSyncNow.style.display = (bREMOTE_ENABLED && !bMOBILE_CLIENT ? 'block' : 'none');
				this.divHeader_lnkSyncNow.innerHTML     = (bREMOTE_ENABLED && !bMOBILE_CLIENT ? L10n.Term('Offline.LNK_OFFLINE_DASHBOARD' ) : '');
				this.divHeader_lnkSyncNow.onclick = function()
				{
					ShowOfflineDashboard();
				};
			}

			TabMenuUI_PopupManagement(pnlToolbarUserHover, ctlAtlanticToolbar_tblToolbarUser);
		}
		/*
		// QuickCreate
		//<td valign="bottom" style="border-left: 1px solid #003564" width="32">
		//	<table id="ctlAtlanticToolbar_tabToolbarQuickCreate" class="AtlanticTabToolbarFrame" cellspacing="0" cellpadding="0" height="100%">
		//		<tbody>
		//			<tr>
		//				<td class="AtlanticOtherQuickCreate">
		//					<img class="AtlanticOtherTabMoreArrow" src="../App_Themes/Atlantic/images/ToolbarQuickCreate.gif" align="absmiddle" style="border-width:0px;height:20px;width:32px;">
		//				</td>
		//			</tr>
		//		</tbody>
		//	</table>
		//</td>
		var tdAtlanticToolbarQuickCreate = document.createElement('td');
		tdAtlanticToolbarQuickCreate.width            = '32px';
		tdAtlanticToolbarQuickCreate.vAlign           = 'bottom';
		tdAtlanticToolbarQuickCreate.style.borderLeft = '1px solid #003564';
		tdAtlanticToolbarQuickCreate.appendChild(tdAtlanticToolbarQuickCreate);
		var ctlAtlanticToolbar_tblToolbarQuickCreate = document.createElement('table');
		ctlAtlanticToolbar_tblToolbarQuickCreate.id          = 'ctlAtlanticToolbar_tblToolbarQuickCreate';
		ctlAtlanticToolbar_tblToolbarQuickCreate.className   = 'AtlanticTabToolbarFrame';
		ctlAtlanticToolbar_tblToolbarQuickCreate.cellSpacing = 0;
		ctlAtlanticToolbar_tblToolbarQuickCreate.cellPadding = 0;
		ctlAtlanticToolbar_tblToolbarQuickCreate.height      = '100%';
		tdAtlanticToolbarQuickCreate.appendChild(ctlAtlanticToolbar_tblToolbarQuickCreate);
		var ctlAtlanticToolbar_tbodyToolbarQuickCreate = document.createElement('tbody');
		ctlAtlanticToolbar_tblToolbarQuickCreate.appendChild(ctlAtlanticToolbar_tbodyToolbarQuickCreate);
		var ctlAtlanticToolbar_trToolbarQuickCreate = document.createElement('tr');
		ctlAtlanticToolbar_tbodyToolbarQuickCreate.appendChild(ctlAtlanticToolbar_trToolbarQuickCreate);
		var ctlAtlanticToolbar_tdToolbarQuickCreate = document.createElement('td');
		ctlAtlanticToolbar_tdToolbarQuickCreate.className = 'AtlanticOtherQuickCreate';
		ctlAtlanticToolbar_trToolbarQuickCreate.appendChild(ctlAtlanticToolbar_tdToolbarQuickCreate);
		var ctlAtlanticToolbar_imgToolbarQuickCreate = document.createElement('img');
		ctlAtlanticToolbar_imgToolbarQuickCreate.className         = 'AtlanticOtherTabMoreArrow';
		ctlAtlanticToolbar_imgToolbarQuickCreate.src               = '../App_Themes/Atlantic/images/ToolbarQuickCreate.gif';
		ctlAtlanticToolbar_imgToolbarQuickCreate.style.borderWidth = '0px';
		ctlAtlanticToolbar_imgToolbarQuickCreate.style.height      = '20px';
		ctlAtlanticToolbar_imgToolbarQuickCreate.style.width       = '32px';
		ctlAtlanticToolbar_imgToolbarQuickCreate.align             = 'absmiddle';
		ctlAtlanticToolbar_tdToolbarQuickCreate.appendChild(ctlAtlanticToolbar_imgToolbarQuickCreate);

		// QuickCreate Hover
		//	<div id="ctlAtlanticToolbar_pnlToolbarQuickCreateHover" style="position: absolute; visibility: hidden; left: -45px; top: 45px; z-index: 1000; display: none;">
		//		<table cellpadding="0" cellspacing="0" class="AtlanticMoreActionsInnerTable">
		//			<tbody>
		//				<tr>
		//					<td class="AtlanticMoreActionsInnerCell">
		//						<a id="ctlAtlanticToolbar_lnkQuickCreateAccounts"      title="Accounts"      class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkQuickCreateAccounts", "", true, "", "", false, true))'>Create Account</a>
		//						<a id="ctlAtlanticToolbar_lnkQuickCreateContacts"      title="Contacts"      class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkQuickCreateContacts", "", true, "", "", false, true))'>Create Contact</a>
		//						<a id="ctlAtlanticToolbar_lnkQuickCreateOpportunities" title="Opportunities" class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkQuickCreateOpportunities", "", true, "", "", false, true))'>Create Opportunity</a>
		//						<a id="ctlAtlanticToolbar_lnkQuickCreateLeads"         title="Leads"         class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkQuickCreateLeads", "", true, "", "", false, true))'>Create Lead</a>
		//						<a id="ctlAtlanticToolbar_lnkQuickCreateCases"         title="Cases"         class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkQuickCreateCases", "", true, "", "", false, true))'>Create Case</a>
		//						<a id="ctlAtlanticToolbar_lnkQuickCreateBugs"          title="Bug Tracker"   class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkQuickCreateBugs", "", true, "", "", false, true))'>Create Bug</a>
		//						<a id="ctlAtlanticToolbar_lnkQuickCreateEmails"        title="Emails"        class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkQuickCreateEmails", "", true, "", "", false, true))'>Archive Email</a>
		//						<a id="ctlAtlanticToolbar_lnkQuickCreateNotes"         title="Notes"         class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkQuickCreateNotes", "", true, "", "", false, true))'>Create Note</a>
		//						<a id="ctlAtlanticToolbar_lnkQuickCreateTasks"         title="Tasks"         class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkQuickCreateTasks", "", true, "", "", false, true))'>Create Task</a>
		//						<a id="ctlAtlanticToolbar_lnkQuickCreateMeetings"      title="Meetings"      class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkQuickCreateMeetings", "", true, "", "", false, true))'>Create Meeting</a>
		//						<a id="ctlAtlanticToolbar_lnkQuickCreateCalls"         title="Calls"         class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkQuickCreateCalls", "", true, "", "", false, true))'>Create Call</a>
		//						<a id="ctlAtlanticToolbar_lnkQuickCreateProject"       title="Projects"      class="AtlanticModuleActionsMenuItems" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ctlSixToolbar$lnkQuickCreateProject", "", true, "", "", false, true))'>Create Project</a>
		//						<input type="hidden" name="ctl00$ctlSixToolbar$hidDynamicNewRecord" id="ctlAtlanticToolbar_hidDynamicNewRecord">
		//					</td>
		//				</tr>
		//			</tbody>
		//		</table>
		//	</div>
		var ctlAtlanticToolbar_pnlToolbarQuickCreateHover = document.createElement('div');
		ctlAtlanticToolbar_pnlToolbarQuickCreateHover.id = 'ctlAtlanticToolbar_pnlToolbarQuickCreateHover';
		ctlAtlanticToolbar_pnlToolbarQuickCreateHover.style.dsipolay   = 'none';
		ctlAtlanticToolbar_pnlToolbarQuickCreateHover.style.position   = 'absolute';
		ctlAtlanticToolbar_pnlToolbarQuickCreateHover.style.visibility = 'hidden';
		ctlAtlanticToolbar_pnlToolbarQuickCreateHover.style.left       = '-45px';
		ctlAtlanticToolbar_pnlToolbarQuickCreateHover.style.top        = '45px';
		ctlAtlanticToolbar_pnlToolbarQuickCreateHover.style.zIndex     = '1000';
		tdAtlanticToolbarQuickCreate.appendChild(ctlAtlanticToolbar_pnlToolbarQuickCreateHover);

		var ctlAtlanticToolbar_tblToolbarQuickCreateHover = document.createElement('table');
		ctlAtlanticToolbar_tblToolbarQuickCreateHover.className   = 'AtlanticMoreActionsInnerTable';
		ctlAtlanticToolbar_tblToolbarQuickCreateHover.cellPadding = 0;
		ctlAtlanticToolbar_tblToolbarQuickCreateHover.cellSpacing = 0;
		ctlAtlanticToolbar_pnlToolbarQuickCreateHover.appendChild(ctlAtlanticToolbar_tblToolbarQuickCreateHover);
		var ctlAtlanticToolbar_tbodyToolbarQuickCreateHover = document.createElement('tbody');
		ctlAtlanticToolbar_tbodyToolbarQuickCreateHover.id = 'ctlAtlanticToolbar_tbodyToolbarQuickCreateHover';
		ctlAtlanticToolbar_tblToolbarQuickCreateHover.appendChild(ctlAtlanticToolbar_tbodyToolbarQuickCreateHover);
		var ctlAtlanticToolbar_trToolbarQuickCreateHover = document.createElement('tr');
		ctlAtlanticToolbar_tbodyToolbarQuickCreateHover.appendChild(ctlAtlanticToolbar_trToolbarQuickCreateHover);
		var ctlAtlanticToolbar_tdToolbarQuickCreateHover = document.createElement('td');
		ctlAtlanticToolbar_tdToolbarQuickCreateHover.className = 'AtlanticMoreActionsInnerCell';
		ctlAtlanticToolbar_trToolbarQuickCreateHover.appendChild(ctlAtlanticToolbar_tdToolbarQuickCreateHover);
		for ( var sModule in arrQuickCreate )
		{
			var a = document.createElement('a');
			a.id        = 'ctlAtlanticToolbar_lnkQuickCreate' + sModule;
			a.title     = sModule;
			a.className = 'AtlanticModuleActionsMenuItems';
			a.innerHTML = sModule;
			a.onclick = function()
			{
				alert(sModule);
			};
			ctlAtlanticToolbar_tdToolbarQuickCreateHover.appendChild(a);
		}

		// <div style="height: 43px; width: 100%"></div>
		var divFinalSpacer = document.createElement('div');
		divFinalSpacer.style.height = '43px';
		divFinalSpacer.style.width  = '100%';
		ctlAtlanticToolbar.appendChild(divFinalSpacer);
		*/
		this.divHeader_divOfflineCache = document.createElement('div');
		this.divHeader_divOfflineCache.id                  = 'divHeader_divOfflineCache';
		this.divHeader_divOfflineCache.className           = 'error';
		this.divHeader_divOfflineCache.style.verticalAlign = 'top';
		this.divHeader_divOfflineCache.style.height        = '60px';
		this.divHeader_divOfflineCache.style.width         = '100%';
		this.divHeader_divOfflineCache.style.overflowY     = 'scroll';
		this.divHeader_divOfflineCache.style.display       = 'none';
		ctlAtlanticToolbar.appendChild(this.divHeader_divOfflineCache);
	}
}

// 04/30/2017 Paul.  Apply access rights. 
TabMenuUI_Atlantic.prototype.ActionsPopup = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sDISPLAY_NAME, ctlTabMenu_tabMenuInner, tdMenuInner, nEDIT_ACLACCESS)
{
	try
	{
		//<div id="ctl00_pnlModuleActionsCalendar" class="PanelHoverHidden" style="position: absolute; visibility: hidden; left: 454px; top: 47px; z-index: 1000; display: none;">
		//	<table cellpadding="0" cellspacing="0" class="ModuleActionsInnerTable">
		//		<tbody><tr>
		//			<td class="ModuleActionsInnerCell">
		//				<span class="ModuleActionsInnerHeader" style="font-weight:bold;">Actions</span>
		//				<a class="ModuleActionsMenuItems" href="../Calls/edit.aspx">Create Call</a>
		//				<a class="ModuleActionsMenuItems" href="../Meetings/edit.aspx">Create Meeting</a>
		//				<a class="ModuleActionsMenuItems" href="../Tasks/edit.aspx">Create Task</a>
		//				<a class="ModuleActionsMenuItems" href="../Calls/default.aspx">Calls</a>
		//				<a class="ModuleActionsMenuItems" href="../Meetings/default.aspx">Meetings</a>
		//				<a class="ModuleActionsMenuItems" href="../Tasks/default.aspx">Tasks</a>
		//			</td>
		//			<td class="ModuleActionsInnerCell"><span class="ModuleActionsInnerHeader" style="font-weight:bold;">Favorites</span><span>None</span></td>
		//			<td class="ModuleActionsInnerCell"><span class="ModuleActionsInnerHeader" style="font-weight:bold;">Last Viewed</span><span>None</span></td>
		//		</tr></tbody>
		//	</table>
		//</div>
		var pnlModuleActions = document.createElement('div');
		pnlModuleActions.id             = 'pnlModuleActions' + sMODULE_NAME;
		pnlModuleActions.className      = 'AtlanticPanelHoverHidden';
		pnlModuleActions.style.position = 'absolute';
		pnlModuleActions.style.zIndex   = 1000;
		tdMenuInner.appendChild(pnlModuleActions);

		// Actions Inner Table
		var tblModuleActionsInner = document.createElement('table');
		tblModuleActionsInner.cellPadding = 0;
		tblModuleActionsInner.cellSpacing = 0;
		tblModuleActionsInner.className   = 'AtlanticModuleActionsInnerTable';
		pnlModuleActions.appendChild(tblModuleActionsInner);
		var tbodyModuleActionsInner = document.createElement('tbody');
		tblModuleActionsInner.appendChild(tbodyModuleActionsInner);

		var trModuleActionsInner = document.createElement('tr');
		tbodyModuleActionsInner.appendChild(trModuleActionsInner);
		var tdModuleActionsInner = document.createElement('td');
		tdModuleActionsInner.className = 'AtlanticModuleActionsInnerCell';
		trModuleActionsInner.appendChild(tdModuleActionsInner);

		var spnActions = document.createElement('span');
		spnActions.className        = 'AtlanticModuleActionsInnerHeader';
		spnActions.style.fontWeight = 'bold';
		spnActions.innerHTML        = L10n.Term('.LBL_ACTIONS');
		tdModuleActionsInner.appendChild(spnActions);
		
		// 02/24/2013 Paul.  For a calendar, create a call or a meeting. 
		if ( sMODULE_NAME == 'Calendar' )
		{
			// 04/30/2017 Paul.  Apply access rights. 
			if ( nEDIT_ACLACCESS >= 0 )
			{
				// 01/10/2018 Paul.  Make sure Call or Meeting module is enabled. 
				var bgPage = chrome.extension.getBackgroundPage();
				if ( bgPage.SplendidCache.Module('Calls') !== undefined )
				{
					var aCreateCall = document.createElement('a');
					aCreateCall.className = 'AtlanticModuleActionsMenuItems';
					aCreateCall.href = '#';
					aCreateCall.innerHTML = L10n.Term(sMODULE_NAME + '.LNK_NEW_CALL');
					aCreateCall.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE, pnlModuleActions)
					{
						pnlModuleActions.style.display    = 'none';
						pnlModuleActions.style.visibility = 'hidden';
						var oEditViewUI = new EditViewUI();
						oEditViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE);
					}, sLayoutPanel, sActionsPanel, 'Calls', null, false, pnlModuleActions);
					tdModuleActionsInner.appendChild(aCreateCall);
				}
				// 01/10/2018 Paul.  Make sure Call or Meeting module is enabled. 
				if ( bgPage.SplendidCache.Module('Meetings') !== undefined )
				{
					var aCreateMeeting = document.createElement('a');
					aCreateMeeting.className = 'AtlanticModuleActionsMenuItems';
					aCreateMeeting.href      = '#';
					aCreateMeeting.innerHTML = L10n.Term(sMODULE_NAME + '.LNK_NEW_MEETING');
					aCreateMeeting.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE, pnlModuleActions)
					{
						pnlModuleActions.style.display    = 'none';
						pnlModuleActions.style.visibility = 'hidden';
						var oEditViewUI = new EditViewUI();
						oEditViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE);
					}, sLayoutPanel, sActionsPanel, 'Meetings', null, false, pnlModuleActions);
					tdModuleActionsInner.appendChild(aCreateMeeting);
				}
			}
		}
		else
		{
			// 04/30/2017 Paul.  Apply access rights. 
			if ( nEDIT_ACLACCESS >= 0 )
			{
				var aCreate = document.createElement('a');
				aCreate.className = 'AtlanticModuleActionsMenuItems';
				aCreate.href = '#';
				aCreate.innerHTML = L10n.Term(sMODULE_NAME + '.LBL_NEW_FORM_TITLE');
				aCreate.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE, pnlModuleActions)
				{
					pnlModuleActions.style.display    = 'none';
					pnlModuleActions.style.visibility = 'hidden';
					var oEditViewUI = new EditViewUI();
					oEditViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE);
				}, sLayoutPanel, sActionsPanel, sMODULE_NAME, null, false, pnlModuleActions);
				tdModuleActionsInner.appendChild(aCreate);
			}

			var aList = document.createElement('a');
			aList.className = 'AtlanticModuleActionsMenuItems';
			aList.href      = '#';
			aList.innerHTML = L10n.Term(sDISPLAY_NAME);
			// 10/27/2012 Paul.  Link was not working.  Change to use binding. 
			aList.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME, pnlModuleActions)
			{
				pnlModuleActions.style.display    = 'none';
				pnlModuleActions.style.visibility = 'hidden';
				TabMenuUI_Clicked(sLayoutPanel, sActionsPanel, sMODULE_NAME);
			}, sLayoutPanel, sActionsPanel, sMODULE_NAME, pnlModuleActions);
			tdModuleActionsInner.appendChild(aList);
		}
		TabMenuUI_PopupManagement(pnlModuleActions, ctlTabMenu_tabMenuInner);
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'TabMenuUI_Atlantic.ActionsPopup ' + sMODULE_NAME);
	}
}

TabMenuUI_Atlantic.prototype.Load = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, callback)
{
	try
	{
		sMENU_ACTIVE_MODULE = sMODULE_NAME;
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.Terminology_LoadModule(sMODULE_NAME, function(status, message)
		{
			if ( status == 0 || status == 1 )
			{
				// 12/06/2014 Paul.  The TabMenu is not based on the platform layout. 
				var sDETAIL_NAME = 'TabMenu';
				if ( bADMIN_MENU )
					sDETAIL_NAME = 'TabMenu.Admin';
				bgPage.DetailViewRelationships_LoadLayout(sDETAIL_NAME, function(status, message)
				{
					sDETAIL_NAME += sPLATFORM_LAYOUT;
					if ( status == 0 || status == 1 )
					{
						// 10/03/2011 Paul.  DetailViewRelationships_LoadLayout returns the layout. 
						var arrDetailViewRelationship = message;
						bgPage.TabMenu_Load(function(status, message)
						{
							if ( status == 0 || status == 1 )
							{
								//alert(dumpObj(message, 'd'));
								try
								{
									var result = message;
									// 12/05/2012 Paul.  arrDetailViewRelationship is just a filter, it is not the actual menu. 
									// For the admin menu, we are going to convert this filter to the real menu. 
									if ( bADMIN_MENU )
									{
										result = arrDetailViewRelationship;
										for ( var i = 0; i < result.length; i++ )
										{
											result[i].DISPLAY_NAME  = '.moduleList.' + result[i].MODULE_NAME;
											result[i].RELATIVE_PATH = '~/' + result[i].MODULE_NAME + '/';
										}
									}
									//alert(dumpObj(result, 'result'));
									TabMenuUI_Clear('ctlAtlanticToolbar');
									
									ctlActiveMenu.Render(sLayoutPanel, sActionsPanel, arrDetailViewRelationship, arrQuickCreate, result);
									callback(1, null);
								}
								catch(e)
								{
									callback(-1, SplendidError.FormatError(e, 'TabMenuUI_Atlantic.Load'));
								}
							}
							else
							{
								callback(status, message);
							}
						});
					}
					else
					{
						callback(status, message);
					}
				});
			}
			else
			{
				SplendidError.SystemMessage(message);
			}
		});
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'TabMenuUI_Atlantic.Load'));
	}
}

