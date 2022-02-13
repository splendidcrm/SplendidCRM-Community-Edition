/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function EditViewUI()
{
	this.MODULE    = null;
	this.ID        = null;
	this.DUPLICATE = false;
	// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
	this.LAST_DATE_MODIFIED = null;
	this.cbSaveComplete = null;
}

// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
EditViewUI.prototype.ButtonTheme = function ()
{
	var sTheme = 'Six';
	// 10/19/2016 Paul.  Add support for Arctic theme. 
	if ( Security.USER_THEME() == 'Arctic' )
		sTheme = 'Arctic';
	return sTheme;
}

EditViewUI.prototype.SubmitOffline = function (sLayoutPanel, sActionsPanel, sSaveType)
{
	try
	{
		// 10/04/2011 Paul.  The session might have timed-out, so first check if we are authenticated. 
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
				if ( window.localStorage && localStorage['OFFLINE_CACHE'] != null )
				{
					var arrOFFLINE_CACHE = JSON.parse(localStorage['OFFLINE_CACHE']);
					for ( var key in arrOFFLINE_CACHE )
					{
						var oCached = arrOFFLINE_CACHE[key];
						var sID          = oCached.ID         ;
						var sKEY         = oCached.KEY        ;
						var sMODULE_NAME = oCached.MODULE_NAME;
						var sNAME        = oCached.NAME       ;
						SplendidError.SystemMessage('Saving ' + sNAME);
						
						var result = JSON.parse(localStorage[key]);
						var row    = result.d.results;
						// 03/16/2014 Paul.  Add hidden buttons for Save Duplicate and Save Concurrency. 
						if ( sSaveType == 'SaveDuplicate' || sSaveType == 'SaveConcurrency' )
							row[sSaveType] = true;
						//alert(dumpObj(result, 'result'));
						// 10/16/2011 Paul.  sID is now a parameter so that it can be distinguished from Offline ID for a new record. 
						// We want to make sure to send a NULL for new records so that the ID is generated on the server with a true GUID. 
						// JavaScript cannot generate a true GUID, but this generated value should be valid on the single device. 
						bgPage.UpdateModule(sMODULE_NAME, row, sID, function(status, message)
						{
							try
							{
								if ( status == 1 )
								{
									if ( LoginViewUI_UpdateHeader !== undefined )
									{
										LoginViewUI_UpdateHeader(sLayoutPanel, sActionsPanel, true);
									}
									// 10/07/2011 Paul.  The offline cache should have changed. 
									arrOFFLINE_CACHE = JSON.parse(localStorage['OFFLINE_CACHE']);
									// 10/07/2011 Paul.  arrOFFLINE_CACHE.length is not valid. 
									var nOFFLINE_CACHE_length = 0;
									for ( var key in arrOFFLINE_CACHE )
									{
										nOFFLINE_CACHE_length++;
									}
									// 10/16/2011 Paul.  After a successful update of an offline record, lets fetch the full record. 
									// We should be able to load the item in a fire-and-forget mode. 
									bgPage.DetailView_LoadItem(sMODULE_NAME, message, function(status, message)
									{
									}, this);
									// 10/07/2011 Paul.  If the cached item was removed from the cache, then try the next one. 
									//alert('arrOFFLINE_CACHE[key] ' + arrOFFLINE_CACHE[key]);
									// 10/11/2011 Paul.  We are having problems with the iterator key, so use sKEY instead. 
									if ( !bgPage.GetIsOffline() && nOFFLINE_CACHE_length > 0 && arrOFFLINE_CACHE[sKEY] === undefined )
									{
										this.SubmitOffline(sLayoutPanel, sActionsPanel, 'Save');
									}
									else if ( arrOFFLINE_CACHE[sKEY] !== undefined )
									{
										SplendidError.SystemMessage(sID + ' still exists in the cache, which suggests a problem while saving.');
									}
									else
									{
										// 10/16/2011 Paul.  When done with all the updates, lets refresh the current list. 
										var lnkActiveTab = document.getElementById('ctlTabMenu_' + sMENU_ACTIVE_MODULE);
										if ( lnkActiveTab != null )
										{
											lnkActiveTab.onclick();
										}
									}
									// 03/16/2014 Paul.  Hide the save buttons when done. 
									if ( sSaveType == 'SaveDuplicate' )
									{
										var btnSaveDuplicate = document.getElementById('btnSubmit_SaveDuplicate');
										if ( btnSaveDuplicate != null )
											btnSaveDuplicate.style.display = 'none';
									}
									else if ( sSaveType == 'SaveConcurrency' )
									{
										var btnSaveConcurrency = document.getElementById('btnSubmit_SaveConcurrency');
										if ( btnSaveConcurrency != null )
											btnSaveConcurrency.style.display = 'none';
									}
								}
								// 03/16/2014 Paul.  Put the error name at the end so that we can detect the event. 
								else if ( EndsWith(message, '.ERR_DUPLICATE_EXCEPTION') )
								{
									var btnSaveDuplicate = document.getElementById('btnSubmit_SaveDuplicate');
									if ( btnSaveDuplicate != null )
										btnSaveDuplicate.style.display = 'inline';
									//message = message.replace('.ERR_DUPLICATE_EXCEPTION', '');
									message = message.substring(0, message.length - '.ERR_DUPLICATE_EXCEPTION'.length);
									SplendidError.SystemMessage(message);
								}
								else if ( EndsWith(message, '.ERR_CONCURRENCY_OVERRIDE') )
								{
									var btnSaveConcurrency = document.getElementById('btnSubmit_SaveConcurrency');
									if ( btnSaveConcurrency != null )
										btnSaveConcurrency.style.display = 'inline';
									//message = message.replace('.ERR_DUPLICATE_EXCEPTION', '');
									message = message.substring(0, message.length - '.ERR_CONCURRENCY_OVERRIDE'.length);
									SplendidError.SystemMessage(message);
								}
								else
								{
									SplendidError.SystemMessage(message);
								}
							}
							catch(e)
							{
								SplendidError.SystemError(e, 'UpdateModule');
							}
						}, this);
						// 10/07/2011 Paul.  Only save one record at a time. 
						break;
					}
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
		SplendidError.SystemError(e, 'EditViewUI.SubmitOffline');
	}
}

function EditViewUI_UpdateTable(sTABLE_NAME, sParameters, sErrorID, sSearchID)
{
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				var row = Sql.ParseFormData(sParameters);
				bgPage.UpdateModuleTable(sTABLE_NAME, row, null, function(status, message)
				{
					if ( status == 1 || status == 3 )
					{
						if ( status == 1 )
						{
							$('#' + sSearchID).click();
						}
						else
						{
							$('#' + sErrorID).text(message);
						}
					}
					else if ( status == -1 )
					{
						$('#' + sErrorID).text(message);
					}
				}, this);
			}
			else
			{
				$('#' + sErrorID).text(message);
			}
		}, this);
	}
	catch(e)
	{
		$('#' + sErrorID).text(e.message);
	}
}

EditViewUI.prototype.PageCommand = function(sLayoutPanel, sActionsPanel, sCommandName, sCommandArguments)
{
	// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
	// 03/15/2014 Paul.  Enable override of concurrency error. 
	if ( sCommandName == 'Save' || sCommandName == 'SaveDuplicate' || sCommandName == 'SaveConcurrency' )
	{
		try
		{
			if ( !this.Validate(sLayoutPanel, this.MODULE + '.EditView' + sPLATFORM_LAYOUT) )
				return;
			// 01/18/2018 Paul.  Execute the script, but if an object is returned, then it just created a function, not execute it. 
			if ( this.FORM_SCRIPT != null && this.FORM_SCRIPT !== undefined && typeof(this.FORM_SCRIPT.Validate) == 'function' )
			{
				var sCustomError = this.FORM_SCRIPT.Validate(sLayoutPanel);
				if ( sCustomError != null )
				{
					SplendidError.SystemMessage(sCustomError);
					return;
				}
			}
			
			var arrLineItems = new Array();
			if ( this.MODULE == 'Quotes' || this.MODULE == 'Orders' || this.MODULE == 'Invoices' || (this.MODULE == 'Opportunities' && Crm.Config.ToString('OpportunitiesMode') == 'Revenue') )
			{
				var oEditLineItemsViewUI = new EditLineItemsViewUI();
				oEditLineItemsViewUI.MODULE_NAME    = this.MODULE_NAME + 'LineItems';
				oEditLineItemsViewUI.PRIMARY_MODULE = this.MODULE;
				oEditLineItemsViewUI.PRIMARY_ID     = this.ID    ;
				if ( !oEditLineItemsViewUI.Validate(sLayoutPanel) )
				{
					SplendidError.SystemMessage(L10n.Term('Orders.ERR_UPDATE_LINE_ITEM'));
					return;
				}
				arrLineItems = oEditLineItemsViewUI.GetValues(sLayoutPanel);
			}

			// 10/04/2011 Paul.  The session might have timed-out, so first check if we are authenticated. 
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.AuthenticatedMethod(function(status, message)
			{
				if ( status == 1 )
				{
					var row = new Object();
					// 10/07/2011 Paul.  EditView_LoadItem can accept an empty ID so that we can have one execution path. 
					bgPage.EditView_LoadItem(this.MODULE, this.ID, function(status, message)
					{
						// 10/07/2011 Paul.  The row needs to start with the existing data. 
						if ( status == 1 )
						{
							row = message;
						}
						this.GetValues(sLayoutPanel, this.MODULE + '.EditView' + sPLATFORM_LAYOUT, false, row);
						if ( this.DUPLICATE )
						{
							this.ID = null;
						}
						row['ID'] = this.ID;

						if ( this.MODULE == 'Quotes' || this.MODULE == 'Orders' || this.MODULE == 'Invoices' || (this.MODULE == 'Opportunities' && Crm.Config.ToString('OpportunitiesMode') == 'Revenue') )
						{
							row.LineItems = arrLineItems;
						}
						//alert(dumpObj(row, 'row'));
						//alert(JSON.stringify(row));
						// 10/16/2011 Paul.  sID is now a parameter so that it can be distinguished from Offline ID for a new record. 
						// We want to make sure to send a NULL for new records so that the ID is generated on the server with a true GUID. 
						// JavaScript cannot generate a true GUID, but this generated value should be valid on the single device. 
						
						// 03/16/2014 Paul.  Pass Save Override to the update module. 
						if ( sCommandName == 'SaveDuplicate' || sCommandName == 'SaveConcurrency' )
							row[sCommandName] = true;
						// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
						if ( this.LAST_DATE_MODIFIED != null )
							row['LAST_DATE_MODIFIED'] = this.LAST_DATE_MODIFIED;
						bgPage.UpdateModule(this.MODULE, row, this.ID, function(status, message)
						{
							try
							{
								// 10/06/2011 Paul.  Status 3 means that the value was cached. 
								if ( status == 1 || status == 3 )
								{
									this.ID = message;
									// 01/30/2013 Paul.  Update header before loading detail view. 
									if ( status == 1 )
									{
										if ( status == 3 )
											SplendidError.SystemMessage('Record was saved to the offline cache.');
										else
											SplendidError.SystemMessage('');
									}
									if ( LoginViewUI_UpdateHeader !== undefined )
									{
										LoginViewUI_UpdateHeader(sLayoutPanel, sActionsPanel, true);
									}
									// 12/05/2012 Paul.  If a system table is updated, then we will need to update the cached data. 
									if ( bADMIN_MENU )
									{
										SplendidUI_CacheModule(this.MODULE, function(status, message)
										{
											if ( status == 2 )
											{
												SplendidError.SystemMessage(message);
											}
										});
									}
									
									// 10/06/2011 Paul.  We don't need to use DetailViewUI.LoadObject() because we store the offline cached data in the same location as the online cache. 
									var oDetailViewUI = new DetailViewUI();
									// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
									// This is to make sure that the detail view update does not get partially over-written by the save complete. 
									oDetailViewUI.Load(sLayoutPanel, sActionsPanel, this.MODULE, this.ID, function(status, message)
									{
										if ( status == 1 )
										{
											SplendidError.SystemMessage('');
											// 10/27/2012 Paul.  We need an event to save the relationship. 
											// 01/30/2013 Paul.  Move the save complete after the detail view has been rendered. 
											if ( this.cbSaveComplete != null )
											{
												// 10/27/2012 Paul.  After a successful relationship save, we will be sent to the detail view of the parent. 
												this.cbSaveComplete(this.ID, this.MODULE);
											}
										}
										else
										{
											SplendidError.SystemMessage(message);
										}
										// 01/30/2013 Paul.  Make sure to only clear the module after a cbSaveComplete call. 
										this.MODULE    = null;
										this.ID        = null;
										this.DUPLICATE = false;
										// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
										this.LAST_DATE_MODIFIED = null;
									}, this);
								}
								// 03/16/2014 Paul.  Put the error name at the end so that we can detect the event. 
								else if ( EndsWith(message, '.ERR_DUPLICATE_EXCEPTION') )
								{
									var btnSaveDuplicate = document.getElementById('btnDynamicButtons_SaveDuplicate');
									if ( btnSaveDuplicate != null )
										btnSaveDuplicate.style.display = 'inline';
									//message = message.replace('.ERR_DUPLICATE_EXCEPTION', '');
									message = message.substring(0, message.length - '.ERR_DUPLICATE_EXCEPTION'.length);
									SplendidError.SystemMessage(message);
								}
								else if ( EndsWith(message, '.ERR_CONCURRENCY_OVERRIDE') )
								{
									var btnSaveConcurrency = document.getElementById('btnDynamicButtons_SaveConcurrency');
									if ( btnSaveConcurrency != null )
										btnSaveConcurrency.style.display = 'inline';
									//message = message.replace('.ERR_DUPLICATE_EXCEPTION', '');
									message = message.substring(0, message.length - '.ERR_CONCURRENCY_OVERRIDE'.length);
									SplendidError.SystemMessage(message);
								}
								else
								{
									SplendidError.SystemMessage(message);
								}
							}
							catch(e)
							{
								SplendidError.SystemAlert(e, 'UpdateModule');
							}
						}, this);
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
			SplendidError.SystemError(e, 'EditViewUI.PageCommand');
		}
	}
	else if ( sCommandName == 'Cancel' )
	{
		// 10/21/2012 Paul.  If this is a new record being cancelled, return to the list. 
		if ( Sql.IsEmptyString(this.ID) )
		{
			var sGRID_NAME = this.MODULE + '.ListView' + sPLATFORM_LAYOUT;
			var oListViewUI = new ListViewUI();
			oListViewUI.Reset(sLayoutPanel, this.MODULE);
			oListViewUI.Load(sLayoutPanel, sActionsPanel, this.MODULE, sGRID_NAME, null, function(status, message)
			{
				if ( status == 0 || status == 1 )
				{
					this.MODULE    = null;
					this.ID        = null;
					this.DUPLICATE = false;
					// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
					this.LAST_DATE_MODIFIED = null;
				}
			});
		}
		else
		{
			var oDetailViewUI = new DetailViewUI();
			// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
			oDetailViewUI.Load(sLayoutPanel, sActionsPanel, this.MODULE, this.ID, function(status, message)
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
			this.MODULE    = null;
			this.ID        = null;
			this.DUPLICATE = false;
			// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
			this.LAST_DATE_MODIFIED = null;
		}
	}
	else
	{
		SplendidError.SystemMessage('EditViewUI.PageCommand: Unknown command ' + sCommandName);
	}
}

EditViewUI.prototype.Clear = function(sLayoutPanel)
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
			alert('EditViewUI.Clear: ' + sLayoutPanel + ' does not exist');
			return;
		}
		//<table class="tabForm" cellspacing="1" cellpadding="0" border="0" style="width:100%;">
		//	<tr>
		//		<td>
		//			<table id="ctlEditView_tblMain" class="tabEditView">
		//			</table>
		//		</td>
		//	</tr>
		//</table>

		// 04/08/2017 Paul.  Use Bootstrap for responsive design.
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			var tblForm = document.createElement('table');
			var tbody   = document.createElement('tbody');
			var tr      = document.createElement('tr');
			var td      = document.createElement('td');
			tblForm.className   = 'tabForm';
			tblForm.cellSpacing = 1;
			tblForm.cellPadding = 0;
			tblForm.border      = 0;
			tblForm.width       = '100%';
			tblForm.appendChild(tbody);
			tbody.appendChild(tr);
			tr.appendChild(td);
			divMainLayoutPanel.appendChild(tblForm);
		
			var ctlEditView_tblMain = document.createElement('table');
			ctlEditView_tblMain.id        = sLayoutPanel + '_ctlEditView_tblMain';
			ctlEditView_tblMain.width     = '100%';
			ctlEditView_tblMain.className = 'tabEditView';
			td.appendChild(ctlEditView_tblMain);
		}
		else
		{
			var ctlEditView_tblMain = document.createElement('div');
			ctlEditView_tblMain.id        = sLayoutPanel + '_ctlEditView_tblMain';
			divMainLayoutPanel.appendChild(ctlEditView_tblMain);
		}
		
		var divEditSubPanel = document.createElement('div');
		divEditSubPanel.id = sLayoutPanel + '_divEditSubPanel';
		divMainLayoutPanel.appendChild(divEditSubPanel);
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'EditViewUI.Clear');
	}
}

EditViewUI.prototype.Validate = function(sLayoutPanel, sEDIT_NAME)
{
	var nInvalidFields = 0;
	//alert('sLayoutPanel ' + sLayoutPanel);
	var bEnableTeamManagement  = Crm.Config.enable_team_management();
	var bRequireTeamManagement = Crm.Config.require_team_management();
	var bEnableDynamicTeams    = Crm.Config.enable_dynamic_teams();
	// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	var bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
	// 09/16/2018 Paul.  Create a multi-tenant system. 
	if ( Crm.Config.enable_multi_tenant_teams() )
	{
		bEnableTeamManagement    = false;
		bEnableDynamicTeams      = false;
		bEnableDynamicAssignment = false;
	}
	var bgPage  = chrome.extension.getBackgroundPage();
	var layout  = bgPage.SplendidCache.EditViewFields(sEDIT_NAME);
	for ( var nLayoutIndex in layout )
	{
		var lay = layout[nLayoutIndex];
		var sFIELD_TYPE                 = lay.FIELD_TYPE                ;
		var sDATA_LABEL                 = lay.DATA_LABEL                ;
		var sDATA_FIELD                 = lay.DATA_FIELD                ;
		var sDATA_FORMAT                = lay.DATA_FORMAT               ;
		var sDISPLAY_FIELD              = lay.DISPLAY_FIELD             ;
		var sLIST_NAME                  = lay.LIST_NAME                 ;
		var sONCLICK_SCRIPT             = lay.ONCLICK_SCRIPT            ;
		var sMODULE_TYPE                = lay.MODULE_TYPE               ;
		// 12/12/2012 Paul.  UI_REQUIRED is not used on SQLite, so use the DATA_REQUIRED value. 
		var bUI_REQUIRED                = Sql.ToBoolean(lay.UI_REQUIRED) || Sql.ToBoolean(lay.DATA_REQUIRED);
		try
		{
			if ( (sDATA_FIELD == 'TEAM_ID' || sDATA_FIELD == 'TEAM_SET_NAME') )
			{
				// 09/16/2018 Paul.  Create a multi-tenant system. 
				if ( Crm.Config.enable_multi_tenant_teams() )
				{
					sFIELD_TYPE  = "Hidden";
					sDATA_FIELD  = "TEAM_ID";
					bUI_REQUIRED = false;
				}
				else if ( !bEnableTeamManagement )
				{
					sFIELD_TYPE = 'Blank';
					bUI_REQUIRED = false;
				}
				else
				{
					if ( bEnableDynamicTeams )
					{
						// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
						// 10/20/2017 Paul.  Don't convert MyPipelineBySalesStage. 
						if ( sEDIT_NAME.indexOf('.Search') < 0 && sEDIT_NAME.indexOf('.Popup') < 0 && sEDIT_NAME.indexOf('.My') < 0 )
						{
							sDATA_LABEL     = '.LBL_TEAM_SET_NAME';
							sDATA_FIELD     = 'TEAM_SET_NAME';
							sFIELD_TYPE     = 'TeamSelect';
							sONCLICK_SCRIPT = '';
						}
					}
					else
					{
						// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
						if ( sFIELD_TYPE == 'TeamSelect' )
						{
							sDATA_LABEL     = 'Teams.LBL_TEAM';
							sDATA_FIELD     = 'TEAM_ID';
							sDISPLAY_FIELD  = 'TEAM_NAME';
							sFIELD_TYPE     = 'ModulePopup';
							sMODULE_TYPE    = 'Teams';
							sONCLICK_SCRIPT = '';
						}
					}
					if ( bRequireTeamManagement )
						bUI_REQUIRED = true;
				}
			}
			// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			else if ( (sDATA_FIELD == 'ASSIGNED_USER_ID' || sDATA_FIELD == 'ASSIGNED_SET_NAME') )
			{
				// 01/06/2018 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
				if ( bEnableDynamicAssignment && sDATA_FORMAT != "1" )
				{
					if ( sEDIT_NAME.indexOf('.Search') < 0 && sEDIT_NAME.indexOf('.Popup') < 0 && sEDIT_NAME.indexOf('.My') < 0 )
					{
						sDATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
						sDATA_FIELD     = 'ASSIGNED_SET_NAME';
						sFIELD_TYPE     = 'UserSelect';
						sONCLICK_SCRIPT = '';
					}
				}
				else
				{
					if ( sFIELD_TYPE == 'UserSelect' )
					{
						sDATA_LABEL     = '.LBL_ASSIGNED_TO';
						sDATA_FIELD     = 'ASSIGNED_USER_ID';
						sDISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
						sFIELD_TYPE     = 'ModulePopup';
						sMODULE_TYPE    = 'Users';
						sONCLICK_SCRIPT = '';
					}
				}
				if ( bRequireTeamManagement )
					bUI_REQUIRED = true;
			}
			if ( bUI_REQUIRED )
			{
				if ( sFIELD_TYPE == 'ModuleAutoComplete' )
				{
					var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
					if ( txt != null && txt.value != null )
					{
						var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
						reqNAME.style.display = Sql.IsEmptyString(txt.value) ? 'inline' : 'none';
						if ( Sql.IsEmptyString(txt.value) )
							nInvalidFields++;
					}
				}
				else if ( sFIELD_TYPE == 'ModulePopup' || sFIELD_TYPE == 'ChangeButton' )
				{
					var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
					if ( txt != null && txt.value != null )
					{
						var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
						reqNAME.style.display = Sql.IsEmptyString(txt.value) ? 'inline' : 'none';
						if ( Sql.IsEmptyString(txt.value) )
							nInvalidFields++;
					}
				}
				// 04/14/2016 Paul.  Add ZipCode lookup. 
				else if ( sFIELD_TYPE == 'TextBox' || sFIELD_TYPE == 'HtmlEditor' || sFIELD_TYPE == 'ZipCodePopup' )
				{
					var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
					if ( txt != null && txt.value != null )
					{
						var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
						reqNAME.style.display = Sql.IsEmptyString(txt.value) ? 'inline' : 'none';
						if ( Sql.IsEmptyString(txt.value) )
							nInvalidFields++;
					}
				}
				// 05/24/2017 Paul.  Need support for DateRange for new Dashboard. 
				else if ( sFIELD_TYPE == 'DateRange' )
				{
					// 01/01/2018 Paul.  datepicker does not like spaces in the id. 
					var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD.replace(/ /g, '_') + '_AFTER');
					if ( txt != null && txt.value != null )
					{
						try
						{
							var dt = $('#' + txt.id).datepicker('getDate');
							if ( isNaN(dt) )
								txt.value = '';
						}
						catch(e)
						{
							txt.value = '';
						}
						var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
						reqNAME.style.display = Sql.IsEmptyString(txt.value) ? 'inline' : 'none';
						if ( Sql.IsEmptyString(txt.value) )
							nInvalidFields++;
					}
					// 01/01/2018 Paul.  datepicker does not like spaces in the id. 
					var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD.replace(/ /g, '_') + '_BEFORE');
					if ( txt != null && txt.value != null )
					{
						try
						{
							var dt = $('#' + txt.id).datepicker('getDate');
							if ( isNaN(dt) )
								txt.value = '';
						}
						catch(e)
						{
							txt.value = '';
						}
						var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
						reqNAME.style.display = Sql.IsEmptyString(txt.value) ? 'inline' : 'none';
						if ( Sql.IsEmptyString(txt.value) )
							nInvalidFields++;
					}
				}
				else if ( sFIELD_TYPE == 'DatePicker' )
				{
					var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
					if ( txt != null && txt.value != null )
					{
						try
						{
							var dt = $('#' + txt.id).datepicker('getDate');
							if ( isNaN(dt) )
								txt.value = '';
						}
						catch(e)
						{
							txt.value = '';
						}
						var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
						reqNAME.style.display = Sql.IsEmptyString(txt.value) ? 'inline' : 'none';
						if ( Sql.IsEmptyString(txt.value) )
							nInvalidFields++;
					}
				}
				else if ( sFIELD_TYPE == 'DateTimeEdit' || sFIELD_TYPE == 'DateTimeNewRecord' || sFIELD_TYPE == 'DateTimePicker' )
				{
					var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
					if ( txt != null && txt.value != null )
					{
						try
						{
							var dt = $('#' + txt.id).datetimepicker('getDate');
							if ( isNaN(dt) )
								txt.value = '';
						}
						catch(e)
						{
							txt.value = '';
						}
						var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
						reqNAME.style.display = Sql.IsEmptyString(txt.value) ? 'inline' : 'none';
						if ( Sql.IsEmptyString(txt.value) )
							nInvalidFields++;
					}
				}
				else if ( sFIELD_TYPE == 'ListBox' )
				{
					if ( sLIST_NAME != null )
					{
						var lst = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
						if ( lst != null )
						{
							// 09/02/2011 Paul.  Always use an array so that we can distinguish between list entry and text entry. 
							var arr = new Array();
							if ( lst.multiple )
							{
								for ( var j = 0; j < lst.options.length; j++ )
								{
									if ( lst.options[j].selected )
									{
										arr.push(lst.options[j].value);
									}
								}
								var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
								reqNAME.style.display = (arr.length == 0) ? 'inline' : 'none';
								if ( arr.length == 0 )
									nInvalidFields++;
							}
							// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
							else if ( bUI_REQUIRED || Sql.ToString(sDATA_FORMAT).toLowerCase().indexOf('force') >= 0 )
							{
								// 01/18/2018 Paul.  Need to populate the array when using single selection. 
								if ( lst.options.selectedIndex >= 0 )
								{
									var sValue = lst.options[lst.options.selectedIndex].value;
									if ( !Sql.IsEmptyString(sValue) )
										arr.push(sValue);
								}
								var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
								if ( reqNAME != null )
								{
									reqNAME.style.display = (arr.length == 0) ? 'inline' : 'none';
									if ( arr.length == 0 )
										nInvalidFields++;
								}
							}
						}
					}
				}
				else if ( sFIELD_TYPE == 'TeamSelect' )
				{
					var sTEAM_SET_LIST = '';
					var arrTeams = document.getElementsByName(sLayoutPanel + '_ctlEditView_TEAM_SET_LIST');
					for ( var i = 0; i < arrTeams.length; i++ )
					{
						if( sTEAM_SET_LIST.length > 0 )
							sTEAM_SET_LIST += ',';
						sTEAM_SET_LIST += arrTeams[i].value;
					}
					var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
					reqNAME.style.display = Sql.IsEmptyString(sTEAM_SET_LIST) ? 'inline' : 'none';
					if ( Sql.IsEmptyString(sTEAM_SET_LIST) )
						nInvalidFields++;
				}
				// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( sFIELD_TYPE == 'UserSelect' )
				{
					var sASSIGNED_SET_LIST = '';
					var arrUsers = document.getElementsByName(sLayoutPanel + '_ctlEditView_ASSIGNED_SET_LIST');
					for ( var i = 0; i < arrUsers.length; i++ )
					{
						if( sASSIGNED_SET_LIST.length > 0 )
							sASSIGNED_SET_LIST += ',';
						sASSIGNED_SET_LIST += arrUsers[i].value;
					}
					var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
					reqNAME.style.display = Sql.IsEmptyString(sASSIGNED_SET_LIST) ? 'inline' : 'none';
					if ( Sql.IsEmptyString(sASSIGNED_SET_LIST) )
						nInvalidFields++;
				}
				// 05/14/2016 Paul.  Add Tags module. 
				else if ( sFIELD_TYPE == 'TagSelect' )
				{
					var sTAG_SET_NAME = '';
					var arrTags = document.getElementsByName(sLayoutPanel + '_ctlEditView_TAG_SET_NAME');
					for ( var i = 0; i < arrTags.length; i++ )
					{
						if( sTAG_SET_NAME.length > 0 )
							sTAG_SET_NAME += ',';
						sTAG_SET_NAME += arrTags[i].value;
					}
					var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
					reqNAME.style.display = Sql.IsEmptyString(sTAG_SET_NAME) ? 'inline' : 'none';
					if ( Sql.IsEmptyString(sTAG_SET_NAME) )
						nInvalidFields++;
				}
				// 06/07/2017 Paul.  Add NAICSCodes module. 
				else if ( sFIELD_TYPE == 'NAICSCodeSelect' )
				{
					var sNAICS_SET_NAME = '';
					var arrNaics = document.getElementsByName(sLayoutPanel + '_ctlEditView_NAICS_SET_NAME');
					for ( var i = 0; i < arrNaics.length; i++ )
					{
						if( sNAICS_SET_NAME.length > 0 )
							sNAICS_SET_NAME += ',';
						sNAICS_SET_NAME += arrNaics[i].value;
					}
					var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
					reqNAME.style.display = Sql.IsEmptyString(sNAICS_SET_NAME) ? 'inline' : 'none';
					if ( Sql.IsEmptyString(sNAICS_SET_NAME) )
						nInvalidFields++;
				}
				// 05/27/2016 Paul.  Add support for File type. 
				else if ( sFIELD_TYPE == 'File' )
				{
					var reqNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED');
					var hidUploadDATA      = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_DATA'     );
					var hidUploadOLD_VALUE = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_OLD_VALUE');
					if ( Sql.IsEmptyString(hidUploadDATA.value) && Sql.IsEmptyString(hidUploadOLD_VALUE.value) )
					{
						nInvalidFields++;
						reqNAME.style.display = 'inline';
					}
					else
					{
						reqNAME.style.display = 'none';
					}
				}
			}
		}
		catch(e)
		{
			SplendidError.SystemAlert(e, 'EditViewUI.Validate ' + sFIELD_TYPE + ' ' + sDATA_FIELD);
		}
	}
	return nInvalidFields == 0;
}

