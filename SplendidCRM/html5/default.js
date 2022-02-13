/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function NetworkStatusChanged()
{
	var divHeader = document.getElementById('tblHeader');
	if ( divHeader != null )
		divHeader.style.backgroundColor = bIS_OFFLINE ? '#efefef' : '#ffd14e';
	var divHeader_divOnlineStatus = ctlActiveMenu.divOnlineStatus();
	if ( divHeader_divOnlineStatus != null )
		divHeader_divOnlineStatus.innerHTML =  bIS_OFFLINE ? L10n.Term('.LBL_OFFLINE') : L10n.Term('.LBL_ONLINE');
	
	var sLayoutPanel  = 'divMainLayoutPanel';
	var sActionsPanel = 'divMainActionsPanel';
	LoginViewUI_UpdateHeader(sLayoutPanel, sActionsPanel, true);
}

function ShowSystemLog()
{
	var $dialog = $('<div id="divSystemLog" style="white-space: nowrap;"></div>');
	$dialog.dialog(
	{
		  modal    : true
		, resizable: (navigator.userAgent.indexOf('iPad') > 0 ? false : true)
		// 04/13/2017 Paul.  Use Bootstrap for responsive design.
		, position : { of: '#divMainPageContent' }
		, width    : $('#divMainPageContent').width() > 0 ? ($('#divMainPageContent').width() - 60) : 800
		// 04/26/2017 Paul.  Use Bootstrap for responsive design.
		//, height   : (navigator.userAgent.indexOf('iPad') > 0 ? 'auto' : ($(window).height() > 0 ? $(window).height() - 60 : 800))
		// 06/21/2017 Paul.  Adjust the minimum height. 
		, height   : $('#divMainPageContent').height() > 400 ? $('#divMainPageContent').height() - 60 : 800
		, title    : 'System Log'
		, create   : function(event, ui)
		{
			var divSystemLog = document.getElementById('divSystemLog');
			if ( navigator.userAgent.indexOf('iPad') > 0 )
			{
				divSystemLog.style.height = 'auto';
			}
			divSystemLog.innerHTML = '<table border=0 cellpadding=2 cellspacing=0><tr><td>' + SplendidError.arrErrorLog.join('</td></tr><tr><td>\n') + '</td></tr></table>';
		}
		, close    : function(event, ui)
		{
			$dialog.dialog('destroy');
			// 10/17/2011 Paul.  We have to remove the new HTML, otherwise there will be multiple definitions for divPopupLayoutPanel. 
			var divSystemLog = document.getElementById('divSystemLog');
			divSystemLog.parentNode.removeChild(divSystemLog);
		}
	});
}

