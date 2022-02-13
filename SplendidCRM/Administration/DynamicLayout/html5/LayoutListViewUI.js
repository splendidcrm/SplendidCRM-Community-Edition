/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function LayoutListViewUI()
{
	this.MODULE_NAME        = null;
	this.GRID_NAME          = null;
	this.LAYOUT             = null;
	// 05/04/2016 Paul.  GRIDVIEWS fields to allow for layout copy. 
	this.VIEW_NAME          = '';
	this.EVENTS             = null;
	this.COLUMN_INDEX_START = null;
	this.MODULE_FIELDS      = new Array();
	this.MODULE_TERMINOLOGY = new Array();
	this.divSelectedLayoutField = null;

	this.COLUMN_TYPES = new Array();
	this.COLUMN_TYPES.push("BoundColumn"    );
	this.COLUMN_TYPES.push("TemplateColumn" );
	this.COLUMN_TYPES.push("HyperLinkColumn");

	this.DATA_FORMATS = new Array();
	this.DATA_FORMATS.push("HyperLink"  );
	this.DATA_FORMATS.push("Date"       );
	this.DATA_FORMATS.push("DateTime"   );
	this.DATA_FORMATS.push("Currency"   );
	this.DATA_FORMATS.push("Image"      );
	this.DATA_FORMATS.push("Hover"      );
	this.DATA_FORMATS.push("JavaScript" );
	this.DATA_FORMATS.push("JavaImage"  );
	this.DATA_FORMATS.push("ImageButton");
	this.DATA_FORMATS.push("Hidden"     );
	// 05/15/2016 Paul.  
	this.DATA_FORMATS.push("Tags"       );

	this.HORIZONTAL_ALIGN = new Array();
	this.HORIZONTAL_ALIGN.push("Left"   );
	this.HORIZONTAL_ALIGN.push("Center" );
	this.HORIZONTAL_ALIGN.push("Right"  );
	this.HORIZONTAL_ALIGN.push("Justify");

	this.VERTICAL_ALIGN = new Array();
	this.VERTICAL_ALIGN.push("Bottom");
	this.VERTICAL_ALIGN.push("Middle");
	this.VERTICAL_ALIGN.push("Top"   );

	this.FIELDS = new Array();
}

LayoutListViewUI.prototype.UpdateLayout = function(message)
{
	this.LAYOUT = message;
	// 05/04/2016 Paul.  GRIDVIEWS fields to allow for layout copy. 
	this.VIEW_NAME = '';
	if ( this.LAYOUT != null && this.LAYOUT.length > 0 )
	{
		var lay = this.LAYOUT[0];
		this.VIEW_NAME = Sql.ToString(lay.VIEW_NAME);
	}
	if ( Sql.IsEmptyString(this.VIEW_NAME) )
		this.VIEW_NAME = 'vw' + this.MODULE_NAME.toUpperCase();
}

