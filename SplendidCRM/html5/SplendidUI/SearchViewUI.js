/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function ToggleUnassignedOnly()
{
	var sLayoutPanel = 'divMainLayoutPanel';
	var sASSIGNED_USER_ID = sLayoutPanel + '_ctlEditView_' + 'ASSIGNED_USER_ID';
	var sUNASSIGNED_ONLY  = sLayoutPanel + '_ctlEditView_' + 'UNASSIGNED_ONLY' ;
	if ( sASSIGNED_USER_ID.length > 0 && sUNASSIGNED_ONLY.length > 0 )
	{
		var lstASSIGNED_USER_ID = document.getElementById(sASSIGNED_USER_ID);
		var chkUNASSIGNED_ONLY  = document.getElementById(sUNASSIGNED_ONLY );
		if ( lstASSIGNED_USER_ID != null && chkUNASSIGNED_ONLY != null )
			lstASSIGNED_USER_ID.disabled = chkUNASSIGNED_ONLY.checked;
	}
}

function SearchViewUI_SearchForm(sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context)
{
	try
	{
		var row = new Object();
		var bgPage = chrome.extension.getBackgroundPage();
		var oEditViewUI = new EditViewUI();
		oEditViewUI.GetValues(sActionsPanel, sEDIT_NAME, true, row);
		// 10/19/2016 Paul.  We need to have access to the DATA_FORMAT field by DATA_FIELD. 
		var layout  = bgPage.SplendidCache.EditViewFields(sEDIT_NAME);
		var layoutByField = new Object();
		for ( var nLayoutIndex in layout )
		{
			var lay = layout[nLayoutIndex];
			var sDATA_FIELD = lay.DATA_FIELD;
			layoutByField[sDATA_FIELD] = lay;
		}
		
		//alert(dumpObj(row, 'SearchViewUI_SearchForm row'));
		var cmd = new Object();
		cmd.CommandText = '';
		if ( row != null )
		{
			var oSearchBuilder = new SearchBuilder();
			for ( var sField in row )
			{
				//alert(sField + ' = ' + row[sField]);
				var oValue = row[sField];
				if ( sField.indexOf(' ') > 0 )
				{
					// 12/05/2011 Paul.  If value is empty, then ignore to prevent search of (0 = 1). 
					// 01/01/2018 Paul.  Handle array separately so that we can make sure that all items are not null. 
					if ( $.isArray(oValue) )
					{
						var nValues = 0;
						for ( var o in oValue )
						{
							if ( oValue[o] != null )
								nValues++;
						}
						if ( nValues > 0 )
						{
							var arrFields = sField.split(' ');
							if ( cmd.CommandText.length > 0 )
								cmd.CommandText += ' and ';
							cmd.CommandText += '(0 = 1';
							for ( var n in arrFields )
							{
								if ( layoutByField[sField] != null && layoutByField[sField].FIELD_TYPE == 'DateRange' )
								{
									cmd.CommandText += ' or (1 = 1';
									if ( oValue.length >= 1 && oValue[0] != null )
									{
										var dt  = FromJsonDate(oValue[0]);
										cmd.CommandText += ' and ' + arrFields[n] + ' >= \'' + formatDate(dt, 'yyyy/MM/dd') + '\'';
									}
									if ( oValue.length >= 2 && oValue[1] != null )
									{
										var dt = FromJsonDate(oValue[1]);
										cmd.CommandText += ' and ' + arrFields[n] + ' <= \'' + formatDate(dt, 'yyyy/MM/dd') + '\'';
									}
									cmd.CommandText += ')';
								}
								else
								{
									Sql.AppendParameter(cmd, arrFields[n], oValue, true);
								}
							}
							cmd.CommandText += ')';
						}
					}
					else if ( !Sql.IsEmptyString(oValue) )
					{
						//alert('multiple fields ' + sField)
						oSearchBuilder.Init(oValue);
						var arrFields = sField.split(' ');
						if ( cmd.CommandText.length > 0 )
							cmd.CommandText += ' and ';
						cmd.CommandText += '(0 = 1';
						for ( var n in arrFields )
						{
							// 01/01/2018 Paul.  Allow searching of multiple date fields. 
							if ( layoutByField[sField] != null && layoutByField[sField].FIELD_TYPE == 'DatePicker' )
							{
								var dt = FromJsonDate(oValue);
								cmd.CommandText += ' or ' + arrFields[n] + ' = \'' + formatDate(dt, 'yy/MM/dd') + '\'';
							}
							else if ( layoutByField[sField] != null && layoutByField[sField].FIELD_TYPE == 'DateTimePicker' )
							{
								var dt = FromJsonDate(oValue);
								cmd.CommandText += ' or ' + arrFields[n] + ' = \'' + formatDate(dt, 'yyyy/MM/dd HH:mm:ss') + '\'';
							}
							else
							{
								if ( typeof(oValue) == 'string' )
									cmd.CommandText += oSearchBuilder.BuildQuery(' or ', arrFields[n]);
								else
									Sql.AppendParameter(cmd, arrFields[n], oValue, true);
							}
						}
						cmd.CommandText += ')';
						//alert(cmd.CommandText);
					}
				}
				else
				{
					if ( typeof(oValue) == 'string' )
					{
						var sMODULE_NAME = sEDIT_NAME.split('.')[0];
						// 10/19/2016 Paul.  Check for Full-Text Search. 
						if ( layoutByField[sField] != null && StartsWith(Sql.ToString(layoutByField[sField].DATA_FORMAT).toLowerCase(), 'fulltext') )
						{
							var arrDATA_FORMAT = layoutByField[sField].DATA_FORMAT.split(' ');
							// 05/21/2018 Paul.  String.Empty does not exist in JavaScript. 
							var sFULL_TEXT_TABLE = '';
							var sFULL_TEXT_FIELD = '';
							var sFULL_TEXT_KEY   = '';
							if ( arrDATA_FORMAT.length >= 2 )
							{
								sFULL_TEXT_TABLE = arrDATA_FORMAT[1];
							}
							if ( sFULL_TEXT_TABLE.toLowerCase() == 'documents' )
							{
								sFULL_TEXT_TABLE = 'DOCUMENT_REVISIONS';
								sFULL_TEXT_FIELD = 'CONTENT'           ;
								sFULL_TEXT_KEY   = 'DOCUMENT_ID'       ;
							}
							else if ( sFULL_TEXT_TABLE.toLowerCase() == 'notes' )
							{
								sFULL_TEXT_TABLE = 'NOTE_ATTACHMENTS';
								sFULL_TEXT_FIELD = 'ATTACHMENT'      ;
								sFULL_TEXT_KEY   = 'NOTE_ID'         ;
							}
							// 10/24/2016 Paul.  KBDocuments use the NOTE_ATTACHMENTS table for attachments and EMAIL_IMAGES table for images. 
							else if ( sFULL_TEXT_TABLE.toLowerCase() == 'kbdocuments' )
							{
								sFULL_TEXT_TABLE = 'NOTE_ATTACHMENTS';
								sFULL_TEXT_FIELD = 'ATTACHMENT'      ;
								sFULL_TEXT_KEY   = 'NOTE_ID'         ;
							}
							else if ( arrDATA_FORMAT.length >= 4 )
							{
								sFULL_TEXT_FIELD = arrDATA_FORMAT[2];
								sFULL_TEXT_KEY   = arrDATA_FORMAT[3];
							}
							if ( !Sql.IsEmptyString(oValue) && !Sql.IsEmptyString(sFULL_TEXT_TABLE) && !Sql.IsEmptyString(sFULL_TEXT_FIELD) && !Sql.IsEmptyString(sFULL_TEXT_KEY) )
							{
								var ControlChars = { CrLf: '\r\n' };
								if ( cmd.CommandText.length > 0 )
									cmd.CommandText += ' and ';
								cmd.CommandText += 'ID in (select ' + sFULL_TEXT_KEY + ' from ' + sFULL_TEXT_TABLE + ' where contains(' + sFULL_TEXT_FIELD + ', \'' + Sql.EscapeSQL(oValue) + '\'))' + ControlChars.CrLf;
							}
						}
						// 07/26/2018 Paul.  Allow a normalized phone search that used the special phone tables. 
						else if ( layoutByField[sField] != null && layoutByField[sField].DATA_FORMAT == 'normalizedphone' && !Sql.IsEmptyString(oValue) && (sMODULE_NAME == "Accounts" || sMODULE_NAME == "Contacts" || sMODULE_NAME == "Leads" || sMODULE_NAME == "Prospects") )
						{
								var ControlChars = { CrLf: '\r\n' };
								if ( cmd.CommandText.length > 0 )
									cmd.CommandText += ' and ';
								var sNORMALIZED_NUMBER = oValue.replace(/[\s+()-.#*]/g, '');
								var vwNORMALIZED_VIEW  = 'vwPHONE_NUMBERS_' + Crm.Modules.TableName(sMODULE_NAME);
							// 08/08/2018 Paul.  Use like clause for more flexible phone number lookup. 
								cmd.CommandText += 'ID in (select ID from ' + vwNORMALIZED_VIEW + ' where NORMALIZED_NUMBER like \'' + Sql.EscapeSQL(sNORMALIZED_NUMBER) + '%' + '\')' + ControlChars.CrLf;
						}
						else if ( layoutByField[sField] != null && layoutByField[sField].FIELD_TYPE == 'DatePicker' )
						{
							if ( cmd.CommandText.length > 0 )
								cmd.CommandText += ' and ';
							var dt = FromJsonDate(oValue);
							cmd.CommandText += sField + ' = \'' + formatDate(dt, 'yy/MM/dd') + '\'';
						}
						else if ( layoutByField[sField] != null && layoutByField[sField].FIELD_TYPE == 'DateTimePicker' )
						{
							if ( cmd.CommandText.length > 0 )
								cmd.CommandText += ' and ';
							var dt = FromJsonDate(oValue);
							cmd.CommandText += sField + ' = \'' + formatDate(dt, 'yyyy/MM/dd HH:mm:ss') + '\'';
						}
						else
						{
							if ( cmd.CommandText.length == 0 )
								cmd.CommandText += oSearchBuilder.BuildQuery('', sField, oValue);
							else
								cmd.CommandText += oSearchBuilder.BuildQuery(' and ', sField, oValue);
						}
					}
					else if ( typeof(oValue) == 'boolean' )
					{
						// 02/03/2013 Paul.  Only set the boolean value if checked. 
						// 02/22/2013 Paul.  Only if checked applies to any checkbox field. 
						if ( oValue )
						{
							if ( sField == 'UNASSIGNED_ONLY' )
							{
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								if ( Crm.Config.enable_dynamic_assignment() )
								{
									Sql.AppendParameter(cmd, 'ASSIGNED_SET_ID', null);
								}
								else
								{
									Sql.AppendParameter(cmd, 'ASSIGNED_USER_ID', null);
								}
							}
							else if ( sField == 'CURRENT_USER_ONLY' )
							{
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								if ( Crm.Config.enable_dynamic_assignment() )
								{
									cmd.CommandText += '   and ASSIGNED_SET_ID in (select MEMBERSHIP_ASSIGNED_SET_ID' + ControlChars.CrLf;
									cmd.CommandText += '                             from vwASSIGNED_SET_MEMBERSHIPS' + ControlChars.CrLf;
									cmd.CommandText += '                            where 1 = 1                     ' + ControlChars.CrLf;
									cmd.CommandText += '                              ';
									Sql.AppendParameter(cmd, 'MEMBERSHIP_ASSIGNED_USER_ID', Security.USER_ID());
									cmd.CommandText += '                          )' + ControlChars.CrLf;
								}
								else
								{
									Sql.AppendParameter(cmd, 'ASSIGNED_USER_ID', Security.USER_ID());
								}
							}
							else
							{
								Sql.AppendParameter(cmd, sField, oValue);
							}
						}
					}
					else
					{
						// 05/24/2017 Paul.  Need support for DateRange for new Dashboard. 
						if ( $.isArray(oValue) && layoutByField[sField] != null && layoutByField[sField].FIELD_TYPE == 'DateRange' )
						{
							if ( oValue.length >= 1 && oValue[0] != null )
							{
								if ( cmd.CommandText.length > 0 )
									cmd.CommandText += ' and ';
								var dt  = FromJsonDate(oValue[0]);
								cmd.CommandText += sField + ' >= \'' + formatDate(dt, 'yyyy/MM/dd') + '\'';
							}
							if ( oValue.length >= 2 && oValue[1] != null )
							{
								if ( cmd.CommandText.length > 0 )
									cmd.CommandText += ' and ';
								var dt = FromJsonDate(oValue[1]);
								cmd.CommandText += sField + ' <= \'' + formatDate(dt, 'yyyy/MM/dd') + '\'';
							}
						}
						else
						{
							Sql.AppendParameter(cmd, sField, oValue);
						}
					}
				}
			}
		}
		//alert(cmd.CommandText);
		// 10/24/2012 Paul.  rowSEARCH_VALUES is the field data used to build the SQL sFILTER string. 
		if ( cbSearch !== undefined && cbSearch != null )
			cbSearch.call(context, sLayoutPanel, sActionsPanel, cmd.CommandText, row);
		else
			SplendidError.SystemError('SearchViewUI_SearchForm: cbSearch is not defined');
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'SearchViewUI_SearchForm');
	}
}

function SearchViewUI_ClearForm(sLayoutPanel, sActionsPanel, sEDIT_NAME)
{
	try
	{
		var oEditViewUI = new EditViewUI();
		oEditViewUI.ClearValues(sActionsPanel, sEDIT_NAME);
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'SearchViewUI_ClearForm');
	}
}

