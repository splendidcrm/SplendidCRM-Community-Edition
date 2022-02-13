/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function PopupViewUI()
{
	this.SORT_FIELD     = 'NAME';
	this.SORT_DIRECTION = 'asc';
	this.MODULE_NAME    = '';
	this.GRID_NAME      = '';
	this.SEARCH_FILTER  = '';
	this.SEARCH_VALUES  = null;
	this.MULTI_SELECT   = false;
	this.OnMainClicked  = null;
}

PopupViewUI.prototype.Clear = function(sLayoutPanel, sMODULE_NAME)
{
	try
	{
		var divMainLayoutPanel = document.getElementById(sLayoutPanel);
		if ( divMainLayoutPanel != null && divMainLayoutPanel.childNodes != null )
		{
			while ( divMainLayoutPanel.childNodes.length > 0 )
			{
				divMainLayoutPanel.removeChild(divMainLayoutPanel.firstChild);
			}
		}
		if ( divMainLayoutPanel == null )
		{
			// 01/18/2015 Paul.  We noticed "divPopupLayoutPanel does not exist" when cancelling related selection on ChatDashboard on Android 4.4.2 phone. 
			//alert('PopupViewUI.Clear: ' + sLayoutPanel + ' does not exist');
			return;
		}
		SplendidUI_ListHeader(sLayoutPanel, sMODULE_NAME + '.LBL_LIST_FORM_TITLE');
		
		var ctlPopupViewButtons = document.createElement('div');
		ctlPopupViewButtons.id = sLayoutPanel + '_ctlPopupView';
		divMainLayoutPanel.appendChild(ctlPopupViewButtons);
		
		// 04/26/2017 Paul.  Use Bootstrap for responsive design.
		var btnClear = null;
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			btnClear       = document.createElement('input');
			btnClear.id        = sLayoutPanel + '_ctlPopupView_btnClear';
			btnClear.type      = 'button';
			btnClear.className = 'button';
			btnClear.title     = L10n.Term('.LBL_CLEAR_BUTTON_TITLE');
			btnClear.value     = L10n.Term('.LBL_CLEAR_BUTTON_LABEL');
			btnClear.style.paddingLeft  = '10px';
			btnClear.style.paddingRight = '10px';
			btnClear.style.marginRight  = '2px';
			btnClear.style.marginBottom = '4px';
		}
		else
		{
			btnClear = document.createElement('button');
			btnClear.id        = sLayoutPanel + '_ctlPopupView_btnClear';
			// 01/07/2018 Paul.  btn-lg-text is working fine in popup view. 
			btnClear.className = 'btn btn-primary btn-lg-text';
			btnClear.style.marginRight = '3px';
			btnClear.appendChild(document.createTextNode(L10n.Term('.LBL_CLEAR_BUTTON_LABEL')));
		}
		btnClear.onclick = BindArguments(this.OnMainClicked, 1, { 'ID': '', 'NAME': '' } );
		ctlPopupViewButtons.appendChild(btnClear);
		
		// 04/26/2017 Paul.  Use Bootstrap for responsive design.
		var btnCancel = null;
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			btnCancel = document.createElement('input');
			btnCancel.id        = sLayoutPanel + '_ctlPopupView_btnCancel';
			btnCancel.type      = 'button';
			btnCancel.className = 'button';
			btnCancel.title     = L10n.Term('.LBL_CANCEL_BUTTON_TITLE');
			btnCancel.value     = L10n.Term('.LBL_CANCEL_BUTTON_LABEL');
			btnCancel.style.paddingLeft  = '10px';
			btnCancel.style.paddingRight = '10px';
			btnCancel.style.marginLeft   = '2px';
			btnCancel.style.marginBottom = '4px';
		}
		else
		{
			btnCancel = document.createElement('button');
			btnCancel.id        = sLayoutPanel + '_ctlPopupView_btnCancel';
			// 01/07/2018 Paul.  btn-lg-text is working fine in popup view. 
			btnCancel.className = 'btn btn-primary btn-lg-text';
			btnCancel.style.marginRight = '3px';
			btnCancel.appendChild(document.createTextNode(L10n.Term('.LBL_CANCEL_BUTTON_LABEL')));
		}
		btnCancel.onclick = BindArguments(this.OnMainClicked, -2, null );
		ctlPopupViewButtons.appendChild(btnCancel);
		
		// 01/28/2018 Paul.  We need to paginate the popup to support large data sets. 
		var ctlListView_divPagination = document.createElement('div');
		ctlListView_divPagination.id = sLayoutPanel + '_ctlListView_grdMain_pagination';
		ctlListView_divPagination.className = 'listViewPaginationTdS1';
		ctlListView_divPagination.style.textAlign = 'right';
		divMainLayoutPanel.appendChild(ctlListView_divPagination);
		
		// <table id="ctlListView_grdMain" class="listView" cellspacing="1" cellpadding="3" rules="all" border="0" border="1" width="100%">
		var ctlListView_grdMain = document.createElement('table');
		ctlListView_grdMain.id        = sLayoutPanel + '_ctlListView_grdMain';
		ctlListView_grdMain.width     = '100%';
		// 04/23/2017 Paul.  Use Bootstrap for responsive design.
		if ( !SplendidDynamic.BootstrapLayout() )
			ctlListView_grdMain.className = 'listView';
		else
			ctlListView_grdMain.className = 'table table-striped table-bordered dt-responsive nowrap';
		divMainLayoutPanel.appendChild(ctlListView_grdMain);
	}
	catch(e)
	{
		SplendidError.SystemMessage(SplendidError.FormatError(e, 'PopupViewUI.Clear'));
	}
}

PopupViewUI.prototype.Reset = function(sLayoutPanel, sMODULE_NAME)
{
	try
	{
		this.SORT_FIELD     = 'NAME';
		this.SORT_DIRECTION = 'asc' ;
		this.SEARCH_FILTER  = ''    ;
		this.SEARCH_VALUES  = null  ;
		this.Clear(sLayoutPanel, sMODULE_NAME);
	}
	catch(e)
	{
		SplendidError.SystemMessage(SplendidError.FormatError(e, 'PopupViewUI.Reset'));
	}
}