LayoutListViewUI.prototype.AllowDeleteLayout = function()
{
	var bAllowDelete = true;
	if      ( this.GRID_NAME == 'Accounts.Assets'                     ) bAllowDelete = false;
	else if ( this.GRID_NAME == 'Accounts.Balance'                    ) bAllowDelete = false;
	else if ( this.GRID_NAME == 'Accounts.MemberOrganizations'        ) bAllowDelete = false;
	else if ( this.GRID_NAME == 'Campaigns.CallMarketing'             ) bAllowDelete = false;
	else if ( this.GRID_NAME == 'Campaigns.CampaignTrackers'          ) bAllowDelete = false;
	else if ( this.GRID_NAME == 'Campaigns.EmailMarketing'            ) bAllowDelete = false;
	else if ( this.GRID_NAME == 'Contacts.DirectReports'              ) bAllowDelete = false;
	else if ( this.GRID_NAME == 'Documents.DocumentRevisions'         ) bAllowDelete = false;
	else if ( this.GRID_NAME == 'Payments.PaymentTransactions'        ) bAllowDelete = false;
	else if ( this.GRID_NAME == 'Products.RelatedProducts'            ) bAllowDelete = false;
	else if ( this.GRID_NAME == 'ProductTemplates.RelatedProducts'    ) bAllowDelete = false;
	else if ( StartsWith(this.GRID_NAME, 'Azure%'                   ) ) bAllowDelete = false;
	else if ( StartsWith(this.GRID_NAME, 'SurveyResults.%'          ) ) bAllowDelete = false;
	else if ( StartsWith(this.GRID_NAME, 'Surveys.%'                ) ) bAllowDelete = false;
	else if ( StartsWith(this.GRID_NAME, 'SurveyPages.%'            ) ) bAllowDelete = false;
	else if ( StartsWith(this.GRID_NAME, 'SurveyQuestions.%'        ) ) bAllowDelete = false;
	else if ( StartsWith(this.GRID_NAME, 'Users.%'                  ) ) bAllowDelete = false;
	else if ( StartsWith(this.GRID_NAME, 'Teams.%'                  ) ) bAllowDelete = false;
	else if ( StartsWith(this.GRID_NAME, 'Workflows.%'              ) ) bAllowDelete = false;
	else if ( StartsWith(this.GRID_NAME, 'AuthorizeNet.%'           ) ) bAllowDelete = false;
	else if ( StartsWith(this.GRID_NAME, 'QuickBooks.%'             ) ) bAllowDelete = false;
	else if ( StartsWith(this.GRID_NAME, 'Campaigns.Track%'         ) ) bAllowDelete = false;
	else if ( StartsWith(this.GRID_NAME, 'Twitter%'                 ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.ListView'                  ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.PopupView'                 ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.PopupAddressView'          ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.PreviewView'               ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Mobile'                    ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Portal'                    ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Export'                    ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.OfficeAddin'               ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Search'                    ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.SearchDuplicates'          ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.SearchPhones'              ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Template'                  ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Activities.History'        ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Activities.Open'           ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyActivities'              ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Exchange'                  ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.GoogleApps'                ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Gmail'                     ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.iCloud'                    ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.QuickBooks'                ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.QuickBooksOnline'          ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.HubSpot'                   ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Marketo'                   ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MailChimp'                 ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Accounts'                  ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Bugs'                      ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Cases'                     ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Contacts'                  ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Contracts'                 ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.CreditCards'               ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Documents'                 ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Invoices'                  ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Leads'                     ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.LineItems'                 ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Opportunities'             ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Orders'                    ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Payments'                  ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Products'                  ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Project'                   ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.ProjectTask'               ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Prospects'                 ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.ProspectLists'             ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Quotes'                    ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Threads'                   ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Notes'                     ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Users'                     ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.Posts'                     ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.KBDocuments'               ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.ChatMessages'              ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.SurveyResults'             ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyAccounts'                ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyBugs'                    ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyCalls'                   ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyCases'                   ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyContacts'                ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyEmails'                  ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyLeads'                   ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyMeetings'                ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyOpportunities'           ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyInvoices'                ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyOrders'                  ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyQuotes'                  ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyProjects'                ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyProjectTasks'            ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyProspects'               ) ) bAllowDelete = false;
	else if ( EndsWith(this.GRID_NAME, '.MyTasks'                   ) ) bAllowDelete = false;
	return bAllowDelete;
}

LayoutListViewUI.prototype.PageCommand = function(sCommandName, sCommandArguments)
{
	SplendidError.SystemMessage('');
	// 05/04/2016 Paul.  Provide a way to save a layout copy. 
	if ( sCommandName == 'Copy' )
	{
		var txtCopyLayout    = document.getElementById('txtCopyLayout'   );
		var btnRoleSelect    = document.getElementById('btnRoleSelect'   );
		var btnDeleteLayout  = document.getElementById('btnDeleteLayout' );
		var btnLayoutRestore = document.getElementById('btnLayoutRestore');
		var btnLayoutExport  = document.getElementById('btnLayoutExport' );
		if ( txtCopyLayout.style.display == 'none' )
		{
			txtCopyLayout.LAYOUT_NAME      = this.GRID_NAME;
			txtCopyLayout.value            = this.GRID_NAME + '.Copy';
			txtCopyLayout.style.display    = 'inline';
			btnRoleSelect.style.display    = 'inline';
			btnDeleteLayout.style.display  = 'none'  ;
			btnLayoutRestore.style.display = 'none'  ;
			btnLayoutExport.style.display  = 'none'  ;
		}
		else
		{
			txtCopyLayout.value            = '';
			txtCopyLayout.style.display    = 'none'  ;
			btnRoleSelect.style.display    = 'none'  ;
			btnDeleteLayout.style.display  = (this.AllowDeleteLayout() ? 'inline' : 'none');
			btnLayoutRestore.style.display = 'inline';
			btnLayoutExport.style.display  = 'inline';
		}
	}
	else if ( sCommandName == 'Delete' )
	{
		try
		{
			var obj = new Object();
			AdminLayout_Delete('GRIDVIEWS_COLUMNS', this.GRID_NAME, obj, function(status, message)
			{
				if ( status == 1 )
				{
					AdminLayoutDeleteView(this.MODULE_NAME, this.GRID_NAME);
					AdminLayoutClear();
				}
				else
				{
					SplendidError.SystemMessage(message);
				}
			}, this);
		}
		catch(e)
		{
			SplendidError.SystemError(e, 'LayoutListViewUI.PageCommand');
		}
	}
	else if ( sCommandName == 'Save' )
	{
		try
		{
			var tblLayout = document.getElementById('tblLayout');
			var bgPage = chrome.extension.getBackgroundPage();
			var obj = new Object();
			obj.GRIDVIEWS                     = new Object();
			// 05/04/2016 Paul.  EDITVIEWS fields to allow for layout copy. 
			obj.GRIDVIEWS.MODULE_NAME         = this.MODULE_NAME;
			obj.GRIDVIEWS.VIEW_NAME           = this.VIEW_NAME  ;
			obj.GRIDVIEWS.PRE_LOAD_EVENT_ID   = document.getElementById('tblEvents_PRE_LOAD_EVENT_ID'  ).value;
			obj.GRIDVIEWS.POST_LOAD_EVENT_ID  = document.getElementById('tblEvents_POST_LOAD_EVENT_ID' ).value;
			obj.GRIDVIEWS.SCRIPT              = document.getElementById('tblEvents_SCRIPT'             ).value;
			obj.GRIDVIEWS_COLUMNS = new Array();

			var nCOLUMN_INDEX = Sql.ToInteger(this.COLUMN_INDEX_START);
			for ( var i = 0; i < tblLayout.rows.length; i++ )
			{
				var tr = tblLayout.rows[i];
				for ( var j = 0; j < tr.cells.length; j++ )
				{
					var td = tr.cells[j];
					for ( var k = 0; k < td.childNodes.length; k++ )
					{
						var div = td.childNodes[k];
						var lay = this.CreateLayoutObject(div);
						if ( !Sql.IsEmptyString(lay.COLUMN_TYPE) )
						{
							lay.COLUMN_INDEX = nCOLUMN_INDEX;
							obj.GRIDVIEWS_COLUMNS.push(lay);
							nCOLUMN_INDEX++;
						}
					}
				}
			}
			// 05/04/2016 Paul.  Provide a way to save a layout copy. 
			var sVIEW_NAME = this.GRID_NAME;
			var txtCopyLayout = document.getElementById('txtCopyLayout');
			if ( txtCopyLayout.style.display == 'inline' )
			{
				txtCopyLayout.value = Trim(txtCopyLayout.value);
				if ( Sql.IsEmptyString(txtCopyLayout.value) || txtCopyLayout.value == sVIEW_NAME )
				{
					AdminLayoutMesasge(L10n.Term('DynamicLayout.ERR_NEW_LAYOUT_NAME'));
					return;
				}
				else
				{
					sVIEW_NAME = txtCopyLayout.value;
				}
			}
			AdminLayout_Update('GRIDVIEWS_COLUMNS', sVIEW_NAME, obj, function(status, message)
			{
				if ( status == 1 )
				{
					// 05/04/2016 Paul.  Update view and hide copy on success. 
					if ( txtCopyLayout.style.display == 'inline' )
					{
						this.GRID_NAME = sVIEW_NAME;
						this.PageCommand('Copy', null);
						AdminLayoutAddView(this.MODULE_NAME, this.GRID_NAME, 'ListView');
					}
					AdminLayoutMesasge(L10n.Term('DynamicLayout.LBL_SAVE_COMPLETE'));
					this.Reload(false);
				}
				else
				{
					SplendidError.SystemMessage(message);
				}
			}, this);
		}
		catch(e)
		{
			SplendidError.SystemError(e, 'LayoutListViewUI.PageCommand');
		}
	}
	else if ( sCommandName == 'Cancel' )
	{
		try
		{
			AdminLayoutClear();
		}
		catch(e)
		{
			SplendidError.SystemError(e, 'LayoutListViewUI.PageCommand');
		}
	}
}

LayoutListViewUI.prototype.AddProperty = function(tblProperties, sFieldName, sFieldValue)
{
	var tr = null;
	var tdLabel = null;
	var tdField = null;
	tr = tblProperties.insertRow(-1);
	tr.id = 'tblProperties_tr' + sFieldName;
	tdLabel = tr.insertCell(-1);
	tdField = tr.insertCell(-1);
	tdLabel.style.width = '35%';
	$(tdLabel).text(L10n.Term('DynamicLayout.LBL_' + sFieldName));
	var spn = document.createElement('span');
	spn.id = 'tblProperties_' + sFieldName;
	$(spn).text(sFieldValue);
	tdField.appendChild(spn);
}

LayoutListViewUI.prototype.AddTextBoxProperty = function(tblProperties, sFieldName, sFieldValue, sWidth)
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
	$(tdLabel).text(L10n.Term('DynamicLayout.LBL_' + sFieldName));
	//$(tdField).text(sFieldValue);
	var txt = document.createElement('input');
	txt.id    = 'tblProperties_' + sFieldName;
	txt.type  = 'text';
	txt.style.width = (sWidth === undefined ? '200px' : sWidth);
	txt.value = sFieldValue;
	tdField.appendChild(txt);
}

LayoutListViewUI.prototype.AddCheckBoxProperty = function(tblProperties, sFieldName, sFieldValue)
{
	var tr = null;
	var tdLabel = null;
	var tdField = null;
	tr = tblProperties.insertRow(-1);
	tr.id = 'tblProperties_tr' + sFieldName;
	tdLabel = tr.insertCell(-1);
	tdField = tr.insertCell(-1);
	tdLabel.style.width = '35%';
	$(tdLabel).text(L10n.Term('DynamicLayout.LBL_' + sFieldName));
	//$(tdField).text(sFieldValue);
	var chk = document.createElement('input');
	chk.id        = 'tblProperties_' + sFieldName;
	chk.type      = 'checkbox';
	chk.className = 'checkbox';
	chk.checked   = Sql.ToBoolean(sFieldValue);
	tdField.appendChild(chk);
}

LayoutListViewUI.prototype.AddTextAreaProperty = function(tblProperties, sFieldName, sFieldValue)
{
	var tr = null;
	var tdLabel = null;
	var tdField = null;
	tr = tblProperties.insertRow(-1);
	tr.id = 'tblProperties_tr' + sFieldName;
	tdLabel = tr.insertCell(-1);
	tdField = tr.insertCell(-1);
	tdLabel.style.width = '35%';
	$(tdLabel).text(L10n.Term('DynamicLayout.LBL_' + sFieldName));
	//$(tdField).text(sFieldValue);
	var txt = document.createElement('textarea');
	txt.id           = 'tblProperties_' + sFieldName;
	txt.style.width  = '95%';
	txt.rows         = 3;
	txt.value = sFieldValue;
	tdField.appendChild(txt);
}

LayoutListViewUI.prototype.AddListBoxProperty = function(tblProperties, sFieldName, sFieldValue, sListName, bAllowNone)
{
	var tr = null;
	var tdLabel = null;
	var tdField = null;
	tr = tblProperties.insertRow(-1);
	tr.id = 'tblProperties_tr' + sFieldName;
	tdLabel = tr.insertCell(-1);
	tdField = tr.insertCell(-1);
	tdLabel.style.width = '35%';
	$(tdLabel).text(L10n.Term('DynamicLayout.LBL_' + sFieldName));
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

LayoutListViewUI.prototype.ShowProperty = function(sFieldName, bVisible)
{
	var tr = document.getElementById('tblProperties_tr' + sFieldName);
	if ( tr != null )
		tr.style.display = (bVisible ? 'table-row' : 'none');
}

LayoutListViewUI.prototype.GetPropertyVisibility = function(sFieldName)
{
	var bVisible = false;
	var tr = document.getElementById('tblProperties_tr' + sFieldName);
	if ( tr != null )
		bVisible = (tr.style.display != 'none');
	return bVisible;
}

LayoutListViewUI.prototype.GetPropertyValue = function(sFieldName)
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

LayoutListViewUI.prototype.SaveProperties = function()
{
	if ( this.divSelectedLayoutField != null )
	{
//debugger;
		var obj = new Object();
		obj.COLUMN_TYPE                = this.GetPropertyValue('COLUMN_TYPE'               );
		obj.DATA_FORMAT                = this.GetPropertyValue('DATA_FORMAT'               );
		obj.HEADER_TEXT                = this.GetPropertyValue('HEADER_TEXT'               );
		obj.DATA_FIELD                 = this.divSelectedLayoutField.DATA_FIELD;
		obj.SORT_EXPRESSION            = this.GetPropertyValue('SORT_EXPRESSION'           );
		obj.ITEMSTYLE_WIDTH            = this.GetPropertyValue('ITEMSTYLE_WIDTH'           );
		obj.ITEMSTYLE_CSSCLASS         = this.GetPropertyValue('ITEMSTYLE_CSSCLASS'        );
		obj.ITEMSTYLE_HORIZONTAL_ALIGN = this.GetPropertyValue('ITEMSTYLE_HORIZONTAL_ALIGN');
		obj.ITEMSTYLE_VERTICAL_ALIGN   = this.GetPropertyValue('ITEMSTYLE_VERTICAL_ALIGN'  );
		obj.ITEMSTYLE_WRAP             = this.GetPropertyValue('ITEMSTYLE_WRAP'            );
		obj.URL_FIELD                  = this.GetPropertyValue('URL_FIELD'                 );
		obj.URL_FORMAT                 = this.GetPropertyValue('URL_FORMAT'                );
		obj.URL_TARGET                 = this.GetPropertyValue('URL_TARGET'                );
		obj.URL_MODULE                 = this.GetPropertyValue('URL_MODULE'                );
		obj.URL_ASSIGNED_FIELD         = this.GetPropertyValue('URL_ASSIGNED_FIELD'        );
		obj.MODULE_TYPE                = this.GetPropertyValue('MODULE_TYPE'               );
		obj.LIST_NAME                  = this.GetPropertyValue('LIST_NAME'                 );
		obj.PARENT_FIELD               = this.GetPropertyValue('PARENT_FIELD'              );
		// 05/30/2017 Paul.  We need to manually set the label for TeamSelect and TagSelect as they are not visible. 
		if ( obj.FIELD_TYPE == 'TeamSelect' )
		{
			obj.DATA_LABEL = '.LBL_LIST_TEAM_SET_NAME';
		}
		// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		else if ( obj.FIELD_TYPE == 'UserSelect' )
		{
			obj.DATA_LABEL = '.LBL_LIST_ASSIGNED_SET_NAME';
		}
		else if ( obj.FIELD_TYPE == 'TagSelect' )
		{
			obj.DATA_LABEL = '.LBL_LIST_TAG_SET_NAME';
		}
		// 06/07/2017 Paul.  Add NAICSCodes module. 
		else if ( obj.FIELD_TYPE == 'NAICSCodeSelect' )
		{
			obj.DATA_LABEL = 'NAICSCodes.LBL_NAICS_SET_NAME';
		}
		this.SetLayoutObject(this.divSelectedLayoutField, obj);
	}
	this.CancelProperties();
	return false;
}

LayoutListViewUI.prototype.CancelProperties = function()
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

LayoutListViewUI.prototype.LoadProperties = function(divLayoutField)
{
	this.divSelectedLayoutField = divLayoutField;

	var divPropertiesButtons = document.getElementById('divPropertiesButtons');
	divPropertiesButtons.style.display = 'block';
	while ( divPropertiesButtons.childNodes.length > 0 )
	{
		divPropertiesButtons.removeChild(divPropertiesButtons.firstChild);
	}

	var btnPropertiesSave   = document.createElement('input');
	btnPropertiesSave.id                = 'btnPropertiesSave';
	btnPropertiesSave.type              = 'button';
	btnPropertiesSave.className         = 'button';
	btnPropertiesSave.value             = L10n.Term('.LBL_SAVE_BUTTON_LABEL'  );
	btnPropertiesSave.style.cursor      = 'pointer';
	btnPropertiesSave.style.marginRight = '3px';
	divPropertiesButtons.appendChild(btnPropertiesSave  );
	btnPropertiesSave.onclick     = BindArguments(function(context)
	{
		context.SaveProperties();
	}, this);

	var btnPropertiesCancel = document.createElement('input');
	divPropertiesButtons.appendChild(btnPropertiesCancel);
	btnPropertiesCancel.id                = 'btnPropertiesCancel';
	btnPropertiesCancel.type              = 'button';
	btnPropertiesCancel.className         = 'button';
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
	this.AddListBoxProperty (tblProperties, 'COLUMN_TYPE'               , Sql.ToString (divLayoutField.COLUMN_TYPE               ), this.COLUMN_TYPES      , false);
	this.AddListBoxProperty (tblProperties, 'DATA_FORMAT'               , Sql.ToString (divLayoutField.DATA_FORMAT               ), this.DATA_FORMATS      , true );
	this.AddListBoxProperty (tblProperties, 'HEADER_TEXT'               , Sql.ToString (divLayoutField.HEADER_TEXT               ), this.MODULE_TERMINOLOGY, true );
	this.AddProperty        (tblProperties, 'DATA_FIELD'                , Sql.ToString (divLayoutField.DATA_FIELD                ));
	this.AddListBoxProperty (tblProperties, 'SORT_EXPRESSION'           , Sql.ToString (divLayoutField.SORT_EXPRESSION           ), this.FIELDS            , true );
	this.AddTextBoxProperty (tblProperties, 'ITEMSTYLE_WIDTH'           , Sql.ToString (divLayoutField.ITEMSTYLE_WIDTH           ), '100px');
	this.AddTextBoxProperty (tblProperties, 'ITEMSTYLE_CSSCLASS'        , Sql.ToString (divLayoutField.ITEMSTYLE_CSSCLASS        ));
	this.AddListBoxProperty (tblProperties, 'ITEMSTYLE_HORIZONTAL_ALIGN', Sql.ToString (divLayoutField.ITEMSTYLE_HORIZONTAL_ALIGN), this.HORIZONTAL_ALIGN  , true );
	this.AddListBoxProperty (tblProperties, 'ITEMSTYLE_VERTICAL_ALIGN'  , Sql.ToString (divLayoutField.ITEMSTYLE_VERTICAL_ALIGN  ), this.VERTICAL_ALIGN    , true );
	// 05/15/2016 Paul.  Special rule where null is true.  This is because this field was added after initial implementation. 
	if ( divLayoutField.ITEMSTYLE_WRAP == null )
		divLayoutField.ITEMSTYLE_WRAP = true;
	this.AddCheckBoxProperty(tblProperties, 'ITEMSTYLE_WRAP'            , Sql.ToBoolean(divLayoutField.ITEMSTYLE_WRAP            ));
	this.AddTextAreaProperty(tblProperties, 'URL_FIELD'                 , Sql.ToString (divLayoutField.URL_FIELD                 ));
	this.AddTextAreaProperty(tblProperties, 'URL_FORMAT'                , Sql.ToString (divLayoutField.URL_FORMAT                ));
	this.AddTextBoxProperty (tblProperties, 'URL_TARGET'                , Sql.ToString (divLayoutField.URL_TARGET                ));
	this.AddTextBoxProperty (tblProperties, 'URL_MODULE'                , Sql.ToString (divLayoutField.URL_MODULE                ));
	this.AddTextBoxProperty (tblProperties, 'URL_ASSIGNED_FIELD'        , Sql.ToString (divLayoutField.URL_ASSIGNED_FIELD        ));
	this.AddListBoxProperty (tblProperties, 'MODULE_TYPE'               , Sql.ToString (divLayoutField.MODULE_TYPE               ), TERMINOLOGY_LISTS['MODULE_TYPES'], true );
	this.AddListBoxProperty (tblProperties, 'LIST_NAME'                 , Sql.ToString (divLayoutField.LIST_NAME                 ), TERMINOLOGY_LISTS['vwTERMINOLOGY_PickList'], true );
	this.AddTextBoxProperty (tblProperties, 'PARENT_FIELD'              , Sql.ToString (divLayoutField.PARENT_FIELD              ));


	var lstCOLUMN_TYPE = document.getElementById('tblProperties_COLUMN_TYPE');
	lstCOLUMN_TYPE.onchange = BindArguments(function(context)
	{
		context.FieldTypeChanged();
	}, this);
	var lstDATA_FORMAT = document.getElementById('tblProperties_DATA_FORMAT');
	lstDATA_FORMAT.onchange = BindArguments(function(context)
	{
		context.FieldTypeChanged();
	}, this);
	this.FieldTypeChanged();
}

LayoutListViewUI.prototype.FieldTypeChanged = function()
{
	var lstCOLUMN_TYPE = document.getElementById('tblProperties_COLUMN_TYPE');
	var lstDATA_FORMAT = document.getElementById('tblProperties_DATA_FORMAT');
	var sCOLUMN_TYPE = lstCOLUMN_TYPE.options[lstCOLUMN_TYPE.options.selectedIndex].value;
	var sDATA_FORMAT = lstDATA_FORMAT.options[lstDATA_FORMAT.options.selectedIndex].value;
	// 06/19/2010 Paul.  JavaScript data format show show URL Field, Format and Target. 
	// 08/02/2010 Paul.  The Hover control is very similar to a JavaScript control. 
	// 02/28/2014 Paul.  JavaImage is just like JavaScript, but shows an icon. 
	// 03/01/2014 Paul.  ImageButton is just like JavaScript, but shows an icon and has a command event. 
	this.ShowProperty('URL_FIELD'         , (sCOLUMN_TYPE == "HyperLinkColumn" || sDATA_FORMAT == "HyperLink" || sDATA_FORMAT == "JavaScript" || sDATA_FORMAT == "Hover" || sDATA_FORMAT == "JavaImage" || sDATA_FORMAT == "ImageButton"));
	// 08/15/2014 Paul.  Show the URL_FORMAT for Images so that we can point to the EmailImages URL. 
	this.ShowProperty('URL_FORMAT'        , (sCOLUMN_TYPE == "HyperLinkColumn" || sDATA_FORMAT == "HyperLink" || sDATA_FORMAT == "JavaScript" || sDATA_FORMAT == "Hover" || sDATA_FORMAT == "JavaImage" || sDATA_FORMAT == "ImageButton" || sDATA_FORMAT == "Image"));
	this.ShowProperty('URL_TARGET'        , (sCOLUMN_TYPE == "HyperLinkColumn" || sDATA_FORMAT == "HyperLink" || sDATA_FORMAT == "JavaScript" || sDATA_FORMAT == "Hover" || sDATA_FORMAT == "JavaImage" || sDATA_FORMAT == "ImageButton"));
	this.ShowProperty('URL_MODULE'        , (sCOLUMN_TYPE == "HyperLinkColumn" || sDATA_FORMAT == "HyperLink"));
	this.ShowProperty('URL_ASSIGNED_FIELD', (sCOLUMN_TYPE == "HyperLinkColumn" || sDATA_FORMAT == "HyperLink"));
	// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
	this.ShowProperty('PARENT_FIELD'      , (sCOLUMN_TYPE == "HyperLinkColumn" || sDATA_FORMAT == "HyperLink"));
	// 02/17/2010 Paul.  The Module Type only applies to TemplateColumn HyperLink. 
	this.ShowProperty('MODULE_TYPE'       , (sCOLUMN_TYPE == "TemplateColumn"  && sDATA_FORMAT == "HyperLink"));
}

LayoutListViewUI.prototype.LoadFromLayout = function()
{
	var tblLayout = document.getElementById('tblLayout');
	// 04/06/2016 Paul.  Clear rows before building.  List was duplicating after save. 
	while ( tblLayout.rows.length > 0 )
	{
		tblLayout.deleteRow(0);
	}
	if ( this.LAYOUT != null && this.LAYOUT.length > 0 )
	{
		var tr = null;
		var td = null;
		for ( var nLayoutIndex in this.LAYOUT )
		{
			var lay = this.LAYOUT[nLayoutIndex];
			var sCOLUMN_TYPE = Sql.ToString (lay.COLUMN_TYPE);
			var sDATA_FORMAT = Sql.ToString (lay.DATA_FORMAT);
			if ( this.COLUMN_INDEX_START == null )
				this.COLUMN_INDEX_START =lay.COLUMN_INDEX;

			tr = tblLayout.insertRow(-1);
			this.BindRow(tblLayout, tr, lay);
			td = tr.insertCell(-1);
			this.BindColumn(tblLayout, td, lay);
		}
	}
}

LayoutListViewUI.prototype.CreateLayoutObject = function(src)
{
	var obj = new Object();
	obj.COLUMN_TYPE                = Sql.ToString (src.COLUMN_TYPE                );
	obj.DATA_FORMAT                = Sql.ToString (src.DATA_FORMAT                );
	obj.HEADER_TEXT                = Sql.ToString (src.HEADER_TEXT                );
	obj.DATA_FIELD                 = Sql.ToString (src.DATA_FIELD                 );
	obj.SORT_EXPRESSION            = Sql.ToString (src.SORT_EXPRESSION            );
	obj.ITEMSTYLE_WIDTH            = Sql.ToString (src.ITEMSTYLE_WIDTH            );
	obj.ITEMSTYLE_CSSCLASS         = Sql.ToString (src.ITEMSTYLE_CSSCLASS         );
	obj.ITEMSTYLE_HORIZONTAL_ALIGN = Sql.ToString (src.ITEMSTYLE_HORIZONTAL_ALIGN );
	obj.ITEMSTYLE_VERTICAL_ALIGN   = Sql.ToString (src.ITEMSTYLE_VERTICAL_ALIGN   );
	// 05/15/2016 Paul.  Special rule where null is true.  This is because this field was added after initial implementation. 
	if ( src.ITEMSTYLE_WRAP == null )
		src.ITEMSTYLE_WRAP = true;
	obj.ITEMSTYLE_WRAP             = Sql.ToBoolean(src.ITEMSTYLE_WRAP             );
	obj.URL_FIELD                  = Sql.ToString (src.URL_FIELD                  );
	obj.URL_FORMAT                 = Sql.ToString (src.URL_FORMAT                 );
	obj.URL_TARGET                 = Sql.ToString (src.URL_TARGET                 );
	obj.URL_MODULE                 = Sql.ToString (src.URL_MODULE                 );
	obj.URL_ASSIGNED_FIELD         = Sql.ToString (src.URL_ASSIGNED_FIELD         );
	obj.MODULE_TYPE                = Sql.ToString (src.MODULE_TYPE                );
	obj.LIST_NAME                  = Sql.ToString (src.LIST_NAME                  );
	obj.PARENT_FIELD               = Sql.ToString (src.PARENT_FIELD               );
	return obj;
}

LayoutListViewUI.prototype.RenderField = function(div)
{
	while ( div.childNodes.length > 0 )
	{
		div.removeChild(div.firstChild);
	}
	
	var divDATA_FIELD  = document.createElement('div');
	var divHEADER_TEXT = document.createElement('div');
	div.appendChild(divDATA_FIELD);
	div.appendChild(divHEADER_TEXT);
	if ( div.DATA_FORMAT == 'Hover' )
	{
		$(divDATA_FIELD).text(L10n.Term('DynamicLayout.LBL_HOVER_TYPE'));
		$(divHEADER_TEXT).text(div.URL_FIELD);
	}
	else if ( div.DATA_FORMAT == 'ImageButton' )
	{
		$(divDATA_FIELD).text(L10n.Term('DynamicLayout.LBL_IMAGE_BUTTON_TYPE'));
		$(divHEADER_TEXT).text(div.URL_FIELD);
	}
	else if ( div.DATA_FORMAT == 'JavaScript' )
	{
		$(divDATA_FIELD).text(L10n.Term('DynamicLayout.LBL_JAVASCRIPT_TYPE'));
		$(divHEADER_TEXT).text(div.URL_FIELD);
	}
	else
	{
		$(divDATA_FIELD).text(div.DATA_FIELD);
		$(divHEADER_TEXT).text(L10n.Term(div.HEADER_TEXT));
		if ( Sql.IsEmptyString(div.HEADER_TEXT) )
		{
			var nbsp = String.fromCharCode(160);
			$(divHEADER_TEXT).text(nbsp);
		}
		// 03/13/2016 Paul.  Display the list name to make it easier to confirm the change. 
		if ( !Sql.IsEmptyString(div.LIST_NAME) )
		{
			var divLIST_NAME = document.createElement('div');
			divHEADER_TEXT.appendChild(divLIST_NAME);
			divLIST_NAME.style.float = 'right';
			$(divLIST_NAME).text(div.LIST_NAME);
		}
	}
	// 04/06/2016 Paul.  Blank field should not have edit icon. 
	if (div.FIELD_TYPE == 'Blank')
	{
		$(divDATA_FIELD).text(L10n.Term('DynamicLayout.LBL_BLANK_TYPE'));
		$(divDATA_LABEL).text(String.fromCharCode(160));
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
		divDATA_FIELD.appendChild(imgEdit);
		imgEdit.onclick = BindArguments(function(context)
		{
			context.LoadProperties(div);
		}, this);
	}
}

LayoutListViewUI.prototype.SetLayoutObject = function(div, src)
{
	div.COLUMN_TYPE                = Sql.ToString (src.COLUMN_TYPE                );
	div.DATA_FORMAT                = Sql.ToString (src.DATA_FORMAT                );
	div.HEADER_TEXT                = Sql.ToString (src.HEADER_TEXT                );
	div.DATA_FIELD                 = Sql.ToString (src.DATA_FIELD                 );
	div.SORT_EXPRESSION            = Sql.ToString (src.SORT_EXPRESSION            );
	div.ITEMSTYLE_WIDTH            = Sql.ToString (src.ITEMSTYLE_WIDTH            );
	div.ITEMSTYLE_CSSCLASS         = Sql.ToString (src.ITEMSTYLE_CSSCLASS         );
	div.ITEMSTYLE_HORIZONTAL_ALIGN = Sql.ToString (src.ITEMSTYLE_HORIZONTAL_ALIGN );
	div.ITEMSTYLE_VERTICAL_ALIGN   = Sql.ToString (src.ITEMSTYLE_VERTICAL_ALIGN   );
	// 05/15/2016 Paul.  Special rule where null is true.  This is because this field was added after initial implementation. 
	if ( src.ITEMSTYLE_WRAP == null )
		src.ITEMSTYLE_WRAP = true;
	div.ITEMSTYLE_WRAP             = Sql.ToBoolean(src.ITEMSTYLE_WRAP             );
	div.URL_FIELD                  = Sql.ToString (src.URL_FIELD                  );
	div.URL_FORMAT                 = Sql.ToString (src.URL_FORMAT                 );
	div.URL_TARGET                 = Sql.ToString (src.URL_TARGET                 );
	div.URL_MODULE                 = Sql.ToString (src.URL_MODULE                 );
	div.URL_ASSIGNED_FIELD         = Sql.ToString (src.URL_ASSIGNED_FIELD         );
	div.MODULE_TYPE                = Sql.ToString (src.MODULE_TYPE                );
	div.LIST_NAME                  = Sql.ToString (src.LIST_NAME                  );
	div.PARENT_FIELD               = Sql.ToString (src.PARENT_FIELD               );
	this.RenderField(div);
}

LayoutListViewUI.prototype.LayoutAddField = function(jDropTarget, jDragged)
{
	//alert(jDropTarget    instanceof jQuery);
	//alert(jDragged instanceof jQuery);
	//alert(jDropTarget   .attr('data-id-group'))
	//alert(jDragged.attr('data-id-group'))
	if ( jDragged.attr('data-id-group') == 'FieldList' )
	{
		if ( jDropTarget.attr('data-id-group') == 'LayoutCell' && jDropTarget[0].childNodes.length > 0 )
		{
			var jExistingField = $(jDropTarget[0].childNodes[0]);
			if ( jExistingField.prop('DATA_FIELD') != '' )
			{
				var divField = document.getElementById('divFieldList_' + jExistingField.prop('DATA_FIELD'));
				if ( divField != null )
					divField.style.display = 'block';
			}
			jDragged[0].style.display = 'none';
			
			var lay = this.CreateLayoutObject(jDragged[0]);
			var div = jDropTarget[0];
			this.SetLayoutObject(div, lay);
		}
		else if ( jDropTarget.attr('data-id-group') == 'LayoutField' )
		{
			if ( jDropTarget.prop('DATA_FIELD') != '' )
			{
				var divField = document.getElementById('divFieldList_' + jDropTarget.prop('DATA_FIELD'));
				if ( divField != null )
					divField.style.display = 'block';
			}
			jDragged[0].style.display = 'none';
			
			var lay = this.CreateLayoutObject(jDragged[0]);
			var div = jDropTarget[0];
			this.SetLayoutObject(div, lay);
		}
	}
	else if ( jDragged.attr('data-id-group') == 'LayoutField' )
	{
		if ( jDropTarget.attr('data-id-group') == 'LayoutCell' && jDropTarget[0].childNodes.length > 0 )
		{
		}
		else if ( jDropTarget.attr('data-id-group') == 'LayoutField' )
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
}

LayoutListViewUI.prototype.LayoutRemoveField = function(jDragged)
{
	if ( jDragged.attr('data-id-group') == 'LayoutField' )
	{
		// 04/06/2016 Paul.  DATA_FIELD is a property, not an attribute. 
		if (jDragged.prop('DATA_FIELD') != '')
		{
			var divField = document.getElementById('divFieldList_' + jDragged.prop('DATA_FIELD'));
			if ( divField != null )
				divField.style.display = 'block';
		}
		jDragged.prop('DATA_FIELD', '');
		var div = jDragged[0];
		// 04/06/2016 Paul.  We need to reset all fields when removing. 
		var lay = new Object();
		lay.COLUMN_TYPE = 'BoundColumn';
		this.SetLayoutObject(div, lay);
	}
}

LayoutListViewUI.prototype.BindRow = function(tblLayout, tr)
{
	var context = this;
	tr.className             = 'grab';
	tr.style.backgroundColor = '#ddd';
	$(tr).attr('data-id-group', 'LayoutRow');
	$(tr).draggable(
	{ containment: '#tblLayoutFrame'
	//, hoverClass: 'ui-state-hover'
	, cursor: 'move'
	, helper: function()
		{
			var tblLayout = document.getElementById('tblLayout');
			var sHeight   = $(tr).height().toString() + 'px';
			var sWidth    = $(tr).width().toString()  + 'px';
			return $("<div style='border: 1px solid red; height: " + sHeight + "; width: " + sWidth + ";'></div>");
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
			console.log('Drop on row');
			$(this).removeClass('ui-state-hover');
			var sDataIdGroup = ui.draggable.attr('data-id-group');
			if ( sDataIdGroup == 'NewBoundColumn' )
			{
				var lay = new Object();
				lay.COLUMN_TYPE = 'BoundColumn';
				lay.DATA_FORMAT = '';
				lay.DATA_FIELD  = '';
				context.LayoutAddRow(this.rowIndex + 1, lay);
			}
			else if ( sDataIdGroup == 'NewTemplateColumn' )
			{
				var lay = new Object();
				lay.COLUMN_TYPE = 'TemplateColumn';
				lay.DATA_FORMAT = '';
				lay.DATA_FIELD  = '';
				context.LayoutAddRow(this.rowIndex + 1, lay);
			}
			else if ( sDataIdGroup == 'LayoutRow' && this != ui.draggable[0] )
			{
				// 03/02/2016 Paul.  Change before or after based on direction. 
				if ( ui.draggable[0].rowIndex > this.rowIndex )
					ui.draggable.insertBefore(this);
				else
					ui.draggable.insertAfter(this);
			}
			else if ( sDataIdGroup == 'FieldList' )
			{
				context.LayoutAddRow(this.rowIndex + 1, ui.draggable[0]);
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
			return (sDataIdGroup == 'NewBoundColumn') || (sDataIdGroup == 'NewTemplateColumn') || (sDataIdGroup == 'LayoutRow') || (sDataIdGroup == 'DeletedRow') || (sDataIdGroup == 'FieldList');
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

LayoutListViewUI.prototype.BindColumn = function(tblLayout, td, lay)
{
	var context = this;
	$(td).attr('data-id-group'   , 'LayoutCell');
	/*
	$(td).droppable(
	{ greedy: true
	, drop: function(event, ui)
		{
			console.log('Drop on column');
			$(this).removeClass('ui-state-hover');
			LayoutAddField($(this), ui.draggable);
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			return (sDataIdGroup == 'FieldList') || (sDataIdGroup == 'LayoutField');
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
	*/
	
	var div = document.createElement('div');
	td.appendChild(div);
	div.className             = 'grab';
	div.style.border          = '1px solid black';
	div.style.padding         = '2px';
	div.style.margin          = '2px';
	div.style.backgroundColor = '#eee';
	div.style.overflow        = 'hidden';
	div.style.width           = (2 * nFieldListWidth).toString() + 'px';
	$(div).attr('data-id-group'   , 'LayoutField');
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
			console.log('Drop on column');
			$(this).removeClass('ui-state-hover');
			context.LayoutAddField($(this), ui.draggable);
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			return (sDataIdGroup == 'FieldList') || (sDataIdGroup == 'LayoutField');
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
		var sCOLUMN_TYPE = lay.COLUMN_TYPE;
		var sDATA_FORMAT = lay.DATA_FORMAT;
		// 03/16/2016 Paul.  Hidden fields do not need to be handled separately. 
		var divField = document.getElementById('divFieldList_' + lay.DATA_FIELD);
		if ( divField != null )
			divField.style.display = 'none';
			
		div.COLUMN_TYPE                = lay.COLUMN_TYPE                ;
		div.DATA_FORMAT                = lay.DATA_FORMAT                ;
		div.HEADER_TEXT                = lay.HEADER_TEXT                ;
		div.DATA_FIELD                 = lay.DATA_FIELD                 ;
		div.SORT_EXPRESSION            = lay.SORT_EXPRESSION            ;
		div.ITEMSTYLE_WIDTH            = lay.ITEMSTYLE_WIDTH            ;
		div.ITEMSTYLE_CSSCLASS         = lay.ITEMSTYLE_CSSCLASS         ;
		div.ITEMSTYLE_HORIZONTAL_ALIGN = lay.ITEMSTYLE_HORIZONTAL_ALIGN ;
		div.ITEMSTYLE_VERTICAL_ALIGN   = lay.ITEMSTYLE_VERTICAL_ALIGN   ;
		div.ITEMSTYLE_WRAP             = lay.ITEMSTYLE_WRAP             ;
		div.URL_FIELD                  = lay.URL_FIELD                  ;
		div.URL_FORMAT                 = lay.URL_FORMAT                 ;
		div.URL_TARGET                 = lay.URL_TARGET                 ;
		div.URL_MODULE                 = lay.URL_MODULE                 ;
		div.URL_ASSIGNED_FIELD         = lay.URL_ASSIGNED_FIELD         ;
		div.MODULE_TYPE                = lay.MODULE_TYPE                ;
		div.LIST_NAME                  = lay.LIST_NAME                  ;
		div.PARENT_FIELD               = lay.PARENT_FIELD               ;
		this.RenderField(div);
	}
	else
	{
		// 03/21/2016 Paul.  $().attr() must be used consistently as it is different then direct field access. 
		//$(div).attr('COLUMN_TYPE', 'BoundColumn');
		//$(div).attr('DATA_FORMAT', ''           );
		//$(div).attr('DATA_FIELD' , ''           );
		div.COLUMN_TYPE = 'BoundColumn';
		div.DATA_FORMAT = ''           ;
		div.DATA_FIELD  = ''           ;
		var divDATA_FIELD  = document.createElement('div');
		var divHEADER_TEXT = document.createElement('div');
		div.appendChild(divDATA_FIELD);
		div.appendChild(divHEADER_TEXT);
		$(divDATA_FIELD).text(L10n.Term('DynamicLayout.LBL_BOUND_COLUMN_TYPE'));
		$(divHEADER_TEXT).text(String.fromCharCode(160));
	}
}

LayoutListViewUI.prototype.LayoutAddRow = function(nPosition, lay)
{
	var divFieldList = document.getElementById('divFieldList');
	var tblLayout = document.getElementById('tblLayout');
	var tr = tblLayout.insertRow(nPosition);
	this.BindRow(tblLayout, tr);

	var td = tr.insertCell(0);
	this.BindColumn(tblLayout, td, lay);
}

LayoutListViewUI.prototype.AddBusinessRulePopup = function(tblEvents, sFieldLabel, sFieldName, sFieldID, sFieldValue)
{
	var tr = tblEvents.insertRow(-1);
	var tdLabel = tr.insertCell(-1);
	var tdField = tr.insertCell(-1);
	tdLabel.style.padding = '2px';
	tdField.style.padding = '2px';
	tdLabel.style.width   = '25%';
	tdField.style.width   = '75%';
	$(tdLabel).text(L10n.Term('BusinessRules.' + sFieldLabel));
	var txt = document.createElement('input');
	txt.id    = 'tblEvents_' + sFieldName + '_NAME';
	txt.type  = 'text';
	txt.value = sFieldValue;
	txt.style.width = '200px';
	txt.style.marginRight = '3px';
	tdField.appendChild(txt);
	var hid = document.createElement('input');
	hid.id    = 'tblEvents_' + sFieldName + '_ID';
	hid.type  = 'hidden';
	hid.value = sFieldID;
	tdField.appendChild(hid);

	var btnEventSelect               = document.createElement('input');
	btnEventSelect.id                = 'btnEventSelect_' + sFieldName;
	btnEventSelect.type              = 'button';
	btnEventSelect.className         = 'button';
	btnEventSelect.value             = L10n.Term('.LBL_SELECT_BUTTON_LABEL');
	btnEventSelect.style.marginRight = '3px';
	tdField.appendChild(btnEventSelect);
	btnEventSelect.onclick = BindArguments(function(txt, hid, context)
	{
		sRULE_CHANGE_NAME = txt.id;
		sRULE_CHANGE_ID   = hid.id;
		return window.open('../../BusinessRules/Popup.aspx?Module=' + context.MODULE_NAME, 'BusinessRulesPopup', sPopupWindowOptions);
	}, txt, hid, this);

	var btnEventClear               = document.createElement('input');
	btnEventClear.id                = 'btnLayoutCancel_' + sFieldName;
	btnEventClear.type              = 'button';
	btnEventClear.className         = 'button';
	btnEventClear.value             = L10n.Term('.LBL_CLEAR_BUTTON_LABEL');
	btnEventClear.style.marginRight = '3px';
	tdField.appendChild(btnEventClear);
	btnEventClear.onclick = BindArguments(function(txt, hid, context)
	{
		txt.value = '';
		hid.value = '';
	}, txt, hid, this);
}

// 07/18/2018 Paul.  We need to check for the subpanel, so that the terms for Contacts are used for the Accounts.Contacts layout. 
LayoutListViewUI.prototype.GetModuleName = function()
{
	var sMODULE_TERMS = this.MODULE_NAME;
	var arrNAME = this.GRID_NAME.split('.');
	if ( arrNAME.length > 1 && MODULES[arrNAME[1]] !== undefined )
	{
		sMODULE_TERMS = arrNAME[1];
	}
	return sMODULE_TERMS;
}

LayoutListViewUI.prototype.LoadView = function()
{
	var context = this;
	var divFieldList = document.getElementById('divFieldList');
	// 07/18/2018 Paul.  We need to check for the subpanel, so that the terms for Contacts are used for the Accounts.Contacts layout. 
	var sMODULE_TERMS = this.GetModuleName() + '.LBL_';
	this.MODULE_TERMINOLOGY = new Array();

	// 04/19/2018 Paul.  MODIFIED_BY_ID is not the correct name, use MODIFIED_USER_ID instead. 
	for ( var sTerm in TERMINOLOGY )
	{
		if (  sTerm == ".LBL_LIST_ID"                 // || sTerm == ".LBL_ID"              
		   || sTerm == ".LBL_LIST_DELETED"            // || sTerm == ".LBL_DELETED"         
		   || sTerm == ".LBL_LIST_CREATED_BY"         // || sTerm == ".LBL_CREATED_BY"      
		   || sTerm == ".LBL_LIST_CREATED_BY_ID"      // || sTerm == ".LBL_CREATED_BY_ID"   
		   || sTerm == ".LBL_LIST_CREATED_BY_NAME"    // || sTerm == ".LBL_CREATED_BY_NAME" 
		   || sTerm == ".LBL_LIST_DATE_ENTERED"       // || sTerm == ".LBL_DATE_ENTERED"    
		   || sTerm == ".LBL_LIST_MODIFIED_USER_ID"   // || sTerm == ".LBL_MODIFIED_USER_ID"
		   || sTerm == ".LBL_LIST_DATE_MODIFIED"      // || sTerm == ".LBL_DATE_MODIFIED"   
		   || sTerm == ".LBL_LIST_DATE_MODIFIED_UTC"  // || sTerm == ".LBL_DATE_MODIFIED_UTC"
		   || sTerm == ".LBL_LIST_MODIFIED_BY"        // || sTerm == ".LBL_MODIFIED_BY"     
		   || sTerm == ".LBL_LIST_MODIFIED_USER_ID"   // || sTerm == ".LBL_MODIFIED_USER_ID"
		   || sTerm == ".LBL_LIST_MODIFIED_BY_NAME"   // || sTerm == ".LBL_MODIFIED_BY_NAME"
		   || sTerm == ".LBL_LIST_ASSIGNED_USER_ID"   // || sTerm == ".LBL_ASSIGNED_USER_ID"
		   || sTerm == ".LBL_LIST_ASSIGNED_TO"        // || sTerm == ".LBL_ASSIGNED_TO"     
		   || sTerm == ".LBL_LIST_ASSIGNED_TO_NAME"   // || sTerm == ".LBL_ASSIGNED_TO_NAME"
		   || sTerm == ".LBL_LIST_TEAM_ID"            // || sTerm == ".LBL_TEAM_ID"         
		   || sTerm == ".LBL_LIST_TEAM_NAME"          // || sTerm == ".LBL_TEAM_NAME"       
		   || sTerm == ".LBL_LIST_TEAM_SET_ID"        // || sTerm == ".LBL_TEAM_SET_ID"     
		   || sTerm == ".LBL_LIST_TEAM_SET_NAME"      // || sTerm == ".LBL_TEAM_SET_NAME"   
		   || sTerm == ".LBL_LIST_ID_C"               // || sTerm == ".LBL_ID_C"            
		   || sTerm == ".LBL_LIST_LAST_ACTIVITY_DATE" // || sTerm == ".LBL_LAST_ACTIVITY_DATE"
		// 05/13/2016 Paul.  LBL_TAG_SET_NAME should be global. 
		   || sTerm == ".LBL_LIST_TAG_SET_NAME"       // || sTerm == ".LBL_TAG_SET_NAME"    
		// 07/18/2018 Paul.  Add Archive terms. 
		   || sTerm == ".LBL_LIST_ARCHIVE_BY"         // || sTerm == ".LBL_ARCHIVE_BY"       
		   || sTerm == ".LBL_LIST_ARCHIVE_BY_NAME"    // || sTerm == ".LBL_ARCHIVE_BY_NAME"  
		   || sTerm == ".LBL_LIST_ARCHIVE_DATE_UTC"   // || sTerm == ".LBL_ARCHIVE_DATE_UTC" 
		   || sTerm == ".LBL_LIST_ARCHIVE_USER_ID"    // || sTerm == ".LBL_ARCHIVE_USER_ID"  
		   || sTerm == ".LBL_LIST_ARCHIVE_VIEW"       // || sTerm == ".LBL_ARCHIVE_VIEW"     
		// 07/18/2018 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		   || sTerm == ".LBL_LIST_ASSIGNED_SET_ID"    // || sTerm == ".LBL_ASSIGNED_SET_ID"  
		   || sTerm == ".LBL_LIST_ASSIGNED_SET_NAME"  // || sTerm == ".LBL_ASSIGNED_SET_NAME"
		   )
		{
			this.MODULE_TERMINOLOGY.push(sTerm);
		}
		else if ( StartsWith(sTerm, sMODULE_TERMS) )
		{
			this.MODULE_TERMINOLOGY.push(sTerm);
		}
	}
	
	var nbsp = String.fromCharCode(160);
	var imgDelete = document.createElement('img');
	imgDelete.id           = 'divFieldList_Delete';
	imgDelete.style.border = '1px solid white';
	imgDelete.style.width  = '48px';
	imgDelete.style.height = '48px';
	imgDelete.alt          = L10n.Term('.LBL_DELETE');
	// http://www.iconarchive.com/show/windows-8-icons-by-icons8/Industry-Trash-icon.html
	imgDelete.src          = '../../../App_Themes/Six/images/Industry-Trash-icon.png';
	$(imgDelete).attr('data-id-group', 'Delete');
	divFieldList.appendChild(imgDelete);
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
				for ( var i = 0; i < ui.draggable[0].cells.length; i++ )
				{
					var cell = ui.draggable[0].cells[i];
					for ( var j = 0; j < cell.childNodes.length; j++ )
					{
						// 02/07/2016 Paul.  Remove each field first so that it will get enabled in the field list. 
						var div = cell.childNodes[j];
						context.LayoutRemoveField($(div));
					}
				}
				var tblLayout = document.getElementById('tblLayout');
				tblLayout.deleteRow(ui.draggable[0].rowIndex);
				if ( tblLayout.rows.length == 0 )
				{
					lay.COLUMN_TYPE = 'BoundColumn';
					lay.DATA_FORMAT = '';
					lay.DATA_FIELD  = '';
					context.LayoutAddRow(-1, lay);
				}
				// 02/07/2016 Paul.  Mark the row as deleted so that it will not also be treated as a row drop due to overlap. 
				ui.draggable.attr('data-id-group', 'DeletedRow');
			}
			else ( sDataIdGroup == 'LayoutField' )
			{
				context.LayoutRemoveField(ui.draggable);
			}
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			return (sDataIdGroup == 'LayoutField' || sDataIdGroup == 'LayoutRow');
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
	divFieldList.appendChild(divField);

	// 02/20/2016 Paul.  It does not make sense to allow creation of bound column as data field is read-only. 
	//divField = document.createElement('div');
	//divField.id                    = 'divFieldList_NewBoundColumn';
	//divField.className             = 'grab';
	//divField.style.border          = '1px solid black';
	//divField.style.padding         = '2px' ;
	//divField.style.margin          = '2px' ;
	//divField.style.backgroundColor = '#eee';
	//divField.style.width           = nFieldListWidth.toString() + 'px';
	//$(divField).text(L10n.Term('DynamicLayout.LBL_NEW_BOUND_COLUMN'));
	//$(divField).attr('data-id-group', 'NewBoundColumn');
	//divFieldList.appendChild(divField);
	//$(divField).draggable(
	//{ containment: '#tblLayoutFrame'
	//, helper: 'clone'
	//, cursor: 'move'
	//, start: function( event, ui )
	//	{
	//		context.CancelProperties();
	//	}
	//});

	divField = document.createElement('div');
	divField.id                    = 'divFieldList_NewTemplateColumn';
	divField.className             = 'grab';
	divField.style.border          = '1px solid black';
	divField.style.padding         = '2px' ;
	divField.style.margin          = '2px' ;
	divField.style.backgroundColor = '#eee';
	divField.style.width           = nFieldListWidth.toString() + 'px';
	$(divField).text(L10n.Term('DynamicLayout.LBL_NEW_TEMPLATE_COLUMN'));
	$(divField).attr('data-id-group', 'NewTemplateColumn');
	divFieldList.appendChild(divField);
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
	divFieldList.appendChild(divField);

	this.FIELDS = new Array();
	for ( var i = 0; i < this.MODULE_FIELDS.length; i++ )
	{
		var lay = this.MODULE_FIELDS[i];
		if ( lay.ColumnName == 'EXCHANGE_FOLDER' )
			continue;
		var div = document.createElement('div');
		div.id                         = 'divFieldList_' + lay.DATA_FIELD;
		div.className                  = 'grab';
		div.style.border               = '1px solid black';
		div.style.padding              = '2px' ;
		div.style.margin               = '2px' ;
		div.style.backgroundColor      = '#eee';
		div.style.width                = nFieldListWidth.toString() + 'px';
		div.COLUMN_TYPE                = lay.COLUMN_TYPE                ;
		div.DATA_FORMAT                = lay.DATA_FORMAT                ;
		div.HEADER_TEXT                = lay.HEADER_TEXT                ;
		div.DATA_FIELD                 = lay.DATA_FIELD                 ;
		div.SORT_EXPRESSION            = lay.SORT_EXPRESSION            ;
		div.ITEMSTYLE_WIDTH            = '10%'; // lay.ITEMSTYLE_WIDTH            ;
		div.ITEMSTYLE_CSSCLASS         = null;  // lay.ITEMSTYLE_CSSCLASS         ;
		div.ITEMSTYLE_HORIZONTAL_ALIGN = null;  // lay.ITEMSTYLE_HORIZONTAL_ALIGN ;
		div.ITEMSTYLE_VERTICAL_ALIGN   = null;  // lay.ITEMSTYLE_VERTICAL_ALIGN   ;
		div.ITEMSTYLE_WRAP             = null;  // lay.ITEMSTYLE_WRAP             ;
		div.URL_FIELD                  = lay.URL_FIELD                  ;
		div.URL_FORMAT                 = lay.URL_FORMAT                 ;
		div.URL_TARGET                 = null;  // lay.URL_TARGET                 ;
		div.URL_MODULE                 = null;  // lay.URL_MODULE                 ;
		div.URL_ASSIGNED_FIELD         = lay.URL_ASSIGNED_FIELD         ;
		div.MODULE_TYPE                = null;  // lay.MODULE_TYPE                ;
		div.LIST_NAME                  = lay.LIST_NAME                  ;
		div.PARENT_FIELD               = null;  // lay.PARENT_FIELD               ;
		if ( lay.DATA_FORMAT == 'HyperLink' )
			div.ITEMSTYLE_CSSCLASS = 'listViewTdLinkS1';
		this.FIELDS.push(lay.DATA_FIELD);

		$(div).attr('data-id-group', 'FieldList');
		divFieldList.appendChild(div);
		$(div).draggable(
		{ containment: '#tblLayoutFrame'
		, helper: 'clone'
		, cursor: 'move'
		, drop: function(e)
			{
				//console.log('dropped on ' + e.target.id);
			}
		, start: function( event, ui )
			{
				context.CancelProperties();
			}
		});
		
		var divDATA_FIELD  = document.createElement('div');
		var divHEADER_TEXT = document.createElement('div');
		div.appendChild(divDATA_FIELD);
		div.appendChild(divHEADER_TEXT);
		$(divDATA_FIELD).text(lay.DATA_FIELD);
		if ( Sql.IsEmptyString(lay.HEADER_TEXT) )
		{
			if ( lay.ColumnName == 'ASSIGNED_USER_ID' )
				lay.HEADER_TEXT = '.LBL_LIST_' + lay.ColumnName;
			else
			{
				// 07/18/2018 Paul.  We need to check for the subpanel, so that the terms for Contacts are used for the Accounts.Contacts layout. 
				lay.HEADER_TEXT = sMODULE_TERMS + 'LIST_' + lay.ColumnName;
			}
			div.HEADER_TEXT = lay.HEADER_TEXT;
		}
		$(divHEADER_TEXT).text(L10n.Term(lay.HEADER_TEXT));
	}

	while ( divLayoutButtons.childNodes.length > 0 )
	{
		divLayoutButtons.removeChild(divLayoutButtons.firstChild);
	}
	
	var btnLayoutSave               = document.createElement('input');
	btnLayoutSave.id                = 'btnLayoutSave'  ;
	btnLayoutSave.type              = 'button';
	btnLayoutSave.className         = 'button';
	btnLayoutSave.value             = L10n.Term('.LBL_SAVE_BUTTON_LABEL');
	btnLayoutSave.style.cursor      = 'pointer';
	btnLayoutSave.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnLayoutSave  );
	btnLayoutSave.onclick = BindArguments(function(PageCommand, context)
	{
		PageCommand.call(context, 'Save', null);
	}, this.PageCommand, this);

	var btnLayoutCancel               = document.createElement('input');
	btnLayoutCancel.id                = 'btnLayoutCancel';
	btnLayoutCancel.type              = 'button';
	btnLayoutCancel.className         = 'button';
	btnLayoutCancel.value             = L10n.Term('.LBL_CANCEL_BUTTON_LABEL');
	btnLayoutCancel.style.cursor      = 'pointer';
	btnLayoutCancel.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnLayoutCancel);
	btnLayoutCancel.onclick = BindArguments(function(PageCommand, context)
	{
		PageCommand.call(context, 'Cancel', null);
	}, this.PageCommand, this);

	// 05/04/2016 Paul.  Provide a way to save a layout copy. 
	var btnCopyLayout               = document.createElement('input');
	btnCopyLayout.id                = 'btnCopyLayout';
	btnCopyLayout.type              = 'button';
	btnCopyLayout.className         = 'button';
	btnCopyLayout.value             = L10n.Term('DynamicLayout.LBL_COPY_BUTTON_TITLE');
	btnCopyLayout.style.cursor      = 'pointer';
	btnCopyLayout.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnCopyLayout);
	btnCopyLayout.onclick = BindArguments(function(PageCommand, context)
	{
		PageCommand.call(context, 'Copy', null);
	}, this.PageCommand, this);
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
	btnRoleSelect.className         = 'button';
	btnRoleSelect.value             = L10n.Term('DynamicLayout.LBL_SELECT_ROLE');
	btnRoleSelect.style.marginRight = '3px';
	btnRoleSelect.style.display     = 'none';
	divLayoutButtons.appendChild(btnRoleSelect);
	btnRoleSelect.onclick = BindArguments(function(context)
	{
		return window.open('../../ACLRoles/PopupMultiSelect.aspx?SingleSelection=1', 'ACLRolessPopup', sPopupWindowOptions);
	}, this);

	// 05/05/2016 Paul.  Provide a way to delete a layout. 
	var btnDeleteLayout               = document.createElement('input');
	btnDeleteLayout.id                = 'btnDeleteLayout';
	btnDeleteLayout.type              = 'button';
	btnDeleteLayout.className         = 'button';
	btnDeleteLayout.value             = L10n.Term('DynamicLayout.LBL_DELETE_BUTTON_TITLE');
	btnDeleteLayout.style.cursor      = 'pointer';
	btnDeleteLayout.style.marginRight = '3px';
	btnDeleteLayout.style.display     = (this.AllowDeleteLayout() ? 'inline' : 'none');
	divLayoutButtons.appendChild(btnDeleteLayout);
	btnDeleteLayout.onclick = BindArguments(function(PageCommand, context)
	{
		if ( confirm(L10n.Term('DynamicLayout.ERR_DELETE_CONFIRM')) )
		{
			PageCommand.call(context, 'Delete', null);
		}
	}, this.PageCommand, this);

	// 03/13/2016 Paul.  Restore Defaults. 
	var btnLayoutRestore               = document.createElement('input');
	btnLayoutRestore.id                = 'btnLayoutRestore';
	btnLayoutRestore.type              = 'button';
	btnLayoutRestore.className         = 'button';
	btnLayoutRestore.value             = L10n.Term('.LBL_DEFAULTS_BUTTON_LABEL');
	btnLayoutRestore.style.cursor      = 'pointer';
	btnLayoutRestore.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnLayoutRestore);
	btnLayoutRestore.onclick = BindArguments(function(PageCommand, context)
	{
		context.CancelProperties();
		context.Reload(true);
	}, this.PageCommand, this);

	var btnLayoutExport               = document.createElement('input');
	btnLayoutExport.id                = 'btnLayoutExport';
	btnLayoutExport.type              = 'button';
	btnLayoutExport.className         = 'button';
	btnLayoutExport.value             = L10n.Term('.LBL_EXPORT_BUTTON_LABEL');
	btnLayoutExport.style.cursor      = 'pointer';
	btnLayoutExport.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnLayoutExport);
	btnLayoutExport.onclick = BindArguments(function(PageCommand, context)
	{
		window.location.href = '../GridViews/export.aspx?NAME=' + context.GRID_NAME;
	}, this.PageCommand, this);

	var spnError = document.createElement('span');
	spnError.id        = 'divLayoutButtons_Error';
	spnError.className = 'error';
	divLayoutButtons.appendChild(spnError);

	this.LoadFromLayout();

	if ( this.EVENTS != null )
	{
		var spnEvents = document.createElement('span');
		spnEvents.style.float   = 'right';
		spnEvents.style.cursor  = 'pointer';
		divLayoutButtons.appendChild(spnEvents);
		$(spnEvents).text(L10n.Term('DynamicLayout.LBL_EVENTS'));
		var imgEventsExpand = document.createElement('img');
		imgEventsExpand.id                = 'imgEventsExpand';
		imgEventsExpand.style.cursor      = 'pointer';
		imgEventsExpand.style.marginLeft  = '3px';
		imgEventsExpand.style.marginRight = '3px';
		imgEventsExpand.src               = sREMOTE_SERVER + 'App_Themes/Six/images/advanced_search.gif';
		spnEvents.appendChild(imgEventsExpand);
		spnEvents.onclick = function()
		{
			var tblEvents       = document.getElementById('tblEvents');
			var imgEventsExpand = document.getElementById('imgEventsExpand');
			if ( tblEvents.style.display == 'none' )
			{
				tblEvents.style.display = 'block';
				imgEventsExpand.src = sREMOTE_SERVER + 'App_Themes/Six/images/basic_search.gif';
			}
			else
			{
				tblEvents.style.display = 'none';
				imgEventsExpand.src = sREMOTE_SERVER + 'App_Themes/Six/images/advanced_search.gif';
			}
		};

		var tblEvents = document.getElementById('tblEvents');
		tblEvents.style.display = 'none';
		// 07/13/2016 Paul.  Make sure values are not null.  
		this.AddBusinessRulePopup(tblEvents, 'LBL_TABLE_LOAD_EVENT_NAME', 'PRE_LOAD_EVENT'  , Sql.ToString(this.EVENTS.PRE_LOAD_EVENT_ID  ), Sql.ToString(this.EVENTS.PRE_LOAD_EVENT_NAME  ));
		this.AddBusinessRulePopup(tblEvents, 'LBL_ROW_LOAD_EVENT_NAME'  , 'POST_LOAD_EVENT' , Sql.ToString(this.EVENTS.POST_LOAD_EVENT_ID ), Sql.ToString(this.EVENTS.POST_LOAD_EVENT_NAME ));
		tr = tblEvents.insertRow(-1);
		tdLabel             = tr.insertCell(-1);
		tdField             = tr.insertCell(-1);
		tdLabel.style.padding = '2px';
		tdField.style.padding = '2px';
		tdLabel.style.width   = '15%';
		tdField.style.width   = '85%';
		tdLabel.style.verticalAlign = 'top';
		$(tdLabel).text(L10n.Term('BusinessRules.LBL_SCRIPT'));
		txt = document.createElement('textarea');
		txt.id           = 'tblEvents_SCRIPT';
		txt.type         = 'text';
		txt.style.width  = '350px';
		txt.rows         = 3;
		// 03/16/2016 Paul.  Make sure to convert null to empty string. 
		txt.value        = Sql.ToString(this.EVENTS.SCRIPT);
		tdField.appendChild(txt);
	}
}

LayoutListViewUI.prototype.Load = function()
{
	try
	{
		AdminLayoutClear();
		
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				// 05/09/2016 Paul.  Specify LayoutType. 
				// 10/19/2016 Paul.  Specify the LayoutName so that we can search the fields added in a _List view. 
				AdminLayout_GetModuleFields(this.MODULE_NAME, 'ListView', this.GRID_NAME, function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						this.MODULE_FIELDS = message;
						// 07/18/2018 Paul.  We need to check for the subpanel, so that the terms for Contacts are used for the Accounts.Contacts layout. 
						var sMODULE_TERMS = this.GetModuleName();
						bgPage.Terminology_LoadModule(sMODULE_TERMS, function(status, message)
						{
							if ( status == 0 || status == 1 )
							{
								AdminLayout_GetListViewColumns(this.GRID_NAME, false, function(status, message)
								{
									if ( status == 1 )
									{
										// 05/04/2016 Paul.  UpdateLayout is a common approach. 
										this.UpdateLayout(message);
										AdminLayout_GetListViewEvents(this.GRID_NAME, function(status, message)
										{
											if ( status == 1 )
											{
												if ( message instanceof Array && message.length > 0 )
													this.EVENTS = message[0];
												this.LoadView();
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
			else
			{
				SplendidError.SystemMessage(message);
			}
		}, this);
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'LayoutListViewUI.Load');
	}
}

LayoutListViewUI.prototype.Reload = function(bDEFAULT_VIEW)
{
	try
	{
		AdminLayout_GetListViewColumns(this.GRID_NAME, bDEFAULT_VIEW, function(status, message)
		{
			if ( status == 1 )
			{
				// 05/04/2016 Paul.  UpdateLayout is a common approach. 
				this.UpdateLayout(message);
				this.LoadFromLayout();
			}
			else
			{
				SplendidError.SystemMessage(message);
			}
		}, this);
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'LayoutListViewUI.Reload');
	}
}

