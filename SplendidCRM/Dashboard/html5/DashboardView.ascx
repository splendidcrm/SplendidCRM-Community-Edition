<%@ Control Language="c#" AutoEventWireup="false" Codebehind="DashboardView.ascx.cs" Inherits="SplendidCRM.Dashboard.html5.DashboardView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<script runat="server">
/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/

</script>

<%@ Register TagPrefix="SplendidCRM" Tagname="RestUtils" Src="~/_controls/RestUtils.ascx" %>
<SplendidCRM:RestUtils Runat="Server" />
<%@ Register TagPrefix="SplendidCRM" Tagname="FormatDateJavaScript" Src="~/_controls/FormatDateJavaScript.ascx" %>
<SplendidCRM:FormatDateJavaScript Runat="Server" />

<div id="divDashboardView" class="nav-md">
	<div id="divError"></div>

	<div class="container body">
		<div class="main_container">
			<div id="divMainPageContent" role="main">
				<div class="" style="padding-top: 10px;">
					<div id="divMainLayoutPanel_Header"></div>
					<div id="divMainActionsPanel" style="padding-bottom: 5px;"></div>
					<div id="divMainLayoutPanel_Menu"></div>
					<div id="divMainLayoutPanel"></div>
				</div>
			</div>
		</div>
	</div>
</div>

