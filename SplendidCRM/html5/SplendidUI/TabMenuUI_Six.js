/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function TabMenuUI_Six(sLayoutPanel, sActionsPanel)
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

TabMenuUI_Six.prototype.divError           = function() { return this.divHeader_divError          ; }
TabMenuUI_Six.prototype.divAuthenticated   = function() { return this.divHeader_divAuthenticated  ; }
TabMenuUI_Six.prototype.spnWelcome         = function() { return this.divHeader_spnWelcome        ; }
TabMenuUI_Six.prototype.spnUserName        = function() { return this.divHeader_spnUserName       ; }
TabMenuUI_Six.prototype.spnLogout          = function() { return this.divHeader_spnLogout         ; }
TabMenuUI_Six.prototype.lnkLogout          = function() { return this.divHeader_lnkLogout         ; }
// 08/22/2014 Paul.  Add SyncNow for offline client. 
TabMenuUI_Six.prototype.spnSyncNow         = function() { return this.divHeader_spnSyncNow        ; }
TabMenuUI_Six.prototype.lnkSyncNow         = function() { return this.divHeader_lnkSyncNow        ; }
TabMenuUI_Six.prototype.divOnlineStatus    = function() { return this.divHeader_divOnlineStatus   ; }
TabMenuUI_Six.prototype.divOfflineCache    = function() { return this.divHeader_divOfflineCache   ; }
TabMenuUI_Six.prototype.divSplendidStorage = function() { return this.divHeader_divSplendidStorage; }
TabMenuUI_Six.prototype.lnkCacheAll        = function() { return this.lnkHeaderCacheAll           ; }
TabMenuUI_Six.prototype.lnkSystemLog       = function() { return this.lnkHeaderSystemLog          ; }
TabMenuUI_Six.prototype.lnkSplendidStorage = function() { return this.lnkHeaderSplendidStorage    ; }