function ShowSplendidStorage()
{
	var $dialog = $('<div id="divSplendidStorage" style="white-space: nowrap;"></div>');
	$dialog.dialog(
	{
		  modal    : true
		, resizable: (navigator.userAgent.indexOf('iPad') > 0 ? false : true)
		// 04/13/2017 Paul.  Use Bootstrap for responsive design.
		, position : { of: '#divMainPageContent' }
		, width    : $('#divMainPageContent').width() > 0 ? ($('#divMainPageContent').width() - 60) : 800
		// 04/26/2017 Paul.  Use Bootstrap for responsive design.
		//, height   : (navigator.userAgent.indexOf('iPad') > 0 ? 'auto' : ($(window).height() > 0 ? $(window).height() - 60 : 800))
		, height   : $('#divMainPageContent').height() > 0 ? $('#divMainPageContent').height() - 60 : 800
		, title    : 'Splendid Storage'
		, create   : function(event, ui)
		{
			var nTotalSize = 0;
			var arrKeys = new Array();
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.SplendidStorage.foreach(function(status, key, value)
			{
				if ( status == 1 )
				{
					nTotalSize += key.length + value.length;
					arrKeys.push('<td valign="top">' + value.length.toString() + '</td><td>' + key + '</td>');
				}
				else if ( status == 0 )
				{
					var divSplendidStorage = document.getElementById('divSplendidStorage');
					if ( navigator.userAgent.indexOf('iPad') > 0 )
					{
						divSplendidStorage.style.height = 'auto';
					}
					divSplendidStorage.innerHTML = '<table border=0 cellpadding=2 cellspacing=0><tr>' + arrKeys.join('</tr><tr>\n') + '<tr><td colspan=2><br />\n' 
						+ nTotalSize.toString() + ' characters ' + (SplendidStorage.db == null ? 'localStorage' : 'Web SQL storage') 
						+ ' <input id="SplendidStorage_btnClear" type="submit" value="' + L10n.Term('.LBL_CLEAR_BUTTON_LABEL') + '" class="button" />'
						+ ' <input id="SplendidStorage_btnClearAll" type="submit" value="' + L10n.Term('.LBL_CLEARALL') + '" class="button" />'
						+ '</td></tr></table>';
					
					var btnClear = document.getElementById('SplendidStorage_btnClear');
					btnClear.onclick = function()
					{
						LoginViewUI_ClearModuleLists(false, function(status, message)
						{
							$dialog.dialog('destroy');
							var divSplendidStorage = document.getElementById('divSplendidStorage');
							divSplendidStorage.parentNode.removeChild(divSplendidStorage);
						});
					}
					
					var btnClearAll = document.getElementById('SplendidStorage_btnClearAll');
					btnClearAll.onclick = function()
					{
						LoginViewUI_ClearModuleLists(true, function(status, message)
						{
							$dialog.dialog('destroy');
							var divSplendidStorage = document.getElementById('divSplendidStorage');
							divSplendidStorage.parentNode.removeChild(divSplendidStorage);
						});
					}
				}
				else if ( status == -1 )
				{
					var divSplendidStorage = document.getElementById('divSplendidStorage');
					divSplendidStorage.innerHTML = key;
				}
			});
		}
		, close    : function(event, ui)
		{
			$dialog.dialog('destroy');
			// 10/17/2011 Paul.  We have to remove the new HTML, otherwise there will be multiple definitions for divPopupLayoutPanel. 
			var divSplendidStorage = document.getElementById('divSplendidStorage');
			divSplendidStorage.parentNode.removeChild(divSplendidStorage);
		}
	});
}

var bCacheAllModulesBusy = false;

function CacheAllModuleItems_Next(sMODULE_NAME, arrIDS, callback)
{
	try
	{
		if ( bCacheAllModulesBusy && arrIDS.length > 0 )
		{
			var sID = arrIDS.pop();
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.DetailView_LoadItem(sMODULE_NAME, sID, function(status, message)
			{
				if ( status == 1 )
				{
					var row = message;
					callback(2, 'Loaded ' + sMODULE_NAME + ': ' + row['NAME']);
					CacheAllModuleItems_Next(sMODULE_NAME, arrIDS, callback);
				}
				else
				{
					callback(status, message);
				}
			});
		}
		else
		{
			callback(1, '');
		}
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'CacheAllModuleItems_Next'));
	}
}

