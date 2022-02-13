/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function TabMenuUI_Mobile(sLayoutPanel, sActionsPanel)
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

TabMenuUI_Mobile.prototype.divError           = function() { return this.divHeader_divError          ; }
TabMenuUI_Mobile.prototype.divAuthenticated   = function() { return this.divHeader_divAuthenticated  ; }
TabMenuUI_Mobile.prototype.spnWelcome         = function() { return this.divHeader_spnWelcome        ; }
TabMenuUI_Mobile.prototype.spnUserName        = function() { return this.divHeader_spnUserName       ; }
TabMenuUI_Mobile.prototype.spnLogout          = function() { return this.divHeader_spnLogout         ; }
TabMenuUI_Mobile.prototype.lnkLogout          = function() { return this.divHeader_lnkLogout         ; }
// 08/22/2014 Paul.  Add SyncNow for offline client. 
TabMenuUI_Mobile.prototype.spnSyncNow         = function() { return this.divHeader_spnSyncNow        ; }
TabMenuUI_Mobile.prototype.lnkSyncNow         = function() { return this.divHeader_lnkSyncNow        ; }
TabMenuUI_Mobile.prototype.divOnlineStatus    = function() { return this.divHeader_divOnlineStatus   ; }
TabMenuUI_Mobile.prototype.divOfflineCache    = function() { return this.divHeader_divOfflineCache   ; }
TabMenuUI_Mobile.prototype.divSplendidStorage = function() { return this.divHeader_divSplendidStorage; }
TabMenuUI_Mobile.prototype.lnkCacheAll        = function() { return this.lnkHeaderCacheAll           ; }
TabMenuUI_Mobile.prototype.lnkSystemLog       = function() { return this.lnkHeaderSystemLog          ; }
TabMenuUI_Mobile.prototype.lnkSplendidStorage = function() { return this.lnkHeaderSplendidStorage    ; }

TabMenuUI_Mobile.prototype.RenderHeader = function()
{
	try
	{
		TabMenuUI_Clear('ctlHeader');
		TabMenuUI_Clear('ctlTabMenu');
		TabMenuUI_Clear('ctlAtlanticToolbar');
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'TabMenuUI_Mobile.RenderHeader');
	}
}