TabMenuUI_Six.prototype.RenderHeader = function()
{
	try
	{
		// 05/06/2013 Paul.  Clear pointers as the tags will be deleted. 
		this.divHeader_divError           = null;
		this.divHeader_divAuthenticated   = null;
		this.divHeader_spnWelcome         = null;
		this.divHeader_spnUserName        = null;
		this.divHeader_spnLogout          = null;
		this.divHeader_lnkLogout          = null;
		this.divHeader_spnSyncNow         = null;
		this.divHeader_lnkSyncNow         = null;
		this.divHeader_divOnlineStatus    = null;
		this.divHeader_divOfflineCache    = null;
		this.divHeader_divSplendidStorage = null;
		this.lnkHeaderCacheAll            = null;
		this.lnkHeaderSystemLog           = null;
		this.lnkHeaderSplendidStorage     = null;
		TabMenuUI_Clear('ctlHeader');
		TabMenuUI_Clear('ctlAtlanticToolbar');
		
		var bgPage = chrome.extension.getBackgroundPage();
		var ctlHeader = document.getElementById('ctlHeader');
		if ( ctlHeader != null )
		{
			// <table id="tblHeader" border="0" cellpadding="0" cellspacing="0" width="100%" style=" background-color: #ffd14e">
			var tblHeader = document.createElement('table');
			tblHeader.id          = 'tblHeader';
			tblHeader.cellPadding = 0;
			tblHeader.cellSpacing = 0;
			tblHeader.border      = 0;
			tblHeader.width       = '100%';
			var header_background  = bgPage.SplendidCache.Config('header_background' );
			if ( !Sql.IsEmptyString(header_background) )
				tblHeader.style.backgroundImage = 'url(' + sIMAGE_SERVER + 'App_Themes/Six/' + header_background + ')';
			else
				tblHeader.style.backgroundColor = '#ffd14e';

			ctlHeader.appendChild(tblHeader);
			var tbody = document.createElement('tbody');
			tblHeader.appendChild(tbody);
			var tr = document.createElement('tr');
			tbody.appendChild(tr);

			var td = document.createElement('td');
			td.width  = '50%';
			td.vAlign = 'top';
			tr.appendChild(td);
			// <table border="0" cellpadding="0" cellspacing="0" width="100%">
			var tblLogo = document.createElement('table');
			tblLogo.cellPadding = 0;
			tblLogo.cellSpacing = 0;
			tblLogo.border      = 0;
			tblLogo.width       = '100%';
			td.appendChild(tblLogo);
			tbody = document.createElement('tbody');
			tblLogo.appendChild(tbody);
			tr = document.createElement('tr');
			tbody.appendChild(tr);

			td = document.createElement('td');
			td.width  = '207';
			tr.appendChild(td);
			// <a href="#" onclick="Reload();">
			// 	<img id="divHeader_imgCompanyLogo" src="../Include/images/SplendidCRM_Logo.gif" alt="SplendidCRM" width="207" height="60" border="0" />
			// </a>
			var aLogo = document.createElement('a');
			aLogo.href    = '#';
			aLogo.onclick = function()
			{
				Reload();
			};
			td.appendChild(aLogo);
			// 05/19/2013 Paul.  Apply config customizations of header logo. 
			var header_logo_image  = bgPage.SplendidCache.Config('header_logo_image' );
			var header_logo_width  = bgPage.SplendidCache.Config('header_logo_width' );
			var header_logo_height = bgPage.SplendidCache.Config('header_logo_height');
			var header_logo_style  = bgPage.SplendidCache.Config('header_logo_style' );
			var company_name       = bgPage.SplendidCache.Config('company_name'      );
			var divHeader_imgCompanyLogo = document.createElement('img');
			divHeader_imgCompanyLogo.id     = 'divHeader_imgCompanyLogo';
			divHeader_imgCompanyLogo.alt    = !Sql.IsEmptyString(company_name) ? company_name : 'SplendidCRM';
			if ( !Sql.IsEmptyString(header_logo_image) )
			{
				if ( StartsWith(header_logo_image, 'http') )
					divHeader_imgCompanyLogo.src    = header_logo_image;
				else if ( StartsWith(header_logo_image, '~/') )
					divHeader_imgCompanyLogo.src    = sIMAGE_SERVER + header_logo_image.substring(2, header_logo_image.length);
				else
					divHeader_imgCompanyLogo.src    = sIMAGE_SERVER + 'Include/images/' + header_logo_image;
				if ( Sql.ToInteger(header_logo_width) > 0 )
					divHeader_imgCompanyLogo.width  = Sql.ToInteger(header_logo_width);
				if ( Sql.ToInteger(header_logo_height) > 0 )
					divHeader_imgCompanyLogo.height = Sql.ToInteger(header_logo_height);
				divHeader_imgCompanyLogo.border = 0;
				if ( !Sql.IsEmptyString(header_logo_style) )
					divHeader_imgCompanyLogo.style = header_logo_style;
			}
			else
			{
				divHeader_imgCompanyLogo.src    = sIMAGE_SERVER + 'Include/images/SplendidCRM_Logo.gif';
				divHeader_imgCompanyLogo.width  = 207;
				divHeader_imgCompanyLogo.height =  60;
				divHeader_imgCompanyLogo.style  = 'margin-left: 10px';
			}
			aLogo.appendChild(divHeader_imgCompanyLogo);
			
			td = document.createElement('td');
			tr.appendChild(td);
			// <div id="lblError" class="error"></div>
			this.divHeader_divError = document.createElement('div');
			this.divHeader_divError.id        = 'lblError';
			this.divHeader_divError.className = 'error';
			td.appendChild(this.divHeader_divError);
			if ( SplendidError.sLastError != null )
				this.divHeader_divError.innerHTML = SplendidError.sLastError;

			td = document.createElement('td');
			td.width  = '50%';
			td.vAlign = 'top';
			tr.appendChild(td);
			var tblStatus = document.createElement('table');
			tblStatus.cellPadding = 2;
			tblStatus.cellSpacing = 0;
			tblStatus.border      = 0;
			tblStatus.width       = '100%';
			td.appendChild(tblStatus);
			tbody = document.createElement('tbody');
			tblStatus.appendChild(tbody);
			tr = document.createElement('tr');
			tbody.appendChild(tr);

			td = document.createElement('td');
			td.vAlign = 'top';
			tr.appendChild(td);
			td = document.createElement('td');
			td.vAlign = 'top';
			tr.appendChild(td);
			// <div id="divHeader_divOfflineCache" style="vertical-align: top; height: 60px; overflow-y: scroll; width: 100%;"></div>
			this.divHeader_divOfflineCache = document.createElement('div');
			this.divHeader_divOfflineCache.id                  = 'divHeader_divOfflineCache';
			this.divHeader_divOfflineCache.className           = 'error';
			this.divHeader_divOfflineCache.style.verticalAlign = 'top';
			this.divHeader_divOfflineCache.style.height        = '60px';
			this.divHeader_divOfflineCache.style.width         = '100%';
			this.divHeader_divOfflineCache.style.overflowY     = 'scroll';
			this.divHeader_divOfflineCache.style.display       = 'none';
			td.appendChild(this.divHeader_divOfflineCache);

			// <td align="right" class="myArea" nowrap="nowrap" style="padding-right: 10px;" width="220">
			// 	<div id="divHeader_divAuthenticated" class="welcome" style="display:none">
			// 		<span id="divHeader_spnWelcome"></span>&nbsp;
			// 		<b><span id="divHeader_spnUserName"></span></b>
			// 		<span id="divHeader_spnLogout">
			// 			&nbsp;[&nbsp;<a id="divHeader_lnkLogout" href='#' class="myAreaLink"></a>&nbsp;]
			// 		</span>
			// 	</div>
			td = document.createElement('td');
			td.className          = 'myArea';
			td.align              = 'right';
			td.width              = '220';
			td.setAttribute('nowrap', 'nowrap');  // 04/25/2013 Paul.  IE9 is ignoring the nowrap whiteSpace style. 
			td.style.whiteSpace   = 'nowrap';
			td.style.paddingRight = '10px';
			tr.appendChild(td);

			var nbsp = String.fromCharCode(160);
			this.divHeader_divAuthenticated = document.createElement('div');
			this.divHeader_divAuthenticated.id               = 'divHeader_divAuthenticated';
			this.divHeader_divAuthenticated.className        = 'welcome';
			this.divHeader_divAuthenticated.style.display    = 'none';
			this.divHeader_divAuthenticated.style.whiteSpace = 'nowrap';
			td.appendChild(this.divHeader_divAuthenticated);
			// 04/25/2013 Paul.  The welcome text is causing the right alignment to fail. 
			//this.divHeader_spnWelcome = document.createElement('span');
			//this.divHeader_spnWelcome.id = 'divHeader_spnWelcome';
			//this.divHeader_spnWelcome.style.paddingRight = '6px';
			//this.divHeader_divAuthenticated.appendChild(this.divHeader_spnWelcome);
			this.divHeader_spnUserName = document.createElement('span');
			this.divHeader_spnUserName.id = 'divHeader_spnUserName';
			this.divHeader_spnUserName.style.fontWeight = 'bold';
			this.divHeader_divAuthenticated.appendChild(this.divHeader_spnUserName);
			
			// 08/22/2014 Paul.  Add SyncNow for offline client. 
			this.divHeader_spnSyncNow = document.createElement('span');
			this.divHeader_spnSyncNow.id = 'divHeader_spnSyncNow';
			this.divHeader_divAuthenticated.appendChild(this.divHeader_spnLogout);
			this.divHeader_spnSyncNow.appendChild(document.createTextNode(nbsp + '[' + nbsp));
			this.divHeader_lnkSyncNow = document.createElement('a');
			this.divHeader_lnkSyncNow.id        = 'divHeader_lnkSyncNow';
			this.divHeader_lnkSyncNow.href      = '#';
			this.divHeader_lnkSyncNow.className = 'myAreaLink';
			this.divHeader_spnSyncNow.appendChild(this.divHeader_lnkSyncNow);
			this.divHeader_spnSyncNow.appendChild(document.createTextNode(nbsp + ']' + nbsp));

			this.divHeader_spnLogout = document.createElement('span');
			this.divHeader_spnLogout.id = 'divHeader_spnLogout';
			this.divHeader_divAuthenticated.appendChild(this.divHeader_spnLogout);
			this.divHeader_spnLogout.appendChild(document.createTextNode(nbsp + '[' + nbsp));
			this.divHeader_lnkLogout = document.createElement('a');
			this.divHeader_lnkLogout.id        = 'divHeader_lnkLogout';
			this.divHeader_lnkLogout.href      = '#';
			this.divHeader_lnkLogout.className = 'myAreaLink';
			this.divHeader_spnLogout.appendChild(this.divHeader_lnkLogout);
			this.divHeader_spnLogout.appendChild(document.createTextNode(nbsp + ']' + nbsp));

			// 	<div id="divHeader_divOnlineStatus" class="welcome"></div>
			this.divHeader_divOnlineStatus = document.createElement('div');
			this.divHeader_divOnlineStatus.id               = 'divHeader_divOnlineStatus';
			this.divHeader_divOnlineStatus.className        = 'welcome';
			this.divHeader_divOnlineStatus.style.whiteSpace = 'nowrap';
			td.appendChild(this.divHeader_divOnlineStatus);
			// 	<div id="divHeader_divSystemLog" style="white-space: nowrap">
			// 		<a id="lnkHeaderSystemLog" href="#" onclick="ShowSystemLog()" class="welcome">System Log</a>
			// 	</div>
			var divHeader_divSystemLog = document.createElement('div');
			divHeader_divSystemLog.id               = 'divHeader_divSystemLog';
			divHeader_divSystemLog.style.whiteSpace = 'nowrap';
			td.appendChild(divHeader_divSystemLog);
			this.lnkHeaderSystemLog = document.createElement('a');
			this.lnkHeaderSystemLog.id        = 'lnkHeaderSystemLog';
			this.lnkHeaderSystemLog.href      = '#';
			this.lnkHeaderSystemLog.className = 'welcome';
			this.lnkHeaderSystemLog.innerHTML = 'System Log';
			this.lnkHeaderSystemLog.onclick = function()
			{
				ShowSystemLog();
			};
			divHeader_divSystemLog.appendChild(this.lnkHeaderSystemLog);
			// 	<div id="divHeader_divSplendidStorage">
			// 		<a id="lnkHeaderCacheAll"  href="#" onclick="CacheAllModules()" class="welcome">Cache All</a>
			// 		&nbsp;&nbsp;
			// 		<a id="lnkHeaderSplendidStorage" href="#" onclick="ShowSplendidStorage()" class="welcome">Splendid Storage</a>
			// 	</div>
			this.divHeader_divSplendidStorage = document.createElement('div');
			this.divHeader_divSplendidStorage.id = 'divHeader_divSplendidStorage';
			td.appendChild(this.divHeader_divSplendidStorage);
			this.lnkHeaderCacheAll = document.createElement('a');
			this.lnkHeaderCacheAll.id        = 'lnkHeaderCacheAll';
			this.lnkHeaderCacheAll.href      = '#';
			this.lnkHeaderCacheAll.className = 'welcome';
			this.lnkHeaderCacheAll.innerHTML = 'Cache All';
			this.lnkHeaderCacheAll.onclick = function()
			{
				CacheAllModules();
			};
			this.divHeader_divSplendidStorage.appendChild(this.lnkHeaderCacheAll);
			this.divHeader_divSplendidStorage.appendChild(document.createTextNode(nbsp + nbsp));
			this.lnkHeaderSplendidStorage = document.createElement('a');
			this.lnkHeaderSplendidStorage.id        = 'lnkHeaderSplendidStorage';
			this.lnkHeaderSplendidStorage.href      = '#';
			this.lnkHeaderSplendidStorage.className = 'welcome';
			this.lnkHeaderSplendidStorage.innerHTML = 'Splendid Storage';
			this.lnkHeaderSplendidStorage.onclick = function()
			{
				ShowSplendidStorage();
			};
			this.divHeader_divSplendidStorage.appendChild(this.lnkHeaderSplendidStorage);
			LoginViewUI_UpdateHeader(this.LayoutPanel, this.ActionsPanel, true);
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'TabMenuUI_Six.RenderHeader');
	}
}

