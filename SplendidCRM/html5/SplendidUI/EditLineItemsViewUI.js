/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function EditLineItemsViewUI()
{
	this.layout         = null;
	this.SORT_FIELD     = 'POSITION';
	this.SORT_DIRECTION = 'asc';
	this.MODULE_NAME    = '';
	this.GRID_NAME      = '';
	this.TABLE_NAME     = '';
	this.PRIMARY_MODULE = '';
	this.PRIMARY_ID     = '';
	this.HIDE_VIEW_EDIT = false;
	this.HIDE_DELETE    = false;
	this.SHOW_CONFLICTS = false;
	this.bEnableOptions      = Crm.Config.ToBoolean('ProductCatalog.EnableOptions');
	// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
	// Place init code in InitializeComponent as it occurs before LoadLineItems. 
	this.bEnableTaxLineItems = Crm.Config.ToBoolean('Orders.TaxLineItems'         );
	this.bEnableTaxShipping  = Crm.Config.ToBoolean('Orders.TaxShipping'          );
	this.bShowTax            = Crm.Config.ToBoolean('Orders.ShowTaxColumn'        );
	// 12/14/2013 Paul.  Move Show flags to config. 
	this.bShowCostPrice      = Crm.Config.ToBoolean('Orders.ShowCostPriceColumn'  );
	this.bShowListPrice      = Crm.Config.ToBoolean('Orders.ShowListPriceColumn'  );
	// 11/30/2015 Paul.  Allow Tax to be disabled and to hide MFT Part Number. 
	this.bShowMftPartNum     = Crm.Config.ToBoolean('Orders.ShowMftPartNumColumn' );
	this.bEnableSalesTax     = Crm.Config.ToBoolean('Orders.EnableSalesTax'       );
}

EditLineItemsViewUI.prototype.PageCommand = function(sLayoutPanel, sActionsPanel, sCommandName, sCommandArguments)
{
	try
	{
		if ( sCommandName == 'Create' )
		{
			var oEditViewUI = new EditViewUI();
			oEditViewUI.Load(sLayoutPanel, sActionsPanel, this.MODULE_NAME, null, false);
		}
		else
		{
			SplendidError.SystemMessage('EditLineItemsViewUI.PageCommand: Unknown command ' + sCommandName);
		}
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'EditLineItemsViewUI.PageCommand');
	}
}

EditLineItemsViewUI.prototype.Render = function(sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout, divEditLineItemsView, rows, rowPRIMARY, sPRIMARY_MODULE, sPRIMARY_ID)
{
	// 03/02/2016 Paul.  We need to save the layout for use in DeleteRow event. 
	this.layout         = layout           ;
	this.MODULE_NAME    = sLIST_MODULE_NAME;
	this.PRIMARY_MODULE = sPRIMARY_MODULE  ;
	this.PRIMARY_ID     = sPRIMARY_ID      ;
	this.RenderLineHeader(sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout, divEditLineItemsView, rows, rowPRIMARY, sPRIMARY_MODULE, sPRIMARY_ID);
	this.RenderLineItems (sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout, divEditLineItemsView, rows, rowPRIMARY, sPRIMARY_MODULE, sPRIMARY_ID);
	var spn = document.createElement('span');
	spn.id = sLayoutPanel + '_ctlEditLineItemsView_AjaxErrors';
	spn.style.color = 'red';
	divEditLineItemsView.appendChild(spn);
	this.RenderSummary   (sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout, divEditLineItemsView, rows, rowPRIMARY, sPRIMARY_MODULE, sPRIMARY_ID);
}

EditLineItemsViewUI.prototype.AddListBox = function(sLayoutPanel, td, sLIST_NAME, sDATA_FIELD, sDATA_VALUE, bAllowNone, bShow)
{
	var lst = document.createElement('select');
	td.appendChild(lst);
	try
	{
		var sLIST_NAME  = sLIST_NAME;
		var arrLIST = L10n.GetList(sLIST_NAME);
		if ( bAllowNone )
		{
			var opt = document.createElement('option');
			opt.setAttribute('value', '');
			opt.innerHTML = L10n.Term('.LBL_NONE');
			lst.appendChild(opt);
			if ( sDATA_VALUE != null && sDATA_VALUE == '' )
				opt.setAttribute('selected', 'selected');
		}
		if ( arrLIST != null )
		{
			for ( var i = 0; i < arrLIST.length; i++ )
			{
				var opt = document.createElement('option');
				lst.appendChild(opt);
				opt.setAttribute('value', arrLIST[i]);
				opt.innerHTML = L10n.ListTerm(sLIST_NAME, arrLIST[i]);
				if ( sDATA_VALUE != null && sDATA_VALUE == arrLIST[i] )
					opt.setAttribute('selected', 'selected');
			}
		}
		else
		{
			console.log(sLIST_NAME + ' is null');
		}
		if ( !bShow )
			lst.style.display = 'none';
	}
	catch(e)
	{
		console.log('EditLineItemsViewUI.AddListBox(' + sLIST_NAME + ', ' + sDATA_FIELD + ', ' + sDATA_VALUE + '):' + e.message);
	}
	return lst;
}

EditLineItemsViewUI.prototype.AddTextBox = function(sLayoutPanel, td, sDATA_FIELD, sDATA_VALUE, nTabIndex, bVisible)
{
	var txt = document.createElement('input');
	txt.type        = 'text';
	txt.value       = sDATA_VALUE;
	if ( nTabIndex !== undefined && nTabIndex != null )
		txt.tabIndex    = nTabIndex;
	if ( bVisible !== undefined && bVisible != null && !bVisible )
		txt.style.display = 'none';
	td.appendChild(txt);
	return txt;
}

EditLineItemsViewUI.prototype.AddSummaryTextBox = function(sLayoutPanel, tblMain, sPRIMARY_MODULE, sDATA_FIELD, sDATA_VALUE, bReadOnly, bVisible)
{
	var txt = null;
	try
	{
		var tr = tblMain.insertRow(-1);
		var td = tr.insertCell(-1);
		td.style.width = '65%';
		td = tr.insertCell(-1);
		td.style.width = '15%';
		td.className   = 'dataLabel';
		var spn = document.createElement('span');
		td.appendChild(spn);
		spn.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_' + sDATA_FIELD)));
		td = tr.insertCell(-1);
		td.style.width = '20%';
		td.className   = 'dataField';
		
		txt = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, sDATA_VALUE, null, bVisible);
		txt.id = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
		if ( bReadOnly )
		{
			txt.readonly = 'readonly';
			txt.style.backgroundColor = '#DDDDDD';
		}
		td.appendChild(txt);
	}
	catch(e)
	{
		console.log('EditLineItemsViewUI.AddSummaryTextBox: ' + e.message);
	}
	return txt;
}

EditLineItemsViewUI.prototype.AddHidden = function(sLayoutPanel, td, sDATA_FIELD, sDATA_VALUE)
{
	var hid = document.createElement('input');
	hid.id    = sLayoutPanel + '_ctlEditView_' + sDATA_FIELD;
	hid.type  = 'hidden';
	hid.value = sDATA_VALUE;
	td.appendChild(hid);
	return hid;
}

EditLineItemsViewUI.prototype.RenderLineHeader = function(sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout, divEditLineItemsView, rows, rowPRIMARY, sPRIMARY_MODULE, sPRIMARY_ID)
{
	try
	{
		if ( rowPRIMARY == null )
		{
			rowPRIMARY = new Object();
			rowPRIMARY['CURRENCY_ID'] = Crm.Config.ToString('default_currency');
		}
		var ctlEditLineItemsView_ctlLineHeaderPanel = document.createElement('div');
		ctlEditLineItemsView_ctlLineHeaderPanel.id = sLayoutPanel + '_ctlEditLineItemsView_ctlLineHeaderPanel';
		divEditLineItemsView.appendChild(ctlEditLineItemsView_ctlLineHeaderPanel);
	
		var nbsp    = String.fromCharCode(160);
		var tblForm = document.createElement('table');
		var tr      = tblForm.insertRow(-1);
		var td      = tr.insertCell(-1);
		tblForm.className   = 'tabForm';
		tblForm.cellSpacing = 1;
		tblForm.cellPadding = 0;
		tblForm.border      = 0;
		tblForm.width       = '100%';
		ctlEditLineItemsView_ctlLineHeaderPanel.appendChild(tblForm);
	
		var tblMain = document.createElement('table');
		tblMain.id        = sLayoutPanel + '_ctlEditLineItemsView_ctlLineHeaderPanel_tblMain';
		tblMain.cellSpacing = 1;
		tblMain.cellPadding = 0;
		tblMain.border      = 0;
		tblMain.width     = '100%';
		td.appendChild(tblMain);
		tr = tblMain.insertRow(-1);
	
		// CURRENCY
		var td = tr.insertCell(-1);
		var spn = document.createElement('span');
		td.appendChild(spn);
		spn.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_CURRENCY')));
		td.appendChild(document.createTextNode(nbsp));
		var lst = this.AddListBox(sLayoutPanel, td, 'Currencies', 'CURRENCY_ID', Sql.ToString(rowPRIMARY['CURRENCY_ID']), false, true);
		lst.id = sLayoutPanel + '_ctlEditView_' + 'CURRENCY_ID';
		td.appendChild(document.createTextNode(nbsp));
		spn = document.createElement('span');
		td.appendChild(spn);
		spn.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_CONVERSION_RATE')));
		td.appendChild(document.createTextNode(nbsp));
		var txt = this.AddTextBox(sLayoutPanel, td, 'EXCHANGE_RATE', Sql.ToDecimal(rowPRIMARY['EXCHANGE_RATE']), null, true);
		txt.id = sLayoutPanel + '_ctlEditView_' + 'EXCHANGE_RATE';
		txt.maxLength   = 10;
		txt.style.width = '50px';
	
		// TAXRATE
		td = tr.insertCell(-1);
		spn = document.createElement('span');
		if ( !this.bEnableSalesTax )
			spn.style.display = 'none';
		td.appendChild(spn);
		spn.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_TAXRATE')));
		td.appendChild(document.createTextNode(nbsp));
		lst = this.AddListBox(sLayoutPanel, td, 'TaxRates', 'TAXRATE_ID', Sql.ToString(rowPRIMARY['TAXRATE_ID']), true, this.bEnableSalesTax);
		lst.id = sLayoutPanel + '_ctlEditView_' + 'TAXRATE_ID';
	
		// SHIPPER
		td = tr.insertCell(-1);
		spn = document.createElement('span');
		td.appendChild(spn);
		spn.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_SHIPPER')));
		td.appendChild(document.createTextNode(nbsp));
		lst = this.AddListBox(sLayoutPanel, td, 'Shippers', 'SHIPPER_ID', Sql.ToString(rowPRIMARY['SHIPPER_ID']), true, true);
		lst.id = sLayoutPanel + '_ctlEditView_' + 'SHIPPER_ID';
		
		// SHOW_LINE_NUMS, not used anymore. 
		td = tr.insertCell(-1);
		td.appendChild(document.createTextNode(nbsp));
	
		// CALC_GRAND_TOTAL, not used anymore. 
		td = tr.insertCell(-1);
		td.appendChild(document.createTextNode(nbsp));
	
		td = tr.insertCell(-1);
		td.appendChild(document.createTextNode(nbsp));
	}
	catch(e)
	{
		console.log('EditLineItemsViewUI.RenderLineHeader: ' + e.message);
	}
}

