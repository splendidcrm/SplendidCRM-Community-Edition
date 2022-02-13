/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function TabMenuUI_Gentelella(sLayoutPanel, sActionsPanel)
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

TabMenuUI_Gentelella.prototype.divError           = function() { return this.divHeader_divError          ; }
TabMenuUI_Gentelella.prototype.divAuthenticated   = function() { return this.divHeader_divAuthenticated  ; }
TabMenuUI_Gentelella.prototype.spnWelcome         = function() { return this.divHeader_spnWelcome        ; }
TabMenuUI_Gentelella.prototype.spnUserName        = function() { return this.divHeader_spnUserName       ; }
TabMenuUI_Gentelella.prototype.spnLogout          = function() { return this.divHeader_spnLogout         ; }
TabMenuUI_Gentelella.prototype.lnkLogout          = function() { return this.divHeader_lnkLogout         ; }
// 08/22/2014 Paul.  Add SyncNow for offline client. 
TabMenuUI_Gentelella.prototype.spnSyncNow         = function() { return this.divHeader_spnSyncNow        ; }
TabMenuUI_Gentelella.prototype.lnkSyncNow         = function() { return this.divHeader_lnkSyncNow        ; }
TabMenuUI_Gentelella.prototype.divOnlineStatus    = function() { return this.divHeader_divOnlineStatus   ; }
TabMenuUI_Gentelella.prototype.divOfflineCache    = function() { return this.divHeader_divOfflineCache   ; }
TabMenuUI_Gentelella.prototype.divSplendidStorage = function() { return this.divHeader_divSplendidStorage; }
TabMenuUI_Gentelella.prototype.lnkCacheAll        = function() { return this.lnkHeaderCacheAll           ; }
TabMenuUI_Gentelella.prototype.lnkSystemLog       = function() { return this.lnkHeaderSystemLog          ; }
TabMenuUI_Gentelella.prototype.lnkSplendidStorage = function() { return this.lnkHeaderSplendidStorage    ; }

TabMenuUI_Gentelella.prototype.RenderHeader = function()
{
	try
	{
		TabMenuUI_Clear('ctlHeader');
		TabMenuUI_Clear('ctlTabMenu');
		TabMenuUI_Clear('ctlAtlanticToolbar');
		TabMenuUI_Clear('sidebar-menu');
		TabMenuUI_Clear('divNavTitle');
		TabMenuUI_Clear('divProfile');
		TabMenuUI_Clear('divContextMenu');
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'TabMenuUI_Gentelella.RenderHeader');
	}
}

// 12/06/2014 Paul.  LayoutMode is used on the Mobile view. 
TabMenuUI_Gentelella.prototype.ActivateTab = function(sMODULE_NAME, sID, sLAYOUT_MODE)
{
	if ( sMODULE_NAME != sMENU_ACTIVE_MODULE )
	{
		try
		{
			var liMenuItem = document.getElementById('ctlSidebarMenu_' + sMENU_ACTIVE_MODULE);
			if ( liMenuItem != null )
			{
				liMenuItem.className = '';
			}
			sMENU_ACTIVE_MODULE = sMODULE_NAME;
			liMenuItem = document.getElementById('ctlSidebarMenu_' + sMENU_ACTIVE_MODULE);
			if ( liMenuItem != null )
			{
				liMenuItem.className = 'active';
			}
		}
		catch(e)
		{
			SplendidError.SystemAlert(e, 'TabMenuUI_Gentelella.ActivateTab');
		}
	}
}

TabMenuUI_Gentelella.prototype.setContentHeight = function()
{
	// reset height
	$RIGHT_COL.css('min-height', $(window).height());

	var bodyHeight    = $BODY.outerHeight();
	var footerHeight  = $BODY.hasClass('footer_fixed') ? 0 : $FOOTER.height();
	var leftColHeight = $LEFT_COL.eq(1).height() + $SIDEBAR_FOOTER.height();
	var contentHeight = bodyHeight < leftColHeight ? leftColHeight : bodyHeight;

	// normalize content
	contentHeight -= $NAV_MENU.height() + footerHeight;

	$RIGHT_COL.css('min-height', contentHeight);
}