function SearchViewUI_Clear(sLayoutPanel, sActionsPanel, sMODULE_NAME, sEDIT_NAME, bEnableCaching, cbSearch, callback, context)
{
	try
	{
		var divMainLayoutPanel = document.getElementById(sActionsPanel);
		//alert('SearchViewUI_Clear(' + sActionsPanel + ')' + divMainLayoutPanel);
		
		var ctlSearchView_tblSearch = document.getElementById(sActionsPanel + '_ctlSearchView_tblSearch');
		if ( ctlSearchView_tblSearch == null )
		{
			if ( divMainLayoutPanel != null && divMainLayoutPanel.childNodes != null )
			{
				while ( divMainLayoutPanel.childNodes.length > 0 )
				{
					divMainLayoutPanel.removeChild(divMainLayoutPanel.firstChild);
				}
			}
			// <table class="tabSearchForm" cellspacing="1" cellpadding="0" border="0" style="width:100%;">
			// <table id="ctlListView_ctlSearchView_tblSearch" class="tabSearchView">
			var ctlSearchView = document.createElement('table');
			ctlSearchView.id        = sActionsPanel + '_ctlSearchView';
			ctlSearchView.cellSpacing = 1;
			ctlSearchView.cellPadding = 0;
			ctlSearchView.border      = 0;
			ctlSearchView.style.width = '100%';
			ctlSearchView.className   = 'tabSearchForm';
			var a = document.createElement('a');
			if ( divMainLayoutPanel != null )
			{
				if ( divMainLayoutPanel.childNodes != null && divMainLayoutPanel.childNodes.length > 0 )
					divMainLayoutPanel.insertBefore(ctlSearchView, divMainLayoutPanel.firstChild);
				else
					divMainLayoutPanel.appendChild(ctlSearchView);
			}
			else
			{
				alert('SearchViewUI_Clear: ' + sActionsPanel + ' does not exist');
			}
			
			var tSearchView = document.createElement('tbody');
			ctlSearchView.appendChild(tSearchView);
			var tr = document.createElement('tr');
			tSearchView.appendChild(tr);
			var td = document.createElement('td');
			tr.appendChild(td);
			
			ctlSearchView_tblSearch = document.createElement('table');
			ctlSearchView_tblSearch.id        = sActionsPanel + '_ctlSearchView_tblSearch';
			ctlSearchView_tblSearch.className = 'tabSearchView';
			td.appendChild(ctlSearchView_tblSearch);
			
			var tblSearchButtons = document.createElement('table');
			tblSearchButtons.id               = sActionsPanel + '_ctlSearchView_tblSearchButtons';
			tblSearchButtons.cellSpacing      = 0;
			tblSearchButtons.cellPadding      = 0;
			tblSearchButtons.border           = 0;
			tblSearchButtons.width            = '100%';
			tblSearchButtons.style.paddingTop = '4px';
			td.appendChild(tblSearchButtons);
			
			var tSearchButtons = document.createElement('tbody');
			tblSearchButtons.appendChild(tSearchButtons);
			tr = document.createElement('tr');
			tSearchButtons.appendChild(tr);
			td = document.createElement('td');
			tr.appendChild(td);
			
			// <input type="submit" name="ctl00$cntBody$ctlListView$ctlSearchView$btnSearch" value="Search" 
			// onclick="javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(&quot;ctl00$cntBody$ctlListView$ctlSearchView$btnSearch&quot;, &quot;&quot;, true, &quot;&quot;, &quot;&quot;, false, false))" 
			// id="ctl00_cntBody_ctlListView_ctlSearchView_btnSearch" accesskey="Q" title="Search" class="button">
			
			// 04/11/2017 Paul.  Use Bootstrap for responsive design.
			var btnSearch = null;
			if ( !SplendidDynamic.BootstrapLayout() )
			{
				btnSearch = document.createElement('input');
				btnSearch.type      = 'submit';
				btnSearch.id        = sActionsPanel + '_ctlSearchView_btnSearch';
				btnSearch.className = 'button';
				btnSearch.style.marginRight = '3px';
				btnSearch.value     = L10n.Term('.LBL_SEARCH_BUTTON_LABEL');
				btnSearch.title     = L10n.Term('.LBL_SEARCH_BUTTON_LABEL');
				// 06/18/2015 Paul.  Add support for Seven theme. 
				if ( SplendidDynamic.StackedLayout(Security.USER_THEME()) )
				{
					btnSearch.className = 'EditHeaderOtherButton';
				}
			}
			else
			{
				btnSearch = document.createElement('button');
				btnSearch.id        = sActionsPanel + '_ctlSearchView_btnSearch';
				btnSearch.type      = 'button';
				btnSearch.className = 'btn btn-primary btn-lg-text';
				btnSearch.style.marginRight = '3px';
				//var glyph = document.createElement('span');
				//glyph.className = 'glyphicon glyphicon-search';
				//btnSearch.appendChild(glyph);
				// 01/07/2018 Paul.  Label should be Search not select. 
				btnSearch.appendChild(document.createTextNode(L10n.Term('.LBL_SEARCH_BUTTON_LABEL')));
			}
			btnSearch.onclick   = BindArguments(function(sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context)
			{
				SearchViewUI_SearchForm(sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context);
			}, sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context);
			td.appendChild(btnSearch);
			
			// 04/11/2017 Paul.  Use Bootstrap for responsive design.
			var btnClear = null;
			if ( !SplendidDynamic.BootstrapLayout() )
			{
				btnClear = document.createElement('input');
				btnClear.type      = 'submit';
				btnClear.id        = sActionsPanel + '_ctlSearchView_btnClear';
				btnClear.value     = L10n.Term('.LBL_CLEAR_BUTTON_LABEL');
				btnClear.title     = L10n.Term('.LBL_CLEAR_BUTTON_LABEL');
				btnClear.className = 'button';
				btnClear.style.marginRight = '3px';
				// 06/18/2015 Paul.  Add support for Seven theme. 
				if ( SplendidDynamic.StackedLayout(Security.USER_THEME()) )
				{
					btnClear.className = 'EditHeaderOtherButton';
				}
			}
			else
			{
				btnClear = document.createElement('button');
				btnClear.id        = sActionsPanel + '_ctlSearchView_btnClear';
				btnClear.type      = 'button';
				btnClear.className = 'btn btn-primary btn-lg-text';
				btnClear.style.marginRight = '3px';
				//var glyph = document.createElement('span');
				//glyph.className = 'glyphicon glyphicon-remove';
				//btnClear.appendChild(glyph);
				btnClear.appendChild(document.createTextNode(L10n.Term('.LBL_CLEAR_BUTTON_LABEL')));
			}
			btnClear.onclick   = BindArguments(function(sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context)
			{
				SearchViewUI_ClearForm (sLayoutPanel, sActionsPanel, sEDIT_NAME);
				SearchViewUI_SearchForm(sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context);
			}, sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context);
			td.appendChild(btnClear);
			
			if ( bEnableCaching )
			{
				var bgPage = chrome.extension.getBackgroundPage();
				// 04/11/2017 Paul.  Use Bootstrap for responsive design.
				var btnCacheSelected = null;
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					btnCacheSelected = document.createElement('input');
					btnCacheSelected.type      = 'submit';
					btnCacheSelected.id        = sActionsPanel + '_ctlSearchView_btnCacheSelected';
					btnCacheSelected.value     = L10n.Term('.LBL_CACHE_SELECTED');
					btnCacheSelected.title     = L10n.Term('.LBL_CACHE_SELECTED');
					btnCacheSelected.className = 'button';
					btnCacheSelected.style.marginRight = '3px';
					btnCacheSelected.style.display     = (bgPage.GetEnableOffline() && !bgPage.GetIsOffline()) ? 'inline' : 'none';
				}
				else
				{
					btnCacheSelected = document.createElement('button');
					btnCacheSelected.id        = sActionsPanel + '_ctlSearchView_btnCacheSelected';
					btnCacheSelected.className = 'btn btn-primary btn-lg-text';
					btnCacheSelected.style.marginRight = '3px';
					btnCacheSelected.style.display     = (bgPage.GetEnableOffline() && !bgPage.GetIsOffline()) ? 'inline' : 'none';
					btnCacheSelected.appendChild(document.createTextNode(L10n.Term('.LBL_CACHE_SELECTED')));
				}
				btnCacheSelected.onclick   = BindArguments(function(sFieldID, sMODULE_NAME, callback, context)
				{
					SearchViewUI_CacheSelected(sFieldID, sMODULE_NAME, callback, context);
				}, 'chkMain', sMODULE_NAME, callback, context);
				td.appendChild(btnCacheSelected);
				// 04/11/2017 Paul.  Use Bootstrap for responsive design.
				if ( SplendidDynamic.BootstrapLayout() )
				{
				}
				else
				{
					// 06/18/2015 Paul.  Add support for Seven theme. 
					if ( SplendidDynamic.StackedLayout(Security.USER_THEME()) )
					{
						btnCacheSelected.className = 'EditHeaderOtherButton';
					}
				}
			}
			
			//var txt = document.createTextNode(sActionsPanel);
			//td.appendChild(txt);
		}
		else
		{
			var btnSearch = document.getElementById(sActionsPanel + '_ctlSearchView_btnSearch');
			btnSearch.onclick   = BindArguments(function(sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context)
			{
				SearchViewUI_SearchForm(sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context);
			}, sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context);
			
			var btnClear = document.getElementById(sActionsPanel + '_ctlSearchView_btnClear');
			btnClear.onclick   = BindArguments(function(sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context)
			{
				SearchViewUI_ClearForm(sLayoutPanel, sActionsPanel, sEDIT_NAME);
				SearchViewUI_SearchForm(sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context);
			}, sLayoutPanel, sActionsPanel, sEDIT_NAME, cbSearch, context);
			
			var btnCacheSelected = document.getElementById(sActionsPanel + '_ctlSearchView_btnCacheSelected');
			if ( btnCacheSelected != null )
			{
				var bgPage = chrome.extension.getBackgroundPage();
				btnCacheSelected.style.display = (bgPage.GetEnableOffline() && !bgPage.GetIsOffline()) ? 'inline' : 'none';
				btnCacheSelected.onclick = BindArguments(function(sFieldID, sMODULE_NAME, callback, context)
				{
					SearchViewUI_CacheSelected(sFieldID, sMODULE_NAME, callback, context);
				}, 'chkMain', sMODULE_NAME, callback, context);
			}

			if ( ctlSearchView_tblSearch != null && ctlSearchView_tblSearch.childNodes != null )
			{
				while ( ctlSearchView_tblSearch.childNodes.length > 0 )
				{
					ctlSearchView_tblSearch.removeChild(ctlSearchView_tblSearch.firstChild);
				}
			}
			if ( ctlSearchView_tblSearch == null )
			{
				alert('SearchViewUI_Clear: ' + sActionsPanel + '_ctlSearchView_tblSearch' + ' does not exist');
				return;
			}
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'SearchViewUI_Clear');
	}
}

