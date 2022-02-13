/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function DetailViewRelationshipsUI()
{
}

DetailViewRelationshipsUI.prototype.PageCommand = function(sLayoutPanel, sActionsPanel, sCommandName, oCommandArguments)
{
	try
	{
		if ( sCommandName == null )
			sCommandName = '';
		if ( sCommandName.indexOf('.Create') > 0 )
		{
			var sMODULE_NAME = sCommandName.split('.')[0];
			var sEDIT_NAME   = sMODULE_NAME + '.EditView';
			var oEditViewUI  = new EditViewUI();
			var rowInitialValues = new Object();
			if ( oCommandArguments != null && oCommandArguments.PARENT_MODULE !== undefined && oCommandArguments.ID !== undefined && oCommandArguments.NAME !== undefined )
			{
				var sPARENT_ID     = oCommandArguments.ID           ;
				var sPARENT_MODULE = oCommandArguments.PARENT_MODULE;
				var sPARENT_TABLE  = Crm.Modules.TableName(oCommandArguments.PARENT_MODULE);
				// 04/14/2016 Paul.  We need a way to detect that we are loading EditView from a relationship create. 
				rowInitialValues['DetailViewRelationshipCreate'] = true;
				rowInitialValues['PARENT_ID'  ] = oCommandArguments.ID  ;
				rowInitialValues['PARENT_NAME'] = oCommandArguments.NAME;
				// 01/30/2013 Paul.  Include the parent type to make sure that the dropdown is set properly for an activity record. 
				rowInitialValues['PARENT_TYPE'] = oCommandArguments.PARENT_MODULE;
				rowInitialValues[Crm.Modules.SingularTableName(sPARENT_TABLE) + '_ID'  ] = oCommandArguments.ID  ;
				rowInitialValues[Crm.Modules.SingularTableName(sPARENT_TABLE) + '_NAME'] = oCommandArguments.NAME;
				// 04/14/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
				// 04/14/2016 Paul.  In order to inherit assigned user and team, might as well send the entire row. 
				if ( oCommandArguments['PARENT_row'] !== undefined )
				{
					var rowPARENT = oCommandArguments['PARENT_row'];
					if ( rowPARENT['ASSIGNED_USER_ID'] !== undefined )
					{
						rowInitialValues['ASSIGNED_USER_ID' ] = rowPARENT['ASSIGNED_USER_ID' ];
						rowInitialValues['ASSIGNED_TO'      ] = rowPARENT['ASSIGNED_TO'      ];
						rowInitialValues['ASSIGNED_TO_NAME' ] = rowPARENT['ASSIGNED_TO_NAME' ];
						// 07/02/2019 Paul.  Copy dynamic user values. 
						rowInitialValues['ASSIGNED_SET_LIST'] = rowPARENT['ASSIGNED_SET_LIST'];
						rowInitialValues['ASSIGNED_SET_NAME'] = rowPARENT['ASSIGNED_SET_NAME'];
					}
					if ( rowPARENT['TEAM_ID'] !== undefined )
					{
						rowInitialValues['TEAM_ID'      ] = rowPARENT['TEAM_ID'      ];
						rowInitialValues['TEAM_NAME'    ] = rowPARENT['TEAM_NAME'    ];
						rowInitialValues['TEAM_SET_ID'  ] = rowPARENT['TEAM_SET_ID'  ];
						rowInitialValues['TEAM_SET_LIST'] = rowPARENT['TEAM_SET_LIST'];
						rowInitialValues['TEAM_SET_NAME'] = rowPARENT['TEAM_SET_NAME'];
					}
				}
				oEditViewUI.cbSaveComplete = function(sID, sMODULE_NAME)
				{
					var sPRIMARY_MODULE = sPARENT_MODULE;
					var sPRIMARY_ID     = sPARENT_ID    ;
					var sRELATED_MODULE = sMODULE_NAME  ;
					var sRELATED_ID     = sID           ;
					var bgPage = chrome.extension.getBackgroundPage();
					bgPage.UpdateRelatedItem(sPRIMARY_MODULE, sPRIMARY_ID, sRELATED_MODULE, sRELATED_ID, function(status, message)
					{
						// 10/27/2012 Paul.  After saving the relationship, go back to the parent module. 
						// 01/30/2013 Paul.  Some relationships are direct, so there is no relationship procedure. 
						if ( status == 1 || status == 3 || (status == -1 && StartsWith(message, 'Could not find procedure ') ))
						{
							var oDetailViewUI = new DetailViewUI();
							// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
							oDetailViewUI.Load(sLayoutPanel, sActionsPanel, sPARENT_MODULE, sPARENT_ID, function(status, message)
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
						}
						else if ( status == -1 )
						{
							SplendidError.SystemMessage(message);
						}
					}, this);
				};
			}
			sLayoutPanel  = sLayoutPanel.split('_')[0];
			sActionsPanel = sLayoutPanel.replace('Layout', 'Actions');
			oEditViewUI.LoadObject(sLayoutPanel, sActionsPanel, sEDIT_NAME, sMODULE_NAME, rowInitialValues, 'btnDynamicButtons_Save', oEditViewUI.PageCommand, function(status, message)
			{
			});
		}
		else if ( sCommandName.indexOf('.Select') > 0 )
		{
			var sMODULE_NAME   = sCommandName.split('.')[0];
			var sMODULE_TABLE  = Crm.Modules.TableName(sMODULE_NAME);
			if ( oCommandArguments != null && oCommandArguments.PARENT_MODULE !== undefined && oCommandArguments.ID !== undefined && oCommandArguments.NAME !== undefined )
			{
				var sPARENT_ID     = oCommandArguments.ID           ;
				var sPARENT_MODULE = oCommandArguments.PARENT_MODULE;
				var sPARENT_TABLE  = Crm.Modules.TableName(oCommandArguments.PARENT_MODULE);
				var sTABLE_NAME    = 'vw' + sPARENT_TABLE + '_' + sMODULE_TABLE;
				var $dialog = $('<div id="' + sTABLE_NAME + '_divPopup"><div id="divPopupActionsPanel" /><div id="divPopupLayoutPanel" /></div>');
				$dialog.dialog(
				{
					  modal    : true
					, resizable: true
					// 04/13/2017 Paul.  Use Bootstrap for responsive design.
					, position : { of: '#divMainPageContent' }
					, width    : $('#divMainPageContent').width() > 0 ? ($('#divMainPageContent').width() - 60) : 800
					// 04/26/2017 Paul.  Use Bootstrap for responsive design.
					//, height   : (navigator.userAgent.indexOf('iPad') > 0 ? 'auto' : ($(window).height() > 0 ? $(window).height() - 60 : 800))
					, height   : $('#divMainPageContent').height() > 0 ? $('#divMainPageContent').height() - 60 : 800
					, title    : L10n.Term(sMODULE_NAME + '.LBL_LIST_FORM_TITLE')
					, create   : function(event, ui)
					{
						try
						{
							var oPopupViewUI = new PopupViewUI();
							oPopupViewUI.Load('divPopupLayoutPanel', 'divPopupActionsPanel', sMODULE_NAME, false, function(status, message)
							{
								if ( status == 1 )
								{
									var sID   = message.ID  ;
									var sNAME = message.NAME;
								
									var sPRIMARY_MODULE = sPARENT_MODULE;
									var sPRIMARY_ID     = sPARENT_ID    ;
									var sRELATED_MODULE = sMODULE_NAME  ;
									var sRELATED_ID     = sID           ;
									var bgPage = chrome.extension.getBackgroundPage();
									/*
									var sPRIMARY_FIELD = Crm.Modules.SingularTableName(sPARENT_TABLE) + '_ID';
									var sRELATED_FIELD = Crm.Modules.SingularTableName(sMODULE_TABLE) + '_ID';
									// 11/14/2012 Paul.  In the special cases of Accounts Related and Contacts Reports To, we need to correct the field name. 
									if ( sPRIMARY_FIELD == 'ACCOUNT_ID' && sRELATED_FIELD == 'ACCOUNT_ID' )
									{
										sTABLE_NAME    = 'ACCOUNTS_MEMBERS';
										sRELATED_FIELD = 'PARENT_ID';
										sPRIMARY_ID    = sID;
										sRELATED_ID    = sPARENT_ID;
									}
									else if ( sPRIMARY_FIELD == 'CONTACT_ID' && sRELATED_FIELD == 'CONTACT_ID' )
									{
										sTABLE_NAME    = 'CONTACTS_DIRECT_REPORTS';
										sRELATED_FIELD = 'REPORTS_TO_ID';
										sPRIMARY_ID    = sID;
										sRELATED_ID    = sPARENT_ID;
									}
									*/
									bgPage.UpdateRelatedItem(sPRIMARY_MODULE, sPRIMARY_ID, sRELATED_MODULE, sRELATED_ID, function(status, message)
									{
										// 10/27/2012 Paul.  After saving the relationship, go back to the parent module. 
										if ( status == 1 || status == 3 )
										{
											sLayoutPanel  = sLayoutPanel.split('_')[0];
											sActionsPanel = sLayoutPanel.replace('Layout', 'Actions');
											var oDetailViewUI = new DetailViewUI();
											// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
											oDetailViewUI.Load(sLayoutPanel, sActionsPanel, sPARENT_MODULE, sPARENT_ID, function(status, message)
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
										}
										else if ( status == -1 )
										{
											SplendidError.SystemMessage(message);
										}
									}, this);
									// 02/21/2013 Paul.  Use close instead of destroy. 
									$dialog.dialog('close');
								}
								else if ( status == -2 )
								{
									// 02/21/2013 Paul.  Use close instead of destroy. 
									$dialog.dialog('close');
								}
								else if ( status == -1 )
								{
									SplendidError.SystemMessage(message);
								}
							});
						}
						catch(e)
						{
							SplendidError.SystemError(e, 'PopupViewUI dialog');
						}
					}
					, close: function(event, ui)
					{
						$dialog.dialog('destroy');
						// 10/17/2011 Paul.  We have to remove the new HTML, otherwise there will be multiple definitions for divPopupLayoutPanel. 
						var divPopup = document.getElementById(sTABLE_NAME + '_divPopup');
						divPopup.parentNode.removeChild(divPopup);
					}
				});
			}
		}
		else if ( sCommandName.indexOf('.Search') > 0 )
		{
			SplendidError.SystemMessage('Search not supported');
		}
		else
		{
			SplendidError.SystemMessage('DetailViewRelationshipsUI.PageCommand: Unknown command ' + sCommandName);
		}
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'DetailViewRelationshipsUI.PageCommand');
	}
}

DetailViewRelationshipsUI.prototype.Clear = function(sLayoutPanel)
{
	try
	{
		var divMainLayoutPanelSubPanel = document.getElementById(sLayoutPanel + '_divDetailSubPanel');
		if ( divMainLayoutPanelSubPanel != null && divMainLayoutPanelSubPanel.childNodes != null )
		{
			while ( divMainLayoutPanelSubPanel.childNodes.length > 0 )
			{
				divMainLayoutPanelSubPanel.removeChild(divMainLayoutPanelSubPanel.firstChild);
			}
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'DetailViewRelationshipsUI.Clear');
	}
}

DetailViewRelationshipsUI.prototype.LoadView = function(sLayoutPanel, sActionsPanel, layout, row, Page_Command)
{
	try
	{
		for ( var nLayoutIndex in layout )
		{
			var lay = layout[nLayoutIndex];
			var sDETAIL_NAME    = lay.DETAIL_NAME   ;
			var sMODULE_NAME    = lay.MODULE_NAME   ;
			var sTITLE          = lay.TITLE         ;
			var sCONTROL_NAME   = lay.CONTROL_NAME  ;
			var sTABLE_NAME     = lay.TABLE_NAME    ;
			var sPRIMARY_FIELD  = lay.PRIMARY_FIELD ;
			var sSORT_FIELD     = lay.SORT_FIELD    ;
			var sSORT_DIRECTION = lay.SORT_DIRECTION;
			
			//SplendidError.SystemLog('DetailViewRelationshipsUI: ' + sDETAIL_NAME + ', ' + sMODULE_NAME + ', ' + sCONTROL_NAME + ', ' + sTABLE_NAME);
			// 11/30/2012 Paul.  Special control names need to be converted to proper name. 
			if ( sCONTROL_NAME == 'Activities' )
			{
				sTITLE        = 'Activities.LBL_OPEN_ACTIVITIES';
				sCONTROL_NAME = 'Activities.Open';
				this.LoadViewRow(sLayoutPanel, sActionsPanel, sDETAIL_NAME, sMODULE_NAME, sTITLE, sCONTROL_NAME, sTABLE_NAME, sPRIMARY_FIELD, sSORT_FIELD, sSORT_DIRECTION, row, Page_Command);
				sTITLE        = 'Activities.LBL_HISTORY';
				sCONTROL_NAME = 'Activities.History';
				this.LoadViewRow(sLayoutPanel, sActionsPanel, sDETAIL_NAME, sMODULE_NAME, sTITLE, sCONTROL_NAME, sTABLE_NAME, sPRIMARY_FIELD, sSORT_FIELD, sSORT_DIRECTION, row, Page_Command);
			}
			else
			{
				if ( sCONTROL_NAME == 'ActivitiesOpen' )
				{
					sTITLE        = 'Activities.LBL_OPEN_ACTIVITIES';
					sCONTROL_NAME = 'Activities.Open';
				}
				else if ( sCONTROL_NAME == 'ActivitiesHistory' )
				{
					sTITLE        = 'Activities.LBL_HISTORY';
					sCONTROL_NAME = 'Activities.History';
				}
				else if ( sCONTROL_NAME == 'Projects' )
					sCONTROL_NAME = 'Project';
				else if ( sCONTROL_NAME == 'ProjectTasks' )
					sCONTROL_NAME = 'ProjectTask';
				this.LoadViewRow(sLayoutPanel, sActionsPanel, sDETAIL_NAME, sMODULE_NAME, sTITLE, sCONTROL_NAME, sTABLE_NAME, sPRIMARY_FIELD, sSORT_FIELD, sSORT_DIRECTION, row, Page_Command);
			}
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'DetailViewRelationshipsUI.LoadView');
	}
}

DetailViewRelationshipsUI.prototype.LoadViewRow = function(sLayoutPanel, sActionsPanel, sDETAIL_NAME, sMODULE_NAME, sTITLE, sCONTROL_NAME, sTABLE_NAME, sPRIMARY_FIELD, sSORT_FIELD, sSORT_DIRECTION, row, Page_Command)
{
	var sLayoutSubPanel = sLayoutPanel + '_divDetailSubPanel';
	var divMainLayoutPanelSubPanel = document.getElementById(sLayoutSubPanel);
	// 10/17/2012 Paul.  Exit if the LayoutSubPanel does not exist.  This is a sign that the user has navigated elsewhere. 
	if ( divMainLayoutPanelSubPanel == null )
		return;

	try
	{
		var sDETAIL_MODULE     = sDETAIL_NAME.split('.')[0];
		var sCONTROL_VIEW_NAME = sDETAIL_MODULE + '.' + sCONTROL_NAME;
		// 12/23/2012 Paul.  replace('.', '') is only replacing a single occurence.  Use regext to replace all. 
		// This solves the problem of Activities.Open not showing any data.  The pagination code could not find the control ID. 
		var sCONTROL_ID        = sLayoutPanel + '_div' + sCONTROL_VIEW_NAME.replace(/\./g, '');
		
		var divSubPanel = document.createElement('div');
		divSubPanel.id = sCONTROL_ID;
		divMainLayoutPanelSubPanel.appendChild(divSubPanel);
		
		// 06/21/2015 Paul.  The Seven theme has labels stacked above values. 
		SplendidUI_CollapsibleListHeader(sCONTROL_ID, sTITLE, sMODULE_NAME);
		
		// 12/01/2012 Paul.  Use an outer division so that we can collapse the subpanel. 
		var divSubPanelOuter = document.createElement('div');
		divSubPanelOuter.id = sCONTROL_ID + '_Outer';
		if ( window.localStorage )
		{
			if ( localStorage[divSubPanelOuter.id] == '1' )
				divSubPanelOuter.style.display = 'none';
		}
		else
		{
			if ( getCookie(divSubPanelOuter.id) == '1' )
				divSubPanelOuter.style.display = 'none';
		}
		divMainLayoutPanelSubPanel.appendChild(divSubPanelOuter);
		
		var divSubPanelActions = document.createElement('div');
		divSubPanelActions.id = sCONTROL_ID + '_Actions';
		divSubPanelOuter.appendChild(divSubPanelActions);
		// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
		DynamicButtonsUI_Load(sCONTROL_ID, divSubPanelActions.id, 'ListHeader', sCONTROL_VIEW_NAME, row, this.PageCommand, function(status, message)
		{
			if ( status != 1 )
				SplendidError.SystemMessage(message);
		}, this);
		
		var divSubPanelMain = document.createElement('div');
		divSubPanelMain.id = sCONTROL_ID + '_divSubPanelMain';
		divSubPanelOuter.appendChild(divSubPanelMain);
		
		// 10/20/2017 Paul.  Need the Sql.To*() functions. 
		var sPRIMARY_ID    = Sql.ToGuid(row['ID']);
		// 12/24/2012 Paul.  Search filter should use oData query format instead of equals sign. 
		var sSEARCH_FILTER = sPRIMARY_FIELD + " eq '" + sPRIMARY_ID + "'";
		var oListViewUI = new ListViewUI();
		oListViewUI.LoadRelatedModule(divSubPanelMain.id, divSubPanelActions.id, sDETAIL_MODULE, sMODULE_NAME, sCONTROL_VIEW_NAME, sTABLE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSEARCH_FILTER, sPRIMARY_ID, function(status, message)
		{
			//callback(status, message);
			if ( status != 1 )
				SplendidError.SystemMessage(message);
		});
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'DetailViewRelationshipsUI.LoadViewRow ' + sDETAIL_NAME + ' ' + sCONTROL_NAME);
	}
}

DetailViewRelationshipsUI.prototype.Load = function(sLayoutPanel, sActionsPanel, sDETAIL_NAME, row, Page_Command, callback)
{
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.DetailViewRelationships_LoadLayout(sDETAIL_NAME, function(status, message)
		{
			if ( status == 1 )
			{
				var layout = message;
				try
				{
					this.Clear(sLayoutPanel)
					this.LoadView(sLayoutPanel, sActionsPanel, layout, row, Page_Command)
					
					callback(1, null);
				}
				catch(e)
				{
					callback(-1, SplendidError.FormatError(e, 'DetailViewRelationshipsUI.Load'));
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
		callback(-1, SplendidError.FormatError(e, 'DetailViewRelationshipsUI.Load'));
	}
}