TabMenuUI_Gentelella.prototype.Render = function(sLayoutPanel, sActionsPanel, arrDetailViewRelationship, arrQuickCreate, result)
{
	var ctlSidebarMenu = document.getElementById('sidebar-menu');
	if ( ctlSidebarMenu != null )
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
		if ( ctlSidebarMenu.childNodes != null )
		{
			while ( ctlSidebarMenu.childNodes.length > 0 )
			{
				ctlSidebarMenu.removeChild(ctlSidebarMenu.firstChild);
			}
		}

		//<div id="divProfile" class="profile">
		//	<div class="profile_pic">
		//		<img src="images/img.jpg" alt="..." class="img-circle profile_img">
		//	</div>
		//	<div class="profile_info">
		//		<span>Welcome,</span>
		//		<h2>John Doe</h2>
		//	</div>
		//</div>
		var divProfile = document.getElementById('divProfile');
		if ( divProfile != null )
		{
			var divProfilePic = document.createElement('div');
			divProfilePic.className = 'profile_pic';
			divProfile.appendChild(divProfilePic);
			var imgUserPicture = document.createElement('img');
			imgUserPicture.className = 'img-circle profile_img';
			divProfilePic.appendChild(imgUserPicture);
			if ( Sql.IsEmptyString(Security.PICTURE()) )
				imgUserPicture.src = sREMOTE_SERVER + 'Include/images/SplendidCRM_Icon.gif';
			else
				imgUserPicture.src = Security.PICTURE();
			var divProfileInfo = document.createElement('div');
			divProfileInfo.className = 'profile_info';
			divProfile.appendChild(divProfileInfo);
			this.divHeader_spnWelcome = document.createElement('span');
			this.divHeader_spnWelcome.innerHTML = L10n.Term('.NTC_WELCOME')
			divProfileInfo.appendChild(this.divHeader_spnWelcome);
			var spnUserName = document.createElement('h2');
			spnUserName.innerHTML = Security.FULL_NAME();
			divProfileInfo.appendChild(spnUserName);
		}
		var divContextMenu = document.getElementById('divContextMenu');
		if ( divContextMenu )
		{
			var liContextMenu = document.createElement('li');
			liContextMenu.className = '';
			liContextMenu.style.whiteSpace = 'nowrap';
			divContextMenu.appendChild(liContextMenu);

			var tbl = document.createElement('div');
			tbl.style.display = 'table';
			liContextMenu.appendChild(tbl);
			var row = document.createElement('div');
			row.style.display = 'table-row';
			tbl.appendChild(row);
			var col1 = document.createElement('div');
			col1.style.display = 'table-cell';
			row.appendChild(col1);
			var col2 = document.createElement('div');
			col2.style.display = 'table-cell';
			col2.style.verticalAlign = 'top';
			row.appendChild(col2);
			
			var imgUserPicture = document.createElement('img');
			imgUserPicture.style.width  = '55px';
			imgUserPicture.style.height = '45px';
			col1.appendChild(imgUserPicture);
			if ( Sql.IsEmptyString(Security.PICTURE()) )
				imgUserPicture.src = sREMOTE_SERVER + 'Include/images/SplendidCRM_Icon.gif';
			else
				imgUserPicture.src = Security.PICTURE();
			
			var aUserProfile = document.createElement('a');
			aUserProfile.href      = 'javascript:;';
			aUserProfile.className = 'user-profile dropdown-toggle';
			$(aUserProfile).attr('data-toggle', 'dropdown');
			$(aUserProfile).attr('aria-expanded', 'false');
			col2.appendChild(aUserProfile);
			this.divHeader_spnUserName = document.createElement('span');
			this.divHeader_spnUserName.innerHTML = Security.FULL_NAME();
			aUserProfile.appendChild(this.divHeader_spnUserName);
			
			var spnDown = document.createElement('span');
			spnDown.className = 'glyphicon glyphicon-triangle-bottom';
			spnDown.style.paddingLeft = '5px';
			aUserProfile.appendChild(spnDown);
			
			this.divHeader_divOnlineStatus = document.createElement('div');
			this.divHeader_divOnlineStatus.id = 'divHeader_divOnlineStatus';
			aUserProfile.appendChild(this.divHeader_divOnlineStatus);
			this.divHeader_divOnlineStatus.innerHTML = bgPage.GetIsOffline() ? L10n.Term('.LBL_OFFLINE') : L10n.Term('.LBL_ONLINE');

			var ulContextMenu = document.createElement('ul');
			ulContextMenu.className = 'dropdown-menu dropdown-usermenu pull-right';
			col2.appendChild(ulContextMenu);

			for ( var i = 0; i < arrUserContextMenu.length; i++ )
			{
				var liMenuItem = document.createElement('li');
				ulContextMenu.appendChild(liMenuItem);
				var a = document.createElement('a');
				a.id        = arrUserContextMenu[i].id;
				a.appendChild(document.createTextNode(L10n.Term(arrUserContextMenu[i].text)));
				if ( arrUserContextMenu[i].action != null )
				{
					a.onclick = BindArguments(function(action)
					{
						action();
					}, arrUserContextMenu[i].action);
				}
				liMenuItem.appendChild(a);
			}
			// 04/08/2017 Paul.  The following links were created by arrUserContextMenu above. 
			this.lnkHeaderSystemLog       = document.getElementById('lnkHeaderSystemLog'      );
			this.lnkHeaderSplendidStorage = document.getElementById('lnkHeaderSplendidStorage');
			this.lnkHeaderCacheAll        = document.getElementById('lnkHeaderCacheAll'       );
			this.divHeader_lnkLogout      = document.getElementById('divHeader_lnkLogout'     );
			if ( this.lnkHeaderSplendidStorage != null )
				this.lnkHeaderSplendidStorage.style.display = (bgPage.GetEnableOffline() && !bgPage.GetIsOffline()) ? 'inline' : 'none';
			if ( this.lnkHeaderCacheAll != null )
				this.lnkHeaderCacheAll.style.display = (bgPage.GetEnableOffline() && !bgPage.GetIsOffline()) ? 'inline' : 'none';
			
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
		}

		//<div class="menu_section">
		//	<h3 style="display: none;">General</h3>
		//	<ul class="nav side-menu">
		//		<li><a><i class="fa fa-home"></i>Home <span class="fa fa-chevron-down"></span></a>
		//			<ul class="nav child_menu">
		//				<li><a href="index.html">Dashboard</a></li>
		//				<li><a href="index2.html">Dashboard2</a></li>
		//				<li><a href="index3.html">Dashboard3</a></li>
		//			</ul>
		//		</li>
		var divMenuSection = document.createElement('div');
		divMenuSection.className = 'menu_section';
		ctlSidebarMenu.appendChild(divMenuSection);
		var h3SectionTitle = document.createElement('h3');
		h3SectionTitle.style.display = 'none';
		h3SectionTitle.innerHTML     = 'General';
		divMenuSection.appendChild(h3SectionTitle);
		var ulMenuList = document.createElement('ul');
		ulMenuList.className = 'nav side-menu';
		divMenuSection.appendChild(ulMenuList);

		this.divHeader_divError = document.getElementById('divBootstrapError');
		if ( SplendidError.sLastError != null )
			this.divHeader_divError.innerHTML = SplendidError.sLastError;

		// 05/19/2013 Paul.  Apply config customizations of header logo. 
		//var sCompanyHomeImage  = bgPage.SplendidCache.Config('header_home_image');
		//if ( Sql.IsEmptyString(sCompanyHomeImage) )
		//	sCompanyHomeImage = '~/Include/images/SplendidCRM_Icon.gif';
		var sCompanyHomeImage  = bgPage.SplendidCache.Config('header_logo_image');
		if ( Sql.IsEmptyString(sCompanyHomeImage) || sCompanyHomeImage == 'SplendidCRM_Logo.gif' )
			sCompanyHomeImage = '~/Include/images/SplendidCRM_Logo.gif';
		if ( StartsWith(sCompanyHomeImage, '~/') )
			sCompanyHomeImage = sCompanyHomeImage.substring(2, sCompanyHomeImage.length);
		// 01/07/2018 Paul.  Correct the standard folder for logo images. 
		else if ( !StartsWith(sCompanyHomeImage, 'http') )
			sCompanyHomeImage = 'Include/images/' + sCompanyHomeImage;
		var divNavTitle = document.getElementById('divNavTitle');
		if ( divNavTitle != null )
		{
			while ( divNavTitle.childNodes.length > 0 )
			{
				divNavTitle.removeChild(divNavTitle.firstChild);
			}
			var aReload = document.createElement('a');
			aReload.title     = sPRODUCT_TITLE;
			aReload.className = 'site_title';
			aReload.onclick   = function()
			{
				Reload();
			};
			divNavTitle.appendChild(aReload);
			var imgCompany = document.createElement('img');
			imgCompany.src               = sIMAGE_SERVER + sCompanyHomeImage;
			imgCompany.alt               = sPRODUCT_TITLE;
			imgCompany.style.height      = '60px';
			imgCompany.style.width       = '204px';
			imgCompany.style.borderWidth = '0px' ;
			aReload.appendChild(imgCompany);
		}
		
		// 02/23/2013 Paul.  Use object for hash table lookup. 
		var arrValidModules = new Object();
		for ( var i = 0; i < arrDetailViewRelationship.length; i++ )
		{
			arrValidModules[arrDetailViewRelationship[i].MODULE_NAME] = null;
		}
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
				
				var liMenuItem = document.createElement('li');
				liMenuItem.id = 'ctlSidebarMenu_' + sMODULE_NAME;
				ulMenuList.appendChild(liMenuItem);
				// 04/18/2017 Paul.  We want to allow clicking on name to navigate to list.
				var div = document.createElement('div');
				liMenuItem.appendChild(div);
				var aMenuItem = document.createElement('span');
				div.appendChild(aMenuItem);
				aMenuItem.innerHTML = L10n.Term(sDISPLAY_NAME);
				//aMenuItem.href      = '#';
				//aMenuItem.onclick = BindArguments(function(sMODULE_NAME)
				//{
				//	TabMenuUI_Clicked(sLayoutPanel, sActionsPanel, sMODULE_NAME);
				//}, sMODULE_NAME);
				BindArguments(function(aMenuItem, liMenuItem, sMODULE_NAME)
				{
					aMenuItem.onclick = function(e)
					{
						// 06/27/2017 Paul.  On a small device, do not treat menu as direct link to list. 
						// This is because a finger is not exact enough to make the menu appear. 
						// 06/28/2017 Paul.  ChatDashboard is an exception that requires a single click to activate. 
						if ( !$BODY.hasClass('nav-sm') || sMODULE_NAME == 'ChatDashboard' )
						{
							if ( !e )
								e = window.event;
							// IE9 & Other Browsers
							if ( e.stopPropagation )
								e.stopPropagation();
							// IE8 and Lower
							else if ( window.event )
								e.cancelBubble = true;

							TabMenuUI_CreateModule(sLayoutPanel, sActionsPanel, sMODULE_NAME);
						}
					};
					liMenuItem.onclick = function(e)
					{
						if ( !e )
							e = window.event;
						// IE9 & Other Browsers
						if ( e.stopPropagation )
							e.stopPropagation();
						// IE8 and Lower
						else if ( window.event )
							e.cancelBubble = true;

						var $li = $(liMenuItem);
						$('ul:first', $li).slideToggle(function()
						{
							ctlActiveMenu.setContentHeight();
						});
					};
				}, aMenuItem, liMenuItem, sMODULE_NAME)();

				if ( sMODULE_NAME == sMENU_ACTIVE_MODULE )
					liMenuItem.className = 'active';
				// 04/30/2017 Paul.  Apply access rights. 
				this.ActionsPopup(sLayoutPanel, sActionsPanel, sMODULE_NAME, sDISPLAY_NAME, liMenuItem, aMenuItem, nEDIT_ACLACCESS);
			}
		}
		/*
		$SIDEBAR_MENU.find('a').on('click', function(ev)
		{
			var $li = $(this).parent();
			if ( $li.is('.active') )
			{
				$li.removeClass('active active-sm');
				$('ul:first', $li).slideUp(function()
				{
					ctlActiveMenu.setContentHeight();
				});
			}
			else
			{
				// prevent closing menu if we are on child menu
				if ( !$li.parent().is('.child_menu') )
				{
					$SIDEBAR_MENU.find('li').removeClass('active active-sm');
					$SIDEBAR_MENU.find('li ul').slideUp();
				}
				$li.addClass('active');
				$('ul:first', $li).slideDown(function()
				{
					ctlActiveMenu.setContentHeight();
				});
			}
		});
		$SIDEBAR_MENU.find('a').filter(function ()
		{
			return this.href == CURRENT_URL;
		}).parent('li').addClass('current-page').parents('ul').slideDown(function()
		{
			ctlActiveMenu.setContentHeight();
		}).parent().addClass('active');

		// recompute content when resizing
		$(window).smartresize(function()
		{
			ctlActiveMenu.setContentHeight();
		});
		*/
		ctlActiveMenu.setContentHeight();
		/*
		this.divHeader_divOfflineCache = document.createElement('div');
		this.divHeader_divOfflineCache.id                  = 'divHeader_divOfflineCache';
		this.divHeader_divOfflineCache.className           = 'error';
		this.divHeader_divOfflineCache.style.verticalAlign = 'top';
		this.divHeader_divOfflineCache.style.height        = '60px';
		this.divHeader_divOfflineCache.style.width         = '100%';
		this.divHeader_divOfflineCache.style.overflowY     = 'scroll';
		this.divHeader_divOfflineCache.style.display       = 'none';
		ctlSidebarMenu.appendChild(this.divHeader_divOfflineCache);
		*/
	}
}