function CacheAllModules_Next(arrMODULE_NAMES)
{
	try
	{
		if ( bCacheAllModulesBusy && arrMODULE_NAMES.length > 0 )
		{
			var sMODULE_NAME = arrMODULE_NAMES.pop();
			SplendidError.SystemMessage('Loading ' + sMODULE_NAME);
			
			var sGRID_NAME = sMODULE_NAME + '.ListView' + sPLATFORM_LAYOUT;
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.ListView_LoadLayout(sGRID_NAME, function(status, message)
			{
				if ( status == 1 )
				{
					var layout = message;
					var oListViewUI = new ListViewUI();
					var sSELECT_FIELDS = oListViewUI.GridColumns(layout);
					var sLIST_VIEW_SORT_FIELD       = 'NAME';
					var sLIST_VIEW_SORT_DIRECTION   = 'asc';
					var sLIST_VIEW_SEARCH_FILTER    = '';
					bgPage.ListView_LoadModule(sMODULE_NAME, sLIST_VIEW_SORT_FIELD, sLIST_VIEW_SORT_DIRECTION, sSELECT_FIELDS, sLIST_VIEW_SEARCH_FILTER, function(status, message)
					{
						if ( status == 1 )
						{
							var rows = message;
							var arrIDS = new Array();
							for ( var i = 0; i < rows.length; i++ )
							{
								var row = rows[i];
								arrIDS.push(row['ID']);
							}
							CacheAllModuleItems_Next(sMODULE_NAME, arrIDS, function(status, message)
							{
								if ( status == 1 )
								{
									CacheAllModules_Next(arrMODULE_NAMES);
								}
								else
								{
									SplendidError.SystemMessage(message);
								}
							});
						}
						else
						{
							SplendidError.SystemMessage(message);
						}
					});
				}
			});
		}
		else
		{
			SplendidError.SystemMessage('');
			var lnkHeaderCacheAll = ctlActiveMenu.lnkCacheAll();
			if ( lnkHeaderCacheAll != null )
				lnkHeaderCacheAll.innerHTML = L10n.Term('.LBL_CACHE_ALL');
			bCacheAllModulesBusy = false;
		}
	}
	catch(e)
	{
		SplendidError.SystemMessage(SplendidError.FormatError(e, 'CacheModule_Next'));
	}
}

// 04/02/2015 Paul.  DetailViewRelationshipExists was missing. 
function DetailViewRelationshipExists(arrDetailViewRelationship, sMODULE_NAME)
{
	var bFound = false;
	if ( arrDetailViewRelationship != null )
	{
		for ( var i = 0; i < arrDetailViewRelationship.length; i++ )
		{
			if ( arrDetailViewRelationship[i].MODULE_NAME == sMODULE_NAME )
			{
				bFound = true;
				break;
			}
		}
	}
	return bFound;
}

function CacheAllModules()
{
	try
	{
		if ( bCacheAllModulesBusy )
		{
			bCacheAllModulesBusy = false;
			var lnkHeaderCacheAll = ctlActiveMenu.lnkCacheAll();
			if ( lnkHeaderCacheAll != null )
				lnkHeaderCacheAll.innerHTML = L10n.Term('.LBL_CACHE_ALL');
		}
		else if ( !bIS_OFFLINE && confirm(L10n.Term('.NTC_CACHE_CONFIRMATION')) )
		{
			var lnkHeaderCacheAll = ctlActiveMenu.lnkCacheAll();
			if ( lnkHeaderCacheAll != null )
				lnkHeaderCacheAll.innerHTML = L10n.Term('.LBL_STOP_CACHING');
			bCacheAllModulesBusy = true;
			
			// 12/06/2014 Paul.  The TabMenu is not based on the platform layout. 
			var sDETAIL_NAME = 'TabMenu';
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.DetailViewRelationships_LoadLayout(sDETAIL_NAME, function(status, message)
			{
				sDETAIL_NAME += sPLATFORM_LAYOUT;
				if ( status == 1 )
				{
					var arrDetailViewRelationship = message;
					bgPage.TabMenu_Load(function(status, message)
					{
						if ( status == 1 )
						{
							try
							{
								var result = message;
								var arrMODULE_NAMES = new Array();
								for ( var i = 0; i < result.length; i++ )
								{
									var sMODULE_NAME = result[i].MODULE_NAME;
									if ( DetailViewRelationshipExists(arrDetailViewRelationship, sMODULE_NAME) )
									{
										arrMODULE_NAMES.push(sMODULE_NAME);
									}
								}
								CacheAllModules_Next(arrMODULE_NAMES);
							}
							catch(e)
							{
								SplendidError.SystemError(e, 'CacheAllModules');
							}
						}
					});
				}
			});
		}
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'CacheAllModules');
	}
}

function Reload()
{
	try
	{
		// 04/30/2017 Paul.  Current URL will be different for HTML5 client and mobile client. 
		var sCURRENT_URL = window.location.href.split('?')[0];
		window.location.href = 'default.aspx?' + Math.uuid();
	}
	catch(e)
	{
		alert(e.message);
	}
}

