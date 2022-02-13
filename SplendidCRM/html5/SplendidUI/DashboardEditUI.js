/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function DashboardEditUI(sCATEGORY)
{
	this.nFieldListWidth    = 200;
	this.ID                 = null;
	this.MODULE             = 'Dashboard';
	this.CATEGORY           = sCATEGORY;
	this.DASHBOARD          = null;
	this.DASHBOARD_APPS     = new Array();
	this.divSelectedLayoutField = null;
}

DashboardEditUI.prototype.Clear = function(sLayoutPanel, sActionsPanel)
{
	var divMainLayoutPanel = document.getElementById(sActionsPanel);
	if ( divMainLayoutPanel != null && divMainLayoutPanel.childNodes != null )
	{
		while ( divMainLayoutPanel.childNodes.length > 0 )
		{
			divMainLayoutPanel.removeChild(divMainLayoutPanel.firstChild);
		}
	}
	divMainLayoutPanel = document.getElementById(sLayoutPanel);
	if ( divMainLayoutPanel != null && divMainLayoutPanel.childNodes != null )
	{
		while ( divMainLayoutPanel.childNodes.length > 0 )
		{
			divMainLayoutPanel.removeChild(divMainLayoutPanel.firstChild);
		}
	}
	// 07/31/2017 Paul.  Calculate the height so that we can create an auto scroll region. 
	var rect = divMainLayoutPanel.getBoundingClientRect();
	var nFrameHeight = $(window).height() - rect.top - $('#divFooterCopyright').height();
	if ( nFrameHeight < 500 )
		nFrameHeight = 500;

	var tblLayoutFrame = document.createElement('table');
	tblLayoutFrame.id    = 'tblLayoutFrame';
	tblLayoutFrame.width = '100%';
	tblLayoutFrame.style.border = '1px solid black';
	tblLayoutFrame.style.height = nFrameHeight.toString() + 'px';
	divMainLayoutPanel.appendChild(tblLayoutFrame);
	var tbody = document.createElement('tbody');
	tblLayoutFrame.appendChild(tbody);
	var tr = document.createElement('tr');
	tbody.appendChild(tr);

	var tdLayoutFrameFieldList  = document.createElement('td');
	tdLayoutFrameFieldList.id                  = 'tdLayoutFrameFieldList;'
	tdLayoutFrameFieldList.width               = '230px';
	tdLayoutFrameFieldList.style.verticalAlign = 'top';
	tdLayoutFrameFieldList.style.border        = '1px solid black';
	tr.appendChild(tdLayoutFrameFieldList);
	var tdLayoutFrameLayout = document.createElement('td');
	tdLayoutFrameLayout.style.verticalAlign    = 'top';
	tdLayoutFrameLayout.style.border           = '1px solid black';
	tr.appendChild(tdLayoutFrameLayout);
	var tdLayoutFrameProperties = document.createElement('td');
	tdLayoutFrameProperties.id                  = 'tdLayoutFrameProperties';
	tdLayoutFrameProperties.width               = '300px';
	tdLayoutFrameProperties.style.verticalAlign = 'top';
	tdLayoutFrameProperties.style.border        = '1px solid black';
	tr.appendChild(tdLayoutFrameProperties);

	var divDashboardApps = document.createElement('div');
	divDashboardApps.id = 'divDashboardApps';
	tdLayoutFrameFieldList.appendChild(divDashboardApps);
	
	var tblLayoutTableFrame = document.createElement('div');
	tblLayoutTableFrame.id = 'tblLayoutTableFrame';
	tdLayoutFrameLayout.appendChild(tblLayoutTableFrame);
	//var divLayoutError = document.createElement('div');
	//divLayoutError.id = 'divLayoutError';
	//tblLayoutTableFrame.appendChild(divLayoutError);
	
	var divLayoutButtons = document.createElement('div');
	divLayoutButtons.id = 'divLayoutButtons';
	tblLayoutTableFrame.appendChild(divLayoutButtons);
	var tblDashboard = document.createElement('table');
	tblDashboard.id           = 'tblDashboard';
	tblDashboard.width        = '100%';
	tblDashboard.style.border = '1px solid black';
	tblLayoutTableFrame.appendChild(tblDashboard);
	var tblLayout = document.createElement('div');
	tblLayout.id           = 'tblLayout';
	tblLayout.className    = '';
	tblLayout.width        = '100%';
	tblLayout.style.border = '1px solid black';
	tblLayoutTableFrame.appendChild(tblLayout);

	var tblPropertiesFrame = document.createElement('div');
	tblPropertiesFrame.id    = 'tblPropertiesFrame';
	tblPropertiesFrame.width = '100%';
	tdLayoutFrameProperties.appendChild(tblPropertiesFrame);
	var divPropertiesButtons = document.createElement('div');
	divPropertiesButtons.id = 'divPropertiesButtons';
	tblPropertiesFrame.appendChild(divPropertiesButtons)
	var tblProperties = document.createElement('table');
	tblProperties.id           = 'tblProperties';
	tblProperties.width        = '100%';
	tblProperties.style.border = '1px solid black';
	tblPropertiesFrame.appendChild(tblProperties);
}

