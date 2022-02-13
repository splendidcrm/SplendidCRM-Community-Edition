/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
// 09/25/2011 Paul.  sIMAGE_SERVER is usually blank, but is used with the HTML5 client. 
var sIMAGE_SERVER    = '';
// 06/24/2017 Paul.  We need a way to turn off bootstrap for BPMN, ReportDesigner and ChatDashboard. 
var bDESKTOP_LAYOUT  = false;
var sPLATFORM_LAYOUT = '';
var bGLOBAL_LAYOUT_CACHE = false;
// 10/24/2014 Paul.  bREMOTE_ENABLED needs to be in the UI page so that it can be quickly accessed by the Formatting functions. 
var bWINDOWS_AUTH        = false;
var bREMOTE_ENABLED      = false;
// 12/01/2014 Paul.  We need to distinguish between Offline Client and Mobile Client. 
var bMOBILE_CLIENT       = false;
// 06/20/2015 Paul.  Provide a way to go directly to the DetailView or EditView of a record. 
var sINIT_MODE           = '';
var sINIT_MODULE         = '';
var sINIT_ID = '';
// 01/10/2017 Paul.  Add support for ADFS or Azure AD Single Sign on. 
// 04/30/2017 Paul.  Default to Single-Sign-On as disabled. 
var bADFS_SINGLE_SIGN_ON  = false;
var bAZURE_SINGLE_SIGN_ON = false;
var adalInstance          = null;

// https://hjnilsson.com/2016/07/20/authenticated-azure-cors-request-with-active-directory-and-adal-js/
function adalAuthenticateToken()
{
	if ( adalInstance.getCachedUser() )
	{
		// If we have a cached login, use it
		return true
	}

	if ( adalInstance.isCallback(window.location.hash) )
	{
		// This happens after the AD login screen,
		// handleWindowCallback will use the hash to
		// complete the login
		adalInstance.handleWindowCallback()
		return true
	}
	// Not logged in
	return false
}

function SplendidUI_CacheNext(arrMODULE_NAMES, callback)
{
	try
	{
		if ( arrMODULE_NAMES.length > 0 )
		{
			var sMODULE_NAME = arrMODULE_NAMES.pop();
			callback(2, 'Loading ' + sMODULE_NAME + ' cache');
			
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.Terminology_LoadModule(sMODULE_NAME, function(status, message)
			{
				callback(2, 'Loaded ' + sMODULE_NAME + ' Terminology');
				var sGRID_NAME = sMODULE_NAME + '.ListView' + sPLATFORM_LAYOUT;
				bgPage.ListView_LoadLayout(sGRID_NAME, function(status, message)
				{
					callback(2, 'Loaded ' + sGRID_NAME);
					var sDETAIL_NAME = sMODULE_NAME + '.DetailView' + sPLATFORM_LAYOUT;
					bgPage.DetailView_LoadLayout(sDETAIL_NAME, function(status, message)
					{
						callback(2, 'Loaded ' + sDETAIL_NAME);
						bgPage.DynamicButtons_LoadLayout(sDETAIL_NAME, function(status, message)
						{
							callback(2, 'Loaded ' + sDETAIL_NAME + ' buttons');
							var sEDIT_NAME = sMODULE_NAME + '.EditView' + sPLATFORM_LAYOUT;
							bgPage.EditView_LoadLayout(sEDIT_NAME, function(status, message)
							{
								callback(2, 'Loaded ' + sEDIT_NAME);
								bgPage.DynamicButtons_LoadLayout(sEDIT_NAME, function(status, message)
								{
									callback(2, 'Loaded ' + sEDIT_NAME + ' buttons');
									sEDIT_NAME = sMODULE_NAME + '.SearchBasic' + sPLATFORM_LAYOUT;
									bgPage.EditView_LoadLayout(sEDIT_NAME, function(status, message)
									{
										callback(2, 'Loaded ' + sEDIT_NAME + ' search');
										sGRID_NAME = sMODULE_NAME + '.PopupView' + sPLATFORM_LAYOUT;
										bgPage.ListView_LoadLayout(sGRID_NAME, function(status, message)
										{
											callback(2, 'Loaded ' + sGRID_NAME + ' popup');
											sEDIT_NAME = sMODULE_NAME + '.SearchPopup' + sPLATFORM_LAYOUT;
											bgPage.EditView_LoadLayout(sEDIT_NAME, function(status, message)
											{
												callback(2, 'Loaded ' + sEDIT_NAME);
												// 10/08/2012 Paul.  Load DetailViewRelationships. 
												sDETAIL_NAME = sMODULE_NAME + '.DetailView' + sPLATFORM_LAYOUT;
												bgPage.DetailViewRelationships_LoadLayout(sDETAIL_NAME, function(status, message)
												{
													callback(2, 'Loaded ' + sDETAIL_NAME);
													SplendidUI_CacheNext(arrMODULE_NAMES, callback);
												});
											});
										});
									});
								});
							});
						});
					});
				});
			});
		}
		else
		{
			callback(2, '');
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'SplendidUI_CacheNext');
	}
}

function SplendidUI_CacheModule(sMODULE, callback)
{
	switch ( sMODULE )
	{
		case 'Config':
			//callback(2, 'loading all Config settings');
			bgPage.Application_Config(callback);
			break;
		case 'Modules':
			//callback(2, 'loading all Modules');
			bgPage.Application_Modules(callback);
			break;
		case 'Teams':
			//callback(2, 'loading all Teams');
			bgPage.Application_Teams(callback);
			break;
		// 12/31/2017 Paul.  Add support for Dynamic Assignment. 
		case 'Users':
			//callback(2, 'loading all Teams');
			bgPage.Application_Users(callback);
			break;
		case 'GridViews':
			//callback(2, 'loading all GridView layouts');
			bgPage.ListView_LoadAllLayouts(callback);
			break;
		case 'DetailViews':
			//callback(2, 'loading all DetailView layouts');
			bgPage.DetailView_LoadAllLayouts(callback);
			break;
		case 'EditViews':
			//callback(2, 'loading all EditView layouts');
			bgPage.EditView_LoadAllLayouts(callback);
			break;
		case 'DetailViewRelationships':
			//callback(2, 'loading all DetailViewRelationship layouts');
			bgPage.DetailViewRelationships_LoadAllLayouts(callback);
			break;
		case 'DynamicButtons':
			//callback(2, 'loading all DynamicButton layouts');
			bgPage.DynamicButtons_LoadAllLayouts(callback);
			break;
		case 'Terminology':
			//callback(2, 'loading all Terminology');
			bgPage.Terminology_LoadAllTerms(function(status, message)
			{
				if ( status == 1 )
					bgPage.Terminology_LoadAllLists(callback);
			});
			break;
		case 'Currencies':
			//callback(2, 'loading all Currencies');
			bgPage.Terminology_LoadAllLists(callback);
			break;
		case 'Releases':
			//callback(2, 'loading all Releases');
			bgPage.Terminology_LoadAllLists(callback);
			break;
		case 'Terminology':
	}
}