EditViewUI.prototype.GetValues = function(sLayoutPanel, sEDIT_NAME, bSearch, row)
{
	//alert('sLayoutPanel ' + sLayoutPanel);
	var bEnableTeamManagement  = Crm.Config.enable_team_management();
	var bEnableDynamicTeams    = Crm.Config.enable_dynamic_teams();
	// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	var bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
	// 09/16/2018 Paul.  Create a multi-tenant system. 
	if ( Crm.Config.enable_multi_tenant_teams() )
	{
		bEnableTeamManagement    = false;
		bEnableDynamicTeams      = false;
		bEnableDynamicAssignment = false;
	}
	var bgPage  = chrome.extension.getBackgroundPage();
	var layout  = bgPage.SplendidCache.EditViewFields(sEDIT_NAME);
	for ( var nLayoutIndex in layout )
	{
		var lay = layout[nLayoutIndex];
		var sFIELD_TYPE                 = lay.FIELD_TYPE                ;
		var sDATA_LABEL                 = lay.DATA_LABEL                ;
		var sDATA_FIELD                 = lay.DATA_FIELD                ;
		var sDATA_FORMAT                = lay.DATA_FORMAT               ;
		var sDISPLAY_FIELD              = lay.DISPLAY_FIELD             ;
		var sLIST_NAME                  = lay.LIST_NAME                 ;
		var sONCLICK_SCRIPT             = lay.ONCLICK_SCRIPT            ;
		var nFORMAT_ROWS                = Sql.ToInteger(lay.FORMAT_ROWS);
		var sMODULE_TYPE                = lay.MODULE_TYPE               ;
		
		try
		{
			if ( (sDATA_FIELD == 'TEAM_ID' || sDATA_FIELD == 'TEAM_SET_NAME') )
			{
				// 09/16/2018 Paul.  Create a multi-tenant system. 
				if ( Crm.Config.enable_multi_tenant_teams() )
				{
					sFIELD_TYPE  = "Hidden";
					sDATA_FIELD  = "TEAM_ID";
				}
				else if ( !bEnableTeamManagement )
				{
					sFIELD_TYPE = 'Blank';
				}
				else
				{
					if ( bEnableDynamicTeams )
					{
						// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
						// 10/20/2017 Paul.  Don't convert MyPipelineBySalesStage. 
						if ( sEDIT_NAME.indexOf('.Search') < 0 && sEDIT_NAME.indexOf('.Popup') < 0 && sEDIT_NAME.indexOf('.My') < 0 )
						{
							sDATA_LABEL     = '.LBL_TEAM_SET_NAME';
							sDATA_FIELD     = 'TEAM_SET_NAME';
							sFIELD_TYPE     = 'TeamSelect';
							sONCLICK_SCRIPT = '';
						}
					}
					else
					{
						// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
						if ( sFIELD_TYPE == 'TeamSelect' )
						{
							sDATA_LABEL     = 'Teams.LBL_TEAM';
							sDATA_FIELD     = 'TEAM_ID';
							sDISPLAY_FIELD  = 'TEAM_NAME';
							sFIELD_TYPE     = 'ModulePopup';
							sMODULE_TYPE    = 'Teams';
							sONCLICK_SCRIPT = '';
						}
					}
				}
			}
			// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			else if ( (sDATA_FIELD == 'ASSIGNED_USER_ID' || sDATA_FIELD == 'ASSIGNED_SET_NAME') )
			{
				// 01/06/2018 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
				if ( bEnableDynamicAssignment && sDATA_FORMAT != "1" )
				{
					if ( sEDIT_NAME.indexOf('.Search') < 0 && sEDIT_NAME.indexOf('.Popup') < 0 && sEDIT_NAME.indexOf('.My') < 0 )
					{
						sDATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
						sDATA_FIELD     = 'ASSIGNED_SET_NAME';
						sFIELD_TYPE     = 'UserSelect';
						sONCLICK_SCRIPT = '';
					}
				}
				else
				{
					// 12/27/2017 Paul.  If the user manually adds a UserSelect, we need to convert to a ModulePopup. 
					if ( sFIELD_TYPE == 'UserSelect' )
					{
						sDATA_LABEL     = '.LBL_ASSIGNED_TO';
						sDATA_FIELD     = 'ASSIGNED_USER_ID';
						sDISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
						sFIELD_TYPE     = 'ModulePopup';
						sMODULE_TYPE    = 'Users';
						sONCLICK_SCRIPT = '';
					}
				}
			}
			if ( sFIELD_TYPE == 'Hidden' )
			{
				var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				if ( txt != null && txt.value != null )
				{
					//alert(sDATA_FIELD + ' = ' + txt.value);
					row[sDATA_FIELD] = txt.value;
				}
			}
			else if ( sFIELD_TYPE == 'ModuleAutoComplete' )
			{
				var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				if ( txt != null && txt.value != null )
				{
					//alert(sDATA_FIELD + ' = ' + txt.value);
					row[sDATA_FIELD] = txt.value;
				}
			}
			else if ( sFIELD_TYPE == 'ModulePopup' || sFIELD_TYPE == 'ChangeButton' )
			{
				var hid = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				if ( hid != null && hid.value != null )
				{
					//alert(sDISPLAY_FIELD + ' = ' + txt.value);
					// 10/18/2011 Paul.  If this is a search operation, then we want the exact value. 
					if ( bSearch )
						row[sDATA_FIELD] = '=' + hid.value;
					else
						row[sDATA_FIELD] = hid.value;
				}
				// 12/23/2012 Paul.  If the label is PARENT_TYPE, then change the label to a DropDownList.
				if ( sDATA_LABEL == 'PARENT_TYPE' && sFIELD_TYPE == 'ChangeButton' )
				{
					var lst = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_PARENT_TYPE');
					if ( lst != null )
					{
						row['PARENT_TYPE'] = lst.options[lst.options.selectedIndex].value;
					}
				}
			}
			// 04/14/2016 Paul.  Add ZipCode lookup. 
			else if ( sFIELD_TYPE == 'TextBox' || sFIELD_TYPE == 'HtmlEditor' || sFIELD_TYPE == 'ZipCodePopup' )
			{
				if ( nFORMAT_ROWS == 0 )
				{
					var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
					if ( txt != null && txt.value != null )
					{
						//alert(sDATA_FIELD + ' = ' + txt.value);
						row[sDATA_FIELD] = txt.value;
					}
				}
				else
				{
					var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
					// 10/14/2011 Paul.  We still access the value from a textarea. 
					if ( txt != null && txt.value != null )
					{
						//alert(sDATA_FIELD + ' = ' + txt.value);
						row[sDATA_FIELD] = txt.value;
					}
				}
			}
			// 05/24/2017 Paul.  Need support for DateRange for new Dashboard. 
			else if ( sFIELD_TYPE == 'DateRange' )
			{
				// 01/01/2018 Paul.  datepicker does not like spaces in the id. 
				var txtAFTER  = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD.replace(/ /g, '_') + '_AFTER' );
				var txtBEFORE = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD.replace(/ /g, '_') + '_BEFORE');
				if ( (txtAFTER != null && txtAFTER.value != null) || (txtBEFORE != null && txtBEFORE.value != null) )
				{
					row[sDATA_FIELD] = new Array();
					row[sDATA_FIELD].push(null);
					row[sDATA_FIELD].push(null);
					//alert(sDATA_FIELD + ' = ' + txt.value);
					try
					{
						if ( txtAFTER != null && txtAFTER.value != null )
							row[sDATA_FIELD][0] = ToJsonDate($('#' + txtAFTER.id).datepicker('getDate'));
					}
					catch(e)
					{
					}
					try
					{
						if ( txtBEFORE != null && txtBEFORE.value != null )
							row[sDATA_FIELD][1] = ToJsonDate($('#' + txtBEFORE.id).datepicker('getDate'));
					}
					catch(e)
					{
					}
				}
			}
			else if ( sFIELD_TYPE == 'DatePicker' )
			{
				var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				if ( txt != null && txt.value != null )
				{
					//alert(sDATA_FIELD + ' = ' + txt.value);
					try
					{
						
						row[sDATA_FIELD] = ToJsonDate($('#' + txt.id).datepicker('getDate'));
					}
					catch(e)
					{
						row[sDATA_FIELD] = null;
					}
				}
			}
			else if ( sFIELD_TYPE == 'DateTimeEdit' || sFIELD_TYPE == 'DateTimeNewRecord' || sFIELD_TYPE == 'DateTimePicker' )
			{
				var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				if ( txt != null && txt.value != null )
				{
					//alert(sDATA_FIELD + ' = ' + txt.value);
					try
					{
						var dtVALUE = $('#' + txt.id).datetimepicker('getDate');
						row[sDATA_FIELD] = ToJsonDate(dtVALUE);
						//alert(sDATA_FIELD + ' ' + txt.value + ' ' + dtVALUE.toString() + ' ' + FromJsonDate(row[sDATA_FIELD], Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT()))
					}
					catch(e)
					{
						row[sDATA_FIELD] = null;
					}
				}
			}
			else if ( sFIELD_TYPE == 'ListBox' )
			{
				if ( sLIST_NAME != null )
				{
					var lst = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
					if ( lst != null )
					{
						// 09/02/2011 Paul.  Always use an array so that we can distinguish between list entry and text entry. 
						var arr = new Array();
						if ( lst.multiple )
						{
							for ( var j = 0; j < lst.options.length; j++ )
							{
								if ( lst.options[j].selected )
								{
									arr.push(lst.options[j].value);
								}
							}
							if ( arr.length > 0 )
							{
								//alert(sDATA_FIELD + ' = ' + dumpObj(arr, ''));
								// 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV. 
								if ( lst.multiple && Math.abs(nFORMAT_ROWS) > 0 && Sql.ToString(sDATA_FORMAT).toLowerCase().indexOf('csv') >= 0 )
								{
									// 01/06/2018 Paul.  We need to return a string and not an area to prevent the REST API from storing as XML. 
									row[sDATA_FIELD] = arr.join(',');
								}
								else
								{
									row[sDATA_FIELD] = arr;
								}
							}
						}
						else
						{
							if ( lst.options.selectedIndex >= 0 )
							{
								//alert(sDATA_FIELD + ' = ' + lst.options[lst.options.selectedIndex].value);
								// 09/09/2011 Paul.  We need another way to determine if we should use a wildcard search or an exact string. 
								// 09/09/2011 Paul.  Using an array is not good as it causes problems when during a ModuleUpdate operation. 
								if ( bSearch )
								{
									arr.push(lst.options[lst.options.selectedIndex].value);
									row[sDATA_FIELD] = arr;
								}
								else
								{
									row[sDATA_FIELD] = lst.options[lst.options.selectedIndex].value;
								}
							}
						}
					}
				}
			}
			// 08/01/2013 Paul.  Add support for CheckBoxList. 
			else if ( sFIELD_TYPE == 'CheckBoxList' )
			{
				if ( sLIST_NAME != null )
				{
					var arrLIST = L10n.GetList(sLIST_NAME);
					if ( arrLIST != null )
					{
						var arr = new Array();
						row[sDATA_FIELD] = null;
						for ( var i = 0; i < arrLIST.length; i++ )
						{
							var chk = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_' + arrLIST[i]);
							if ( chk != null )
							{
								if ( chk.checked )
									arr.push(chk.value);
							}
						}
						if ( arr.length > 0 )
						{
							// 06/03/2018 Paul.  REPEAT_DOW is a special list that returns 0 = sunday, 1 = monday, etc. 
							if ( sDATA_FIELD == 'REPEAT_DOW' )
							{
								row[sDATA_FIELD] = arr.join('');
							}
							else
							{
								// 06/04/2018 Paul.  Build XML string as the value. 
								var sXML = '<?xml version=\"1.0\" encoding=\"utf-8\"?>';
								sXML += '<Values>';
								for ( var i = 0; i < arr.length; i++ )
								{
									sXML += '<Value>' + Sql.EscapeEmail(arr[i]) + '</Value>';
								}
								sXML += '</Values>';
								row[sDATA_FIELD] = sXML;
							}
						}
					}
				}
			}
			// 08/01/2013 Paul.  Add support for Radio. 
			else if ( sFIELD_TYPE == 'Radio' )
			{
				if ( sLIST_NAME != null )
				{
					var arrLIST = L10n.GetList(sLIST_NAME);
					if ( arrLIST != null )
					{
						row[sDATA_FIELD] = null;
						for ( var i = 0; i < arrLIST.length; i++ )
						{
							var chk = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_' + arrLIST[i]);
							if ( chk != null )
							{
								if ( chk.checked )
								{
									row[sDATA_FIELD] = chk.value;
									break;
								}
							}
						}
					}
				}
			}
			else if ( sFIELD_TYPE == 'CheckBox' )
			{
				var chk = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				// 01/19/2013 Paul.  Make sure to save both the checked and the unchecked state. 
				if ( chk != null )
					row[sDATA_FIELD] = chk.checked;
			}
			else if ( sFIELD_TYPE == 'TeamSelect' )
			{
				var sTEAM_ID       = '';
				var sTEAM_SET_LIST = '';
				var arrTeams = document.getElementsByName(sLayoutPanel + '_ctlEditView_TEAM_SET_LIST');
				for ( var i = 0; i < arrTeams.length; i++ )
				{
					if( sTEAM_SET_LIST.length > 0 )
						sTEAM_SET_LIST += ',';
					if( sTEAM_ID.length == 0 )
						sTEAM_ID = arrTeams[i].value;
					sTEAM_SET_LIST += arrTeams[i].value;
				}
				var arrPrimary = document.getElementsByName(sLayoutPanel + '_ctlEditView_PRIMARY_TEAM');
				for ( var i = 0; i < arrPrimary.length; i++ )
				{
					if ( arrPrimary[i].checked )
					{
						sTEAM_ID = arrPrimary[i].value;
					}
				}
				// 12/27/2017 Paul.  This is a change, but it should follow the same rule as for user select. 
				if ( !bSearch )
					row['TEAM_ID'      ] = sTEAM_ID      ;
				row['TEAM_SET_LIST'] = sTEAM_SET_LIST;
			}
			// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			else if ( sFIELD_TYPE == 'UserSelect' )
			{
				var sASSIGNED_USER_ID  = '';
				var sASSIGNED_SET_LIST = '';
				var arrUsers = document.getElementsByName(sLayoutPanel + '_ctlEditView_ASSIGNED_SET_LIST');
				for ( var i = 0; i < arrUsers.length; i++ )
				{
					if( sASSIGNED_SET_LIST.length > 0 )
						sASSIGNED_SET_LIST += ',';
					if( sASSIGNED_USER_ID.length == 0 )
						sASSIGNED_USER_ID = arrUsers[i].value;
					sASSIGNED_SET_LIST += arrUsers[i].value;
				}
				var arrPrimary = document.getElementsByName(sLayoutPanel + '_ctlEditView_PRIMARY_USER');
				for ( var i = 0; i < arrPrimary.length; i++ )
				{
					if ( arrPrimary[i].checked )
					{
						sASSIGNED_USER_ID = arrPrimary[i].value;
					}
				}
				// 12/27/2017 Paul.  When using dynamic assignment, we don't want both ASSIGNED_USER_ID and ASSIGNED_SET_LIST. 
				if ( !bSearch )
					row['ASSIGNED_USER_ID' ] = sASSIGNED_USER_ID ;
				row['ASSIGNED_SET_LIST'] = sASSIGNED_SET_LIST;
			}
			// 05/14/2016 Paul.  Add Tags module. 
			else if ( sFIELD_TYPE == 'TagSelect' )
			{
				var sTAG_SET_NAME = '';
				var arrTags = document.getElementsByName(sLayoutPanel + '_ctlEditView_TAG_SET_NAME');
				for ( var i = 0; i < arrTags.length; i++ )
				{
					if( sTAG_SET_NAME.length > 0 )
						sTAG_SET_NAME += ',';
					sTAG_SET_NAME += arrTags[i].value;
				}
				row['TAG_SET_NAME'] = sTAG_SET_NAME;
			}
			// 06/07/2017 Paul.  Add NAICSCodes module. 
			else if ( sFIELD_TYPE == 'NAICSCodeSelect' )
			{
				var sNAICS_SET_NAME = '';
				var arrNaics = document.getElementsByName(sLayoutPanel + '_ctlEditView_NAICS_SET_NAME');
				for ( var i = 0; i < arrNaics.length; i++ )
				{
					if( sNAICS_SET_NAME.length > 0 )
						sNAICS_SET_NAME += ',';
					sNAICS_SET_NAME += arrNaics[i].value;
				}
				row['NAICS_SET_NAME'] = sNAICS_SET_NAME;
			}
			// 05/27/2016 Paul.  Add support for File type. 
			else if ( sFIELD_TYPE == 'File' )
			{
				var hidUploadNAME      = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_NAME');
				var hidUploadTYPE      = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_TYPE');
				var hidUploadDATA      = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_DATA');
				var hidUploadOLD_VALUE = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_OLD_VALUE');
				row[sDATA_FIELD] = hidUploadOLD_VALUE.value;
				if ( !Sql.IsEmptyString(hidUploadDATA.value) )
				{
					if ( row.Files === undefined )
						row.Files = new Array();
					var image = new Object();
					var arrFileParts = hidUploadNAME.value.split('.');
					image.DATA_FIELD     = sDATA_FIELD;
					image.FILENAME       = hidUploadNAME.value;
					image.FILE_EXT       = arrFileParts[arrFileParts.length - 1];
					image.FILE_MIME_TYPE = hidUploadTYPE.value;
					image.FILE_DATA      = hidUploadDATA.value;
					row.Files.push(image);
				}
			}
		}
		catch(e)
		{
			SplendidError.SystemAlert(e, 'EditViewUI.GetValues ' + sFIELD_TYPE + ' ' + sDATA_FIELD);
		}
	}
	return row;
}

EditViewUI.prototype.ClearValues = function(sLayoutPanel, sEDIT_NAME)
{
	//alert('sEDIT_NAME ' + sEDIT_NAME);
	var row = new Array();
	var bEnableTeamManagement  = Crm.Config.enable_team_management();
	var bEnableDynamicTeams    = Crm.Config.enable_dynamic_teams();
	// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	var bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
	// 09/16/2018 Paul.  Create a multi-tenant system. 
	if ( Crm.Config.enable_multi_tenant_teams() )
	{
		bEnableTeamManagement    = false;
		bEnableDynamicTeams      = false;
		bEnableDynamicAssignment = false;
	}
	var bgPage  = chrome.extension.getBackgroundPage();
	var layout  = bgPage.SplendidCache.EditViewFields(sEDIT_NAME);
	for ( var nLayoutIndex in layout )
	{
		var lay = layout[nLayoutIndex];
		var sFIELD_TYPE                 = lay.FIELD_TYPE                ;
		var sDATA_FIELD                 = lay.DATA_FIELD                ;
		var sDISPLAY_FIELD              = lay.DISPLAY_FIELD             ;
		var sLIST_NAME                  = lay.LIST_NAME                 ;
		var nFORMAT_ROWS                = Sql.ToInteger(lay.FORMAT_ROWS);
		try
		{
			if ( sFIELD_TYPE == 'Hidden' )
			{
				var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				if ( txt != null )
				{
					txt.value = '';
				}
			}
			else if ( sFIELD_TYPE == 'ModuleAutoComplete' )
			{
				var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				if ( txt != null )
				{
					txt.value = '';
				}
			}
			else if ( sFIELD_TYPE == 'ModulePopup' || sFIELD_TYPE == 'ChangeButton' )
			{
				var sTEMP_DISPLAY_FIELD = Sql.IsEmptyString(sDISPLAY_FIELD) ? sDATA_FIELD + '_NAME' : sDISPLAY_FIELD;
				var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sTEMP_DISPLAY_FIELD);
				if ( txt != null )
				{
					txt.value = '';
				}
				var hid = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				if ( hid != null )
				{
					hid.value = '';
				}
			}
			// 04/14/2016 Paul.  Add ZipCode lookup. 
			else if ( sFIELD_TYPE == 'TextBox' || sFIELD_TYPE == 'HtmlEditor' || sFIELD_TYPE == 'ZipCodePopup' )
			{
				if ( nFORMAT_ROWS == 0 )
				{
					var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
					if ( txt != null )
					{
						txt.value = '';
					}
				}
				else
				{
					var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
					if ( txt != null )
					{
						txt.innerHTML = '';
					}
				}
			}
			// 05/24/2017 Paul.  Need support for DateRange for new Dashboard. 
			// 01/01/2018 Paul.  Correct spelling of field type. 
			else if ( sFIELD_TYPE == 'DateRange' )
			{
				// 01/01/2018 Paul.  datepicker does not like spaces in the id. 
				var txtAFTER = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD.replace(/ /g, '_') + '_AFTER');
				if ( txtAFTER != null )
				{
					txtAFTER.value = '';
				}
				var txtBEFORE = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD.replace(/ /g, '_') + '_BEFORE');
				if ( txtBEFORE != null )
				{
					txtBEFORE.value = '';
				}
			}
			else if ( sFIELD_TYPE == 'DatePicker' )
			{
				var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				if ( txt != null )
				{
					txt.value = '';
				}
			}
			else if ( sFIELD_TYPE == 'DateTimeEdit' || sFIELD_TYPE == 'DateTimeNewRecord' || sFIELD_TYPE == 'DateTimePicker' )
			{
				var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				if ( txt != null )
				{
					txt.value = '';
				}
			}
			else if ( sFIELD_TYPE == 'ListBox' )
			{
				if ( sLIST_NAME != null )
				{
					var lst = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
					if ( lst != null )
					{
						if ( lst.multiple )
						{
							for ( var j = 0; j < lst.options.length; j++ )
							{
								lst.options[j].selected = false;
							}
						}
						else
						{
							lst.options.selectedIndex = 0;
						}
					}
				}
			}
			// 08/01/2013 Paul.  Add support for CheckBoxList. 
			else if ( sFIELD_TYPE == 'CheckBoxList' )
			{
				if ( sLIST_NAME != null )
				{
					var arrLIST = L10n.GetList(sLIST_NAME);
					if ( arrLIST != null )
					{
						for ( var i = 0; i < arrLIST.length; i++ )
						{
							var chk = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_' + arrLIST[i]);
							if ( chk != null )
								chk.checked = false;
						}
					}
				}
			}
			// 08/01/2013 Paul.  Add support for Radio. 
			else if ( sFIELD_TYPE == 'Radio' )
			{
				if ( sLIST_NAME != null )
				{
					var arrLIST = L10n.GetList(sLIST_NAME);
					if ( arrLIST != null )
					{
						for ( var i = 0; i < arrLIST.length; i++ )
						{
							var chk = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_' + arrLIST[i]);
							if ( chk != null )
								chk.checked = false;
						}
					}
				}
			}
			else if ( sFIELD_TYPE == 'CheckBox' )
			{
				var chk = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				if ( chk != null )
					chk.checked = false;
			}
			// 05/27/2016 Paul.  Add support for File type. 
			else if ( sFIELD_TYPE == 'File' )
			{
				var hidUploadNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_NAME');
				var hidUploadTYPE = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_TYPE');
				var hidUploadDATA = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_DATA');
				var fileUpload    = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				hidUploadNAME.value = '';
				hidUploadTYPE.value = '';
				hidUploadDATA.value = '';
				EditViewClearFileInput(fileUpload, sLayoutPanel, sDATA_FIELD);
			}
		}
		catch(e)
		{
			SplendidError.SystemAlert(e, 'EditViewUI.ClearValues' + sFIELD_TYPE + ' ' + sDATA_FIELD);
		}
	}
	return row;
}

EditViewUI.prototype.AutoComplete = function(sLayoutPanel, sMODULE_TYPE, sTEXT_FIELD, sVALUE_FIELD)
{
	// http://jqueryui.com/demos/autocomplete/remote-jsonp.html
	$('#' + sLayoutPanel + '_ctlEditView_' + sTEXT_FIELD).autocomplete(
	{
		  minLength: 2
		, source: function(request, response)
		{
			try
			{
				var sTABLE_NAME = Crm.Modules.TableName(sMODULE_TYPE);
				var sMETHOD = sTABLE_NAME + '_' + sTEXT_FIELD + '_List';
				var oREQUEST = new Object();
				oREQUEST.prefixText = request.term;
				oREQUEST.count = 12;
				// 03/08/2016 Paul.  We need to include the context parameter for Quotes, Orders and Invoices. 
				if ( sMETHOD == 'CONTACTS_BILLING_CONTACT_NAME_List' )
				{
					oREQUEST.contextKey = $('#' + sLayoutPanel + '_ctlEditView_' + 'BILLING_ACCOUNT_NAME').val();
				}
				else if ( sMETHOD == 'CONTACTS_SHIPPING_CONTACT_NAME_List' )
				{
					oREQUEST.contextKey = $('#' + sLayoutPanel + '_ctlEditView_' + 'SHIPPING_ACCOUNT_NAME').val();
				}
				var bgPage = chrome.extension.getBackgroundPage();
				bgPage.AutoComplete_ModuleMethod(sMODULE_TYPE, sMETHOD, JSON.stringify(oREQUEST), function(status, message)
				{
					if ( status == 1 )
					{
						response($.map(message, function(item)
						{
							return { label: item, value: item };
						}));
					}
				}, this);
			}
			catch(e)
			{
				SplendidError.SystemAlert(e, 'EditViewUI.AutoComplete' + sMODULE_TYPE + ' ' + sTEXT_FIELD);
			}
		}
		, select: function(event, ui)
		{
			try
			{
				//alert(dumpObj(ui.item, 'ui.item'));
				if ( sVALUE_FIELD != null && ui.item && !Sql.IsEmptyString(ui.item.value) )
				{
					var sTABLE_NAME = Crm.Modules.TableName(sMODULE_TYPE);
					var sMETHOD = sTABLE_NAME + '_' + sTEXT_FIELD + '_Get';
					var bgPage = chrome.extension.getBackgroundPage();
					bgPage.AutoComplete_ModuleMethod(sMODULE_TYPE, sMETHOD, '{"sNAME": ' + JSON.stringify(ui.item.value) + '}', function(status, message)
					{
						//alert(dumpObj(message, 'AutoComplete response'));
						var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sTEXT_FIELD );
						var hid = document.getElementById(sLayoutPanel + '_ctlEditView_' + sVALUE_FIELD);
						if ( txt != null ) txt.value = (status == 1) ? message.NAME : '';
						if ( hid != null ) hid.value = (status == 1) ? message.ID   : '';
					}, this);
				}
			}
			catch(e)
			{
				SplendidError.SystemAlert(e, 'EditViewUI.AutoComplete' + sMODULE_TYPE + ' ' + sTEXT_FIELD);
			}
		}
		, open: function()
		{
			$(this).removeClass('ui-corner-all').addClass('ui-corner-top');
		}
		, close: function()
		{
			$(this).removeClass('ui-corner-top').addClass('ui-corner-all');
		}
	});
}