EditLineItemsViewUI.prototype.RenderSummary = function(sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout, divEditLineItemsView, rows, rowPRIMARY, sPRIMARY_MODULE, sPRIMARY_ID)
{
	try
	{
		if ( rowPRIMARY == null )
		{
			rowPRIMARY = new Object();
		}
		var ctlEditLineItemsView_ctlSummaryPanel = document.createElement('div');
		ctlEditLineItemsView_ctlSummaryPanel.id = sLayoutPanel + '_ctlEditLineItemsView_ctlSummaryPanel';
		ctlEditLineItemsView_ctlSummaryPanel.style.marginTop = '4px';
		divEditLineItemsView.appendChild(ctlEditLineItemsView_ctlSummaryPanel);
	
		var nbsp    = String.fromCharCode(160);
		var tblForm = document.createElement('table');
		var tr      = tblForm.insertRow(-1);
		var td      = tr.insertCell(-1);
		tblForm.className   = 'tabForm';
		tblForm.cellSpacing = 1;
		tblForm.cellPadding = 0;
		tblForm.border      = 0;
		tblForm.width       = '100%';
		ctlEditLineItemsView_ctlSummaryPanel.appendChild(tblForm);
		
		var tblMain = document.createElement('table');
		tblMain.id        = sLayoutPanel + '_ctlEditLineItemsView_ctlSummaryPanel_tblMain';
		tblMain.cellSpacing = 1;
		tblMain.cellPadding = 0;
		tblMain.border      = 0;
		tblMain.width     = '100%';
		td.appendChild(tblMain);
		
		var oNumberFormat = Security.NumberFormatInfo();
		this.AddSummaryTextBox(sLayoutPanel, tblMain, sPRIMARY_MODULE, 'SUBTOTAL', formatCurrency(rowPRIMARY['SUBTOTAL'], oNumberFormat), true , true);
		this.AddSummaryTextBox(sLayoutPanel, tblMain, sPRIMARY_MODULE, 'DISCOUNT', formatCurrency(rowPRIMARY['DISCOUNT'], oNumberFormat), true , true);
		this.AddSummaryTextBox(sLayoutPanel, tblMain, sPRIMARY_MODULE, 'SHIPPING', formatNumber  (rowPRIMARY['SHIPPING'], oNumberFormat), false, true);
		this.AddSummaryTextBox(sLayoutPanel, tblMain, sPRIMARY_MODULE, 'TAX'     , formatCurrency(rowPRIMARY['TAX'     ], oNumberFormat), true , this.bEnableSalesTax);
		this.AddSummaryTextBox(sLayoutPanel, tblMain, sPRIMARY_MODULE, 'TOTAL'   , formatCurrency(rowPRIMARY['TOTAL'   ], oNumberFormat), true , true);
	}
	catch(e)
	{
		console.log('EditLineItemsViewUI.RenderSummary: ' + e.message);
	}
}

EditLineItemsViewUI.prototype.RenderLineItems = function(sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout, divEditLineItemsView, rows, rowPRIMARY, sPRIMARY_MODULE, sPRIMARY_ID)
{
	try
	{
		var ctlEditLineItemsView_ctlLineItemsPanel = document.createElement('div');
		ctlEditLineItemsView_ctlLineItemsPanel.id = sLayoutPanel + '_ctlEditLineItemsView_ctlLineItemsPanel';
		divEditLineItemsView.appendChild(ctlEditLineItemsView_ctlLineItemsPanel);

		var tblMain = document.createElement('table');
		ctlEditLineItemsView_ctlLineItemsPanel.appendChild(tblMain);
		tblMain.id          = sLayoutPanel + '_ctlEditLineItemsView_grdMain';
		tblMain.cellSpacing = 0;
		tblMain.cellPadding = 2;
		tblMain.border      = 1;
		tblMain.style.width = '100%';
		tblMain.style.borderCollapse = 'collapse';

		this.RenderHeader(sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout, tblMain, rows, sPRIMARY_MODULE, sPRIMARY_ID);
		if ( rows != null )
		{
			for ( var i = 0; i < rows.length; i++ )
			{
				var tr = tblMain.insertRow(-1);
				tr.valign = 'top';
				if ( i % 2 == 0 )
					tr.className = 'oddListRowS1';
				else
					tr.className = 'evenListRowS1';
				var row = rows[i];
				this.RenderRow(sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout, tr, row, sPRIMARY_MODULE, sPRIMARY_ID, false);
			}
		}
		// 03/02/2016 Paul.  For both new and existing records, add an empty new row. 
		this.AddFinalEditRow(sLayoutPanel, sActionsPanel);
	}
	catch(e)
	{
		console.log('EditLineItemsViewUI.RenderLineItems: ' + e.message);
	}
}

EditLineItemsViewUI.prototype.RenderHeader = function(sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout, tblMain, rows, sPRIMARY_MODULE, sPRIMARY_ID)
{
	try
	{
		var nbsp = String.fromCharCode(160);
		var tr = tblMain.insertRow(-1);
		tr.className = 'listViewThS1';
		var th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(nbsp));
		
		// QUANTITY
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_LIST_ITEM_QUANTITY')));
		
		// NAME
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_LIST_ITEM_NAME')));
		
		// MFT_PART_NUM
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_LIST_ITEM_MFT_PART_NUM')));
		th.style.display = !this.bShowMftPartNum ? 'none' : '';
		
		// TAX_CLASS
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_LIST_ITEM_TAX_CLASS')));
		th.style.display = !(this.bEnableSalesTax && !this.bEnableTaxLineItems) ? 'none' : '';
		
		// TAXRATE_ID
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_LIST_ITEM_TAX_RATE')));
		th.style.display = !(this.bEnableSalesTax && this.bEnableTaxLineItems) ? 'none' : '';
		
		// COST_PRICE
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_LIST_ITEM_COST_PRICE')));
		th.style.display = !this.bShowCostPrice ? 'none' : '';
		
		// LIST_PRICE
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_LIST_ITEM_LIST_PRICE')));
		th.style.display = !this.bShowListPrice ? 'none' : '';
		
		// UNIT_PRICE
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_LIST_ITEM_UNIT_PRICE')));
		
		// EXTENDED_PRICE
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_LIST_ITEM_EXTENDED_PRICE')));
		
		// TAX
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_LIST_ITEM_TAX')));
		if ( !(this.bEnableSalesTax && this.bShowTax) )
			th.style.display = 'none';
		
		// DISCOUNT controls. 
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		
		// DISCOUNT_NAME
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term(sPRIMARY_MODULE + '.LBL_LIST_ITEM_DISCOUNT_NAME')));
		
		// DATE_CLOSED
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term('Opportunities.LBL_LIST_ITEM_DATE_CLOSED')));
		th.style.display = (this.PRIMARY_MODULE == 'Opportunities' ? '' : 'none');
		
		// OPPORTUNITY_TYPE
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term('Opportunities.LBL_LIST_ITEM_OPPORTUNITY_TYPE')));
		th.style.display = (this.PRIMARY_MODULE == 'Opportunities' ? '' : 'none');
		
		// LEAD_SOURCE
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term('Opportunities.LBL_LIST_ITEM_LEAD_SOURCE')));
		th.style.display = (this.PRIMARY_MODULE == 'Opportunities' ? '' : 'none');
		
		// NEXT_STEP
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term('Opportunities.LBL_LIST_ITEM_NEXT_STEP')));
		th.style.display = (this.PRIMARY_MODULE == 'Opportunities' ? '' : 'none');
		
		// SALES_STAGE
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term('Opportunities.LBL_LIST_ITEM_SALES_STAGE')));
		th.style.display = (this.PRIMARY_MODULE == 'Opportunities' ? '' : 'none');
		
		// PROBABILITY
		th = document.createElement('th');
		tr.appendChild(th);
		th.style.whiteSpace = 'nowrap';
		th.appendChild(document.createTextNode(L10n.Term('Opportunities.LBL_LIST_ITEM_PROBABILITY')));
		th.style.display = (this.PRIMARY_MODULE == 'Opportunities' ? '' : 'none');
		
		// controls. 
		var th = document.createElement('th');
		tr.appendChild(th);
	}
	catch(e)
	{
		console.log('EditLineItemsViewUI.RenderHeader: ' + e.message);
		SplendidError.SystemError(e, 'EditLineItemsViewUI.RenderHeader');
	}
};

EditLineItemsViewUI.prototype.FieldVisibility = function(sLINE_ITEM_TYPE, sFIELD_NAME)
{
	var bVisible = true;
	switch ( sFIELD_NAME )
	{
		case 'QUANTITY'        :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'NAME'            :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'SELECT_NAME'     :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'DESCRIPTION'     :  break;
		case 'MFT_PART_NUM'    :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'TAX_CLASS'       :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'TAXRATE_ID'      :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'TAX'             :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'COST_PRICE'      :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'LIST_PRICE'      :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'UNIT_PRICE'      :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'EXTENDED_PRICE'  :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'DISCOUNT_ID'     :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'DISCOUNT_NAME'   :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'DISCOUNT_PRICE'  :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'PRICING_FORMULA' :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'PRICING_FACTOR'  :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'DATE_CLOSED'     :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'OPPORTUNITY_TYPE':  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'LEAD_SOURCE'     :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'NEXT_STEP'       :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'SALES_STAGE'     :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'PROBABILITY'     :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
		case 'btnComment'      :  bVisible = (sLINE_ITEM_TYPE != 'Comment');  break;
	}
	return bVisible;
}