PopupViewUI.prototype.Sort = function(sLayoutPanel, sActionsPanel, sFIELD_NAME, sDIRECTION)
{
	try
	{
		this.SORT_FIELD     = sFIELD_NAME;
		this.SORT_DIRECTION = sDIRECTION;
		SplendidError.SystemMessage('Sorting ' + sFIELD_NAME + ' ' + sDIRECTION);
		var bgPage = chrome.extension.getBackgroundPage();
		// 10/04/2011 Paul.  The session might have timed-out, so first check if we are authenticated. 
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				// 10/24/2012 Paul.  rowSEARCH_VALUES is the field data used to build the SQL sFILTER string. 
				this.LoadModule(sLayoutPanel, sActionsPanel, this.MODULE_NAME, this.GRID_NAME, this.SEARCH_FILTER, this.SEARCH_VALUES, function(status, message)
				{
					if ( status == 1 )
					{
						SplendidError.SystemMessage('');
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
		}, this);
	}
	catch(e)
	{
		SplendidError.SystemMessage(SplendidError.FormatError(e, 'PopupViewUI.Sort'));
	}
}

// 10/24/2012 Paul.  rowSEARCH_VALUES is the field data used to build the SQL sFILTER string. 
PopupViewUI.prototype.Search = function(sLayoutPanel, sActionsPanel, sSEARCH_FILTER, rowSEARCH_VALUES)
{
	try
	{
		//alert('PopupViewUI.Search ' + dumpObj(arrData, 'arrData'));
		SplendidError.SystemMessage('Searching ');
		this.SEARCH_FILTER = sSEARCH_FILTER  ;
		this.SEARCH_VALUES = rowSEARCH_VALUES;
		//alert('PopupViewUI.Search ' + this.SEARCH_FILTER);
		var bgPage = chrome.extension.getBackgroundPage();
		// 10/04/2011 Paul.  The session might have timed-out, so first check if we are authenticated. 
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				// 04/23/2017 Paul.  Use Bootstrap for responsive design.
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					// 10/24/2012 Paul.  rowSEARCH_VALUES is the field data used to build the SQL sFILTER string. 
					this.LoadModule(sLayoutPanel, sActionsPanel, this.MODULE_NAME, this.GRID_NAME, this.SEARCH_FILTER, this.SEARCH_VALUES, function(status, message)
					{
						if ( status == 1 )
						{
							//SplendidError.SystemMessage(this.SEARCH_FILTER);
							SplendidError.SystemMessage('');
						}
						else
						{
							SplendidError.SystemMessage(message);
						}
					});
				}
				else
				{
					var ctlListView_grdMain = document.getElementById(sLayoutPanel + '_ctlListView_grdMain');
					// https://datatables.net/reference/api/ajax.reload()
					$(ctlListView_grdMain).DataTable().ajax.reload(function(json)
					{
					}, true);
				}
			}
			else
			{
				SplendidError.SystemMessage(message);
			}
		}, this);
	}
	catch(e)
	{
		SplendidError.SystemMessage(SplendidError.FormatError(e, 'PopupViewUI.Search'));
	}
}

PopupViewUI.prototype.CheckAll = function(chkPopupCheckAll, sFieldID)
{
	try
	{
		var fld = document.getElementsByName(sFieldID);
		for (var i = 0; i < fld.length; i++)
		{
			if ( fld[i].type == 'checkbox' )
			{
				fld[i].checked = chkPopupCheckAll.checked;
				if( fld[i].onclick != null )
				{
					fld[i].onclick();
				}
			}
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'PopupViewUI.CheckAll');
	}
}

PopupViewUI.prototype.RenderHeader = function(sLayoutPanel, sActionsPanel, layout, tbody)
{
	// <tr class="listViewThS1">
	var tr = document.createElement('tr');
	tbody.appendChild(tr);
	tr.className = 'listViewThS1';
	if ( layout.length > 0 )
	{
		// 09/01/2011 Paul.  First column will be for actions. 
		var td = document.createElement('td');
		tr.appendChild(td);
		if ( this.MULTI_SELECT )
		{
			var chkPopupCheckAll = document.createElement('input');
			chkPopupCheckAll.id        = 'chkPopupCheckAll';
			chkPopupCheckAll.name      = 'chkPopupCheckAll';
			chkPopupCheckAll.type      = 'checkbox';
			chkPopupCheckAll.className = 'checkbox';
			chkPopupCheckAll.onclick   = BindArguments(this.CheckAll, chkPopupCheckAll, 'chkPopup');
			chkPopupCheckAll.style.padding       = '2px';
			chkPopupCheckAll.style.verticalAlign = 'middle';
			td.appendChild(chkPopupCheckAll);
		}
		var bEnableTeamManagement = Crm.Config.enable_team_management();
		var bEnableDynamicTeams   = Crm.Config.enable_dynamic_teams();
		for ( var nLayoutIndex in layout )
		{
			var lay = layout[nLayoutIndex];
			//alert(dumpObj(lay, 'lay'));
			var sCOLUMN_TYPE                = lay.COLUMN_TYPE               ;
			var sHEADER_TEXT                = lay.HEADER_TEXT               ;
			var sSORT_EXPRESSION            = lay.SORT_EXPRESSION           ;
			var sITEMSTYLE_WIDTH            = lay.ITEMSTYLE_WIDTH           ;
			var sITEMSTYLE_CSSCLASS         = lay.ITEMSTYLE_CSSCLASS        ;
			var sITEMSTYLE_HORIZONTAL_ALIGN = lay.ITEMSTYLE_HORIZONTAL_ALIGN;
			var sITEMSTYLE_VERTICAL_ALIGN   = lay.ITEMSTYLE_VERTICAL_ALIGN  ;
			var sITEMSTYLE_WRAP             = lay.ITEMSTYLE_WRAP            ;
			var sDATA_FIELD                 = lay.DATA_FIELD                ;
			var sDATA_FORMAT                = lay.DATA_FORMAT               ;
			var sURL_FIELD                  = lay.URL_FIELD                 ;
			var sURL_FORMAT                 = lay.URL_FORMAT                ;
			var sURL_TARGET                 = lay.URL_TARGET                ;
			var sLIST_NAME                  = lay.LIST_NAME                 ;
			var sURL_MODULE                 = lay.URL_MODULE                ;
			var sURL_ASSIGNED_FIELD         = lay.URL_ASSIGNED_FIELD        ;
			var sVIEW_NAME                  = lay.VIEW_NAME                 ;
			var sMODULE_NAME                = lay.MODULE_NAME               ;
			var sMODULE_TYPE                = lay.MODULE_TYPE               ;
			var sPARENT_FIELD               = lay.PARENT_FIELD              ;
			
			td = document.createElement('td');
			tr.appendChild(td);
			if ( (sDATA_FIELD == 'TEAM_NAME' || sDATA_FIELD == 'TEAM_SET_NAME') )
			{
				if ( bEnableTeamManagement && bEnableDynamicTeams )
				{
					sHEADER_TEXT = '.LBL_LIST_TEAM_SET_NAME';
					sDATA_FIELD  = 'TEAM_SET_NAME';
				}
				else if ( !bEnableTeamManagement )
				{
					td.style.display = 'none';
					// 10/24/2012 Paul.  Clear the sort so that there would be no term lookup. 
					sHEADER_TEXT     = null;
					sSORT_EXPRESSION = null;
				}
			}
			
			if ( sSORT_EXPRESSION != null )
			{
				var a = document.createElement('a');
				td.appendChild(a);
				a.innerHTML = '<nobr>' + L10n.Term(sHEADER_TEXT) + '</nobr>';
				var img = document.createElement('img');
				td.appendChild(img);
				img.align             = 'absmiddle';
				img.style.height      = '10px';
				img.style.width       = '8px';
				img.style.borderWidth = '0px';
				if ( sSORT_EXPRESSION == this.SORT_FIELD )
				{
					// img src="../App_Themes/Six/images/arrow_up.gif" align="absmiddle" style="border-width:0px;height:10px;width:8px;" />
					if ( this.SORT_DIRECTION == 'asc' )
					{
						img.src = sIMAGE_SERVER + 'App_Themes/Six/images/arrow_up.gif';
						a.href = '#';
						a.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sFIELD_NAME, sDIRECTION, context)
						{
							context.Sort.call(context, sLayoutPanel, sActionsPanel, sFIELD_NAME, sDIRECTION);
						}, sLayoutPanel, sActionsPanel, sSORT_EXPRESSION, 'desc', this);
					}
					else
					{
						img.src = sIMAGE_SERVER + 'App_Themes/Six/images/arrow_down.gif';
						a.href = '#';
						a.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sFIELD_NAME, sDIRECTION, context)
						{
							context.Sort.call(context, sLayoutPanel, sActionsPanel, sFIELD_NAME, sDIRECTION);
						}, sLayoutPanel, sActionsPanel, sSORT_EXPRESSION, 'asc', this);
					}
				}
				else
				{
					// img src="../App_Themes/Six/images/arrow.gif" align="absmiddle" style="border-width:0px;height:10px;width:8px;" />
					img.src = sIMAGE_SERVER + 'App_Themes/Six/images/arrow.gif';
					a.href = '#';
					a.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sFIELD_NAME, sDIRECTION, context)
					{
						context.Sort.call(context, sLayoutPanel, sActionsPanel, sFIELD_NAME, sDIRECTION);
					}, sLayoutPanel, sActionsPanel, sSORT_EXPRESSION, 'asc', this);
				}
			}
			else if ( sHEADER_TEXT != null )
			{
				var txt = document.createTextNode(L10n.Term(sHEADER_TEXT));
				td.appendChild(txt);
			}
		}
	}
}