DashboardEditUI.prototype.PageCommand = function(sLayoutPanel, sActionsPanel, sCommandName, sCommandArguments)
{
	SplendidError.SystemMessage('');
	// 05/04/2016 Paul.  Provide a way to save a layout copy. 
	// 06/15/2019 Paul.  We currently do not support role-based dashboards, so remove the role selection. 
	/*
	if ( sCommandName == 'Copy' )
	{
		var txtCopyLayout    = document.getElementById('txtCopyLayout'   );
		var btnRoleSelect    = document.getElementById('btnRoleSelect'   );
		var btnDeleteLayout  = document.getElementById('btnDeleteLayout' );
		if ( txtCopyLayout.style.display == 'none' )
		{
			txtCopyLayout.value            = '';
			txtCopyLayout.style.display    = 'inline';
			btnRoleSelect.style.display    = 'inline';
			btnDeleteLayout.style.display  = 'none'  ;
		}
		else
		{
			txtCopyLayout.value            = '';
			txtCopyLayout.style.display    = 'none'  ;
			btnRoleSelect.style.display    = 'none'  ;
			btnDeleteLayout.style.display  = 'inline';
		}
	}
	*/
	if ( sCommandName == 'Delete' )
	{
		try
		{
			var sID = this.ID;
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.DeleteModuleItem(this.MODULE, sID, function(status, message)
			{
				if ( status == 1 )
				{
					this.MODULE  = null;
					this.ID      = null;
					// 06/02/2017 Paul.  Clear LastDashboard. 
					if ( window.localStorage )
						localStorage[this.CATEGORY + 'LastDashboard'] = '';
					else
						setCookie(this.CATEGORY + 'LastDashboard', '', 180);
					if ( ctlActiveMenu.ReloadDashboard !== undefined )
					{
						ctlActiveMenu.ReloadDashboard(sLayoutPanel, sActionsPanel, this.CATEGORY, function(status, message)
						{
						});
					}
					var oDashboardUI = new DashboardUI(this.CATEGORY);
					oDashboardUI.Load(sLayoutPanel, sActionsPanel, sID, function(status, message)
					{
					});
				}
				else
				{
					SplendidError.SystemMessage(message);
				}
			}, this);
		}
		catch(e)
		{
			SplendidError.SystemError(e, 'DashboardEditUI.PageCommand');
		}
	}
	// 06/15/2019 Paul.  We currently do not support role-based dashboards, so remove the role selection. 
	else if ( sCommandName == 'Save' || sCommandName == 'Copy' )
	{
		try
		{
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.AuthenticatedMethod(function(status, message)
			{
				if ( status == 1 )
				{
					var nPANEL_ORDER = 0;
					var row  = new Object();
					row.ID               = this.ID;
					row.CATEGORY         = this.CATEGORY;
					row.ASSIGNED_USER_ID = Security.USER_ID();
					row.TEAM_ID          = Security.TEAM_ID();
					row.NAME             = document.getElementById('tblDashboard_NAME').value;
					row.DashboardPanels = new Array();
					var tblLayout = document.getElementById('tblLayout');
					for ( var nRowIndex = 0; nRowIndex < tblLayout.childNodes.length; nRowIndex++ )
					{
						var tr = tblLayout.childNodes[nRowIndex];
						for ( var nColIndex = 0; nColIndex < tr.childNodes.length; nColIndex++ )
						{
							var td  = tr.childNodes[nColIndex];
							var div = td.childNodes[0];
							var lay = this.CreateLayoutObject(div);
							lay.PANEL_ORDER  = nPANEL_ORDER   ;
							lay.ROW_INDEX    = nRowIndex      ;
							// 05/23/2017 Paul.  The column width is stored with the TD record. 
							lay.COLUMN_WIDTH = Sql.ToInteger(td.COLUMN_WIDTH);
							row.DashboardPanels.push(lay);
							nPANEL_ORDER++;
						}
					}
					// 05/04/2016 Paul.  Provide a way to save a layout copy. 
					// 06/15/2019 Paul.  We currently do not support role-based dashboards, so remove the role selection. 
					if ( sCommandName == 'Copy' )
					{
						row.ID = null;
						/*
						var txtCopyLayout = document.getElementById('txtCopyLayout');
						if ( txtCopyLayout.style.display == 'inline' )
						{
							txtCopyLayout.value = Trim(txtCopyLayout.value);
							if ( Sql.IsEmptyString(txtCopyLayout.value) )
							{
								var message = L10n.Term('DynamicLayout.ERR_NEW_LAYOUT_NAME');
								SplendidError.SystemMessage(message);
								return;
							}
							else
							{
								row.NAME = txtCopyLayout.value;
								this.ID = null;
							}
						}
						*/
					}
					// 06/01/2017 Paul.  If this is a global dashboard (i.e. ASSIGNED_USER_ID is null), then save action will create a new dashboard. 
					if ( this.DASHBOARD != null )
					{
						if ( Sql.IsEmptyGuid(this.DASHBOARD.ASSIGNED_USER_ID) )
							row.ID = null;
					}
					bgPage.UpdateModule(this.MODULE, row, row.ID, function(status, message)
					{
						try
						{
							// 10/06/2011 Paul.  Status 3 means that the value was cached. 
							if ( status == 1 || status == 3 )
							{
								var sID = message;
								this.MODULE  = null;
								this.ID      = null;
								if ( ctlActiveMenu.ReloadDashboard !== undefined )
								{
									ctlActiveMenu.ReloadDashboard(sLayoutPanel, sActionsPanel, this.CATEGORY, function(status, message)
									{
									});
								}
								var oDashboardUI = new DashboardUI(this.CATEGORY);
								oDashboardUI.Load(sLayoutPanel, sActionsPanel, sID, function(status, message)
								{
								});
							}
							else
							{
								SplendidError.SystemMessage(message);
							}
						}
						catch(e)
						{
							SplendidError.SystemError(e, 'DashboardEditUI.PageCommand');
						}
					}, this);
				}
				else
				{
					SplendidError.SystemMessage(message);
				}
			}, this);
		}
		catch(e)
		{
			SplendidError.SystemError(e, 'DashboardEditUI.PageCommand');
		}
	}
	else if ( sCommandName == 'Cancel' )
	{
		try
		{
			//this.Clear(sLayoutPanel, sActionsPanel);
			var oDashboardUI = new DashboardUI(this.CATEGORY);
			oDashboardUI.Load(sLayoutPanel, sActionsPanel, null, function(status, message)
			{
			});
		}
		catch(e)
		{
			SplendidError.SystemError(e, 'DashboardEditUI.PageCommand');
		}
	}
}

DashboardEditUI.prototype.AddProperty = function(tblProperties, sFieldName, sFieldValue)
{
	var tr = null;
	var tdLabel = null;
	var tdField = null;
	tr = tblProperties.insertRow(-1);
	tr.id = 'tblProperties_tr' + sFieldName;
	tdLabel = tr.insertCell(-1);
	tdField = tr.insertCell(-1);
	tdLabel.style.width = '35%';
	$(tdLabel).text(L10n.TableColumnName('Dashboard', sFieldName));
	var spn = document.createElement('span');
	spn.id = 'tblProperties_' + sFieldName;
	$(spn).text(sFieldValue);
	tdField.appendChild(spn);
}

DashboardEditUI.prototype.AddTextBoxProperty = function(tblProperties, sFieldName, sFieldValue, sWidth)
{
	var tr = null;
	var tdLabel = null;
	var tdField = null;
	tr = tblProperties.insertRow(-1);
	tr.id = 'tblProperties_tr' + sFieldName;
	tdLabel = tr.insertCell(-1);
	tdField = tr.insertCell(-1);
	tdLabel.id = 'tblProperties_' + sFieldName + '_LABEL';
	tdLabel.style.width = '35%';
	$(tdLabel).text(L10n.Term('Dashboard.LBL_' + sFieldName));
	//$(tdField).text(sFieldValue);
	var txt = document.createElement('input');
	txt.id    = 'tblProperties_' + sFieldName;
	txt.type  = 'text';
	txt.style.width = (sWidth === undefined ? '200px' : sWidth);
	txt.value = sFieldValue;
	tdField.appendChild(txt);
}

DashboardEditUI.prototype.AddTextAreaProperty = function(tblProperties, sFieldName, sFieldValue)
{
	var tr = null;
	var tdLabel = null;
	var tdField = null;
	tr = tblProperties.insertRow(-1);
	tr.id = 'tblProperties_tr' + sFieldName;
	tdLabel = tr.insertCell(-1);
	tdField = tr.insertCell(-1);
	tdLabel.style.width = '35%';
	$(tdLabel).text(L10n.Term('Dashboard.LBL_' + sFieldName));
	//$(tdField).text(sFieldValue);
	var txt = document.createElement('textarea');
	txt.id           = 'tblProperties_' + sFieldName;
	txt.style.width  = '95%';
	txt.rows         = 3;
	txt.value = sFieldValue;
	tdField.appendChild(txt);
}