TabMenuUI_Six.prototype.CreateTab = function(sTabMenuCtl, sLayoutPanel, sActionsPanel, sMODULE_NAME, sDISPLAY_NAME)
{
	var tbl = document.createElement('table');
	try
	{
		tbl.id          = 'ctlTabMenu_tabMenuInner' + sMODULE_NAME;
		tbl.className   = 'tabFrame';
		tbl.cellSpacing = 0;
		tbl.cellPadding = 0;
		tbl.height      = 25;

		var tbody = document.createElement('tbody');
		tbl.appendChild(tbody);
		var tr = document.createElement('tr');
		tbody.appendChild(tr);

		var td = document.createElement('td');
		tr.appendChild(td);
		if ( sMENU_ACTIVE_MODULE == sMODULE_NAME )
			td.className = 'currentTabLeft';
		else
			td.className = 'otherTabLeft';

		var img = document.createElement('img');
		td.appendChild(img);
		img.src         = sIMAGE_SERVER + 'App_Themes/Six/images/blank.gif';
		img.align       = 'absmiddle';
		// 08/31/2013 Paul.  img border attribute is deprecated.  Use style instead. 
		img.style.width       = '5px';
		img.style.height      = '25px';
		img.style.borderWidth = '0px';

		td = document.createElement('td');
		tr.appendChild(td);
		if ( sMENU_ACTIVE_MODULE == sMODULE_NAME )
			td.className = 'currentTab';
		else
			td.className = 'otherTab';

		td.setAttribute('nowrap', '1');
		var a = document.createElement('a');
		// 10/16/2011 Paul.  Give the link a name so that we can find it and simulate a click. 
		a.id = sTabMenuCtl + '_' + sMODULE_NAME;
		td.appendChild(a);
		if ( sMENU_ACTIVE_MODULE == sMODULE_NAME )
			a.className = 'currentTabLink';
		else
			a.className = 'otherTabLink';
		a.href = '#';
		a.onclick = function()
		{
			TabMenuUI_Clicked(sLayoutPanel, sActionsPanel, sMODULE_NAME);
		};
		
		a.innerHTML = '<nobr>' + L10n.Term(sDISPLAY_NAME) + '</nobr>';

		td = document.createElement('td');
		tr.appendChild(td);
		if ( sMENU_ACTIVE_MODULE == sMODULE_NAME )
			td.className = 'currentTabRight';
		else
			td.className = 'otherTabRight';

		img = document.createElement('img');
		td.appendChild(img);
		img.align       = 'absmiddle';
		// 08/31/2013 Paul.  img border attribute is deprecated.  Use style instead. 
		img.style.width       = '5px';
		img.style.height      = '25px';
		img.style.borderWidth = '0px';
		img.src               = sIMAGE_SERVER + 'App_Themes/Six/images/blank.gif';
		/*
		<td valign="bottom">
			<table id="ctlTabMenu_tabMenuInnerAccounts" class="tabFrame" cellspacing="0" cellpadding="0" height="25">
				<tr>
					<td class="currentTabLeft"><img src="App_Themes/Six/images/blank.gif" align="absmiddle" style="border-width:0px;height:25px;width:5px;" /></td>
					<td class="currentTab" nowrap="1"><a class="currentTabLink" href="#">Accounts</a></td>
					<td class="currentTabRight"><img src="App_Themes/Six/images/blank.gif" align="absmiddle" style="border-width:0px;height:25px;width:5px;" /></td>
				</tr>
			</table>
		</td>
		*/
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'TabMenuUI_Six.CreateTab');
	}
	return tbl;
}