PopupViewUI.prototype.RenderRow = function(sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout, tr, row)
{
	if ( layout.length > 0 )
	{
		// 09/01/2011 Paul.  First column will be for actions. 
		var td = document.createElement('td');
		tr.appendChild(td);
		td.style.whiteSpace = 'nowrap';

		if ( this.MULTI_SELECT )
		{
			var chkPopup = document.createElement('input');
			chkPopup.id        = 'chkPopup_' + Sql.ToString(row['ID']).replace('-', '_');
			chkPopup.name      = 'chkPopup';
			chkPopup.type      = 'checkbox';
			chkPopup.className = 'checkbox';
			chkPopup.Module    = sLIST_MODULE_NAME;
			chkPopup.value     = row['ID'  ];
			chkPopup.tooltip   = row['NAME'];
			//chkPopup.onclick   = BindArguments(this.OnMainClicked, chkPopup, sLIST_MODULE_NAME, row['ID'], row['NAME']);
			chkPopup.style.padding       = '2px';
			chkPopup.style.verticalAlign = 'middle';
			// 09/25/2011 Paul.  IE does not allow you to set the type after it is added to the document. 
			td.appendChild(chkPopup);
			// 10/04/2011 Paul.  IE8 requires that we set checked after appending. 
			if ( SelectionUI_IsSelected(row['ID']) )
				chkPopup.checked = true;
		}

		var bEnableTeamManagement = Crm.Config.enable_team_management();
		var bEnableDynamicTeams   = Crm.Config.enable_dynamic_teams();
		for ( var nLayoutIndex in layout )
		{
			var lay = layout[nLayoutIndex];
			//alert(dumpObj(lay, 'lay'));
			var sCOLUMN_TYPE                = lay.COLUMN_TYPE               ;
			var sHEADER_TEXT                = lay.HEADER_TEXT               ;
			var sSORT_EXPRESSION            = lay.SORT_EXPRESSION           ;
			var sITEMSTYLE_WIDTH            = lay.ITEMSTYLE_WIDTH           ;
			var sITEMSTYLE_CSSCLASS         = lay.ITEMSTYLE_CSSCLASS        ;
			var sITEMSTYLE_HORIZONTAL_ALIGN = lay.ITEMSTYLE_HORIZONTAL_ALIGN;
			var sITEMSTYLE_VERTICAL_ALIGN   = lay.ITEMSTYLE_VERTICAL_ALIGN  ;
			var sITEMSTYLE_WRAP             = lay.ITEMSTYLE_WRAP            ;
			var sDATA_FIELD                 = lay.DATA_FIELD                ;
			var sDATA_FORMAT                = lay.DATA_FORMAT               ;
			var sURL_FIELD                  = lay.URL_FIELD                 ;
			var sURL_FORMAT                 = lay.URL_FORMAT                ;
			var sURL_TARGET                 = lay.URL_TARGET                ;
			var sLIST_NAME                  = lay.LIST_NAME                 ;
			var sURL_MODULE                 = lay.URL_MODULE                ;
			var sURL_ASSIGNED_FIELD         = lay.URL_ASSIGNED_FIELD        ;
			var sVIEW_NAME                  = lay.VIEW_NAME                 ;
			var sMODULE_NAME                = lay.MODULE_NAME               ;
			var sMODULE_TYPE                = lay.MODULE_TYPE               ;
			var sPARENT_FIELD               = lay.PARENT_FIELD              ;
			
			td = document.createElement('td');
			tr.appendChild(td);
			if ( (sDATA_FIELD == 'TEAM_NAME' || sDATA_FIELD == 'TEAM_SET_NAME') )
			{
				if ( bEnableTeamManagement && bEnableDynamicTeams )
				{
					sHEADER_TEXT = '.LBL_LIST_TEAM_SET_NAME';
					sDATA_FIELD  = 'TEAM_SET_NAME';
				}
				else if ( !bEnableTeamManagement )
				{
					td.style.display = 'none';
					// 10/24/2012 Paul.  Clear the sort so that there would be no term lookup. 
					sHEADER_TEXT     = null;
					sSORT_EXPRESSION = null;
				}
			}
			
			if ( sITEMSTYLE_WIDTH            != null ) td.width     = sITEMSTYLE_WIDTH           ;
			if ( sITEMSTYLE_CSSCLASS         != null ) td.className = sITEMSTYLE_CSSCLASS        ;
			if ( sITEMSTYLE_HORIZONTAL_ALIGN != null ) td.align     = sITEMSTYLE_HORIZONTAL_ALIGN;
			if ( sITEMSTYLE_VERTICAL_ALIGN   != null ) td.vAlign    = sITEMSTYLE_VERTICAL_ALIGN  ;
			
			if (   sCOLUMN_TYPE == 'BoundColumn' 
			    && (   sDATA_FORMAT == 'Date'
			        || sDATA_FORMAT == 'DateTime'
			        || sDATA_FORMAT == 'Currency'
			        || sDATA_FORMAT == 'Image'
			        || sDATA_FORMAT == 'MultiLine'
			       )
			   )
			{
				sCOLUMN_TYPE = 'TemplateColumn';
			}
			if ( sCOLUMN_TYPE == 'TemplateColumn' )
			{
				//alert(sDATA_FORMAT + ' ' + row[sDATA_FIELD]);
				if ( row[sDATA_FIELD] != null )
				{
					if ( sDATA_FORMAT == 'HyperLink' )
					{
						var a = document.createElement('a');
						td.appendChild(a);
						a.href      = '#';
						a.innerHTML = row[sDATA_FIELD];
						if ( this.OnMainClicked != null )
						{
							// 12/27/2017 Paul.  The Users popup needs to send back a different field.  The USER_NAME instead of the FULL_NAME. 
							if ( sLIST_MODULE_NAME == 'Users' )
							{
								sDATA_FIELD = 'USER_NAME';
							}
							a.onclick = BindArguments(this.OnMainClicked, 1, { 'ID': row['ID'], 'NAME': row[sDATA_FIELD] } );
						}
					}
					else if ( sDATA_FORMAT == 'Date' )
					{
						var sDATA_VALUE = row[sDATA_FIELD];
						sDATA_VALUE = FromJsonDate(sDATA_VALUE, Security.USER_DATE_FORMAT());
						td.innerHTML = sDATA_VALUE;
					}
					else if ( sDATA_FORMAT == 'DateTime' )
					{
						var sDATA_VALUE = row[sDATA_FIELD];
						sDATA_VALUE = FromJsonDate(sDATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
						td.innerHTML = sDATA_VALUE;
					}
					else if ( sDATA_FORMAT == 'Currency' )
					{
						var sDATA_VALUE = row[sDATA_FIELD];
						td.innerHTML = sDATA_VALUE;
					}
					else if ( sDATA_FORMAT == 'MultiLine' )
					{
						var sDATA_VALUE = row[sDATA_FIELD];
						td.innerHTML = sDATA_VALUE;
					}
					else if ( sDATA_FORMAT == 'Image' )
					{
					}
					else if ( sDATA_FORMAT == 'JavaScript' )
					{
					}
					else if ( sDATA_FORMAT == 'Hover' )
					{
					}
				}
			}
			else if ( sCOLUMN_TYPE == 'BoundColumn' )
			{
				if ( row[sDATA_FIELD] != null )
				{
					if ( sLIST_NAME != null )
					{
						// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
						var sDATA_VALUE = L10n.ListTerm(sLIST_NAME, row[sDATA_FIELD]);
						td.innerHTML = sDATA_VALUE;
					}
					else
					{
						var sDATA_VALUE = row[sDATA_FIELD];
						td.innerHTML = sDATA_VALUE;
					}
				}
			}
		}
	}
}

PopupViewUI.prototype.GridColumns = function(layout)
{
	var arrSelectFields = new Array();
	if ( layout.length > 0 )
	{
		for ( var nLayoutIndex in layout )
		{
			var lay = layout[nLayoutIndex];
			var sSORT_EXPRESSION            = lay.SORT_EXPRESSION           ;
			var sDATA_FIELD                 = lay.DATA_FIELD                ;
			var sDATA_FORMAT                = lay.DATA_FORMAT               ;
			var sURL_FIELD                  = lay.URL_FIELD                 ;
			var sURL_ASSIGNED_FIELD         = lay.URL_ASSIGNED_FIELD        ;
			var sPARENT_FIELD               = lay.PARENT_FIELD              ;
			
			if ( sDATA_FORMAT == 'Hover' )
				continue;
			if ( sDATA_FIELD != null && sDATA_FIELD.length > 0 )
			{
				arrSelectFields.push(sDATA_FIELD);
			}
			if ( sSORT_EXPRESSION != null && sSORT_EXPRESSION.length > 0 )
			{
				if ( sDATA_FIELD != sSORT_EXPRESSION )
					arrSelectFields.push(sSORT_EXPRESSION);
			}
			if ( sURL_FIELD != null && sURL_FIELD.length > 0 )
			{
				if ( sURL_FIELD.indexOf(' ') >= 0 )
				{
					var arrURL_FIELD = sURL_FIELD.split(' ');
					for ( var i in arrURL_FIELD )
					{
						var s = arrURL_FIELD[i];
						if ( s.indexOf('.') == -1 && s.length > 0 )
						{
							arrSelectFields.push(s);
						}
					}
				}
				else if ( sURL_FIELD.indexOf('.') == -1 )
				{
					arrSelectFields.push(sURL_FIELD);
				}
				if ( sURL_ASSIGNED_FIELD != null && sURL_ASSIGNED_FIELD.length > 0 )
				{
					arrSelectFields.push(sURL_ASSIGNED_FIELD);
				}
			}
			if ( sPARENT_FIELD != null && sPARENT_FIELD.length > 0 )
			{
				arrSelectFields.push(sPARENT_FIELD);
			}
		}
	}
	return arrSelectFields.join(',');
}

// 10/24/2012 Paul.  rowSEARCH_VALUES is the field data used to build the SQL sFILTER string. 
PopupViewUI.prototype.LoadModule = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sGRID_NAME, sSEARCH_FILTER, rowSEARCH_VALUES, callback)
{
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		//var layout = bgPage.SplendidCache.GridViewColumns(sGRID_NAME);
		bgPage.ListView_LoadLayout(sGRID_NAME, function(status, message)
		{
			if ( status == 1 )
			{
				// 10/03/2011 Paul. ListView_LoadLayout returns the layout. 
				var layout = message;
				var sSELECT_FIELDS = this.GridColumns(layout);
				// 04/23/2017 Paul.  Use Bootstrap for responsive design.
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					// 10/24/2012 Paul.  rowSEARCH_VALUES is the field data used to build the SQL sFILTER string. 
					// 04/23/2017 Paul.  We need to return the total when using nTOP. 
					bgPage.ListView_LoadModule(sMODULE_NAME, this.SORT_FIELD, this.SORT_DIRECTION, sSELECT_FIELDS, sSEARCH_FILTER, rowSEARCH_VALUES, function(status, message, __total)
					{
						// 10/04/2011 Paul.  ListView_LoadModule returns the row. 
						// 10/21/2012 Paul.  Always display the ListView header. 
						this.Clear(sLayoutPanel, sMODULE_NAME);
						var ctlListView_grdMain = document.getElementById(sLayoutPanel + '_ctlListView_grdMain');
						// 10/17/2012 Paul.  Exit if the Main does not exist.  This is a sign that the user has navigated elsewhere. 
						// 01/28/2018 Paul.  We need to paginate the popup to support large data sets. 
						var divPagination = document.getElementById(sLayoutPanel + '_ctlListView_grdMain_pagination');
						if ( ctlListView_grdMain == null || divPagination == null )
							return;
						var tbody = document.createElement('tbody');
						ctlListView_grdMain.appendChild(tbody);
					
						this.RenderHeader(sLayoutPanel, sActionsPanel, layout, tbody);
					
						if ( status == 1 )
						{
							var rows = message;
							// 01/28/2018 Paul.  We need to paginate the popup to support large data sets. 
							var thisListViewUI = this;
							if ( rows != null && rows.length > 0 )
							{
								/*
								for ( var i = 0; i < rows.length; i++ )
								{
									var tr = document.createElement('tr');
									tbody.appendChild(tr);
									if ( i % 2 == 0 )
										tr.className = 'oddListRowS1';
									else
										tr.className = 'evenListRowS1';
							
									var row = rows[i];
									this.RenderRow(sLayoutPanel, sActionsPanel, sMODULE_NAME, layout, tr, row);
								}
								*/
								$('#' + divPagination.id).paging(rows.length, 
								{ onSelect: function(page)
									{
										while ( tbody.childNodes.length > 2 )
										{
											tbody.removeChild(tbody.lastChild);
										}
										for ( var i = this.slice[0]; i < this.slice[1]; i++ )
										{
											var tr = document.createElement('tr');
											tbody.appendChild(tr);
											if ( i % 2 == 0 )
												tr.className = 'oddListRowS1';
											else
												tr.className = 'evenListRowS1';
											var row = rows[i];
											thisListViewUI.RenderRow(sLayoutPanel, sActionsPanel, sMODULE_NAME, layout, tr, row);
										}
										return false;
									}
								, perpage : Crm.Config.ToInteger('list_max_entries_per_page')
								, format  : '< . >'
								, onFormat: function(type)
									{
										switch ( type )
										{
											case 'block':  // n and c
												if ( this.value != this.page )
													return '<a href="#">' + this.value + '</a>';
												else
													return this.value;
											case 'first':  // [
												if ( this.page > 1 )
													return '<a href="#">' + L10n.Term('.LNK_LIST_FIRST') + '</a>';
												else
													return  '' + L10n.Term('.LNK_LIST_FIRST') + '';
											case 'prev' :  // <
												if ( this.page > 1 )
													return '<a href="#">&lt; ' + L10n.Term('.LNK_LIST_PREVIOUS') + '</a>';
												else
													return '&lt; ' + L10n.Term('.LNK_LIST_PREVIOUS') + '';
											case 'next' :  // >
												if ( this.page < this.pages )
													return '<a href="#">' + L10n.Term('.LNK_LIST_NEXT') + ' &gt;</a>';
												else
													return '' + L10n.Term('.LNK_LIST_NEXT') + ' &gt;';
											case 'last' :  // ]
												if ( this.page < this.pages )
													return '<a href="#">' + L10n.Term('.LNK_LIST_LAST') + '</a>';
												else
													return '' + L10n.Term('.LNK_LIST_LAST') + '';
											case 'leap' :
												//litPageRange.Text = String.Format("&nbsp; <span class=\"pageNumbers\">({0} - {1} {2} {3})</span> ", nPageStart, nPageEnd, sOf, vw.Count);
												return ' ( ' + (this.slice[0] + 1) + ' - ' + this.slice[1] + ' ' + L10n.Term('.LBL_LIST_OF') + ' ' + this.number + ' ) ';
											case 'fill' :
												return ' ';
										}
										return '';
									}
								});
							}
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
					this.Clear(sLayoutPanel, sMODULE_NAME);
					var ctlListView_grdMain = document.getElementById(sLayoutPanel + '_ctlListView_grdMain');
					var dataTableOptions = 
					{ searching   : false  // Disable search. 
					, processing  : true
					, ordering    : true 
					, info        : false  // Hide the Showing information at the bottom. 
					, paging      : true
					, lengthChange: false
					, pageLength  : Crm.Config.ToInteger('list_max_entries_per_page')
					, dom         : 'prtp<"clearfix">'  // https://datatables.net/examples/basic_init/dom.html
					, language    : 
						{ paginate:
							{ first   : L10n.Term('.LNK_LIST_FIRST'   )  // not used. 
							, previous: L10n.Term('.LNK_LIST_PREVIOUS')
							, next    : L10n.Term('.LNK_LIST_NEXT'    )
							, last    : L10n.Term('.LNK_LIST_LAST'    )  // not used. 
							}
						}
					, rowCallback: null
					};

					if ( this.SHOW_CONFLICTS )
					{
						if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
							sSEARCH_FILTER += ' and ';
						var sTABLE_NAME = Crm.Modules.TableName(sMODULE_NAME);
						sSEARCH_FILTER = Sql.ToString(sSEARCH_FILTER) + 'ID in (select ID from vw' + sTABLE_NAME + '_REMOTE_Conflicted)';
					}
					var thisListViewUI = this;
					thisListViewUI.SEARCH_FILTER = sSEARCH_FILTER  ;
					thisListViewUI.SEARCH_VALUES = rowSEARCH_VALUES;
					
					var arrOrder = new Array();
					dataTableOptions.order = new Array();
					dataTableOptions.order.push(arrOrder);
					arrOrder.push(0);
					arrOrder.push(this.SORT_DIRECTION);
					dataTableOptions.columns = this.BootstrapColumns(sLayoutPanel, sActionsPanel, sMODULE_NAME, layout);
					for ( var iColumn = 0; iColumn < dataTableOptions.columns.length; iColumn++ )
					{
						if ( dataTableOptions.columns[iColumn].DATA_FIELD == this.SORT_FIELD )
						{
							arrOrder[0] = iColumn;
							break;
						}
					}
					var sSELECT_FIELDS      = this.GridColumns(layout);
					//dataTableOptions.data    = rows;
					dataTableOptions.serverSide = true;
					dataTableOptions.ajax       = function(data, callback, settings)
					{
						var nTOP            = data.length;
						var nSKIP           = data.start ;
						var sSORT_FIELD     = 'NAME';
						var sSORT_DIRECTION = 'asc' ;
						if ( dataTableOptions.order !== undefined && dataTableOptions.order.length > 0 )
						{
							var nSortIndex = dataTableOptions.order[0][0];
							if ( nSortIndex < dataTableOptions.columns.length )
							{
								sSORT_FIELD     = dataTableOptions.columns[nSortIndex].DATA_FIELD;
								sSORT_DIRECTION = dataTableOptions.order[0][1];
							}
						}
						var sSEARCH_FILTER   = thisListViewUI.SEARCH_FILTER;
						var rowSEARCH_VALUES = thisListViewUI.SEARCH_VALUES;
						bgPage.ListView_LoadModulePaginated(sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT_FIELDS, sSEARCH_FILTER, rowSEARCH_VALUES, nTOP, nSKIP, function(status, message, __total)
						{
							if ( status == 1 )
							{
								//SplendidError.SystemLog('__total = ' + __total);
								//alert(dumpObj(dataTableOptions.order[0], ''));
								SplendidError.SystemMessage('');
								var json = new Object();
								json.draw            = data.draw;  // draw values much match in order for sorting directions to be correct. 
								json.data            = message;  // rows. 
								json.recordsTotal    = __total;
								json.recordsFiltered = __total;
								callback(json);
							}
							else
							{
								SplendidError.SystemMessage(message);
								var json = new Object();
								json.error = message;
								// 01/06/2018 Paul.  Bootstrap table needs empty data array. 
								json.data  = new Array();
								callback(json);
							}
						});
					};
					if ( this.MULTI_SELECT )
					{
						// https://datatables.net/reference/option/headerCallback
						dataTableOptions.headerCallback = function( thead, data, start, end, display )
						{
							$(thead).find('th').eq(1).html('<input id="chkPopupCheckAll" name="chkPopupCheckAll" type="checkbox" class="checkbox" style="padding: 2px; vertical-align: middle; display: inline; margin: 2px 2px 2px 4px; transform: scale(1.5);" onclick="PopupUI_CheckAll(this, \'chkPopup\');">');
						};
					}
					dataTableOptions.drawCallback = function(settings)
					{
						var api = this.api();
						var rows = api.rows({page: 'current'}).data();
						for ( var i = 0; i < rows.length; i++ )
						{
							var row   = rows[i];
							// 10/20/2017 Paul.  Need the Sql.To*() functions. 
							var sID   = Sql.ToGuid  (row['ID'  ]);
							var sNAME = Sql.ToString(row['NAME']);
							// 12/27/2017 Paul.  The Users popup needs to send back a different field.  The USER_NAME instead of the FULL_NAME. 
							if ( sMODULE_NAME == 'Users' )
							{
								sNAME = Sql.ToString(row['USER_NAME']);
							}
							var a = document.getElementById('aPopup_' + sID.replace('-', '_'));
							if ( a != null )
								a.onclick = BindArguments(thisListViewUI.OnMainClicked, 1, { 'ID': sID, 'NAME': sNAME } );
						}
					};
					$(ctlListView_grdMain).DataTable(dataTableOptions);
				}
			}
			else
			{
				callback(status, message);
			}
		}, this);
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'PopupViewUI.LoadModule'));
	}
}

