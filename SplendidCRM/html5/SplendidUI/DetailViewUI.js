/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function DetailViewUI()
{
	this.MODULE  = null;
	this.ID      = null;
	// 02/26/2016 Paul.  OfficeAddin will disable the ActivateTab call. 
	this.ActivateTab = true;
	// 03/19/2016 Paul.  Allow the frame to be different for OfficeAddin. 
	this.FrameClass = 'tabDetailView';
}

DetailViewUI.prototype.PageCommand = function(sLayoutPanel, sActionsPanel, sCommandName, sCommandArguments)
{
	try
	{
		console.log('DetailViewUI.PageCommand: ' + sCommandName + ' ' +  sCommandArguments);
		if ( sCommandName == 'Edit' )
		{
			var oEditViewUI = new EditViewUI();
			oEditViewUI.Load(sLayoutPanel, sActionsPanel, this.MODULE, this.ID, false);
			this.MODULE  = null;
			this.ID      = null;
		}
		// 03/30/2016 Paul.  Convert requires special processing. 
		else if ( sCommandName == 'Convert' )
		{
			var sConvertToModule = '';
			switch ( this.MODULE )
			{
				case 'Prospects':  sConvertToModule = 'Leads'   ;  break;
				case 'Leads'    :  sConvertToModule = 'Contacts';  break;
				case 'Quotes'   :  sConvertToModule = 'Orders'  ;  break;
				case 'Orders'   :  sConvertToModule = 'Invoices';  break;
			}
			if ( !Sql.IsEmptyString(sConvertToModule) )
			{
				var oEditViewUI = new EditViewUI();
				oEditViewUI.Convert(sLayoutPanel, sActionsPanel, sConvertToModule, this.MODULE, this.ID, false);
				this.MODULE  = null;
				this.ID      = null;
			}
			else
			{
				SplendidError.SystemMessage('DetailViewUI.PageCommand: Unknown conversion for module ' + this.MODULE);
			}
		}
		else if ( sCommandName == 'Convert.ToOrder' )
		{
			var oEditViewUI = new EditViewUI();
			oEditViewUI.Convert(sLayoutPanel, sActionsPanel, 'Orders', this.MODULE, this.ID, false);
			this.MODULE  = null;
			this.ID      = null;
		}
		else if ( sCommandName == 'Convert.ToInvoice' )
		{
			var oEditViewUI = new EditViewUI();
			oEditViewUI.Convert(sLayoutPanel, sActionsPanel, 'Invoices', this.MODULE, this.ID, false);
			this.MODULE  = null;
			this.ID      = null;
		}
		else if ( sCommandName == 'Convert.ToOpportunity' )
		{
			var oEditViewUI = new EditViewUI();
			oEditViewUI.Convert(sLayoutPanel, sActionsPanel, 'Opportunities', this.MODULE, this.ID, false);
			this.MODULE  = null;
			this.ID      = null;
		}
		else if ( sCommandName == 'Duplicate' )
		{
			var oEditViewUI = new EditViewUI();
			oEditViewUI.Load(sLayoutPanel, sActionsPanel, this.MODULE, this.ID, true);
			this.MODULE  = null;
			this.ID      = null;
		}
		else if ( sCommandName == 'Delete' )
		{
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.DeleteModuleItem(this.MODULE, this.ID, function(status, message)
			{
				if ( status == 1 )
				{
					var sGRID_NAME = this.MODULE + '.ListView' + sPLATFORM_LAYOUT;
					var oListViewUI = new ListViewUI();
					oListViewUI.Reset(sLayoutPanel, this.MODULE);
					oListViewUI.Load(sLayoutPanel, sActionsPanel, this.MODULE, sGRID_NAME, null, function(status, message)
					{
						if ( status == 0 || status == 1 )
						{
							this.MODULE  = null;
							this.ID      = null;
						}
					});
				}
				else
				{
					SplendidError.SystemMessage(message);
				}
			}, this);
		}
		else if ( sCommandName == 'ViewLog' )
		{
			SplendidError.SystemMessage('ViewLog not supported');
		}
		else if ( sCommandName == 'Cancel' )
		{
			var sGRID_NAME = this.MODULE + '.ListView' + sPLATFORM_LAYOUT;
			var oListViewUI = new ListViewUI();
			oListViewUI.Reset(sLayoutPanel, this.MODULE);
			oListViewUI.Load(sLayoutPanel, sActionsPanel, this.MODULE, sGRID_NAME, null, function(status, message)
			{
				if ( status == 0 || status == 1 )
				{
					this.MODULE  = null;
					this.ID      = null;
				}
			});
		}
		else
		{
			SplendidError.SystemMessage('DetailViewUI.PageCommand: Unknown command ' + sCommandName);
		}
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'DetailViewUI.PageCommand');
	}
}

DetailViewUI.prototype.Clear = function(sLayoutPanel)
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
			alert('DetailViewUI.Clear: ' + sLayoutPanel + ' does not exist');
			return;
		}
		// 04/08/2017 Paul.  Use Bootstrap for responsive design.
		if ( !SplendidDynamic.BootstrapLayout() )
		{
			// <table id="ctlDetailView_tblMain" class="tabDetailView">
			var ctlDetailView_tblMain = document.createElement('table');
			ctlDetailView_tblMain.id        = sLayoutPanel + '_ctlDetailView_tblMain';
			ctlDetailView_tblMain.width     = '100%';
			ctlDetailView_tblMain.className = this.FrameClass;
			divMainLayoutPanel.appendChild(ctlDetailView_tblMain);
		}
		else
		{
			var ctlDetailView_tblMain = document.createElement('div');
			ctlDetailView_tblMain.id        = sLayoutPanel + '_ctlDetailView_tblMain';
			divMainLayoutPanel.appendChild(ctlDetailView_tblMain);
		}
		// 10/08/2012 Paul.  Add DetailSubPanel. 
		// <div id="divDetailSubPanel">
		var divDetailSubPanel = document.createElement('div');
		divDetailSubPanel.id = sLayoutPanel + '_divDetailSubPanel';
		divMainLayoutPanel.appendChild(divDetailSubPanel);
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'DetailViewUI.Clear');
	}
}

NormalizeDescription = function(sDESCRIPTION)
{
	// 06/04/2010 Paul.  Try and prevent excess blank lines. 
	sDESCRIPTION = sDESCRIPTION.replace(/\r\n/g     , '\n');
	sDESCRIPTION = sDESCRIPTION.replace(/\r/g       , '\n');
	sDESCRIPTION = sDESCRIPTION.replace(/<br \/>\n/g, '\n');
	sDESCRIPTION = sDESCRIPTION.replace(/<br\/>\n/g , '\n');
	sDESCRIPTION = sDESCRIPTION.replace(/<br>\n/g   , '\n');
	sDESCRIPTION = sDESCRIPTION.replace(/\n/g       , '<br \/>\r\n');
	return sDESCRIPTION;
}

