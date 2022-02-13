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
	var sMODULE_NAME    = 'Leads';
	var sGRID_NAME      = sMODULE_NAME + '.My' + sMODULE_NAME;
	var sTABLE_NAME     = sMODULE_NAME.toUpperCase();
	var sSORT_FIELD     = 'DATE_ENTERED';
	var sSORT_DIRECTION = 'desc';
	var arrFAVORITE_RECORD_ID = new Array();

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
				
				var sSEARCH_FILTER = 'FAVORITE_MODULE = \'' + sMODULE_NAME + '\' and FAVORITE_USER_ID = \'' + Security.USER_ID() + '\'';
				var bgPage = chrome.extension.getBackgroundPage();
				bgPage.ListView_LoadTable('SUGARFAVORITES', 'FAVORITE_RECORD_ID', 'asc', 'FAVORITE_RECORD_ID', sSEARCH_FILTER, function(status, message)
				{
					if ( status == 1 )
					{
						var rows = message;
						arrFAVORITE_RECORD_ID = new Array();
						for ( var nRowIndex = 0; nRowIndex < rows.length; nRowIndex++ )
						{
							var row = rows[nRowIndex];
							arrFAVORITE_RECORD_ID.push(row['FAVORITE_RECORD_ID']);
						}
						var rowDefaultSearch = Sql.ParseFormData(sDEFAULT_SETTINGS);
						SearchViewUI_Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sSETTINGS_EDITVIEW, rowDefaultSearch, false, this.Search, function(status, message)
						{
							if ( status == 1 )
							{
								SearchViewUI_SearchForm(sLayoutPanel, sActionsPanel, sSETTINGS_EDITVIEW, this.Search, this);
							}
							else
							{
								$('#' + sLayoutPanel + '_divDashletError').text('Dashlet error: ' + message);
							}
						}, this);
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
			if ( arrFAVORITE_RECORD_ID.length > 0 )
			{
				if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
					sSEARCH_FILTER += ' and ';
				sSEARCH_FILTER += 'ID in (';
				for ( var i = 0; i < arrFAVORITE_RECORD_ID.length; i++ )
				{
					if ( i > 0 )
						sSEARCH_FILTER += ', ';
					sSEARCH_FILTER += '\'' + arrFAVORITE_RECORD_ID[i] + '\'';
				}
				sSEARCH_FILTER += ')';
			}
			else
			{
				// 07/31/2017 Paul.  If there are no favorites, then we want to show nothing. 
				if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
					sSEARCH_FILTER += ' and ';
				sSEARCH_FILTER += 'ID is null';
			}
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
		}
	};
});