DashboardEditUI.prototype.AddListBoxProperty = function(tblProperties, sFieldName, sFieldValue, sListName, bAllowNone)
{
	var tr = null;
	var tdLabel = null;
	var tdField = null;
	tr = tblProperties.insertRow(-1);
	tr.id = 'tblProperties_tr' + sFieldName;
	tdLabel = tr.insertCell(-1);
	tdField = tr.insertCell(-1);
	tdLabel.style.width = '35%';
	$(tdLabel).text(L10n.Term('Dashboard.LBL_' + sFieldName));
	//$(tdField).text(sFieldValue);
	var lst = document.createElement('select');
	lst.id      = 'tblProperties_' + sFieldName;
	tdField.appendChild(lst);
	// 04/10/2016 Paul.  Add item to list if not found. 
	var bFound = false;
	if ( sListName instanceof Array )
	{
		var arrLIST = sListName;
		var opt = document.createElement('option');
		if ( bAllowNone )
			lst.appendChild(opt);
		for ( var i = 0; i < arrLIST.length; i++ )
		{
			opt = document.createElement('option');
			lst.appendChild(opt);
			opt.setAttribute('value', arrLIST[i]);
			$(opt).text(arrLIST[i]);
			if ( sFieldValue != null && sFieldValue == arrLIST[i] )
			{
				opt.setAttribute('selected', 'selected');
				bFound = true;
			}
		}
	}
	else if ( typeof(sListName) == 'string' )
	{
		var arrLIST = L10n.GetList(sListName);
		if ( arrLIST != null && arrLIST instanceof Array )
		{
			var opt = document.createElement('option');
			if ( bAllowNone )
				lst.appendChild(opt);
			for ( var i = 0; i < arrLIST.length; i++ )
			{
				opt = document.createElement('option');
				lst.appendChild(opt);
				opt.setAttribute('value', arrLIST[i]);
				opt.innerHTML = L10n.ListTerm(sListName, arrLIST[i]);
				if ( sFieldValue != null && sFieldValue == arrLIST[i] )
				{
					opt.setAttribute('selected', 'selected');
					bFound = true;
				}
			}
		}
	}
	// 04/10/2016 Paul.  Add item to list if not found. 
	if ( !bFound && sFieldValue != null )
	{
		var opt = document.createElement('option');
		lst.appendChild(opt);
		opt.setAttribute('value', sFieldValue);
		opt.innerHTML = sFieldValue;
		opt.setAttribute('selected', 'selected');
	}
}

DashboardEditUI.prototype.ShowProperty = function(sFieldName, bVisible)
{
	var tr = document.getElementById('tblProperties_tr' + sFieldName);
	if ( tr != null )
		tr.style.display = (bVisible ? 'table-row' : 'none');
}

DashboardEditUI.prototype.GetPropertyVisibility = function(sFieldName)
{
	var bVisible = false;
	var tr = document.getElementById('tblProperties_tr' + sFieldName);
	if ( tr != null )
		bVisible = (tr.style.display != 'none');
	return bVisible;
}

DashboardEditUI.prototype.GetPropertyValue = function(sFieldName)
{
	var sValue = '';
	if ( this.GetPropertyVisibility(sFieldName) )
	{
		var fld = document.getElementById('tblProperties_' + sFieldName);
		if ( fld != null )
		{
			var sTagName = fld.tagName.toLowerCase();
			if ( sTagName == 'input' )
			{
				if ( fld.type == 'checkbox' )
				{
					sValue = fld.checked.toString();
				}
				else
				{
					sValue = fld.value;
				}
			}
			else if ( sTagName == 'textarea' )
			{
				sValue = fld.value;
			}
			else if ( sTagName == 'span' )
			{
				// 03/14/2016 Paul.  Firefox does not support innerText. 
				sValue = $(fld).text();
			}
			else if ( sTagName == 'select' )
			{
				sValue = fld.options[fld.options.selectedIndex].value;
			}
		}
	}
	return sValue;
}

DashboardEditUI.prototype.SaveProperties = function()
{
	if ( this.divSelectedLayoutField != null )
	{
		var obj = new Object();
		obj.ID                = this.divSelectedLayoutField.ID               ;
		obj.PANEL_TYPE        = this.divSelectedLayoutField.PANEL_TYPE       ;
		obj.DASHBOARD_APP_ID  = this.divSelectedLayoutField.DASHBOARD_APP_ID ;
		obj.NAME              = this.divSelectedLayoutField.NAME             ;
		obj.CATEGORY          = this.divSelectedLayoutField.CATEGORY         ;
		obj.MODULE_NAME       = this.divSelectedLayoutField.MODULE_NAME      ;
		obj.TITLE             = this.divSelectedLayoutField.TITLE            ;
		obj.SETTINGS_EDITVIEW = this.divSelectedLayoutField.SETTINGS_EDITVIEW;
		obj.IS_ADMIN          = this.divSelectedLayoutField.IS_ADMIN         ;
		obj.APP_ENABLED       = this.divSelectedLayoutField.APP_ENABLED      ;
		obj.SCRIPT_URL        = this.divSelectedLayoutField.SCRIPT_URL       ;
		obj.DEFAULT_SETTINGS  = this.divSelectedLayoutField.DEFAULT_SETTINGS ;
		//obj.PARENT_FIELD      = this.GetPropertyValue('PARENT_FIELD');
		
		this.SetLayoutObject(this.divSelectedLayoutField, obj);
	}
	this.CancelProperties();
	return false;
}

DashboardEditUI.prototype.CancelProperties = function()
{
	this.divSelectedLayoutField = null;
	var divPropertiesButtons = document.getElementById('divPropertiesButtons');
	divPropertiesButtons.style.display = 'none';
	while ( divPropertiesButtons.childNodes.length > 0 )
	{
		divPropertiesButtons.removeChild(divPropertiesButtons.firstChild);
	}

	var tblProperties = document.getElementById('tblProperties');
	if ( tblProperties.rows != null )
	{
		while ( tblProperties.rows.length > 0 )
		{
			tblProperties.deleteRow(0);
		}
	}
	return false;
}

