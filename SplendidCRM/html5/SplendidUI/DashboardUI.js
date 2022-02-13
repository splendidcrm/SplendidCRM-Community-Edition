/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function DashboardUI(sCATEGORY)
{
	this.MODULE   = sCATEGORY;
	this.CATEGORY = sCATEGORY;
	if ( window.localStorage )
		this.CURRENT_DASHBOARD_ID = Sql.ToString(localStorage[this.CATEGORY + 'LastDashboard']);
	else
		this.CURRENT_DASHBOARD_ID = Sql.ToString(getCookie(this.CATEGORY + 'LastDashboard'));
}

DashboardUI.prototype.PageCommand = function(sLayoutPanel, sActionsPanel, sCommandName, sCommandArguments)
{
	try
	{
		if ( sCommandName == 'Create' )
		{
			var oDashboardEditUI = new DashboardEditUI(this.CATEGORY);
			oDashboardEditUI.Load(sLayoutPanel, sActionsPanel, null);
		}
		else
		{
			SplendidError.SystemMessage('DashboardUI.PageCommand: Unknown command ' + sCommandName);
		}
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'DashboardUI.PageCommand');
	}
}

DashboardUI.prototype.Clear = function(sLayoutPanel, sActionsPanel)
{
	try
	{
		SplendidUI_Clear(sLayoutPanel, sActionsPanel);
		SplendidUI_ModuleHeader(sLayoutPanel, sActionsPanel, this.MODULE, L10n.ListTerm('moduleList', this.MODULE));
		var divDashboard = document.createElement('div');
		divDashboard.id          = sLayoutPanel + '_divDashboard';
		divDashboard.style.width = '100%'       ;
		var divMainLayoutPanel = document.getElementById(sLayoutPanel);
		divMainLayoutPanel.appendChild(divDashboard);
	}
	catch(e)
	{
		SplendidError.SystemMessage(SplendidError.FormatError(e, 'DashboardUI.Clear'));
	}
};