function SearchViewUI_CacheSelected(sFieldID, sMODULE_NAME, callback, context)
{
	try
	{
		var nCacheItemCount = 0;
		var bgPage = chrome.extension.getBackgroundPage();
		
		var fld = document.getElementsByName(sFieldID);
		for (var i = 0; i < fld.length; i++)
		{
			if ( fld[i].type == 'checkbox' )
			{
				if ( fld[i].checked )
				{
					nCacheItemCount++;
					var sID = fld[i].value;
					// 10/11/2011 Paul.  Remove the item from the selected array. 
					if ( arrSELECTED[sID] != null )
					{
						delete arrSELECTED[sID];
					}
					bgPage.DetailView_LoadItem(sMODULE_NAME, sID, function(status, message)
					{
						if ( status == 1 )
						{
							var row = message;
							var chkMain = document.getElementById('chkMain_' + Sql.ToString(row['ID']).replace('-', '_'));
							if ( chkMain != null && chkMain.type == 'checkbox' )
								chkMain.checked = false;
							
							callback.call(this, 2, 'Loaded ' + sMODULE_NAME + ': ' + row['NAME']);
						}
						nCacheItemCount--;
						if ( nCacheItemCount == 0 )
						{
							callback.call(this, 2, '');
							var chkMainCheckAll = document.getElementById('chkMainCheckAll');
							if ( chkMainCheckAll != null && chkMainCheckAll.type == 'checkbox' )
								chkMainCheckAll.checked = false;
						}
					}, context||this);
				}
			}
		}
	}
	catch(e)
	{
		SplendidError.SystemMessage(SplendidError.FormatError(e, 'SearchViewUI_CacheSelected'));
	}
}