DetailViewUI.prototype.LoadView = function(sLayoutPanel, sActionsPanel, tblMain, layout, row)
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
		
		var tr = null;
		var nColumn = 0;
		var bEnableTeamManagement = Crm.Config.enable_team_management();
		var bEnableDynamicTeams   = Crm.Config.enable_dynamic_teams();
		// 09/17/2018 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		var bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
		// 09/16/2018 Paul.  Create a multi-tenant system. 
		if ( Crm.Config.enable_multi_tenant_teams() )
		{
			bEnableTeamManagement    = false;
			bEnableDynamicTeams      = false;
			bEnableDynamicAssignment = false;
		}
		// 12/06/2014 Paul.  Use new mobile flag. 
		var bIsMobile = isMobileDevice();
		if ( isMobileLandscape() )
			bIsMobile = false;
		var sTheme = Security.USER_THEME();
		// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
		var oNumberFormat = Security.NumberFormatInfo();

		// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
		var arrERASED_FIELDS = [];
		if ( Crm.Config.enable_data_privacy() )
		{
			if ( row['ERASED_FIELDS'] !== undefined )
			{
				arrERASED_FIELDS = Sql.ToString(row['ERASED_FIELDS']).split(',');
			}
		}
		for ( var nLayoutIndex in layout )
		{
			var lay = layout[nLayoutIndex];
			var sDETAIL_NAME  = lay.DETAIL_NAME ;
			var sFIELD_TYPE   = lay.FIELD_TYPE  ;
			var sDATA_LABEL   = lay.DATA_LABEL  ;
			var sDATA_FIELD   = lay.DATA_FIELD  ;
			var sDATA_FORMAT  = lay.DATA_FORMAT ;
			var sURL_FIELD    = lay.URL_FIELD   ;
			var sURL_FORMAT   = lay.URL_FORMAT  ;
			var sURL_TARGET   = lay.URL_TARGET  ;
			var sLIST_NAME    = lay.LIST_NAME   ;
			var nCOLSPAN      = Sql.ToInteger(lay.COLSPAN);
			var sLABEL_WIDTH  = lay.LABEL_WIDTH ;
			var sFIELD_WIDTH  = lay.FIELD_WIDTH ;
			var nDATA_COLUMNS = Sql.ToInteger(lay.DATA_COLUMNS);
			var sVIEW_NAME    = lay.VIEW_NAME   ;
			var sMODULE_NAME  = lay.MODULE_NAME ;
			var sTOOL_TIP     = lay.TOOL_TIP    ;
			var sMODULE_TYPE  = lay.MODULE_TYPE ;
			var sPARENT_FIELD = lay.PARENT_FIELD;
			
			// 02/28/2014 Paul.  We are going to start using the data column in the Preview panel. 
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
			
			if ( (sDATA_FIELD == 'TEAM_NAME' || sDATA_FIELD == 'TEAM_SET_NAME') )
			{
				if ( !bEnableTeamManagement )
				{
					sFIELD_TYPE = 'Blank';
				}
				else if ( bEnableDynamicTeams )
				{
					sDATA_LABEL = '.LBL_TEAM_SET_NAME';
					sDATA_FIELD = 'TEAM_SET_NAME';
				}
			}
			// 09/16/2018 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			if ( sDATA_FIELD == "ASSIGNED_TO" || sDATA_FIELD == "ASSIGNED_TO_NAME" || sDATA_FIELD == "ASSIGNED_SET_NAME" )
			{
				// 12/17/2017 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
				// 09/16/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
				if ( bEnableDynamicAssignment && sDATA_FORMAT.toLowerCase().indexOf("single") == -1 )
				{
					sDATA_LABEL = ".LBL_ASSIGNED_SET_NAME";
					sDATA_FIELD = "ASSIGNED_SET_NAME";
				}
				else if ( sDATA_FIELD == "ASSIGNED_SET_NAME" )
				{
					sDATA_LABEL = ".LBL_ASSIGNED_TO";
					sDATA_FIELD = "ASSIGNED_TO_NAME";
				}
			}
			if ( sDATA_FIELD == 'EXCHANGE_FOLDER' )
			{
				if ( !Crm.Modules.ExchangeFolders(sMODULE_NAME) )
				{
					sFIELD_TYPE = 'Blank';
				}
			}
			// 09/02/2012 Paul.  A separator will create a new table. We need to match the outer and inner layout. 
			if ( sFIELD_TYPE == 'Separator' )
			{
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					var tblNew = document.createElement('table');
					// 09/27/2012 Paul.  Separator can have an ID and can have a style so that it can be hidden. 
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
						tblNew.id = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD;
					if ( !Sql.IsEmptyString(sDATA_FORMAT) )
						tblNew.setAttribute('style', sDATA_FORMAT);
					tblNew.className = this.FrameClass;
					tblNew.style.marginTop = '5px';
					if ( tblMain.nextSibling == null )
						tblMain.parentNode.appendChild(tblNew);
					else
						tblMain.parentNode.insertBefore(tblNew, tblMain.nextSibling);
					tblMain = tblNew;
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
				nColumn = 0;
				tr = null;
				continue;
			}
			// 12/06/2014 Paul.  Use new mobile flag. 
			if ( nColumn % nDATA_COLUMNS == 0 || tr == null || bIsMobile )
			{
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					tr = document.createElement('tr');
					tbody.appendChild(tr);
				}
				else
				{
					tr = document.createElement('div');
					// 04/08/2017 Paul.  This full column setting is critical to the flow. 
					if ( nDATA_COLUMNS == 1 )
					{
						tr.className = 'col-md-12 col-sm-12 col-xs-12';
					}
					else if ( nDATA_COLUMNS == 2 )
					{
						tr.className = 'col-md-12 col-sm-12 col-xs-6';
					}
					else
					{
						tr.className = 'col-md-12 col-sm-12 col-xs-6';
					}
					tr.className = 'row';
					tbody.appendChild(tr);
				}
			}
			// 06/21/2015 Paul.  The Seven theme has labels stacked above values. 
			var tdLabel = null;
			var tdField = null;
			// 04/08/2017 Paul.  Use Bootstrap for responsive design.
			if ( SplendidDynamic.StackedLayout(sTheme, sDETAIL_NAME) && !SplendidDynamic.BootstrapLayout() )
			{
				tdLabel = document.createElement('td');
				tdField = tdLabel;
				tdField.className = 'tabStackedDetailViewDF';
				tdField.vAlign    = 'top';
				tr.appendChild(tdField);
				if ( nCOLSPAN > 0 )
				{
					tdField.colSpan = (nCOLSPAN + 1) / 2;
					nColumn++;
				}
				tdField.width  = (100 / nDATA_COLUMNS).toString() + '%';
				var spanLabel = document.createElement('span');
				spanLabel.className = 'tabStackedDetailViewDL';
				spanLabel.id        = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD + '_LABEL';
				tdLabel.appendChild(spanLabel);
				if ( sLABEL_WIDTH == '0%' || sLABEL_WIDTH == '0px' || sLABEL_WIDTH == '0' )
				{
					spanLabel.style.display = 'none';
					tdField.style.paddingTop    = '0px';
					tdField.style.paddingBottom = '1px';
				}
				if ( sDATA_LABEL != null )
				{
					if ( sFIELD_TYPE != 'Blank' )
					{
						if ( sDATA_LABEL.indexOf('.') >= 0 )
						{
							var sLabel = L10n.Term(sDATA_LABEL);
							if ( EndsWith(sLabel, ':') )
								sLabel = Left(sLabel, sLabel.length - 1);
							var txt = document.createTextNode(sLabel);
							spanLabel.appendChild(txt);
						}
						else if ( !Sql.IsEmptyString(sDATA_LABEL) )
						{
							var sLabel = row[sDATA_LABEL];
							if ( sLabel === undefined )
								sLabel = sDATA_LABEL;
							if ( !Sql.IsEmptyString(sLabel) )
							{
								if ( EndsWith(sLabel, ':') )
									sLabel = Left(sLabel, sLabel.length - 1);
								var txt = document.createTextNode(sLabel);
								spanLabel.appendChild(txt);
							}
						}
					}
				}
				var spanField = document.createElement('span');
				spanField.id = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD;
				tdField.appendChild(spanField);
				tdField = spanField;
			}
			else
			{
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				if ( !SplendidDynamic.BootstrapLayout() )
				{
					tdLabel = document.createElement('td');
					tr.appendChild(tdLabel);
					tdLabel.className = 'tabDetailViewDL';
					tdLabel.vAlign    = 'top';
					// 02/25/2016 Paul.  Browse does not like 0%. 
					if ( sLABEL_WIDTH == '0%' || sLABEL_WIDTH == '0px' || sLABEL_WIDTH == '0' )
						tdLabel.style.display = 'none';
					else
						tdLabel.width     = sLABEL_WIDTH;
					tdLabel.id        = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD + '_LABEL';
					
					tdField = document.createElement('td');
					tr.appendChild(tdField);
					tdField.className = 'tabDetailViewDF';
					tdField.vAlign    = 'top';
					tdField.width     = sFIELD_WIDTH;
					tdField.id        = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD;
					if ( nCOLSPAN > 0 )
					{
						tdField.colSpan = nCOLSPAN;
						nColumn++;
					}
				}
				else
				{
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					tdLabel = document.createElement('label');
					tdLabel.className = sGridLabel;
					tdLabel.id        = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD + '_LABEL';
					tr.appendChild(tdLabel);
					
					if ( nCOLSPAN > 0 )
					{
						nColumn++;
						if ( nDATA_COLUMNS == 1 )
						{
							// 04/08/2017 Paul.  Unchanged from default. 
							//sGridLabel = 'control-label col-md-3 col-sm-3 col-xs-12';
							//sGridInput = 'col-md-9 col-sm-9 col-xs-12';
						}
						else if ( nDATA_COLUMNS == 2 )
						{
							// 04/08/2017 Paul.  Take rest of columns. 
							//sGridLabel = 'control-label col-md-2 col-sm-2 col-xs-12';
							sGridInput = 'col-md-10 col-sm-10 col-xs-12';
						}
						else
						{
							// 04/08/2017 Paul.  Take rest of columns. 
							//sGridLabel = 'control-label col-md-1 col-sm-1 col-xs-12';
							sGridInput = 'col-md-11 col-sm-11 col-xs-12';
						}
					}
					tdField = document.createElement('div');
					tdField.className = sGridInput;
					tdField.id        = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD;
					tr.appendChild(tdField);
				}
				if ( sDATA_LABEL != null )
				{
					if ( sFIELD_TYPE != 'Blank' )
					{
						if ( sDATA_LABEL.indexOf('.') >= 0 )
						{
							var txt = document.createTextNode(L10n.Term(sDATA_LABEL));
							tdLabel.appendChild(txt);
						}
						else if ( !Sql.IsEmptyString(sDATA_LABEL) )
						{
							// 06/21/2015 Paul.  Label can contain raw text. 
							var sLabel = row[sDATA_LABEL];
							if ( sLabel === undefined )
								sLabel = sDATA_LABEL;
							if ( !Sql.IsEmptyString(sLabel) )
							{
								var txt = document.createTextNode(sLabel);
								tdLabel.appendChild(txt);
							}
						}
					}
				}
			}
			if ( sFIELD_TYPE == 'HyperLink' )
			{
				// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
				if ( (row[sDATA_FIELD] != null || row[sDATA_FIELD] === undefined) && sURL_FORMAT != null && sDATA_FORMAT != null )
				{
					var a = document.createElement('a');
					tdField.appendChild(a);
					if ( sURL_FORMAT.substr(0, 2) == '~/' )
					{
						var arrURL_FORMAT = sURL_FORMAT.split('/');
						var sURL_MODULE_NAME = sMODULE_NAME;
						if ( arrURL_FORMAT.length > 1 )
							sURL_MODULE_NAME = arrURL_FORMAT[1];
						if ( sURL_MODULE_NAME == 'Parents' )
						{
							sURL_MODULE_NAME = row[sDATA_LABEL];
						}
						a.href = '#';
						a.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID)
						{
							if ( sPLATFORM_LAYOUT == '.OfficeAddin' )
							{
								sLayoutPanel  = 'divMainLayoutPanel' ;
								sActionsPanel = 'divMainActionsPanel';
							}
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
						}, sLayoutPanel, sActionsPanel, sURL_MODULE_NAME, row[sURL_FIELD]);
						// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
						if ( row[sDATA_FIELD] === undefined && !Sql.IsEmptyString(row[sURL_FIELD]) )
						{
							// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
							if ( arrERASED_FIELDS.length > 0 && arrERASED_FIELDS.indexOf(sDATA_FIELD) >= 0 )
							{
								tdField.innerHTML = Sql.DataPrivacyErasedPill();
							}
							else
							{
								BindArguments(function(sMODULE_NAME, sID, sDATA_FORMAT, a, context)
								{
									Crm.Modules.ItemName(sMODULE_NAME, sID, function(status, message)
									{
										if ( status == 1 )
										{
											a.innerHTML = sDATA_FORMAT.replace('{0}', message);
										}
									}, context);
								}, sURL_MODULE_NAME, row[sURL_FIELD], sDATA_FORMAT, a, this)();
							}
						}
					}
					else
					{
						a.href = sURL_FORMAT.replace('{0}', row[sURL_FIELD]);
					}
					// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
					if ( row[sDATA_FIELD] !== undefined )
					{
						a.innerHTML = sDATA_FORMAT.replace('{0}', row[sDATA_FIELD]);
					}
				}
				// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
				else if ( arrERASED_FIELDS.length > 0 && arrERASED_FIELDS.indexOf(sDATA_FIELD) >= 0 )
				{
					tdField.innerHTML = Sql.DataPrivacyErasedPill();
				}
			}
			// 02/23/2019 Paul.  ModuleLink was introduced in 2015.  Similar to HyperLink, but uses MODULE_TYPE instead of URL_FORMAT. 
			else if ( sFIELD_TYPE == 'ModuleLink' )
			{
				if ( (row[sDATA_FIELD] != null || row[sDATA_FIELD] === undefined) && sMODULE_TYPE != null )
				{
					var a = document.createElement('a');
					tdField.appendChild(a);
					var sURL_MODULE_NAME = sMODULE_TYPE;
					if ( sURL_MODULE_NAME == 'Parents' )
					{
						sURL_MODULE_NAME = row[sDATA_LABEL];
					}
					a.href = '#';
					a.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID)
					{
						if ( sPLATFORM_LAYOUT == '.OfficeAddin' )
						{
							sLayoutPanel  = 'divMainLayoutPanel' ;
							sActionsPanel = 'divMainActionsPanel';
						}
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
					}, sLayoutPanel, sActionsPanel, sURL_MODULE_NAME, row[sDATA_FIELD]);
					// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
					if ( arrERASED_FIELDS.length > 0 && arrERASED_FIELDS.indexOf(sDATA_FIELD) >= 0 )
					{
						tdField.innerHTML = Sql.DataPrivacyErasedPill();
					}
					else
					{
						BindArguments(function(sMODULE_NAME, sID, sDATA_FORMAT, a, context)
						{
							Crm.Modules.ItemName(sMODULE_NAME, sID, function(status, message)
							{
								if ( status == 1 )
								{
									if ( Sql.IsEmptyString(sDATA_FORMAT) )
										a.innerHTML = message;
									else
										a.innerHTML = sDATA_FORMAT.replace('{0}', message);
								}
							}, context);
						}, sURL_MODULE_NAME, row[sDATA_FIELD], sDATA_FORMAT, a, this)();
					}
				}
				// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
				else if ( arrERASED_FIELDS.length > 0 && arrERASED_FIELDS.indexOf(sDATA_FIELD) >= 0 )
				{
					tdField.innerHTML = Sql.DataPrivacyErasedPill();
				}
			}
			else if ( sFIELD_TYPE == 'String' )
			{
				if ( sDATA_FORMAT != null )
				{
					try
					{
						// 02/25/2016 Paul.  Fix bug.  Check for multiple data fields not format entries. 
						if ( sDATA_FIELD.indexOf(' ') > 0 )
						{
							var arrDATA_FIELD  = sDATA_FIELD.split(' ');
							for ( var nFormatIndex = 0; nFormatIndex < arrDATA_FIELD.length; nFormatIndex++ )
							{
								if ( arrDATA_FIELD[nFormatIndex].indexOf('.') >= 0 )
								{
									sDATA_FORMAT = sDATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', L10n.Term(arrDATA_FIELD[nFormatIndex]));
								}
								else
								{
									//console.log(arrDATA_FIELD[nFormatIndex] + ' ' + row[arrDATA_FIELD[nFormatIndex]]);
									if ( row[arrDATA_FIELD[nFormatIndex]] == null )
									{
										// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
										if ( arrERASED_FIELDS.length > 0 && arrERASED_FIELDS.indexOf(arrDATA_FIELD[nFormatIndex]) >= 0 )
											sDATA_FORMAT = sDATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', Sql.DataPrivacyErasedPill());
										else if ( arrDATA_FIELD[nFormatIndex] == 'PICTURE' )
											sDATA_FORMAT = sDATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', sREMOTE_SERVER + 'App_Themes/Six/images/ActivityStreamUser.gif');
										else
											sDATA_FORMAT = sDATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', '');
									}
									else
									{
										var sDATA_VALUE = row[arrDATA_FIELD[nFormatIndex]];
										//console.log(nFormatIndex + ', ' + arrDATA_FIELD[nFormatIndex] + ': ' + sDATA_VALUE);
										//sDATA_VALUE = FromJsonDate(sDATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
										//sDATA_FORMAT = sDATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', sDATA_VALUE);
										// 03/19/2016 Paul.  Handle currency and date formatting. 
										if ( sDATA_FORMAT.indexOf('{' + nFormatIndex.toString() + ':d}') >= 0 )
										{
											sDATA_VALUE = FromJsonDate(sDATA_VALUE, Security.USER_DATE_FORMAT());
											sDATA_FORMAT = sDATA_FORMAT.replace('{' + nFormatIndex.toString() + ':d}', sDATA_VALUE);
										}
										else if ( sDATA_FORMAT.indexOf('{' + nFormatIndex.toString() + ':c}') >= 0 )
										{
											//console.log(sDATA_VALUE + ' = ' + formatCurrency(sDATA_VALUE, oNumberFormat));
											sDATA_VALUE = formatCurrency(sDATA_VALUE, oNumberFormat);
											sDATA_FORMAT = sDATA_FORMAT.replace('{' + nFormatIndex.toString() + ':c}', sDATA_VALUE);
										}
										else if ( sDATA_FORMAT.indexOf('{' + nFormatIndex.toString() + ';') >= 0 )
										{
											var nStartListName = sDATA_FORMAT.indexOf('{' + nFormatIndex.toString() + ';');
											if ( nStartListName > 0 )
											{
												var nEndListName = sDATA_FORMAT.indexOf('}', nStartListName);
												if ( nEndListName > nStartListName )
												{
													var sPLACEHOLDER = sDATA_FORMAT.substring(nStartListName, nEndListName + 1);
													//console.log(sPLACEHOLDER);
													var sLIST_NAME   = sDATA_FORMAT.substring(nStartListName + ('{' + nFormatIndex.toString() + ';').length, nEndListName);
													sDATA_VALUE = L10n.ListTerm(sLIST_NAME, sDATA_VALUE);
													sDATA_FORMAT = sDATA_FORMAT.replace(sPLACEHOLDER, sDATA_VALUE);
												}
											}
										}
										// 10/03/2011 Paul.  If the data value is an integer, then substr() will throw an exception. 
										else if ( typeof(sDATA_VALUE) == 'string' && sDATA_VALUE.substr(0, 7) == '\\/Date(' )
										{
											sDATA_VALUE = FromJsonDate(sDATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
											sDATA_FORMAT = sDATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', sDATA_VALUE);
										}
										else
										{
											sDATA_FORMAT = sDATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', sDATA_VALUE);
										}
									}
								}
							}
							// 12/24/2012 Paul.  Use regex global replace flag. 
							tdField.id = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD.replace(/\s/g, '_');
							tdField.innerHTML = sDATA_FORMAT;
						}
						else if ( row[sDATA_FIELD] != null )
						{
							// 12/24/2012 Paul.  Use regex global replace flag. 
							tdField.id = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD.replace(/\s/g, '_');
							if ( !Sql.IsEmptyString(sLIST_NAME) )
							{
								var sDATA_VALUE = Sql.ToString(row[sDATA_FIELD]);
								// 08/01/2013 Paul.  Expand XML values from CheckBoxList. 
								if ( StartsWith(sDATA_VALUE, '<?xml') )
								{
									var sVALUES = '';
									var xmlVALUES = $.parseXML(sDATA_VALUE);
									$(xmlVALUES).find('Value').each(function()
									{
										if ( sVALUES.length > 0 )
											sVALUES += ', ';
										sVALUES += L10n.ListTerm(sLIST_NAME, $(this).text());
									});
									sDATA_VALUE = sVALUES;
								}
								else
								{
									// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
									sDATA_VALUE = L10n.ListTerm(sLIST_NAME, sDATA_VALUE);
								}
								tdField.innerHTML = sDATA_FORMAT.replace('{0}', sDATA_VALUE);
							}
							else
							{
								var sDATA_VALUE = row[sDATA_FIELD];
								try
								{
									if ( sDATA_FORMAT.indexOf('{0:d}') >= 0 )
									{
										sDATA_VALUE = FromJsonDate(sDATA_VALUE, Security.USER_DATE_FORMAT());
										// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
										if ( sDATA_VALUE == '' && arrERASED_FIELDS.length > 0 && arrERASED_FIELDS.indexOf(sDATA_FIELD) >= 0 )
											tdField.innerHTML = Sql.DataPrivacyErasedPill();
										else
											tdField.innerHTML = sDATA_FORMAT.replace('{0:d}', sDATA_VALUE);
									}
									else if ( sDATA_FORMAT.indexOf('{0:c}') >= 0 )
									{
										//console.log(sDATA_VALUE + ' = ' + formatCurrency(sDATA_VALUE, oNumberFormat));
										sDATA_VALUE = formatCurrency(sDATA_VALUE, oNumberFormat);
										tdField.innerHTML = sDATA_FORMAT.replace('{0:c}', sDATA_VALUE);
									}
									// 03/19/2019 Paul.  Add support for floating point numbers. 
									else if (sDATA_FORMAT.indexOf('{0:f') >= 0)
									{
										var nStartListName = sDATA_FORMAT.indexOf('{0:f');
										if (nStartListName >= 0)
										{
											var nEndListName = sDATA_FORMAT.indexOf('}', nStartListName);
											if (nEndListName > nStartListName)
											{
												var sPLACEHOLDER = sDATA_FORMAT.substring(nStartListName, nEndListName + 1);
												try
												{
													// 10/11/2020 Paul.  .NET defaults to 2 digit float. 
													var nFixed = 2;
													if ( sDATA_FORMAT != '{0:f}' )
														nFixed = parseInt(sDATA_FORMAT.substring(nStartListName + ('{0:f').length, nEndListName));
													if ( sDATA_VALUE != null )
														sDATA_VALUE = parseFloat(sDATA_VALUE).toFixed(nFixed);
												}
												catch(error)
												{
													sDATA_VALUE = error.message;
												}
												tdField.innerHTML = sDATA_FORMAT.replace(sPLACEHOLDER, sDATA_VALUE);
											}
										}
									}
									// 03/19/2019 Paul.  Add support for floating point numbers. 
									else if (sDATA_FORMAT.indexOf('{0:F') >= 0)
									{
										var nStartListName = sDATA_FORMAT.indexOf('{0:F');
										if (nStartListName >= 0)
										{
											var nEndListName = sDATA_FORMAT.indexOf('}', nStartListName);
											if (nEndListName > nStartListName)
											{
												var sPLACEHOLDER = sDATA_FORMAT.substring(nStartListName, nEndListName + 1);
												try
												{
													var nFixed = parseInt(sDATA_FORMAT.substring(nStartListName + ('{0:F').length, nEndListName));
													if ( sDATA_VALUE != null )
														sDATA_VALUE = parseFloat(sDATA_VALUE).toFixed(nFixed);
												}
												catch(error)
												{
													sDATA_VALUE = error.message;
												}
												tdField.innerHTML = sDATA_FORMAT.replace(sPLACEHOLDER, sDATA_VALUE);
											}
										}
									}
									// 10/03/2011 Paul.  If the data value is an integer, then substr() will throw an exception. 
									else if ( typeof(sDATA_VALUE) == 'string' && sDATA_VALUE.substr(0, 7) == '\\/Date(' )
									{
										sDATA_VALUE = FromJsonDate(sDATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
										tdField.innerHTML = sDATA_FORMAT.replace('{0}', sDATA_VALUE);
									}
									else
									{
										// 08/26/2014 Paul.  Text with angle brackets (such as an email), will generate an error when used with innerHTML. 
										//tdField.innerHTML = sDATA_FORMAT.replace('{0}', sDATA_VALUE);
										tdField.appendChild(document.createTextNode(sDATA_FORMAT.replace('{0}', sDATA_VALUE)));
									}
								}
								catch(e)
								{
									//alert(dumpObj(sDATA_VALUE, e.message));
								}
							}
						}
						// 11/30/2012 Paul.  Special formatting for Address HTML fields are normally provided by special _Edit view.
						else if ( sDATA_FORMAT == '{0}' && EndsWith(sDATA_FIELD, 'ADDRESS_HTML') )
						{
							// 'PRIMARY_ADDRESS_HTML'
							// 'ALT_ADDRESS_HTML'
							// 'BILLING_ADDRESS_HTML'
							// 'SHIPPING_ADDRESS_HTML'
							var sADDRESS_BASE = sDATA_FIELD.replace('_HTML', '_');
							tdField.innerHTML = Sql.ToString(row[sADDRESS_BASE + 'STREET'    ]) + '<br />'
							                  + Sql.ToString(row[sADDRESS_BASE + 'CITY'      ]) + ' '
							                  + Sql.ToString(row[sADDRESS_BASE + 'STATE'     ]) + ' &nbsp;&nbsp;'
							                  + Sql.ToString(row[sADDRESS_BASE + 'POSTALCODE']) + '<br />'
							                  + Sql.ToString(row[sADDRESS_BASE + 'COUNTRY'   ]) + ' ';
						}
						// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
						else if ( arrERASED_FIELDS.length > 0 && arrERASED_FIELDS.indexOf(sDATA_FIELD) >= 0 )
						{
							tdField.innerHTML = Sql.DataPrivacyErasedPill();
						}
					}
					catch(e)
					{
						SplendidError.SystemAlert(e, 'DetailViewUI.LoadView');
					}
				}
			}
			else if ( sFIELD_TYPE == 'TextBox' )
			{
				if ( row[sDATA_FIELD] != null )
				{
					// 12/24/2012 Paul.  Use regex global replace flag. 
					tdField.id = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD.replace(/\s/g, '_');
					var sDATA = row[sDATA_FIELD];
					if ( sDATA != null )
					{
						sDATA = NormalizeDescription(sDATA);
					}
					else if ( arrERASED_FIELDS.length > 0 && arrERASED_FIELDS.indexOf(sDATA_FIELD) >= 0 )
					{
						sDATA = Sql.DataPrivacyErasedPill();
					}
					try
					{
						tdField.innerHTML = sDATA;
					}
					catch(e)
					{
						sDATA = row[sDATA_FIELD];
						sDATA = sDATA.replace(/</g, '&lt;');
						sDATA = sDATA.replace(/>/g, '&gt;');
						var pre = document.createElement('pre');
						tdField.appendChild(pre);
						pre.innerHTML = sDATA;
					}
				}
			}
			// 05/27/2016 Paul.  Add support for Image type. 
			else if ( sFIELD_TYPE == 'Image' )
			{
				if ( row[sDATA_FIELD] != null )
				{
					// 12/24/2012 Paul.  Use regex global replace flag. 
					tdField.id = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD.replace(/\s/g, '_');
					var sDATA = row[sDATA_FIELD];
					try
					{
						var img = document.createElement('img');
						img.src = sREMOTE_SERVER + 'Images/Image.aspx?ID=' + sDATA;
						tdField.appendChild(img);
					}
					catch(e)
					{
						sDATA = row[sDATA_FIELD];
						sDATA = sDATA.replace(/</g, '&lt;');
						sDATA = sDATA.replace(/>/g, '&gt;');
						var pre = document.createElement('pre');
						tdField.appendChild(pre);
						pre.innerHTML = sDATA + ' ' + e.message;
					}
				}
			}
			// 05/27/2016 Paul.  Add support for File type. 
			else if ( sFIELD_TYPE == 'File' )
			{
				if ( row[sDATA_FIELD] != null )
				{
					// 12/24/2012 Paul.  Use regex global replace flag. 
					tdField.id = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD.replace(/\s/g, '_');
					var sDATA = row[sDATA_FIELD];
					try
					{
						var lnk = document.createElement('a');
						lnk.href = sREMOTE_SERVER + 'Images/Image.aspx?ID=' + sDATA;
						lnk.innerHTML = sDATA;
						tdField.appendChild(lnk);
						Crm.Modules.ItemName('Images', sDATA, function(status, message)
						{
							if ( status == 1 )
							{
								lnk.innerHTML = message;
							}
						}, this);
					}
					catch(e)
					{
						sDATA = row[sDATA_FIELD];
						sDATA = sDATA.replace(/</g, '&lt;');
						sDATA = sDATA.replace(/>/g, '&gt;');
						var pre = document.createElement('pre');
						tdField.appendChild(pre);
						pre.innerHTML = sDATA + ' ' + e.message;
					}
				}
			}
			else if ( sFIELD_TYPE == 'CheckBox' )
			{
				var chk = document.createElement('input');
				// 06/18/2011 Paul.  IE requires that the input type be defined prior to appending the field. 
				// 12/24/2012 Paul.  Use regex global replace flag. 
				chk.id        = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD.replace(/\s/g, '_');
				chk.type      = 'checkbox';
				chk.className = 'checkbox';
				chk.disabled  = 'disabled';
				if ( SplendidDynamic.BootstrapLayout() )
					chk.style.transform = 'scale(1.5)';
				// 09/25/2011 Paul.  IE does not allow you to set the type after it is added to the document. 
				tdField.appendChild(chk);
				chk.checked   = Sql.ToBoolean(row[sDATA_FIELD]);
			}
			else if ( sFIELD_TYPE == 'Blank' )
			{
				tdField.innerHTML = '';
			}
			// 09/03/2012 Paul.  A header is similar to a label, but without the data field. 
			else if ( sFIELD_TYPE == 'Header' )
			{
				tdLabel.innerHTML = '<h4>' + tdLabel.innerHTML + '</h4>';
				tdField.innerHTML = '';
			}
			// 06/21/2015 Paul.  We are not ready to support javascript. 
			// 02/25/2016 Paul.  Add support for JavaScript for OfficeAddin. 
			else if ( sFIELD_TYPE == 'JavaScript' )
			{
				try
				{
					if ( !Sql.IsEmptyString(sURL_FORMAT) )
					{
						// 03/20/2016 Paul.  Need to protect against null strings. 
						var arrURL_FORMAT = Sql.ToString(sURL_FORMAT).split(' ');
						var arrURL_FIELD  = Sql.ToString(sURL_FIELD ).split(' ');
						for ( var nFormatIndex = 0; nFormatIndex < arrURL_FIELD.length; nFormatIndex++ )
						{
							if ( row[arrURL_FIELD[nFormatIndex]] == null )
							{
								sURL_FORMAT = Sql.ToString(sURL_FORMAT).replace('{' + nFormatIndex.toString() + '}', '');
								sURL_TARGET = Sql.ToString(sURL_TARGET).replace('{' + nFormatIndex.toString() + '}', '');
							}
							else
							{
								var sURL_VALUE = row[arrURL_FIELD[nFormatIndex]];
								sURL_VALUE = FromJsonDate(sURL_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
								sURL_FORMAT = Sql.ToString(sURL_FORMAT).replace('{' + nFormatIndex.toString() + '}', Sql.EscapeJavaScript(sURL_VALUE));
								sURL_TARGET = Sql.ToString(sURL_TARGET).replace('{' + nFormatIndex.toString() + '}', Sql.EscapeJavaScript(sURL_VALUE));
							}
						}
						// 12/03/2009 Paul.  LinkedIn Company Profile requires a span tag to insert the link.
						if ( !Sql.IsEmptyString(sURL_TARGET) )
						{
							var spn = document.createElement('span');
							spn.id = sURL_TARGET;
							tdField.appendChild(spn);
						}
						eval(sURL_FORMAT);
					}
				}
				catch(e)
				{
					console.log(e.message);
				}
			}
			// 05/14/2016 Paul.  Add Tags module. 
			else if ( sFIELD_TYPE == 'Tags' )
			{
				if ( row[sDATA_FIELD] != null )
				{
					// 12/24/2012 Paul.  Use regex global replace flag. 
					tdField.id = sLayoutPanel + '_ctlDetailView_' + sDATA_FIELD.replace(/\s/g, '_');
					var sDATA = row[sDATA_FIELD];
					if ( !Sql.IsEmptyString(sDATA) )
					{
						var arrTAGS = sDATA.split(',');
						for ( var iTag = 0; iTag < arrTAGS.length; iTag++ )
						{
							var spn = document.createElement('span');
							spn.className = 'Tags';
							spn.appendChild(document.createTextNode(arrTAGS[iTag]))
							tdField.appendChild(spn);
							tdField.appendChild(document.createTextNode(' '))
						}
					}
				}
			}
			else
			{
				tdField.innerHTML = 'Unsupported field type: ' + sFIELD_TYPE;
			}
			// 04/08/2017 Paul.  Use Bootstrap for responsive design.
			if ( SplendidDynamic.BootstrapLayout() )
			{
				// 04/08/2017 Paul.  An empty field will cause problems for grid flow. 
				// 01/11/2018 Paul.  Adding nbsp to innerHTML is causing the hyperlinks to fail.  Instead, add text node. 
				tdLabel.appendChild(document.createTextNode('\u00A0'));
				tdField.appendChild(document.createTextNode('\u00A0'));
			}
			nColumn++;
		}
		// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
		for ( var nLayoutIndex in layout )
		{
			var lay = layout[nLayoutIndex];
			var sFORM_SCRIPT = lay.SCRIPT;
			if ( !Sql.IsEmptyString(sFORM_SCRIPT) )
			{
				// 11/24/2017 Paul.  Need to replace all occurrences. 
				sFORM_SCRIPT = sFORM_SCRIPT.replace(/SPLENDID_DETAILVIEW_LAYOUT_ID/g, sLayoutPanel + '_ctlDetailView');
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
		// 10/08/2012 Paul.  callback is not available here. 
		SplendidError.SystemAlert(e, 'DetailViewUI.LoadView');
	}
}

DetailViewUI.prototype.LoadItem = function(sLayoutPanel, sActionsPanel, layout, sDETAIL_NAME, sMODULE_NAME, sID, callback)
{
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.DetailView_LoadItem(sMODULE_NAME, sID, function(status, message)
		{
			if ( status == 1 )
			{
				// 10/04/2011 Paul.  DetailViewUI.LoadItem returns the row. 
				var row = message;
				// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
				if ( SplendidDynamic.StackedLayout(Security.USER_THEME(), sDETAIL_NAME) )
					DynamicButtonsUI_Clear(sLayoutPanel + '_Header_' + sActionsPanel);
				DynamicButtonsUI_Clear(sActionsPanel);
				this.Clear(sLayoutPanel);
				// 12/06/2014 Paul.  LayoutMode is used on the Mobile view. 
				if ( this.ActivateTab )
				ctlActiveMenu.ActivateTab(sMODULE_NAME, sID, 'DetailView', this);
				// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
				var arrERASED_FIELDS = [];
				if ( Crm.Config.enable_data_privacy() )
				{
					if ( row['ERASED_FIELDS'] !== undefined )
					{
						arrERASED_FIELDS = Sql.ToString(row['ERASED_FIELDS']).split(',');
					}
				}
				var sNAME = Sql.ToString(row['NAME']);
				// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
				if ( arrERASED_FIELDS.length > 0 && arrERASED_FIELDS.indexOf('NAME') >= 0 )
				{
					// 07/01/2018 Paul.  We want to allow the display of partial names. 
					if ( sMODULE_NAME == 'Contacts' || sMODULE_NAME == 'Leads' || sMODULE_NAME == 'Prospects' )
					{
						var sFIRST_NAME = row['FIRST_NAME'];
						var sLAST_NAME  = row['LAST_NAME' ];
						if ( sFIRST_NAME == null && arrERASED_FIELDS.indexOf('FIRST_NAME') >= 0 )
							sFIRST_NAME = Sql.DataPrivacyErasedPill();
						if ( sLAST_NAME == null && arrERASED_FIELDS.indexOf('LAST_NAME') >= 0 )
							sLAST_NAME = Sql.DataPrivacyErasedPill();
						sNAME = sFIRST_NAME + ' ' + sLAST_NAME;
					}
					else
					{
						sNAME = Sql.DataPrivacyErasedPill();
					}
				}
				// 01/30/2013 Paul.  Clicking on the sub-title will refresh the view as a way to correct bugs in the rendering. 
				SplendidUI_ModuleHeader(sLayoutPanel, sActionsPanel, sMODULE_NAME, sNAME, Sql.ToString(row['ID']));
				// 08/20/2016 Paul.  Add Business Process buttons. 
				if ( row != null && !Sql.IsEmptyGuid(row['PENDING_PROCESS_ID']) )
				{
					var gPENDING_PROCESS_ID = Sql.ToGuid(row['PENDING_PROCESS_ID']);
					bgPage.ProcessButtons_GetProcessStatus(gPENDING_PROCESS_ID, function(status, message)
					{
						if ( status == 1 )
						{
							if ( message != null && message.length > 0 )
							{
								var rowProcess = message[0];
								var oProcessButtonsUI = new ProcessButtonsUI(this.MODULE, this.ID, rowProcess);
								oProcessButtonsUI.LoadButtons(sLayoutPanel, sActionsPanel, rowProcess, function(status, message)
								{
									// 08/20/2016 Paul.  We need the callback event here to continue the Load operation. 
									callback(status, message);
								});
							}
							else
							{
								DynamicButtonsUI_Load(sLayoutPanel, sActionsPanel, 'ModuleHeader', sDETAIL_NAME, row, this.PageCommand, function(status, message)
								{
									if ( status != 1 )
										callback(status, message);
								}, this);
							}
						}
						else
							callback(status, message);
					}, this);
				}
				else
				{
					// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
					DynamicButtonsUI_Load(sLayoutPanel, sActionsPanel, 'ModuleHeader', sDETAIL_NAME, row, this.PageCommand, function(status, message)
					{
						if ( status != 1 )
							callback(status, message);
					}, this);
				}
				
				//var layout = bgPage.SplendidCache.DetailViewFields(sDETAIL_NAME);
				var tblMain = document.getElementById(sLayoutPanel + '_ctlDetailView_tblMain');
				this.LoadView(sLayoutPanel, sActionsPanel, tblMain, layout, row);
				
				// 02/27/2016 Paul.  Add support for Quotes, Orders and Invoices. 
				if ( sMODULE_NAME == 'Quotes' || sMODULE_NAME == 'Orders' || sMODULE_NAME == 'Invoices' || (sMODULE_NAME == 'Opportunities' && Crm.Config.ToString('OpportunitiesMode') == 'Revenue') )
				{
					//console.log(dumpObj(row.LineItems, 'row.LineItems'));
					var sGRID_NAME = sMODULE_NAME + '.LineItems';
					bgPage.ListView_LoadLayout(sGRID_NAME, function(status, message)
					{
						if ( status == 1 )
						{
							layout = message;
							var sPRIMARY_ID = sID;
							var sRELATED_MODULE = sMODULE_NAME + 'LineItems';
							var divDetailSubPanel = document.getElementById(sLayoutPanel + '_divDetailSubPanel');
							var ctlListView_grdMain = document.createElement('table');
							ctlListView_grdMain.id        = sLayoutPanel + '_ctlListView_grdMain';
							ctlListView_grdMain.width     = '100%';
							ctlListView_grdMain.className = 'listView';
							divMainLayoutPanel.insertBefore(ctlListView_grdMain, divDetailSubPanel);
							var tbody = document.createElement('tbody');
							ctlListView_grdMain.appendChild(tbody);
							
							var oListViewUI = new ListViewUI();
							oListViewUI.SORT_FIELD     = 'POSITION';
							oListViewUI.MODULE_NAME    = sRELATED_MODULE;
							oListViewUI.GRID_NAME      = sGRID_NAME;
							oListViewUI.HIDE_VIEW_EDIT = true;
							oListViewUI.HIDE_DELETE    = true;
							oListViewUI.Render(sLayoutPanel, sActionsPanel, sRELATED_MODULE, layout, tbody, row.LineItems, sMODULE_NAME, sPRIMARY_ID);
							
							if ( sMODULE_NAME == 'Quotes' || sMODULE_NAME == 'Orders' || sMODULE_NAME == 'Invoices' )
							{
								var ctlSummaryView_tblMain = document.createElement('table');
								ctlSummaryView_tblMain.id        = sLayoutPanel + '_ctlSummaryView_tblMain';
								ctlSummaryView_tblMain.width     = '100%';
								ctlSummaryView_tblMain.className = this.FrameClass;
								divMainLayoutPanel.insertBefore(ctlSummaryView_tblMain, divDetailSubPanel);
								bgPage.DetailView_LoadLayout(sDETAIL_NAME.replace('.DetailView', '.SummaryView'), function(status, message)
								{
									if ( status == 1 )
									{
										// 10/03/2011 Paul.  DetailView_LoadLayout returns the layout. 
										var layout = message;
										this.LoadView(sLayoutPanel, sActionsPanel, ctlSummaryView_tblMain, layout, row);
									}
									var oDetailViewRelationshipsUI = new DetailViewRelationshipsUI();
									oDetailViewRelationshipsUI.Load(sLayoutPanel, sActionsPanel, sDETAIL_NAME, row, this.PageCommand, function(status, message)
									{
										// 01/30/2013 Paul.  We need the callback event here to continue the Load operation. 
										callback(status, message);
									});
								}, this);
							}
							else
							{
								var oDetailViewRelationshipsUI = new DetailViewRelationshipsUI();
								oDetailViewRelationshipsUI.Load(sLayoutPanel, sActionsPanel, sDETAIL_NAME, row, this.PageCommand, function(status, message)
								{
									// 01/30/2013 Paul.  We need the callback event here to continue the Load operation. 
									callback(status, message);
								});
							}
						}
					}, this);
				}
				else
				{
					var oDetailViewRelationshipsUI = new DetailViewRelationshipsUI();
					oDetailViewRelationshipsUI.Load(sLayoutPanel, sActionsPanel, sDETAIL_NAME, row, this.PageCommand, function(status, message)
					{
						// 01/30/2013 Paul.  We need the callback event here to continue the Load operation. 
						callback(status, message);
					});
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
		callback(-1, SplendidError.FormatError(e, 'DetailViewUI.LoadItem'));
	}
}

DetailViewUI.prototype.LoadObject = function(sLayoutPanel, sActionsPanel, sDETAIL_NAME, sMODULE_NAME, row, PageCommand, callback)
{
	try
	{
		this.MODULE  = sMODULE_NAME;
		this.ID      = null;
		
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.Terminology_LoadModule(sMODULE_NAME, function(status, message)
		{
			if ( status == 0 || status == 1 )
			{
				bgPage.DetailView_LoadLayout(sDETAIL_NAME, function(status, message)
				{
					if ( status == 1 )
					{
						// 10/03/2011 Paul.  DetailView_LoadLayout returns the layout. 
						var layout = message;
						if ( row != null )
						{
							// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
							if ( SplendidDynamic.StackedLayout(Security.USER_THEME(), sDETAIL_NAME) )
								DynamicButtonsUI_Clear(sLayoutPanel + '_Header_' + sActionsPanel);
							DynamicButtonsUI_Clear(sActionsPanel);
							this.Clear(sLayoutPanel);
							
							if ( PageCommand == null )
								PageCommand = this.PageCommand;
							// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
							DynamicButtonsUI_Load(sLayoutPanel, sActionsPanel, 'ModuleHeader', sDETAIL_NAME, row, PageCommand, function(status, message)
							{
							}, this);
							
							//var layout = bgPage.SplendidCache.DetailViewFields(sDETAIL_NAME);
							var tblMain = document.getElementById(sLayoutPanel + '_ctlDetailView_tblMain');
							this.LoadView(sLayoutPanel, sActionsPanel, tblMain, layout, row);
							
							callback(status, message);
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
		callback(-1, SplendidError.FormatError(e, 'DetailViewUI.LoadObject'));
	}
}

DetailViewUI.prototype.Parent = function(sID, callback, context)
{
	var sTABLE_NAME     = 'vwPARENTS';
	var sSORT_FIELD     = 'PARENT_ID';
	var sSORT_DIRECTION = '';
	var sSELECT         = 'PARENT_ID, PARENT_NAME, PARENT_TYPE, PARENT_ASSIGNED_USER_ID';
	var sFILTER         = 'PARENT_ID eq \'' + sID + '\'';
	var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=' + sTABLE_NAME + '&$orderby=' + encodeURIComponent(sSORT_FIELD + ' ' + sSORT_DIRECTION) + '&$select=' + escape(sSELECT) + '&$filter=' + escape(sFILTER), 'GET');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							if ( result.d.results.length > 0 )
								callback.call(context||this, 1, result.d.results[0]);
							else
								callback.call(context||this, -1, 'Item not found for ID = ' + sID);
						}
						else
						{
							callback.call(context||this, -1, xhr.responseText);
						}
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback.call(context||this, -1, SplendidError.FormatError(e, 'DetailViewUI.Parent'));
				}
			}, context||this);
		}
	}
	try
	{
		xhr.send();
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'DetailViewUI.Parent'));
	}
}

// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
DetailViewUI.prototype.Load = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, callback, context)
{
	try
	{
		this.MODULE  = null;
		this.ID      = null;
		
		var bgPage = chrome.extension.getBackgroundPage();
		// 11/29/2011 Paul.  We are having an issue with the globals getting reset, so we need to re-initialize. 
		if ( !bgPage.SplendidCache.IsInitialized() )
		{
			SplendidUI_ReInit(sLayoutPanel, sActionsPanel, sMODULE_NAME);
			return;
		}
		// 01/19/2013 Paul.  A Parents module requires a lookup to get the module name. 
		if ( sMODULE_NAME == 'Parents' )
		{
			this.Parent(sID, function(status, message)
			{
				if ( status == 1 && message !== undefined && message != null )
				{
					var row = message;
					sMODULE_NAME = row['PARENT_TYPE'];
					this.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID);
				}
				else
				{
					SplendidError.SystemMessage(message);
				}
			}, this);
			// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
			callback.call(context||this, 0, null);
			return;
		}
		
		this.MODULE  = sMODULE_NAME;
		this.ID      = sID;
		// 10/04/2011 Paul.  The session might have timed-out, so first check if we are authenticated. 
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				bgPage.Terminology_LoadModule(sMODULE_NAME, function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						var sDETAIL_NAME = sMODULE_NAME + '.DetailView' + sPLATFORM_LAYOUT;
						bgPage.DetailView_LoadLayout(sDETAIL_NAME, function(status, message)
						{
							if ( status == 1 )
							{
								SplendidUI_ModuleHeader(sLayoutPanel, sActionsPanel, sMODULE_NAME, '');
								// 10/03/2011 Paul.  DetailView_LoadLayout returns the layout. 
								var layout = message;
								if ( sID != null )
								{
									this.LoadItem(sLayoutPanel, sActionsPanel, layout, sDETAIL_NAME, sMODULE_NAME, sID, function(status, message)
									{
										// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
										callback.call(context||this, status, message);
									});
								}
							}
							else
							{
								// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
								callback.call(context||this, status, message);
							}
						}, this);
					}
					else
					{
						// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
						callback.call(context||this, status, message);
					}
				}, this);
			}
			else
			{
				// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
				callback.call(context||this, status, message);
			}
		}, this);
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'DetailViewUI.Load'));
	}
}