DashboardEditUI.prototype.LoadProperties = function(divLayoutField)
{
	this.divSelectedLayoutField = divLayoutField;

	var divPropertiesButtons = document.getElementById('divPropertiesButtons');
	divPropertiesButtons.style.display = 'block';
	while ( divPropertiesButtons.childNodes.length > 0 )
	{
		divPropertiesButtons.removeChild(divPropertiesButtons.firstChild);
	}
	
	/*
	var btnPropertiesSave   = document.createElement('input');
	btnPropertiesSave.id                = 'btnPropertiesSave';
	btnPropertiesSave.type              = 'button';
	btnPropertiesSave.className         = 'btn btn-primary';
	btnPropertiesSave.value             = L10n.Term('.LBL_SAVE_BUTTON_LABEL'  );
	btnPropertiesSave.style.cursor      = 'pointer';
	btnPropertiesSave.style.marginRight = '3px';
	divPropertiesButtons.appendChild(btnPropertiesSave  );
	btnPropertiesSave.onclick     = BindArguments(function(context)
	{
		context.SaveProperties();
	}, this);
	*/
	var btnPropertiesCancel = document.createElement('input');
	divPropertiesButtons.appendChild(btnPropertiesCancel);
	btnPropertiesCancel.id                = 'btnPropertiesCancel';
	btnPropertiesCancel.type              = 'button';
	btnPropertiesCancel.className         = 'btn btn-primary';
	btnPropertiesCancel.value             = L10n.Term('.LBL_CANCEL_BUTTON_LABEL');
	btnPropertiesCancel.style.cursor      = 'pointer';
	btnPropertiesCancel.style.marginRight = '3px';
	btnPropertiesCancel.onclick   = BindArguments(function(context)
	{
		context.CancelProperties();
	}, this);

	var tblProperties = document.getElementById('tblProperties');
	if ( tblProperties.rows != null )
	{
		while ( tblProperties.rows.length > 0 )
		{
			tblProperties.deleteRow(0);
		}
	}
	/*
	// 02/25/2016 Paul.  DATA_FIELD and DATA_FORMAT should be text area. 
	this.AddListBoxProperty (tblProperties, "FIELD_TYPE"                , Sql.ToString (divLayoutField.FIELD_TYPE                ), this.FIELD_TYPES       , false);
	this.AddListBoxProperty (tblProperties, "DATA_LABEL"                , Sql.ToString (divLayoutField.DATA_LABEL                ), this.MODULE_TERMINOLOGY, true );
	this.AddTextAreaProperty(tblProperties, "DATA_FIELD"                , Sql.ToString (divLayoutField.DATA_FIELD                ));
	this.AddTextAreaProperty(tblProperties, "DATA_FORMAT"               , Sql.ToString (divLayoutField.DATA_FORMAT               ));
	this.AddTextAreaProperty(tblProperties, "URL_FIELD"                 , Sql.ToString (divLayoutField.URL_FIELD                 ));
	this.AddTextAreaProperty(tblProperties, "URL_FORMAT"                , Sql.ToString (divLayoutField.URL_FORMAT                ));
	this.AddTextBoxProperty (tblProperties, "URL_TARGET"                , Sql.ToString (divLayoutField.URL_TARGET                ));
	this.AddListBoxProperty (tblProperties, "MODULE_TYPE"               , Sql.ToString (divLayoutField.MODULE_TYPE               ), TERMINOLOGY_LISTS['MODULE_TYPES'], true );
	this.AddListBoxProperty (tblProperties, "LIST_NAME"                 , Sql.ToString (divLayoutField.LIST_NAME                 ), TERMINOLOGY_LISTS['vwTERMINOLOGY_PickList'], true );
	this.AddListBoxProperty (tblProperties, "COLSPAN"                   , Sql.ToInteger(divLayoutField.COLSPAN                   ), this.COLSPANS          , false);
	this.AddTextBoxProperty (tblProperties, "TOOL_TIP"                  , Sql.ToString (divLayoutField.TOOL_TIP                  ));
	this.AddTextBoxProperty (tblProperties, "PARENT_FIELD"              , Sql.ToString (divLayoutField.PARENT_FIELD              ));
	var lstFIELD_TYPE = document.getElementById('tblProperties_FIELD_TYPE');
	lstFIELD_TYPE.onchange = BindArguments(function(context)
	{
		context.FieldTypeChanged();
	}, this);
	this.FieldTypeChanged();
	*/
	this.AddProperty(tblProperties, 'ID'               , Sql.ToGuid   (divLayoutField.ID               ));
	this.AddProperty(tblProperties, 'PANEL_TYPE'       , Sql.ToString (divLayoutField.PANEL_TYPE       ));
	this.AddProperty(tblProperties, 'DASHBOARD_APP_ID' , Sql.ToGuid   (divLayoutField.DASHBOARD_APP_ID ));
	this.AddProperty(tblProperties, 'NAME'             , Sql.ToString (divLayoutField.NAME             ));
	this.AddProperty(tblProperties, 'CATEGORY'         , Sql.ToString (divLayoutField.CATEGORY         ));
	this.AddProperty(tblProperties, 'MODULE_NAME'      , Sql.ToString (divLayoutField.MODULE_NAME      ));
	this.AddProperty(tblProperties, 'TITLE'            , Sql.ToString (divLayoutField.TITLE            ));
	this.AddProperty(tblProperties, 'SETTINGS_EDITVIEW', Sql.ToString (divLayoutField.SETTINGS_EDITVIEW));
	this.AddProperty(tblProperties, 'IS_ADMIN'         , Sql.ToBoolean(divLayoutField.IS_ADMIN         ));
	this.AddProperty(tblProperties, 'APP_ENABLED'      , Sql.ToBoolean(divLayoutField.APP_ENABLED      ));
	this.AddProperty(tblProperties, 'SCRIPT_URL'       , Sql.ToString (divLayoutField.SCRIPT_URL       ));
	this.AddProperty(tblProperties, 'DEFAULT_SETTINGS' , Sql.ToString (divLayoutField.DEFAULT_SETTINGS ));
}

DashboardEditUI.prototype.LoadFromLayout = function(sLayoutPanel, sActionsPanel, arrDASHBOARDS_PANELS)
{
	var divDashboardApps = document.getElementById('divDashboardApps');
	var tblLayout = document.getElementById('tblLayout');
	while ( tblLayout.childNodes.length > 0 )
	{
		tblLayout.removeChild(tblLayout.firstChild);
	}

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
		for ( var nLayoutIndex in arrDASHBOARDS_PANELS )
		{
			var lay = arrDASHBOARDS_PANELS[nLayoutIndex];
			if ( nLAST_ROW_INDEX == null || nLAST_ROW_INDEX != lay.ROW_INDEX )
			{
				nLAST_ROW_INDEX = lay.ROW_INDEX;
				tr = document.createElement('div');
				tblLayout.appendChild(tr);
				this.BindRow(tblLayout, tr, lay);
			}
			td = document.createElement('div');
			td.className = 'col-xs-' + lay.COLUMN_WIDTH.toString();
			td.COLUMN_WIDTH = lay.COLUMN_WIDTH;
			tr.appendChild(td);
			this.BindColumn(td, lay);
		}
	}
	// 05/16/2017 Paul.  If the list is empty, then add a blank row. 
	else
	{
		var tr = document.createElement('div');
		tblLayout.appendChild(tr);
		this.BindRow(tblLayout, tr);

		var td = document.createElement('div');
		td.className = 'col-xs-12';
		tr.appendChild(td);
		this.BindColumn(td, null);
	}
}

DashboardEditUI.prototype.CreateLayoutObject = function(src)
{
	var obj = new Object();
	obj.ID                = Sql.ToGuid   (src.ID               );
	obj.PANEL_TYPE        = Sql.ToString (src.PANEL_TYPE       );
	obj.DASHBOARD_APP_ID  = Sql.ToGuid   (src.DASHBOARD_APP_ID );
	obj.NAME              = Sql.ToString (src.NAME             );
	obj.CATEGORY          = Sql.ToString (src.CATEGORY         );
	obj.MODULE_NAME       = Sql.ToString (src.MODULE_NAME      );
	obj.TITLE             = Sql.ToString (src.TITLE            );
	obj.SETTINGS_EDITVIEW = Sql.ToString (src.SETTINGS_EDITVIEW);
	obj.IS_ADMIN          = Sql.ToBoolean(src.IS_ADMIN         );
	obj.APP_ENABLED       = Sql.ToBoolean(src.APP_ENABLED      );
	obj.SCRIPT_URL        = Sql.ToString (src.SCRIPT_URL       );
	obj.DEFAULT_SETTINGS  = Sql.ToString (src.DEFAULT_SETTINGS );
	return obj;
}

DashboardEditUI.prototype.RenderField = function(div)
{
	while ( div.childNodes.length > 0 )
	{
		div.removeChild(div.firstChild);
	}
	
	var divPANEL_TITLE  = document.createElement('div');
	var divPANEL_MODULE = document.createElement('div');
	div.appendChild(divPANEL_TITLE );
	div.appendChild(divPANEL_MODULE);
	$(divPANEL_TITLE ).text(L10n.Term(div.TITLE));
	$(divPANEL_MODULE).text(div.MODULE_NAME);
	if ( Sql.IsEmptyString(div.MODULE_NAME) )
	{
		var nbsp = String.fromCharCode(160);
		$(divPANEL_MODULE).text(nbsp);
	}
	// 03/13/2016 Paul.  Display the list name to make it easier to confirm the change. 
	if ( !Sql.IsEmptyString(div.LIST_NAME) )
	{
		var nbsp = String.fromCharCode(160);
		$(divPANEL_MODULE).text($(divPANEL_MODULE).text() + nbsp + div.LIST_NAME);
	}
	// 03/13/2016 Paul.  Display the module type to make it easier to confirm the change. 
	if ( !Sql.IsEmptyString(div.MODULE_TYPE) )
	{
		var nbsp = String.fromCharCode(160);
		$(divPANEL_MODULE).text($(divPANEL_MODULE).text() + nbsp + div.MODULE_TYPE);
	}
	// 04/06/2016 Paul.  Blank field should not have edit icon. 
	if (div.PANEL_TYPE == 'Blank')
	{
		$(divPANEL_TITLE ).text(L10n.Term('Dashboard.LBL_BLANK_TYPE'));
		$(divPANEL_MODULE).text(String.fromCharCode(160));
	}
	else
	{
		var imgEdit = document.createElement('img');
		// https://css-tricks.com/all-about-floats/
		imgEdit.style.cursor  = 'pointer';
		imgEdit.style.float   = 'right';
		imgEdit.style.display = 'inline';
		imgEdit.style.padding = '0px';
		imgEdit.style.margin  = '0px';
		imgEdit.src           = sREMOTE_SERVER + 'App_Themes/Six/images/edit_inline.gif';
		divPANEL_TITLE.appendChild(imgEdit);
		imgEdit.onclick = BindArguments(function(context)
		{
			context.LoadProperties(div);
		}, this);
	}
}