EditLineItemsViewUI.prototype.RenderRow = function(sLayoutPanel, sActionsPanel, sLIST_MODULE_NAME, layout, tr, row, sPRIMARY_MODULE, sPRIMARY_ID, bEditMode)
{
	try
	{
		tr.ID                    = (row != null ? Sql.ToString  (row['ID'                   ]) : '');
		tr.LINE_GROUP_ID         = (row != null ? Sql.ToString  (row['LINE_GROUP_ID'        ]) : '');
		tr.LINE_ITEM_TYPE        = (row != null ? Sql.ToString  (row['LINE_ITEM_TYPE'       ]) : '');
		tr.PRODUCT_TEMPLATE_ID   = (row != null ? Sql.ToString  (row['PRODUCT_TEMPLATE_ID'  ]) : '');
		tr.PARENT_TEMPLATE_ID    = (row != null ? Sql.ToString  (row['PARENT_TEMPLATE_ID'   ]) : '');
		tr.PREVIOUS_NAME         = (row != null ? Sql.ToString  (row['PREVIOUS_NAME'        ]) : '');
		tr.VENDOR_PART_NUM       = (row != null ? Sql.ToString  (row['VENDOR_PART_NUM'      ]) : '');
		tr.PREVIOUS_MFT_PART_NUM = (row != null ? Sql.ToString  (row['PREVIOUS_MFT_PART_NUM']) : '');
		tr.QUANTITY              = (row != null ? Sql.ToString  (row['QUANTITY'             ]) : '');
		tr.NAME                  = (row != null ? Sql.ToString  (row['NAME'                 ]) : '');
		tr.DESCRIPTION           = (row != null ? Sql.ToString  (row['DESCRIPTION'          ]) : '');
		tr.MFT_PART_NUM          = (row != null ? Sql.ToString  (row['MFT_PART_NUM'         ]) : '');
		tr.TAX_CLASS             = (row != null ? Sql.ToString  (row['TAX_CLASS'            ]) : '');
		tr.TAXRATE_ID            = (row != null ? Sql.ToString  (row['TAXRATE_ID'           ]) : '');
		tr.COST_PRICE            = (row != null ? Sql.ToString  (row['COST_PRICE'           ]) : '');
		tr.LIST_PRICE            = (row != null ? Sql.ToString  (row['LIST_PRICE'           ]) : '');
		tr.UNIT_PRICE            = (row != null ? Sql.ToString  (row['UNIT_PRICE'           ]) : '');
		tr.EXTENDED_PRICE        = (row != null ? Sql.ToString  (row['EXTENDED_PRICE'       ]) : '');
		tr.TAX                   = (row != null ? Sql.ToString  (row['TAX'                  ]) : '');
		tr.DISCOUNT_ID           = (row != null ? Sql.ToString  (row['DISCOUNT_ID'          ]) : '');
		tr.PRICING_FORMULA       = (row != null ? Sql.ToString  (row['PRICING_FORMULA'      ]) : '');
		tr.PRICING_FACTOR        = (row != null ? Sql.ToString  (row['PRICING_FACTOR'       ]) : '');
		tr.DISCOUNT_PRICE        = (row != null ? Sql.ToString  (row['DISCOUNT_PRICE'       ]) : '');
		// 03/06/2016 Paul.  Don't convert to date yet.  Keep as Json string. 
		tr.DATE_CLOSED           = (row != null ? Sql.ToString  (row['DATE_CLOSED'          ]) : '');
		tr.OPPORTUNITY_TYPE      = (row != null ? Sql.ToString  (row['OPPORTUNITY_TYPE'     ]) : '');
		tr.LEAD_SOURCE           = (row != null ? Sql.ToString  (row['LEAD_SOURCE'          ]) : '');
		tr.NEXT_STEP             = (row != null ? Sql.ToString  (row['NEXT_STEP'            ]) : '');
		tr.SALES_STAGE           = (row != null ? Sql.ToString  (row['SALES_STAGE'          ]) : '');
		tr.PROBABILITY           = (row != null ? Sql.ToDecimal (row['PROBABILITY'          ]) : '');
		
		var td = tr.insertCell(-1);
		td.style.width = '1%';
		var spn = document.createElement('span');
		td.appendChild(spn);
		spn.appendChild(document.createTextNode(Sql.ToString(tr.LINE_ITEM_TYPE)));
		
		// QUANTITY
		td = tr.insertCell(-1);
		td.style.width = '10%';
		
		// NAME
		td = tr.insertCell(-1);
		td.style.width = '20%';
		
		// MFT_PART_NUM
		td = tr.insertCell(-1);
		td.style.width = '20%';
		td.style.display = !this.bShowMftPartNum ? 'none' : '';
		
		// TAX_CLASS
		td = tr.insertCell(-1);
		td.style.width   = '10%';
		td.style.display = !(this.bEnableSalesTax && !this.bEnableTaxLineItems) ? 'none' : '';
		
		// TAXRATE_ID
		td = tr.insertCell(-1);
		td.style.width = '10%';
		td.style.display = !(this.bEnableSalesTax && this.bEnableTaxLineItems) ? 'none' : '';
		
		// COST_PRICE
		td = tr.insertCell(-1);
		td.style.width   = '10%';
		td.align         = 'right';
		td.style.display = !this.bShowCostPrice ? 'none' : '';
		
		// LIST_PRICE
		td = tr.insertCell(-1);
		td.style.width   = '10%';
		td.align         = 'right';
		td.style.display = !this.bShowListPrice ? 'none' : '';
		
		// UNIT_PRICE
		td = tr.insertCell(-1);
		td.style.width = '10%';
		td.align       = 'right';
		
		// EXTENDED_PRICE
		td = tr.insertCell(-1);
		td.style.width = '10%';
		td.align       = 'right';
		
		// TAX
		td = tr.insertCell(-1);
		td.style.width   = '5%';
		td.align         = 'right';
		td.style.display = !(this.bEnableSalesTax && this.bShowTax) ? 'none' : '';
		
		// DISCOUNT controls. 
		td = tr.insertCell(-1);
		td.style.width = '10%';
		
		// DISCOUNT_PRICE
		td = tr.insertCell(-1);
		td.style.width = '10%';
		td.align       = 'right';
		
		// DATE_CLOSED
		td = tr.insertCell(-1);
		td.style.width = '15%';
		td.style.display = (this.PRIMARY_MODULE == 'Opportunities' ? '' : 'none');
		
		// OPPORTUNITY_TYPE
		td = tr.insertCell(-1);
		td.style.width = '15%';
		td.style.display = (this.PRIMARY_MODULE == 'Opportunities' ? '' : 'none');
		
		// LEAD_SOURCE
		td = tr.insertCell(-1);
		td.style.width = '15%';
		td.style.display = (this.PRIMARY_MODULE == 'Opportunities' ? '' : 'none');
		
		// NEXT_STEP
		td = tr.insertCell(-1);
		td.style.width = '15%';
		td.style.display = (this.PRIMARY_MODULE == 'Opportunities' ? '' : 'none');
		
		// SALES_STAGE
		td = tr.insertCell(-1);
		td.style.width = '15%';
		td.style.display = (this.PRIMARY_MODULE == 'Opportunities' ? '' : 'none');
		
		// PROBABILITY
		td = tr.insertCell(-1);
		td.style.width = '15%';
		td.style.display = (this.PRIMARY_MODULE == 'Opportunities' ? '' : 'none');
		
		// controls. 
		td = tr.insertCell(-1);
		td.style.width = '10%';
		td.style.whiteSpace = 'nowrap';
		
		if ( bEditMode )
			this.EditRow(sLayoutPanel, sActionsPanel, tr);
		else
			this.DisplayRow(sLayoutPanel, sActionsPanel, tr);
	}
	catch(e)
	{
		console.log('EditLineItemsViewUI.RenderRow: ' + e.message);
		SplendidError.SystemError(e, 'EditLineItemsViewUI.RenderRow');
	}
}

EditLineItemsViewUI.prototype.IsLineItemNotEmpty = function(row)
{
	// 08/16/2010 Paul.  Must allow exception for a Comment row. 
	// 11/18/2010 Paul.  Include Discount and Subtotal in list of non-empty line items. 
	// 11/18/2010 Paul.  We do not need to check the DISCOUNT_ID as a discount cannot stand-alone. 
	if ( !Sql.IsEmptyString(row["NAME"]) || !Sql.IsEmptyGuid(row["PRODUCT_TEMPLATE_ID"]) || Sql.ToString(row["LINE_ITEM_TYPE"]) == "Comment" || Sql.ToString(row["LINE_ITEM_TYPE"]) == "Subtotal" )
		return true;
	return false;
}

EditLineItemsViewUI.prototype.UpdateTotals = function(sLayoutPanel)
{
	var dSUBTOTAL = 0.0;
	// 08/13/2010 Paul.  Discount is now computed per line item. 
	var dDISCOUNT = 0.0;
	var dSHIPPING = Sql.ToDecimal($('#' + sLayoutPanel + '_ctlEditView_' + 'SHIPPING').val());
	var dTAX      = 0.0;
	var dTOTAL    = 0.0;
	var dTAX_RATE = 0.0;
	
	if ( this.bEnableSalesTax )
	{
		var lstTAXRATE_ID = document.getElementById(sLayoutPanel + '_ctlEditView_' + 'TAXRATE_ID');
		var gTAXRATE_ID = lstTAXRATE_ID.options[lstTAXRATE_ID.options.selectedIndex].value;
		if ( !Sql.IsEmptyGuid(gTAXRATE_ID) )
		{
			var rowTaxRate = SplendidCache.TaxRates(gTAXRATE_ID);
			if ( rowTaxRate != null )
			{
				dTAX_RATE = Sql.ToDouble(rowTaxRate["VALUE"]) / 100;
			}
		}
	}
	var tblMain = document.getElementById(sLayoutPanel + '_ctlEditLineItemsView_grdMain');
	for ( var i = 0; i < tblMain.rows.length; i++ )
	{
		var row = tblMain.rows[i];
		// 08/11/2007 Paul.  Allow an item to be manually added.  Require either a product ID or a name. 
		// 11/18/2010 Paul.  We do not need to check the DISCOUNT_ID as a discount cannot stand-alone. 
		if ( !Sql.IsEmptyString(row["NAME"]) || !Sql.IsEmptyGuid(row["PRODUCT_TEMPLATE_ID"]) )
		{
			var sLINE_ITEM_TYPE = Sql.ToString (row["LINE_ITEM_TYPE"]);
			// 02/10/2011 Paul.  Stop converting the Quantity to an integer. 
			var nQUANTITY       = Sql.ToDecimal(row["QUANTITY"      ]);
			var dUNIT_PRICE     = Sql.ToDecimal(row["UNIT_PRICE"    ]);
			var dDISCOUNT_PRICE = Sql.ToDecimal(row["DISCOUNT_PRICE"]);
			if ( sLINE_ITEM_TYPE != "Comment" )
			{
				dSUBTOTAL += dUNIT_PRICE * nQUANTITY;
				// 08/13/2010 Paul.  Discount is now computed per line item. 
				// 08/15/2010 Paul.  Discount already includes quantity. 
				dDISCOUNT += dDISCOUNT_PRICE;
				// 11/30/2015 Paul.  Allow Tax to be disabled and to hide MFT Part Number. 
				if ( this.bEnableSalesTax )
				{
					// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
					if ( this.bEnableTaxLineItems )
					{
						var gTAXRATE_ID = Sql.ToGuid(row["TAXRATE_ID"]);
						if ( !Sql.IsEmptyGuid(gTAXRATE_ID) )
						{
							var rowTaxRate = SplendidCache.TaxRates(gTAXRATE_ID);
							if ( rowTaxRate != null )
							{
								dTAX += (dUNIT_PRICE * nQUANTITY - dDISCOUNT_PRICE) * Sql.ToDouble(rowTaxRate["VALUE"]) / 100;
							}
						}
					}
					else
					{
						var sTAX_CLASS = Sql.ToString(row["TAX_CLASS"]);
						if ( sTAX_CLASS == "Taxable" )
							dTAX += (dUNIT_PRICE * nQUANTITY - dDISCOUNT_PRICE) * dTAX_RATE;
					}
				}
			}
		}
	}
	// 08/02/2010 Paul.  Some states require that the shipping be taxes. We will use one flag for Quotes, Orders and Invoices. 
	if ( this.bEnableTaxShipping )
	{
		dTAX += dSHIPPING * dTAX_RATE;
	}
	dTOTAL = dSUBTOTAL - dDISCOUNT + dTAX + dSHIPPING;

	var oNumberFormat = Security.NumberFormatInfo();
	$('#' + sLayoutPanel + '_ctlEditView_' + 'SUBTOTAL').val(formatCurrency(dSUBTOTAL, oNumberFormat));
	$('#' + sLayoutPanel + '_ctlEditView_' + 'DISCOUNT').val(formatNumber  (dDISCOUNT, oNumberFormat));
	$('#' + sLayoutPanel + '_ctlEditView_' + 'SHIPPING').val(formatNumber  (dSHIPPING, oNumberFormat));
	$('#' + sLayoutPanel + '_ctlEditView_' + 'TAX'     ).val(formatCurrency(dTAX     , oNumberFormat));
	$('#' + sLayoutPanel + '_ctlEditView_' + 'TOTAL'   ).val(formatCurrency(dTOTAL   , oNumberFormat));
}