// 12/06/2014 Paul.  LayoutMode is used on the Mobile view. 
TabMenuUI_Six.prototype.ActivateTab = function(sMODULE_NAME, sID, sLAYOUT_MODE)
{
	if ( sMODULE_NAME != sMENU_ACTIVE_MODULE )
	{
		try
		{
			// 09/04/2011 Paul.  Deactivate the existing tab. 
			var tbl = document.getElementById('ctlTabMenu_tabMenuInner' + sMENU_ACTIVE_MODULE);
			if ( tbl != null )
			{
				tbl.rows[0].cells[0].className = 'otherTabLeft';
				tbl.rows[0].cells[1].className = 'otherTab';
				tbl.rows[0].cells[1].childNodes[0].className = 'otherTabLink';
				tbl.rows[0].cells[2].className = 'otherTabRight';
			}
			// 02/01/2013 Paul.  Render all action bars, just all but the active one. 
			var pnlModuleActions = document.getElementById('pnlModuleActionsBar' + sMENU_ACTIVE_MODULE);
			if ( pnlModuleActions != null )
			{
				pnlModuleActions.style.display    = 'none';
				pnlModuleActions.style.visibility = 'hidden';
			}

			sMENU_ACTIVE_MODULE = sMODULE_NAME;
			// 09/04/2011 Paul.  Activate the new tab. 
			tbl = document.getElementById('ctlTabMenu_tabMenuInner' + sMENU_ACTIVE_MODULE);
			if ( tbl != null )
			{
				tbl.rows[0].cells[0].className = 'currentTabLeft';
				tbl.rows[0].cells[1].className = 'currentTab';
				tbl.rows[0].cells[1].childNodes[0].className = 'currentTabLink';
				tbl.rows[0].cells[2].className = 'currentTabRight';
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
			SplendidError.SystemAlert(e, 'TabMenuUI_Six.ActivateTab');
		}
	}
}

TabMenuUI_Six.prototype.Render = function(sLayoutPanel, sActionsPanel, arrDetailViewRelationship, arrQuickCreate, result)
{
	var sTabMenuCtl = 'ctlTabMenu';
	// 10/15/2011 Paul.  sTabMenuCtl is a div tag now so that we can do more with the panel. 
	var ctlTabMenu = document.getElementById(sTabMenuCtl);
	// <table id="ctlTabMenu_tblSixMenu" class="tabFrame" cellspacing="0" cellpadding="0" bgcolor="#ffd14e"></table>
	var tblSixMenu = document.createElement('table');
	tblSixMenu.id                    = sTabMenuCtl + '_tblSixMenu';
	tblSixMenu.className             = 'tabFrame';
	tblSixMenu.cellSpacing           = 0;
	tblSixMenu.cellPadding           = 0;
	tblSixMenu.style.backgroundColor = '#ffd14e';
	ctlTabMenu.appendChild(tblSixMenu);
	
	var tbody = document.createElement('tbody');
	tblSixMenu.appendChild(tbody);
	// <td style="padding-left:14px;" class="otherTabRight">&nbsp;</td>
	var tr = document.createElement('tr');
	tbody.appendChild(tr);
	var td = document.createElement('td');
	tr.appendChild(td);
	td.className         = 'otherTabRight';
	td.style.paddingLeft = '14px';
	td.innerHTML = '&nbsp;';
	
	// 02/23/2013 Paul.  Use object for hash table lookup. 
	var arrValidModules = new Object();
	for ( var i = 0; i < arrDetailViewRelationship.length; i++ )
	{
		arrValidModules[arrDetailViewRelationship[i].MODULE_NAME] = null;
	}
	var sUSER_AGENT = navigator.userAgent;
	for ( var i = 0; i < result.length; i++ )
	{
		var sMODULE_NAME = result[i].MODULE_NAME;
		// 04/30/2017 Paul.  Apply access rights. 
		var nEDIT_ACLACCESS = (Sql.IsEmptyString(result[i].EDIT_ACLACCESS) ? 0 : Sql.ToInteger(result[i].EDIT_ACLACCESS));
		// 11/15/2012 Paul.  The Surface app does not use the TabMenu DetailView relationship. 
		// 02/23/2013 Paul.  Use object for hash table lookup. 
		if ( arrDetailViewRelationship.length == 0 || arrValidModules[sMODULE_NAME] !== undefined )
		{
			var sDISPLAY_NAME  = result[i].DISPLAY_NAME ;
			var sRELATIVE_PATH = result[i].RELATIVE_PATH;
			td = document.createElement('td');
			tr.appendChild(td);
			td.vAlign = 'bottom';
			var tabMenuInner = ctlActiveMenu.CreateTab(sTabMenuCtl, sLayoutPanel, sActionsPanel, sMODULE_NAME, sDISPLAY_NAME);
			td.appendChild(tabMenuInner);
			
			// 10/20/2011 Paul.  Nook with Android SD uses WIN. 
			// 11/14/2012 Paul.  Microsoft Surface has a Touch attribute. 
			// 11/19/2012 Paul.  WinJS app does not include Touch in the agent string. 
			if ( sUSER_AGENT == 'WIN' || sUSER_AGENT.indexOf('Android') > 0 || sUSER_AGENT.indexOf('iPad') > 0 || sUSER_AGENT.indexOf('iPhone') > 0 || sUSER_AGENT.indexOf('Touch') > 0 || sUSER_AGENT.indexOf('MSAppHost') > 0 )
			{
				// 02/01/2013 Paul.  Render all action bars, just all but the active one. 
				//if ( sMENU_ACTIVE_MODULE == sMODULE_NAME )
				{
					// 02/01/2013 Paul.  We do not use 
					//var trActions = document.createElement('tr');
					//tbody.appendChild(trActions);
					//var tdActions = document.createElement('td');
					//trActions.appendChild(tdActions);
					// 04/30/2017 Paul.  ActionBar does not exist.  Use Load instead. 
					ctlActiveMenu.Load(sTabMenuCtl, sLayoutPanel, sActionsPanel, sMODULE_NAME, sDISPLAY_NAME, ctlTabMenu, (sMENU_ACTIVE_MODULE == sMODULE_NAME), nEDIT_ACLACCESS);
				}
			}
			// 11/14/2012 Paul.  Let's try having the action bar and the popdowns. 
			//else
			{
				// 04/30/2017 Paul.  Apply access rights. 
				ctlActiveMenu.ActionsPopup(sTabMenuCtl, sLayoutPanel, sActionsPanel, sMODULE_NAME, sDISPLAY_NAME, tabMenuInner, td, nEDIT_ACLACCESS);
			}
		}
	}
	// <td width="100%" class="tabRow"><img src="App_Themes/Six/images/blank.gif" align="absmiddle" style="border-width:0px;height:1px;width:1px;" /></td>
	td = document.createElement('td');
	tr.appendChild(td);
	td.className = 'tabRow';
	td.width     = '100%';
	var img = document.createElement('img');
	td.appendChild(img);
	img.align       = 'absmiddle';
	// 08/31/2013 Paul.  img border attribute is deprecated.  Use style instead. 
	img.style.width       = '1px';
	img.style.height      = '1px';
	img.style.borderWidth = '0px';
	img.src         = sIMAGE_SERVER + 'App_Themes/Six/images/blank.gif';
}

// 04/30/2017 Paul.  Apply access rights. 
TabMenuUI_Six.prototype.ActionsPopup = function(sTabMenuCtl, sLayoutPanel, sActionsPanel, sMODULE_NAME, sDISPLAY_NAME, ctlTabMenu_tabMenuInner, tdMenuInner, nEDIT_ACLACCESS)
{
	try
	{
		/*
		<div id="ctl00_pnlModuleActionsContacts" class="PanelHoverHidden" style="position: absolute; left: 412px; top: 151px; z-index: 1000; display: none; visibility: hidden; ">
			<table cellpadding="0" cellspacing="0" class="ModuleActionsShadingTable">
			<tbody>
				<tr>
					<td colspan="3" class="ModuleActionsShadingHorizontal"></td>
				</tr>
				<tr>
					<td class="ModuleActionsShadingVertical"></td>
					<td>
						<table cellpadding="0" cellspacing="0" class="ModuleActionsInnerTable">
						<tbody>
							<tr>
								<td class="ModuleActionsInnerCell">
									<span class="ModuleActionsInnerHeader" style="font-weight:bold;">Actions</span>
									<a class="ModuleActionsMenuItems" href="../Contacts/edit.aspx">Create Contact</a>
									<a class="ModuleActionsMenuItems" href="../Contacts/default.aspx">Contacts</a>
								</td>
							</tr>
						</tbody>
						</table>
					</td>
					<td class="ModuleActionsShadingVertical"></td>
				</tr>
				<tr>
					<td colspan="3" class="ModuleActionsShadingHorizontal"></td>
				</tr>
			</tbody>
			</table>
		</div>
		*/
		var pnlModuleActions = document.createElement('div');
		pnlModuleActions.id        = 'pnlModuleActions' + sMODULE_NAME;
		pnlModuleActions.className = 'PanelHoverHidden';
		// 02/23/2013 Paul.  Increase the zIndex so that the popup will appear on top of the FullCalendar. 
		pnlModuleActions.style.zIndex = 100;
		tdMenuInner.appendChild(pnlModuleActions);
		var tblShading = document.createElement('table');
		tblShading.cellPadding = 0;
		tblShading.cellSpacing = 0;
		tblShading.className   = 'ModuleActionsShadingTable';
		pnlModuleActions.appendChild(tblShading);
		var tShading = document.createElement('tbody');
		tblShading.appendChild(tShading);
		
		// Shading Top
		var trShadingTop = document.createElement('tr');
		tShading.appendChild(trShadingTop);

		var tdShadingTop = document.createElement('td');
		tdShadingTop.colSpan   = 3;
		tdShadingTop.className = 'ModuleActionsShadingHorizontal';
		trShadingTop.appendChild(tdShadingTop);
		
		// Shading Center
		var trShadingCenter = document.createElement('tr');
		tShading.appendChild(trShadingCenter);
		var tdShadingLeft = document.createElement('td');
		tdShadingLeft.className = 'ModuleActionsShadingVertical';
		trShadingCenter.appendChild(tdShadingLeft);
		var tdShadingCenter = document.createElement('td');
		trShadingCenter.appendChild(tdShadingCenter);
		var tdShadingRight = document.createElement('td');
		tdShadingRight.className = 'ModuleActionsShadingVertical';
		trShadingCenter.appendChild(tdShadingRight);

		// Shading Bottom
		var trShadingBottom = document.createElement('tr');
		tShading.appendChild(trShadingBottom);
		var tdShadingBottom = document.createElement('td');
		tdShadingBottom.colSpan   = 3;
		tdShadingBottom.className = 'ModuleActionsShadingHorizontal';
		trShadingBottom.appendChild(tdShadingBottom);
		
		// Actions Inner Table
		var tblModuleActionsInner = document.createElement('table');
		tblModuleActionsInner.cellPadding = 0;
		tblModuleActionsInner.cellSpacing = 0;
		tblModuleActionsInner.className   = 'ModuleActionsInnerTable';
		tdShadingCenter.appendChild(tblModuleActionsInner);
		var tModuleActionsInner = document.createElement('tbody');
		tblModuleActionsInner.appendChild(tModuleActionsInner);

		var trModuleActionsInner = document.createElement('tr');
		tModuleActionsInner.appendChild(trModuleActionsInner);
		var tdModuleActionsInner = document.createElement('td');
		tdModuleActionsInner.className = 'ModuleActionsInnerCell';
		trModuleActionsInner.appendChild(tdModuleActionsInner);

		var spnActions = document.createElement('span');
		spnActions.className = 'ModuleActionsInnerHeader';
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
					aCreateCall.className = 'ModuleActionsMenuItems';
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
					aCreateMeeting.className = 'ModuleActionsMenuItems';
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
				aCreate.className = 'ModuleActionsMenuItems';
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
			aList.className = 'ModuleActionsMenuItems';
			aList.href      = '#';
			aList.innerHTML = L10n.Term(sDISPLAY_NAME);
			// 10/27/2012 Paul.  Link was not working.  Change to use binding. 
			aList.onclick = BindArguments(function(sTabMenuCtl, sLayoutPanel, sActionsPanel, sMODULE_NAME, pnlModuleActions)
			{
				pnlModuleActions.style.display    = 'none';
				pnlModuleActions.style.visibility = 'hidden';
				TabMenuUI_Clicked(sLayoutPanel, sActionsPanel, sMODULE_NAME);
			}, sTabMenuCtl, sLayoutPanel, sActionsPanel, sMODULE_NAME, pnlModuleActions);
			tdModuleActionsInner.appendChild(aList);
		}

		TabMenuUI_PopupManagement(pnlModuleActions, ctlTabMenu_tabMenuInner);
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'TabMenuUI_Six.ActionsPopup ' + sMODULE_NAME);
	}
}