EditViewUI.prototype.AutoCompleteBlur = function(sLayoutPanel, sMODULE_TYPE, sTEXT_FIELD, sVALUE_FIELD, sSubmitID)
{
	try
	{
		var txt = document.getElementById(sLayoutPanel + '_ctlEditView_' + sTEXT_FIELD );
		var hid = document.getElementById(sLayoutPanel + '_ctlEditView_' + sVALUE_FIELD);
		
		if ( !Sql.IsEmptyString(txt.value) )
		{
			var sTABLE_NAME = Crm.Modules.TableName(sMODULE_TYPE);
			var sMETHOD = sTABLE_NAME + '_' + sTEXT_FIELD + '_Get';
			var oREQUEST = new Object();
			oREQUEST.sNAME = txt.value;
			// 03/08/2016 Paul.  We need to include the context parameter for Quotes, Orders and Invoices. 
			if ( sMETHOD == 'CONTACTS_BILLING_CONTACT_NAME_Get' )
			{
				oREQUEST.contextKey = $('#' + sLayoutPanel + '_ctlEditView_' + 'BILLING_ACCOUNT_NAME').val();
			}
			else if ( sMETHOD == 'CONTACTS_SHIPPING_CONTACT_NAME_Get' )
			{
				oREQUEST.contextKey = $('#' + sLayoutPanel + '_ctlEditView_' + 'SHIPPING_ACCOUNT_NAME').val();
			}
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.AutoComplete_ModuleMethod(sMODULE_TYPE, sMETHOD, JSON.stringify(oREQUEST), function(status, message)
			{
				//alert(dumpObj(message, 'AutoComplete response status = ' + status));
				if ( txt != null ) txt.value = (status == 0 || status == 1) ? message.NAME : '';
				if ( hid != null ) hid.value = (status == 0 || status == 1) ? message.ID   : '';
				if ( sSubmitID !== undefined && sSubmitID != null )
				{
					var btnSubmit = document.getElementById(sLayoutPanel + '_ctlEditView_' + sSubmitID);
					if ( btnSubmit != null )
						btnSubmit.onclick();
				}
			}, this);
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'EditViewUI.AutoCompleteBlur' + sMODULE_TYPE + ' ' + sTEXT_FIELD);
	}
}

EditViewUI.prototype.LoadTeamSelect = function(sLayoutPanel, tdField, sTEAM_SET_ID, sTEAM_SET_LIST, bUI_REQUIRED, bAllowDefaults)
{
	try
	{
		var ctlEditView_TEAM_SET_NAME = document.createElement('table');
		var tbody = document.createElement('tbody');
		var tr    = document.createElement('tr');
		ctlEditView_TEAM_SET_NAME.id          = sLayoutPanel + '_ctlEditView_TEAM_SET_NAME';
		ctlEditView_TEAM_SET_NAME.className   = 'listView';
		ctlEditView_TEAM_SET_NAME.cellSpacing = 0;
		ctlEditView_TEAM_SET_NAME.cellPadding = 2;
		ctlEditView_TEAM_SET_NAME.border      = 1;
		ctlEditView_TEAM_SET_NAME.style.borderCollapse = 'collapse';
		ctlEditView_TEAM_SET_NAME.appendChild(tbody);
		tr.className = 'listViewThS1';
		tbody.appendChild(tr);
		tdField.appendChild(ctlEditView_TEAM_SET_NAME);

		var tdTeam = document.createElement('th');
		tdTeam.innerHTML = '&nbsp;';
		tr.appendChild(tdTeam);
		var tdPrimary = document.createElement('th');
		tr.appendChild(tdPrimary);
		tdPrimary.innerHTML = L10n.Term('Teams.LBL_LIST_PRIMARY_TEAM');
		var tdEdit = document.createElement('th');
		tdEdit.align     = 'right';
		tdEdit.innerHTML = '&nbsp;';
		tr.appendChild(tdEdit);
		
		if ( bAllowDefaults && !Sql.IsEmptyString(Security.TEAM_ID()) && !Sql.IsEmptyString(Security.TEAM_NAME()) )
		{
			tr = document.createElement('tr');
			tbody.appendChild(tr);
			
			tdTeam = document.createElement('td');
			tr.appendChild(tdTeam);
			
			var txt = document.createTextNode(Security.TEAM_NAME());
			tdTeam.appendChild(txt);
			
			var hid = document.createElement('input');
			hid.id        = sLayoutPanel + '_ctlEditView_TEAM_SET_LIST';
			hid.name      = sLayoutPanel + '_ctlEditView_TEAM_SET_LIST';
			hid.type      = 'hidden';
			hid.value     = Security.TEAM_ID();
			tdTeam.appendChild(hid);
			
			tdPrimary = document.createElement('td');
			tdPrimary.align = 'center';
			tr.appendChild(tdPrimary);
			var chk = document.createElement('input');
			chk.id        = sLayoutPanel + '_ctlEditView_PRIMARY_TEAM';
			chk.name      = sLayoutPanel + '_ctlEditView_PRIMARY_TEAM';
			chk.type      = 'checkbox';
			chk.className = 'checkbox';
			chk.disabled  = 'disabled';
			// 04/08/2017 Paul.  Use Bootstrap for responsive design.
			if ( SplendidDynamic.BootstrapLayout() )
			{
				chk.style.transform = 'scale(1.5)';
				// 05/30/2018 Paul.  Disable new line after checkbox. 
				chk.style.display = 'inline';
			}
			tdPrimary.appendChild(chk);
			// 10/26/2011 Paul.  The checked flag must be set after adding. 
			chk.checked   = true;
			chk.value     = Security.TEAM_ID();
			
			tdEdit = document.createElement('td');
			tdEdit.align = 'right';
			tdEdit.style.whiteSpace = 'nowrap';
			tr.appendChild(tdEdit);
			// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
			if ( !SplendidDynamic.BootstrapLayout() )
			{
				var imgDelete = document.createElement('input');
				imgDelete.type   = 'image';
				// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
				imgDelete.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/delete_inline.gif';
				imgDelete.style.borderWidth = '0px';
				imgDelete.onclick = BindArguments(function(tr)
				{
					tr.parentNode.removeChild(tr);
				}, tr);
				tdEdit.appendChild(imgDelete);
			}
			else
			{
				var aDelete = document.createElement('a');
				aDelete.href= '#';
				tdEdit.appendChild(aDelete);
				aDelete.onclick = BindArguments(function(tr)
				{
					tr.parentNode.removeChild(tr);
				}, tr);
				var imgDelete = document.createElement('span');
				aDelete.appendChild(imgDelete);
				imgDelete.className           = 'glyphicon glyphicon-remove fa-2x';
				imgDelete.style.cursor        = 'pointer';
				imgDelete.title               = L10n.Term('.LNK_DELETE');
				imgDelete.style.padding       = '2px';
			}
		}
		if ( !Sql.IsEmptyString(sTEAM_SET_LIST) )
		{
			var arrTEAM_SET_LIST = sTEAM_SET_LIST.split(',');
			for ( var i = 0; i < arrTEAM_SET_LIST.length; i++ )
			{
				var sTEAM_ID = arrTEAM_SET_LIST[i];
				tr = document.createElement('tr');
				tbody.appendChild(tr);
				
				tdTeam = document.createElement('td');
				tr.appendChild(tdTeam);
				
				var txt = document.createTextNode(Crm.Teams.Name(sTEAM_ID));
				var hid = document.createElement('input');
				hid.id        = sLayoutPanel + '_ctlEditView_TEAM_SET_LIST';
				hid.name      = sLayoutPanel + '_ctlEditView_TEAM_SET_LIST';
				hid.type      = 'hidden';
				hid.value     = sTEAM_ID;
				tdTeam.appendChild(hid);
				tdTeam.appendChild(txt);
				
				tdPrimary = document.createElement('td');
				tdPrimary.align = 'center';
				tr.appendChild(tdPrimary);
				var chk = document.createElement('input');
				chk.id        = sLayoutPanel + '_ctlEditView_PRIMARY_TEAM';
				chk.name      = sLayoutPanel + '_ctlEditView_PRIMARY_TEAM';
				chk.type      = 'checkbox';
				chk.className = 'checkbox';
				chk.disabled  = 'disabled';
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				if ( SplendidDynamic.BootstrapLayout() )
				{
					chk.style.transform = 'scale(1.5)';
					// 05/30/2018 Paul.  Disable new line after checkbox. 
					chk.style.display = 'inline';
				}
				tdPrimary.appendChild(chk);
				// 10/26/2011 Paul.  The checked flag must be set after adding. 
				chk.checked   = (i == 0);
				chk.value     = sTEAM_ID;
				
				tdEdit = document.createElement('td');
				tdEdit.align = 'right';
				tdEdit.style.whiteSpace = 'nowrap';
				tr.appendChild(tdEdit);
				// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					var imgDelete = document.createElement('input');
					imgDelete.type   = 'image';
					// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
					imgDelete.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/delete_inline.gif';
					imgDelete.style.borderWidth = '0px';
					imgDelete.onclick = BindArguments(function(tr)
					{
						tr.parentNode.removeChild(tr);
					}, tr);
					tdEdit.appendChild(imgDelete);
				}
				else
				{
					var aDelete = document.createElement('a');
					aDelete.href= '#';
					tdEdit.appendChild(aDelete);
					aDelete.onclick = BindArguments(function(tr)
					{
						tr.parentNode.removeChild(tr);
					}, tr);
					var imgDelete = document.createElement('span');
					aDelete.appendChild(imgDelete);
					imgDelete.className           = 'glyphicon glyphicon-remove fa-2x';
					imgDelete.style.cursor        = 'pointer';
					imgDelete.title               = L10n.Term('.LNK_DELETE');
					imgDelete.style.padding       = '2px';
				}
			}
		}
		
		// 10/26/2011 Paul.  Adding teams will always be at the bottom.  We will not allow in-place editing. 
		tr = document.createElement('tr');
		tbody.appendChild(tr);
		
		tdTeam = document.createElement('td');
		tr.appendChild(tdTeam);
		
		var spnInputs = document.createElement('div');
		tdTeam.appendChild(spnInputs);
		
		var txt = document.createElement('input');
		txt.id        = sLayoutPanel + '_ctlEditView_TEAM_NAME';
		txt.type      = 'text';
		txt.className = 'form-control';
		txt.onkeypress = function(e)
		{
			// 04/16/2017 Paul.  Use blur event. 
			return RegisterEnterKeyPress(e, txt.onblur);
		};
		spnInputs.appendChild(txt);
		
		var hid = document.createElement('input');
		hid.id        = sLayoutPanel + '_ctlEditView_TEAM_ID';
		hid.type      = 'hidden';
		spnInputs.appendChild(hid);
		
		// 04/16/2017 Paul.  Use Bootstrap for responsive design.
		var fnChange = BindArguments(function(txt, hid, sMODULE_TYPE)
		{
			var $dialog = $('<div id="' + hid.id + '_divPopup"><div id="divPopupActionsPanel" /><div id="divPopupLayoutPanel" /></div>');
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
				, title    : L10n.Term('Teams.LBL_LIST_FORM_TITLE')
				, create   : function(event, ui)
				{
					try
					{
						var oPopupViewUI = new PopupViewUI();
						oPopupViewUI.Load('divPopupLayoutPanel', 'divPopupActionsPanel', 'Teams', false, function(status, message)
						{
							if ( status == 1 )
							{
								hid.value = message.ID  ;
								txt.value = message.NAME;
								// 02/21/2013 Paul.  Use close instead of destroy. 
								$dialog.dialog('close');
								
								var btnSubmit = document.getElementById(sLayoutPanel + '_ctlEditView_TEAM_NAME_btnInsert');
								btnSubmit.click();
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
					var divPopup = document.getElementById(hid.id + '_divPopup');
					divPopup.parentNode.removeChild(divPopup);
				}
			});
		}, txt, hid, 'Teams');

		// 04/16/2017 Paul.  Use glyphicon instead of regular icon. 
		var btnChange = null;
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			btnChange = document.createElement('input');
			spnInputs.appendChild(btnChange);
			btnChange.id        = sLayoutPanel + '_ctlEditView_TEAM_NAME_btnChange';
			btnChange.type      = 'button';
			btnChange.className = 'button';
			btnChange.title     = L10n.Term('.LBL_SELECT_BUTTON_TITLE');
			btnChange.value     = L10n.Term('.LBL_SELECT_BUTTON_LABEL');
			btnChange.style.marginLeft  = '4px';
			btnChange.style.marginRight = '2px';
			btnChange.onclick = fnChange;
		}
		else
		{
			spnInputs.className = 'input-group';
			var grp = document.createElement('span');
			grp.className = 'input-group-btn';
			spnInputs.appendChild(grp);
			
			btnChange = document.createElement('button');
			grp.appendChild(btnChange);
			btnChange.id        = sLayoutPanel + '_ctlEditView_TEAM_NAME_btnChange';
			btnChange.className = 'btn btn-default';
			btnChange.onclick   = fnChange;
			var glyph = document.createElement('span');
			glyph.className = 'glyphicon glyphicon-edit';
			btnChange.appendChild(glyph);
		}
		this.AutoComplete(sLayoutPanel, 'Teams', 'TEAM_NAME', 'TEAM_ID');
		txt.onblur = BindArguments(this.AutoCompleteBlur, sLayoutPanel, 'Teams', 'TEAM_NAME', 'TEAM_ID', 'TEAM_NAME_btnInsert');

		// 12/15/2014 Paul.  Use small button on mobile device. 
		// 04/16/2017 Paul.  We don't need mobile version now that we are using a small button. 
		/*
		var bIsMobile = isMobileDevice();
		if ( isMobileLandscape() )
			bIsMobile = false;
		if ( bIsMobile )
		{
			btnChange.style.display = 'none';
			var aChange = document.createElement('a');
			tdTeam.appendChild(aChange);
			var iChange = document.createElement('i');
			iChange.className = 'fa fa-2x fa-location-arrow navButton';
			aChange.style.verticalAlign = 'bottom';
			// 02/25/2016 Paul.  Use pointer cursor. 
			aChange.style.cursor        = 'pointer';
			aChange.appendChild(iChange);
			aChange.onclick = function()
			{
				btnChange.click();
			};
		}
		*/
		
		tdPrimary = document.createElement('td');
		tdPrimary.align = 'center';
		tr.appendChild(tdPrimary);
		var chk = document.createElement('input');
		chk.type      = 'checkbox';
		chk.className = 'checkbox';
		// 04/08/2017 Paul.  Use Bootstrap for responsive design.
		if ( SplendidDynamic.BootstrapLayout() )
		{
			chk.style.transform = 'scale(1.5)';
			// 05/30/2018 Paul.  Disable new line after checkbox. 
			chk.style.display = 'inline';
		}
		tdPrimary.appendChild(chk);
		chk.checked   = bAllowDefaults;
		
		tdEdit = document.createElement('td');
		tdEdit.align = 'right';
		tdEdit.style.whiteSpace = 'nowrap';
		tr.appendChild(tdEdit);
		// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
		var imgInsert = null;
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			imgInsert = document.createElement('input');
			imgInsert.id     = sLayoutPanel + '_ctlEditView_TEAM_NAME_btnInsert';
			imgInsert.type   = 'image';
			// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
			imgInsert.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/accept_inline.gif';
			imgInsert.style.borderWidth = '0px';
		}
		else
		{
			imgInsert = document.createElement('a');
			imgInsert.id     = sLayoutPanel + '_ctlEditView_TEAM_NAME_btnInsert';
			imgInsert.href   = '#';
			var spnInsert = document.createElement('span');
			imgInsert.appendChild(spnInsert);
			spnInsert.className     = 'glyphicon glyphicon-ok fa-2x';
			spnInsert.style.cursor  = 'pointer';
			spnInsert.title         = L10n.Term('.LBL_SUBMIT_BUTTON_LABEL');
			spnInsert.style.padding = '2px';
		}
		var thisEditView = this;
		imgInsert.onclick = BindArguments(function(tr, txt, hid, chk)
		{
			var sTEAM_ID   = hid.value;
			var sTEAM_NAME = txt.value;
			var bPRIMARY   = chk.checked;
			if ( !Sql.IsEmptyString(sTEAM_ID) )
			{
				var trNew = document.createElement('tr');
				tbody.insertBefore(trNew, tr);
				var tdNew = document.createElement('td');
				trNew.appendChild(tdNew);
				
				var txtNew = document.createTextNode(sTEAM_NAME);
				tdNew.appendChild(txtNew);
				var hidNew = document.createElement('input');
				hidNew.id    = sLayoutPanel + '_ctlEditView_TEAM_SET_LIST';
				hidNew.name  = sLayoutPanel + '_ctlEditView_TEAM_SET_LIST';
				hidNew.type  = 'hidden';
				hidNew.value = sTEAM_ID;
				tdNew.appendChild(hidNew);
				
				tdNew = document.createElement('td');
				tdNew.align = 'center';
				trNew.appendChild(tdNew);
				var chkNew = document.createElement('input');
				chkNew.id        = sLayoutPanel + '_ctlEditView_PRIMARY_TEAM';
				chkNew.name      = sLayoutPanel + '_ctlEditView_PRIMARY_TEAM';
				chkNew.type      = 'checkbox';
				chkNew.className = 'checkbox';
				chkNew.disabled  = 'disabled';
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				if ( SplendidDynamic.BootstrapLayout() )
					chkNew.style.transform = 'scale(1.5)';
				tdNew.appendChild(chkNew);
				// 10/26/2011 Paul.  The checked flag must be set after adding. 
				chkNew.checked   = bPRIMARY;
				chkNew.value     = sTEAM_ID;
				
				tdNew = document.createElement('td');
				trNew.appendChild(tdNew);
				tdNew.align = 'right';
				tdNew.style.whiteSpace = 'nowrap';
				// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					var imgDelete = document.createElement('input');
					imgDelete.type   = 'image';
					// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
					imgDelete.src    = sIMAGE_SERVER + 'App_Themes/' + thisEditView.ButtonTheme() + '/images/delete_inline.gif';
					imgDelete.style.borderWidth = '0px';
					imgDelete.onclick = BindArguments(function(trNew)
					{
						trNew.parentNode.removeChild(trNew);
					}, trNew);
					tdNew.appendChild(imgDelete);
				}
				else
				{
					var aDelete = document.createElement('a');
					aDelete.href = '#';
					tdNew.appendChild(aDelete);
					aDelete.onclick = BindArguments(function(trNew)
					{
						trNew.parentNode.removeChild(trNew);
					}, trNew);
					var imgDelete = document.createElement('span');
					aDelete.appendChild(imgDelete);
					imgDelete.className     = 'glyphicon glyphicon-remove fa-2x';
					imgDelete.style.cursor  = 'pointer';
					imgDelete.title         = L10n.Term('.LNK_DELETE');
					imgDelete.style.padding = '2px';
				}
				
				if ( bPRIMARY )
				{
					// 10/26/2011 Paul.  If setting this as primary, then clear all previous. 
					var arrPrimary = document.getElementsByName(sLayoutPanel + '_ctlEditView_PRIMARY_TEAM');
					for ( var i = 0; i < arrPrimary.length; i++ )
					{
						arrPrimary[i].checked = false;
					}
					chkNew.checked = bPRIMARY;
				}
			}
			hid.value = '';
			txt.value = '';
			chk.checked = false;
		}, tr, txt, hid, chk);
		tdEdit.appendChild(imgInsert);
		// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			var imgCancel = document.createElement('input');
			imgCancel.id     = sLayoutPanel + '_ctlEditView_TEAM_NAME_btnCancel';
			imgCancel.type   = 'image';
			// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
			imgCancel.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/decline_inline.gif';
			imgCancel.style.borderWidth = '0px';
			imgCancel.onclick = BindArguments(function(txt, hid)
			{
				hid.value = '';
				txt.value = '';
			}, txt, hid);
			tdEdit.appendChild(imgCancel);
		}
		else
		{
			var aCancel = document.createElement('a');
			aCancel.href = '#';
			aCancel.id   = sLayoutPanel + '_ctlEditView_TEAM_NAME_btnCancel';
			tdEdit.appendChild(aCancel);
			aCancel.onclick = BindArguments(function(txt, hid)
			{
				hid.value = '';
				txt.value = '';
			}, txt, hid);
			var imgCancel = document.createElement('span');
			aCancel.appendChild(imgCancel);
			imgCancel.className     = 'glyphicon glyphicon-remove fa-2x';
			imgCancel.style.cursor  = 'pointer';
			imgCancel.title         = L10n.Term('.LNK_DELETE');
			imgCancel.style.padding = '2px';
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'EditViewUI.LoadTeamSelect');
	}
}

// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
EditViewUI.prototype.LoadUserSelect = function(sLayoutPanel, tdField, sASSIGNED_SET_ID, sASSIGNED_SET_LIST, bUI_REQUIRED, bAllowDefaults)
{
	try
	{
		var ctlEditView_ASSIGNED_SET_NAME = document.createElement('table');
		var tbody = document.createElement('tbody');
		var tr    = document.createElement('tr');
		ctlEditView_ASSIGNED_SET_NAME.id          = sLayoutPanel + '_ctlEditView_ASSIGNED_SET_NAME';
		ctlEditView_ASSIGNED_SET_NAME.className   = 'listView';
		ctlEditView_ASSIGNED_SET_NAME.cellSpacing = 0;
		ctlEditView_ASSIGNED_SET_NAME.cellPadding = 2;
		ctlEditView_ASSIGNED_SET_NAME.border      = 1;
		ctlEditView_ASSIGNED_SET_NAME.style.borderCollapse = 'collapse';
		ctlEditView_ASSIGNED_SET_NAME.appendChild(tbody);
		tr.className = 'listViewThS1';
		tbody.appendChild(tr);
		tdField.appendChild(ctlEditView_ASSIGNED_SET_NAME);

		var tdUser = document.createElement('th');
		tdUser.innerHTML = '&nbsp;';
		tr.appendChild(tdUser);
		var tdPrimary = document.createElement('th');
		tr.appendChild(tdPrimary);
		tdPrimary.innerHTML = L10n.Term('Users.LBL_LIST_PRIMARY_USER');
		var tdEdit = document.createElement('th');
		tdEdit.align     = 'right';
		tdEdit.innerHTML = '&nbsp;';
		tr.appendChild(tdEdit);
		
		if ( bAllowDefaults && !Sql.IsEmptyString(Security.USER_ID()) && !Sql.IsEmptyString(Security.USER_NAME()) )
		{
			tr = document.createElement('tr');
			tbody.appendChild(tr);
			
			tdUser = document.createElement('td');
			tr.appendChild(tdUser);
			
			var txt = document.createTextNode(Security.USER_NAME());
			tdUser.appendChild(txt);
			
			var hid = document.createElement('input');
			hid.id        = sLayoutPanel + '_ctlEditView_ASSIGNED_SET_LIST';
			hid.name      = sLayoutPanel + '_ctlEditView_ASSIGNED_SET_LIST';
			hid.type      = 'hidden';
			hid.value     = Security.USER_ID();
			tdUser.appendChild(hid);
			
			tdPrimary = document.createElement('td');
			tdPrimary.align = 'center';
			tr.appendChild(tdPrimary);
			var chk = document.createElement('input');
			chk.id        = sLayoutPanel + '_ctlEditView_PRIMARY_USER';
			chk.name      = sLayoutPanel + '_ctlEditView_PRIMARY_USER';
			chk.type      = 'checkbox';
			chk.className = 'checkbox';
			chk.disabled  = 'disabled';
			// 04/08/2017 Paul.  Use Bootstrap for responsive design.
			if ( SplendidDynamic.BootstrapLayout() )
			{
				chk.style.transform = 'scale(1.5)';
				// 05/30/2018 Paul.  Disable new line after checkbox. 
				chk.style.display = 'inline';
			}
			tdPrimary.appendChild(chk);
			// 10/26/2011 Paul.  The checked flag must be set after adding. 
			chk.checked   = true;
			chk.value     = Security.USER_ID();
			
			tdEdit = document.createElement('td');
			tdEdit.align = 'right';
			tdEdit.style.whiteSpace = 'nowrap';
			tr.appendChild(tdEdit);
			// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
			if ( !SplendidDynamic.BootstrapLayout() )
			{
				var imgDelete = document.createElement('input');
				imgDelete.type   = 'image';
				// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
				imgDelete.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/delete_inline.gif';
				imgDelete.style.borderWidth = '0px';
				imgDelete.onclick = BindArguments(function(tr)
				{
					tr.parentNode.removeChild(tr);
				}, tr);
				tdEdit.appendChild(imgDelete);
			}
			else
			{
				var aDelete = document.createElement('a');
				aDelete.href= '#';
				tdEdit.appendChild(aDelete);
				aDelete.onclick = BindArguments(function(tr)
				{
					tr.parentNode.removeChild(tr);
				}, tr);
				var imgDelete = document.createElement('span');
				aDelete.appendChild(imgDelete);
				imgDelete.className           = 'glyphicon glyphicon-remove fa-2x';
				imgDelete.style.cursor        = 'pointer';
				imgDelete.title               = L10n.Term('.LNK_DELETE');
				imgDelete.style.padding       = '2px';
			}
		}
		if ( !Sql.IsEmptyString(sASSIGNED_SET_LIST) )
		{
			var arrASSIGNED_SET_LIST = sASSIGNED_SET_LIST.split(',');
			for ( var i = 0; i < arrASSIGNED_SET_LIST.length; i++ )
			{
				var sASSIGNED_USER_ID = arrASSIGNED_SET_LIST[i];
				tr = document.createElement('tr');
				tbody.appendChild(tr);
				
				tdUser = document.createElement('td');
				tr.appendChild(tdUser);
				
				var sASSIGNED_USER_NAME = Crm.Users.Name(sASSIGNED_USER_ID);
				var txt = document.createTextNode(sASSIGNED_USER_NAME);
				var hid = document.createElement('input');
				hid.id        = sLayoutPanel + '_ctlEditView_ASSIGNED_SET_LIST';
				hid.name      = sLayoutPanel + '_ctlEditView_ASSIGNED_SET_LIST';
				hid.type      = 'hidden';
				hid.value     = sASSIGNED_USER_ID;
				tdUser.appendChild(hid);
				tdUser.appendChild(txt);
				
				tdPrimary = document.createElement('td');
				tdPrimary.align = 'center';
				tr.appendChild(tdPrimary);
				var chk = document.createElement('input');
				chk.id        = sLayoutPanel + '_ctlEditView_PRIMARY_USER';
				chk.name      = sLayoutPanel + '_ctlEditView_PRIMARY_USER';
				chk.type      = 'checkbox';
				chk.className = 'checkbox';
				chk.disabled  = 'disabled';
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				if ( SplendidDynamic.BootstrapLayout() )
				{
					chk.style.transform = 'scale(1.5)';
					// 05/30/2018 Paul.  Disable new line after checkbox. 
					chk.style.display = 'inline';
				}
				tdPrimary.appendChild(chk);
				// 10/26/2011 Paul.  The checked flag must be set after adding. 
				chk.checked   = (i == 0);
				chk.value     = sASSIGNED_USER_ID;
				
				tdEdit = document.createElement('td');
				tdEdit.align = 'right';
				tdEdit.style.whiteSpace = 'nowrap';
				tr.appendChild(tdEdit);
				// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					var imgDelete = document.createElement('input');
					imgDelete.type   = 'image';
					// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
					imgDelete.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/delete_inline.gif';
					imgDelete.style.borderWidth = '0px';
					imgDelete.onclick = BindArguments(function(tr)
					{
						tr.parentNode.removeChild(tr);
					}, tr);
					tdEdit.appendChild(imgDelete);
				}
				else
				{
					var aDelete = document.createElement('a');
					aDelete.href= '#';
					tdEdit.appendChild(aDelete);
					aDelete.onclick = BindArguments(function(tr)
					{
						tr.parentNode.removeChild(tr);
					}, tr);
					var imgDelete = document.createElement('span');
					aDelete.appendChild(imgDelete);
					imgDelete.className           = 'glyphicon glyphicon-remove fa-2x';
					imgDelete.style.cursor        = 'pointer';
					imgDelete.title               = L10n.Term('.LNK_DELETE');
					imgDelete.style.padding       = '2px';
				}
			}
		}
		
		// 10/26/2011 Paul.  Adding teams will always be at the bottom.  We will not allow in-place editing. 
		tr = document.createElement('tr');
		tbody.appendChild(tr);
		
		tdUser = document.createElement('td');
		tr.appendChild(tdUser);
		
		var spnInputs = document.createElement('div');
		tdUser.appendChild(spnInputs);
		
		var txt = document.createElement('input');
		txt.id        = sLayoutPanel + '_ctlEditView_ASSIGNED_TO';
		txt.type      = 'text';
		txt.className = 'form-control';
		txt.onkeypress = function(e)
		{
			// 04/16/2017 Paul.  Use blur event. 
			return RegisterEnterKeyPress(e, txt.onblur);
		};
		spnInputs.appendChild(txt);
		
		var hid = document.createElement('input');
		hid.id        = sLayoutPanel + '_ctlEditView_ASSIGNED_USER_ID';
		hid.type      = 'hidden';
		spnInputs.appendChild(hid);
		
		// 04/16/2017 Paul.  Use Bootstrap for responsive design.
		var fnChange = BindArguments(function(txt, hid, sMODULE_TYPE)
		{
			var $dialog = $('<div id="' + hid.id + '_divPopup"><div id="divPopupActionsPanel" /><div id="divPopupLayoutPanel" /></div>');
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
				, title    : L10n.Term('Users.LBL_LIST_FORM_TITLE')
				, create   : function(event, ui)
				{
					try
					{
						var oPopupViewUI = new PopupViewUI();
						oPopupViewUI.Load('divPopupLayoutPanel', 'divPopupActionsPanel', 'Users', false, function(status, message)
						{
							if ( status == 1 )
							{
								hid.value = message.ID  ;
								txt.value = message.NAME;
								// 02/21/2013 Paul.  Use close instead of destroy. 
								$dialog.dialog('close');
								
								var btnSubmit = document.getElementById(sLayoutPanel + '_ctlEditView_ASSIGNED_TO_btnInsert');
								btnSubmit.click();
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
					var divPopup = document.getElementById(hid.id + '_divPopup');
					divPopup.parentNode.removeChild(divPopup);
				}
			});
		}, txt, hid, 'Users');

		// 04/16/2017 Paul.  Use glyphicon instead of regular icon. 
		var btnChange = null;
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			btnChange = document.createElement('input');
			spnInputs.appendChild(btnChange);
			btnChange.id        = sLayoutPanel + '_ctlEditView_ASSIGNED_TO_btnChange';
			btnChange.type      = 'button';
			btnChange.className = 'button';
			btnChange.title     = L10n.Term('.LBL_SELECT_BUTTON_TITLE');
			btnChange.value     = L10n.Term('.LBL_SELECT_BUTTON_LABEL');
			btnChange.style.marginLeft  = '4px';
			btnChange.style.marginRight = '2px';
			btnChange.onclick = fnChange;
		}
		else
		{
			spnInputs.className = 'input-group';
			var grp = document.createElement('span');
			grp.className = 'input-group-btn';
			spnInputs.appendChild(grp);
			
			btnChange = document.createElement('button');
			grp.appendChild(btnChange);
			btnChange.id        = sLayoutPanel + '_ctlEditView_ASSIGNED_TO_btnChange';
			btnChange.className = 'btn btn-default';
			btnChange.onclick   = fnChange;
			var glyph = document.createElement('span');
			glyph.className = 'glyphicon glyphicon-edit';
			btnChange.appendChild(glyph);
		}
		this.AutoComplete(sLayoutPanel, 'Users', 'ASSIGNED_TO', 'ASSIGNED_USER_ID');
		txt.onblur = BindArguments(this.AutoCompleteBlur, sLayoutPanel, 'Users', 'ASSIGNED_TO', 'ASSIGNED_USER_ID', 'ASSIGNED_TO_btnInsert');

		// 12/15/2014 Paul.  Use small button on mobile device. 
		// 04/16/2017 Paul.  We don't need mobile version now that we are using a small button. 
		/*
		var bIsMobile = isMobileDevice();
		if ( isMobileLandscape() )
			bIsMobile = false;
		if ( bIsMobile )
		{
			btnChange.style.display = 'none';
			var aChange = document.createElement('a');
			tdUser.appendChild(aChange);
			var iChange = document.createElement('i');
			iChange.className = 'fa fa-2x fa-location-arrow navButton';
			aChange.style.verticalAlign = 'bottom';
			// 02/25/2016 Paul.  Use pointer cursor. 
			aChange.style.cursor        = 'pointer';
			aChange.appendChild(iChange);
			aChange.onclick = function()
			{
				btnChange.click();
			};
		}
		*/
		
		tdPrimary = document.createElement('td');
		tdPrimary.align = 'center';
		tr.appendChild(tdPrimary);
		var chk = document.createElement('input');
		chk.type      = 'checkbox';
		chk.className = 'checkbox';
		// 04/08/2017 Paul.  Use Bootstrap for responsive design.
		if ( SplendidDynamic.BootstrapLayout() )
		{
			chk.style.transform = 'scale(1.5)';
			// 05/30/2018 Paul.  Disable new line after checkbox. 
			chk.style.display = 'inline';
		}
		tdPrimary.appendChild(chk);
		chk.checked   = bAllowDefaults;
		
		tdEdit = document.createElement('td');
		tdEdit.align = 'right';
		tdEdit.style.whiteSpace = 'nowrap';
		tr.appendChild(tdEdit);
		// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
		var imgInsert = null;
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			imgInsert = document.createElement('input');
			imgInsert.id     = sLayoutPanel + '_ctlEditView_ASSIGNED_TO_btnInsert';
			imgInsert.type   = 'image';
			// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
			imgInsert.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/accept_inline.gif';
			imgInsert.style.borderWidth = '0px';
		}
		else
		{
			imgInsert = document.createElement('a');
			imgInsert.id     = sLayoutPanel + '_ctlEditView_ASSIGNED_TO_btnInsert';
			imgInsert.href   = '#';
			var spnInsert = document.createElement('span');
			imgInsert.appendChild(spnInsert);
			spnInsert.className     = 'glyphicon glyphicon-ok fa-2x';
			spnInsert.style.cursor  = 'pointer';
			spnInsert.title         = L10n.Term('.LBL_SUBMIT_BUTTON_LABEL');
			spnInsert.style.padding = '2px';
		}
		var thisEditView = this;
		imgInsert.onclick = BindArguments(function(tr, txt, hid, chk)
		{
			var sASSIGNED_USER_ID   = hid.value;
			var sASSIGNED_TO_NAME = txt.value;
			var bPRIMARY   = chk.checked;
			if ( !Sql.IsEmptyString(sASSIGNED_USER_ID) )
			{
				var trNew = document.createElement('tr');
				tbody.insertBefore(trNew, tr);
				var tdNew = document.createElement('td');
				trNew.appendChild(tdNew);
				
				var txtNew = document.createTextNode(sASSIGNED_TO_NAME);
				tdNew.appendChild(txtNew);
				var hidNew = document.createElement('input');
				hidNew.id    = sLayoutPanel + '_ctlEditView_ASSIGNED_SET_LIST';
				hidNew.name  = sLayoutPanel + '_ctlEditView_ASSIGNED_SET_LIST';
				hidNew.type  = 'hidden';
				hidNew.value = sASSIGNED_USER_ID;
				tdNew.appendChild(hidNew);
				
				tdNew = document.createElement('td');
				tdNew.align = 'center';
				trNew.appendChild(tdNew);
				var chkNew = document.createElement('input');
				chkNew.id        = sLayoutPanel + '_ctlEditView_PRIMARY_USER';
				chkNew.name      = sLayoutPanel + '_ctlEditView_PRIMARY_USER';
				chkNew.type      = 'checkbox';
				chkNew.className = 'checkbox';
				chkNew.disabled  = 'disabled';
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				if ( SplendidDynamic.BootstrapLayout() )
					chkNew.style.transform = 'scale(1.5)';
				tdNew.appendChild(chkNew);
				// 10/26/2011 Paul.  The checked flag must be set after adding. 
				chkNew.checked   = bPRIMARY;
				chkNew.value     = sASSIGNED_USER_ID;
				
				tdNew = document.createElement('td');
				trNew.appendChild(tdNew);
				tdNew.align = 'right';
				tdNew.style.whiteSpace = 'nowrap';
				// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					var imgDelete = document.createElement('input');
					imgDelete.type   = 'image';
					// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
					imgDelete.src    = sIMAGE_SERVER + 'App_Themes/' + thisEditView.ButtonTheme() + '/images/delete_inline.gif';
					imgDelete.style.borderWidth = '0px';
					imgDelete.onclick = BindArguments(function(trNew)
					{
						trNew.parentNode.removeChild(trNew);
					}, trNew);
					tdNew.appendChild(imgDelete);
				}
				else
				{
					var aDelete = document.createElement('a');
					aDelete.href = '#';
					tdNew.appendChild(aDelete);
					aDelete.onclick = BindArguments(function(trNew)
					{
						trNew.parentNode.removeChild(trNew);
					}, trNew);
					var imgDelete = document.createElement('span');
					aDelete.appendChild(imgDelete);
					imgDelete.className     = 'glyphicon glyphicon-remove fa-2x';
					imgDelete.style.cursor  = 'pointer';
					imgDelete.title         = L10n.Term('.LNK_DELETE');
					imgDelete.style.padding = '2px';
				}
				
				if ( bPRIMARY )
				{
					// 10/26/2011 Paul.  If setting this as primary, then clear all previous. 
					var arrPrimary = document.getElementsByName(sLayoutPanel + '_ctlEditView_PRIMARY_USER');
					for ( var i = 0; i < arrPrimary.length; i++ )
					{
						arrPrimary[i].checked = false;
					}
					chkNew.checked = bPRIMARY;
				}
			}
			hid.value = '';
			txt.value = '';
			chk.checked = false;
		}, tr, txt, hid, chk);
		tdEdit.appendChild(imgInsert);
		// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			var imgCancel = document.createElement('input');
			imgCancel.id     = sLayoutPanel + '_ctlEditView_ASSIGNED_TO_btnCancel';
			imgCancel.type   = 'image';
			// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
			imgCancel.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/decline_inline.gif';
			imgCancel.style.borderWidth = '0px';
			imgCancel.onclick = BindArguments(function(txt, hid)
			{
				hid.value = '';
				txt.value = '';
			}, txt, hid);
			tdEdit.appendChild(imgCancel);
		}
		else
		{
			var aCancel = document.createElement('a');
			aCancel.href = '#';
			aCancel.id   = sLayoutPanel + '_ctlEditView_ASSIGNED_TO_btnCancel';
			tdEdit.appendChild(aCancel);
			aCancel.onclick = BindArguments(function(txt, hid)
			{
				hid.value = '';
				txt.value = '';
			}, txt, hid);
			var imgCancel = document.createElement('span');
			aCancel.appendChild(imgCancel);
			imgCancel.className     = 'glyphicon glyphicon-remove fa-2x';
			imgCancel.style.cursor  = 'pointer';
			imgCancel.title         = L10n.Term('.LNK_DELETE');
			imgCancel.style.padding = '2px';
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'EditViewUI.LoadUserSelect');
	}
}

EditViewUI.prototype.LoadTagSelect = function(sLayoutPanel, tdField, sTAG_SET_NAME, bUI_REQUIRED)
{
	try
	{
		var ctlEditView_TAG_SET_LIST = document.createElement('table');
		var tbody = document.createElement('tbody');
		var tr    = document.createElement('tr');
		ctlEditView_TAG_SET_LIST.id          = sLayoutPanel + '_ctlEditView_TAG_SET_LIST';
		ctlEditView_TAG_SET_LIST.className   = 'listView';
		ctlEditView_TAG_SET_LIST.cellSpacing = 0;
		ctlEditView_TAG_SET_LIST.cellPadding = 2;
		ctlEditView_TAG_SET_LIST.border      = 1;
		ctlEditView_TAG_SET_LIST.style.borderCollapse = 'collapse';
		ctlEditView_TAG_SET_LIST.appendChild(tbody);
		tr.className = 'listViewThS1';
		tbody.appendChild(tr);
		tdField.appendChild(ctlEditView_TAG_SET_LIST);

		var tdTag = document.createElement('th');
		tdTag.innerHTML = '&nbsp;';
		tr.appendChild(tdTag);
		var tdEdit = document.createElement('th');
		tdEdit.align     = 'right';
		tdEdit.innerHTML = '&nbsp;';
		tr.appendChild(tdEdit);
		
		if ( !Sql.IsEmptyString(sTAG_SET_NAME) )
		{
			var arrTAG_SET_NAME = sTAG_SET_NAME.split(',');
			for ( var i = 0; i < arrTAG_SET_NAME.length; i++ )
			{
				var sTAG_NAME = arrTAG_SET_NAME[i];
				tr = document.createElement('tr');
				tbody.appendChild(tr);
				
				tdTag = document.createElement('td');
				tr.appendChild(tdTag);
				
				var hid = document.createElement('input');
				hid.name  = sLayoutPanel + '_ctlEditView_TAG_SET_NAME';
				hid.type  = 'hidden';
				hid.value = sTAG_NAME;
				tdTag.appendChild(hid);
				
				var txt = document.createTextNode(sTAG_NAME);
				tdTag.appendChild(txt);
				
				tdEdit = document.createElement('td');
				tdEdit.align = 'right';
				tdEdit.style.whiteSpace = 'nowrap';
				tr.appendChild(tdEdit);
				// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					var imgDelete = document.createElement('input');
					imgDelete.type   = 'image';
					// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
					imgDelete.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/delete_inline.gif';
					imgDelete.style.borderWidth = '0px';
					imgDelete.onclick = BindArguments(function(tr)
					{
						tr.parentNode.removeChild(tr);
					}, tr);
					tdEdit.appendChild(imgDelete);
				}
				else
				{
					var aDelete = document.createElement('a');
					aDelete.href = '#';
					tdEdit.appendChild(aDelete);
					aDelete.onclick = BindArguments(function(tr)
					{
						tr.parentNode.removeChild(tr);
					}, tr);
					var imgDelete = document.createElement('span');
					aDelete.appendChild(imgDelete);
					imgDelete.className           = 'glyphicon glyphicon-remove fa-2x';
					imgDelete.style.cursor        = 'pointer';
					imgDelete.title               = L10n.Term('.LNK_DELETE');
					imgDelete.style.padding       = '2px';
				}
			}
		}
		
		// 10/26/2011 Paul.  Adding teams will always be at the bottom.  We will not allow in-place editing. 
		tr = document.createElement('tr');
		tbody.appendChild(tr);
		
		tdTag = document.createElement('td');
		tr.appendChild(tdTag);
		
		var spnInputs = document.createElement('div');
		tdTag.appendChild(spnInputs);
		
		var txt = document.createElement('input');
		txt.id        = sLayoutPanel + '_ctlEditView_TAG_NAME';
		txt.type      = 'text';
		txt.className = 'form-control';
		txt.onkeypress = function(e)
		{
			// 04/16/2017 Paul.  Use blur event. 
			return RegisterEnterKeyPress(e, txt.onblur);
		};
		spnInputs.appendChild(txt);
		
		// 04/16/2017 Paul.  Use Bootstrap for responsive design.
		var fnChange = BindArguments(function(txt, sMODULE_TYPE)
		{
			var $dialog = $('<div id="TagSelect_divPopup"><div id="divPopupActionsPanel" /><div id="divPopupLayoutPanel" /></div>');
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
				, title    : L10n.Term('Tags.LBL_LIST_FORM_TITLE')
				, create   : function(event, ui)
				{
					try
					{
						var oPopupViewUI = new PopupViewUI();
						oPopupViewUI.Load('divPopupLayoutPanel', 'divPopupActionsPanel', 'Tags', false, function(status, message)
						{
							if ( status == 1 )
							{
								txt.value = message.NAME;
								// 02/21/2013 Paul.  Use close instead of destroy. 
								$dialog.dialog('close');
								
								var btnSubmit = document.getElementById(sLayoutPanel + '_ctlEditView_TAG_NAME_btnInsert');
								btnSubmit.click();
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
					var divPopup = document.getElementById('TagSelect_divPopup');
					divPopup.parentNode.removeChild(divPopup);
				}
			});
		}, txt, 'Tags');

		// 04/16/2017 Paul.  Use glyphicon instead of regular icon. 
		var btnChange = null;
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			btnChange = document.createElement('input');
			btnChange.id        = sLayoutPanel + '_ctlEditView_TAG_NAME_btnChange';
			btnChange.type      = 'button';
			btnChange.className = 'button';
			btnChange.title     = L10n.Term('.LBL_SELECT_BUTTON_TITLE');
			btnChange.value     = L10n.Term('.LBL_SELECT_BUTTON_LABEL');
			btnChange.style.marginLeft  = '4px';
			btnChange.style.marginRight = '2px';
			btnChange.onclick = fnChange;
			spnInputs.appendChild(btnChange);
		}
		else
		{
			spnInputs.className = 'input-group';
			var grp = document.createElement('span');
			grp.className = 'input-group-btn';
			spnInputs.appendChild(grp);
			
			btnChange = document.createElement('button');
			grp.appendChild(btnChange);
			btnChange.id        = sLayoutPanel + '_ctlEditView_TAG_NAME_btnChange';
			btnChange.className = 'btn btn-default';
			btnChange.onclick   = fnChange;
			var glyph = document.createElement('span');
			glyph.className = 'glyphicon glyphicon-edit';
			btnChange.appendChild(glyph);
		}
		this.AutoComplete(sLayoutPanel, 'Tags', 'TAG_NAME', 'TAG_ID');
		txt.onblur = BindArguments(this.AutoCompleteBlur, sLayoutPanel, 'Tags', 'TAG_NAME', 'TAG_ID', 'TAG_NAME_btnInsert');

		// 12/15/2014 Paul.  Use small button on mobile device. 
		// 04/16/2017 Paul.  We don't need mobile version now that we are using a small button. 
		/*
		var bIsMobile = isMobileDevice();
		if ( isMobileLandscape() )
			bIsMobile = false;
		if ( bIsMobile )
		{
			btnChange.style.display = 'none';
			var aChange = document.createElement('a');
			tdTag.appendChild(aChange);
			var iChange = document.createElement('i');
			iChange.className = 'fa fa-2x fa-location-arrow navButton';
			aChange.style.verticalAlign = 'bottom';
			// 02/25/2016 Paul.  Use pointer cursor. 
			aChange.style.cursor        = 'pointer';
			aChange.appendChild(iChange);
			aChange.onclick = function()
			{
				btnChange.click();
			};
		}
		*/
		
		tdEdit = document.createElement('td');
		tdEdit.align = 'right';
		tdEdit.style.whiteSpace = 'nowrap';
		tr.appendChild(tdEdit);
		// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
		var imgInsert = null;
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			imgInsert = document.createElement('input');
			imgInsert.id     = sLayoutPanel + '_ctlEditView_TAG_NAME_btnInsert';
			imgInsert.type   = 'image';
			// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
			imgInsert.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/accept_inline.gif';
			imgInsert.style.borderWidth = '0px';
		}
		else
		{
			imgInsert = document.createElement('a');
			imgInsert.id     = sLayoutPanel + '_ctlEditView_TAG_NAME_btnInsert';
			imgInsert.href   = '#';
			var spnInsert = document.createElement('span');
			imgInsert.appendChild(spnInsert);
			spnInsert.className     = 'glyphicon glyphicon-ok fa-2x';
			spnInsert.style.cursor  = 'pointer';
			spnInsert.title         = L10n.Term('.LBL_SUBMIT_BUTTON_LABEL');
			spnInsert.style.padding = '2px';
		}
		var thisEditView = this;
		imgInsert.onclick = BindArguments(function(tr, txt)
		{
			var sTAG_NAME = txt.value;
			if ( !Sql.IsEmptyString(sTAG_NAME) )
			{
				var trNew = document.createElement('tr');
				tbody.insertBefore(trNew, tr);
				var tdNew = document.createElement('td');
				trNew.appendChild(tdNew);
				
				var hidNew = document.createElement('input');
				hidNew.name  = sLayoutPanel + '_ctlEditView_TAG_SET_NAME';
				hidNew.type  = 'hidden';
				hidNew.value = sTAG_NAME;
				tdNew.appendChild(hidNew);
				
				var txtNew = document.createTextNode(sTAG_NAME);
				tdNew.appendChild(txtNew);
				
				tdNew = document.createElement('td');
				trNew.appendChild(tdNew);
				tdNew.align = 'right';
				tdNew.style.whiteSpace = 'nowrap';
				// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					var imgDelete = document.createElement('input');
					imgDelete.type   = 'image';
					// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
					imgDelete.src    = sIMAGE_SERVER + 'App_Themes/' + thisEditView.ButtonTheme() + '/images/delete_inline.gif';
					imgDelete.style.borderWidth = '0px';
					imgDelete.onclick = BindArguments(function(trNew)
					{
						trNew.parentNode.removeChild(trNew);
					}, trNew);
					tdNew.appendChild(imgDelete);
				}
				else
				{
					var aDelete = document.createElement('a');
					aDelete.href = '#';
					tdNew.appendChild(aDelete);
					var imgDelete = document.createElement('span');
					aDelete.appendChild(imgDelete);
					aDelete.onclick = BindArguments(function(trNew)
					{
						trNew.parentNode.removeChild(trNew);
					}, trNew);
					imgDelete.className     = 'glyphicon glyphicon-remove fa-2x';
					imgDelete.style.cursor  = 'pointer';
					imgDelete.title         = L10n.Term('.LNK_DELETE');
					imgDelete.style.padding = '2px';
				}
			}
			txt.value = '';
		}, tr, txt);
		tdEdit.appendChild(imgInsert);
		// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			var imgCancel = document.createElement('input');
			imgCancel.id     = sLayoutPanel + '_ctlEditView_TAG_NAME_btnCancel';
			imgCancel.type   = 'image';
			// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
			imgCancel.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/decline_inline.gif';
			imgCancel.style.borderWidth = '0px';
			imgCancel.onclick = BindArguments(function(txt)
			{
				txt.value = '';
			}, txt);
			tdEdit.appendChild(imgCancel);
		}
		else
		{
			var aCancel = document.createElement('a');
			aCancel.href = '#';
			aCancel.id   = sLayoutPanel + '_ctlEditView_TAG_NAME_btnCancel';
			tdEdit.appendChild(aCancel);
			aCancel.onclick = BindArguments(function(txt)
			{
				txt.value = '';
			}, txt);
			var imgCancel = document.createElement('span');
			aCancel.appendChild(imgCancel);
			imgCancel.className     = 'glyphicon glyphicon-remove fa-2x';
			imgCancel.style.cursor  = 'pointer';
			imgCancel.title         = L10n.Term('.LNK_DELETE');
			imgCancel.style.padding = '2px';
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'EditViewUI.LoadTagSelect');
	}
}