EditLineItemsViewUI.prototype.UpdateRow = function(sLayoutPanel, sActionsPanel, tr)
{
	for ( var i = 0; i < tr.cells.length; i++ )
	{
		var td = tr.cells[i];
		switch ( i )
		{
			case 1:  // QUANTITY
			{
				var sDATA_FIELD = 'QUANTITY';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
						tr[sDATA_FIELD] = Sql.ToDecimal(td.childNodes[j].value);
				}
				break;
			}
			case 2:  // NAME
			{
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					switch ( td.childNodes[j].name )
					{
						case 'NAME'               :  tr['NAME'               ] = Sql.ToString(td.childNodes[j].value);  break;
						case 'PRODUCT_TEMPLATE_ID':  tr['PRODUCT_TEMPLATE_ID'] = Sql.ToString(td.childNodes[j].value);  break;
						case 'DESCRIPTION'        :  tr['DESCRIPTION'        ] = Sql.ToString(td.childNodes[j].value);  break;
					}
				}
				break;
			}
			case 3:  // MFT_PART_NUM
			{
				var sDATA_FIELD = 'MFT_PART_NUM';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
						tr[sDATA_FIELD] = Sql.ToString(td.childNodes[j].value);
				}
				break;
			}
			case 4:  // TAX_CLASS
			{
				var sDATA_FIELD = 'TAX_CLASS';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
					{
						var sel = td.childNodes[j];
						tr[sDATA_FIELD] = Sql.ToString(sel.options[sel.options.selectedIndex].value);
					}
				}
				break;
			}
			case 5:  // TAXRATE_ID
			{
				var sDATA_FIELD = 'TAXRATE_ID';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
					{
						var sel = td.childNodes[j];
						tr[sDATA_FIELD] = Sql.ToString(sel.options[sel.options.selectedIndex].value);
					}
				}
				break;
			}
			case 6:  // COST_PRICE
			{
				var sDATA_FIELD = 'COST_PRICE';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
						tr[sDATA_FIELD] = Sql.ToDecimal(td.childNodes[j].value);
				}
				break;
			}
			case 7:  // LIST_PRICE
			{
				var sDATA_FIELD = 'LIST_PRICE';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
						tr[sDATA_FIELD] = Sql.ToDecimal(td.childNodes[j].value);
				}
				break;
			}
			case 8:  // UNIT_PRICE
			{
				var sDATA_FIELD = 'UNIT_PRICE';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
						tr[sDATA_FIELD] = Sql.ToDecimal(td.childNodes[j].value);
				}
				break;
			}
			case 9:  // EXTENDED_PRICE
			{
				var sDATA_FIELD = 'EXTENDED_PRICE';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
						tr[sDATA_FIELD] = Sql.ToDecimal(td.childNodes[j].value);
				}
				break;
			}
			case 10:  // TAX
			{
				var sDATA_FIELD = 'TAX';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
						tr[sDATA_FIELD] = Sql.ToDecimal(td.childNodes[j].value);
				}
				break;
			}
			case 11:  // DISCOUNT controls. 
			{
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					switch ( td.childNodes[j].name )
					{
						case 'DISCOUNT_ID'    :  tr['DISCOUNT_ID'    ] = Sql.ToString (td.childNodes[j].value);  break;
						case 'PRICING_FORMULA':  tr['PRICING_FORMULA'] = Sql.ToString (td.childNodes[j].value);  break;
						case 'PRICING_FACTOR' :  tr['PRICING_FACTOR' ] = Sql.ToDecimal(td.childNodes[j].value);  break;
					}
				}
				if ( Sql.IsEmptyString(tr['PRICING_FORMULA']) )
				{
					tr['PRICING_FACTOR' ] = '';
				}
				break;
			}
			case 12:  // DISCOUNT_PRICE
			{
				var sDATA_FIELD = 'DISCOUNT_PRICE';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
						tr[sDATA_FIELD] = Sql.ToDecimal(td.childNodes[j].value);
				}
				break;
			}
			case 13:  // DATE_CLOSED
			{
				var sDATA_FIELD = 'DATE_CLOSED';
				if ( this.PRIMARY_MODULE == 'Opportunities' )
				{
					for ( var j = 0; j < td.childNodes.length; j++ )
					{
						if ( td.childNodes[j].name == sDATA_FIELD )
						{
							var dtVALUE = $(td.childNodes[j]).datetimepicker('getDate');
							tr[sDATA_FIELD] = ToJsonDate(dtVALUE);
						}
					}
				}
				break;
			}
			case 14:  // OPPORTUNITY_TYPE
			{
				var sDATA_FIELD = 'OPPORTUNITY_TYPE';
				if ( this.PRIMARY_MODULE == 'Opportunities' )
				{
					for ( var j = 0; j < td.childNodes.length; j++ )
					{
						if ( td.childNodes[j].name == sDATA_FIELD )
						{
							var sel = td.childNodes[j];
							tr[sDATA_FIELD] = Sql.ToString(sel.options[sel.options.selectedIndex].value);
						}
					}
				}
				break;
			}
			case 15:  // LEAD_SOURCE
			{
				var sDATA_FIELD = 'LEAD_SOURCE';
				if ( this.PRIMARY_MODULE == 'Opportunities' )
				{
					for ( var j = 0; j < td.childNodes.length; j++ )
					{
						if ( td.childNodes[j].name == sDATA_FIELD )
						{
							var sel = td.childNodes[j];
							tr[sDATA_FIELD] = Sql.ToString(sel.options[sel.options.selectedIndex].value);
						}
					}
				}
				break;
			}
			case 16:  // NEXT_STEP
			{
				var sDATA_FIELD = 'NEXT_STEP';
				if ( this.PRIMARY_MODULE == 'Opportunities' )
				{
					for ( var j = 0; j < td.childNodes.length; j++ )
					{
						if ( td.childNodes[j].name == sDATA_FIELD )
							tr[sDATA_FIELD] = Sql.ToString(td.childNodes[j].value);
					}
				}
				break;
			}
			case 17:  // SALES_STAGE
			{
				var sDATA_FIELD = 'SALES_STAGE';
				if ( this.PRIMARY_MODULE == 'Opportunities' )
				{
					for ( var j = 0; j < td.childNodes.length; j++ )
					{
						if ( td.childNodes[j].name == sDATA_FIELD )
						{
							var sel = td.childNodes[j];
							tr[sDATA_FIELD] = Sql.ToString(sel.options[sel.options.selectedIndex].value);
						}
					}
				}
				break;
			}
			case 18:  // PROBABILITY
			{
				var sDATA_FIELD = 'PROBABILITY';
				if ( this.PRIMARY_MODULE == 'Opportunities' )
				{
					for ( var j = 0; j < td.childNodes.length; j++ )
					{
						if ( td.childNodes[j].name == sDATA_FIELD )
							tr[sDATA_FIELD] = Sql.ToDecimal(td.childNodes[j].value);
					}
				}
				break;
			}
		}
	}

	var row = tr;
	if ( tr.LINE_ITEM_TYPE == 'Comment' )
	{
		row["NAME"               ] = '';
		row["MFT_PART_NUM"       ] = '';
		row["VENDOR_PART_NUM"    ] = '';
		row["PRODUCT_TEMPLATE_ID"] = '';
		// 07/11/2010 Paul.  Add PARENT_TEMPLATE_ID. 
		row["PARENT_TEMPLATE_ID" ] = '';
		// 07/15/2010 Paul.  Add GROUP_ID for options management. 
		// 08/13/2010 Paul.  Use LINE_GROUP_ID instead of GROUP_ID. 
		row["LINE_GROUP_ID"      ] = '';
		row["TAX_CLASS"          ] = '';
		// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
		row["TAXRATE_ID"         ] = '';
		row["TAX"                ] = '';
		row["QUANTITY"           ] = '';
		row["COST_PRICE"         ] = '';
		row["LIST_PRICE"         ] = '';
		row["UNIT_PRICE"         ] = '';
		row["EXTENDED_PRICE"     ] = '';
		row["DISCOUNT_ID"        ] = '';
		row["DISCOUNT_NAME"      ] = '';
		row["DISCOUNT_PRICE"     ] = '';
		row["PRICING_FORMULA"    ] = '';
		row["PRICING_FACTOR"     ] = '';
	}
	else
	{
		// 11/30/2015 Paul.  Allow Tax to be disabled and to hide MFT Part Number. 
		if ( this.bEnableSalesTax )
		{
			// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
			if ( this.bEnableTaxLineItems )
			{
				row["TAX_CLASS"          ] = '';
			}
			else
			{
				row["TAXRATE_ID"         ] = '';
				row["TAX"                ] = '';
			}
		}
		else
		{
			row["TAX_CLASS"          ] = '';
			row["TAXRATE_ID"         ] = '';
			row["TAX"                ] = '';
		}
		// 02/10/2011 Paul.  Stop converting the Quantity to an integer. 
		row["EXTENDED_PRICE"     ] = Sql.ToDecimal(row["QUANTITY"]) * Sql.ToDecimal(row["UNIT_PRICE"]);
		if ( !Sql.IsEmptyString(row["PRICING_FORMULA"]) )
		{
			var sPRICING_FORMULA = Sql.ToString (row["PRICING_FORMULA"]);
			var fPRICING_FACTOR  = Sql.ToFloat  (row["PRICING_FACTOR" ]);
			var dEXTENDED_PRICE  = Sql.ToDecimal(row["EXTENDED_PRICE" ]);
			var dDISCOUNT_VALUE  = 0.0;
			row["DISCOUNT_PRICE"   ] = this.DiscountValue(sPRICING_FORMULA, fPRICING_FACTOR, dEXTENDED_PRICE);
		}
		else
		{
			row["PRICING_FACTOR"     ] = '';
		}
		// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
		// 11/30/2015 Paul.  Allow Tax to be disabled and to hide MFT Part Number. 
		if ( this.bEnableSalesTax && this.bEnableTaxLineItems )
		{
			row["TAX"         ] = '';
			var gTAXRATE_ID = Sql.ToGuid(row["TAXRATE_ID"]);
			if ( !Sql.IsEmptyGuid(gTAXRATE_ID) )
			{
				var rowTaxRate = SplendidCache.TaxRates(gTAXRATE_ID);
				if ( rowTaxRate != null )
				{
					row["TAX"         ] = (Sql.ToDecimal(row["EXTENDED_PRICE"]) - Sql.ToDecimal(row["DISCOUNT_PRICE"])) * Sql.ToDecimal(rowTaxRate["VALUE"]) / 100;
				}
			}
		}
	}
	this.UpdateTotals(sLayoutPanel);
	if ( this.IsLineItemNotEmpty(tr) )
	{
		this.DisplayRow(sLayoutPanel, sActionsPanel, tr);
		this.AddFinalEditRow(sLayoutPanel, sActionsPanel);
	}
	else
	{
		this.DeleteRow(sLayoutPanel, sActionsPanel, tr);
	}
}

EditLineItemsViewUI.prototype.UpdateItem = function(sLayoutPanel, sActionsPanel, tr, item)
{
	console.log('UpdateItem ' + dumpObj(item, 'item'));
	var oNumberFormat = Security.NumberFormatInfo();
	var txtQUANTITY        = null;
	var txtUNIT_PRICE      = null;
	var txtEXTENDED_PRICE  = null;
	var lstDISCOUNT_ID     = null;
	var txtDISCOUNT_PRICE  = null;
	var lstPRICING_FORMULA = null;
	var txtPRICING_FACTOR  = null;
	for ( var i = 0; i < tr.cells.length; i++ )
	{
		var td = tr.cells[i];
		switch ( i )
		{
			case 1:  // QUANTITY
			{
				var sDATA_FIELD = 'QUANTITY';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
					{
						txtQUANTITY = td.childNodes[j];
						if ( Sql.ToDecimal(txtQUANTITY.value) == 0 )
							txtQUANTITY.value = '1';
					}
				}
				break;
			}
			case 2:  // NAME
			{
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					switch ( td.childNodes[j].name )
					{
						case 'NAME'               :  td.childNodes[j].value = Sql.ToString(item.NAME       );  break;
						case 'PRODUCT_TEMPLATE_ID':  td.childNodes[j].value = Sql.ToString(item.ID         );  break;
						case 'DESCRIPTION'        :  td.childNodes[j].value = Sql.ToString(item.DESCRIPTION);  break;
					}
				}
				break;
			}
			case 3:  // MFT_PART_NUM
			{
				var sDATA_FIELD = 'MFT_PART_NUM';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
						td.childNodes[j].value = Sql.ToString(item[sDATA_FIELD]);
				}
				break;
			}
			case 4:  // TAX_CLASS
			{
				var sDATA_FIELD = 'TAX_CLASS';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
					{
						var sel = td.childNodes[j];
						for ( var k = 0; k < sel.options.length ; k++ )
						{
							if ( sel.options[k].value == item[sDATA_FIELD] )
							{
								sel.options[k].selected = true;
								break;
							}
						}
					}
				}
				break;
			}
			case 5:  // TAXRATE_ID
			{
				var sDATA_FIELD = 'TAXRATE_ID';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
					{
						var sel = td.childNodes[j];
						for ( var k = 0; k < sel.options.length ; k++ )
						{
							if ( sel.options[k].value == item[sDATA_FIELD] )
							{
								sel.options[k].selected = true;
								break;
							}
						}
					}
				}
				break;
			}
			case 6:  // COST_PRICE
			{
				var sDATA_FIELD = 'COST_PRICE';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
					{
						td.childNodes[j].value = formatNumber(Sql.ToString(item[sDATA_FIELD]), oNumberFormat);
					}
				}
				break;
			}
			case 7:  // LIST_PRICE
			{
				var sDATA_FIELD = 'LIST_PRICE';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
					{
						td.childNodes[j].value = formatNumber(Sql.ToString(item[sDATA_FIELD]), oNumberFormat);
					}
				}
				break;
			}
			case 8:  // UNIT_PRICE
			{
				var sDATA_FIELD = 'UNIT_PRICE';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
					{
						txtUNIT_PRICE = td.childNodes[j];
						td.childNodes[j].value = formatNumber(Sql.ToString(item[sDATA_FIELD]), oNumberFormat);
					}
				}
				break;
			}
			case 9:  // EXTENDED_PRICE
			{
				var sDATA_FIELD = 'EXTENDED_PRICE';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
					{
						txtEXTENDED_PRICE = td.childNodes[j];
						td.childNodes[j].value = formatNumber(Sql.ToDecimal(txtQUANTITY.value) * Sql.ToDecimal(item['UNIT_PRICE']), oNumberFormat);
					}
				}
				break;
			}
			case 10:  // TAX
			{
				var sDATA_FIELD = 'TAX';
				break;
			}
			case 11:  // DISCOUNT controls. 
			{
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					switch ( td.childNodes[j].name )
					{
						case 'DISCOUNT_ID'    :  lstDISCOUNT_ID     = td.childNodes[j];  break;
						case 'PRICING_FORMULA':  lstPRICING_FORMULA = td.childNodes[j];  break;
						case 'PRICING_FACTOR' :  txtPRICING_FACTOR  = td.childNodes[j];  break;
					}
				}
				break;
			}
			case 12:  // DISCOUNT_PRICE
			{
				var sDATA_FIELD = 'DISCOUNT_PRICE';
				for ( var j = 0; j < td.childNodes.length; j++ )
				{
					if ( td.childNodes[j].name == sDATA_FIELD )
					{
						txtDISCOUNT_PRICE = td.childNodes[j];
					}
				}
				break;
			}
			case 13:  // DATE_CLOSED
			{
				var sDATA_FIELD = 'DATE_CLOSED';
				break;
			}
			case 14:  // OPPORTUNITY_TYPE
			{
				var sDATA_FIELD = 'OPPORTUNITY_TYPE';
				break;
			}
			case 15:  // LEAD_SOURCE
			{
				var sDATA_FIELD = 'LEAD_SOURCE';
				break;
			}
			case 16:  // NEXT_STEP
			{
				var sDATA_FIELD = 'NEXT_STEP';
				break;
			}
			case 17:  // SALES_STAGE
			{
				var sDATA_FIELD = 'SALES_STAGE';
				break;
			}
			case 18:  // PROBABILITY
			{
				var sDATA_FIELD = 'PROBABILITY';
				break;
			}
		}
	}
	if ( lstDISCOUNT_ID != null && lstDISCOUNT_ID.options.selectedIndex > 0 )
	{
		this.UpdateDiscount(txtQUANTITY, txtUNIT_PRICE, txtEXTENDED_PRICE, lstPRICING_FORMULA, txtPRICING_FACTOR, lstDISCOUNT_ID, txtDISCOUNT_PRICE, false);
	}
	else if ( lstPRICING_FORMULA != null && lstPRICING_FORMULA.options.selectedIndex > 0 )
	{
		this.UpdatePricingFormula(txtQUANTITY, txtUNIT_PRICE, txtEXTENDED_PRICE, lstPRICING_FORMULA, txtPRICING_FACTOR, lstDISCOUNT_ID, txtDISCOUNT_PRICE, false);
	}
}