DashboardEditUI.prototype.SetLayoutObject = function(div, src)
{
	div.ID                = Sql.ToGuid   (src.ID               );
	div.PANEL_TYPE        = Sql.ToString (src.PANEL_TYPE       );
	div.DASHBOARD_APP_ID  = Sql.ToGuid   (src.DASHBOARD_APP_ID );
	div.NAME              = Sql.ToString (src.NAME             );
	div.CATEGORY          = Sql.ToString (src.CATEGORY         );
	div.MODULE_NAME       = Sql.ToString (src.MODULE_NAME      );
	div.TITLE             = Sql.ToString (src.TITLE            );
	div.SETTINGS_EDITVIEW = Sql.ToString (src.SETTINGS_EDITVIEW);
	div.IS_ADMIN          = Sql.ToBoolean(src.IS_ADMIN         );
	div.APP_ENABLED       = Sql.ToBoolean(src.APP_ENABLED      );
	div.SCRIPT_URL        = Sql.ToString (src.SCRIPT_URL       );
	div.DEFAULT_SETTINGS  = Sql.ToString (src.DEFAULT_SETTINGS );
	this.RenderField(div);
}

DashboardEditUI.prototype.UpdateColumnWidths = function(tr)
{
	var nCOLUMN_WIDTH = 12;
	if      ( tr.childNodes.length <= 1 ) nCOLUMN_WIDTH = 12;
	else if ( tr.childNodes.length <= 2 ) nCOLUMN_WIDTH =  6;
	else if ( tr.childNodes.length <= 3 ) nCOLUMN_WIDTH =  4;
	else if ( tr.childNodes.length <= 4 ) nCOLUMN_WIDTH =  3;
	else if ( tr.childNodes.length <= 6 ) nCOLUMN_WIDTH =  2;
	else                                  nCOLUMN_WIDTH =  1;
	for ( var i = 0; i < tr.childNodes.length; i++ )
	{
		td = tr.childNodes[i];
		td.className    = 'col-xs-' + nCOLUMN_WIDTH.toString();
		td.COLUMN_WIDTH = nCOLUMN_WIDTH;
	}
}

DashboardEditUI.prototype.LayoutAddField = function(jDropTarget, jDragged)
{
	//alert(jDropTarget    instanceof jQuery);
	//alert(jDragged instanceof jQuery);
	//alert(jDropTarget   .attr('data-id-group'))
	//alert(jDragged.attr('data-id-group'))
	console.log('Dragged ' + jDragged.attr('data-id-group'));
	console.log('Dropped ' + jDropTarget.attr('data-id-group'));
	if ( jDragged.attr('data-id-group') == 'DashboardApp' )
	{
		if ( jDropTarget.attr('data-id-group') == 'LayoutCell' )
		{
			jDragged[0].style.display = 'none';
			
			var lay = this.CreateLayoutObject(jDragged[0]);
			var tr = jDropTarget[0].parentNode;
			var td = document.createElement('div');
			td.className = 'col-xs-12';
			if ( jDropTarget[0].nextSibling == null )
				tr.appendChild(td);
			else
				tr.insertBefore(td, jDropTarget[0].nextSibling);
			this.BindColumn(td, lay);
			this.UpdateColumnWidths(tr);
		}
		else if ( jDropTarget.attr('data-id-group') == 'DashboardPanel' )
		{
			if ( jDropTarget.prop('DASHBOARD_APP_ID') != '' )
			{
				var divField = document.getElementById('divDashboardApps_' + jDropTarget.prop('DASHBOARD_APP_ID'));
				if ( divField != null )
					divField.style.display = 'block';
			}
			jDragged[0].style.display = 'none';
			
			var lay = this.CreateLayoutObject(jDragged[0]);
			var div = jDropTarget[0];
			this.SetLayoutObject(div, lay);
		}
	}
	else if ( jDragged.attr('data-id-group') == 'DashboardPanel' )
	{
		if ( jDropTarget.attr('data-id-group') == 'LayoutCell' )
		{
			var lay = this.CreateLayoutObject(jDragged[0]);
			var tr = jDropTarget[0].parentNode;
			var td = document.createElement('div');
			td.className = 'col-xs-12';
			if ( jDropTarget[0].nextSibling == null )
				tr.appendChild(td);
			else
				tr.insertBefore(td, jDropTarget[0].nextSibling);
			this.BindColumn(td, lay);
			this.UpdateColumnWidths(tr);

			this.LayoutRemoveField(jDragged);
		}
		else if ( jDropTarget.attr('data-id-group') == 'DashboardPanel' )
		{
			if ( jDragged[0] != jDropTarget[0] )
			{
				//console.log('Swap two layout fields');
				var objDragged    = this.CreateLayoutObject(jDragged[0]);
				var objDropTarget = this.CreateLayoutObject(jDropTarget[0]);
				var lay = objDragged;
				var div = jDropTarget[0];
				this.SetLayoutObject(div, lay);
				
				lay = objDropTarget;
				div = jDragged[0];
				this.SetLayoutObject(div, lay);
			}
		}
	}
	else if ( jDragged.attr('data-id-group') == 'NewBlank' )
	{
		if ( jDropTarget.attr('data-id-group') == 'LayoutCell' )
		{
			var tr = jDropTarget[0].parentNode;
			var td = document.createElement('div');
			td.className = 'col-xs-12';
			if ( jDropTarget[0].nextSibling == null )
				tr.appendChild(td);
			else
				tr.insertBefore(td, jDropTarget[0].nextSibling);
			this.BindColumn(td, null);
			this.UpdateColumnWidths(tr);
		}
		else if ( jDropTarget.attr('data-id-group') == 'DashboardPanel' )
		{
			if ( jDropTarget.prop('DASHBOARD_APP_ID') != '' )
			{
				var divField = document.getElementById('divDashboardApps_' + jDropTarget.prop('DASHBOARD_APP_ID'));
				if ( divField != null )
					divField.style.display = 'block';
			}
			var div = jDropTarget[0];
			while ( div.childNodes.length > 0 )
			{
				div.removeChild(div.firstChild);
			}
			div.DASHBOARD_APP_ID = null;
			div.PANEL_TYPE = 'Blank';
			var divPANEL_TITLE  = document.createElement('div');
			var divPANEL_MODULE = document.createElement('div');
			div.appendChild(divPANEL_TITLE );
			div.appendChild(divPANEL_MODULE);
			$(divPANEL_TITLE ).text(L10n.Term('Dashboard.LBL_BLANK_TYPE'));
			$(divPANEL_MODULE).text(String.fromCharCode(160));
		}
	}
}

