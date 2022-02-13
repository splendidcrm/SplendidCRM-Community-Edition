<%@ Control Language="c#" AutoEventWireup="false" Codebehind="NewRecord.ascx.cs" Inherits="SplendidCRM.$modulename$.NewRecord" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
<div id="divNewRecord">
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderLeft" Src="~/_controls/HeaderLeft.ascx" %>
	<SplendidCRM:HeaderLeft ID="ctlHeaderLeft" Title="$modulename$.LBL_NEW_FORM_TITLE" Width=<%# uWidth %> Visible="<%# ShowHeader %>" Runat="Server" />

	<asp:Panel ID="pnlMain" Width="100%" CssClass="leftColumnModuleS3" runat="server">
		<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
		<SplendidCRM:DynamicButtons ID="ctlDynamicButtons" Visible="<%# ShowTopButtons && !PrintView %>" Runat="server" />

		<asp:Panel ID="pnlEdit" CssClass="" style="margin-bottom: 4px;" Width=<%# uWidth %> runat="server">
			<asp:Literal Text='<%# "<h4>" + L10n.Term("$modulename$.LBL_NEW_FORM_TITLE") + "</h4>" %>' Visible="<%# ShowInlineHeader %>" runat="server" />
			<table ID="tblMain" class="tabEditView" runat="server">
			</table>
		</asp:Panel>

		<SplendidCRM:DynamicButtons ID="ctlFooterButtons" Visible="<%# ShowBottomButtons && !PrintView %>" Runat="server" />
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
</div>