DashboardUI.prototype.Render = function(sLayoutPanel, sActionsPanel, row, arrDASHBOARDS_PANELS, callback)
{
	var bgPage = chrome.extension.getBackgroundPage();
	var divDashboard = document.getElementById(sLayoutPanel + '_divDashboard');
	while ( divDashboard.childNodes.length > 0 )
	{
		divDashboard.removeChild(divDashboard.firstChild);
	}
	
	var sID   = null;
	var sNAME = '';
	if ( row != null )
	{
		sID   = Sql.ToString(row['ID'  ])
		sNAME = Sql.ToString(row['NAME']);
	}
	SplendidUI_ModuleHeader(sLayoutPanel, sActionsPanel, this.MODULE, sNAME, sID);

	if ( arrDASHBOARDS_PANELS != null && arrDASHBOARDS_PANELS.length > 0 )
	{
		for ( var nLayoutIndex in arrDASHBOARDS_PANELS )
		{
			var lay = arrDASHBOARDS_PANELS[nLayoutIndex];
			if ( Sql.IsEmptyGuid(lay.DASHBOARD_APP_ID) )
				lay.PANEL_TYPE = 'Blank';
			else
				lay.PANEL_TYPE = 'Panel';
		}

		var arrRowItems = new Array();
		arrRowItems.push(0);
		var nRowIndex = 0;
		var nLAST_ROW_INDEX = null;
		for ( var nLayoutIndex in arrDASHBOARDS_PANELS )
		{
			var lay = arrDASHBOARDS_PANELS[nLayoutIndex];
			if ( nLAST_ROW_INDEX == null )
			{
				nLAST_ROW_INDEX = lay.ROW_INDEX;
				arrRowItems[nRowIndex]++;
			}
			else if ( nLAST_ROW_INDEX != lay.ROW_INDEX )
			{
				nLAST_ROW_INDEX = lay.ROW_INDEX;
				arrRowItems.push(1);
				nRowIndex++;
			}
			else
			{
				arrRowItems[nRowIndex]++;
			}
		}
		nRowIndex = 0;
		nLAST_ROW_INDEX = null;
		for ( var nLayoutIndex in arrDASHBOARDS_PANELS )
		{
			var lay = arrDASHBOARDS_PANELS[nLayoutIndex];
			if ( nLAST_ROW_INDEX == null )
			{
				nLAST_ROW_INDEX = lay.ROW_INDEX;
			}
			else if ( nLAST_ROW_INDEX != lay.ROW_INDEX )
			{
				nLAST_ROW_INDEX = lay.ROW_INDEX;
				nRowIndex++;
			}
			if      ( arrRowItems[nRowIndex] <= 1 ) lay.COLUMN_WIDTH = 12;
			else if ( arrRowItems[nRowIndex] <= 2 ) lay.COLUMN_WIDTH =  6;
			else if ( arrRowItems[nRowIndex] <= 3 ) lay.COLUMN_WIDTH =  4;
			else if ( arrRowItems[nRowIndex] <= 4 ) lay.COLUMN_WIDTH =  3;
			else if ( arrRowItems[nRowIndex] <= 6 ) lay.COLUMN_WIDTH =  2;
			else                                    lay.COLUMN_WIDTH =  1;
		}

		var tr = null;
		var td = null;
		nRowIndex = 0;
		nLAST_ROW_INDEX = null;
		for ( var nPanelIndex in arrDASHBOARDS_PANELS )
		{
			var panel = arrDASHBOARDS_PANELS[nPanelIndex];
			if ( nLAST_ROW_INDEX == null || nLAST_ROW_INDEX != panel.ROW_INDEX )
			{
				nLAST_ROW_INDEX = panel.ROW_INDEX;
				tr = document.createElement('div');
				divDashboard.appendChild(tr);
				tr.className = 'row';
			}
			td = document.createElement('div');
			td.className = 'col-xs-' + panel.COLUMN_WIDTH.toString();
			tr.appendChild(td);
			
			var sPANEL_TYPE = panel.PANEL_TYPE;
			if ( sPANEL_TYPE != 'Blank' )
			{
				var div = document.createElement('div');
				td.appendChild(div);
				div.className = 'x_panel tile';
				this.RenderField(sLayoutPanel + '_divDashboard', sActionsPanel, div, panel.ID, panel.TITLE, panel.SCRIPT_URL, panel.SETTINGS_EDITVIEW, panel.DEFAULT_SETTINGS);
			}
		}
	}
	callback(1, null);
};