function SplendidUI_ProgressBar(sActionsPanel)
{
	if ( !Sql.IsEmptyString(sActionsPanel) )
	{
		var divActionsPanel = document.getElementById(sActionsPanel);
		if ( divActionsPanel != null )
		{
			if ( divActionsPanel.childNodes != null )
			{
				while ( divActionsPanel.childNodes.length > 0 )
				{
					divActionsPanel.removeChild(divActionsPanel.firstChild);
				}
			}
			var divProgressBarFrame = document.createElement('div');
			divProgressBarFrame.id                    = 'divSplendidUI_ProgressBarFrame';
			divProgressBarFrame.style.margin          = '4px';
			divProgressBarFrame.style.padding         = '2px';
			divProgressBarFrame.style.border          = '1px solid #cccccc';
			divProgressBarFrame.style.width           = '90%';
			divProgressBarFrame.style.backgroundColor = '#ffffff';
			divActionsPanel.appendChild(divProgressBarFrame);
			var divProgressStatusText = document.createElement('div');
			divProgressStatusText.id = 'divSplendidUI_ProgressStatusText';
			divProgressBarFrame.appendChild(divProgressStatusText);
			// 12/31/2014 Paul.  Firefox does not like innerText. Use createTextNode. 
			divProgressStatusText.innerHTML = '';
			var tblProgressBar = document.createElement('table');
			tblProgressBar.id                    = 'tblSplendidUI_ProgressBar';
			tblProgressBar.cellSpacing           = 0;
			tblProgressBar.style.width           = '100%';
			tblProgressBar.style.backgroundColor = '#000000';
			divProgressBarFrame.appendChild(tblProgressBar);
			var tbodyProgressBar = document.createElement('tbody');
			tbodyProgressBar.className = 'SplendidProgressBar';
			tblProgressBar.appendChild(tbodyProgressBar);
			var trProgressBar = document.createElement('tr');
			tbodyProgressBar.appendChild(trProgressBar);
			var tdProgressBar = document.createElement('td');
			tdProgressBar.align                = 'center';
			tdProgressBar.style.padding        = '2px';
			tdProgressBar.style.color          = '#ffffff';
			tdProgressBar.style.fontSize       = '12px';
			tdProgressBar.style.fontStyle      = 'normal';
			tdProgressBar.style.fontWeight     = 'normal';
			tdProgressBar.style.textDecoration = 'none';
			trProgressBar.appendChild(tdProgressBar);
			var divProgressBarText = document.createElement('div');
			divProgressBarText.id = 'divSplendidUI_ProgressBarText';
			tdProgressBar.appendChild(divProgressBarText);
			divProgressBarText.innerHTML = '0%';
		}
	}
}

function SplendidUI_UpdateProgressBar(nProgress, nTotal, sStatusText)
{
	if ( nTotal > 1 )
	{
		var nProgress = Math.round(100 * (nProgress + 1) / nTotal);
		if ( nProgress > 100 )
			nProgress = 100;
		else if ( nProgress == 0 )
			nProgress = 1;
	
		var sProgress = nProgress.toString() + '%';
		var tblProgressBar        = document.getElementById('tblSplendidUI_ProgressBar'       );
		var divProgressBarText    = document.getElementById('divSplendidUI_ProgressBarText'   );
		var divProgressStatusText = document.getElementById('divSplendidUI_ProgressStatusText');
		divProgressBarText.innerHTML    = sProgress;
		tblProgressBar.style.width      = sProgress;
		divProgressStatusText.innerHTML = sStatusText;
	}
}

function SplendidUI_Cache(callback)
{
	try
	{
		SplendidError.SystemLog('SplendidUI_Cache');
		//callback(2, 'Begin loading all layouts');
		var nCacheItemCount = 0;
		var bgPage = chrome.extension.getBackgroundPage();
		/*
		// 12/06/2014 Paul.  The TabMenu is not based on the platform layout. 
		bgPage.DetailViewRelationships_LoadLayout('TabMenu', function(status, message)
		{
			if ( status == 1 )
			{
				var arrMODULE_NAMES = new Array();
				// 10/03/2011 Paul.  DetailViewRelationships_LoadLayout returns the layout. 
				var arrDetailViewRelationship = message;
				//var arrDetailViewRelationship = bgPage.SplendidCache.DetailViewRelationships('TabMenu');
				for ( var i = 0; i < arrDetailViewRelationship.length; i++ )
				{
					var sMODULE_NAME = arrDetailViewRelationship[i].MODULE_NAME;
					arrMODULE_NAMES.push(sMODULE_NAME);
				}
				// 10/06/2011 Paul.  We can't use a simple loop as JavaScript will re-use existing variables within the scope. 
				// SplendidUI_CacheNext makes sure that each fetch is called sequentially. 
				SplendidUI_CacheNext(arrMODULE_NAMES, callback);
			}
			else
			{
				callback(-1, message);
			}
		});
		*/
		// 10/09/2012 Paul.  Cache all available non-admin modules, not just the tab modules.  This is needed for sub-panels. 
		/*
		bgPage.Application_Modules(function(status, message)
		{
			if ( status == 1 )
			{
				var arrMODULE_NAMES = new Array();
				var arrMODULES = message;
				for ( var sMODULE_NAME in arrMODULES )
				{
					if ( arrMODULES[sMODULE_NAME].IS_ADMIN == 0 )
						arrMODULE_NAMES.push(sMODULE_NAME);
				}
				//alert(dumpObj(arrMODULE_NAMES, 'arrMODULE_NAMES'));
				SplendidUI_CacheNext(arrMODULE_NAMES, callback);
			}
		});
		*/
		// 10/16/2012 Paul.  GLobal flag to indicate that the cache is being loaded. 
		if ( bGLOBAL_LAYOUT_CACHE )
		{
			//SplendidError.SystemMessage('Global Layout Cache already loaded.');
			// 02/01/2013 Paul.  Signal that we are done. 
			callback(1, null);
			return;
		}
		
		// 12/13/2014 Paul.  We need a progress bar on cell phones due to the slow loading times. 
		SplendidUI_ProgressBar('divMainActionsPanel');
		SplendidUI_UpdateProgressBar(0, 2, 'Authenticating...');
		bgPage.IsAuthenticated(function(status, message)
		{
			if ( status == 1 )
			{
				bGLOBAL_LAYOUT_CACHE = true;
				// 10/12/2012 Paul.  Instead of 300+ requests, use the new bulk load functions to populate the layout cache. 
				//SplendidUI_UpdateProgressBar(1, 8, 'Loading all GridView layouts');
				//bgPage.ListView_LoadAllLayouts(function(status, message)
				//{
				//	SplendidUI_UpdateProgressBar(2, 8, 'Loading all DetailView layouts');
				//	bgPage.DetailView_LoadAllLayouts(function(status, message)
				//	{
				//		SplendidUI_UpdateProgressBar(3, 8, 'Loading all EditView layouts');
				//		bgPage.EditView_LoadAllLayouts(function(status, message)
				//		{
				//			SplendidUI_UpdateProgressBar(4, 8, 'Loading all DetailViewRelationship layouts');
				//			bgPage.DetailViewRelationships_LoadAllLayouts(function(status, message)
				//			{
				//				SplendidUI_UpdateProgressBar(5, 8, 'Loading all DynamicButton layouts');
				//				bgPage.DynamicButtons_LoadAllLayouts(function(status, message)
				//				{
				//					SplendidUI_UpdateProgressBar(6, 8, 'Loading all Terminology Lists');
				//					bgPage.Terminology_LoadAllLists(function(status, message)
				//					{
				//						SplendidUI_UpdateProgressBar(7, 8, 'Loading all Terminology');
				//						bgPage.Terminology_LoadAllTerms(function(status, message)
				//						{
				//							// 11/29/2014 Paul.  If there are no terms, then clear the global layout cache so that a load will be attempted again. 
				//							var nTerms = 0;
				//							for ( var t in message.TERMINOLOGY )
				//							{
				//								nTerms++;
				//								break;
				//							}
				//							if ( nTerms == 0 )
				//								bGLOBAL_LAYOUT_CACHE = false;
				//							SplendidUI_UpdateProgressBar(8, 8, 'Done loading all layouts');
				//							var divProgressBarFrame = document.getElementById('divSplendidUI_ProgressBarFrame');
				//							if ( divProgressBarFrame != null )
				//							{
				//								divProgressBarFrame.parentNode.removeChild(divProgressBarFrame);
				//							}
				//							// 10/16/2012 Paul.  Signal that we are done. 
				//							callback(1, null);
				//						});
				//					});
				//				});
				//			});
				//		});
				//	});
				//});
				// 02/27/2016 Paul.  Combine all layout gets. 
				callback(2, 'Loading all layouts');
				SplendidUI_UpdateProgressBar(1, 2, 'Loading all layouts');
				bgPage.Application_GetAllLayouts(function(status, message)
				{
					if ( status == 2 )
					{
						callback(2, message);
					}
					else
					{
						// 11/29/2014 Paul.  If there are no terms, then clear the global layout cache so that a load will be attempted again. 
						var nTerms = 0;
						for ( var t in message.TERMINOLOGY )
						{
							nTerms++;
							break;
						}
						if ( nTerms == 0 )
							bGLOBAL_LAYOUT_CACHE = false;
						callback(2, 'Done loading all layouts');
						SplendidUI_UpdateProgressBar(8, 8, 'Done loading all layouts');
						var divProgressBarFrame = document.getElementById('divSplendidUI_ProgressBarFrame');
						if ( divProgressBarFrame != null )
						{
							divProgressBarFrame.parentNode.removeChild(divProgressBarFrame);
						}
						// 10/16/2012 Paul.  Signal that we are done. 
						callback(1, null);
					}
				});
			}
			else
			{
				// 12/01/2014 Paul.  Return 1 as status so caller will continue. 
				callback(1, null);
			}
		});
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'SplendidUI_Cache');
	}
}