// 12/06/2014 Paul.  LayoutMode is used on the Mobile view. 
TabMenuUI_Mobile.prototype.ActivateTab = function(sMODULE_NAME, sID, sLAYOUT_MODE, obj)
{
	//var aNavMenu    = document.getElementById('ctlAtlanticToolbar_aNavMenu'   );
	var aNavCreate  = document.getElementById('ctlAtlanticToolbar_aNavCreate' );
	var aNavSearch  = document.getElementById('ctlAtlanticToolbar_aNavSearch' );
	var aNavBack    = document.getElementById('ctlAtlanticToolbar_aNavBack'   );
	var aNavEdit    = document.getElementById('ctlAtlanticToolbar_aNavEdit'   );
	var aNavSave    = document.getElementById('ctlAtlanticToolbar_aNavSave'   );
	// 01/25/2015 Paul.  We need to update the NavCenter as it displays the module. 
	var tdNavCenter = document.getElementById('ctlAtlanticToolbar_tdNavCenter');
	if ( tdNavCenter != null )
	{
		TabMenuUI_Clear('ctlAtlanticToolbar_tdNavCenter');
		var sModuleTitle = L10n.ListTerm('moduleList', sMODULE_NAME);
		if ( sMODULE_NAME == 'Offline' )
			sModuleTitle = L10n.Term('Offline.LNK_OFFLINE_DASHBOARD');
		tdNavCenter.appendChild(document.createTextNode(sModuleTitle));
	}

	// 12/06/2014 Paul.  Always show the nav menu. 
	//if ( aNavMenu   != null ) aNavMenu.style.display   = (sLAYOUT_MODE == 'ListView' || ) ? 'inline' : 'none';
	if ( aNavCreate  != null ) aNavCreate.style.display = (sLAYOUT_MODE == 'ListView') ? 'inline' : 'none';
	if ( aNavSearch  != null ) aNavSearch.style.display = (sLAYOUT_MODE == 'ListView') ? 'inline' : 'none';
	if ( aNavBack    != null ) aNavBack.style.display   = (sLAYOUT_MODE == 'EditView' || sLAYOUT_MODE == 'DetailView') ? 'inline' : 'none';
	if ( aNavEdit    != null )
	{
		aNavEdit.style.display   = (sLAYOUT_MODE == 'DetailView') ? 'inline' : 'none';
		if ( obj != null && obj !== undefined )
		{
			aNavEdit.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, obj)
			{
				obj.PageCommand.call(obj, sLayoutPanel, sActionsPanel, 'Edit', null);
			}, this.LayoutPanel, this.ActionsPanel, obj);
		}
	}
	if ( aNavSave    != null )
	{
		aNavSave.style.display   = (sLAYOUT_MODE == 'EditView'  ) ? 'inline' : 'none';
		if ( obj != null && obj !== undefined )
		{
			aNavSave.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, obj)
			{
				obj.PageCommand.call(obj, sLayoutPanel, sActionsPanel, 'Save', null);
			}, this.LayoutPanel, this.ActionsPanel, obj);
		}
	}
	if ( btnDynamicButtons_SaveDuplicate != null )
	{
		btnDynamicButtons_SaveDuplicate.style.display = 'none';
		if ( obj != null && obj !== undefined )
		{
			btnDynamicButtons_SaveDuplicate.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, obj)
			{
				obj.PageCommand.call(obj, sLayoutPanel, sActionsPanel, 'SaveDuplicate', null);
			}, this.LayoutPanel, this.ActionsPanel, obj);
		}
	}
	if ( btnDynamicButtons_SaveConcurrency != null )
	{
		btnDynamicButtons_SaveConcurrency.style.display = 'none';
		if ( obj != null && obj !== undefined )
		{
			btnDynamicButtons_SaveConcurrency.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, obj)
			{
				obj.PageCommand.call(obj, sLayoutPanel, sActionsPanel, 'SaveConcurrency', null);
			}, this.LayoutPanel, this.ActionsPanel, obj);
		}
	}
	var spnChatChannel   = document.getElementById('ctlAtlanticToolbar_spnChatChannel');
	var aNavChatChannels = document.getElementById('ctlAtlanticToolbar_aNavChatChannels');
	if ( spnChatChannel   != null ) spnChatChannel.style.display   = 'none';
	if ( aNavChatChannels != null ) aNavChatChannels.style.display = 'none';
}