DashboardEditUI.prototype.LayoutRemoveField = function(jDragged)
{
	if ( jDragged.attr('data-id-group') == 'DashboardPanel' )
	{
		// 04/06/2016 Paul.  DASHBOARD_APP_ID is a property, not an attribute. 
		if (jDragged.prop('DASHBOARD_APP_ID') != '')
		{
			var divField = document.getElementById('divDashboardApps_' + jDragged.prop('DASHBOARD_APP_ID'));
			if ( divField != null )
				divField.style.display = 'block';
		}
		var td = jDragged[0].parentNode;
		var tr = td.parentNode;
		tr.removeChild(td);
		if ( tr.childNodes.length == 0 )
		{
			td = document.createElement('div');
			td.className = 'col-xs-12';
			tr.appendChild(td);
			this.BindColumn(td, null);
		}
		this.UpdateColumnWidths(tr);
	}
}

DashboardEditUI.prototype.BindRow = function(tblLayout, tr)
{
	var context = this;
	tr.className             = 'row grab';
	tr.style.backgroundColor = '#ddd';
	$(tr).attr('data-id-group', 'LayoutRow');
	$(tr).draggable(
	{ containment: '#tblLayoutFrame'
	//, hoverClass: 'ui-state-hover'
	, cursor: 'move'
	, helper: function()
		{
			var sHeight   = $(tr).height().toString() + 'px';
			var sWidth    = $(tr).width().toString()  + 'px';
			return $("<div style='border: 1px solid red; height: " + sHeight + "; width: " + sWidth + ";'>&nbsp;</div>");
		}
	, start: function(event, ui)
		{
			context.CancelProperties();
		}
	});
	// http://api.jqueryui.com/droppable/#event-drop
	$(tr).droppable(
	{ greedy: true
	, drop: function(event, ui)
		{
			//console.log('Drop on row');
			$(this).removeClass('ui-state-hover');
			var sDataIdGroup = ui.draggable.attr('data-id-group');
			if ( sDataIdGroup == 'NewRow' )
				context.LayoutAddRow(this.rowIndex + 1);
			else if ( sDataIdGroup == 'LayoutRow' && this != ui.draggable[0] )
			{
				// 03/02/2016 Paul.  Change before or after based on direction. 
				if ( ui.draggable[0].rowIndex > this.rowIndex )
					ui.draggable.insertBefore(this);
				else
					ui.draggable.insertAfter(this);
			}
			else if ( sDataIdGroup == 'DeletedRow' )
			{
				//console.log('Ignore deleted row');
			}
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			// 02/07/2016 Paul.  Included deleted row so that a highlighted row will get cleared. 
			return (sDataIdGroup == 'NewRow') || (sDataIdGroup == 'LayoutRow') || (sDataIdGroup == 'DeletedRow');
		}
	, over: function (event, ui)
		{
			$(this).addClass('ui-state-hover');
		}
	, out: function (event, ui)
		{
			$(this).removeClass('ui-state-hover');
		}
	});
}

DashboardEditUI.prototype.BindColumn = function(td, lay)
{
	var context = this;
	$(td).attr('data-id-group'   , 'LayoutCell');
	$(td).droppable(
	{ greedy: true
	, drop: function(event, ui)
		{
			console.log('Drop on column');
			$(this).removeClass('ui-state-hover');
			context.LayoutAddField($(this), ui.draggable);
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			return (sDataIdGroup == 'DashboardApp') || (sDataIdGroup == 'DashboardPanel') || (sDataIdGroup == 'NewBlank');
		}
	, over: function (event, ui)
		{
			$(this).addClass('ui-state-hover');
		}
	, out: function (event, ui)
		{
			$(this).removeClass('ui-state-hover');
		}
	});
	
	var div = document.createElement('div');
	td.appendChild(div);
	div.className             = 'grab';
	div.style.border          = '1px solid black';
	div.style.padding         = '2px';
	div.style.margin          = '2px';
	div.style.backgroundColor = '#eee';
	div.style.overflow        = 'hidden';
	div.style.width           = '80%';
	$(div).attr('data-id-group'   , 'DashboardPanel');
	$(div).draggable(
	{ containment: '#tblLayoutFrame'
	, helper: 'clone'
	, cursor: 'move'
	, start: function( event, ui )
		{
			context.CancelProperties();
		}
	});
	$(div).droppable(
	{ greedy: true
	, drop: function(event, ui)
		{
			//console.log('Drop on column');
			$(this).removeClass('ui-state-hover');
			context.LayoutAddField($(this), ui.draggable);
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			return (sDataIdGroup == 'DashboardApp') || (sDataIdGroup == 'DashboardPanel') || (sDataIdGroup == 'NewBlank');
		}
	, over: function (event, ui)
		{
			$(this).addClass('ui-state-hover');
		}
	, out: function (event, ui)
		{
			$(this).removeClass('ui-state-hover');
		}
	});

	if ( lay !== undefined && lay != null )
	{
		var sPANEL_TYPE = lay.PANEL_TYPE;
		if ( lay == null || sPANEL_TYPE == 'Blank' )
		{
			div.PANEL_TYPE = lay.PANEL_TYPE;
			div.COLSPAN    = lay.COLSPAN   ;
			var divPANEL_TITLE  = document.createElement('div');
			var divPANEL_MODULE = document.createElement('div');
			div.appendChild(divPANEL_TITLE );
			div.appendChild(divPANEL_MODULE);
			$(divPANEL_TITLE ).text(L10n.Term('Dashboard.LBL_BLANK_TYPE'));
			$(divPANEL_MODULE).text(String.fromCharCode(160));
		}
		else
		{
			var divField = document.getElementById('divDashboardApps_' + lay.DASHBOARD_APP_ID);
			if ( divField != null )
				divField.style.display = 'none';
			
			div.ID                         = lay.ID               ;
			div.PANEL_TYPE                 = lay.PANEL_TYPE       ;
			div.DASHBOARD_APP_ID           = lay.DASHBOARD_APP_ID ;
			div.NAME                       = lay.NAME             ;
			div.CATEGORY                   = lay.CATEGORY         ;
			div.MODULE_NAME                = lay.MODULE_NAME      ;
			div.TITLE                      = lay.TITLE            ;
			div.SETTINGS_EDITVIEW          = lay.SETTINGS_EDITVIEW;
			div.IS_ADMIN                   = lay.IS_ADMIN         ;
			div.APP_ENABLED                = lay.APP_ENABLED      ;
			div.SCRIPT_URL                 = lay.SCRIPT_URL       ;
			div.DEFAULT_SETTINGS           = lay.DEFAULT_SETTINGS ;
			this.RenderField(div);
		}
	}
	else
	{
		// 03/21/2016 Paul.  $().attr() must be used consistently as it is different then direct field access. 
		//$(div).attr('PANEL_TYPE', 'Blank');
		//$(div).attr('DASHBOARD_APP_ID', ''     );
		div.PANEL_TYPE       = 'Blank';
		div.DASHBOARD_APP_ID = ''     ;
		var divPANEL_TITLE  = document.createElement('div');
		var divPANEL_MODULE = document.createElement('div');
		div.appendChild(divPANEL_TITLE );
		div.appendChild(divPANEL_MODULE);
		$(divPANEL_TITLE ).text(L10n.Term('Dashboard.LBL_BLANK_TYPE'));
		$(divPANEL_MODULE).text(String.fromCharCode(160));
	}
}

DashboardEditUI.prototype.LayoutAddRow = function(nPosition)
{
	var divDashboardApps = document.getElementById('divDashboardApps');
	var tblLayout = document.getElementById('tblLayout');
	var tr = document.createElement('div');
	tr.className = 'row';
	if ( nPosition >= 0 )
		tblLayout.insertBefore(tr, tblLayout.childNodes[nPosition]);
	else
		tblLayout.appendChild(tr);
	this.BindRow(tblLayout, tr);

	var td = document.createElement('div');
	td.className = 'col-xs-12';
	tr.appendChild(td);
	this.BindColumn(td, null);
}