// 04/30/2017 Paul.  Apply access rights. 
TabMenuUI_Gentelella.prototype.ActionsPopup = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sDISPLAY_NAME, liMenuItem, aMenuItem, nEDIT_ACLACCESS)
{
	try
	{
		// 05/08/2017 Paul.  ChatDashboard does not have sub-items. 
		if ( sMODULE_NAME == 'ChatDashboard' )
			return;

		//<ul class="nav child_menu">
		//	<li><a href="index.html">Dashboard</a></li>
		//	<li><a href="index2.html">Dashboard2</a></li>
		//	<li><a href="index3.html">Dashboard3</a></li>
		//</ul>
		var spnDown = document.createElement('span');
		spnDown.className = 'fa fa-chevron-down';
		aMenuItem.appendChild(spnDown);
		spnDown.onclick = function(e)
		{
			if ( !e )
				e = window.event;
			// IE9 & Other Browsers
			if ( e.stopPropagation )
				e.stopPropagation();
			// IE8 and Lower
			else if ( window.event )
				e.cancelBubble = true;

			var $li = $(liMenuItem);
			$('ul:first', $li).slideToggle(function()
			{
				ctlActiveMenu.setContentHeight();
			});
		};

		var ulActions = document.createElement('ul');
		ulActions.id = 'pnlModuleActions' + sMODULE_NAME;
		ulActions.className = 'nav child_menu';
		liMenuItem.appendChild(ulActions)

		// 02/24/2013 Paul.  For a calendar, create a call or a meeting. 
		if ( sMODULE_NAME == 'Calendar' )
		{
			// 04/30/2017 Paul.  Apply access rights. 
			if ( nEDIT_ACLACCESS >= 0 )
			{
				// 06/28/2017 Paul.  We need a item for the calendar itself as base item is disabled on phone. 
				var liShowCalendar = document.createElement('li');
				ulActions.appendChild(liShowCalendar);
				var aShowCalendar = document.createElement('a');
				aShowCalendar.href = '#';
				aShowCalendar.innerHTML = L10n.Term(sMODULE_NAME + '.LBL_LIST_FORM_TITLE');
				aShowCalendar.onclick = function(e)
				{
					if ( !e )
						e = window.event;
					// IE9 & Other Browsers
					if ( e.stopPropagation )
						e.stopPropagation();
					// IE8 and Lower
					else if ( window.event )
						e.cancelBubble = true;
					// 04/08/2017 Paul.  If the small menu is begin displayed, then we have to hide it the sub-menu manually. 
					if ( !$BODY.hasClass('nav-md') )
					{
						var $li = $(liMenuItem);
						$('ul:first', $li).slideToggle(function()
						{
							//ctlActiveMenu.setContentHeight();
						});
					}
					TabMenuUI_CreateModule(sLayoutPanel, sActionsPanel, sMODULE_NAME);
				};
				liShowCalendar.appendChild(aShowCalendar);
				
				// 01/10/2018 Paul.  Make sure Call or Meeting module is enabled. 
				var bgPage = chrome.extension.getBackgroundPage();
				if ( bgPage.SplendidCache.Module('Calls') !== undefined )
				{
					var liCreateCall = document.createElement('li');
					ulActions.appendChild(liCreateCall);
					var aCreateCall = document.createElement('a');
					aCreateCall.href = '#';
					aCreateCall.innerHTML = L10n.Term(sMODULE_NAME + '.LNK_NEW_CALL');
					aCreateCall.onclick = function(e)
					{
						if ( !e )
							e = window.event;
						// IE9 & Other Browsers
						if ( e.stopPropagation )
							e.stopPropagation();
						// IE8 and Lower
						else if ( window.event )
							e.cancelBubble = true;
						// 04/08/2017 Paul.  If the small menu is begin displayed, then we have to hide it the sub-menu manually. 
						if ( !$BODY.hasClass('nav-md') )
						{
							var $li = $(liMenuItem);
							$('ul:first', $li).slideToggle(function()
							{
								//ctlActiveMenu.setContentHeight();
							});
						}
						var oEditViewUI = new EditViewUI();
						oEditViewUI.Load(sLayoutPanel, sActionsPanel, 'Calls', null, false);
					};
					liCreateCall.appendChild(aCreateCall);
				}
				// 01/10/2018 Paul.  Make sure Call or Meeting module is enabled. 
				if ( bgPage.SplendidCache.Module('Meetings') !== undefined )
				{
					var liCreateMeeting = document.createElement('li');
					ulActions.appendChild(liCreateMeeting);
					var aCreateMeeting = document.createElement('a');
					aCreateMeeting.href      = '#';
					aCreateMeeting.innerHTML = L10n.Term(sMODULE_NAME + '.LNK_NEW_MEETING');
					aCreateMeeting.onclick = function(e)
					{
						if ( !e )
							e = window.event;
						// IE9 & Other Browsers
						if ( e.stopPropagation )
							e.stopPropagation();
						// IE8 and Lower
						else if ( window.event )
							e.cancelBubble = true;
						// 04/08/2017 Paul.  If the small menu is begin displayed, then we have to hide it the sub-menu manually. 
						if ( !$BODY.hasClass('nav-md') )
						{
							var $li = $(liMenuItem);
							$('ul:first', $li).slideToggle(function()
							{
								//ctlActiveMenu.setContentHeight();
							});
						}
						var oEditViewUI = new EditViewUI();
						oEditViewUI.Load(sLayoutPanel, sActionsPanel, 'Meetings', null, false);
					};
					liCreateMeeting.appendChild(aCreateMeeting);
				}
			}
		}
		else if ( sMODULE_NAME == 'Dashboard' )
		{
			this.ReloadDashboard(sLayoutPanel, sActionsPanel, sMODULE_NAME, function(status, message)
			{
			});
		}
		else if ( sMODULE_NAME == 'Home' )
		{
			this.ReloadDashboard(sLayoutPanel, sActionsPanel, sMODULE_NAME, function(status, message)
			{
			});
		}
		else
		{
			// 04/30/2017 Paul.  Apply access rights. 
			if ( nEDIT_ACLACCESS >= 0 )
			{
				var liCreate = document.createElement('li');
				ulActions.appendChild(liCreate);
				var aCreate = document.createElement('a');
				aCreate.href = '#';
				aCreate.innerHTML = L10n.Term(sMODULE_NAME + '.LBL_NEW_FORM_TITLE');
				aCreate.onclick = function(e)
				{
					if ( !e )
						e = window.event;
					// IE9 & Other Browsers
					if ( e.stopPropagation )
						e.stopPropagation();
					// IE8 and Lower
					else if ( window.event )
						e.cancelBubble = true;
					// 04/08/2017 Paul.  If the small menu is begin displayed, then we have to hide it the sub-menu manually. 
					if ( !$BODY.hasClass('nav-md') )
					{
						var $li = $(liMenuItem);
						$('ul:first', $li).slideToggle(function()
						{
							//ctlActiveMenu.setContentHeight();
						});
					}
					var oEditViewUI = new EditViewUI();
					oEditViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, null, false);
				};
				liCreate.appendChild(aCreate);
			}

			var liList = document.createElement('li');
			ulActions.appendChild(liList);
			var aList = document.createElement('a');
			aList.href      = '#';
			aList.innerHTML = L10n.Term(sDISPLAY_NAME);
			aList.onclick = function(e)
			{
				if ( !e )
					e = window.event;
				// IE9 & Other Browsers
				if ( e.stopPropagation )
					e.stopPropagation();
				// IE8 and Lower
				else if ( window.event )
					e.cancelBubble = true;
				// 04/08/2017 Paul.  If the small menu is begin displayed, then we have to hide it the sub-menu manually. 
				if ( !$BODY.hasClass('nav-md') )
				{
					var $li = $(liMenuItem);
					$('ul:first', $li).slideToggle(function()
					{
						//ctlActiveMenu.setContentHeight();
					});
				}
				TabMenuUI_CreateModule(sLayoutPanel, sActionsPanel, sMODULE_NAME);
			};
			liList.appendChild(aList);
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'TabMenuUI_Gentelella.ActionsPopup ' + sMODULE_NAME);
	}
}