EditLineItemsViewUI.prototype.InitDrag = function(sLayoutPanel, tr)
{
	var td = tr.cells[0];
	var imgDrag = document.createElement('img');
	imgDrag.src                = sIMAGE_SERVER + 'App_Themes/Six/images/draghandle_table.gif';
	imgDrag.align              = 'absmiddle';
	imgDrag.style.height       = '16px';
	imgDrag.style.width        = '16px';
	imgDrag.style.borderWidth  = '0px';
	imgDrag.style.padding      = '4px';
	td.appendChild(imgDrag);
	$(imgDrag).attr('data-id-group', 'LayoutRow');
	$(imgDrag).draggable(
	{ cursor: 'move'
	, hoverClass: 'ui-state-hover'
	, containment: '#' + sLayoutPanel + '_ctlEditLineItemsView_grdMain'
	, helper: function()
		{
			var sHeight   = $(tr).height().toString() + 'px';
			var sWidth    = $(tr).width().toString()  + 'px';
			return $( "<div style='border: 1px solid red; height: " + sHeight + "; width: " + sWidth + ";'>&nbsp;</div>" );
		}
	});
	$(tr).droppable(
	{ greedy: true
	, drop: function(event, ui)
		{
			$(this).removeClass('ui-state-hover');
			var sDataIdGroup = ui.draggable.attr('data-id-group');
			if ( sDataIdGroup == 'LayoutRow' )
			{
				var imgDrag = ui.draggable[0];
				if ( this != imgDrag.parentNode.parentNode )
				{
					console.log('Drop on other row');
					var trDraggable = imgDrag.parentNode.parentNode;
					if ( trDraggable.rowIndex > this.rowIndex )
						$(trDraggable).insertBefore(this);
					else
						$(trDraggable).insertAfter(this);
				}
				else
				{
					console.log('Drop on same row');
				}
			}
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			return sDataIdGroup == 'LayoutRow';
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

EditLineItemsViewUI.prototype.DisplayRow = function(sLayoutPanel, sActionsPanel, tr)
{
	tr.EDIT_MODE = 'ReadOnly';
	var oNumberFormat = Security.NumberFormatInfo();
	var nbsp = String.fromCharCode(160);
	for ( var i = 0; i < tr.cells.length; i++ )
	{
		var td = tr.cells[i];
		while ( td.childNodes.length > 0 )
		{
			td.removeChild(td.firstChild);
		}
		switch ( i )
		{
			case 0:  // LINE_ITEM_TYPE
			{
				var context = this;
				var sDATA_FIELD = 'LINE_ITEM_TYPE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				//var div = document.createElement('div');
				//td.appendChild(div);
				//div.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				this.InitDrag(sLayoutPanel, tr);
				break;
			}
			case 1:  // QUANTITY
			{
				var sDATA_FIELD = 'QUANTITY';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				break;
			}
			case 2:  // NAME
			{
				var sDATA_FIELD = 'NAME';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				
				sDATA_FIELD = 'DESCRIPTION';
				sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) && !Sql.IsEmptyString(sDATA_VALUE) )
				{
					td.appendChild(document.createElement('br'));
					spn = document.createElement('span');
					td.appendChild(spn);
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				break;
			}
			case 3:  // MFT_PART_NUM
			{
				var sDATA_FIELD = 'MFT_PART_NUM';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				break;
			}
			case 4:  // TAX_CLASS
			{
				var sDATA_FIELD = 'TAX_CLASS';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					sDATA_VALUE = L10n.ListTerm('tax_class_dom', sDATA_VALUE);
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				break;
			}
			case 5:  // TAXRATE_ID
			{
				var sDATA_FIELD = 'TAXRATE_ID';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					sDATA_VALUE = L10n.ListTerm('TaxRates', sDATA_VALUE);
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				break;
			}
			case 6:  // COST_PRICE
			{
				var sDATA_FIELD = 'COST_PRICE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					spn.appendChild(document.createTextNode(formatCurrency(Sql.ToString(sDATA_VALUE), oNumberFormat)));
				}
				break;
			}
			case 7:  // LIST_PRICE
			{
				var sDATA_FIELD = 'LIST_PRICE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					spn.appendChild(document.createTextNode(formatCurrency(Sql.ToString(sDATA_VALUE), oNumberFormat)));
				}
				break;
			}
			case 8:  // UNIT_PRICE
			{
				var sDATA_FIELD = 'UNIT_PRICE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					spn.appendChild(document.createTextNode(formatCurrency(Sql.ToString(sDATA_VALUE), oNumberFormat)));
				}
				break;
			}
			case 9:  // EXTENDED_PRICE
			{
				var sDATA_FIELD = 'EXTENDED_PRICE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					spn.appendChild(document.createTextNode(formatCurrency(Sql.ToString(sDATA_VALUE), oNumberFormat)));
				}
				break;
			}
			case 10:  // TAX
			{
				var sDATA_FIELD = 'TAX';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					spn.appendChild(document.createTextNode(formatCurrency(Sql.ToString(sDATA_VALUE), oNumberFormat)));
				}
				break;
			}
			case 11:  // DISCOUNT controls. 
			{
				var sDATA_FIELD = 'DISCOUNT_ID';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					sDATA_VALUE = L10n.ListTerm('Discounts', sDATA_VALUE);
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				
				sDATA_FIELD = 'PRICING_FORMULA';
				sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					if ( !Sql.IsEmptyString(tr['DISCOUNT_ID']) )
						td.appendChild(document.createTextNode(nbsp));
					spn = document.createElement('span');
					td.appendChild(spn);
					sDATA_VALUE = L10n.ListTerm('pricing_formula_line_items', sDATA_VALUE);
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				sDATA_FIELD = 'PRICING_FACTOR';
				sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) && !Sql.IsEmptyString(tr.PRICING_FORMULA) )
				{
					td.appendChild(document.createTextNode(nbsp));
					spn = document.createElement('span');
					td.appendChild(spn);
					spn.appendChild(document.createTextNode(formatNumber(Sql.ToString(sDATA_VALUE), oNumberFormat)));
				}
				break;
			}
			case 12:  // DISCOUNT_PRICE
			{
				var sDATA_FIELD = 'DISCOUNT_PRICE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					spn.appendChild(document.createTextNode(formatCurrency(Sql.ToString(sDATA_VALUE), oNumberFormat)));
				}
				break;
			}
			case 13:  // DATE_CLOSED
			{
				var sDATA_FIELD = 'DATE_CLOSED';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					sDATA_VALUE = FromJsonDate(sDATA_VALUE, Security.USER_DATE_FORMAT());
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				break;
			}
			case 14:  // OPPORTUNITY_TYPE
			{
				var sDATA_FIELD = 'OPPORTUNITY_TYPE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					sDATA_VALUE = L10n.ListTerm('opportunity_type_dom', sDATA_VALUE);
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				break;
			}
			case 15:  // LEAD_SOURCE
			{
				var sDATA_FIELD = 'LEAD_SOURCE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					sDATA_VALUE = L10n.ListTerm('lead_source_dom', sDATA_VALUE);
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				break;
			}
			case 16:  // NEXT_STEP
			{
				var sDATA_FIELD = 'NEXT_STEP';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				break;
			}
			case 17:  // SALES_STAGE
			{
				var sDATA_FIELD = 'SALES_STAGE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					sDATA_VALUE = L10n.ListTerm('sales_stage_dom', sDATA_VALUE);
					spn.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				}
				break;
			}
			case 18:  // PROBABILITY
			{
				var sDATA_FIELD = 'PROBABILITY';
				var sDATA_VALUE = tr[sDATA_FIELD];
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) )
				{
					spn = document.createElement('span');
					td.appendChild(spn);
					sDATA_VALUE = formatNumber(Sql.ToString(sDATA_VALUE), oNumberFormat);
					spn.appendChild(document.createTextNode(sDATA_VALUE));
				}
				break;
			}
			case 19:
			{
				var btnEdit = document.createElement('input');
				btnEdit.type      = 'button';
				btnEdit.className = 'button';
				btnEdit.title     = L10n.Term('.LBL_EDIT_BUTTON_TITLE');
				btnEdit.value     = L10n.Term('.LBL_EDIT_BUTTON_LABEL');
				btnEdit.style.margin = '4px 2px 4px 4px';
				btnEdit.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, tr, context)
				{
					context.AjaxError(sLayoutPanel, '');
					context.EditRow(sLayoutPanel, sActionsPanel, tr);
				}, sLayoutPanel, sActionsPanel, tr, this);
				td.appendChild(btnEdit);
				
				var btnDelete = document.createElement('input');
				btnDelete.type      = 'button';
				btnDelete.className = 'button';
				btnDelete.title     = L10n.Term('.LBL_DELETE_BUTTON_TITLE');
				btnDelete.value     = L10n.Term('.LBL_DELETE_BUTTON_LABEL');
				btnDelete.style.margin = '4px 4px 4px 2px';
				btnDelete.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, tr, context)
				{
					context.AjaxError(sLayoutPanel, '');
					context.DeleteRow(sLayoutPanel, sActionsPanel, tr);
				}, sLayoutPanel, sActionsPanel, tr, this);
				td.appendChild(btnDelete);
				break;
			}
		}
	}
}