DetailViewUI.prototype.LoadOfficeAddin = function(sLayoutPanel, sActionsPanel, sDETAIL_NAME, sMODULE_NAME, sID, callback, context)
{
	try
	{
		this.MODULE  = sMODULE_NAME;
		this.ID      = sID;
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				bgPage.Terminology_LoadModule(sMODULE_NAME, function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						bgPage.DetailView_LoadLayout(sDETAIL_NAME, function(status, message)
						{
							if ( status == 1 )
							{
								SplendidUI_ModuleHeader(sLayoutPanel, sActionsPanel, sMODULE_NAME, '');
								// 10/03/2011 Paul.  DetailView_LoadLayout returns the layout. 
								var layout = message;
								if ( sID != null )
								{
									this.LoadItem(sLayoutPanel, sActionsPanel, layout, sDETAIL_NAME, sMODULE_NAME, sID, function(status, message)
									{
										// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
										callback.call(context||this, status, message);
									});
								}
							}
							else
							{
								// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
								callback.call(context||this, status, message);
							}
						}, this);
					}
					else
					{
						// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
						callback.call(context||this, status, message);
					}
				}, this);
			}
			else
			{
				// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
				callback.call(context||this, status, message);
			}
		}, this);
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'DetailViewUI.LoadOfficeAddin'));
	}
}