function SplendidUI_Clear(sLayoutPanel, sActionsPanel)
{
	try
	{
		var divHeaderPanel = document.getElementById(sLayoutPanel + '_Header');
		if ( divHeaderPanel != null && divHeaderPanel.childNodes != null )
		{
			while ( divHeaderPanel.childNodes.length > 0 )
			{
				divHeaderPanel.removeChild(divHeaderPanel.firstChild);
			}
		}
		var divLayoutPanel = document.getElementById(sLayoutPanel);
		if ( divLayoutPanel != null && divLayoutPanel.childNodes != null )
		{
			while ( divLayoutPanel.childNodes.length > 0 )
			{
				divLayoutPanel.removeChild(divLayoutPanel.firstChild);
			}
		}
		// 11/25/2014 Paul.  The Chat Dashboard does not have an actions panel. 
		if ( !Sql.IsEmptyString(sActionsPanel) )
		{
			var divActionsPanel = document.getElementById(sActionsPanel);
			if ( divActionsPanel != null && divActionsPanel.childNodes != null )
			{
				while ( divActionsPanel.childNodes.length > 0 )
				{
					divActionsPanel.removeChild(divActionsPanel.firstChild);
				}
			}
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'SplendidUI_Clear');
	}
}

function SplendidUI_ModuleHeader(sLayoutPanel, sActionsPanel, sMODULE_NAME, sSUB_TITLE, sID)
{
	try
	{
		// 12/06/2014 Paul.  Don't display the module header on a mobile device. 
		// 02/25/2016 Paul.  OfficeAddin looks like mobile. 
		if ( sPLATFORM_LAYOUT == '.Mobile' || sPLATFORM_LAYOUT == '.OfficeAddin' )
			return;
		
		var sMODULE_TITLE  = '.moduleList.' + sMODULE_NAME;
		var divHeaderPanel = document.getElementById(sLayoutPanel + '_Header');
		if ( divHeaderPanel != null && divHeaderPanel.childNodes != null )
		{
			while ( divHeaderPanel.childNodes.length > 0 )
			{
				divHeaderPanel.removeChild(divHeaderPanel.firstChild);
			}
		}
		//<asp:Table CssClass="moduleTitle" runat="server">
		//	<asp:TableRow>
		//		<asp:TableCell Wrap="false">
		//			<h2><span class="pointer">&raquo;</span></h2>
		//		</asp:TableCell>
		//	</asp:TableRow>
		//</asp:Table>
		if ( divHeaderPanel != null )
		{
			// 06/21/2015 Paul.  The Seven theme has labels stacked above values. 
			if ( SplendidDynamic.StackedLayout(Security.USER_THEME()) )
			{
				//<table class="moduleTitle ModuleHeaderFrame" cellspacing="1" cellpadding="0" border="0" style="width:100%;">
				//	<tbody>
				//		<tr>
				//			<td valign="top">
				//				<span class="ModuleHeaderModule ModuleHeaderModuleAccounts">Acc</span>
				//			</td>
				//			<td style="width:99%;">
				//				<span id="ctl00_cntBody_ctlEditView_ctlDynamicButtons_ctl00_lblTitle" class="ModuleHeaderName">02-02-2010 Analyst</span>&nbsp;
				//			</td>
				//			<td align="right" style="white-space:nowrap;padding-top:3px; padding-left: 5px;">
				//			</td>
				//			<td id="ctl00_cntBody_ctlEditView_ctlDynamicButtons_ctl00_tdButtons" align="left" style="white-space:nowrap;">
				//				<input type="submit" name="ctl00$cntBody$ctlEditView$ctlDynamicButtons$ctl00$btnSAVE"   value="  Save  "   onclick="javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(&quot;ctl00$cntBody$ctlEditView$ctlDynamicButtons$ctl00$btnSAVE&quot;, &quot;&quot;, true, &quot;&quot;, &quot;&quot;, false, false))" id="ctl00_cntBody_ctlEditView_ctlDynamicButtons_ctl00_btnSAVE" title="Save" class="EditHeaderFirstButton">
				//				<input type="submit" name="ctl00$cntBody$ctlEditView$ctlDynamicButtons$ctl00$btnCANCEL" value="  Cancel  " onclick="window.location.href='default.aspx'; return false;WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(&quot;ctl00$cntBody$ctlEditView$ctlDynamicButtons$ctl00$btnCANCEL&quot;, &quot;&quot;, true, &quot;&quot;, &quot;&quot;, false, false))" id="ctl00_cntBody_ctlEditView_ctlDynamicButtons_ctl00_btnCANCEL" title="Cancel" class="EditHeaderOtherButton" style="margin-right: 3px;">
				//			</td>
				//		</tr>
				//	</tbody>
				//</table>
				var tblHeader = document.createElement('table');
				tblHeader.cellSpacing = 1;
				tblHeader.cellPadding = 0;
				tblHeader.border      = 0;
				tblHeader.style.width = '100%';
				tblHeader.className   = 'moduleTitle ModuleHeaderFrame';
				divHeaderPanel.appendChild(tblHeader);
				var tbody = document.createElement('tbody');
				tblHeader.appendChild(tbody);
				var tr = document.createElement('tr');
				tbody.appendChild(tr);
				var td = document.createElement('td');
				tr.appendChild(td);
				td.vAlign = 'top';
				// 05/09/2017 Paul.  Reduce spacing between tile and text. 
				td.width  = '50px';
				var spanModule = document.createElement('span');
				td.appendChild(spanModule);
				spanModule.className = 'ModuleHeaderModule ModuleHeaderModule' + sMODULE_NAME;
				spanModule.innerHTML = L10n.Term(sMODULE_NAME + '.LBL_MODULE_ABBREVIATION');
				td = document.createElement('td');
				tr.appendChild(td);
				// 04/13/2017 Paul.  Decrease so that buttons don't have to wrap. 
				td.style.width = '70%';
				var divMain = document.createElement('div');
				td.appendChild(divMain);
				divMain.id  = sLayoutPanel + '_Header_divMainActionsPanel_divMain';
				if ( !Sql.IsEmptyString(sSUB_TITLE) )
				{
					var spanName = document.createElement('span');
					divMain.appendChild(spanName);
					spanName.className = 'ModuleHeaderName';
					// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
					if ( sSUB_TITLE.indexOf('<span class=\"Erased\">') >= 0 )
					{
						sSUB_TITLE = sSUB_TITLE.replaceAll(Sql.DataPrivacyErasedPill(), '');
						var txtTitle = document.createTextNode(sSUB_TITLE);
						spanName.appendChild(txtTitle);
						var spanErased = document.createElement('span');
						divMain.appendChild(spanErased);
						spanErased.className = 'Erased';
						spanErased.innerHTML = L10n.Term('DataPrivacy.LBL_ERASED_VALUE');
					}
					else
					{
						var txtTitle = document.createTextNode(sSUB_TITLE);
						spanName.appendChild(txtTitle);
					}
					var nbsp = document.createTextNode('\u00A0');
					td.appendChild(nbsp);
				}
				td = document.createElement('td');
				tr.appendChild(td);
				td.align             = 'right';
				td.style.whiteSpace  = 'nowrap';
				td.style.paddingTop  = '3px';
				td.style.paddingLeft = '5px';
				td = document.createElement('td');
				tr.appendChild(td);
				// 04/13/2017 Paul.  Align right now that we have alocated more space. 
				td.align             = 'right';
				td.style.whiteSpace  = 'nowrap';
				
				var divButtons = document.createElement('div');
				td.appendChild(divButtons);
				divButtons.id      = sLayoutPanel + '_Header_divMainActionsPanel';
				var divButtonHover = document.createElement('div');
				td.appendChild(divButtonHover);
				divButtonHover.id  = sLayoutPanel + '_Header_divMainActionsPanel_divButtonHover';
				divButtonHover.className = 'PanelHoverHidden ModuleHeaderOtherPanel';
			}
			else
			{
				var tblHeader = document.createElement('table');
				tblHeader.cellSpacing = 1;
				tblHeader.cellPadding = 0;
				tblHeader.border      = 0;
				tblHeader.width       = '100%';
				tblHeader.className   = 'moduleTitle';
				divHeaderPanel.appendChild(tblHeader);
			
				var tbody = document.createElement('tbody');
				tblHeader.appendChild(tbody);
				var tr = document.createElement('tr');
				tbody.appendChild(tr);
				var td = document.createElement('td');
				tr.appendChild(td);
				var h2 = document.createElement('h2');
				td.appendChild(h2);
			
				var lnkModule = document.createElement('a');
				h2.appendChild(lnkModule);
				lnkModule.innerHTML = L10n.Term(sMODULE_TITLE);
				lnkModule.href = '#';
				// 10/17/2016 Paul.  Hide module for Arctic theme. 
				if ( Security.USER_THEME() == 'Arctic' )
					lnkModule.style.display = 'none';
				lnkModule.onclick = function()
				{
					// 12/05/2012 Paul.  Only allow Users module if in Admin mode. 
					if ( bADMIN_MENU || sMODULE_NAME != 'Users' )
					{
						// 02/22/2013 Paul.  The Calendar has a separate view. 
						if ( sMODULE_NAME == 'Calendar' )
						{
							var oCalendarViewUI = new CalendarViewUI();
							oCalendarViewUI.Clear(sLayoutPanel, sActionsPanel);
							oCalendarViewUI.Load(sLayoutPanel, sActionsPanel, function(status, message)
							{
								if ( status == 0 || status == 1 )
								{
									sEDITVIEW_MODULE   = null;
									sEDITVIEW_ID       = null;
									sDETAILVIEW_MODULE = null;
									sDETAILVIEW_ID     = null;
								}
							});
						}
						// 11/25/2014 Paul.  The ChatDashboard has a separate view. 
						else if ( sMODULE_NAME == 'ChatDashboard' )
						{
							var oChatDashboardUI = new ChatDashboardUI();
							oChatDashboardUI.Render(sLayoutPanel, sActionsPanel, function(status, message)
							{
								if ( status == 0 || status == 1 )
								{
									sEDITVIEW_MODULE   = null;
									sEDITVIEW_ID       = null;
									sDETAILVIEW_MODULE = null;
									sDETAILVIEW_ID     = null;
								}
							});
						}
						else
						{
							var sGRID_NAME = sMODULE_NAME + '.ListView' + sPLATFORM_LAYOUT;
							var oListViewUI = new ListViewUI();
							oListViewUI.Reset(sLayoutPanel, sMODULE_NAME);
							oListViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sGRID_NAME, null, function(status, message)
							{
								if ( status == 0 || status == 1 )
								{
									sEDITVIEW_MODULE   = null;
									sEDITVIEW_ID       = null;
									sDETAILVIEW_MODULE = null;
									sDETAILVIEW_ID     = null;
								}
							});
						}
					}
				};
				// 11/25/2014 Paul.  We do not want the Home sub title for Calendar and Chat Dashboard. 
				if ( !Sql.IsEmptyString(sSUB_TITLE) )
				{
					var raquo = document.createElement('span');
					h2.appendChild(raquo);
					raquo.className = 'pointer';
					raquo.innerHTML = '&raquo;';
					// 10/17/2016 Paul.  Hide module for Arctic theme. 
					if ( Security.USER_THEME() == 'Arctic' )
						raquo.style.display = 'none';
					// 01/30/2013 Paul.  Clicking on the sub-title will refresh the view as a way to correct bugs in the rendering. 
					// 10/17/2016 Paul.  The Arctic theme does not use a link for the sub title. 
					if ( Sql.IsEmptyString(sID) || Security.USER_THEME() == 'Arctic' )
					{
						// 10/15/2012 Paul.  The sub title should already be converted from a term. 
						var txtTitle = document.createTextNode(sSUB_TITLE);
						h2.appendChild(txtTitle);
					}
					else
					{
						var lnkSubTitle = document.createElement('a');
						h2.appendChild(lnkSubTitle);
						// 01/30/2013 Paul.  The sub title should already be converted from a term. 
						//lnkSubTitle.innerHTML = sSUB_TITLE;
						// 08/26/2014 Paul.  Text with angle brackets (such as an email), will generate an error when used with innerHTML. 
						lnkSubTitle.appendChild(document.createTextNode(sSUB_TITLE));
						lnkSubTitle.href = '#';
						lnkSubTitle.onclick = function()
						{
							var oDetailViewUI = new DetailViewUI();
							// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
							oDetailViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, function(status, message)
							{
								if ( status == 1 )
								{
									SplendidError.SystemMessage('');
								}
								else
								{
									SplendidError.SystemMessage(message);
								}
							}, this);
						};
					}
				}
			}
		}
	}
	catch(e)
	{
		SplendidError.SystemMessage(SplendidError.FormatError(e, 'SplendidUI_ModuleHeader'));
	}
}