function PopupViewUI_CheckAll(chkPopupCheckAll, sFieldID)
{
	try
	{
		var fld = document.getElementsByName(sFieldID);
		for (var i = 0; i < fld.length; i++)
		{
			if ( fld[i].type == 'checkbox' )
			{
				fld[i].checked = chkPopupCheckAll.checked;
				if( fld[i].onclick != null )
				{
					fld[i].onclick();
				}
			}
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'PopupViewUI_CheckAll');
	}
}

PopupViewUI.prototype.BootstrapColumns = function(sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout)
{
	// 04/20/2017 Paul.  Build DataTables columns. 
	var arrDataTableColumns = new Array();
	// 04/21/2017 Paul.  First column is used for expandable button. 
	var objDataColumn = new Object();
	objDataColumn.data      = null;
	objDataColumn.title     = '';
	objDataColumn.width     = '1%';
	objDataColumn.render    = function(data, type, row, meta) { return ''; };
	objDataColumn.orderable = false;
	objDataColumn.orderData = arrDataTableColumns.length;
	arrDataTableColumns.push(objDataColumn);
	
	if ( this.MULTI_SELECT )
	{
		// 04/21/2017 Paul.  The second column contains the actions for checkbox, View and Edit. 
		objDataColumn = new Object();
		objDataColumn.data      = null;
		objDataColumn.title     = '';
		objDataColumn.width     = '30';
		objDataColumn.render    = function(data, type, row, meta)
		{
			if ( type == 'display' )
			{
				// 10/20/2017 Paul.  Need the Sql.To*() functions. 
				var sID   = Sql.ToGuid  (row['ID'  ]);
				var sNAME = Sql.ToString(row['NAME']);
				var sChecked = (SelectionUI_IsSelected(sID) ? 'checked="checked"' : '');
				sCell += '	<input id="chkPopup_' + sID.replace('-', '_') + '" name="chkPopup" type="checkbox" class="checkbox" value="' + sID + '" tooltip="' + escape(sNAME) + '" Module="' + escape(sLIST_MODULE_NAME) + '" style="padding: 2px; vertical-align: top; display: inline; margin: 7px 2px 2px 4px; transform: scale(1.5);" onclick="SelectionUI_chkPopup_Clicked(this, \'' + escape(sLIST_MODULE_NAME) + '\', \'' + sID + '\', \'' + sNAME + '\')" ' + sChecked + '>';
				return sCell;
			}
			else
			{
				return '';
			}
		};
		// 01/12/2018 Paul.  Force first column to be displayed. 
		objDataColumn.className = ' all';
		objDataColumn.orderable = false;
		objDataColumn.orderData = arrDataTableColumns.length;
		arrDataTableColumns.push(objDataColumn);
	}
	
	var bEnableTeamManagement = Crm.Config.enable_team_management();
	var bEnableDynamicTeams   = Crm.Config.enable_dynamic_teams();
	// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
	var oNumberFormat = Security.NumberFormatInfo();
	if ( Crm.Config.ToString('currency_format') == 'c0' )
		oNumberFormat.CurrencyDecimalDigits = 0;
	for ( var nLayoutIndex in layout )
	{
		var lay = layout[nLayoutIndex];
		BindArguments(function(lay)
		{
			//alert(dumpObj(lay, 'lay'));
			var sCOLUMN_TYPE                = lay.COLUMN_TYPE               ;
			var sHEADER_TEXT                = lay.HEADER_TEXT               ;
			var sSORT_EXPRESSION            = lay.SORT_EXPRESSION           ;
			var sITEMSTYLE_WIDTH            = lay.ITEMSTYLE_WIDTH           ;
			var sITEMSTYLE_CSSCLASS         = lay.ITEMSTYLE_CSSCLASS        ;
			var sITEMSTYLE_HORIZONTAL_ALIGN = lay.ITEMSTYLE_HORIZONTAL_ALIGN;
			var sITEMSTYLE_VERTICAL_ALIGN   = lay.ITEMSTYLE_VERTICAL_ALIGN  ;
			var sITEMSTYLE_WRAP             = lay.ITEMSTYLE_WRAP            ;
			var sDATA_FIELD                 = lay.DATA_FIELD                ;
			var sDATA_FORMAT                = lay.DATA_FORMAT               ;
			var sURL_FIELD                  = lay.URL_FIELD                 ;
			var sURL_FORMAT                 = lay.URL_FORMAT                ;
			var sURL_TARGET                 = lay.URL_TARGET                ;
			var sLIST_NAME                  = lay.LIST_NAME                 ;
			var sURL_MODULE                 = lay.URL_MODULE                ;
			var sURL_ASSIGNED_FIELD         = lay.URL_ASSIGNED_FIELD        ;
			var sVIEW_NAME                  = lay.VIEW_NAME                 ;
			var sMODULE_NAME                = lay.MODULE_NAME               ;
			var sMODULE_TYPE                = lay.MODULE_TYPE               ;
			var sPARENT_FIELD               = lay.PARENT_FIELD              ;
		
			if ( (sDATA_FIELD == 'TEAM_NAME' || sDATA_FIELD == 'TEAM_SET_NAME') )
			{
				if ( bEnableTeamManagement && bEnableDynamicTeams )
				{
					sHEADER_TEXT = '.LBL_LIST_TEAM_SET_NAME';
					sDATA_FIELD  = 'TEAM_SET_NAME';
				}
				else if ( !bEnableTeamManagement )
				{
					// 10/24/2012 Paul.  Clear the sort so that there would be no term lookup. 
					sHEADER_TEXT     = null;
					sSORT_EXPRESSION = null;
					sCOLUMN_TYPE     = 'Hidden';
				}
			}
			if (   sCOLUMN_TYPE == 'BoundColumn' 
				&& (   sDATA_FORMAT == 'Date'
					|| sDATA_FORMAT == 'DateTime'
					|| sDATA_FORMAT == 'Currency'
					|| sDATA_FORMAT == 'Image'
					|| sDATA_FORMAT == 'MultiLine'
					// 08/26/2014 Paul.  Ignore ImageButton. 
					|| sDATA_FORMAT == 'ImageButton'
					)
				)
			{
				sCOLUMN_TYPE = 'TemplateColumn';
			}
			// 08/20/2016 Paul.  The hidden field is a DATA_FORMAT, not a COLUMN_TYPE, but keep COLUMN_TYPE just in case anyone used it. 
			if ( sCOLUMN_TYPE == 'Hidden' || sDATA_FORMAT == 'Hidden' )
			{
				return;  // 04/23/2017 Paul.  Return instead of continue as we are in a binding function. 
			}
			// 04/10/2017 Paul.  Hide unsupported formats. 
			else if ( sCOLUMN_TYPE == 'TemplateColumn' && (sDATA_FORMAT == 'Hover' || sDATA_FORMAT == 'ImageButton' || sDATA_FORMAT == 'Hidden') )
			{
				return;  // 04/23/2017 Paul.  Return instead of continue as we are in a binding function. 
			}
			if ( sCOLUMN_TYPE == 'TemplateColumn' )
			{
				// 04/20/2017 Paul.  Build DataTables columns. 
				objDataColumn = new Object();
				objDataColumn.data       = null;
				objDataColumn.title      = (Sql.IsEmptyString(sHEADER_TEXT) ? '' : L10n.Term(sHEADER_TEXT));
				objDataColumn.DATA_FIELD = sDATA_FIELD;
				objDataColumn.orderable  = (sSORT_EXPRESSION != null);
				objDataColumn.className  = '';
				if ( sITEMSTYLE_WIDTH            != null ) objDataColumn.width      = sITEMSTYLE_WIDTH;
				if ( sITEMSTYLE_HORIZONTAL_ALIGN != null ) objDataColumn.className += ' gridView' + sITEMSTYLE_HORIZONTAL_ALIGN;
				if ( sITEMSTYLE_VERTICAL_ALIGN   != null ) objDataColumn.className += ' gridView' + sITEMSTYLE_VERTICAL_ALIGN  ;
				objDataColumn.className  = Trim(objDataColumn.className);
				objDataColumn.orderData  = arrDataTableColumns.length;
				arrDataTableColumns.push(objDataColumn);
				// 01/12/2018 Paul.  Try and force the NAME column to always be displayed on mobile portrait mode. 
				// https://datatables.net/extensions/responsive/classes
				if ( sDATA_FIELD == "NAME" )
					objDataColumn.className = ' all';
				
				objDataColumn.render = function(data, type, full, meta)
				{
					var sDATA_VALUE = '';
					var row = data;
					if ( row[sDATA_FIELD] != null )
					{
						if ( sDATA_FORMAT == 'HyperLink' )
						{
							var sID = row['ID'];
							sDATA_VALUE += '<a id="aPopup_' + sID.replace('-', '_') + '" href="#" ';
							// 12/01/2012 Paul.  For activities lists, we need to convert the activity to the base module. 
							if ( sURL_MODULE == 'Activities' && row['ACTIVITY_TYPE'] !== undefined )
							{
								sURL_MODULE = row['ACTIVITY_TYPE'];
							}
							//a.onclick = BindArguments(this.OnMainClicked, 1, { 'ID': row['ID'], 'NAME': row[sDATA_FIELD] } );
							sDATA_VALUE += '>';
							if ( row[sDATA_FIELD] !== undefined )
							{
								// 08/24/2014 Paul.  WinRT does not like to add text with angle brackets. 
								sDATA_VALUE += escapeHTML(row[sDATA_FIELD]);
							}
							else
							{
								sDATA_VALUE += sID;
							}
							sDATA_VALUE += '</a>';
						}
						else if ( sDATA_FORMAT == 'Date' )
						{
							sDATA_VALUE = row[sDATA_FIELD];
							sDATA_VALUE = FromJsonDate(sDATA_VALUE, Security.USER_DATE_FORMAT());
						}
						else if ( sDATA_FORMAT == 'DateTime' )
						{
							sDATA_VALUE = row[sDATA_FIELD];
							sDATA_VALUE = FromJsonDate(sDATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
						}
						else if ( sDATA_FORMAT == 'Currency' )
						{
							sDATA_VALUE = formatCurrency(row[sDATA_FIELD], oNumberFormat);
						}
						else if ( sDATA_FORMAT == 'MultiLine' )
						{
							sDATA_VALUE = row[sDATA_FIELD];
						}
						else if ( sDATA_FORMAT == 'Image' )
						{
						}
						else if ( sDATA_FORMAT == 'JavaScript' )
						{
						}
						else if ( sDATA_FORMAT == 'Hover' )
						{
						}
						// 08/26/2014 Paul.  Ignore ImageButton. 
						else if ( sDATA_FORMAT == 'ImageButton' )
						{
						}
						// 05/15/2016 Paul.  Add Tags module. 
						else if ( sDATA_FORMAT == 'Tags' )
						{
							sDATA_VALUE = '';
							var sDATA = row[sDATA_FIELD];
							if ( !Sql.IsEmptyString(sDATA) )
							{
								var arrTAGS = sDATA.split(',');
								for ( var iTag = 0; iTag < arrTAGS.length; iTag++ )
								{
									sDATA_VALUE += '<span class="Tags">';
									sDATA_VALUE += escapeHTML(arrTAGS[iTag]);
									sDATA_VALUE += '</span> ';
								}
							}
						}
						else
						{
							sDATA_VALUE = row[sDATA_FIELD];
						}
					}
					return sDATA_VALUE;
				};
			}
			else if ( sCOLUMN_TYPE == 'BoundColumn' )
			{
				// 04/20/2017 Paul.  Build DataTables columns. 
				objDataColumn = new Object();
				objDataColumn.data       = null;
				objDataColumn.title      = (Sql.IsEmptyString(sHEADER_TEXT) ? '' : L10n.Term(sHEADER_TEXT));
				objDataColumn.DATA_FIELD = sDATA_FIELD;
				objDataColumn.orderable  = (sSORT_EXPRESSION != null);
				objDataColumn.className  = '';
				if ( sITEMSTYLE_WIDTH            != null ) objDataColumn.width      = sITEMSTYLE_WIDTH;
				if ( sITEMSTYLE_HORIZONTAL_ALIGN != null ) objDataColumn.className += ' gridView' + sITEMSTYLE_HORIZONTAL_ALIGN;
				if ( sITEMSTYLE_VERTICAL_ALIGN   != null ) objDataColumn.className += ' gridView' + sITEMSTYLE_VERTICAL_ALIGN  ;
				objDataColumn.className  = Trim(objDataColumn.className);
				objDataColumn.orderData  = arrDataTableColumns.length;
				arrDataTableColumns.push(objDataColumn);
				
				objDataColumn.render = function(data, type, full, meta)
				{
					var sDATA_VALUE = '';
					var row = data;
					if ( row[sDATA_FIELD] != null )
					{
						// 12/01/2012 Paul.  The activity status needs to be dynamically converted to the correct list. 
						if ( sLIST_NAME == 'activity_status' )
						{
							var sACTIVITY_TYPE = row['ACTIVITY_TYPE'];
							switch ( sACTIVITY_TYPE )
							{
								case 'Tasks'   :
									sLIST_NAME  = 'task_status_dom'   ;
									sDATA_VALUE = L10n.ListTerm(sLIST_NAME, row[sDATA_FIELD]);
									break;
								case 'Meetings':
									sLIST_NAME  = 'meeting_status_dom';
									sDATA_VALUE = L10n.ListTerm(sLIST_NAME, row[sDATA_FIELD]);
									break;
								case 'Calls'   :
									// 07/15/2006 Paul.  Call status is translated externally. 
									sDATA_VALUE = L10n.ListTerm('call_direction_dom', row['DIRECTION']) + ' ' + L10n.ListTerm('call_status_dom', row['STATUS']);
									break;
								case 'Notes'   :
									// 07/15/2006 Paul.  Note Status is not normally as it does not have a status. 
									sDATA_VALUE = L10n.Term('.activity_dom.Note');
									break;
								// 06/15/2006 Paul.  This list name for email_status does not follow the standard. 
								case 'Emails'  :
									sLIST_NAME  = 'dom_email_status'  ;
									sDATA_VALUE = L10n.ListTerm(sLIST_NAME, row[sDATA_FIELD]);
									break;
								// 04/21/2006 Paul.  If the activity does not have a status (such as a Note), then use activity_dom. 
								default        :
									sLIST_NAME  = 'activity_dom'      ;
									sDATA_VALUE = L10n.ListTerm(sLIST_NAME, row[sDATA_FIELD]) + '[' + sACTIVITY_TYPE + ']';
									break;
							}
						}
						else if ( sLIST_NAME != null )
						{
							// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
							sDATA_VALUE = L10n.ListTerm(sLIST_NAME, row[sDATA_FIELD]);
						}
						else
						{
							sDATA_VALUE = row[sDATA_FIELD];
						}
					}
					return sDATA_VALUE;
				};
			}
		}, lay)();
	}
	return arrDataTableColumns;
};

PopupViewUI.prototype.Load = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, bMultiSelect, callback)
{
	try
	{
		var sGRID_NAME = sMODULE_NAME + '.PopupView' + sPLATFORM_LAYOUT;
		this.MODULE_NAME   = sMODULE_NAME;
		this.GRID_NAME     = sGRID_NAME  ;
		this.SEARCH_FILTER = ''          ;
		this.SEARCH_VALUES = null        ;
		this.MULTI_SELECT  = bMultiSelect;
		this.OnMainClicked = callback    ;

		var bgPage = chrome.extension.getBackgroundPage();
		// 10/04/2011 Paul.  The session might have timed-out, so first check if we are authenticated. 
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				bgPage.Terminology_LoadModule(sMODULE_NAME, function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						// 09/10/2011 Paul.  Make sure to load the layout first as it might be needed inside SearchViewUI_SearchForm, or PopupViewUI.LoadModule, which run in parallel. 
						bgPage.ListView_LoadLayout(sGRID_NAME, function(status, message)
						{
							if ( status == 0 || status == 1 )
							{
								// 10/03/2011 Paul. ListView_LoadLayout returns the layout. 
								var layout = message;
								var rowDefaultSearch = null;
								SearchViewUI_Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sMODULE_NAME + '.SearchPopup' + sPLATFORM_LAYOUT, rowDefaultSearch, false, this.Search, function(status, message)
								{
									if ( status == -1 )
										callback(status, message);
								}, this);
								// 10/24/2012 Paul.  rowSEARCH_VALUES is the field data used to build the SQL sFILTER string. 
								this.LoadModule(sLayoutPanel, sActionsPanel, sMODULE_NAME, sGRID_NAME, this.SEARCH_FILTER, this.SEARCH_VALUES, function(status, message)
								{
									if ( status == -1 )
										callback(status, message);
								});
							}
							else
							{
								callback(status, message);
							}
						}, this);
					}
					else
					{
						callback(status, message);
					}
				}, this);
			}
			else
			{
				callback(-1, message);
			}
		}, this);
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'PopupViewUI.Load'));
	}
}

