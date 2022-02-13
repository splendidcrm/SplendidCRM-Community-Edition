<%@ Control Language="c#" AutoEventWireup="false" Codebehind="DetailView.ascx.cs" Inherits="SplendidCRM.EmailClient.DetailView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
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
<div id="divListView">
	<asp:Table CssClass="tabDetailView" runat="server">
		<asp:TableRow>
			<asp:TableCell CssClass="EmailDetailViewDF" ColumnSpan="2">
				<asp:Table SkinID="tabEditViewButtons" Visible="<%# !PrintView %>" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="10%" Wrap="false">
							<asp:Button CommandName="Reply"       OnCommand="Page_Command" CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term("Emails.LBL_BUTTON_REPLY"           ) + "  " %>' ToolTip='<%# L10n.Term("Emails.LBL_BUTTON_REPLY_TITLE"     ) %>' Runat="server" />
							<asp:Button CommandName="ReplyAll"    OnCommand="Page_Command" CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term("Emails.LBL_BUTTON_REPLY_ALL"       ) + "  " %>' ToolTip='<%# L10n.Term("Emails.LBL_BUTTON_REPLY_ALL_TITLE" ) %>' Runat="server" />
							<asp:Button CommandName="Forward"     OnCommand="Page_Command" CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term("Emails.LBL_BUTTON_FORWARD"         ) + "  " %>' ToolTip='<%# L10n.Term("Emails.LBL_BUTTON_FORWARD_TITLE"   ) %>' Runat="server" />
							<asp:Button CommandName="Delete"      OnCommand="Page_Command" CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term(".LBL_DELETE_BUTTON_LABEL"          ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_DELETE_BUTTON_TITLE"          ) %>' UseSubmitBehavior="false" OnClientClick="return ConfirmDelete();" Runat="server" />
							<asp:Button CommandName="ShowHeaders" OnCommand="Page_Command" CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term("Emails.LBL_BUTTON_VIEW_HEADERS"    ) + "  " %>' ToolTip='<%# L10n.Term("Emails.LBL_BUTTON_VIEW_HEADERS"    ) %>' Runat="server" />
							<asp:Button CommandName="Import"      OnCommand="Page_Command" CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term(".LBL_IMPORT"                       ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_IMPORT"                       ) %>' Runat="server" />
							<asp:Button                                                    CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term("EmailClient.LBL_EMAIL_QUICK_CREATE") + "  " %>' ToolTip='<%# L10n.Term("EmailClient.LBL_EMAIL_QUICK_CREATE") %>' UseSubmitBehavior="false" OnClientClick="toggleDisplay('divEmailClientDetailViewQuickCreate'); return false;" Runat="server" />
							<div id="divEmailClientDetailViewQuickCreate" style="display: none;">
								<br />
								<asp:Button CommandName="QuickCreate" CommandArgument="Bugs"     OnCommand="Page_Command" CssClass="button" style="margin-top: 2px; margin-right: 3px;" Text='<%# "  " + L10n.Term("Bugs.LNK_NEW_BUG"        ) + "  " %>' runat="server" />
								<asp:Button CommandName="QuickCreate" CommandArgument="Cases"    OnCommand="Page_Command" CssClass="button" style="margin-top: 2px; margin-right: 3px;" Text='<%# "  " + L10n.Term("Cases.LNK_NEW_CASE"      ) + "  " %>' runat="server" />
								<asp:Button CommandName="QuickCreate" CommandArgument="Contacts" OnCommand="Page_Command" CssClass="button" style="margin-top: 2px; margin-right: 3px;" Text='<%# "  " + L10n.Term("Contacts.LNK_NEW_CONTACT") + "  " %>' runat="server" />
								<asp:Button CommandName="QuickCreate" CommandArgument="Leads"    OnCommand="Page_Command" CssClass="button" style="margin-top: 2px; margin-right: 3px;" Text='<%# "  " + L10n.Term("Leads.LNK_NEW_LEAD"      ) + "  " %>' runat="server" />
								<asp:Button CommandName="QuickCreate" CommandArgument="Tasks"    OnCommand="Page_Command" CssClass="button" style="margin-top: 2px; margin-right: 3px;" Text='<%# "  " + L10n.Term("Tasks.LNK_NEW_TASK"      ) + "  " %>' runat="server" />
							</div>
						</asp:TableCell>
						<asp:TableCell>
							<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow ID="trFROM" runat="server">
			<asp:TableCell Width="15%" CssClass="EmailDetailViewDL"><%# L10n.Term("Emails.LBL_FROM") %></asp:TableCell>
			<asp:TableCell Width="85%" CssClass="EmailDetailViewDF"><asp:Label ID="txtFROM" Runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow ID="trNAME" runat="server">
			<asp:TableCell CssClass="EmailDetailViewDL"><%# L10n.Term("Emails.LBL_SUBJECT") %></asp:TableCell>
			<asp:TableCell CssClass="EmailDetailViewDF"><asp:Label ID="txtNAME" Font-Bold="true" Runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow ID="trDATE_START" runat="server">
			<asp:TableCell CssClass="EmailDetailViewDL"><%# L10n.Term("Emails.LBL_DATE_SENT") %></asp:TableCell>
			<asp:TableCell CssClass="EmailDetailViewDF"><asp:Label ID="txtDATE_START" Runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow ID="trTO_ADDRS" runat="server">
			<asp:TableCell CssClass="EmailDetailViewDL"><%# L10n.Term("Emails.LBL_TO") %></asp:TableCell>
			<asp:TableCell CssClass="EmailDetailViewDF"><asp:Label ID="txtTO_ADDRS" Runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow ID="trCC_ADDRS" runat="server">
			<asp:TableCell CssClass="EmailDetailViewDL"><%# L10n.Term("Emails.LBL_CC") %></asp:TableCell>
			<asp:TableCell CssClass="EmailDetailViewDF"><asp:Label ID="txtCC_ADDRS" Runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow ID="trINTERNET_HEADERS" runat="server">
			<asp:TableCell ColumnSpan="2">
				<asp:Literal ID="litINTERNET_HEADERS" runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow ID="trATTACHMENTS" runat="server">
			<asp:TableCell CssClass="EmailDetailViewDL"><%# L10n.Term("Emails.LBL_ATTACHMENTS") %></asp:TableCell>
			<asp:TableCell CssClass="EmailDetailViewDF">
				<asp:Repeater ID="rptATTACHMENTS" runat="server">
					<ItemTemplate>
						<asp:HyperLink NavigateUrl='<%# Eval("URL") %>' Text='<%# Eval("FileName") %>' Target="_blank" Runat="server" />&nbsp;
					</ItemTemplate>
				</asp:Repeater>
				<asp:DataGrid ID="grdATTACHMENTS" AutoGenerateColumns="true" runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell VerticalAlign="Top" ColumnSpan="2"><asp:Label ID="txtDESCRIPTION" Runat="server" /></asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