DashboardUI.prototype.RenderField = function(sLayoutPanel, sActionsPanel, div, sID, sTITLE, sSCRIPT_URL, sSETTINGS_EDITVIEW, sDEFAULT_SETTINGS)
{
	var divPANEL_TITLE = document.createElement('div');
	div.appendChild(divPANEL_TITLE);
	divPANEL_TITLE.className = 'x_title';
	var h2 = document.createElement('h2');
	divPANEL_TITLE.appendChild(h2);
	$(h2).text(L10n.Term(sTITLE));
	var ulNavBar = document.createElement('ul');
	divPANEL_TITLE.appendChild(ulNavBar);
	ulNavBar.className = 'nav navbar-right panel_toolbox';
	
	var liSettings = document.createElement('li');
	ulNavBar.appendChild(liSettings);
	var aSettings = document.createElement('a');
	liSettings.appendChild(aSettings);
	var spnSettings = document.createElement('span');
	aSettings.appendChild(spnSettings);
	spnSettings.className = 'glyphicon glyphicon-cog';
	spnSettings.style.fontSize = '1.5em';

	var liRefresh = document.createElement('li');
	ulNavBar.appendChild(liRefresh);
	var aRefresh = document.createElement('a');
	liRefresh.appendChild(aRefresh);
	var spnRefresh = document.createElement('span');
	aRefresh.appendChild(spnRefresh);
	spnRefresh.className = 'glyphicon glyphicon-refresh';
	spnRefresh.style.fontSize = '1.5em';

	var clearfix = document.createElement('div');
	divPANEL_TITLE.appendChild(clearfix);
	clearfix.className = 'clearfix';

	var sPANEL_ID = sLayoutPanel + '_' + sID.replace('-', '_');
	var divPANEL_CONTENT = document.createElement('div');
	div.appendChild(divPANEL_CONTENT);
	divPANEL_CONTENT.id        = sPANEL_ID;
	divPANEL_CONTENT.className = 'x_content';

	var sPANEL_SETTINGS_ID = sPANEL_ID + '_Settings';
	var divPANEL_SETTINGS = document.createElement('div');
	divPANEL_CONTENT.appendChild(divPANEL_SETTINGS);
	divPANEL_SETTINGS.id        = sPANEL_SETTINGS_ID;
	divPANEL_SETTINGS.style.display = 'none';

	clearfix = document.createElement('div');
	divPANEL_CONTENT.appendChild(clearfix);
	clearfix.className = 'clearfix';

	var sPANEL_BODY_ID = sPANEL_ID + '_Body';
	var divPANEL_BODY = document.createElement('div');
	divPANEL_CONTENT.appendChild(divPANEL_BODY);
	divPANEL_BODY.id        = sPANEL_BODY_ID;
	
	clearfix = document.createElement('div');
	divPANEL_CONTENT.appendChild(clearfix);
	clearfix.className = 'clearfix';

	spnSettings.onclick = function()
	{
		var divPANEL_SETTINGS = document.getElementById(sPANEL_SETTINGS_ID);
		divPANEL_SETTINGS.style.display = (divPANEL_SETTINGS.style.display == 'none' ? 'inline' : 'none');
	}

	try
	{
		sSCRIPT_URL = sSCRIPT_URL.replace('~/', sREMOTE_SERVER);
		// 06/21/2017 Paul.  The require() system is caching old values.
		sSCRIPT_URL += '?version=' + sAssemblyVersion;
		require([sSCRIPT_URL], function(panel)
		{
			try
			{
				panel.Render(sPANEL_BODY_ID, sPANEL_SETTINGS_ID, sSCRIPT_URL, sSETTINGS_EDITVIEW, sDEFAULT_SETTINGS);
				spnRefresh.onclick = function()
				{
					var bgPage = chrome.extension.getBackgroundPage();
					bgPage.AuthenticatedMethod(function(status, message)
					{
						if ( status == 1 )
						{
							var divPANEL_BODY = document.getElementById(sPANEL_BODY_ID);
							while ( divPANEL_BODY.childNodes.length > 0 )
							{
								divPANEL_BODY.removeChild(divPANEL_BODY.firstChild);
							}
							panel.Render(sPANEL_BODY_ID, sPANEL_SETTINGS_ID, sSCRIPT_URL, sSETTINGS_EDITVIEW, sDEFAULT_SETTINGS);
						}
					}, this);
				}
			}
			catch(e)
			{
				SplendidError.SystemError(e, 'DashboardUI.RenderField.require');
			}
		});
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'DashboardUI.RenderField');
	}
}