// 06/07/2017 Paul.  Add NAICSCodes module. 
EditViewUI.prototype.LoadNaicsSelect = function(sLayoutPanel, tdField, sNAICS_SET_NAME, bUI_REQUIRED)
{
	try
	{
		var ctlEditView_NAICS_SET_LIST = document.createElement('table');
		var tbody = document.createElement('tbody');
		var tr    = document.createElement('tr');
		ctlEditView_NAICS_SET_LIST.id          = sLayoutPanel + '_ctlEditView_NAICS_SET_LIST';
		ctlEditView_NAICS_SET_LIST.className   = 'listView';
		ctlEditView_NAICS_SET_LIST.cellSpacing = 0;
		ctlEditView_NAICS_SET_LIST.cellPadding = 2;
		ctlEditView_NAICS_SET_LIST.border      = 1;
		ctlEditView_NAICS_SET_LIST.style.borderCollapse = 'collapse';
		ctlEditView_NAICS_SET_LIST.appendChild(tbody);
		tr.className = 'listViewThS1';
		tbody.appendChild(tr);
		tdField.appendChild(ctlEditView_NAICS_SET_LIST);

		var tdNaics = document.createElement('th');
		tdNaics.innerHTML = '&nbsp;';
		tr.appendChild(tdNaics);
		var tdEdit = document.createElement('th');
		tdEdit.align     = 'right';
		tdEdit.innerHTML = '&nbsp;';
		tr.appendChild(tdEdit);
		
		if ( !Sql.IsEmptyString(sNAICS_SET_NAME) )
		{
			var arrNAICS_SET_NAME = sNAICS_SET_NAME.split(',');
			for ( var i = 0; i < arrNAICS_SET_NAME.length; i++ )
			{
				var sNAICS_CODE_NAME = arrNAICS_SET_NAME[i];
				tr = document.createElement('tr');
				tbody.appendChild(tr);
				
				tdNaics = document.createElement('td');
				tr.appendChild(tdNaics);
				
				var hid = document.createElement('input');
				hid.name  = sLayoutPanel + '_ctlEditView_NAICS_SET_NAME';
				hid.type  = 'hidden';
				hid.value = sNAICS_CODE_NAME;
				tdNaics.appendChild(hid);
				
				var txt = document.createTextNode(sNAICS_CODE_NAME);
				tdNaics.appendChild(txt);
				
				tdEdit = document.createElement('td');
				tdEdit.align = 'right';
				tdEdit.style.whiteSpace = 'nowrap';
				tr.appendChild(tdEdit);
				// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					var imgDelete = document.createElement('input');
					imgDelete.type   = 'image';
					// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
					imgDelete.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/delete_inline.gif';
					imgDelete.style.borderWidth = '0px';
					imgDelete.onclick = BindArguments(function(tr)
					{
						tr.parentNode.removeChild(tr);
					}, tr);
					tdEdit.appendChild(imgDelete);
				}
				else
				{
					var aDelete = document.createElement('a');
					aDelete.href = '#';
					tdEdit.appendChild(aDelete);
					aDelete.onclick = BindArguments(function(tr)
					{
						tr.parentNode.removeChild(tr);
					}, tr);
					var imgDelete = document.createElement('span');
					aDelete.appendChild(imgDelete);
					imgDelete.className           = 'glyphicon glyphicon-remove fa-2x';
					imgDelete.style.cursor        = 'pointer';
					imgDelete.title               = L10n.Term('.LNK_DELETE');
					imgDelete.style.padding       = '2px';
				}
			}
		}
		
		// 10/26/2011 Paul.  Adding teams will always be at the bottom.  We will not allow in-place editing. 
		tr = document.createElement('tr');
		tbody.appendChild(tr);
		
		tdNaics = document.createElement('td');
		tr.appendChild(tdNaics);
		
		var spnInputs = document.createElement('div');
		tdNaics.appendChild(spnInputs);
		
		var txt = document.createElement('input');
		txt.id        = sLayoutPanel + '_ctlEditView_NAICS_CODE_NAME';
		txt.type      = 'text';
		txt.className = 'form-control';
		txt.onkeypress = function(e)
		{
			// 04/16/2017 Paul.  Use blur event. 
			return RegisterEnterKeyPress(e, txt.onblur);
		};
		spnInputs.appendChild(txt);
		
		// 04/16/2017 Paul.  Use Bootstrap for responsive design.
		var fnChange = BindArguments(function(txt, sMODULE_TYPE)
		{
			var $dialog = $('<div id="NaicsSelect_divPopup"><div id="divPopupActionsPanel" /><div id="divPopupLayoutPanel" /></div>');
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
				, title    : L10n.Term('NAICSCodes.LBL_LIST_FORM_TITLE')
				, create   : function(event, ui)
				{
					try
					{
						var oPopupViewUI = new PopupViewUI();
						oPopupViewUI.Load('divPopupLayoutPanel', 'divPopupActionsPanel', 'NAICSCodes', false, function(status, message)
						{
							if ( status == 1 )
							{
								txt.value = message.NAME;
								// 02/21/2013 Paul.  Use close instead of destroy. 
								$dialog.dialog('close');
								
								var btnSubmit = document.getElementById(sLayoutPanel + '_ctlEditView_NAICS_CODE_NAME_btnInsert');
								btnSubmit.click();
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
					var divPopup = document.getElementById('NaicsSelect_divPopup');
					divPopup.parentNode.removeChild(divPopup);
				}
			});
		}, txt, 'NAICSCodes');

		// 04/16/2017 Paul.  Use glyphicon instead of regular icon. 
		var btnChange = null;
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			btnChange = document.createElement('input');
			btnChange.id        = sLayoutPanel + '_ctlEditView_NAICS_CODE_NAME_btnChange';
			btnChange.type      = 'button';
			btnChange.className = 'button';
			btnChange.title     = L10n.Term('.LBL_SELECT_BUTTON_TITLE');
			btnChange.value     = L10n.Term('.LBL_SELECT_BUTTON_LABEL');
			btnChange.style.marginLeft  = '4px';
			btnChange.style.marginRight = '2px';
			btnChange.onclick = fnChange;
			spnInputs.appendChild(btnChange);
		}
		else
		{
			spnInputs.className = 'input-group';
			var grp = document.createElement('span');
			grp.className = 'input-group-btn';
			spnInputs.appendChild(grp);
			
			btnChange = document.createElement('button');
			grp.appendChild(btnChange);
			btnChange.id        = sLayoutPanel + '_ctlEditView_NAICS_CODE_NAME_btnChange';
			btnChange.className = 'btn btn-default';
			btnChange.onclick   = fnChange;
			var glyph = document.createElement('span');
			glyph.className = 'glyphicon glyphicon-edit';
			btnChange.appendChild(glyph);
		}
		this.AutoComplete(sLayoutPanel, 'NAICSCodes', 'NAICS_CODE_NAME', 'NAICS_CODE_ID');
		txt.onblur = BindArguments(this.AutoCompleteBlur, sLayoutPanel, 'NAICSCodes', 'NAICS_CODE_NAME', 'NAICS_CODE_ID', 'NAICS_CODE_NAME_btnInsert');

		// 12/15/2014 Paul.  Use small button on mobile device. 
		// 04/16/2017 Paul.  We don't need mobile version now that we are using a small button. 
		/*
		var bIsMobile = isMobileDevice();
		if ( isMobileLandscape() )
			bIsMobile = false;
		if ( bIsMobile )
		{
			btnChange.style.display = 'none';
			var aChange = document.createElement('a');
			tdNaics.appendChild(aChange);
			var iChange = document.createElement('i');
			iChange.className = 'fa fa-2x fa-location-arrow navButton';
			aChange.style.verticalAlign = 'bottom';
			// 02/25/2016 Paul.  Use pointer cursor. 
			aChange.style.cursor        = 'pointer';
			aChange.appendChild(iChange);
			aChange.onclick = function()
			{
				btnChange.click();
			};
		}
		*/
		
		tdEdit = document.createElement('td');
		tdEdit.align = 'right';
		tdEdit.style.whiteSpace = 'nowrap';
		tr.appendChild(tdEdit);
		// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
		var imgInsert = null;
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			imgInsert = document.createElement('input');
			imgInsert.id     = sLayoutPanel + '_ctlEditView_NAICS_CODE_NAME_btnInsert';
			imgInsert.type   = 'image';
			// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
			imgInsert.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/accept_inline.gif';
			imgInsert.style.borderWidth = '0px';
		}
		else
		{
			imgInsert = document.createElement('a');
			imgInsert.id     = sLayoutPanel + '_ctlEditView_NAICS_CODE_NAME_btnInsert';
			imgInsert.href   = '#';
			var spnInsert = document.createElement('span');
			imgInsert.appendChild(spnInsert);
			spnInsert.className     = 'glyphicon glyphicon-ok fa-2x';
			spnInsert.style.cursor  = 'pointer';
			spnInsert.title         = L10n.Term('.LBL_SUBMIT_BUTTON_LABEL');
			spnInsert.style.padding = '2px';
		}
		var thisEditView = this;
		imgInsert.onclick = BindArguments(function(tr, txt)
		{
			var sNAICS_CODE_NAME = txt.value;
			if ( !Sql.IsEmptyString(sNAICS_CODE_NAME) )
			{
				var trNew = document.createElement('tr');
				tbody.insertBefore(trNew, tr);
				var tdNew = document.createElement('td');
				trNew.appendChild(tdNew);
				
				var hidNew = document.createElement('input');
				hidNew.name  = sLayoutPanel + '_ctlEditView_NAICS_SET_NAME';
				hidNew.type  = 'hidden';
				hidNew.value = sNAICS_CODE_NAME;
				tdNew.appendChild(hidNew);
				
				var txtNew = document.createTextNode(sNAICS_CODE_NAME);
				tdNew.appendChild(txtNew);
				
				tdNew = document.createElement('td');
				trNew.appendChild(tdNew);
				tdNew.align = 'right';
				tdNew.style.whiteSpace = 'nowrap';
				// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					var imgDelete = document.createElement('input');
					imgDelete.type   = 'image';
					// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
					imgDelete.src    = sIMAGE_SERVER + 'App_Themes/' + thisEditView.ButtonTheme() + '/images/delete_inline.gif';
					imgDelete.style.borderWidth = '0px';
					imgDelete.onclick = BindArguments(function(trNew)
					{
						trNew.parentNode.removeChild(trNew);
					}, trNew);
					tdNew.appendChild(imgDelete);
				}
				else
				{
					var aDelete = document.createElement('a');
					aDelete.href = '#';
					tdNew.appendChild(aDelete);
					var imgDelete = document.createElement('span');
					aDelete.appendChild(imgDelete);
					aDelete.onclick = BindArguments(function(trNew)
					{
						trNew.parentNode.removeChild(trNew);
					}, trNew);
					imgDelete.className     = 'glyphicon glyphicon-remove fa-2x';
					imgDelete.style.cursor  = 'pointer';
					imgDelete.title         = L10n.Term('.LNK_DELETE');
					imgDelete.style.padding = '2px';
				}
			}
			txt.value = '';
		}, tr, txt);
		tdEdit.appendChild(imgInsert);
		// 04/13/2017 Paul.  Use glyphicon instead of regular icon. 
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			var imgCancel = document.createElement('input');
			imgCancel.id     = sLayoutPanel + '_ctlEditView_NAICS_CODE_NAME_btnCancel';
			imgCancel.type   = 'image';
			// 10/19/2016 Paul.  Use function to allow separate button for Arctic theme. 
			imgCancel.src    = sIMAGE_SERVER + 'App_Themes/' + this.ButtonTheme() + '/images/decline_inline.gif';
			imgCancel.style.borderWidth = '0px';
			imgCancel.onclick = BindArguments(function(txt)
			{
				txt.value = '';
			}, txt);
			tdEdit.appendChild(imgCancel);
		}
		else
		{
			var aCancel = document.createElement('a');
			aCancel.href = '#';
			aCancel.id   = sLayoutPanel + '_ctlEditView_NAICS_CODE_NAME_btnCancel';
			tdEdit.appendChild(aCancel);
			aCancel.onclick = BindArguments(function(txt)
			{
				txt.value = '';
			}, txt);
			var imgCancel = document.createElement('span');
			aCancel.appendChild(imgCancel);
			imgCancel.className     = 'glyphicon glyphicon-remove fa-2x';
			imgCancel.style.cursor  = 'pointer';
			imgCancel.title         = L10n.Term('.LNK_DELETE');
			imgCancel.style.padding = '2px';
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'EditViewUI.LoadNaicsSelect');
	}
}

