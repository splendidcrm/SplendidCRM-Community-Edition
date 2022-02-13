/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function DynamicButtonsUI_Clear(sActionsPanel)
{
	try
	{
		var divMainLayoutPanelActions = document.getElementById(sActionsPanel);
		//alert('DynamicButtonsUI_Clear(' + sActionsPanel + ')' + divMainLayoutPanelActions);
		if ( divMainLayoutPanelActions != null && divMainLayoutPanelActions.childNodes != null )
		{
			while ( divMainLayoutPanelActions.childNodes.length > 0 )
			{
				divMainLayoutPanelActions.removeChild(divMainLayoutPanelActions.firstChild);
			}
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'DynamicButtonsUI_Clear');
	}
}

// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
function DynamicButtonsUI_LoadButtons(sLayoutPanel, sActionsPanel, sButtonStyle, layout, row, Page_Command, context)
{
	try
	{
		var divActionsPanel = document.getElementById(sActionsPanel);
		var divButtonHover  = null;
		// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
		if ( SplendidDynamic.StackedLayout(Security.USER_THEME(), sVIEW_NAME) )
		{
			divActionsPanel = document.getElementById(sLayoutPanel + '_Header_divMainActionsPanel');
			divButtonHover  = document.getElementById(sLayoutPanel + '_Header_divMainActionsPanel_divButtonHover');
		}
		// 10/17/2012 Paul.  Exit if the ActionsPanel does not exist.  This is a sign that the user has navigated elsewhere. 
		if ( divActionsPanel == null )
			return;
		// 08/20/2016 Paul.  Change to a span so that it can be placed side-by-side with another button panel. 
		var pnlDynamicButtons = document.createElement('div');
		pnlDynamicButtons.id        = 'pnlDynamicButtons';
		pnlDynamicButtons.className = 'button-panel';
		divActionsPanel.appendChild(pnlDynamicButtons);
		// 04/13/2017 Paul.  Use Bootstrap for responsive design.
		if ( !SplendidDynamic.BootstrapLayout() )
			pnlDynamicButtons.style.display = 'inline-block';
		
		var bMoreListItems = false;
		var sTheme = Security.USER_THEME();
		for ( var iButton in layout )
		{
			var lay = layout[iButton];
			// 03/06/2016 Paul.  sCOMMAND_NAME might be null, so we have to use Sql.ToString() so that we can use indexOf. 
			var sVIEW_NAME          = Sql.ToString(lay.VIEW_NAME         );
			var sCONTROL_TYPE       = Sql.ToString(lay.CONTROL_TYPE      );
			var sMODULE_NAME        = Sql.ToString(lay.MODULE_NAME       );
			//var sMODULE_ACCESS_TYPE = Sql.ToString(lay.MODULE_ACCESS_TYPE);
			//var sTARGET_NAME        = Sql.ToString(lay.TARGET_NAME       );
			//var sTARGET_ACCESS_TYPE = Sql.ToString(lay.TARGET_ACCESS_TYPE);
			var sCONTROL_TEXT       = Sql.ToString(lay.CONTROL_TEXT      );
			var sCONTROL_TOOLTIP    = Sql.ToString(lay.CONTROL_TOOLTIP   );
			var sCONTROL_CSSCLASS   = Sql.ToString(lay.CONTROL_CSSCLASS  );
			var sTEXT_FIELD         = Sql.ToString(lay.TEXT_FIELD        );
			var sARGUMENT_FIELD     = Sql.ToString(lay.ARGUMENT_FIELD    );
			var sCOMMAND_NAME       = Sql.ToString(lay.COMMAND_NAME      );
			var sURL_FORMAT         = Sql.ToString(lay.URL_FORMAT        );
			var sURL_TARGET         = Sql.ToString(lay.URL_TARGET        );
			var sONCLICK_SCRIPT     = Sql.ToString(lay.ONCLICK_SCRIPT    );
			// 03/14/2014 Paul.  Allow hidden buttons to be created. 
			var bHIDDEN             = Sql.ToBoolean(lay.HIDDEN);
			// 04/30/2017 Paul.  Apply access rights. 
			var nMODULE_ACLACCESS = (Sql.IsEmptyString(lay.MODULE_ACLACCESS) ? 0 : Sql.ToInteger(lay.MODULE_ACLACCESS));
			var nTARGET_ACLACCESS = (Sql.IsEmptyString(lay.TARGET_ACLACCESS) ? 0 : Sql.ToInteger(lay.TARGET_ACLACCESS));
			if ( nMODULE_ACLACCESS < 0 || nTARGET_ACLACCESS < 0 )
				continue;
			
			// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
			if ( divButtonHover != null )
			{
				// 02/26/2016 Paul.  Instead of dropdown for just search, use special font to add search icon.  This is mainly for the OfficeAddin. 
				if ( iButton == 1 && sButtonStyle == 'ListHeader' && sCOMMAND_NAME.indexOf('.Search') > 0 && layout.length == 2 )
				{
				}
				// 06/21/2015 Paul.  DataGrid are the select all/select page toggles in the upper left corner of a grid. 
				else if ( (iButton == 1 && (sButtonStyle == 'ModuleHeader' || sButtonStyle == 'ListHeader' || sButtonStyle == 'MassUpdateHeader')) || (iButton == 0 && sButtonStyle == 'DataGrid') )
				{
					// 04/13/2017 Paul.  Use Bootstrap for responsive design.
					if ( !SplendidDynamic.BootstrapLayout() )
					{
						var btnMore = document.createElement('img');
						pnlDynamicButtons.appendChild(btnMore);
						pnlDynamicButtons.className = '';
						if ( sButtonStyle == 'ModuleHeader' || sButtonStyle == 'MassUpdateHeader' )
						{
							btnMore.src   = sIMAGE_SERVER + 'App_Themes/Seven/images/moreWhite.gif';
							btnMore.style.verticalAlign = 'bottom';
						}
						else if ( sButtonStyle == 'ListHeader' )
							btnMore.src   = sIMAGE_SERVER + 'App_Themes/Seven/images/subpanel_more.gif';
						else if ( sButtonStyle == 'DataGrid' )
							btnMore.src   = sIMAGE_SERVER + 'App_Themes/Seven/images/datagrid_more.gif';
						btnMore.align = 'absmiddle';
						btnMore.style.height      = '20px';
						btnMore.style.width       = '16px;'
						btnMore.style.borderWidth = '0px';
						btnMore.className = sButtonStyle + 'MoreButton';
						btnMore.onclick   = function()
						{
							return false;
						};
						pnlDynamicButtons = divButtonHover;
						TabMenuUI_PopupManagement(divButtonHover, divActionsPanel);
					}
					else
					{
						pnlDynamicButtons.className = 'btn-group';
						var btnMore = document.createElement('button');
						btnMore.type      = 'button';
						btnMore.className = 'btn btn-primary dropdown-toggle';
						$(btnMore).attr('data-toggle'  , 'dropdown');
						$(btnMore).attr('aria-expanded', 'false'   );
						pnlDynamicButtons.appendChild(btnMore);
						var caret = document.createElement('span');
						//caret.className = 'caret fa-2x';
						caret.className = 'glyphicon glyphicon-triangle-bottom';
						btnMore.appendChild(caret);
						
						divButtonHover = document.createElement('ul');
						divButtonHover.className = 'dropdown-menu pull-right';
						divButtonHover.role      = 'menu';
						pnlDynamicButtons.appendChild(divButtonHover);
						pnlDynamicButtons = divButtonHover;
						bMoreListItems = true;
					}
				}
				if ( iButton == 0 && sButtonStyle == 'ListHeader' && (sCOMMAND_NAME.indexOf('.Create') > 0) )
				{
					sCONTROL_TEXT = '+';
				}
			}
			
			// 11/24/2012 Paul.  Search and ViewLog are not supported at this time. 
			// 03/10/2013 Paul.  SendInvites is not supported. 
			// 02/26/2016 Paul.  Enable search. 
			// 04/13/2017 Paul.  Hide ViewRelatedActivities. 
			// 01/07/2018 Paul.  Hide Archive Data and Search. 
			if ( !Sql.IsEmptyString(sCOMMAND_NAME) && (sCOMMAND_NAME == 'Save.SendInvites' || sCOMMAND_NAME == 'ViewLog' || sCOMMAND_NAME == 'vCard' || sCOMMAND_NAME == 'ViewRelatedActivities' || sCOMMAND_NAME == 'Archive.MoveData' || sCOMMAND_NAME == 'Activities.SearchOpen' || sCONTROL_TEXT == 'Activities.LBL_SEARCH_RELATED') )
				continue;
			else if ( bREMOTE_ENABLED && sVIEW_NAME == 'Users.DetailView' )
			{
				// 10/19/2014 Paul.  Users.DetailView ResetDefaults, ChangePassword, Duplicate are not supported. 
				if (sCOMMAND_NAME == 'EditMyAccount' || sCOMMAND_NAME == 'ResetDefaults' || sCOMMAND_NAME == 'ChangePassword' || sCOMMAND_NAME == 'Duplicate' )
					continue;
			}
			var sCONTROL_ID = '';
			if ( !Sql.IsEmptyString(sCOMMAND_NAME) )
			{
				sCONTROL_ID = 'btnDynamicButtons_' + sCOMMAND_NAME;
			}
			else if ( !Sql.IsEmptyString(sCONTROL_TEXT) )
			{
				sCONTROL_ID = 'btnDynamicButtons_' + sCONTROL_TEXT;
				if ( sCONTROL_TEXT.indexOf('.') >= 0 )
				{
					sCONTROL_ID = sCONTROL_TEXT.split('.')[1];
					sCONTROL_ID = sCONTROL_ID.replace('LBL_', '');
					sCONTROL_ID = sCONTROL_ID.replace('_BUTTON_LABEL', '');
				}
			}
			if ( !Sql.IsEmptyString(sCONTROL_ID) )
			{
				//sCONTROL_ID = sCONTROL_ID.Trim();
				// 12/24/2012 Paul.  Use regex global replace flag. 
				sCONTROL_ID = sCONTROL_ID.replace(/\s/g, '_');
				sCONTROL_ID = sCONTROL_ID.replace(/\./g, '_');
			}
			try
			{
				var arrTEXT_FIELD = new Array();
				var objTEXT_FIELD = new Array();
				if ( sTEXT_FIELD != null )
				{
					arrTEXT_FIELD = sTEXT_FIELD.split(' ');
					objTEXT_FIELD = arrTEXT_FIELD;
					for ( var i = 0 ; i < arrTEXT_FIELD.Length; i++ )
					{
						if ( arrTEXT_FIELD[i].length > 0 )
						{
							objTEXT_FIELD[i] = '';
							if ( row != null )
							{
								if ( row[arrTEXT_FIELD[i]] != null )
									objTEXT_FIELD[i] = row[arrTEXT_FIELD[i]];
							}
						}
					}
				}
				if ( sCONTROL_TYPE == 'Button' )
				{
					if ( Sql.IsEmptyString(sCOMMAND_NAME) )
					{
						sCOMMAND_NAME = sONCLICK_SCRIPT.replace('return false;', '');
						sCOMMAND_NAME = sCOMMAND_NAME.replace('Popup();', 's.Select');
						sCOMMAND_NAME = sCOMMAND_NAME.replace('Opportunitys', 'Opportunities');
					}
					if ( sCOMMAND_NAME.indexOf('.Create') > 0 || sCOMMAND_NAME.indexOf('.Select') > 0 )
					{
						sARGUMENT_FIELD = 'ID,NAME';
					}
					var btn = null;
					if ( iButton == 1 && sButtonStyle == 'ListHeader' && sCOMMAND_NAME.indexOf('.Search') > 0 && layout.length == 2 /* && sPLATFORM_LAYOUT == '.OfficeAddin'*/ )
					{
						btn = document.createElement('button');
						pnlDynamicButtons.appendChild(btn);
						// 04/17/2017 Paul.  Use Bootstrap for responsive design.
						if ( !SplendidDynamic.BootstrapLayout() )
						{
							btn.align = 'absmiddle';
							btn.style.borderWidth  = '0px';
							btn.style.marginLeft   = '-3px';
							btn.style.marginRight = '3px';
							btn.className = sButtonStyle + 'SearchButton';
						}
						else
						{
							btn.className = 'btn btn-primary';
						}
						var iNavSearch = document.createElement('span');
						iNavSearch.className = 'glyphicon glyphicon-search';
						btn.appendChild(iNavSearch);
					}
					else
					{
						// 04/13/2017 Paul.  Use Bootstrap for responsive design.
						if ( !SplendidDynamic.BootstrapLayout() )
						{
							btn = document.createElement('input');
							pnlDynamicButtons.appendChild(btn);
							btn.type              = 'submit';
							btn.className         = sCONTROL_CSSCLASS;
							btn.style.marginRight = '3px';
							// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
							if ( SplendidDynamic.StackedLayout(sTheme, sVIEW_NAME) )
							{
								btn.className = (iButton == 0 ? sButtonStyle + "FirstButton" : sButtonStyle + "OtherButton");
								btn.style.marginRight = '0px';
							}
							btn.value = '  ' + L10n.Term(sCONTROL_TEXT) + '  ';
							btn.title = (sCONTROL_TOOLTIP.length > 0) ? L10n.Term(sCONTROL_TOOLTIP) : '';
						}
						else
						{
							if ( bMoreListItems )
							{
								var li = document.createElement('li');
								pnlDynamicButtons.appendChild(li);
								btn = document.createElement('a');
								li.appendChild(btn);
								btn.href = '#';
								btn.appendChild(document.createTextNode(L10n.Term(sCONTROL_TEXT)));
							}
							else
							{
								btn = document.createElement('button');
								pnlDynamicButtons.appendChild(btn);
								btn.type      = 'button';
								btn.className = 'btn btn-primary';
								if ( sCONTROL_TEXT == '+' )
								{
									var glyph = document.createElement('span');
									glyph.className = 'glyphicon glyphicon-plus';
									btn.appendChild(glyph);
								}
								else
								{
									btn.appendChild(document.createTextNode(L10n.Term(sCONTROL_TEXT)));
								}
							}
						}
					}
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
						btn.id              = sCONTROL_ID;
					btn.CommandName     = sCOMMAND_NAME;
					//btn.OnClientClick   = sONCLICK_SCRIPT;
					// 03/14/2014 Paul.  Allow hidden buttons to be created. 
					if ( bHIDDEN )
						btn.style.display = 'none';
					var oARGUMENT_VALUE = null;
					if ( !Sql.IsEmptyString(sARGUMENT_FIELD) )
					{
						oARGUMENT_VALUE = new Object();
						oARGUMENT_VALUE['PARENT_MODULE'] = sMODULE_NAME;
						// 04/14/2016 Paul.  In order to inherit assigned user and team, might as well send the entire row. 
						oARGUMENT_VALUE['PARENT_row'] = row;
						var arrFields = sARGUMENT_FIELD.split(',');
						for ( var n in arrFields )
						{
							if ( row[arrFields[n]] != null )
							{
								oARGUMENT_VALUE[arrFields[n]] = row[arrFields[n]];
								//btn.CommandArgument = oARGUMENT_VALUE;
							}
						}
					}
					//btn.onclick = new Function('function("' + sLayoutPanel + '", "' + sCOMMAND_NAME + '", "' + sARGUMENT_VALUE + '")');
					btn.onclick = BindArguments(function(Page_Command, sLayoutPanel, sActionsPanel, sCOMMAND_NAME, oARGUMENT_VALUE, context)
					{
						Page_Command.call(context, sLayoutPanel, sActionsPanel, sCOMMAND_NAME, oARGUMENT_VALUE);
					}, Page_Command, sLayoutPanel, sActionsPanel, sCOMMAND_NAME, oARGUMENT_VALUE, context||this);
				}
				else if ( sCONTROL_TYPE == 'HyperLink' )
				{
					var lnk = document.createElement('a');
					pnlDynamicButtons.appendChild(lnk);
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
						lnk.id              = sCONTROL_ID;
					lnk.innerHTML       = L10n.Term(sCONTROL_TEXT);
					lnk.toolTip         = (sCONTROL_TOOLTIP.length > 0) ? L10n.Term(sCONTROL_TOOLTIP) : '';
					lnk.className       = sCONTROL_CSSCLASS;
					//lnk.href            = String_Format(sURL_FORMAT, objTEXT_FIELD);
					//btn.Command        += Page_Command;
					btn.CommandName     = sCOMMAND_NAME;
					//btn.OnClientClick   = sONCLICK_SCRIPT;
					lnk.style.marginRight = '3px';
					lnk.style.marginLeft  = '3px';
				}
				else if ( sCONTROL_TYPE == 'ButtonLink' )
				{
					var btn = null;
					// 04/13/2017 Paul.  Use Bootstrap for responsive design.
					if ( !SplendidDynamic.BootstrapLayout() )
					{
						btn = document.createElement('input');
						pnlDynamicButtons.appendChild(btn);
						btn.type            = 'submit';
						btn.className       = sCONTROL_CSSCLASS;
						btn.style.marginRight = '3px';
						// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
						if ( SplendidDynamic.StackedLayout(sTheme, sVIEW_NAME) )
						{
							var sButtonStyle = 'ModuleHeader';
							if ( sVIEW_NAME.indexOf('.EditView') >= 0 )
								sButtonStyle = 'EditHeader';
							btn.className = (iButton == 0 ? sButtonStyle + "FirstButton" : sButtonStyle + "OtherButton");
							btn.style.marginRight = '0px';
						}
						btn.value           = '  ' + L10n.Term(sCONTROL_TEXT) + '  ';
						btn.title           = (sCONTROL_TOOLTIP.length > 0) ? L10n.Term(sCONTROL_TOOLTIP) : '';
					}
					else
					{
						if ( bMoreListItems )
						{
							var li = document.createElement('li');
							pnlDynamicButtons.appendChild(li);
							btn = document.createElement('a');
							li.appendChild(btn);
							btn.href = '#';
							btn.appendChild(document.createTextNode(L10n.Term(sCONTROL_TEXT)));
						}
						else
						{
							btn = document.createElement('button');
							pnlDynamicButtons.appendChild(btn);
							btn.type      = 'button';
							btn.className = 'btn btn-primary';
							btn.appendChild(document.createTextNode(L10n.Term(sCONTROL_TEXT)));
						}
					}
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
						btn.id              = sCONTROL_ID;
					btn.CommandName     = sCOMMAND_NAME;
					//if ( sONCLICK_SCRIPT != null && sONCLICK_SCRIPT.length > 0 )
					//	btn.OnClientClick   = String.Format(sONCLICK_SCRIPT, objTEXT_FIELD);
					//else
					//	btn.OnClientClick   = "window.location.href='" + Sql.EscapeJavaScript(String_Format(sURL_FORMAT, objTEXT_FIELD)) + "'; return false;";
					//btn.onclick = new Function('function("' + sLayoutPanel + '", "' + sCOMMAND_NAME + '", null)');
					btn.onclick = BindArguments(function(Page_Command, sLayoutPanel, sActionsPanel, sCommandName, sCommandArguments, context)
					{
						Page_Command.call(context, sLayoutPanel, sActionsPanel, sCommandName, sCommandArguments);
					}, Page_Command, sLayoutPanel, sActionsPanel, sCOMMAND_NAME, null, context||this);
				}
			}
			catch(e)
			{
				SplendidError.SystemAlert(e, 'DynamicButtonsUI_LoadButtons ' + sCONTROL_TEXT);
			}
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'DynamicButtonsUI_LoadButtons');
	}
}

// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
function DynamicButtonsUI_Load(sLayoutPanel, sActionsPanel, sButtonStyle, sVIEW_NAME, row, Page_Command, callback, context)
{
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.DynamicButtons_LoadLayout(sVIEW_NAME, function(status, message)
		{
			if ( status == 1 )
			{
				// 10/03/2011 Paul.  DynamicButtons_LoadLayout returns the layout. 
				var layout = message;
				try
				{
					// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
					if ( SplendidDynamic.StackedLayout(Security.USER_THEME(), sVIEW_NAME) )
						DynamicButtonsUI_Clear(sLayoutPanel + '_Header_' + sActionsPanel);
					DynamicButtonsUI_Clear(sActionsPanel);
					//var layout = bgPage.SplendidCache.DynamicButtons(sVIEW_NAME);
					// 06/21/2015 Paul.  Seven theme buttons are on the Header panel. 
					DynamicButtonsUI_LoadButtons(sLayoutPanel, sActionsPanel, sButtonStyle, layout, row, Page_Command, this);
					// 08/20/2016 Paul.  We need to call and use the context. 
					callback.call(context, 1, null);
				}
				catch(e)
				{
					callback.call(context, -1, SplendidError.FormatError(e, 'DynamicButtonsUI_Load'));
				}
			}
			else
			{
				// 08/20/2016 Paul.  We need to call and use the context. 
				callback.call(context, status, message);
			}
		}, context||this);
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'DynamicButtonsUI_Load'));
	}
}