DashboardUI.prototype.Load = function(sLayoutPanel, sActionsPanel, sID, callback, context)
{
	try
	{
		this.Clear(sLayoutPanel, sActionsPanel);
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				bgPage.Terminology_LoadModule(this.MODULE, function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						ctlActiveMenu.ActivateTab(this.MODULE, null, this.MODULE, this);
						// 06/29/2017 Paul.  The Create button is intrusive, especially on a mobile device. 
						//DynamicButtonsUI_Load(sLayoutPanel, sActionsPanel, '', 'Dashboard.MainView', null, this.PageCommand, function(status, message)
						//{
						//}, this);
						
						if ( Sql.IsEmptyString(sID) )
						{
							sID = this.CURRENT_DASHBOARD_ID;
						}
						this.CURRENT_DASHBOARD_ID = Sql.ToString(sID);
						if ( window.localStorage )
							localStorage[this.CATEGORY + 'LastDashboard'] = this.CURRENT_DASHBOARD_ID;
						else
							setCookie(this.CATEGORY + 'LastDashboard', this.CURRENT_DASHBOARD_ID, 180);
						if ( !Sql.IsEmptyString(sID) )
						{
							bgPage.Dashboards_LoadPanels(this.CURRENT_DASHBOARD_ID, function(status, message)
							{
								if ( status == 1 )
								{
									var arrDASHBOARDS_PANELS = message;
									bgPage.Dashboards_LoadItem(this.CURRENT_DASHBOARD_ID, function(status, message)
									{
										if ( status == 1 )
										{
											var row = null;
											if ( message instanceof Array && message.length > 0 )
												row = message[0];
											this.Render(sLayoutPanel, sActionsPanel, row, arrDASHBOARDS_PANELS, callback);
										}
										else
										{
											SplendidError.SystemMessage(message);
										}
									}, this);
								}
								else
								{
									SplendidError.SystemMessage(message);
								}
							}, this);
						}
						else
						{
							var sCATEGORY = this.CATEGORY;
							// 06/29/2017 Paul.  ASSIGNED_USER_ID is null for global dashboards. 
							var sSEARCH_FILTER = "ASSIGNED_USER_ID eq \'" + Security.USER_ID() + "\' and CATEGORY eq \'" + sCATEGORY + "\'";
							bgPage.ListView_LoadModule('Dashboard', 'NAME', 'asc', 'ID, NAME', sSEARCH_FILTER, null, function(status, message, __total)
							{
								if ( status == 1 )
								{
									var rows = message;
									if ( rows.length > 0 )
									{
										var row = rows[0];
										// 10/20/2017 Paul.  Need the Sql.To*() functions. 
										sID = Sql.ToGuid(row['ID']);
										if ( window.localStorage )
											localStorage[sCATEGORY + 'LastDashboard'] = sID;
										else
											setCookie(sCATEGORY + 'LastDashboard', sID, 180);
										if ( !Sql.IsEmptyString(sID) )
										{
											this.Load(sLayoutPanel, sActionsPanel, sID, callback, context);
										}
										callback(1, null);
									}
									else
									{
										// 06/29/2017 Paul.  Load default dashboards if none are set. 
										sSEARCH_FILTER = "ASSIGNED_USER_ID is null and CATEGORY eq \'" + sCATEGORY + "\'";
										bgPage.ListView_LoadModule('Dashboard', 'NAME', 'asc', 'ID, NAME', sSEARCH_FILTER, null, function(status, message, __total)
										{
											if ( status == 1 )
											{
												rows = message;
												if ( rows.length > 0 )
												{
													var row = rows[0];
													// 10/20/2017 Paul.  Need the Sql.To*() functions. 
													sID = Sql.ToGuid(row['ID']);
													if ( window.localStorage )
														localStorage[sCATEGORY + 'LastDashboard'] = sID;
													else
														setCookie(sCATEGORY + 'LastDashboard', sID, 180);
													if ( !Sql.IsEmptyString(sID) )
													{
														this.Load(sLayoutPanel, sActionsPanel, sID, callback, context);
													}
												}
												callback(1, null);
											}
											else
											{
												callback(status, message);
											}
										}, this);
									}
								}
								else
								{
									callback(status, message);
								}
							}, this);
						}
						SplendidUI_Cache(function(status, message)
						{
							if ( status == 2 )
							{
								SplendidError.SystemMessage(message);
							}
						});
					}
					else
					{
						callback.call(context||this, status, message);
					}
				}, this);
			}
			else
			{
				callback.call(context||this, -1, message);
			}
		}, this);
	}
	catch(e)
	{
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'DashboardUI.Load'));
	}
};