DashboardEditUI.prototype.LoadView = function(sLayoutPanel, sActionsPanel, arrDASHBOARDS_PANELS)
{
	var context = this;
	var divDashboardApps = document.getElementById('divDashboardApps');
	var divNonScroll = document.createElement('div');
	divDashboardApps.appendChild(divNonScroll);
	
	var nbsp = String.fromCharCode(160);

	var imgDelete = document.createElement('span');
	imgDelete.id            = 'divDashboardApps_Delete';
	imgDelete.className     = 'glyphicon glyphicon-trash';
	imgDelete.style.fontSize= '4em';
	imgDelete.style.cursor  = 'pointer';
	imgDelete.title         = L10n.Term('.LNK_DELETE');
	imgDelete.style.padding = '2px';
	imgDelete.style.border  = '1px solid white';
	$(imgDelete).attr('data-id-group', 'Delete');
	divNonScroll.appendChild(imgDelete);
	// http://api.jqueryui.com/droppable/#event-drop
	$(imgDelete).droppable(
	{ hoverClass: 'ui-state-hover'
	, tolerance: 'touch'
	, greedy: true
	, drop: function(event, ui)
		{
			//console.log('Drop on delete');
			$(this).removeClass('ui-state-hover');
			var sDataIdGroup = ui.draggable.attr('data-id-group');
			if ( sDataIdGroup == 'LayoutRow' )
			{
				for ( var i = 0; i < ui.draggable[0].childNodes.length; i++ )
				{
					var cell = ui.draggable[0].childNodes[i];
					for ( var j = 0; j < cell.childNodes.length; j++ )
					{
						// 02/07/2016 Paul.  Remove each field first so that it will get enabled in the field list. 
						var div = cell.childNodes[j];
						context.LayoutRemoveField($(div));
					}
				}
				var tblLayout = document.getElementById('tblLayout');
				tblLayout.removeChild(ui.draggable[0]);
				// 05/17/2017 Paul.  When dragging, a row is added for dragging, so length will be 1 when empty. 
				if ( tblLayout.childNodes.length <= 1 )
					context.LayoutAddRow(-1);
				// 02/07/2016 Paul.  Mark the row as deleted so that it will not also be treated as a row drop due to overlap. 
				ui.draggable.attr('data-id-group', 'DeletedRow');
			}
			else ( sDataIdGroup == 'DashboardPanel' )
			{
				context.LayoutRemoveField(ui.draggable);
			}
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			return (sDataIdGroup == 'DashboardPanel' || sDataIdGroup == 'LayoutRow');
		}
	, over: function (event, ui)
		{
			$(this).addClass('ui-state-hover');
		}
	, out: function (event, ui)
		{
			$(this).removeClass('ui-state-hover');
		}
	});
	
	var divField = document.createElement('div');
	$(divField).text(nbsp);
	divNonScroll.appendChild(divField);

	divField = document.createElement('div');
	divField.id                    = 'divDashboardApps_NewRow';
	divField.className             = 'grab';
	divField.style.border          = '1px solid black';
	divField.style.padding         = '2px'    ;
	divField.style.margin          = '2px'    ;
	divField.style.backgroundColor = '#eee'   ;
	divField.style.width           = this.nFieldListWidth.toString() + 'px';
	$(divField).text(L10n.Term('Dashboard.LBL_NEW_ROW'));
	$(divField).attr('data-id-group', 'NewRow');
	divNonScroll.appendChild(divField);
	$(divField).draggable(
	{ containment: '#tblLayoutFrame'
	, helper: 'clone'
	, cursor: 'move'
	, start: function( event, ui )
		{
			context.CancelProperties();
		}
	});
	
	divField = document.createElement('div');
	divField.id                    = 'divDashboardApps_NewBlank';
	divField.className             = 'grab';
	divField.style.border          = '1px solid black';
	divField.style.padding         = '2px' ;
	divField.style.margin          = '2px' ;
	divField.style.backgroundColor = '#eee';
	divField.style.width           = this.nFieldListWidth.toString() + 'px';
	$(divField).text(L10n.Term('Dashboard.LBL_NEW_BLANK'));
	$(divField).attr('data-id-group', 'NewBlank');
	divNonScroll.appendChild(divField);
	$(divField).draggable(
	{ containment: '#tblLayoutFrame'
	, helper: 'clone'
	, cursor: 'move'
	, start: function( event, ui )
		{
			context.CancelProperties();
		}
	});

	divField = document.createElement('div');
	$(divField).text(nbsp);
	divNonScroll.appendChild(divField);

	// 07/31/2017 Paul.  The addition of My Favorites and My Teams means that we need a scrollable list. 
	var rectNonScroll = divNonScroll.getBoundingClientRect();
	var divAutoScrollApps = document.createElement('div');
	divDashboardApps.appendChild(divAutoScrollApps);
	divAutoScrollApps.style.overflowY = 'auto';
	divAutoScrollApps.style.height    = ($('#tblLayoutFrame').height() - rectNonScroll.height).toString() + 'px';
	for ( var i = 0; i < this.DASHBOARD_APPS.length; i++ )
	{
		var lay = this.DASHBOARD_APPS[i];
		var div = document.createElement('div');
		div.id                         = 'divDashboardApps_' + lay.ID;
		div.className                  = 'grab';
		div.style.border               = '1px solid black';
		div.style.padding              = '2px' ;
		div.style.margin               = '2px' ;
		div.style.backgroundColor      = '#eee';
		div.style.width                = this.nFieldListWidth.toString() + 'px';
		div.ID                         = null                 ;
		div.PANEL_TYPE                 = 'Panel'              ;
		div.DASHBOARD_APP_ID           = lay.ID               ;
		div.NAME                       = lay.NAME             ;
		div.CATEGORY                   = lay.CATEGORY         ;
		div.MODULE_NAME                = lay.MODULE_NAME      ;
		div.TITLE                      = lay.TITLE            ;
		div.SETTINGS_EDITVIEW          = lay.SETTINGS_EDITVIEW;
		div.IS_ADMIN                   = lay.IS_ADMIN         ;
		div.APP_ENABLED                = lay.APP_ENABLED      ;
		div.SCRIPT_URL                 = lay.SCRIPT_URL       ;
		div.DEFAULT_SETTINGS           = lay.DEFAULT_SETTINGS ;

		$(div).attr('data-id-group', 'DashboardApp');
		divAutoScrollApps.appendChild(div);
		$(div).draggable(
		{ containment: '#tblLayoutFrame'
		, helper: 'clone'
		, cursor: 'move'
		, drop: function(e)
			{
				alert('dropped on ' + e.target.id);
			}
		, start: function( event, ui )
			{
				context.CancelProperties();
			}
		});
		
		var divPANEL_TITLE  = document.createElement('div');
		var divPANEL_MODULE = document.createElement('div');
		div.appendChild(divPANEL_TITLE );
		div.appendChild(divPANEL_MODULE);
		$(divPANEL_TITLE ).text(L10n.Term(lay.TITLE));
		$(divPANEL_MODULE).text(lay.MODULE_NAME);
		if ( Sql.IsEmptyString(lay.MODULE_NAME) )
		{
			var nbsp = String.fromCharCode(160);
			$(divPANEL_MODULE).text(nbsp);
		}
	}

	while ( divLayoutButtons.childNodes.length > 0 )
	{
		divLayoutButtons.removeChild(divLayoutButtons.firstChild);
	}
	
	var btnLayoutSave               = document.createElement('input');
	btnLayoutSave.id                = 'btnLayoutSave'  ;
	btnLayoutSave.type              = 'button';
	btnLayoutSave.className         = 'btn btn-primary';
	btnLayoutSave.value             = L10n.Term('.LBL_SAVE_BUTTON_LABEL');
	btnLayoutSave.style.cursor      = 'pointer';
	btnLayoutSave.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnLayoutSave  );
	btnLayoutSave.onclick = BindArguments(function(PageCommand, context)
	{
		PageCommand.call(context, sLayoutPanel, sActionsPanel, 'Save', null);
	}, this.PageCommand, this);

	var btnLayoutCancel               = document.createElement('input');
	btnLayoutCancel.id                = 'btnLayoutCancel';
	btnLayoutCancel.type              = 'button';
	btnLayoutCancel.className         = 'btn btn-primary';
	btnLayoutCancel.value             = L10n.Term('.LBL_CANCEL_BUTTON_LABEL');
	btnLayoutCancel.style.cursor      = 'pointer';
	btnLayoutCancel.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnLayoutCancel);
	btnLayoutCancel.onclick = BindArguments(function(PageCommand, context)
	{
		PageCommand.call(context, sLayoutPanel, sActionsPanel, 'Cancel', null);
	}, this.PageCommand, this);

	// 05/04/2016 Paul.  Provide a way to save a layout copy. 
	var btnCopyLayout               = document.createElement('input');
	btnCopyLayout.id                = 'btnCopyLayout';
	btnCopyLayout.type              = 'button';
	btnCopyLayout.className         = 'btn btn-primary';
	btnCopyLayout.value             = L10n.Term('Dashboard.LBL_COPY_BUTTON_TITLE');
	btnCopyLayout.style.cursor      = 'pointer';
	btnCopyLayout.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnCopyLayout);
	btnCopyLayout.onclick = BindArguments(function(PageCommand, context)
	{
		PageCommand.call(context, sLayoutPanel, sActionsPanel, 'Copy', null);
	}, this.PageCommand, this);
	// 06/15/2019 Paul.  We currently do not support role-based dashboards, so remove the role selection. 
	/*
	var txtCopyLayout               = document.createElement('input');
	txtCopyLayout.id                = 'txtCopyLayout';
	txtCopyLayout.type              = 'text';
	txtCopyLayout.style.width       = '200px';
	txtCopyLayout.style.marginRight = '3px';
	txtCopyLayout.style.display     = 'none';
	divLayoutButtons.appendChild(txtCopyLayout);

	var btnRoleSelect               = document.createElement('input');
	btnRoleSelect.id                = 'btnRoleSelect';
	btnRoleSelect.type              = 'button';
	btnRoleSelect.className         = 'btn btn-primary';
	btnRoleSelect.value             = L10n.Term('Dashboard.LBL_SELECT_ROLE');
	btnRoleSelect.style.marginRight = '3px';
	btnRoleSelect.style.display     = 'none';
	divLayoutButtons.appendChild(btnRoleSelect);
	btnRoleSelect.onclick = BindArguments(function(context)
	{
		// 06/15/2019 Paul.  Fix roles popup. 
		return window.open('../Administration/ACLRoles/PopupMultiSelect.aspx?SingleSelection=1', 'ACLRolessPopup', sPopupWindowOptions);
	}, this);
	*/

	// 05/05/2016 Paul.  Provide a way to delete a layout. 
	var btnDeleteLayout               = document.createElement('input');
	btnDeleteLayout.id                = 'btnDeleteLayout';
	btnDeleteLayout.type              = 'button';
	btnDeleteLayout.className         = 'btn btn-primary';
	btnDeleteLayout.value             = L10n.Term('Dashboard.LBL_DELETE_BUTTON_TITLE');
	btnDeleteLayout.style.cursor      = 'pointer';
	btnDeleteLayout.style.marginRight = '3px';
	btnDeleteLayout.style.display     = 'inline';
	divLayoutButtons.appendChild(btnDeleteLayout);
	btnDeleteLayout.onclick = BindArguments(function(PageCommand, context)
	{
		if ( confirm(L10n.Term('Dashboard.ERR_DELETE_CONFIRM')) )
		{
			PageCommand.call(context, sLayoutPanel, sActionsPanel, 'Delete', null);
		}
	}, this.PageCommand, this);
	// 06/01/2017 Paul.  Global dashboards cannot be deleted. 
	if ( this.DASHBOARD != null )
	{
		if ( Sql.IsEmptyGuid(this.DASHBOARD.ASSIGNED_USER_ID) )
			btnDeleteLayout.style.display     = 'none';
	}

	var spnError = document.createElement('span');
	spnError.id        = 'divLayoutButtons_Error';
	spnError.className = 'error';
	divLayoutButtons.appendChild(spnError);

	this.LoadFromLayout(sLayoutPanel, sActionsPanel, arrDASHBOARDS_PANELS);

	var tblDashboard = document.getElementById('tblDashboard');
	tr = tblDashboard.insertRow(-1);
	tdLabel             = tr.insertCell(-1);
	tdField             = tr.insertCell(-1);
	tdLabel.style.padding = '2px';
	tdField.style.padding = '2px';
	tdLabel.style.width   = '15%';
	tdField.style.width   = '85%';
	tdLabel.style.verticalAlign = 'top';
	$(tdLabel).text(L10n.Term('Dashboard.LBL_NAME'));
	txt = document.createElement('textarea');
	txt.id           = 'tblDashboard_NAME';
	txt.type         = 'text';
	txt.style.width  = '350px';
	txt.rows         = 3;
	if ( this.DASHBOARD != null )
		txt.value        = Sql.ToString(this.DASHBOARD.NAME);
	tdField.appendChild(txt);
}