EditViewUI.prototype.LoadView = function(sLayoutPanel, tblMain, layout, row, sSubmitID)
{
	try
	{
		// 10/17/2012 Paul.  Exit if the Main does not exist.  This is a sign that the user has navigated elsewhere. 
		if ( tblMain == null )
			return;
		var tbody = null;
		// 04/08/2017 Paul.  Use Bootstrap for responsive design.
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			tbody = document.createElement('tbody');
			tblMain.appendChild(tbody);
		}
		else
		{
			// 04/08/2017 Paul.  Use Bootstrap for responsive design.
			var x_panel = document.createElement('div');
			x_panel.className = 'x_panel';
			tblMain.appendChild(x_panel);
			var x_content = document.createElement('div');
			x_content.className = 'x_content';
			x_panel.appendChild(x_content);
			var x_form = document.createElement('div');
			x_form.className = 'form-horizontal form-label-left';
			x_content.appendChild(x_form);
			tbody = document.createElement('div');
			tbody.className = 'form-group';
			x_form.appendChild(tbody);
		}
		
		var tr        = null;
		var nColIndex = 0;
		var tdLabel   = null;
		var tdField   = null;
		var bEnableTeamManagement  = Crm.Config.enable_team_management();
		var bRequireTeamManagement = Crm.Config.require_team_management();
		var bEnableDynamicTeams    = Crm.Config.enable_dynamic_teams();
		// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		var bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
		var bRequireUserAssignment = Crm.Config.require_user_assignment();
		// 09/16/2018 Paul.  Create a multi-tenant system. 
		if ( Crm.Config.enable_multi_tenant_teams() )
		{
			bEnableTeamManagement    = false;
			bEnableDynamicTeams      = false;
			bEnableDynamicAssignment = false;
		}
		// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
		if ( row != null && row['DATE_MODIFIED'] !== undefined )
			this.LAST_DATE_MODIFIED = row['DATE_MODIFIED'];

		// 08/31/2012 Paul.  Add support for speech. 
		var bEnableSpeech = Crm.Config.enable_speech();
		var sUSER_AGENT   = navigator.userAgent;
		if ( sUSER_AGENT == 'Chrome' || sUSER_AGENT.indexOf('Android') > 0 || sUSER_AGENT.indexOf('iPad') > 0 || sUSER_AGENT.indexOf('iPhone') > 0 )
			bEnableSpeech = Crm.Config.enable_speech();
		// 12/06/2014 Paul.  Use new mobile flag. 
		var bIsMobile = isMobileDevice();
		if ( isMobileLandscape() )
			bIsMobile = false;
		var sTheme = Security.USER_THEME();
		// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
		var oNumberFormat = Security.NumberFormatInfo();
		for ( var nLayoutIndex in layout )
		{
			var lay = layout[nLayoutIndex];
			//alert(dumpObj(lay, 'EditViewUI.LoadView layout'));
			var sEDIT_NAME                  = lay.EDIT_NAME                 ;
			var sFIELD_TYPE                 = lay.FIELD_TYPE                ;
			var sDATA_LABEL                 = lay.DATA_LABEL                ;
			var sDATA_FIELD                 = lay.DATA_FIELD                ;
			var sDATA_FORMAT                = lay.DATA_FORMAT               ;
			var sDISPLAY_FIELD              = lay.DISPLAY_FIELD             ;
			var sCACHE_NAME                 = lay.CACHE_NAME                ;
			var sLIST_NAME                  = lay.LIST_NAME                 ;
			// 12/05/2012 Paul.  UI_REQUIRED is not used on SQLite, so use the DATA_REQUIRED value. 
			var bUI_REQUIRED                = Sql.ToBoolean(lay.UI_REQUIRED) || Sql.ToBoolean(lay.DATA_REQUIRED);
			var sONCLICK_SCRIPT             = lay.ONCLICK_SCRIPT            ;
			var sFORMAT_SCRIPT              = lay.FORMAT_SCRIPT             ;
			var nFORMAT_TAB_INDEX           = Sql.ToInteger(lay.FORMAT_TAB_INDEX );
			var nFORMAT_MAX_LENGTH          = Sql.ToInteger(lay.FORMAT_MAX_LENGTH);
			var nFORMAT_SIZE                = Sql.ToInteger(lay.FORMAT_SIZE      );
			var nFORMAT_ROWS                = Sql.ToInteger(lay.FORMAT_ROWS      );
			var nFORMAT_COLUMNS             = Sql.ToInteger(lay.FORMAT_COLUMNS   );
			var nCOLSPAN                    = Sql.ToInteger(lay.COLSPAN          );
			var nROWSPAN                    = Sql.ToInteger(lay.ROWSPAN          );
			var sLABEL_WIDTH                = lay.LABEL_WIDTH               ;
			var sFIELD_WIDTH                = lay.FIELD_WIDTH               ;
			var nDATA_COLUMNS               = Sql.ToInteger(lay.DATA_COLUMNS     );
			var sVIEW_NAME                  = lay.VIEW_NAME                 ;
			var sFIELD_VALIDATOR_ID         = lay.FIELD_VALIDATOR_ID        ;
			var sFIELD_VALIDATOR_MESSAGE    = lay.FIELD_VALIDATOR_MESSAGE   ;
			var sUI_VALIDATOR               = lay.UI_VALIDATOR              ;
			var sVALIDATION_TYPE            = lay.VALIDATION_TYPE           ;
			var sREGULAR_EXPRESSION         = lay.REGULAR_EXPRESSION        ;
			var sDATA_TYPE                  = lay.DATA_TYPE                 ;
			var sMININUM_VALUE              = lay.MININUM_VALUE             ;
			var sMAXIMUM_VALUE              = lay.MAXIMUM_VALUE             ;
			var sCOMPARE_OPERATOR           = lay.COMPARE_OPERATOR          ;
			var sMODULE_TYPE                = lay.MODULE_TYPE               ;
			var sFIELD_VALIDATOR_NAME       = lay.FIELD_VALIDATOR_NAME      ;
			var sTOOL_TIP                   = lay.TOOL_TIP                  ;
			var bVALID_RELATED              = false                         ;
			var sRELATED_SOURCE_MODULE_NAME = lay.RELATED_SOURCE_MODULE_NAME;
			var sRELATED_SOURCE_VIEW_NAME   = lay.RELATED_SOURCE_VIEW_NAME  ;
			var sRELATED_SOURCE_ID_FIELD    = lay.RELATED_SOURCE_ID_FIELD   ;
			var sRELATED_SOURCE_NAME_FIELD  = lay.RELATED_SOURCE_NAME_FIELD ;
			var sRELATED_VIEW_NAME          = lay.RELATED_VIEW_NAME         ;
			var sRELATED_ID_FIELD           = lay.RELATED_ID_FIELD          ;
			var sRELATED_NAME_FIELD         = lay.RELATED_NAME_FIELD        ;
			var sRELATED_JOIN_FIELD         = lay.RELATED_JOIN_FIELD        ;
			var sPARENT_FIELD               = lay.PARENT_FIELD              ;
			var sFIELD_VALIDATOR_MESSAGE    = lay.FIELD_VALIDATOR_MESSAGE   ;
			var sVALIDATION_TYPE            = lay.VALIDATION_TYPE           ;
			var sREGULAR_EXPRESSION         = lay.REGULAR_EXPRESSION        ;
			var sDATA_TYPE                  = lay.DATA_TYPE                 ;
			var sMININUM_VALUE              = lay.MININUM_VALUE             ;
			var sMAXIMUM_VALUE              = lay.MAXIMUM_VALUE             ;
			var sCOMPARE_OPERATOR           = lay.COMPARE_OPERATOR          ;
			// 05/15/2018 Paul.  sTOOL_TIP already defined.  
			//var sTOOL_TIP                   = ''                            ;
			var sMODULE_NAME                = ''                            ;
			
			if ( nDATA_COLUMNS == 0 )
				nDATA_COLUMNS = 2;
			// 04/08/2017 Paul.  Use Bootstrap for responsive design.
			var sGridLabel = 'control-label';
			var sGridInput = '';
			if ( nDATA_COLUMNS == 1 )
			{
				sGridLabel = 'control-label col-md-3 col-sm-4 col-xs-12';
				sGridInput = 'col-md-9 col-sm-8 col-xs-12';
			}
			else if ( nDATA_COLUMNS == 2 )
			{
				sGridLabel = 'control-label col-md-2 col-sm-3 col-xs-12';
				sGridInput = 'col-md-4 col-sm-3 col-xs-12';
			}
			else if ( nDATA_COLUMNS == 3 )
			{
				sGridLabel = 'control-label col-md-1 col-sm-2 col-xs-12';
				sGridInput = 'col-md-3 col-sm-2 col-xs-12';
			}
			else if ( nDATA_COLUMNS == 4 )
			{
				sGridLabel = 'control-label col-md-1 col-sm-1 col-xs-12';
				sGridInput = 'col-md-2 col-sm-2 col-xs-12';
			}
			else
			{
				sGridLabel = 'control-label col-md-1 col-sm-1 col-xs-12';
				sGridInput = 'col-md-1 col-sm-1 col-xs-12';
			}
			// 05/30/2018 Paul.  Apply nCOLSPAN. 
			if ( nCOLSPAN == 3 )
			{
				sGridLabel = 'control-label col-md-3 col-sm-4 col-xs-12';
				sGridInput = 'col-md-9 col-sm-8 col-xs-12';
			}
			
			var arrEDIT_NAME = sEDIT_NAME.split('.');
			if ( arrEDIT_NAME.length > 0 )
				sMODULE_NAME = arrEDIT_NAME[0];
			
			if ( (sDATA_FIELD == 'TEAM_ID' || sDATA_FIELD == 'TEAM_SET_NAME') )
			{
				// 09/16/2018 Paul.  Create a multi-tenant system. 
				if ( Crm.Config.enable_multi_tenant_teams() )
				{
					sFIELD_TYPE  = "Hidden";
					sDATA_FIELD  = "TEAM_ID";
					bUI_REQUIRED = false;
				}
				else if ( !bEnableTeamManagement )
				{
					sFIELD_TYPE  = 'Blank';
					// 10/24/2012 Paul.  Clear the label to prevent a term lookup. 
					sDATA_LABEL  = null;
					sDATA_FIELD  = null;
					bUI_REQUIRED = false;
				}
				else
				{
					if ( bEnableDynamicTeams )
					{
						// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
						// 10/20/2017 Paul.  Don't convert MyPipelineBySalesStage. 
						if ( sEDIT_NAME.indexOf('.Search') < 0 && sEDIT_NAME.indexOf('.Popup') < 0 && sEDIT_NAME.indexOf('.My') < 0 )
						{
							sDATA_LABEL     = '.LBL_TEAM_SET_NAME';
							sDATA_FIELD     = 'TEAM_SET_NAME';
							sFIELD_TYPE     = 'TeamSelect';
							sONCLICK_SCRIPT = '';
						}
					}
					else
					{
						// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
						if ( sFIELD_TYPE == 'TeamSelect' )
						{
							sDATA_LABEL     = 'Teams.LBL_TEAM';
							sDATA_FIELD     = 'TEAM_ID';
							sDISPLAY_FIELD  = 'TEAM_NAME';
							sFIELD_TYPE     = 'ModulePopup';
							sMODULE_TYPE    = 'Teams';
							sONCLICK_SCRIPT = '';
						}
					}
					if ( bRequireTeamManagement )
						bUI_REQUIRED = true;
				}
			}
			// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			else if ( (sDATA_FIELD == 'ASSIGNED_USER_ID' || sDATA_FIELD == 'ASSIGNED_SET_NAME') )
			{
				// 01/06/2018 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
				if ( bEnableDynamicAssignment && sDATA_FORMAT != "1" )
				{
					if ( sEDIT_NAME.indexOf('.Search') < 0 && sEDIT_NAME.indexOf('.Popup') < 0 && sEDIT_NAME.indexOf('.My') < 0 )
					{
						sDATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
						sDATA_FIELD     = 'ASSIGNED_SET_NAME';
						sFIELD_TYPE     = 'UserSelect';
						sONCLICK_SCRIPT = '';
					}
				}
				else
				{
					if ( sFIELD_TYPE == 'UserSelect' )
					{
						sDATA_LABEL     = '.LBL_ASSIGNED_TO';
						sDATA_FIELD     = 'ASSIGNED_USER_ID';
						sDISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
						sFIELD_TYPE     = 'ModulePopup';
						sMODULE_TYPE    = 'Users';
						sONCLICK_SCRIPT = '';
					}
				}
				if ( bRequireTeamManagement )
					bUI_REQUIRED = true;
			}
			// 02/03/2013 Paul.  FAVORITE_RECORD_ID is not supported on the HTML5 Offline Client or the Browser Extensions. 
			else if ( sDATA_FIELD == 'FAVORITE_RECORD_ID' )
			{
				sFIELD_TYPE = 'Blank';
			}
			else if ( sDATA_FIELD == 'EXCHANGE_FOLDER' )
			{
				if ( !Crm.Modules.ExchangeFolders(sMODULE_NAME) )
				{
					sFIELD_TYPE = 'Blank';
				}
			}
			if ( sFIELD_TYPE == 'Blank' )
			{
				bUI_REQUIRED = false;
			}
			// 09/02/2012 Paul.  A separator will create a new table. We need to match the outer and inner layout. 
			if ( sFIELD_TYPE == 'Separator' )
			{
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					var divMainLayoutPanel = document.getElementById(sLayoutPanel);
					var tblOuter     = document.createElement('table');
					var tbodyOuter   = document.createElement('tbody');
					var trOuter      = document.createElement('tr');
					var tdOuter      = document.createElement('td');
					// 09/27/2012 Paul.  Separator can have an ID and can have a style so that it can be hidden. 
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
						tblOuter.id = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
					if ( !Sql.IsEmptyString(sDATA_FORMAT) )
						tblOuter.setAttribute('style', sDATA_FORMAT);
					tblOuter.className   = 'tabForm';
					tblOuter.cellSpacing = 1;
					tblOuter.cellPadding = 0;
					tblOuter.border      = 0;
					tblOuter.width       = '100%';
					tblOuter.style.marginTop = '5px';
					tblOuter.appendChild(tbodyOuter);
					tbodyOuter.appendChild(trOuter);
					trOuter.appendChild(tdOuter);
					// 02/28/2016 Paul.  Use the new divEditSubPanel to determine placement. 
					var divEditSubPanel = document.getElementById(sLayoutPanel + '_divEditSubPanel');
					divMainLayoutPanel.insertBefore(tblOuter, divEditSubPanel);
		
					tblMain = document.createElement('table');
					tblMain.width     = '100%';
					tblMain.className = 'tabEditView';
					tdOuter.appendChild(tblMain);
					tbody = document.createElement('tbody');
					tblMain.appendChild(tbody);
				}
				else
				{
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					var x_panel = document.createElement('div');
					x_panel.className = 'x_panel';
					tblMain.appendChild(x_panel);
					var x_content = document.createElement('div');
					x_content.className = 'x_content';
					x_panel.appendChild(x_content);
					var x_form = document.createElement('div');
					x_form.className = 'form-horizontal form-label-left';
					x_content.appendChild(x_form);
					tbody = document.createElement('div');
					tbody.className = 'form-group';
					x_form.appendChild(tbody);
				}
				nColIndex = 0;
				tr = null;
				continue;
			}
			// 09/03/2012 Paul.  We are going to ignore address buttons. 
			else if ( sFIELD_TYPE == 'AddressButtons' )
			{
				continue;
			}
			// 11/17/2007 Paul.  On a mobile device, each new field is on a new row. 
			// 12/02/2005 Paul.  COLSPAN == -1 means that a new column should not be created. 
			// 12/06/2014 Paul.  Use new mobile flag. 
			// 02/26/2016 Paul.  We do not want the 1 column layout for the search panel on an OfficeAddin. 
			if ( (nCOLSPAN >= 0 && nColIndex == 0) || tr == null || (bIsMobile && sEDIT_NAME.indexOf('.SearchSubpanel.OfficeAddin') < 0 ) )
			{
				// 11/25/2005 Paul.  Don't pre-create a row as we don't want a blank
				// row at the bottom.  Add rows just before they are needed. 
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					tr = document.createElement('tr');
					tbody.appendChild(tr);
				}
				else
				{
					tr = document.createElement('div');
					tr.className = 'row';
					tbody.appendChild(tr);
				}
			}
			// 06/20/2009 Paul.  The label and the field will be on separate rows for a NewRecord form. 
			var trLabel = tr;
			var trField = tr;
			if ( nCOLSPAN >= 0 || tdLabel == null || tdField == null )
			{
				// 06/21/2015 Paul.  The Seven theme has labels stacked above values. 
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				if ( SplendidDynamic.StackedLayout(sTheme, sEDIT_NAME) && !SplendidDynamic.BootstrapLayout() )
				{
					tdLabel = document.createElement('td');
					tdField = tdLabel;
					trLabel.appendChild(tdLabel);
					if ( sLABEL_WIDTH == '100%' && sFIELD_WIDTH == '0%' && nDATA_COLUMNS == 1 )
					{
						trField = document.createElement('tr');
						tbody.appendChild(tr);
					}
					else
					{
						// 06/20/2009 Paul.  Don't specify the normal styles for a NewRecord form. 
						// This is so that the label will be left aligned. 
						tdLabel.className = 'tabStackedEditViewDF';
						tdLabel.vAlign    = 'top';
						//tdLabel.width     = sLABEL_WIDTH;
						//tdField.className = 'dataField';
						//tdField.vAlign    = 'top';
					}
					trField.appendChild(tdField);
					var spanLabel = document.createElement('span');
					spanLabel.className = 'tabStackedEditViewDL';
					spanLabel.id = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_LABEL';
					tdLabel.appendChild(spanLabel);
					if ( nCOLSPAN > 0 )
					{
						tdField.colSpan = nCOLSPAN;
					}
					// 11/28/2005 Paul.  Don't use the field width if COLSPAN is specified as we want it to take the rest of the table.  The label width will be sufficient. 
					if ( nCOLSPAN == 0 && sFIELD_WIDTH != '0%' )
						tdField.width  = sFIELD_WIDTH;
				
					if ( sDATA_LABEL != null )
					{
						if ( sDATA_LABEL.indexOf('.') >= 0 )
						{
							var sLabel = L10n.Term(sDATA_LABEL);
							if ( EndsWith(sLabel, ':') )
								sLabel = Left(sLabel, sLabel.length - 1);
							var txt = document.createTextNode(sLabel);
							spanLabel.appendChild(txt);
						}
						else if ( !Sql.IsEmptyString(sDATA_LABEL) && row != null )
						{
							var sLabel = row[sDATA_LABEL];
							if ( sLabel === undefined )
								sLabel = sDATA_LABEL;
							var txt = document.createTextNode(Sql.ToString(sLabel));
							spanLabel.appendChild(txt);
						}
					}
					if ( bUI_REQUIRED )
					{
						var lblRequired = document.createElement('span');
						spanLabel.appendChild(lblRequired);
						lblRequired.className = 'required';
						lblRequired.innerHTML = L10n.Term('.LBL_REQUIRED_SYMBOL');
					}
				}
				else
				{
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					if ( !SplendidDynamic.BootstrapLayout() )
					{
						tdLabel = document.createElement('td');
						tdField = document.createElement('td');
						tdLabel.id = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_LABEL';
						trLabel.appendChild(tdLabel);
						if ( sLABEL_WIDTH == '100%' && sFIELD_WIDTH == '0%' && nDATA_COLUMNS == 1 )
						{
							trField = document.createElement('tr');
							tbody.appendChild(tr);
						}
						else
						{
							// 06/20/2009 Paul.  Don't specify the normal styles for a NewRecord form. 
							// This is so that the label will be left aligned. 
							tdLabel.className = 'dataLabel';
							tdLabel.vAlign    = 'top';
							tdLabel.width     = sLABEL_WIDTH;
							tdField.className = 'dataField';
							tdField.vAlign    = 'top';
						}
						trField.appendChild(tdField);
						if ( nCOLSPAN > 0 )
						{
							tdField.colSpan = nCOLSPAN;
						}
						// 11/28/2005 Paul.  Don't use the field width if COLSPAN is specified as we want it to take the rest of the table.  The label width will be sufficient. 
						if ( nCOLSPAN == 0 && sFIELD_WIDTH != '0%' )
							tdField.Width  = sFIELD_WIDTH;
					}
					else
					{
						// 04/08/2017 Paul.  Use Bootstrap for responsive design.
						tdLabel = document.createElement('label');
						tdLabel.className = sGridLabel;
						trLabel.appendChild(tdLabel);
						tdLabel.id = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_LABEL';
						
						tdField = document.createElement('div');
						tdField.className = sGridInput;
						trLabel.appendChild(tdField);
					}
				
					if ( sDATA_LABEL != null )
					{
						if ( sDATA_LABEL.indexOf('.') >= 0 )
						{
							var txt = document.createTextNode(L10n.Term(sDATA_LABEL));
							tdLabel.appendChild(txt);
						}
						else if ( !Sql.IsEmptyString(sDATA_LABEL) && row != null )
						{
							// 06/21/2015 Paul.  Label can contain raw text. 
							var sLabel = row[sDATA_LABEL];
							if ( sLabel === undefined )
								sLabel = Sql.ToString(sDATA_LABEL);
							else
								sLabel = Sql.ToString(sLabel) + ':';
							var txt = document.createTextNode(sLabel);
							tdLabel.appendChild(txt);
						}
					}
					if ( bUI_REQUIRED )
					{
						var lblRequired = document.createElement('span');
						tdLabel.appendChild(lblRequired);
						lblRequired.className = 'required';
						lblRequired.innerHTML = L10n.Term('.LBL_REQUIRED_SYMBOL');
					}
				}
			}
			//alert(sDATA_FIELD);
			try
			{
				if ( sFIELD_TYPE == 'Blank' )
				{
					tdLabel.innerHTML = '&nbsp;'
					tdField.innerHTML = '&nbsp;'
				}
				// 09/03/2012 Paul.  A header is similar to a label, but without the data field. 
				else if ( sFIELD_TYPE == 'Header' )
				{
					tdLabel.innerHTML = '<h4>' + tdLabel.innerHTML + '</h4>';
					tdField.innerHTML = '&nbsp;';
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
					{
						tdField.innerHTML = tdLabel.innerHTML;
						tdLabel.innerHTML = '&nbsp;';
						tdLabel.className = 'control-label col-md-0 col-sm-0 col-xs-0';
						tdField.className = 'col-md-12 col-sm-12 col-xs-12';
					}
				}
				else if ( sFIELD_TYPE == 'Hidden' )
				{
					// 02/28/2008 Paul.  When the hidden field is the first in the row, we end up with a blank row. 
					// Just ignore for now as IE does not have a problem with the blank row. 
					nCOLSPAN = -1;
					var txt = document.createElement('input');
					txt.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
					txt.type      = 'hidden';
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						txt.className = 'form-control';
					if ( row != null )
					{
						if ( !Sql.IsEmptyString(sDATA_FIELD) && row[sDATA_FIELD] != null )
							txt.value = row[sDATA_FIELD];
						// 04/14/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
						// 04/14/2016 Paul.  We need a way to detect that we are loading EditView from a relationship create. 
						if ( Sql.ToBoolean(row['DetailViewRelationshipCreate']) )
						{
							if ( sDATA_FIELD == 'TEAM_ID' )
							{
								if ( Crm.Config.ToBoolean('inherit_team') && !Sql.IsEmptyString(row[sDATA_FIELD]) )
								{
									txt.value = row[sDATA_FIELD];
								}
								else
								{
									txt.value = Security.TEAM_ID();
								}
							}
							else if ( sDATA_FIELD == 'ASSIGNED_USER_ID' )
							{
								if ( Crm.Config.ToBoolean('inherit_assigned_user') && !Sql.IsEmptyString(row[sDATA_FIELD]) )
								{
									txt.value = row[sDATA_FIELD];
								}
								else
								{
									txt.value = Security.USER_ID();
								}
							}
						}
					}
					else if ( sDATA_FIELD == 'TEAM_ID' )
						txt.value = Security.TEAM_ID();
					else if ( sDATA_FIELD == 'ASSIGNED_USER_ID' )
						txt.value = Security.USER_ID();
					tdField.appendChild(txt);
				}
				else if ( sFIELD_TYPE == 'ModuleAutoComplete' )
				{
					var txt = document.createElement('input');
					txt.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
					txt.type      = 'text';
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						txt.className = 'form-control';
					if ( nFORMAT_MAX_LENGTH > 0 ) txt.maxlength = nFORMAT_MAX_LENGTH;
					if ( nFORMAT_TAB_INDEX  > 0 ) txt.tabindex  = nFORMAT_TAB_INDEX ;
					if ( nFORMAT_SIZE       > 0 ) txt.size      = nFORMAT_SIZE      ;
					if ( row != null && row[sDATA_FIELD] != null )
						txt.value = row[sDATA_FIELD];
					tdField.appendChild(txt);
					// 08/31/2012 Paul.  Add support for speech. 
					if ( bEnableSpeech )
					{
						txt.setAttribute('speech', 'speech');
						txt.setAttribute('x-webkit-speech', 'x-webkit-speech');
					}
					if ( sSubmitID != null )
					{
						txt.onkeypress = function(e)
						{
							return RegisterEnterKeyPress(e, sSubmitID);
						};
					}
					if ( bUI_REQUIRED )
					{
						var reqNAME = document.createElement('span');
						reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
						reqNAME.className         = 'required';
						reqNAME.style.paddingLeft = '4px';
						reqNAME.style.display     = 'none';
						reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
						tdField.appendChild(reqNAME);
					}
					// 01/06/2018 Paul.  Poorly configured layout can have an empty module type. Disable auto complete instead of generating an error. 
					if ( !Sql.IsEmptyString(sMODULE_TYPE) )
						this.AutoComplete(sLayoutPanel, sMODULE_TYPE, sDATA_FIELD, null);
				}
				else if ( sFIELD_TYPE == 'ModulePopup' || sFIELD_TYPE == 'ChangeButton' )
				{
					var spnInputs = document.createElement('span');
					tdField.appendChild(spnInputs);
					var lstField = null;
					// 12/01/2012 Paul.  If the label is PARENT_TYPE, then change the label to a DropDownList.
					if ( sDATA_LABEL == 'PARENT_TYPE' && sFIELD_TYPE == 'ChangeButton' )
					{
						while ( tdLabel.childNodes.length > 0 )
						{
							tdLabel.removeChild(tdLabel.firstChild);
						}
						lstField = document.createElement('select');
						// 04/08/2017 Paul.  Use Bootstrap for responsive design.
						if ( SplendidDynamic.BootstrapLayout() )
							lstField.className = 'form-control';
						tdLabel.appendChild(lstField);
						lstField.id = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_PARENT_TYPE';
						if ( nFORMAT_TAB_INDEX > 0 )
						{
							lstField.tabindex = nFORMAT_TAB_INDEX;
						}
						var sDATA_VALUE = null;
						if ( row != null && row['PARENT_TYPE'] != null )
							sDATA_VALUE = row['PARENT_TYPE'];
						var arrLIST = L10n.GetList('record_type_display');
						if ( arrLIST != null )
						{
							for ( var i = 0; i < arrLIST.length; i++ )
							{
								var opt = document.createElement('option');
								lstField.appendChild(opt);
								opt.setAttribute('value', arrLIST[i]);
								opt.innerHTML = L10n.ListTerm('record_type_display', arrLIST[i]);
								if ( sDATA_VALUE != null && sDATA_VALUE == arrLIST[i] )
									opt.setAttribute('selected', 'selected');
							}
						}
					}
					tdField.style.whiteSpace = 'nowrap';
					// 10/18/2011 Paul.  A custom field will not have a display name. 
					var sTEMP_DISPLAY_FIELD = Sql.IsEmptyString(sDISPLAY_FIELD) ? sDATA_FIELD + '_NAME' : sDISPLAY_FIELD;
					var txt = document.createElement('input');
					txt.id = sLayoutPanel + '_ctlEditView_' + sTEMP_DISPLAY_FIELD;
					txt.type      = 'text';
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						txt.className = 'form-control';
					//txt.readOnly  = true;
					if ( nFORMAT_MAX_LENGTH > 0 ) txt.maxlength = nFORMAT_MAX_LENGTH;
					if ( nFORMAT_TAB_INDEX  > 0 ) txt.tabindex  = nFORMAT_TAB_INDEX ;
					if ( nFORMAT_SIZE       > 0 ) txt.size      = nFORMAT_SIZE      ;
					if ( row != null )
					{
						if ( !Sql.IsEmptyString(sDISPLAY_FIELD) && row[sDISPLAY_FIELD] != null )
							txt.value = row[sDISPLAY_FIELD];
						// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
						else if ( row[sDISPLAY_FIELD] === undefined && !Sql.IsEmptyString(row[sDATA_FIELD]) && !Sql.IsEmptyString(sMODULE_TYPE) )
						{
							BindArguments(function(sMODULE_NAME, sID, txt, context)
							{
								Crm.Modules.ItemName(sMODULE_NAME, sID, function(status, message)
								{
									if ( status == 1 )
										txt.value = message;
								}, context);
							}, sMODULE_TYPE, row[sDATA_FIELD], txt, this)();
						}
						// 04/14/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
						// 04/14/2016 Paul.  We need a way to detect that we are loading EditView from a relationship create. 
						if ( Sql.ToBoolean(row['DetailViewRelationshipCreate']) )
						{
							if ( sEDIT_NAME.indexOf('.Search') < 0 && sDATA_FIELD == 'TEAM_ID' )
							{
								if ( Crm.Config.ToBoolean('inherit_team') && !Sql.IsEmptyString(row[sDATA_FIELD]) )
								{
									txt.value = row['TEAM_NAME'];
								}
								else
								{
									txt.value = Security.TEAM_NAME();
								}
							}
							else if ( sEDIT_NAME.indexOf('.Search') < 0 && sDATA_FIELD == 'ASSIGNED_USER_ID' )
							{
								if ( Crm.Config.ToBoolean('inherit_assigned_user') && !Sql.IsEmptyString(row[sDATA_FIELD]) )
								{
									if ( sDISPLAY_FIELD == 'ASSIGNED_TO_NAME' )
										txt.value = row['ASSIGNED_TO_NAME'];
									else
										txt.value = row['ASSIGNED_TO'];
								}
								else
								{
									if ( sDISPLAY_FIELD == 'ASSIGNED_TO_NAME' )
										txt.value = Security.FULL_NAME();
									else
										txt.value = Security.USER_NAME();
								}
							}
						}
					}
					else if ( sEDIT_NAME.indexOf('.Search') < 0 && sDATA_FIELD == 'TEAM_ID' )
					{
						txt.value = Security.TEAM_NAME();
					}
					else if ( sEDIT_NAME.indexOf('.Search') < 0 && sDATA_FIELD == 'ASSIGNED_USER_ID' )
					{
						if ( sDISPLAY_FIELD == 'ASSIGNED_TO_NAME' )
							txt.value = Security.FULL_NAME();
						else
							txt.value = Security.USER_NAME();
					}
					spnInputs.appendChild(txt);
					if ( sSubmitID != null )
					{
						txt.onkeypress = function(e)
						{
							return RegisterEnterKeyPress(e, sSubmitID);
						};
					}
					
					var hid = document.createElement('input');
					hid.id   = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
					hid.type = 'hidden';
					if ( row != null )
					{
						if ( row[sDATA_FIELD] != null )
							hid.value = row[sDATA_FIELD];
						// 06/28/2016 Paul.  We need a way to detect that we are loading EditView from a relationship create. 
						if ( Sql.ToBoolean(row['DetailViewRelationshipCreate']) )
						{
							if ( sEDIT_NAME.indexOf('.Search') < 0 && sDATA_FIELD == 'TEAM_ID' )
							{
								if ( Crm.Config.ToBoolean('inherit_team') && !Sql.IsEmptyString(row[sDATA_FIELD]) )
								{
									hid.value = Sql.ToString(row['TEAM_ID']);
								}
								else
								{
									hid.value = Security.TEAM_NAME();
								}
							}
							else if ( sEDIT_NAME.indexOf('.Search') < 0 && sDATA_FIELD == 'ASSIGNED_USER_ID' )
							{
								if ( Crm.Config.ToBoolean('inherit_assigned_user') && !Sql.IsEmptyString(row[sDATA_FIELD]) )
								{
									hid.value = Sql.ToString(row['ASSIGNED_USER_ID']);
								}
								else
								{
									hid.value = Security.USER_ID();
								}
							}
						}
					}
					else if ( sEDIT_NAME.indexOf('.Search') < 0 && sDATA_FIELD == 'TEAM_ID' && !Sql.IsEmptyGuid(Security.TEAM_ID()) )
					{
						hid.value = Security.TEAM_ID();
					}
					else if ( sEDIT_NAME.indexOf('.Search') < 0 && sDATA_FIELD == 'ASSIGNED_USER_ID' )
					{
						hid.value = Security.USER_ID();
					}
					spnInputs.appendChild(hid);
					
					var spnButtons = document.createElement('span');
					tdField.appendChild(spnButtons);
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					var btnChange = null;
					if ( !SplendidDynamic.BootstrapLayout() )
					{
						btnChange = document.createElement('input');
						btnChange.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_btnChange';
						btnChange.type      = 'button';
						btnChange.className = 'button';
						btnChange.title     = L10n.Term('.LBL_SELECT_BUTTON_TITLE');
						btnChange.value     = L10n.Term('.LBL_SELECT_BUTTON_LABEL');
						btnChange.style.marginLeft  = '4px';
						btnChange.style.marginRight = '2px';
					}
					// 06/25/2017 Paul.  Button with text does not look good on tablet. 
					else if ( bMOBILE_CLIENT )
					{
						btnChange               = document.createElement('button');
						btnChange.href          = '#';
						btnChange.id            = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + "_btnClear";
						btnChange.className     = 'btn btn-default';
						spnInputs.className  = 'col-lg-8 col-md-8 col-sm-6 col-xs-12';
						spnButtons.className = 'col-lg-4 col-md-4 col-sm-6 col-xs-12';
						$(spnInputs ).attr('style', 'padding: 0px !important');
						$(spnButtons).attr('style', 'padding: 0px !important');
						var imgChange = document.createElement('span');
						btnChange.appendChild(imgChange);
						imgChange.className     = 'glyphicon glyphicon-edit';
						imgChange.style.cursor  = 'pointer';
						imgChange.title         = L10n.Term('.LBL_SELECT_BUTTON_LABEL');
						imgChange.style.padding = '2px';
					}
					else
					{
						btnChange = document.createElement('button');
						btnChange.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_btnChange';
						// 04/08/2017 Paul.  input-group stops grid column, so can't use. 
						//tdField.className    = 'input-group ' + sGridInput;
						//spnButtons.className = 'input-group-btn';
						spnInputs.className  = 'col-lg-8 col-md-8 col-sm-6 col-xs-12';
						spnButtons.className = 'col-lg-4 col-md-4 col-sm-6 col-xs-12';
						// 04/08/2017 Paul.  Force removal of padding. 
						$(spnInputs ).attr('style', 'padding: 0px !important');
						$(spnButtons).attr('style', 'padding: 0px !important');
						// 12/31/2017 Paul.  btn-lg-text is not working well. 
						btnChange.className  = 'btn btn-default';
						var glyph = document.createElement('span');
						glyph.className = 'glyphicon glyphicon-edit';
						btnChange.appendChild(glyph);
						//btnChange.appendChild(document.createTextNode(L10n.Term('.LBL_SELECT_BUTTON_LABEL')));
					}
					btnChange.onclick = BindArguments(function(txt, hid, sMODULE_TYPE, sDATA_LABEL, sFIELD_TYPE, sDATA_FIELD, sONCLICK_SCRIPT)
					{
						// 12/01/2012 Paul.  If this is a Parent Type popup, then we need to get the type from the dropdown list. 
						if ( sDATA_LABEL == 'PARENT_TYPE' && sFIELD_TYPE == 'ChangeButton' )
						{
							var lstField = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_PARENT_TYPE');
							sMODULE_TYPE = lstField.options[lstField.options.selectedIndex].value;
						}
						var $dialog = $('<div id="' + hid.id + '_divPopup"><div id="divPopupActionsPanel" /><div id="divPopupLayoutPanel" /></div>');
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
							, title    : L10n.Term(sMODULE_TYPE + '.LBL_LIST_FORM_TITLE')
							, create   : function(event, ui)
							{
								try
								{
									// 03/08/2016 Paul.  Use sONCLICK_SCRIPT to to detect Accounts/Contacts dependencies. 
									var cmd = new Object();
									cmd.CommandText = '';
									var rowDefaultSearch = new Object();
									if ( sMODULE_TYPE == 'Contacts' && !Sql.IsEmptyString(sONCLICK_SCRIPT) )
									{
										if ( sONCLICK_SCRIPT.indexOf('BillingContactPopup()') >= 0 )
										{
											var sACCOUNT_NAME = $('#' + sLayoutPanel + '_ctlEditView_' + 'BILLING_ACCOUNT_NAME').val();
											if ( !Sql.IsEmptyString(sACCOUNT_NAME) )
											{
												rowDefaultSearch['ACCOUNT_NAME'] = sACCOUNT_NAME;
												cmd.CommandText += 'ACCOUNT_NAME = \'' + Sql.EscapeSQL(sACCOUNT_NAME) + '\'';
											}
										}
										else if ( sONCLICK_SCRIPT.indexOf('ShippingContactPopup()') >= 0 )
										{
											var sACCOUNT_NAME = $('#' + sLayoutPanel + '_ctlEditView_' + 'SHIPPING_ACCOUNT_NAME').val();
											if ( !Sql.IsEmptyString(sACCOUNT_NAME) )
											{
												rowDefaultSearch['ACCOUNT_NAME'] = Sql.ToString(sACCOUNT_NAME);
												cmd.CommandText += 'ACCOUNT_NAME = \'' + Sql.EscapeSQL(sACCOUNT_NAME) + '\'';
											}
										}
									}
									var oPopupViewUI = new PopupViewUI();
									oPopupViewUI.LoadWithSearch('divPopupLayoutPanel', 'divPopupActionsPanel', sMODULE_TYPE, false, cmd.CommandText, rowDefaultSearch, function(status, message)
									{
										if ( status == 1 )
										{
											hid.value = message.ID  ;
											txt.value = message.NAME;
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
							, close    : function(event, ui)
							{
								$dialog.dialog('destroy');
								// 10/17/2011 Paul.  We have to remove the new HTML, otherwise there will be multiple definitions for divPopupLayoutPanel. 
								var divPopup = document.getElementById(hid.id + '_divPopup');
								divPopup.parentNode.removeChild(divPopup);
							}
						});
					}, txt, hid, sMODULE_TYPE, sDATA_LABEL, sFIELD_TYPE, sDATA_FIELD, sONCLICK_SCRIPT);
					spnButtons.appendChild(btnChange);
					// 12/15/2014 Paul.  Use small button on mobile device. 
					// 04/16/2017 Paul.  We don't need mobile version now that we are using a small button. 
					/*
					if ( bIsMobile )
					{
						btnChange.style.display = 'none';
						var aChange = document.createElement('a');
						spnButtons.appendChild(aChange);
						var iChange = document.createElement('i');
						iChange.className = 'fa fa-2x fa-location-arrow navButton';
						aChange.style.verticalAlign = 'bottom';
						// 02/25/2016 Paul.  Use pointer cursor. 
						aChange.style.cursor = 'pointer';
						aChange.appendChild(iChange);
						// 01/25/2015 Paul.  Need to bind arguments in order to ensure event attached to correct button. 
						aChange.onclick = BindArguments(function(btnChange)
						{
							btnChange.click();
						}, btnChange);
					}
					*/
					
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					var btnClear = null;
					if ( !SplendidDynamic.BootstrapLayout() )
					{
						btnClear = document.createElement('input');
						btnClear.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + "_btnClear";
						btnClear.type      = 'button';
						btnClear.className = 'button';
						btnClear.title     = L10n.Term('.LBL_CLEAR_BUTTON_TITLE');
						btnClear.value     = L10n.Term('.LBL_CLEAR_BUTTON_LABEL');
						btnClear.style.marginLeft  = '2px';
						btnClear.style.marginRight = '4px';
					}
					// 06/25/2017 Paul.  Button with text does not look good on tablet. 
					else if ( bMOBILE_CLIENT )
					{
						btnClear               = document.createElement('button');
						btnClear.href          = '#';
						btnClear.id            = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + "_btnClear";
						btnClear.className     = 'btn btn-default';
						var imgClear = document.createElement('span');
						btnClear.appendChild(imgClear);
						imgClear.className     = 'glyphicon glyphicon-remove';
						imgClear.style.cursor  = 'pointer';
						imgClear.title         = L10n.Term('.LBL_CLEAR_BUTTON_LABEL');
						imgClear.style.padding = '2px';
					}
					else
					{
						btnClear = document.createElement('button');
						btnClear.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + "_btnClear";
						// 12/31/2017 Paul.  btn-lg-text is not working well. 
						btnClear.className = 'btn btn-default';
						var glyph = document.createElement('span');
						glyph.className = 'glyphicon glyphicon-remove';
						btnClear.appendChild(glyph);
						//btnClear.appendChild(document.createTextNode(L10n.Term('.LBL_CLEAR_BUTTON_LABEL')));
					}
					btnClear.onclick = BindArguments(function(txt, hid)
					{
						hid.value = '';
						txt.value = '';
					}, txt, hid);
					spnButtons.appendChild(btnClear);
					// 12/15/2014 Paul.  Use small button on mobile device. 
					// 04/16/2017 Paul.  We don't need mobile version now that we are using a small button. 
					/*
					if (bIsMobile )
					{
						btnClear.style.display = 'none';
						var aClear = document.createElement('a');
						spnButtons.appendChild(aClear);
						var iClear = document.createElement('i');
						iClear.className = 'fa fa-2x fa-remove navButton';
						aClear.style.verticalAlign = 'bottom';
						// 02/25/2016 Paul.  Use pointer cursor. 
						aClear.style.cursor = 'pointer';
						aClear.appendChild(iClear);
						// 01/25/2015 Paul.  Need to bind arguments in order to ensure event attached to correct button. 
						aClear.onclick = BindArguments(function(btnClear)
						{
							btnClear.click();
						}, btnClear);
					}
					*/
					if ( bUI_REQUIRED )
					{
						var reqNAME = document.createElement('span');
						reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
						reqNAME.className         = 'required';
						reqNAME.style.paddingLeft = '4px';
						reqNAME.style.display     = 'none';
						reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
						tdField.appendChild(reqNAME);
					}
					// 03/08/2016 Paul.  Use sONCLICK_SCRIPT to to detect Accounts/Contacts dependencies. 
					// 01/06/2018 Paul.  Poorly configured layout can have an empty module type. Disable auto complete instead of generating an error. 
					if ( !Sql.IsEmptyString(sMODULE_TYPE) )
					{
						this.AutoComplete(sLayoutPanel, sMODULE_TYPE, sTEMP_DISPLAY_FIELD, sDATA_FIELD);
						txt.onblur = BindArguments(this.AutoCompleteBlur, sLayoutPanel, sMODULE_TYPE, sTEMP_DISPLAY_FIELD, sDATA_FIELD);
					}
				}
				else if ( sFIELD_TYPE == 'TeamSelect' )
				{
					var sTEAM_SET_ID   = '';
					var sTEAM_SET_LIST = '';
					if ( row != null )
					{
						sTEAM_SET_ID   = row['TEAM_SET_ID'];
						sTEAM_SET_LIST = row['TEAM_SET_LIST'];
					}
					// 06/10/2016 Paul.  Need to apply defaults when using DetailViewRelationshipCreate. 
					// 06/28/2016 Paul.  Need to check row before DetailViewRelationshipCreate. 
					var bAllowDefaults = row == null && sEDIT_NAME.indexOf('.Search') < 0 && sEDIT_NAME.indexOf('.Popup') < 0 || (row != null && Sql.ToBoolean(row['DetailViewRelationshipCreate']));
					this.LoadTeamSelect(sLayoutPanel, tdField, sTEAM_SET_ID, sTEAM_SET_LIST, bUI_REQUIRED, bAllowDefaults);
					if ( bUI_REQUIRED )
					{
						var reqNAME = document.createElement('span');
						reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
						reqNAME.className         = 'required';
						reqNAME.style.paddingLeft = '4px';
						reqNAME.style.display     = 'none';
						reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
						tdField.appendChild(reqNAME);
					}
				}
				// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( sFIELD_TYPE == 'UserSelect' )
				{
					var sASSIGNED_SET_ID   = '';
					var sASSIGNED_SET_LIST = '';
					if ( row != null )
					{
						sASSIGNED_SET_ID   = row['ASSIGNED_SET_ID'];
						sASSIGNED_SET_LIST = row['ASSIGNED_SET_LIST'];
					}
					// 06/10/2016 Paul.  Need to apply defaults when using DetailViewRelationshipCreate. 
					// 06/28/2016 Paul.  Need to check row before DetailViewRelationshipCreate. 
					var bAllowDefaults = row == null && sEDIT_NAME.indexOf('.Search') < 0 && sEDIT_NAME.indexOf('.Popup') < 0 || (row != null && Sql.ToBoolean(row['DetailViewRelationshipCreate']));
					this.LoadUserSelect(sLayoutPanel, tdField, sASSIGNED_SET_ID, sASSIGNED_SET_LIST, bUI_REQUIRED, bAllowDefaults);
					if ( bUI_REQUIRED )
					{
						var reqNAME = document.createElement('span');
						reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
						reqNAME.className         = 'required';
						reqNAME.style.paddingLeft = '4px';
						reqNAME.style.display     = 'none';
						reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
						tdField.appendChild(reqNAME);
					}
				}
				// 05/14/2016 Paul.  Add Tags module. 
				else if ( sFIELD_TYPE == 'TagSelect' )
				{
					var sTAG_SET_NAME = '';
					if ( row != null )
					{
						sTAG_SET_NAME = row['TAG_SET_NAME'];
					}
					this.LoadTagSelect(sLayoutPanel, tdField, sTAG_SET_NAME, bUI_REQUIRED);
					if ( bUI_REQUIRED )
					{
						var reqNAME = document.createElement('span');
						reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
						reqNAME.className         = 'required';
						reqNAME.style.paddingLeft = '4px';
						reqNAME.style.display     = 'none';
						reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
						tdField.appendChild(reqNAME);
					}
				}
				// 06/07/2017 Paul.  Add NAICSCodes module. 
				else if ( sFIELD_TYPE == 'NAICSCodeSelect' )
				{
					var sNAICS_SET_NAME = '';
					if ( row != null )
					{
						sNAICS_SET_NAME = row['NAICS_SET_NAME'];
					}
					this.LoadNaicsSelect(sLayoutPanel, tdField, sNAICS_SET_NAME, bUI_REQUIRED);
					if ( bUI_REQUIRED )
					{
						var reqNAME = document.createElement('span');
						reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
						reqNAME.className         = 'required';
						reqNAME.style.paddingLeft = '4px';
						reqNAME.style.display     = 'none';
						reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
						tdField.appendChild(reqNAME);
					}
				}
				// 04/14/2016 Paul.  Add ZipCode lookup. 
				else if ( sFIELD_TYPE == 'TextBox' || sFIELD_TYPE == 'HtmlEditor' || sFIELD_TYPE == 'ZipCodePopup' )
				{
					if ( nFORMAT_ROWS == 0 )
					{
						var txt = document.createElement('input');
						txt.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
						txt.type      = 'text';
						// 04/08/2017 Paul.  Use Bootstrap for responsive design.
						if ( SplendidDynamic.BootstrapLayout() )
							txt.className = 'form-control';
						if ( nFORMAT_MAX_LENGTH > 0 ) txt.maxlength = nFORMAT_MAX_LENGTH;
						if ( nFORMAT_TAB_INDEX  > 0 ) txt.tabindex  = nFORMAT_TAB_INDEX ;
						if ( nFORMAT_SIZE       > 0 ) txt.size      = nFORMAT_SIZE      ;
						tdField.appendChild(txt);
						// 09/10/2011 Paul.  Search fields can have multiple fields. 
						if ( sDATA_FIELD.indexOf(' ') > 0 )
						{
							var arrDATA_FIELD = sDATA_FIELD.split(' ');
							for ( var nFieldIndex in arrDATA_FIELD )
							{
								if ( row != null && row[arrDATA_FIELD[nFieldIndex]] != null )
									txt.value = row[arrDATA_FIELD[nFieldIndex]];
							}
						}
						else
						{
							if ( row != null && row[sDATA_FIELD] != null )
								txt.value = row[sDATA_FIELD];
						}
						// 08/31/2012 Paul.  Add support for speech. 
						// 04/14/2016 Paul.  Add ZipCode lookup. 
						if ( (sFIELD_TYPE == 'TextBox' || sFIELD_TYPE == 'ZipCodePopup') && bEnableSpeech )
						{
							txt.setAttribute('speech', 'speech');
							txt.setAttribute('x-webkit-speech', 'x-webkit-speech');
						}
						if ( sSubmitID != null )
						{
							txt.onkeypress = function(e)
							{
								return RegisterEnterKeyPress(e, sSubmitID);
							};
						}
					}
					else
					{
						var txt = document.createElement('textarea');
						tdField.appendChild(txt);
						txt.id = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
						// 04/08/2017 Paul.  Use Bootstrap for responsive design.
						if ( SplendidDynamic.BootstrapLayout() )
							txt.className = 'form-control';
						if ( nFORMAT_MAX_LENGTH > 0 ) txt.maxlength = nFORMAT_MAX_LENGTH;
						if ( nFORMAT_TAB_INDEX  > 0 ) txt.tabindex  = nFORMAT_TAB_INDEX ;
						if ( nFORMAT_ROWS       > 0 ) txt.rows      = nFORMAT_ROWS      ;
						if ( nFORMAT_COLUMNS    > 0 ) txt.cols      = nFORMAT_COLUMNS   ;
						if ( row != null && row[sDATA_FIELD] != null )
							txt.value = row[sDATA_FIELD];
						// 08/31/2012 Paul.  Add support for speech. 
						// 04/14/2016 Paul.  Add ZipCode lookup. 
						if ( (sFIELD_TYPE == 'TextBox' || sFIELD_TYPE == 'ZipCodePopup') && bEnableSpeech )
						{
							var txtSpeech = document.createElement('input');
							tdField.appendChild(txtSpeech);
							txtSpeech.id = txt.id + '_SPEECH';
							//txtSpeech.setAttribute('style', 'width: 15px; height: 20px; border: 0px; background-color: transparent; vertical-align:top;');
							txtSpeech.style.width           = '15px';
							txtSpeech.style.width           = '20px';
							txtSpeech.style.border          = '0px' ;
							txtSpeech.style.backgroundColor = 'transparent';
							txtSpeech.style.verticalAlign   = 'top';
							txtSpeech.setAttribute('speech', 'speech');
							txtSpeech.setAttribute('x-webkit-speech', 'x-webkit-speech');
							txtSpeech.onspeechchange = BindArguments(function(txtSpeech, txt)
							{
								try
								{
									txt.value += txtSpeech.value + ' ';
									txtSpeech.value = '';
									txt.focus();
								}
								catch(e)
								{
								}
							}, txtSpeech, txt);
							txtSpeech.onwebkitspeechchange = BindArguments(function(txtSpeech, txt)
							{
								try
								{
									txt.value += txtSpeech.value + ' ';
									txtSpeech.value = '';
									txt.focus();
								}
								catch(e)
								{
								}
							}, txtSpeech, txt);
						}
					}
					if ( bUI_REQUIRED )
					{
						var reqNAME = document.createElement('span');
						reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
						reqNAME.className         = 'required';
						reqNAME.style.paddingLeft = '4px';
						reqNAME.style.display     = 'none';
						reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
						tdField.appendChild(reqNAME);
					}
				}
				// 05/24/2017 Paul.  Need support for DateRange for new Dashboard. 
				else if ( sFIELD_TYPE == 'DateRange' )
				{
					// 01/01/2018 Paul.  Place date range fields in inner table. 
					var tblRange     = document.createElement('table');
					var tbodyRange   = document.createElement('tbody');
					var trRange      = document.createElement('tr');
					var tdRangeLabel = document.createElement('td');
					var tdRangeField = document.createElement('td');
					tblRange.cellSpacing = 1;
					tblRange.cellPadding = 0;
					tblRange.border      = 0;
					tblRange.appendChild(tbodyRange);
					tbodyRange.appendChild(trRange);
					trRange.appendChild(tdRangeLabel);
					trRange.appendChild(tdRangeField);
					tdField.appendChild(tblRange);

					var lbl = document.createTextNode(' ' + L10n.Term('Dashboard.LBL_SEARCH_AFTER' ));
					tdRangeLabel.appendChild(lbl);

					var txt = document.createElement('input');
					// 01/01/2018 Paul.  datepicker does not like spaces in id. 
					txt.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD.replace(/ /g, '_') + '_AFTER';
					txt.type      = 'text';
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						txt.className = 'form-control';
					if ( nFORMAT_MAX_LENGTH > 0 ) txt.maxlength = nFORMAT_MAX_LENGTH;
					if ( nFORMAT_TAB_INDEX  > 0 ) txt.tabindex  = nFORMAT_TAB_INDEX ;
					if ( nFORMAT_SIZE       > 0 ) txt.size      = nFORMAT_SIZE      ;
					tdRangeField.appendChild(txt);
					if ( row != null && row[sDATA_FIELD] != null )
					{
						txt.value = FromJsonDate(row[sDATA_FIELD], Security.USER_DATE_FORMAT());
					}
					if ( sSubmitID != null )
					{
						txt.onkeypress = function(e)
						{
							return RegisterEnterKeyPress(e, sSubmitID);
						};
					}
					// http://www.phpeveryday.com/articles/jQuery-UI-Changing-the-date-format-for-Datepicker-P1023.html
					var sDATE_FORMAT = Security.USER_DATE_FORMAT();
					sDATE_FORMAT = sDATE_FORMAT.replace('yyyy', 'yy');
					sDATE_FORMAT = sDATE_FORMAT.replace('MM'  , 'mm');
					$('#' + txt.id).datepicker( { dateFormat: sDATE_FORMAT } );

					// 01/01/2018 Paul.  Use inner table instead. 
					/*
					// 05/24/2017 Paul.  We need to fake the next column. 
					if ( nCOLSPAN > 0 )
						nColIndex += nCOLSPAN;
					else if ( nCOLSPAN == 0 )
						nColIndex++;
					if ( nColIndex >= nDATA_COLUMNS )
						nColIndex = 0;
					if ( (nCOLSPAN >= 0 && nColIndex == 0) || tr == null || (bIsMobile && sEDIT_NAME.indexOf('.SearchSubpanel.OfficeAddin') < 0 ) )
					{
						if ( !SplendidDynamic.BootstrapLayout() )
						{
							tr = document.createElement('tr');
							tbody.appendChild(tr);
						}
						else
						{
							tr = document.createElement('div');
							tr.className = 'row';
							tbody.appendChild(tr);
						}
					}
					
					trLabel = tr;
					trField = tr;
					if ( SplendidDynamic.StackedLayout(sTheme, sEDIT_NAME) && !SplendidDynamic.BootstrapLayout() )
					{
						tdLabel = document.createElement('td');
						tdField = tdLabel;
						trLabel.appendChild(tdLabel);
						if ( sLABEL_WIDTH == '100%' && sFIELD_WIDTH == '0%' && nDATA_COLUMNS == 1 )
						{
							trField = document.createElement('tr');
							tbody.appendChild(tr);
						}
						else
						{
							tdLabel.className = 'tabStackedEditViewDF';
							tdLabel.vAlign    = 'top';
						}
						trField.appendChild(tdField);
						var spanLabel = document.createElement('span');
						spanLabel.className = 'tabStackedEditViewDL';
						tdLabel.appendChild(spanLabel);
					}
					else
					{
						if ( !SplendidDynamic.BootstrapLayout() )
						{
							tdLabel = document.createElement('td');
							tdField = document.createElement('td');
							tdLabel.id = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_LABEL';
							trLabel.appendChild(tdLabel);
							if ( sLABEL_WIDTH == '100%' && sFIELD_WIDTH == '0%' && nDATA_COLUMNS == 1 )
							{
								trField = document.createElement('tr');
								tbody.appendChild(tr);
							}
							else
							{
								tdLabel.className = 'dataLabel';
								tdLabel.vAlign    = 'top';
								tdLabel.width     = sLABEL_WIDTH;
								tdField.className = 'dataField';
								tdField.vAlign    = 'top';
							}
							trField.appendChild(tdField);
							if ( nCOLSPAN > 0 )
							{
								tdField.colSpan = nCOLSPAN;
							}
							if ( nCOLSPAN == 0 && sFIELD_WIDTH != '0%' )
								tdField.Width  = sFIELD_WIDTH;
						}
						else
						{
							// 04/08/2017 Paul.  Use Bootstrap for responsive design.
							tdLabel = document.createElement('label');
							tdLabel.className = sGridLabel;
							trLabel.appendChild(tdLabel);
						
							tdField = document.createElement('div');
							tdField.className = sGridInput;
							trLabel.appendChild(tdField);
						}
					}
					if ( sDATA_LABEL != null )
					{
						if ( sDATA_LABEL.indexOf('.') >= 0 )
						{
							var txt = document.createTextNode(L10n.Term(sDATA_LABEL));
							tdLabel.appendChild(txt);
						}
						else if ( !Sql.IsEmptyString(sDATA_LABEL) && row != null )
						{
							// 06/21/2015 Paul.  Label can contain raw text. 
							var sLabel = row[sDATA_LABEL];
							if ( sLabel === undefined )
								sLabel = Sql.ToString(sDATA_LABEL);
							else
								sLabel = Sql.ToString(sLabel) + ':';
							var txt = document.createTextNode(sLabel);
							tdLabel.appendChild(txt);
						}
					}
					*/
					
					// 01/01/2018 Paul.  Use inner table instead. 
					trRange      = document.createElement('tr');
					tdRangeLabel = document.createElement('td');
					tdRangeField = document.createElement('td');
					tbodyRange.appendChild(trRange);
					trRange.appendChild(tdRangeLabel);
					trRange.appendChild(tdRangeField);
					
					var lbl = document.createTextNode(' ' + L10n.Term('Dashboard.LBL_SEARCH_BEFORE'));
					tdRangeLabel.appendChild(lbl);
					var txt = document.createElement('input');
					// 01/01/2018 Paul.  datepicker does not like spaces in the id. 
					txt.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD.replace(/ /g, '_') + '_BEFORE';
					txt.type      = 'text';
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						txt.className = 'form-control';
					if ( nFORMAT_MAX_LENGTH > 0 ) txt.maxlength = nFORMAT_MAX_LENGTH;
					if ( nFORMAT_TAB_INDEX  > 0 ) txt.tabindex  = nFORMAT_TAB_INDEX ;
					if ( nFORMAT_SIZE       > 0 ) txt.size      = nFORMAT_SIZE      ;
					tdRangeField.appendChild(txt);
					if ( row != null && row[sDATA_FIELD] != null )
					{
						txt.value = FromJsonDate(row[sDATA_FIELD], Security.USER_DATE_FORMAT());
					}
					if ( sSubmitID != null )
					{
						txt.onkeypress = function(e)
						{
							return RegisterEnterKeyPress(e, sSubmitID);
						};
					}
					// http://www.phpeveryday.com/articles/jQuery-UI-Changing-the-date-format-for-Datepicker-P1023.html
					var sDATE_FORMAT = Security.USER_DATE_FORMAT();
					sDATE_FORMAT = sDATE_FORMAT.replace('yyyy', 'yy');
					sDATE_FORMAT = sDATE_FORMAT.replace('MM'  , 'mm');
					$('#' + txt.id).datepicker( { dateFormat: sDATE_FORMAT } );
				}
				else if ( sFIELD_TYPE == 'DatePicker' )
				{
					var txt = document.createElement('input');
					txt.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
					txt.type      = 'text';
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						txt.className = 'form-control';
					if ( nFORMAT_MAX_LENGTH > 0 ) txt.maxlength = nFORMAT_MAX_LENGTH;
					if ( nFORMAT_TAB_INDEX  > 0 ) txt.tabindex  = nFORMAT_TAB_INDEX ;
					if ( nFORMAT_SIZE       > 0 ) txt.size      = nFORMAT_SIZE      ;
					tdField.appendChild(txt);
					if ( row != null && row[sDATA_FIELD] != null )
					{
						txt.value = FromJsonDate(row[sDATA_FIELD], Security.USER_DATE_FORMAT());
					}
					if ( sSubmitID != null )
					{
						txt.onkeypress = function(e)
						{
							return RegisterEnterKeyPress(e, sSubmitID);
						};
					}
					// http://www.phpeveryday.com/articles/jQuery-UI-Changing-the-date-format-for-Datepicker-P1023.html
					var sDATE_FORMAT = Security.USER_DATE_FORMAT();
					sDATE_FORMAT = sDATE_FORMAT.replace('yyyy', 'yy');
					sDATE_FORMAT = sDATE_FORMAT.replace('MM'  , 'mm');
					$('#' + txt.id).datepicker( { dateFormat: sDATE_FORMAT } );
					if ( bUI_REQUIRED )
					{
						var reqNAME = document.createElement('span');
						reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
						reqNAME.className         = 'required';
						reqNAME.style.paddingLeft = '4px';
						reqNAME.style.display     = 'none';
						reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
						tdField.appendChild(reqNAME);
					}
				}
				else if ( sFIELD_TYPE == 'DateTimeEdit' || sFIELD_TYPE == 'DateTimeNewRecord' || sFIELD_TYPE == 'DateTimePicker' )
				{
					var sDATE_FORMAT = Security.USER_DATE_FORMAT();
					var sTIME_FORMAT = Security.USER_TIME_FORMAT();
					// 05/05/2013 Paul.  Remove the day name from the edit field. 
					sDATE_FORMAT = sDATE_FORMAT.replace('dddd,', '');
					sDATE_FORMAT = sDATE_FORMAT.replace('dddd' , '');
					sDATE_FORMAT = sDATE_FORMAT.replace('ddd,' , '');
					sDATE_FORMAT = sDATE_FORMAT.replace('ddd'  , '');
					sDATE_FORMAT = Trim(sDATE_FORMAT);
					
					var txt = document.createElement('input');
					txt.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
					txt.type      = 'text';
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						txt.className = 'form-control';
					if ( nFORMAT_MAX_LENGTH > 0 ) txt.maxlength = nFORMAT_MAX_LENGTH;
					if ( nFORMAT_TAB_INDEX  > 0 ) txt.tabindex  = nFORMAT_TAB_INDEX ;
					if ( nFORMAT_SIZE       > 0 ) txt.size      = nFORMAT_SIZE      ;
					tdField.appendChild(txt);
					if ( row != null && row[sDATA_FIELD] != null )
					{
						txt.value = FromJsonDate(row[sDATA_FIELD], sDATE_FORMAT + ' ' + sTIME_FORMAT);
					}
					if ( sSubmitID != null )
					{
						txt.onkeypress = function(e)
						{
							return RegisterEnterKeyPress(e, sSubmitID);
						};
					}
					// 05/05/2013 Paul.  We need to convert .NET date formatting to TimePicker date formatting. 
					// http://arshaw.com/fullcalendar/docs/utilities/formatDate/
					// http://trentrichardson.com/examples/timepicker/
					// http://docs.jquery.com/UI/Datepicker/formatDate
					sDATE_FORMAT = sDATE_FORMAT.replace('dddd', 'DD');
					sDATE_FORMAT = sDATE_FORMAT.replace('ddd' , 'D' );
					sDATE_FORMAT = sDATE_FORMAT.replace('yyyy', 'yy');
					sDATE_FORMAT = sDATE_FORMAT.replace('MMMM', 'XX');  // Temp variables. 
					sDATE_FORMAT = sDATE_FORMAT.replace('MMM' , 'X' );
					sDATE_FORMAT = sDATE_FORMAT.replace('MM'  , 'mm');
					sDATE_FORMAT = sDATE_FORMAT.replace('M'   , 'm' );
					sDATE_FORMAT = sDATE_FORMAT.replace('XX'  , 'MM');  // Temp variables. 
					sDATE_FORMAT = sDATE_FORMAT.replace('X'   , 'M' );
					var bAMPM        = (sTIME_FORMAT.indexOf('t') >= 0) || (sTIME_FORMAT.indexOf('T') >= 0);
					$('#' + txt.id).datetimepicker( { dateFormat: sDATE_FORMAT, timeFormat: sTIME_FORMAT, ampm: bAMPM } );
					// 05/05/2013 Paul.  Add format for debugging. 
					//tdField.appendChild(document.createTextNode(sDATE_FORMAT + ' ' + sTIME_FORMAT));
					if ( bUI_REQUIRED )
					{
						var reqNAME = document.createElement('span');
						reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
						reqNAME.className         = 'required';
						reqNAME.style.paddingLeft = '4px';
						reqNAME.style.display     = 'none';
						reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
						tdField.appendChild(reqNAME);
					}
				}
				else if ( sFIELD_TYPE == 'ListBox' )
				{
					if ( sLIST_NAME != null )
					{
						var lst = document.createElement('select');
						tdField.appendChild(lst);
						lst.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
						// 08/03/2017 Paul.  We need a way to insert NONE into the a ListBox while still allowing multiple rows. 
						// The trick will be to use a negative number.  Use an absolute value here to reduce the areas to fix. 
						if ( Math.abs(nFORMAT_ROWS) > 0 )
						{
							lst.multiple = 'multiple';
							lst.size     = Math.abs(nFORMAT_ROWS);
						}
						if ( nFORMAT_TAB_INDEX > 0 )
						{
							lst.tabindex = nFORMAT_TAB_INDEX;
						}
						// 04/08/2017 Paul.  Use Bootstrap for responsive design.
						if ( SplendidDynamic.BootstrapLayout() )
							lst.className = 'form-control';
						var sDATA_VALUE = null;
						if ( row != null && row[sDATA_FIELD] != null )
							sDATA_VALUE = row[sDATA_FIELD];
						// 09/27/2012 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
						if ( !Sql.IsEmptyString(sPARENT_FIELD) )
						{
							var lstPARENT_FIELD = document.getElementById(sLayoutPanel + '_ctlEditView_' + sPARENT_FIELD);
							if ( lstPARENT_FIELD != null )
							{
								sLIST_NAME = lstPARENT_FIELD.options[lstPARENT_FIELD.options.selectedIndex].value;
								lstPARENT_FIELD.onchange = BindArguments(function(lst, lstPARENT_FIELD, bUI_REQUIRED)
								{
									lst.options.length = 0;
									var sLIST_NAME = lstPARENT_FIELD.options[lstPARENT_FIELD.options.selectedIndex].value;
									var arrLIST = L10n.GetList(sLIST_NAME);
									if ( arrLIST != null )
									{
										// 04/23/2017 Paul.  We don't need a NONE record when using multi-selection. 
										if ( !bUI_REQUIRED && nFORMAT_ROWS <= 0 )
										{
											var opt = document.createElement('option');
											lst.appendChild(opt);
											opt.setAttribute('value', '');
											opt.innerHTML = L10n.Term('.LBL_NONE');
											if ( sDATA_VALUE != null && sDATA_VALUE == '' )
												opt.setAttribute('selected', 'selected');
										}
										for ( var i = 0; i < arrLIST.length; i++ )
										{
											var opt = document.createElement('option');
											lst.appendChild(opt);
											opt.setAttribute('value', arrLIST[i]);
											// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
											opt.innerHTML = L10n.ListTerm(sLIST_NAME, arrLIST[i]);
											if ( sDATA_VALUE != null && sDATA_VALUE == arrLIST[i] )
												opt.setAttribute('selected', 'selected');
										}
									}
								}, lst, lstPARENT_FIELD, bUI_REQUIRED);
							}
						}
						var arrLIST = L10n.GetList(sLIST_NAME);
						if ( arrLIST != null )
						{
							// 04/23/2017 Paul.  We don't need a NONE record when using multi-selection. 
							// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
							if ( (!bUI_REQUIRED || Sql.ToString(sDATA_FORMAT).toLowerCase().indexOf('force') >= 0) && nFORMAT_ROWS <= 0 )
							{
								// 01/08/2018 Paul.  Some lists have the first entry as a blank. 
								if ( !(arrLIST.length > 0 && Sql.IsEmptyString(arrLIST[0])) )
								{
									var opt = document.createElement('option');
									lst.appendChild(opt);
									opt.setAttribute('value', '');
									opt.innerHTML = L10n.Term('.LBL_NONE');
									if ( sDATA_VALUE != null && sDATA_VALUE == '' )
										opt.setAttribute('selected', 'selected');
								}
							}
							// 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV. 
							if ( Math.abs(nFORMAT_ROWS) > 0 && Sql.ToString(sDATA_FORMAT).toLowerCase().indexOf('csv') >= 0 )
							{
								// 01/06/2018 Paul.  We are removing form-control. 
								lst.className = 'multiple-select';
								var arrDATA_VALUES = new Array();
								if ( sDATA_VALUE != null )
									arrDATA_VALUES = sDATA_VALUE.split(',');
								for ( var i = 0; i < arrLIST.length; i++ )
								{
									var opt = document.createElement('option');
									lst.appendChild(opt);
									opt.setAttribute('value', arrLIST[i]);
									opt.innerHTML = L10n.ListTerm(sLIST_NAME, arrLIST[i]);
									for ( var j = 0; j < arrDATA_VALUES.length; j++ )
									{
										if ( arrDATA_VALUES[j] != null && arrDATA_VALUES[j] == arrLIST[i] )
										{
											opt.setAttribute('selected', 'selected');
											break;
										}
									}
								}
								var sALL_SELECTED   = L10n.Term(".LBL_ALL_SELECTED"  );
								var sCOUNT_SELECTED = L10n.Term(".LBL_COUNT_SELECTED");
								$(lst).multipleSelect({selectAll: false, width: '100%', minimumCountSelected: 10, allSelected: sALL_SELECTED, countSelected: sCOUNT_SELECTED });
							}
							// 06/08/2018 Paul.  Expand XML values from ListBox. 
							else if ( Math.abs(nFORMAT_ROWS) > 0 && sDATA_VALUE != null && StartsWith(sDATA_VALUE, '<?xml') )
							{
								var xmlVALUES = $.parseXML(sDATA_VALUE);
								var arrDATA_VALUES = new Array();
								$(xmlVALUES).find('Value').each(function()
								{
									arrDATA_VALUES.push($(this).text());
								});
								lst.className = 'multiple-select';
								for ( var i = 0; i < arrLIST.length; i++ )
								{
									var opt = document.createElement('option');
									lst.appendChild(opt);
									opt.setAttribute('value', arrLIST[i]);
									opt.innerHTML = L10n.ListTerm(sLIST_NAME, arrLIST[i]);
									for ( var j = 0; j < arrDATA_VALUES.length; j++ )
									{
										if ( arrDATA_VALUES[j] != null && arrDATA_VALUES[j] == arrLIST[i] )
										{
											opt.setAttribute('selected', 'selected');
											break;
										}
									}
								}
								var sALL_SELECTED   = L10n.Term(".LBL_ALL_SELECTED"  );
								var sCOUNT_SELECTED = L10n.Term(".LBL_COUNT_SELECTED");
								$(lst).multipleSelect({selectAll: false, width: '100%', minimumCountSelected: 10, allSelected: sALL_SELECTED, countSelected: sCOUNT_SELECTED });
							}
							else
							{
								for ( var i = 0; i < arrLIST.length; i++ )
								{
									var opt = document.createElement('option');
									lst.appendChild(opt);
									opt.setAttribute('value', arrLIST[i]);
									// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
									opt.innerHTML = L10n.ListTerm(sLIST_NAME, arrLIST[i]);
									if ( sDATA_VALUE != null && sDATA_VALUE == arrLIST[i] )
										opt.setAttribute('selected', 'selected');
								}
							}
							// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
							if ( bUI_REQUIRED || Sql.ToString(sDATA_FORMAT).toLowerCase().indexOf('force') >= 0 )
							{
								var reqNAME = document.createElement('span');
								reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
								reqNAME.className         = 'required';
								reqNAME.style.paddingLeft = '4px';
								reqNAME.style.display     = 'none';
								reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
								tdField.appendChild(reqNAME);
							}
						}
						// 09/27/2012 Paul. Allow onchange code to be stored in the database.  
						if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
						{
							lst.onchange = BindArguments(function(sONCLICK_SCRIPT)
							{
								if ( StartsWith(sONCLICK_SCRIPT, 'return ') )
									sONCLICK_SCRIPT = sONCLICK_SCRIPT.substring(7);
								eval(sONCLICK_SCRIPT);
							}, sONCLICK_SCRIPT);
						}
					}
				}
				// 08/01/2013 Paul.  Add support for CheckBoxList. 
				else if ( sFIELD_TYPE == 'CheckBoxList' )
				{
					if ( sLIST_NAME != null )
					{
						var lst = document.createElement('div');
						tdField.appendChild(lst);
						lst.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
						if ( nFORMAT_ROWS > 0 )
						{
							lst.style.height    = nFORMAT_ROWS.toString() + 'px';
							lst.style.overflowY = 'auto';
						}
						if ( nFORMAT_TAB_INDEX > 0 )
						{
							lst.tabindex = nFORMAT_TAB_INDEX;
						}
						var sDATA_VALUE = null;
						if ( row != null && row[sDATA_FIELD] != null )
							sDATA_VALUE = row[sDATA_FIELD];
						var arrLIST = L10n.GetList(sLIST_NAME);
						if ( arrLIST != null )
						{
							for ( var i = 0; i < arrLIST.length; i++ )
							{
								var chk = document.createElement('input');
								// 06/18/2011 Paul.  IE requires that the input type be defined prior to appending the field. 
								chk.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_' + arrLIST[i];
								chk.type      = 'checkbox';
								chk.className = 'checkbox';
								// 04/08/2017 Paul.  Use Bootstrap for responsive design.
								if ( SplendidDynamic.BootstrapLayout() )
								{
									chk.style.transform = 'scale(1.5)';
									// 05/30/2018 Paul.  Disable new line after checkbox. 
									chk.style.display = 'inline';
								}
								lst.appendChild(chk);
								chk.setAttribute('value', arrLIST[i]);
								var lab = document.createElement('label');
								lab.setAttribute('for', chk.id);
								lst.appendChild(lab);
								lab.innerHTML = '&nbsp;' + L10n.ListTerm(sLIST_NAME, arrLIST[i]) + '&nbsp;';
								// 05/30/2018 Paul.  Format 1 means horizontal span. 
								if ( sDATA_FORMAT != '1' )
								{
									var br = document.createElement('br');
									lst.appendChild(br);
								}
							}
							// 06/03/2018 Paul.  REPEAT_DOW is a special list that returns 0 = sunday, 1 = monday, etc. 
							if ( sDATA_VALUE != null && sDATA_FIELD == 'REPEAT_DOW' )
							{
								for ( var i = 0; i < sDATA_VALUE.length; i++ )
								{
									var chk = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_' + sDATA_VALUE[i]);
									if ( chk != null )
										chk.checked = true;
								}
							}
							// 08/01/2013 Paul.  Expand XML values from CheckBoxList. 
							else if ( sDATA_VALUE != null && StartsWith(sDATA_VALUE, '<?xml') )
							{
								var xmlVALUES = $.parseXML(sDATA_VALUE);
								$(xmlVALUES).find('Value').each(function()
								{
									var chk = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_' + $(this).text());
									if ( chk != null )
										chk.checked = true;
								});
							}
							if ( bUI_REQUIRED && nFORMAT_ROWS > 0 )
							{
								var reqNAME = document.createElement('span');
								reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
								reqNAME.className         = 'required';
								reqNAME.style.paddingLeft = '4px';
								reqNAME.style.display     = 'none';
								reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
								tdField.appendChild(reqNAME);
							}
						}
					}
				}
				// 08/01/2013 Paul.  Add support for Radio. 
				else if ( sFIELD_TYPE == 'Radio' )
				{
					if ( sLIST_NAME != null )
					{
						var lst = document.createElement('div');
						tdField.appendChild(lst);
						lst.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
						if ( nFORMAT_ROWS > 0 )
						{
							lst.style.height    = nFORMAT_ROWS.toString() + 'px';
							lst.style.overflowY = 'auto';
						}
						if ( nFORMAT_TAB_INDEX > 0 )
						{
							lst.tabindex = nFORMAT_TAB_INDEX;
						}
						var sDATA_VALUE = null;
						if ( row != null && row[sDATA_FIELD] != null )
							sDATA_VALUE = row[sDATA_FIELD];
						var arrLIST = L10n.GetList(sLIST_NAME);
						if ( arrLIST != null )
						{
							if ( !bUI_REQUIRED )
							{
								var rad = document.createElement('input');
								rad.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_';
								rad.name      = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
								rad.type      = 'radio';
								rad.className = 'radio';
								lst.appendChild(rad);
								rad.setAttribute('value', '');
								var lab = document.createElement('label');
								lab.setAttribute('for', rad.id);
								lst.appendChild(lab);
								lab.innerHTML = L10n.Term('.LBL_NONE');
								var br = document.createElement('br');
								lst.appendChild(br);
								if ( sDATA_VALUE == null || sDATA_VALUE == '' )
									rad.checked = true;
							}
							for ( var i = 0; i < arrLIST.length; i++ )
							{
								var rad = document.createElement('input');
								// 06/18/2011 Paul.  IE requires that the input type be defined prior to appending the field. 
								rad.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_' + arrLIST[i];
								rad.name      = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
								rad.type      = 'radio';
								rad.className = 'radio';
								lst.appendChild(rad);
								rad.setAttribute('value', arrLIST[i]);
								var lab = document.createElement('label');
								lab.setAttribute('for', rad.id);
								lst.appendChild(lab);
								lab.innerHTML = L10n.ListTerm(sLIST_NAME, arrLIST[i]);
								var br = document.createElement('br');
								lst.appendChild(br);
								if ( sDATA_VALUE == arrLIST[i] )
									rad.checked = true;
							}
							if ( bUI_REQUIRED && nFORMAT_ROWS > 0 )
							{
								var reqNAME = document.createElement('span');
								reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
								reqNAME.className         = 'required';
								reqNAME.style.paddingLeft = '4px';
								reqNAME.style.display     = 'none';
								reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
								tdField.appendChild(reqNAME);
							}
						}
					}
				}
				else if ( sFIELD_TYPE == 'CheckBox' )
				{
					var chk = document.createElement('input');
					// 06/18/2011 Paul.  IE requires that the input type be defined prior to appending the field. 
					chk.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
					chk.type      = 'checkbox';
					chk.className = 'checkbox';
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
					{
						chk.style.transform = 'scale(1.5)';
						// 05/30/2018 Paul.  Disable new line after checkbox. 
						chk.style.display = 'inline';
					}
					// 09/25/2011 Paul.  IE does not allow you to set the type after it is added to the document. 
					tdField.appendChild(chk);
					if ( nFORMAT_TAB_INDEX > 0 ) chk.tabindex  = nFORMAT_TAB_INDEX;
					var sDATA_VALUE = 'false';
					if ( row != null && row[sDATA_FIELD] != null )
					{
						sDATA_VALUE = row[sDATA_FIELD];
					}
					// 07/02/2018 Paul.  Allow defaults to display as checked for Opt Out and Do Not Call. 
					else if ( row == null )
					{
						if (sDATA_FIELD == 'EMAIL_OPT_OUT' )
						{
							sDATA_VALUE = Crm.Config.ToBoolean('default_email_opt_out');
						}
						else if (sDATA_FIELD == 'DO_NOT_CALL' )
						{
							sDATA_VALUE = Crm.Config.ToBoolean('default_do_not_call');
						}
					}
					chk.checked = Sql.ToBoolean(sDATA_VALUE);
					// 03/10/2013 Paul. Add support for onClick. 
					if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
					{
						chk.onclick = BindArguments(function(sONCLICK_SCRIPT)
						{
							if ( StartsWith(sONCLICK_SCRIPT, 'return ') )
								sONCLICK_SCRIPT = sONCLICK_SCRIPT.substring(7);
							eval(sONCLICK_SCRIPT);
						}, sONCLICK_SCRIPT);
					}
				}
				else if ( sFIELD_TYPE == 'Label' )
				{
					var lbl = document.createElement('span');
					lbl.id        = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
					tdField.appendChild(lbl);
					if ( sDATA_FIELD.indexOf('.') > 0 )
						lbl.innerHTML = L10n.Term(sDATA_FIELD);
					else if ( row != null && row[sDATA_FIELD] != null )
						lbl.innerHTML = row[sDATA_FIELD];
				}
				// 05/27/2016 Paul.  Add support for File type. 
				else if ( sFIELD_TYPE == 'File' )
				{
					// 05/27/2016 Paul.  This code is similar to that used by ChatDashboardUI.js 
					var hidUploadNAME  = document.createElement('input');
					hidUploadNAME.id   = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_NAME';
					hidUploadNAME.type = 'hidden';
					tdField.appendChild(hidUploadNAME);
					var hidUploadTYPE  = document.createElement('input');
					hidUploadTYPE.id   = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_TYPE';
					hidUploadTYPE.type = 'hidden';
					tdField.appendChild(hidUploadTYPE);
					var hidUploadDATA  = document.createElement('input');
					hidUploadDATA.id   = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_DATA';
					hidUploadDATA.type = 'hidden';
					tdField.appendChild(hidUploadDATA);
					var hidUploadOLD_VALUE  = document.createElement('input');
					hidUploadOLD_VALUE.id   = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_OLD_VALUE';
					hidUploadOLD_VALUE.type = 'hidden';
					tdField.appendChild(hidUploadOLD_VALUE);

					var fileUpload = document.createElement('input');
					fileUpload.id      = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
					fileUpload.type    = 'file';
					fileUpload.onchange = BindArguments(function(fileUpload, sLayoutPanel, sDATA_FIELD)
					{
						EditViewFileUploadEvent(fileUpload, sLayoutPanel, sDATA_FIELD);
					}, fileUpload, sLayoutPanel, sDATA_FIELD);
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						fileUpload.className = 'form-control';
					tdField.appendChild(fileUpload);
					var btnFileClear = document.createElement('button');
					btnFileClear.className = 'button';
					btnFileClear.innerHTML = L10n.Term('.LBL_CLEAR_BUTTON_LABEL');
					btnFileClear.onclick = BindArguments(function(sDATA_FIELD)
					{
						var hidUploadNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_NAME');
						var hidUploadTYPE = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_TYPE');
						var hidUploadDATA = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_DATA');
						var fileUpload    = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
						hidUploadNAME.value = '';
						hidUploadTYPE.value = '';
						hidUploadDATA.value = '';
						EditViewClearFileInput(fileUpload, sLayoutPanel, sDATA_FIELD);
						return false;
					}, sDATA_FIELD);
					var br = document.createElement('br');
					tdField.appendChild(br);
					if ( bUI_REQUIRED )
					{
						var reqNAME = document.createElement('span');
						reqNAME.id                = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_REQUIRED';
						reqNAME.className         = 'required';
						reqNAME.style.paddingLeft = '4px';
						reqNAME.style.display     = 'none';
						reqNAME.innerHTML         = L10n.Term('.ERR_REQUIRED_FIELD');
						tdField.appendChild(reqNAME);
					}
					if ( row != null && row[sDATA_FIELD] != null )
					{
						sDATA_VALUE = row[sDATA_FIELD];
						hidUploadOLD_VALUE.value = sDATA_VALUE;
						var lnk = document.createElement('a');
						lnk.href = sREMOTE_SERVER + 'Images/Image.aspx?ID=' + sDATA_VALUE;
						lnk.innerHTML = sDATA_VALUE;
						tdField.appendChild(lnk);
						Crm.Modules.ItemName('Images', sDATA_VALUE, function(status, message)
						{
							if ( status == 1 )
							{
								lnk.innerHTML = message;
							}
						}, this);
					}
				}
				else
				{
					//08/31/2012 Paul.  Add debugging code. 
					//alert('Unknown field type: ' + sFIELD_TYPE);
				}
			}
			catch(e)
			{
				SplendidError.SystemAlert(e, sFIELD_TYPE + ' ' + sDATA_FIELD);
			}
			// 12/02/2007 Paul.  Each view can now have its own number of data columns. 
			// This was needed so that search forms can have 4 data columns. The default is 2 columns. 
			if ( nCOLSPAN > 0 )
				nColIndex += nCOLSPAN;
			else if ( nCOLSPAN == 0 )
				nColIndex++;
			if ( nColIndex >= nDATA_COLUMNS )
				nColIndex = 0;
		}
		// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
		for ( var nLayoutIndex in layout )
		{
			var lay = layout[nLayoutIndex];
			var sFORM_SCRIPT = lay.SCRIPT;
			if ( !Sql.IsEmptyString(sFORM_SCRIPT) )
			{
				// 11/24/2017 Paul.  Need to replace all occurrences. 
				sFORM_SCRIPT = sFORM_SCRIPT.replace(/SPLENDID_EDITVIEW_LAYOUT_ID/g, sLayoutPanel + '_ctlEditView');
				// 01/18/2018 Paul.  If wrapped, then treat FORM_SCRIPT as a function. 
				sFORM_SCRIPT = Trim(sFORM_SCRIPT);
				if ( StartsWith(sFORM_SCRIPT, '(') && EndsWith(sFORM_SCRIPT, ')') )
				{
					//console.log('Evaluating form script as function.');
					var fnFORM_SCRIPT = eval(sFORM_SCRIPT);
					if ( typeof(fnFORM_SCRIPT) == 'function' )
					{
						// 01/18/2018 Paul.  Execute the script, but if an object is returned, then it just created a function, not execute it. 
						this.FORM_SCRIPT = fnFORM_SCRIPT();
						if ( this.FORM_SCRIPT !== undefined && typeof(this.FORM_SCRIPT.Initialize) == 'function' )
						{
							//console.log('Executing form script Initialize function.');
							this.FORM_SCRIPT.Initialize();
						}
						else
						{
							//console.log('Executed form script as function.');
							this.FORM_SCRIPT = null;
						}
					}
					else
					{
						console.log('Form script not a function and will not be executed.');
					}
				}
				else
				{
					//console.log('Executing form script as raw script.');
					eval(sFORM_SCRIPT);
				}
			}
			break;
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'EditViewUI.LoadView');
	}
}