function SplendidUI_ListHeader(sLayoutPanel, sTITLE)
{
	try
	{
		//<asp:Table SkinID="tabFrame" CssClass="h3Row" runat="server">
		//	<asp:TableRow>
		//		<asp:TableCell Wrap="false">
		//			<h3><asp:Image SkinID="h3Arrow" Runat="server" />&nbsp;<asp:Label Text='<%# L10n.Term(sTitle) %>' runat="server" /></h3>
		//		</asp:TableCell>
		//	</asp:TableRow>
		//</asp:Table>
		var divMainLayoutPanel = document.getElementById(sLayoutPanel);
		if ( divMainLayoutPanel != null )
		{
			var tblHeader = document.createElement('table');
			tblHeader.cellSpacing = 1;
			tblHeader.cellPadding = 0;
			tblHeader.border      = 0;
			tblHeader.width       = '100%';
			tblHeader.className   = 'tabFrame';
			divMainLayoutPanel.appendChild(tblHeader);
			
			var tbody = document.createElement('tbody');
			tblHeader.appendChild(tbody);
			var tr = document.createElement('tr');
			tbody.appendChild(tr);
			var td = document.createElement('td');
			tr.appendChild(td);
			var h3 = document.createElement('h3');
			td.appendChild(h3);
			
			var img = document.createElement('img');
			h3.appendChild(img);
			img.align             = 'absmiddle';
			img.style.height      = '11px';
			img.style.width       = '11px';
			img.style.borderWidth = '0px';
			img.src               = sIMAGE_SERVER + 'App_Themes/Six/images/h3Arrow.gif';
			
			var nbsp = String.fromCharCode(160);
			var txtTitle = document.createTextNode(nbsp + L10n.Term(sTITLE));
			h3.appendChild(txtTitle);
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'SplendidUI_ListHeader');
	}
}