DashboardEditUI.prototype.Load = function(sLayoutPanel, sActionsPanel, sID)
{
	try
	{
		this.Clear(sLayoutPanel, sActionsPanel);
		this.ID = sID;
		
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				bgPage.DashboardApps_LoadAll(function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						this.DASHBOARD_APPS = message;
						// 04/25/2019 Paul.  The module name is singular, not plural. 
						bgPage.Terminology_LoadModule('Dashboard', function(status, message)
						{
							if ( status == 0 || status == 1 )
							{
								if ( !Sql.IsEmptyString(this.ID) )
								{
									bgPage.Dashboards_LoadPanels(this.ID, function(status, message)
									{
										if ( status == 1 )
										{
											var arrDASHBOARDS_PANELS = message;
											bgPage.Dashboards_LoadItem(this.ID, function(status, message)
											{
												if ( status == 1 )
												{
													if ( message instanceof Array && message.length > 0 )
														this.DASHBOARD = message[0];
													this.LoadView(sLayoutPanel, sActionsPanel, arrDASHBOARDS_PANELS);
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
									this.LoadView(sLayoutPanel, sActionsPanel, null);
								}
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
				SplendidError.SystemMessage(message);
			}
		}, this);
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'DashboardEditUI.Load');
	}
}

DashboardEditUI.prototype.Reload = function(sLayoutPanel, sActionsPanel)
{
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.Dashboards_LoadPanels(this.ID, function(status, message)
		{
			if ( status == 1 )
			{
				var arrDASHBOARDS_PANELS = message;
				this.LoadFromLayout(sLayoutPanel, sActionsPanel, arrDASHBOARDS_PANELS);
			}
			else
			{
				SplendidError.SystemMessage(message);
			}
		}, this);
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'DashboardEditUI.Reload');
	}
}

