/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

define(function()
{
	var sMODULE_NAME    = 'Calls';
	var sGRID_NAME      = sMODULE_NAME + '.My' + sMODULE_NAME;
	var sTABLE_NAME     = 'vw' + sMODULE_NAME.toUpperCase() + '_MyList';
	var sSORT_FIELD     = 'DATE_START';
	var sSORT_DIRECTION = 'desc';

	return {
		Render: function(sLayoutPanel, sActionsPanel, sSCRIPT_URL, sSETTINGS_EDITVIEW, sDEFAULT_SETTINGS)
		{
			var divDashboardPanel = document.getElementById(sLayoutPanel);
			if ( divDashboardPanel != null )
			{
				var divDashletBody = document.createElement('div');
				divDashletBody.id = sLayoutPanel + '_divDashletBody';
				divDashletBody.align = 'center';
				divDashboardPanel.appendChild(divDashletBody);
				var divDashletError = document.createElement('div');
				divDashletError.id = sLayoutPanel + '_divDashletError';
				divDashletError.className = 'error';
				divDashletBody.appendChild(divDashletError);
				var divDashletHTML5 = document.createElement('div');
				divDashletHTML5.id = sLayoutPanel + '_divDashletHTML5';
				divDashletHTML5.style.width = '100%';
				divDashletBody.appendChild(divDashletHTML5);
				
				var rowDefaultSearch = Sql.ParseFormData(sDEFAULT_SETTINGS);
				SearchViewUI_Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sSETTINGS_EDITVIEW, rowDefaultSearch, false, this.Search, function(status, message)
				{
					if ( status == 1 )
					{
						// 06/13/2017 Paul.  Set default values. 
						var lstASSIGNED_USER_ID = document.getElementById(sActionsPanel + '_ctlEditView_ASSIGNED_USER_ID');
						if ( lstASSIGNED_USER_ID != null )
						{
							var gUSER_ID = Security.USER_ID();
							// 12/27/2017 Paul.  Dynamic Assignment will not use a dropdown list. 
							if ( $(lstASSIGNED_USER_ID).is('select') )
							{
								for ( var i = lstASSIGNED_USER_ID.options.length - 1; i >= 0; i-- )
								{
									if ( lstASSIGNED_USER_ID.options[i].value == gUSER_ID )
										lstASSIGNED_USER_ID.options[i].selected = true;
								}
							}
							else ( Crm.Config.enable_dynamic_assignment() )
							{
								$('#' + sActionsPanel + '_ctlEditView_ASSIGNED_USER_ID'     ).val(Security.USER_ID()  );
								$('#' + sActionsPanel + '_ctlEditView_ASSIGNED_TO'          ).val(Security.USER_NAME());
								$('#' + sActionsPanel + '_ctlEditView_ASSIGNED_TO_btnInsert').click();
							}
						}
						SearchViewUI_SearchForm(sLayoutPanel, sActionsPanel, sSETTINGS_EDITVIEW, this.Search, this);
					}
					else
					{
						$('#' + sLayoutPanel + '_divDashletError').text('Dashlet error: ' + message);
					}
				}, this);
			}
		},
		Search: function(sLayoutPanel, sActionsPanel, sSEARCH_FILTER, rowSEARCH_VALUES)
		{
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.AuthenticatedMethod(function(status, message)
			{
				if ( status == 1 )
				{
					//$('#' + sLayoutPanel + '_divDashletError').text('Search: ' + sSEARCH_FILTER);

					var divDashletHTML5 = document.getElementById(sLayoutPanel + '_divDashletHTML5');
					while ( divDashletHTML5.childNodes.length > 0 )
					{
						divDashletHTML5.removeChild(divDashletHTML5.firstChild);
					}
			
					try
					{
						var sPRIMARY_ID     = null;
						var oListViewUI = new ListViewUI();
						oListViewUI.BootstrapColumnsFinalize = this.BootstrapColumnsFinalize;
						oListViewUI.AdditionalColumns        = this.AdditionalColumns;
						oListViewUI.LoadRelatedModule(divDashletHTML5.id, sActionsPanel, sMODULE_NAME, sMODULE_NAME, sGRID_NAME, sTABLE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSEARCH_FILTER, sPRIMARY_ID, function(status, message)
						{
							if ( status != 1 )
								$('#' + sLayoutPanel + '_divDashletError').text('Dashlet error: ' + message);
						});
					}
					catch(e)
					{
						$('#' + sLayoutPanel + '_divDashletError').text(e.message);
					}
				}
			}, this);
		},
		AdditionalColumns: function(arrSelectFields)
		{
			// 10/20/2017 Paul.  Just in case the ID is not included in the layout. 
			if ( $.inArray('ID'              , arrSelectFields) == -1 ) arrSelectFields.push('ID'              );
			if ( $.inArray('DURATION_HOURS'  , arrSelectFields) == -1 ) arrSelectFields.push('DURATION_HOURS'  );
			if ( $.inArray('DURATION_MINUTES', arrSelectFields) == -1 ) arrSelectFields.push('DURATION_MINUTES');
			if ( $.inArray('DATE_START'      , arrSelectFields) == -1 ) arrSelectFields.push('DATE_START'      );
			if ( $.inArray('ACCEPT_STATUS'   , arrSelectFields) == -1 ) arrSelectFields.push('ACCEPT_STATUS'   );
		},
		BootstrapColumnsFinalize: function(sLayoutPanel, sActionsPanel, sMODULE_NAME, arrDataTableColumns)
		{
			try
			{
				var arrNewDataTableColumns = new Array();
				var objDataColumn = new Object();
				objDataColumn.data       = null;
				objDataColumn.title      = L10n.Term('Activities.LBL_LIST_CLOSE');
				objDataColumn.DATA_FIELD = null;
				objDataColumn.orderable  = false;
				objDataColumn.className  = '';
				objDataColumn.width      = '1%';
				objDataColumn.className += ' gridViewCenter';
				objDataColumn.className  = Trim(objDataColumn.className);
				objDataColumn.orderData  = arrNewDataTableColumns.length;
				objDataColumn.render = function(data, type, full, meta)
				{
					var sDATA_VALUE = '';
					var row = data;
					if ( type == 'display' )
					{
						// 10/20/2017 Paul.  Need the Sql.To*() functions. 
						var sID   = Sql.ToGuid  (row['ID'  ]);
						var sNAME = Sql.ToString(row['NAME']);
						// 06/14/2017 Paul.  We don't have a way to set the Status=Close in the HTML5 client. 
						var sDATA_VALUE = '<a href="#" onclick="return ListViewUI_Edit(\'' + sLayoutPanel + '\', \'' + sActionsPanel + '\', \'' + escape(sMODULE_NAME) + '\', \'' + sID + '\', false, \'&Status=Close\');"><span class="glyphicon glyphicon-remove fa-2x" title="' + escape(L10n.Term('Activities.LBL_LIST_CLOSE')) + '" style="cursor: pointer; padding: 2px;"></span></a>';
					}
					return sDATA_VALUE;
				};
				arrNewDataTableColumns.push(objDataColumn);
				
				objDataColumn = new Object();
				objDataColumn.data       = null;
				objDataColumn.title      = L10n.Term('Calls.LBL_LIST_DURATION');
				objDataColumn.DATA_FIELD = null;
				objDataColumn.orderable  = false;
				objDataColumn.className  = '';
				objDataColumn.width      = '10%';
				objDataColumn.className += ' gridViewLeft';
				objDataColumn.className  = Trim(objDataColumn.className);
				objDataColumn.orderData  = arrNewDataTableColumns.length;
				objDataColumn.render = function(data, type, full, meta)
				{
					var sDATA_VALUE = '';
					if ( type == 'display' )
					{
						var row = data;
						// 10/20/2017 Paul.  Need the Sql.To*() functions. 
						sDATA_VALUE = Sql.ToInteger(row['DURATION_HOURS']).toString() + 'h' + Sql.ToInteger(row['DURATION_MINUTES']).toString() + 'm';
					}
					return sDATA_VALUE;
				};
				arrNewDataTableColumns.push(objDataColumn);
				
				objDataColumn = new Object();
				objDataColumn.data       = null;
				objDataColumn.title      = L10n.Term('Calls.LBL_LIST_DATE');
				objDataColumn.DATA_FIELD = 'DATE_START';
				objDataColumn.orderable  = true;
				objDataColumn.className  = '';
				objDataColumn.width      = '15%';
				objDataColumn.className += ' gridViewLeft';
				objDataColumn.className  = Trim(objDataColumn.className);
				objDataColumn.orderData  = arrNewDataTableColumns.length;
				objDataColumn.render = function(data, type, full, meta)
				{
					var sDATA_VALUE = '';
					if ( type == 'display' )
					{
						var row = data;
						// 10/20/2017 Paul.  Need the Sql.To*() functions. 
						sDATA_VALUE = Sql.ToString(row['DATE_START']);
						var dtDATE_START = FromJsonDate(sDATA_VALUE);
						sDATA_VALUE = "<font class='" + (dtDATE_START < (new Date()) ? 'overdueTask' : 'futureTask') + "'>" + FromJsonDate(sDATA_VALUE, Security.USER_DATE_FORMAT()) + "</font>";
					}
					return sDATA_VALUE;
				};
				arrNewDataTableColumns.push(objDataColumn);
				
				objDataColumn = new Object();
				objDataColumn.data       = null;
				objDataColumn.title      = L10n.Term('Activities.LBL_ACCEPT_THIS');
				objDataColumn.DATA_FIELD = 'ACCEPT_STATUS';
				objDataColumn.orderable  = false;
				objDataColumn.className  = '';
				objDataColumn.width      = '1%';
				objDataColumn.className += ' gridViewLeft';
				objDataColumn.className  = Trim(objDataColumn.className);
				objDataColumn.orderData  = arrNewDataTableColumns.length;
				objDataColumn.render = function(data, type, full, meta)
				{
					var sDATA_VALUE = '';
					if ( type == 'display' )
					{
						var row = data;
						// 10/20/2017 Paul.  Need the Sql.To*() functions. 
						var sID   = Sql.ToGuid  (row['ID'  ]);
						var sNAME = Sql.ToString(row['NAME']);
						if ( Sql.ToString(row['ACCEPT_STATUS']).toLowerCase() == 'none' )
						{
							//sDATA_VALUE = sActionsPanel + '_ctlSearchView_btnSearch';
							var gUSER_ID = Security.USER_ID();
							sDATA_VALUE += '<a href="#" onclick="return EditViewUI_UpdateTable(\'vwCALLS_USERS\', \'CALL_ID=' + sID + '&USER_ID=' + gUSER_ID + '&ACCEPT_STATUS=accept\', \''    + sLayoutPanel.replace('_divDashletHTML5', '_divDashletError') + '\', \'' + sActionsPanel + '_ctlSearchView_btnSearch' + '\');"><span class="glyphicon glyphicon-ok fa-2x" title="'     + escape(L10n.ListTerm('dom_meeting_accept_options', 'accept'   )) + '" style="cursor: pointer; padding: 2px;"></span></a>';
							sDATA_VALUE += '<a href="#" onclick="return EditViewUI_UpdateTable(\'vwCALLS_USERS\', \'CALL_ID=' + sID + '&USER_ID=' + gUSER_ID + '&ACCEPT_STATUS=tentative\', \'' + sLayoutPanel.replace('_divDashletHTML5', '_divDashletError') + '\', \'' + sActionsPanel + '_ctlSearchView_btnSearch' + '\');"><span class="glyphicon glyphicon-minus fa-2x" title="'  + escape(L10n.ListTerm('dom_meeting_accept_options', 'tentative')) + '" style="cursor: pointer; padding: 2px;"></span></a>';
							sDATA_VALUE += '<a href="#" onclick="return EditViewUI_UpdateTable(\'vwCALLS_USERS\', \'CALL_ID=' + sID + '&USER_ID=' + gUSER_ID + '&ACCEPT_STATUS=decline\', \''   + sLayoutPanel.replace('_divDashletHTML5', '_divDashletError') + '\', \'' + sActionsPanel + '_ctlSearchView_btnSearch' + '\');"><span class="glyphicon glyphicon-remove fa-2x" title="' + escape(L10n.ListTerm('dom_meeting_accept_options', 'decline'  )) + '" style="cursor: pointer; padding: 2px;"></span></a>';
						}
						else
						{
							sDATA_VALUE = L10n.ListTerm('dom_meeting_accept_status', row['ACCEPT_STATUS']);
						}
					}
					return sDATA_VALUE;
				};
				arrNewDataTableColumns.push(objDataColumn);
				
				// 06/14/2017 Paul.  First column is blank and second column is view/edit. 
				arrNewDataTableColumns.splice(0, 0, arrDataTableColumns[0]);
				arrNewDataTableColumns.splice(1, 0, arrDataTableColumns[1]);
				for ( var i = 2; i < arrDataTableColumns.length; i++ )
				{
					arrNewDataTableColumns.splice(Sql.ToInteger(arrDataTableColumns[i].COLUMN_INDEX) + 1, 0, arrDataTableColumns[i]);
				}
			}
			catch(e)
			{
				console.log('MyCalls.BootstrapColumnsFinalize:' + e.message);
			}
			return arrNewDataTableColumns;
		}
	};
});