// 02/24/2013 Paul.  Moved setCookie() to utility.js. 

// 02/27/2012 Paul.  ShowSubPanel is used in ListHeader to Collapse sub-panel. 
function ShowSubPanel(sShowSubPanel, sHideSubPanel, sSubPanel, sSubPanelFrame)
{
	var lnkShowSubPanel = document.getElementById(sShowSubPanel);
	var lnkHideSubPanel = document.getElementById(sHideSubPanel);
	var divSubPanel     = document.getElementById(sSubPanel);
	lnkShowSubPanel.style.display = 'none';
	lnkHideSubPanel.style.display = 'inline';
	divSubPanel.style.display     = 'inline';
	// 09/25/2016 Paul.  New code for Seven theme requires that we manually hide the buttons. 
	var divSubPanelButtons = document.getElementById(sSubPanel + 'Buttons');
	if ( divSubPanelButtons != null )
		divSubPanelButtons.style.display = 'inline';
	// 09/25/2016 Paul.  New code for Seven theme requires that we manually hide the buttons. 
	var divSubPanelFrame = document.getElementById(sSubPanelFrame);
	if ( divSubPanelFrame != null )
		divSubPanelFrame.className = 'h3Row';
	if ( window.localStorage )
	{
		if ( localStorage[sSubPanel] !== undefined )
			localStorage.removeItem(sSubPanel);
	}
	else
	{
		deleteCookie(sSubPanel);
	}
}
function HideSubPanel(sShowSubPanel, sHideSubPanel, sSubPanel, sSubPanelFrame, days)
{
	// 12/25/2012 Paul.  The Reminders popdown is only remembered for 1 day. 
	if ( days === undefined )
		days = 180;
	var lnkShowSubPanel = document.getElementById(sShowSubPanel);
	var lnkHideSubPanel = document.getElementById(sHideSubPanel);
	var divSubPanel     = document.getElementById(sSubPanel);
	lnkShowSubPanel.style.display = 'inline';
	lnkHideSubPanel.style.display = 'none';
	divSubPanel.style.display     = 'none';
	// 09/25/2016 Paul.  New code for Seven theme requires that we manually hide the buttons. 
	var divSubPanelButtons = document.getElementById(sSubPanel + 'Buttons');
	if ( divSubPanelButtons != null )
		divSubPanelButtons.style.display = 'none';
	// 09/25/2016 Paul.  New code for Seven theme requires that we manually hide the buttons. 
	var divSubPanelFrame = document.getElementById(sSubPanelFrame);
	if ( divSubPanelFrame != null )
		divSubPanelFrame.className = 'h3Row h3RowDisabled';
	try
	{
		if ( window.localStorage )
			localStorage[sSubPanel] = '1';
		else
			setCookie(sSubPanel, '1', 180);
	}
	catch(e)
	{
		// 03/10/2013 Paul.  IE9 is throwing an out-of-memory error. Just ignore the error. 
		//if ( window.localStorage.remainingSpace !== undefined )
		//	alert('remainingSpace = ' + window.localStorage.remainingSpace);
		SplendidError.SystemLog('HideSubPanel: ' + e.message);
	}
}