EditLineItemsViewUI.prototype.EditRow = function(sLayoutPanel, sActionsPanel, tr)
{
	tr.EDIT_MODE = 'Edit';
	var oNumberFormat = Security.NumberFormatInfo();
	var txtQUANTITY        = null;
	var txtUNIT_PRICE      = null;
	var txtEXTENDED_PRICE  = null;
	var lstDISCOUNT_ID     = null;
	var txtDISCOUNT_PRICE  = null;
	var lstPRICING_FORMULA = null;
	var txtPRICING_FACTOR  = null;
	for ( var i = 0; i < tr.cells.length; i++ )
	{
		var td = tr.cells[i];
		while ( td.childNodes.length > 0 )
		{
			td.removeChild(td.firstChild);
		}
		switch ( i )
		{
			case 0:  // LINE_ITEM_TYPE
			{
				var context = this;
				var sDATA_FIELD = 'LINE_ITEM_TYPE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				//var div = document.createElement('div');
				//td.appendChild(div);
				//div.appendChild(document.createTextNode(Sql.ToString(sDATA_VALUE)));
				this.InitDrag(sLayoutPanel, tr);
				break;
				break;
			}
			case 1:  // QUANTITY
			{
				var sDATA_FIELD = 'QUANTITY';
				var sDATA_VALUE = tr[sDATA_FIELD];
				txtQUANTITY = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, Sql.ToDecimal(sDATA_VALUE), 11, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txtQUANTITY.name        = sDATA_FIELD;
				txtQUANTITY.maxLength   = 10;
				txtQUANTITY.style.width = '50px';
				txtQUANTITY.autocomplete = 'off';
				break;
			}
			case 2:  // NAME
			{
				var hid = document.createElement('input');
				hid.name = 'PRODUCT_TEMPLATE_ID';
				hid.type = 'hidden';
				hid.value = tr.PRODUCT_TEMPLATE_ID;
				td.appendChild(hid);
				// 03/08/2016 Paul.  Don't place edit fields in a nobr as it is harder to get out. 
				td.style.whiteSpace = 'nowrap';
				
				var sDATA_FIELD = 'NAME';
				var sDATA_VALUE = tr[sDATA_FIELD];
				var txt = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, Sql.ToString(sDATA_VALUE), 12, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txt.name          = sDATA_FIELD;
				txt.autocomplete  = 'off';
				txt.style.display = 'inline-block';
				txt.onblur = BindArguments(function(tr, txt, context)
				{
					if ( !Sql.IsEmptyString(txt.value) )
					{
						var sNAME          = txt.value;
						var lstCURRENCY_ID = document.getElementById(sLayoutPanel + '_ctlEditView_' + 'CURRENCY_ID');
						var gCURRENCY_ID   = lstCURRENCY_ID.options[lstCURRENCY_ID.options.selectedIndex].value;
						var bgPage = chrome.extension.getBackgroundPage();
						bgPage.AutoComplete_ModuleMethod('Products/ProductCatalog', 'GetItemDetailsByName', '{"gCURRENCY_ID": ' + JSON.stringify(gCURRENCY_ID) + ', "sNAME": ' + JSON.stringify(sNAME) + '}', function(status, message)
						{
							if ( typeof(message) == 'string' )
							{
								var error = JSON.parse(message);
								this.AjaxError(sLayoutPanel, error.Message);
							}
							else if ( typeof(message) == 'object' )
							{
								var item = message;
								this.UpdateItem(sLayoutPanel, sActionsPanel, tr, item);
							}
						}, context);
					}
				}, tr, txt, this);
				var thisContext = this;
				// http://jqueryui.com/demos/autocomplete/remote-jsonp.html
				$(txt).autocomplete(
				{
					  minLength: 2
					, source: function(request, response)
					{
						try
						{
							var bgPage = chrome.extension.getBackgroundPage();
							bgPage.AutoComplete_ModuleMethod('Products/ProductCatalog', 'ItemNameList', '{"prefixText": ' + JSON.stringify(request.term) + ', "count": 12}', function(status, message)
							{
								if ( status == 1 )
								{
									response($.map(message, function(item)
									{
										return { label: item, value: item };
									}));
								}
							}, thisContext);
						}
						catch(e)
						{
							console.log('EditLIneItemsViewUI.AutoComplete: ' + e.message);
						}
					}
					, select: function(event, ui)
					{
						try
						{
							//alert(dumpObj(ui.item, 'ui.item'));
							if ( ui.item && !Sql.IsEmptyString(ui.item.value) )
							{
								var sNAME          = ui.item.value;
								var lstCURRENCY_ID = document.getElementById(sLayoutPanel + '_ctlEditView_' + 'CURRENCY_ID');
								var gCURRENCY_ID   = lstCURRENCY_ID.options[lstCURRENCY_ID.options.selectedIndex].value;
								var bgPage = chrome.extension.getBackgroundPage();
								bgPage.AutoComplete_ModuleMethod('Products/ProductCatalog', 'GetItemDetailsByName', '{"gCURRENCY_ID": ' + JSON.stringify(gCURRENCY_ID) + ', "sNAME": ' + JSON.stringify(sNAME) + '}', function(status, message)
								{
									if ( typeof(message) == 'string' )
									{
										var error = JSON.parse(message);
										this.AjaxError(sLayoutPanel, error.Message);
									}
									else if ( typeof(message) == 'object' )
									{
										var item = message;
										this.UpdateItem(sLayoutPanel, sActionsPanel, tr, item);
									}
								}, thisContext);
							}
						}
						catch(e)
						{
							console.log('EditLIneItemsViewUI.AutoComplete: ' + e.message);
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
				
				var btnChange = document.createElement('input');
				btnChange.type      = 'button';
				btnChange.className = 'button';
				btnChange.title     = L10n.Term('.LBL_SELECT_BUTTON_TITLE');
				btnChange.value     = L10n.Term('.LBL_SELECT_BUTTON_LABEL');
				btnChange.style.marginLeft  = '4px';
				btnChange.style.marginRight = '2px';
				btnChange.style.display = !this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) ? 'none' : 'inline-block';
				btnChange.onclick = BindArguments(function(txt, hid, sMODULE_TYPE, sDATA_FIELD, context)
				{
					context.AjaxError(sLayoutPanel, '');
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
								var oPopupViewUI = new PopupViewUI();
								// 02/29/2016 Paul.  ProductCatalog has a special sort field. 
								oPopupViewUI.SORT_FIELD = 'NAME_SORT';
								oPopupViewUI.Load('divPopupLayoutPanel', 'divPopupActionsPanel', sMODULE_TYPE, false, function(status, message)
								{
									if ( status == 1 )
									{
										hid.value = message.ID  ;
										txt.value = message.NAME;
										var sPRODUCT_TEMPLATE_ID = message.ID;
										var lstCURRENCY_ID = document.getElementById(sLayoutPanel + '_ctlEditView_' + 'CURRENCY_ID');
										var gCURRENCY_ID   = lstCURRENCY_ID.options[lstCURRENCY_ID.options.selectedIndex].value;
										var bgPage = chrome.extension.getBackgroundPage();
										bgPage.AutoComplete_ModuleMethod('Products/ProductCatalog', 'GetItemDetailsByID', '{"gCURRENCY_ID": ' + JSON.stringify(gCURRENCY_ID) + ', "sID": ' + JSON.stringify(sPRODUCT_TEMPLATE_ID) + '}', function(status, message)
										{
											if ( typeof(message) == 'string' )
											{
												var error = JSON.parse(message);
												this.AjaxError(sLayoutPanel, error.Message);
											}
											else if ( typeof(message) == 'object' )
											{
												var item = message;
												this.UpdateItem(sLayoutPanel, sActionsPanel, tr, item);
											}
										}, context);
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
				}, txt, hid, 'ProductCatalog', sDATA_FIELD, this);
				td.appendChild(btnChange);
				
				sDATA_FIELD = 'DESCRIPTION';
				sDATA_VALUE = tr[sDATA_FIELD];
				txt               = document.createElement('textarea');
				txt.name          = sDATA_FIELD;
				txt.value         = sDATA_VALUE;
				txt.rows          = 3;
				txt.cols          = 20;
				txt.tabIndex      = 24;
				txt.style.width   = '180px';
				txt.autocomplete  = 'off';
				txt.style.display = !this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) ? 'none' : 'block';
				td.appendChild(txt);
				break;
			}
			case 3:  // MFT_PART_NUM
			{
				var sDATA_FIELD = 'MFT_PART_NUM';
				var sDATA_VALUE = tr[sDATA_FIELD];
				var txt = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, Sql.ToString(sDATA_VALUE), 14, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txt.name         = sDATA_FIELD;
				txt.autocomplete = 'off';
				txt.onblur = BindArguments(function(tr, txt, context)
				{
					if ( !Sql.IsEmptyString(txt.value) )
					{
						var sMFT_PART_NUM  = txt.value;
						var lstCURRENCY_ID = document.getElementById(sLayoutPanel + '_ctlEditView_' + 'CURRENCY_ID');
						var gCURRENCY_ID   = lstCURRENCY_ID.options[lstCURRENCY_ID.options.selectedIndex].value;
						var bgPage = chrome.extension.getBackgroundPage();
						bgPage.AutoComplete_ModuleMethod('Products/ProductCatalog', 'GetItemDetailsByNumber', '{"gCURRENCY_ID": ' + JSON.stringify(gCURRENCY_ID) + ', "sMFT_PART_NUM": ' + JSON.stringify(sMFT_PART_NUM) + '}', function(status, message)
						{
							if ( typeof(message) == 'string' )
							{
								var error = JSON.parse(message);
								this.AjaxError(sLayoutPanel, error.Message);
							}
							else if ( typeof(message) == 'object' )
							{
								var item = message;
								this.UpdateItem(sLayoutPanel, sActionsPanel, tr, item);
							}
						}, context);
					}
				}, tr, txt, this);
				var thisContext = this;
				// http://jqueryui.com/demos/autocomplete/remote-jsonp.html
				$(txt).autocomplete(
				{
					  minLength: 2
					, source: function(request, response)
					{
						try
						{
							var bgPage = chrome.extension.getBackgroundPage();
							bgPage.AutoComplete_ModuleMethod('Products/ProductCatalog', 'ItemNumberList', '{"prefixText": ' + JSON.stringify(request.term) + ', "count": 12}', function(status, message)
							{
								if ( status == 1 )
								{
									response($.map(message, function(item)
									{
										return { label: item, value: item };
									}));
								}
							}, thisContext);
						}
						catch(e)
						{
							console.log('EditLIneItemsViewUI.AutoComplete: ' + e.message);
						}
					}
					, select: function(event, ui)
					{
						try
						{
							//alert(dumpObj(ui.item, 'ui.item'));
							if ( ui.item && !Sql.IsEmptyString(ui.item.value) )
							{
								var sMFT_PART_NUM  = ui.item.value;
								var lstCURRENCY_ID = document.getElementById(sLayoutPanel + '_ctlEditView_' + 'CURRENCY_ID');
								var gCURRENCY_ID   = lstCURRENCY_ID.options[lstCURRENCY_ID.options.selectedIndex].value;
								var bgPage = chrome.extension.getBackgroundPage();
								bgPage.AutoComplete_ModuleMethod('Products/ProductCatalog', 'GetItemDetailsByNumber', '{"gCURRENCY_ID": ' + JSON.stringify(gCURRENCY_ID) + ', "sMFT_PART_NUM": ' + JSON.stringify(sMFT_PART_NUM) + '}', function(status, message)
								{
									if ( typeof(message) == 'string' )
									{
										var error = JSON.parse(message);
										this.AjaxError(sLayoutPanel, error.Message);
									}
									else if ( typeof(message) == 'object' )
									{
										var item = message;
										this.UpdateItem(sLayoutPanel, sActionsPanel, tr, item);
									}
								}, thisContext);
							}
						}
						catch(e)
						{
							console.log('EditLIneItemsViewUI.AutoComplete: ' + e.message);
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
				break;
			}
			case 4:  // TAX_CLASS
			{
				var sDATA_FIELD = 'TAX_CLASS';
				var sDATA_VALUE = tr[sDATA_FIELD];
				var lst = this.AddListBox(sLayoutPanel, td, 'tax_class_dom', sDATA_FIELD, Sql.ToString(sDATA_VALUE), false, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				lst.name = sDATA_FIELD;
				break;
			}
			case 5:  // TAXRATE_ID
			{
				var sDATA_FIELD = 'TAXRATE_ID';
				var sDATA_VALUE = tr[sDATA_FIELD];
				var lst = this.AddListBox(sLayoutPanel, td, 'TaxRates', sDATA_FIELD, Sql.ToString(sDATA_VALUE), true, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				lst.name = sDATA_FIELD;
				break;
			}
			case 6:  // COST_PRICE
			{
				var sDATA_FIELD = 'COST_PRICE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				var txt = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, formatNumber(sDATA_VALUE, oNumberFormat), 16, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txt.name         = sDATA_FIELD;
				txt.style.width  = '60px';
				txt.autocomplete = 'off';
				break;
			}
			case 7:  // LIST_PRICE
			{
				var sDATA_FIELD = 'LIST_PRICE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				var txt = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, formatNumber(sDATA_VALUE, oNumberFormat), 17, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txt.name         = sDATA_FIELD;
				txt.style.width  = '60px';
				txt.autocomplete = 'off';
				break;
			}
			case 8:  // UNIT_PRICE
			{
				var sDATA_FIELD = 'UNIT_PRICE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				txtUNIT_PRICE = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, formatNumber(sDATA_VALUE, oNumberFormat), 18, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txtUNIT_PRICE.name         = sDATA_FIELD;
				txtUNIT_PRICE.style.width  = '60px';
				txtUNIT_PRICE.autocomplete = 'off';
				break;
			}
			case 9:  // EXTENDED_PRICE
			{
				var sDATA_FIELD = 'EXTENDED_PRICE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				txtEXTENDED_PRICE = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, formatNumber(sDATA_VALUE, oNumberFormat), 19, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txtEXTENDED_PRICE.name         = sDATA_FIELD;
				txtEXTENDED_PRICE.style.width  = '60px';
				txtEXTENDED_PRICE.autocomplete = 'off';
				txtEXTENDED_PRICE.readOnly     = 'readonly';
				break;
			}
			case 10:  // TAX
			{
				var sDATA_FIELD = 'TAX';
				var sDATA_VALUE = tr[sDATA_FIELD];
				var txt = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, formatNumber(sDATA_VALUE, oNumberFormat), 20, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txt.name         = sDATA_FIELD;
				txt.style.width  = '30px';
				txt.autocomplete = 'off';
				txt.readOnly     = 'readonly';
				break;
			}
			case 11:  // DISCOUNT controls. 
			{
				td.style.whiteSpace = 'nowrap';
				var sDATA_FIELD = 'DISCOUNT_ID';
				var sDATA_VALUE = tr[sDATA_FIELD];
				lstDISCOUNT_ID = this.AddListBox(sLayoutPanel, td, 'Discounts', sDATA_FIELD, Sql.ToString(sDATA_VALUE), true, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				lstDISCOUNT_ID.name     = sDATA_FIELD;
				lstDISCOUNT_ID.tabIndex = 21;
				lstDISCOUNT_ID.style.display = !this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) ? 'none' : 'block';
				
				sDATA_FIELD = 'PRICING_FORMULA';
				sDATA_VALUE = tr[sDATA_FIELD];
				lstPRICING_FORMULA = this.AddListBox(sLayoutPanel, td, 'pricing_formula_line_items', sDATA_FIELD, Sql.ToString(sDATA_VALUE), true, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				lstPRICING_FORMULA.name     = sDATA_FIELD;
				lstPRICING_FORMULA.tabIndex = 21;
				lstPRICING_FORMULA.style.display = !this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) ? 'none' : 'inline-block';
				
				sDATA_FIELD = 'PRICING_FACTOR';
				sDATA_VALUE = tr[sDATA_FIELD];
				txtPRICING_FACTOR = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, Sql.ToDecimal(sDATA_VALUE), 22, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txtPRICING_FACTOR.name         = sDATA_FIELD;
				txtPRICING_FACTOR.style.width  = '30px';
				txtPRICING_FACTOR.autocomplete = 'off';
				txtPRICING_FACTOR.style.display = !this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD) ? 'none' : 'inline-block';
				break;
			}
			case 12:  // DISCOUNT_PRICE
			{
				var sDATA_FIELD = 'DISCOUNT_PRICE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				txtDISCOUNT_PRICE = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, formatNumber(sDATA_VALUE, oNumberFormat), 23, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txtDISCOUNT_PRICE.name         = sDATA_FIELD;
				txtDISCOUNT_PRICE.style.width  = '60px';
				txtDISCOUNT_PRICE.autocomplete = 'off';
				txtDISCOUNT_PRICE.readOnly     = 'readonly';
				break;
			}
			case 13:  // DATE_CLOSED
			{
				var sDATA_FIELD = 'DATE_CLOSED';
				var sDATA_VALUE = tr[sDATA_FIELD];
				var sDATE_FORMAT = Security.USER_DATE_FORMAT();
				// 05/05/2013 Paul.  Remove the day name from the edit field. 
				sDATE_FORMAT = sDATE_FORMAT.replace('dddd,', '');
				sDATE_FORMAT = sDATE_FORMAT.replace('dddd' , '');
				sDATE_FORMAT = sDATE_FORMAT.replace('ddd,' , '');
				sDATE_FORMAT = sDATE_FORMAT.replace('ddd'  , '');
				sDATE_FORMAT = Trim(sDATE_FORMAT);
				var txt = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, FromJsonDate(sDATA_VALUE, sDATE_FORMAT), 24, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txt.name         = sDATA_FIELD;
				txt.autocomplete = 'off';
				$(txt).datepicker();
				break;
			}
			case 14:  // OPPORTUNITY_TYPE
			{
				var sDATA_FIELD = 'OPPORTUNITY_TYPE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				var lst = this.AddListBox(sLayoutPanel, td, 'opportunity_type_dom', sDATA_FIELD, Sql.ToString(sDATA_VALUE), false, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				lst.name = sDATA_FIELD;
				break;
			}
			case 15:  // LEAD_SOURCE
			{
				var sDATA_FIELD = 'LEAD_SOURCE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				var lst = this.AddListBox(sLayoutPanel, td, 'lead_source_dom', sDATA_FIELD, Sql.ToString(sDATA_VALUE), false, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				lst.name = sDATA_FIELD;
				break;
			}
			case 16:  // NEXT_STEP
			{
				var sDATA_FIELD = 'NEXT_STEP';
				var sDATA_VALUE = tr[sDATA_FIELD];
				var txt = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, Sql.ToString(sDATA_VALUE), 25, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txt.name         = sDATA_FIELD;
				txt.autocomplete = 'off';
				break;
			}
			case 17:  // SALES_STAGE
			{
				var sDATA_FIELD = 'SALES_STAGE';
				var sDATA_VALUE = tr[sDATA_FIELD];
				var lst = this.AddListBox(sLayoutPanel, td, 'sales_stage_dom', sDATA_FIELD, Sql.ToString(sDATA_VALUE), false, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				lst.name = sDATA_FIELD;
				break;
			}
			case 18:  // PROBABILITY
			{
				var sDATA_FIELD = 'PROBABILITY';
				var sDATA_VALUE = tr[sDATA_FIELD];
				txtDISCOUNT_PRICE = this.AddTextBox(sLayoutPanel, td, sDATA_FIELD, formatNumber(sDATA_VALUE, oNumberFormat), 26, this.FieldVisibility(tr.LINE_ITEM_TYPE, sDATA_FIELD));
				txtDISCOUNT_PRICE.name         = sDATA_FIELD;
				txtDISCOUNT_PRICE.style.width  = '60px';
				txtDISCOUNT_PRICE.autocomplete = 'off';
				break;
			}
			case 19:
			{
				var btnUpdate = document.createElement('input');
				btnUpdate.type      = 'button';
				btnUpdate.className = 'button';
				btnUpdate.title     = L10n.Term('.LBL_UPDATE_BUTTON_TITLE');
				btnUpdate.value     = L10n.Term('.LBL_UPDATE_BUTTON_LABEL');
				btnUpdate.style.margin = '4px 2px 4px 4px';
				btnUpdate.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, tr, context)
				{
					context.AjaxError(sLayoutPanel, '');
					context.UpdateRow(sLayoutPanel, sActionsPanel, tr);
				}, sLayoutPanel, sActionsPanel, tr, this);
				td.appendChild(btnUpdate);
				
				var btnCancel = document.createElement('input');
				btnCancel.type      = 'button';
				btnCancel.className = 'button';
				btnCancel.title     = L10n.Term('.LBL_CANCEL_BUTTON_TITLE');
				btnCancel.value     = L10n.Term('.LBL_CANCEL_BUTTON_LABEL');
				btnCancel.style.margin = '4px 4px 4px 2px';
				btnCancel.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, tr, context)
				{
					context.AjaxError(sLayoutPanel, '');
					if ( context.IsLineItemNotEmpty(tr) )
						context.DisplayRow(sLayoutPanel, sActionsPanel, tr);
					else
						context.DeleteRow(sLayoutPanel, sActionsPanel, tr);
				}, sLayoutPanel, sActionsPanel, tr, this);
				td.appendChild(btnCancel);
				td.appendChild(document.createElement('br'));
				
				if ( this.FieldVisibility(tr.LINE_ITEM_TYPE, 'btnComment') )
				{
					var spnComment = document.createElement('span');
					spnComment.style.whiteSpace = 'nowrap';
					spnComment.style.cursor     = 'pointer';
					td.appendChild(spnComment);
					var imgPlus = document.createElement('input');
					imgPlus.type               = 'image';
					imgPlus.alt                = L10n.Term('Orders.LBL_ADD_COMMENT');
					imgPlus.src                = sIMAGE_SERVER + 'App_Themes/Six/images/plus_inline.gif';
					imgPlus.align              = 'absmiddle';
					imgPlus.style.height       = '12px';
					imgPlus.style.width        = '12px';
					imgPlus.style.borderWidth  = '0px';
					imgPlus.style.paddingRight = '4px';
					spnComment.appendChild(imgPlus);
					var aAddComment = document.createElement('a');
					aAddComment.href = '#';
					aAddComment.appendChild(document.createTextNode(imgPlus.alt));
					spnComment.appendChild(aAddComment);
					spnComment.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, tr, context)
					{
						context.AjaxError(sLayoutPanel, '');
						var row = tr;
						row["LINE_ITEM_TYPE"     ] = 'Comment';
						row["NAME"               ] = '';
						row["MFT_PART_NUM"       ] = '';
						row["VENDOR_PART_NUM"    ] = '';
						row["PRODUCT_TEMPLATE_ID"] = '';
						row["PARENT_TEMPLATE_ID" ] = '';
						row["LINE_GROUP_ID"      ] = '';
						row["TAX_CLASS"          ] = '';
						row["TAXRATE_ID"         ] = '';
						row["TAX"                ] = '';
						row["QUANTITY"           ] = '';
						row["COST_PRICE"         ] = '';
						row["LIST_PRICE"         ] = '';
						row["UNIT_PRICE"         ] = '';
						row["EXTENDED_PRICE"     ] = '';
						row["DISCOUNT_ID"        ] = '';
						row["DISCOUNT_NAME"      ] = '';
						row["DISCOUNT_PRICE"     ] = '';
						row["PRICING_FORMULA"    ] = '';
						row["PRICING_FACTOR"     ] = '';
						context.EditRow(sLayoutPanel, sActionsPanel, tr);
					}, sLayoutPanel, sActionsPanel, tr, this);
				}
				break;
			}
		}
	}
	
	lstDISCOUNT_ID.onchange = BindArguments(function(txtQUANTITY, txtUNIT_PRICE, txtEXTENDED_PRICE, lstPRICING_FORMULA, txtPRICING_FACTOR, lstDISCOUNT_ID, txtDISCOUNT_PRICE, context)
	{
		context.UpdateDiscount(txtQUANTITY, txtUNIT_PRICE, txtEXTENDED_PRICE, lstPRICING_FORMULA, txtPRICING_FACTOR, lstDISCOUNT_ID, txtDISCOUNT_PRICE, true);
	}, txtQUANTITY, txtUNIT_PRICE, txtEXTENDED_PRICE, lstPRICING_FORMULA, txtPRICING_FACTOR, lstDISCOUNT_ID, txtDISCOUNT_PRICE, this);
	
	lstPRICING_FORMULA.onchange = BindArguments(function(txtQUANTITY, txtUNIT_PRICE, txtEXTENDED_PRICE, lstPRICING_FORMULA, txtPRICING_FACTOR, lstDISCOUNT_ID, txtDISCOUNT_PRICE, context)
	{
		context.UpdatePricingFormula(txtQUANTITY, txtUNIT_PRICE, txtEXTENDED_PRICE, lstPRICING_FORMULA, txtPRICING_FACTOR, lstDISCOUNT_ID, txtDISCOUNT_PRICE, true);
	}, txtQUANTITY, txtUNIT_PRICE, txtEXTENDED_PRICE, lstPRICING_FORMULA, txtPRICING_FACTOR, lstDISCOUNT_ID, txtDISCOUNT_PRICE, this);
}

EditLineItemsViewUI.prototype.UpdateDiscount = function(txtQUANTITY, txtUNIT_PRICE, txtEXTENDED_PRICE, lstPRICING_FORMULA, txtPRICING_FACTOR, lstDISCOUNT_ID, txtDISCOUNT_PRICE, bOnChange)
{
	try
	{
		var oNumberFormat = Security.NumberFormatInfo();
		// 02/10/2011 Paul.  Stop converting the Quantity to an integer. 
		var nQUANTITY        = Sql.ToDecimal(txtQUANTITY      .value);
		var dUNIT_PRICE      = Sql.ToDecimal(txtUNIT_PRICE    .value);
		var gDISCOUNT_ID     = lstDISCOUNT_ID.options[lstDISCOUNT_ID.options.selectedIndex].value;
		var dDISCOUNT_VALUE  = 0.0;  // Sql.ToDecimal(txtDISCOUNT_PRICE.value);
		var sDISCOUNT_NAME   = '';
		var sPRICING_FORMULA = '';
		var fPRICING_FACTOR  = 0;
		
		// 08/15/2010 Paul.  In this area, we use the UNIT_PRICE instead of list or cost. 
		rowDISCOUNT = SplendidCache.Discounts(gDISCOUNT_ID);
		if ( rowDISCOUNT != null )
		{
			sPRICING_FORMULA = Sql.ToString(rowDISCOUNT["PRICING_FORMULA"]);
			fPRICING_FACTOR  = Sql.ToFloat (rowDISCOUNT["PRICING_FACTOR" ]);
			sDISCOUNT_NAME   = Sql.ToString(rowDISCOUNT["NAME"           ]);
			dDISCOUNT_VALUE  = context.DiscountValue(sPRICING_FORMULA, fPRICING_FACTOR, dUNIT_PRICE);
		}
		// 08/15/2010 Paul.  The value we store is the discount amount and not the end-price. 
		txtDISCOUNT_PRICE.value = formatNumber(nQUANTITY * dDISCOUNT_VALUE, oNumberFormat);
		txtEXTENDED_PRICE.value = formatNumber(nQUANTITY * dUNIT_PRICE    , oNumberFormat);
		txtPRICING_FACTOR.value = fPRICING_FACTOR;
		if ( bOnChange )
		{
			for ( var i = 0; i < lstPRICING_FORMULA.options.length ; i++ )
			{
				if ( lstPRICING_FORMULA.options[i].value == sPRICING_FORMULA )
				{
					lstPRICING_FORMULA.options[i].selected = true;
					break;
				}
			}
		}
	}
	catch(e)
	{
		console.log(e.message);
	}
}

EditLineItemsViewUI.prototype.UpdatePricingFormula = function(txtQUANTITY, txtUNIT_PRICE, txtEXTENDED_PRICE, lstPRICING_FORMULA, txtPRICING_FACTOR, lstDISCOUNT_ID, txtDISCOUNT_PRICE)
{
	try
	{
		var oNumberFormat = Security.NumberFormatInfo();
		var nQUANTITY        = Sql.ToDecimal(txtQUANTITY      .value);
		var dUNIT_PRICE      = Sql.ToDecimal(txtUNIT_PRICE    .value);
		var sPRICING_FORMULA = lstPRICING_FORMULA.options[lstPRICING_FORMULA.options.selectedIndex];
		var fPRICING_FACTOR  = Sql.ToFloat  (txtPRICING_FACTOR.value);
		var dDISCOUNT_VALUE  = context.DiscountValue(sPRICING_FORMULA, fPRICING_FACTOR, dUNIT_PRICE);
		
		txtDISCOUNT_PRICE.value = formatNumber(nQUANTITY * dDISCOUNT_VALUE, oNumberFormat);
		txtEXTENDED_PRICE.value = formatNumber(nQUANTITY * dUNIT_PRICE    , oNumberFormat);
		if ( bOnChange )
		{
			lstDISCOUNT_ID.options.selectedIndex = 0;
		}
	}
	catch(e)
	{
		console.log(e.message);
	}
}

EditLineItemsViewUI.prototype.DiscountValue = function(sPRICING_FORMULA, fPRICING_FACTOR, dLIST_PRICE)
{
	var dDISCOUNT_VALUE = 0.0;
	if ( fPRICING_FACTOR > 0 )
	{
		switch ( sPRICING_FORMULA )
		{
			case 'PercentageDiscount':
				dDISCOUNT_VALUE = (dLIST_PRICE * (Sql.ToDecimal(fPRICING_FACTOR) /100)*100)/100;
				break;
			case 'FixedDiscount'     :
				dDISCOUNT_VALUE = Sql.ToDecimal(fPRICING_FACTOR);
				break;
		}
	}
	return dDISCOUNT_VALUE;
}

EditLineItemsViewUI.prototype.DeleteRow = function(sLayoutPanel, sActionsPanel, tr)
{
	try
	{
		tr.parentNode.removeChild(tr);
		this.UpdateTotals(sLayoutPanel);
		this.AddFinalEditRow(sLayoutPanel, sActionsPanel);
	}
	catch(e)
	{
		console.log(e.message);
	}
}

EditLineItemsViewUI.prototype.AddFinalEditRow = function(sLayoutPanel, sActionsPanel)
{
	try
	{
		var nEditRows = 0;
		var tblMain = document.getElementById(sLayoutPanel + '_ctlEditLineItemsView_grdMain');
		for ( var i = 0; i < tblMain.rows.length; i++ )
		{
			var tr = tblMain.rows[i];
			if ( tr.EDIT_MODE == 'Edit' || tr.EDIT_MODE == 'New' )
			{
				nEditRows++;
			}
		}
		if ( nEditRows == 0 )
		{
			var tr = tblMain.insertRow(-1);
			var row = null;
			this.RenderRow(sLayoutPanel, sActionsPanel, this.MODULE_NAME, this.layout, tr, row, this.PRIMARY_MODULE, this.PRIMARY_ID, true);
			tr.EDIT_MODE = 'New';
		}
	}
	catch(e)
	{
		console.log(e.message);
	}
}

EditLineItemsViewUI.prototype.AjaxError = function(sLayoutPanel, message)
{
	$('#' + sLayoutPanel + '_ctlEditLineItemsView_AjaxErrors').text(message);
}

EditLineItemsViewUI.prototype.Validate = function(sLayoutPanel)
{
	var bValid = true;
	var tblMain = document.getElementById(sLayoutPanel + '_ctlEditLineItemsView_grdMain');
	for ( var i = 0; i < tblMain.rows.length; i++ )
	{
		var tr = tblMain.rows[i];
		if ( tr.EDIT_MODE == 'Edit' || tr.EDIT_MODE == 'New' )
		{
			// 03/03/2016 Paul.  Can't use IsLineItemNotEmpty() as the values are not saved. 
			if ( tr.LINE_ITEM_TYPE == 'Comment' || tr.LINE_ITEM_TYPE == 'Subtotal' )
				continue;
			var td = tr.cells[2];
			var sNAME                = '';
			var sPRODUCT_TEMPLATE_ID = '';
			var sMFT_PART_NUM        = '';
			for ( var j = 0; j < td.childNodes.length; j++ )
			{
				switch ( td.childNodes[j].name )
				{
					case 'NAME'               :  sNAME                = Sql.ToString(td.childNodes[j].value);  break;
					case 'PRODUCT_TEMPLATE_ID':  sPRODUCT_TEMPLATE_ID = Sql.ToString(td.childNodes[j].value);  break;
				}
			}
			td = tr.cells[3];
			for ( var j = 0; j < td.childNodes.length; j++ )
			{
				if ( td.childNodes[j].name == 'MFT_PART_NUM' )
					sMFT_PART_NUM = Sql.ToString(td.childNodes[j].value);
			}
			if ( !Sql.IsEmptyString(sNAME) || !Sql.IsEmptyString(sPRODUCT_TEMPLATE_ID) || !Sql.IsEmptyString(sMFT_PART_NUM) )
			{
				this.AjaxError(sLayoutPanel, '');
				bValid = false;
			}
		}
	}
	return bValid;
}

EditLineItemsViewUI.prototype.GetValues = function(sLayoutPanel)
{
	var arrLineItems = new Array();
	var tblMain = document.getElementById(sLayoutPanel + '_ctlEditLineItemsView_grdMain');
	for ( var i = 0; i < tblMain.rows.length; i++ )
	{
		var tr = tblMain.rows[i];
		if ( tr.EDIT_MODE == 'ReadOnly' )
		{
			var row = tr;
			var oLineItem = new Object();
			oLineItem.ID                    = Sql.ToString (row['ID'                   ]);
			oLineItem.LINE_GROUP_ID         = Sql.ToString (row['LINE_GROUP_ID'        ]);
			oLineItem.LINE_ITEM_TYPE        = Sql.ToString (row['LINE_ITEM_TYPE'       ]);
			oLineItem.PRODUCT_TEMPLATE_ID   = Sql.ToString (row['PRODUCT_TEMPLATE_ID'  ]);
			oLineItem.PARENT_TEMPLATE_ID    = Sql.ToString (row['PARENT_TEMPLATE_ID'   ]);
			oLineItem.PREVIOUS_NAME         = Sql.ToString (row['PREVIOUS_NAME'        ]);
			oLineItem.VENDOR_PART_NUM       = Sql.ToString (row['VENDOR_PART_NUM'      ]);
			oLineItem.PREVIOUS_MFT_PART_NUM = Sql.ToString (row['PREVIOUS_MFT_PART_NUM']);
			oLineItem.QUANTITY              = Sql.ToDecimal(row['QUANTITY'             ]);
			oLineItem.NAME                  = Sql.ToString (row['NAME'                 ]);
			oLineItem.DESCRIPTION           = Sql.ToString (row['DESCRIPTION'          ]);
			oLineItem.MFT_PART_NUM          = Sql.ToString (row['MFT_PART_NUM'         ]);
			oLineItem.TAX_CLASS             = Sql.ToString (row['TAX_CLASS'            ]);
			oLineItem.TAXRATE_ID            = Sql.ToString (row['TAXRATE_ID'           ]);
			oLineItem.COST_PRICE            = Sql.ToDecimal(row['COST_PRICE'           ]);
			oLineItem.LIST_PRICE            = Sql.ToDecimal(row['LIST_PRICE'           ]);
			oLineItem.UNIT_PRICE            = Sql.ToDecimal(row['UNIT_PRICE'           ]);
			oLineItem.EXTENDED_PRICE        = Sql.ToDecimal(row['EXTENDED_PRICE'       ]);
			oLineItem.TAX                   = Sql.ToDecimal(row['TAX'                  ]);
			oLineItem.DISCOUNT_ID           = Sql.ToString (row['DISCOUNT_ID'          ]);
			oLineItem.PRICING_FORMULA       = Sql.ToString (row['PRICING_FORMULA'      ]);
			oLineItem.PRICING_FACTOR        = Sql.ToDecimal(row['PRICING_FACTOR'       ]);
			oLineItem.DISCOUNT_PRICE        = Sql.ToDecimal(row['DISCOUNT_PRICE'       ]);
			if ( this.PRIMARY_MODULE == 'Opportunities' )
			{
				oLineItem.DATE_CLOSED      = Sql.ToString (row['DATE_CLOSED'     ]);
				oLineItem.OPPORTUNITY_TYPE = Sql.ToString (row['OPPORTUNITY_TYPE']);
				oLineItem.LEAD_SOURCE      = Sql.ToString (row['LEAD_SOURCE'     ]);
				oLineItem.NEXT_STEP        = Sql.ToString (row['NEXT_STEP'       ]);
				oLineItem.SALES_STAGE      = Sql.ToString (row['SALES_STAGE'     ]);
				oLineItem.PROBABILITY      = Sql.ToDecimal(row['PROBABILITY'     ]);
			}
			arrLineItems.push(oLineItem);
		}
	}
	return arrLineItems;
}