TabMenuUI_Mobile.prototype.Render = function(sLayoutPanel, sActionsPanel, arrDetailViewRelationship, arrQuickCreate, result)
{
	this.LayoutPanel  = sLayoutPanel ;
	this.ActionsPanel = sActionsPanel;
	var ctlAtlanticToolbar = document.getElementById('ctlAtlanticToolbar');
	if ( ctlAtlanticToolbar != null )
	{
		var bgPage = chrome.extension.getBackgroundPage();
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
		if ( ctlAtlanticToolbar.childNodes != null )
		{
			while ( ctlAtlanticToolbar.childNodes.length > 0 )
			{
				ctlAtlanticToolbar.removeChild(ctlAtlanticToolbar.firstChild);
			}
		}

		//<div class="navTopSpacer"></div>
		//<div class="navTop">
		//	<table cellpadding="0" cellspacing="0" align="center" style="width: 100%">
		//		<tr>
		//			<td id="navMenu" class="navLeft">
		//				<a href="#"><i id="navBars" class="fa fa-2x fa-bars"></i></a>
		//			</td>
		//			<td class="navCenter">
		//			</td>
		//			<td class="navRight">
		//			</td>
		//		</tr>
		//	</table>
		//</div>
		var divTopSpacer = document.createElement('div');
		divTopSpacer.className = 'navTopSpacer';
		ctlAtlanticToolbar.appendChild(divTopSpacer);
		var divTop = document.createElement('div');
		divTop.className = 'navTop';
		ctlAtlanticToolbar.appendChild(divTop);
		var tblMobileMenu = document.createElement('table');
		tblMobileMenu.id = 'ctlAtlanticToolbar_tblMobileMenu';
		tblMobileMenu.cellPadding = 0;
		tblMobileMenu.cellSpacing = 0;
		tblMobileMenu.align       = 'center';
		tblMobileMenu.style.width = '100%';
		ctlAtlanticToolbar.appendChild(tblMobileMenu);
		var tbodyMobileMenu = document.createElement('tbody');
		tblMobileMenu.appendChild(tbodyMobileMenu);
		var trMobileMenu = document.createElement('tr');
		tbodyMobileMenu.appendChild(trMobileMenu);
		var tdNavLeft = document.createElement('td');
		tdNavLeft.id = 'navMenu';
		tdNavLeft.className = 'navLeft';
		trMobileMenu.appendChild(tdNavLeft);
		var tdNavCenter = document.createElement('td');
		tdNavCenter.id = 'ctlAtlanticToolbar_tdNavCenter';
		tdNavCenter.className = 'navCenter';
		tdNavCenter.appendChild(document.createTextNode(L10n.ListTerm('moduleList', sMENU_ACTIVE_MODULE)));
		trMobileMenu.appendChild(tdNavCenter);
		var tdNavRight = document.createElement('td');
		tdNavRight.className = 'navRight';
		trMobileMenu.appendChild(tdNavRight);
		if ( sessionStorage['device.platform'] === 'iOS' && parseFloat(sessionStorage['device.version']) >= 7.0 )
		{
			divTopSpacer.style.height = '20px';
			divTop.style.top = '20px';
			//formBody.style.marginTop = '56px';
		}
		// Error bar. 
		this.divHeader_divError = document.createElement('div');
		this.divHeader_divError.id        = 'lblError';
		this.divHeader_divError.className = 'error';
		ctlAtlanticToolbar.appendChild(this.divHeader_divError);

		// Menu 
		var aNavMenu = document.createElement('a');
		aNavMenu.id = 'ctlAtlanticToolbar_aNavMenu';
		aNavMenu.href = '#';
		tdNavLeft.appendChild(aNavMenu);
		var iNavBars = document.createElement('i');
		iNavBars.className = 'fa fa-2x fa-bars navButton';
		aNavMenu.appendChild(iNavBars);
		
		// Back 
		var aNavBack = document.createElement('a');
		aNavBack.id = 'ctlAtlanticToolbar_aNavBack';
		aNavBack.href = '#';
		aNavBack.style.display = 'none';
		tdNavLeft.appendChild(aNavBack);
		var iNavBack = document.createElement('i');
		iNavBack.className = 'fa fa-2x fa-chevron-left navButton';
		aNavBack.appendChild(iNavBack);
		aNavBack.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME)
		{
			var sGRID_NAME = sMODULE_NAME + '.ListView' + sPLATFORM_LAYOUT;
			var oListViewUI = new ListViewUI();
			oListViewUI.Reset(sLayoutPanel, sMODULE_NAME);
			oListViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sGRID_NAME, null, function(status, message)
			{
				if ( status == 0 || status == 1 )
				{
					this.MODULE  = null;
					this.ID      = null;
				}
			});
		}, this.LayoutPanel, this.ActionsPanel, sMENU_ACTIVE_MODULE);
		
		// ChatChannels 
		var spnChatChannel = document.createElement('a');
		spnChatChannel.id = 'ctlAtlanticToolbar_spnChatChannel';
		spnChatChannel.className = 'navChatChannel';
		spnChatChannel.style.display = 'none';
		tdNavLeft.appendChild(spnChatChannel);
		var aNavChatChannels = document.createElement('a');
		aNavChatChannels.id = 'ctlAtlanticToolbar_aNavChatChannels';
		aNavChatChannels.href = '#';
		//aNavChatChannels.style.display = 'none';
		tdNavLeft.appendChild(aNavChatChannels);
		var iNavChatChannels = document.createElement('i');
		iNavChatChannels.id = 'ctlAtlanticToolbar_iNavChatChannels';
		iNavChatChannels.className = 'fa fa-chevron-down navButton navChatChannel';
		aNavChatChannels.appendChild(iNavChatChannels);
		
		// Search
		var aNavSearch = document.createElement('a');
		aNavSearch.id = 'ctlAtlanticToolbar_aNavSearch';
		aNavSearch.href = '#';
		aNavSearch.style.display = 'none';
		tdNavRight.appendChild(aNavSearch);
		var iNavSearch = document.createElement('i');
		iNavSearch.className = 'fa fa-2x fa-search navButton';
		aNavSearch.appendChild(iNavSearch);
		aNavSearch.onclick = BindArguments(function(sLayoutPanel, sActionsPanel)
		{
			var ctlSearchView = document.getElementById(sActionsPanel + '_ctlSearchView');
			if ( ctlSearchView != null )
			{
				if ( ctlSearchView.style.display == 'none' )
					ctlSearchView.style.display = 'block';  // 12/06/2014 Paul.  Inline causes rendering to look ugly. 
				else
					ctlSearchView.style.display = 'none'
			}

		}, this.LayoutPanel, this.ActionsPanel);

		// Create
		var aNavCreate = document.createElement('a');
		aNavCreate.id = 'ctlAtlanticToolbar_aNavCreate';
		aNavCreate.href = '#';
		aNavCreate.style.display = 'none';
		tdNavRight.appendChild(aNavCreate);
		var iNavCreate = document.createElement('i');
		iNavCreate.className = 'fa fa-2x fa-plus navButton';
		aNavCreate.appendChild(iNavCreate);
		aNavCreate.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE)
		{
			var oEditViewUI = new EditViewUI();
			oEditViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE);
		}, this.LayoutPanel, this.ActionsPanel, sMENU_ACTIVE_MODULE, null, false);

		// Save
		var aNavSave = document.createElement('a');
		aNavSave.id = 'ctlAtlanticToolbar_aNavSave';
		aNavSave.href = '#';
		aNavSave.style.display = 'none';
		tdNavRight.appendChild(aNavSave);
		var iNavSave = document.createElement('i');
		iNavSave.className = 'fa fa-2x fa-save navButton';
		aNavSave.appendChild(iNavSave);
		aNavSave.onclick = function()
		{
			alert('Save not attached');
		};
		// Save Duplicate
		var btnDynamicButtons_SaveDuplicate = document.createElement('a');
		btnDynamicButtons_SaveDuplicate.id = 'btnDynamicButtons_SaveDuplicate';
		btnDynamicButtons_SaveDuplicate.href = '#';
		btnDynamicButtons_SaveDuplicate.style.display = 'none';
		tdNavRight.appendChild(btnDynamicButtons_SaveDuplicate);
		var iNavSave = document.createElement('i');
		iNavSave.className = 'fa fa-2x fa-save navButton';
		iNavSave.style.color = 'red';
		btnDynamicButtons_SaveDuplicate.appendChild(iNavSave);
		btnDynamicButtons_SaveDuplicate.onclick = function()
		{
			alert('Save Duplicate not attached');
		};
		// Save Concurrent
		var btnDynamicButtons_SaveConcurrency = document.createElement('a');
		btnDynamicButtons_SaveConcurrency.id = 'btnDynamicButtons_SaveConcurrency';
		btnDynamicButtons_SaveConcurrency.href = '#';
		btnDynamicButtons_SaveConcurrency.style.display = 'none';
		tdNavRight.appendChild(btnDynamicButtons_SaveConcurrency);
		var iNavSave = document.createElement('i');
		iNavSave.className = 'fa fa-2x fa-save navButton';
		iNavSave.style.color = 'red';
		btnDynamicButtons_SaveConcurrency.appendChild(iNavSave);
		btnDynamicButtons_SaveConcurrency.onclick = function()
		{
			alert('Save Duplicate not attached');
		};

		// Edit
		var aNavEdit = document.createElement('a');
		aNavEdit.id = 'ctlAtlanticToolbar_aNavEdit';
		aNavEdit.href = '#';
		aNavEdit.style.display = 'none';
		tdNavRight.appendChild(aNavEdit);
		var iNavEdit = document.createElement('i');
		iNavEdit.className = 'fa fa-2x fa-edit navButton';
		aNavEdit.appendChild(iNavEdit);
		aNavEdit.onclick = function()
		{
			alert('Edit not attached');
		};

		var menu = new Array();
		var options =
		{ triggerOn    : 'click'
		, displayAround: 'trigger'
		, sizeStyle    : 'content'
		, mouseClick   : 'left'
		, left         : 0
		, top          : $(tblMobileMenu).height() + 2
		, position     : 'bottom'
		, containment  : '#' + navMenu.id
		};
		
		var arrValidModules = new Object();
		for ( var i = 0; i < arrDetailViewRelationship.length; i++ )
		{
			arrValidModules[arrDetailViewRelationship[i].MODULE_NAME] = null;
		}
		for ( var i = 0; i < result.length; i++ )
		{
			var sMODULE_NAME   = result[i].MODULE_NAME  ;
			var sDISPLAY_NAME  = result[i].DISPLAY_NAME ;
			var sRELATIVE_PATH = result[i].RELATIVE_PATH;
			// 11/15/2012 Paul.  The Surface app does not use the TabMenu DetailView relationship. 
			// 02/23/2013 Paul.  Use object for hash table lookup. 
			if ( (arrDetailViewRelationship.length == 0 || arrValidModules[sMODULE_NAME] !== undefined) && sMODULE_NAME != 'Home' )
			{
				var item = new Object();
				item.name  = L10n.ListTerm('moduleList', sMODULE_NAME);
				item.title = L10n.ListTerm('moduleList', sMODULE_NAME);
				item.img   = sIMAGE_SERVER + 'App_Themes/Six/images/' + sMODULE_NAME + '.gif';
				item.fun   = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME)
				{
					TabMenuUI_Clicked(sLayoutPanel, sActionsPanel, sMODULE_NAME);
				}, this.LayoutPanel, this.ActionsPanel, sMODULE_NAME);
				menu.push(item);
			}
		}
		var item = new Object();
		item.name    = '';
		item.disable = 'true';
		menu.push(item);
		for ( var i = 0; i < arrUserContextMenu.length; i++ )
		{
			if ( arrUserContextMenu[i].id == 'divHeader_lnkLogout' )
			{
				if ( !bWINDOWS_AUTH )
				{
					var item = new Object();
					item.name  = L10n.Term(arrUserContextMenu[i].text);
					item.title = L10n.Term(arrUserContextMenu[i].text);
					item.fun   =BindArguments(function(sLayoutPanel, sActionsPanel)
					{
						LoginViewUI_PageCommand(sLayoutPanel, sActionsPanel, 'Logout', null, null);
					}, this.LayoutPanel, this.ActionsPanel);
					menu.push(item);
				}
			}
			else
			{
				var item = new Object();
				item.name  = L10n.Term(arrUserContextMenu[i].text);
				item.title = L10n.Term(arrUserContextMenu[i].text);
				if ( arrUserContextMenu[i].action != null )
				{
					item.fun = BindArguments(function(action)
					{
						action();
					}, arrUserContextMenu[i].action);
				}
				menu.push(item);
			}
		}
		$(iNavBars).contextMenu('menu', menu, options);
	}
}

TabMenuUI_Mobile.prototype.Load = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, callback)
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
									callback(-1, SplendidError.FormatError(e, 'TabMenuUI_Mobile.Load'));
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
		callback(-1, SplendidError.FormatError(e, 'TabMenuUI_Mobile.Load'));
	}
}