<SplendidCRM:InlineScript runat="server">
<script type="text/javascript">
function RenderDashboards(sLayoutPanel, sActionsPanel, sCATEGORY, ulActions, rows)
{
	var sMODULE_NAME  = sCATEGORY;
	function RenderDashboards_ActivateTab(rows, sID)
	{
		for ( var i = 0; i < rows.length; i++ )
		{
			var liList = document.getElementById('pnlModuleActions' + sMODULE_NAME + '_' + rows[i].ID);
			if ( liList )
			{
				liList.className = (rows[i].ID == sID ? 'active' : '');
			}
		}
	}

	for ( var i = 0; i < rows.length; i++ )
	{
		var sID   = rows[i].ID;
		var sNAME = rows[i].NAME;
		BindArguments(function(sID, sNAME)
		{
			var liList = document.createElement('li');
			liList.id        = 'pnlModuleActions' + sMODULE_NAME + '_' + sID;
			liList.role      = 'presentation';
			liList.className = '';
			ulActions.appendChild(liList);
			var aList = document.createElement('a');
			aList.href      = '#';
			aList.innerHTML = sNAME;
			try
			{
				aList.onclick = function(e)
				{
					RenderDashboards_ActivateTab(rows, sID);
					if ( !e )
						e = window.event;
					if ( e.stopPropagation )
						e.stopPropagation();
					else if ( window.event )
						e.cancelBubble = true;
					var oDashboardUI = new DashboardUI(sCATEGORY);
					oDashboardUI.Load(sLayoutPanel, sActionsPanel, sID, function(status, message)
					{
					});
				};
				liList.appendChild(aList);
				var spnEdit = document.createElement('span');
				spnEdit.className = 'glyphicon glyphicon-edit';
				spnEdit.style.fontSize = '1.5em';
				spnEdit.style.padding  = '4px';
				spnEdit.title          = L10n.Term('.LBL_EDIT_BUTTON_TITLE');
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
	var liCreate = document.createElement('li');
	ulActions.appendChild(liCreate);
	var aCreate = document.createElement('a');
	aCreate.href = '#';
	//aCreate.innerHTML = L10n.Term(sMODULE_NAME + '.LBL_NEW_FORM_TITLE');
	aCreate.title = L10n.Term(sMODULE_NAME + '.LBL_NEW_FORM_TITLE');
	aCreate.onclick = function(e)
	{
		if ( !e )
			e = window.event;
		if ( e.stopPropagation )
			e.stopPropagation();
		else if ( window.event )
			e.cancelBubble = true;
		var oDashboardEditUI = new DashboardEditUI(sCATEGORY);
		oDashboardEditUI.Load(sLayoutPanel, sActionsPanel, null);
	};
	liCreate.appendChild(aCreate);
	var spnEdit = document.createElement('span');
	spnEdit.className = 'glyphicon glyphicon-asterisk';
	spnEdit.style.fontSize = '1.5em';
	spnEdit.style.padding  = '4px';
	aCreate.appendChild(spnEdit);
}

// 06/13/2017 Paul.  We need to replace the functions called when View and Edit in a list view are called. 
function ListViewUI_View(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID)
{
	window.location.href = sREMOTE_SERVER + sMODULE_NAME + '/view.aspx?ID=' + sID;
}

function ListViewUI_Edit(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE, sAdditionalParams)
{
	window.location.href = sREMOTE_SERVER + sMODULE_NAME + '/edit.aspx?ID=' + sID + Sql.ToString(sAdditionalParams);
}

window.onload = function()
{
	try
	{
		var sCATEGORY     = 'Dashboard';
		var sMODULE_NAME  = sCATEGORY;
		var sLayoutPanel  = 'divMainLayoutPanel';
		var sActionsPanel = 'divMainActionsPanel';
		var bgPage = chrome.extension.getBackgroundPage();
		// 05/30/2017 Paul.  Correct background inline instead of in RestUtils.js. 
		bgPage.Application_GetAllLayouts       = Application_GetAllLayouts;
		bgPage.ListView_LoadTable              = ListView_LoadTable;
		bgPage.ListView_LoadTableWithAggregate = ListView_LoadTableWithAggregate;
		bgPage.ListView_LoadTablePaginated     = ListView_LoadTablePaginated;
		// 03/25/2020 Paul.  New service call as the process list has special filtering rules. 
		bgPage.ListView_LoadProcessPaginated   = ListView_LoadProcessPaginated;
		bgPage.DashboardApps_LoadAll           = DashboardApps_LoadAll;
		bgPage.Dashboards_LoadItem             = Dashboards_LoadItem;
		bgPage.Dashboards_LoadPanels           = Dashboards_LoadPanels;
		ctlActiveMenu = new TabMenuUI_None(sLayoutPanel, sActionsPanel);
		ctlActiveMenu.divError = function()
		{
			var divChartError = document.getElementById('divError');
			divChartError.innerHTML = e.message;
		}
		ctlActiveMenu.ReloadDashboard = function(sLayoutPanel, sActionsPanel, sCATEGORY, callback)
		{
			var sMODULE_NAME = sCATEGORY;
			var ulActions = document.getElementById('pnlModuleActions' + sMODULE_NAME);
			if ( ulActions != null )
			{
				while ( ulActions.childNodes.length > 0 )
				{
					ulActions.removeChild(ulActions.firstChild);
				}
				// 06/01/2017 Paul.  ASSIGNED_USER_ID is null for global dashboards. 
				var sSEARCH_FILTER = "ASSIGNED_USER_ID eq \'" + Security.USER_ID() + "\' and CATEGORY eq \'" + sCATEGORY + "\'";
				bgPage.ListView_LoadModule('Dashboard', 'NAME', 'asc', 'ID, NAME', sSEARCH_FILTER, null, function(status, message, __total)
				{
					if ( status == 1 )
					{
						var rows = message;
						if ( rows.length > 0 )
						{
							RenderDashboards(sLayoutPanel, sActionsPanel, sCATEGORY, ulActions, rows);
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
									RenderDashboards(sLayoutPanel, sActionsPanel, sCATEGORY, ulActions, rows);
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

		bgPage.IsAuthenticated(function(status, message)
		{
			if ( status == 1 )
			{
				bgPage.Application_Modules(function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						SplendidUI_Cache(function(status, message)
						{
							if ( status == 0 || status == 1 )
							{
								var divMainLayoutPanel_Header = document.getElementById('divMainLayoutPanel_Menu');
								var divTabMenu = document.createElement('div');
								divTabMenu.role = 'tabpanel';
								divMainLayoutPanel_Header.appendChild(divTabMenu);
								var ulActions = document.createElement('ul');
								ulActions.id        = 'pnlModuleActions' + sMODULE_NAME;
								ulActions.role      = 'tablist';
								ulActions.className = 'nav nav-tabs bar_tabs';
								divTabMenu.appendChild(ulActions);

								ctlActiveMenu.ReloadDashboard(sLayoutPanel, sActionsPanel, sCATEGORY, function(status, message)
								{
									var oDashboardUI = new DashboardUI(sCATEGORY);
									oDashboardUI.Load(sLayoutPanel, sActionsPanel, null, function(status, message)
									{
										if ( status == 1 )
										{
											if ( !Sql.IsEmptyString(oDashboardUI.CURRENT_DASHBOARD_ID) )
											{
												var liList = document.getElementById('pnlModuleActions' + sMODULE_NAME + '_' + oDashboardUI.CURRENT_DASHBOARD_ID);
												if ( liList != null )
													liList.className = 'active';
											}
										}
										else
										{
											SplendidError.SystemMessage(message);
										}
									});
								});
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
			else
			{
				SplendidError.SystemMessage(message);
			}
		});
	}
	catch(e)
	{
		SplendidError.SystemMessage('window.onload: ' + e.message);
	}
};
</script>
</SplendidCRM:InlineScript>