function SearchViewUI_Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sEDIT_NAME, row, bEnableCaching, cbSearch, callback, context)
{
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.EditView_LoadLayout(sEDIT_NAME, function(status, message)
		{
			if ( status == 1 )
			{
				// 10/03/2011 Paul.  EditView_LoadLayout returns the layout. 
				var layout = message;
				SearchViewUI_Clear(sLayoutPanel, sActionsPanel, sMODULE_NAME, sEDIT_NAME, bEnableCaching, cbSearch, callback, this);
				//var layout  = bgPage.SplendidCache.EditViewFields(sEDIT_NAME);
				var tblMain = document.getElementById(sActionsPanel + '_ctlSearchView_tblSearch');
				var oEditViewUI = new EditViewUI();
				oEditViewUI.LoadView(sActionsPanel, tblMain, layout, row, sActionsPanel + '_ctlSearchView_btnSearch');
				
				// 12/06/2014 Paul.  Don't display the module header on a mobile device. 
				if ( sPLATFORM_LAYOUT == '.Mobile' )
				{
					var ctlSearchView = document.getElementById(sActionsPanel + '_ctlSearchView');
					ctlSearchView.style.display = 'none';
				}
				
				callback.call(this, 1, null);
			}
			else
			{
				callback.call(this, status, message);
			}
		}, context||this);
	}
	catch(e)
	{
		callback.call(context, -1, SplendidError.FormatError(e, 'SearchViewUI_Load'));
	}
}