function SplendidUI_CollapsibleListHeader(sLayoutPanel, sTITLE, sMODULE_NAME)
{
	try
	{
		//<asp:Table SkinID="tabFrame" CssClass="h3Row" runat="server">
		//	<asp:TableRow>
		//		<asp:TableCell Wrap="false">
		//			<h3><asp:Image SkinID="h3Arrow" Runat="server" />&nbsp;<asp:Label Text='<%# L10n.Term(sTitle) %>' runat="server" /></h3>
		//		</asp:TableCell>
		//	</asp:TableRow>
		//</asp:Table>
		//<h3>
		//	<span>
		//		<a id="ctl00_cntBody_ctlDetailView_ctl03_ctl00_lnkShowSubPanel" href="javascript:ShowSubPanel('ctl00_cntBody_ctlDetailView_ctl03_ctl00_lnkShowSubPanel','ctl00_cntBody_ctlDetailView_ctl03_ctl00_lnkHideSubPanel','divAccountsActivitiesOpen');" style="display:none"><img src="../App_Themes/Six/images/advanced_search.gif" align="absmiddle" style="border-width:0px;height:8px;width:8px;"></a>
		//		<a id="ctl00_cntBody_ctlDetailView_ctl03_ctl00_lnkHideSubPanel" href="javascript:HideSubPanel('ctl00_cntBody_ctlDetailView_ctl03_ctl00_lnkShowSubPanel','ctl00_cntBody_ctlDetailView_ctl03_ctl00_lnkHideSubPanel','divAccountsActivitiesOpen');" style="display:inline"><img src="../App_Themes/Six/images/basic_search.gif" align="absmiddle" style="border-width:0px;height:8px;width:8px;"></a>
		//	</span>
		//	&nbsp;<span>Open Activities</span>
		//</h3>
		var divMainLayoutPanel = document.getElementById(sLayoutPanel);
		if ( divMainLayoutPanel != null )
		{
			// 06/21/2015 Paul.  The Seven theme has labels stacked above values. 
			if ( SplendidDynamic.StackedLayout(Security.USER_THEME()) )
			{
				//<table id="ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_tblSubPanelFrame" class="h3Row" cellspacing="1" cellpadding="0" border="0" style="width:100%;">
				//	<tbody>
				//		<tr>
				//			<td valign="top">
				//				<span class="ModuleHeaderModule ModuleHeaderModuleContacts ListHeaderModule">Con</span>
				//			</td>
				//			<td style="width:99%;white-space:nowrap;">
				//				<span class="ListHeaderName">Contacts</span>
				//			</td>
				//			<td>
				//				<span>
				//					<a id="ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_lnkShowSubPanel" href="javascript:ShowSubPanel('ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_lnkShowSubPanel','ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_lnkHideSubPanel','divAccountsContacts','ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_tblSubPanelFrame');" style="display:none"><img src="../App_Themes/Seven/images/subpanel_expand.gif" align="absmiddle" style="border-width:0px;height:16px;width:16px;"></a>
				//					<a id="ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_lnkHideSubPanel" href="javascript:HideSubPanel('ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_lnkShowSubPanel','ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_lnkHideSubPanel','divAccountsContacts','ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_tblSubPanelFrame');" style="display:inline"><img src="../App_Themes/Seven/images/subpanel_collapse.gif" align="absmiddle" style="border-width:0px;height:16px;width:16px;"></a>
				//				</span>
				//			</td>
				//			<td id="ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_tdButtons" align="left" onclick="javascript:ShowSubPanel('ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_lnkShowSubPanel','ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_lnkHideSubPanel','divAccountsContacts','ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_tblSubPanelFrame');" style="white-space:nowrap;"><input type="submit" name="ctl00$cntBody$ctlDetailView$ctl03$ctlDynamicButtons$ctl00$btnCONTACTS_CREATE" value="  +  " onclick="javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(&quot;ctl00$cntBody$ctlDetailView$ctl03$ctlDynamicButtons$ctl00$btnCONTACTS_CREATE&quot;, &quot;&quot;, true, &quot;&quot;, &quot;&quot;, false, false))" id="ctl00_cntBody_ctlDetailView_ctl03_ctlDynamicButtons_ctl00_btnCONTACTS_CREATE" title="Create" class="ListHeaderFirstButton"><input type="image" name="ctl00$cntBody$ctlDetailView$ctl03$ctlDynamicButtons$ctl00$ctl05" class="ListHeaderMoreButton" src="../App_Themes/Seven/images/subpanel_more.gif" align="absmiddle" onclick="void(0); return false;WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(&quot;ctl00$cntBody$ctlDetailView$ctl03$ctlDynamicButtons$ctl00$ctl05&quot;, &quot;&quot;, true, &quot;&quot;, &quot;&quot;, false, false))" style="border-width:0px;height:20px;width:16px;">
				//			</td>
				//		</tr>
				//	</tbody>
				//</table>
				var tblHeader = document.createElement('table');
				tblHeader.id = sLayoutPanel + '_Header';
				tblHeader.cellSpacing = 1;
				tblHeader.cellPadding = 0;
				tblHeader.border      = 0;
				tblHeader.width       = '100%';
				tblHeader.className   = 'h3Row';
				divMainLayoutPanel.appendChild(tblHeader);
				var tbody = document.createElement('tbody');
				tblHeader.appendChild(tbody);
				var tr = document.createElement('tr');
				tbody.appendChild(tr);
				var td = document.createElement('td');
				tr.appendChild(td);
				td.vAlign = 'top';
				var spanModule = document.createElement('span');
				td.appendChild(spanModule);
				spanModule.className = 'ModuleHeaderModule ModuleHeaderModule' + sMODULE_NAME + ' ListHeaderModule';
				spanModule.innerHTML = L10n.Term(sMODULE_NAME + '.LBL_MODULE_ABBREVIATION');
				
				// 04/13/2017 Paul.  Decrease so that buttons don't have to wrap. 
				td.style.width      = '70%';
				td.style.whiteSpace = 'nowrap';
				var spanName = document.createElement('span');
				td.appendChild(spanName);
				spanName.className = 'ListHeaderName';
				var txtTitle = document.createTextNode(L10n.Term(sTITLE));
				spanName.appendChild(txtTitle);

				td = document.createElement('td');
				tr.appendChild(td);
				// 04/13/2017 Paul.  Align right now that we have alocated more space. 
				td.align             = 'right';
				td.style.whiteSpace  = 'nowrap';
				
				var spanShowHide = document.createElement('div');
				spanShowHide.style.display = 'inline-block';
				td.appendChild(spanShowHide);
				
				var bPanelHidden = false;
				if ( window.localStorage )
					bPanelHidden = (localStorage[sLayoutPanel + '_Outer'] == '1');
				else
					bPanelHidden = (getCookie(sLayoutPanel + '_Outer') == '1');
				var lnkShowSubPanel = document.createElement('a');
				lnkShowSubPanel.id     = sLayoutPanel + '_lnkShowSubPanel';
				lnkShowSubPanel.border = 0;
				lnkShowSubPanel.href   = '#';
				lnkShowSubPanel.style.display = bPanelHidden ? 'inline' : 'none';
				lnkShowSubPanel.onclick = BindArguments(function(sLayoutPanel)
				{
					ShowSubPanel(sLayoutPanel + '_lnkShowSubPanel', sLayoutPanel + '_lnkHideSubPanel', sLayoutPanel + '_Outer');
				}, sLayoutPanel);
				spanShowHide.appendChild(lnkShowSubPanel);
			
				var lnkHideSubPanel = document.createElement('a');
				lnkHideSubPanel.id     = sLayoutPanel + '_lnkHideSubPanel';
				lnkHideSubPanel.border = 0;
				lnkHideSubPanel.href   = '#';
				lnkHideSubPanel.style.display = bPanelHidden ? 'none' : 'inline';
				lnkHideSubPanel.onclick = BindArguments(function(sLayoutPanel)
				{
					HideSubPanel(sLayoutPanel + '_lnkShowSubPanel', sLayoutPanel + '_lnkHideSubPanel', sLayoutPanel + '_Outer');
				}, sLayoutPanel);
				spanShowHide.appendChild(lnkHideSubPanel);
			
				// 04/13/2017 Paul.  Use Bootstrap for responsive design.
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					var imgShow = document.createElement('img');
					lnkShowSubPanel.appendChild(imgShow);
					imgShow.align             = 'absmiddle';
					imgShow.style.height      = '16px';
					imgShow.style.width       = '16px';
					imgShow.style.borderWidth = '0px';
					imgShow.style.border      = 'none';
					imgShow.src               = sIMAGE_SERVER + 'App_Themes/Seven/images/subpanel_expand.gif';
			
					var imgHide = document.createElement('img');
					lnkHideSubPanel.appendChild(imgHide);
					imgHide.align             = 'absmiddle';
					imgHide.style.height      = '16px';
					imgHide.style.width       = '16px';
					imgHide.style.borderWidth = '0px';
					imgHide.style.border      = 'none';
					imgHide.src               = sIMAGE_SERVER + 'App_Themes/Seven/images/subpanel_collapse.gif';
				}
				else
				{
					var imgShow = document.createElement('span');
					lnkShowSubPanel.appendChild(imgShow);
					lnkShowSubPanel.className = 'btn';
					imgShow.className = 'glyphicon glyphicon-chevron-down subpanel_toolbox';
					//imgShow.className = 'fa fa-chevron-down';
			
					var imgHide = document.createElement('span');
					lnkHideSubPanel.appendChild(imgHide);
					lnkHideSubPanel.className = 'btn';
					imgHide.className = 'glyphicon glyphicon-chevron-up subpanel_toolbox';
					//imgHide.className = 'fa fa-chevron-up';
				}
			
				var divButtons = document.createElement('div');
				divButtons.style.display = 'inline-block';
				// 04/13/2017 Paul.  Use Bootstrap for responsive design.
				if ( SplendidDynamic.BootstrapLayout() )
					divButtons.className = 'btn-group';
				td.appendChild(divButtons);
				divButtons.id      = sLayoutPanel + '_Header_divMainActionsPanel';
				var divButtonHover = document.createElement('div');
				td.appendChild(divButtonHover);
				divButtonHover.id  = sLayoutPanel + '_Header_divMainActionsPanel_divButtonHover';
				divButtonHover.className = 'PanelHoverHidden ListHeaderOtherPanel';
			}
			else
			{
				var tblHeader = document.createElement('table');
				tblHeader.id = sLayoutPanel + '_Header';
				tblHeader.cellSpacing = 1;
				tblHeader.cellPadding = 0;
				tblHeader.border      = 0;
				tblHeader.width       = '100%';
				tblHeader.className   = 'h3Row';
				divMainLayoutPanel.appendChild(tblHeader);
			
				var tbody = document.createElement('tbody');
				tblHeader.appendChild(tbody);
				var tr = document.createElement('tr');
				tbody.appendChild(tr);
				var td = document.createElement('td');
				tr.appendChild(td);
				var h3 = document.createElement('h3');
				td.appendChild(h3);
			
				var bPanelHidden = false;
				if ( window.localStorage )
					bPanelHidden = (localStorage[sLayoutPanel + '_Outer'] == '1');
				else
					bPanelHidden = (getCookie(sLayoutPanel + '_Outer') == '1');
				var lnkShowSubPanel = document.createElement('a');
				lnkShowSubPanel.id     = sLayoutPanel + '_lnkShowSubPanel';
				lnkShowSubPanel.border = 0;
				lnkShowSubPanel.href   = '#';
				lnkShowSubPanel.style.display = bPanelHidden ? 'inline' : 'none';
				lnkShowSubPanel.onclick = BindArguments(function(sLayoutPanel)
				{
					ShowSubPanel(sLayoutPanel + '_lnkShowSubPanel', sLayoutPanel + '_lnkHideSubPanel', sLayoutPanel + '_Outer');
				}, sLayoutPanel);
				h3.appendChild(lnkShowSubPanel);
			
				var lnkHideSubPanel = document.createElement('a');
				lnkHideSubPanel.id     = sLayoutPanel + '_lnkHideSubPanel';
				lnkHideSubPanel.border = 0;
				lnkHideSubPanel.href   = '#';
				lnkHideSubPanel.style.display = bPanelHidden ? 'none' : 'inline';
				lnkHideSubPanel.onclick = BindArguments(function(sLayoutPanel)
				{
					HideSubPanel(sLayoutPanel + '_lnkShowSubPanel', sLayoutPanel + '_lnkHideSubPanel', sLayoutPanel + '_Outer');
				}, sLayoutPanel);
				h3.appendChild(lnkHideSubPanel);
			
				// 04/13/2017 Paul.  Use Bootstrap for responsive design.
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					var imgShow = document.createElement('img');
					lnkShowSubPanel.appendChild(imgShow);
					imgShow.align             = 'absmiddle';
					imgShow.style.height      = '8px';
					imgShow.style.width       = '8px';
					imgShow.style.borderWidth = '0px';
					imgShow.style.padding     = '2px';
					imgShow.style.border      = 'none';
					imgShow.src               = sIMAGE_SERVER + 'App_Themes/Six/images/advanced_search.gif';
			
					var imgHide = document.createElement('img');
					lnkHideSubPanel.appendChild(imgHide);
					imgHide.align             = 'absmiddle';
					imgHide.style.height      = '8px';
					imgHide.style.width       = '8px';
					imgHide.style.borderWidth = '0px';
					imgHide.style.padding     = '2px';
					imgHide.style.border      = 'none';
					imgHide.src               = sIMAGE_SERVER + 'App_Themes/Six/images/basic_search.gif';
				}
				else
				{
					var imgShow = document.createElement('span');
					lnkShowSubPanel.appendChild(imgShow);
					imgShow.className = 'glyphicon glyphicon-chevron-down';
			
					var imgHide = document.createElement('span');
					lnkHideSubPanel.appendChild(imgHide);
					imgHide.className = 'glyphicon glyphicon-chevron-up';
				}
			
				var nbsp = String.fromCharCode(160);
				var txtTitle = document.createTextNode(nbsp + L10n.Term(sTITLE));
				h3.appendChild(txtTitle);
			}
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'SplendidUI_CollapsibleListHeader');
	}
}