function EditViewFileUploadEvent(fileUpload, sLayoutPanel, sDATA_FIELD)
{
	try
	{
		var files = fileUpload.files;
		if ( files.length > 0 )
		{
			var file = files[0];
			if ( file.size > Crm.Config.ToInteger('upload_maxsize') )
			{
				alert('uploaded file was too big: max filesize: ' + Crm.Config.ToInteger('upload_maxsize'));
				var fileUpload = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD);
				EditViewClearFileInput(fileUpload, sLayoutPanel, sDATA_FIELD);
				return;
			}
			else //if ( file.type.match(/image.*/) )
			{
				// http://www.javascripture.com/FileReader
				var reader = new FileReader();
				reader.onload = function()
				{
					var arrayBuffer = reader.result;
					var hidUploadNAME = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_NAME');
					var hidUploadTYPE = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_TYPE');
					var hidUploadDATA = document.getElementById(sLayoutPanel + '_ctlEditView_' + sDATA_FIELD + '_DATA');
					hidUploadNAME.value = file.name;
					hidUploadTYPE.value = file.type;
					hidUploadDATA.value = base64ArrayBuffer(arrayBuffer);
					//alert(file.name + ' -> ' + file.type);
				};
				reader.readAsArrayBuffer(file);
			}
		}
	}
	catch(e)
	{
		alert(e.message);
	}
}