// 02/01/2013 Paul.  Render all action bars, just all but the active one. 
// 04/30/2017 Paul.  Apply access rights. 
TabMenuUI_Six.prototype.Load = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sDISPLAY_NAME, ctlTabMenu, bActive, nEDIT_ACLACCESS)
{
	try
	{
		var sTabMenuCtl = 'ctlTabMenu';
		/*
		<div id=ctl00_cntLastViewed_ctlActions_divShortcuts class=lastView width="100%">
			<b>Actions:&nbsp;&nbsp;</b> 
			<nobr>
				<a class=lastViewLink title="Create User" href="edit.aspx">
					<img border=0 align=absMiddle src="/SplendidCRM6/App_Themes/Sugar/images/CreateUsers.gif" width=16 height=16>
					 &nbsp;Create User
				</a>&nbsp; 
			</nobr>
			<nobr>
				<a class=lastViewLink title=Users href="default.aspx">
					<img border=0 align=absMiddle src="/SplendidCRM6/App_Themes/Sugar/images/Users.gif" width=16 height=16>
					 &nbsp;Users
				</a>&nbsp; 
			</nobr>
		</div>
		*/
		var pnlModuleActions = document.createElement('div');
		pnlModuleActions.id        = 'pnlModuleActionsBar' + sMODULE_NAME;
		pnlModuleActions.className = 'lastView';
		pnlModuleActions.width     = '100%';
		if ( !bActive )
		{
			pnlModuleActions.style.display    = 'none';
			pnlModuleActions.style.visibility = 'hidden';
		}
		ctlTabMenu.appendChild(pnlModuleActions);
		
		var lblActions = document.createElement('b');
		lblActions.innerHTML = L10n.Term('.LBL_ACTIONS') + '&nbsp;&nbsp;'
		pnlModuleActions.appendChild(lblActions);
		
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
					var nobrCreateCall = document.createElement('nobr');
					pnlModuleActions.appendChild(nobrCreateCall);
					var aCreateCall = document.createElement('a');
					aCreateCall.className = 'lastViewLink';
					aCreateCall.href = '#';
					aCreateCall.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE)
					{
						var oEditViewUI = new EditViewUI();
						oEditViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE);
					}, sLayoutPanel, sActionsPanel, 'Calls', null, false);
					aCreateCall.title     = L10n.Term(sMODULE_NAME + '.LNK_NEW_CALL');
					nobrCreateCall.appendChild(aCreateCall);
					
					var txtCreateCall = document.createTextNode(L10n.Term(sMODULE_NAME + '.LNK_NEW_CALL'));
					aCreateCall.appendChild(txtCreateCall);
				}
				// 01/10/2018 Paul.  Make sure Call or Meeting module is enabled. 
				if ( bgPage.SplendidCache.Module('Meetings') !== undefined )
				{
					var nobrCreateMeeting = document.createElement('nobr');
					pnlModuleActions.appendChild(nobrCreateMeeting);
					var aCreateMeeting = document.createElement('a');
					aCreateMeeting.className = 'lastViewLink';
					aCreateMeeting.href = '#';
					aCreateMeeting.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE)
					{
						var oEditViewUI = new EditViewUI();
						oEditViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE);
					}, sLayoutPanel, sActionsPanel, 'Meetings', null, false);
					aCreateMeeting.title     = L10n.Term(sMODULE_NAME + '.LNK_NEW_MEETING');
					nobrCreateMeeting.appendChild(aCreateMeeting);
					
					var txtCreateMeeting = document.createTextNode(L10n.Term(sMODULE_NAME + '.LNK_NEW_MEETING'));
					aCreateMeeting.appendChild(txtCreateMeeting);
				}
			}
		}
		else
		{
			// 04/30/2017 Paul.  Apply access rights. 
			if ( nEDIT_ACLACCESS >= 0 )
			{
				var nobrCreate = document.createElement('nobr');
				pnlModuleActions.appendChild(nobrCreate);
				var aCreate = document.createElement('a');
				aCreate.className = 'lastViewLink';
				aCreate.href = '#';
				aCreate.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE)
				{
					var oEditViewUI = new EditViewUI();
					oEditViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE);
				}, sLayoutPanel, sActionsPanel, sMODULE_NAME, null, false);
				aCreate.title     = L10n.Term(sMODULE_NAME + '.LBL_NEW_FORM_TITLE');
				nobrCreate.appendChild(aCreate);
			
				/*
				var imgCreate = document.createElement('img');
				// 10/15/2011 Paul.  Must append image before setting src. 
				aCreate.appendChild(imgCreate);
				imgCreate.align              = 'absmiddle';
				imgCreate.style.height       = '16px';
				imgCreate.style.width        = '16px';
				imgCreate.style.borderWidth  = '0px';
				imgCreate.src                = sIMAGE_SERVER + 'App_Themes/Six/images/Create' + sMODULE_NAME + '.gif';
				imgCreate.style.paddingRight = '5px';
				*/
				var txtCreate = document.createTextNode(L10n.Term(sMODULE_NAME + '.LBL_NEW_FORM_TITLE'));
				aCreate.appendChild(txtCreate);
			}
		
			var nobrList = document.createElement('nobr');
			pnlModuleActions.appendChild(nobrList);
			var aList = document.createElement('a');
			aList.className = 'lastViewLink';
			aList.href      = '#';
			aList.title     = L10n.Term(sDISPLAY_NAME);
			aList.onclick = BindArguments(function(sTabMenuCtl, sLayoutPanel, sActionsPanel, sMODULE_NAME)
			{
				TabMenuUI_Clicked(sLayoutPanel, sActionsPanel, sMODULE_NAME);
			}, sTabMenuCtl, sLayoutPanel, sActionsPanel, sMODULE_NAME);
			nobrList.appendChild(aList);
			
			/*
			var imgList = document.createElement('img');
			// 10/15/2011 Paul.  Must append image before setting src. 
			aList.appendChild(imgList);
			imgList.align              = 'absmiddle';
			imgList.style.height       = '16px';
			imgList.style.width        = '16px';
			imgList.style.borderWidth  = '0px';
			imgList.src                = sIMAGE_SERVER + 'App_Themes/Six/images/' + sMODULE_NAME + '.gif';
			imgList.style.paddingRight = '5px';
			*/
			var txtList = document.createTextNode(L10n.Term(sDISPLAY_NAME));
			aList.appendChild(txtList);
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'TabMenuUI_Six.Load ' + sMODULE_NAME);
	}
}

TabMenuUI_Six.prototype.Load = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, callback)
{
	try
	{
		var sTabMenuCtl = 'ctlTabMenu';
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
									
									TabMenuUI_Clear(sTabMenuCtl)
									ctlActiveMenu.Render(sLayoutPanel, sActionsPanel, arrDetailViewRelationship, null, result);
									callback(1, null);
								}
								catch(e)
								{
									callback(-1, SplendidError.FormatError(e, 'TabMenuUI_Six.Load'));
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
		callback(-1, SplendidError.FormatError(e, 'TabMenuUI_Six.Load'));
	}
}