function SplendidUI_NextCustomList(arrLISTS, callback)
{
	try
	{
		if ( arrLISTS.length > 0 )
		{
			var sLIST_NAME = arrLISTS.pop();
			
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.Terminology_LoadCustomList(sLIST_NAME, function(status, message)
			{
				callback(2, 'Loaded ' + sLIST_NAME);
				SplendidUI_NextCustomList(arrLISTS, callback);
			});
		}
		else
		{
			callback(1, '');
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'SplendidUI_NextCustomList');
	}
}


function SplendidUI_LoadCustomLists(callback)
{
	try
	{
		var arrLISTS = new Array();
		arrLISTS.push('Currencies'       );
		arrLISTS.push('Release'          );
		arrLISTS.push('ContractTypes'    );
		arrLISTS.push('AssignedUser'     );
		//arrLISTS.push('Manufacturers'    );
		//arrLISTS.push('Discounts'        );
		//arrLISTS.push('Shippers'         );
		//arrLISTS.push('Regions'          );
		//arrLISTS.push('ProductTypes'     );
		//arrLISTS.push('ProductCategories');
		// 02/24/2013 Paul.  Add custom calendar lists. 
		arrLISTS.push('month_names_dom'      );
		arrLISTS.push('short_month_names_dom');
		arrLISTS.push('day_names_dom'        );
		arrLISTS.push('short_day_names_dom'  );
		SplendidUI_NextCustomList(arrLISTS, callback);
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'SplendidUI_LoadCustomLists');
	}
}