TabMenuUI_Gentelella.prototype.ReloadDashboard = function(sLayoutPanel, sActionsPanel, sCATEGORY, callback)
{
	var bgPage = chrome.extension.getBackgroundPage();
	bgPage.AuthenticatedMethod(function(status, message)
	{
		if ( status == 1 )
		{
			// 06/14/2017 Paul.  The category can be Home or Dashboard. 
			var sMODULE_NAME = sCATEGORY;
			var ulActions = document.getElementById('pnlModuleActions' + sMODULE_NAME);
			if ( ulActions != null )
			{
				while ( ulActions.childNodes.length > 0 )
				{
					ulActions.removeChild(ulActions.firstChild);
				}
				var liMenuItem = ulActions.parentNode;
				var liCreate = document.createElement('li');
				ulActions.appendChild(liCreate);
				var aCreate = document.createElement('a');
				aCreate.href = '#';
				aCreate.innerHTML = L10n.Term(sMODULE_NAME + '.LBL_NEW_FORM_TITLE');
				aCreate.onclick = function(e)
				{
					if ( !e )
						e = window.event;
					if ( e.stopPropagation )
						e.stopPropagation();
					else if ( window.event )
						e.cancelBubble = true;
					if ( !$BODY.hasClass('nav-md') )
					{
						var $li = $(liMenuItem);
						$('ul:first', $li).slideToggle(function()
						{
							//ctlActiveMenu.setContentHeight();
						});
					}
					var oDashboardEditUI = new DashboardEditUI(sCATEGORY);
					oDashboardEditUI.Load(sLayoutPanel, sActionsPanel, null);
				};
				liCreate.appendChild(aCreate);
		
				var sSEARCH_FILTER = "ASSIGNED_USER_ID eq \'" + Security.USER_ID() + "\' and CATEGORY eq \'" + sCATEGORY + "\'";
				bgPage.ListView_LoadModule('Dashboard', 'NAME', 'asc', 'ID, NAME', sSEARCH_FILTER, null, function(status, message, __total)
				{
					if ( status == 1 )
					{
						var rows = message;
						if ( rows.length > 0 )
						{
							this.RenderDashboards(sLayoutPanel, sActionsPanel, sCATEGORY, ulActions, rows);
						}
						else
						{
							// 06/01/2017 Paul.  Load default dashboards if none are set. 
							sSEARCH_FILTER = "ASSIGNED_USER_ID is null and CATEGORY eq \'" + sCATEGORY + "\'";
							bgPage.ListView_LoadModule('Dashboard', 'NAME', 'asc', 'ID, NAME', sSEARCH_FILTER, null, function(status, message, __total)
							{
								if ( status == 1 )
								{
									rows = message;
									// 06/02/2017 Paul.  If last dashboard not set, then show the first default dashboard. 
									var sCURRENT_DASHBOARD_ID = null;
									if ( window.localStorage )
										sCURRENT_DASHBOARD_ID = localStorage[sCATEGORY + 'LastDashboard'];
									else
										sCURRENT_DASHBOARD_ID = getCookie(sCATEGORY + 'LastDashboard');
									if ( Sql.IsEmptyString(sCURRENT_DASHBOARD_ID) && rows.length > 0 )
									{
										sCURRENT_DASHBOARD_ID = Sql.ToString(rows[0]['ID']);
										if ( window.localStorage )
											localStorage[sCATEGORY + 'LastDashboard'] = sCURRENT_DASHBOARD_ID;
										else
											setCookie(sCATEGORY + 'LastDashboard', sCURRENT_DASHBOARD_ID, 180);
									}
									this.RenderDashboards(sLayoutPanel, sActionsPanel, sCATEGORY, ulActions, rows);
								}
								else
								{
									SplendidError.SystemMessage(message);
								}
								if ( callback != null )
								{
									callback(status, message);
								}
							}, this);
						}
					}
					else
					{
						SplendidError.SystemMessage(message);
					}
					if ( callback != null )
					{
						callback(status, message);
					}
				}, this);
			}
		}
	}, this);
}

