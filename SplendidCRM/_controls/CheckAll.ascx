<%@ Control Language="c#" AutoEventWireup="false" Codebehind="CheckAll.ascx.cs" Inherits="SplendidCRM._controls.CheckAll" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
<script runat="server">
/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
</script>
<script type="text/javascript">
var sSelectedLabelFormat = '<%= L10n.Term(".LBL_SELECTED") %>';

function ValidateOne()
{
	if ( SelectedCount('<%= sFieldName %>') < 1 )
	{
		alert('<%= Sql.EscapeJavaScript(L10n.Term(".LBL_LISTVIEW_NO_SELECTED")) %>');
		return false;
	}
	return true;
}
function ValidateTwo()
{
	if ( SelectedCount('<%= sFieldName %>') < 2 )
	{
		alert('<%= Sql.EscapeJavaScript(L10n.Term(".LBL_LISTVIEW_TWO_REQUIRED")) %>');
		return false;
	}
	return true;
}

function SplendidGrid_CheckAll(value)
{
	var fld = document.forms[0]['<%= sFieldName %>'];
	if ( fld != undefined )
	{
		if ( fld.length == undefined )
		{
			if ( fld.type == 'checkbox' )
			{
				fld.checked = value;
				SplendidGrid_ToggleCheckbox(fld);
			}
		}
		else
		{
			for (i = 0; i < fld.length; i++)
			{
				if ( fld[i].type == 'checkbox' )
				{
					fld[i].checked = value;
					SplendidGrid_ToggleCheckbox(fld[i]);
				}
			}
		}
		if ( !value )
		{
			var fldSelectedLabelClientID = document.getElementById('<%= lblSelectedLabel.ClientID %>');
			var fldSelectedItemsClientID = document.getElementById('<%= hidSelectedItems.ClientID %>');
			if ( fldSelectedItemsClientID != null )
				fldSelectedItemsClientID.value = '';
			if ( fldSelectedLabelClientID != null )
				fldSelectedLabelClientID.innerHTML = sSelectedLabelFormat.replace('{0}', Math.floor((fldSelectedItemsClientID.value.length+1)/37));
		}
	}
}

// 11/27/2010 Paul.  Special functions to add and remove checkbox values from a hidden field. 
function SplendidGrid_ToggleCheckbox(chk)
{
	var fldSelectedLabelClientID = document.getElementById('<%= lblSelectedLabel.ClientID %>');
	var fldSelectedItemsClientID = document.getElementById('<%= hidSelectedItems.ClientID %>');
	if ( fldSelectedItemsClientID != null )
	{
		if ( chk.checked )
		{
			if ( fldSelectedItemsClientID.value.indexOf(chk.value) < 0 )
			{
				if ( fldSelectedItemsClientID.value.length > 0 )
					fldSelectedItemsClientID.value += ',';
				fldSelectedItemsClientID.value += chk.value;
			}
		}
		else
		{
			// 09/20/2013 Paul.  New method of removing an item from a comma-separated string. 
			var arr = fldSelectedItemsClientID.value.split(',');
			var i = arr.indexOf(chk.value);
			if ( i != -1 )
				arr.splice(i, 1);
			fldSelectedItemsClientID.value = arr.join(',');
		}
		if ( fldSelectedLabelClientID != null )
		{
			// 09/20/2013 Paul.  Need a new method for counting items that is not guid-specific. 
			var nItems = 0;
			if ( chk.name == 'chkMain' )
				nItems = Math.floor((fldSelectedItemsClientID.value.length+1)/37);
			else if ( fldSelectedItemsClientID.value.length > 0 )
				nItems = fldSelectedItemsClientID.value.split(',').length;
			fldSelectedLabelClientID.innerHTML = sSelectedLabelFormat.replace('{0}', nItems);
		}
	}
}

</script>
<asp:Panel ID="pnlCheckAll" Visible="<%# !SplendidDynamic.StackedLayout(Page.Theme) %>" style="display: inline-block;" runat="server">
	<asp:HyperLink ID="lnkSelectPage" NavigateUrl='<%# "javascript:SplendidGrid_CheckAll(1);" %>' Text='<%# L10n.Term(".LBL_SELECT_PAGE") %>' CssClass="listViewCheckLink" runat="server" />
	<asp:Literal Text=" - " runat="server" />
	<asp:LinkButton ID="btnSelectAll" Visible="<%# bShowSelectAll %>" Text='<%# L10n.Term(".LBL_SELECT_ALL") %>' CommandName="SelectAll" OnCommand="Page_Command" CssClass="listViewCheckLink" runat="server" />
	<asp:Literal Text=" - " Visible="<%# bShowSelectAll %>" runat="server" />
	<asp:HyperLink ID="lnkDeselectAll" NavigateUrl='<%# "javascript:SplendidGrid_CheckAll(0);" %>' Text='<%# L10n.Term(".LBL_DESELECT_ALL") %>' CssClass="listViewCheckLink" runat="server" />
	&nbsp;
</asp:Panel>
<asp:Label ID="lblSelectedLabel" runat="server" />
<asp:HiddenField ID="hidSelectedItems" runat="server" />
<div class="CheckAllPaddingBottom">
</div>