function SplendidUI_Init(sLayoutPanel, sActionsPanel, sMODULE_NAME, rowDefaultSearch, callback)
{
	try
	{
		callback(2, 'Authenticating with CRM.');
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				callback(2, 'Loading config.');
				bgPage.Application_Config(function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						callback(2, 'Loading modules.');
						bgPage.Application_Modules(function(status, message)
						{
							if ( status == 0 || status == 1 )
							{
								callback(2, 'Loading global terminology.');
								// 03/10/2013 Paul.  Use SplendidUI_Cache instead of caching terminology separately. 
								SplendidUI_Cache(function(status, message)
								{
									if ( status == 0 || status == 1 )
									{
										// 03/21/2016 Paul.  OfficeAddin should not be used unless platform is .OfficeAddin. 
										if ( sMODULE_NAME == 'OfficeAddin' && sPLATFORM_LAYOUT != '.OfficeAddin' )
											sMODULE_NAME = 'Contacts';
										// 10/02/2011 Paul.  Status of 3 means that the globals are done loading. 
										// 05/06/2013 Paul.  Now that we use ActiveMenu RenderHeader. 
										//callback(3, '');
										callback(2, 'Loading tab menu for ' + sMODULE_NAME);
										// 10/15/2011 Paul.  sTabMenuCtl is a div tag now so that we can do more with the panel. 
										// 04/23/2013 Paul.  New approach to menu management. 
										var sTHEME = Security.USER_THEME();
										// 12/04/2014 Paul.  Add new mobile platform. 
										// 02/25/2016 Paul.  OfficeAddin looks like mobile. 
										if ( sPLATFORM_LAYOUT == '.OfficeAddin' )
											ctlActiveMenu = new TabMenuUI_OfficeAddin(sLayoutPanel, sActionsPanel);
										// 04/08/2017 Paul.  Use Bootstrap for responsive design.
										//else if ( sPLATFORM_LAYOUT == '.Mobile' )
										//	ctlActiveMenu = new TabMenuUI_Mobile(sLayoutPanel, sActionsPanel);
										//else if ( sTHEME == 'Six' )
										//	ctlActiveMenu = new TabMenuUI_Six(sLayoutPanel, sActionsPanel);
										//else if ( sTHEME == 'Atlantic' )
										//	ctlActiveMenu = new TabMenuUI_Atlantic(sLayoutPanel, sActionsPanel);
										else
											ctlActiveMenu = new TabMenuUI_Gentelella(sLayoutPanel, sActionsPanel);
										ctlActiveMenu.RenderHeader();
										// 11/18/2013 Paul.  Change to status 4 so that only a browser extension will process the event. 
										callback(4, '');
										ctlActiveMenu.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, function(status, message)
										{
											// 01/01/2012 Paul.  Move loading teams before loading the list view as the list might display team names. 
											callback(2, 'Loading teams.');
											bgPage.Application_Teams(function(status, message)
											{
												if ( status == 0 || status == 1 )
												{
													// 06/20/2015 Paul.  Provide a way to go directly to the DetailView or EditView of a record. 
													if ( (sINIT_MODE == 'edit' || sINIT_MODE == 'view') && !Sql.IsEmptyString(sINIT_MODULE) && !Sql.IsEmptyString(sINIT_ID) )
													{
														if ( sINIT_MODE == 'edit' )
														{
															callback(2, 'Editing ' + sINIT_MODULE + ': ' + sINIT_ID);
															sMODULE_NAME = sINIT_MODULE;
															sID          = sINIT_ID    ;
															var oEditViewUI = new EditViewUI();
															oEditViewUI.LoadWithCallback(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, false, function(status, message)
															{
																if ( status == 0 || status == 1 )
																{
																	callback(1, null);
																}
																else
																{
																	callback(status, message);
																}
															}, this);
														}
														else if ( sINIT_MODE == 'view' )
														{
															callback(2, 'Viewing ' + sINIT_MODULE + ': ' + sINIT_ID);
															sMODULE_NAME = sINIT_MODULE;
															sID          = sINIT_ID    ;
															var oDetailViewUI = new DetailViewUI();
															oDetailViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, function(status, message)
															{
																if ( status == 0 || status == 1 )
																{
																	callback(1, null);
																}
																else
																{
																	callback(status, message);
																}
															}, this);
														}
														else
														{
															var sGRID_NAME = sMODULE_NAME + '.ListView' + sPLATFORM_LAYOUT;
															callback(2, 'Loading ' + sGRID_NAME + '.');
															var oListViewUI = new ListViewUI();
															oListViewUI.Reset(sLayoutPanel, sMODULE_NAME);
															oListViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sGRID_NAME, rowDefaultSearch, function(status, message)
															{
																if ( status == 0 || status == 1 )
																{
																	callback(1, null);
																}
																else
																{
																	callback(status, message);
																}
															});
														}
														sINIT_MODE   = '';
														sINIT_MODULE = '';
														sINIT_ID     = '';
													}
													// 02/22/2013 Paul.  The Calendar has a separate view. 
													else if ( sMODULE_NAME == 'Calendar' )
													{
														callback(2, 'Loading Calendar.');
														var oCalendarViewUI = new CalendarViewUI();
														oCalendarViewUI.Clear(sLayoutPanel, sActionsPanel);
														oCalendarViewUI.Load(sLayoutPanel, sActionsPanel, function(status, message)
														{
															if ( status == 0 || status == 1 )
															{
																callback(1, null);
															}
															else
															{
																callback(status, message);
															}
														});
													}
													// 02/22/2013 Paul.  The ChatDashboard has a separate view. 
													else if ( sMODULE_NAME == 'ChatDashboard' )
													{
														callback(2, 'Loading ChatDashboard.');
														var oChatDashboardUI = new ChatDashboardUI();
														oChatDashboardUI.Render(sLayoutPanel, sActionsPanel, function(status, message)
														{
															if ( status == 0 || status == 1 )
															{
																callback(1, null);
															}
															else
															{
																callback(status, message);
															}
														});
													}
													// 05/09/2017 Paul.  The Dashboard has a separate view. 
													else if ( sMODULE_NAME == 'Dashboard' )
													{
														callback(2, 'Loading Dashboard.');
														var oDashboardUI = new DashboardUI(sMODULE_NAME);
														oDashboardUI.Clear(sLayoutPanel, sActionsPanel);
														oDashboardUI.Load(sLayoutPanel, sActionsPanel, null, function(status, message)
														{
															if ( status == 0 || status == 1 )
															{
																callback(1, null);
															}
															else
															{
																callback(status, message);
															}
														});
													}
													// 05/09/2017 Paul.  Add Home Dashboard. 
													else if ( sMODULE_NAME == 'Home' )
													{
														callback(2, 'Loading Home Dashboard.');
														var oDashboardUI = new DashboardUI(sMODULE_NAME);
														oDashboardUI.Clear(sLayoutPanel, sActionsPanel);
														oDashboardUI.Load(sLayoutPanel, sActionsPanel, null, function(status, message)
														{
															if ( status == 0 || status == 1 )
															{
																callback(1, null);
															}
															else
															{
																callback(status, message);
															}
														});
													}
													// 02/24/2016 Paul.  OfficeAddin view. 
													else if ( sMODULE_NAME == 'OfficeAddin' )
													{
														callback(2, 'Loading OfficeAddin.');
														var oOfficeAddinUI = new OfficeAddinUI(sExchangeFromDisplayName, sExchangeFromEmailAddress, sExchangeItemSubject, arrExchangeFromEmailAddress);
														oOfficeAddinUI.Render(sLayoutPanel, sActionsPanel, function(status, message)
														{
															if ( status == 0 || status == 1 )
															{
																callback(1, null);
															}
															else
															{
																callback(status, message);
															}
														});
													}
													else
													{
														var sGRID_NAME = sMODULE_NAME + '.ListView' + sPLATFORM_LAYOUT;
														callback(2, 'Loading ' + sGRID_NAME + '.');
														var oListViewUI = new ListViewUI();
														oListViewUI.Reset(sLayoutPanel, sMODULE_NAME);
														oListViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sGRID_NAME, rowDefaultSearch, function(status, message)
														{
															if ( status == 0 || status == 1 )
															{
																callback(1, null);
															}
															else
															{
																callback(status, message);
															}
														});
													}
												}
												else
												{
													callback(status, message);
												}
											});
											// 12/31/2017 Paul.  Add support for Dynamic Assignment. Load in parallel to teams. 
											callback(2, 'Loading users.');
											bgPage.Application_Users(function(status, message)
											{
												if ( status == 0 || status == 1 )
												{
												}
												else
												{
													callback(status, message);
												}
											});
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
				callback(status, message);
			}
		});
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'SplendidUI_Init'));
	}
}

function SplendidUI_ReInit(sLayoutPanel, sActionsPanel, sMODULE_NAME)
{
	try
	{
		if ( sMODULE_NAME == null )
			sMODULE_NAME = sSTARTUP_MODULE;
		SplendidUI_Init(sLayoutPanel, sActionsPanel, sMODULE_NAME, null, function(status, message)
		{
			if ( status == 3 )
			{
				LoginViewUI_UpdateHeader(sLayoutPanel, sActionsPanel, true)
			}
			else if ( status == 1 )
			{
				SplendidError.SystemMessage('');
			}
			else
			{
				SplendidError.SystemMessage(message);
			}
		});
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'SplendidUI_ReInit'));
	}
}
