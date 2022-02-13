<%@ Control Language="c#" AutoEventWireup="false" Codebehind="NewRecord.ascx.cs" Inherits="SplendidCRM.Administration.DynamicLayout.DetailViews.NewRecord" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<SplendidCRM:InlineScript runat="server">
	<script type="text/javascript">
	function ChangeLayoutField(sPARENT_ID, sPARENT_NAME)
	{
		document.getElementById('<%= txtLAYOUT_FIELD_ID.ClientID %>').value = sPARENT_ID;
		document.getElementById('<%= btnLAYOUT_FIELD.ClientID %>').click();
	}
	function LayoutFieldSelect()
	{
		return window.open('Popup.aspx', 'LayoutFieldSelect', '<%= SplendidCRM.Crm.Config.PopupWindowOptions() %>');
	}
	</script>
</SplendidCRM:InlineScript>
<div id="divNewRecord">
	<asp:HiddenField ID="txtLAYOUT_FIELD_ID" Runat="server" />
	<asp:Button ID="btnLAYOUT_FIELD" Text="Layout Field Submit" OnClick="btnLAYOUT_FIELD_Click" style="display:none;" runat="server" />
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader ID="ctlListHeader" Title="DynamicLayout.LBL_DETAIL_VIEW_FIELD" Runat="Server" />

	<asp:Table SkinID="tabEditViewButtons" Visible="<%# !PrintView %>" runat="server">
		<asp:TableRow>
			<asp:TableCell ID="tdButtons" Width="10%" Wrap="false">
				<asp:Button ID="btnSave"   CommandName="NewRecord.Save"   OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_SAVE_BUTTON_LABEL"  ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_SAVE_BUTTON_TITLE"  ) %>' Runat="server" />&nbsp;
				<asp:Button ID="btnCancel" CommandName="NewRecord.Cancel" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_CANCEL_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE") %>' Runat="server" />&nbsp;
				<asp:Button ID="btnCopy"   UseSubmitBehavior="false" OnClientClick="LayoutFieldSelect(); return false;" CssClass="button" Text='<%# "  " + L10n.Term("DynamicLayout.LBL_COPY_BUTTON_LABEL"  ) + "  " %>' ToolTip='<%# L10n.Term("DynamicLayout.LBL_COPY_BUTTON_TITLE"  ) %>' Runat="server" />&nbsp;
			</asp:TableCell>
			<asp:TableCell>
				<asp:RequiredFieldValidator ID="reqNAME" ControlToValidate="txtDATA_FIELD" ErrorMessage="(required)" CssClass="required" Enabled="false" EnableClientScript="false" EnableViewState="false" Runat="server" />
				<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
			</asp:TableCell>
			<asp:TableCell ID="tdRequired" HorizontalAlign="Right" Wrap="false" Visible="false">
				<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" />
				&nbsp;
				<asp:Label Text='<%# L10n.Term(".NTC_REQUIRED") %>' Runat="server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<asp:HiddenField ID="txtFIELD_ID" runat="server" />
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabEditView" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="25%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_FIELD_INDEX") %>' runat="server" /></asp:TableCell>
						<asp:TableCell Width="75%" CssClass="dataField"><asp:Label ID="txtFIELD_INDEX" runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_FIELD_TYPE") %>' runat="server" />&nbsp;<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField">
							<asp:DropDownList ID="lstFIELD_TYPE" OnSelectedIndexChanged="lstFIELD_TYPE_Changed" AutoPostBack="true" Runat="server">
								<asp:ListItem Value="String"    >String</asp:ListItem>
								<asp:ListItem Value="TextBox"   >TextBox</asp:ListItem>
								<asp:ListItem Value="HyperLink" >HyperLink</asp:ListItem>
								<asp:ListItem Value="ModuleLink">ModuleLink</asp:ListItem>
								<asp:ListItem Value="CheckBox"  >CheckBox</asp:ListItem>
								<asp:ListItem Value="Button"    >Button</asp:ListItem>
								<asp:ListItem Value="Image"     >Image</asp:ListItem>
								<asp:ListItem Value="File"      >File</asp:ListItem>
								<asp:ListItem Value="Blank"     >Blank</asp:ListItem>
								<asp:ListItem Value="Line"      >Line</asp:ListItem>
								<asp:ListItem Value="IFrame"    >IFrame</asp:ListItem>
								<asp:ListItem Value="JavaScript">JavaScript</asp:ListItem>
								<asp:ListItem Value="Separator" >Separator</asp:ListItem>
								<asp:ListItem Value="Header"    >Header</asp:ListItem>
								<asp:ListItem Value="Tags"      >Tags</asp:ListItem>
							</asp:DropDownList>
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trDATA_LABEL" runat="server">
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_DATA_LABEL" ) %>' runat="server" />&nbsp; (<asp:CheckBox ID="chkFREE_FORM_LABEL" OnCheckedChanged="chkFREE_FORM_LABEL_CheckedChanged" CssClass="checkbox" AutoPostBack="True" Runat="server" /> <asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_FREE_FORM_DATA" ) %>' runat="server" />)</asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="txtDATA_LABEL"  size="35" Visible="False" Runat="server" /><asp:DropDownList ID="lstDATA_LABEL" DataTextField="DISPLAY_NAME" DataValueField="NAME" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trDATA_FIELD" runat="server">
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_DATA_FIELD" ) %>' runat="server" />(<asp:CheckBox ID="chkFREE_FORM_DATA" OnCheckedChanged="chkFREE_FORM_DATA_CheckedChanged" CssClass="checkbox" AutoPostBack="True" Runat="server" /> <asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_FREE_FORM_DATA" ) %>' runat="server" />)</asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="txtDATA_FIELD"  size="35" Visible="False" Runat="server" /><asp:DropDownList ID="lstDATA_FIELD" DataTextField="ColumnName" DataValueField="ColumnName" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trDATA_FORMAT" runat="server">
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_DATA_FORMAT") %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="txtDATA_FORMAT" size="35" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trURL_FIELD" runat="server">
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_URL_FIELD"  ) %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="txtURL_FIELD"   Columns="75" Rows="3" TextMode="MultiLine" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trURL_FORMAT" runat="server">
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_URL_FORMAT" ) %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="txtURL_FORMAT"  Columns="75" Rows="3" TextMode="MultiLine" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trURL_TARGET" runat="server">
						<asp:TableCell CssClass="dataLabel"><asp:Label ID="lblURL_TARGET" Text='<%# L10n.Term("DynamicLayout.LBL_URL_TARGET" ) %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="txtURL_TARGET"  size="35" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trMODULE_TYPE" Visible="false" runat="server">
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_MODULE_TYPE"      ) %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:DropDownList ID="lstMODULE_TYPE" DataTextField="MODULE_NAME" DataValueField="MODULE_NAME" runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trLIST_NAME" runat="server">
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_LIST_NAME"  ) %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:DropDownList ID="lstLIST_NAME" DataTextField="LIST_NAME" DataValueField="LIST_NAME" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trCOLSPAN" runat="server">
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_COLSPAN"    ) %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="txtCOLSPAN"     size="35" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trTOOL_TIP" runat="server">
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_TOOL_TIP"   ) %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="txtTOOL_TIP"    size="35" runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trPARENT_FIELD" Visible="false" runat="server">
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("DynamicLayout.LBL_PARENT_FIELD"   ) %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="txtPARENT_FIELD"    size="35" runat="server" /></asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

