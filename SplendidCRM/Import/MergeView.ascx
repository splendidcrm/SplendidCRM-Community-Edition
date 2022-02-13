<%@ Control Language="C#" AutoEventWireup="false" CodeBehind="MergeView.ascx.cs" Inherits="SplendidCRM.Import.MergeView" %>
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
<div id="divMergeView">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EnableModuleLabel="false" EnablePrint="true" HelpName="MergeView" EnableHelp="true" Runat="Server" />
	
	<script type="text/javascript">
	function CopyTextField(idDest, idSrc)
	{
		try
		{
			//alert('CopyTextField(' + idDest + ',' + idSrc + ')');
			var fldDest = document.getElementById(idDest);
			var fldSrc  = document.getElementById(idSrc );
			if ( fldDest == null ) alert('Could not find destiation field: ' + idDest);
			if ( fldSrc  == null ) alert('Could not find source field: ' + idSrc);
			if ( fldDest != null && fldSrc != null )
			{
				fldDest.value = fldSrc.innerHTML;
			}
		}
		catch(e)
		{
			alert(e);
		}
		return false;
	}
	function CopyHtmlField(idDest, idSrc)
	{
		try
		{
			//alert('CopyHtmlField(' + idDest + ',' + idSrc + ')');
			// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
			var fldDest = CKEDITOR.instances[idDest];
			var fldSrc  = document.getElementById(idSrc );
			if ( fldDest == null ) alert('Could not find destiation field: ' + idDest);
			if ( fldSrc  == null ) alert('Could not find source field: ' + idSrc);
			if ( fldDest != null && fldSrc != null )
			{
				if ( fldDest.EditMode == 0 )
					fldDest.SetHTML(fldSrc.innerHTML);
				else
					fldDest.SetData(fldSrc.innerHTML);
			}
		}
		catch(e)
		{
			alert(e);
		}
		return false;
	}
	function CopyInputField(idDest, idSrc)
	{
		try
		{
			//alert('CopyTextField(' + idDest + ',' + idSrc + ')');
			var fldDest = document.getElementById(idDest);
			var fldSrc  = document.getElementById(idSrc );
			if ( fldDest == null ) alert('Could not find destiation field: ' + idDest);
			if ( fldSrc  == null ) alert('Could not find source field: ' + idSrc);
			if ( fldDest != null && fldSrc != null )
			{
				fldDest.value = fldSrc.value;
			}
		}
		catch(e)
		{
			alert(e);
		}
		return false;
	}
	function CopyListField(idDest, idSrc)
	{
		try
		{
			//alert('CopyListField(' + idDest + ',' + idSrc + ')');
			var fldDest = document.getElementById(idDest);
			var fldSrc  = document.getElementById(idSrc );
			if ( fldDest == null ) alert('Could not find destiation field: ' + idDest);
			if ( fldSrc  == null ) alert('Could not find source field: ' + idSrc);
			for ( i=0; i < fldDest.options.length; i++ )
			{
				if ( fldDest.options[i].value == fldSrc.innerHTML )
				{
					fldDest.options.selectedIndex = i;
					break;
				}
			}
		}
		catch(e)
		{
			alert(e);
		}
		return false;
	}
	function SetListFields(idDest, arrValues)
	{
		try
		{
			//alert('SetListFields(' + idDest + ',' + idSrc + ')');
			var fldDest = document.getElementById(idDest);
			if ( fldDest == null ) alert('Could not find destiation field: ' + idDest);
			for ( i=0; i < fldDest.options.length; i++ )
			{
				fldDest.options[i].selected = false;
				for ( j=0; j < arrValues.length; j++ )
				{
					if ( arrValues[j] == fldDest.options[i].value )
						fldDest.options[i].selected = true;
				}
			}
		}
		catch(e)
		{
			alert(e);
		}
		return false;
	}
	function SetCheckBoxListFields(idDest, arrValues)
	{
		try
		{
			//alert('SetCheckBoxListFields(' + idDest + ')');
			for ( i=0; ; i++ )
			{
				var fldDest = document.getElementById(idDest + '_' + i);
				if ( fldDest == null )
					break;
				fldDest.checked = false;
				for ( j=0; j < arrValues.length; j++ )
				{
					if ( arrValues[j] == fldDest.nextSibling.innerHTML )
						fldDest.checked = true;
				}
			}
		}
		catch(e)
		{
			alert(e);
		}
		return false;
	}
	function SetRadioFields(idDest, sValue)
	{
		try
		{
			//alert('SetRadioFields(' + idDest + ')');
			var fldDest = document.getElementsByName(idDest);
			if ( fldDest == null ) alert('Could not find destiation field: ' + idDest);
			for ( i=0; i < fldDest.length; i++ )
			{
				fldDest[i].checked = false;
				if ( sValue == fldDest[i].value )
					fldDest[i].checked = true;
			}
		}
		catch(e)
		{
			alert(e);
		}
		return false;
	}
	function CopyCheckboxField(idDest, idSrc)
	{
		try
		{
			var fldDest = document.getElementById(idDest);
			var fldSrc  = document.getElementById(idSrc );
			if ( fldDest == null ) alert('Could not find destiation field: ' + idDest);
			if ( fldSrc  == null ) alert('Could not find source field: ' + idSrc);
			if ( fldDest != null && fldSrc != null )
			{
				fldDest.checked = (fldSrc.innerHTML == 'true');
			}
		}
		catch(e)
		{
			alert(e);
		}
		return false;
	}
	function SetPrimaryRecord(id)
	{
		var fldPrimaryRecord = document.getElementById('<%= hidPrimaryRecord.ClientID %>');
		var fldSetPrimary    = document.getElementById('<%= btnSetPrimary.ClientID %>');
		fldPrimaryRecord.value = id;
		fldSetPrimary.click();
		return false;
	}
	function RemoveRecord(id)
	{
		var fldRemoveRecord = document.getElementById('<%= hidRemoveRecord.ClientID %>');
		var fldRemove       = document.getElementById('<%= btnRemove.ClientID %>');
		fldRemoveRecord.value = id;
		fldRemove.click();
		return false;
	}
	</script>

	<asp:Button ID="btnSetPrimary" Text="SetPrimary" CommandName="SetPrimary" OnCommand="Page_Command" style="display:none" runat="server" />
	<asp:Button ID="btnRemove"     Text="Remove"     CommandName="Remove"     OnCommand="Page_Command" style="display:none" runat="server" />
	<asp:HiddenField ID="hidRecords"         runat="server" />
	<asp:HiddenField ID="hidPrimaryRecord"   runat="server" />
	<asp:HiddenField ID="hidRemoveRecord"    EnableViewState="false" runat="server" />
	<asp:HiddenField ID="hidRecordCount"     runat="server" />
	<asp:HiddenField ID="hidDifferentFields" runat="server" />
	<asp:HiddenField ID="hidSimilarFields"   runat="server" />
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<div><asp:Label Text='<%# L10n.Term("Merge.LBL_DIFF_COL_VALUES") %>' Font-Bold="true" runat="server" /></div>
				<table ID="tblMain" class="tabEditView" runat="server">
				</table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<div><asp:Label Text='<%# L10n.Term("Merge.LBL_SAME_COL_VALUES") %>' Font-Bold="true" runat="server" /></div>
				<table ID="tblSimilar" class="tabEditView" runat="server">
				</table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

</div>