var pnlOfficeAddinUIActions = null;

function OfficeAddinUI_HidePopup()
{
	if ( pnlOfficeAddinUIActions != null )
	{
		pnlOfficeAddinUIActions.style.display = 'none';
		pnlOfficeAddinUIActions.style.visibility = 'hidden';
		pnlOfficeAddinUIActions = null;
	}
}

function OfficeAddinUI_PopupManagement(pnlModuleActions, ctlTabMenu_tabMenuInner)
{
	// http://www.quirksmode.org/dom/events/index.html
	ctlTabMenu_tabMenuInner.onmouseover = function(event)
	{
		if ( pnlOfficeAddinUIActions == pnlModuleActions )
			return;
		if ( pnlOfficeAddinUIActions != null )
		{
			pnlOfficeAddinUIActions.style.display    = 'none';
			pnlOfficeAddinUIActions.style.visibility = 'hidden';
			pnlOfficeAddinUIActions = null;
		}
		pnlModuleActions.style.display    = 'inline';
		pnlModuleActions.style.visibility = 'visible';
		pnlModuleActions.style.position   = 'absolute';
		var rect = ctlTabMenu_tabMenuInner.getBoundingClientRect();
		if ( navigator.userAgent.indexOf('MSAppHost') > 0 )
		{
			pnlModuleActions.style.left = Math.floor(rect.left  ) + 'px';
			pnlModuleActions.style.top  = Math.floor(rect.bottom) + 'px';
		}
		else
		{
			if ( window.pageXOffset !== undefined )
				pnlModuleActions.style.left       = (rect.left   + window.pageXOffset) + 'px';
			else if ( document.body.scrollLeft !== undefined )
				pnlModuleActions.style.left       = (rect.left   + document.body.scrollLeft) + 'px';
			if ( window.pageYOffset !== undefined )
				pnlModuleActions.style.top        = (rect.bottom + window.pageYOffset) + 'px';
			else if ( document.body.scrollTop !== undefined )
				pnlModuleActions.style.top        = (rect.bottom + document.body.scrollTop - 4) + 'px';
		}
		rect = pnlModuleActions.getBoundingClientRect();
		if ( rect.right > $(window).width() )
		{
			pnlModuleActions.style.left = ($(window).width() - (rect.right - rect.left)) + 'px';
		}
		pnlOfficeAddinUIActions = pnlModuleActions;
	};
	// http://www.quirksmode.org/dom/w3c_cssom.html
	ctlTabMenu_tabMenuInner.onmouseout = function(event)
	{
		var rect = pnlModuleActions.getBoundingClientRect();
		if ( event === undefined )
			event = window.event;
		if ( event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > (rect.bottom + 2) )
		{
			pnlModuleActions.style.display    = 'none';
			pnlModuleActions.style.visibility = 'hidden';
			pnlOfficeAddinUIActions = null;
		}
	};
	pnlModuleActions.onmouseover = function(event)
	{
	};
	pnlModuleActions.onmouseout = function(event)
	{
		var rect = pnlModuleActions.getBoundingClientRect();
		if ( event === undefined )
			event = window.event;
		if ( event.clientX < rect.left || event.clientX > rect.right || event.clientY < (rect.top - 2) || event.clientY > rect.bottom )
		{
			pnlModuleActions.style.display    = 'none';
			pnlModuleActions.style.visibility = 'hidden';
			pnlOfficeAddinUIActions = null;
		}
	};
}