PopupViewUI.prototype.LoadWithSearch = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, bMultiSelect, sSEARCH_FILTER, rowDefaultSearch, callback)
{
	try
	{
		var sGRID_NAME = sMODULE_NAME + '.PopupView' + sPLATFORM_LAYOUT;
		this.MODULE_NAME   = sMODULE_NAME    ;
		this.GRID_NAME     = sGRID_NAME      ;
		this.SEARCH_FILTER = sSEARCH_FILTER  ;
		this.SEARCH_VALUES = rowDefaultSearch;
		this.MULTI_SELECT  = bMultiSelect    ;
		this.OnMainClicked = callback        ;

		var bgPage = chrome.extension.getBackgroundPage();
		// 10/04/2011 Paul.  The session might have timed-out, so first check if we are authenticated. 
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				bgPage.Terminology_LoadModule(sMODULE_NAME, function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						// 09/10/2011 Paul.  Make sure to load the layout first as it might be needed inside SearchViewUI_SearchForm, or PopupViewUI.LoadModule, which run in parallel. 
						bgPage.ListView_LoadLayout(sGRID_NAME, function(status, message)
						{
							if ( status == 0 || status == 1 )
							{
								// 10/03/2011 Paul. ListView_LoadLayout returns the layout. 
								var layout = message;
								SearchViewUI_Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sMODULE_NAME + '.SearchPopup' + sPLATFORM_LAYOUT, rowDefaultSearch, false, this.Search, function(status, message)
								{
									if ( status == -1 )
										callback(status, message);
								}, this);
								// 10/24/2012 Paul.  rowSEARCH_VALUES is the field data used to build the SQL sFILTER string. 
								this.LoadModule(sLayoutPanel, sActionsPanel, sMODULE_NAME, sGRID_NAME, this.SEARCH_FILTER, this.SEARCH_VALUES, function(status, message)
								{
									if ( status == -1 )
										callback(status, message);
								});
							}
							else
							{
								callback(status, message);
							}
						}, this);
					}
					else
					{
						callback(status, message);
					}
				}, this);
			}
			else
			{
				callback(-1, message);
			}
		}, this);
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'PopupViewUI.LoadWithSearch'));
	}
}