function EditViewClearFileInput(ctl, sLayoutPanel, sDATA_FIELD)
{
	// http://stackoverflow.com/questions/1703228/how-to-clear-file-input-with-javascript
	try
	{
		ctl.value = null;
	}
	catch(e)
	{
	}
	if ( ctl.value )
	{
		var fileUpload = ctl.cloneNode(true)
		ctl.parentNode.replaceChild(fileUpload, ctl);
		fileUpload.onchange = BindArguments(function(fileUpload, sLayoutPanel, sDATA_FIELD)
		{
			EditViewFileUploadEvent(fileUpload, sLayoutPanel, sDATA_FIELD);
		}, fileUpload, sLayoutPanel, sDATA_FIELD);
	}
}

EditViewUI.prototype.LoadLineItems = function(sLayoutPanel, sActionsPanel, tblMain, sEDIT_NAME, sMODULE_NAME, sID, row, callback)
{
	try
	{
		if ( sMODULE_NAME == 'Quotes' || sMODULE_NAME == 'Orders' || sMODULE_NAME == 'Invoices' || (sMODULE_NAME == 'Opportunities' && Crm.Config.ToString('OpportunitiesMode') == 'Revenue') )
		{
			//console.log(dumpObj(row.LineItems, 'row.LineItems'));
			var sGRID_NAME = sMODULE_NAME + '.LineItems';
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.ListView_LoadLayout(sGRID_NAME, function(status, message)
			{
				if ( status == 1 )
				{
					layout = message;
					var sPRIMARY_ID = sID;
					var sRELATED_MODULE = sMODULE_NAME + 'LineItems';
					var rowLineItems    = row != null ? row.LineItems : null;
					
					var divEditLineItemsView = document.createElement('div');
					var divMainLayoutPanel   = document.getElementById(sLayoutPanel);
					var divEditSubPanel      = document.getElementById(sLayoutPanel + '_divEditSubPanel');
					divMainLayoutPanel.insertBefore(divEditLineItemsView, divEditSubPanel);
					
					var oEditLineItemsViewUI = new EditLineItemsViewUI();
					oEditLineItemsViewUI.SORT_FIELD     = 'POSITION';
					oEditLineItemsViewUI.GRID_NAME      = sGRID_NAME;
					oEditLineItemsViewUI.HIDE_VIEW_EDIT = true;
					oEditLineItemsViewUI.HIDE_DELETE    = true;
					oEditLineItemsViewUI.Render(sLayoutPanel, sActionsPanel, sRELATED_MODULE, layout, divEditLineItemsView, rowLineItems, row, sMODULE_NAME, sPRIMARY_ID);
					
					if ( sMODULE_NAME == 'Quotes' || sMODULE_NAME == 'Orders' || sMODULE_NAME == 'Invoices' )
					{
						var tblForm = document.createElement('table');
						var tbody   = document.createElement('tbody');
						var tr      = document.createElement('tr');
						var td      = document.createElement('td');
						tblForm.className   = 'tabForm';
						tblForm.cellSpacing = 1;
						tblForm.cellPadding = 0;
						tblForm.border      = 0;
						tblForm.width       = '100%';
						tblForm.style.marginTop = '4px';
						tblForm.appendChild(tbody);
						tbody.appendChild(tr);
						tr.appendChild(td);
						divMainLayoutPanel.insertBefore(tblForm, divEditSubPanel);
						var ctlEditDescription_tblMain = document.createElement('table');
						ctlEditDescription_tblMain.id        = sLayoutPanel + '_ctlEditDescription_tblMain';
						ctlEditDescription_tblMain.width     = '100%';
						ctlEditDescription_tblMain.className = 'tabEditView';
						td.appendChild(ctlEditDescription_tblMain);
						bgPage.EditView_LoadLayout(sEDIT_NAME.replace('.EditView', '.EditDescription'), function(status, message)
						{
							if ( status == 1 )
							{
								var layout = message;
								this.LoadView(sLayoutPanel, ctlEditDescription_tblMain, layout, row);
							}
							if ( callback != null )
							{
								callback(1, null);
							}
						}, this);
					}
					else
					{
						if ( callback != null )
						{
							callback(1, null);
						}
					}
				}
			}, this);
		}
		else
		{
			// 06/20/2015 Paul.  Call the callback when done. 
			if ( callback != null )
			{
				callback(1, null);
			}
		}
	}
	catch(e)
	{
		console.log(e.message);
		callback(-1, SplendidError.FormatError(e, 'EditViewUI.LoadLineItems'));
	}
}

EditViewUI.prototype.LoadItem = function(sLayoutPanel, sActionsPanel, layout, sEDIT_NAME, sMODULE_NAME, sID, sSubmitID, callback)
{
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		if ( !Sql.IsEmptyString(sID) )
		{
			bgPage.EditView_LoadItem(sMODULE_NAME, sID, function(status, message)
			{
				if ( status == 1 )
				{
					// 10/04/2011 Paul.  EditViewUI.LoadItem returns the row. 
					var row = message;
					// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
					if ( SplendidDynamic.StackedLayout(Security.USER_THEME(), sEDIT_NAME) )
						DynamicButtonsUI_Clear(sLayoutPanel + '_Header_' + sActionsPanel);
					DynamicButtonsUI_Clear(sActionsPanel);
					this.Clear(sLayoutPanel);
					// 12/06/2014 Paul.  LayoutMode is used on the Mobile view. 
					ctlActiveMenu.ActivateTab(sMODULE_NAME, sID, 'EditView', this);
					// 01/30/2013 Paul.  Clicking on the sub-title will refresh the view as a way to correct bugs in the rendering. 
					SplendidUI_ModuleHeader(sLayoutPanel, sActionsPanel, sMODULE_NAME, Sql.ToString(row['NAME']), Sql.ToString(row['ID']));
					// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
					DynamicButtonsUI_Load(sLayoutPanel, sActionsPanel, 'EditHeader', sEDIT_NAME, row, this.PageCommand, function(status, message)
					{
						if ( status != 1 )
							callback(status, message);
					}, this);
					
					//var layout  = bgPage.SplendidCache.EditViewFields(sEDIT_NAME);
					var tblMain = document.getElementById(sLayoutPanel + '_ctlEditView_tblMain');
					this.LoadView(sLayoutPanel, tblMain, layout, row, sSubmitID);
					// 02/27/2016 Paul.  Add support for Quotes, Orders and Invoices. 
					this.LoadLineItems(sLayoutPanel, sActionsPanel, tblMain, sEDIT_NAME, sMODULE_NAME, sID, row, function(status, message)
					{
						// 06/20/2015 Paul.  Call the callback when done. 
						if ( callback != null )
						{
							callback(1, null);
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
			this.Clear(sLayoutPanel);
			ctlActiveMenu.ActivateTab(sMODULE_NAME, sID, 'EditView', this);
			
			var row = null;
			SplendidUI_ModuleHeader(sLayoutPanel, sActionsPanel, sMODULE_NAME, '');
			// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
			DynamicButtonsUI_Load(sLayoutPanel, sActionsPanel, 'EditHeader', sEDIT_NAME, row, this.PageCommand, function(status, message)
			{
				if ( status != 1 )
					callback(status, message);
			}, this);
			
			//var layout  = bgPage.SplendidCache.EditViewFields(sEDIT_NAME);
			var tblMain = document.getElementById(sLayoutPanel + '_ctlEditView_tblMain');
			this.LoadView(sLayoutPanel, tblMain, layout, row, sSubmitID);
			// 02/27/2016 Paul.  Add support for Quotes, Orders and Invoices. 
			this.LoadLineItems(sLayoutPanel, sActionsPanel, tblMain, sEDIT_NAME, sMODULE_NAME, sID, row, function(status, message)
			{
				// 06/20/2015 Paul.  Call the callback when done. 
				if ( callback != null )
				{
					callback(1, null);
				}
			}, this);
		}
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'EditViewUI.LoadItem'));
	}
}

EditViewUI.prototype.LoadObject = function(sLayoutPanel, sActionsPanel, sEDIT_NAME, sMODULE_NAME, row, sSubmitID, PageCommand, callback)
{
	try
	{
		this.MODULE = sMODULE_NAME;
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.Terminology_LoadModule(sMODULE_NAME, function(status, message)
		{
			if ( status == 0 || status == 1 )
			{
				bgPage.EditView_LoadLayout(sEDIT_NAME, function(status, message)
				{
					if ( status == 1 )
					{
						// 10/03/2011 Paul.  EditView_LoadLayout returns the layout. 
						var layout = message;
						// 07/30/2013 Paul.  Check for layout not row. 
						if ( layout != null )
						{
							// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
							if ( SplendidDynamic.StackedLayout(Security.USER_THEME(), sEDIT_NAME) )
								DynamicButtonsUI_Clear(sLayoutPanel + '_Header_' + sActionsPanel);
							DynamicButtonsUI_Clear(sActionsPanel);
							this.Clear(sLayoutPanel);
							// 12/06/2014 Paul.  LayoutMode is used on the Mobile view. 
							var sID = Sql.ToString(row['ID']);
							ctlActiveMenu.ActivateTab(sMODULE_NAME, sID, 'EditView', this);
							SplendidUI_ModuleHeader(sLayoutPanel, sActionsPanel, sMODULE_NAME, '');
							// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
							DynamicButtonsUI_Load(sLayoutPanel, sActionsPanel, 'EditHeader', sEDIT_NAME, row, PageCommand, function(status, message)
							{
							}, this);
							
							//var layout  = bgPage.SplendidCache.EditViewFields(sEDIT_NAME);
							var tblMain = document.getElementById(sLayoutPanel + '_ctlEditView_tblMain');
							this.LoadView(sLayoutPanel, tblMain, layout, row, sSubmitID);
							
							callback(status, message);
						}
						else
						{
							callback(-1, message);
						}
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
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'EditViewUI.LoadObject'));
	}
}

EditViewUI.prototype.Load = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE)
{
	try
	{
		this.MODULE    = null;
		this.ID        = null;
		this.DUPLICATE = false;
		// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
		this.LAST_DATE_MODIFIED = null;
		
		var bgPage = chrome.extension.getBackgroundPage();
		// 11/29/2011 Paul.  We are having an issue with the globals getting reset, so we need to re-initialize. 
		if ( !bgPage.SplendidCache.IsInitialized() )
		{
			SplendidUI_ReInit(sLayoutPanel, sActionsPanel, sMODULE_NAME);
			return;
		}
		
		this.MODULE    = sMODULE_NAME;
		this.ID        = sID         ;
		this.DUPLICATE = bDUPLICATE  ;
		// 10/04/2011 Paul.  The session might have timed-out, so first check if we are authenticated. 
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				bgPage.Terminology_LoadModule(sMODULE_NAME, function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						var sEDIT_NAME = sMODULE_NAME + '.EditView' + sPLATFORM_LAYOUT;
						bgPage.EditView_LoadLayout(sEDIT_NAME, function(status, message)
						{
							if ( status == 1 )
							{
								// 10/03/2011 Paul.  EditView_LoadLayout returns the layout. 
								var layout = message;
								this.LoadItem(sLayoutPanel, sActionsPanel, layout, sEDIT_NAME, sMODULE_NAME, sID, 'btnDynamicButtons_Save', function(status, message)
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
		SplendidError.SystemError(e, 'EditViewUI.Load');
	}
}

// 06/20/2015 Paul.  Same code, but allows for a callback. 
EditViewUI.prototype.LoadWithCallback = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, bDUPLICATE, callback, context)
{
	try
	{
		this.MODULE    = null;
		this.ID        = null;
		this.DUPLICATE = false;
		// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
		this.LAST_DATE_MODIFIED = null;
		
		var bgPage = chrome.extension.getBackgroundPage();
		// 11/29/2011 Paul.  We are having an issue with the globals getting reset, so we need to re-initialize. 
		if ( !bgPage.SplendidCache.IsInitialized() )
		{
			SplendidUI_ReInit(sLayoutPanel, sActionsPanel, sMODULE_NAME);
			return;
		}
		
		this.MODULE    = sMODULE_NAME;
		this.ID        = sID         ;
		this.DUPLICATE = bDUPLICATE  ;
		// 10/04/2011 Paul.  The session might have timed-out, so first check if we are authenticated. 
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				bgPage.Terminology_LoadModule(sMODULE_NAME, function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						var sEDIT_NAME = sMODULE_NAME + '.EditView' + sPLATFORM_LAYOUT;
						bgPage.EditView_LoadLayout(sEDIT_NAME, function(status, message)
						{
							if ( status == 1 )
							{
								// 10/03/2011 Paul.  EditView_LoadLayout returns the layout. 
								var layout = message;
								this.LoadItem(sLayoutPanel, sActionsPanel, layout, sEDIT_NAME, sMODULE_NAME, sID, 'btnDynamicButtons_Save', function(status, message)
								{
									callback.call(context||this, status, message);
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
						callback.call(context||this, status, message);
					}
				}, this);
			}
			else
			{
				callback.call(context||this, status, message);
			}
		}, this);
	}
	catch(e)
	{
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'EditViewUI.Load'));
	}
}

// 03/30/2016 Paul.  Convert requires special processing. 
EditViewUI.prototype.Convert = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sSOURCE_MODULE_NAME, sSOURCE_ID, sConvertToModule, bDUPLICATE)
{
	console.log('EditViewUI.Convert ' + sMODULE_NAME + ' ' + sSOURCE_MODULE_NAME + ' ' + sSOURCE_ID);
	try
	{
		this.MODULE    = null;
		this.ID        = null;
		this.DUPLICATE = false;
		this.LAST_DATE_MODIFIED = null;
		
		this.MODULE    = sMODULE_NAME;
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				bgPage.Terminology_LoadModule(sMODULE_NAME, function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						var sEDIT_NAME = sMODULE_NAME + '.EditView' + sPLATFORM_LAYOUT;
						bgPage.EditView_LoadLayout(sEDIT_NAME, function(status, message)
						{
							if ( status == 1 )
							{
								// 10/03/2011 Paul.  EditView_LoadLayout returns the layout. 
								var layout = message;
								bgPage.EditView_ConvertItem(sMODULE_NAME, sSOURCE_MODULE_NAME, sSOURCE_ID, function(status, message)
								{
									if ( status == 1 )
									{
										var row = message;
										if ( SplendidDynamic.StackedLayout(Security.USER_THEME(), sEDIT_NAME) )
											DynamicButtonsUI_Clear(sLayoutPanel + '_Header_' + sActionsPanel);
										DynamicButtonsUI_Clear(sActionsPanel);
										this.Clear(sLayoutPanel);
										ctlActiveMenu.ActivateTab(sMODULE_NAME, null, 'EditView', this);
										SplendidUI_ModuleHeader(sLayoutPanel, sActionsPanel, sMODULE_NAME, Sql.ToString(row['NAME']), '');
										DynamicButtonsUI_Load(sLayoutPanel, sActionsPanel, 'EditHeader', sEDIT_NAME, row, this.PageCommand, function(status, message)
										{
											if ( status != 1 )
												SplendidError.SystemMessage(message);
										}, this);
										
										var tblMain = document.getElementById(sLayoutPanel + '_ctlEditView_tblMain');
										this.LoadView(sLayoutPanel, tblMain, layout, row, 'btnDynamicButtons_Save');
										this.LoadLineItems(sLayoutPanel, sActionsPanel, tblMain, sEDIT_NAME, sMODULE_NAME, null, row, function(status, message)
										{
											SplendidError.SystemMessage('');
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
		SplendidError.SystemError(e, 'EditViewUI.Load');
	}
}