function DynamicButtonsUI_OfficeAddinActions(sLayoutPanel, sActionsPanel, divActionsPanel, layout, row, sCOMMAND_MODULE, Page_Command, context)
{
	try
	{
		var divButtonHover = document.createElement(row == null ? 'span' : 'div');
		divActionsPanel.appendChild(divButtonHover);
		var btnActions = document.createElement('input');
		divButtonHover.appendChild(btnActions);
		btnActions.type      = 'submit';
		btnActions.value     = L10n.Term('.LBL_ACTIONS');
		btnActions.className = 'OfficeAddinActions';
		btnActions.onclick = function()
		{
			return false;
		};
		
		var pnlDynamicButtons = document.createElement('div');
		pnlDynamicButtons.id               = divActionsPanel.id + '_pnlDynamicButtons';
		if ( row != null )
			pnlDynamicButtons.style.marginTop  = '-7px';
		pnlDynamicButtons.className        = 'OfficeAddinOtherPanel';
		pnlDynamicButtons.style.display    = 'none';
		pnlDynamicButtons.style.visibility = 'hidden';
		divActionsPanel.appendChild(pnlDynamicButtons);
		
		OfficeAddinUI_PopupManagement(pnlDynamicButtons, divButtonHover);
		
		var sTheme = Security.USER_THEME();
		for ( var iButton in layout )
		{
			var lay = layout[iButton];
			// 03/06/2016 Paul.  sCOMMAND_NAME might be null, so we have to use Sql.ToString() so that we can use indexOf. 
			var sVIEW_NAME          = Sql.ToString(lay.VIEW_NAME         );
			var sCONTROL_TYPE       = Sql.ToString(lay.CONTROL_TYPE      );
			var sMODULE_NAME        = Sql.ToString(lay.MODULE_NAME       );
			//var sMODULE_ACCESS_TYPE = Sql.ToString(lay.MODULE_ACCESS_TYPE);
			//var sTARGET_NAME        = Sql.ToString(lay.TARGET_NAME       );
			//var sTARGET_ACCESS_TYPE = Sql.ToString(lay.TARGET_ACCESS_TYPE);
			var sCONTROL_TEXT       = Sql.ToString(lay.CONTROL_TEXT      );
			var sCONTROL_TOOLTIP    = Sql.ToString(lay.CONTROL_TOOLTIP   );
			var sCONTROL_CSSCLASS   = Sql.ToString(lay.CONTROL_CSSCLASS  );
			var sTEXT_FIELD         = Sql.ToString(lay.TEXT_FIELD        );
			var sARGUMENT_FIELD     = Sql.ToString(lay.ARGUMENT_FIELD    );
			var sCOMMAND_NAME       = Sql.ToString(lay.COMMAND_NAME      );
			var sURL_FORMAT         = Sql.ToString(lay.URL_FORMAT        );
			var sURL_TARGET         = Sql.ToString(lay.URL_TARGET        );
			var sONCLICK_SCRIPT     = Sql.ToString(lay.ONCLICK_SCRIPT    );
			// 03/14/2014 Paul.  Allow hidden buttons to be created. 
			var bHIDDEN             = Sql.ToBoolean(lay.HIDDEN);
			// 04/30/2017 Paul.  Apply access rights. 
			var nMODULE_ACLACCESS = (Sql.IsEmptyString(lay.MODULE_ACLACCESS) ? 0 : Sql.ToInteger(lay.MODULE_ACLACCESS));
			var nTARGET_ACLACCESS = (Sql.IsEmptyString(lay.TARGET_ACLACCESS) ? 0 : Sql.ToInteger(lay.TARGET_ACLACCESS));
			if ( nMODULE_ACLACCESS < 0 || nTARGET_ACLACCESS < 0 )
				continue;
			
			// 11/24/2012 Paul.  Search and ViewLog are not supported at this time. 
			// 03/10/2013 Paul.  SendInvites is not supported. 
			// 02/26/2016 Paul.  Enable search. 
			if ( !Sql.IsEmptyString(sCOMMAND_NAME) && (sCOMMAND_NAME == 'Save.SendInvites' || sCOMMAND_NAME == 'ViewLog' || sCOMMAND_NAME == 'vCard') )
				continue;
			else if ( bREMOTE_ENABLED && sVIEW_NAME == 'Users.DetailView' )
			{
				// 10/19/2014 Paul.  Users.DetailView ResetDefaults, ChangePassword, Duplicate are not supported. 
				if (sCOMMAND_NAME == 'EditMyAccount' || sCOMMAND_NAME == 'ResetDefaults' || sCOMMAND_NAME == 'ChangePassword' || sCOMMAND_NAME == 'Duplicate' )
					continue;
			}
			var sCONTROL_ID = '';
			if ( !Sql.IsEmptyString(sCOMMAND_NAME) )
			{
				sCONTROL_ID = 'btnDynamicButtons_' + sCOMMAND_NAME;
			}
			else if ( !Sql.IsEmptyString(sCONTROL_TEXT) )
			{
				sCONTROL_ID = 'btnDynamicButtons_' + sCONTROL_TEXT;
				if ( sCONTROL_TEXT.indexOf('.') >= 0 )
				{
					sCONTROL_ID = sCONTROL_TEXT.split('.')[1];
					sCONTROL_ID = sCONTROL_ID.replace('LBL_', '');
					sCONTROL_ID = sCONTROL_ID.replace('_BUTTON_LABEL', '');
				}
			}
			if ( !Sql.IsEmptyString(sCONTROL_ID) )
			{
				//sCONTROL_ID = sCONTROL_ID.Trim();
				// 12/24/2012 Paul.  Use regex global replace flag. 
				sCONTROL_ID = sCONTROL_ID.replace(/\s/g, '_');
				sCONTROL_ID = sCONTROL_ID.replace(/\./g, '_');
			}
			try
			{
				var arrTEXT_FIELD = new Array();
				var objTEXT_FIELD = new Array();
				if ( sTEXT_FIELD != null )
				{
					arrTEXT_FIELD = sTEXT_FIELD.split(' ');
					objTEXT_FIELD = arrTEXT_FIELD;
					for ( var i = 0 ; i < arrTEXT_FIELD.Length; i++ )
					{
						if ( arrTEXT_FIELD[i].length > 0 )
						{
							objTEXT_FIELD[i] = '';
							if ( row != null )
							{
								if ( row[arrTEXT_FIELD[i]] != null )
									objTEXT_FIELD[i] = row[arrTEXT_FIELD[i]];
							}
						}
					}
				}
				var oARGUMENT_VALUE = new Object();
				// 03/21/2016 Paul.  The OfficeAddin uses a shared list of buttons, so we must prepend the module to the command. 
				oARGUMENT_VALUE['COMMAND_MODULE'] = sCOMMAND_MODULE;
				if ( sCONTROL_TYPE == 'Button' )
				{
					if ( Sql.IsEmptyString(sCOMMAND_NAME) )
					{
						sCOMMAND_NAME = sONCLICK_SCRIPT.replace('return false;', '');
						sCOMMAND_NAME = sCOMMAND_NAME.replace('Popup();', 's.Select');
						sCOMMAND_NAME = sCOMMAND_NAME.replace('Opportunitys', 'Opportunities');
					}
					if ( sCOMMAND_NAME.indexOf('.Select') > 0 )
					{
						sARGUMENT_FIELD = 'ID,NAME';
					}
					var btn = document.createElement('input');
					btn.type               = 'submit';
					btn.value              = '  ' + L10n.Term(sCONTROL_TEXT) + '  ';
					btn.className          = 'OfficeAddinOtherButton';
					// 03/21/2016 Paul.  Style is getting taken-over by Office.css, so manually align left. 
					btn.style.textAlign    = 'left';
					btn.style.paddingLeft  = '4px';
					btn.style.paddingRight = '4px';
					btn.style.marginRight  = '0px';
					
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
						btn.id              = sCONTROL_ID;
					btn.title           = (sCONTROL_TOOLTIP.length > 0) ? L10n.Term(sCONTROL_TOOLTIP) : '';
					btn.CommandName     = sCOMMAND_NAME;
					//btn.OnClientClick   = sONCLICK_SCRIPT;
					btn.style.marginRight = '3px';
					// 03/14/2014 Paul.  Allow hidden buttons to be created. 
					if ( bHIDDEN )
						btn.style.display = 'none';
					if ( !Sql.IsEmptyString(sARGUMENT_FIELD) )
					{
						oARGUMENT_VALUE['PARENT_MODULE'] = sMODULE_NAME;
						var arrFields = sARGUMENT_FIELD.split(',');
						for ( var n in arrFields )
						{
							if ( row != null && row[arrFields[n]] != null )
							{
								oARGUMENT_VALUE[arrFields[n]] = row[arrFields[n]];
								//btn.CommandArgument = oARGUMENT_VALUE;
							}
						}
					}
					pnlDynamicButtons.appendChild(btn);
					if ( sCOMMAND_NAME == 'ArchiveEmail' )
					{
						if ( oARGUMENT_VALUE['ID'] !== null )
						{
							btn.id = 'ArchiveEmail_' + oARGUMENT_VALUE['ID'];
							if ( oExchangeSplendidRelated[oARGUMENT_VALUE['ID']] != null )
							{
								btn.style.textDecoration = 'line-through';
								btn.style.fontStyle      = 'italic';
								btn.disabled             = true;
								continue;
							}
						}
					}
					//btn.onclick = new Function('function("' + sLayoutPanel + '", "' + sCOMMAND_NAME + '", "' + sARGUMENT_VALUE + '")');
					btn.onclick = BindArguments(function(Page_Command, sLayoutPanel, sActionsPanel, sCOMMAND_NAME, oARGUMENT_VALUE, context)
					{
						Page_Command.call(context, sLayoutPanel, sActionsPanel, sCOMMAND_NAME, oARGUMENT_VALUE);
					}, Page_Command, sLayoutPanel, sActionsPanel, sCOMMAND_NAME, oARGUMENT_VALUE, context||this);
				}
				else if ( sCONTROL_TYPE == 'HyperLink' )
				{
					var lnk = document.createElement('a');
					pnlDynamicButtons.appendChild(lnk);
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
						lnk.id              = sCONTROL_ID;
					lnk.innerHTML       = L10n.Term(sCONTROL_TEXT);
					lnk.toolTip         = (sCONTROL_TOOLTIP.length > 0) ? L10n.Term(sCONTROL_TOOLTIP) : '';
					lnk.className       = sCONTROL_CSSCLASS;
					//lnk.href            = String_Format(sURL_FORMAT, objTEXT_FIELD);
					//btn.Command        += Page_Command;
					btn.CommandName     = sCOMMAND_NAME;
					//btn.OnClientClick   = sONCLICK_SCRIPT;
					lnk.style.marginRight = '3px';
					lnk.style.marginLeft  = '3px';
				}
				else if ( sCONTROL_TYPE == 'ButtonLink' )
				{
					var btn = document.createElement('input');
					btn.type            = 'submit';
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
						btn.id              = sCONTROL_ID;
					btn.value           = '  ' + L10n.Term(sCONTROL_TEXT) + '  ';
					btn.title           = (sCONTROL_TOOLTIP.length > 0) ? L10n.Term(sCONTROL_TOOLTIP) : '';
					btn.CommandName     = sCOMMAND_NAME;
					//if ( sONCLICK_SCRIPT != null && sONCLICK_SCRIPT.length > 0 )
					//	btn.OnClientClick   = String.Format(sONCLICK_SCRIPT, objTEXT_FIELD);
					//else
					//	btn.OnClientClick   = "window.location.href='" + Sql.EscapeJavaScript(String_Format(sURL_FORMAT, objTEXT_FIELD)) + "'; return false;";
					btn.className          = 'OfficeAddinOtherButton';
					// 03/21/2016 Paul.  Style is getting taken-over by Office.css, so manually align left. 
					btn.style.textAlign    = 'left';
					btn.style.paddingLeft  = '4px';
					btn.style.paddingRight = '4px';
					btn.style.marginRight  = '0px';
					//btn.onclick = new Function('function("' + sLayoutPanel + '", "' + sCOMMAND_NAME + '", null)');
					btn.onclick = BindArguments(function(Page_Command, sLayoutPanel, sActionsPanel, sCOMMAND_NAME, oARGUMENT_VALUE, context)
					{
						Page_Command.call(context, sLayoutPanel, sActionsPanel, sCOMMAND_NAME, oARGUMENT_VALUE);
					}, Page_Command, sLayoutPanel, sActionsPanel, sCOMMAND_NAME, oARGUMENT_VALUE, context||this);
					pnlDynamicButtons.appendChild(btn);
				}
			}
			catch(e)
			{
				console.log(e);
				SplendidError.SystemAlert(e, 'DynamicButtonsUI_OfficeAddinActions ' + sCONTROL_TEXT);
			}
		}
	}
	catch(e)
	{
		console.log(e);
		SplendidError.SystemAlert(e, 'DynamicButtonsUI_OfficeAddinActions');
	}
}