TabMenuUI_Gentelella.prototype.RenderDashboards = function(sLayoutPanel, sActionsPanel, sCATEGORY, ulActions, rows)
{
	for ( var i = 0; i < rows.length; i++ )
	{
		var sID   = rows[i].ID;
		var sNAME = rows[i].NAME;
		BindArguments(function(sID, sNAME)
		{
			var liList = document.createElement('li');
			ulActions.appendChild(liList);
			var aList = document.createElement('a');
			aList.href      = '#';
			aList.innerHTML = sNAME;
			try
			{
				aList.onclick = function(e)
				{
					if ( !e )
						e = window.event;
					if ( e.stopPropagation )
						e.stopPropagation();
					else if ( window.event )
						e.cancelBubble = true;
					if ( !$BODY.hasClass('nav-md') )
					{
						var $li = $(liList);
						$('ul:first', $li).slideToggle(function()
						{
							//ctlActiveMenu.setContentHeight();
						});
					}
					var oDashboardUI = new DashboardUI(sCATEGORY);
					oDashboardUI.Load(sLayoutPanel, sActionsPanel, sID, function(status, message)
					{
					});
				};
				liList.appendChild(aList);
				var spnEdit = document.createElement('span');
				spnEdit.className = 'fa fa-2x fa-edit';
				spnEdit.title     = L10n.Term('.LBL_EDIT_BUTTON_TITLE');
				aList.appendChild(spnEdit);
				spnEdit.onclick = function(e)
				{
					if ( !e )
						e = window.event;
					// IE9 & Other Browsers
					if ( e.stopPropagation )
						e.stopPropagation();
					// IE8 and Lower
					else if ( window.event )
						e.cancelBubble = true;
					var oDashboardEditUI = new DashboardEditUI(sCATEGORY);
					oDashboardEditUI.Load(sLayoutPanel, sActionsPanel, sID);
				};
			}
			catch(e)
			{
				SplendidError.SystemMessage(e.message);
			}
		}, sID, sNAME)();
	}
}

TabMenuUI_Gentelella.prototype.Load = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, callback)
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
									TabMenuUI_Clear('sidebar-menu');
									TabMenuUI_Clear('divNavTitle');
									TabMenuUI_Clear('divProfile');
									TabMenuUI_Clear('divContextMenu');
									
									ctlActiveMenu.Render(sLayoutPanel, sActionsPanel, arrDetailViewRelationship, arrQuickCreate, result);
									callback(1, null);
								}
								catch(e)
								{
									callback(-1, SplendidError.FormatError(e, 'TabMenuUI_Gentelella.Load'));
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
		callback(-1, SplendidError.FormatError(e, 'TabMenuUI_Gentelella.Load'));
	}
}

